# 🐛 Résumé des bugs rencontrés et résolutions

## 📋 Vue d'ensemble

Ce document liste chronologiquement **tous les bugs rencontrés** lors de la refonte du système de synchronisation, avec les causes, impacts et résolutions.

---

## 🔴 BUG #1 : Fonction name mismatch dans syncAllData()

### 📅 Quand
Après la première version de la refonte (v1.1.0)

### 🐛 Symptôme
```
ReferenceError: saveEquipmentToSupabase is not defined
```

### 🔍 Cause
La fonction `syncAllData()` appelait `saveEquipmentToSupabase()` (ancien nom) au lieu de `syncEquipmentToSupabase()` (nouveau nom après refonte).

**Fichier** : `index.html` ligne ~4908

### ✅ Résolution
```javascript
// ❌ Avant
await saveEquipmentToSupabase(eq);

// ✅ Après
await syncEquipmentToSupabase(eq);
```

**Commit** : `07c0360` - "fix: Corriger appel à syncEquipmentToSupabase dans syncAllData"

### 📊 Impact
- ❌ Synchronisation globale bloquée
- ✅ Résolu en 1 changement de ligne

---

## 🔴 BUG #2 : Équipement introuvable lors de suppression/édition

### 📅 Quand
Après le bug #1, lors des tests utilisateur

### 🐛 Symptôme
```
❌ Erreur: équipement introuvable
```
Au clic sur les boutons "Modifier" ou "Supprimer"

### 🔍 Cause
La fonction `renderEquipmentList()` passait `equipment.id` (ancien champ) aux gestionnaires d'événements onclick, alors que la nouvelle architecture utilise `equipment.local_id`.

**Fichier** : `index.html` lignes ~2678-2679

### 📌 Code problématique
```javascript
<button onclick="editEquipment('${equipment.id}')">Modifier</button>
<button onclick="deleteEquipment('${equipment.id}')">Supprimer</button>
```

### ✅ Résolution
1. Normaliser l'équipement avant affichage
2. Utiliser `normalized.local_id` dans les onclick

```javascript
const normalized = normalizeEquipmentForDisplay(equipment);

<button onclick="editEquipment('${normalized.local_id}')">Modifier</button>
<button onclick="deleteEquipment('${normalized.local_id}')">Supprimer</button>
```

**Commit** : `7ede8c2` - "fix: Adapter renderEquipmentList pour utiliser local_id"

### 📊 Impact
- ❌ Impossible de modifier ou supprimer les équipements
- ✅ Résolu en normalisant avant le rendu

---

## 🔴 BUG #3 : Champs vides lors de l'édition

### 📅 Quand
Signalé par l'utilisateur après le bug #2

### 🐛 Symptôme
Tous les champs du formulaire étaient vides lors de l'édition d'un équipement existant.

### 🔍 Cause
La fonction `editEquipment()` utilisait `equipment.*` directement au lieu de `eq.*` (équipement normalisé).

Avec la nouvelle structure, les données métier sont dans `equipment.data.*`, pas directement dans `equipment.*`.

**Fichier** : `index.html` lignes ~3890-3979

### 📌 Code problématique
```javascript
// ❌ Avant (après normalisation)
const eq = normalizeEquipmentForDisplay(equipment);
document.getElementById('formDate').value = equipment.date || '';  // undefined!
document.getElementById('formTechnicien').value = equipment.technicien || '';  // undefined!
```

### ✅ Résolution
Utiliser `eq.*` partout après normalisation (remplacement massif avec sed)

```javascript
// ✅ Après
const eq = normalizeEquipmentForDisplay(equipment);
document.getElementById('formDate').value = eq.date || '';
document.getElementById('formTechnicien').value = eq.technicien || '';
```

**Commit** : `0da1d2c` - "fix: Utiliser équipement normalisé dans editEquipment()"

### 📊 Impact
- ❌ Formulaire vide = perte de données lors de l'édition
- ✅ Résolu en utilisant l'objet normalisé

