# Script pour modifier SEULEMENT la date de transaction
$filePath = "src\components\Simulator\SimulatorForm.tsx"
$content = Get-Content $filePath -Raw

# Obtenir la date du jour au format YYYY-MM-DD
$today = Get-Date -Format "yyyy-MM-dd"

# 1. Remplacer l'initialisation de dateTransaction
$oldInit = "    dateTransaction: '',"
$newInit = "    dateTransaction: '$today',"
$content = $content -replace [regex]::Escape($oldInit), $newInit

# 2. Remplacer SEULEMENT le champ de saisie de la date de transaction
# Rechercher le pattern spécifique pour la date de transaction
$pattern = '(name="dateTransaction"[^>]*?)onChange=\{handleInputChange\}[^>]*?onBlur=\{validateDates\}[^>]*?className="w-full px-3 py-2 bg-white border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-cote-ivoire-primary text-gray-800 placeholder-gray-500 font-bold text-lg"'
$replacement = '$1readOnly className="w-full px-3 py-2 bg-gray-100 border border-gray-300 rounded-md text-gray-600 font-bold text-lg cursor-not-allowed"'

$content = $content -replace $pattern, $replacement

# Sauvegarder le fichier modifié
Set-Content $filePath -Value $content -Encoding UTF8

Write-Host "Modifications appliquées avec succès !"
Write-Host "Seule la date de transaction est verrouillée sur: $today"
Write-Host "La date de facture reste modifiable"
