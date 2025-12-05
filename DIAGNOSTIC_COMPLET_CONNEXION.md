# 🔍 Diagnostic Complet - Erreur "Invalid login credentials"

## ❌ Problème actuel

L'utilisateur `diallombemba7@gmail.com` ne peut pas se connecter malgré :
- ✅ L'utilisateur existe dans Supabase
- ✅ L'email est confirmé (`email_confirmed_at` a une date)

## 🔍 Étapes de diagnostic

### ÉTAPE 1 : Vérifier l'état complet de l'utilisateur dans Supabase

Exécutez cette requête dans **Supabase SQL Editor** :

```sql
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at,
  last_sign_in_at,
  encrypted_password IS NOT NULL as has_password,
  LENGTH(encrypted_password::text) as password_length,
  updated_at
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';
```

**Vérifications :**
- ✅ `email_confirmed_at` doit avoir une date
- ✅ `confirmed_at` doit avoir une date
- ✅ `has_password` doit être `true`
- ✅ `password_length` doit être > 0

### ÉTAPE 2 : Vérifier les clés Supabase dans `.env`

Vérifiez que le fichier `.env` à la racine du projet contient :

```env
VITE_SUPABASE_URL=https://glptqzestfxdpxcwlzsz.supabase.co
VITE_SUPABASE_ANON_KEY=votre_cle_anon_ici
```

**Important :**
- Les clés doivent correspondre au projet Supabase où se trouve l'utilisateur
- Redémarrez le serveur de développement après modification du `.env`

### ÉTAPE 3 : Vérifier la configuration Supabase

1. Allez dans **Supabase Dashboard** > **Authentication** > **Settings**
2. Vérifiez :
   - **Site URL** : `http://localhost:5173` (pour le développement)
   - **Redirect URLs** : Doit inclure `http://localhost:5173/**`
   - **Enable email confirmations** : Peut être activé ou désactivé selon vos besoins

### ÉTAPE 4 : Réinitialiser le mot de passe

**Méthode 1 : Via Supabase Dashboard (RECOMMANDÉ)**

1. Allez dans **Authentication** > **Users**
2. Trouvez `diallombemba7@gmail.com`
3. Cliquez sur **"..."** > **"Reset password"**
4. Un email sera envoyé à l'utilisateur
5. L'utilisateur doit cliquer sur le lien et créer un nouveau mot de passe

**Méthode 2 : Créer un nouveau mot de passe directement (ADMIN)**

Si vous avez accès à l'API Admin Supabase, vous pouvez créer un nouveau mot de passe directement.

### ÉTAPE 5 : Tester avec un nouveau compte

Pour vérifier que l'authentification fonctionne globalement :

1. Créez un nouveau compte avec un autre email
2. Essayez de vous connecter avec ce nouveau compte
3. Si ça fonctionne → Le problème est spécifique à `diallombemba7@gmail.com`
4. Si ça ne fonctionne pas → Problème de configuration générale

### ÉTAPE 6 : Vérifier les logs Supabase

1. Allez dans **Supabase Dashboard** > **Logs** > **Auth Logs**
2. Cherchez les tentatives de connexion pour `diallombemba7@gmail.com`
3. Regardez les erreurs détaillées

## ✅ Solutions par ordre de priorité

### Solution 1 : Réinitialiser le mot de passe (90% des cas)

Le problème est très probablement le mot de passe incorrect ou corrompu.

**Action :**
1. Via Supabase Dashboard > Authentication > Users
2. Cliquez sur "Reset password" pour `diallombemba7@gmail.com`
3. L'utilisateur recevra un email de réinitialisation
4. L'utilisateur crée un nouveau mot de passe
5. Essayez de vous connecter avec le nouveau mot de passe

### Solution 2 : Vérifier les clés Supabase

Si les clés Supabase dans `.env` ne correspondent pas au bon projet :

1. Vérifiez que `VITE_SUPABASE_URL` correspond au projet où se trouve l'utilisateur
2. Vérifiez que `VITE_SUPABASE_ANON_KEY` est la bonne clé
3. Redémarrez le serveur de développement

### Solution 3 : Désactiver temporairement la confirmation d'email

Pour tester si le problème vient de la confirmation :

1. Allez dans **Authentication** > **Settings**
2. Décochez **"Enable email confirmations"**
3. Essayez de vous connecter
4. Si ça fonctionne, le problème était la confirmation
5. Réactivez la confirmation après les tests

### Solution 4 : Vérifier le format de l'email

Assurez-vous qu'il n'y a pas d'espaces ou de caractères invisibles :

- Email correct : `diallombemba7@gmail.com`
- Vérifiez qu'il n'y a pas d'espaces avant/après
- Vérifiez la casse (normalement insensible à la casse, mais vérifiez quand même)

### Solution 5 : Vérifier le mot de passe

- Le mot de passe doit contenir au moins 6 caractères
- Vérifiez qu'il n'y a pas d'espaces au début ou à la fin
- Vérifiez la casse (majuscules/minuscules)
- Vérifiez les caractères spéciaux

## 🆘 Si rien ne fonctionne

### Option 1 : Supprimer et recréer l'utilisateur

1. Dans Supabase Dashboard > Authentication > Users
2. Supprimez l'utilisateur `diallombemba7@gmail.com`
3. Créez un nouveau compte avec le même email
4. Confirmez l'email si nécessaire
5. Essayez de vous connecter

### Option 2 : Contacter le support Supabase

Si le problème persiste après toutes ces vérifications :

1. Allez dans Supabase Dashboard > Support
2. Fournissez :
   - L'email de l'utilisateur
   - Les logs d'authentification
   - Une description du problème

## 📝 Checklist finale

Avant de contacter le support, vérifiez :

- [ ] L'utilisateur existe dans Supabase Auth
- [ ] L'email est confirmé (`email_confirmed_at` a une date)
- [ ] L'utilisateur a un mot de passe (`encrypted_password` existe)
- [ ] Les clés Supabase dans `.env` sont correctes
- [ ] Le serveur de développement a été redémarré
- [ ] Le mot de passe a été réinitialisé via Supabase Dashboard
- [ ] Un nouveau compte de test fonctionne
- [ ] Les logs Supabase ont été vérifiés

## 💡 Astuce

Pour éviter ce problème à l'avenir, ajoutez un lien "Mot de passe oublié ?" dans le formulaire de connexion de votre application.

