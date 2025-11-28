-- ═══════════════════════════════════════════════════════════════════════════════
-- NETTOYAGE COMPLET DU SCHÉMA SUPABASE - TABLE EQUIPEMENTS
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Ce script corrige toutes les incohérences de noms de colonnes :
-- - Supprime les colonnes en lowercase (sans quotes)
-- - Crée les colonnes en camelCase (avec quotes pour préserver la casse)
-- - Nettoie les doublons
--
-- ⚠️ ATTENTION : Exécutez ce script dans l'éditeur SQL de Supabase
-- ⚠️ Sauvegardez vos données avant exécution si nécessaire
--
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- ÉTAPE 1 : SUPPRESSION DES COLONNES EN LOWERCASE (DOUBLONS)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Informations générales (doublons lowercase)
ALTER TABLE equipements DROP COLUMN IF EXISTS contactsite;
ALTER TABLE equipements DROP COLUMN IF EXISTS heuredebut;
ALTER TABLE equipements DROP COLUMN IF EXISTS heurefin;
ALTER TABLE equipements DROP COLUMN IF EXISTS telreferent;
ALTER TABLE equipements DROP COLUMN IF EXISTS typevisite;
ALTER TABLE equipements DROP COLUMN IF EXISTS refdoe;
ALTER TABLE equipements DROP COLUMN IF EXISTS refplan;
ALTER TABLE equipements DROP COLUMN IF EXISTS qrcode;

-- Compteur d'eau (doublons lowercase)
ALTER TABLE equipements DROP COLUMN IF EXISTS watermetertype;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterserial;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterfield;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermetergtb;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterdiff;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterlastread;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterMetercoherence;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterobs;

-- Débits air (doublons lowercase)
ALTER TABLE equipements DROP COLUMN IF EXISTS sanitarytype;
ALTER TABLE equipements DROP COLUMN IF EXISTS sanitarylocation;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowmeasured;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowregulation;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowcompliance;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowvents;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowventsstate;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowobs;

-- GTB (doublons lowercase)
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbsoftware;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbversion;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbpoints;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbpointsfault;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbavailability;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtblastupdate;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbanomalies;

-- Qualité eau (doublons lowercase)
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitycircuit;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitypoint;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityph;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityconductivity;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitytemp;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityhardness;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitytac;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityturbidity;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitychlorine;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityiron;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitytreatment;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityobs;

-- Anciennes colonnes snake_case (remplacées par camelCase)
ALTER TABLE equipements DROP COLUMN IF EXISTS heure_debut;
ALTER TABLE equipements DROP COLUMN IF EXISTS heure_fin;
ALTER TABLE equipements DROP COLUMN IF EXISTS contact_site;
ALTER TABLE equipements DROP COLUMN IF EXISTS tel_referent;
ALTER TABLE equipements DROP COLUMN IF EXISTS type_visite;
ALTER TABLE equipements DROP COLUMN IF EXISTS ref_doe;
ALTER TABLE equipements DROP COLUMN IF EXISTS ref_plan;
ALTER TABLE equipements DROP COLUMN IF EXISTS qr_code;
ALTER TABLE equipements DROP COLUMN IF EXISTS date_visite;

-- ═══════════════════════════════════════════════════════════════════════════════
-- ÉTAPE 2 : CRÉATION DES COLONNES CAMELCASE (AVEC QUOTES)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Informations générales
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS lot TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS date TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "heureDebut" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "heureFin" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS technicien TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS entreprise TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "contactSite" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "telReferent" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS meteo TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "typeVisite" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS niveau TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS local TEXT;

-- Identification équipement
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS type TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS code TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "qrCode" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "refDOE" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "refPlan" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS marque TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS modele TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS serie TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS puissance TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS unite TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS annee TEXT;

-- Compteur d'eau
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterMeterType" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterMeterSerial" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterMeterField" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterMeterGTB" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterMeterDiff" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterMeterLastRead" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterMeterCoherence" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterMeterObs" TEXT;

-- Débits air sanitaires
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "sanitaryType" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "sanitaryLocation" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "airFlowMeasured" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "airFlowRegulation" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "airFlowCompliance" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "airFlowVents" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "airFlowVentsState" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "airFlowObs" TEXT;

-- GTB
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "gtbSoftware" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "gtbVersion" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "gtbPoints" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "gtbPointsFault" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "gtbAvailability" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "gtbLastUpdate" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "gtbAnomalies" TEXT;

-- Qualité eau
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityCircuit" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityPoint" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityPH" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityConductivity" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityTemp" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityHardness" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityTAC" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityTurbidity" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityChlorine" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityIron" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityTreatment" TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS "waterQualityObs" TEXT;

-- Évaluation et anomalies
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS ev INTEGER;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS crit TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS type_anomalie TEXT;  -- ⚠️ snake_case (comme dans le code)
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS budget TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS priorite TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS constat TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS observations TEXT;
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS actions TEXT;

-- Métadonnées
ALTER TABLE equipements ADD COLUMN IF NOT EXISTS timestamp TIMESTAMPTZ;

-- ═══════════════════════════════════════════════════════════════════════════════
-- ÉTAPE 3 : CRÉATION DES INDEX POUR PERFORMANCES
-- ═══════════════════════════════════════════════════════════════════════════════

DROP INDEX IF EXISTS idx_equipements_lot;
DROP INDEX IF EXISTS idx_equipements_code;
DROP INDEX IF EXISTS idx_equipements_timestamp;
DROP INDEX IF EXISTS idx_equipements_lot_code_timestamp;

CREATE INDEX idx_equipements_lot ON equipements(lot);
CREATE INDEX idx_equipements_code ON equipements(code);
CREATE INDEX idx_equipements_timestamp ON equipements(timestamp);
CREATE INDEX idx_equipements_lot_code_timestamp ON equipements(lot, code, timestamp);

-- ═══════════════════════════════════════════════════════════════════════════════
-- ÉTAPE 4 : COMMENTAIRES POUR DOCUMENTATION
-- ═══════════════════════════════════════════════════════════════════════════════

COMMENT ON COLUMN equipements.lot IS 'Lot technique (Structure, CVC, etc.)';
COMMENT ON COLUMN equipements.code IS 'Code unique de l''équipement';
COMMENT ON COLUMN equipements.ev IS 'État visuel (0-4)';
COMMENT ON COLUMN equipements.crit IS 'Criticité (U/I/A/S)';
COMMENT ON COLUMN equipements.type_anomalie IS 'Type d''anomalie';
COMMENT ON COLUMN equipements.timestamp IS 'Date et heure de création';

-- ═══════════════════════════════════════════════════════════════════════════════
-- ✅ SCRIPT TERMINÉ
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Toutes les colonnes sont maintenant cohérentes avec le code :
-- - Noms en camelCase (avec quotes) pour tous les champs
-- - Sauf type_anomalie qui reste en snake_case
-- - Tous les doublons lowercase supprimés
-- - Index créés pour optimiser les requêtes
--
-- ═══════════════════════════════════════════════════════════════════════════════
