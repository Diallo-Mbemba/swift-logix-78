# 🔒 Guide - Activation Row Level Security (RLS)

## 📋 Qu'est-ce que RLS ?

Row Level Security (RLS) est une fonctionnalité de sécurité PostgreSQL qui permet de contrôler l'accès aux lignes d'une table en fonction de l'utilisateur qui effectue la requête. C'est essentiel pour la sécurité de votre application Supabase.

## 🚀 Activation RLS

### Méthode 1 : Script complet (Recommandé)

1. Allez sur https://supabase.com/dashboard
2. Sélectionnez votre projet
3. Ouvrez **SQL Editor**
4. Copiez-collez le contenu de `ACTIVER_RLS.sql`
5. Cliquez sur **Run** (ou F5)

Ce script va :
- ✅ Activer RLS sur toutes les tables
- ✅ Supprimer les anciennes politiques (si elles existent)
- ✅ Créer toutes les politiques nécessaires
- ✅ Vérifier que tout est correctement configuré

### Méthode 2 : Activation manuelle

Si vous préférez activer RLS manuellement :

1. Allez dans **Table Editor**
2. Pour chaque table :
   - Cliquez sur la table
   - Allez dans l'onglet **Policies** (ou **RLS**)
   - Activez **"Enable Row Level Security"**

## ✅ Vérification

Après avoir exécuté le script, vérifiez que RLS est bien activé :

1. Exécutez `VERIFIER_RLS.sql` dans SQL Editor
2. Vous devriez voir :
   - ✅ Activé pour toutes les tables
   - Le nombre de politiques pour chaque table

## 📊 Politiques RLS créées

### users_app
- **Users can view own profile** : Les utilisateurs peuvent voir leur propre profil
- **Users can update own profile** : Les utilisateurs peuvent mettre à jour leur propre profil
- **Allow service role to insert profiles** : Permet au trigger de créer les profils

### simulations
- **Users can view own simulations** : Les utilisateurs peuvent voir leurs propres simulations
- **Users can insert own simulations** : Les utilisateurs peuvent créer leurs propres simulations
- **Users can update own simulations** : Les utilisateurs peuvent modifier leurs propres simulations
- **Users can delete own simulations** : Les utilisateurs peuvent supprimer leurs propres simulations

### orders
- **Users can view own orders** : Les utilisateurs peuvent voir leurs propres commandes
- **Users can insert own orders** : Les utilisateurs peuvent créer leurs propres commandes
- **Users can update own orders** : Les utilisateurs peuvent modifier leurs propres commandes
- **Admins can view all orders** : Les admins peuvent voir toutes les commandes
- **Admins can update all orders** : Les admins peuvent modifier toutes les commandes

### order_validations
- **Admins and cashiers can view validations** : Les admins et caissiers peuvent voir les validations
- **Admins and cashiers can insert validations** : Les admins et caissiers peuvent créer des validations
- **Users can view own order validations** : Les utilisateurs peuvent voir les validations de leurs propres commandes

### credit_pools
- **Users can view own credit pools** : Les utilisateurs peuvent voir leurs propres pools de crédits
- **Users can insert own credit pools** : Les utilisateurs peuvent créer leurs propres pools
- **Users can update own credit pools** : Les utilisateurs peuvent modifier leurs propres pools

### credit_usage
- **Users can view own credit usage** : Les utilisateurs peuvent voir leur propre utilisation de crédits
- **Users can insert own credit usage** : Les utilisateurs peuvent créer des enregistrements d'utilisation

### settings
- **Users can view own settings** : Les utilisateurs peuvent voir leurs propres paramètres
- **Users can update own settings** : Les utilisateurs peuvent modifier leurs propres paramètres
- **Users can insert own settings** : Les utilisateurs peuvent créer leurs propres paramètres

### admin_users
- **Admins can view all admin users** : Les admins peuvent voir tous les admins
- **Admins can insert admin users** : Les admins peuvent créer de nouveaux admins
- **Admins can update admin users** : Les admins peuvent modifier les admins

## ⚠️ Important

### Sécurité

- **RLS est essentiel** : Sans RLS, tous les utilisateurs peuvent accéder à toutes les données
- **Testez après activation** : Vérifiez que votre application fonctionne toujours correctement
- **Vérifiez les politiques** : Assurez-vous que les politiques correspondent à vos besoins

### Trigger de création de profil

Le trigger `create_user_profile()` utilise `SECURITY DEFINER`, ce qui lui permet de contourner RLS. Cependant, une politique explicite a été ajoutée pour permettre l'insertion de profils lors de l'inscription.

### Service Role

Le service role (utilisé par les fonctions backend) peut contourner RLS. C'est normal et nécessaire pour certaines opérations système.

## 🔍 Dépannage

### Problème : "new row violates row-level security policy"

**Solution** : Vérifiez que :
1. RLS est activé sur la table
2. Une politique INSERT existe pour cette table
3. La politique permet l'insertion pour l'utilisateur actuel

### Problème : "permission denied for table"

**Solution** : Vérifiez que :
1. L'utilisateur est authentifié (`auth.uid()` n'est pas null)
2. Une politique SELECT existe pour cette table
3. La politique permet la lecture pour l'utilisateur actuel

### Problème : Les données ne s'affichent pas

**Solution** : Vérifiez que :
1. RLS est activé
2. Les politiques SELECT sont correctes
3. L'utilisateur est bien authentifié

## 📝 Commandes utiles

### Voir toutes les politiques
```sql
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

### Voir le statut RLS d'une table
```sql
SELECT relname, relrowsecurity 
FROM pg_class 
WHERE relname = 'nom_de_la_table';
```

### Désactiver RLS (⚠️ Non recommandé)
```sql
ALTER TABLE nom_de_la_table DISABLE ROW LEVEL SECURITY;
```

## ✅ Checklist

- [ ] RLS activé sur toutes les tables
- [ ] Politiques créées pour toutes les tables
- [ ] Test de connexion utilisateur
- [ ] Test de création de données
- [ ] Test de lecture de données
- [ ] Test de modification de données
- [ ] Test de suppression de données
- [ ] Vérification que les admins ont les bonnes permissions





