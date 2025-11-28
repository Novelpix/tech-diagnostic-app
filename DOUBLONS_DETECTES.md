# 🔍 Analyse du schéma Supabase - Doublons détectés

## 📊 Résumé

**Total colonnes actuelles** : 83
**Total après nettoyage** : ~70
**Doublons à supprimer** : ~13

---

## ❌ Doublons identifiés

### 1. Colonnes temporelles

| ✅ Garder (camelCase) | ❌ Supprimer (snake_case) |
|----------------------|--------------------------|
| `heureDebut` | `heure_debut` |
| `heureFin` | `heure_fin` |
| `date` | `date_visite` |

---

### 2. Colonnes compteur d'eau

| ✅ Garder (camelCase) | ❌ Supprimer (lowercase) |
|----------------------|-------------------------|
| `waterMeterType` | `watermetertype` |
| `waterMeterSerial` | `watermeterserial` |
| `waterMeterField` | `watermeterfield` |
| `waterMeterGTB` | `watermetergtb` |
| `waterMeterDiff` | `watermeterdiff` |
| `waterMeterLastRead` | `watermeterlastread` |
| `waterMeterCoherence` | `waterMetercoherence` (casse mixte!) |
| `waterMeterObs` | `watermeterobs` |

---

### 3. Colonnes débits air

| ✅ Garder (camelCase) | ❌ Supprimer (lowercase) |
|----------------------|-------------------------|
| `airFlowMeasured` | `airflowmeasured` |
| `airFlowRegulation` | `airflowregulation` |
| `airFlowCompliance` | `airflowcompliance` |
| `airFlowVents` | `airflowvents` |
| `airFlowVentsState` | `airflowventsstate` |
| `airFlowObs` | `airflowobs` |

---

### 4. Colonnes sanitaires

| ✅ Garder (camelCase) | ❌ Supprimer (lowercase) |
|----------------------|-------------------------|
| `sanitaryType` | `sanitarytype` |
| `sanitaryLocation` | `sanitarylocation` |

---

### 5. Colonnes GTB

| ✅ Garder (camelCase) | ❌ Supprimer (lowercase) |
|----------------------|-------------------------|
| `gtbSoftware` | `gtbsoftware` |
| `gtbVersion` | `gtbversion` |
| `gtbPoints` | `gtbpoints` |
| `gtbPointsFault` | `gtbpointsfault` |
| `gtbAvailability` | `gtbavailability` |
| `gtbLastUpdate` | `gtblastupdate` |
| `gtbAnomalies` | `gtbanomalies` |

---

### 6. Colonnes qualité eau

| ✅ Garder (camelCase) | ❌ Supprimer (lowercase) |
|----------------------|-------------------------|
| `waterQualityCircuit` | `waterqualitycircuit` |
| `waterQualityPoint` | `waterqualitypoint` |
| `waterQualityPH` | `waterqualityph` |
| `waterQualityConductivity` | `waterqualityconductivity` |
| `waterQualityTemp` | `waterqualitytemp` |
| `waterQualityHardness` | `waterqualityhardness` |
| `waterQualityTAC` | `waterqualitytac` |
| `waterQualityTurbidity` | `waterqualityturbidity` |
| `waterQualityChlorine` | `waterqualitychlorine` |
| `waterQualityIron` | `waterqualityiron` |
| `waterQualityTreatment` | `waterqualitytreatment` |
| `waterQualityObs` | `waterqualityobs` |

---

### 7. Autres doublons généraux

| ✅ Garder (camelCase) | ❌ Supprimer (lowercase) |
|----------------------|-------------------------|
| `contactSite` | `contactsite` |
| `telReferent` | `telreferent` |
| `typeVisite` | `typevisite` |
| `refDOE` | `refdoe` |
| `refPlan` | `refplan` |
| `qrCode` | `qrcode` |

---

## ❌ Colonnes obsolètes (remplacées)

| ❌ Supprimer | ✅ Remplacée par |
|-------------|-----------------|
| `criticite` | `crit` |
| `remarques` | `observations` |
| `recommandations` | `actions` |

---

## ❌ Colonnes inutilisées (architecture refondée)

| Colonne | Type | Raison de suppression |
|---------|------|----------------------|
| `data` | JSONB | Architecture refondée : champs aplatis |
| `supabase_id` | UUID | Doublon avec `id` (primary key) |

---

## ✅ Colonnes à conserver

### Colonnes de base
- `id` (UUID, primary key)
- `created_at` (TIMESTAMPTZ)

### Informations générales (13 colonnes)
- `lot`, `date`, `heureDebut`, `heureFin`
- `technicien`, `entreprise`, `contactSite`, `telReferent`
- `meteo`, `typeVisite`, `niveau`, `local`
- `latitude`, `longitude` (GPS)

### Identification équipement (11 colonnes)
- `type`, `code`, `qrCode`, `refDOE`, `refPlan`
- `marque`, `modele`, `serie`, `puissance`, `unite`, `annee`

### Compteur d'eau (8 colonnes)
- `waterMeterType`, `waterMeterSerial`, `waterMeterField`, `waterMeterGTB`
- `waterMeterDiff`, `waterMeterLastRead`, `waterMeterCoherence`, `waterMeterObs`

### Débits air sanitaires (8 colonnes)
- `sanitaryType`, `sanitaryLocation`
- `airFlowMeasured`, `airFlowRegulation`, `airFlowCompliance`
- `airFlowVents`, `airFlowVentsState`, `airFlowObs`

### GTB (7 colonnes)
- `gtbSoftware`, `gtbVersion`, `gtbPoints`, `gtbPointsFault`
- `gtbAvailability`, `gtbLastUpdate`, `gtbAnomalies`

### Qualité eau (12 colonnes)
- `waterQualityCircuit`, `waterQualityPoint`, `waterQualityPH`
- `waterQualityConductivity`, `waterQualityTemp`, `waterQualityHardness`
- `waterQualityTAC`, `waterQualityTurbidity`, `waterQualityChlorine`
- `waterQualityIron`, `waterQualityTreatment`, `waterQualityObs`

### Évaluation et anomalies (8 colonnes)
- `ev` (INTEGER), `crit`, `type_anomalie` ⚠️ (snake_case)
- `budget`, `priorite`, `constat`, `observations`, `actions`

### Métadonnées (1 colonne)
- `timestamp` (TIMESTAMPTZ)

---

## 🎯 Action requise

**Exécutez le script** : `supabase-schema-cleanup-v2.sql`

Ce script va :
1. ✅ Supprimer TOUS les doublons listés ci-dessus
2. ✅ Supprimer les colonnes obsolètes
3. ✅ Supprimer les colonnes inutilisées
4. ✅ Conserver uniquement les colonnes camelCase (avec quotes)

**Résultat attendu** : 70 colonnes propres, 0 doublon, 0 erreur de synchronisation.

---

**Généré automatiquement par analyse du schéma Supabase**
**Date** : 2025-11-28
