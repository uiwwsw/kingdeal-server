sudo chmod 755 bin/server.dart
sudo iptables -I OUTPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
nohup sudo dart run bin/server.dart &