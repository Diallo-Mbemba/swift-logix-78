# 📋 Guide de Migration des Données de Référence vers Supabase

## 🎯 Objectif

Migrer les données de référence (TEC, VOC, TarifPORT) du localStorage vers Supabase et mettre en place un système d'import depuis Excel.

## 📝 Étapes de Migration

### 1. Créer les tables dans Supabase

1. Connectez-vous à votre projet Supabase
2. Allez dans **SQL Editor**
3. Exécutez le fichier `REFERENCE_DATA_TABLES.sql`
4. Vérifiez que les tables sont créées :
   - `tec_articles`
   - `voc_products`
   - `tarifport_products`

### 2. Migrer les données existantes (optionnel)

Si vous avez des données dans le localStorage que vous souhaitez migrer :

```typescript
// Script de migration (à exécuter une fois dans la console du navigateur)
// Ouvrez la console (F12) et exécutez ce code

async function migrateReferenceData() {
  const { referenceDataService } = await import('./src/services/supabase/referenceDataService');
  
  // Migrer TEC
  const tecData = localStorage.getItem('tecArticles');
  if (tecData) {
    const articles = JSON.parse(tecData);
    await referenceDataService.bulkInsertTECArticles(articles);
    console.log(`✅ ${articles.length} articles TEC migrés`);
  }
  
  // Migrer VOC
  const vocData = localStorage.getItem('vocProducts');
  if (vocData) {
    const products = JSON.parse(vocData);
    await referenceDataService.bulkInsertVOCProducts(products);
    console.log(`✅ ${products.length} produits VOC migrés`);
  }
  
  // Migrer TarifPORT
  const tarifportData = localStorage.getItem('tarifportProducts');
  if (tarifportData) {
    const products = JSON.parse(tarifportData);
    await referenceDataService.bulkInsertTarifPORTProducts(products);
    console.log(`✅ ${products.length} produits TarifPORT migrés`);
  }
}

migrateReferenceData();
```

### 3. Importer depuis Excel

1. Connectez-vous en tant qu'administrateur
2. Allez dans la page d'administration (à ajouter dans votre routing)
3. Utilisez la page `ReferenceDataImportPage` pour importer vos fichiers Excel

## 📊 Format des fichiers Excel

### TEC (Tarif Extérieur Commun)

**Colonnes obligatoires :**
- `Code SH10` : Code SH à 10 chiffres
- `Désignation` : Description du produit

**Colonnes optionnelles :**
- `US` : Unité statistique
- `DD` : Droits de douane (%)
- `RSTA` : RSTA (%)
- `PCS` : PCS (%)
- `PUA` : PUA (%)
- `PCC` : PCC (%)
- `RRR` : RRR (%)
- `RCP` : RCP (%)
- `TVA` : TVA (%)
- `Code SH6` : Code SH à 6 chiffres
- `Cumul Sans TVA` : Taux cumulé sans TVA
- `Cumul Avec TVA` : Taux cumulé avec TVA
- `TUB`, `DUS`, `DUD`, `TCB`, `TSM`, `TSB`, `PSV`, `TAI`, `TAB`, `TUF` : Autres colonnes

### VOC (Vérification d'Origine des Conteneurs)

**Colonnes obligatoires :**
- `Code SH` : Code SH du produit
- `Désignation` : Description du produit

**Colonnes optionnelles :**
- `Observation` : Observations
- `Exempté` : Oui/Non ou 1/0 (indique si le produit est exempté)

### TarifPORT

**Colonnes obligatoires :**
- `Libellé Produit` : Nom du produit

**Colonnes optionnelles :**
- `Chapitre` : Chapitre du tarif
- `TP` : Type de produit
- `Code Redevance` : Code de redevance

## 🔧 Utilisation dans le Code

### Avant (localStorage)

```typescript
import { findTECArticleByCode } from './data/tec';

const article = findTECArticleByCode('01011100');
```

### Après (Supabase)

```typescript
import { findTECArticleByCode } from './data/tec';

const article = await findTECArticleByCode('01011100');
```

**Note :** Toutes les fonctions sont maintenant asynchrones. Utilisez `await` ou `.then()`.

## 🚀 Ajouter la Route d'Administration

Ajoutez la route dans votre `App.tsx` ou fichier de routing :

```typescript
import ReferenceDataImportPage from './components/Admin/ReferenceDataImportPage';

// Dans vos routes
<Route path="/admin/reference-data" element={<ReferenceDataImportPage />} />
```

## ✅ Vérification

1. Vérifiez que les tables sont créées dans Supabase
2. Testez l'import d'un fichier Excel
3. Vérifiez que les données sont bien dans Supabase
4. Testez que les fonctions de recherche fonctionnent correctement

## 🔒 Sécurité

- Seuls les administrateurs peuvent modifier les données (RLS activé)
- Tout le monde peut lire les données (nécessaire pour les simulations)
- Les données sont validées avant l'insertion

## 📝 Notes

- Les données sont mises en cache pendant 5 minutes pour améliorer les performances
- Le système utilise un fallback vers localStorage si Supabase n'est pas disponible
- Les colonnes Excel sont mappées automatiquement (insensible à la casse et aux accents)


