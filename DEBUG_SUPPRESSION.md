# 🐛 DEBUG - Suppression d'équipement ne fonctionne pas dans Supabase

## 📋 Symptôme
L'équipement est supprimé localement (localStorage) mais reste dans Supabase.

---

## 🔍 Diagnostic à effectuer

### Étape 1 : Vérifier les logs dans la console

Ouvrez la console du navigateur (F12) et supprimez un équipement. Cherchez ces messages :

**Messages attendus (succès)** :
```
🗑️ Suppression Supabase de l'équipement ID: xxx
📍 ID local: yyy
📍 ID Supabase: xxx
✅ Équipement supprimé de Supabase: [...]
✅ ID Supabase supprimé: xxx
```

**Messages d'erreur possibles** :
```
❌ Erreur suppression Supabase: {...}
⚠️ Aucun équipement supprimé (peut-être déjà supprimé ou ID invalide)
⚠️ Équipement sans ID Supabase - probablement jamais synchronisé
```

### Étape 2 : Vérifier les permissions RLS dans Supabase

Le problème le plus probable est un **manque de politique RLS (Row Level Security)** pour la suppression.

**Vérification dans Supabase** :
1. Ouvrez Supabase Dashboard → **Authentication** → **Policies**
2. Table `equipements`
3. Vérifiez qu'il existe une politique **DELETE**

**Politique manquante** :
```sql
-- Si cette politique n'existe pas, la suppression est bloquée
CREATE POLICY "Enable delete for users" ON equipements
FOR DELETE
USING (true);  -- ⚠️ Attention : ceci autorise TOUTE suppression
```

**Politique sécurisée (si vous avez de l'authentification)** :
```sql
CREATE POLICY "Enable delete for authenticated users" ON equipements
FOR DELETE
USING (auth.uid() IS NOT NULL);
```

### Étape 3 : Vérifier que supabase_id existe

Le code vérifie si `equipment.supabase_id` existe avant de supprimer :

```javascript
if (!supabaseEquipmentId) {
  console.warn("⚠️ Équipement sans ID Supabase");
  return true;  // Pas d'erreur, équipement jamais synchronisé
}
```

**Test** : Ouvrez la console et tapez :
```javascript
// Récupérer un équipement
const eq = AppState.equipmentData["Structure"][0];
console.log("supabase_id:", eq.supabase_id);
```

Si `supabase_id` est `undefined` ou `null`, l'équipement n'a jamais été synchronisé et ne peut pas être supprimé de Supabase.

---

## 🔧 Solutions possibles

### Solution 1 : Ajouter politique RLS pour DELETE

**Dans Supabase Dashboard → SQL Editor** :

```sql
-- Activer RLS sur la table (si pas déjà fait)
ALTER TABLE equipements ENABLE ROW LEVEL SECURITY;

-- Créer politique DELETE permissive (TEMPORAIRE pour tests)
CREATE POLICY "Allow all deletes for testing" ON equipements
FOR DELETE
USING (true);

-- ⚠️ Remplacer par une politique sécurisée en production :
-- CREATE POLICY "Allow delete for authenticated users" ON equipements
-- FOR DELETE
-- USING (auth.uid() IS NOT NULL);
```

### Solution 2 : Vérifier la table photos

Les photos doivent aussi avoir une politique DELETE :

```sql
-- Table photos
CREATE POLICY "Allow all deletes for testing" ON photos
FOR DELETE
USING (true);
```

### Solution 3 : Ajouter plus de logs pour debug

Si le problème persiste, modifiez temporairement le code pour avoir plus d'informations :

**Dans `deleteEquipmentFromSupabase` (ligne ~3705)** :

```javascript
const { data: deletedData, error } = await supabaseClient
  .from("equipements")
  .delete()
  .eq("id", supabaseEquipmentId)
  .select();

console.log("🔍 DELETE Response:", { deletedData, error });  // AJOUT
console.log("🔍 Deleted count:", deletedData ? deletedData.length : 0);  // AJOUT

if (error) {
  console.error("❌ Erreur suppression Supabase:", error);
  console.error("❌ Error code:", error.code);  // AJOUT
  console.error("❌ Error message:", error.message);  // AJOUT
  console.error("❌ Error hint:", error.hint);  // AJOUT
  // ...
}
```

---

## 📊 Codes d'erreur fréquents

| Code | Message | Cause | Solution |
|------|---------|-------|----------|
| `42501` | `permission denied` | Pas de politique DELETE | Ajouter politique RLS |
| `23503` | `foreign key violation` | Photos référencent l'équipement | Supprimer photos d'abord (déjà fait dans le code) |
| `PGRST116` | `The result contains 0 rows` | ID n'existe pas | Vérifier supabase_id |

---

## ✅ Checklist de vérification

- [ ] Ouvrir console navigateur (F12)
- [ ] Supprimer un équipement
- [ ] Noter les logs affichés
- [ ] Vérifier si erreur RLS (`permission denied`)
- [ ] Vérifier si `supabase_id` existe sur l'équipement
- [ ] Ouvrir Supabase Dashboard → Policies
- [ ] Vérifier politique DELETE sur `equipements`
- [ ] Vérifier politique DELETE sur `photos`
- [ ] Si manquante, exécuter script SQL ci-dessus
- [ ] Retester la suppression

---

## 🎯 Action immédiate

**Que faire maintenant** :

1. **Ouvrez la console** (F12 dans le navigateur)
2. **Supprimez un équipement**
3. **Copiez-collez TOUS les logs** affichés dans la console
4. **Envoyez-moi les logs** pour diagnostic précis

**Exemple de logs à copier** :
```
🗑️ Suppression Supabase de l'équipement ID: abc123
📍 ID local: def456
📍 ID Supabase: abc123
❌ Erreur suppression Supabase: {code: "42501", message: "permission denied for table equipements"}
```

---

**Version** : Debug 1.0
**Date** : 2025-11-29
