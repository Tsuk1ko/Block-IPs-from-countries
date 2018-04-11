#!/bin/bash
# Jindai Kirin
# https://lolico.moe
# https://github.com/YKilin/Block-IPs-from-countries

DAL="delegated-apnic-latest.txt"

# 添加/更新ipset
function add_ipset {
	# 国家代码
	CCODE=`echo $1 | tr 'a-z' 'A-Z'`
	TMPFILE=$(mktemp /tmp/bi.XXXXXXXXXX)
	# 没有列表就下载
	if [ ! -s $DAL ]; then
		echo "Downloading IPs data..."
		curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' > $DAL
	fi
	# 获取IP段
	cat $DAL | grep ipv4 | grep $CCODE | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > $TMPFILE
	# 检查是否成功
	if [ -s $TMPFILE ]; then
		echo "Get IP data success."
	else
		echo
		echo "Failed to get IP data. Please check your input."
		echo
		echo "You could know what country code you can use in"
		echo
		echo "http://doc.chacuo.net/iso-3166-1"
		echo "or"
		echo "https://www.iso.org/obp/ui/"
		echo
		echo "Country code is not case sensitive."
		echo
		exit 1
	fi
	# 判断是否已经有此set
	lookuplist=`ipset list | grep "Name:" | grep $CCODE"ip"`
	if [ -n "$lookuplist" ]; then
		echo "Updating [$CCODE] ipset... It may take a long time, please holdon."
		ipset flush $CCODE"ip"
	else
		echo "Creating [$CCODE] ipset... It may take a long time, please holdon."
		ipset -N $CCODE"ip" hash:net
	fi
	# 加入数据
	for i in `cat $TMPFILE`; do ipset -A $CCODE"ip" $i; done
	rm -f $TMPFILE
	echo "Done!"
}

# 封禁ip
function block_ipset {
	# 国家代码
	CCODE=$1
	# 判断是否已经有此set
	lookuplist=`ipset list | grep "Name:" | grep $CCODE"ip"`
	if [ -n "$lookuplist" ]; then
		iptables -I INPUT -p tcp -m set --match-set $CCODE"ip" src -j DROP
		iptables -I INPUT -p udp -m set --match-set $CCODE"ip" src -j DROP
		echo "Block IPs from [$CCODE] successfully!"
	else
		echo "Failed. You have not added [$CCODE] ipset yet."
		echo "Please use option -a to add it first."
		exit 1
	fi
}

# 解封ip
function unblock_ipset {
	# 国家代码
	CCODE=$1
	iptables -D INPUT -p tcp -m set --match-set $CCODE"ip" src -j DROP
	iptables -D INPUT -p udp -m set --match-set $CCODE"ip" src -j DROP
	echo "Unblock IPs from [$CCODE] successfully!"
}

# 查看封禁列表
function block_list {
	iptables -L | grep match-set
}

# 打印帮助信息
function print_help {
	echo
	echo "Usage: bash block-ips.sh <option> [country code]"
	echo "Options:"
	echo -e "  -a <country code>\tAdd or update the ipset of a country"
	echo -e "    \t\t\tYou could know what country code you can use (alpha-2 code) in"
	echo -e "    \t\t\thttp://www.ipdeny.com/ipblocks/data/countries/"
	echo -e "    \t\t\tor https://www.iso.org/obp/ui/"
	echo -e "    \t\t\tNotice: If you want to update IP data, please delete file"
	echo -e "    \t\t\t$DAL first"
	echo -e "  -b <country code>\tBlock IPs from the country you specified, according"
	echo -e "    \t\t\tto the ipset you add with -a"
	echo -e "  -u <country code>\tUnblock IPs from a country"
	echo -e "  -l \t\t\tList the countries which are blocked"
	echo -e "  -h, --help\t\tShow this help message and exit"
	echo
	exit 0
}

# 检查参数
function check_arg {
	if [ -z $1 ]; then
		echo "Missing mandatory argument!"
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
	echo
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
-l) block_list;;
-h) print_help;;
--help) print_help;;
*)	echo "Option error!"
	print_help
;;
esac
