#!/bin/bash
# https://raw.githubusercontent.com/YKilin/Block-IPs-from-countries/master/block-ips.sh

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
	if [ -z "$lookuplist" ]; then
		echo "Creating ipset... It may take a long time, please holdon."
		ipset -N $GEOIP"ip" hash:net
	else
		echo "Updating ipset... It may take a long time, please holdon."
		ipset flush $GEOIP"ip"
	fi
	# 加入数据
	for i in `cat /tmp/$GEOIP.zone`; do ipset -A $GEOIP"ip" $i; done
	rm -f /tmp/$GEOIP.zone
	echo "Finished!"
}

add_ipset ad