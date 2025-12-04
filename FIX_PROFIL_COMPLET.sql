-- ============================================
-- FIX COMPLET: Erreur serveur lors du chargement du profil
-- ============================================
-- Ce script corrige définitivement l'erreur "Erreur serveur lors du chargement du profil"
-- en s'assurant que toutes les politiques RLS sont correctement configurées
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

-- 5. Supprimer TOUTES les politiques existantes pour repartir de zéro
-- (c'est critique pour éviter les conflits)
DROP POLICY IF EXISTS "Users can view own profile" ON users_app;
DROP POLICY IF EXISTS "Users can update own profile" ON users_app;
DROP POLICY IF EXISTS "Allow service role to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Allow trigger to insert profiles" ON users_app;
DROP POLICY IF EXISTS "Admins can view all users" ON users_app;

-- 6. Créer la politique SELECT de BASE (PRIORITAIRE - doit être créée en premier)
-- Cette politique permet à TOUS les utilisateurs de voir leur propre profil
-- C'est la politique la plus importante pour que la connexion fonctionne
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT 
  USING (auth.uid() = id);

-- 7. Créer la politique UPDATE (mise à jour du profil)
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE 
  USING (auth.uid() = id);

-- 8. Créer la politique INSERT permissive pour permettre au trigger de créer le profil
-- IMPORTANT: Cette politique est très permissive (WITH CHECK (true)) pour garantir
-- que le trigger SECURITY DEFINER peut créer le profil sans problème
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

-- 10. Créer la politique pour les admins (APRÈS la politique de base)
-- Cette politique utilise la fonction SECURITY DEFINER pour éviter la récursion
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

-- Vérifier que RLS est activé
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname = 'users_app';

-- Vérifier que toutes les politiques sont créées dans le bon ordre
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
-- 3. Que les politiques RLS sont bien appliquées (voir requête #2 ci-dessus)

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. L'ORDRE DE CRÉATION DES POLITIQUES EST CRITIQUE :
--    - "Users can view own profile" doit être créée EN PREMIER
--    - "Admins can view all users" doit être créée APRÈS
--    - Les deux politiques utilisent FOR SELECT, donc elles sont combinées avec OR
--
-- 2. La politique "Users can view own profile" permet à TOUS les utilisateurs
--    de voir leur propre profil (auth.uid() = id)
--
-- 3. La politique "Admins can view all users" permet aux admins de voir TOUS les utilisateurs
--    mais ne remplace PAS la politique de base, elle s'ajoute (OR)
--
-- 4. La politique INSERT "Allow trigger to insert profiles" est très permissive (WITH CHECK (true))
--    pour garantir que le trigger SECURITY DEFINER peut créer le profil sans problème
--
-- 5. Si vous avez encore des problèmes après avoir exécuté ce script :
--    a. Vérifiez que toutes les politiques sont créées (voir requête de vérification #2)
--    b. Vérifiez que le trigger est actif (voir requête de vérification #3)
--    c. Vérifiez que la fonction est SECURITY DEFINER (voir requête de vérification #4)
--    d. Testez la connexion avec un compte utilisateur normal (pas admin)
--    e. Vérifiez les logs Supabase pour plus de détails sur l'erreur 500

