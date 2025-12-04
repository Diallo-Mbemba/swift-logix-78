-- ============================================
-- Script pour permettre aux caissiers de valider les commandes
-- ============================================

-- Supprimer les politiques existantes si elles existent (pour éviter les conflits)
DROP POLICY IF EXISTS "Cashiers can update orders" ON orders;
DROP POLICY IF EXISTS "Cashiers can view all orders" ON orders;

-- 1. Ajouter une politique RLS pour permettre aux caissiers de mettre à jour les commandes
CREATE POLICY "Cashiers can update orders" ON orders
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'cashier' AND is_active = true
    )
  );

-- 2. Ajouter une politique RLS pour permettre aux caissiers de voir toutes les commandes
CREATE POLICY "Cashiers can view all orders" ON orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE user_id = auth.uid() AND role = 'cashier' AND is_active = true
    )
  );

-- 3. Vérifier que la table admin_users existe et contient les rôles
-- Si vous n'avez pas encore de caissiers dans admin_users, vous pouvez en créer un :
-- INSERT INTO admin_users (id, user_id, name, email, role, permissions, is_active, created_at)
-- VALUES (
--   gen_random_uuid(),
--   'UUID_DE_L_UTILISATEUR_CAISSIER',
--   'Nom du Caissier',
--   'email@caissier.com',
--   'cashier',
--   ARRAY['validate_orders'],
--   true,
--   NOW()
-- );

