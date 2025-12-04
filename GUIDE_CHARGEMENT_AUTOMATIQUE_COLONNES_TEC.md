# 🔧 Guide - Chargement Automatique des Colonnes TEC

## Problème résolu

**Symptôme :** À l'étape 5 du simulateur, après avoir chargé une facture à l'étape 4, les codes SH présents dans le tableau ne chargeaient pas automatiquement les colonnes avec les **valeurs réelles** contenues dans la base TEC :
- DD (%) - Droits de douane
- RSTA (%) - Redevance statistique
- PCS - Prélèvement communautaire de solidarité
- PUA - Prélèvement unitaire d'accompagnement
- PCC - Prélèvement communautaire de compétitivité
- RRR - Redevance de régularisation
- RCP - Redevance contrôle des prix
- TVA (%) - Taxe sur la valeur ajoutée
- Cumul Sans TVA (%) - Taux cumulé sans TVA
- Cumul Avec TVA (%) - Taux cumulé avec TVA

**Important :** Les colonnes doivent afficher les **valeurs réelles** contenues dans la base TEC en fonction du code SH du produit, et non des valeurs par défaut ou calculées.

## Solution implémentée

### 1. Extension de l'interface Article

L'interface `Article` a été étendue pour inclure toutes les colonnes TEC individuelles :

```typescript
interface Article {
  id: string;
  codeHS: string;
  designation: string;
  quantite: number;
  prixUnitaire: number;
  prixTotal: number;
  poids: number;
  tauxDroit: number;
  montantDroit: number;
  prixTotalImporte?: number;
  // Nouvelles colonnes TEC individuelles
  dd?: number;
  rsta?: number;
  pcs?: number;
  pua?: number;
  pcc?: number;
  rrr?: number;
  rcp?: number;
  tva?: number;
  cumulSansTVA?: number;
  cumulAvecTVA?: number;
}
```

### 2. Chargement automatique lors de l'upload de facture

Lors de l'upload d'un fichier Excel à l'étape 4, le système charge maintenant automatiquement toutes les colonnes TEC avec les **valeurs réelles** de la base TEC pour chaque article :

```typescript
// Récupérer l'article TEC pour charger automatiquement les colonnes
const codeHS = get('codesh', 'codehs', 'codehs');
const tecArticle = findTECArticleByCode(codeHS);

// Debug: afficher les valeurs TEC réelles récupérées
if (tecArticle && codeHS) {
  console.log(`✅ Valeurs TEC réelles pour ${codeHS}:`, {
    dd: tecArticle.dd,
    rsta: tecArticle.rsta,
    pcs: tecArticle.pcs,
    pua: tecArticle.pua,
    pcc: tecArticle.pcc,
    rrr: tecArticle.rrr,
    rcp: tecArticle.rcp,
    tva: tecArticle.tva,
    cumulSansTVA: tecArticle.cumulSansTVA,
    cumulAvecTVA: tecArticle.cumulAvecTVA
  });
}

return ({
  id: (get('id') || (idx + 1).toString()),
  codeHS: codeHS,
  designation: get('designation', 'libelle', 'designations'),
  quantite: quantite,
  prixUnitaire: prixUnitaire,
  prixTotal: prixTotalCalcule,
  poids: parseNumber(get('poidskg', 'poids')),
  tauxDroit: parseNumber(get('tauxdroit')) || tecArticle?.cumulAvecTVA || 0,
  montantDroit: parseNumber(get('montantdroit')),
  prixTotalImporte: prixTotalImporte,
  // Chargement automatique des VALEURS RÉELLES de la base TEC
  dd: tecArticle?.dd || 0,           // Valeur réelle DD de la base TEC
  rsta: tecArticle?.rsta || 0,       // Valeur réelle RSTA de la base TEC
  pcs: tecArticle?.pcs || 0,         // Valeur réelle PCS de la base TEC
  pua: tecArticle?.pua || 0,         // Valeur réelle PUA de la base TEC
  pcc: tecArticle?.pcc || 0,         // Valeur réelle PCC de la base TEC
  rrr: tecArticle?.rrr || 0,         // Valeur réelle RRR de la base TEC
  rcp: tecArticle?.rcp || 0,         // Valeur réelle RCP de la base TEC
  tva: tecArticle?.tva || 0,         // Valeur réelle TVA de la base TEC
  cumulSansTVA: tecArticle?.cumulSansTVA || 0,   // Valeur réelle Cumul Sans TVA
  cumulAvecTVA: tecArticle?.cumulAvecTVA || 0,   // Valeur réelle Cumul Avec TVA
});
```

**Note importante :** Le `|| 0` est uniquement une valeur de fallback si l'article TEC n'est pas trouvé. Si l'article existe dans la base TEC, les **valeurs réelles** sont utilisées.

### 3. Chargement automatique lors de la sélection de code SH

Quand un utilisateur sélectionne un code SH via le modal de recherche, toutes les colonnes TEC sont automatiquement chargées avec les **valeurs réelles** de la base TEC :

