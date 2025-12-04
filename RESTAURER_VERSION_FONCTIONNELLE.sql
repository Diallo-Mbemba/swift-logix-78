-- ============================================
-- RESTAURATION: Version fonctionnelle d'origine
-- ============================================
-- Ce script restaure l'application à son état fonctionnel d'origine,
-- avant les modifications liées aux admins et caissiers.
-- À cette version, le système fonctionnait correctement.
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

-- 4. Supprimer TOUTES les politiques existantes pour repartir de zéro
-- (y compris celles liées aux admins qui causent des problèmes)
DROP POLICY IF EXISTS "Users can view own profile" ON users_app;
DROP POLICY IF EXISTS "Users can update own profile" ON users_app;
DROP POLICY IF EXISTS "Allow service role to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Allow trigger to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Admins can view all users" ON users_app;

-- 5. Supprimer les fonctions qui causent des problèmes (si elles existent)
DROP FUNCTION IF EXISTS is_user_admin(UUID);
DROP FUNCTION IF EXISTS is_user_cashier(UUID);

-- 6. Créer UNIQUEMENT les politiques de base (version fonctionnelle d'origine)
-- Politique SELECT : Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT 
  USING (auth.uid() = id);

-- 7. Politique UPDATE : Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE 
  USING (auth.uid() = id);

-- 8. Politique INSERT : Permettre au trigger de créer le profil
-- IMPORTANT: Politique permissive pour garantir que le trigger fonctionne
CREATE POLICY "Allow trigger to insert profiles" ON users_app
  FOR INSERT 
  WITH CHECK (true);

-- 9. S'assurer que les permissions sont correctes
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users_app TO postgres, anon, authenticated, service_role;

-- ============================================
-- VÉRIFICATIONS
-- ============================================

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

-- Vérifier les politiques (il ne devrait y avoir QUE les 3 politiques de base)
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY policyname;

-- Vérifier le trigger
SELECT 
  tgname as "Trigger Name",
  CASE 
    WHEN tgenabled = 'O' THEN '✅ Activé'
    WHEN tgenabled = 'D' THEN '❌ Désactivé'
    ELSE tgenabled
  END as "Status"
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';

-- Vérifier la fonction
SELECT 
  proname as "Function Name",
  CASE 
    WHEN prosecdef THEN '✅ Security Definer'
    ELSE '❌ Non Security Definer'
  END as "Security Definer"
FROM pg_proc
WHERE proname = 'create_user_profile';

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. Cette version ne contient QUE les politiques de base :
--    - Users can view own profile (SELECT)
--    - Users can update own profile (UPDATE)
--    - Allow trigger to insert profiles (INSERT)
--
-- 2. Les politiques pour les admins ont été SUPPRIMÉES pour éviter :
--    - La récursion infinie
--    - Les erreurs 500
--    - Les conflits entre politiques
--
-- 3. Les admins peuvent toujours :
--    - Se connecter normalement (ils sont des utilisateurs normaux dans users_app)
--    - Utiliser la table admin_users séparément pour leurs fonctionnalités admin
--    - Mais ils ne peuvent PAS voir tous les utilisateurs via users_app
--
-- 4. Si vous avez besoin des fonctionnalités admin/caissier plus tard :
--    - Utilisez des fonctions SECURITY DEFINER pour éviter la récursion
--    - Ou créez des vues séparées pour les admins
--
-- 5. Cette version est la version fonctionnelle d'origine qui marchait bien
--    avant les modifications liées aux caissiers.

