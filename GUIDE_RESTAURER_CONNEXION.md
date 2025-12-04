# Guide de restauration : Connexion et création de compte

## Problème

Après avoir exécuté les scripts SQL de correction RLS, la connexion et la création de compte ne fonctionnent plus alors qu'elles fonctionnaient avant.

## Cause

Les scripts RLS ont peut-être :
1. **Supprimé ou modifié la politique INSERT** nécessaire pour que le trigger crée le profil
2. **Créé des conflits entre les politiques** qui bloquent la création de profil
3. **Désactivé ou cassé le trigger** `on_auth_user_created`

## Solution : Script de restauration

### Étape 1 : Exécuter le script de restauration

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`RESTAURER_CONNEXION_INSCRIPTION.sql`**
3. Vérifiez qu'il n'y a **pas d'erreur** dans les résultats

Ce script va :
- ✅ Vérifier et recréer le trigger `on_auth_user_created` si nécessaire
- ✅ Supprimer toutes les politiques RLS existantes pour `users_app`
- ✅ Recréer les politiques correctement avec une politique INSERT permissive
- ✅ Vérifier que tout est correctement configuré

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

### Étape 3 : Tester la création de compte

1. **Déconnectez-vous** complètement de l'application
2. **Rafraîchissez la page** (F5)
3. **Essayez de créer un nouveau compte**
4. Vérifiez que :
   - L'inscription fonctionne sans erreur
   - Le profil est créé automatiquement
   - Vous pouvez vous connecter immédiatement après l'inscription

### Étape 4 : Tester la connexion

1. **Essayez de vous connecter** avec un compte existant
2. Vérifiez que :
   - La connexion fonctionne sans erreur
   - Le profil est chargé correctement
   - Vous accédez au dashboard

## Diagnostic si ça ne fonctionne toujours pas

### Vérifier que le trigger fonctionne

```sql
-- Vérifier que le trigger existe et est actif
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
-- Réactiver le trigger
ALTER TABLE auth.users ENABLE TRIGGER on_auth_user_created;
```

### Vérifier que la fonction est SECURITY DEFINER

```sql
-- Vérifier que la fonction existe et est SECURITY DEFINER
SELECT 
  proname as "Function Name",
  CASE 
    WHEN prosecdef THEN '✅ Security Definer'
    ELSE '❌ Non Security Definer'
  END as "Security Definer"
FROM pg_proc
WHERE proname = 'create_user_profile';
```

**Si la fonction n'est pas SECURITY DEFINER** :
```sql
-- Recréer la fonction avec SECURITY DEFINER
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users_app (id, email, name, plan, remaining_credits, total_credits)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    'free',
    3,
    3
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    RAISE WARNING 'Erreur lors de la création du profil utilisateur pour %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Vérifier les politiques RLS

```sql
-- Vérifier que toutes les politiques sont créées
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY policyname;
```

**Vous devriez voir** :
- ✅ "Users can view own profile" (SELECT)
- ✅ "Users can update own profile" (UPDATE)
- ✅ "Allow trigger to insert profiles" (INSERT) avec `WITH CHECK (true)`
- ✅ "Admins can view all users" (SELECT)

**Si la politique INSERT n'existe pas ou n'est pas permissive** :
```sql
-- Créer la politique INSERT permissive
CREATE POLICY "Allow trigger to insert profiles" ON users_app
  FOR INSERT 
  WITH CHECK (true);
```

### Vérifier les permissions

```sql
-- Vérifier les permissions sur la table
SELECT 
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND table_name = 'users_app';
```

**Si les permissions manquent** :
```sql
-- Accorder les permissions nécessaires
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users_app TO postgres, anon, authenticated, service_role;
```

## Test manuel du trigger

Pour tester si le trigger fonctionne manuellement :

```sql
-- Créer un utilisateur de test dans auth.users (via Supabase Auth, pas directement)
-- Puis vérifier que le profil a été créé :
SELECT * FROM users_app ORDER BY created_at DESC LIMIT 1;
```

**Si le profil n'a pas été créé automatiquement** :
1. Vérifiez les logs Supabase pour voir les erreurs du trigger
2. Vérifiez que la fonction `create_user_profile()` existe et est SECURITY DEFINER
3. Vérifiez que le trigger est actif

## Solution alternative : Création manuelle du profil

Si le trigger ne fonctionne toujours pas, vous pouvez créer le profil manuellement après l'inscription :

```sql
-- 1. Récupérer l'ID de l'utilisateur depuis auth.users
SELECT id, email, raw_user_meta_data->>'name' as name
FROM auth.users
WHERE email = 'EMAIL_DE_L_UTILISATEUR@example.com';

-- 2. Créer le profil manuellement
INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
VALUES (
  'ID_FROM_AUTH_USERS',
  'EMAIL_DE_L_UTILISATEUR@example.com',
  'Nom Utilisateur',
  'free',
  3,
  3
);
```

## Prévention

Pour éviter ce problème à l'avenir :

1. **Ne modifiez pas les politiques RLS** sans comprendre leur impact
2. **Testez toujours** la connexion et l'inscription après avoir modifié les politiques RLS
3. **Conservez une copie** des politiques RLS qui fonctionnent
4. **Utilisez les scripts de restauration** si quelque chose ne fonctionne plus

## Si le problème persiste

Si après avoir suivi toutes ces étapes le problème persiste :

1. **Collectez les informations suivantes** :
   - Messages d'erreur complets lors de la création de compte
   - Messages d'erreur complets lors de la connexion
   - Résultats de toutes les requêtes de vérification ci-dessus
   - Logs Supabase (si disponibles)

2. **Vérifiez que** :
   - La table `users_app` existe et a les bonnes colonnes
   - Le trigger `on_auth_user_created` existe et est actif
   - La fonction `create_user_profile()` existe et est SECURITY DEFINER
   - Les politiques RLS sont correctement configurées
   - Les permissions sont correctement accordées

3. **Consultez les autres guides** :
   - `GUIDE_FIX_PROFIL_CONNEXION.md` : Pour les erreurs 500 lors du chargement du profil
   - `GUIDE_FIX_PAGE_FIGEE.md` : Pour les problèmes de page figée
   - `SOLUTION_INSCRIPTION.md` : Pour les problèmes d'inscription
   - `FIX_TRIGGER.sql` : Pour corriger le trigger de création de profil

