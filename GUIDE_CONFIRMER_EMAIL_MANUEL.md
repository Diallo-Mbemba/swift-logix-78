# 🔧 Guide - Confirmer manuellement l'email d'un utilisateur

## ❌ Problème

L'utilisateur existe dans Supabase mais ne peut pas se connecter avec l'erreur "Invalid login credentials". Cela est souvent dû à un **email non confirmé**.

## ✅ Solution 1 : Via Supabase Dashboard (Recommandé)

### Méthode simple

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Allez dans **Authentication** > **Users**
4. Cherchez l'utilisateur par email
5. Cliquez sur l'utilisateur pour ouvrir les détails
6. Dans la section **Email Confirmed**, vous verrez :
   - Si l'email est confirmé : `email_confirmed_at` aura une date
   - Si l'email n'est pas confirmé : `email_confirmed_at` sera `null`
7. Si l'email n'est pas confirmé :
   - Cliquez sur **"..."** (menu) à côté de l'utilisateur
   - Sélectionnez **"Send confirmation email"** pour renvoyer l'email de confirmation
   - OU utilisez la Solution 2 ci-dessous pour confirmer manuellement

## ✅ Solution 2 : Via SQL Editor (Confirmation manuelle)

### Étape 1 : Vérifier l'état de l'utilisateur

1. Allez dans Supabase Dashboard > **SQL Editor**
2. Exécutez cette requête (remplacez `email@example.com` par l'email réel) :

```sql
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at,
  last_sign_in_at
FROM auth.users
WHERE email = 'email@example.com';
```

**Résultat attendu :**
- Si `email_confirmed_at` est `null` → L'email n'est pas confirmé (c'est le problème)
- Si `email_confirmed_at` a une date → L'email est confirmé (le problème est ailleurs)

### Étape 2 : Confirmer manuellement l'email

Si `email_confirmed_at` est `null`, exécutez cette requête :

```sql
UPDATE auth.users
SET 
  email_confirmed_at = NOW(),
  updated_at = NOW()
WHERE email = 'email@example.com';
```

**Remplacez `email@example.com` par l'email réel de l'utilisateur.**

**Note importante :** `confirmed_at` est une colonne générée automatiquement par Supabase et ne doit pas être mise à jour manuellement. Elle sera automatiquement mise à jour lorsque `email_confirmed_at` est défini.

### Étape 3 : Vérifier la confirmation

Exécutez à nouveau la requête de l'Étape 1 pour vérifier que `email_confirmed_at` a maintenant une date.

## ✅ Solution 3 : Désactiver la confirmation d'email (Pour tous les utilisateurs)

Si vous êtes en développement et que vous voulez que tous les utilisateurs puissent se connecter sans confirmation :

1. Allez dans **Authentication** > **Settings**
2. Décochez **"Enable email confirmations"**
3. Cliquez sur **Save**

**Maintenant, tous les utilisateurs peuvent se connecter sans confirmation d'email.**

## ✅ Solution 4 : Réinitialiser le mot de passe

Si l'email est confirmé mais que l'utilisateur ne peut toujours pas se connecter, le problème peut être le mot de passe :

1. Dans Supabase Dashboard > **Authentication** > **Users**
2. Trouvez l'utilisateur
3. Cliquez sur **"..."** (menu)
4. Sélectionnez **"Reset password"**
5. Un email de réinitialisation sera envoyé à l'utilisateur

## 🔍 Vérifier tous les utilisateurs non confirmés

Pour voir tous les utilisateurs dont l'email n'est pas confirmé :

```sql
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at
FROM auth.users
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;
```

## 📝 Checklist de diagnostic

Avant de confirmer manuellement, vérifiez :

- [ ] L'utilisateur existe bien dans Supabase Auth (Authentication > Users)
- [ ] L'email est correct (pas de fautes de frappe)
- [ ] `email_confirmed_at` est `null` (email non confirmé)
- [ ] Le mot de passe est correct (ou réinitialisé si nécessaire)

## ⚠️ Important

- **En production** : Il est recommandé de laisser la confirmation d'email activée pour la sécurité
- **En développement** : Vous pouvez désactiver la confirmation d'email pour faciliter les tests
- **Confirmation manuelle** : Utilisez-la uniquement si l'utilisateur ne peut pas recevoir l'email de confirmation

## 🆘 Si rien ne fonctionne

1. Vérifiez les logs Supabase : Dashboard > Logs > Auth Logs
2. Vérifiez que les clés Supabase dans `.env` sont correctes
3. Redémarrez le serveur de développement après modification du `.env`
4. Essayez de créer un nouveau compte pour tester


