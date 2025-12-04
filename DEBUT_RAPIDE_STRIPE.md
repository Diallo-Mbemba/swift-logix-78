# ⚡ Démarrage Rapide Stripe - 5 Minutes

## 🎯 Objectif : Lancer Stripe en 5 minutes

---

## 📋 Checklist Express

### 1️⃣ Créer les fichiers .env (2 min)

#### Fichier `.env` à la racine :
```env
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_PUBLISHABLE_KEY_HERE
VITE_APP_URL=http://localhost:5173
VITE_API_URL=http://localhost:3000/api
VITE_DEFAULT_CURRENCY=XAF
```

#### Fichier `server/.env` :
```env
PORT=3000
STRIPE_SECRET_KEY=sk_test_YOUR_SECRET_KEY_HERE
FRONTEND_URL=http://localhost:5173
NODE_ENV=development
```

### 2️⃣ Installer et démarrer le backend (2 min)

```bash
cd server
npm install
npm run dev
```

✅ Vérifiez : `http://localhost:3000/health` doit répondre

### 3️⃣ Configurer les webhooks (1 min)

Dans un nouveau terminal :
```bash
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

📋 Copiez le secret `whsec_...` et ajoutez-le dans `server/.env` :
```env
STRIPE_WEBHOOK_SECRET=whsec_VOTRE_SECRET_ICI
```

🔄 Redémarrez le serveur backend

### 4️⃣ Démarrer le frontend (30 sec)

Dans un nouveau terminal (à la racine) :
```bash
npm run dev
```

### 5️⃣ Tester (30 sec)

1. Ouvrir `http://localhost:5173`
2. Choisir un plan → Stripe
3. Carte de test : `4242 4242 4242 4242`
4. Date : `12/25`, CVC : `123`

✅ **C'est fait !** 🎉

---

## 🚨 Si ça ne marche pas

- ✅ Backend démarré ? → `http://localhost:3000/health`
- ✅ Frontend démarré ? → `http://localhost:5173`
- ✅ Webhooks tunnelé ? → Terminal avec `stripe listen`
- ✅ Fichiers `.env` créés ? → Vérifiez à la racine et dans `server/`

---

## 📖 Documentation complète

- `CONFIGURATION_STRIPE_CLES.md` - Guide détaillé avec vos clés
- `GUIDE_INTEGRATION_STRIPE.md` - Documentation complète
- `ETAPES_STRIPE_RESUME.md` - Résumé des étapes

