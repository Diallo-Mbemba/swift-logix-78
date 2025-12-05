-- ============================================
-- SCRIPT : Confirmer manuellement l'email d'un utilisateur
-- ============================================
-- Utilisez ce script si l'utilisateur existe mais ne peut pas se connecter
-- à cause d'un email non confirmé
-- ============================================

-- ÉTAPE 1 : Vérifier l'état de l'utilisateur
-- Remplacez 'email@example.com' par l'email de l'utilisateur
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at,
  last_sign_in_at
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

-- ÉTAPE 2 : Confirmer manuellement l'email
-- Remplacez 'email@example.com' par l'email de l'utilisateur
-- NOTE: confirmed_at est une colonne générée automatiquement, ne pas la mettre à jour
UPDATE auth.users
SET 
  email_confirmed_at = NOW(),
  updated_at = NOW()
WHERE email = 'diallombemba7@gmail.com';

-- ÉTAPE 3 : Vérifier que la confirmation a fonctionné
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

-- ============================================
-- ALTERNATIVE : Confirmer par ID utilisateur
-- ============================================
-- Si vous connaissez l'ID de l'utilisateur (UUID)
-- Remplacez 'USER_ID_HERE' par l'ID de l'utilisateur

-- UPDATE auth.users
-- SET 
--   email_confirmed_at = NOW(),
--   updated_at = NOW()
-- WHERE id = 'USER_ID_HERE';
-- NOTE: confirmed_at est généré automatiquement à partir de email_confirmed_at

-- ============================================
-- RÉINITIALISER LE MOT DE PASSE (si nécessaire)
-- ============================================
-- Si l'utilisateur a oublié son mot de passe,
-- utilisez la fonction de réinitialisation dans l'application
-- ou via Supabase Dashboard > Authentication > Users > Reset Password

-- ============================================
-- VÉRIFIER TOUS LES UTILISATEURS NON CONFIRMÉS
-- ============================================
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at
FROM auth.users
WHERE email_confirmed_at IS NULL
ORDER BY created_at DESC;


