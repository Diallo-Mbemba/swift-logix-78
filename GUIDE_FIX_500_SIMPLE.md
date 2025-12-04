# Guide simple : Erreur 500 lors du chargement du profil

## Problème

Vous voyez cette erreur dans la console :
```
❌ Erreur lors de la récupération du profil
Failed to load resource: the server responded with a status of 500 ()
```

## Solution en 2 étapes

### Étape 1 : Exécuter le script de diagnostic

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`DIAGNOSTIC_ERREUR_500.sql`**
3. Regardez les résultats de la première requête :
   - **Si le profil existe** : Vous verrez les informations du profil
   - **Si le profil n'existe pas** : La requête ne retournera rien

### Étape 2 : Exécuter le script de correction

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`FIX_ERREUR_500_FINAL.sql`**
3. Ce script va :
   - ✅ Créer le profil s'il n'existe pas
   - ✅ Recréer toutes les politiques RLS correctement
   - ✅ S'assurer que RLS n'est pas forcé (ce qui peut causer des erreurs 500)
   - ✅ Vérifier que tout est correctement configuré

### Étape 3 : Tester la connexion

1. **Déconnectez-vous** complètement de l'application
2. **Videz le cache du navigateur** (Ctrl+Shift+Delete)
3. **Fermez complètement le navigateur**
4. **Rouvrez le navigateur** et allez sur l'application
5. **Essayez de vous connecter** à nouveau

## Vérifications après l'exécution

Après avoir exécuté `FIX_ERREUR_500_FINAL.sql`, vous devriez voir dans les résultats :

1. **Profil créé ou existant** : ✅
2. **RLS Status** : ✅ Activé (mais pas forcé)
3. **Politiques créées** :
   - ✅ "Users can view own profile" (SELECT)
   - ✅ "Users can update own profile" (UPDATE)
   - ✅ "Allow trigger to insert profiles" (INSERT)
   - ✅ "Admins can view all users" (SELECT)
4. **Trigger** : ✅ Activé

## Si ça ne fonctionne toujours pas

### Vérifier que le profil existe

```sql
SELECT * FROM users_app WHERE id = 'dab872d3-6e7f-4980-92b7-70cd5ae246b5';
```

**Si le profil n'existe toujours pas**, créez-le manuellement :

```sql
-- 1. Récupérer l'email depuis auth.users
SELECT id, email, raw_user_meta_data->>'name' as name
FROM auth.users
WHERE id = 'dab872d3-6e7f-4980-92b7-70cd5ae246b5';

-- 2. Créer le profil (remplacez EMAIL par l'email récupéré)
INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
VALUES (
  'dab872d3-6e7f-4980-92b7-70cd5ae246b5',
  'EMAIL_DE_L_UTILISATEUR@example.com',
  'Nom Utilisateur',
  'free',
  3,
  3
);
```

### Vérifier que RLS n'est pas forcé

```sql
SELECT 
  relname,
  relrowsecurity as "RLS Activé",
  relforcerowsecurity as "RLS Forcé"
FROM pg_class
WHERE relname = 'users_app';
```

**Si RLS est forcé** (relforcerowsecurity = true), désactivez-le :

```sql
ALTER TABLE users_app NO FORCE ROW LEVEL SECURITY;
```

### Vérifier les politiques RLS

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition USING"
FROM pg_policies
WHERE tablename = 'users_app'
ORDER BY cmd, policyname;
```

**Vous devriez voir au moins** :
- ✅ "Users can view own profile" (SELECT) avec `auth.uid() = id`
- ✅ "Admins can view all users" (SELECT)
- ✅ "Allow trigger to insert profiles" (INSERT)

## Pourquoi ce script fonctionne

Le script `FIX_ERREUR_500_FINAL.sql` :
1. **Crée le profil s'il n'existe pas** - résout le problème si le profil manque
2. **Désactive RLS forcé** - RLS forcé peut causer des erreurs 500
3. **Recrée les politiques dans le bon ordre** - évite les conflits
4. **Utilise une politique INSERT permissive** - garantit que le trigger fonctionne

## Différence avec les autres scripts

- **`FIX_PROFIL_COMPLET.sql`** : Ne crée pas le profil s'il n'existe pas
- **`FIX_ERREUR_500_FINAL.sql`** : Crée le profil automatiquement et désactive RLS forcé

## Support supplémentaire

Si le problème persiste :
1. Vérifiez les **logs Supabase** dans le dashboard
2. Consultez `DIAGNOSTIC_ERREUR_500.sql` pour plus de détails
3. Vérifiez que votre ID utilisateur est correct dans les scripts

