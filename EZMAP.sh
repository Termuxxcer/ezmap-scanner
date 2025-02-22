#!/bin/bash
#===============================================================================
# EZMAP Scanner | Полная версия с автоматизацией
# Версия: 1.1 | Автор: r1tly
# GitHub: https://github.com/yourusername/ez-nmap
#===============================================================================

#-------------------------------------
# Конфигурация
#-------------------------------------
CONFIG_FILE=".EZMAP_config"
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'
COLOR_RESET='\033[0m'

declare -a selected_options
target=""
lang="en"

#-------------------------------------
# Полная система перевода
#-------------------------------------
choose_language() {
    system_lang=$(echo "$LANG" | cut -d '_' -f 1)
    case $system_lang in
        "ru") default_lang=1 ;;
        "de") default_lang=3 ;;
        *) default_lang=2 ;;
    esac

    echo -e "\n${COLOR_CYAN}Выберите язык / Choose language / Sprache wählen:${COLOR_RESET}"
    echo "1. Русский"
    echo "2. English"
    echo "3. Deutsch"

    read -p "$(echo -e "${COLOR_YELLOW}>> ${COLOR_RESET}")" lang_choice

    case ${lang_choice:-$default_lang} in
        1|R|r) lang="ru" ;;
        2|E|e) lang="en" ;;
        3|D|d) lang="de" ;;
    esac
}

