-- Migration pour le système de formulaires dynamiques
-- 1. Création de la table des types d'équipements
CREATE TABLE IF NOT EXISTS types_equipements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom TEXT NOT NULL UNIQUE,
    lot TEXT NOT NULL,
    icone TEXT,
    champs JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Ajout de la colonne data (JSONB) à la table equipements si elle n'existe pas
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'equipements' AND column_name = 'data') THEN
        ALTER TABLE equipements ADD COLUMN data JSONB DEFAULT '{}'::jsonb;
    END IF;
END $$;

-- 3. Ajout de la colonne photos (JSONB) à la table equipements si elle n'existe pas (pour la nouvelle structure)
-- Note: Si vous utilisez une table séparée 'photos', cette colonne peut servir de cache ou être omise.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'equipements' AND column_name = 'photos') THEN
        ALTER TABLE equipements ADD COLUMN photos JSONB DEFAULT '[]'::jsonb;
    END IF;
END $$;

-- 4. Insertion du type "Radiateur" pour test
INSERT INTO types_equipements (nom, lot, icone, champs)
VALUES (
    'Radiateur', 
    'CVC', 
    '🔥', 
    '[
        {
            "name": "puissance",
            "label": "Puissance (W)",
            "type": "number",
            "unit": "W",
            "required": false
        },
        {
            "name": "type_radiateur",
            "label": "Type de radiateur",
            "type": "select",
            "options": ["Fonte", "Acier", "Panneau rayonnant", "Aluminium"],
            "required": false
        },
        {
            "name": "raccordement",
            "label": "Type de raccordement",
            "type": "select",
            "options": ["Deux tuyaux", "Monotube", "Par le sol"],
            "required": false
        },
        {
            "name": "presence_purge",
            "label": "Purgeur présent",
            "type": "boolean",
            "required": false
        },
        {
            "name": "etat_robinet",
            "label": "État du robinet",
            "type": "select",
            "options": ["Fonctionnel", "Grippé", "Fuyard", "Manquant"],
            "required": true
        }
    ]'::jsonb
)
ON CONFLICT (nom) DO UPDATE 
SET champs = EXCLUDED.champs;

-- 5. Insertion d'un autre type "CTA" pour l'exemple
INSERT INTO types_equipements (nom, lot, icone, champs)
VALUES (
    'CTA', 
    'CVC', 
    '💨', 
    '[
        {
            "name": "debit_air",
            "label": "Débit d''air (m³/h)",
            "type": "number",
            "unit": "m³/h",
            "required": true
        },
        {
            "name": "marque_moteur",
            "label": "Marque du moteur",
            "type": "text",
            "required": false
        },
        {
            "name": "type_filtre",
            "label": "Type de filtre",
            "type": "select",
            "options": ["G4", "F7", "F9", "HEPA"],
            "required": false
        },
        {
            "name": "etat_courroie",
            "label": "État courroie",
            "type": "select",
            "options": ["Bon", "Détendue", "Craquelée", "Rompue"],
            "required": true
        }
    ]'::jsonb
)
ON CONFLICT (nom) DO UPDATE 
SET champs = EXCLUDED.champs;

-- 6. Politique RLS (Sécurité)
ALTER TABLE types_equipements ENABLE ROW LEVEL SECURITY;

-- Tout le monde peut lire les types
CREATE POLICY "Lecture publique types_equipements" 
ON types_equipements FOR SELECT 
USING (true);

-- Seuls les admins (ou authentifiés selon besoin) peuvent modifier
-- Ici on laisse ouvert pour le dev, à restreindre en prod
CREATE POLICY "Modification types_equipements" 
ON types_equipements FOR ALL 
USING (true);
