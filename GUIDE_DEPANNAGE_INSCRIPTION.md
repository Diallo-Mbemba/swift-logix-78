# 🔧 Guide de Dépannage - Messages d'Erreur après Inscription

## 📋 Messages d'Erreur Courants et Solutions

### 1. "Database error saving new user"

**Cause** : Le trigger SQL `create_user_profile()` ne fonctionne pas correctement.

**Solutions** :
1. Vérifiez que le trigger existe dans Supabase :
   ```sql
   SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
   ```

2. Vérifiez que la fonction `create_user_profile()` existe :
   ```sql
   SELECT * FROM pg_proc WHERE proname = 'create_user_profile';
   ```

3. Réexécutez le script `FIX_TRIGGER.sql` dans Supabase SQL Editor

4. Vérifiez les politiques RLS pour permettre l'insertion :
   ```sql
   -- Vérifier les politiques
   SELECT * FROM pg_policies WHERE tablename = 'users_app';
   ```

### 2. "Cet email est déjà utilisé"

**Cause** : Un compte existe déjà avec cet email.

**Solutions** :
- Connectez-vous avec cet email au lieu de créer un nouveau compte
- Utilisez un autre email pour créer un nouveau compte

### 3. "Erreur de configuration serveur. Les tables de base de données sont manquantes"

**Cause** : Le schéma SQL n'a pas été exécuté dans Supabase.

**Solutions** :
1. Allez dans Supabase > SQL Editor
2. Exécutez le fichier `SUPABASE_SCHEMA.sql`
3. Vérifiez que toutes les tables sont créées :
   ```sql
   SELECT table_name FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name IN ('users_app', 'simulations', 'orders', 'credit_pools');
   ```

### 4. "Erreur de permissions. Vérifiez les politiques RLS dans Supabase"

**Cause** : Les politiques RLS bloquent la création du profil.

**Solutions** :
1. Vérifiez que RLS est activé :
   ```sql
   SELECT tablename, rowsecurity FROM pg_tables 
   WHERE schemaname = 'public' AND tablename = 'users_app';
   ```

2. Vérifiez les politiques :
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'users_app';
   ```

3. Exécutez `FIX_RLS_BLOCKING.sql` si nécessaire

### 5. "Veuillez confirmer votre email"

**Cause** : Supabase nécessite une confirmation d'email.

**Solutions** :
- **Option 1** : Vérifiez votre boîte de réception et cliquez sur le lien de confirmation
- **Option 2** : Désactivez la confirmation d'email dans Supabase :
  1. Allez dans Authentication > Settings
  2. Décochez "Enable email confirmations"
  3. Cliquez sur Save

### 6. "Erreur de connexion. Vérifiez votre connexion internet"

**Cause** : Problème de réseau ou clés Supabase incorrectes.

**Solutions** :
1. Vérifiez votre connexion internet
2. Vérifiez que les clés Supabase dans `.env` sont correctes :
   ```
   VITE_SUPABASE_URL=https://votre-projet.supabase.co
   VITE_SUPABASE_ANON_KEY=votre_cle_anon
   ```
3. Redémarrez le serveur de développement

## 🔍 Comment Obtenir Plus d'Informations

### Ouvrir la Console du Navigateur

1. Appuyez sur **F12** ou **Ctrl+Shift+I** (Windows) / **Cmd+Option+I** (Mac)
2. Allez dans l'onglet **Console**
3. Cherchez les messages d'erreur en rouge
4. Copiez le message d'erreur complet

### Vérifier les Erreurs Supabase

Dans la console, cherchez :
- Messages commençant par `Erreur Supabase`
- Codes d'erreur comme `PGRST116`, `23505`, etc.
- Messages contenant `AuthApiError` ou `PostgrestError`

## 📝 Checklist de Vérification

Avant de créer un compte, vérifiez :

- [ ] Le fichier `.env` contient les bonnes clés Supabase
- [ ] Le schéma SQL (`SUPABASE_SCHEMA.sql`) a été exécuté
- [ ] Le trigger `on_auth_user_created` existe et est actif
- [ ] La fonction `create_user_profile()` existe
- [ ] Les politiques RLS sont correctement configurées
- [ ] La confirmation d'email est désactivée (en développement) ou activée (en production)

## 🆘 Si Rien Ne Fonctionne

1. **Vérifiez les logs Supabase** :
   - Allez dans Supabase Dashboard > Logs
   - Cherchez les erreurs récentes

2. **Testez directement dans Supabase** :
   ```sql
   -- Tester la création manuelle d'un profil
   INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
   VALUES (
     'test-id-123',
     'test@example.com',
     'Test User',
     'free',
     0,
     0
   );
   ```

3. **Contactez le support** avec :
   - Le message d'erreur complet de la console
   - Les logs Supabase
   - La configuration de votre projet

