-- ============================================
-- CRÉER LES PROFILS MANQUANTS
-- ============================================
-- Ce script crée automatiquement les profils dans users_app
-- pour tous les utilisateurs qui existent dans auth.users
-- mais n'ont pas de profil dans users_app
-- ============================================

-- Créer les profils manquants pour tous les utilisateurs auth existants
INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
SELECT 
  u.id,
  u.email,
  COALESCE(
    u.raw_user_meta_data->>'name', 
    split_part(u.email, '@', 1)
  ) as name,
  'free' as plan,
  3 as remaining_credits,
  3 as total_credits
FROM auth.users u
WHERE NOT EXISTS (
  SELECT 1 FROM users_app ua WHERE ua.id = u.id
)
ON CONFLICT (id) DO NOTHING;

-- Afficher le résultat
SELECT 
  COUNT(*) as profils_crees
FROM users_app ua
WHERE ua.id IN (
  SELECT id FROM auth.users
);

-- ============================================
-- FIN DU SCRIPT
-- ============================================

