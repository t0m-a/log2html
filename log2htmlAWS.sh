#!/bin/bash
#title           :log2htmlAWS.sh
#description     :This script retrieves information through BASH shell commands and requests to Cloud APIs
#                 and diplays them in a HTML page build on the fly with a joined CSS style sheet.
#                 Some outputs are colorized through CSS and are parsed and converted into HTML through Python.
#                 For VMWare or DigitalOcean cloud instances Data, please see log2htmlVM.sh or log2htmlDO.sh
#author		     :Thomas Simon
#date            :20190927
#version         :0.2
#usage		     :bash log2htmlAWS.sh / automate by adding to crontab
#notes           :You'll need Python ≥ 2, pip and Pygments, install apt install python-pigments. http://pygments.org/.
#bash_version    :version 4.4.20(1)-release
#========================================================================================================================

# PATHS
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

### GLOBAL VARIABLES
### SYSTEM information Data
hostname=`hostname`
id=$(id)
hostinfo=$(uname -a)
osinfo=$(cat /etc/os-release | grep -v URL)
youare=`whoami`
date=`date`
uptime=`uptime`
who=$(w)
diskfree=$(df --total -h)
memfree=$(free -h | grep -v "+")
ip=$(curl -s -q http://api.ipify.org/)
ipcfg=$(ifconfig | grep -i inet | grep -v inet6 | grep -v "127.0.0.1" | cut -d: -f1 | cut -c14-27 | cut -d 'n' -f 1)
dns=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2)
auth=$(tail -n 200 /var/log/auth.log | grep -v 'pam_unix(cron:session):' | pygmentize -f html)