translate() {
    local key="$1"
    declare -A translations

    case $lang in
        "ru") translations=(
            ["loading"]="Загрузка"
            ["choose_options"]="Выберите опции сканирования (можно несколько, через запятую):"
            ["enter_ports"]="Введите порты для сканирования (например, 80,443): "
            ["enter_output_file"]="Введите имя файла для сохранения результата: "
            ["enter_script_name"]="Введите имя скрипта (например, vuln): "
            ["conflicts_detected"]="Обнаружены конфликты опций:"
            ["continue_with_conflicts"]="Обнаружены конфликты. Продолжить с выбранными опциями? (Y/N): "
            ["options_reset"]="Опции сброшены. Попробуйте снова."
            ["enter_ip"]="Введите IP-адрес или хост для сканирования: "
            ["ready_request"]="Готовый запрос: nmap ${selected_options[*]} $target"
            ["start_scan"]="Начать сканирование? (Y/N): "
            ["scan_started"]="Запуск nmap с опциями: ${selected_options[*]} на цели: $target"
            ["scan_completed"]="Сканирование завершено."
            ["continue_prompt"]="Продолжить? (Y/N): "
            ["nmap_not_installed"]="Ошибка: nmap не установлен. Установите nmap и повторите попытку."
            ["no_ip_error"]="Ошибка: IP-адрес или хост не введен. Пожалуйста, введите IP-адрес или хост."
            ["page_1"]="Страница 1: Основные опции"
            ["page_2"]="Страница 2: Дополнительные опции"
            ["page_3"]="Страница 3: Выбранные опции"
            ["next_page"]="Следующая страница"
            ["previous_page"]="Предыдущая страница"
            ["exit"]="Выход"
            ["option_sV"]="1. -sV: Определение версий служб"
            ["option_sS"]="2. -sS: Синхронное сканирование (Stealth scan)"
            ["option_sU"]="3. -sU: Сканирование UDP портов"
            ["option_sP"]="4. -sP: Пинг-сканирование (только проверка доступности хоста)"
            ["option_sT"]="5. -sT: Сканирование TCP соединений"
            ["option_sN"]="6. -sN: NULL-сканирование (отправка пакетов без флагов)"
            ["option_sF"]="7. -sF: FIN-сканирование (отправка пакетов с FIN флагом)"
            ["option_sX"]="8. -sX: Xmas-сканирование (отправка пакетов с FIN, PSH и URG флагами)"
            ["option_A"]="9. -A: Агрессивное сканирование (включает OS detection, version detection, script scanning и traceroute)"
            ["option_O"]="10. -O: Определение операционной системы"
            ["option_p"]="11. -p: Сканирование определенных портов (например, -p 80,443)"
            ["option_T4"]="12. -T4: Ускоренное сканирование (агрессивное по времени)"
            ["option_v"]="13. -v: Увеличение уровня детализации (verbose)"
            ["option_oN"]="14. -oN: Сохранение результата в файл (например, -oN output.txt)"
            ["option_sC"]="15. -sC: Запуск скриптов по умолчанию (аналогично --script=default)"
            ["option_script"]="16. --script: Запуск пользовательских скриптов (например, --script=vuln)"
            ["option_Pn"]="17. -Pn: Не проверять доступность хоста (пропустить ping)"
            ["option_sA"]="18. -sA: ACK-сканирование"
            ["option_sW"]="19. -sW: Window-сканирование"
            ["option_sM"]="20. -sM: Maimon-сканирование"
            ["option_sI"]="21. -sI: Idle-сканирование"
            ["option_sY"]="22. -sY: SCTP INIT-сканирование"
            ["option_sZ"]="23. -sZ: SCTP COOKIE-ECHO-сканирование"
            ["option_sL"]="24. -sL: Сканирование списка (только перечисление хостов)"
            ["option_sR"]="25. -sR: RPC-сканирование"
            ["option_sD"]="26. -sD: Сканирование с использованием Dummy-зондов"
            ["option_F"]="27. -F: Быстрое сканирование (только основные порты)"
            ["warning_aggressive"]="Внимание: Агрессивные методы сканирования могут вызвать повышенную нагрузку на сеть и быть замечены системами защиты."
            ["warning_timing"]="Внимание: Ускоренное сканирование может вызвать повышенную нагрузку на сеть."
            ["warning_stealth"]="Внимание: Сканирование с использованием скрытых методов может быть замечено системами защиты."
            ["root_required"]="Внимание: Для некоторых опций требуются права администратора. Запустите скрипт с правами root."
            ["use_previous_options"]="Использовать предыдущие опции? (Y/N): "
            ["starting_fresh"]="Начинаем с чистого листа."
            ["skip_to_ip"]="Перейти к вводу IP-адреса? (Y/N): "
            ["remove_option"]="Введите номер опции ещё раз, чтобы убрать её."
            ["option_already_selected"]="Опция уже выбрана. Убрать её? (Y/N): "
            ["clear_all_options"]="Очистить все выбранные опции? (Y/N): "
            ["no_options_selected"]="Нет выбранных опций."
        ) ;;
        "en") translations=(
            ["loading"]="Loading"
            ["choose_options"]="Choose scanning options (multiple options allowed, separated by commas):"
            ["enter_ports"]="Enter ports to scan (e.g., 80,443): "
            ["enter_output_file"]="Enter the output file name: "
            ["enter_script_name"]="Enter the script name (e.g., vuln): "
            ["conflicts_detected"]="Conflicts detected:"
            ["continue_with_conflicts"]="Conflicts detected. Continue with selected options? (Y/N): "
            ["options_reset"]="Options reset. Try again."
            ["enter_ip"]="Enter the IP address or host to scan: "
            ["ready_request"]="Ready request: nmap ${selected_options[*]} $target"
            ["start_scan"]="Start scanning? (Y/N): "
            ["scan_started"]="Running nmap with options: ${selected_options[*]} on target: $target"
            ["scan_completed"]="Scan completed."
            ["continue_prompt"]="Continue? (Y/N): "
            ["nmap_not_installed"]="Error: nmap is not installed. Please install nmap and try again."
            ["no_ip_error"]="Error: IP address or host not entered. Please enter an IP address or host."
            ["page_1"]="Page 1: Basic options"
            ["page_2"]="Page 2: Advanced options"
            ["page_3"]="Page 3: Selected options"
            ["next_page"]="Next page"
            ["previous_page"]="Previous page"
            ["exit"]="Exit"
            ["option_sV"]="1. -sV: Version detection"
            ["option_sS"]="2. -sS: SYN Stealth scan"
            ["option_sU"]="3. -sU: UDP scan"
            ["option_sP"]="4. -sP: Ping scan (host discovery only)"
            ["option_sT"]="5. -sT: TCP connect scan"
            ["option_sN"]="6. -sN: NULL scan"
            ["option_sF"]="7. -sF: FIN scan"
            ["option_sX"]="8. -sX: Xmas scan (FIN, PSH, URG flags)"
            ["option_A"]="9. -A: Aggressive scan (OS detection, version detection, script scanning, and traceroute)"
            ["option_O"]="10. -O: OS detection"
            ["option_p"]="11. -p: Scan specific ports (e.g., -p 80,443)"
            ["option_T4"]="12. -T4: Aggressive timing template"
            ["option_v"]="13. -v: Increase verbosity level"
            ["option_oN"]="14. -oN: Save output to a file (e.g., -oN output.txt)"
            ["option_sC"]="15. -sC: Run default scripts (equivalent to --script=default)"
            ["option_script"]="16. --script: Run custom scripts (e.g., --script=vuln)"
            ["option_Pn"]="17. -Pn: Treat all hosts as online (skip host discovery)"
            ["option_sA"]="18. -sA: ACK scan"
            ["option_sW"]="19. -sW: Window scan"
            ["option_sM"]="20. -sM: Maimon scan"
            ["option_sI"]="21. -sI: Idle scan"
            ["option_sY"]="22. -sY: SCTP INIT scan"
            ["option_sZ"]="23. -sZ: SCTP COOKIE-ECHO scan"
            ["option_sL"]="24. -sL: List scan (simply list targets to scan)"
            ["option_sR"]="25. -sR: RPC scan"
            ["option_sD"]="26. -sD: Dummy scan"
            ["option_F"]="27. -F: Fast scan (only common ports)"
            ["warning_aggressive"]="Warning: Aggressive scanning methods may cause high network load and be detected by security systems."
            ["warning_timing"]="Warning: Fast timing scans may cause high network load."
            ["warning_stealth"]="Warning: Stealth scanning methods may be detected by security systems."
            ["root_required"]="Warning: Some options require root privileges. Run the script as root."
            ["use_previous_options"]="Use previous options? (Y/N): "
            ["starting_fresh"]="Starting fresh."
            ["skip_to_ip"]="Skip to entering IP address? (Y/N): "
            ["remove_option"]="Enter the option number again to remove it."
            ["option_already_selected"]="Option already selected. Remove it? (Y/N): "
            ["clear_all_options"]="Clear all selected options? (Y/N): "
            ["no_options_selected"]="No options selected."
        ) ;;
        "de") translations=(
            ["loading"]="Laden"
            ["choose_options"]="Wählen Sie Scan-Optionen (mehrere Optionen möglich, durch Kommas getrennt):"
            ["enter_ports"]="Geben Sie die zu scannenden Ports ein (z. B. 80,443): "
            ["enter_output_file"]="Geben Sie den Namen der Ausgabedatei ein: "
            ["enter_script_name"]="Geben Sie den Skriptnamen ein (z. B. vuln): "
            ["conflicts_detected"]="Konflikte erkannt:"
            ["continue_with_conflicts"]="Konflikte erkannt. Mit ausgewählten Optionen fortfahren? (Y/N): "
            ["options_reset"]="Optionen zurückgesetzt. Versuchen Sie es erneut."
            ["enter_ip"]="Geben Sie die IP-Adresse oder den Host zum Scannen ein: "
            ["ready_request"]="Fertiggestellte Anfrage: nmap ${selected_options[*]} $target"
            ["start_scan"]="Scan starten? (Y/N): "
            ["scan_started"]="Nmap wird mit den Optionen ausgeführt: ${selected_options[*]} auf Ziel: $target"
            ["scan_completed"]="Scan abgeschlossen."
            ["continue_prompt"]="Fortfahren? (Y/N): "
            ["nmap_not_installed"]="Fehler: nmap ist nicht installiert. Bitte installieren Sie nmap und versuchen Sie es erneut."
            ["no_ip_error"]="Fehler: IP-Adresse oder Host nicht eingegeben. Bitte geben Sie eine IP-Adresse oder einen Host ein."
            ["page_1"]="Seite 1: Grundlegende Optionen"
            ["page_2"]="Seite 2: Erweiterte Optionen"
            ["page_3"]="Seite 3: Ausgewählte Optionen"
            ["next_page"]="Nächste Seite"
            ["previous_page"]="Vorherige Seite"
            ["exit"]="Beenden"
            ["option_sV"]="1. -sV: Versionserkennung"
            ["option_sS"]="2. -sS: SYN-Stealth-Scan"
            ["option_sU"]="3. -sU: UDP-Scan"
            ["option_sP"]="4. -sP: Ping-Scan (nur Host-Erkennung)"
            ["option_sT"]="5. -sT: TCP-Connect-Scan"
            ["option_sN"]="6. -sN: NULL-Scan"
            ["option_sF"]="7. -sF: FIN-Scan"
            ["option_sX"]="8. -sX: Xmas-Scan (FIN, PSH, URG-Flags)"
            ["option_A"]="9. -A: Aggressiver Scan (OS-Erkennung, Versionserkennung, Skript-Scanning und Traceroute)"
            ["option_O"]="10. -O: OS-Erkennung"
            ["option_p"]="11. -p: Bestimmte Ports scannen (z. B. -p 80,443)"
            ["option_T4"]="12. -T4: Aggressives Timing-Template"
            ["option_v"]="13. -v: Erhöhen Sie die Ausführlichkeit"
            ["option_oN"]="14. -oN: Ausgabe in eine Datei speichern (z. B. -oN output.txt)"
            ["option_sC"]="15. -sC: Standardskripte ausführen (entspricht --script=default)"
            ["option_script"]="16. --script: Benutzerdefinierte Skripte ausführen (z. B. --script=vuln)"
            ["option_Pn"]="17. -Pn: Alle Hosts als online behandeln (Host-Erkennung überspringen)"
            ["option_sA"]="18. -sA: ACK-Scan"
            ["option_sW"]="19. -sW: Window-Scan"
            ["option_sM"]="20. -sM: Maimon-Scan"
            ["option_sI"]="21. -sI: Idle-Scan"
            ["option_sY"]="22. -sY: SCTP INIT-Scan"
            ["option_sZ"]="23. -sZ: SCTP COOKIE-ECHO-Scan"
            ["option_sL"]="24. -sL: Listen-Scan (einfach Ziele auflisten)"
            ["option_sR"]="25. -sR: RPC-Scan"
            ["option_sD"]="26. -sD: Dummy-Scan"
            ["option_F"]="27. -F: Schneller Scan (nur häufige Ports)"
            ["warning_aggressive"]="Warnung: Aggressive Scanmethoden können eine hohe Netzwerklast verursachen und von Sicherheitssystemen erkannt werden."
            ["warning_timing"]="Warnung: Schnelle Timing-Scans können eine hohe Netzwerklast verursachen."
            ["warning_stealth"]="Warnung: Stealth-Scanmethoden können von Sicherheitssystemen erkannt werden."
            ["root_required"]="Warnung: Einige Optionen erfordern Root-Rechte. Führen Sie das Skript als Root aus."
            ["use_previous_options"]="Vorherige Optionen verwenden? (Y/N): "
            ["starting_fresh"]="Beginne neu."
            ["skip_to_ip"]="Direkt zur Eingabe der IP-Adresse? (Y/N): "
            ["remove_option"]="Geben Sie die Optionsnummer erneut ein, um sie zu entfernen."
            ["option_already_selected"]="Option bereits ausgewählt. Entfernen? (Y/N): "
            ["clear_all_options"]="Alle ausgewählten Optionen löschen? (Y/N): "
            ["no_options_selected"]="Keine Optionen ausgewählt."
        ) ;;
    esac

    echo "${translations[$key]}"
}

