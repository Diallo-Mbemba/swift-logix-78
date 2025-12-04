# ✅ Prochaines Étapes - Démarrer Stripe

## 🎯 Résumé : Vous êtes ici → 

✅ Fichiers `.env` créés  
⏭️ **Prochaine étape : Démarrer les services**

---

## 🚀 Démarrer les Services (dans l'ordre)

### 1️⃣ Terminal 1 : Backend Serveur

```powershell
cd server
npm install
npm run dev
```

**✅ Vérifiez :** Ouvrez `http://localhost:3000/health`  
Vous devriez voir : `{"status":"ok",...}`

**⚠️ Gardez ce terminal ouvert !**

---

### 2️⃣ Terminal 2 : Webhooks Stripe

#### A. Installer Stripe CLI (une seule fois)

**Option 1 - Avec Scoop :**
```powershell
scoop bucket add stripe https://github.com/stripe/scoop-stripe-cli.git
scoop install stripe
```

**Option 2 - Télécharger :**
https://github.com/stripe/stripe-cli/releases

#### B. Se connecter

```powershell
stripe login
```

#### C. Tunneler les webhooks

```powershell
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

**📋 Action importante :**
1. Copiez le secret `whsec_...` qui s'affiche
2. Ouvrez `server/.env`
3. Remplacez `STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here` par le vrai secret
4. Redémarrez le serveur backend (Terminal 1 : Ctrl+C puis `npm run dev`)

**⚠️ Gardez ce terminal ouvert !**

---

### 3️⃣ Terminal 3 : Frontend

```powershell
cd ..
npm run dev
```

**✅ Vérifiez :** Ouvrez `http://localhost:5173`  
L'application devrait se charger.

**⚠️ Gardez ce terminal ouvert !**

---

## 🧪 Tester le Paiement

1. **Ouvrez** : `http://localhost:5173`
2. **Connectez-vous** (ou créez un compte)
3. **Allez sur** : Page des plans (`/plans`)
4. **Sélectionnez** un plan
5. **Choisissez** : "Stripe" comme méthode
6. **Utilisez la carte de test** :
   - Numéro : `4242 4242 4242 4242`
   - Date : `12/25`
   - CVC : `123`

**✅ Si ça marche :** Paiement confirmé + Crédits ajoutés !

---

## 🐛 Problèmes ?

### Le backend ne démarre pas

```powershell
cd server
npm install
```

### Port déjà utilisé

Changez le port dans `server/.env` :
```
PORT=3001
```

### "Stripe non initialisé"

1. Vérifiez que `.env` existe à la racine
2. Redémarrez le frontend

### "404" sur create-payment-intent

1. Vérifiez que le backend tourne : `http://localhost:3000/health`
2. Vérifiez `VITE_API_URL=http://localhost:3000/api` dans `.env`

---

## 📋 Checklist

- [ ] Backend installé (`cd server && npm install`)
- [ ] Backend démarré (Terminal 1)
- [ ] Backend accessible (`http://localhost:3000/health`)
- [ ] Stripe CLI installé
- [ ] Stripe CLI connecté (`stripe login`)
- [ ] Webhooks tunnelé (Terminal 2)
- [ ] Secret webhook copié dans `server/.env`
- [ ] Backend redémarré avec le nouveau secret
- [ ] Frontend démarré (Terminal 3)
- [ ] Test de paiement réussi ✅

---

## 📚 Guides détaillés

- **`DEMARRER_SERVICES.md`** - Guide complet étape par étape
- **`CONFIGURATION_STRIPE_CLES.md`** - Configuration détaillée
- **`DEBUT_RAPIDE_STRIPE.md`** - Version rapide

---

## 🎉 Prêt !

Vous avez **3 terminaux** à ouvrir, puis testez le paiement. C'est parti ! 🚀