---

## 🔴 BUG #4 : Colonne "croquis" introuvable dans Supabase

### 📅 Quand
Signalé par l'utilisateur : "erreur d enregistrement apres une modif d equipement"

### 🐛 Symptôme
```
Could not find the 'croquis' column of 'equipements' in the schema cache
```

### 🔍 Cause
Le champ `croquis` (base64 du dessin) était stocké dans `equipment.data.croquis` et envoyé à Supabase lors de la synchronisation.

**Problème** : `croquis` est un champ **local uniquement** (comme les photos), il ne doit PAS être envoyé à Supabase. La table Supabase n'a pas cette colonne.

**Fichier** : `index.html` ligne ~4641 (dans syncEquipmentToSupabase)

### 📌 Code problématique
```javascript
// ❌ Avant
const equipmentForDb = { ...equipment.data };
// Contenait equipment.data.croquis → envoyé à Supabase → erreur
```

### ✅ Résolution
Exclure explicitement le champ `croquis` du payload Supabase

```javascript
// ✅ Après
const equipmentForDb = { ...equipment.data };
delete equipmentForDb.croquis;  // Stockage local uniquement
```

**Commit** : `ec2a934` - "fix: Exclure le champ croquis du payload Supabase"

### 📊 Impact
- ❌ Impossible de synchroniser les modifications d'équipement
- ✅ Résolu en excluant le champ local

---

## 🔴 BUG #5 : Colonnes camelCase converties en lowercase

### 📅 Quand
Lors des premiers tests de synchronisation après le bug #4

### 🐛 Symptôme
```
Could not find the 'contactSite' column of 'equipements' in the schema cache
Could not find the 'airFlowCompliance' column of 'equipements' in the schema cache
Could not find the 'heureDebut' column of 'equipements' in the schema cache
```

### 🔍 Cause
**PostgreSQL convertit automatiquement les noms de colonnes en lowercase** si elles ne sont pas créées avec des **guillemets doubles**.

```sql
-- ❌ Sans quotes → PostgreSQL crée "contactsite"
ALTER TABLE equipements ADD COLUMN contactSite TEXT;

-- ✅ Avec quotes → PostgreSQL préserve "contactSite"
ALTER TABLE equipements ADD COLUMN "contactSite" TEXT;
```

### 📌 Code JavaScript (attendu)
```javascript
// Le code envoie en camelCase
const equipmentForDb = {
  contactSite: "...",    // camelCase
  airFlowCompliance: "...",
  heureDebut: "..."
};
```

### ✅ Résolution
Demander à l'utilisateur d'exécuter un script SQL avec **tous les noms de colonnes entre guillemets**.

**Fichiers** :
- `supabase-migration.sql` (v1, incomplet)
- `supabase-schema-cleanup.sql` (v2, avec quotes mais laissait doublons)
- `supabase-drop-doublons.sql` (v3, DROP forcé avec CASCADE)

**Exemple** :
```sql
DROP COLUMN IF EXISTS contactsite CASCADE;  -- Supprimer lowercase
ADD COLUMN IF NOT EXISTS "contactSite" TEXT;  -- Créer avec quotes
```

### 📊 Impact
- ❌ TOUTES les synchronisations échouaient
- ✅ Résolu avec script SQL + quotes sur toutes les colonnes camelCase

---

## 🔴 BUG #6 : Doublons de colonnes dans le schéma Supabase

### 📅 Quand
Détecté lors de la vérification du schéma après les bugs #4 et #5

### 🐛 Symptôme
La requête de vérification montrait **83 colonnes** au lieu de ~70 attendues.

**Doublons confirmés par l'utilisateur** :
- `heure_fin` trouvé **2 fois**
- `waterMeterType` ET `watermetertype` coexistent

### 🔍 Cause
Combinaison de plusieurs facteurs :

1. **Migrations multiples** : Anciens scripts créaient en snake_case, nouveaux en camelCase
2. **PostgreSQL lowercase** : Colonnes créées sans quotes → converties en lowercase
3. **Scripts incomplets** : v1 et v2 utilisaient `ADD IF NOT EXISTS` sans DROP préalable