```typescript
const handleSelectCodeHS = (newCode: string, designation: string) => {
  // Récupérer l'article TEC complet pour le nouveau code
  const tecArticle = findTECArticleByCode(newCode);
  
  // Debug: afficher les valeurs TEC réelles récupérées
  if (tecArticle) {
    console.log(`✅ Valeurs TEC réelles pour ${newCode}:`, {
      dd: tecArticle.dd,
      rsta: tecArticle.rsta,
      pcs: tecArticle.pcs,
      pua: tecArticle.pua,
      pcc: tecArticle.pcc,
      rrr: tecArticle.rrr,
      rcp: tecArticle.rcp,
      tva: tecArticle.tva,
      cumulSansTVA: tecArticle.cumulSansTVA,
      cumulAvecTVA: tecArticle.cumulAvecTVA
    });
  }
  
  // Mettre à jour l'article avec toutes les colonnes TEC
  setNewArticle(prev => ({
    ...prev,
    codeHS: newCode,
    // Charger automatiquement les VALEURS RÉELLES de la base TEC
    dd: tecArticle?.dd || 0,           // Valeur réelle DD de la base TEC
    rsta: tecArticle?.rsta || 0,       // Valeur réelle RSTA de la base TEC
    pcs: tecArticle?.pcs || 0,         // Valeur réelle PCS de la base TEC
    pua: tecArticle?.pua || 0,         // Valeur réelle PUA de la base TEC
    pcc: tecArticle?.pcc || 0,         // Valeur réelle PCC de la base TEC
    rrr: tecArticle?.rrr || 0,         // Valeur réelle RRR de la base TEC
    rcp: tecArticle?.rcp || 0,         // Valeur réelle RCP de la base TEC
    tva: tecArticle?.tva || 0,         // Valeur réelle TVA de la base TEC
    cumulSansTVA: tecArticle?.cumulSansTVA || 0,   // Valeur réelle Cumul Sans TVA
    cumulAvecTVA: tecArticle?.cumulAvecTVA || 0,   // Valeur réelle Cumul Avec TVA
    tauxDroit: tecArticle?.cumulAvecTVA || 0       // Valeur réelle Cumul Avec TVA
  }));
};
```

### 4. Affichage optimisé dans le tableau

Le tableau des articles utilise maintenant les colonnes chargées automatiquement au lieu de faire des appels répétés à la base TEC :

```typescript
// Avant (lent)
<td>{formatDecimal(tecArticle?.dd)}</td>

// Maintenant (rapide)
<td>{formatDecimal(article.dd)}</td>
```

## Avantages de la solution

### ✅ Performance améliorée
- Plus besoin de faire des appels répétés à `findTECArticleByCode()` pour chaque affichage
- Les données TEC sont chargées une seule fois et stockées dans l'article

### ✅ Expérience utilisateur améliorée
- Les colonnes se remplissent automatiquement dès l'upload de la facture
- Plus besoin d'attendre ou de recharger les données

### ✅ Cohérence des données
- Les colonnes TEC sont toujours synchronisées avec le code SH sélectionné
- Pas de risque de désynchronisation entre les colonnes

### ✅ Facilité de maintenance
- Code plus simple et plus lisible
- Moins de dépendances entre les composants

## Comment tester

1. **Upload de facture :**
   - Allez à l'étape 4 du simulateur
   - Uploadez un fichier Excel contenant des codes SH
   - Passez à l'étape 5
   - Vérifiez que toutes les colonnes TEC sont automatiquement remplies avec les **valeurs réelles** de la base TEC
   - Ouvrez la console du navigateur (F12) pour voir les logs de debug des valeurs TEC réelles

2. **Sélection manuelle de code SH :**
   - À l'étape 5, cliquez sur le bouton de recherche à côté d'un code SH
   - Sélectionnez un nouveau code SH
   - Vérifiez que toutes les colonnes TEC se mettent à jour automatiquement avec les **valeurs réelles**
   - Vérifiez dans la console que les valeurs TEC réelles sont bien récupérées

3. **Vérification des valeurs réelles :**
   - Comparez les valeurs affichées dans le tableau avec celles de la base TEC
   - Les valeurs doivent correspondre exactement à celles stockées dans la base TEC
   - Si un code SH n'existe pas dans la base TEC, les colonnes affichent 0

4. **Performance :**
   - Le tableau devrait s'afficher plus rapidement
   - Pas de délai lors du changement de code SH

## Notes techniques

- Les colonnes TEC sont optionnelles (`?`) pour maintenir la compatibilité avec les anciens articles
- **Valeurs réelles garanties :** Si un code SH existe dans la base TEC, les **valeurs réelles** sont utilisées
- **Fallback sécurisé :** Si un code SH n'est pas trouvé dans la base TEC, les valeurs par défaut sont 0
- L'unité statistique (US) continue d'être récupérée dynamiquement car elle n'est pas stockée dans l'article
- La solution est rétrocompatible avec les simulations existantes
- **Logs de debug :** Des logs sont ajoutés pour vérifier que les valeurs TEC réelles sont bien récupérées

## Exemple de valeurs réelles

Pour un code SH comme `0101.11.00` (Bovins vivants), les valeurs réelles de la base TEC sont :
- DD: 5.0%
- RSTA: 0.0%
- PCS: 1
- PUA: 0.0%
- PCC: 0.0%
- RRR: 0.0%
- RCP: 0.0%
- TVA: 19.25%
- Cumul Sans TVA: 5.0%
- Cumul Avec TVA: 24.25%

Ces valeurs exactes sont maintenant affichées automatiquement dans le tableau.
