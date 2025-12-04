-- ============================================
-- Script pour créer le premier compte Admin Système
-- ============================================
-- 
-- INSTRUCTIONS :
-- 1. Remplacez 'EMAIL_DE_L_ADMIN' par l'email de l'utilisateur qui sera admin
-- 2. Remplacez 'NOM_DE_L_ADMIN' par le nom de l'admin
-- 3. Exécutez ce script dans le SQL Editor de Supabase
-- 
-- IMPORTANT : L'utilisateur doit d'abord exister dans users_app
-- (créé automatiquement lors de l'inscription via Supabase Auth)
-- ============================================

-- Étape 1 : Trouver l'ID de l'utilisateur dans users_app
-- Remplacez 'EMAIL_DE_L_ADMIN' par l'email réel
DO $$
DECLARE
  user_id_found UUID;
  user_email TEXT := 'EMAIL_DE_L_ADMIN';  -- ⚠️ REMPLACER ICI
  user_name TEXT := 'NOM_DE_L_ADMIN';     -- ⚠️ REMPLACER ICI
BEGIN
  -- Vérifier si l'utilisateur existe
  SELECT id INTO user_id_found
  FROM users_app
  WHERE email = user_email;

  IF user_id_found IS NULL THEN
    RAISE EXCEPTION 'L''utilisateur avec l''email % n''existe pas dans users_app. Veuillez d''abord créer le compte utilisateur via l''inscription.', user_email;
  END IF;

  -- Vérifier si l'utilisateur a déjà un compte admin
  IF EXISTS (
    SELECT 1 FROM admin_users WHERE user_id = user_id_found
  ) THEN
    RAISE EXCEPTION 'Cet utilisateur a déjà un compte administrateur/caissier.';
  END IF;

  -- Créer le compte admin système
  INSERT INTO admin_users (
    id,
    user_id,
    name,
    email,
    role,
    permissions,
    is_active,
    created_at
  ) VALUES (
    gen_random_uuid(),
    user_id_found,
    user_name,
    user_email,
    'admin',
    ARRAY['manage_all', 'manage_cashiers', 'manage_orders', 'manage_users'],
    true,
    NOW()
  );

  RAISE NOTICE '✅ Compte admin système créé avec succès pour % (%)', user_name, user_email;
END $$;

-- ============================================
-- Vérification
-- ============================================
-- Pour vérifier que l'admin a été créé, exécutez :
-- SELECT au.*, ua.email, ua.name as user_name
-- FROM admin_users au
-- JOIN users_app ua ON au.user_id = ua.id
-- WHERE au.role = 'admin';

