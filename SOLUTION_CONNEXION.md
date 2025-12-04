# 🔧 Solution - Utilisateur inscrit mais ne peut pas se connecter

## ❌ Problème

L'utilisateur est bien inscrit dans Supabase Auth, mais ne peut pas se connecter. Cela peut être dû à plusieurs raisons :

1. **Confirmation d'email requise** : Supabase nécessite une confirmation d'email
2. **Profil utilisateur manquant** : Le profil dans `users_app` n'a pas été créé
3. **Erreur lors du chargement du profil** : Le profil existe mais ne peut pas être chargé

## ✅ Solutions

### Solution 1 : Désactiver la confirmation d'email (Recommandé pour le développement)

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Settings**
4. Décochez **"Enable email confirmations"**
5. Cliquez sur **Save**

**Maintenant, les utilisateurs peuvent se connecter immédiatement après inscription.**

### Solution 2 : Vérifier et créer le profil manuellement

Si l'utilisateur est inscrit mais le profil n'existe pas dans `users_app` :

1. Allez dans Supabase **Table Editor** > `users_app`
2. Vérifiez si un profil existe pour cet utilisateur
3. Si non, récupérez l'ID de l'utilisateur depuis **Authentication** > **Users**
4. Créez le profil manuellement dans SQL Editor :

```sql
-- Remplacer 'USER_ID' par l'ID de l'utilisateur depuis auth.users
-- Remplacer 'email@example.com' et 'Nom Utilisateur' par les vraies valeurs

INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
VALUES (
  'USER_ID',
  'email@example.com',
  'Nom Utilisateur',
  'free',
  3,
  3
);
```

### Solution 3 : Vérifier que le trigger fonctionne

1. Allez dans Supabase **Database** > **Functions**
2. Vérifiez que `create_user_profile()` existe
3. Allez dans **Database** > **Triggers**
4. Vérifiez que `on_auth_user_created` existe et est actif

**Si le trigger n'existe pas**, exécutez `FIX_TRIGGER.sql` dans SQL Editor.

### Solution 4 : Créer le profil automatiquement lors de la connexion

Le code a été amélioré pour créer automatiquement le profil si il n'existe pas lors de la connexion. 

**Si vous avez déjà un utilisateur inscrit sans profil** :
1. Essayez de vous connecter avec cet utilisateur
2. Le système créera automatiquement le profil manquant
3. Si cela ne fonctionne pas, utilisez la Solution 2

## 🔍 Vérifications

### Vérifier que l'utilisateur existe dans auth.users

1. Allez dans Supabase **Authentication** > **Users**
2. Vérifiez que l'utilisateur est listé
3. Vérifiez le statut :
   - **Confirmed** : L'email est confirmé, peut se connecter
   - **Unconfirmed** : Doit confirmer l'email ou désactiver la confirmation

### Vérifier que le profil existe dans users_app

1. Allez dans Supabase **Table Editor** > `users_app`
2. Cherchez l'utilisateur par email
3. Si absent, créez-le manuellement (Solution 2)

### Vérifier les erreurs dans la console

Ouvrez la console du navigateur (F12) et regardez :
- Les erreurs Supabase
- Les messages de succès/échec
- Les logs de création de profil

## 🚀 Solution rapide (tout en un)

1. **Désactivez la confirmation d'email** (Solution 1)
2. **Exécutez FIX_TRIGGER.sql** dans SQL Editor (pour les futurs utilisateurs)
3. **Créez le profil manuellement** pour l'utilisateur existant (Solution 2)
4. **Redémarrez l'application** et testez la connexion

## 📝 Script SQL pour créer tous les profils manquants

Si vous avez plusieurs utilisateurs sans profil, exécutez ce script :

```sql
-- Créer les profils manquants pour tous les utilisateurs auth existants
INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'name', split_part(u.email, '@', 1)) as name,
  'free' as plan,
  3 as remaining_credits,
  3 as total_credits
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM users_app ua WHERE ua.id = u.id
)
ON CONFLICT (id) DO NOTHING;
```

## ⚠️ Important

- Après avoir créé le profil manuellement, l'utilisateur doit **se déconnecter et se reconnecter** pour que le profil soit chargé
- Si la confirmation d'email est activée, l'utilisateur doit cliquer sur le lien dans l'email avant de pouvoir se connecter
- Le code a été amélioré pour créer automatiquement le profil lors de la connexion si il manque





