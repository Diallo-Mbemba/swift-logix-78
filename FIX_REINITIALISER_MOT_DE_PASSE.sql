-- ============================================
-- SCRIPT : Réinitialiser le mot de passe d'un utilisateur
-- ============================================
-- Utilisez ce script si l'utilisateur ne peut pas se connecter
-- même après avoir confirmé son email
-- ============================================

-- ÉTAPE 1 : Vérifier l'état de l'utilisateur
SELECT 
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at,
  last_sign_in_at,
  encrypted_password IS NOT NULL as has_password
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

-- ============================================
-- SOLUTION 1 : Réinitialiser via l'interface Supabase (RECOMMANDÉ)
-- ============================================
-- 1. Allez dans Supabase Dashboard > Authentication > Users
-- 2. Trouvez l'utilisateur
-- 3. Cliquez sur "..." > "Reset password"
-- 4. Un email de réinitialisation sera envoyé

-- ============================================
-- SOLUTION 2 : Réinitialiser le mot de passe directement (AVANCÉ)
-- ============================================
-- ATTENTION : Cette méthode nécessite de connaître le nouveau mot de passe en clair
-- Supabase va le hasher automatiquement

-- Pour réinitialiser le mot de passe, vous devez utiliser l'API Supabase Admin
-- ou utiliser la fonction de réinitialisation dans l'application

-- ============================================
-- SOLUTION 3 : Vérifier et corriger le hash du mot de passe
-- ============================================
-- Si le mot de passe semble corrompu, vous pouvez forcer une réinitialisation

-- Option A : Via l'interface Supabase (RECOMMANDÉ)
-- 1. Authentication > Users > Trouvez l'utilisateur
-- 2. Cliquez sur "..." > "Reset password"
-- 3. L'utilisateur recevra un email pour réinitialiser

-- Option B : Forcer la réinitialisation (nécessite Supabase Admin API)
-- Utilisez l'API Admin de Supabase pour réinitialiser le mot de passe

-- ============================================
-- SOLUTION 4 : Créer un nouveau mot de passe temporaire
-- ============================================
-- Si vous avez accès à l'API Admin Supabase, vous pouvez créer un nouveau mot de passe
-- Sinon, utilisez la fonction de réinitialisation dans l'application

-- ============================================
-- VÉRIFICATIONS À FAIRE
-- ============================================

-- 1. Vérifier que l'email est confirmé
SELECT 
  email,
  email_confirmed_at IS NOT NULL as email_confirmed,
  confirmed_at IS NOT NULL as user_confirmed
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

-- 2. Vérifier que l'utilisateur a un mot de passe
SELECT 
  email,
  encrypted_password IS NOT NULL as has_password,
  LENGTH(encrypted_password::text) as password_length
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

-- ============================================
-- SOLUTION RECOMMANDÉE : Utiliser la fonction de réinitialisation
-- ============================================
-- La meilleure solution est d'utiliser la fonction "Mot de passe oublié ?" 
-- dans l'application ou via Supabase Dashboard

