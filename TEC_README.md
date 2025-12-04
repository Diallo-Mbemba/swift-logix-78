# Système TEC (Tarif Extérieur Commun) - Kprague

## Vue d'ensemble

Le système TEC permet de gérer et rechercher les codes SH (Système Harmonisé) et leurs tarifs douaniers associés. Il est intégré dans l'application Kprague pour faciliter les calculs de droits de douane.

## Fonctionnalités

### 1. Gestion des articles TEC
- **Import Excel** : Chargement de fichiers Excel contenant les codes SH et tarifs
- **Stockage localStorage** : Persistance des données dans le navigateur
- **Données d'exemple** : Chargement de données de test pour les démonstrations
- **Vidage de table** : Suppression de toutes les données TEC

### 2. Recherche d'articles
- **Recherche par code SH** : Recherche exacte ou partielle par code SH10 ou SH6
- **Recherche par désignation** : Recherche textuelle dans les descriptions
- **Interface intuitive** : Modal de recherche avec filtres et résultats en temps réel

### 3. Intégration avec le simulateur
- **Sélection d'articles** : Ajout direct d'articles TEC dans les simulations
- **Calcul automatique** : Application automatique des taux de droits
- **Validation** : Vérification de la cohérence des données

## Structure des données

Chaque article TEC contient les champs suivants :

| Champ | Description | Type |
|-------|-------------|------|
| `sh10Code` | Code SH10 (10 chiffres) | String |
| `designation` | Description du produit | String |
| `us` | Unité statistique (kg, pce, etc.) | String |
| `dd` | Droits de douane (%) | Number |
| `rsta` | RSTA (%) | Number |
| `pcs` | PCS (%) | Number |
| `pua` | PUA (%) | Number |
| `pcc` | PCC (%) | Number |
| `cumulSansTVA` | Taux cumulé sans TVA (%) | Number |
| `cumulAvecTVA` | Taux cumulé avec TVA (%) | Number |
| `tva` | TVA (%) | Number |
| `sh6Code` | Code SH6 (6 chiffres) | String |
| `tub` | TUB | String |
| `dus` | DUS | String |
| `dud` | DUD | String |
| `tcb` | TCB | String |
| `tsm` | TSM | String |
| `tsb` | TSB | String |
| `psv` | PSV | String |
| `tai` | TAI | String |
| `tab` | TAB | String |
| `tuf` | TUF | String |

## Format Excel requis

Le fichier Excel doit contenir **24 colonnes** dans l'ordre suivant :

1. **sh10 code** - Code SH10
2. **designation** - Description du produit
3. **us** - Unité statistique
4. **dd** - Droits de douane (%)
5. **rsta** - RSTA (%)
6. **pcs** - PCS (%)
7. **pua** - PUA (%)
8. **pcc** - PCC (%)
9. **rrr** - RRR (%)
10. **rcp** - RCP (%)
11. **cumul sans tva** - Taux cumulé sans TVA (%)
12. **cumul avec tva** - Taux cumulé avec TVA (%)
13. **tva** - TVA (%)
14. **h6 cod** - Code SH6
15. **tub** - TUB
16. **dus** - DUS
17. **dud** - DUD
18. **tcb** - TCB
19. **tsm** - TSM
20. **tsb** - TSB
21. **psv** - PSV
22. **tai** - TAI
23. **tab** - TAB
24. **tuf** - TUF

## Utilisation

### 1. Accès à la page TEC
- Connectez-vous à l'application Kprague
- Cliquez sur "TEC" dans le menu de navigation

### 2. Chargement des données
- **Données d'exemple** : Cliquez sur "Données d'exemple" pour charger des articles de test
- **Import Excel** : Utilisez "Charger le fichier TEC" pour importer vos propres données
- **Vidage** : Utilisez "Vider la table" pour supprimer toutes les données

### 3. Recherche d'articles
- Utilisez les filtres "Code SH" et "Désignation" pour rechercher des articles
- Les résultats s'affichent en temps réel
- Cliquez sur un article pour voir ses détails

### 4. Intégration dans le simulateur
- Dans l'étape "Articles" du simulateur, cliquez sur "Rechercher TEC"
- Recherchez et sélectionnez l'article souhaité
- L'article sera automatiquement ajouté à votre simulation avec ses taux de droits

## Calculs automatiques

Le système calcule automatiquement :

- **Taux de droit total** = DD + RSTA + PCS + PUA + PCC
- **Droits de douane** = FOB × (Taux de droit total / 100)
- **TVA** = CAF × (TVA / 100)

## Données d'exemple

Le système inclut des données d'exemple pour les catégories suivantes :
- Produits laitiers (codes 190190)
- Matériaux de construction (codes 251720, 680610)
- Électronique (codes 847130, 851712, 851713)
- Véhicules (codes 870323, 870324, 870325)

## Support technique

Pour toute question ou problème :
1. Vérifiez que votre fichier Excel respecte le format requis
2. Assurez-vous que les codes SH sont valides (10 chiffres pour SH10, 6 pour SH6)
3. Vérifiez que les pourcentages sont des nombres décimaux valides

## Sécurité

- Les données sont stockées localement dans le navigateur (localStorage)
- Aucune donnée n'est envoyée vers des serveurs externes
- Les données sont persistantes jusqu'à ce que vous les supprimiez manuellement 