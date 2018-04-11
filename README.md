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
Usage: bash block-ips.sh <option> [country code]
Options:
  -a <country code>	Add or update the ipset of a country
    			You could know what country code you can use (alpha-2 code) in
    			http://www.ipdeny.com/ipblocks/data/countries/
    			or https://www.iso.org/obp/ui/
    			Notice: If you want to update IP data, please delete file
    			delegated-apnic-latest.txt first
  -b <country code>	Block IPs from the country you specified, according
    			to the ipset you add with -a
  -u <country code>	Unblock IPs from a country
  -l 			List the countries which are blocked
  -h, --help		Show this help message and exit

```
Country code is not case sensitive.

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