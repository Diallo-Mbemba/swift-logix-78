-- ============================================
-- FIX: Impossible de créer un nouvel acteur
-- ============================================
-- Ce script vérifie et corrige les problèmes qui empêchent la création d'acteurs
-- ============================================

-- 1. Vérifier que la table actors existe
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'actors'
  ) THEN
    RAISE NOTICE '⚠️ La table actors n''existe pas. Création...';
    
    -- Créer la table
    CREATE TABLE actors (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES users_app(id) ON DELETE CASCADE,
      nom VARCHAR(255) NOT NULL,
      adresse TEXT NOT NULL,
      telephone VARCHAR(50),
      email VARCHAR(255),
      type VARCHAR(50) NOT NULL CHECK (type IN ('importateur', 'fournisseur', 'transitaire')),
      zone VARCHAR(100),
      pays VARCHAR(2),
      created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
      updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );
    
    RAISE NOTICE '✅ Table actors créée';
  ELSE
    RAISE NOTICE '✅ La table actors existe déjà';
  END IF;
END $$;

-- 2. Vérifier et ajouter les colonnes manquantes
DO $$
BEGIN
  -- Vérifier si user_id existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'actors' 
    AND column_name = 'user_id'
  ) THEN
    ALTER TABLE actors ADD COLUMN user_id UUID REFERENCES users_app(id) ON DELETE CASCADE;
    RAISE NOTICE '✅ Colonne user_id ajoutée';
  END IF;
  
  -- Vérifier si nom existe (au lieu de name)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'actors' 
    AND column_name = 'nom'
  ) THEN
    -- Si name existe, le renommer en nom
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'actors' 
      AND column_name = 'name'
    ) THEN
      ALTER TABLE actors RENAME COLUMN name TO nom;
      RAISE NOTICE '✅ Colonne name renommée en nom';
    ELSE
      ALTER TABLE actors ADD COLUMN nom VARCHAR(255);
      RAISE NOTICE '✅ Colonne nom ajoutée';
    END IF;
  END IF;
  
  -- Vérifier si adresse existe (au lieu de address)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'actors' 
    AND column_name = 'adresse'
  ) THEN
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'actors' 
      AND column_name = 'address'
    ) THEN
      ALTER TABLE actors RENAME COLUMN address TO adresse;
      RAISE NOTICE '✅ Colonne address renommée en adresse';
    ELSE
      ALTER TABLE actors ADD COLUMN adresse TEXT;
      RAISE NOTICE '✅ Colonne adresse ajoutée';
    END IF;
  END IF;
  
  -- Vérifier si telephone existe (au lieu de phone)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'actors' 
    AND column_name = 'telephone'
  ) THEN
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'actors' 
      AND column_name = 'phone'
    ) THEN
      ALTER TABLE actors RENAME COLUMN phone TO telephone;
      RAISE NOTICE '✅ Colonne phone renommée en telephone';
    ELSE
      ALTER TABLE actors ADD COLUMN telephone VARCHAR(50);
      RAISE NOTICE '✅ Colonne telephone ajoutée';
    END IF;
  END IF;
  
  -- Vérifier si zone existe
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'actors' 
    AND column_name = 'zone'
  ) THEN
    ALTER TABLE actors ADD COLUMN zone VARCHAR(100);
    RAISE NOTICE '✅ Colonne zone ajoutée';
  END IF;
  
  -- Vérifier si pays existe (au lieu de country)
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'actors' 
    AND column_name = 'pays'
  ) THEN
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_schema = 'public' 
      AND table_name = 'actors' 
      AND column_name = 'country'
    ) THEN
      ALTER TABLE actors RENAME COLUMN country TO pays;
      RAISE NOTICE '✅ Colonne country renommée en pays';
    ELSE
      ALTER TABLE actors ADD COLUMN pays VARCHAR(2);
      RAISE NOTICE '✅ Colonne pays ajoutée';
    END IF;
  END IF;
END $$;

-- 3. S'assurer que user_id est NOT NULL
ALTER TABLE actors 
  ALTER COLUMN user_id SET NOT NULL;

-- 4. Modifier le type si nécessaire
ALTER TABLE actors 
  DROP CONSTRAINT IF EXISTS actors_type_check;
ALTER TABLE actors 
  ADD CONSTRAINT actors_type_check CHECK (type IN ('importateur', 'fournisseur', 'transitaire'));

-- 5. Créer les index
CREATE INDEX IF NOT EXISTS idx_actors_user_id ON actors(user_id);
CREATE INDEX IF NOT EXISTS idx_actors_type ON actors(type);
CREATE INDEX IF NOT EXISTS idx_actors_nom ON actors(nom);

-- 6. Créer le trigger pour updated_at
CREATE OR REPLACE FUNCTION update_actors_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_actors_updated_at_trigger ON actors;
CREATE TRIGGER update_actors_updated_at_trigger
  BEFORE UPDATE ON actors
  FOR EACH ROW
  EXECUTE FUNCTION update_actors_updated_at();

-- 7. Activer RLS
ALTER TABLE actors ENABLE ROW LEVEL SECURITY;

-- 8. Supprimer les anciennes politiques
DROP POLICY IF EXISTS "Users can view own actors" ON actors;
DROP POLICY IF EXISTS "Users can insert own actors" ON actors;
DROP POLICY IF EXISTS "Users can update own actors" ON actors;
DROP POLICY IF EXISTS "Users can delete own actors" ON actors;

-- 9. Créer les politiques RLS
CREATE POLICY "Users can view own actors" ON actors
  FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own actors" ON actors
  FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own actors" ON actors
  FOR UPDATE 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own actors" ON actors
  FOR DELETE 
  USING (auth.uid() = user_id);

-- 10. Permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON actors TO postgres, anon, authenticated, service_role;

-- ============================================
-- VÉRIFICATIONS
-- ============================================

-- Vérifier la structure de la table
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'actors'
ORDER BY ordinal_position;

-- Vérifier les politiques RLS
SELECT 
  policyname,
  cmd,
  qual as "Condition USING",
  with_check as "Condition WITH CHECK"
FROM pg_policies
WHERE schemaname = 'public' 
AND tablename = 'actors'
ORDER BY policyname;

-- Vérifier que RLS est activé
SELECT 
  relname as "Table",
  CASE 
    WHEN relrowsecurity THEN '✅ Activé'
    ELSE '❌ Désactivé'
  END as "RLS Status"
FROM pg_class
WHERE relname = 'actors';