#-------------------------------------
# Визуальные эффекты
#-------------------------------------
show_ascii_art() {
    clear
    echo -e "${COLOR_CYAN}"
    while IFS= read -r line; do
        echo "$line"
        sleep 0.05
    done << "EOF"
                _____                    _____                    _____                    _____                    _____
         /\    \                  /\    \                  /\    \                  /\    \                  /\    \
        /::\    \                /::\    \                /::\____\                /::\    \                /::\    \
       /::::\    \               \:::\    \              /::::|   |               /::::\    \              /::::\    \
      /::::::\    \               \:::\    \            /:::::|   |              /::::::\    \            /::::::\    \
     /:::/\:::\    \               \:::\    \          /::::::|   |             /:::/\:::\    \          /:::/\:::\    \
    /:::/__\:::\    \               \:::\    \        /:::/|::|   |            /:::/__\:::\    \        /:::/__\:::\    \
   /::::\   \:::\    \               \:::\    \      /:::/ |::|   |           /::::\   \:::\    \      /::::\   \:::\    \
  /::::::\   \:::\    \               \:::\    \    /:::/  |::|___|______    /::::::\   \:::\    \    /::::::\   \:::\    \
 /:::/\:::\   \:::\    \               \:::\    \  /:::/   |::::::::\    \  /:::/\:::\   \:::\    \  /:::/\:::\   \:::\____\
/:::/__\:::\   \:::\____\_______________\:::\____\/:::/    |:::::::::\____\/:::/  \:::\   \:::\____\/:::/  \:::\   \:::|    |
\:::\   \:::\   \::/    /\::::::::::::::::::/    /\::/    / ~~~~~/:::/    /\::/    \:::\  /:::/    /\::/    \:::\  /:::|____|
 \:::\   \:::\   \/____/  \::::::::::::::::/____/  \/____/      /:::/    /  \/____/ \:::\/:::/    /  \/_____/\:::\/:::/    /
  \:::\   \:::\    \       \:::\~~~~\~~~~~~                    /:::/    /            \::::::/    /            \::::::/    /
   \:::\   \:::\____\       \:::\    \                        /:::/    /              \::::/    /              \::::/    /
    \:::\   \::/    /        \:::\    \                      /:::/    /               /:::/    /                \::/____/
     \:::\   \/____/          \:::\    \                    /:::/    /               /:::/    /                  ~~
      \:::\    \               \:::\    \                  /:::/    /               /:::/    /
       \:::\____\               \:::\____\                /:::/    /               /:::/    /
        \::/    /                \::/    /                \::/    /                \::/    /
         \/____/                  \/____/                  \/____/                  \/____/


EOF
    echo -e "${COLOR_RESET}"
}

