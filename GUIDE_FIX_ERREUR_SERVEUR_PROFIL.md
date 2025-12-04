# Guide de résolution : Erreur serveur lors du chargement du profil

## Message d'erreur

```
Erreur serveur lors du chargement du profil. 
Exécutez FIX_RLS_PROFIL_CONNEXION.sql dans Supabase. 
Consultez GUIDE_FIX_PROFIL_CONNEXION.md
```

## Solution rapide

### Étape 1 : Exécuter le script de correction complet

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`FIX_PROFIL_COMPLET.sql`**
3. Vérifiez qu'il n'y a **pas d'erreur** dans les résultats

Ce script va :
- ✅ Recréer le trigger pour la création automatique de profil
- ✅ Supprimer **TOUTES** les politiques RLS existantes
- ✅ Recréer les politiques dans le **BON ORDRE** pour que tout fonctionne

### Étape 2 : Vérifier les résultats

Après avoir exécuté le script, vous devriez voir dans les résultats :

1. **RLS Status** : ✅ Activé
2. **Politiques créées** :
   - ✅ "Users can view own profile" (SELECT)
   - ✅ "Users can update own profile" (UPDATE)
   - ✅ "Allow trigger to insert profiles" (INSERT)
   - ✅ "Admins can view all users" (SELECT)
3. **Trigger** : ✅ Activé
4. **Fonction** : ✅ Security Definer

### Étape 3 : Tester la connexion

1. **Déconnectez-vous** complètement de l'application
2. **Videz le cache du navigateur** (Ctrl+Shift+Delete)
3. **Fermez complètement le navigateur**
4. **Rouvrez le navigateur** et allez sur l'application
5. **Essayez de vous connecter** à nouveau

## Pourquoi ce script fonctionne

Le script `FIX_PROFIL_COMPLET.sql` :
1. **Supprime toutes les politiques existantes** pour éviter les conflits
2. **Recrée les politiques dans le bon ordre** :
   - D'abord la politique de base "Users can view own profile" (pour tous les utilisateurs)
   - Ensuite la politique pour les admins "Admins can view all users"
3. **Utilise une politique INSERT permissive** pour garantir que le trigger fonctionne
4. **Vérifie que tout est correctement configuré** avec des requêtes de diagnostic

## Si ça ne fonctionne toujours pas

### Vérifier que les politiques sont créées

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition USING"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY policyname;
```

**Vous devriez voir au moins** :
- ✅ "Users can view own profile" (SELECT) avec `auth.uid() = id`
- ✅ "Admins can view all users" (SELECT)
- ✅ "Allow trigger to insert profiles" (INSERT)

### Vérifier que votre profil existe

```sql
-- Remplacer USER_ID par votre ID d'utilisateur
SELECT * FROM users_app WHERE id = 'USER_ID';
```

**Si le profil n'existe pas** :
1. Vérifiez que le trigger est actif (voir ci-dessous)
2. Créez le profil manuellement si nécessaire

### Vérifier que le trigger est actif

```sql
SELECT 
  tgname as "Trigger Name",
  CASE 
    WHEN tgenabled = 'O' THEN '✅ Activé'
    WHEN tgenabled = 'D' THEN '❌ Désactivé'
    ELSE tgenabled
  END as "Status"
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';
```

**Si le trigger est désactivé** :
```sql
ALTER TABLE auth.users ENABLE TRIGGER on_auth_user_created;
```

### Vérifier les logs Supabase

1. Allez dans le **Dashboard Supabase**
2. Ouvrez **Logs** > **Postgres Logs**
3. Cherchez les erreurs liées à `users_app` ou `RLS`
4. Les erreurs vous indiqueront exactement quel est le problème

## Création manuelle du profil (si nécessaire)

Si votre profil n'existe pas dans `users_app`, créez-le manuellement :

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

## Différence avec les autres scripts

- **`FIX_RLS_PROFIL_CONNEXION.sql`** : Script original, peut avoir des conflits
- **`FIX_CONNEXION_DEFINITIF.sql`** : Script pour la connexion, mais peut ne pas résoudre l'erreur 500
- **`FIX_PROFIL_COMPLET.sql`** : Script complet qui combine toutes les corrections et garantit que tout fonctionne

## Prévention

Pour éviter ce problème à l'avenir :

1. **Utilisez toujours `FIX_PROFIL_COMPLET.sql`** si vous avez des problèmes avec les politiques RLS
2. **Ne modifiez pas les politiques RLS manuellement** sans comprendre leur impact
3. **Testez toujours** la connexion après avoir modifié les politiques RLS
4. **Conservez une copie** des politiques RLS qui fonctionnent

## Support supplémentaire

Si le problème persiste après avoir suivi toutes ces étapes :

1. **Collectez les informations suivantes** :
   - Messages d'erreur complets de la console (F12)
   - Résultats de toutes les requêtes de vérification ci-dessus
   - Logs Supabase (si disponibles)

2. **Vérifiez que** :
   - La table `users_app` existe et a les bonnes colonnes
   - Le trigger `on_auth_user_created` existe et est actif
   - La fonction `create_user_profile()` existe et est SECURITY DEFINER
   - Les politiques RLS sont correctement configurées
   - Les permissions sont correctement accordées

3. **Consultez les autres guides** :
   - `GUIDE_FIX_CONNEXION_DEFINITIF.md` : Pour les problèmes de connexion
   - `GUIDE_FIX_PAGE_FIGEE.md` : Pour les problèmes de page figée
   - `GUIDE_RESTAURER_CONNEXION.md` : Pour restaurer la connexion et l'inscription

