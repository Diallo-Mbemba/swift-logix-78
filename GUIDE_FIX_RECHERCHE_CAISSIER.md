# 🔧 Guide - Résolution du problème de recherche d'utilisateurs

## ❌ Problème

La recherche d'utilisateurs pour créer un caissier ne fonctionne pas.

## 🔍 Causes possibles

1. **Politique RLS manquante** : Les admins n'ont pas la permission de voir tous les utilisateurs
2. **Utilisateur non authentifié** : L'admin n'est pas correctement connecté
3. **Utilisateur n'est pas admin** : Le compte n'a pas le rôle administrateur
4. **Erreur de syntaxe SQL** : Problème avec la requête de recherche

## ✅ Solutions

### Étape 1 : Vérifier que vous êtes connecté comme admin

1. Vérifiez que vous êtes bien connecté
2. Vérifiez que votre compte a le rôle `'admin'` dans la table `admin_users`

**Vérification SQL** :
```sql
SELECT 
  au.*,
  ua.email as user_email
FROM admin_users au
JOIN users_app ua ON au.user_id = ua.id
WHERE ua.email = 'VOTRE_EMAIL@example.com';
```

### Étape 2 : Exécuter le script SQL pour les permissions

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier `FIX_RLS_ADMIN_VIEW_USERS.sql`
3. Vérifiez que la politique a été créée

**Vérification** :
```sql
SELECT policyname 
FROM pg_policies 
WHERE tablename = 'users_app' 
  AND policyname = 'Admins can view all users';
```

### Étape 3 : Tester la recherche

1. Ouvrez la console du navigateur (F12)
2. Allez sur la page de gestion des caissiers
3. Essayez de rechercher un utilisateur
4. Regardez les logs dans la console :
   - `🔍 Recherche d'utilisateurs dans adminService...`
   - `✅ Utilisateur authentifié: ...`
   - `✅ Utilisateur est admin, recherche en cours...`
   - `✅ Recherche réussie: X utilisateurs trouvés`

### Étape 4 : Vérifier les erreurs

Si vous voyez une erreur dans la console :

**Erreur "Permission refusée" ou "RLS"** :
- Exécutez `FIX_RLS_ADMIN_VIEW_USERS.sql` dans Supabase
- Vérifiez que vous êtes connecté avec un compte admin

**Erreur "Vous devez être connecté"** :
- Déconnectez-vous et reconnectez-vous
- Vérifiez que la session Supabase est active

**Erreur "Seuls les administrateurs peuvent rechercher"** :
- Vérifiez que votre compte a le rôle `'admin'` dans `admin_users`
- Vérifiez que `is_active = true` dans `admin_users`

## 🧪 Test manuel dans Supabase

Exécutez cette requête dans le SQL Editor de Supabase (en étant connecté comme admin) :

```sql
-- Tester la recherche
SELECT 
  id,
  email,
  name
FROM users_app
WHERE email ILIKE '%test%' OR name ILIKE '%test%'
ORDER BY name ASC
LIMIT 20;
```

Si cette requête fonctionne mais pas l'application, le problème vient du code JavaScript.

## 📝 Scripts disponibles

- `FIX_RLS_ADMIN_VIEW_USERS.sql` : Ajoute la politique RLS pour permettre aux admins de voir tous les utilisateurs
- `TEST_RECHERCHE_USERS.sql` : Teste et vérifie que tout fonctionne correctement

## 🔄 Après avoir exécuté le script

1. **Rafraîchissez la page** dans votre navigateur
2. **Déconnectez-vous et reconnectez-vous** pour rafraîchir la session
3. **Essayez à nouveau la recherche**

## 📞 Si le problème persiste

1. Ouvrez la console du navigateur (F12)
2. Copiez tous les messages d'erreur
3. Vérifiez les logs dans la console :
   - Messages commençant par 🔍, ✅, ou ❌
   - Erreurs en rouge
4. Vérifiez que le script SQL a bien été exécuté et qu'il n'y a pas eu d'erreur

