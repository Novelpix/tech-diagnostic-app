-- ═══════════════════════════════════════════════════════════════════════
-- SCRIPT DE VÉRIFICATION : Contrôle des colonnes des tables
-- Date : 2025-12-02
-- Description : Vérifie que toutes les colonnes existent dans les tables
-- ═══════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────
-- 1. VÉRIFIER LES COLONNES DE LA TABLE LOCALISATIONS
-- ───────────────────────────────────────────────────────────────────────

SELECT
    '📋 COLONNES TABLE LOCALISATIONS' AS info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'localisations'
ORDER BY ordinal_position;

-- ───────────────────────────────────────────────────────────────────────
-- 2. VÉRIFIER LES COLONNES DE LA TABLE EQUIPEMENTS
-- ───────────────────────────────────────────────────────────────────────

SELECT
    '📋 COLONNES TABLE EQUIPEMENTS' AS info,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'equipements'
ORDER BY ordinal_position;

-- ───────────────────────────────────────────────────────────────────────
-- 3. VÉRIFIER LES COLONNES DYNAMIQUES (Compteur, GTB, Qualité eau, etc.)
-- ───────────────────────────────────────────────────────────────────────

SELECT
    '🔍 COLONNES DYNAMIQUES SPÉCIFIQUES' AS info,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'equipements'
AND (
    column_name LIKE 'waterMeter%' OR
    column_name LIKE 'airFlow%' OR
    column_name LIKE 'gtb%' OR
    column_name LIKE 'waterQuality%' OR
    column_name LIKE 'sanitary%'
)
ORDER BY column_name;

-- ───────────────────────────────────────────────────────────────────────
-- 4. COMPTER LES COLONNES PAR CATÉGORIE
-- ───────────────────────────────────────────────────────────────────────

SELECT
    '📊 COMPTAGE PAR CATÉGORIE' AS info,
    'Compteurs eau' AS categorie,
    COUNT(*) AS nb_colonnes
FROM information_schema.columns
WHERE table_name = 'equipements'
AND column_name LIKE 'waterMeter%'

UNION ALL

SELECT
    '📊 COMPTAGE PAR CATÉGORIE' AS info,
    'Débits air' AS categorie,
    COUNT(*) AS nb_colonnes
FROM information_schema.columns
WHERE table_name = 'equipements'
AND (column_name LIKE 'airFlow%' OR column_name LIKE 'sanitary%')

UNION ALL

SELECT
    '📊 COMPTAGE PAR CATÉGORIE' AS info,
    'GTB' AS categorie,
    COUNT(*) AS nb_colonnes
FROM information_schema.columns
WHERE table_name = 'equipements'
AND column_name LIKE 'gtb%'

UNION ALL

SELECT
    '📊 COMPTAGE PAR CATÉGORIE' AS info,
    'Qualité eau' AS categorie,
    COUNT(*) AS nb_colonnes
FROM information_schema.columns
WHERE table_name = 'equipements'
AND column_name LIKE 'waterQuality%';

-- ───────────────────────────────────────────────────────────────────────
-- 5. VÉRIFIER LA FOREIGN KEY localisation_id
-- ───────────────────────────────────────────────────────────────────────

SELECT
    '🔗 FOREIGN KEY' AS info,
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'equipements'
AND kcu.column_name = 'localisation_id';

-- ───────────────────────────────────────────────────────────────────────
-- 6. VÉRIFIER LES INDEX
-- ───────────────────────────────────────────────────────────────────────

SELECT
    '📑 INDEX' AS info,
    indexname,
    tablename,
    indexdef
FROM pg_indexes
WHERE tablename IN ('localisations', 'equipements')
ORDER BY tablename, indexname;

-- ───────────────────────────────────────────────────────────────────────
-- 7. COMPTER LES DONNÉES
-- ───────────────────────────────────────────────────────────────────────

SELECT
    '📊 DONNÉES' AS info,
    'localisations' AS table_name,
    COUNT(*) AS nb_lignes
FROM localisations

UNION ALL

SELECT
    '📊 DONNÉES' AS info,
    'equipements' AS table_name,
    COUNT(*) AS nb_lignes
FROM equipements;

-- ═══════════════════════════════════════════════════════════════════════
-- ATTENDU :
-- - localisations : 11 colonnes + métadonnées (created_at, updated_at, id)
-- - equipements : ~70-80 colonnes
-- - Compteurs eau : 8 colonnes (waterMeter*)
-- - Débits air : 8 colonnes (airFlow*, sanitary*)
-- - GTB : 7 colonnes (gtb*)
-- - Qualité eau : 12 colonnes (waterQuality*)
-- ═══════════════════════════════════════════════════════════════════════
