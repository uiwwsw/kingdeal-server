if [ -f program.pid ]; then
  sudo pkill -9 -ef 'dart run $(dirname $0)/bin/server.dart'
fi

sudo chmod 755 $(dirname $0)/bin/server.dart &&sudo iptables -I OUTPUT 1 -p tcp --dport 80 -j ACCEPT &&sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT &&nohup sudo dart run bin/server.dart > nohup.out 2>&1 &
