# 🔧 Guide : Correction de l'erreur "Rendered more hooks" et migration localStorage → Supabase

## ✅ Corrections appliquées

### 1. Erreur "Rendered more hooks than during the previous render"
**Problème** : Dans `SettingsPage.tsx`, il y avait un `return` conditionnel avec des hooks (`useState`, `useEffect`) avant d'autres hooks, ce qui violait la règle des hooks de React.

**Solution** : Tous les hooks (`useState`, `useEffect`) ont été déplacés avant le `return` conditionnel. Les hooks doivent toujours être appelés dans le même ordre à chaque rendu.

**Fichier modifié** : `src/components/SettingsPage.tsx`

### 2. Tables Supabase manquantes créées
**Problème** : Plusieurs données étaient encore stockées dans `localStorage` au lieu de Supabase.

**Solution** : Script SQL créé pour ajouter les tables manquantes :
- `actors` : Acteurs (fournisseurs, clients, etc.) - **privé par utilisateur**
- `invoice_history` : Historique des factures - **privé par utilisateur**
- `admin_decision_criteria` : Critères de décision admin - **privé ou global**
- `reference_data` : Données de référence (TEC, VOC, TarifPORT) - **partagées entre tous**

**Fichier créé** : `CREATE_MISSING_TABLES_RLS.sql`

## 📋 Actions à effectuer

### Étape 1 : Exécuter le script SQL
1. Ouvrez votre projet Supabase
2. Allez dans **SQL Editor**
3. Copiez-collez le contenu de `CREATE_MISSING_TABLES_RLS.sql`
4. Cliquez sur **Run**

### Étape 2 : Vérifier les politiques RLS
Après avoir exécuté le script, vérifiez que les politiques RLS sont actives :

```sql
SELECT 
  tablename,
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname IN ('actors', 'invoice_history', 'admin_decision_criteria', 'reference_data');
```

## 🔄 Fichiers à migrer (localStorage → Supabase)

Les fichiers suivants utilisent encore `localStorage` et doivent être migrés vers Supabase :

### Priorité haute (données utilisateur)
1. ✅ `SettingsPage.tsx` - TEC, VOC, TarifPORT (données de référence, peuvent rester en localStorage temporairement)
2. ⚠️ `SimulatorForm.tsx` - Historique des factures → `invoice_history`
3. ⚠️ `AdminDecisionsSettings.tsx` - Critères de décision → `admin_decision_criteria`
4. ⚠️ `TECManagementPage.tsx` - Articles TEC → `reference_data` (type='tec')
5. ⚠️ `TarifPORTManagementPage.tsx` - Produits TarifPORT → `reference_data` (type='tarifport')

### Priorité moyenne (données système)
6. ⚠️ `paymentUtils.ts` - Paiements, validations, sessions caissier
7. ⚠️ `adminDecisions.ts` - Critères de décision
8. ⚠️ `salesReportUtils.ts` - Sessions caissier
9. ⚠️ `stripeWebhooks.ts` - Données utilisateur et paiements

## 🔒 Politiques RLS appliquées

### Actors (Acteurs)
- ✅ Les utilisateurs ne voient que leurs propres acteurs
- ✅ Les utilisateurs peuvent créer/modifier/supprimer leurs propres acteurs

### Invoice History (Historique des factures)
- ✅ Les utilisateurs ne voient que leur propre historique
- ✅ Les utilisateurs peuvent créer/modifier/supprimer leur propre historique

### Admin Decision Criteria (Critères de décision)
- ✅ Les utilisateurs voient leurs propres critères + les critères globaux
- ✅ Les utilisateurs peuvent créer/modifier/supprimer leurs propres critères
- ✅ Les admins peuvent gérer les critères globaux

### Reference Data (Données de référence)
- ✅ Tous les utilisateurs authentifiés peuvent voir les données de référence (partagées)
- ✅ Seuls les admins peuvent créer/modifier/supprimer les données de référence

## 📝 Notes importantes

1. **Données de référence (TEC, VOC, TarifPORT)** : Ces données sont partagées entre tous les utilisateurs. Elles peuvent rester temporairement en `localStorage` pour des raisons de performance, mais devraient idéalement être dans Supabase pour la cohérence.

2. **Historique des factures** : Doit absolument être migré vers Supabase car c'est une donnée utilisateur critique.

3. **Acteurs** : Doit absolument être migré vers Supabase car chaque utilisateur doit avoir ses propres acteurs privés.

4. **Critères de décision admin** : Peuvent être globaux (partagés) ou privés par utilisateur.

## 🚀 Prochaines étapes

1. ✅ Exécuter `CREATE_MISSING_TABLES_RLS.sql` dans Supabase
2. ⏳ Créer les services Supabase pour `actors`, `invoice_history`, `admin_decision_criteria`, `reference_data`
3. ⏳ Remplacer `localStorage` par les appels Supabase dans les fichiers listés ci-dessus
4. ⏳ Tester que chaque utilisateur ne voit que ses propres données

## 🔍 Vérification

Pour vérifier que les politiques RLS fonctionnent correctement :

1. Connectez-vous avec un utilisateur A
2. Créez des acteurs, factures, etc.
3. Déconnectez-vous et connectez-vous avec un utilisateur B
4. Vérifiez que l'utilisateur B ne voit pas les données de l'utilisateur A

