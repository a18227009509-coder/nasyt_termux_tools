#!/bin/bash
#本脚本由HA制作(Termux版本)
#NAS油条工具箱Termux版本"
#欢迎加入NAS油条赤石技术交流群
#有什么赤石技术可以进来交流
#赤石群号:610699712
cd $HOME
time_date="2025/11/30"
version="ter-v1.0.0"
nasyt_termux_dir="$HOME/.nasyt_termux"
source $nasyt_termux_dir/config.txt >/dev/null 2>&1
bin_dir="usr/bin"
check_pkg_install() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release #加载变量
    fi
    if command -v termux-info >/dev/null 2>&1; then
        sys="(Termux 终端)"
        PRETTY_NAME="Termux终端"
        sed -i 's@^\(deb.*stable main\)$@#\1\ndeb https://mirrors.tuna.tsinghua.edu.cn/termux/termux-packages-24 stable main@' $PREFIX/etc/apt/sources.list >/dev/null
        pkg_install="pkg install"
        pkg_remove="pkg remove"
        pkg_update="pkg update"
        deb_sys="pkg"
        yes_tg="-y"
        
# 全部变量
# 定义颜色变量
color_variable() {
    color='\033[0m'
    green='\033[0;32m'
    blue='\033[0;34m'
    red='\033[31m'
    yellow='\033[33m'
    grey='\e[37m'
    pink='\033[38;5;218m'
    cyan='\033[96m'
}

all_variable() {
    
    OUTPUT_FILE="nasyt_termux" # 下载文件名
    time_out=10  # curl超时时间（秒）
    urls=(
      "https://gitee.com/nasyt/nasyt-linux-tool/raw/master/nasyt.sh"   # 主链接
      "https://raw.githubusercontent.com/nasyt233/nasyt-linux-tool/refs/heads/master/nasyt.sh" # 备用链接2
      "https://linux.class2.icu/shell/nasyt.sh"  # 备用链接2
      "https://nasyt.hoha.top/shell/nasyt.sh" # 备用链接3
      "https://nasyt2.class2.icu/shell/nasyt.sh"  # 备用链接4
    )
    
}
server_ip() {
    server_ip=$(hostname -i) # 服务器IP
    $habit --msgbox "当前IP为: $server_ip" 0 0
}

info() {
    echo -e "$cyan[$(date +"%r")]$color $green[INFO]$color" $*
}
uptime_cn() {
    uptime_sc=$(uptime | sed 's/up/运行/; s/days/天/; s/day/天/; s/hours/小时/; s/hour/小时/; s/minutes/分钟/; s/minute/分钟/; s/users/用户/; s/user/用户/; s/load average/平均负载/')
    $habit --msgbox "系统: $uptime_sc" 0 0
}

br() {
    echo -e "\e[1;34m----------------------------\e[0m"
}

esc() {
    echo -e "$(info) 按$green回车键$color$blue返回$color,按$yellow Ctrl+C$color$red退出$color"
    read
}

#错误处理
cw() {
    if [ $cw_test -ne 0 ]; then
       break
    fi
}

#文件选择器
file_xz() {
    #处理
    file_browser_xz() {
        #第一个目录参数
        current_dir="${1:-.}"
        #第二个变量参数
        file_var="${2:-file_index}"
        
        # 检查目录是否存在
        if [[ ! -d "$current_dir" ]]; then
            echo "目标目录 '$current_dir' 不存在" >&2
            return 1
        fi
            #循环
            while true
            do
                local menu_items=()
                
                #如果不是根目录，添加返回选项
                if [[ "$current_dir" != "." ]]; then
                    menu_items+=(".." "📁 ◀返回上级目录")
                fi
                
                #添加当前目录内容
                while IFS= read -r item; do
                    if [[ -n "$item" ]]; then
                        if [[ -d "$current_dir/$item" ]]; then
                            menu_items+=("$item" "📁 $item/")
                        else
                            menu_items+=("$item" "📄 $item")
                        fi
                    fi
                done < <(ls -a "$current_dir" --group-directories-first)
                
                dir_xz=$($habit --title "文件选择器" \
                --menu "文件浏览器: $current_dir 🤓👇" 0 0 15 \
                "${menu_items[@]}" \
                2>&1 1>/dev/tty)
                
                if [[ -z "$dir_xz" ]]; then
                    break
                fi
                
                if [[ "$dir_xz" == ".." ]]; then
                    current_dir=$(dirname "$current_dir")
                elif [[ -d "$current_dir/$dir_xz" ]]; then
                    current_dir="$current_dir/$dir_xz"
                else
                    $habit --yesno "确认文件: $current_dir/$dir_xz" 0 0
                    if [ $? -eq 0 ]; then
                        eval "$file_var"="$current_dir/$dir_xz"
                        break
                    fi
                fi
            done    
        }
    file_browser_xz "$@"
    #输出
    if [[ -n $file_index ]]; then
        echo $file_index
    else
        echo $file_var
    fi
}

