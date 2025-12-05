-- ============================================
-- SCRIPT : Vérifier l'état et réinitialiser le mot de passe
-- ============================================
-- Utilisez ce script pour diagnostiquer le problème de connexion
-- ============================================

-- ÉTAPE 1 : Vérifier l'état complet de l'utilisateur
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at,
  last_sign_in_at,
  encrypted_password IS NOT NULL as has_password,
  LENGTH(encrypted_password::text) as password_length,
  updated_at
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

-- ============================================
-- RÉINITIALISATION DU MOT DE PASSE
-- ============================================
-- IMPORTANT : Vous ne pouvez PAS modifier directement le mot de passe en SQL
-- car il est hashé. Vous DEVEZ utiliser Supabase Dashboard ou l'API Admin.

-- SOLUTION RECOMMANDÉE : Via Supabase Dashboard
-- 1. Allez dans Authentication > Users
-- 2. Trouvez diallombemba7@gmail.com
-- 3. Cliquez sur "..." > "Reset password"
-- 4. Un email sera envoyé à l'utilisateur

-- ============================================
-- VÉRIFICATIONS À FAIRE
-- ============================================

-- Vérifier que l'email est bien confirmé
SELECT 
  email,
  email_confirmed_at IS NOT NULL as email_confirmed,
  confirmed_at IS NOT NULL as user_confirmed,
  CASE 
    WHEN email_confirmed_at IS NULL THEN '❌ Email NON confirmé'
    ELSE '✅ Email confirmé'
  END as status_email,
  CASE 
    WHEN confirmed_at IS NULL THEN '❌ Utilisateur NON confirmé'
    ELSE '✅ Utilisateur confirmé'
  END as status_user
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

-- Vérifier que l'utilisateur a un mot de passe
SELECT 
  email,
  encrypted_password IS NOT NULL as has_password,
  CASE 
    WHEN encrypted_password IS NULL THEN '❌ Pas de mot de passe'
    ELSE '✅ Mot de passe existe'
  END as status_password
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

