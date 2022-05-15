# Colors
white="\e[97m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
bold="\e[1m"
purple="\e[35m"

# Reading entered domain
echo -e "${green}${bold}Enter domain to enumerate subdomains:- ${white}" ;
read domain ;

# BOOT WEESLEYLUNA
echo -e "${red}${bold}[+]BOOT OF ${purple}WEESLEYLUNA";


# Creating directories
if [ ! -d "$domain" ];then
        mkdir $domain
fi


# Enumerate all domains
echo -e "${red}[+]Enumerate all domains..."; 
assetfinder --subs-only ${domain} > $domain/assetfinder.txt -silent;
subfinder -d ${domain} -o $domain/subfinder.txt -silent;
amass enum --passive -d $domain -o $domain/amass.txt -silent;

# Enumerate Cert.sh
echo -e "${red}[+]Enumerate CERT.SH...";
curl -s "https://crt.sh/?q=%25.$domain&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | anew $domain/cert.txt

# Combining results
echo "domains saved at $domain/domains.txt..."; 
cat $domain/assetfinder.txt $domain/subfinder.txt $domain/amass.txt $domain/cert.txt | anew $domain/domains.txt 

# Enumerate DNS
echo -e "${red}[+]Enumerating DNS...";
cat ${domain}/domains.txt | dnsx -silent -a -resp-only -o $domain/dnsx.txt 

# Enumerate CIDR
echo -e "${red}[+]Enumerating CIDR..."; 
mapcidr -l $domain/dnsx.txt -silent -aggregate -o $domain/mapcidr.txt

# Enumerate Naabu
echo -e "${blue}[+]Enumerating NAABU..." ;
naabu -l $domain/mapcidr.txt top-ports 100 -silent -sa | httpx -silent -timeout 60 -threads 100 | anew $domain/naabuIP.txt
