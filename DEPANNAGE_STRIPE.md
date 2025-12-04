# 🔧 Dépannage - Erreur d'Initialisation Stripe

## ❌ Problème : "Erreur d'initialisation" lors du paiement Stripe

### ✅ Solutions rapides

#### 1. Vérifier que le backend est démarré

Le backend doit être en cours d'exécution pour créer les PaymentIntent Stripe.

**Démarrer le backend :**
```bash
cd server
npm install  # Si ce n'est pas déjà fait
npm run dev
```

Vous devriez voir :
```
🚀 Server running on http://localhost:3000
📡 API available at http://localhost:3000/api
```

#### 2. Vérifier le fichier `.env` du backend

Dans le dossier `server/`, créez un fichier `.env` avec :

```env
PORT=3000
STRIPE_SECRET_KEY=sk_test_VOTRE_CLE_SECRETE_ICI
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
FRONTEND_URL=http://localhost:5173
NODE_ENV=development
```

**Important :** Utilisez la même clé secrète que dans le `.env` du frontend.

#### 3. Vérifier le fichier `.env` du frontend

À la racine du projet, vérifiez que `.env` contient :

```env
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_VOTRE_CLE_PUBLIQUE_ICI
VITE_STRIPE_SECRET_KEY=sk_test_VOTRE_CLE_SECRETE_ICI
VITE_API_URL=http://localhost:3000/api
VITE_APP_URL=http://localhost:5173
VITE_DEFAULT_CURRENCY=XAF
```

#### 4. Redémarrer le serveur de développement

Après avoir modifié `.env`, **redémarrez** le serveur frontend :

```bash
# Arrêtez le serveur (Ctrl+C)
# Puis redémarrez
npm run dev
```

#### 5. Vérifier que l'API est accessible

Ouvrez dans votre navigateur :
- http://localhost:3000/health (devrait retourner `{"status":"ok"}`)
- http://localhost:3000/api/test (devrait retourner `{"message":"API is working!"}`)

### 🔍 Diagnostic détaillé

#### Vérifier les logs du navigateur

1. Ouvrez la console du navigateur (F12)
2. Allez dans l'onglet "Console"
3. Essayez de faire un paiement Stripe
4. Regardez les messages d'erreur détaillés

#### Messages d'erreur courants

**"Impossible de contacter le serveur"**
- ✅ Solution : Démarrez le backend (`cd server && npm run dev`)

**"Endpoint non trouvé (404)"**
- ✅ Solution : Vérifiez que `VITE_API_URL=http://localhost:3000/api` dans `.env`

**"Configuration Stripe manquante"**
- ✅ Solution : Vérifiez que `VITE_STRIPE_PUBLISHABLE_KEY` est définie dans `.env`

**"Erreur serveur (500)"**
- ✅ Solution : Vérifiez les logs du backend et que `STRIPE_SECRET_KEY` est configurée dans `server/.env`

### 📋 Checklist complète

- [ ] Backend démarré sur le port 3000
- [ ] Fichier `server/.env` créé avec `STRIPE_SECRET_KEY`
- [ ] Fichier `.env` à la racine avec `VITE_STRIPE_PUBLISHABLE_KEY` et `VITE_API_URL`
- [ ] Serveur frontend redémarré après modification de `.env`
- [ ] API accessible sur http://localhost:3000/health
- [ ] Clés Stripe valides (commencent par `pk_test_` et `sk_test_`)

### 🆘 Si le problème persiste

1. **Vérifiez les ports** : Assurez-vous que le port 3000 n'est pas utilisé par un autre processus
2. **Vérifiez les clés Stripe** : Allez sur https://dashboard.stripe.com/test/apikeys
3. **Consultez les logs** : Regardez les logs du backend et du navigateur
4. **Testez l'API manuellement** :
   ```bash
   curl -X POST http://localhost:3000/api/create-payment-intent \
     -H "Content-Type: application/json" \
     -d '{"amount":100000,"currency":"xaf","metadata":{"planId":"test","userId":"test","planName":"Test"}}'
   ```

### 📞 Support

Si le problème persiste après avoir suivi ces étapes, vérifiez :
- Les logs du backend dans le terminal
- La console du navigateur (F12)
- Les fichiers `.env` (vérifiez qu'ils sont bien sauvegardés)


