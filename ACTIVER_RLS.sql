-- ============================================
-- ACTIVATION RLS SUR TOUTE LA BASE DE DONNÉES
-- ============================================
-- Ce script active Row Level Security (RLS) sur toutes les tables
-- et crée toutes les politiques nécessaires
-- ============================================

-- ============================================
-- 1. ACTIVER RLS SUR TOUTES LES TABLES
-- ============================================

ALTER TABLE IF EXISTS users_app ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS simulations ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS order_validations ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS credit_pools ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS credit_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS admin_users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. SUPPRIMER LES ANCIENNES POLITIQUES (si elles existent)
-- ============================================

-- users_app
DROP POLICY IF EXISTS "Users can view own profile" ON users_app;
DROP POLICY IF EXISTS "Users can update own profile" ON users_app;
DROP POLICY IF EXISTS "Allow trigger to insert profiles" ON users_app;

-- simulations
DROP POLICY IF EXISTS "Users can view own simulations" ON simulations;
DROP POLICY IF EXISTS "Users can insert own simulations" ON simulations;
DROP POLICY IF EXISTS "Users can update own simulations" ON simulations;
DROP POLICY IF EXISTS "Users can delete own simulations" ON simulations;

-- orders
DROP POLICY IF EXISTS "Users can view own orders" ON orders;
DROP POLICY IF EXISTS "Users can insert own orders" ON orders;
DROP POLICY IF EXISTS "Users can update own orders" ON orders;

-- order_validations
DROP POLICY IF EXISTS "Admins and cashiers can view validations" ON order_validations;
DROP POLICY IF EXISTS "Admins and cashiers can insert validations" ON order_validations;

-- credit_pools
DROP POLICY IF EXISTS "Users can view own credit pools" ON credit_pools;
DROP POLICY IF EXISTS "Users can insert own credit pools" ON credit_pools;
DROP POLICY IF EXISTS "Users can update own credit pools" ON credit_pools;

-- credit_usage
DROP POLICY IF EXISTS "Users can view own credit usage" ON credit_usage;
DROP POLICY IF EXISTS "Users can insert own credit usage" ON credit_usage;

-- settings
DROP POLICY IF EXISTS "Users can view own settings" ON settings;
DROP POLICY IF EXISTS "Users can update own settings" ON settings;
DROP POLICY IF EXISTS "Users can insert own settings" ON settings;

-- admin_users
DROP POLICY IF EXISTS "Admins can view all admin users" ON admin_users;
DROP POLICY IF EXISTS "Admins can insert admin users" ON admin_users;
DROP POLICY IF EXISTS "Admins can update admin users" ON admin_users;

-- ============================================
-- 3. CRÉER LES POLITIQUES RLS
-- ============================================

-- ============================================
-- POLITIQUES POUR users_app
-- ============================================

-- Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT USING (auth.uid() = id);

-- Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE USING (auth.uid() = id);

-- IMPORTANT: Permettre au trigger SECURITY DEFINER de créer le profil
-- Le trigger s'exécute avec les permissions du créateur de la fonction
-- donc il contourne RLS, mais on peut aussi ajouter une politique explicite
-- pour les cas où le trigger ne fonctionne pas
CREATE POLICY "Allow service role to insert profiles" ON users_app
  FOR INSERT 
  WITH CHECK (
    -- Permettre l'insertion si c'est pour l'utilisateur authentifié
    auth.uid() = id
    OR
    -- Permettre au trigger/service role d'insérer
    auth.jwt() ->> 'role' = 'service_role'
  );

-- ============================================
-- POLITIQUES POUR simulations
-- ============================================

CREATE POLICY "Users can view own simulations" ON simulations
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own simulations" ON simulations
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own simulations" ON simulations
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own simulations" ON simulations
  FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR orders
-- ============================================

CREATE POLICY "Users can view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own orders" ON orders
  FOR UPDATE USING (auth.uid() = user_id);

-- Les admins peuvent voir toutes les commandes
CREATE POLICY "Admins can view all orders" ON orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- Les admins peuvent mettre à jour toutes les commandes
CREATE POLICY "Admins can update all orders" ON orders
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- ============================================
-- POLITIQUES POUR order_validations
-- ============================================

CREATE POLICY "Admins and cashiers can view validations" ON order_validations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role IN ('admin', 'cashier') AND is_active = true
    )
  );

CREATE POLICY "Admins and cashiers can insert validations" ON order_validations
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role IN ('admin', 'cashier') AND is_active = true
    )
  );

-- Les utilisateurs peuvent voir les validations de leurs propres commandes
CREATE POLICY "Users can view own order validations" ON order_validations
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.id = order_validations.order_id
      AND orders.user_id = auth.uid()
    )
  );

-- ============================================
-- POLITIQUES POUR credit_pools
-- ============================================

CREATE POLICY "Users can view own credit pools" ON credit_pools
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own credit pools" ON credit_pools
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own credit pools" ON credit_pools
  FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR credit_usage
-- ============================================

CREATE POLICY "Users can view own credit usage" ON credit_usage
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own credit usage" ON credit_usage
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR settings
-- ============================================

CREATE POLICY "Users can view own settings" ON settings
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON settings
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own settings" ON settings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR admin_users
-- ============================================

-- Les admins peuvent voir tous les admins
CREATE POLICY "Admins can view all admin users" ON admin_users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- Les admins peuvent créer de nouveaux admins
CREATE POLICY "Admins can insert admin users" ON admin_users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- Les admins peuvent mettre à jour les admins
CREATE POLICY "Admins can update admin users" ON admin_users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- ============================================
-- 4. VÉRIFICATION
-- ============================================

-- Vérifier que RLS est activé sur toutes les tables
DO $$
DECLARE
  table_name TEXT;
  rls_enabled BOOLEAN;
BEGIN
  FOR table_name IN 
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'public' 
    AND tablename IN (
      'users_app', 'simulations', 'orders', 'order_validations',
      'credit_pools', 'credit_usage', 'settings', 'admin_users'
    )
  LOOP
    SELECT relrowsecurity INTO rls_enabled
    FROM pg_class
    WHERE relname = table_name;
    
    IF rls_enabled THEN
      RAISE NOTICE '✅ RLS activé sur: %', table_name;
    ELSE
      RAISE WARNING '❌ RLS NON activé sur: %', table_name;
    END IF;
  END LOOP;
END $$;

-- Afficher toutes les politiques créées
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
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================
-- FIN DU SCRIPT
-- ============================================
-- Après l'exécution, toutes les tables auront RLS activé
-- et toutes les politiques seront en place
-- ============================================





