# Guide : Restauration de la version fonctionnelle d'origine

## Objectif

Restaurer l'application à son état fonctionnel d'origine, avant les modifications liées aux admins et caissiers. À cette version, le système fonctionnait correctement.

## Problème

Après avoir essayé d'attribuer un profil caissier à un utilisateur, plusieurs problèmes sont apparus :
- Erreur 500 lors de la connexion
- Récursion infinie dans les politiques RLS
- Conflits entre les politiques RLS
- Problèmes de chargement du profil

## Solution : Restauration à la version d'origine

### Étape 1 : Exécuter le script de restauration

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`RESTAURER_VERSION_FONCTIONNELLE.sql`**
3. Vérifiez qu'il n'y a **pas d'erreur** dans les résultats

Ce script va :
- ✅ Recréer le trigger pour la création automatique de profil
- ✅ Supprimer **TOUTES** les politiques RLS existantes
- ✅ Recréer **UNIQUEMENT** les 3 politiques de base :
  1. "Users can view own profile" (SELECT)
  2. "Users can update own profile" (UPDATE)
  3. "Allow trigger to insert profiles" (INSERT)
- ✅ Supprimer les fonctions problématiques (`is_user_admin`, etc.)
- ✅ Vérifier que tout est correctement configuré

### Étape 2 : Vérifier les résultats

Après avoir exécuté le script, vous devriez voir :

1. **RLS Status** : ✅ Activé (mais pas forcé)
2. **Politiques créées** (uniquement 3) :
   - ✅ "Users can view own profile" (SELECT) - `auth.uid() = id`
   - ✅ "Users can update own profile" (UPDATE) - `auth.uid() = id`
   - ✅ "Allow trigger to insert profiles" (INSERT) - `WITH CHECK (true)`
3. **Trigger** : ✅ Activé
4. **Fonction** : ✅ Security Definer

**IMPORTANT** : Il ne doit **PAS** y avoir de politique "Admins can view all users".

### Étape 3 : Tester la connexion

1. **Déconnectez-vous** complètement de l'application
2. **Videz le cache du navigateur** (Ctrl+Shift+Delete)
3. **Fermez complètement le navigateur**
4. **Rouvrez le navigateur** et allez sur l'application
5. **Testez la connexion** avec un compte utilisateur normal
6. **Testez la création d'un nouveau compte**

Tout devrait fonctionner normalement.

## Ce qui est restauré

### ✅ Fonctionnalités restaurées

- ✅ Connexion fonctionnelle
- ✅ Création de compte fonctionnelle
- ✅ Chargement du profil fonctionnel
- ✅ Pas d'erreur 500
- ✅ Pas de récursion infinie
- ✅ Trigger de création de profil fonctionnel

### ❌ Fonctionnalités supprimées (temporairement)

- ❌ Les admins ne peuvent plus voir tous les utilisateurs via `users_app`
- ❌ Les politiques RLS pour les admins ont été supprimées
- ❌ Les fonctions `is_user_admin()` et `is_user_cashier()` ont été supprimées

## Impact sur les fonctionnalités admin/caissier

### Ce qui fonctionne toujours

- ✅ Les admins peuvent toujours se connecter (ils sont des utilisateurs normaux dans `users_app`)
- ✅ La table `admin_users` existe toujours et peut être utilisée séparément
- ✅ Les fonctionnalités admin/caissier dans l'application peuvent toujours fonctionner
- ✅ Mais elles doivent utiliser `admin_users` directement, pas via `users_app`

### Ce qui ne fonctionne plus

- ❌ Les admins ne peuvent plus voir tous les utilisateurs via une politique RLS sur `users_app`
- ❌ La recherche d'utilisateurs par les admins via `users_app` ne fonctionnera pas
- ❌ Les pages de gestion des caissiers qui utilisent `users_app` peuvent ne pas fonctionner

## Si vous avez besoin des fonctionnalités admin/caissier

Si vous avez besoin des fonctionnalités admin/caissier plus tard, vous pouvez :

1. **Utiliser des fonctions SECURITY DEFINER** pour éviter la récursion :
   - Créer `is_user_admin()` avec `SECURITY DEFINER`
   - Utiliser cette fonction dans les politiques RLS
   - Voir `FIX_ERREUR_500_RECURSION.sql` pour un exemple

2. **Créer des vues séparées** pour les admins :
   - Créer une vue `admin_users_view` avec `SECURITY DEFINER`
   - Les admins utilisent cette vue au lieu de `users_app` directement

3. **Utiliser des requêtes directes** dans le code :
   - Les admins peuvent faire des requêtes directes à `admin_users`
   - Sans passer par les politiques RLS de `users_app`

## Vérifications

### Vérifier que seules les 3 politiques de base existent

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition USING"
FROM pg_policies
WHERE tablename = 'users_app'
ORDER BY policyname;
```

**Vous devriez voir UNIQUEMENT** :
- ✅ "Allow trigger to insert profiles" (INSERT)
- ✅ "Users can update own profile" (UPDATE)
- ✅ "Users can view own profile" (SELECT)

**Vous ne devriez PAS voir** :
- ❌ "Admins can view all users"

### Vérifier que les fonctions problématiques ont été supprimées

```sql
SELECT proname 
FROM pg_proc 
WHERE proname IN ('is_user_admin', 'is_user_cashier');
```

**Résultat attendu** : Aucune ligne (les fonctions ont été supprimées)

## Prévention

Pour éviter ce problème à l'avenir :

1. **Testez toujours** les modifications RLS sur un environnement de test
2. **Évitez les références circulaires** dans les politiques RLS
3. **Utilisez des fonctions SECURITY DEFINER** si vous devez référencer d'autres tables protégées par RLS
4. **Conservez une copie** des politiques RLS qui fonctionnent

## Si le problème persiste

Si après avoir exécuté le script le problème persiste :

1. **Vérifiez que seules les 3 politiques de base existent** (voir requête ci-dessus)
2. **Vérifiez que RLS n'est pas forcé** :
   ```sql
   SELECT relforcerowsecurity FROM pg_class WHERE relname = 'users_app';
   -- Doit retourner false
   ```
3. **Vérifiez que le trigger est actif** :
   ```sql
   SELECT tgenabled FROM pg_trigger WHERE tgname = 'on_auth_user_created';
   -- Doit retourner 'O'
   ```
4. **Vérifiez les logs Supabase** pour voir les erreurs exactes

## Retour en arrière

Si vous avez besoin de revenir à cette version fonctionnelle plus tard :

1. Exécutez simplement `RESTAURER_VERSION_FONCTIONNELLE.sql` à nouveau
2. Toutes les modifications seront annulées
3. Vous reviendrez à l'état fonctionnel d'origine

