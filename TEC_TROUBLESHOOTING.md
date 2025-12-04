# 🔧 Guide de Dépannage - Import TEC

## Problème : Taux cumulés non chargés

### Symptômes
- Les taux cumulés (cumul sans TVA et cumul avec TVA) apparaissent à 0% après l'import
- Les autres taux (DD, RSTA, PCS, etc.) se chargent correctement
- Le message d'import indique des calculs automatiques effectués

### Causes possibles

#### 1. Format des cellules Excel
**Problème :** Les cellules contenant les taux cumulés sont au format "Texte" au lieu de "Nombre"

**Solution :**
1. Ouvrez votre fichier Excel
2. Sélectionnez les colonnes K et L (taux cumulés)
3. Clic droit → "Format de cellule"
4. Choisissez "Nombre" ou "Général"
5. Sauvegardez et réimportez

#### 2. Symboles % dans les cellules
**Problème :** Les valeurs contiennent le symbole % (ex: "5.5%" au lieu de "5.5")

**Solution :**
1. Supprimez tous les symboles % des cellules numériques
2. Utilisez uniquement les valeurs décimales (5.5, 10.25, etc.)

#### 3. Espaces avant/après les valeurs
**Problème :** Des espaces invisibles entourent les valeurs

**Solution :**
1. Utilisez la fonction TRIM() d'Excel pour nettoyer les cellules
2. Ou supprimez manuellement les espaces

#### 4. Séparateur décimal incorrect
**Problème :** Utilisation de la virgule au lieu du point (format français)

**Solution :**
1. Remplacez les virgules par des points : 5,5 → 5.5
2. Ou configurez Excel pour utiliser le point comme séparateur décimal

### Structure attendue du fichier Excel

Le fichier doit contenir **exactement 24 colonnes** dans cet ordre :

| Colonne | Lettre | Contenu | Type |
|---------|--------|---------|------|
| 1 | A | Code SH10 | Texte |
| 2 | B | Désignation | Texte |
| 3 | C | Unité statistique | Texte |
| 4 | D | DD (Droits de douane) | Nombre |
| 5 | E | RSTA | Nombre |
| 6 | F | PCS | Nombre |
| 7 | G | PUA | Nombre |
| 8 | H | PCC | Nombre |
| 9 | I | RRR | Nombre |
| 10 | J | RCP | Nombre |
| **11** | **K** | **Cumul sans TVA** | **Nombre** |
| **12** | **L** | **Cumul avec TVA** | **Nombre** |
| 13 | M | TVA | Nombre |
| 14 | N | Code SH6 | Texte |
| 15 | O | TUB | Texte |
| 16 | P | DUS | Texte |
| 17 | Q | DUD | Texte |
| 18 | R | TCB | Texte |
| 19 | S | TSM | Texte |
| 20 | T | TSB | Texte |
| 21 | U | PSV | Texte |
| 22 | V | TAI | Texte |
| 23 | W | TAB | Texte |
| 24 | X | TUF | Texte |

### Solutions automatiques

Le système inclut maintenant des **calculs automatiques** pour les taux cumulés manquants :

- **Cumul sans TVA** = DD + RSTA + PCS + PUA + PCC
- **Cumul avec TVA** = Cumul sans TVA + TVA

### Vérification après import

1. **Consultez la console** (F12 → Console) pour voir les logs détaillés
2. **Vérifiez les statistiques** affichées après l'import
3. **Exportez les données** pour vérifier les valeurs finales

### Exemple de données correctes

```csv
Code SH,Désignation,US,DD,RSTA,PCS,PUA,PCC,RRR,RCP,Cumul sans TVA,Cumul avec TVA,TVA
8431490000,Machines agricoles,kg,5.0,0.0,1.0,0.0,0.0,0.0,0.0,6.0,25.25,19.25
```

### Contact et support

Si le problème persiste :
1. Vérifiez les logs dans la console du navigateur
2. Exportez vos données pour vérification
3. Contactez l'équipe technique avec le fichier Excel et les logs 