#!/bin/bash

# Check at least one check
if [ "$#" -eq 0 ]; then
    echo "错误: 没有输入参数。"
    exit 1
fi

# Get the first params
command=$1


show_help() {
    echo "help info："
    echo "bash ais.sh help - read the help"
    echo "bash ais.sh install - install aut for your account"
}

install_software() {
    echo "start install aut..."
    sudo apt update

}

# 根据输入参数执行相应的函数
case $command in
    help)
        show_help
        ;;
    install)
        install_software
        ;;
    *)
        echo "error: unknown command '$command' try to use "bash ais.sh help" to get more info"
        exit 1
        ;;
esac
