# 🔧 Correction - Boucle infinie lors de la connexion

## ❌ Problème identifié

Lorsque l'utilisateur saisit ses identifiants, le système tourne indéfiniment sans se connecter. Cela était causé par :

1. **Appels multiples à `loadUserProfile`** : La fonction était appelée dans `login`, `onAuthStateChange`, etc.
2. **Boucle infinie** : Si le profil n'existait pas, `loadUserProfile` mettait `isAuthenticated: false`, ce qui déclenchait `onAuthStateChange` à nouveau
3. **Pas de garde-fou** : Aucune protection contre les appels multiples simultanés

## ✅ Corrections apportées

### 1. Ajout d'un paramètre `createIfMissing`

La fonction `loadUserProfile` accepte maintenant un paramètre pour contrôler quand créer le profil automatiquement :

```typescript
loadUserProfile(userId: string, createIfMissing: boolean = false)
```

- `createIfMissing: false` : Ne crée pas le profil (utilisé dans `onAuthStateChange` pour éviter les boucles)
- `createIfMissing: true` : Crée le profil s'il manque (utilisé dans `login`)

### 2. Simplification de la logique de connexion

La fonction `login` a été simplifiée pour éviter les appels multiples :

```typescript
const login = async (email: string, password: string): Promise<boolean> => {
  setLoading(true);
  const result = await authService.signIn(email, password);
  
  if (result.user) {
    await new Promise(resolve => setTimeout(resolve, 1000));
    await loadUserProfile(result.user.id, true); // Créer si manquant
  }
  
  return true;
};
```

### 3. Protection contre les boucles dans `onAuthStateChange`

`onAuthStateChange` n'essaie plus de créer le profil automatiquement :

```typescript
supabase.auth.onAuthStateChange(async (event, session) => {
  if (session?.user) {
    await loadUserProfile(session.user.id, false); // Ne pas créer ici
  }
});
```

### 4. Ajout d'un flag `mounted`

Un flag `mounted` empêche les mises à jour après le démontage du composant.

## 🚀 Vérifications à faire

### 1. Vérifier que le profil existe dans la base

1. Allez dans Supabase **Table Editor** > `users_app`
2. Vérifiez que votre utilisateur a un profil
3. Si non, exécutez `CREATE_MISSING_PROFILES.sql`

### 2. Vérifier les logs de la console

Ouvrez la console du navigateur (F12) et regardez :
- Les messages de chargement du profil
- Les erreurs éventuelles
- Les tentatives de création automatique

### 3. Tester la connexion

1. Redémarrez l'application
2. Essayez de vous connecter
3. Le système devrait :
   - Se connecter rapidement
   - Créer le profil automatiquement s'il manque
   - Ne plus tourner indéfiniment

## 📝 Si le problème persiste

Si le système tourne toujours indéfiniment :

1. **Vérifiez que le profil existe** :
   ```sql
   SELECT * FROM users_app WHERE email = 'votre@email.com';
   ```

2. **Créez le profil manuellement** si nécessaire :
   ```sql
   INSERT INTO users_app (id, email, name, plan, remaining_credits, total_credits)
   SELECT 
     u.id,
     u.email,
     COALESCE(u.raw_user_meta_data->>'name', split_part(u.email, '@', 1)),
     'free',
     3,
     3
   FROM auth.users u
   WHERE u.email = 'votre@email.com'
   AND NOT EXISTS (SELECT 1 FROM users_app WHERE id = u.id);
   ```

3. **Vérifiez les politiques RLS** :
   - Allez dans **Table Editor** > `users_app` > **Policies**
   - Vérifiez que les politiques permettent la lecture du profil

4. **Vérifiez les erreurs dans la console** :
   - Ouvrez la console (F12)
   - Regardez les erreurs Supabase
   - Notez les codes d'erreur (PGRST116, etc.)

## ✅ Résultat attendu

Après ces corrections :
- ✅ La connexion se fait rapidement
- ✅ Le profil est créé automatiquement s'il manque
- ✅ Plus de boucle infinie
- ✅ `loading` passe à `false` correctement

