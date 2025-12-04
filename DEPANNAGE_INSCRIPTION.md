# 🔧 Dépannage - Impossible de créer un compte utilisateur

## ✅ VÉRIFICATIONS À FAIRE

### 1. Vérifier que le schéma SQL a été exécuté

**IMPORTANT** : Le schéma SQL doit être exécuté dans Supabase avant de pouvoir créer des comptes.

1. Allez sur votre projet Supabase : https://supabase.com/dashboard
2. Ouvrez **SQL Editor**
3. Vérifiez que les tables suivantes existent :
   - `users_app`
   - `simulations`
   - `orders`
   - `credit_pools`
   - etc.

**Si les tables n'existent pas** :
- Copiez le contenu de `SUPABASE_SCHEMA.sql`
- Collez-le dans SQL Editor
- Cliquez sur **Run** ou **Execute**

### 2. Vérifier la configuration d'authentification Supabase

1. Allez dans **Authentication** > **Settings**
2. Vérifiez que **Enable email confirmations** est configuré selon vos besoins :
   - **Activé** : L'utilisateur doit confirmer son email avant de se connecter
   - **Désactivé** : L'utilisateur peut se connecter immédiatement après inscription

**Pour désactiver la confirmation d'email** (recommandé en développement) :
1. **Authentication** > **Settings**
2. Décochez **Enable email confirmations**
3. Cliquez sur **Save**

### 3. Vérifier les politiques RLS (Row Level Security)

1. Allez dans **Table Editor** > `users_app`
2. Vérifiez que **RLS** est activé
3. Vérifiez que les politiques suivantes existent :
   - "Users can view own profile"
   - "Users can update own profile"

### 4. Vérifier le trigger de création automatique

1. Allez dans **Database** > **Functions**
2. Vérifiez que la fonction `create_user_profile()` existe
3. Allez dans **Database** > **Triggers**
4. Vérifiez que le trigger `on_auth_user_created` existe et est actif

### 5. Vérifier les erreurs dans la console du navigateur

Ouvrez la console du navigateur (F12) et regardez les erreurs :
- Erreurs Supabase (code d'erreur, message)
- Erreurs de réseau
- Erreurs de permissions

## 🔍 ERREURS COURANTES

### Erreur : "relation 'users_app' does not exist"
**Solution** : Le schéma SQL n'a pas été exécuté. Exécutez `SUPABASE_SCHEMA.sql` dans SQL Editor.

### Erreur : "new row violates row-level security policy"
**Solution** : Les politiques RLS ne sont pas correctement configurées. Vérifiez les politiques dans Supabase.

### Erreur : "duplicate key value violates unique constraint"
**Solution** : L'utilisateur existe déjà. Essayez avec un autre email.

### Erreur : "email address not authorized"
**Solution** : Vérifiez les paramètres d'authentification dans Supabase. Désactivez les restrictions d'email si nécessaire.

## 🚀 SOLUTION RAPIDE

Si vous venez de créer votre projet Supabase :

1. **Exécutez le schéma SQL** :
   - Ouvrez Supabase SQL Editor
   - Copiez-collez `SUPABASE_SCHEMA.sql`
   - Exécutez le script

2. **Désactivez la confirmation d'email** (pour le développement) :
   - Authentication > Settings
   - Décochez "Enable email confirmations"
   - Save

3. **Redémarrez l'application** :
   ```bash
   npm run dev
   ```

4. **Essayez de créer un compte** avec un email valide

## 📝 VÉRIFICATION MANUELLE DU PROFIL

Si l'inscription semble réussir mais que vous ne pouvez pas vous connecter :

1. Allez dans Supabase **Table Editor** > `users_app`
2. Vérifiez si un profil a été créé pour votre utilisateur
3. Si non, créez-le manuellement :
   ```sql
   INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
   VALUES (
     'user_id_from_auth_users',
     'votre@email.com',
     'Votre Nom',
     'free',
     3,
     3
   );
   ```

## 🔗 LIENS UTILES

- [Documentation Supabase Auth](https://supabase.com/docs/guides/auth)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Database Triggers](https://supabase.com/docs/guides/database/triggers)

