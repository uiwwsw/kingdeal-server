if [ -f program.pid ]; then
  sudo kill -9 `cat program.pid`
fi

sudo chmod 755 bin/server.dart &&sudo iptables -I OUTPUT 1 -p tcp --dport 80 -j ACCEPT &&sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT &&nohup sudo dart run bin/server.dart > nohup.out 2>&1 & echo $! > program.pid