### CLOUD instance Metadata for AWS EC2.
volumeAmi=$(curl -s http://169.254.169.254/latest/meta-data/block-device-mapping/ami/)
volumeRoot=$(curl -s http://169.254.169.254/latest/meta-data/block-device-mapping/root/)
instanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
instanceType=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
instanceSignature=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/signature)
availabilityZone=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
securityGroups=$(curl -s http://169.254.169.254/latest/meta-data/security-groups)
sshPubKey=$(curl -s http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key)
localIpv4=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
hMac=$(curl -s http://169.254.169.254/latest/meta-data/mac)
netmask=$(ifconfig | grep -i netmask | grep -v 127 | awk '{print $4}')
lanip=$(ifconfig | grep -i netmask | grep -v 127 | awk '{print $2}')
gateway=$(ip route | grep -i default | awk '{print $3}')
privateDns=$(curl -s http://169.254.169.254/latest/meta-data/hostname)
publicDns=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
awsDomain=$(curl -s http://169.254.169.254/latest/meta-data/services/domain)
awsDomainPartition=$(curl -s http://169.254.169.254/latest/meta-data/services/partition)
instanceFullDocument=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document)

### HTTP LOG Files
access=$(tail -n 75 /var/log/nginx/access.log /var/log/nginx/access.log.1 | pygmentize -f html)
error=$(tail -n 75 /var/log/nginx/error.log /var/log/nginx/error.log.1 | pygmentize -f html)

### CUSTOM HTTP LOG files BY DOMAINS or SUBDOMAINS, set parameters and uncomment accordingdly.
### DOMAIN(s) and SUBDOMAIN(S) variables
#subdomain='exampleSubdomainName1'
#subdomain2='subdomainName2'

### NGINX paths to LOG files
#subdomainAccess=$(tail -n 75 /var/log/nginx/$subdomain_access.log | pygmentize -f html)
#subdomainError=$(tail -n 75 /var/log/nginx/$subdomain_error.log | pygmentize -f html)
#subdomainAccess2=$(tail -n 75 /var/log/nginx/$subdomain_access.log | pygmentize -f html)
#subdomainError2=$(tail -n 75 /var/log/nginx/$subdomain_error.log | pygmentize -f html)

### APACHE2 paths to LOG files
#subdomainAccess=$(tail -n 75 /var/log/apache2/$subdomain_access.log | pygmentize -f html)
#subdomainError=$(tail -n 75 /var/log/apache2/$subdomain_error.log | pygmentize -f html)
#subdomainAccess2=$(tail -n 75 /var/log/apache2/$subdomain_access.log | pygmentize -f html)
#subdomainError2=$(tail -n 75 /var/log/apache2/$subdomain_error.log | pygmentize -f html)
#apacheOtherVhostsAccess=$(tail -n 75 /var/log/apache2/other_vhosts_access.log | pygmentize -f html)

### Creating workDir and HTML work file
mkdir -p /var/www/html/logs;
htmlFile="/var/www/html/logs/index.html"
test -f $htmlFile || touch $htmlFile

### Writting variables content data into HTML file
### We start a fresh file by over writting existing HTML content with " > " when declaring <!DOCTYPE><html><head>
echo "<!DOCTYPE html>
<html>
    <head>" > $htmlFile;
echo '  <meta charset="utf-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <link href="https://fonts.googleapis.com/css?family=Libre+Franklin:300,400|Roboto+Mono:300,400&display=swap" rel="stylesheet">
        <link REL=StyleSheet HREF="style.css" TYPE="text/css">' >> $htmlFile;
echo "  <title>Stats and Logs at $hostname</title>" >> $htmlFile;
echo "      </head>
        <body>" >> $htmlFile;
echo '<nav><span class="title"><a class="navlink" href="#main">System Stats and Logs Information</a></span>
        <ul>
        <li><a class="navlink" href="#host">Host</a></li>
        <li><a class="navlink" href="#network">Network</a></li>
        <li><a class="navlink" href="#resources">Resources</a></li>
        <li><a class="navlink" href="#auth_logs">Auth Logs</a></li>
        <li><a class="navlink" href="#http_logs">HTTP Logs</a></li>
        </ul></nav>' >> $htmlFile;
echo "            <div class="main" id="main">" >> $htmlFile;
echo "<span class="anchor" id="host"></span><a name="host">&nbsp</a><h1 class="host">Instance Host Information</h1>" >> $htmlFile;
echo "<p><b>Hostname</b> <span id="highlight">$hostname</span> <b>has id</b> <span id="highlight">$instanceId</span> and is of <b>type</b> <span id="highlight">$instanceType</span> in <b>region</b> <span id="highlight">$availabilityZone</span></p>" >> $htmlFile;
echo "<p><b><span id="highlight">Private</span> IPV4 DNS hostname is</b>: $privateDns. And <b><span id="highlight">Public</span> IPV4 DNS hostname is</b>: $publicDns</p>" >> $htmlFile;
echo "<p><b>Instance signature is</b>: $instanceSignature</p>" >> $htmlFile;
echo "<p><b>Date</b>: $date</p>" >> $htmlFile;
echo "<p><b>Uptime</b>: $uptime</p>" >> $htmlFile;
echo "<p><b>User running script is</b>: $youare $id</p>" >> $htmlFile;
echo "<p><b>At</b>: $hostinfo</p>" >> $htmlFile;
echo "<p><b>AWS domain of instance is</b>: $awsDomain. <b>AWS domain partition is:</b> $awsDomainPartition</p>" >> $htmlFile;
echo "<p><b>OS Information</b>:<br><pre>$osinfo</pre></p>" >> $htmlFile
echo "<p><b>AWS instance document (full)</b>:<br><pre>$instanceFullDocument</pre></p>" >> $htmlFile
echo "<span class="anchor" id="network"></span><a name="network">&nbsp</a><h1 class="network">Instance Network Information</h1>" >> $htmlFile;
echo "<p><b>Private IPv4 </b>$localIpv4<b> has netmask </b>$netmask<b> and gateway </b>$gateway</p>" >> $htmlFile;
echo "<p><b>Wan address is</b>: $ip - <b>ETH0 address is</b>: $ipcfg and <b>has MAC</b>: $hMac</p>" >> $htmlFile;
echo "<p><b>DNS IP </b>$dns</p>" >> $htmlFile;
echo "<p><b>AWS Security Groups are</b>: $securityGroups</p>" >> $htmlFile;
echo "<p><b>Publich SSH Key recorded</b>:<br><pre>$sshPubKey</pre></p>" >> $htmlFile;
echo "<span class="anchor" id="resources"></span><a name="resources">&nbsp</a><h1 class="resources">Instance Resources & Users Information</h1>" >> $htmlFile;
echo "<p><b>Connected users</b>:<br><pre>$who</pre></p>" >> $htmlFile;
echo "<p><b>AMI volume is</b>: $volumeAmi. <b>System ROOT volume is</b>: $volumeRoot</p>" >> $htmlFile;
echo "<p><b>Volumes usage</b>:<br><pre>$diskfree</pre></p>" >> $htmlFile;
echo "<p><b>Memory usage</b>:<br><pre>$memfree</pre></p>" >> $htmlFile;
echo "<span class="anchor" id="auth_logs"></span><a name="auth_logs">&nbsp</a><h1 class="auth_logs">Instance Authentification & Access Information</h1>" >> $htmlFile;
echo "<p><b>Auth logs</b>:<br>$auth</p>" >> $htmlFile;
echo "<span class="anchor" id="http_logs"></span><a name="http_logs">&nbsp</a><h1 class="http_logs">Instance HTTP Log Information</h1>" >> $htmlFile;
echo "<p><b>NGINX Main Access logs</b>:<br>$access</p>" >> $htmlFile;
echo "<p><b>NGINX Main Error logs</b>:<br>$error</p>" >> $htmlFile;
### HTML section example for NGINX CUSTOM HTTP LOG files BY SUBDOMAINS, set parameters accordingdly and uncomment.
#echo "<p><b>NGINX $subdomain Access logs:</b><br>$subdomainAccess" >> $htmlFile;
#echo "<p><b>NGINX $subdomain Error logs:</b><br>$subdomainError" >> $htmlFile;
### HTML section example for APACHE CUSTOM HTTP LOG files BY SUBDOMAINS, set parameters accordingdly and uncomment.
#echo "<p><b>APACHE $subdomain Access logs:</b><br>$subdomainAccess" >> $htmlFile;
#echo "<p><b>APACHE $subdomain Error logs:</b><br>$subdomainAccess" >> $htmlFile;
echo '              </div>
                    <footer><div class="full-width">
                        <ul><li><a class="navlink" href="#main">Page top</a></ul></li></p>
                    </div></footer>
        </body>
</html>' >> $htmlFile;
exit 0