-- ============================================
-- FIX: Erreur 500 causée par récursion infinie dans les politiques RLS
-- ============================================
-- Problème identifié: La politique "Admins can view all users" sur users_app fait
-- référence à admin_users, qui a elle-même des politiques RLS créant une récursion infinie.
-- PostgreSQL détecte cette récursion (erreur 42P17) → erreur 500 dans l'API REST.
-- ============================================
-- Solution: Utiliser une fonction SECURITY DEFINER pour vérifier si un utilisateur est admin.
-- Cette fonction contourne RLS et évite la récursion.
-- ============================================

-- 1. Recréer la fonction create_user_profile
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users_app (id, email, name, plan, remaining_credits, total_credits)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    'free',
    3,
    3
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    RAISE WARNING 'Erreur lors de la création du profil utilisateur pour %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Supprimer et recréer le trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile();

-- 3. S'assurer que RLS est activé (mais pas forcé)
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;
ALTER TABLE users_app NO FORCE ROW LEVEL SECURITY;

-- 4. Supprimer TOUTES les politiques existantes
DROP POLICY IF EXISTS "Users can view own profile" ON users_app;
DROP POLICY IF EXISTS "Users can update own profile" ON users_app;
DROP POLICY IF EXISTS "Allow service role to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Allow trigger to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Admins can view all users" ON users_app;

-- 5. Créer une fonction SECURITY DEFINER pour vérifier si un utilisateur est admin
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

-- 6. Créer la politique SELECT de BASE (PRIORITAIRE)
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT 
  USING (auth.uid() = id);

-- 7. Créer la politique UPDATE
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE 
  USING (auth.uid() = id);

-- 8. Créer la politique INSERT permissive pour le trigger
CREATE POLICY "Allow trigger to insert profiles" ON users_app
  FOR INSERT 
  WITH CHECK (true);

-- 9. Créer la politique pour les admins en utilisant la fonction SECURITY DEFINER
-- Cette politique n'utilise plus directement SELECT sur admin_users,
-- donc pas de récursion
CREATE POLICY "Admins can view all users" ON users_app
  FOR SELECT USING (
    -- Utiliser la fonction SECURITY DEFINER qui contourne RLS
    is_user_admin()
  );

-- 10. S'assurer que les permissions sont correctes
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users_app TO postgres, anon, authenticated, service_role;

-- ============================================
-- VÉRIFICATIONS
-- ============================================

-- Vérifier que la fonction existe et est SECURITY DEFINER
SELECT 
  proname as "Function Name",
  CASE 
    WHEN prosecdef THEN '✅ Security Definer'
    ELSE '❌ Non Security Definer'
  END as "Security Definer"
FROM pg_proc
WHERE proname = 'is_user_admin';

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

-- Vérifier que RLS est activé (mais pas forcé)
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status",
  CASE 
    WHEN relforcerowsecurity THEN '⚠️ Forcé (peut causer des problèmes)'
    ELSE '✅ Non forcé'
  END as "RLS Forcé"
FROM pg_class
WHERE relname = 'users_app';

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
-- 4. Cette solution résout l'erreur 42P17 (récursion infinie) qui causait l'erreur 500.

