# Guide de Test - Validation d'Achat de Crédits

## 🎯 **Vue d'ensemble**

Ce guide explique comment tester la nouvelle fonctionnalité qui empêche l'utilisateur d'acheter de nouveaux crédits tant qu'il en possède encore.

## 🚀 **Fonctionnalités Implémentées**

### 1. **Validation d'achat de crédits**
- ✅ Empêche l'achat si l'utilisateur a encore des crédits
- ✅ Message d'alerte informatif
- ✅ Boutons désactivés visuellement

### 2. **Interface utilisateur améliorée**
- ✅ Message informatif sur le statut des crédits
- ✅ Boutons d'achat désactivés quand approprié
- ✅ Indicateurs visuels clairs

### 3. **Fonctions utilitaires**
- ✅ `canUserBuyCredits(user)` - Vérifie si l'utilisateur peut acheter
- ✅ `getCreditPurchaseMessage(user)` - Message informatif

## 📋 **Scénarios de Test**

### **Scénario 1 : Utilisateur avec des crédits restants**

1. **Se connecter** avec un utilisateur qui a des crédits :
   - Aller sur `/login`
   - Se connecter avec un compte ayant des crédits > 0

2. **Aller sur la page des plans** :
   - Naviguer vers `/plans`
   - Observer le message informatif jaune

3. **Tenter d'acheter un plan** :
   - Cliquer sur "Choisir ce plan" pour un plan payant
   - Vérifier que l'alerte s'affiche
   - Vérifier que les boutons sont désactivés

4. **Vérifications** :
   - ✅ Message jaune : "Vous avez encore X crédits disponibles"
   - ✅ Boutons affichent "Crédits disponibles" (grisés)
   - ✅ Alerte : "Vous avez encore X crédits disponibles. Vous ne pouvez pas acheter..."

### **Scénario 2 : Utilisateur sans crédits**

1. **Se connecter** avec un utilisateur sans crédits :
   - Utiliser un compte avec `remainingCredits = 0`

2. **Aller sur la page des plans** :
   - Naviguer vers `/plans`
   - Observer le message informatif bleu

3. **Tenter d'acheter un plan** :
   - Cliquer sur "Choisir ce plan"
   - Vérifier que le modal de paiement s'ouvre

4. **Vérifications** :
   - ✅ Message bleu : "Vous n'avez plus de crédits"
   - ✅ Boutons affichent "Choisir ce plan" (actifs)
   - ✅ Modal de paiement s'ouvre normalement

### **Scénario 3 : Plan gratuit**

1. **Tester le plan gratuit** :
   - Cliquer sur "Commencer gratuitement"
   - Vérifier que le bouton fonctionne toujours

2. **Vérifications** :
   - ✅ Plan gratuit toujours accessible
   - ✅ Bouton "Commencer gratuitement" actif

## 🔍 **Points de Vérification**

### **Messages Informatifs**
- **Avec crédits** : Message jaune avec nombre de crédits
- **Sans crédits** : Message bleu encourageant l'achat
- **Cohérence** : Messages cohérents entre l'alerte et l'interface

### **Boutons d'Achat**
- **Avec crédits** : Boutons grisés avec texte "Crédits disponibles"
- **Sans crédits** : Boutons actifs avec texte "Choisir ce plan"
- **Plan gratuit** : Toujours accessible

### **Validation Fonctionnelle**
- **Avec crédits** : Alerte empêche l'achat
- **Sans crédits** : Modal de paiement s'ouvre
- **Cohérence** : Validation cohérente partout

## 🛠️ **Fonctions Techniques**

### **canUserBuyCredits(user)**
```javascript
// Retourne true seulement si remainingCredits <= 0
// Empêche l'achat si l'utilisateur a encore des crédits
```

### **getCreditPurchaseMessage(user)**
```javascript
// Message personnalisé selon le nombre de crédits
// "Vous avez encore X crédits..." ou "Vous n'avez plus de crédits..."
```

## 🎨 **Interface Utilisateur**

### **Messages Informatifs**
- **Couleur jaune** : Utilisateur a encore des crédits
- **Couleur bleue** : Utilisateur peut acheter
- **Icônes** : 💳 pour crédits disponibles, 🔄 pour achat possible

### **Boutons**
- **Grisés** : Quand l'achat n'est pas possible
- **Actifs** : Quand l'achat est possible
- **Texte adaptatif** : "Crédits disponibles" vs "Choisir ce plan"

## ✅ **Checklist de Test**

### **Test avec crédits restants**
- [ ] Message informatif jaune s'affiche
- [ ] Boutons sont grisés et désactivés
- [ ] Texte des boutons : "Crédits disponibles"
- [ ] Alerte empêche l'achat
- [ ] Plan gratuit reste accessible

### **Test sans crédits**
- [ ] Message informatif bleu s'affiche
- [ ] Boutons sont actifs
- [ ] Texte des boutons : "Choisir ce plan"
- [ ] Modal de paiement s'ouvre
- [ ] Achat fonctionne normalement

### **Test de cohérence**
- [ ] Messages cohérents partout
- [ ] Validation fonctionnelle
- [ ] Interface utilisateur claire
- [ ] Pas de bugs visuels

## 🎉 **Résultat Attendu**

L'utilisateur ne peut plus acheter de nouveaux crédits tant qu'il en possède encore, avec une interface claire et des messages informatifs qui expliquent pourquoi l'achat n'est pas possible.
