-- ============================================
-- Script pour permettre aux admins de voir tous les utilisateurs
-- ============================================
-- Ce script ajoute une politique RLS pour permettre aux admins de rechercher
-- et voir tous les utilisateurs dans users_app (nécessaire pour créer des caissiers)

-- Supprimer la politique existante si elle existe (pour éviter les conflits)
DROP POLICY IF EXISTS "Admins can view all users" ON users_app;

-- Ajouter une politique pour permettre aux admins de voir tous les utilisateurs
CREATE POLICY "Admins can view all users" ON users_app
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- Les utilisateurs peuvent toujours voir leur propre profil (politique existante)
-- La politique "Users can view own profile" reste active

-- Vérification
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'users_app'
ORDER BY policyname;

