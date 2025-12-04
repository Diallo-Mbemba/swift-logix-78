-- ============================================
-- Script de test pour vérifier la recherche d'utilisateurs
-- ============================================
-- Ce script permet de tester si les admins peuvent voir tous les utilisateurs

-- 1. Vérifier que la politique RLS existe
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE tablename = 'users_app'
  AND policyname = 'Admins can view all users';

-- 2. Vérifier que RLS est activé sur users_app
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'users_app';

-- 3. Compter le nombre total d'utilisateurs (pour référence)
SELECT COUNT(*) as total_users FROM users_app;

-- 4. Tester la requête de recherche (remplacez 'TERME_RECHERCHE' par un terme réel)
-- Cette requête simule ce que fait l'application
-- Note: Cette requête doit être exécutée en étant connecté comme admin
SELECT 
  id,
  email,
  name
FROM users_app
WHERE email ILIKE '%TERME_RECHERCHE%' OR name ILIKE '%TERME_RECHERCHE%'
ORDER BY name ASC
LIMIT 20;

-- 5. Vérifier que l'utilisateur actuel est admin
SELECT 
  auth.uid() as current_user_id,
  EXISTS (
    SELECT 1 FROM admin_users
    WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
  ) as is_admin;

-- 6. Si la politique n'existe pas, exécutez FIX_RLS_ADMIN_VIEW_USERS.sql

