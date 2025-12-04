# Système VOC (Verification of Conformity) - Kprague

## Vue d'ensemble

Le système VOC permet de gérer les produits soumis ou exemptés de la Vérification de Conformité. Il est intégré dans l'application Kprague pour faciliter la gestion des produits importés.

## Fonctionnalités

### 1. Gestion des produits VOC
- **Import Excel** : Chargement de fichiers Excel contenant les codes SH et statuts VOC
- **Stockage localStorage** : Persistance des données dans le navigateur
- **Données d'exemple** : Chargement de données de test pour les démonstrations
- **Vidage de table** : Suppression de toutes les données VOC

### 2. Recherche d'articles
- **Recherche par code SH** : Recherche exacte ou partielle par code SH
- **Recherche par désignation** : Recherche textuelle dans les descriptions
- **Statut d'exemption** : Indication claire des produits exemptés ou soumis au VOC

### 3. Intégration avec le simulateur
- **Vérification automatique** : Contrôle du statut VOC lors des simulations
- **Validation** : Vérification de la cohérence des données

### 4. Paramètres de calcul
- **RRR (Redevance de Régularisation)** : Calcul automatique basé sur la valeur CAF
- **RCP (Redevance Contrôle des Prix)** : Calcul automatique basé sur la valeur CAF
- **Taux configurables** : Paramètres ajustables dans les paramètres de l'application

## Structure des données

Chaque produit VOC contient les champs suivants :

| Champ | Description | Type |
|-------|-------------|------|
| `codeSH` | Code SH du produit | String |
| `designation` | Description du produit | String |
| `observation` | Observations supplémentaires (optionnel) | String |
| `exempte` | Statut d'exemption (true = exempté, false = soumis) | Boolean |

## Paramètres RRR et RCP

### RRR (Redevance de Régularisation)
- **Description** : Redevance appliquée pour la régularisation des importations
- **Calcul automatique** : Basé sur la valeur CAF avec un taux configurable
- **Taux par défaut** : 0.4% de la valeur CAF
- **Mode manuel** : Possibilité de saisir une valeur manuelle

### RCP (Redevance Contrôle des Prix)
- **Description** : Redevance pour le contrôle des prix des marchandises importées
- **Calcul automatique** : Basé sur la valeur CAF avec un taux configurable
- **Taux par défaut** : 0.3% de la valeur CAF
- **Mode manuel** : Possibilité de saisir une valeur manuelle

### Configuration des taux
Les taux RRR et RCP sont configurables dans les paramètres de l'application :
- **Accès** : Paramètres > Taux de calcul
- **Modification** : Valeurs décimales (ex: 0.004 pour 0.4%)
- **Persistance** : Sauvegarde automatique dans localStorage

## Format Excel requis

Le fichier Excel doit contenir **4 colonnes** dans l'ordre suivant :

1. **Colonne A: Code SH** (obligatoire) - Code SH du produit
2. **Colonne B: Désignation** (obligatoire) - Description du produit
3. **Colonne C: Observation** (optionnel) - Observations supplémentaires
4. **Colonne D: Exempté** (obligatoire) - 1 pour Oui (exempté), 0 pour Non (soumis)

### Exemple de données Excel :

| Code SH | Désignation | Observation | Exempté |
|---------|-------------|-------------|---------|
| 1901901000 | Préparations à base de lait | Produit alimentaire de base | 1 |
| 8471300000 | Ordinateurs portables | Équipement informatique | 0 |
| 8517130000 | Téléphones intelligents | Télécommunication avancée | 0 |

## Utilisation

### 1. Accès à la gestion VOC
- Connectez-vous à l'application Kprague
- Allez dans "Paramètres"
- Utilisez la section "Gestion des Produits VOC"

### 2. Chargement des données
- **Données d'exemple** : Cliquez sur "Modèle Excel" pour charger des produits de test
- **Import Excel** : Utilisez "Importer les données VOC" pour importer vos propres données
- **Vidage** : Utilisez "Vider la table" pour supprimer toutes les données

### 3. Format du fichier
- La première ligne doit contenir les en-têtes
- Seules les lignes avec un code SH et une désignation valides seront importées
- Le champ "Exempté" utilise 1 pour Oui et 0 pour Non

## Données d'exemple

Le système inclut des données d'exemple pour les catégories suivantes :
- **Produits alimentaires** (codes 190190) - Exemptés
- **Matériaux de construction** (codes 251720, 680610) - Soumis
- **Électronique** (codes 847130, 851712, 851713) - Soumis
- **Véhicules** (codes 870323, 870324, 870325) - Soumis

## Intégration avec le simulateur

Le système VOC est automatiquement intégré dans le simulateur :
- Lors de la saisie d'un code SH, le statut VOC est vérifié
- Les produits exemptés ne nécessitent pas de certificat de conformité
- Les produits soumis au VOC nécessitent une vérification de conformité
- **Impact sur les coûts** : Les paramètres RRR et RCP sont calculés automatiquement selon le statut VOC
- **Calcul des redevances** : Les taux RRR et RCP s'appliquent aux produits soumis au VOC
- **Optimisation** : Les produits exemptés peuvent bénéficier de réductions sur certaines redevances

## Support technique

Pour toute question ou problème :
1. Vérifiez que votre fichier Excel respecte le format requis
2. Assurez-vous que les codes SH sont valides
3. Vérifiez que le champ "Exempté" contient uniquement 1 ou 0

## Sécurité

- Les données sont stockées localement dans le navigateur (localStorage)
- Aucune donnée n'est envoyée vers des serveurs externes
- Les données sont persistantes jusqu'à ce que vous les supprimiez manuellement

## Différences avec le système TEC

| Aspect | TEC | VOC |
|--------|-----|-----|
| **Objectif** | Tarifs douaniers | Vérification de conformité |
| **Colonnes Excel** | 22 colonnes | 4 colonnes |
| **Données** | Codes SH + tarifs | Codes SH + statut exemption |
| **Utilisation** | Calcul des droits | Validation des importations | 