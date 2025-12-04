-- ============================================
-- TEST: Vérifier l'accès au profil utilisateur
-- ============================================
-- Exécutez ce script pour tester si RLS permet
-- à un utilisateur authentifié de lire son profil
-- ============================================

-- 1. Vérifier que la politique SELECT existe
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'users_app'
AND policyname = 'Users can view own profile';

-- 2. Vérifier que RLS est activé
SELECT 
  relname as "Table",
  relrowsecurity as "RLS Activé"
FROM pg_class
WHERE relname = 'users_app';

-- 3. Vérifier qu'un utilisateur existe dans users_app
-- Remplacez 'dab872d3-6e7f-4980-92b7-70cd5ae246b5' par l'ID de votre utilisateur
SELECT 
  id,
  email,
  name,
  plan,
  remaining_credits,
  total_credits
FROM users_app
WHERE id = 'dab872d3-6e7f-4980-92b7-70cd5ae246b5';

-- 4. Si l'utilisateur n'existe pas, créer le profil
-- Remplacez les valeurs par celles de votre utilisateur
INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
VALUES (
  'dab872d3-6e7f-4980-92b7-70cd5ae246b5',
  'diallombemba7@gmail.com',
  'Utilisateur Test',
  'free',
  3,
  3
)
ON CONFLICT (id) DO UPDATE
SET 
  email = EXCLUDED.email,
  name = EXCLUDED.name;

-- 5. Vérifier les permissions de la table
SELECT 
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
AND table_name = 'users_app';

-- ============================================
-- SOLUTION: Si RLS bloque, créer une politique temporaire
-- ============================================
-- ⚠️ ATTENTION: Cette politique est très permissive
-- Utilisez-la uniquement pour le debug, puis supprimez-la

-- Créer une politique temporaire pour permettre la lecture
-- (à supprimer après le debug)
-- CREATE POLICY "Temporary: Allow all authenticated users to read" ON users_app
--   FOR SELECT USING (auth.uid() IS NOT NULL);

-- ============================================

