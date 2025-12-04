# Guide d'Intégration Stripe - Étapes Complètes

## 📋 Vue d'ensemble

Ce guide vous accompagne dans l'intégration complète des paiements Stripe dans votre application SaaS. Actuellement, le frontend est prêt mais il manque le backend serveur pour créer les PaymentIntent de manière sécurisée.

## 🎯 Objectif

Rendre les paiements Stripe fonctionnels en créant le backend API nécessaire pour :
- Créer des PaymentIntent de manière sécurisée
- Gérer les webhooks Stripe
- Traiter les paiements réussis

---

## 📚 ÉTAPE 1 : Créer un compte Stripe et obtenir les clés

### 1.1 Créer un compte Stripe

1. Rendez-vous sur https://stripe.com
2. Créez un compte (gratuit)
3. Activez le mode test pour commencer

### 1.2 Récupérer les clés API

1. **Dashboard Stripe** → **Developers** → **API keys**
2. Copiez la **Publishable key** (commence par `pk_test_...`)
3. Copiez la **Secret key** (commence par `sk_test_...`) - **⚠️ À garder secrète !**
4. Pour le webhook secret, voir l'étape 5

---

## 📚 ÉTAPE 2 : Configurer les variables d'environnement

### 2.1 Créer le fichier `.env`

À la racine du projet, créez un fichier `.env` (si il n'existe pas déjà) :

```env
# Stripe Configuration
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_VOTRE_CLE_PUBLIQUE_ICI
VITE_STRIPE_SECRET_KEY=sk_test_VOTRE_CLE_SECRETE_ICI
VITE_STRIPE_WEBHOOK_SECRET=whsec_VOTRE_WEBHOOK_SECRET_ICI

# Application Configuration
VITE_APP_URL=http://localhost:5173
VITE_API_URL=http://localhost:3000/api

# Currency Configuration
VITE_DEFAULT_CURRENCY=XAF
```

### 2.2 Important

- Remplacez les valeurs par vos vraies clés Stripe
- Le fichier `.env` doit être dans `.gitignore` (ne jamais le commiter)
- En production, utilisez `pk_live_...` et `sk_live_...`

---

## 📚 ÉTAPE 3 : Créer le backend serveur (Option Recommandée)

### 3.1 Installation des dépendances

Créez un nouveau dossier `server` à la racine du projet :

```bash
mkdir server
cd server
npm init -y
```

Installez les dépendances nécessaires :

```bash
npm install express cors dotenv stripe
npm install --save-dev @types/express @types/cors nodemon typescript @types/node ts-node
```

### 3.2 Structure du serveur

Créez la structure suivante :

```
server/
├── src/
│   ├── routes/
│   │   ├── payment.ts
│   │   └── webhooks.ts
│   ├── controllers/
│   │   └── paymentController.ts
│   └── index.ts
├── .env
├── package.json
└── tsconfig.json
```

### 3.3 Configuration TypeScript (`server/tsconfig.json`)

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

### 3.4 Fichier d'environnement du serveur (`server/.env`)

```env
# Port du serveur
PORT=3000

# Stripe Secret Key (CÔTÉ SERVEUR UNIQUEMENT)
STRIPE_SECRET_KEY=sk_test_VOTRE_CLE_SECRETE_ICI

# Webhook Secret (obtenu après configuration du webhook)
STRIPE_WEBHOOK_SECRET=whsec_VOTRE_WEBHOOK_SECRET_ICI

# URL de l'application frontend
FRONTEND_URL=http://localhost:5173

# Mode
NODE_ENV=development
```

### 3.5 Point d'entrée du serveur (`server/src/index.ts`)

```typescript
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import paymentRoutes from './routes/payment';
import webhookRoutes from './routes/webhooks';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true
}));

// Webhooks doivent être parsés en raw body (AVANT express.json())
app.use('/api/webhooks/stripe', webhookRoutes);

// Autres routes peuvent utiliser express.json()
app.use(express.json());
app.use('/api', paymentRoutes);

// Route de santé
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log(`📡 API available at http://localhost:${PORT}/api`);
});
```

### 3.6 Routes de paiement (`server/src/routes/payment.ts`)

```typescript
import express from 'express';
import { createPaymentIntent } from '../controllers/paymentController';

const router = express.Router();

// POST /api/create-payment-intent
router.post('/create-payment-intent', createPaymentIntent);

export default router;
```

### 3.7 Contrôleur de paiement (`server/src/controllers/paymentController.ts`)

```typescript
import { Request, Response } from 'express';
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
});

interface CreatePaymentIntentRequest {
  amount: number;
  currency: string;
  metadata: {
    planId: string;
    userId: string;
    planName: string;
  };
}