show_loading() {
    local i=0
    local spin='-\|/'
    echo -n "$(translate "loading") "
    while :; do
        i=$(( (i+1) % 4 ))
        printf "\b${spin:$i:1}"
        sleep 0.1
    done
}

#-------------------------------------
# Основная логика
#-------------------------------------
toggle_option() {
    local option="$1"
    if [[ " ${selected_options[*]} " =~ " $option " ]]; then
        read -p "$(translate "option_already_selected") " remove
        if [[ "${remove^^}" == "Y" ]]; then
            selected_options=("${selected_options[@]/$option}")
            return 1  # Возвращаем 1, чтобы вернуться к выбору опций
        fi
    else
        selected_options+=("$option")
    fi
    return 0
}

check_conflicts() {
    local conflicts=()
    [[ " ${selected_options[*]} " =~ " -sS " && " ${selected_options[*]} " =~ " -sT " ]] && conflicts+=("-sS и -sT: Синхронное сканирование и TCP сканирование не могут использоваться вместе.")
    [[ " ${selected_options[*]} " =~ " -sN " && " ${selected_options[*]} " =~ " -sF " ]] && conflicts+=("-sN и -sF: NULL-сканирование и FIN-сканирование не могут использоваться вместе.")
    [[ " ${selected_options[*]} " =~ " -sX " && " ${selected_options[*]} " =~ " -sF " ]] && conflicts+=("-sX и -sF: Xmas-сканирование и FIN-сканирование не могут использоваться вместе.")
    [[ " ${selected_options[*]} " =~ " -A " && (" ${selected_options[*]} " =~ " -sS " || " ${selected_options[*]} " =~ " -sT ") ]] && conflicts+=("-A уже включает сканирование TCP, не используйте с -sS или -sT.")

    if [[ ${#conflicts[@]} -gt 0 ]]; then
        echo -e "${COLOR_RED}$(translate "conflicts_detected")${COLOR_RESET}"
        printf "  ${COLOR_YELLOW}%s${COLOR_RESET}\n" "${conflicts[@]}"
        return 1
    fi
    return 0
}

#-------------------------------------
# Работа с конфигурацией
#-------------------------------------
save_config() {
    echo "selected_options=(${selected_options[*]})" > "$CONFIG_FILE"
    echo "lang='$lang'" >> "$CONFIG_FILE"
}

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        read -p "$(translate "use_previous_options") " use_previous
        if [[ "${use_previous^^}" == "Y" ]]; then
            echo -e "${COLOR_GREEN}$(translate "using_previous_options")${COLOR_RESET}"
        else
            selected_options=()
            echo -e "${COLOR_YELLOW}$(translate "starting_fresh")${COLOR_RESET}"
        fi
    fi
}

#-------------------------------------
# Функция для очистки и проверки IP-адреса или хоста
#-------------------------------------
clean_target() {
    local input="$1"
    # Удаляем лишние пробелы в начале и конце
    input=$(echo "$input" | xargs)
    # Проверяем, что введённый адрес не пустой
    if [[ -z "$input" ]]; then
        echo ""
    else
        # Проверка на корректность IP-адреса или доменного имени
        if [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || [[ "$input" =~ ^([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}$ ]]; then
            echo "$input"
        else
            echo -e "${COLOR_RED}Некорректный IP-адрес или доменное имя.${COLOR_RESET}" >&2
            echo ""
        fi
    fi
}

#-------------------------------------
# Основной интерфейс
#-------------------------------------
show_options_menu() {
    local page="$1"
    clear
    echo -e "${COLOR_CYAN}$(translate "page_$page")${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}$(translate "remove_option")${COLOR_RESET}"

    case $page in
        1)
            echo "$(translate "option_sV") $( [[ " ${selected_options[*]} " =~ " -sV " ]] && echo "[*]" )"
            echo "$(translate "option_sS") $( [[ " ${selected_options[*]} " =~ " -sS " ]] && echo "[*]" )"
            echo "$(translate "option_sU") $( [[ " ${selected_options[*]} " =~ " -sU " ]] && echo "[*]" )"
            echo "$(translate "option_sP") $( [[ " ${selected_options[*]} " =~ " -sP " ]] && echo "[*]" )"
            echo "$(translate "option_sT") $( [[ " ${selected_options[*]} " =~ " -sT " ]] && echo "[*]" )"
            echo "$(translate "option_sN") $( [[ " ${selected_options[*]} " =~ " -sN " ]] && echo "[*]" )"
            echo "$(translate "option_sF") $( [[ " ${selected_options[*]} " =~ " -sF " ]] && echo "[*]" )"
            echo "$(translate "option_sX") $( [[ " ${selected_options[*]} " =~ " -sX " ]] && echo "[*]" )"
            echo "$(translate "option_A") $( [[ " ${selected_options[*]} " =~ " -A " ]] && echo "[*]" )"
            echo "$(translate "option_O") $( [[ " ${selected_options[*]} " =~ " -O " ]] && echo "[*]" )"
            echo "$(translate "option_p") $( [[ " ${selected_options[*]} " =~ " -p " ]] && echo "[*]" )"
            echo "$(translate "option_T4") $( [[ " ${selected_options[*]} " =~ " -T4 " ]] && echo "[*]" )"
            echo "$(translate "option_v") $( [[ " ${selected_options[*]} " =~ " -v " ]] && echo "[*]" )"
            ;;
        2)
            echo "$(translate "option_oN") $( [[ " ${selected_options[*]} " =~ " -oN " ]] && echo "[*]" )"
            echo "$(translate "option_sC") $( [[ " ${selected_options[*]} " =~ " -sC " ]] && echo "[*]" )"
            echo "$(translate "option_script") $( [[ " ${selected_options[*]} " =~ " --script " ]] && echo "[*]" )"
            echo "$(translate "option_Pn") $( [[ " ${selected_options[*]} " =~ " -Pn " ]] && echo "[*]" )"
            echo "$(translate "option_sA") $( [[ " ${selected_options[*]} " =~ " -sA " ]] && echo "[*]" )"
            echo "$(translate "option_sW") $( [[ " ${selected_options[*]} " =~ " -sW " ]] && echo "[*]" )"
            echo "$(translate "option_sM") $( [[ " ${selected_options[*]} " =~ " -sM " ]] && echo "[*]" )"
            echo "$(translate "option_sI") $( [[ " ${selected_options[*]} " =~ " -sI " ]] && echo "[*]" )"
            echo "$(translate "option_sY") $( [[ " ${selected_options[*]} " =~ " -sY " ]] && echo "[*]" )"
            echo "$(translate "option_sZ") $( [[ " ${selected_options[*]} " =~ " -sZ " ]] && echo "[*]" )"
            echo "$(translate "option_sL") $( [[ " ${selected_options[*]} " =~ " -sL " ]] && echo "[*]" )"
            echo "$(translate "option_sR") $( [[ " ${selected_options[*]} " =~ " -sR " ]] && echo "[*]" )"
            echo "$(translate "option_sD") $( [[ " ${selected_options[*]} " =~ " -sD " ]] && echo "[*]" )"
            echo "$(translate "option_F") $( [[ " ${selected_options[*]} " =~ " -F " ]] && echo "[*]" )"
            ;;
        3)
            if [[ ${#selected_options[@]} -eq 0 ]]; then
                echo -e "${COLOR_YELLOW}$(translate "no_options_selected")${COLOR_RESET}"
            else
                echo -e "${COLOR_CYAN}$(translate "page_3")${COLOR_RESET}"
                for option in "${selected_options[@]}"; do
                    echo "- $option"
                done
                read -p "$(translate "clear_all_options") " clear_all
                if [[ "${clear_all^^}" == "Y" ]]; then
                    selected_options=()
                    echo -e "${COLOR_GREEN}$(translate "options_reset")${COLOR_RESET}"
                fi
            fi
            ;;
    esac

    echo -e "\nn. $(translate "next_page")"
    echo "p. $(translate "previous_page")"
    echo "q. $(translate "exit")"
}

#-------------------------------------
# Обработка выбора пользователя
#-------------------------------------
handle_menu_choice() {
    local choice="${1,,}"  # Приводим к нижнему регистру
    case $choice in
        1) toggle_option "-sV" ;;
        2) toggle_option "-sS"; show_warning "-sS" ;;
        3) toggle_option "-sU" ;;
        4) toggle_option "-sP" ;;
        5) toggle_option "-sT" ;;
        6) toggle_option "-sN"; show_warning "-sN" ;;
        7) toggle_option "-sF"; show_warning "-sF" ;;
        8) toggle_option "-sX"; show_warning "-sX" ;;
        9) toggle_option "-A"; show_warning "-A" ;;
        10) toggle_option "-O" ;;
        11) read -p "$(translate "enter_ports") " ports; toggle_option "-p $ports" ;;
        12) toggle_option "-T4"; show_warning "-T4" ;;
        13) toggle_option "-v" ;;
        14) read -p "$(translate "enter_output_file") " output_file; toggle_option "-oN $output_file" ;;
        15) toggle_option "-sC" ;;
        16) read -p "$(translate "enter_script_name") " script_name; toggle_option "--script=$script_name" ;;
        17) toggle_option "-Pn" ;;
        18) toggle_option "-sA" ;;
        19) toggle_option "-sW" ;;
        20) toggle_option "-sM" ;;
        21) toggle_option "-sI" ;;
        22) toggle_option "-sY" ;;
        23) toggle_option "-sZ" ;;
        24) toggle_option "-sL" ;;
        25) toggle_option "-sR" ;;
        26) toggle_option "-sD" ;;
        27) toggle_option "-F" ;;
        *) echo -e "${COLOR_RED}$(translate "invalid_choice" "$choice")${COLOR_RESET}" ;;
    esac
}

