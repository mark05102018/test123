#!/bin/bash


val () {

url=$1
echo $url > domain.txt

domain=$(sed 's/\.com.*/.com/' domain.txt | sed -r 's/.{12}//')
https=$( sed 's/\.com.*/.com/' domain.txt)
ip=$(dig $domain +short | tail -1)

if [[ -n "$ip" ]]
then

# IP's above (space) are CLOUDFLARE and below (space) are INCAPSULA. 	

NETWORKS="103.21.244.0/22 
103.22.200.0/22 
103.31.4.0/22
104.16.0.0/12 
108.162.192.0/18 
131.0.72.0/22 
141.101.64.0/18 
162.158.0.0/15 
172.64.0.0/13 
173.245.48.0/20 
188.114.96.0/20 
190.93.240.0/20 
197.234.240.0/22 
198.41.128.0/17
 
199.83.128.0/21 
198.143.32.0/19 
149.126.72.0/21 
103.28.248.0/22 
45.64.64.0/22 
185.11.124.0/22 
192.230.64.0/18 
107.154.0.0/16 
45.60.0.0/16 
45.223.0.0/16"

for IP in $ip; do
    grepcidr "$NETWORKS" <(echo "$IP") >/dev/null && \
        ip_stat=0 || \
        ip_stat=1
done

        if [[ $ip_stat == 0 ]]
	then
		https_stat=$(wget $https -q -S 2>&1 | head -1 | awk '{print $2}')
		if [[ $https_stat == 200 ]]
	        then
	              	file_stat=$( wget $1 -q -S 2>&1 | head -1 | awk '{print $2}')
	                if [[ $file_stat == 200 ]] 
	                then
        	                wget $1 -q -O $domain
                	        md5_dl=$(md5sum $domain | awk '{print $1}')
				md5_web=$(wget $1 -q -O - | md5sum | awk '{print $1}')
				rm $domain
				if [[ $md5_web == $md5_dl ]]
                      	 	then
				return 0
		
                	        else
                	        return 4
                	        fi
			
	                else
        	        return 3
	                fi

	        else
	        return 2
	        fi

	else
	return 5
	fi


else
return 1
fi

}

val $1
echo "$?"

rm domain.txt
