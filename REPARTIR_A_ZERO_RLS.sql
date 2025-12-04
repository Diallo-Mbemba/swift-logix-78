-- ============================================
-- REPARTIR À ZÉRO : Suppression de toutes les politiques RLS
-- ============================================
-- Ce script supprime TOUTES les politiques RLS existantes et repart de zéro
-- avec une configuration simple et fonctionnelle
-- ============================================

-- 1. Supprimer TOUTES les politiques existantes sur users_app (de manière dynamique)
DO $$
DECLARE
  policy_record RECORD;
  policies_deleted INTEGER := 0;
BEGIN
  RAISE NOTICE 'Recherche et suppression de toutes les politiques sur users_app...';
  
  -- Supprimer chaque politique trouvée
  FOR policy_record IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'public' 
    AND tablename = 'users_app'
  LOOP
    BEGIN
      EXECUTE format('DROP POLICY IF EXISTS %I ON users_app', policy_record.policyname);
      RAISE NOTICE '✅ Politique supprimée: %', policy_record.policyname;
      policies_deleted := policies_deleted + 1;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE WARNING '❌ Erreur lors de la suppression de la politique %: %', policy_record.policyname, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE 'Total de politiques supprimées: %', policies_deleted;
END $$;

-- 2. Supprimer les fonctions qui pourraient causer des problèmes
DROP FUNCTION IF EXISTS is_user_admin(UUID);
DROP FUNCTION IF EXISTS is_user_admin();
DROP FUNCTION IF EXISTS is_user_cashier(UUID);
DROP FUNCTION IF EXISTS is_user_cashier();

-- 3. Désactiver temporairement RLS pour nettoyer
ALTER TABLE users_app DISABLE ROW LEVEL SECURITY;

-- 4. Attendre un peu pour s'assurer que tout est nettoyé
DO $$
BEGIN
  RAISE NOTICE '✅ Toutes les politiques RLS ont été supprimées';
  RAISE NOTICE '✅ RLS est maintenant désactivé';
END $$;

-- 5. Réactiver RLS
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;
ALTER TABLE users_app NO FORCE ROW LEVEL SECURITY;

-- 6. Recréer la fonction create_user_profile (toujours la recréer pour être sûr)
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

-- 7. Supprimer et recréer le trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile();

-- 8. Recréer UNIQUEMENT les politiques de base (configuration minimale et fonctionnelle)
-- Politique 1: Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT 
  USING (auth.uid() = id);

-- Politique 2: Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE 
  USING (auth.uid() = id);

-- Politique 3: Permettre au trigger de créer le profil (politique très permissive)
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
    WHEN relforcerowsecurity THEN '⚠️ Forcé'
    ELSE '✅ Non forcé'
  END as "RLS Forcé"
FROM pg_class
WHERE relname = 'users_app';

-- Vérifier le nombre de politiques (il doit y avoir EXACTEMENT 3)
SELECT 
  COUNT(*) as "Nombre de politiques",
  CASE 
    WHEN COUNT(*) = 3 THEN '✅ Correct (3 politiques)'
    WHEN COUNT(*) > 3 THEN '⚠️ Trop de politiques (il en reste ' || COUNT(*) || ')'
    ELSE '❌ Pas assez de politiques'
  END as "Status"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app';

-- Lister toutes les politiques restantes
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
-- RÉSULTAT ATTENDU
-- ============================================
-- Après l'exécution de ce script, vous devriez avoir :
-- ✅ RLS activé (mais pas forcé)
-- ✅ 3 politiques UNIQUEMENT :
--    1. "Users can view own profile" (SELECT)
--    2. "Users can update own profile" (UPDATE)
--    3. "Allow trigger to insert profiles" (INSERT)
-- ✅ Trigger actif
-- ✅ Fonction create_user_profile avec SECURITY DEFINER
-- ✅ Aucune fonction is_user_admin ou is_user_cashier
-- ✅ Aucune politique pour les admins

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. Cette configuration est MINIMALE et FONCTIONNELLE
-- 2. Elle permet :
--    - La connexion des utilisateurs
--    - La création de compte
--    - Le chargement du profil
--    - La mise à jour du profil
-- 3. Elle ne permet PAS :
--    - Aux admins de voir tous les utilisateurs (pour éviter la récursion)
-- 4. Si vous avez besoin des fonctionnalités admin/caissier plus tard,
--    utilisez des fonctions SECURITY DEFINER ou des vues séparées

