# 🔧 Guide - Résolution du problème de création de caissier

## ❌ Problème

Erreur lors de la création d'un caissier : "Erreur de permissions. Assurez-vous que vous êtes connecté avec un compte administrateur et que les politiques RLS sont correctement configurées."

## 🔍 Causes possibles

1. **Politique RLS manquante** : La politique "Admins can insert admin users" n'existe pas ou n'est pas correctement configurée
2. **Utilisateur non authentifié** : L'admin n'est pas correctement connecté
3. **Utilisateur n'est pas admin** : Le compte n'a pas le rôle `'admin'` dans `admin_users`
4. **RLS bloquant l'insertion** : Les politiques RLS empêchent l'insertion dans `admin_users`

## ✅ Solutions

### Étape 1 : Vérifier que vous êtes connecté comme admin

1. Vérifiez que vous êtes bien connecté
2. Vérifiez que votre compte a le rôle `'admin'` dans la table `admin_users`

**Vérification SQL** :
```sql
-- Vérifier votre compte admin
SELECT 
  au.*,
  ua.email as user_email
FROM admin_users au
JOIN users_app ua ON au.user_id = ua.id
WHERE ua.email = 'VOTRE_EMAIL@example.com';
```

**Résultat attendu** :
- `role` doit être `'admin'`
- `is_active` doit être `true`

### Étape 2 : Exécuter le script SQL pour les permissions

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier `FIX_RLS_ADMIN_USERS.sql`
3. Vérifiez qu'il n'y a pas d'erreur

**Ce script crée les politiques suivantes** :
- `Admins can view all admin users` : Permet aux admins de voir tous les comptes
- `Admins can insert admin users` : **Permet aux admins de créer des caissiers** ⭐
- `Admins can update admin users` : Permet aux admins de modifier les comptes
- `Admins can delete admin users` : Permet aux admins de supprimer les comptes

### Étape 3 : Vérifier que les politiques existent

Exécutez cette requête dans Supabase :

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE tablename = 'admin_users'
ORDER BY policyname;
```

**Résultat attendu** : Vous devriez voir au moins 4 politiques, dont "Admins can insert admin users"

### Étape 4 : Tester la création

1. **Rafraîchissez la page** dans votre navigateur (F5)
2. **Déconnectez-vous et reconnectez-vous** pour rafraîchir la session
3. Allez sur `/admin/cashiers`
4. Essayez de créer un caissier
5. Ouvrez la console (F12) et regardez les logs :
   - `✅ Vérification admin réussie, création du caissier...`
   - `🔄 Insertion du caissier dans admin_users...`
   - `✅ Caissier créé avec succès: ...`

## 🧪 Test manuel dans Supabase

Exécutez cette requête dans le SQL Editor de Supabase (en étant connecté comme admin) :

```sql
-- Tester l'insertion d'un caissier (remplacez les valeurs)
-- Note: Cette requête doit être exécutée en étant connecté comme admin
INSERT INTO admin_users (
  id,
  user_id,
  name,
  email,
  role,
  permissions,
  is_active,
  created_at
) VALUES (
  gen_random_uuid(),
  'UUID_DE_L_UTILISATEUR_CIBLE',  -- Remplacez par l'ID réel
  'Nom du Caissier',
  'email@caissier.com',
  'cashier',
  ARRAY['validate_orders'],
  true,
  NOW()
);
```

Si cette requête fonctionne mais pas l'application, le problème vient du code JavaScript.

## 📝 Scripts disponibles

- `FIX_RLS_ADMIN_USERS.sql` : **Script principal** - Ajoute toutes les politiques RLS nécessaires pour admin_users
- `CREATE_FIRST_ADMIN.sql` : Pour créer le premier compte admin (si nécessaire)

## 🔄 Après avoir exécuté le script

1. **Rafraîchissez la page** dans votre navigateur (F5)
2. **Déconnectez-vous et reconnectez-vous** pour rafraîchir la session Supabase
3. **Essayez à nouveau de créer un caissier**

## 📞 Si le problème persiste

1. Ouvrez la console du navigateur (F12)
2. Copiez tous les messages d'erreur
3. Vérifiez les logs dans la console :
   - Messages commençant par 🔍, ✅, ou ❌
   - Erreurs en rouge
4. Vérifiez que :
   - Le script SQL a bien été exécuté sans erreur
   - Vous êtes bien connecté avec un compte admin
   - Votre compte a `role = 'admin'` et `is_active = true` dans `admin_users`

## ⚠️ Important

- L'utilisateur cible doit **d'abord exister dans `users_app`** (créé lors de l'inscription)
- Un utilisateur ne peut avoir qu'**un seul compte admin/caissier**
- Les politiques RLS doivent être créées **avant** de pouvoir créer des caissiers

