-- ============================================
-- FIX: "Vous n'avez pas access" après inscription
-- ============================================
-- Ce script corrige les problèmes de permissions RLS
-- qui empêchent l'utilisateur d'accéder à son profil après l'inscription
-- ============================================

-- 1. Supprimer les anciennes politiques pour users_app (si elles existent)
DROP POLICY IF EXISTS "Users can view own profile" ON users_app;
DROP POLICY IF EXISTS "Users can update own profile" ON users_app;
DROP POLICY IF EXISTS "Allow service role to insert profiles" ON users_app;

-- 2. S'assurer que RLS est activé
ALTER TABLE users_app ENABLE ROW LEVEL SECURITY;

-- 3. Créer la politique SELECT (lecture du profil)
CREATE POLICY "Users can view own profile" ON users_app
  FOR SELECT 
  USING (auth.uid() = id);

-- 4. Créer la politique UPDATE (mise à jour du profil)
CREATE POLICY "Users can update own profile" ON users_app
  FOR UPDATE 
  USING (auth.uid() = id);

-- 5. Créer la politique INSERT pour permettre au trigger de créer le profil
-- Cette politique permet au trigger SECURITY DEFINER de créer le profil
CREATE POLICY "Allow service role to insert profiles" ON users_app
  FOR INSERT 
  WITH CHECK (
    auth.uid() = id 
    OR auth.jwt() ->> 'role' = 'service_role'
  );

-- 6. Vérifier que les politiques sont créées
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
ORDER BY policyname;

-- 7. Vérifier que RLS est activé
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname = 'users_app';

-- ============================================
-- VÉRIFICATION SUPPLÉMENTAIRE
-- ============================================

-- Vérifier que le trigger existe et est actif
SELECT 
  tgname as "Trigger Name",
  tgenabled as "Enabled",
  tgrelid::regclass as "Table"
FROM pg_trigger
WHERE tgname = 'on_auth_user_created';

-- Vérifier que la fonction create_user_profile existe
SELECT 
  proname as "Function Name",
  prosecdef as "Security Definer"
FROM pg_proc
WHERE proname = 'create_user_profile';

-- ============================================
-- SOLUTION ALTERNATIVE: Si le problème persiste
-- ============================================
-- Si après avoir exécuté ce script, l'utilisateur ne peut toujours pas accéder,
-- vérifiez que le profil a bien été créé dans users_app :

-- SELECT * FROM users_app WHERE email = 'email_de_l_utilisateur@example.com';

-- Si le profil n'existe pas, créez-le manuellement :
-- INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
-- VALUES (
--   'UUID_DE_L_UTILISATEUR_FROM_AUTH.USERS',
--   'email@example.com',
--   'Nom Utilisateur',
--   'free',
--   3,
--   3
-- );

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. Les politiques RLS utilisent auth.uid() qui retourne l'ID de l'utilisateur authentifié
-- 2. Le trigger SECURITY DEFINER s'exécute avec les permissions du créateur de la fonction
-- 3. La politique INSERT permet à la fois l'utilisateur et le service_role d'insérer
-- 4. Après avoir exécuté ce script, l'utilisateur devrait pouvoir accéder à son profil

