# Changelog - PEC Tech App

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/).

---

## [1.0.0] - 2025-01-28

### ✨ Ajouté
- Affichage de la version de l'application en haut à droite (à côté du point vert)
- Constante `APP_VERSION` pour gérer la version
- Log de la version dans la console au démarrage

### 🔧 Amélioré
- Refonte complète de la synchronisation Supabase
- Nettoyage automatique des IDs Supabase fantômes au démarrage
- Logique INSERT/UPDATE simplifiée et robuste
- Basculement automatique INSERT si UPDATE échoue (ID fantôme)
- Code mieux documenté et structuré

### 🐛 Corrigé
- Suppression d'équipements dans Supabase fonctionnelle
- Correction du bug "Aucune donnée retournée par Supabase"
- Correction des UUID fantômes dans les équipements JSON importés
- Suppression de l'ancienne fonction `sendToSupabase()` obsolète

### 📝 Technique
- Séparation ID local (`equipment.id`) et UUID Supabase (`equipment.supabase_id`)
- Script SQL `supabase-migration.sql` pour créer les colonnes manquantes
- Fonction `cleanPhantomSupabaseIds()` pour nettoyer les données
- Fonction `equipmentExistsInSupabase()` utilitaire

---

## Instructions pour incrémenter la version

**Format de version : MAJOR.MINOR.PATCH**

- **MAJOR** : Changements incompatibles (breaking changes)
- **MINOR** : Nouvelles fonctionnalités (rétrocompatibles)
- **PATCH** : Corrections de bugs

**Exemples :**
- Bug fix → `1.0.0` → `1.0.1`
- Nouvelle fonctionnalité → `1.0.1` → `1.1.0`
- Refonte majeure → `1.1.0` → `2.0.0`

**Pour changer la version :**
1. Modifier `APP_VERSION` dans `index.html` (ligne ~2306)
2. Ajouter l'entrée dans ce fichier `CHANGELOG.md`
3. Commit avec message : `chore: Bump version to X.Y.Z`