export const createPaymentIntent = async (req: Request, res: Response) => {
  try {
    const { amount, currency, metadata }: CreatePaymentIntentRequest = req.body;

    // Validation
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Montant invalide' });
    }

    if (!currency) {
      return res.status(400).json({ error: 'Devise requise' });
    }

    if (!metadata || !metadata.planId || !metadata.userId) {
      return res.status(400).json({ error: 'Métadonnées manquantes' });
    }

    // Créer le PaymentIntent
    const paymentIntent = await stripe.paymentIntents.create({
      amount, // Montant en centimes (ex: 1000 = 10.00 XAF)
      currency: currency.toLowerCase(),
      metadata,
      automatic_payment_methods: {
        enabled: true,
      },
      description: `Paiement plan ${metadata.planName}`,
    });

    // Retourner le client_secret au frontend
    res.json({
      paymentIntent: {
        id: paymentIntent.id,
        client_secret: paymentIntent.client_secret,
        status: paymentIntent.status,
      },
    });
  } catch (error: any) {
    console.error('Erreur lors de la création du PaymentIntent:', error);
    res.status(500).json({
      error: error.message || 'Erreur lors de la création du paiement',
    });
  }
};
```

### 3.8 Routes de webhooks (`server/src/routes/webhooks.ts`)

```typescript
import express from 'express';
import Stripe from 'stripe';

const router = express.Router();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-12-18.acacia',
});

// IMPORTANT: express.raw() pour les webhooks
router.post('/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'] as string;
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  if (!webhookSecret) {
    console.error('⚠️ STRIPE_WEBHOOK_SECRET non configuré');
    return res.status(500).send('Webhook secret manquant');
  }

  let event: Stripe.Event;

  try {
    // Vérifier la signature du webhook
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err: any) {
    console.error('❌ Erreur de signature webhook:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Traiter les événements
  switch (event.type) {
    case 'payment_intent.succeeded':
      const paymentIntent = event.data.object as Stripe.PaymentIntent;
      console.log('✅ Paiement réussi:', paymentIntent.id);
      console.log('Métadonnées:', paymentIntent.metadata);
      
      // TODO: Mettre à jour les crédits de l'utilisateur ici
      // Vous pouvez appeler votre logique de mise à jour des crédits
      // updateUserCredits(paymentIntent.metadata.userId, paymentIntent.metadata.planId);
      
      break;

    case 'payment_intent.payment_failed':
      const failedPayment = event.data.object as Stripe.PaymentIntent;
      console.log('❌ Paiement échoué:', failedPayment.id);
      // TODO: Notifier l'utilisateur de l'échec
      break;

    case 'payment_intent.canceled':
      console.log('⚠️ Paiement annulé:', event.data.object);
      break;

    default:
      console.log(`🔔 Événement non géré: ${event.type}`);
  }

  // Répondre rapidement à Stripe
  res.json({ received: true });
});

export default router;
```

### 3.9 Scripts dans `server/package.json`

Ajoutez ces scripts :

```json
{
  "scripts": {
    "dev": "nodemon --exec ts-node src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "type-check": "tsc --noEmit"
  }
}
```

### 3.10 Démarrer le serveur

```bash
cd server
npm run dev
```

Le serveur devrait démarrer sur `http://localhost:3000`

---

## 📚 ÉTAPE 4 : Tester l'API backend

### 4.1 Tester la route de santé

```bash
curl http://localhost:3000/health
```

Réponse attendue : `{"status":"ok","message":"Server is running"}`

### 4.2 Tester la création d'un PaymentIntent

```bash
curl -X POST http://localhost:3000/api/create-payment-intent \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100000,
    "currency": "xaf",
    "metadata": {
      "planId": "silver",
      "userId": "user_123",
      "planName": "Silver"
    }
  }'
```

Vous devriez recevoir un `client_secret` dans la réponse.

---

## 📚 ÉTAPE 5 : Configurer les webhooks Stripe

### 5.1 Installer Stripe CLI (pour le développement local)

**Windows (avec PowerShell) :**
```powershell
# Télécharger depuis https://github.com/stripe/stripe-cli/releases
# Ou utiliser Scoop:
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

### 5.2 Se connecter à Stripe CLI

```bash
stripe login
```

### 5.3 Tunneler les webhooks vers le serveur local

Dans un terminal séparé :

```bash
stripe listen --forward-to localhost:3000/api/webhooks/stripe
```

Stripe CLI vous donnera un **webhook signing secret** (commence par `whsec_...`)

### 5.4 Mettre à jour le `.env` du serveur

Copiez le webhook secret dans `server/.env` :

```env
STRIPE_WEBHOOK_SECRET=whsec_VOTRE_SECRET_ICI
```

**En production :** Configurez le webhook dans le Dashboard Stripe :
1. Dashboard → Developers → Webhooks
2. Add endpoint
3. URL : `https://votre-domaine.com/api/webhooks/stripe`
4. Événements à sélectionner :
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `payment_intent.canceled`
5. Copiez le **Signing secret** dans votre `.env` de production

---

## 📚 ÉTAPE 6 : Tester le paiement complet

### 6.1 Démarrer les services

1. **Terminal 1 - Backend :**
   ```bash
   cd server
   npm run dev
   ```

