-- ═══════════════════════════════════════════════════════════════════════════════
-- SUPPRESSION DES DOUBLONS - VERSION 3 (ULTRA-SIMPLE)
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Ce script SUPPRIME UNIQUEMENT les doublons identifiés.
-- Il ne crée AUCUNE colonne (les camelCase existent déjà).
--
-- ⚠️ ATTENTION : Exécutez ce script dans l'éditeur SQL de Supabase
--
-- Doublons confirmés par l'utilisateur :
-- - heure_fin (trouvé 2 fois)
-- - waterMeterType ET watermetertype
--
-- ═══════════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════════════
-- SUPPRESSION DES DOUBLONS SNAKE_CASE (avec CASCADE pour forcer)
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE equipements DROP COLUMN IF EXISTS heure_debut CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS heure_fin CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS date_visite CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS contact_site CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS tel_referent CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS type_visite CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS ref_doe CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS ref_plan CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS qr_code CASCADE;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SUPPRESSION DES DOUBLONS LOWERCASE (avec CASCADE pour forcer)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Généraux
ALTER TABLE equipements DROP COLUMN IF EXISTS contactsite CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS telreferent CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS typevisite CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS refdoe CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS refplan CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS qrcode CASCADE;

-- Compteur d'eau (celui trouvé par l'utilisateur : watermetertype)
ALTER TABLE equipements DROP COLUMN IF EXISTS watermetertype CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterserial CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterfield CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermetergtb CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterdiff CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterlastread CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS "waterMetercoherence" CASCADE;  -- casse mixte bizarre
ALTER TABLE equipements DROP COLUMN IF EXISTS watermetercoherence CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS watermeterobs CASCADE;

-- Débits air
ALTER TABLE equipements DROP COLUMN IF EXISTS sanitarytype CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS sanitarylocation CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowmeasured CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowregulation CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowcompliance CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowvents CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowventsstate CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS airflowobs CASCADE;

-- GTB
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbsoftware CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbversion CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbpoints CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbpointsfault CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbavailability CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtblastupdate CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS gtbanomalies CASCADE;

-- Qualité eau
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitycircuit CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitypoint CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityph CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityconductivity CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitytemp CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityhardness CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitytac CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityturbidity CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitychlorine CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityiron CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualitytreatment CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS waterqualityobs CASCADE;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SUPPRESSION DES COLONNES OBSOLÈTES (avec CASCADE pour forcer)
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE equipements DROP COLUMN IF EXISTS criticite CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS remarques CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS recommandations CASCADE;

-- ═══════════════════════════════════════════════════════════════════════════════
-- SUPPRESSION DES COLONNES INUTILISÉES (avec CASCADE pour forcer)
-- ═══════════════════════════════════════════════════════════════════════════════

ALTER TABLE equipements DROP COLUMN IF EXISTS data CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS supabase_id CASCADE;

-- ═══════════════════════════════════════════════════════════════════════════════
-- ✅ SCRIPT TERMINÉ
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- Ce script supprime UNIQUEMENT les doublons et colonnes obsolètes.
-- Il ne touche PAS aux colonnes camelCase qui existent déjà.
--
-- Après exécution, vérifiez avec :
-- SELECT column_name FROM information_schema.columns
-- WHERE table_name = 'equipements' ORDER BY column_name;
--
-- ═══════════════════════════════════════════════════════════════════════════════
