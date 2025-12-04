# 🤖 Guide d'Intégration OpenAI/GPT-4 pour le Chatbot IA

## 🎯 **Vue d'ensemble**

Le système de chatbot IA a été amélioré avec une intégration hybride qui combine :
- **IA Locale** : Réponses rapides et précises basées sur vos données de simulation
- **GPT-4** : Intelligence avancée pour les questions complexes et l'analyse contextuelle

## 🚀 **Fonctionnalités**

### **Système Hybride Intelligent**
- **Questions simples** → IA Locale (rapide, précise, basée sur vos données)
- **Questions complexes** → GPT-4 (analyse approfondie, conseils avancés)
- **Fallback automatique** → Si GPT-4 n'est pas disponible, utilise l'IA locale

### **Indicateurs Visuels**
- 🟡 **IA Locale** : Bot classique, réponses rapides
- 🟣 **GPT-4** : Icône Sparkles, analyse avancée
- ⚙️ **Configuration** : Bouton paramètres pour configurer OpenAI

## 🔧 **Configuration**

### **1. Obtenir une clé API OpenAI**

1. Visitez [platform.openai.com](https://platform.openai.com)
2. Créez un compte ou connectez-vous
3. Allez dans "API Keys"
4. Cliquez sur "Create new secret key"
5. Copiez la clé (commence par `sk-`)

### **2. Configuration dans l'application**

#### **Option A : Variable d'environnement (Recommandée)**
```bash
# Dans votre fichier .env
VITE_OPENAI_API_KEY=sk-your-openai-api-key-here
```

#### **Option B : Configuration via l'interface**
1. Ouvrez le chatbot IA
2. Cliquez sur l'icône ⚙️ dans le header
3. Entrez votre clé API OpenAI
4. Cliquez sur "Sauvegarder"

## 🎯 **Types de Questions et Réponses**

### **IA Locale (Rapide et Précis)**
✅ **Questions sur vos données spécifiques :**
- "Quel est le montant de la CAF de cette simulation ?"
- "Combien d'articles ai-je dans ma simulation ?"
- "Quel est le poids total de mes marchandises ?"
- "Quels sont les codes HS de mes produits ?"
- "Mon ratio coût/FOB est-il bon ?"

### **GPT-4 (Analyse Avancée)**
🧠 **Questions complexes et contextuelles :**
- "Comment optimiser ma stratégie d'importation ?"
- "Explique-moi les différences entre les incoterms"
- "Quelle est la meilleure approche pour réduire les risques ?"
- "Comment créer un plan de mitigation personnalisé ?"
- "Analyse approfondie de ma simulation"
- "Guide détaillé pour négocier avec les fournisseurs"

## 🔄 **Logique de Routage Automatique**

Le système décide automatiquement quelle IA utiliser :

### **GPT-4 sera utilisé pour :**
- Questions contenant : "explique", "pourquoi", "comment", "guide", "tutoriel"
- Questions techniques : "réglementation", "loi", "procédure"
- Questions de comparaison : "différence", "mieux", "alternative"
- Questions longues (>100 caractères)
- Intention peu claire (confidence < 60%)

### **IA Locale sera utilisée pour :**
- Questions sur les coûts, articles, transport, incoterms
- Questions spécifiques à vos données de simulation
- Questions courtes et directes
- Intention clairement identifiée

## 💡 **Exemples d'Utilisation**

### **Questions pour l'IA Locale :**
```
"Quel est le montant de la CAF ?"
"Combien d'articles j'ai ?"
"Mon fret est-il élevé ?"
"Quels sont les codes HS ?"
"Analyser mes coûts"
```

### **Questions pour GPT-4 :**
```
"Comment puis-je optimiser ma stratégie d'importation pour réduire les coûts tout en minimisant les risques ?"
"Explique-moi en détail les avantages et inconvénients de chaque incoterm pour ma situation spécifique"
"Guide-moi dans la création d'un plan de mitigation des risques personnalisé"
"Quelle est la meilleure approche pour négocier avec les fournisseurs chinois ?"
```

## 🛡️ **Sécurité et Confidentialité**

### **Données Sensibles**
- Les données de simulation sont envoyées à OpenAI pour le contexte
- Aucune donnée personnelle sensible n'est transmise
- Les clés API sont stockées localement dans le navigateur

### **Recommandations**
- Utilisez des clés API avec des limites de dépenses
- Surveillez votre utilisation sur platform.openai.com
- Ne partagez jamais votre clé API

## 🔧 **Dépannage**

### **Problème : GPT-4 ne fonctionne pas**
- ✅ Vérifiez que votre clé API est correcte
- ✅ Vérifiez votre solde OpenAI
- ✅ Vérifiez votre connexion internet
- ✅ Le système basculera automatiquement sur l'IA locale

### **Problème : Réponses génériques**
- ✅ Assurez-vous que vos données de simulation sont complètes
- ✅ Posez des questions plus spécifiques
- ✅ Utilisez les mots-clés recommandés

### **Problème : Erreurs de configuration**
- ✅ Vérifiez le format de la clé API (doit commencer par `sk-`)
- ✅ Redémarrez l'application après configuration
- ✅ Vérifiez la console du navigateur pour les erreurs

## 📊 **Métriques et Monitoring**

### **Indicateurs dans l'Interface**
- **Source de la réponse** : Local, OpenAI, ou Fallback
- **Niveau de confiance** : De 0.1 à 1.0
- **Temps de réponse** : Affiché pour chaque message

### **Logs de Debug**
```javascript
// Dans la console du navigateur
console.log('Source:', response.source);
console.log('Confidence:', response.confidence);
```

## 🎯 **Bonnes Pratiques**

### **Pour des Réponses Optimales**
1. **Soyez spécifique** : "Analyse mon transport" plutôt que "Aide-moi"
2. **Utilisez le contexte** : "Pour ma simulation de téléphones..."
3. **Posez des questions ciblées** : "Comment réduire mon fret de 20% ?"

### **Pour Économiser sur OpenAI**
1. **Utilisez l'IA locale** pour les questions simples
2. **Évitez les questions trop longues** sans contexte
3. **Regroupez vos questions** plutôt que de les poser séparément

## 🚀 **Évolutions Futures**

### **Fonctionnalités Prévues**
- [ ] Support de GPT-4 Turbo pour des réponses plus rapides
- [ ] Cache intelligent des réponses fréquentes
- [ ] Analyse de sentiment des conversations
- [ ] Recommandations personnalisées basées sur l'historique
- [ ] Export des conversations en PDF

### **Améliorations Techniques**
- [ ] Optimisation des prompts pour réduire les tokens
- [ ] Compression des données de contexte
- [ ] Support de plusieurs modèles OpenAI
- [ ] Intégration avec d'autres IA (Claude, Gemini)

---

## 📞 **Support**

Pour toute question ou problème :
1. Vérifiez ce guide
2. Consultez la console du navigateur
3. Testez avec l'IA locale d'abord
4. Contactez le support technique

**Le système hybride garantit une expérience optimale même sans OpenAI configuré !** 🎉
