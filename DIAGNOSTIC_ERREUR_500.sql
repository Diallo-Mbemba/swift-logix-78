-- ============================================
-- DIAGNOSTIC: Erreur 500 lors de la récupération du profil
-- ============================================
-- Ce script diagnostique les problèmes qui causent l'erreur 500
-- lors de la tentative de récupération du profil utilisateur
-- ============================================

-- 1. Vérifier que le profil existe pour l'utilisateur
-- Remplacez 'dab872d3-6e7f-4980-92b7-70cd5ae246b5' par votre ID utilisateur
SELECT 
  'Vérification du profil' as test,
  id,
  email,
  name,
  plan,
  remaining_credits,
  total_credits,
  created_at,
  updated_at
FROM users_app
WHERE id = 'dab872d3-6e7f-4980-92b7-70cd5ae246b5';

-- 2. Vérifier que l'utilisateur existe dans auth.users
SELECT 
  'Vérification auth.users' as test,
  id,
  email,
  created_at
FROM auth.users
WHERE id = 'dab872d3-6e7f-4980-92b7-70cd5ae246b5';

-- 3. Vérifier toutes les politiques RLS sur users_app
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK",
  CASE 
    WHEN cmd = 'SELECT' THEN '✅ SELECT'
    WHEN cmd = 'INSERT' THEN '✅ INSERT'
    WHEN cmd = 'UPDATE' THEN '✅ UPDATE'
    WHEN cmd = 'DELETE' THEN '✅ DELETE'
    ELSE cmd
  END as "Type"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY cmd, policyname;

-- 4. Vérifier que RLS est activé
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status",
  CASE 
    WHEN relforcerowsecurity THEN '✅ Forcé'
    ELSE '❌ Non forcé'
  END as "RLS Forcé"
FROM pg_class
WHERE relname = 'users_app';

-- 5. Vérifier les permissions sur la table
SELECT 
  grantee,
  privilege_type,
  is_grantable
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND table_name = 'users_app'
ORDER BY grantee, privilege_type;

-- 6. Tester la fonction auth.uid() (doit être exécuté en tant qu'utilisateur authentifié)
-- Note: Cette requête ne fonctionnera que dans le contexte d'un utilisateur authentifié
-- SELECT 
--   'Test auth.uid()' as test,
--   auth.uid() as current_user_id,
--   CASE 
--     WHEN auth.uid() IS NOT NULL THEN '✅ auth.uid() fonctionne'
--     ELSE '❌ auth.uid() retourne NULL'
--   END as status;

-- 7. Vérifier s'il y a des contraintes ou triggers qui pourraient causer des problèmes
SELECT 
  conname as "Contrainte",
  contype as "Type",
  CASE 
    WHEN contype = 'p' THEN 'Primary Key'
    WHEN contype = 'f' THEN 'Foreign Key'
    WHEN contype = 'u' THEN 'Unique'
    WHEN contype = 'c' THEN 'Check'
    ELSE contype::text
  END as "Description"
FROM pg_constraint
WHERE conrelid = 'users_app'::regclass;

-- 8. Vérifier les triggers sur users_app
SELECT 
  tgname as "Trigger Name",
  CASE 
    WHEN tgenabled = 'O' THEN '✅ Activé'
    WHEN tgenabled = 'D' THEN '❌ Désactivé'
    ELSE tgenabled
  END as "Status",
  tgtype::text as "Type"
FROM pg_trigger
WHERE tgrelid = 'users_app'::regclass
AND tgname NOT LIKE 'RI_%'; -- Exclure les triggers de foreign key

-- 9. Vérifier la structure de la table users_app
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'users_app'
ORDER BY ordinal_position;

-- 10. Vérifier s'il y a des index qui pourraient causer des problèmes
SELECT 
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename = 'users_app';

-- ============================================
-- RÉSULTATS ATTENDUS
-- ============================================
-- 1. Le profil doit exister dans users_app avec l'ID 'dab872d3-6e7f-4980-92b7-70cd5ae246b5'
-- 2. L'utilisateur doit exister dans auth.users avec le même ID
-- 3. Il doit y avoir au moins 2 politiques SELECT :
--    - "Users can view own profile" avec USING (auth.uid() = id)
--    - "Admins can view all users"
-- 4. RLS doit être activé
-- 5. Les permissions doivent être accordées à authenticated, anon, service_role

-- ============================================
-- SI LE PROFIL N'EXISTE PAS
-- ============================================
-- Si la requête #1 ne retourne aucun résultat, créez le profil manuellement :
-- 
-- INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
-- VALUES (
--   'dab872d3-6e7f-4980-92b7-70cd5ae246b5',
--   'EMAIL_DE_L_UTILISATEUR@example.com',
--   'Nom Utilisateur',
--   'free',
--   3,
--   3
-- );

-- ============================================
-- SI LES POLITIQUES NE SONT PAS CORRECTES
-- ============================================
-- Si la requête #3 ne montre pas les bonnes politiques, exécutez :
-- FIX_PROFIL_COMPLET.sql

