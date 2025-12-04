-- ============================================
-- RESTAURATION: Connexion et création de compte
-- ============================================
-- Ce script restaure les fonctionnalités de connexion et d'inscription
-- qui ont été cassées par les scripts RLS précédents
-- ============================================

-- 1. Recréer la fonction create_user_profile (toujours la recréer pour être sûr)
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
    -- Logger l'erreur mais ne pas bloquer la création de l'utilisateur auth
    RAISE WARNING 'Erreur lors de la création du profil utilisateur pour %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Supprimer le trigger s'il existe déjà
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 3. Créer le trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile();

-- 4. S'assurer que RLS est activé
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;

-- 5. Supprimer les politiques existantes pour repartir de zéro
DROP POLICY IF EXISTS "Users can view own profile" ON users_app;
DROP POLICY IF EXISTS "Users can update own profile" ON users_app;
DROP POLICY IF EXISTS "Allow service role to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Allow trigger to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Admins can view all users" ON users_app;

-- 6. Créer la politique SELECT (lecture du profil) - PRIORITAIRE
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT 
  USING (auth.uid() = id);

-- 7. Créer la politique UPDATE (mise à jour du profil)
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE 
  USING (auth.uid() = id);

-- 8. Créer la politique INSERT pour permettre au trigger de créer le profil
-- IMPORTANT: Le trigger SECURITY DEFINER devrait contourner RLS, mais on ajoute
-- une politique permissive pour être sûr que ça fonctionne
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
    -- Permettre si c'est le propre profil de l'utilisateur
    auth.uid() = id
    OR
    -- Utiliser la fonction SECURITY DEFINER qui contourne RLS
    is_user_admin()
  );

-- 11. S'assurer que les permissions sont correctes
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.users_app TO postgres, anon, authenticated, service_role;

-- ============================================
-- VÉRIFICATIONS
-- ============================================

-- Vérifier que RLS est activé
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname = 'users_app';

-- Vérifier que toutes les politiques sont créées
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY policyname;

-- Vérifier que le trigger existe et est actif
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

-- Vérifier que la fonction existe et est SECURITY DEFINER
SELECT 
  proname as "Function Name",
  CASE 
    WHEN prosecdef THEN '✅ Security Definer'
    ELSE '❌ Non Security Definer'
  END as "Security Definer"
FROM pg_proc
WHERE proname = 'create_user_profile';

-- ============================================
-- TEST DE LA FONCTIONNALITÉ
-- ============================================
-- Après avoir exécuté ce script, testez :
-- 1. Créer un nouveau compte (l'inscription devrait fonctionner)
-- 2. Se connecter avec un compte existant (la connexion devrait fonctionner)
-- 3. Vérifier que le profil est créé automatiquement lors de l'inscription

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. La politique INSERT "Allow trigger to insert profiles" est très permissive (WITH CHECK (true))
--    Cela permet au trigger SECURITY DEFINER de créer le profil sans problème
-- 2. Le trigger SECURITY DEFINER devrait normalement contourner RLS, mais cette politique
--    garantit que ça fonctionne même si RLS est strict
-- 3. Les politiques SELECT et UPDATE restent restrictives (uniquement le propre profil)
-- 4. La politique pour les admins permet de voir tous les utilisateurs

