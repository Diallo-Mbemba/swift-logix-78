# Guide de Test - Mise à Jour Automatique des Crédits

## 🎯 **Vue d'ensemble**

Ce guide explique comment tester la nouvelle fonctionnalité de mise à jour automatique des crédits après validation du paiement à la caisse OIC.

## 🚀 **Fonctionnalités Implémentées**

### 1. **Mise à jour automatique lors de la validation par la caisse**
- ✅ Crédits ajoutés automatiquement après validation du paiement
- ✅ Plan utilisateur mis à jour selon la commande
- ✅ Messages de confirmation avec informations sur les crédits

### 2. **Mise à jour automatique lors de l'autorisation par l'admin**
- ✅ Crédits ajoutés automatiquement lors de l'autorisation
- ✅ Double sécurité pour s'assurer que les crédits sont bien attribués

### 3. **Fonctions utilitaires ajoutées**
- ✅ `addCredits()` dans AuthContext
- ✅ `updateUserCreditsAfterPayment()` dans paymentUtils
- ✅ `updateUserCreditsById()` pour les admins

## 📋 **Scénarios de Test**

### **Scénario 1 : Validation par la Caisse OIC**

1. **Créer une commande** :
   - Aller sur `/plans`
   - Sélectionner un plan (ex: Plan Argent - 10 crédits)
   - Choisir "Caisse OIC" comme méthode de paiement
   - Noter le numéro de commande généré

2. **Valider à la caisse** :
   - Aller sur `/oic-cashier`
   - Démarrer une session de caissier
   - Rechercher la commande par son numéro
   - Cliquer sur "Valider et encaisser"

3. **Vérifier la mise à jour** :
   - ✅ Message de confirmation mentionne les crédits
   - ✅ Console affiche le log de mise à jour
   - ✅ Crédits utilisateur mis à jour automatiquement

### **Scénario 2 : Autorisation par l'Administrateur**

1. **Après validation par la caisse** :
   - Aller sur `/payment-validation`
   - Onglet "Commandes OIC"
   - Trouver la commande validée

2. **Autoriser la commande** :
   - Cliquer sur "Voir détails"
   - Cliquer sur "Autoriser les crédits"

3. **Vérifier la mise à jour** :
   - ✅ Message de confirmation mentionne les crédits
   - ✅ Console affiche le log de mise à jour
   - ✅ Crédits utilisateur mis à jour automatiquement

## 🔍 **Points de Vérification**

### **Dans la Console du Navigateur**
```
✅ Crédits mis à jour automatiquement pour l'utilisateur user@example.com
🔄 Contexte d'authentification mis à jour avec les nouveaux crédits
```

### **Dans le localStorage**
- Vérifier que `user.remainingCredits` a été mis à jour
- Vérifier que `user.totalCredits` a été mis à jour
- Vérifier que `user.plan` correspond au plan acheté

### **Dans l'Interface Utilisateur**
- Messages d'alerte mentionnent la mise à jour des crédits
- Dashboard utilisateur affiche les nouveaux crédits **automatiquement**
- Bouton "Actualiser" disponible pour forcer la mise à jour si nécessaire

### **Mise à Jour Automatique**
- ✅ Les crédits se mettent à jour automatiquement dans le tableau de bord
- ✅ Pas besoin de rafraîchir la page
- ✅ Événement personnalisé déclenche la mise à jour du contexte

## 🛠️ **Fonctions Techniques**

### **updateUserCreditsAfterPayment(order)**
```javascript
// Trouve le plan correspondant
// Met à jour les crédits de l'utilisateur
// Sauvegarde dans localStorage
// Retourne true si succès
```

### **addCredits(credits) dans AuthContext**
```javascript
// Ajoute des crédits à l'utilisateur connecté
// Met à jour remainingCredits et totalCredits
// Sauvegarde automatiquement
```

## 🚨 **Gestion d'Erreurs**

### **Cas d'Erreur Possibles**
1. **Plan non trouvé** : Log d'erreur dans la console
2. **Utilisateur non trouvé** : Log d'erreur dans la console
3. **ID utilisateur ne correspond pas** : Log d'erreur dans la console

### **Messages d'Erreur**
```
⚠️ Échec de la mise à jour automatique des crédits pour l'utilisateur user@example.com
```

## 📊 **Plans et Crédits**

| Plan | Prix | Crédits | Description |
|------|------|---------|-------------|
| Bronze | 1,000 XAF | 1 | 1 simulation |
| Argent | 8,000 XAF | 10 | 10 simulations |
| Or | 88,000 XAF | 100 | 100 simulations |
| Diamant | 880,000 XAF | 1,000 | 1000 simulations |

## 🔄 **Bouton d'Actualisation**

### **Fonctionnalité**
- Bouton "Actualiser" disponible dans le tableau de bord
- Force la mise à jour des crédits depuis le localStorage
- Utile si la mise à jour automatique ne fonctionne pas

### **Utilisation**
1. Aller sur le tableau de bord (`/dashboard`)
2. Cliquer sur le bouton "Actualiser" (icône RefreshCw)
3. Les crédits se mettent à jour immédiatement

## ✅ **Checklist de Test**

- [ ] Créer une commande avec un plan payant
- [ ] Valider le paiement à la caisse OIC
- [ ] Vérifier la mise à jour automatique des crédits
- [ ] Tester le bouton "Actualiser" si nécessaire
- [ ] Autoriser la commande par l'admin
- [ ] Vérifier la double mise à jour (si applicable)
- [ ] Tester avec différents plans
- [ ] Vérifier les messages d'erreur
- [ ] Tester la persistance des données

## 🎉 **Résultat Attendu**

Après validation du paiement à la caisse OIC, le stock de crédits de l'utilisateur se met automatiquement à jour sans intervention manuelle, permettant une expérience utilisateur fluide et automatisée.
