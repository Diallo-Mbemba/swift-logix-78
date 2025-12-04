# Guide : Correction de l'impossibilité de créer un acteur

## Problème

Impossible de créer un nouvel acteur et certains menus semblent avoir disparu.

## Causes possibles

1. **Table `actors` n'existe pas** ou a une structure incorrecte
2. **Politiques RLS manquantes** ou incorrectes
3. **Colonnes manquantes** dans la table (nom, adresse, telephone, etc.)
4. **Hook `useAdmin` en erreur** qui masque les menus

## Solution

### Étape 1 : Exécuter le script de correction

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`FIX_CREATION_ACTEUR.sql`**
3. Vérifiez qu'il n'y a **pas d'erreur** dans les résultats

Ce script va :
- ✅ Vérifier que la table `actors` existe
- ✅ Créer la table si elle n'existe pas
- ✅ Vérifier et ajouter les colonnes manquantes (nom, adresse, telephone, etc.)
- ✅ Renommer les colonnes si nécessaire (name → nom, address → adresse, etc.)
- ✅ Créer les index pour améliorer les performances
- ✅ Créer le trigger pour `updated_at`
- ✅ Activer RLS et créer les politiques appropriées

### Étape 2 : Vérifier les résultats

Après avoir exécuté le script, vous devriez voir :

1. **Table actors** : ✅ Existe avec les colonnes :
   - `id` (UUID)
   - `user_id` (UUID, NOT NULL)
   - `nom` (VARCHAR(255), NOT NULL)
   - `adresse` (TEXT, NOT NULL)
   - `telephone` (VARCHAR(50))
   - `email` (VARCHAR(255))
   - `type` (VARCHAR(50), CHECK: importateur, fournisseur, transitaire)
   - `zone` (VARCHAR(100))
   - `pays` (VARCHAR(2))
   - `created_at` (TIMESTAMP)
   - `updated_at` (TIMESTAMP)

2. **RLS Status** : ✅ Activé

3. **Politiques créées** :
   - ✅ "Users can view own actors" (SELECT)
   - ✅ "Users can insert own actors" (INSERT)
   - ✅ "Users can update own actors" (UPDATE)
   - ✅ "Users can delete own actors" (DELETE)

### Étape 3 : Vérifier les menus

Si certains menus ont disparu, vérifiez :

1. **Ouvrez la console du navigateur** (F12)
2. **Vérifiez les erreurs** liées à `useAdmin` ou `adminService`
3. **Vérifiez que vous êtes bien connecté** (`user` n'est pas null)

### Étape 4 : Tester la création d'acteur

1. **Rafraîchissez la page** de l'application (F5)
2. **Allez sur la page des acteurs** (`/actors`)
3. **Cliquez sur "Ajouter un acteur"**
4. **Remplissez le formulaire** :
   - Type d'acteur (obligatoire)
   - Nom de l'entreprise (obligatoire)
   - Adresse (obligatoire)
   - Téléphone (optionnel)
   - Email (optionnel)
   - Zone (pour les importateurs)
   - Pays (pour les fournisseurs)
5. **Cliquez sur "Ajouter"**
6. **Vérifiez qu'il n'y a pas d'erreur**

## Messages d'erreur possibles

### "Erreur de permissions. Assurez-vous que la table actors existe..."

**Cause** : Politiques RLS manquantes ou incorrectes

**Solution** : Exécutez `FIX_CREATION_ACTEUR.sql`

### "La table actors n'existe pas..."

**Cause** : La table n'a pas été créée

**Solution** : Exécutez `FIX_CREATION_ACTEUR.sql`

### "Certains champs obligatoires sont manquants..."

**Cause** : Des champs obligatoires (nom, adresse) ne sont pas remplis

**Solution** : Remplissez tous les champs obligatoires

### "Vous devez être connecté pour sauvegarder un acteur..."

**Cause** : Vous n'êtes pas connecté

**Solution** : Connectez-vous d'abord

## Vérifications SQL

### Vérifier que la table existe

```sql
SELECT * FROM information_schema.tables 
WHERE table_name = 'actors';
```

### Vérifier la structure de la table

```sql
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'actors'
ORDER BY ordinal_position;
```

### Vérifier les politiques RLS

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'actors'
ORDER BY policyname;
```

### Vérifier que RLS est activé

```sql
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname = 'actors';
```

## Si les menus ont disparu

### Vérifier le hook useAdmin

1. **Ouvrez la console** (F12)
2. **Vérifiez les erreurs** liées à `adminService.getUserRole`
3. **Vérifiez que la table `admin_users` existe**

### Vérifier que vous êtes connecté

1. **Vérifiez que `user` n'est pas null** dans la console
2. **Vérifiez que `user.id` existe**

### Vérifier les routes

1. **Vérifiez que les routes sont bien définies** dans `App.tsx`
2. **Vérifiez que les composants sont bien importés**

## Fichiers modifiés

- ✅ `src/components/Actors/ActorsPage.tsx` : Amélioration de la gestion des erreurs
- ✅ `FIX_CREATION_ACTEUR.sql` : Script de correction complet
- ✅ `GUIDE_FIX_CREATION_ACTEUR.md` : Ce guide

## Notes importantes

- Les acteurs sont maintenant stockés dans Supabase (pas dans localStorage)
- Chaque utilisateur ne voit que ses propres acteurs (grâce à RLS)
- Les menus admin/caissier sont visibles uniquement pour les utilisateurs ayant ces rôles
- Si le chargement des rôles échoue, les menus de base restent visibles

