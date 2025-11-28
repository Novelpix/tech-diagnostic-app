# Configuration Supabase - PEC Tech App

## 🎯 Objectif

Ce document explique comment configurer correctement la base de données Supabase pour l'application PEC Tech.

---

## ⚠️ Problème résolu

La table `equipements` contenait des **incohérences de noms de colonnes** :
- Doublons : `watermetertype` (lowercase) ET `waterMeterType` (camelCase)
- Noms incorrects : colonnes converties en lowercase par PostgreSQL
- Anciennes colonnes : snake_case (`heure_debut`) au lieu de camelCase (`heureDebut`)

**Conséquence** : Erreurs lors de la synchronisation (`column not found`)

---

## ✅ Solution : Script de nettoyage

### Fichier : `supabase-schema-cleanup.sql`

Ce script effectue un **nettoyage complet** du schéma :

1. **Supprime** toutes les colonnes en lowercase (doublons)
2. **Supprime** toutes les colonnes en snake_case (anciennes)
3. **Crée** toutes les colonnes en camelCase (avec quotes pour préserver la casse)
4. **Crée** les index pour optimiser les performances
5. **Documente** les colonnes avec des commentaires

---

## 🚀 Instructions d'exécution

### Étape 1 : Sauvegarder les données (optionnel)

Si vous avez des données importantes dans la table `equipements`, exportez-les d'abord :

```sql
-- Dans l'éditeur SQL Supabase
SELECT * FROM equipements;
```

Puis **Export to CSV** dans l'interface Supabase.

---

### Étape 2 : Exécuter le script de nettoyage

1. Ouvrez **Supabase Dashboard** → **SQL Editor**
2. Créez une **nouvelle requête**
3. Copiez-collez le contenu complet de `supabase-schema-cleanup.sql`
4. Cliquez sur **Run** (Exécuter)

Le script s'exécute en 4 étapes :
- ✅ Suppression des doublons lowercase
- ✅ Suppression des anciennes colonnes snake_case
- ✅ Création des colonnes camelCase (avec quotes)
- ✅ Création des index et commentaires

---

### Étape 3 : Vérifier le résultat

```sql
-- Vérifier les colonnes créées
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'equipements'
ORDER BY column_name;
```

Vous devriez voir toutes les colonnes en **camelCase** (avec quotes) :
- `airFlowCompliance`
- `contactSite`
- `heureDebut`
- `waterMeterType`
- etc.

**Exception** : `type_anomalie` reste en snake_case (comme dans le code)

---

## 📋 Liste des colonnes créées

### Informations générales
- `lot`, `date`, `heureDebut`, `heureFin`
- `technicien`, `entreprise`, `contactSite`, `telReferent`
- `meteo`, `typeVisite`, `niveau`, `local`

### Identification équipement
- `type`, `code`, `qrCode`, `refDOE`, `refPlan`
- `marque`, `modele`, `serie`, `puissance`, `unite`, `annee`

### Compteur d'eau (8 champs)
- `waterMeterType`, `waterMeterSerial`, `waterMeterField`, `waterMeterGTB`
- `waterMeterDiff`, `waterMeterLastRead`, `waterMeterCoherence`, `waterMeterObs`

### Débits air sanitaires (8 champs)
- `sanitaryType`, `sanitaryLocation`
- `airFlowMeasured`, `airFlowRegulation`, `airFlowCompliance`
- `airFlowVents`, `airFlowVentsState`, `airFlowObs`

### GTB (7 champs)
- `gtbSoftware`, `gtbVersion`, `gtbPoints`, `gtbPointsFault`
- `gtbAvailability`, `gtbLastUpdate`, `gtbAnomalies`

### Qualité eau (12 champs)
- `waterQualityCircuit`, `waterQualityPoint`, `waterQualityPH`
- `waterQualityConductivity`, `waterQualityTemp`, `waterQualityHardness`
- `waterQualityTAC`, `waterQualityTurbidity`, `waterQualityChlorine`
- `waterQualityIron`, `waterQualityTreatment`, `waterQualityObs`

### Évaluation et anomalies
- `ev` (INTEGER), `crit`, `type_anomalie` ⚠️ (snake_case)
- `budget`, `priorite`, `constat`, `observations`, `actions`

### Métadonnées
- `timestamp` (TIMESTAMPTZ)

---

## 🔍 Vérification de la synchronisation

Après exécution du script, testez la synchronisation :

### Test 1 : Création + Sync (INSERT)
1. Créez un nouvel équipement dans l'app
2. Vérifiez dans la console : `➕ INSERT d'un nouvel équipement`
3. Vérifiez dans Supabase : l'équipement doit apparaître

### Test 2 : Édition + Sync (UPDATE)
1. Modifiez l'équipement créé
2. Vérifiez dans la console : `🔄 UPDATE de l'équipement`
3. Vérifiez dans Supabase : **1 seul équipement** (pas de doublon)

### Test 3 : Suppression
1. Supprimez l'équipement
2. Vérifiez dans Supabase : l'équipement doit disparaître

---

## ❓ Dépannage

### Erreur : "column not found"
→ Le script n'a pas été exécuté ou une colonne est manquante
→ Réexécutez `supabase-schema-cleanup.sql`

### Erreur : "permission denied"
→ Vérifiez que vous avez les droits admin sur Supabase
→ Vérifiez les RLS (Row Level Security) policies

### Doublons après UPDATE
→ Vérifiez que `supabase_id` est bien préservé lors de l'édition
→ Vérifiez les logs : doit afficher `UPDATE` et non `INSERT`

---

## 📚 Fichiers de référence

- `supabase-schema-cleanup.sql` : Script de nettoyage complet (à exécuter)
- `supabase-migration.sql` : Ancien script (remplacé par cleanup)
- `CHANGELOG.md` : Documentation des versions et changements

---

## ✨ Résultat attendu

Après exécution du script :
- ✅ **0 erreur** de synchronisation
- ✅ **0 doublon** après édition
- ✅ Synchronisation INSERT/UPDATE intelligente
- ✅ Suppression complète (local + Supabase)
- ✅ Workflow terrain robuste (offline-first)

---

**Version** : 1.1.0
**Date** : 2025-11-28
**Auteur** : Claude (Architecture sync refactor)
