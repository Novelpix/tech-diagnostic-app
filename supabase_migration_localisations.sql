-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION : Séparation Projet & Localisation / Équipements
-- Date : 2025-11-29
-- Description : Création table localisations + refonte architecture
-- ═══════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────
-- 1. CRÉER LA TABLE LOCALISATIONS
-- ───────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS localisations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Informations projet
    project_name TEXT NOT NULL,
    project_surface TEXT,
    project_address TEXT,
    project_gps TEXT,

    -- Contact et entreprise
    company_name TEXT,
    site_contact_name TEXT,
    site_contact_phone TEXT,

    -- Informations visite
    technician_name TEXT,
    visit_date TEXT,
    weather_conditions TEXT,
    type_visite TEXT,

    -- Métadonnées
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ───────────────────────────────────────────────────────────────────────
-- 2. ACTIVER RLS SUR LOCALISATIONS
-- ───────────────────────────────────────────────────────────────────────

ALTER TABLE localisations ENABLE ROW LEVEL SECURITY;

-- Politiques RLS (publiques pour développement)
-- ⚠️ PRODUCTION : Remplacer "using (true)" par "using (auth.uid() = user_id)"

CREATE POLICY "localisations_select_policy" ON localisations FOR SELECT USING (true);
CREATE POLICY "localisations_insert_policy" ON localisations FOR INSERT WITH CHECK (true);
CREATE POLICY "localisations_update_policy" ON localisations FOR UPDATE USING (true);
CREATE POLICY "localisations_delete_policy" ON localisations FOR DELETE USING (true);

-- ───────────────────────────────────────────────────────────────────────
-- 3. MODIFIER LA TABLE EQUIPEMENTS
-- ───────────────────────────────────────────────────────────────────────

-- Ajouter la colonne localisation_id (référence vers localisations)
ALTER TABLE equipements
ADD COLUMN IF NOT EXISTS localisation_id UUID REFERENCES localisations(id) ON DELETE CASCADE;

-- Créer un index pour améliorer les performances des JOINs
CREATE INDEX IF NOT EXISTS idx_equipements_localisation
ON equipements(localisation_id);

-- ───────────────────────────────────────────────────────────────────────
-- 4. NOTES DE MIGRATION
-- ───────────────────────────────────────────────────────────────────────

-- ✅ Les champs suivants RESTENT dans la table equipements :
--    - lot (lot_technique)
--    - niveau (niveau_etage)
--    - local (local_zone)
--    - heure_debut
--    - heure_fin
--    - latitude, longitude (gps_capture spécifique à l'équipement)
--    - data (JSONB contenant designation, marque, etc.)

-- ✅ Les champs suivants sont maintenant dans localisations :
--    - project_name (nouveau)
--    - project_surface (nouveau)
--    - project_address (nouveau)
--    - project_gps (nouveau)
--    - company_name (était "entreprise")
--    - site_contact_name (nouveau)
--    - site_contact_phone (nouveau)
--    - technician_name (était "technicien")
--    - visit_date (était "date_visite")
--    - weather_conditions (nouveau)
--    - type_visite (nouveau)

-- ⚠️ ATTENTION : Les anciennes colonnes de equipements (technicien, entreprise, date_visite)
--    sont conservées pour compatibilité. Elles ne seront plus utilisées par l'interface.
--    Elles pourront être supprimées ultérieurement si nécessaire.

-- ═══════════════════════════════════════════════════════════════════════
-- FIN DE LA MIGRATION
-- ═══════════════════════════════════════════════════════════════════════
