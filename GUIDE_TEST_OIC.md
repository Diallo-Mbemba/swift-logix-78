# Guide de Test - Système de Paiement OIC

## 🎯 **Vue d'ensemble du Système**

Le système de paiement OIC implémente un flux complet en 4 étapes :

1. **Utilisateur** : Sélectionne un plan et crée une commande
2. **Caissier OIC** : Valide le paiement physique
3. **Administrateur** : Autorise l'utilisation des crédits
4. **Utilisateur** : Utilise ses crédits pour les simulations

## 🚀 **Démarrage du Test**

### 1. Démarrer l'application
```bash
npm run dev
```
L'application sera disponible sur `http://localhost:5174`

### 2. Se connecter
- Email : `test@example.com`
- Mot de passe : `password`

## 📋 **Scénarios de Test**

### **Scénario 1 : Création d'une Commande**

1. **Aller sur la page des plans** (`/plans`)
2. **Sélectionner un plan** (ex: Plan Basic)
3. **Choisir "Caisse OIC"** comme méthode de paiement
4. **Cliquer sur "Valider"**
5. **Vérifier** :
   - Modal de succès s'affiche
   - Numéro de commande généré (format: CMD-XXXXXX-XXXX)
   - Instructions pour la caisse OIC
   - Commande visible dans le dashboard utilisateur

### **Scénario 2 : Validation par la Caisse OIC**

1. **Aller sur la page caisse** (`/oic-cashier`)
2. **Démarrer une session** :
   - Nom du caissier : `Caissier Test`
   - Cliquer sur "Démarrer la session"
3. **Rechercher la commande** :
   - Entrer le numéro de commande créé précédemment
   - Cliquer sur "Rechercher"
4. **Vérifier les détails** :
   - Informations utilisateur
   - Plan et montant
   - Statut "En attente de validation"
5. **Valider le paiement** :
   - Cliquer sur "Valider et encaisser"
   - Vérifier la génération du reçu
6. **Vérifier** :
   - Commande passe au statut "Validé"
   - Reçu généré automatiquement

### **Scénario 3 : Autorisation par l'Administrateur**

1. **Aller sur la page de validation** (`/payment-validation`)
2. **Basculer sur l'onglet "Commandes OIC"**
3. **Vérifier la commande** :
   - Statut "Validé par la caisse"
   - Informations complètes
4. **Autoriser la commande** :
   - Cliquer sur l'icône "Autoriser" (bouclier)
   - Entrer le nom du validateur : `Admin Test`
   - Cliquer sur "Autoriser les crédits"
5. **Vérifier** :
   - Commande passe au statut "Autorisé"
   - Crédits ajoutés au compte utilisateur

### **Scénario 4 : Utilisation des Crédits**

1. **Retourner au dashboard** (`/dashboard`)
2. **Vérifier la section "Mes Commandes"** :
   - Commande visible avec statut "Crédits débloqués"
   - Crédits ajoutés au compteur
3. **Tester une simulation** :
   - Aller sur `/simulator`
   - Effectuer une simulation
   - Vérifier que les crédits sont déduits

## 🔍 **Points de Vérification**

### **Interface Utilisateur**
- [ ] Modal de commande avec instructions claires
- [ ] Numéro de commande unique et lisible
- [ ] Section commandes dans le dashboard
- [ ] Statuts visuels avec couleurs appropriées

### **Interface Caissier**
- [ ] Recherche de commande par numéro
- [ ] Affichage des détails complets
- [ ] Validation avec génération de reçu
- [ ] Gestion des sessions

### **Interface Administrateur**
- [ ] Onglets pour commandes et paiements
- [ ] Filtres et recherche fonctionnels
- [ ] Actions d'autorisation
- [ ] Statistiques en temps réel

### **Flux de Données**
- [ ] Commandes créées et stockées
- [ ] Statuts mis à jour correctement
- [ ] Crédits ajoutés après autorisation
- [ ] Historique complet des actions

## 🐛 **Tests d'Erreur**

### **Commande Inexistante**
1. Aller sur la caisse OIC
2. Entrer un numéro de commande inexistant
3. Vérifier le message d'erreur

### **Commande Déjà Validée**
1. Valider une commande
2. Essayer de la valider à nouveau
3. Vérifier le message d'erreur

### **Autorisation Sans Validation**
1. Essayer d'autoriser une commande non validée
2. Vérifier que l'action n'est pas disponible

## 📊 **Données de Test**

### **Plans Disponibles**
- Plan Basic : 10 crédits - 5,000 XAF
- Plan Pro : 50 crédits - 20,000 XAF
- Plan Premium : 200 crédits - 75,000 XAF

### **Utilisateurs de Test**
- **Utilisateur** : `test@example.com` / `password`
- **Caissier** : `Caissier Test`
- **Admin** : `Admin Test`

## 🎯 **Résultats Attendus**

### **Statuts des Commandes**
1. `pending_validation` → Jaune (En attente)
2. `validated` → Bleu (Validé par la caisse)
3. `authorized` → Vert (Autorisé par l'admin)

### **Notifications**
- Messages de succès pour chaque étape
- Instructions claires pour l'utilisateur
- Reçus générés automatiquement

### **Sécurité**
- Validation des permissions
- Vérification des statuts
- Traçabilité des actions

## 🔧 **Dépannage**

### **Problèmes Courants**

1. **Commande non trouvée** :
   - Vérifier le numéro de commande
   - S'assurer que la commande existe

2. **Statut non mis à jour** :
   - Actualiser la page
   - Vérifier les logs de la console

3. **Crédits non ajoutés** :
   - Vérifier que la commande est autorisée
   - Contrôler le statut dans le dashboard

### **Logs de Debug**
Ouvrir la console du navigateur pour voir :
- Création des commandes
- Mise à jour des statuts
- Erreurs éventuelles

## ✅ **Checklist de Validation**

- [ ] Création de commande fonctionne
- [ ] Recherche par numéro fonctionne
- [ ] Validation par caisse fonctionne
- [ ] Autorisation par admin fonctionne
- [ ] Crédits ajoutés correctement
- [ ] Interface utilisateur intuitive
- [ ] Gestion d'erreurs appropriée
- [ ] Flux complet sans erreur

---

**Note** : Ce système est conçu pour fonctionner entièrement côté client avec localStorage. En production, il faudrait implémenter une API backend pour la persistance des données.







