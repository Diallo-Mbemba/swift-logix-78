-- ============================================
-- Script de vérification des permissions caissier
-- ============================================
-- Ce script vous aide à diagnostiquer les problèmes de permissions RLS pour les caissiers

-- 1. Vérifier les politiques RLS existantes pour les caissiers
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'orders' 
  AND policyname LIKE '%cashier%' OR policyname LIKE '%Cashier%'
ORDER BY policyname;

-- 2. Vérifier si RLS est activé sur la table orders
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'orders';

-- 3. Vérifier les utilisateurs avec le rôle cashier dans admin_users
SELECT 
  au.id,
  au.user_id,
  au.name,
  au.email,
  au.role,
  au.is_active,
  au.created_at,
  ua.id as user_app_id,
  ua.email as user_app_email
FROM admin_users au
LEFT JOIN users_app ua ON au.user_id = ua.id
WHERE au.role = 'cashier'
ORDER BY au.created_at DESC;

-- 4. Vérifier l'utilisateur actuellement connecté (remplacez 'VOTRE_USER_ID' par l'ID de l'utilisateur)
-- Pour obtenir l'ID de l'utilisateur connecté, utilisez : SELECT auth.uid();
SELECT 
  auth.uid() as current_user_id,
  EXISTS (
    SELECT 1 FROM admin_users
    WHERE user_id = auth.uid() AND role = 'cashier' AND is_active = true
  ) as is_cashier,
  EXISTS (
    SELECT 1 FROM admin_users
    WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
  ) as is_admin;

-- 5. Vérifier une commande spécifique (remplacez 'ORDER_ID' par l'ID de la commande)
-- SELECT * FROM orders WHERE id = 'ORDER_ID';

-- 6. Tester les permissions de lecture (SELECT)
-- Cette requête devrait retourner des résultats si les politiques RLS sont correctes
SELECT COUNT(*) as total_orders_visible
FROM orders
WHERE EXISTS (
  SELECT 1 FROM admin_users
  WHERE user_id = auth.uid() AND role = 'cashier' AND is_active = true
);

-- 7. Si aucune politique n'existe, exécutez le script FIX_RLS_CAISSIER.sql

