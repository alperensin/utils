#!/usr/bin/env bash
#
# gitLog.sh - Gerador de log do git no padrão {repositório}/{caminho arquivo}.{extensão}#{hash do commit}
#
# Site:         https://github.com/alperensin/utils
# Autor:        André Luiz Perensin
# Manutenção:   alperensin
#
# ---------------------------------------------------------------------------- #
# Script para buscar arquivos no histórico do git contendo o padrão:
#
#   {repositório}/{caminho arquivo}.{extensão}#{hash do commit}
#
# Exemplo de resultado:
#
#   Commit: #0000000000
#   nome_repositorio/caminho_arquivo/arquivo.extensao#0000000000
#   nome_repositorio/caminho_arquivo/arquivo.extensao#0000000000
#   nome_repositorio/caminho_arquivo/arquivo.extensao#0000000000
#   Commit: #9999999999
#   nome_repositorio/caminho_arquivo/arquivo.extensao#9999999999
#   nome_repositorio/caminho_arquivo/arquivo.extensao#9999999999
#
# O script deve ser utilizado dentro do diretório do repositório.
#
# Exemplos de utilização:
#   $ ./gitLog.sh
#     Neste exemplo o script será executado pedindo ao usuário que informe os dados de usuário e data inicial.
#   $ ./gitLog.sh -u Andre
#     Neste exemplo o script será executado já informando o usuário (-u) e pedindo que informe apenas a data inicial.
#   $ ./gitLog.sh -u Andre -d 2023-08-01
#     Neste exemplo o script será executado já informando o usuário (-u) e data inicial (-d).
#   $ ./gitLog.sh -u Andre -d 2023-08-01 -f
#     Neste exemplo o script será executado já informando o usuário (-u) e data inicial (-d), além de salvar o resultado (-f) em um arquivo txt com o nome da branch atual.
#
# ---------------------------------------------------------------------------- #
# Histórico:
#
#   v1.0 - 21/09/2023, André Luiz Perensin:
#     - Criação do script
#
# ---------------------------------------------------------------------------- #
# Testado em:
#
#   bash  3.2.57
#   zsh   5.8
# ---------------------------------------------------------------------------- #

echo "Custom GitLog"
echo ""

print_usage() {
  echo "Script usage: $(basename \$0) [-u <user>] [-d <2023-12-31>] [-f]" >&2
}

USER=""
AFTER=""
SAVE_FILE=""
COMMIT=""
ROW=""
TEMPORARY_FILE=".gitLog.txt"
PROJECT_NAME="$(basename $(pwd))/"

while getopts 'u:d:f' flag; do
  case "${flag}" in
    u) USER="${OPTARG}" ;;
    d) AFTER="${OPTARG}" ;;
    f) SAVE_FILE="1" ;;
    *) print_usage
       exit 1 ;;
  esac
done

[ ! "$USER" ] && read -p "Informe o usuário dos commits: " USER || echo "User: $USER"
[ ! "$AFTER" ] && read -p 'Informe a data inicial (YYYY-MM-DD): ' AFTER || echo "Initial Date: $AFTER"
echo ""

[ ! "$USER" ] && echo "Usuário não foi informado." && exit 1

git log --name-status --author="$USER" --after="$AFTER" --pretty=format:'commit: #%h' > "$TEMPORARY_FILE"

[[ "$SAVE_FILE" -eq "1" ]] && TEMPORARY_FILE_SAVE_NAME="git_rows.txt"

while read -r row
do

  IS_COMMIT=$(echo $row | grep "commit: " | cut -d " " -f 2)

  [ ! "$row" ] && COMMIT="" && continue

  if [[ "$IS_COMMIT" ]]; then
    COMIT_NAME="Commit: $IS_COMMIT"
    [[ "$SAVE_FILE" -eq "1" ]] && echo "$COMIT_NAME" >> "$TEMPORARY_FILE_SAVE_NAME" || echo "$COMIT_NAME"
    COMMIT="$IS_COMMIT"
    continue
  fi

  [ "$COMMIT" ] && ROW=$(echo $row | cut -d " " -f 2)

  if [[ "$SAVE_FILE" -eq "1" ]]; then
    echo "$PROJECT_NAME$ROW$COMMIT" >> "$TEMPORARY_FILE_SAVE_NAME"
  else
    echo "$PROJECT_NAME$ROW$COMMIT"
  fi

done < "$TEMPORARY_FILE"

if [[ "$SAVE_FILE" -eq "1" ]]; then
  FILE_NAME="$(git symbolic-ref --short HEAD | sed "s/\//|/").txt"
  cat "$TEMPORARY_FILE_SAVE_NAME" > "$FILE_NAME"
  rm "$TEMPORARY_FILE_SAVE_NAME"
fi

rm "$TEMPORARY_FILE"