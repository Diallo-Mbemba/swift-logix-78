-- ============================================
-- Script pour corriger les politiques RLS pour admin_users
-- ============================================
-- Ce script s'assure que les admins peuvent créer, modifier et supprimer des comptes admin/caissier

-- Supprimer les politiques existantes si elles existent (pour éviter les conflits)
DROP POLICY IF EXISTS "Admins can view all admin users" ON admin_users;
DROP POLICY IF EXISTS "Admins can insert admin users" ON admin_users;
DROP POLICY IF EXISTS "Admins can update admin users" ON admin_users;
DROP POLICY IF EXISTS "Admins can delete admin users" ON admin_users;

-- 1. Politique pour permettre aux admins de voir tous les comptes admin/caissier
CREATE POLICY "Admins can view all admin users" ON admin_users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- 2. Politique pour permettre aux admins de créer des comptes admin/caissier
CREATE POLICY "Admins can insert admin users" ON admin_users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- 3. Politique pour permettre aux admins de modifier les comptes admin/caissier
CREATE POLICY "Admins can update admin users" ON admin_users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- 4. Politique pour permettre aux admins de supprimer les comptes admin/caissier
CREATE POLICY "Admins can delete admin users" ON admin_users
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- Vérification
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE tablename = 'admin_users'
ORDER BY policyname;

-- Vérifier que RLS est activé
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'admin_users';