#-------------------------------------
# Функция для вывода предупреждений
#-------------------------------------
show_warning() {
    local option="$1"
    case $option in
        "-A") echo -e "${COLOR_YELLOW}$(translate "warning_aggressive")${COLOR_RESET}" ;;
        "-T4") echo -e "${COLOR_YELLOW}$(translate "warning_timing")${COLOR_RESET}" ;;
        "-sS"|"-sX"|"-sF"|"-sN") echo -e "${COLOR_YELLOW}$(translate "warning_stealth")${COLOR_RESET}" ;;
    esac
}

#-------------------------------------
# Главный цикл программы
#-------------------------------------
main() {
    choose_language
    load_config

    # Проверка Nmap
    if ! command -v nmap &>/dev/null; then
        echo -e "${COLOR_RED}$(translate "nmap_not_installed")${COLOR_RESET}"
        exit 1
    fi

    while true; do
        show_ascii_art
        show_loading &
        pid=$!
        sleep 3
        kill $pid 2>/dev/null
        printf "\b \n"

        current_page=1
        while true; do
            show_options_menu $current_page
            read -p "$(echo -e "${COLOR_YELLOW}>> ${COLOR_RESET}")" input

            case $input in
                n|N) current_page=$((current_page % 3 + 1)) ;;
                p|P) current_page=$((current_page - 1)); [[ $current_page -lt 1 ]] && current_page=3 ;;
                q|Q) exit 0 ;;
                *)
                    if [[ $current_page -eq 3 ]]; then
                        # На странице выбранных опций обрабатываем только очистку
                        continue
                    else
                        process_user_input "$input"
                        [[ $? -eq 1 ]] && break
                    fi
                    ;;
            esac
        done
    done
}

