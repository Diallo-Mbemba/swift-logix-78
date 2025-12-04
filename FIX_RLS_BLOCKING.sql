-- ============================================
-- FIX: RLS BLOQUE LA LECTURE DU PROFIL
-- ============================================
-- Si RLS bloque la lecture du profil lors de la connexion,
-- exécutez ce script pour corriger les politiques
-- ============================================

-- 1. Vérifier que la politique SELECT existe pour users_app
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'users_app' 
    AND policyname = 'Users can view own profile'
  ) THEN
    RAISE NOTICE 'Création de la politique SELECT pour users_app...';
    CREATE POLICY "Users can view own profile" ON users_app
      FOR SELECT USING (auth.uid() = id);
  ELSE
    RAISE NOTICE '✅ La politique SELECT existe déjà';
  END IF;
END $$;

-- 2. Vérifier que RLS est bien activé
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_class 
    WHERE relname = 'users_app' 
    AND relrowsecurity = true
  ) THEN
    RAISE NOTICE 'Activation de RLS sur users_app...';
    ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;
  ELSE
    RAISE NOTICE '✅ RLS est déjà activé sur users_app';
  END IF;
END $$;

-- 3. Tester la politique (doit retourner true pour un utilisateur authentifié)
-- Cette requête sera exécutée dans le contexte de l'utilisateur authentifié
SELECT 
  'Test RLS' as test,
  auth.uid() as current_user_id,
  CASE 
    WHEN auth.uid() IS NOT NULL THEN '✅ Utilisateur authentifié'
    ELSE '❌ Utilisateur non authentifié'
  END as auth_status;

-- 4. Vérifier les politiques existantes
SELECT 
  tablename,
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY policyname;

-- ============================================
-- SOLUTION ALTERNATIVE: Désactiver temporairement RLS pour debug
-- ============================================
-- ⚠️ ATTENTION: Ne faites cela QUE pour le debug, puis réactivez RLS !
-- 
-- ALTER TABLE users_app DISABLE ROW LEVEL SECURITY;
-- 
-- Après le debug, réactivez RLS:
-- ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;
-- 
-- ============================================

