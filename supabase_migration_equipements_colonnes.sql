-- ═══════════════════════════════════════════════════════════════════════
-- MIGRATION : Ajout des colonnes manquantes à la table equipements
-- Date : 2025-12-02
-- Description : Colonnes pour les champs métier (hors projet/localisation)
-- ═══════════════════════════════════════════════════════════════════════

-- ⚠️ IMPORTANT :
-- Les champs projet/localisation (date, technicien, entreprise, etc.)
-- sont maintenant dans la table "localisations" (voir supabase_migration_localisations.sql)
-- Ce script ajoute UNIQUEMENT les colonnes spécifiques aux équipements

ALTER TABLE equipements

-- ───────────────────────────────────────────────────────────────────────
-- INFORMATIONS ÉQUIPEMENT (spécifiques à chaque équipement)
-- ───────────────────────────────────────────────────────────────────────

-- Lot et localisation dans le bâtiment
ADD COLUMN IF NOT EXISTS lot TEXT,
ADD COLUMN IF NOT EXISTS niveau TEXT,
ADD COLUMN IF NOT EXISTS local TEXT,
ADD COLUMN IF NOT EXISTS heureDebut TEXT,
ADD COLUMN IF NOT EXISTS heureFin TEXT,

-- Identification équipement
ADD COLUMN IF NOT EXISTS type TEXT,
ADD COLUMN IF NOT EXISTS code TEXT,           -- Repère équipement (ex: EC-RDC-01)
ADD COLUMN IF NOT EXISTS qrCode TEXT,
ADD COLUMN IF NOT EXISTS refDOE TEXT,
ADD COLUMN IF NOT EXISTS refPlan TEXT,

-- Caractéristiques techniques
ADD COLUMN IF NOT EXISTS marque TEXT,
ADD COLUMN IF NOT EXISTS modele TEXT,
ADD COLUMN IF NOT EXISTS serie TEXT,
ADD COLUMN IF NOT EXISTS puissance TEXT,
ADD COLUMN IF NOT EXISTS unite TEXT,
ADD COLUMN IF NOT EXISTS annee TEXT,

-- ───────────────────────────────────────────────────────────────────────
-- CHAMPS SPÉCIFIQUES PAR TYPE D'ÉQUIPEMENT
-- ───────────────────────────────────────────────────────────────────────

-- 💧 Compteurs d'eau
ADD COLUMN IF NOT EXISTS waterMeterType TEXT,
ADD COLUMN IF NOT EXISTS waterMeterSerial TEXT,
ADD COLUMN IF NOT EXISTS waterMeterField TEXT,
ADD COLUMN IF NOT EXISTS waterMeterGTB TEXT,
ADD COLUMN IF NOT EXISTS waterMeterDiff TEXT,
ADD COLUMN IF NOT EXISTS waterMeterLastRead TEXT,
ADD COLUMN IF NOT EXISTS waterMeterCoherence TEXT,
ADD COLUMN IF NOT EXISTS waterMeterObs TEXT,

-- 🌬️ Débits air sanitaires
ADD COLUMN IF NOT EXISTS sanitaryType TEXT,
ADD COLUMN IF NOT EXISTS sanitaryLocation TEXT,
ADD COLUMN IF NOT EXISTS airFlowMeasured TEXT,
ADD COLUMN IF NOT EXISTS airFlowRegulation TEXT,
ADD COLUMN IF NOT EXISTS airFlowCompliance TEXT,
ADD COLUMN IF NOT EXISTS airFlowVents TEXT,
ADD COLUMN IF NOT EXISTS airFlowVentsState TEXT,
ADD COLUMN IF NOT EXISTS airFlowObs TEXT,

-- 🖥️ GTB (Gestion Technique du Bâtiment)
ADD COLUMN IF NOT EXISTS gtbSoftware TEXT,
ADD COLUMN IF NOT EXISTS gtbVersion TEXT,
ADD COLUMN IF NOT EXISTS gtbPoints TEXT,
ADD COLUMN IF NOT EXISTS gtbPointsFault TEXT,
ADD COLUMN IF NOT EXISTS gtbAvailability TEXT,
ADD COLUMN IF NOT EXISTS gtbLastUpdate TEXT,
ADD COLUMN IF NOT EXISTS gtbAnomalies TEXT,