2. **Terminal 2 - Webhooks (si en développement local) :**
   ```bash
   stripe listen --forward-to localhost:3000/api/webhooks/stripe
   ```

3. **Terminal 3 - Frontend :**
   ```bash
   npm run dev
   ```

### 6.2 Tester un paiement

1. Ouvrez l'application : `http://localhost:5173`
2. Connectez-vous
3. Allez sur la page des plans
4. Sélectionnez un plan
5. Choisissez "Stripe" comme méthode de paiement
6. Utilisez une **carte de test Stripe** :
   - Numéro : `4242 4242 4242 4242`
   - Date d'expiration : n'importe quelle date future (ex: 12/25)
   - CVC : n'importe quel code à 3 chiffres (ex: 123)
   - Nom : n'importe quel nom

### 6.3 Vérifier le résultat

- Le paiement devrait réussir
- Une commande devrait être créée
- Les crédits devraient être ajoutés automatiquement
- Vérifiez les logs du serveur pour voir les événements webhooks

---

## 📚 ÉTAPE 7 : Solution temporaire (Mode développement sans backend)

Si vous voulez tester rapidement sans créer de backend, vous pouvez créer un mode mock :

### 7.1 Créer un service mock (`src/services/stripeServiceMock.ts`)

```typescript
import { PaymentIntentData, PaymentResult } from './stripeService';

export const createMockPaymentIntent = async (data: PaymentIntentData): Promise<PaymentResult> => {
  // Simuler un délai réseau
  await new Promise(resolve => setTimeout(resolve, 1000));

  // Retourner un mock client_secret
  return {
    success: true,
    paymentIntent: {
      id: `pi_mock_${Date.now()}`,
      client_secret: `pi_mock_${Date.now()}_secret_mock_${Math.random().toString(36).substr(2, 9)}`,
      status: 'requires_payment_method',
    },
  };
};
```

### 7.2 Modifier `stripeService.ts` pour utiliser le mock en développement

```typescript
// Dans stripeService.ts
async createPaymentIntent(data: PaymentIntentData): Promise<PaymentResult> {
  // Mode mock pour développement sans backend
  if (import.meta.env.DEV && !STRIPE_CONFIG.apiUrl) {
    console.warn('⚠️ Mode mock activé - aucun backend configuré');
    return await createMockPaymentIntent(data);
  }

  // Code normal avec backend...
}
```

**⚠️ ATTENTION :** Cette solution ne doit être utilisée QUE pour le développement. En production, vous DEVEZ avoir un backend sécurisé.

---

## 📚 ÉTAPE 8 : Déploiement en production

### 8.1 Variables d'environnement de production

- Utilisez les clés **live** Stripe (`pk_live_...` et `sk_live_...`)
- Configurez le webhook Stripe avec l'URL de production
- Utilisez HTTPS partout

### 8.2 Déployer le backend

Options de déploiement :
- **Vercel** : Fonctions serverless
- **Railway** : Déploiement simple
- **Heroku** : Classique mais payant
- **AWS/GCP/Azure** : Pour des besoins plus complexes

### 8.3 Sécurité

- ✅ Ne jamais exposer la clé secrète Stripe côté client
- ✅ Valider tous les webhooks avec la signature
- ✅ Utiliser HTTPS
- ✅ Limiter les CORS
- ✅ Valider tous les inputs

---

## 🐛 Dépannage

### Problème : "Stripe non initialisé"
- **Solution :** Vérifiez que `VITE_STRIPE_PUBLISHABLE_KEY` est défini dans `.env`

### Problème : "Erreur HTTP 404" lors de la création du PaymentIntent
- **Solution :** Vérifiez que le backend est démarré et accessible à `http://localhost:3000`

### Problème : "Webhook signature verification failed"
- **Solution :** Vérifiez que `STRIPE_WEBHOOK_SECRET` correspond au secret du webhook configuré

### Problème : "Currency not supported"
- **Solution :** Stripe ne supporte pas toutes les devises. Pour XAF, vérifiez si elle est supportée ou utilisez XOF (West African CFA franc)

---

## ✅ Checklist finale

- [ ] Compte Stripe créé
- [ ] Clés API récupérées (test)
- [ ] Fichier `.env` créé avec les clés
- [ ] Backend serveur créé et fonctionnel
- [ ] API `/api/create-payment-intent` testée
- [ ] Webhooks configurés (local avec Stripe CLI)
- [ ] Paiement testé avec une carte de test
- [ ] Crédits ajoutés après paiement réussi
- [ ] Webhooks reçus et traités correctement
- [ ] Variables d'environnement de production configurées (quand prêt)

---

## 📞 Support

- Documentation Stripe : https://stripe.com/docs
- Documentation Stripe React : https://stripe.com/docs/stripe-js/react
- Support Stripe : https://support.stripe.com

---

## 🎉 Félicitations !

Une fois toutes ces étapes complétées, vos paiements Stripe seront fonctionnels ! 🚀

