# Guide : Migration des acteurs vers Supabase

## Objectif

Migrer la gestion des acteurs de `localStorage`/`ACTORS_DATABASE` vers Supabase pour que chaque utilisateur ait ses propres acteurs.

## Problème actuel

La page `ActorsPage` utilise actuellement :
- `ACTORS_DATABASE` : Un tableau statique dans `src/data/actors.ts`
- Les données ne sont pas persistées dans Supabase
- Tous les utilisateurs voient les mêmes acteurs

## Solution : Migration vers Supabase

### Étape 1 : Créer/modifier la table actors dans Supabase

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`CREATE_TABLE_ACTORS.sql`**
3. Vérifiez qu'il n'y a **pas d'erreur** dans les résultats

Ce script va :
- ✅ Créer la table `actors` avec la structure correcte (nom, adresse, telephone, etc.)
- ✅ Ajouter `user_id` pour que chaque utilisateur ait ses propres acteurs
- ✅ Créer les index pour améliorer les performances
- ✅ Créer un trigger pour mettre à jour `updated_at` automatiquement
- ✅ Activer RLS avec les politiques appropriées

### Étape 2 : Vérifier les résultats

Après avoir exécuté le script, vous devriez voir :

1. **Table actors** : ✅ Existe avec les colonnes : id, user_id, nom, adresse, telephone, email, type, zone, pays
2. **RLS Status** : ✅ Activé
3. **Politiques créées** :
   - ✅ "Users can view own actors" (SELECT)
   - ✅ "Users can insert own actors" (INSERT)
   - ✅ "Users can update own actors" (UPDATE)
   - ✅ "Users can delete own actors" (DELETE)

### Étape 3 : Tester la migration

1. **Rafraîchissez la page** de l'application (F5)
2. **Allez sur la page des acteurs**
3. **Vérifiez que** :
   - La page se charge sans erreur
   - Vous pouvez ajouter un nouvel acteur
   - Vous pouvez modifier un acteur existant
   - Vous pouvez supprimer un acteur
   - Les acteurs sont persistés après rafraîchissement

## Modifications apportées au code

### 1. Nouveau service Supabase

**Fichier créé** : `src/services/supabase/actorDataService.ts`

Ce service fournit :
- `getActorsByUser(userId)` : Récupérer tous les acteurs d'un utilisateur
- `getActorById(id)` : Récupérer un acteur par ID
- `createActor(userId, actor)` : Créer un nouvel acteur
- `updateActor(id, updates)` : Mettre à jour un acteur
- `deleteActor(id)` : Supprimer un acteur

### 2. Composant ActorsPage modifié

**Fichier modifié** : `src/components/Actors/ActorsPage.tsx`

**Changements** :
- ✅ Utilise `useAuth()` pour obtenir l'utilisateur connecté
- ✅ Charge les acteurs depuis Supabase au montage du composant
- ✅ Utilise `actorDataService` au lieu de `ACTORS_DATABASE`
- ✅ Gère les états de chargement et d'erreur
- ✅ Les opérations (ajout, modification, suppression) sont maintenant asynchrones et utilisent Supabase

## Structure de la table actors

```sql
CREATE TABLE actors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users_app(id) ON DELETE CASCADE,
  nom VARCHAR(255) NOT NULL,
  adresse TEXT NOT NULL,
  telephone VARCHAR(50),
  email VARCHAR(255),
  type VARCHAR(50) NOT NULL CHECK (type IN ('importateur', 'fournisseur', 'transitaire')),
  zone VARCHAR(100),
  pays VARCHAR(2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Politiques RLS

Les politiques RLS garantissent que :
- ✅ Chaque utilisateur ne voit que ses propres acteurs
- ✅ Chaque utilisateur ne peut créer/modifier/supprimer que ses propres acteurs
- ✅ Les données sont sécurisées et isolées par utilisateur

## Migration des données existantes

Si vous avez des acteurs dans `ACTORS_DATABASE` que vous voulez migrer :

1. **Identifiez l'utilisateur** pour lequel vous voulez migrer les acteurs
2. **Exécutez ce script SQL** (remplacez `USER_ID` par l'ID de l'utilisateur) :

```sql
-- Migrer les acteurs depuis ACTORS_DATABASE vers Supabase
-- Remplacez USER_ID par l'ID de l'utilisateur
INSERT INTO actors (user_id, nom, adresse, telephone, email, type, zone, pays)
SELECT 
  'USER_ID'::UUID as user_id,
  nom,
  adresse,
  telephone,
  email,
  type,
  zone,
  pays
FROM (
  VALUES
    ('SARL IMPORT PLUS', 'BP 1234, Douala, Cameroun', '+237 233 42 15 67', 'contact@importplus.cm', 'importateur', NULL, NULL),
    -- Ajoutez les autres acteurs ici
    ...
) AS actors_data(nom, adresse, telephone, email, type, zone, pays);
```

## Vérifications

### Vérifier que la table existe

```sql
SELECT * FROM information_schema.tables 
WHERE table_name = 'actors';
```

### Vérifier les politiques RLS

```sql
SELECT policyname, cmd, qual 
FROM pg_policies 
WHERE tablename = 'actors';
```

### Vérifier les acteurs d'un utilisateur

```sql
-- Remplacez USER_ID par l'ID de l'utilisateur
SELECT * FROM actors WHERE user_id = 'USER_ID';
```

## Avantages de la migration

1. **Persistance** : Les acteurs sont sauvegardés dans Supabase
2. **Isolation** : Chaque utilisateur a ses propres acteurs
3. **Sécurité** : RLS garantit que les utilisateurs ne voient que leurs données
4. **Synchronisation** : Les données sont synchronisées entre tous les appareils
5. **Backup** : Les données sont sauvegardées automatiquement par Supabase

## Si vous avez des problèmes

### Erreur : "Table actors does not exist"

**Solution** : Exécutez `CREATE_TABLE_ACTORS.sql` dans Supabase

### Erreur : "Permission denied" ou erreur RLS

**Solution** : Vérifiez que les politiques RLS sont créées (voir vérifications ci-dessus)

### Les acteurs ne se chargent pas

**Vérifiez** :
1. Que vous êtes bien connecté (`user` n'est pas null)
2. Que la table `actors` existe
3. Que les politiques RLS sont correctement configurées
4. Les logs de la console pour voir les erreurs exactes

## Fichiers modifiés/créés

- ✅ `src/services/supabase/actorDataService.ts` (nouveau)
- ✅ `src/components/Actors/ActorsPage.tsx` (modifié)
- ✅ `CREATE_TABLE_ACTORS.sql` (nouveau)
- ✅ `GUIDE_MIGRATION_ACTEURS_SUPABASE.md` (ce guide)

## Notes importantes

- Les acteurs dans `ACTORS_DATABASE` ne sont plus utilisés
- Chaque utilisateur doit créer ses propres acteurs
- Les acteurs sont maintenant privés par utilisateur (grâce à RLS)
- La structure `ActorData` reste la même, seule la source de données change

