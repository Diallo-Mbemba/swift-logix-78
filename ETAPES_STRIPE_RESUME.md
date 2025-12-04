# 🚀 Étapes Rapides - Intégration Stripe

## Résumé des étapes à suivre

### ✅ ÉTAPE 1 : Configuration Stripe (5 minutes)

1. **Créer un compte Stripe** : https://stripe.com
2. **Récupérer les clés** :
   - Dashboard → Developers → API keys
   - Copier la **Publishable key** (`pk_test_...`)
   - Copier la **Secret key** (`sk_test_...`)

### ✅ ÉTAPE 2 : Configuration Frontend (2 minutes)

1. Créer/mettre à jour `.env` à la racine du projet :
```env
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_VOTRE_CLE_ICI
VITE_APP_URL=http://localhost:5173
VITE_API_URL=http://localhost:3000/api
VITE_DEFAULT_CURRENCY=XAF
```

2. Redémarrer le serveur de développement :
```bash
npm run dev
```

### ✅ ÉTAPE 3 : Configuration Backend (10 minutes)

1. **Aller dans le dossier server** :
```bash
cd server
```

2. **Installer les dépendances** :
```bash
npm install
```

3. **Créer le fichier `.env`** dans le dossier `server/` :
```env
PORT=3000
STRIPE_SECRET_KEY=sk_test_VOTRE_CLE_SECRETE_ICI
STRIPE_WEBHOOK_SECRET=whsec_A_OBTENIR_APRES
FRONTEND_URL=http://localhost:5173
NODE_ENV=development
```

4. **Démarrer le serveur** :
```bash
npm run dev
```

Le serveur devrait démarrer sur `http://localhost:3000`

### ✅ ÉTAPE 4 : Configuration Webhooks (5 minutes)

1. **Installer Stripe CLI** :
   - Windows : https://github.com/stripe/stripe-cli/releases
   - macOS : `brew install stripe/stripe-cli/stripe`
   - Linux : https://github.com/stripe/stripe-cli/releases

2. **Se connecter** :
```bash
stripe login
```

3. **Tunneler les webhooks** (dans un nouveau terminal) :
```bash
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

4. **Copier le webhook secret** (commence par `whsec_...`) dans `server/.env` :
```env
STRIPE_WEBHOOK_SECRET=whsec_VOTRE_SECRET_ICI
```

5. **Redémarrer le serveur backend**

### ✅ ÉTAPE 5 : Test du paiement (2 minutes)

1. **Démarrer les 3 services** :
   - Terminal 1 : Frontend (`npm run dev`)
   - Terminal 2 : Backend (`cd server && npm run dev`)
   - Terminal 3 : Webhooks (`stripe listen --forward-to localhost:3000/api/webhooks/stripe`)

2. **Tester un paiement** :
   - Ouvrir http://localhost:5173
   - Se connecter
   - Choisir un plan
   - Sélectionner "Stripe"
   - Utiliser la carte de test : `4242 4242 4242 4242`
   - Date : n'importe quelle date future (ex: 12/25)
   - CVC : 123

3. **Vérifier** :
   - ✅ Paiement réussi
   - ✅ Commande créée
   - ✅ Crédits ajoutés

---

## 📁 Fichiers créés

- ✅ `GUIDE_INTEGRATION_STRIPE.md` - Guide complet détaillé
- ✅ `server/` - Backend serveur complet
- ✅ `server/src/index.ts` - Point d'entrée du serveur
- ✅ `server/src/routes/payment.ts` - Routes de paiement
- ✅ `server/src/routes/webhooks.ts` - Routes de webhooks
- ✅ `server/src/controllers/paymentController.ts` - Contrôleur de paiement

---

## ⚠️ Notes importantes

1. **Sécurité** :
   - ❌ Ne JAMAIS exposer la clé secrète Stripe côté client
   - ✅ Toujours valider les webhooks avec la signature
   - ✅ Utiliser HTTPS en production

2. **Développement** :
   - Utiliser les clés `test` (`pk_test_...`, `sk_test_...`)
   - Les cartes de test sont disponibles dans la documentation Stripe

3. **Production** :
   - Utiliser les clés `live` (`pk_live_...`, `sk_live_...`)
   - Configurer le webhook dans le Dashboard Stripe
   - Déployer le backend sur un serveur (Vercel, Railway, Heroku, etc.)

---

## 🐛 Problèmes courants

| Problème | Solution |
|----------|----------|
| "Stripe non initialisé" | Vérifier que `VITE_STRIPE_PUBLISHABLE_KEY` est dans `.env` |
| "404 sur create-payment-intent" | Vérifier que le backend est démarré sur le port 3000 |
| "Webhook signature failed" | Vérifier que `STRIPE_WEBHOOK_SECRET` correspond au secret du tunnel |
| "Currency not supported" | Vérifier que XAF est supporté ou utiliser XOF |

---

## 📚 Documentation complète

Voir `GUIDE_INTEGRATION_STRIPE.md` pour le guide complet avec toutes les explications détaillées.

---

## 🎉 C'est parti !

Suivez ces étapes dans l'ordre et vos paiements Stripe seront fonctionnels en moins de 30 minutes ! 🚀

