# Guide : Correction de la récursion infinie dans les politiques RLS

## Problème identifié

L'erreur 500 était causée par une **récursion infinie** dans les politiques RLS :

```
users_app → SELECT → policy "Admins can view all users" 
  → SELECT admin_users 
    → policy RLS admin_users 
      → SELECT admin_users 
        → ... (boucle infinie)
```

PostgreSQL détecte cette récursion infinie et retourne l'erreur **42P17**, qui se traduit par une **erreur 500** dans l'API REST.

## Cause racine

La politique `"Admins can view all users"` sur `users_app` utilisait :

```sql
EXISTS (
  SELECT 1 FROM admin_users
  WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
)
```

Mais `admin_users` a elle-même des politiques RLS qui font référence à `admin_users`, créant une boucle infinie.

## Solution : Fonction SECURITY DEFINER

La solution est d'utiliser une **fonction SECURITY DEFINER** qui contourne RLS pour vérifier si un utilisateur est admin.

### Fonction créée

```sql
CREATE OR REPLACE FUNCTION is_user_admin(check_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  -- Cette fonction s'exécute avec les permissions du créateur (SECURITY DEFINER)
  -- donc elle contourne RLS et évite la récursion
  RETURN EXISTS (
    SELECT 1 FROM admin_users
    WHERE user_id = check_user_id
    AND role = 'admin'
    AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;
```

### Politique corrigée

```sql
CREATE POLICY "Admins can view all users" ON users_app
  FOR SELECT USING (
    -- Utiliser la fonction SECURITY DEFINER qui contourne RLS
    is_user_admin()
  );
```

## Application de la correction

### Étape 1 : Exécuter le script de correction

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`FIX_ERREUR_500_RECURSION.sql`**
3. Vérifiez qu'il n'y a **pas d'erreur** dans les résultats

Ce script va :
- ✅ Créer la fonction `is_user_admin()` avec `SECURITY DEFINER`
- ✅ Supprimer l'ancienne politique problématique
- ✅ Recréer la politique en utilisant la fonction
- ✅ Vérifier que tout est correctement configuré

### Étape 2 : Vérifier les résultats

Après avoir exécuté le script, vous devriez voir :

1. **Fonction créée** : ✅ `is_user_admin` avec Security Definer
2. **Politique créée** : ✅ "Admins can view all users" utilisant `is_user_admin()`
3. **RLS Status** : ✅ Activé (mais pas forcé)

### Étape 3 : Tester la connexion

1. **Déconnectez-vous** complètement de l'application
2. **Videz le cache du navigateur** (Ctrl+Shift+Delete)
3. **Fermez complètement le navigateur**
4. **Rouvrez le navigateur** et allez sur l'application
5. **Essayez de vous connecter** à nouveau

L'erreur 500 devrait être résolue.

## Pourquoi cette solution fonctionne

1. **SECURITY DEFINER** : La fonction s'exécute avec les permissions du créateur (généralement `postgres`), donc elle **contourne RLS** et évite la récursion.

2. **STABLE** : La fonction est marquée comme `STABLE`, ce qui permet à PostgreSQL de l'optimiser pour des requêtes répétées.

3. **Pas de récursion** : La politique n'utilise plus directement `SELECT` sur `admin_users`, mais appelle une fonction qui contourne RLS.

## Vérifications

### Vérifier que la fonction existe

```sql
SELECT 
  proname as "Function Name",
  CASE 
    WHEN prosecdef THEN '✅ Security Definer'
    ELSE '❌ Non Security Definer'
  END as "Security Definer"
FROM pg_proc
WHERE proname = 'is_user_admin';
```

### Vérifier les politiques

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition USING"
FROM pg_policies
WHERE tablename = 'users_app'
ORDER BY policyname;
```

**Vous devriez voir** :
- ✅ "Users can view own profile" avec `auth.uid() = id`
- ✅ "Admins can view all users" avec `is_user_admin()`

## Scripts mis à jour

Tous les scripts suivants ont été mis à jour pour utiliser la fonction `is_user_admin()` :

- ✅ `FIX_ERREUR_500_RECURSION.sql` (nouveau script dédié)
- ✅ `FIX_PROFIL_COMPLET.sql`
- ✅ `FIX_CONNEXION_DEFINITIF.sql`
- ✅ `FIX_ERREUR_500_FINAL.sql`
- ✅ `FIX_RLS_PROFIL_CONNEXION.sql`
- ✅ `RESTAURER_CONNEXION_INSCRIPTION.sql`

## Prévention

Pour éviter ce problème à l'avenir :

1. **Ne faites jamais de SELECT direct sur une table protégée par RLS** dans une politique RLS
2. **Utilisez toujours des fonctions SECURITY DEFINER** pour vérifier les rôles ou permissions
3. **Testez toujours** les politiques RLS pour détecter les récursions
4. **Consultez les logs PostgreSQL** si vous voyez des erreurs 42P17

## Si le problème persiste

Si après avoir exécuté le script l'erreur 500 persiste :

1. **Vérifiez les logs Supabase** pour voir l'erreur exacte
2. **Vérifiez que la fonction `is_user_admin()` existe** et est `SECURITY DEFINER`
3. **Vérifiez que la politique utilise bien `is_user_admin()`** et non un SELECT direct
4. **Testez la fonction manuellement** :
   ```sql
   SELECT is_user_admin();
   ```

## Références

- [PostgreSQL RLS Documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [SECURITY DEFINER Functions](https://www.postgresql.org/docs/current/sql-createfunction.html#SQL-CREATEFUNCTION-SECURITY)

