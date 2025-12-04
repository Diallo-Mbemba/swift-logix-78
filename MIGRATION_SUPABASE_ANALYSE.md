# 📊 ANALYSE COMPLÈTE - Migration localStorage → Supabase

## 🔍 1. CARTographie DES DONNÉES

### Données stockées en localStorage :

| Clé localStorage | Type | Description | Fichiers concernés |
|-----------------|------|-------------|-------------------|
| `user` | User | Utilisateur connecté avec crédits | `AuthContext.tsx`, `creditFIFOService.ts` |
| `simulations` | Simulation[] | Toutes les simulations de coûts | `SimulationContext.tsx` |
| `orders` | Order[] | Commandes de plans/crédits | `orderUtils.ts`, `PaymentModal.tsx` |
| `orderValidations` | OrderValidation[] | Historique des validations | `orderUtils.ts` |
| `creditPools_{userId}` | CreditPool[] | Pools de crédits FIFO | `creditFIFOService.ts` |
| `creditUsage_{userId}` | CreditUsage[] | Historique utilisation crédits | `creditFIFOService.ts` |
| `settings` | SettingsState | Paramètres application | `SettingsContext.tsx` |
| `adminUsers` | AdminUser[] | Utilisateurs admin/caissier | `orderUtils.ts` |
| `vocProducts` | VOCProduct[] | Produits VOC (référence) | `voc.ts` |

### Modèles de données identifiés :

1. **User** (utilisateur)
   - id, email, name, plan
   - remainingCredits, totalCredits
   - creditPools (relation)
   - createdAt

2. **Simulation** (simulation de coût)
   - id, userId, productName, numeroFacture
   - fob, fret, assurance, droitDouane, etc.
   - formData, autoCalculations, criteria
   - articles[], correctionHistory[]
   - status, createdAt, updatedAt

3. **Order** (commande)
   - id, orderNumber, userId, userEmail, userName
   - planId, planName, planCredits
   - amount, currency, status
   - paymentMethod, validatedAt, authorizedAt
   - validatedBy, authorizedBy, receiptNumber

4. **OrderValidation** (validation commande)
   - id, orderId, validatorId, validatorName
   - validatedAt, type, notes

5. **CreditPool** (pool de crédits FIFO)
   - id, orderId, orderNumber
   - planId, planName
   - totalCredits, remainingCredits
   - createdAt, expiresAt, isActive

6. **CreditUsage** (utilisation crédit)
   - id, userId, simulationId
   - creditPoolId, orderId, orderNumber
   - usedAt, simulationName

7. **Settings** (paramètres)
   - Structure JSON avec préférences utilisateur

8. **AdminUser** (admin/caissier)
   - id, name, email, role
   - permissions[], createdAt, isActive

### Pages/Composants qui manipulent les données :

- **AuthContext.tsx** : login, register, logout, updateUser
- **SimulationContext.tsx** : addSimulation, updateSimulation, deleteSimulation
- **creditFIFOService.ts** : gestion pools FIFO, consommation crédits
- **orderUtils.ts** : CRUD commandes, validations
- **SettingsContext.tsx** : gestion paramètres
- **Dashboard.tsx** : affichage simulations, commandes
- **PaymentModal.tsx** : création commandes
- **OICCashierPage.tsx** : validation commandes

---

## 🗄️ 2. SCHÉMA DE BASE DE DONNÉES SUPABASE

### Tables nécessaires :

1. **users_app** (profil utilisateur étendu)
2. **simulations** (simulations de coûts)
3. **orders** (commandes)
4. **order_validations** (validations)
5. **credit_pools** (pools FIFO)
6. **credit_usage** (historique utilisation)
7. **settings** (paramètres utilisateur)
8. **admin_users** (admins/caissiers)

---

## 🔑 3. AUTHENTIFICATION

- Remplacer login/register localStorage par Supabase Auth
- Utiliser `supabase.auth.signUp()`, `signInWithPassword()`, `signOut()`
- Gérer session avec `onAuthStateChange()`
- Créer profil utilisateur dans `users_app` après signup

---

## 📁 4. ARCHITECTURE FINALE

```
/src
  /lib
    supabaseClient.ts          # Client Supabase
  /services
    supabase/
      authService.ts           # Service auth
      simulationService.ts     # CRUD simulations
      orderService.ts          # CRUD orders
      creditService.ts         # Gestion crédits FIFO
      settingsService.ts       # Paramètres
  /hooks
    useSupabase.ts            # Hooks réutilisables
    useSimulations.ts
    useOrders.ts
    useCredits.ts
  /contexts
    AuthContext.tsx           # Migré vers Supabase
    SimulationContext.tsx     # Migré vers Supabase
    SettingsContext.tsx        # Migré vers Supabase
```

---

## ✅ 5. CHECKLIST DE MIGRATION

- [ ] Créer client Supabase
- [ ] Générer scripts SQL
- [ ] Migrer AuthContext
- [ ] Migrer SimulationContext
- [ ] Migrer creditFIFOService
- [ ] Migrer orderUtils
- [ ] Migrer SettingsContext
- [ ] Supprimer localStorage
- [ ] Tester flux complet
- [ ] Vérifier RLS (Row Level Security)


