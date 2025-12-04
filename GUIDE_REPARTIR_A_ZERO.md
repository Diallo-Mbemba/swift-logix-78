# Guide : Repartir à zéro avec les politiques RLS

## Objectif

Supprimer **TOUTES** les politiques RLS existantes et repartir de zéro avec une configuration simple et fonctionnelle.

## Pourquoi repartir à zéro ?

Après plusieurs modifications des politiques RLS, il peut y avoir :
- Des conflits entre politiques
- Des récursions infinies
- Des politiques obsolètes ou contradictoires
- Des erreurs 500 difficiles à diagnostiquer

Repartir à zéro permet d'avoir une configuration propre et fonctionnelle.

## Solution : Script de réinitialisation

### Étape 1 : Exécuter le script de réinitialisation

1. Ouvrez le **SQL Editor** dans Supabase
2. Exécutez le fichier **`REPARTIR_A_ZERO_RLS.sql`**
3. Vérifiez qu'il n'y a **pas d'erreur** dans les résultats

Ce script va :
- ✅ Supprimer **TOUTES** les politiques RLS existantes
- ✅ Supprimer les fonctions problématiques (`is_user_admin`, etc.)
- ✅ Désactiver temporairement RLS pour nettoyer
- ✅ Réactiver RLS
- ✅ Recréer le trigger et la fonction de création de profil
- ✅ Recréer **UNIQUEMENT** 3 politiques de base simples :
  1. "Users can view own profile" (SELECT)
  2. "Users can update own profile" (UPDATE)
  3. "Allow trigger to insert profiles" (INSERT)

### Étape 2 : Vérifier les résultats

Après avoir exécuté le script, vous devriez voir :

1. **RLS Status** : ✅ Activé (mais pas forcé)
2. **Politiques créées** (uniquement 3) :
   - ✅ "Users can view own profile" (SELECT) - `auth.uid() = id`
   - ✅ "Users can update own profile" (UPDATE) - `auth.uid() = id`
   - ✅ "Allow trigger to insert profiles" (INSERT) - `WITH CHECK (true)`
3. **Trigger** : ✅ Activé
4. **Fonction** : ✅ Security Definer

**IMPORTANT** : Il ne doit y avoir **QUE 3 politiques**. Aucune autre politique ne doit exister.

### Étape 3 : Tester la connexion

1. **Déconnectez-vous** complètement de l'application
2. **Videz le cache du navigateur** (Ctrl+Shift+Delete)
3. **Fermez complètement le navigateur**
4. **Rouvrez le navigateur** et allez sur l'application
5. **Testez la connexion** avec un compte utilisateur
6. **Testez la création d'un nouveau compte**

Tout devrait fonctionner normalement.

## Configuration finale

### Politiques RLS créées

```sql
-- 1. Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT USING (auth.uid() = id);

-- 2. Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE USING (auth.uid() = id);

-- 3. Le trigger peut créer des profils
CREATE POLICY "Allow trigger to insert profiles" ON users_app
  FOR INSERT WITH CHECK (true);
```

### Ce qui fonctionne

- ✅ Connexion des utilisateurs
- ✅ Création de compte
- ✅ Chargement du profil
- ✅ Mise à jour du profil
- ✅ Trigger de création automatique de profil

### Ce qui ne fonctionne pas (intentionnellement)

- ❌ Les admins ne peuvent pas voir tous les utilisateurs via `users_app`
- ❌ Pas de fonctionnalités spéciales pour les admins/caissiers via RLS

## Vérifications

### Vérifier qu'il n'y a que 3 politiques

```sql
SELECT 
  policyname,
  cmd,
  qual as "Condition USING"
FROM pg_policies
WHERE tablename = 'users_app'
ORDER BY cmd, policyname;
```

**Résultat attendu** : Exactement 3 lignes

### Vérifier que les fonctions problématiques ont été supprimées

```sql
SELECT proname 
FROM pg_proc 
WHERE proname IN ('is_user_admin', 'is_user_cashier');
```

**Résultat attendu** : Aucune ligne

### Vérifier que RLS n'est pas forcé

```sql
SELECT 
  relname,
  relrowsecurity as "RLS Activé",
  relforcerowsecurity as "RLS Forcé"
FROM pg_class
WHERE relname = 'users_app';
```

**Résultat attendu** :
- `relrowsecurity` = `true` (RLS activé)
- `relforcerowsecurity` = `false` (RLS non forcé)

## Si vous avez besoin des fonctionnalités admin/caissier

Si vous avez besoin des fonctionnalités admin/caissier plus tard, vous pouvez :

1. **Utiliser des fonctions SECURITY DEFINER** (recommandé) :
   - Créer `is_user_admin()` avec `SECURITY DEFINER`
   - Utiliser cette fonction dans les politiques RLS
   - Voir `FIX_ERREUR_500_RECURSION.sql` pour un exemple

2. **Créer des vues séparées** :
   - Créer une vue `admin_users_view` avec `SECURITY DEFINER`
   - Les admins utilisent cette vue au lieu de `users_app` directement

3. **Utiliser des requêtes directes dans le code** :
   - Les admins peuvent faire des requêtes directes à `admin_users`
   - Sans passer par les politiques RLS de `users_app`

## Avantages de cette configuration

1. **Simple** : Seulement 3 politiques, faciles à comprendre
2. **Fonctionnelle** : Toutes les fonctionnalités de base fonctionnent
3. **Sans récursion** : Pas de références circulaires
4. **Sans conflit** : Pas de politiques contradictoires
5. **Maintenable** : Facile à modifier ou étendre

## Prévention

Pour éviter les problèmes à l'avenir :

1. **Testez toujours** les modifications RLS sur un environnement de test
2. **Évitez les références circulaires** dans les politiques RLS
3. **Utilisez des fonctions SECURITY DEFINER** si vous devez référencer d'autres tables protégées par RLS
4. **Conservez une copie** des politiques RLS qui fonctionnent
5. **Documentez** chaque politique que vous ajoutez

## Si le problème persiste

Si après avoir exécuté le script le problème persiste :

1. **Vérifiez qu'il n'y a que 3 politiques** (voir requête ci-dessus)
2. **Vérifiez que RLS n'est pas forcé** (voir requête ci-dessus)
3. **Vérifiez que le trigger est actif** :
   ```sql
   SELECT tgenabled FROM pg_trigger WHERE tgname = 'on_auth_user_created';
   -- Doit retourner 'O'
   ```
4. **Vérifiez les logs Supabase** pour voir les erreurs exactes
5. **Vérifiez que votre profil existe** :
   ```sql
   SELECT * FROM users_app WHERE id = 'VOTRE_USER_ID';
   ```

## Retour en arrière

Si vous avez besoin de revenir à cette configuration propre plus tard :

1. Exécutez simplement `REPARTIR_A_ZERO_RLS.sql` à nouveau
2. Toutes les modifications seront annulées
3. Vous reviendrez à cette configuration minimale et fonctionnelle

