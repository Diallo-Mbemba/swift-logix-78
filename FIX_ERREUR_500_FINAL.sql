-- ============================================
-- FIX FINAL: Erreur 500 lors de la récupération du profil
-- ============================================
-- Ce script corrige définitivement l'erreur 500 en vérifiant et créant le profil
-- si nécessaire, puis en s'assurant que les politiques RLS sont correctes
-- ============================================

-- IMPORTANT: Remplacez 'dab872d3-6e7f-4980-92b7-70cd5ae246b5' par votre ID utilisateur
-- si vous voulez créer le profil manuellement

-- 1. Vérifier si le profil existe
DO $$
DECLARE
  user_id UUID := 'dab872d3-6e7f-4980-92b7-70cd5ae246b5';
  user_email TEXT;
  user_name TEXT;
  profile_exists BOOLEAN;
BEGIN
  -- Vérifier si le profil existe
  SELECT EXISTS(SELECT 1 FROM users_app WHERE id = user_id) INTO profile_exists;
  
  IF NOT profile_exists THEN
    -- Récupérer les infos de l'utilisateur depuis auth.users
    SELECT email, COALESCE(raw_user_meta_data->>'name', split_part(email, '@', 1))
    INTO user_email, user_name
    FROM auth.users
    WHERE id = user_id;
    
    IF user_email IS NOT NULL THEN
      RAISE NOTICE 'Création du profil manquant pour: % (%)', user_email, user_id;
      
      -- Créer le profil
      INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
      VALUES (user_id, user_email, user_name, 'free', 3, 3)
      ON CONFLICT (id) DO NOTHING;
      
      RAISE NOTICE '✅ Profil créé avec succès';
    ELSE
      RAISE WARNING '❌ Utilisateur non trouvé dans auth.users avec l''ID: %', user_id;
    END IF;
  ELSE
    RAISE NOTICE '✅ Le profil existe déjà';
  END IF;
END $$;

-- 2. Recréer la fonction create_user_profile
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

-- 3. Supprimer et recréer le trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile();

-- 4. S'assurer que RLS est activé (mais pas forcé)
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;
ALTER TABLE users_app NO FORCE ROW LEVEL SECURITY;

-- 5. Supprimer TOUTES les politiques existantes
DROP POLICY IF EXISTS "Users can view own profile" ON users_app;
DROP POLICY IF EXISTS "Users can update own profile" ON users_app;
DROP POLICY IF EXISTS "Allow service role to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Allow trigger to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Admins can view all users" ON users_app;

-- 6. Créer la politique SELECT de BASE (PRIORITAIRE)
-- Cette politique permet à TOUS les utilisateurs de voir leur propre profil
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

-- 9. Créer une fonction SECURITY DEFINER pour vérifier si un utilisateur est admin
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

-- 10. Créer la politique pour les admins en utilisant la fonction SECURITY DEFINER
CREATE POLICY "Admins can view all users" ON users_app
  FOR SELECT USING (
    -- Utiliser la fonction SECURITY DEFINER qui contourne RLS
    is_user_admin()
  );

-- 11. S'assurer que les permissions sont correctes
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users_app TO postgres, anon, authenticated, service_role;

-- ============================================
-- VÉRIFICATIONS
-- ============================================

-- Vérifier que le profil existe maintenant
SELECT 
  'Vérification du profil' as test,
  id,
  email,
  name,
  plan,
  remaining_credits,
  total_credits
FROM users_app
WHERE id = 'dab872d3-6e7f-4980-92b7-70cd5ae246b5';

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

-- Vérifier toutes les politiques
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY cmd, policyname;

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

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. Ce script crée automatiquement le profil s'il n'existe pas
-- 2. Il s'assure que RLS n'est PAS forcé (NO FORCE ROW LEVEL SECURITY)
--    car RLS forcé peut causer des erreurs 500
-- 3. Les politiques sont créées dans le bon ordre pour éviter les conflits
-- 4. La politique INSERT est très permissive pour garantir que le trigger fonctionne