**Exemple** :
```sql
-- Script initial (sans quotes)
ADD COLUMN waterMeterType TEXT;  → PostgreSQL crée "watermetertype"

-- Script de correction (avec quotes)
ADD COLUMN "waterMeterType" TEXT;  → PostgreSQL crée "waterMeterType"

Résultat : 2 colonnes !
```

### 📌 Liste complète des doublons

| ✅ Garder (camelCase) | ❌ Supprimer |
|----------------------|-------------|
| `heureDebut` | `heure_debut` |
| `heureFin` | `heure_fin` |
| `waterMeterType` | `watermetertype` |
| `contactSite` | `contactsite` |
| `airFlowCompliance` | `airflowcompliance` |
| `date` | `date_visite` |
| `crit` | `criticite` |
| `observations` | `remarques` |
| `actions` | `recommandations` |

+ 40+ autres doublons dans compteur eau, GTB, qualité eau, etc.

### ✅ Résolution

**Version 1** : `supabase-schema-cleanup.sql`
- ❌ Échec : Utilisait `ADD IF NOT EXISTS` sans DROP → laissait doublons

**Version 2** : `supabase-schema-cleanup-v2.sql`
- ❌ Échec : Tentait DROP puis CREATE → pas assez agressif

**Version 3** : `supabase-drop-doublons.sql` ⭐ **SOLUTION FINALE**
- ✅ **UNIQUEMENT des DROP** avec `CASCADE`
- ✅ Ne crée RIEN (colonnes camelCase existent déjà)
- ✅ Force la suppression même avec dépendances

```sql
-- Supprime TOUS les doublons snake_case
ALTER TABLE equipements DROP COLUMN IF EXISTS heure_debut CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS heure_fin CASCADE;

-- Supprime TOUS les doublons lowercase
ALTER TABLE equipements DROP COLUMN IF EXISTS watermetertype CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS contactsite CASCADE;

-- Supprime colonnes obsolètes
ALTER TABLE equipements DROP COLUMN IF EXISTS criticite CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS remarques CASCADE;

-- Supprime colonnes inutilisées
ALTER TABLE equipements DROP COLUMN IF EXISTS data CASCADE;
ALTER TABLE equipements DROP COLUMN IF EXISTS supabase_id CASCADE;
```

**Commits** :
- `905d912` - Script v1
- `08c1b4e` - Script v2
- `faf0b57` - Script v3 (final)

### 📊 Impact
- ❌ 83 colonnes → confusion, risque de données incohérentes
- ✅ ~70 colonnes après nettoyage → schéma propre et cohérent

---

## 🔴 BUG #7 : INSERT au lieu de UPDATE (doublons dans Supabase)

### 📅 Quand
Signalé par l'utilisateur en début de conversation (résumé fourni)

### 🐛 Symptôme
```
🔄 Début de synchronisation équipement: xxx
➕ INSERT d'un nouvel équipement
```
Alors que c'était une **modification** d'un équipement existant → création de **doublons** dans Supabase.

### 🔍 Cause
L'ancienne architecture utilisait un seul identifiant (`id`) qui changeait lors de l'édition.

**Workflow problématique** :
1. Création équipement → `id: "abc"` → INSERT dans Supabase → `supabase_id: "xyz"`
2. Édition équipement → génération d'un **nouvel** `id: "def"` → perte du lien avec Supabase
3. Synchronisation → pas de `supabase_id` trouvé → **INSERT** au lieu de UPDATE
4. Résultat : **2 équipements dans Supabase** pour 1 seul dans l'app

### ✅ Résolution
Refonte complète avec **système dual d'identifiants** :

**Nouvelle architecture** :
```javascript
{
  local_id: "uuid-local",        // Permanent, jamais changé
  supabase_id: "uuid-supabase",  // ID Supabase (null avant 1ère sync)
  status: "pending|synced|error",
  synced: boolean,
  data: { /* champs métier */ }
}
```

