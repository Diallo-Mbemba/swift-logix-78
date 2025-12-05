# 🔧 Guide - Erreur "Invalid login credentials"

## ❌ Problème

Vous recevez l'erreur **"Invalid login credentials"** lors de la tentative de connexion.

## ✅ Solutions

### Solution 1 : Vérifier vos identifiants

1. **Vérifiez que vous utilisez le bon email** (attention aux fautes de frappe)
2. **Vérifiez que vous utilisez le bon mot de passe** (attention à la casse et aux caractères spéciaux)
3. **Essayez de réinitialiser votre mot de passe** si vous n'êtes pas sûr

### Solution 2 : Vérifier la confirmation d'email (CAUSE LA PLUS COURANTE)

Si vous venez de créer un compte, **vous devez confirmer votre email** avant de pouvoir vous connecter.

1. **Vérifiez votre boîte de réception** (et les spams/courriers indésirables)
2. **Cherchez un email de Supabase** avec le sujet "Confirm your signup"
3. **Cliquez sur le lien de confirmation** dans l'email

**Si vous n'avez pas reçu l'email :**
- Vérifiez les spams
- Attendez quelques minutes (l'email peut prendre du temps)
- Vérifiez que l'adresse email est correcte

### Solution 3 : Désactiver la confirmation d'email (Pour le développement)

Si vous êtes en développement et que vous voulez vous connecter immédiatement sans confirmation :

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Settings**
4. Décochez **"Enable email confirmations"**
5. Cliquez sur **Save**

**Maintenant, vous pouvez vous connecter immédiatement après inscription.**

### Solution 4 : Vérifier que l'utilisateur existe dans Supabase

1. Allez dans Supabase Dashboard > **Authentication** > **Users**
2. Cherchez votre email dans la liste
3. Si l'utilisateur n'existe pas, **créez un nouveau compte**

### Solution 5 : Réinitialiser le mot de passe

Si vous avez oublié votre mot de passe :

1. Cliquez sur **"Mot de passe oublié ?"** dans le formulaire de connexion
2. Entrez votre email
3. Vérifiez votre boîte de réception pour le lien de réinitialisation
4. Suivez les instructions pour créer un nouveau mot de passe

### Solution 6 : Vérifier la configuration Supabase

1. **Vérifiez que les clés Supabase sont correctes** dans le fichier `.env` :
   ```
   VITE_SUPABASE_URL=https://votre-projet.supabase.co
   VITE_SUPABASE_ANON_KEY=votre_cle_anon
   ```

2. **Redémarrez le serveur de développement** après modification du `.env`

## 🔍 Diagnostic

### Vérifier dans Supabase Dashboard

1. Allez dans **Authentication** > **Users**
2. Cherchez votre email
3. Vérifiez :
   - **Email confirmed** : Doit être `true` si la confirmation est activée
   - **Last sign in** : Date de dernière connexion
   - **Created at** : Date de création du compte

### Vérifier dans la console du navigateur

1. Ouvrez la console (F12)
2. Regardez les messages d'erreur détaillés
3. Cherchez :
   - `code: "invalid_credentials"`
   - `status: 400`
   - Messages contenant "Email not confirmed"

## 📝 Checklist

Avant de contacter le support, vérifiez :

- [ ] L'email est correct (pas de fautes de frappe)
- [ ] Le mot de passe est correct
- [ ] L'email a été confirmé (si la confirmation est activée)
- [ ] L'utilisateur existe dans Supabase Auth
- [ ] Les clés Supabase dans `.env` sont correctes
- [ ] Le serveur de développement a été redémarré après modification du `.env`

## 🆘 Si rien ne fonctionne

1. **Créez un nouveau compte** avec un autre email pour tester
2. **Vérifiez les logs Supabase** : Dashboard > Logs > Auth Logs
3. **Contactez le support** avec :
   - L'email utilisé
   - Le message d'erreur complet de la console
   - Une capture d'écran de l'erreur


