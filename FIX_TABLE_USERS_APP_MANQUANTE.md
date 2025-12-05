# 🔧 Solution - Table users_app manquante ou profil utilisateur introuvable

## ❌ Problème identifié

D'après les logs, le problème est :
1. ✅ La connexion Supabase Auth fonctionne (SIGNED_IN)
2. ❌ Le profil utilisateur n'existe pas dans `users_app` (erreur 404)
3. ❌ La création automatique du profil échoue aussi (erreur 404)

## 🔍 Diagnostic

### Erreurs observées :
- `Failed to load resource: the server responded with a status of 404`
- `Erreur lors de la récupération du profil`
- `Erreur lors de la création manuelle du profil`

### Causes possibles :
1. **La table `users_app` n'existe pas** dans Supabase
2. **Les politiques RLS bloquent l'accès** à la table
3. **Le trigger de création automatique ne fonctionne pas**

## ✅ Solutions

### Solution 1 : Vérifier que la table users_app existe

1. Allez dans **Supabase Dashboard** > **Table Editor**
2. Cherchez la table `users_app`
3. Si elle n'existe pas → Exécutez le schéma SQL (Solution 2)

### Solution 2 : Exécuter le schéma SQL complet

1. Allez dans **Supabase Dashboard** > **SQL Editor**
2. Ouvrez le fichier `SUPABASE_SCHEMA.sql`
3. Copiez-collez le contenu dans SQL Editor
4. Exécutez le script (Run/Execute)
5. Vérifiez que la table `users_app` a été créée

### Solution 3 : Créer le profil utilisateur manuellement

Si la table existe mais le profil n'existe pas :

1. Allez dans **Supabase Dashboard** > **SQL Editor**
2. Exécutez d'abord cette requête pour récupérer l'ID utilisateur :

```sql
SELECT 
  id,
  email,
  raw_user_meta_data->>'name' as name
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';
```

3. Ensuite, créez le profil avec cet ID :

```sql
INSERT INTO users_app (
  id,
  email,
  name,
  plan,
  remaining_credits,
  total_credits
)
VALUES (
  'ID_UTILISATEUR_ICI',  -- Remplacez par l'ID de l'ÉTAPE 2
  'diallombemba7@gmail.com',
  'Nom Utilisateur',  -- Ou depuis raw_user_meta_data
  'free',
  3,
  3
);
```

### Solution 4 : Utiliser le script automatique

J'ai créé le fichier `FIX_CREER_PROFIL_UTILISATEUR.sql` qui :
- Vérifie que la table existe
- Récupère automatiquement l'ID utilisateur
- Crée le profil avec les bonnes valeurs

**Exécutez ce script dans Supabase SQL Editor.**

### Solution 5 : Vérifier les politiques RLS

Si la table existe mais vous ne pouvez pas y accéder :

1. Allez dans **Supabase Dashboard** > **Table Editor** > `users_app`
2. Cliquez sur **"Policies"** ou **"RLS"**
3. Vérifiez que les politiques suivantes existent :
   - "Users can view own profile"
   - "Users can insert own profile"
   - "Users can update own profile"

Si les politiques n'existent pas, exécutez `FIX_RLS_PROFIL_CONNEXION.sql` ou `CREATE_MISSING_TABLES_RLS.sql`.

## 📝 Étapes de résolution complète

1. **Vérifier que la table existe** :
   ```sql
   SELECT EXISTS (
     SELECT FROM information_schema.tables 
     WHERE table_schema = 'public' 
     AND table_name = 'users_app'
   );
   ```

2. **Si la table n'existe pas** → Exécutez `SUPABASE_SCHEMA.sql`

3. **Si la table existe** → Exécutez `FIX_CREER_PROFIL_UTILISATEUR.sql`

4. **Vérifier les politiques RLS** → Exécutez `CREATE_MISSING_TABLES_RLS.sql` si nécessaire

5. **Redémarrer l'application** et essayer de se connecter

## 🆘 Si rien ne fonctionne

1. Vérifiez les logs Supabase : Dashboard > Logs > Postgres Logs
2. Vérifiez que le schéma SQL complet a été exécuté
3. Vérifiez que les triggers existent : Database > Triggers
4. Vérifiez que les fonctions existent : Database > Functions

