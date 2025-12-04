# 🔑 Configuration Stripe - Clés Intégrées

## ✅ Vos clés Stripe ont été intégrées !

Voici comment finaliser la configuration avec vos clés de test.

---

## 📝 ÉTAPE 1 : Créer le fichier .env du Frontend

À la **racine du projet**, créez un fichier `.env` avec ce contenu :

```env
# Stripe Configuration
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_51SYfQuDpUNYp5tGjSvwwM05wod5r3b2UTzpeEZ9iZhgfm5r0BzLw4PAp2WbimzSpYsY9ShBZeZKGH5KMED0J5UCq001fMTwNjB
VITE_STRIPE_SECRET_KEY=sk_test_51SYfQuDpUNYp5tGjepuKD4X8mCUym8aQ7oaODbdR2B1nrZvmNkmrntuZlmp74gyfMnoZxaBLRK1NHif5tDawtszk00SqMh3AXU
VITE_STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Application Configuration
VITE_APP_URL=http://localhost:5173
VITE_API_URL=http://localhost:3000/api

# Currency Configuration
VITE_DEFAULT_CURRENCY=XAF

# OpenAI Configuration (Optionnel)
VITE_OPENAI_API_KEY=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
```

**Fichier à créer :** `.env` (à la racine, au même niveau que `package.json`)

---

## 📝 ÉTAPE 2 : Créer le fichier .env du Backend

Dans le dossier `server/`, créez un fichier `.env` avec ce contenu :

```env
# Port du serveur
PORT=3000

# Stripe Secret Key (CÔTÉ SERVEUR UNIQUEMENT)
STRIPE_SECRET_KEY=sk_test_51SYfQuDpUNYp5tGjepuKD4X8mCUym8aQ7oaODbdR2B1nrZvmNkmrntuZlmp74gyfMnoZxaBLRK1NHif5tDawtszk00SqMh3AXU

# Webhook Secret (obtenu après configuration du webhook avec Stripe CLI)
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# URL de l'application frontend
FRONTEND_URL=http://localhost:5173

# Mode
NODE_ENV=development
```

**Fichier à créer :** `server/.env`

---

## 🚀 ÉTAPE 3 : Installer et démarrer le backend

```bash
# Aller dans le dossier server
cd server

# Installer les dépendances
npm install

# Démarrer le serveur (en mode développement)
npm run dev
```

Le serveur devrait démarrer sur `http://localhost:3000`

**Vérification :** Ouvrez `http://localhost:3000/health` dans votre navigateur. Vous devriez voir :
```json
{"status":"ok","message":"Server is running","timestamp":"..."}
```

---

## 🔔 ÉTAPE 4 : Configurer les webhooks Stripe (pour développement local)

### 4.1 Installer Stripe CLI

**Windows (PowerShell) :**
```powershell
# Option 1: Télécharger depuis
# https://github.com/stripe/stripe-cli/releases

# Option 2: Avec Scoop
scoop bucket add stripe https://github.com/stripe/scoop-stripe-cli.git
scoop install stripe
```

**macOS :**
```bash
brew install stripe/stripe-cli/stripe
```

**Linux :**
```bash
# Télécharger depuis https://github.com/stripe/stripe-cli/releases
```

### 4.2 Se connecter à Stripe

```bash
stripe login
```

Suivez les instructions pour vous connecter avec votre compte Stripe.

### 4.3 Tunneler les webhooks

