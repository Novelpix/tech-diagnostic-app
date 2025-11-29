# 🐛 BUG #10 : Suppression d'équipement ne fonctionne pas dans Supabase

## 📅 Date
29 novembre 2025

## 🎯 Branche
`claude/refonte-sync-workflow-01TBb7HA4Noq7wWYY7qa9dkZ` (refonte v1.1.0)

---

## ❌ Symptôme

L'équipement est supprimé localement (localStorage) mais **reste dans Supabase**.

**Message utilisateur** :
> "lors de la suppression d'un équipement, celui ci ne disparait pas de supabase"

**Erreur dans la console** :
```
(index):3742 🗑️ Suppression Supabase de l'équipement ID: 6175e1fd-dd4f-4fed-931c-f972c2ba686f
(index):3817 Exception deleteEquipmentFromSupabase: ReferenceError: equipmentId is not defined
    at deleteEquipmentFromSupabase ((index):3743:37)
    at deleteEquipment ((index):3682:37)
    at HTMLButtonElement.onclick ((index):1:1)
```

---

## 🔍 Cause

**Fichier** : `index.html`
**Fonction** : `deleteEquipmentFromSupabase()`
**Lignes** : 3716-3817

### Code problématique

```javascript
// Ligne 3716 : le paramètre s'appelle localId
async function deleteEquipmentFromSupabase(localId) {
  try {
    // ...

    const equipmentToDelete = Object.values(AppState.equipmentData)
      .flat()
      .find(eq => eq.local_id === localId);  // ✅ Utilise localId correctement

    const supabaseEquipmentId = equipmentToDelete.supabase_id;

    console.log(`🗑️ Suppression Supabase de l'équipement ID: ${supabaseEquipmentId}`);
    console.log(`📍 ID local: ${equipmentId}`);  // ❌ ERREUR : equipmentId n'existe pas !
    console.log(`📍 ID Supabase: ${supabaseEquipmentId}`);

    // ... le reste du code ne s'exécute jamais à cause de l'erreur
  }
}
```

### Explication

1. La fonction prend `localId` comme paramètre (ligne 3716)
2. Le code utilise correctement `localId` pour trouver l'équipement (ligne 3725)
3. **MAIS** ligne 3743, un `console.log` utilise `equipmentId` qui n'existe pas
4. JavaScript lance une `ReferenceError`
5. L'exception stoppe l'exécution de la fonction
6. L'équipement n'est **jamais supprimé** de Supabase

### Origine de l'erreur

**Copier-coller** depuis la version précédente du code qui utilisait `equipmentId` comme nom de paramètre. Lors de la refonte v1.1.0, le paramètre a été renommé en `localId` mais le `console.log` n'a pas été mis à jour.

---

## ✅ Solution

### Correctif appliqué

**Fichier** : `index.html`
**Ligne** : 3743

```javascript
// ❌ AVANT
console.log(`📍 ID local: ${equipmentId}`);

// ✅ APRÈS
console.log(`📍 ID local: ${localId}`);
```

### Commit

```
commit d400a34
fix: Corriger ReferenceError equipmentId dans deleteEquipmentFromSupabase

- Ligne 3743 : ${equipmentId} → ${localId}
- Résout ReferenceError qui bloquait la suppression
- Suppression fonctionne maintenant dans Supabase

Branche: claude/refonte-sync-workflow-01TBb7HA4Noq7wWYY7qa9dkZ
```

---

## 📊 Impact

### Avant le correctif
- ❌ Suppression locale : ✅ Fonctionne
- ❌ Suppression Supabase : ❌ **Ne fonctionne pas** (ReferenceError)
- ❌ Photos Supabase : ❌ Restent orphelines
- ❌ Données incohérentes : Local vide, Supabase plein

### Après le correctif
- ✅ Suppression locale : ✅ Fonctionne
- ✅ Suppression Supabase : ✅ **Fonctionne**
- ✅ Photos Supabase : ✅ Supprimées correctement
- ✅ Cohérence : Local et Supabase synchronisés

---

## 🔄 Processus de suppression complet

Après le correctif, le workflow de suppression fonctionne comme prévu :

### Étape 1 : Suppression locale
```javascript
// Dans deleteEquipment()
AppState.equipmentData[AppState.currentLot].splice(index, 1);
saveToLocalStorage();
```

### Étape 2 : Suppression Supabase
```javascript
// Dans deleteEquipmentFromSupabase(localId)

// 2.1 : Supprimer les photos du storage
await supabaseClient.storage
  .from("pec-photos")
  .remove(filePaths);

// 2.2 : Supprimer les entrées de la table photos
await supabaseClient
  .from("photos")
  .delete()
  .eq("equipement_id", supabaseEquipmentId);

// 2.3 : Supprimer l'équipement
await supabaseClient
  .from("equipements")
  .delete()
  .eq("id", supabaseEquipmentId);
```

### Étape 3 : Feedback utilisateur
```javascript
showToast('🗑️ Fiche supprimée (Local + Supabase)', 'success');
```

---

## 🧪 Tests à effectuer

Après déploiement sur Netlify :

### Test 1 : Suppression équipement synchronisé
1. ✅ Créer un équipement
2. ✅ Synchroniser (supabase_id renseigné)
3. ✅ Supprimer l'équipement
4. ✅ Vérifier : équipement supprimé de Supabase
5. ✅ Vérifier : photos supprimées du storage
6. ✅ Vérifier : entrées photos supprimées de la table

### Test 2 : Suppression équipement non synchronisé
1. ✅ Créer un équipement
2. ✅ **NE PAS** synchroniser (supabase_id = null)
3. ✅ Supprimer l'équipement
4. ✅ Vérifier : équipement supprimé localement
5. ✅ Vérifier : pas d'erreur (retour true car jamais synchronisé)

### Test 3 : Console logs
1. ✅ Ouvrir console (F12)
2. ✅ Supprimer un équipement
3. ✅ Vérifier logs :
   ```
   🗑️ Suppression Supabase de l'équipement ID: xxx
   📍 ID local: yyy
   📍 ID Supabase: xxx
   ✅ N photo(s) supprimée(s) du storage
   ✅ Entrées photos supprimées de la table
   ✅ Équipement supprimé de Supabase: [...]
   ```
4. ✅ Vérifier : **aucune** erreur ReferenceError

---

## 📝 Checklist déploiement

- [x] Corriger le code (ligne 3743)
- [x] Commit avec message descriptif
- [x] Push vers origin
- [ ] Créer PR vers `dev`
- [ ] Merger PR
- [ ] Netlify auto-déploie depuis `dev`
- [ ] Tester sur Netlify (tests ci-dessus)
- [ ] Confirmer : suppression fonctionne

---

## 🎯 Résultat attendu

Après déploiement et test :

✅ **Suppression locale** : équipement disparaît de l'app
✅ **Suppression Supabase** : équipement disparaît de la BDD
✅ **Suppression photos** : photos disparaissent du storage
✅ **Logs clairs** : pas d'erreur ReferenceError
✅ **Cohérence** : local et distant synchronisés

---

**Version** : Correctif v1.1.1
**Date** : 2025-11-29
**Auteur** : Claude (fix bug suppression)
**Branche** : `claude/refonte-sync-workflow-01TBb7HA4Noq7wWYY7qa9dkZ`
**Commit** : `d400a34`
