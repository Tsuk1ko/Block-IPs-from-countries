#!/bin/bash
# Jindai Kirin
# https://lolico.moe
# https://github.com/YKilin/Block-IPs-from-countries

# 添加/更新ipset
function add_ipset {
	# 国家代码
	GEOIP=$1
	echo "Downloading IPs data..."
	wget -P /tmp http://www.ipdeny.com/ipblocks/data/countries/$GEOIP.zone 2> /dev/null
	# 检查下载是否成功
	if [ -f "/tmp/"$GEOIP".zone" ]; then
		echo "Download success."
	else
		echo "Failed to download data. Please check your input."
		exit 1
	fi
	# 判断是否已经有此set
	lookuplist=`ipset list | grep "Name:" | grep $GEOIP"ip"`
	if [ -n "$lookuplist" ]; then
		echo "Updating ipset... It may take a long time, please holdon."
		ipset flush $GEOIP"ip"
	else
		echo "Creating ipset... It may take a long time, please holdon."
		ipset -N $GEOIP"ip" hash:net
	fi
	# 加入数据
	for i in `cat /tmp/$GEOIP.zone`; do ipset -A $GEOIP"ip" $i; done
	rm -f /tmp/$GEOIP.zone
	echo "Done!"
}

# 封禁ip
function block_ipset {
	# 国家代码
	GEOIP=$1
	# 判断是否已经有此set
	lookuplist=`ipset list | grep "Name:" | grep $GEOIP"ip"`
	if [ -n "$lookuplist" ]; then
		iptables -I INPUT -p tcp -m set --match-set $GEOIP"ip" src -j DROP
		iptables -I INPUT -p udp -m set --match-set $GEOIP"ip" src -j DROP
		echo "Block IPs from $GEOIP successfully!"
	else
		echo "Failed. You have not added $GEOIP ipset yet."
		echo "Please use option -a to add it first."
		exit 1
	fi
}

# 解封ip
function unblock_ipset {
	# 国家代码
	GEOIP=$1
	iptables -D INPUT -p tcp -m set --match-set $GEOIP"ip" src -j DROP
	iptables -D INPUT -p udp -m set --match-set $GEOIP"ip" src -j DROP
	echo "Unblock IPs from $GEOIP successfully!"
}

# 打印帮助信息
function print_help {
	echo "Usage: bash block-ips.sh <option> <GeoIP>"
	echo "Options:"
	echo -e " -a\t\tAdd or update the ipset of a country"
	echo -e "   \t\tYou could know what GeoIP you can use in"
	echo -e "   \t\thttp://www.ipdeny.com/ipblocks/data/countries/"
	echo -e "   \t\tNotice: GeoIP must be LOWERCACE"
	echo -e " -b\t\tBlock IPs from the country you specified,"
	echo -e "   \t\taccording to the ipset you add with -a"
	echo -e " -u\t\tUnblock IPs from a country"
	echo -e " -h, --help\tShow this help message and exit"
	exit 0
}

# 检查参数
function check_arg {
	if [ -z $1 ]; then
		echo "Missing mandatory argument!"
		echo
		print_help
	fi
}

# ----------------main----------------
# 检查ipset是否安装
test=`ipset help 2>/dev/null | grep hash:ip`
if [ -z "$test" ]; then
	echo "You have not installed ipset!"
	echo "Please install it with:"
	echo -e "\tapt-get install -y ipset"
	echo -e "\tor"
	echo -e "\tyum install -y ipset"
	exit 1
fi

# 检查参数


case $1 in
-a) check_arg $2
	add_ipset $2
;;
-b) check_arg $2
	block_ipset $2
;;
-u) check_arg $2
	unblock_ipset $2
;;
-h) print_help;;
--help) print_help;;
*)	echo "Option error!"
	echo
	print_help
;;
esac