-- 🧪 Qualité eau
ADD COLUMN IF NOT EXISTS waterQualityCircuit TEXT,
ADD COLUMN IF NOT EXISTS waterQualityPoint TEXT,
ADD COLUMN IF NOT EXISTS waterQualityPH TEXT,
ADD COLUMN IF NOT EXISTS waterQualityConductivity TEXT,
ADD COLUMN IF NOT EXISTS waterQualityTemp TEXT,
ADD COLUMN IF NOT EXISTS waterQualityHardness TEXT,
ADD COLUMN IF NOT EXISTS waterQualityTAC TEXT,
ADD COLUMN IF NOT EXISTS waterQualityTurbidity TEXT,
ADD COLUMN IF NOT EXISTS waterQualityChlorine TEXT,
ADD COLUMN IF NOT EXISTS waterQualityIron TEXT,
ADD COLUMN IF NOT EXISTS waterQualityTreatment TEXT,
ADD COLUMN IF NOT EXISTS waterQualityObs TEXT,

-- ───────────────────────────────────────────────────────────────────────
-- ÉVALUATION ET ANOMALIES
-- ───────────────────────────────────────────────────────────────────────

ADD COLUMN IF NOT EXISTS ev INTEGER,
ADD COLUMN IF NOT EXISTS crit TEXT,
ADD COLUMN IF NOT EXISTS type_anomalie TEXT,
ADD COLUMN IF NOT EXISTS budget TEXT,
ADD COLUMN IF NOT EXISTS priorite TEXT,

-- Constats et observations
ADD COLUMN IF NOT EXISTS constat TEXT,
ADD COLUMN IF NOT EXISTS observations TEXT,
ADD COLUMN IF NOT EXISTS actions TEXT,

-- GPS spécifique à l'équipement (différent du GPS projet)
ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION,
ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION,

-- Métadonnées
ADD COLUMN IF NOT EXISTS timestamp TIMESTAMPTZ;

-- ───────────────────────────────────────────────────────────────────────
-- INDEX POUR AMÉLIORER LES PERFORMANCES
-- ───────────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_equipements_lot ON equipements(lot);
CREATE INDEX IF NOT EXISTS idx_equipements_code ON equipements(code);
CREATE INDEX IF NOT EXISTS idx_equipements_timestamp ON equipements(timestamp);
CREATE INDEX IF NOT EXISTS idx_equipements_lot_code ON equipements(lot, code);

-- ───────────────────────────────────────────────────────────────────────
-- COMMENTAIRES POUR DOCUMENTATION
-- ───────────────────────────────────────────────────────────────────────

COMMENT ON COLUMN equipements.lot IS 'Lot technique (Structure, CVC, Électricité, etc.)';
COMMENT ON COLUMN equipements.code IS 'Repère équipement (ex: EC-RDC-01, CH-R1-02)';
COMMENT ON COLUMN equipements.niveau IS 'Niveau/Étage (ex: RDC, R+1, SS1)';
COMMENT ON COLUMN equipements.local IS 'Local/Zone (ex: Local technique, Chaufferie)';
COMMENT ON COLUMN equipements.ev IS 'État visuel (0=Bon, 1=Moyen, 2=Dégradé, 3=Critique, 4=Danger)';
COMMENT ON COLUMN equipements.crit IS 'Criticité (U=Urgent, I=Important, A=À surveiller, S=Sécuritaire)';
COMMENT ON COLUMN equipements.timestamp IS 'Date et heure de création de la fiche';
COMMENT ON COLUMN equipements.localisation_id IS 'Référence vers la table localisations (projet/visite)';

-- ═══════════════════════════════════════════════════════════════════════
-- FIN DE LA MIGRATION
-- ═══════════════════════════════════════════════════════════════════════

-- ⚠️ IMPORTANT : Exécuter APRÈS supabase_migration_localisations.sql
-- La colonne localisation_id (FK) a déjà été créée par le premier script.
