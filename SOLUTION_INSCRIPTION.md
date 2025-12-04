# 🔧 Solution - Erreur "Database error saving new user"

## ❌ Problème

L'erreur `AuthApiError: Database error saving new user` signifie que le trigger SQL qui crée automatiquement le profil utilisateur dans la table `users_app` échoue.

## ✅ Solution en 3 étapes

### ÉTAPE 1 : Vérifier que le schéma de base existe

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Ouvrez **SQL Editor**
4. Exécutez cette requête pour vérifier :

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'users_app';
```

**Si la table n'existe pas** :
- Copiez tout le contenu de `SUPABASE_SCHEMA.sql`
- Collez-le dans SQL Editor
- Cliquez sur **Run** (ou F5)

### ÉTAPE 2 : Corriger le trigger

1. Dans Supabase SQL Editor, copiez-collez le contenu de `FIX_TRIGGER.sql`
2. Cliquez sur **Run**

Ce script va :
- Supprimer l'ancien trigger défaillant
- Recréer la fonction avec une meilleure gestion d'erreurs
- Vérifier que la table existe
- Configurer les permissions correctement

### ÉTAPE 3 : Vérifier les permissions RLS

Le trigger doit pouvoir insérer dans `users_app`. Vérifiez que :

1. Allez dans **Table Editor** > `users_app`
2. Cliquez sur **Policies** (ou **RLS**)
3. Vérifiez qu'il n'y a **PAS** de politique INSERT qui bloque

**Si nécessaire**, ajoutez cette politique temporaire pour permettre au trigger de fonctionner :

```sql
-- Permettre au trigger SECURITY DEFINER d'insérer
-- Cette politique n'est normalement pas nécessaire car SECURITY DEFINER contourne RLS
-- Mais si le problème persiste, ajoutez-la :

CREATE POLICY "Allow trigger to insert profiles" ON users_app
  FOR INSERT 
  WITH CHECK (true);
```

**⚠️ ATTENTION** : Cette politique est très permissive. Supprimez-la après avoir résolu le problème si vous l'avez ajoutée.

## 🔍 Vérification

Après avoir exécuté `FIX_TRIGGER.sql`, testez la création d'un compte :

1. Redémarrez votre application (`npm run dev`)
2. Essayez de créer un compte
3. Vérifiez dans Supabase **Table Editor** > `users_app` qu'un profil a été créé

## 📋 Checklist de dépannage

- [ ] Le schéma `SUPABASE_SCHEMA.sql` a été exécuté
- [ ] Le script `FIX_TRIGGER.sql` a été exécuté
- [ ] La table `users_app` existe
- [ ] La fonction `create_user_profile()` existe (Database > Functions)
- [ ] Le trigger `on_auth_user_created` existe (Database > Triggers)
- [ ] RLS est activé sur `users_app`
- [ ] Les politiques RLS permettent au trigger de fonctionner

## 🚨 Si le problème persiste

1. **Vérifiez les logs Supabase** :
   - Allez dans **Logs** > **Postgres Logs**
   - Cherchez les erreurs liées à `create_user_profile`

2. **Testez manuellement la fonction** :
   ```sql
   -- Créer un utilisateur de test dans auth.users (via l'interface Supabase)
   -- Puis vérifier si le trigger fonctionne
   SELECT * FROM users_app WHERE email = 'test@example.com';
   ```

3. **Créez le profil manuellement** (solution temporaire) :
   ```sql
   -- Récupérez l'ID de l'utilisateur depuis auth.users
   INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
   VALUES (
     'user-id-from-auth-users',
     'user@example.com',
     'Nom Utilisateur',
     'free',
     3,
     3
   );
   ```

## 📝 Note sur Stripe

L'erreur Stripe (`Please call Stripe() with your publishable key`) est séparée. Pour la corriger :

1. Ajoutez dans votre `.env` :
   ```env
   VITE_STRIPE_PUBLISHABLE_KEY=pk_test_votre_cle_ici
   ```
   
   Ou laissez vide si vous n'utilisez pas Stripe pour l'instant (l'application fonctionnera sans).





