# Guide de résolution : Erreur 500 lors de la récupération du profil

## Problème

Lors de la connexion, vous rencontrez une erreur 500 avec les messages suivants dans la console :

```
❌ Erreur lors de la récupération du profil
Failed to load resource: the server responded with a status of 500 ()
❌ Le profil n'a toujours pas pu être chargé après deux tentatives
```

## Cause

Cette erreur est généralement causée par :
1. **Conflit entre les politiques RLS** : Plusieurs politiques RLS sur `users_app` peuvent entrer en conflit
2. **Politique RLS manquante ou mal configurée** : La politique "Users can view own profile" n'existe pas ou est incorrecte
3. **Problème avec `auth.uid()`** : La fonction `auth.uid()` ne retourne pas la valeur attendue
4. **Profil manquant** : Le profil n'existe pas dans `users_app` pour l'utilisateur authentifié

## Solution

### Étape 1 : Exécuter le script SQL de correction

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier `FIX_RLS_PROFIL_CONNEXION.sql`
3. Vérifiez qu'il n'y a pas d'erreur dans les résultats

Ce script va :
- Supprimer toutes les politiques RLS existantes pour `users_app`
- Recréer les politiques correctement dans le bon ordre
- Vérifier que RLS est activé
- Vérifier que le trigger et la fonction de création de profil existent

### Étape 2 : Vérifier que le profil existe

Après avoir exécuté le script, vérifiez que votre profil existe dans `users_app` :

```sql
-- Remplacer USER_ID par votre ID d'utilisateur (visible dans la console)
SELECT * FROM users_app WHERE id = 'USER_ID';
```

Si le profil n'existe pas :
1. Vérifiez que le trigger `on_auth_user_created` est actif
2. Créez le profil manuellement si nécessaire (voir ci-dessous)

### Étape 3 : Tester la connexion

1. **Déconnectez-vous** complètement de l'application
2. **Rafraîchissez la page** (F5)
3. **Connectez-vous** à nouveau
4. **Ouvrez la console** (F12) pour voir les logs

### Étape 4 : Vérifier les logs

Dans la console, vous devriez voir :
- ✅ `Utilisateur authentifié: [USER_ID]`
- ✅ `Profil récupéré avec succès`

Si vous voyez toujours une erreur 500 :
1. Copiez les messages d'erreur complets de la console
2. Vérifiez les logs Supabase dans le dashboard
3. Consultez la section "Diagnostic avancé" ci-dessous

## Création manuelle du profil (si nécessaire)

Si le profil n'existe pas dans `users_app`, créez-le manuellement :

```sql
-- 1. Récupérer l'ID et l'email depuis auth.users
SELECT id, email, raw_user_meta_data->>'name' as name
FROM auth.users
WHERE email = 'VOTRE_EMAIL@example.com';

-- 2. Créer le profil dans users_app
INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
VALUES (
  'ID_FROM_AUTH_USERS',
  'VOTRE_EMAIL@example.com',
  'Nom Utilisateur',
  'free',
  3,
  3
);
```

## Diagnostic avancé

### Vérifier les politiques RLS

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition USING"
FROM pg_policies
WHERE tablename = 'users_app'
ORDER BY policyname;
```

Vous devriez voir au moins :
- ✅ "Users can view own profile" (SELECT)
- ✅ "Users can update own profile" (UPDATE)
- ✅ "Allow service role to insert profiles" (INSERT)
- ✅ "Admins can view all users" (SELECT)

### Vérifier que RLS est activé

```sql
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname = 'users_app';
```

### Tester la politique RLS directement

Dans le SQL Editor de Supabase, vous pouvez tester la politique en simulant un utilisateur :

```sql
-- Simuler un utilisateur authentifié
SELECT set_config('request.jwt.claims', '{"sub": "VOTRE_USER_ID"}', true);

-- Tester la requête
SELECT * FROM users_app WHERE id = auth.uid();
```

**Note** : Cette méthode de test peut ne pas fonctionner dans tous les contextes. Le test le plus fiable est de se connecter via l'application.

### Vérifier les profils orphelins

```sql
-- Vérifier s'il y a des utilisateurs dans auth.users sans profil dans users_app
SELECT 
  au.id,
  au.email,
  CASE 
    WHEN ua.id IS NULL THEN '❌ Profil manquant'
    ELSE '✅ Profil existe'
  END as status
FROM auth.users au
LEFT JOIN users_app ua ON au.id = ua.id
WHERE ua.id IS NULL;
```

## Erreurs courantes et solutions

### Erreur : "PGRST116 - No rows found"
**Cause** : Le profil n'existe pas dans `users_app`  
**Solution** : Créez le profil manuellement (voir section ci-dessus)

### Erreur : "42501 - permission denied"
**Cause** : La politique RLS bloque l'accès  
**Solution** : Exécutez `FIX_RLS_PROFIL_CONNEXION.sql` à nouveau

### Erreur : "500 - Internal Server Error"
**Cause** : Problème SQL interne, souvent lié aux politiques RLS  
**Solution** :
1. Vérifiez les logs Supabase pour plus de détails
2. Exécutez `FIX_RLS_PROFIL_CONNEXION.sql`
3. Vérifiez que toutes les politiques sont correctement créées

### Le profil se charge mais l'application ne fonctionne toujours pas
**Cause** : Problème de cache ou de state dans l'application  
**Solution** :
1. Déconnectez-vous complètement
2. Videz le cache du navigateur (Ctrl+Shift+Delete)
3. Rafraîchissez la page (F5)
4. Reconnectez-vous

## Prévention

Pour éviter ce problème à l'avenir :

1. **Ne modifiez pas les politiques RLS manuellement** sans comprendre leur impact
2. **Testez toujours après avoir modifié les politiques RLS**
3. **Vérifiez que le trigger `on_auth_user_created` est actif** lors de la création de nouveaux utilisateurs
4. **Utilisez les scripts SQL fournis** plutôt que de créer les politiques manuellement

## Support supplémentaire

Si le problème persiste après avoir suivi ce guide :

1. **Collectez les informations suivantes** :
   - Messages d'erreur complets de la console (F12)
   - Résultats de la requête de vérification des politiques RLS
   - Résultats de la requête de vérification du profil
   - Logs Supabase (si disponibles)

2. **Vérifiez que** :
   - Vous êtes bien connecté avec un compte valide
   - Le profil existe dans `users_app`
   - Les politiques RLS sont correctement configurées
   - RLS est activé sur `users_app`

3. **Consultez les autres guides** :
   - `GUIDE_FIX_ACCESS.md` : Pour les problèmes d'accès après inscription
   - `FIX_CONNEXION_BLOQUEE.md` : Pour les problèmes de connexion bloquée
   - `DEPANNAGE_INSCRIPTION.md` : Pour les problèmes d'inscription

