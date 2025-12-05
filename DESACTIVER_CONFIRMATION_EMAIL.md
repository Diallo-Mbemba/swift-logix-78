# 🔧 Désactiver la confirmation d'email dans Supabase

## 📸 Configuration actuelle

D'après votre capture d'écran, **"Enable email confirmations"** est actuellement **coché (activé)**.

## ✅ Solution : Désactiver la confirmation d'email

### Étapes à suivre :

1. **Décochez la case "Enable email confirmations"**
   - Cliquez sur la case à cocher pour la décocher
   - Elle ne doit plus être cochée (comme dans l'image ci-dessous)

2. **Cliquez sur "Save"** en bas de la page
   - Attendez la confirmation que les paramètres ont été sauvegardés

3. **Redémarrez votre serveur de développement** (si nécessaire)
   - Arrêtez le serveur (Ctrl+C)
   - Redémarrez avec `npm run dev`

## ✅ Résultat attendu

Après avoir désactivé la confirmation d'email :

- ✅ Les nouveaux utilisateurs peuvent se connecter **immédiatement** après inscription
- ✅ Les utilisateurs existants peuvent se connecter **sans avoir confirmé leur email**
- ✅ Plus besoin de cliquer sur un lien de confirmation dans l'email

## ⚠️ Important

- **En développement** : Désactiver la confirmation est recommandé pour faciliter les tests
- **En production** : Il est recommandé d'activer la confirmation d'email pour la sécurité

## 🔄 Pour réactiver plus tard

Si vous voulez réactiver la confirmation d'email plus tard :

1. Retournez dans **Authentication** > **Settings**
2. **Cochez** "Enable email confirmations"
3. Cliquez sur **"Save"**

## 📝 Note

Même après avoir désactivé la confirmation, les utilisateurs qui ont déjà confirmé leur email restent confirmés. Les nouveaux utilisateurs n'auront plus besoin de confirmer leur email.

