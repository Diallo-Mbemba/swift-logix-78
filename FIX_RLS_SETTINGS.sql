-- ============================================
-- FIX: RLS pour la table settings
-- ============================================
-- Ce script corrige les problèmes de permissions RLS
-- qui empêchent l'utilisateur d'accéder à ses paramètres
-- ============================================

-- 1. Supprimer les anciennes politiques pour settings (si elles existent)
DROP POLICY IF EXISTS "Users can view own settings" ON settings;
DROP POLICY IF EXISTS "Users can update own settings" ON settings;
DROP POLICY IF EXISTS "Users can insert own settings" ON settings;

-- 2. S'assurer que RLS est activé
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- 3. Créer la politique SELECT (lecture des paramètres)
CREATE POLICY "Users can view own settings" ON settings
  FOR SELECT 
  USING (auth.uid() = user_id);

-- 4. Créer la politique UPDATE (mise à jour des paramètres)
CREATE POLICY "Users can update own settings" ON settings
  FOR UPDATE 
  USING (auth.uid() = user_id);

-- 5. Créer la politique INSERT (création des paramètres)
CREATE POLICY "Users can insert own settings" ON settings
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- 6. Vérifier que les politiques sont créées
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'settings'
ORDER BY policyname;

-- 7. Vérifier que RLS est activé
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname = 'settings';

-- ============================================
-- NOTES IMPORTANTES
-- ============================================
-- 1. Les politiques RLS utilisent auth.uid() qui retourne l'ID de l'utilisateur authentifié
-- 2. Après avoir exécuté ce script, l'utilisateur devrait pouvoir accéder à ses paramètres
-- 3. Si l'utilisateur n'a pas encore de paramètres, ils seront créés automatiquement lors de la première sauvegarde

