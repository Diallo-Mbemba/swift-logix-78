-- ============================================
-- Script pour permettre aux admins de créer des pools de crédits
-- ============================================
-- Ce script ajoute une politique RLS pour permettre aux admins de créer
-- des pools de crédits pour n'importe quel utilisateur lors de l'autorisation d'une commande

-- Supprimer la politique existante si elle existe (pour éviter les conflits)
DROP POLICY IF EXISTS "Admins can insert credit pools for any user" ON credit_pools;

-- Ajouter une politique pour permettre aux admins de créer des pools de crédits pour n'importe quel utilisateur
CREATE POLICY "Admins can insert credit pools for any user" ON credit_pools
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'admin' AND is_active = true
    )
  );

-- Les utilisateurs peuvent toujours créer leurs propres pools (politique existante)
-- La politique "Users can insert own credit pools" reste active

-- Vérification
SELECT 
  schemaname,
  tablename,
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'credit_pools'
ORDER BY policyname;

