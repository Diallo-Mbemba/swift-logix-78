-- ============================================
-- FIX: Erreur 500 lors de la récupération du profil après connexion
-- ============================================
-- Ce script corrige les problèmes RLS qui causent une erreur 500
-- lors de la tentative de récupération du profil utilisateur
-- ============================================

-- 1. Supprimer TOUTES les politiques existantes pour users_app
-- (pour éviter les conflits)
DROP POLICY IF EXISTS "Users can view own profile" ON users_app;
DROP POLICY IF EXISTS "Users can update own profile" ON users_app;
DROP POLICY IF EXISTS "Allow service role to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Admins can view all users" ON users_app;

-- 2. S'assurer que RLS est activé
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;

-- 3. Recréer la politique SELECT (lecture du profil)
-- Cette politique doit être créée EN PREMIER pour éviter les conflits
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT 
  USING (auth.uid() = id);

-- 4. Créer la politique UPDATE (mise à jour du profil)
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE 
  USING (auth.uid() = id);

-- 5. Créer la politique INSERT pour permettre au trigger de créer le profil
CREATE POLICY "Allow service role to insert profiles" ON users_app
  FOR INSERT 
  WITH CHECK (
    auth.uid() = id 
    OR auth.jwt() ->> 'role' = 'service_role'
  );

-- 6. Créer une fonction SECURITY DEFINER pour vérifier si un utilisateur est admin
-- Cette fonction contourne RLS et évite la récursion infinie
CREATE OR REPLACE FUNCTION is_user_admin(check_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
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

-- 7. Recréer la politique pour les admins en utilisant la fonction SECURITY DEFINER
-- Cette politique n'utilise plus directement SELECT sur admin_users,
-- donc pas de récursion
CREATE POLICY "Admins can view all users" ON users_app
  FOR SELECT USING (
    -- Permettre si c'est le propre profil de l'utilisateur
    auth.uid() = id
    OR
    -- Utiliser la fonction SECURITY DEFINER qui contourne RLS
    is_user_admin()
  );

-- ============================================
-- VÉRIFICATIONS
-- ============================================

-- 7. Vérifier que RLS est activé
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname = 'users_app';

-- 8. Vérifier que toutes les politiques sont créées
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY policyname;

-- 9. Vérifier que le trigger existe et est actif
SELECT 
  tgname as "Trigger Name",
  CASE 
    WHEN tgenabled = 'O' THEN '✅ Activé'
    WHEN tgenabled = 'D' THEN '❌ Désactivé'
    ELSE tgenabled
  END as "Status",
  tgrelid::regclass as "Table"
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';

-- 10. Vérifier que la fonction create_user_profile existe
SELECT 
  proname as "Function Name",
  CASE 
    WHEN prosecdef THEN '✅ Security Definer'
    ELSE '❌ Non Security Definer'
  END as "Security Definer"
FROM pg_proc
WHERE proname = 'create_user_profile';

-- ============================================
-- TEST DE LA POLITIQUE (à exécuter en tant qu'utilisateur authentifié)
-- ============================================
-- Note: Ce test doit être exécuté dans le contexte d'un utilisateur authentifié
-- via l'application (pas directement dans le SQL Editor)
-- 
-- Dans l'application, après connexion, la requête suivante devrait fonctionner:
-- SELECT * FROM users_app WHERE id = auth.uid();
-- 
-- Si cette requête retourne une erreur 500, vérifiez:
-- 1. Que auth.uid() retourne bien l'ID de l'utilisateur
-- 2. Que le profil existe dans users_app avec cet ID
-- 3. Que les politiques RLS sont bien appliquées (voir requête #8 ci-dessus)

-- ============================================
-- DIAGNOSTIC SUPPLÉMENTAIRE
-- ============================================

-- Vérifier s'il y a des profils orphelins (dans auth.users mais pas dans users_app)
SELECT 
  au.id as "Auth User ID",
  au.email as "Email",
  CASE 
    WHEN ua.id IS NULL THEN '❌ Profil manquant dans users_app'
    ELSE '✅ Profil existe'
  END as "Status"
FROM auth.users au
LEFT JOIN users_app ua ON au.id = ua.id
ORDER BY au.created_at DESC
LIMIT 10;

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. L'ordre de création des politiques est important:
--    - "Users can view own profile" doit être créée en premier
--    - "Admins can view all users" doit être créée après
--    - Les deux politiques utilisent FOR SELECT, donc elles sont combinées avec OR
--
-- 2. La politique "Admins can view all users" inclut la condition auth.uid() = id
--    pour éviter les conflits avec la politique de base
--
-- 3. Si l'erreur 500 persiste après avoir exécuté ce script:
--    a. Vérifiez les logs Supabase pour plus de détails
--    b. Vérifiez que le profil existe dans users_app
--    c. Vérifiez que auth.uid() retourne bien l'ID de l'utilisateur
--    d. Testez la requête directement dans le SQL Editor en tant qu'utilisateur authentifié
--
-- 4. Pour tester en tant qu'utilisateur authentifié dans le SQL Editor:
--    - Utilisez la fonction set_config pour simuler un utilisateur:
--      SELECT set_config('request.jwt.claims', '{"sub": "USER_ID_ICI"}', true);
--    - Puis testez: SELECT * FROM users_app WHERE id = auth.uid();