#监控服务器资源
resources_show() {
    echo -e "$(info) 正在读取数据中"
    if command -v termux-info >/dev/null 2>&1; then
        resources_show_notermux="CPU 使用率：不支持termux"
    else
        cpu_usage=$(grep 'cpu ' /proc/stat | awk '{u=$2+$4; t=$2+$4+$5; print "" sprintf("%.1f%%", u/t*100)}') >/dev/null 2>&1
        resources_show_notermux="CPU 使用率：$cpu_usage%"
        cpu_core=grep 'cpu[0-9]' /proc/stat | awk '{u=$2+$4; t=$2+$4+$5; printf "CPU核心%s：%.1f%%\n", substr($1,4), u/t*100}'
    fi
    #cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*,*([-9.)* id.*/\1/" | awk '{print 100}' >/dev/null 2>&1)
    mem_total=$(grep MemTotal /proc/meminfo | awk '{printf "%.1fGiB", $2/1024/1024}'); >/dev/null 2>&1
    mem_available=$(grep MemAvailable /proc/meminfo | awk '{printf "%.1fGiB", $2/1024/1024}'); >/dev/null 2>&1
    mem_usage=$(free | awk '/Mem/ {print $3/$2*100.0}') >/dev/null 2>&1
    #mem_used=$(grep MemTotal /proc/meminfo | awk '{t=$2} END {grep MemAvailable /proc/meminfo | awk -v t=t "{printf \"%.1fGiB\", (t-$2)/1024/1024}"}') >/dev/null 2>&1
    swap_total=$(grep SwapTotal /proc/meminfo | awk '{if($2==0){print "0.0GiB"}else{printf "%.1fGiB", $2/1024/1024}}'); >/dev/null 2>&1
    swap_free=$(grep SwapFree /proc/meminfo | awk '{if($2==0){print "0.0GiB"}else{printf "%.1fGiB", $2/1024/1024}}'); >/dev/null 2>&1
    #swap_used=$(grep SwapTotal /proc/meminfo | awk '{t=$2} END {grep SwapFree /proc/meminfo | awk -v t=t "{if(t==0){print \"0.0GiB\"}else{printf \"%.1fGiB\", (t-$2)/1024/1024}}"}'); >/dev/null 2>&1
    ps_quantity=$(ps -e --no-headers | wc -l) >/dev/null 2>&1
    swap_usage=$(grep -E 'SwapTotal|SwapFree' /proc/meminfo | awk -v total=$(grep SwapTotal /proc/meminfo | awk '{print $2}') '{if($1=="SwapFree:"){if(total==0){printf "利用率：0.0%%\n"}else{printf "利用率：%.1f%%\n", (total-$2)/total*100}}}') >/dev/null 2>&1
    echo -e "$(info) $green 读取数据完毕$color"
    $habit --msgbox "操作系统: $PRETTY_NAME \n\n$resources_show_notermux \n    $cpu_core\n内存总量：$mem_total 使用率：$mem_usage%\n    可用：$mem_available  \n\nSwap总量：$swap_total $swap_usage\n    可用：$swap_free \n\n进程数量: $ps_quantity" 0 0
}

# 根据时间返回问候语
get_greeting() {
    local hour=$(date +"%H")
    case $hour in
        05|06|07|08|09|10|11)
            echo "🌅 早上好！欢迎使用Termux工具箱"
            ;;
        12|13|14|15|16|17|18)
            echo "☀️ 下午好！欢迎使用Termux工具箱"
            ;;
        *)
            echo "🌙 晚上好！欢迎使用Termux工具箱"
            ;;
    esac
}

test_termux() {
    if command -v termux-info >/dev/null 2>&1; then
        $habit --msgbox "不支持termux终端" 0 0
        break
    fi
}

# 检查dialog whiptail figlet安装
test_install_jc() {
    if [ $? -ne 0 ]; then
        echo -e "$(info) $red 安装失败。$color"
    else
        echo -e "$(info) $green 安装成功。$color"
    fi
}

test_dialog() {
        if command -v dialog &> /dev/null
        then
            echo -e "$green ◉ dialog 已经安装，跳过安装步骤。 $color"
        else 
            echo "$(info) 正在安装dialog"
            $pkg_install dialog $yes_tg
            if [ $? -ne 0 ]; then
                echo -e "$(info) 安装完成"
            fi
            echo -e "$red 安装失败。 $color"
        fi
}

