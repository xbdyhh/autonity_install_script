#!/bin/bash

# Check at least one check
if [ "$#" -eq 0 ]; then
    echo "error: no command input..."
    exit 1
fi

# Get the first params
command=$1


show_help() {
    echo "help info："
    echo "bash ais.sh help - read the help"
    echo "bash ais.sh install - install aut for your account"
    echo "bash ais.sh register - register your account an env"
    echo "bash ais.sh sign <message you want to sign> - sign message from you opr.key, you can create this key by regisger"
    echo "bash ais.sh run_node - run a autonity node on you sever"
}
register() {
    cd ~
    echo '[aut]' > .autrc
    echo 'rpc_endpoint = https://rpc1.piccadilly.autonity.org/' >> .autrc
    echo 'keyfile = ./keystore/opr.key'>> .autrc
    mkdir -p keystore
    aut account new --keyfile keystore/opr.key
}
install_aut() {
    echo "start install aut..."
    sudo apt update
    apt install make -y
    apt install pipx -y
    pipx install --force git+https://github.com/autonity/aut
    sudo cp ~/.local/bin/aut /usr/local/bin
    cd
    git clone https://github.com/autonity/autonity.git
    cd  autonity
    git checkout tags/v0.12.2 -b v0.12.2
    make autonity
    sudo cp build/bin/autonity /usr/local/bin/autonity
    autonity version
    aut -h
}

sign(){
    local message=$1
    echo "message is: $message"
    aut account sign-message $message
}

run_node(){	
    mkdir $HOME/autonity-chaindata
    sudo tee /etc/systemd/system/autonity.service > /dev/null <<EOF
     	[Unit]
	Description=autonity
	After=network.target
	[Service]
	User=root
	ExecStart=autonity --datadir /root/autonity-chaindata --piccadilly --http --http.addr 0.0.0.0 --http.api aut,eth,net,txpool,web3,admin --http.vhosts * --ws --ws.addr 0.0.0.0 --ws.api aut,eth,net,txpool,web3,admin --nat extip:$(hostname -i)
	KillSignal=SIGINT
	Restart=on-failure
	RestartSec=30
	StartLimitInterval=350
	StartLimitBurst=10
	[Install]
	WantedBy=default.target
EOF
    sudo systemctl daemon-reload && \
    sudo systemctl enable autonity && \
    sudo systemctl restart autonity
}
case $command in
    help)
        show_help
        ;;
    install)
        install_aut
        ;;
    register)
	register
	;;
    sign)
        if [ -z "$2" ]; then
            echo "error:  please input your message you want to sign"
            exit 1
        else
            sign "$2"
        fi
        ;;
    run_node)
	run_node
	;;
    *)
        echo "error: unknown command '$command' try to use "bash ais.sh help" to get more info"
        exit 1
        ;;
esac
