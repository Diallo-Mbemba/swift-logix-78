# 🚀 GUIDE DE MIGRATION - localStorage → Supabase

## 📋 ÉTAPES DE MIGRATION

### 1. Configuration Supabase

1. **Créer un projet Supabase** sur [supabase.com](https://supabase.com)

2. **Récupérer les clés** :
   - Allez dans Settings → API
   - Copiez `Project URL` et `anon public` key

3. **Créer le fichier `.env`** à la racine du projet :
   ```env
   VITE_SUPABASE_URL=votre_url_supabase
   VITE_SUPABASE_ANON_KEY=votre_cle_anon
   ```

4. **Exécuter le schéma SQL** :
   - Ouvrez Supabase SQL Editor
   - Copiez-collez le contenu de `SUPABASE_SCHEMA.sql`
   - Exécutez le script

### 2. Installation des dépendances

Les dépendances Supabase sont déjà installées dans `package.json` :
- `@supabase/supabase-js`

### 3. Migration des données existantes (optionnel)

Si vous avez des données dans localStorage que vous souhaitez migrer :

```typescript
// Script de migration (à exécuter une seule fois)
// Créer un fichier migrate.ts et l'exécuter

import { supabase } from './src/lib/supabaseClient';

async function migrateLocalStorageToSupabase() {
  // Migrer les simulations
  const simulations = JSON.parse(localStorage.getItem('simulations') || '[]');
  for (const sim of simulations) {
    await supabase.from('simulations').insert({
      // mapper les données
    });
  }

  // Migrer les commandes
  const orders = JSON.parse(localStorage.getItem('orders') || '[]');
  for (const order of orders) {
    await supabase.from('orders').insert({
      // mapper les données
    });
  }

  // etc.
}
```

### 4. Mise à jour des composants

Tous les contextes et services ont été migrés :
- ✅ `AuthContext` → utilise Supabase Auth
- ✅ `SimulationContext` → utilise Supabase
- ✅ `SettingsContext` → utilise Supabase
- ✅ `creditFIFOService` → utilise Supabase
- ✅ `orderUtils` → utilise Supabase

### 5. Mise à jour des appels asynchrones

⚠️ **IMPORTANT** : Les fonctions qui utilisaient localStorage sont maintenant asynchrones.

**Avant** :
```typescript
const orders = getUserOrders(userId);
```

**Après** :
```typescript
const orders = await getUserOrders(userId);
```

### 6. Composants à mettre à jour

Les composants suivants doivent être mis à jour pour utiliser `await` :

- `Dashboard.tsx` - `getUserOrders()` est maintenant async
- `PaymentModal.tsx` - `createOrder()` est maintenant async
- `OICCashierPage.tsx` - `updateOrderStatus()` est maintenant async
- `CreditPoolsDisplay.tsx` - `getUserCreditPools()` est maintenant async
- Tous les composants utilisant `deductCredit()` - maintenant async

### 7. Nettoyage

Après vérification que tout fonctionne :

1. Supprimer les anciens fichiers (si backup créé)
2. Vérifier qu'aucune référence à `localStorage` ne reste (sauf pour des données temporaires)
3. Tester tous les flux utilisateur

## ✅ CHECKLIST FINALE

- [ ] Variables d'environnement configurées
- [ ] Schéma SQL exécuté dans Supabase
- [ ] Migration des données (si nécessaire)
- [ ] Tous les composants mis à jour avec `await`
- [ ] Test de connexion/déconnexion
- [ ] Test de création de simulation
- [ ] Test de création de commande
- [ ] Test de validation de commande
- [ ] Test de consommation de crédit
- [ ] Vérification RLS (Row Level Security)

## 🔧 DÉPANNAGE

### Erreur "Missing Supabase environment variables"
- Vérifiez que `.env` existe et contient les bonnes variables
- Redémarrez le serveur de développement

### Erreur RLS (Row Level Security)
- Vérifiez que les politiques RLS sont bien créées
- Vérifiez que l'utilisateur est bien connecté (`auth.uid()`)

### Erreur de connexion
- Vérifiez l'URL Supabase
- Vérifiez la clé anon
- Vérifiez la console Supabase pour les logs

## 📚 RESSOURCES

- [Documentation Supabase](https://supabase.com/docs)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

