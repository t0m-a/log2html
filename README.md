# log2html

Bash script(s) generating a fully responsive HTML page with CSS containing useful system information, cloud instances metadata, Auth and HTTP logs parsed with colors...

## Description

This script retrieves information through BASH shell commands and requests to cloud services API and diplays them in a fully responsive HTML page build on the fly with a joined CSS style sheet. Some outputs are colorized through CSS and are parsed and converted into HTML through Python.

### Repository content

There are four files in the repository:

- One for classical VMWare Linux virtual machines.
- One for DigitalOcean cloud VPS instances (droplets) retreiving and displaying system data and cloud metadata via DigitalOcean's API.
- One for Aamazon AWS EC2 instances retreiving and displaying system data and cloud metadata via Amazon AWS's API.
- One CSS stylesheet, style.css, containing main styles and responsive programming.

## Pre-requisites

You will need Python ≥ 2 and Pygments [http://pygments.org/](http://pygments.org/).
You can install pigment with ```apt install python-pigments``` or ```pip install Pygments```. 

## Details

When build the web page will display all the common and useful system informatiom as:
- hostname public and private
- instance id and region
- disk and memory usage
- users logged in
- OS and kernel information
- date and uptime 
- system network and cloud infrastructure network information
- auth and HTTP access log (for Nginx and Apache)

### Updated styles per providers

DigitalOcean, blue:
![Program generated web page screenshot](https://tsimon.me/img/do.jpg)
Amazon Web Service, orange:
![Program generated web page screenshot](https://tsimon.me/img/aws.jpg)
VNware, green:
![Program generated web page screenshot](https://tsimon.me/img/vm.jpg)

### Screenshots

Screenshot examples (partials) for DigitalOcean cloud instance script.

Host section:
![Program generated web page screenshot](https://tsimon.me/img/genlogsh1.jpg)
Network section:
![Program generated web page screenshot](https://tsimon.me/img/genlogsh2.jpg)
Resources section:
![Program generated web page screenshot](https://tsimon.me/img/genlogsh3.jpg)
Logs sections:
![Program generated web page screenshot](https://tsimon.me/img/genlogsh4.jpg)
![Program generated web page screenshot](https://tsimon.me/img/genlogsh5.jpg)