**Logique de synchronisation** :
```javascript
if (equipment.supabase_id) {
  // HAS supabase_id → UPDATE
  await supabaseClient.from("equipements")
    .update(equipmentForDb)
    .eq('id', equipment.supabase_id);
} else {
  // NO supabase_id → INSERT
  await supabaseClient.from("equipements")
    .insert(equipmentForDb);
}
```

**Protection anti-phantom ID** :
```javascript
// Si UPDATE ne retourne rien → équipement supprimé côté Supabase
if (!result.data || result.data.length === 0) {
  console.warn("UUID n'existe plus, fallback to INSERT");
  await supabaseClient.from("equipements").insert(equipmentForDb);
}
```

**Commit** : Refonte v1.1.0 complète

### 📊 Impact
- ❌ Doublons systématiques lors des modifications
- ✅ Résolu avec architecture dual ID + logique INSERT/UPDATE

---

## 🔴 BUG #8 : Changements non visibles sur Netlify

### 📅 Quand
Après les premiers correctifs (bugs #1, #2, #3)

### 🐛 Symptôme
L'utilisateur testait sur Netlify et voyait toujours les anciennes erreurs malgré les commits/push.

**Citation** : *"rien n'a changé", "toujours les 2 mêmes erreurs"*

### 🔍 Cause
Les changements étaient sur la branche **feature** (`claude/fix-equipment-sync-...`), mais Netlify déploie depuis la branche **`dev`**.

**Workflow Git** :
```
feature branch (commits ici) → dev (Netlify déploie ici) → main
```

### ✅ Résolution
Créer des **Pull Requests** pour merger feature → dev → déploiement auto Netlify.

**PRs créées** :
- PR #7 : Refonte sync + premiers correctifs
- PR #8 : Correctifs supplémentaires
- PR à créer : Correctif croquis (dernière branche)

### 📊 Impact
- ❌ Confusion : "les bugs persistent" alors qu'ils étaient corrigés
- ✅ Résolu en créant les PRs vers dev

---

## 📊 Récapitulatif des bugs

| # | Bug | Cause | Résolution | Commit |
|---|-----|-------|-----------|--------|
| 1 | Fonction name mismatch | Renommage incomplet | Mise à jour appel fonction | `07c0360` |
| 2 | Équipement introuvable | Utilisait `id` au lieu de `local_id` | Normalisation + `local_id` | `7ede8c2` |
| 3 | Champs vides édition | Utilisait `equipment.*` au lieu de `eq.*` | Utiliser objet normalisé | `0da1d2c` |
| 4 | Colonne croquis introuvable | Envoyé à Supabase par erreur | Exclure du payload | `ec2a934` |
| 5 | camelCase → lowercase | PostgreSQL sans quotes | Scripts SQL avec quotes | `905d912`, `08c1b4e`, `faf0b57` |
| 6 | Doublons colonnes (83→70) | Migrations multiples | Script DROP CASCADE | `faf0b57` |
| 7 | INSERT au lieu UPDATE | ID changeait à l'édition | Architecture dual ID | v1.1.0 |
| 8 | Changements invisibles Netlify | Pas mergé dans dev | Pull Requests | PRs #7, #8 |

---

## ✅ État actuel

### Résolu ✅
- [x] Architecture dual ID (local_id + supabase_id)
- [x] Logique INSERT/UPDATE intelligente
- [x] Normalisation pour affichage
- [x] Exclusion champs locaux (croquis)
- [x] Script SQL de nettoyage (v3)

### En attente ⏳
- [ ] Exécution script v3 dans Supabase (utilisateur)
- [ ] Vérification : 83 → 70 colonnes
- [ ] Vérification : doublons supprimés
- [ ] Tests de synchronisation complets
- [ ] Merge vers dev + déploiement Netlify

---

**Document généré automatiquement**
**Date** : 2025-11-28
**Version app** : 1.1.0