Dans un **nouveau terminal** (gardez le serveur backend en cours d'exécution), lancez :

```bash
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

Vous verrez quelque chose comme :
```
> Ready! Your webhook signing secret is whsec_xxxxxxxxxxxxx (^C to quit)
```

### 4.4 Mettre à jour le fichier server/.env

Copiez le **webhook signing secret** (commence par `whsec_...`) et mettez-le dans `server/.env` :

```env
STRIPE_WEBHOOK_SECRET=whsec_VOTRE_SECRET_ICI
```

**Redémarrez le serveur backend** pour que la nouvelle variable soit prise en compte.

---

## ✅ ÉTAPE 5 : Démarrer le frontend

Dans un **nouveau terminal** (à la racine du projet) :

```bash
# S'assurer d'être à la racine du projet
cd ..

# Démarrer le serveur frontend
npm run dev
```

Le frontend devrait démarrer sur `http://localhost:5173`

---

## 🧪 ÉTAPE 6 : Tester un paiement

### 6.1 Assurez-vous que tout est démarré

Vous devriez avoir **3 terminaux** qui tournent :

1. **Terminal 1** : Backend serveur (`cd server && npm run dev`)
2. **Terminal 2** : Webhooks Stripe (`stripe listen --forward-to localhost:3000/api/webhooks/stripe`)
3. **Terminal 3** : Frontend (`npm run dev`)

### 6.2 Tester le paiement

1. Ouvrez votre navigateur : `http://localhost:5173`
2. Connectez-vous à votre compte
3. Allez sur la page des plans
4. Sélectionnez un plan (par exemple "Bronze" ou "Silver")
5. Cliquez sur "Acheter" ou "Payer"
6. Choisissez **"Stripe"** comme méthode de paiement
7. Utilisez une **carte de test Stripe** :
   - **Numéro de carte** : `4242 4242 4242 4242`
   - **Date d'expiration** : N'importe quelle date future (ex: `12/25`)
   - **CVC** : N'importe quel code à 3 chiffres (ex: `123`)
   - **Nom** : N'importe quel nom

### 6.3 Vérifier le résultat

✅ Le paiement devrait réussir  
✅ Une commande devrait être créée automatiquement  
✅ Les crédits devraient être ajoutés à votre compte  
✅ Vous verrez les événements dans le terminal des webhooks  

---

## 📋 Checklist de vérification

- [ ] Fichier `.env` créé à la racine avec la clé publique Stripe
- [ ] Fichier `server/.env` créé avec la clé secrète Stripe
- [ ] Dépendances du backend installées (`cd server && npm install`)
- [ ] Serveur backend démarré et accessible sur `http://localhost:3000`
- [ ] Stripe CLI installé et connecté
- [ ] Webhooks tunnelé (`stripe listen --forward-to localhost:3000/api/webhooks/stripe`)
- [ ] Webhook secret copié dans `server/.env`
- [ ] Serveur backend redémarré avec le nouveau secret
- [ ] Frontend démarré et accessible sur `http://localhost:5173`
- [ ] Paiement testé avec la carte `4242 4242 4242 4242`

---

## 🐛 Dépannage

### ❌ "Stripe non initialisé" dans le frontend
- **Solution** : Vérifiez que le fichier `.env` existe à la racine
- **Solution** : Redémarrez le serveur frontend après avoir créé/modifié `.env`

### ❌ "404" lors de la création du PaymentIntent
- **Solution** : Vérifiez que le backend est bien démarré sur le port 3000
- **Solution** : Vérifiez l'URL dans `.env` : `VITE_API_URL=http://localhost:3000/api`

### ❌ "Webhook signature verification failed"
- **Solution** : Vérifiez que `STRIPE_WEBHOOK_SECRET` dans `server/.env` correspond au secret du tunnel
- **Solution** : Redémarrez le serveur backend après avoir mis à jour le secret

### ❌ Le serveur backend ne démarre pas
- **Solution** : Vérifiez que toutes les dépendances sont installées : `cd server && npm install`
- **Solution** : Vérifiez que le port 3000 n'est pas déjà utilisé

---

## 🔒 Sécurité

⚠️ **IMPORTANT :**
- Les fichiers `.env` sont déjà dans `.gitignore` (ne seront pas commités)
- Ne partagez JAMAIS vos clés secrètes Stripe
- En production, utilisez les clés `live` (`pk_live_...` et `sk_live_...`)
- La clé secrète (`sk_test_...`) doit rester côté serveur uniquement

---

## 📚 Prochaines étapes

Une fois que tout fonctionne en local :

1. **Tester avec différentes cartes de test** :
   - Succès : `4242 4242 4242 4242`
   - Échec : `4000 0000 0000 0002`
   - 3D Secure : `4000 0025 0000 3155`

2. **Déployer en production** :
   - Utiliser les clés `live` de Stripe
   - Configurer le webhook dans le Dashboard Stripe
   - Déployer le backend sur un serveur (Vercel, Railway, Heroku, etc.)

3. **Voir la documentation complète** :
   - `GUIDE_INTEGRATION_STRIPE.md` pour tous les détails
   - `ETAPES_STRIPE_RESUME.md` pour un résumé rapide

---

## 🎉 C'est tout !

Vos clés Stripe sont maintenant configurées ! Suivez simplement ces étapes et vos paiements fonctionneront. 🚀

**Besoin d'aide ?** Vérifiez la section Dépannage ci-dessus ou consultez les guides complets.


