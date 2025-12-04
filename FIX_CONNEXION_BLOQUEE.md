# 🔧 Solution - Connexion bloquée après saisie des identifiants

## ❌ Problème

Le système reste figé sur la page de connexion après avoir entré l'email et le mot de passe, alors que l'utilisateur existe dans `auth.users` et `users_app`.

## 🔍 Causes possibles

1. **RLS bloque la lecture du profil** : La politique RLS empêche la lecture de `users_app`
2. **Erreur silencieuse** : Une erreur n'est pas gérée correctement
3. **Boucle infinie** : Le loading reste à `true` indéfiniment
4. **Session non synchronisée** : La session Supabase n'est pas correctement chargée

## ✅ Solutions

### Solution 1 : Vérifier les politiques RLS (PRIORITÉ)

Le problème est probablement que RLS bloque la lecture du profil.

1. Allez sur https://supabase.com/dashboard
2. Ouvrez **SQL Editor**
3. Exécutez `FIX_RLS_BLOCKING.sql`
4. Vérifiez que la politique `"Users can view own profile"` existe

**Vérification manuelle** :
```sql
-- Vérifier que la politique existe
SELECT * FROM pg_policies 
WHERE tablename = 'users_app' 
AND policyname = 'Users can view own profile';

-- Vérifier que RLS est activé
SELECT relname, relrowsecurity 
FROM pg_class 
WHERE relname = 'users_app';
```

### Solution 2 : Vérifier les logs de la console

1. Ouvrez la console du navigateur (F12)
2. Essayez de vous connecter
3. Regardez les logs :
   - `🔐 Tentative de connexion pour: ...`
   - `✅ Connexion Supabase Auth réussie: ...`
   - `📥 Chargement du profil utilisateur...`
   - `❌ Erreur lors de la récupération du profil: ...`

**Si vous voyez une erreur RLS** :
- Code `42501` : Permission denied
- Message contenant "row-level security" : RLS bloque l'accès

### Solution 3 : Vérifier que l'utilisateur est bien authentifié

Dans la console, après la connexion, vérifiez :

```javascript
// Dans la console du navigateur
const { data: { user } } = await supabase.auth.getUser();
console.log('Utilisateur authentifié:', user);
```

Si `user` est `null`, la connexion Supabase Auth a échoué.

### Solution 4 : Tester la lecture du profil directement

Dans la console du navigateur, après connexion :

```javascript
// Tester la lecture du profil
const { data, error } = await supabase
  .from('users_app')
  .select('*')
  .eq('id', user.id)
  .single();

console.log('Profil:', data);
console.log('Erreur:', error);
```

**Si vous obtenez une erreur RLS** :
- Exécutez `FIX_RLS_BLOCKING.sql`
- Ou vérifiez manuellement les politiques dans Supabase

### Solution 5 : Désactiver temporairement RLS pour debug

⚠️ **ATTENTION** : Ne faites cela QUE pour le debug, puis réactivez RLS !

```sql
-- Désactiver RLS temporairement
ALTER TABLE users_app DISABLE ROW LEVEL SECURITY;

-- Tester la connexion

-- Puis réactiver RLS
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;

-- Et recréer la politique
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT USING (auth.uid() = id);
```

## 🔍 Diagnostic étape par étape

### Étape 1 : Vérifier la connexion Supabase Auth

Dans la console :
```javascript
// Vérifier la session
const { data: { session } } = await supabase.auth.getSession();
console.log('Session:', session);
```

### Étape 2 : Vérifier l'accès au profil

```javascript
// Vérifier l'ID utilisateur
const { data: { user } } = await supabase.auth.getUser();
console.log('User ID:', user?.id);

// Tester la lecture
const { data, error } = await supabase
  .from('users_app')
  .select('*')
  .eq('id', user?.id)
  .single();

console.log('Profil:', data);
console.log('Erreur:', error);
```

### Étape 3 : Vérifier les politiques RLS

Dans Supabase SQL Editor :
```sql
-- Voir toutes les politiques pour users_app
SELECT * FROM pg_policies WHERE tablename = 'users_app';

-- Vérifier que RLS est activé
SELECT relname, relrowsecurity FROM pg_class WHERE relname = 'users_app';
```

## 🚀 Solution rapide

1. **Exécutez `FIX_RLS_BLOCKING.sql`** dans Supabase SQL Editor
2. **Ouvrez la console du navigateur** (F12)
3. **Essayez de vous connecter**
4. **Regardez les logs** pour voir où ça bloque
5. **Si erreur RLS** : Vérifiez que la politique existe et est correcte

## 📝 Checklist

- [ ] L'utilisateur existe dans `auth.users`
- [ ] L'utilisateur existe dans `users_app`
- [ ] RLS est activé sur `users_app`
- [ ] La politique `"Users can view own profile"` existe
- [ ] La politique utilise `auth.uid() = id`
- [ ] La session Supabase est valide après connexion
- [ ] Les logs de la console montrent où ça bloque

## ⚠️ Erreurs courantes

### Erreur : "new row violates row-level security policy"
**Solution** : La politique RLS bloque l'accès. Vérifiez que la politique SELECT existe.

### Erreur : "permission denied for table users_app"
**Solution** : RLS est activé mais aucune politique ne permet l'accès. Créez la politique.

### Erreur : "relation does not exist"
**Solution** : La table `users_app` n'existe pas. Exécutez `SUPABASE_SCHEMA.sql`.

### Le loading reste indéfini
**Solution** : Vérifiez que `setLoading(false)` est appelé dans tous les cas (même en cas d'erreur).

## 🔗 Fichiers utiles

- `FIX_RLS_BLOCKING.sql` : Script pour corriger les politiques RLS
- `ACTIVER_RLS.sql` : Script complet pour activer RLS
- `VERIFIER_RLS.sql` : Script pour vérifier RLS





