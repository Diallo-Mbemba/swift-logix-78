# 🚀 Guide de Connexion Supabase - Application KPrague

## 📋 Table des Matières

1. [Création du Projet Supabase](#1-création-du-projet-supabase)
2. [Configuration de la Base de Données](#2-configuration-de-la-base-de-données)
3. [Configuration de l'Authentification](#3-configuration-de-lauthentification)
4. [Configuration de l'Application](#4-configuration-de-lapplication)
5. [Intégration du Code](#5-intégration-du-code)
6. [Test et Déploiement](#6-test-et-déploiement)
7. [Dépannage](#7-dépannage)

---

## 1. Création du Projet Supabase

### 1.1 Créer un Compte Supabase
1. Aller sur [https://supabase.com](https://supabase.com)
2. Cliquer sur "Start your project"
3. Se connecter avec GitHub ou créer un compte

### 1.2 Créer un Nouveau Projet
1. Cliquer sur "New Project"
2. Choisir votre organisation
3. Remplir les informations :
   - **Nom du projet** : `kprague-simulation`
   - **Mot de passe de la base de données** : `VotreMotDePasseSecurise123!`
   - **Région** : `West Europe` (recommandé pour l'Europe)
4. Cliquer sur "Create new project"

### 1.3 Récupérer les Clés d'API
1. Aller dans **Settings** > **API**
2. Noter les informations suivantes :
   - **Project URL** : `https://your-project-id.supabase.co`
   - **anon public** : `your-anon-key-here`
   - **service_role secret** : `your-service-role-key` (garder secret)

---

## 2. Configuration de la Base de Données

### 2.1 Exécuter le Schéma SQL
1. Aller dans **SQL Editor**
2. Cliquer sur "New query"
3. Copier tout le contenu du fichier `SUPABASE_SCHEMA.txt`
4. Cliquer sur "Run" pour exécuter le script

### 2.2 Vérifier les Tables Créées
1. Aller dans **Table Editor**
2. Vérifier que toutes les tables sont créées :
   - `users`
   - `simulations`
   - `simulation_articles`
   - `actors`
   - `tec_articles`
   - `voc_products`
   - `tarifport_products`
   - `currencies`
   - `incoterms`
   - `subscriptions`
   - `payments`
   - `user_settings`
   - `simulation_logs`

### 2.3 Vérifier les Politiques RLS
1. Aller dans **Authentication** > **Policies**
2. Vérifier que toutes les tables ont RLS activé
3. Vérifier que les politiques sont créées correctement

---

## 3. Configuration de l'Authentification

### 3.1 Configurer les Providers
1. Aller dans **Authentication** > **Providers**
2. Activer **Email** (par défaut activé)
3. Optionnel : Activer **Google** ou **GitHub**

### 3.2 Configurer les Redirections
1. Aller dans **Authentication** > **URL Configuration**
2. Ajouter les URLs de redirection :
   - **Site URL** : `http://localhost:5173` (développement)
   - **Redirect URLs** :
     - `http://localhost:5173/auth/callback`
     - `http://localhost:5173/dashboard`
     - `https://votre-domaine.com/auth/callback` (production)

### 3.3 Configurer les Templates d'Email
1. Aller dans **Authentication** > **Email Templates**
2. Personnaliser les templates :
   - **Confirm signup**
   - **Invite user**
   - **Magic Link**
   - **Change email address**
   - **Reset password**

---

## 4. Configuration de l'Application

### 4.1 Installer les Dépendances
```bash
# Installer le client Supabase
npm install @supabase/supabase-js

# Installer les hooks React
npm install @supabase/auth-helpers-react

# Installer les utilitaires
npm install react-hook-form @hookform/resolvers yup
```

### 4.2 Créer les Variables d'Environnement
Créer le fichier `.env.local` :
```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_APP_NAME=KPrague - Simulation de Coûts d'Importation
VITE_APP_ENVIRONMENT=development
```

### 4.3 Créer le Client Supabase
Créer le fichier `src/lib/supabase.ts` :
```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Variables d\'environnement Supabase manquantes')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  }
})
```

---

## 5. Intégration du Code

### 5.1 Mettre à Jour le Main.tsx
```typescript
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { AuthProvider } from './contexts/AuthContext'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AuthProvider>
      <App />
    </AuthProvider>
  </React.StrictMode>,
)
```

### 5.2 Créer le Contexte d'Authentification
Créer le fichier `src/contexts/AuthContext.tsx` :
```typescript
import React, { createContext, useContext, useEffect, useState } from 'react'
import { User, Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'

interface AuthContextType {
  user: User | null
  session: Session | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<void>
  signUp: (email: string, password: string, name: string) => Promise<void>
  signOut: () => Promise<void>
  resetPassword: (email: string) => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Récupérer la session initiale
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)
    })

    // Écouter les changements d'authentification
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({
        email,
      password,
    })
    if (error) throw error
  }

  const signUp = async (email: string, password: string, name: string) => {
    const { error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            name,
        },
      },
    })
    if (error) throw error
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  const resetPassword = async (email: string) => {
    const { error } = await supabase.auth.resetPasswordForEmail(email)
    if (error) throw error
  }

  const value = {
    user,
    session,
    loading,
    signIn,
    signUp,
    signOut,
    resetPassword,
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
```

### 5.3 Créer les Hooks pour les Données
Créer le fichier `src/hooks/useSupabase.ts` :
```typescript
import { useState, useEffect } from 'react'
import { supabase } from '../lib/supabase'
import { useAuth } from '../contexts/AuthContext'

// Hook pour les simulations
export function useSimulations() {
  const [simulations, setSimulations] = useState([])
  const [loading, setLoading] = useState(true)
  const { user } = useAuth()

  useEffect(() => {
    if (user) {
      fetchSimulations()
    }
  }, [user])

  const fetchSimulations = async () => {
    try {
      const { data, error } = await supabase
        .from('simulations')
        .select('*')
        .eq('user_id', user?.id)
        .order('created_at', { ascending: false })

      if (error) throw error
      setSimulations(data || [])
    } catch (error) {
      console.error('Erreur lors de la récupération des simulations:', error)
    } finally {
      setLoading(false)
    }
  }

  const createSimulation = async (simulationData: any) => {
    try {
      const { data, error } = await supabase
        .from('simulations')
        .insert([{ ...simulationData, user_id: user?.id }])
        .select()

      if (error) throw error
      await fetchSimulations()
      return data[0]
    } catch (error) {
      console.error('Erreur lors de la création de la simulation:', error)
      throw error
    }
  }

  const updateSimulation = async (id: string, updates: any) => {
    try {
      const { data, error } = await supabase
        .from('simulations')
        .update(updates)
        .eq('id', id)
        .eq('user_id', user?.id)
        .select()

      if (error) throw error
      await fetchSimulations()
      return data[0]
    } catch (error) {
      console.error('Erreur lors de la mise à jour de la simulation:', error)
      throw error
    }
  }

  const deleteSimulation = async (id: string) => {
    try {
      const { error } = await supabase
        .from('simulations')
        .delete()
        .eq('id', id)
        .eq('user_id', user?.id)

      if (error) throw error
      await fetchSimulations()
    } catch (error) {
      console.error('Erreur lors de la suppression de la simulation:', error)
      throw error
    }
  }

  return {
      simulations,
    loading,
    createSimulation,
      updateSimulation,
      deleteSimulation,
    refetch: fetchSimulations,
  }
}

// Hook pour les données de référence
export function useReferenceData() {
  const [tecArticles, setTecArticles] = useState([])
  const [vocProducts, setVocProducts] = useState([])
  const [tarifportProducts, setTarifportProducts] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchReferenceData()
  }, [])

  const fetchReferenceData = async () => {
    try {
      const [tecResult, vocResult, tarifportResult] = await Promise.all([
        supabase.from('tec_articles').select('*'),
        supabase.from('voc_products').select('*'),
        supabase.from('tarifport_products').select('*'),
      ])

      if (tecResult.error) throw tecResult.error
      if (vocResult.error) throw vocResult.error
      if (tarifportResult.error) throw tarifportResult.error

      setTecArticles(tecResult.data || [])
      setVocProducts(vocResult.data || [])
      setTarifportProducts(tarifportResult.data || [])
    } catch (error) {
      console.error('Erreur lors de la récupération des données de référence:', error)
    } finally {
      setLoading(false)
    }
  }

  return {
    tecArticles,
    vocProducts,
    tarifportProducts,
    loading,
    refetch: fetchReferenceData,
  }
}
```

---

## 6. Test et Déploiement

### 6.1 Tester l'Application
1. Démarrer l'application : `npm run dev`
2. Tester l'inscription d'un utilisateur
3. Tester la connexion
4. Tester la création d'une simulation
5. Vérifier que les données sont sauvegardées dans Supabase

### 6.2 Vérifier les Données
1. Aller dans **Table Editor** dans Supabase
2. Vérifier que les données sont créées dans les tables
3. Vérifier que les politiques RLS fonctionnent

### 6.3 Configuration de Production
1. Créer un fichier `.env.production`
2. Mettre à jour les URLs de redirection dans Supabase
3. Configurer le domaine de production

---

## 7. Dépannage

### 7.1 Erreurs Courantes

**Erreur : "Variables d'environnement Supabase manquantes"**
- Vérifier que le fichier `.env.local` existe
- Vérifier que les variables sont correctement nommées
- Redémarrer le serveur de développement

**Erreur : "RLS policy violation"**
- Vérifier que l'utilisateur est connecté
- Vérifier que les politiques RLS sont correctement configurées
- Vérifier que l'utilisateur a les bonnes permissions

**Erreur : "Network error"**
- Vérifier la connexion internet
- Vérifier que l'URL Supabase est correcte
- Vérifier que la clé API est valide

### 7.2 Logs et Debug
1. Ouvrir les outils de développement du navigateur
2. Aller dans l'onglet **Console**
3. Vérifier les erreurs et les logs
4. Utiliser `console.log()` pour déboguer

### 7.3 Support
- Documentation Supabase : [https://supabase.com/docs](https://supabase.com/docs)
- Discord Supabase : [https://discord.supabase.com](https://discord.supabase.com)
- GitHub Issues : [https://github.com/supabase/supabase](https://github.com/supabase/supabase)

---

## 🎉 Félicitations !

Votre application KPrague est maintenant connectée à Supabase ! 

Vous pouvez :
- ✅ Créer des comptes utilisateurs
- ✅ Gérer l'authentification
- ✅ Sauvegarder les simulations
- ✅ Gérer les crédits
- ✅ Utiliser les données de référence

Pour la suite, vous pouvez :
1. Ajouter des fonctionnalités supplémentaires
2. Configurer les paiements Stripe
3. Optimiser les performances
4. Déployer en production

---

**Besoin d'aide ?** N'hésitez pas à consulter la documentation ou à demander de l'aide dans la communauté Supabase ! 