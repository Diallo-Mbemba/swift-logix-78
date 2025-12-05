# 🔧 Solution Immédiate - Réinitialiser le mot de passe

## ❌ Problème actuel

L'email est confirmé mais la connexion échoue toujours avec "Invalid login credentials".  
**Le problème est très probablement le mot de passe.**

## ✅ Solution IMMÉDIATE : Réinitialiser le mot de passe

### Méthode 1 : Via Supabase Dashboard (RECOMMANDÉ - 2 minutes)

1. **Allez sur** https://supabase.com/dashboard
2. **Sélectionnez votre projet** (`glptqzestfxdpxcwlzsz`)
3. **Allez dans** Authentication > Users
4. **Cherchez** `diallombemba7@gmail.com`
5. **Cliquez sur** "..." (trois points) à côté de l'utilisateur
6. **Sélectionnez** "Reset password"
7. **Un email sera envoyé** à `diallombemba7@gmail.com`
8. **L'utilisateur doit** :
   - Ouvrir l'email (vérifier aussi les spams)
   - Cliquer sur le lien "Reset password"
   - Créer un nouveau mot de passe (minimum 6 caractères)
9. **Essayez de vous connecter** avec le nouveau mot de passe

### Méthode 2 : Vérifier l'état de l'utilisateur

Exécutez cette requête dans **Supabase SQL Editor** pour vérifier l'état :

```sql
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  encrypted_password IS NOT NULL as has_password
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';
```

**Vérifiez que :**
- ✅ `email_confirmed_at` a une date (email confirmé)
- ✅ `confirmed_at` a une date (utilisateur confirmé)
- ✅ `has_password` est `true` (mot de passe existe)

## 🔍 Pourquoi le mot de passe ne fonctionne pas ?

Causes possibles :
1. **Mot de passe incorrect** - L'utilisateur a oublié ou saisi incorrectement
2. **Mot de passe corrompu** - Le hash du mot de passe dans la base est corrompu
3. **Problème de hashage** - Le mot de passe n'a pas été correctement hashé lors de l'inscription

## ✅ Solution définitive

**La seule solution fiable est de réinitialiser le mot de passe via Supabase Dashboard.**

Vous ne pouvez pas :
- ❌ Voir le mot de passe en clair (il est hashé)
- ❌ Modifier directement le hash en SQL (trop complexe et risqué)

Vous devez :
- ✅ Utiliser la fonction "Reset password" de Supabase
- ✅ Laisser l'utilisateur créer un nouveau mot de passe via l'email

## 📝 Après la réinitialisation

Une fois que l'utilisateur a créé un nouveau mot de passe :

1. **Essayez de vous connecter** avec le nouveau mot de passe
2. **Si ça fonctionne** → Le problème était le mot de passe
3. **Si ça ne fonctionne toujours pas** → Vérifiez :
   - Les clés Supabase dans `.env`
   - La configuration Supabase (Site URL, Redirect URLs)
   - Les logs Supabase (Dashboard > Logs > Auth Logs)

## 🆘 Si l'email de réinitialisation n'arrive pas

1. **Vérifiez les spams/courriers indésirables**
2. **Attendez quelques minutes** (l'email peut prendre du temps)
3. **Vérifiez l'adresse email** dans Supabase Dashboard
4. **Réessayez** "Reset password" depuis Supabase Dashboard

## 💡 Astuce

Pour éviter ce problème à l'avenir, ajoutez un lien **"Mot de passe oublié ?"** dans votre formulaire de connexion.

