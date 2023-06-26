if [ -f program.pid ]; then
  sudo pkill -9 -ef 'dart run /home/ubuntu/kingdeal-server/bin/server.dart'
fi

sudo chmod 755 /home/ubuntu/kingdeal-server/bin/server.dart &&sudo iptables -I OUTPUT 1 -p tcp --dport 80 -j ACCEPT &&sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT &&nohup sudo dart run /home/ubuntu/kingdeal-server/bin/server.dart > nohup.out 2>&1 &
