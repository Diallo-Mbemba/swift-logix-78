# Guide - Gestion des Comptes Admin et Caissiers

## 🎯 Vue d'Ensemble

Ce système permet à un **administrateur système** de créer et gérer des comptes **caissiers** via une interface web. Les caissiers peuvent ensuite valider les commandes à la caisse OIC.

## 📋 Prérequis

1. **Compte utilisateur existant** : L'utilisateur doit d'abord s'inscrire via l'interface d'inscription pour créer son compte dans `users_app`
2. **Compte admin système** : Un premier compte admin doit être créé manuellement via SQL

## 🔧 Étape 1 : Créer le Premier Compte Admin Système

### Option A : Via SQL (Recommandé)

1. **Inscrivez-vous** d'abord via l'interface d'inscription avec l'email qui sera admin
2. Ouvrez le **SQL Editor** dans Supabase
3. Ouvrez le fichier `CREATE_FIRST_ADMIN.sql`
4. **Remplacez** :
   - `EMAIL_DE_L_ADMIN` par l'email de l'utilisateur
   - `NOM_DE_L_ADMIN` par le nom de l'admin
5. **Exécutez** le script

### Option B : Via l'Interface (Si vous avez déjà un admin)

Si vous avez déjà un compte admin, vous pouvez créer d'autres admins via l'interface web (fonctionnalité à ajouter si nécessaire).

### Vérification

Pour vérifier que l'admin a été créé :

```sql
SELECT au.*, ua.email, ua.name as user_name
FROM admin_users au
JOIN users_app ua ON au.user_id = ua.id
WHERE au.role = 'admin';
```

## 🎨 Étape 2 : Utiliser l'Interface de Gestion des Caissiers

### Accéder à la Page

1. **Connectez-vous** avec le compte admin système
2. Allez sur `/admin/cashiers` dans votre navigateur
3. Vous verrez la page de gestion des caissiers

### Créer un Nouveau Caissier

1. Cliquez sur **"Nouveau Caissier"**
2. Dans le modal :
   - **Recherchez un utilisateur** par email ou nom
   - **Sélectionnez** l'utilisateur dans les résultats
   - Le nom et l'email seront pré-remplis automatiquement
   - Cliquez sur **"Créer le caissier"**

⚠️ **Important** : L'utilisateur doit d'abord exister dans `users_app` (créé lors de l'inscription).

### Gérer les Caissiers Existants

- **Modifier** : Cliquez sur l'icône ✏️ (Edit)
- **Activer/Désactiver** : Cliquez sur l'icône ✓ ou ✗
- **Supprimer** : Cliquez sur l'icône 🗑️ (Trash)

### Rechercher un Caissier

Utilisez la barre de recherche en haut pour filtrer par nom ou email.

## 🔐 Permissions et Sécurité

### Politiques RLS

Les politiques RLS suivantes sont nécessaires (déjà incluses dans `SUPABASE_SCHEMA.sql`) :

- **Admins can view all admin users** : Les admins peuvent voir tous les comptes admin/caissier
- **Admins can insert admin users** : Les admins peuvent créer de nouveaux comptes
- **Admins can update admin users** : Les admins peuvent modifier les comptes
- **Admins can delete admin users** : Les admins peuvent supprimer les comptes (via le service)

### Vérification des Permissions

Le système vérifie automatiquement :
- Si l'utilisateur connecté est un admin avant d'afficher la page
- Si l'utilisateur a les permissions nécessaires pour chaque action

## 📝 Structure des Données

### Table `admin_users`

```sql
CREATE TABLE admin_users (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users_app(id),
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  role TEXT CHECK (role IN ('admin', 'cashier')),
  permissions TEXT[],
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Permissions par Défaut

- **Admin** : `['manage_all', 'manage_cashiers', 'manage_orders', 'manage_users']`
- **Caissier** : `['validate_orders']`

## 🚀 Flux Complet

### 1. Créer un Compte Utilisateur

```
Utilisateur → Inscription → users_app créé automatiquement
```

### 2. Créer un Compte Caissier (par Admin)

```
Admin → /admin/cashiers → Recherche utilisateur → Création caissier
```

### 3. Utiliser le Compte Caissier

```
Caissier → Connexion → /oic-cashier → Validation commandes
```

## 🐛 Dépannage

### Erreur : "Vous n'avez pas les permissions nécessaires"

**Cause** : L'utilisateur n'est pas un admin.

**Solution** :
1. Vérifiez que l'utilisateur existe dans `admin_users` avec `role = 'admin'`
2. Vérifiez que `is_active = true`
3. Vérifiez que l'utilisateur est bien connecté

### Erreur : "L'utilisateur n'existe pas dans users_app"

**Cause** : L'utilisateur n'a pas encore créé de compte.

**Solution** : L'utilisateur doit d'abord s'inscrire via l'interface d'inscription.

### Erreur : "Cet utilisateur a déjà un compte administrateur/caissier"

**Cause** : L'utilisateur a déjà une entrée dans `admin_users`.

**Solution** : Utilisez la fonctionnalité de modification au lieu de création.

### La recherche d'utilisateurs ne retourne aucun résultat

**Cause** : Aucun utilisateur ne correspond à la recherche.

**Solution** :
1. Vérifiez l'orthographe
2. Vérifiez que l'utilisateur existe bien dans `users_app`
3. Essayez de rechercher par email complet

## 📚 Fichiers Créés

- `src/services/supabase/adminService.ts` : Service pour gérer les admin_users
- `src/components/Admin/CashierManagementPage.tsx` : Page de gestion des caissiers
- `CREATE_FIRST_ADMIN.sql` : Script pour créer le premier admin
- `GUIDE_ADMIN_CAISSIER.md` : Ce guide

## ✅ Checklist de Démarrage

- [ ] Créer le premier compte admin via `CREATE_FIRST_ADMIN.sql`
- [ ] Vérifier que l'admin peut accéder à `/admin/cashiers`
- [ ] Créer un compte utilisateur test (inscription)
- [ ] Créer un compte caissier test via l'interface
- [ ] Tester la connexion avec le compte caissier
- [ ] Tester la validation d'une commande par le caissier

## 🎯 Prochaines Étapes Possibles

- [ ] Ajouter une page de gestion des admins (similaire aux caissiers)
- [ ] Ajouter des permissions granulaires
- [ ] Ajouter un historique des actions admin
- [ ] Ajouter des notifications lors de la création/modification de comptes

