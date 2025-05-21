#!/bin/bash

# URL da API para obter as informações de download
API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"

# Diretório de destino para a aplicação
# Usar ${HOME} para expansão correta do diretório home do usuário
APPDIR="${HOME}/Applications/cursor-ide"
FINAL_APPIMAGE_NAME="cursor-ide.AppImage"
DESTINATION_PATH="${APPDIR}/${FINAL_APPIMAGE_NAME}"

# --- Configurações do .desktop e Ícone ---
# Nome do arquivo de ícone que será salvo em APPDIR
ICON_FILENAME="cursor-ide.png"
# URL para baixar o ícone oficial do Cursor
ICON_URL="https://avatars.githubusercontent.com/u/126759922?s=48&v=4"
# Caminho completo para o arquivo de ícone salvo
ICON_DEST_PATH="${APPDIR}/${ICON_FILENAME}"
# Diretório e nome do arquivo .desktop
DESKTOP_FILE_DIR="${HOME}/.local/share/applications"
DESKTOP_FILE_NAME="cursor-ide.desktop"
DESKTOP_FILE_PATH="${DESKTOP_FILE_DIR}/${DESKTOP_FILE_NAME}"
# --- Fim das Configurações do .desktop e Ícone ---


echo "Script para baixar e instalar/atualizar o Cursor IDE"
echo "---------------------------------------------------"
echo "Diretório de instalação: ${DESTINATION_PATH}"
echo "Arquivo .desktop será criado em: ${DESKTOP_FILE_PATH}"
echo ""
echo "Buscando informações de download de: $API_URL"

# --- Verificações de dependências ---
if ! command -v jq &> /dev/null; then
    echo "Erro: jq não pôde ser encontrado. Por favor, instale o jq."
    echo "Exemplo (Debian/Ubuntu): sudo apt update && sudo apt install jq"
    echo "Exemplo (Fedora): sudo dnf install jq"
    echo "Exemplo (macOS com Homebrew): brew install jq"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "Erro: curl não pôde ser encontrado. Por favor, instale o curl."
    exit 1
fi

if ! command -v wget &> /dev/null; then
    echo "Erro: wget não pôde ser encontrado. Por favor, instale o wget."
    exit 1
fi
# --- Fim das verificações de dependências ---

# --- Obter URL de Download ---
JSON_RESPONSE=$(curl -s "$API_URL")
if [ -z "$JSON_RESPONSE" ]; then
    echo "Erro: Não foi possível obter resposta da API: $API_URL"
    exit 1
fi

DOWNLOAD_URL=$(echo "$JSON_RESPONSE" | jq -r '.downloadUrl')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" == "null" ]; then
    echo "Erro: Não foi possível obter a 'downloadUrl' da resposta da API."
    echo "Resposta da API:"
    echo "$JSON_RESPONSE"
    exit 1
fi
echo "URL de download encontrada: $DOWNLOAD_URL"
# --- Fim da obtenção da URL de Download ---

# Extrai o nome do arquivo como será baixado pelo wget (baseado na URL)
DOWNLOADED_FILENAME_ORIGINAL=$(basename "$DOWNLOAD_URL")
LOCAL_DOWNLOAD_PATH="./${DOWNLOADED_FILENAME_ORIGINAL}" # Temporário no diretório atual

echo "Nome do arquivo a ser baixado: ${DOWNLOADED_FILENAME_ORIGINAL}"
echo "Iniciando o download do AppImage..."

# Remover arquivo baixado anteriormente com o mesmo nome, se existir, para evitar problemas.
rm -f "${LOCAL_DOWNLOAD_PATH}"

# --- Download do Arquivo AppImage ---
if wget --progress=bar:force "$DOWNLOAD_URL" -O "${LOCAL_DOWNLOAD_PATH}"; then
    echo "" # Nova linha após a barra de progresso
    echo "Download de '${DOWNLOADED_FILENAME_ORIGINAL}' concluído com sucesso!"
else
    echo "" # Nova linha após possível saída de erro do wget
    echo "Erro: O download de '$DOWNLOAD_URL' falhou."
    rm -f "${LOCAL_DOWNLOAD_PATH}" # Tenta remover arquivo parcial, se houver
    exit 1
fi
# --- Fim do Download do Arquivo AppImage ---

# --- Instalação ---
# 1. Criar o diretório de destino se não existir
echo "Verificando/Criando o diretório de destino: ${APPDIR}"
if ! mkdir -p "${APPDIR}"; then
    echo "Erro: Não foi possível criar o diretório ${APPDIR}"
    echo "Limpando o arquivo baixado: ${LOCAL_DOWNLOAD_PATH}"
    rm -f "${LOCAL_DOWNLOAD_PATH}"
    exit 1
fi
echo "Diretório ${APPDIR} pronto."

# 2. Mover e renomear o arquivo baixado
echo "Movendo '${LOCAL_DOWNLOAD_PATH}' para '${DESTINATION_PATH}'"
if mv "${LOCAL_DOWNLOAD_PATH}" "${DESTINATION_PATH}"; then
    echo "Arquivo movido com sucesso para ${DESTINATION_PATH}."
