-- ============================================
-- SCRIPT : Créer le profil utilisateur manuellement
-- ============================================
-- Utilisez ce script si le profil n'existe pas dans users_app
-- ============================================

-- ÉTAPE 1 : Vérifier que la table users_app existe
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'users_app'
) as table_exists;

-- ÉTAPE 2 : Vérifier si le profil existe déjà
SELECT 
  id,
  email,
  name,
  plan,
  remaining_credits,
  total_credits
FROM users_app
WHERE email = 'diallombemba7@gmail.com';

-- ÉTAPE 3 : Récupérer l'ID de l'utilisateur depuis auth.users
SELECT 
  id,
  email,
  raw_user_meta_data->>'name' as name_from_metadata
FROM auth.users
WHERE email = 'diallombemba7@gmail.com';

-- ÉTAPE 4 : Créer le profil utilisateur manuellement
-- Remplacez les valeurs suivantes :
-- - 'USER_ID_FROM_AUTH' : L'ID de l'utilisateur depuis auth.users (ÉTAPE 3)
-- - 'diallombemba7@gmail.com' : L'email de l'utilisateur
-- - 'Nom Utilisateur' : Le nom de l'utilisateur (ou depuis raw_user_meta_data)

INSERT INTO users_app (
  id,
  email,
  name,
  plan,
  remaining_credits,
  total_credits
)
VALUES (
  (SELECT id FROM auth.users WHERE email = 'diallombemba7@gmail.com'),
  'diallombemba7@gmail.com',
  COALESCE(
    (SELECT raw_user_meta_data->>'name' FROM auth.users WHERE email = 'diallombemba7@gmail.com'),
    SPLIT_PART('diallombemba7@gmail.com', '@', 1)
  ),
  'free',
  3,
  3
)
ON CONFLICT (id) DO UPDATE
SET 
  email = EXCLUDED.email,
  name = COALESCE(EXCLUDED.name, users_app.name),
  updated_at = NOW();

-- ÉTAPE 5 : Vérifier que le profil a été créé
SELECT 
  id,
  email,
  name,
  plan,
  remaining_credits,
  total_credits,
  created_at
FROM users_app
WHERE email = 'diallombemba7@gmail.com';

-- ============================================
-- CRÉER LE PROFIL POUR TOUS LES UTILISATEURS MANQUANTS
-- ============================================
-- Si plusieurs utilisateurs n'ont pas de profil, utilisez ce script :

INSERT INTO users_app (
  id,
  email,
  name,
  plan,
  remaining_credits,
  total_credits
)
SELECT 
  au.id,
  au.email,
  COALESCE(
    au.raw_user_meta_data->>'name',
    SPLIT_PART(au.email, '@', 1)
  ) as name,
  'free' as plan,
  3 as remaining_credits,
  3 as total_credits
FROM auth.users au
LEFT JOIN users_app ua ON au.id = ua.id
WHERE ua.id IS NULL
ON CONFLICT (id) DO NOTHING;

