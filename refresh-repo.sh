#!/usr/bin/env bash
# Script para atualizar fork do Oh-My-Bash e rebasear a branch de customizações

set -e  # Para o script se houver erro
set -o pipefail

# Nome da branch principal do upstream
UPSTREAM_BRANCH="master"

# Nome da sua branch de customizações
CUSTOM_BRANCH="customize"

echo "Atualizando repositório do upstream..."

# Pega as atualizações do upstream
git fetch upstream

# Volta para a branch main do fork
git checkout main

# Mescla as mudanças do upstream na main
git merge "upstream/$UPSTREAM_BRANCH"

echo "Main atualizada com o upstream."

# Atualiza a branch de customizações
git checkout "$CUSTOM_BRANCH"

# Rebase da sua branch de customizações em cima da main atualizada
git rebase main

echo "Branch '$CUSTOM_BRANCH' rebaseada em main."

echo "Atualização concluída! Agora você pode testar e fazer push para seu fork:"
echo "git push origin $CUSTOM_BRANCH --force"

