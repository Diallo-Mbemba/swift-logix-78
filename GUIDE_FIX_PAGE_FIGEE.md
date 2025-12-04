# Guide de résolution : Page de connexion figée

## Problème

La page de connexion reste figée après avoir entré les identifiants, avec un indicateur de chargement qui ne se termine jamais.

## Causes possibles

1. **Erreur 500 lors du chargement du profil** : Les politiques RLS bloquent l'accès au profil
2. **Timeout du chargement** : Le chargement du profil prend trop de temps
3. **Erreur non gérée** : Une exception n'est pas correctement capturée
4. **Boucle infinie** : Le chargement du profil échoue et se relance indéfiniment

## Solutions

### Solution 1 : Exécuter le script SQL de correction (PRIORITAIRE)

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier `FIX_RLS_PROFIL_CONNEXION.sql`
3. Vérifiez qu'il n'y a pas d'erreur dans les résultats
4. Rafraîchissez la page (F5)
5. Essayez de vous connecter à nouveau

### Solution 2 : Vérifier que le profil existe

Si le script SQL ne résout pas le problème, vérifiez que votre profil existe :

```sql
-- Remplacer USER_ID par votre ID d'utilisateur
SELECT * FROM users_app WHERE id = 'USER_ID';
```

Si le profil n'existe pas :
1. Vérifiez que le trigger `on_auth_user_created` est actif
2. Créez le profil manuellement si nécessaire (voir section ci-dessous)

### Solution 3 : Vider le cache et réessayer

1. **Déconnectez-vous** complètement de l'application
2. **Videz le cache du navigateur** :
   - Chrome/Edge : `Ctrl+Shift+Delete` → Cochez "Images et fichiers en cache" → Effacer
   - Firefox : `Ctrl+Shift+Delete` → Cochez "Cache" → Effacer
3. **Fermez complètement le navigateur**
4. **Rouvrez le navigateur** et allez sur l'application
5. **Essayez de vous connecter** à nouveau

### Solution 4 : Vérifier les logs de la console

1. Ouvrez la **console du navigateur** (F12)
2. Allez sur l'onglet **Console**
3. Essayez de vous connecter
4. Regardez les messages d'erreur

**Messages à rechercher** :
- `❌ Erreur 500: Problème serveur lors de la récupération du profil`
- `❌ Erreur RLS: La politique de sécurité bloque l'accès au profil`
- `❌ Le profil n'a toujours pas pu être chargé après deux tentatives`

**Actions selon le message** :
- **Erreur 500** : Exécutez `FIX_RLS_PROFIL_CONNEXION.sql`
- **Erreur RLS** : Exécutez `FIX_RLS_PROFIL_CONNEXION.sql`
- **Profil non trouvé** : Créez le profil manuellement (voir ci-dessous)

## Création manuelle du profil

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

## Améliorations apportées au code

Les corrections suivantes ont été apportées pour éviter que la page reste figée :

1. **Timeout global dans `login()`** : La fonction `login` a maintenant un timeout de 15 secondes maximum
2. **Timeout de sécurité dans l'initialisation** : L'initialisation de l'application a un timeout de 10 secondes
3. **Gestion d'erreur améliorée** : Toutes les erreurs sont maintenant capturées et `loading` est toujours mis à `false`
4. **Messages d'erreur plus clairs** : Les messages d'erreur indiquent maintenant les scripts SQL à exécuter

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

## Prévention

Pour éviter ce problème à l'avenir :

1. **Exécutez toujours les scripts SQL de correction** avant de signaler un problème
2. **Vérifiez les politiques RLS** après chaque modification de la base de données
3. **Testez la connexion** après chaque modification des politiques RLS
4. **Consultez les logs** de la console pour identifier rapidement les problèmes

## Si le problème persiste

Si après avoir suivi toutes ces étapes le problème persiste :

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
   - Le script `FIX_RLS_PROFIL_CONNEXION.sql` a été exécuté sans erreur

3. **Consultez les autres guides** :
   - `GUIDE_FIX_PROFIL_CONNEXION.md` : Pour les erreurs 500 lors du chargement du profil
   - `GUIDE_FIX_ACCESS.md` : Pour les problèmes d'accès après inscription
   - `FIX_CONNEXION_BLOQUEE.md` : Pour les problèmes de connexion bloquée

