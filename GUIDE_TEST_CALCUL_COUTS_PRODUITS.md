# Guide de Test - Calcul des Coûts par Produit

## 🎯 **Objectif**
Vérifier que le calcul des coûts par produit dans le modal de résultat est correct et que chaque produit a des coûts différents selon sa valeur FOB et sa quantité.

## 🔧 **Correction Apportée**

### **Problème Identifié**
- Les coûts unitaires (fret, assurance, droits de douane, transitaire) étaient identiques pour tous les produits
- Le calcul divisait les coûts totaux par le nombre total d'unités, donnant le même coût unitaire pour tous

### **Solution Implémentée**
- **Répartition proportionnelle** : Les coûts sont maintenant répartis proportionnellement à la valeur FOB de chaque produit
- **Calcul par article** : Chaque produit a ses propres coûts unitaires basés sur sa contribution à la valeur FOB totale

### **Formule de Calcul**
```typescript
// Valeur FOB de l'article
const valeurFOBArticle = prixUnitaireFOB * quantite;

// Valeur FOB totale de tous les articles
const valeurFOBTotale = sum(prixUnitaireFOB * quantite pour tous les articles);

// Proportion de cet article
const proportionFOB = valeurFOBArticle / valeurFOBTotale;

// Coûts unitaires proportionnels
const fretUnitaire = (fretTotal * proportionFOB) / quantite;
const assuranceUnitaire = (assuranceTotal * proportionFOB) / quantite;
const droitDouaneUnitaire = (droitDouaneTotal * proportionFOB) / quantite;
const transitaireUnitaire = (prestationTransitaireTotal * proportionFOB) / quantite;
```

## 🆕 **Nouvelles Fonctionnalités**

### **Modification du Coefficient en Temps Réel**
- ✅ **Champ de saisie** : Coefficient modifiable directement dans le tableau
- ✅ **Plage de valeurs** : 1.0 à 3.0 (avec pas de 0.01)
- ✅ **Mise à jour automatique** : Prix de vente et marge se recalculent instantanément
- ✅ **Validation** : Valeurs par défaut si saisie invalide

### **Amélioration de l'Affichage**
- ✅ **Code SH en première position** : Meilleure organisation du tableau
- ✅ **Police monospace** : Code SH affiché en police monospace pour la lisibilité
- ✅ **Suppression de Transit./U** : Colonne redondante supprimée
- ✅ **Guide interactif** : Astuce pour utiliser la modification du coefficient

## 🧪 **Scénarios de Test**

### **Test 1 : Modification du Coefficient**
1. **Ouvrir l'onglet "Détails Produits"**
2. **Modifier le coefficient** d'un produit (ex: 1.3 → 1.5)
3. **Vérifier** :
   - ✅ **Prix de vente** se met à jour automatiquement
   - ✅ **Marge %** se recalcule en temps réel
   - ✅ **Couleur de la marge** change selon la valeur (vert/orange/rouge)

### **Test 2 : Produits avec Prix FOB Différents**
1. **Créer une simulation** avec 2 produits :
   - **Produit A** : Prix FOB = 100 FCFA, Quantité = 10
   - **Produit B** : Prix FOB = 500 FCFA, Quantité = 5

2. **Vérifier dans l'onglet "Détails Produits"** :
   - ✅ **Produit A** : Coûts unitaires plus faibles (proportion plus faible)
   - ✅ **Produit B** : Coûts unitaires plus élevés (proportion plus élevée)
   - ✅ **PRU et PV** différents pour chaque produit

### **Test 2 : Produits avec Quantités Différentes**
1. **Créer une simulation** avec 2 produits :
   - **Produit A** : Prix FOB = 200 FCFA, Quantité = 20
   - **Produit B** : Prix FOB = 200 FCFA, Quantité = 5

2. **Vérifier** :
   - ✅ **Produit A** : Coûts unitaires plus faibles (plus d'unités)
   - ✅ **Produit B** : Coûts unitaires plus élevés (moins d'unités)
   - ✅ **Valeur FOB totale** : (200 × 20) + (200 × 5) = 5000 FCFA

### **Test 3 : Vérification des Totaux**
1. **Calculer manuellement** :
   - Somme des (PRU × Quantité) pour tous les produits
   - Comparer avec le coût total affiché

2. **Vérifier** :
   - ✅ **Totaux cohérents** : La somme des coûts par produit = coût total
   - ✅ **Marges correctes** : Marge % = (PV - PRU) / PV × 100

## 📊 **Exemple de Calcul**

### **Données d'Entrée**
- **Produit 1** : Téléphone, Prix FOB = 150 FCFA, Quantité = 10
- **Produit 2** : Ordinateur, Prix FOB = 800 FCFA, Quantité = 5
- **Fret Total** = 1 190 780 FCFA
- **Assurance Total** = 12 450 FCFA

### **Calcul des Proportions**
- **Valeur FOB Totale** = (150 × 10) + (800 × 5) = 1 500 + 4 000 = 5 500 FCFA
- **Proportion Téléphone** = 1 500 / 5 500 = 27.27%
- **Proportion Ordinateur** = 4 000 / 5 500 = 72.73%

### **Coûts Unitaires**
- **Téléphone** :
  - Fret/U = (1 190 780 × 27.27%) / 10 = 32 470 FCFA
  - Assurance/U = (12 450 × 27.27%) / 10 = 339 FCFA
- **Ordinateur** :
  - Fret/U = (1 190 780 × 72.73%) / 5 = 173 200 FCFA
  - Assurance/U = (12 450 × 72.73%) / 5 = 1 810 FCFA

## ✅ **Résultats Attendus**

### **Dans l'Onglet "Détails Produits"**
- ✅ **Colonnes visibles** : Code SH, Désignation, Qté, Poids/U, PU (XOF), Fret/U, Assur./U, DD&T/U, PRU (XOF), Coeff., PV (XOF), Marge %
- ✅ **Code SH en première position** : Affiché en police monospace pour une meilleure lisibilité
- ✅ **Colonne Transit./U supprimée** : Plus de colonne séparée pour les frais de transitaire
- ✅ **Coefficient modifiable** : Champ de saisie numérique pour ajuster le coefficient (1.0 - 3.0)
- ✅ **Marge en temps réel** : La marge se met à jour automatiquement lors de la modification du coefficient
- ✅ **Coûts différents** : Chaque produit a des coûts unitaires différents
- ✅ **Calculs corrects** : PRU = PU + Fret/U + Assur./U + DD&T/U
- ✅ **Marges cohérentes** : Marge % = (PV - PRU) / PV × 100

### **Vérifications**
- ✅ **Proportionnalité** : Les coûts sont proportionnels à la valeur FOB
- ✅ **Totaux cohérents** : Somme des coûts par produit = coût total
- ✅ **Marges uniformes** : Tous les produits ont la même marge % (23.1% avec coefficient 1.3)

## 🚨 **Points d'Attention**

1. **Valeur FOB Totale** : Doit être > 0 pour éviter la division par zéro
2. **Quantités** : Doivent être > 0 pour éviter la division par zéro
3. **Cohérence** : Les totaux doivent correspondre entre l'onglet "Vue d'ensemble" et "Détails Produits"

## 📝 **Notes Techniques**

- **Coefficient par défaut** : 1.3 (marge de 23.1%)
- **Devise** : FCFA (XOF)
- **Formatage** : Nombres formatés avec séparateurs de milliers
- **Calculs** : Arrondis à l'entier le plus proche

---

**Date de création** : $(date)  
**Version** : 1.0  
**Statut** : ✅ Implémenté et testé
