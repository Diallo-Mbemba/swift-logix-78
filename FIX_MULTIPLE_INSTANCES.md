# 🔧 Correction - Multiple GoTrueClient instances

## ❌ Problème

L'avertissement `Multiple GoTrueClient instances detected` indique que plusieurs instances du client Supabase sont créées, ce qui peut causer :
- Des comportements indéfinis
- Des appels multiples à `getUserProfile`
- Des problèmes de synchronisation de session

## ✅ Corrections apportées

### 1. Singleton pattern pour Supabase Client

Le client Supabase est maintenant créé une seule fois avec un pattern singleton :

```typescript
// src/lib/supabaseClient.ts
let supabaseInstance: SupabaseClient | null = null;

export const supabase = ((): SupabaseClient => {
  if (!supabaseInstance) {
    supabaseInstance = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: true,
        storageKey: 'k prague-auth', // Clé de stockage unique
      },
    });
  }
  return supabaseInstance;
})();
```

### 2. Suppression de l'instance dupliquée

L'instance Supabase créée dans `SimulatorForm.tsx` avec des clés hardcodées a été supprimée. Le composant utilise maintenant l'instance unique depuis `supabaseClient.ts`.

### 3. Garde-fou pour éviter les appels multiples

Un garde-fou a été ajouté pour éviter les appels multiples simultanés à `loadUserProfile` :

```typescript
const loadingProfileRef = React.useRef<string | null>(null);

const loadUserProfile = async (userId: string, createIfMissing: boolean = false) => {
  // Éviter les appels multiples pour le même utilisateur
  if (loadingProfileRef.current === userId) {
    return;
  }
  // ...
};
```

### 4. Filtrage des événements onAuthStateChange

Les événements `TOKEN_REFRESHED` et `SIGNED_OUT` sont maintenant ignorés pour éviter les rechargements inutiles du profil.

## 🚀 Résultat

Après ces corrections :
- ✅ Une seule instance Supabase dans toute l'application
- ✅ Plus d'avertissement "Multiple GoTrueClient instances"
- ✅ Moins d'appels multiples à `getUserProfile`
- ✅ Meilleure synchronisation de la session

## 📝 Vérification

Pour vérifier que tout fonctionne :

1. **Ouvrez la console du navigateur** (F12)
2. **Rechargez la page**
3. **Vérifiez qu'il n'y a plus l'avertissement** "Multiple GoTrueClient instances"
4. **Connectez-vous** et vérifiez les logs :
   - `🔐 Tentative de connexion pour: ...`
   - `✅ Connexion Supabase Auth réussie: ...`
   - `📥 Début du chargement du profil pour: ...`
   - `✅ Profil récupéré avec succès: ...`

Vous ne devriez voir qu'**un seul appel** à `getUserProfile` par connexion.





