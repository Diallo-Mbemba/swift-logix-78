@echo off
echo 🔧 Nettoyage du projet en cours...

rmdir /s /q node_modules
rmdir /s /q dist
rmdir /s /q .vite
rmdir /s /q .next

del package-lock.json
del yarn.lock
del pnpm-lock.yaml

echo 📦 Réinstallation des dépendances...
npm install

echo 🚀 Lancement de Cursor avec plus de mémoire...
setx NODE_OPTIONS "--max-old-space-size=4096"
start cursor.exe

echo ✅ Tout est prêt !
pause