test_figlet() {
    if command -v figlet >/dev/null 2>&1; then
        echo -e "$green ◉ figlet 已经安装，跳过安装步骤。$color"
    else 
        echo "$(info) 正在安装figlet"
        $pkg_install figlet $yes_tg
        if [ $? -ne 0 ]; then
            echo -e "$(info) 安装完成"
        fi
            echo -e "$red 安装失败。 $color"
    fi
}
test_toilet() {
    if command -v toilet >/dev/null 2>&1; then
        echo -e "$green ◉ toilet已安装，跳过安装步骤 $color"
    else
        echo "$(info) toilet未安装，正在安装"
        $pkg_install toilet $yes_tg
    fi
}

test_whiptail() {
    if command -v whiptail &> /dev/null
    then
        echo -e "$(info) ◉ whiptail已安装, 跳过安装步骤。"
    else
        echo -e "$(info) whiptail未安装，正在安装。"
        if command -v pacman >/dev/null 2>&1; then
            echo -e "$(info) 检测到Arch系统，正在安装libnewt软件包"
            $pkg_install libnewt $yes_tg
        else
            $pkg_install whiptail $yes_tg
                if [ $? -ne 0 ]; then
                    echo "$(info) 安装完成"
                fi
                echo -e "$red 安装失败。 $color"
        fi
    fi
}
    
test_curl() {
    if command -v curl >/dev/null 2>&1; then
        echo -e "$green ◉ curl已安装,跳过安装$color"
    else
        echo "$(info) 正在安装curl"
        $pkg_install curl $yes_tg >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "$red curl安装失败 $color"
        else
            echo "$(info) curl安装成功"
        fi
    fi
}

test_wget() {
    if command -v wget >/dev/null 2>&1; then
        echo -e "$green ◉ wget已安装，跳过安装 $color"
    else
        echo "$(info) 正在安装wget"
        $pkg_install wget $yes_tg
    fi
}

test_eatmydata() {
    if command -v eatmydata >/dev/null 2>&1; then
        echo -e "$green ◉ eatmydata已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装eatmydata"
        $pkg_install eatmydata $yes_tg
    fi
}

test_python() {
    if command -v python >/dev/null 2>&1; then
       echo -e "$green ◉ python已安装,跳过安装$color"
    else
       echo -e "$(info) 正在安装python"
       $pkg_install python $yes_tg
    fi
}

test_pip() {
    if command -v pip >/dev/null 2>&1; then
       echo -e "$green ◉ pip已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装pip"
        $pkg_install pip $yes_tg
    fi
}

test_git() {
    if command -v git >/dev/null 2>&1; then
        echo -e "$green ◉ git已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装git"
        $pkg_install git $yes_tg
    fi
}

test_tmux() {
    if command -v tmux >/dev/null 2>&1; then
        echo -e "$green ◉ tmux已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装tmux工具"
        $pkg_install tmux $yes_tg
    fi
}

test_neofetch() {
    if command -v neofetch >/dev/null 2>&1; then
        echo -e "$green ◉ neofetch已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装neofetch工具"
        $pkg_install neofetch $yes_tg
    fi
}

test_fastfetch() {
    if command -v fastfetch >/dev/null 2>&1; then
        echo -e "$green ◉ fastfetch已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装 fastfetch"
        $pkg_install fastfetch $yes_tg
    fi
}

test_hashcat() {
    if command -v hashcat >/dev/null 2>&1; then
        echo -e "$green ◉ hashcat已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装hashcat工具"
        $pkg_install hashcat $yes_tg
    fi
}

test_burpsuite() {
    if command -v burpsuite >/dev/null 2>&1; then
        echo -e "$green ◉ burpsuite已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装burpsuite工具"
        $pkg_install burpsuite $yes_tg
    fi
}

test_nmap() {
    if command -v nmap >/dev/null 2>&1; then
        echo -e "$green ◉ nmap已安装，跳过安装。$color"
    else
        echo -e "$(info) 正在安装nmap"
        $pkg_install nmap $yes_tg
    fi
}

test_htop() {
    if command -v htop >/dev/null 2>&1; then
        echo -e "$green ◉ htop已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装htop"
        $pkg_install htop $yes_tg
    fi
}

test_ncdu() {
    if command -v ncdu >/dev/null 2>&1; then
        echo -e "$green ◉ ncdu已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装curl"
        $pkg_install ncdu $yes_tg
    fi
}

test_bastet() {
    echo "111"
}

#通用安装
test_install() {
    if command -v $* >/dev/null 2>&1; then
        echo -e "$(info) $green $*已安装,跳过安装$color"
    else
        echo -e "$(info) 正在安装$*"
        $sudo_setup $pkg_install $* $yes_t

