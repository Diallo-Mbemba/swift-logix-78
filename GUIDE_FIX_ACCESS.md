# 🔧 Guide - Corriger "Vous n'avez pas access" après inscription

## 🔍 Problème

Après l'inscription, vous voyez le message **"vous n'avez pas access"** ou vous ne pouvez pas accéder à votre profil.

## ✅ Solution Rapide

### Étape 1 : Exécuter le Script SQL

1. Allez sur votre projet Supabase : https://supabase.com/dashboard
2. Ouvrez le **SQL Editor**
3. Copiez-collez le contenu de `FIX_ACCESS_APRES_INSCRIPTION.sql`
4. Cliquez sur **Run** (ou appuyez sur F5)

### Étape 2 : Vérifier que ça fonctionne

1. Déconnectez-vous de l'application
2. Réessayez de vous inscrire
3. Vous devriez maintenant pouvoir accéder à votre profil

## 🔍 Diagnostic

### Vérifier les Politiques RLS

Exécutez cette requête dans SQL Editor :

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app';
```

Vous devriez voir :
- ✅ "Users can view own profile" (SELECT)
- ✅ "Users can update own profile" (UPDATE)
- ✅ "Allow service role to insert profiles" (INSERT)

### Vérifier que RLS est Activé

```sql
SELECT 
  relname as "Table",
  relrowsecurity as "RLS Activé"
FROM pg_class
WHERE relname = 'users_app';
```

Le résultat doit être `true` pour `RLS Activé`.

### Vérifier que le Profil Existe

```sql
-- Remplacez par l'email de l'utilisateur
SELECT * FROM users_app WHERE email = 'votre@email.com';
```

Si aucun résultat, le profil n'a pas été créé. Voir la section "Créer le Profil Manuellement" ci-dessous.

## 🛠️ Solutions Détaillées

### Solution 1 : Politiques RLS Manquantes

**Symptôme** : Aucune politique n'existe pour `users_app`

**Solution** : Exécutez `FIX_ACCESS_APRES_INSCRIPTION.sql`

### Solution 2 : Profil Non Créé

**Symptôme** : L'utilisateur existe dans `auth.users` mais pas dans `users_app`

**Solution** : Créez le profil manuellement :

```sql
-- 1. Trouver l'ID de l'utilisateur dans auth.users
SELECT id, email FROM auth.users WHERE email = 'votre@email.com';

-- 2. Créer le profil dans users_app (remplacez l'ID)
INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
VALUES (
  'ID_DE_L_UTILISATEUR',
  'votre@email.com',
  'Nom Utilisateur',
  'free',
  3,
  3
);
```

### Solution 3 : Trigger Non Fonctionnel

**Symptôme** : Le trigger `on_auth_user_created` n'existe pas ou ne fonctionne pas

**Solution** : Réexécutez `FIX_TRIGGER.sql` ou `SUPABASE_SCHEMA.sql`

### Solution 4 : RLS Désactivé

**Symptôme** : RLS n'est pas activé sur `users_app`

**Solution** :
```sql
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;
```

## 📋 Checklist de Vérification

Après avoir exécuté le script, vérifiez :

- [ ] RLS est activé sur `users_app`
- [ ] La politique "Users can view own profile" existe
- [ ] La politique "Users can update own profile" existe
- [ ] La politique "Allow service role to insert profiles" existe
- [ ] Le trigger `on_auth_user_created` existe et est actif
- [ ] La fonction `create_user_profile()` existe
- [ ] Le profil utilisateur existe dans `users_app`

## 🚨 Si Rien Ne Fonctionne

### Option 1 : Désactiver Temporairement RLS (DEBUG UNIQUEMENT)

⚠️ **ATTENTION** : Ne faites cela QUE pour le debug, puis réactivez RLS !

```sql
-- Désactiver RLS temporairement
ALTER TABLE users_app DISABLE ROW LEVEL SECURITY;

-- Tester l'accès
-- ...

-- RÉACTIVER RLS après le test
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;
```

### Option 2 : Créer une Politique Temporaire Plus Permissive

```sql
-- Créer une politique temporaire (à supprimer après)
CREATE POLICY "Temporary: Allow authenticated users" ON users_app
  FOR ALL
  USING (auth.uid() IS NOT NULL);

-- Après avoir résolu le problème, supprimez cette politique :
-- DROP POLICY "Temporary: Allow authenticated users" ON users_app;
```

## 📞 Support

Si le problème persiste après avoir suivi toutes ces étapes :

1. Copiez les résultats des requêtes de vérification
2. Copiez les erreurs de la console du navigateur (F12)
3. Vérifiez les logs Supabase (Dashboard > Logs)

## ✅ Résultat Attendu

Après avoir exécuté `FIX_ACCESS_APRES_INSCRIPTION.sql` :

- ✅ L'utilisateur peut s'inscrire
- ✅ Le profil est créé automatiquement
- ✅ L'utilisateur peut accéder à son profil
- ✅ L'utilisateur peut voir le dashboard
- ✅ Aucun message "vous n'avez pas access"

