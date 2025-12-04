# 🚀 Démarrer les Services - Guide Étape par Étape

## ✅ Étape 1 : Installer les dépendances du backend

Ouvrez un terminal PowerShell et exécutez :

```powershell
cd server
npm install
```

Cela peut prendre 1-2 minutes. Attendez que toutes les dépendances soient installées.

**✅ Vérification :** Vous devriez voir "added X packages" à la fin.

---

## ✅ Étape 2 : Démarrer le serveur backend

Toujours dans le dossier `server`, démarrez le serveur :

```powershell
npm run dev
```

**✅ Vous devriez voir :**
```
🚀 Server running on http://localhost:3000
📡 API available at http://localhost:3000/api
🌐 Frontend URL: http://localhost:5173
🔧 Environment: development
```

**✅ Testez que ça marche :**
Ouvrez votre navigateur et allez sur : `http://localhost:3000/health`

Vous devriez voir :
```json
{"status":"ok","message":"Server is running","timestamp":"..."}
```

**⚠️ IMPORTANT :** Gardez ce terminal ouvert ! Le serveur doit continuer à tourner.

---

## ✅ Étape 3 : Installer et configurer Stripe CLI (pour les webhooks)

### 3.1 Installer Stripe CLI

**Option A - Avec Scoop (Recommandé sur Windows) :**
```powershell
scoop bucket add stripe https://github.com/stripe/scoop-stripe-cli.git
scoop install stripe
```

**Option B - Téléchargement manuel :**
Téléchargez depuis : https://github.com/stripe/stripe-cli/releases
Extrayez et ajoutez au PATH.

### 3.2 Se connecter à Stripe

Ouvrez un **NOUVEAU terminal** et exécutez :

```powershell
stripe login
```

Suivez les instructions pour vous connecter avec votre compte Stripe.

### 3.3 Tunneler les webhooks

Dans le même terminal (ou un nouveau), exécutez :

```powershell
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

**✅ Vous devriez voir :**
```
> Ready! Your webhook signing secret is whsec_xxxxxxxxxxxxx (^C to quit)
```

**⚠️ IMPORTANT :** 
1. Copiez le secret `whsec_...` qui s'affiche
2. Ajoutez-le dans `server/.env` :
   ```
   STRIPE_WEBHOOK_SECRET=whsec_VOTRE_SECRET_ICI
   ```
3. Redémarrez le serveur backend (Ctrl+C puis `npm run dev`)

**⚠️ GARDEZ CE TERMINAL OUVERT !** Le tunnel doit rester actif.

---

## ✅ Étape 4 : Démarrer le frontend

Ouvrez un **NOUVEAU terminal** (à la racine du projet) et exécutez :

```powershell
cd ..
npm run dev
```

**✅ Vous devriez voir :**
```
  VITE v5.x.x  ready in xxx ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
```

**✅ Testez :** Ouvrez `http://localhost:5173` dans votre navigateur.

**⚠️ GARDEZ CE TERMINAL OUVERT !**

---

## ✅ Étape 5 : Tester un paiement Stripe

### 5.1 Vérifier que tout est démarré

Vous devriez avoir **3 terminaux** ouverts :

1. ✅ **Terminal 1** : Backend serveur (`cd server && npm run dev`)
2. ✅ **Terminal 2** : Webhooks Stripe (`stripe listen --forward-to...`)
3. ✅ **Terminal 3** : Frontend (`npm run dev`)

### 5.2 Effectuer un test de paiement

1. **Ouvrez votre navigateur** : `http://localhost:5173`
2. **Connectez-vous** à votre compte (ou créez-en un)
3. **Allez sur la page des plans** (généralement `/plans`)
4. **Sélectionnez un plan** (par exemple "Bronze" ou "Silver")
5. **Cliquez sur "Acheter"** ou "Payer"
6. **Choisissez "Stripe"** comme méthode de paiement
7. **Utilisez une carte de test** :
   - **Numéro** : `4242 4242 4242 4242`
   - **Date d'expiration** : `12/25` (ou n'importe quelle date future)
   - **CVC** : `123` (ou n'importe quel code à 3 chiffres)
   - **Nom** : N'importe quel nom

### 5.3 Vérifier le résultat

**✅ Succès si :**
- Le paiement est confirmé
- Une commande est créée
- Les crédits sont ajoutés à votre compte
- Vous voyez des événements dans le terminal des webhooks

**❌ Si ça ne marche pas :**
- Vérifiez que les 3 terminaux sont ouverts
- Vérifiez les erreurs dans la console du navigateur (F12)
- Vérifiez les logs du serveur backend
- Vérifiez que le webhook secret est bien dans `server/.env`

---

## 🐛 Dépannage

### ❌ Le backend ne démarre pas

**Erreur : "Cannot find module"**
```powershell
cd server
npm install
```

**Erreur : "Port 3000 already in use"**
- Fermez l'application qui utilise le port 3000
- Ou changez le port dans `server/.env` : `PORT=3001`

### ❌ Le frontend ne démarre pas

**Erreur : "Cannot find module"**
```powershell
npm install
```

**Erreur : "Port 5173 already in use"**
- Fermez l'autre instance
- Ou changez le port dans `vite.config.ts`

### ❌ Stripe CLI non trouvé

**Erreur : "stripe: command not found"**
- Installez Stripe CLI (voir étape 3.1)
- Vérifiez qu'il est dans le PATH
- Redémarrez le terminal

### ❌ "Stripe non initialisé" dans le frontend

**Solution :**
1. Vérifiez que `.env` existe à la racine
2. Vérifiez que `VITE_STRIPE_PUBLISHABLE_KEY` est bien défini
3. Redémarrez le serveur frontend

### ❌ "404" lors de la création du PaymentIntent

**Solution :**
1. Vérifiez que le backend est démarré (`http://localhost:3000/health`)
2. Vérifiez que `VITE_API_URL=http://localhost:3000/api` dans `.env`
3. Vérifiez les logs du serveur backend

### ❌ "Webhook signature verification failed"

**Solution :**
1. Vérifiez que `STRIPE_WEBHOOK_SECRET` dans `server/.env` correspond au secret du tunnel
2. Redémarrez le serveur backend après avoir mis à jour le secret
3. Vérifiez que le tunnel webhook est toujours actif

---

## 📋 Checklist finale

- [ ] Dépendances du backend installées (`cd server && npm install`)
- [ ] Serveur backend démarré et accessible (`http://localhost:3000/health`)
- [ ] Stripe CLI installé
- [ ] Stripe CLI connecté (`stripe login`)
- [ ] Webhooks tunnelé (`stripe listen --forward-to...`)
- [ ] Webhook secret copié dans `server/.env`
- [ ] Serveur backend redémarré avec le nouveau secret
- [ ] Frontend démarré (`http://localhost:5173`)
- [ ] Test de paiement effectué avec la carte `4242 4242 4242 4242`
- [ ] Paiement réussi ✅

---

## 🎉 C'est tout !

Si tous les éléments de la checklist sont cochés, vos paiements Stripe sont maintenant fonctionnels ! 🚀

**Prochaines étapes :**
- Tester avec différentes cartes de test
- Déployer en production (utiliser les clés `live`)
- Consulter les logs pour le débogage


