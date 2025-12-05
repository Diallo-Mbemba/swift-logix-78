# 🔧 Guide - Réinitialiser le mot de passe d'un utilisateur

## ❌ Problème

L'utilisateur existe et l'email est confirmé, mais il ne peut toujours pas se connecter avec l'erreur "Invalid login credentials". Le problème est probablement le **mot de passe**.

## ✅ Solution 1 : Via Supabase Dashboard (RECOMMANDÉ)

### Méthode simple et sécurisée

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Users**
4. Cherchez l'utilisateur par email (`diallombemba7@gmail.com`)
5. Cliquez sur l'utilisateur pour ouvrir les détails
6. Cliquez sur **"..."** (menu) à côté de l'utilisateur
7. Sélectionnez **"Reset password"**
8. Un email de réinitialisation sera envoyé à l'utilisateur
9. L'utilisateur doit :
   - Ouvrir l'email
   - Cliquer sur le lien de réinitialisation
   - Entrer un nouveau mot de passe

## ✅ Solution 2 : Via l'application (Fonction "Mot de passe oublié ?")

Si votre application a une fonctionnalité de réinitialisation de mot de passe :

1. Sur la page de connexion, cliquez sur **"Mot de passe oublié ?"** ou **"Forgot password?"**
2. Entrez l'email : `diallombemba7@gmail.com`
3. Cliquez sur **"Envoyer"** ou **"Send"**
4. Vérifiez la boîte de réception (et les spams)
5. Cliquez sur le lien de réinitialisation dans l'email
6. Entrez un nouveau mot de passe

## ✅ Solution 3 : Vérifier l'état de l'utilisateur

Avant de réinitialiser, vérifiez l'état de l'utilisateur dans Supabase SQL Editor :

```sql
-- Vérifier l'état complet de l'utilisateur
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at,
  last_sign_in_at,
  encrypted_password IS NOT NULL as has_password
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';
```

**Vérifications importantes :**
- ✅ `email_confirmed_at` doit avoir une date (email confirmé)
- ✅ `confirmed_at` doit avoir une date (utilisateur confirmé)
- ✅ `has_password` doit être `true` (mot de passe existe)

## ✅ Solution 4 : Créer un nouveau compte de test

Si la réinitialisation ne fonctionne pas, créez un nouveau compte de test pour vérifier que l'authentification fonctionne :

1. Allez sur la page d'inscription
2. Créez un nouveau compte avec un autre email
3. Essayez de vous connecter avec ce nouveau compte

Si le nouveau compte fonctionne, le problème est spécifique à l'utilisateur `diallombemba7@gmail.com`.

## 🔍 Diagnostic approfondi

### Vérifier les logs Supabase

1. Allez dans Supabase Dashboard > **Logs** > **Auth Logs**
2. Cherchez les tentatives de connexion pour `diallombemba7@gmail.com`
3. Regardez les erreurs détaillées

### Vérifier la configuration Supabase

1. Allez dans **Authentication** > **Settings**
2. Vérifiez que :
   - **Enable email confirmations** est configuré selon vos besoins
   - **Site URL** est correct (`http://localhost:5173` pour le développement)
   - **Redirect URLs** inclut votre URL de réinitialisation

## 📝 Checklist de diagnostic

Avant de réinitialiser le mot de passe, vérifiez :

- [ ] L'utilisateur existe dans Supabase Auth
- [ ] L'email est confirmé (`email_confirmed_at` a une date)
- [ ] L'utilisateur a un mot de passe (`encrypted_password` existe)
- [ ] L'email utilisé pour la connexion est exactement le même que dans Supabase (pas de fautes de frappe)
- [ ] Le mot de passe saisi est correct (attention à la casse, espaces, caractères spéciaux)

## ⚠️ Important

- **Ne modifiez jamais directement le mot de passe dans la base de données** - utilisez toujours la fonction de réinitialisation
- **Les mots de passe sont hashés** - vous ne pouvez pas voir le mot de passe en clair
- **La réinitialisation via email est la méthode la plus sécurisée**

## 🆘 Si rien ne fonctionne

1. **Vérifiez les logs Supabase** : Dashboard > Logs > Auth Logs
2. **Vérifiez que les clés Supabase dans `.env` sont correctes**
3. **Redémarrez le serveur de développement** après modification du `.env`
4. **Créez un nouveau compte de test** pour vérifier que l'authentification fonctionne globalement
5. **Contactez le support** avec :
   - L'email de l'utilisateur
   - Les logs Supabase
   - Une capture d'écran de l'erreur

