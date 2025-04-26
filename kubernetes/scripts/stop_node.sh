#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

info() {
    echo -e "${GREEN}🛈 [INFO]${NC} ${GREEN}$1${NC}"
}

error() {
    echo -e "${RED}✗ [ERROR]${NC} ${RED}$1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠ [WARNING]${NC} ${YELLOW}$1${NC}"
}

success() {
    echo -e "${GREEN}✓ [SUCCESS]${NC} ${GREEN}$1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

soft_stop_node() {
    if ! command_exists kubectl; then 
        error "kubectl не установлен!"
    else
        POD_NAME=$(kubectl get pods -n bakhilin -o jsonpath='{.items[*].metadata.name}')
        NODE_NAME=$(kubectl get pod $POD_NAME -n bakhilin -o jsonpath='{.spec.nodeName}')
        
        echo -e "\n${YELLOW}⚓ Подготовка к эвакуации с ноды ${BLUE}$NODE_NAME${NC}"
        kubectl cordon $NODE_NAME
        kubectl delete pod $POD_NAME
        kubectl uncordon $NODE_NAME
        
        echo -e "${RED}💀 Титаник тонет!${NC}"
        echo -e "${GREEN}🚢 Пассажиры эвакуируются на Алимпик...${NC}"
    fi
}

hard_stop_node() {
    POD_NAME=$(kubectl get pods -n bakhilin -o jsonpath='{.items[*].metadata.name}')
    NODE_NAME=$(kubectl get pod $POD_NAME -n bakhilin -o jsonpath='{.spec.nodeName}')
    PORT="220$((${NODE_NAME: -1} + 1))"
    ssh -p${PORT} root@46.243.172.225 "hostname" # poweroff
}

choose_type() {
    echo 'Выберите тип крушения:'
    echo '(1) Мягкий, без полного потопления.'
    echo '(2) Полное погружение на дно. (Остановка VM)'
    read -p ': ' n
    if [ "$n" = 1 ]; then
        soft_stop_node
    elif [ "$n" = 2 ]; then
        warn 'Ты уверен, что хочешь полностью отключить виртуальную машину?'
        read -p 'Yes/No: ' answer
        if [[ "$answer" =~ ^[Yy][Ee][Ss]?$ ]]; then
            hard_stop_node
        fi
    fi
}

alimpic() {
    clear
    echo -e "${GREEN}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "   🛳️  ${BLUE}RMS Olympic ${GREEN}- Корабль мечты!"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    echo -e "${CYAN}Вы находитесь на безопасном корабле,${NC}"
    echo -e "${CYAN}который не собирается тонуть!${NC}\n"
    
    echo -e "${MAGENTA}Доступное меню на корабле:${NC}"
    read -p "$(echo -e "${YELLOW}(1) Проверить здоровье пассажиров ${NC}") " n
    
    if [ $n == 1 ]; then
        echo -e "\n${BLUE}⚕️  Медицинский осмотр пассажиров:${NC}"
        curl -X GET "https://nikitos.tech/info" && \
        echo "" && \
        curl -X GET "https://nikitos.tech/info/currency?date=2016-12-12&currency=USD" && \
        echo ""
    fi
}

titanic() {
    clear
    echo -e "${RED}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "   🚢 ${BLUE}RMS Titanic ${RED}- Рейс 1912"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    
    echo -e "${CYAN}Пассажиры Титаника: ${NC}"
    kubectl get pods -n bakhilin -o wide
    
    echo -e "\n${GREEN}⛵ ОТПЛЫВАЕМ!${NC}"
    
    echo -ne "${BLUE}Плавание"
    for i in {1..5}; do
        echo -ne "${RED}~${BLUE}>${NC}"
        sleep 0.5
    done
    echo ""
    
    choose_type
    
    echo -e "\n${RED}☠ Титаник тонет. Эвакуация всех пассажиров на Алимпик:${NC}"
    timeout 15 kubectl get pods -w -n bakhilin -o wide
    
    echo -e "\n${GREEN}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "   🎉 Все пассажиры спасены!"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    
    alimpic
}

show_menu() {
    clear
    echo -e "${BLUE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "   🚢 ${GREEN}White Star Line ${BLUE}- Выбор корабля"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    echo -e "${YELLOW}1) Титаник ${RED}(опасный рейс)${NC}"
    echo -e "${YELLOW}2) Алимпик ${GREEN}(безопасный рейс)${NC}"
    read -p "$(echo -e "${CYAN}Выберите корабль (1/2): ${NC}") " n
    
    if [ $n == 1 ]; then
        titanic
    elif [ $n == 2 ]; then
        alimpic
    else
        error "Такого корабля нет, либо все билеты раскуплены!"
        sleep 2
        show_menu
    fi
}

login() {
    clear
    echo -e "${BLUE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "   🎫 ${GREEN}Регистрация пассажира"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    
    echo -e "${CYAN}Чтобы отправиться в путешествие, заполните карточку:${NC}"
    read -p "$(echo -e "${YELLOW}Введите имя: ${NC}") " name
    read -sp "$(echo -e "${YELLOW}Введите пароль: ${NC}") " password
    echo ""
    
    if [ "$password" == "admin" ]; then
        echo -e "\n${GREEN}✓ Добро пожаловать на борт, господин $name!${NC}"
        sleep 1
        
        echo -e "\n${CYAN}Вы готовы отправиться в путешествие своей мечты?${NC}"
        read -p "$(echo -e "${YELLOW}Yes/No: ${NC}") " answer
        
        if [[ "$answer" =~ ^[Yy][Ee][Ss]?$ ]]; then
            show_menu
        else    
            echo -e "\n${BLUE}До новых встреч!${NC}"
            exit 0
        fi 
    else 
        error "Пароль не подходит. Доступ запрещен!"
        exit 1
    fi
}

start_game() {
    clear
    echo -e "${BLUE}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo -e "   🛳️  ${GREEN}White Star Line ${BLUE}приветствует вас!"
    echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${NC}"
    echo -e "${CYAN}Крупнейшая британская судоходная компания"
    echo -e "конца XIX — начала XX века.${NC}\n"
    
    login
}

start_game
