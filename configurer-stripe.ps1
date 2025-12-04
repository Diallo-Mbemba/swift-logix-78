# Script PowerShell pour configurer automatiquement Stripe
# Usage: .\configurer-stripe.ps1

Write-Host "🔑 Configuration automatique de Stripe" -ForegroundColor Cyan
Write-Host ""

# Clés Stripe fournies
$PUBLIC_KEY = "pk_test_51SYfQuDpUNYp5tGjSvwwM05wod5r3b2UTzpeEZ9iZhgfm5r0BzLw4PAp2WbimzSpYsY9ShBZeZKGH5KMED0J5UCq001fMTwNjB"
$SECRET_KEY = "sk_test_51SYfQuDpUNYp5tGjepuKD4X8mCUym8aQ7oaODbdR2B1nrZvmNkmrntuZlmp74gyfMnoZxaBLRK1NHif5tDawtszk00SqMh3AXU"

# Contenu du fichier .env frontend
$FRONTEND_ENV = @"
# Stripe Configuration
VITE_STRIPE_PUBLISHABLE_KEY=$PUBLIC_KEY
VITE_STRIPE_SECRET_KEY=$SECRET_KEY
VITE_STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Application Configuration
VITE_APP_URL=http://localhost:5173
VITE_API_URL=http://localhost:3000/api

# Currency Configuration
VITE_DEFAULT_CURRENCY=XAF

# OpenAI Configuration (Optionnel)
VITE_OPENAI_API_KEY=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
"@

# Contenu du fichier .env backend
$BACKEND_ENV = @"
# Port du serveur
PORT=3000

# Stripe Secret Key (CÔTÉ SERVEUR UNIQUEMENT - NE JAMAIS EXPOSER)
STRIPE_SECRET_KEY=$SECRET_KEY

# Webhook Secret (obtenu après configuration du webhook avec Stripe CLI)
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# URL de l'application frontend
FRONTEND_URL=http://localhost:5173

# Mode
NODE_ENV=development
"@

# Fonction pour créer un fichier .env
function Create-EnvFile {
    param(
        [string]$Path,
        [string]$Content,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        Write-Host "⚠️  Le fichier existe déjà : $Path" -ForegroundColor Yellow
        $overwrite = Read-Host "Voulez-vous le remplacer ? (O/N)"
        if ($overwrite -ne "O" -and $overwrite -ne "o") {
            Write-Host "   Ignoré : $Path" -ForegroundColor Gray
            return
        }
    }
    
    try {
        $Content | Out-File -FilePath $Path -Encoding UTF8 -NoNewline
        Write-Host "✅ Créé : $Path" -ForegroundColor Green
        Write-Host "   $Description" -ForegroundColor Gray
    }
    catch {
        Write-Host "❌ Erreur lors de la création de $Path : $_" -ForegroundColor Red
    }
}

Write-Host "📝 Création des fichiers .env..." -ForegroundColor Cyan
Write-Host ""

# Créer le fichier .env à la racine
$rootEnvPath = Join-Path $PSScriptRoot ".env"
Create-EnvFile -Path $rootEnvPath -Content $FRONTEND_ENV -Description "Configuration frontend"

# Créer le dossier server s'il n'existe pas
$serverDir = Join-Path $PSScriptRoot "server"
if (-not (Test-Path $serverDir)) {
    Write-Host "⚠️  Le dossier 'server' n'existe pas. Création..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $serverDir | Out-Null
}

# Créer le fichier server/.env
$serverEnvPath = Join-Path $serverDir ".env"
Create-EnvFile -Path $serverEnvPath -Content $BACKEND_ENV -Description "Configuration backend"

Write-Host ""
Write-Host "✨ Configuration terminée !" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Prochaines étapes :" -ForegroundColor Cyan
Write-Host "   1. Installer les dépendances du backend :" -ForegroundColor White
Write-Host "      cd server && npm install" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Démarrer le serveur backend :" -ForegroundColor White
Write-Host "      cd server && npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Configurer les webhooks (nouveau terminal) :" -ForegroundColor White
Write-Host "      stripe listen --forward-to localhost:3000/api/webhooks/stripe" -ForegroundColor Gray
Write-Host ""
Write-Host "   4. Copier le webhook secret dans server/.env" -ForegroundColor White
Write-Host ""
Write-Host "   5. Démarrer le frontend :" -ForegroundColor White
Write-Host "      npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "📖 Consultez CONFIGURATION_STRIPE_CLES.md pour plus de détails" -ForegroundColor Cyan