process_user_input() {
    local choices=(${1//,/ })
    for choice in "${choices[@]}"; do
        handle_menu_choice "$choice"
        if [[ $? -eq 1 ]]; then
            return 1  # Возвращаем 1, чтобы вернуться к выбору опций
        fi
    done

    if ! check_conflicts; then
        read -p "$(translate "continue_with_conflicts") " answer
        if [[ "${answer^^}" != "Y" ]]; then
            return 1  # Возвращаем 1, чтобы вернуться к выбору опций
        fi
    fi

    manage_target_input
    execute_scan
}

manage_target_input() {
    while [[ -z "$target" ]]; do
        read -e -p "$(translate "enter_ip") " input
        target=$(clean_target "$input")
        if [[ -z "$target" ]]; then
            echo -e "${COLOR_RED}$(translate "no_ip_error")${COLOR_RESET}"
        fi
    done
}

execute_scan() {
    echo -e "${COLOR_GREEN}$(translate "ready_request")${COLOR_RESET}"
    read -p "$(translate "start_scan") " answer

    if [[ "${answer^^}" == "Y" ]]; then
        echo -e "${COLOR_CYAN}$(translate "scan_started")${COLOR_RESET}"
        nmap "${selected_options[@]}" "$target"

        read -p "$(translate "continue_prompt") " answer
        if [[ "${answer^^}" == "Y" ]]; then
            target=""
        else
            exit 0
        fi
    fi
}

# Запуск
trap 'echo -e "\n${COLOR_RED}Прервано пользователем${COLOR_RESET}"; exit 1' INT
main
