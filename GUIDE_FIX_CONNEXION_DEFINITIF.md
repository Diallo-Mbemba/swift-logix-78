# Guide de résolution définitive : Connexion et création de compte

## Problème identifié

Le problème est survenu après avoir exécuté `FIX_RLS_ADMIN_VIEW_USERS.sql` pour permettre aux admins de voir tous les utilisateurs. Ce script a créé une politique RLS qui **bloque l'accès des utilisateurs normaux à leur propre profil**.

### Cause racine

Le script `FIX_RLS_ADMIN_VIEW_USERS.sql` a créé une politique "Admins can view all users" qui :
- ✅ Permet aux admins de voir tous les utilisateurs
- ❌ **NE permet PAS aux utilisateurs normaux de voir leur propre profil**

Cette politique vérifie uniquement si l'utilisateur est admin, mais ne vérifie pas `auth.uid() = id`, ce qui est nécessaire pour que les utilisateurs normaux puissent voir leur propre profil.

## Solution : Script de correction définitive

### Étape 1 : Exécuter le script de correction

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`FIX_CONNEXION_DEFINITIF.sql`**
3. Vérifiez qu'il n'y a **pas d'erreur** dans les résultats

Ce script va :
- ✅ Recréer le trigger `on_auth_user_created` pour la création automatique de profil
- ✅ Supprimer **TOUTES** les politiques RLS existantes pour `users_app`
- ✅ Recréer les politiques dans le **BON ORDRE** :
  1. **"Users can view own profile"** (EN PREMIER) - permet à tous les utilisateurs de voir leur propre profil
  2. **"Users can update own profile"** - permet aux utilisateurs de mettre à jour leur profil
  3. **"Allow trigger to insert profiles"** - permet au trigger de créer le profil
  4. **"Admins can view all users"** (APRÈS) - permet aux admins de voir tous les utilisateurs

### Étape 2 : Vérifier les résultats

Après avoir exécuté le script, vous devriez voir dans les résultats :

1. **RLS Status** : ✅ Activé
2. **Politiques créées** (dans cet ordre) :
   - ✅ "Users can view own profile" (SELECT) - `auth.uid() = id`
   - ✅ "Users can update own profile" (UPDATE) - `auth.uid() = id`
   - ✅ "Allow trigger to insert profiles" (INSERT) - `WITH CHECK (true)`
   - ✅ "Admins can view all users" (SELECT) - vérifie si admin
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

1. **Essayez de vous connecter** avec un compte utilisateur normal (pas admin)
2. Vérifiez que :
   - La connexion fonctionne sans erreur
   - Le profil est chargé correctement
   - Vous accédez au dashboard

### Étape 5 : Tester avec un compte admin

1. **Connectez-vous avec un compte admin**
2. Vérifiez que :
   - La connexion fonctionne
   - Vous pouvez voir tous les utilisateurs (si vous avez une page de gestion des utilisateurs)

## Pourquoi l'ordre des politiques est important

En PostgreSQL, quand plusieurs politiques RLS utilisent le même type d'opération (SELECT, INSERT, etc.), elles sont combinées avec **OR**. Cela signifie que si **AU MOINS UNE** politique autorise l'accès, l'utilisateur peut accéder.

Cependant, l'ordre de création peut affecter l'évaluation des politiques. C'est pourquoi il est important de :
1. Créer la politique de base **EN PREMIER** : "Users can view own profile"
2. Créer la politique pour les admins **APRÈS** : "Admins can view all users"

## Différences avec les scripts précédents

### Script problématique (`FIX_RLS_ADMIN_VIEW_USERS.sql`)
```sql
CREATE POLICY "Admins can view all users" ON users_app
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );
```
**Problème** : Cette politique ne permet PAS aux utilisateurs normaux de voir leur propre profil.

### Script de correction (`FIX_CONNEXION_DEFINITIF.sql`)
```sql
-- 1. Politique de base (EN PREMIER)
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT USING (auth.uid() = id);

-- 2. Politique pour les admins (APRÈS)
CREATE POLICY "Admins can view all users" ON users_app
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() 
      AND role = 'admin' 
      AND is_active = true
    )
  );
```
**Solution** : Les deux politiques sont combinées avec OR, donc :
- Les utilisateurs normaux peuvent voir leur propre profil (politique #1)
- Les admins peuvent voir tous les utilisateurs (politique #2)

## Diagnostic si ça ne fonctionne toujours pas

### Vérifier que les politiques sont dans le bon ordre

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

**Vous devriez voir** :
1. "Admins can view all users" (SELECT)
2. "Allow trigger to insert profiles" (INSERT)
3. "Users can update own profile" (UPDATE)
4. "Users can view own profile" (SELECT)

**Note** : L'ordre alphabétique peut être différent, mais les deux politiques SELECT doivent exister.

### Vérifier que la politique de base fonctionne

```sql
-- Tester si un utilisateur peut voir son propre profil
-- (à exécuter dans le contexte d'un utilisateur authentifié)
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM users_app 
      WHERE id = auth.uid()
    ) THEN '✅ L''utilisateur peut voir son propre profil'
    ELSE '❌ L''utilisateur NE PEUT PAS voir son propre profil'
  END as "Test Politique";
```

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

## Prévention

Pour éviter ce problème à l'avenir :

1. **Ne modifiez pas les politiques RLS de base** sans comprendre leur impact
2. **Testez toujours** la connexion et l'inscription après avoir modifié les politiques RLS
3. **Créez les politiques dans le bon ordre** :
   - Politiques de base d'abord
   - Politiques spéciales (admins, etc.) après
4. **Utilisez le script `FIX_CONNEXION_DEFINITIF.sql`** si quelque chose ne fonctionne plus

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
   - Les politiques RLS sont correctement configurées (voir requêtes de vérification)
   - Les permissions sont correctement accordées

3. **Consultez les autres guides** :
   - `GUIDE_RESTAURER_CONNEXION.md` : Pour restaurer la connexion et l'inscription
   - `GUIDE_FIX_PROFIL_CONNEXION.md` : Pour les erreurs 500 lors du chargement du profil
   - `GUIDE_FIX_PAGE_FIGEE.md` : Pour les problèmes de page figée