else
    echo "Erro: Falha ao mover '${LOCAL_DOWNLOAD_PATH}' para '${DESTINATION_PATH}'."
    echo "Verifique as permissões e se o caminho é válido."
    echo "Limpando o arquivo baixado (se ainda existir): ${LOCAL_DOWNLOAD_PATH}"
    rm -f "${LOCAL_DOWNLOAD_PATH}" # Limpa o arquivo baixado que não pôde ser movido
    exit 1
fi

# 3. Tornar o AppImage executável
echo "Tornando '${DESTINATION_PATH}' executável..."
if chmod +x "${DESTINATION_PATH}"; then
    echo "'${DESTINATION_PATH}' agora é executável."
else
    echo "Erro: Falha ao tornar '${DESTINATION_PATH}' executável."
    # O arquivo já foi movido, apenas alertar. Não é crítico para o .desktop, mas o app não rodará.
    # Considerar reverter o mv ou deletar o destino se isso for um erro fatal.
    # Por ora, apenas alertar e continuar para a criação do .desktop.
fi
# --- Fim da Instalação ---

# --- Download do Ícone ---
echo "Baixando ícone de ${ICON_URL} para ${ICON_DEST_PATH}..."
if wget -q "$ICON_URL" -O "${ICON_DEST_PATH}"; then
    echo "Ícone baixado com sucesso para ${ICON_DEST_PATH}."
else
    echo "Aviso: Falha ao baixar o ícone de ${ICON_URL}."
    echo "O arquivo .desktop será criado, mas pode não ter um ícone visualmente correto."
    # Poderíamos definir ICON_DEST_PATH para um ícone genérico do sistema se o download falhar
    # Ex: ICON_DEST_PATH="utilities-terminal" (se o tema tiver)
    # Por enquanto, deixaremos o caminho mesmo que o arquivo não exista.
fi
# --- Fim do Download do Ícone ---

# --- Geração do Arquivo .desktop ---
echo "Criando o arquivo .desktop em ${DESKTOP_FILE_PATH}"
# Certificar que o diretório para o .desktop existe
if ! mkdir -p "${DESKTOP_FILE_DIR}"; then
    echo "Erro: Não foi possível criar o diretório ${DESKTOP_FILE_DIR} para o arquivo .desktop."
    echo "A instalação do AppImage foi concluída, mas o atalho no menu não pôde ser criado."
    exit 1 # Ou pode optar por continuar sem o .desktop
fi

# Usar cat com here document para criar o arquivo .desktop
cat > "${DESKTOP_FILE_PATH}" << EOF
[Desktop Entry]
Version=1.1
Name=Cursor AI IDE
Comment=AI First Code Editor. Edit with AI.
GenericName=Text Editor
# %U permite que arquivos sejam passados para a aplicação (e.g. "Open with...")
Exec=${DESTINATION_PATH} --no-sandbox %U
Icon=${ICON_DEST_PATH}
Type=Application
StartupNotify=true
# StartupWMClass é importante para o gerenciador de janelas associar a janela ao .desktop
# "Cursor" é uma suposição comum para apps Electron com esse nome.
# Pode ser necessário verificar com 'xprop WM_CLASS' na janela do Cursor se isso não funcionar.
StartupWMClass=Cursor
Categories=Development;IDE;TextEditor;
Keywords=vscode;cursor;ai;editor;ide;programming;
# MimeType básico; pode ser expandido se soubermos os tipos específicos que o Cursor manipula bem
MimeType=text/plain;application/x-zerosize;inode/directory;
Actions=new-empty-window;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=${DESTINATION_PATH} --no-sandbox --new-window %U
Icon=${ICON_DEST_PATH}
EOF

# Definir permissões corretas para o arquivo .desktop (não precisa ser executável)
chmod 644 "${DESKTOP_FILE_PATH}"

echo "Arquivo .desktop '${DESKTOP_FILE_NAME}' criado com sucesso em ${DESKTOP_FILE_DIR}."

# Atualizar o banco de dados de aplicações desktop para que o novo atalho apareça
if command -v update-desktop-database &> /dev/null; then
    echo "Atualizando o banco de dados de aplicações desktop..."
    update-desktop-database "${DESKTOP_FILE_DIR}"
    echo "Banco de dados atualizado."
else
    echo "Aviso: 'update-desktop-database' não encontrado. Você pode precisar"
    echo "reiniciar sua sessão ou executar este comando manualmente para que o"
    echo "atalho do Cursor apareça no menu de aplicações."
    echo "Exemplo: update-desktop-database ~/.local/share/applications"
fi
# --- Fim da Geração do Arquivo .desktop ---

echo ""
echo "Instalação/Atualização do Cursor IDE concluída com sucesso!"
echo "Você pode executar com: ${DESTINATION_PATH}"
echo "Ou procurar por 'Cursor AI IDE' no menu de aplicações do seu desktop."
echo "Se ${APPDIR} estiver no seu PATH, também com: ${FINAL_APPIMAGE_NAME}"

exit 0
