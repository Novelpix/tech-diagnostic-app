# 🧹 Instructions de nettoyage des doublons Supabase

## ⚠️ Situation actuelle

Malgré l'exécution du script v2, il reste des **doublons** dans votre table `equipements` :

- ❌ `heure_fin` (trouvé 2 fois)
- ❌ `waterMeterType` ET `watermetertype` (coexistent)

---

## ✅ Solution : Script ultra-simple

### Fichier : `supabase-drop-doublons.sql` ⭐ **EXÉCUTER CELUI-CI**

Ce script fait **UNIQUEMENT** des suppressions (DROP) :
- ✅ Supprime les doublons snake_case (`heure_fin`, `date_visite`, etc.)
- ✅ Supprime les doublons lowercase (`watermetertype`, `contactsite`, etc.)
- ✅ Supprime les colonnes obsolètes (`criticite`, `remarques`, etc.)
- ✅ Supprime les colonnes inutilisées (`data`, `supabase_id`)
- ✅ Utilise `CASCADE` pour forcer la suppression même s'il y a des dépendances
- ✅ **NE CRÉE AUCUNE COLONNE** (les camelCase existent déjà)

---

## 🚀 Instructions d'exécution

### Étape 1 : Ouvrir Supabase

1. Ouvrez **Supabase Dashboard** → **SQL Editor**
2. Créez une **nouvelle requête**

---

### Étape 2 : Copier-coller le script

1. Ouvrez le fichier `supabase-drop-doublons.sql`
2. **Copiez tout le contenu** (du début à la fin)
3. **Collez** dans l'éditeur SQL de Supabase

---

### Étape 3 : Exécuter

1. Cliquez sur **Run** (Exécuter)
2. Attendez quelques secondes
3. Vérifiez qu'il n'y a **pas d'erreur** (le script utilise `IF EXISTS` donc c'est sécurisé)

---

### Étape 4 : Vérifier le résultat

Exécutez cette requête pour lister toutes les colonnes :

```sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'equipements'
ORDER BY column_name;
```

**Vérifications à faire** :

1. **Comptez le nombre de colonnes** : devrait être **~70** (au lieu de 83)

2. **Vérifiez que ces colonnes ont DISPARU** :
   - ❌ `heure_debut`, `heure_fin` (snake_case)
   - ❌ `watermetertype` (lowercase)
   - ❌ `date_visite` (obsolète)
   - ❌ `criticite`, `remarques`, `recommandations` (obsolètes)
   - ❌ `data`, `supabase_id` (inutilisées)

3. **Vérifiez que ces colonnes EXISTENT TOUJOURS** :
   - ✅ `heureDebut`, `heureFin` (camelCase)
   - ✅ `waterMeterType` (camelCase)
   - ✅ `date` (sans _visite)
   - ✅ `crit`, `observations`, `actions` (nouvelles versions)

---

### Étape 5 : Confirmer

Envoyez-moi :
1. Le **nombre total de colonnes** après nettoyage
2. Si vous voyez encore des **doublons** (lesquels ?)

---

## ❓ Dépannage

### Erreur "permission denied"
→ Vérifiez que vous êtes admin sur Supabase

### Erreur "cannot drop column ... because other objects depend on it"
→ Le script utilise déjà `CASCADE`, cette erreur ne devrait pas apparaître

### Les doublons sont toujours là
→ Envoyez-moi la liste exacte des colonnes trouvées
→ Certaines colonnes peuvent avoir des quotes bizarres

---

## 🎯 Résultat attendu

Après exécution :
- ✅ **70 colonnes** (au lieu de 83)
- ✅ **0 doublon** (`heure_fin` n'apparaît qu'une fois = `heureFin`)
- ✅ **0 doublon** (`waterMeterType` apparaît, `watermetertype` disparaît)
- ✅ Prêt pour les **tests de synchronisation**

---

**Version** : 3 (script simplifié, DROP uniquement)
**Date** : 2025-11-28
