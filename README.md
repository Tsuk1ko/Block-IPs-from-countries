# Block IPs from countries
A linux bash script to help you block IPs from countries.

## Prepare
Install ipset
```bash
apt-get install -y ipset
```
or
```bash
yum install -y ipset
```

## Usage
```
Usage: bash block-ips.sh <option> [GeoIP]
Options:
	-a <GeoIP>	Add or update the ipset of a country
	  		You could know what GeoIP you can use in
	  		http://www.ipdeny.com/ipblocks/data/countries/
	  		Notice: GeoIP must be LOWERCACE
	-b <GeoIP>	Block IPs from the country you specified,
	  		according to the ipset you add with -a
	-u <GeoIP>	Unblock IPs from a country
	-l 		List the countries which are blocked
	-h, --help	Show this help message and exit
```

## Example
If you want to block IPs from China
```bash
wget https://raw.githubusercontent.com/YKilin/Block-IPs-from-countries/master/block-ips.sh
bash block-ips.sh -a cn
bash block-ips.sh -b cn
```
If you want to unblock IPs from China
```bash
bash block-ips.sh -u cn
```