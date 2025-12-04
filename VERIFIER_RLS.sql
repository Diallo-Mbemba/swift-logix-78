-- ============================================
-- VÉRIFICATION RLS SUR TOUTE LA BASE
-- ============================================
-- Ce script vérifie que RLS est activé sur toutes les tables
-- ============================================

-- Vérifier que RLS est activé sur toutes les tables
SELECT 
  tablename as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "Statut RLS",
  (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public' AND tablename = t.tablename) as "Nombre de politiques"
FROM pg_tables t
LEFT JOIN pg_class c ON c.relname = t.tablename
WHERE t.schemaname = 'public' 
AND t.tablename IN (
  'users_app', 
  'simulations', 
  'orders', 
  'order_validations',
  'credit_pools', 
  'credit_usage', 
  'settings', 
  'admin_users'
)
ORDER BY tablename;

-- Afficher toutes les politiques RLS
SELECT 
  tablename as "Table",
  policyname as "Nom de la politique",
  cmd as "Commande",
  CASE 
    WHEN permissive = 'PERMISSIVE' THEN 'Permissive'
    ELSE 'Restrictive'
  END as "Type"
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

