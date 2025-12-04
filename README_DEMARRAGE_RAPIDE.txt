═══════════════════════════════════════════════════════════════
  ⚡ DÉMARRAGE RAPIDE STRIPE - TOUT AUTOMATIQUE
═══════════════════════════════════════════════════════════════

✅ Configuration automatique complète :

   1. Exécutez : .\STRIPE_AUTO_SETUP.ps1
      → Crée les .env, installe les dépendances

   2. Exécutez : .\TOUT_DEMARRER.ps1
      → Démarre tous les services (3 fenêtres)

═══════════════════════════════════════════════════════════════
  📋 Scripts disponibles
═══════════════════════════════════════════════════════════════

   STRIPE_AUTO_SETUP.ps1     → Configuration complète automatique
   TOUT_DEMARRER.ps1         → Démarre tout en une fois
   demarrer-backend.ps1      → Backend uniquement
   demarrer-frontend.ps1     → Frontend uniquement
   demarrer-webhooks.ps1     → Webhooks Stripe

═══════════════════════════════════════════════════════════════
  ⚠️  IMPORTANT - Webhooks
═══════════════════════════════════════════════════════════════

   Si c'est votre première fois :

   1. Installez Stripe CLI :
      scoop bucket add stripe https://github.com/stripe/scoop-stripe-cli.git
      scoop install stripe

   2. Connectez-vous :
      stripe login

   3. Le secret 'whsec_...' apparaîtra quand vous lancez les webhooks
   4. Ajoutez-le dans server/.env comme STRIPE_WEBHOOK_SECRET

═══════════════════════════════════════════════════════════════
  🧪 TESTER
═══════════════════════════════════════════════════════════════

   URL : http://localhost:5173
   Carte test : 4242 4242 4242 4242
   Date : 12/25
   CVC : 123

═══════════════════════════════════════════════════════════════


