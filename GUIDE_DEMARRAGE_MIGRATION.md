# 🚀 Guide de démarrage rapide - Migration Supabase

## Étape 1 : Exécuter le script SQL

1. Ouvrez votre projet Supabase
2. Allez dans **SQL Editor**
3. Copiez-collez le contenu de `CREATE_MISSING_TABLES_RLS.sql`
4. Cliquez sur **Run** (ou Ctrl+Enter)

## Étape 2 : Vérifier les tables créées

Dans Supabase SQL Editor, exécutez :

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('actors', 'invoice_history', 'admin_decision_criteria', 'reference_data')
ORDER BY table_name;
```

Vous devriez voir les 4 tables listées.

## Étape 3 : Vérifier les politiques RLS

```sql
SELECT 
  tablename,
  policyname,
  cmd as "Operation"
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('actors', 'invoice_history', 'admin_decision_criteria', 'reference_data')
ORDER BY tablename, policyname;
```

Vous devriez voir plusieurs politiques pour chaque table.

## Étape 4 : Créer le premier admin (si nécessaire)

Si vous n'avez pas encore d'admin :

1. Exécutez `CREATE_FIRST_ADMIN.sql` dans Supabase SQL Editor
2. Remplacez `'VOTRE_EMAIL@example.com'` par votre email
3. Connectez-vous avec cet email pour accéder aux fonctions admin

## Étape 5 : Tester l'application

1. **Test d'isolation** :
   - Créez un compte utilisateur A
   - Créez des acteurs, générez des factures
   - Créez un compte utilisateur B
   - Vérifiez que B ne voit pas les données de A

2. **Test des données de référence** :
   - Connectez-vous avec un utilisateur normal
   - Vérifiez que vous pouvez voir TEC/VOC/TarifPORT
   - Essayez de modifier → doit afficher "admin requis"
   - Connectez-vous avec un admin
   - Vérifiez que vous pouvez modifier

## ✅ Vérification finale

Si tout fonctionne :
- ✅ Les utilisateurs ne voient que leurs propres données
- ✅ Les admins peuvent modifier les données de référence
- ✅ Les données sont persistées dans Supabase
- ✅ Plus d'erreurs "Rendered more hooks"

## 🆘 En cas de problème

1. **Erreur RLS** : Vérifiez que les politiques sont créées (Étape 3)
2. **Données manquantes** : Vérifiez que les tables existent (Étape 2)
3. **Droits admin** : Vérifiez que vous avez créé un admin (Étape 4)
4. **Erreur de connexion** : Vérifiez vos variables d'environnement `.env`

---

**Migration prête ! 🎉**

