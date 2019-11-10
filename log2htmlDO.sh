#!/bin/bash
#title           :log2htmlDO.sh
#description     :This script retrieves information through BASH shell commands and diplays them in a HTML page
#                 build on the fly with a joined CSS style sheet.
#                 Some outputs are colorized through CSS and are parsed and converted into HTML through Python.
#                 For VMWare or AWS EC2 cloud instances Data, please see log2htmlVM.sh or log2htmlAWS.sh
#author		     :Thomas Simon
#date            :20190927
#version         :0.2
#usage		     :bash log2htmlDO.sh / automate by adding to crontab
#notes           :You'll need Python ≥ 2, pip and Pygments, install it with "pip install Pygments". http://pygments.org/.
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
ip=$(curl -s http://api.ipify.org/)
ipcfg=$(ifconfig | grep -i inet | grep -v inet6 | grep -v "127.0.0.1" | cut -d: -f1 | cut -c14-27 | cut -d 'n' -f 1)
dns=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2)
auth=$(tail -n 200 /var/log/auth.log | grep -v 'pam_unix(cron:session):' | pygmentize -f html)

### CLOUD instance Metadata for DIGITALOCEAN Droplet
hostname=$(curl -s http://169.254.169.254/metadata/v1/hostname)
instanceId=$(curl -s http://169.254.169.254/metadata/v1/id)
lanIp=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/address)
netmask=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/netmask)
gateway=$(curl -s http://169.254.169.254/metadata/v1/interfaces/public/0/anchor_ipv4/gateway)
region=$(curl -s http://169.254.169.254/metadata/v1/region)
activeFloating=$(curl -s http://169.254.169.254/metadata/v1/floating_ip/ipv4/active)
activeFloatingIp=$(curl -s http://169.254.169.254/metadata/v1/floating_ip/ipv4/ip_address)

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
echo '<nav>
        <ul><li><a class="navlink" href="#main">System Stats and Logs Information:</a></li>
        <li><a class="navlink" href="#host">Host</a></li>
        <li><a class="navlink" href="#network">Network</a></li>
        <li><a class="navlink" href="#resources">Resources</a></li>
        <li><a class="navlink" href="#auth_logs">Auth Logs</a></li>
        <li><a class="navlink" href="#http_logs">HTTP Logs</a></li>
        </ul></nav>' >> $htmlFile;
echo "            <div class="main" id="main">" >> $htmlFile;
echo "<span class="anchor" id="host"></span><a name="host">&nbsp</a><h1 class="host">Instance Host Information</h1>" >> $htmlFile;
echo "<p><b>Hostname</b> <span class="doresults">$hostname</span> <b>has id</b> <span class="doresults">$instanceId</span></p>" >> $htmlFile;
echo "<p><b>Date</b>: <span class="doresults">$date</span></p>" >> $htmlFile;
echo "<p><b>Uptime</b>: <span class="doresults">$uptime</span></p>" >> $htmlFile;
echo "<p><b>User running script is</b>: <span class="doresults">$youare</span> <span class="doresults">$id</span></p>" >> $htmlFile;
echo "<p><b>At</b>: <span class="doresults">$hostinfo</span></p>" >> $htmlFile;
echo "<p><b>OS Information</b>:<br><pre>$osinfo</pre></p>" >> $htmlFile
echo "<span class="anchor" id="network"></span><a name="network">&nbsp</a><h1 class="network">Instance Network Information</h1>" >> $htmlFile;
echo "<p><b>Private IPv4 </b><span class="doresults">$lanIp</span><b> has netmask </b><span class="doresults">$netmask</span><b> and gateway </b><span class="doresults">$gateway</span></p>" >> $htmlFile;
echo "<p><b>Is floating IP active?</b>: <span class="doresults">$activeFloating</span><b> and has address </b><span class="doresults">$activeFloatingIp</span></p>" >> $htmlFile;
echo "<p><b>Wan </b>$ip - <b>eth0 </b><span class="doresults">$ipcfg</span></p>" >> $htmlFile;
echo "<p><b>DNS IP </b><span class="doresults">$dns</span></p>" >> $htmlFile;
echo "<span class="anchor" id="resources"></span><a name="resources">&nbsp</a><h1 class="resources">Instance Resources & Users Information</h1>" >> $htmlFile;
echo "<p><b>Connected users</b>:<br><pre>$who</pre></p>" >> $htmlFile;
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