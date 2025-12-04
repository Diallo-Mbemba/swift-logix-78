-- ============================================
-- FIX: Récursion infinie dans les politiques RLS
-- ============================================
-- Problème: La politique "Admins can view all users" sur users_app fait référence
-- à admin_users, qui a elle-même des politiques RLS, créant une récursion infinie.
-- PostgreSQL détecte cette récursion (erreur 42P17) → erreur 500 dans l'API REST.
-- ============================================
-- Solution: Créer une fonction SECURITY DEFINER pour vérifier si un utilisateur est admin.
-- Cette fonction contourne RLS et évite la récursion.
-- ============================================

-- 1. Créer une fonction SECURITY DEFINER pour vérifier si un utilisateur est admin
-- Cette fonction contourne RLS et évite la récursion infinie
CREATE OR REPLACE FUNCTION is_user_admin(check_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  -- Vérifier si l'utilisateur est admin dans admin_users
  -- Cette fonction s'exécute avec les permissions du créateur (SECURITY DEFINER)
  -- donc elle contourne RLS et évite la récursion
  RETURN EXISTS (
    SELECT 1 FROM admin_users
    WHERE user_id = check_user_id
    AND role = 'admin'
    AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- 2. Créer une fonction similaire pour vérifier si un utilisateur est caissier
CREATE OR REPLACE FUNCTION is_user_cashier(check_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_users
    WHERE user_id = check_user_id
    AND role = 'cashier'
    AND is_active = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- 3. Supprimer l'ancienne politique "Admins can view all users" qui cause la récursion
DROP POLICY IF EXISTS "Admins can view all users" ON users_app;

-- 4. Recréer la politique en utilisant la fonction SECURITY DEFINER
-- Cette politique n'utilise plus directement SELECT sur admin_users,
-- donc pas de récursion
CREATE POLICY "Admins can view all users" ON users_app
  FOR SELECT USING (
    -- Utiliser la fonction SECURITY DEFINER qui contourne RLS
    is_user_admin()
  );

-- 5. Vérifier que la fonction fonctionne
SELECT 
  'Test fonction is_user_admin' as test,
  is_user_admin() as "Est admin";

-- ============================================
-- VÉRIFICATIONS
-- ============================================

-- Vérifier que la fonction existe et est SECURITY DEFINER
SELECT 
  proname as "Function Name",
  CASE 
    WHEN prosecdef THEN '✅ Security Definer'
    ELSE '❌ Non Security Definer'
  END as "Security Definer",
  prorettype::regtype as "Return Type"
FROM pg_proc
WHERE proname IN ('is_user_admin', 'is_user_cashier')
ORDER BY proname;

-- Vérifier les politiques sur users_app
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY policyname;

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. La fonction is_user_admin() est SECURITY DEFINER, donc elle s'exécute
--    avec les permissions du créateur de la fonction (généralement postgres)
--    et contourne RLS, évitant ainsi la récursion infinie.
--
-- 2. La fonction est STABLE, ce qui signifie qu'elle peut être optimisée
--    par PostgreSQL pour des requêtes répétées.
--
-- 3. La politique "Admins can view all users" utilise maintenant is_user_admin()
--    au lieu de faire directement SELECT sur admin_users, ce qui évite la récursion.
--
-- 4. Si vous avez d'autres politiques qui font référence à admin_users de manière
--    similaire, utilisez ces fonctions pour éviter la récursion.

