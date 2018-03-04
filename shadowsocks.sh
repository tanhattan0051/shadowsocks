
#/bin/sh
yum update -y
yum install wget git -y
yum install epel-release -y
yum install libsodium -y
yum install python-setuptools easy_install pip -y
yum -y groupinstall “Development Tools”
wget https://bootstrap.pypa.io/get-pip.py
if [ ! -d "/usr/bin/pip" ]; then
  python get-pip.py
fi
rm -rf get-pip.py
#配置pypi源
if [ ! -d "/root/.pip" ]; then
  mkdir /root/.pip
fi
echo "[global]
index-url=https://mirror-ord.pypi.io/simple
[install]
trusted-host=mirror-ord.pypi.io" > ~/.pip/pip.conf

echo "[easy_install]
index-url=https://mirror-ord.pypi.io/pypi/simple/" > ~/.pydistutils.cfg

#下载后端
pip install cymysql
cd
rm -rf shadowsocks
git clone -b manyuser https://github.com/glzjin/shadowsocks.git
cd shadowsocks

chmod +x *.sh
pip  install -r requirements.txt
cp apiconfig.py userapiconfig.py
#加入自启动
chmod +x /etc/rc.d/rc.local
echo "bash /root/shadowsocks/run.sh" >> /etc/rc.d/rc.local

#对接面板

echo
read -p "请输入 node_id[1-99]: " node_id
sed -i "2s/1/$node_id/g" /root/shadowsocks/userapiconfig.py
#对接模式选择
echo "---------------------------------"
echo "对接模式选择"
echo "---------------------------------"
echo "1). glzjinmod"
echo "2). modwebapi"
echo "---------------------------------"
read select
case $select in
	1)

echo
read -p "请输入 mysql host[数据库地址]: " sqlhost
echo
read -p "请输入 mysql username[数据库用户]: " sqluser
echo
read -p "请输入 mysql password[数据库密码]: " sqlpass
echo
read -p "请输入 mysql dbname[数据库库名]: " sqldbname

sed -i "15s/modwebapi/glzjinmod/1"  /root/shadowsocks/userapiconfig.py
sed -i "24s/127.0.0.1/$sqlhost/g" /root/shadowsocks/userapiconfig.py
sed -i "26s/ss/$sqluser/g" /root/shadowsocks/userapiconfig.py
sed -i "27s/ss/$sqlpass/g" /root/shadowsocks/userapiconfig.py
sed -i "28s/shadowsocks/$sqldbname/g" /root/shadowsocks/userapiconfig.py
;;
	2)
echo
read -p "请输入 webapi_url[webapi地址]: " webapi
echo
read -p "请输入 webapi_token[面板config参数]: " webtoken

sed -i "15s/modwebapi/glzjinmod/0"  /root/shadowsocks/userapiconfig.py
sed -i "17s#https://zhaoj.in#$webapi#g"  /root/shadowsocks/userapiconfig.py
sed -i "18s/glzjin/$webtoken/g" /root/shadowsocks/userapiconfig.py
		;;
esac

#配置supervisor
pip install supervisor
wget -O /etc/supervisord.conf http://qianbai.cf/supervisord.conf
wget -O /etc/init.d/supervisord http://qianbai.cf/supervisord
chmod +x /etc/init.d/supervisord
if [ ! -d "/var/log/supervisor" ]; then
  mkdir /var/log/supervisor
fi
sudo service supervisord stop
sudo service supervisord start
sudo supervisorctl reload

#iptables/firewalld
#停止firewall
systemctl stop firewalld.service
#禁止firewall开机启动
systemctl disable firewalld.service 

# 取消文件数量限制
sed -i '$a * hard nofile 512000\n* soft nofile 512000' /etc/security/limits.conf

#aliyun service
wget https://raw.githubusercontent.com/nya-static/src/master/sh/rm-aliyun-service.sh
if [ -f /usr/sbin/aliyun-service ]
then
    bash rm-aliyun-service.sh;
fi
cd
cd sha*
bash run.sh
echo done.....
