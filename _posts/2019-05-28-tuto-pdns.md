---
title: "Tutorial: Passive DNS"
date: 2019-05-28
layout: post
categories: 
tags: 
---

# Table of Contents

1.  [Motivation](#org363a15f)
2.  [Architecture Overview](#org3bd102e)
3.  [Preparation](#org35fa5e8)
4.  [Set up](#orgec39e5c)
    1.  [Passive DNS Collection](#org066917f)
    2.  [D4-core server](#orgfb19cd2)
    3.  [analyzer-d4-passivedns](#org907c1ab)
    4.  [Final steps](#org3f36b7b)
5.  [Appendix : Installing a server](#org01228af)
6.  [Appendix : Installing a sensor](#org3959502)
    1.  [C version](#orga42d98c)
    2.  [d4-goclient](#org167865b)

A passive DNS is a service that records DNS requests made over time, as well as their corresponding answers.


<a id="org363a15f"></a>

# Motivation

-   CIRCL (and other CSIRTs) have their own passive DNS collection mechanisms (eg. [CIRCL's](https://www.circl.lu/services/passive-dns)),
-   current collection models are affected with DoH (DNS over HTTPS) and centralised DNS services,
-   DNS answers collection is a tedious process,
-   sharing Passive DNS stream between organisation is challenging due to privacy

Our Strategy with using D4 is the following:

-   Improve Passive DNS collection diversity by being closer to the source and limit impact of DoH (e.g. at the OS resolver level),
-   increasing diversity and (mixing models) before sharing/storing Passive DNS records,
-   simplify process and tools to install for Passive DNS collection by relying on D4 sensors instead of custom mechanisms,
-   provide a distributed infrastructure for mixing streams and filtering out the sharing to the validated partners.


<a id="org3bd102e"></a>

# Architecture Overview

Before diving into the HOWTO, let's review how DNS data will flow in D4 and what
are the different actors. The following diagram reads from left to right, with
sensors on the left, and end-users of our passivedns webservice on the right.
Software components are numbered in red circles.

![img](/assets/images/pdns-d4.png "Passive DNS on D4")

The following table sums up D4'architecture and how its components interact:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-right" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-right">#</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-right">1</td>
<td class="org-left">PassiveDNS: captures DNS requests on an interface and pipes its standard output to d4-goclient (2)</td>
</tr>


<tr>
<td class="org-right">2</td>
<td class="org-left">d4-goclient: encapsulates data from stdin (1) and sends it to the d4 server defined in the config file</td>
</tr>


<tr>
<td class="org-right">3</td>
<td class="org-left">D4-core server: decapsulates d4 packets and pushes the content &#x2013;PassiveDNS "\n"-separated records&#x2013; to a list of D4 analyzer redis queue</td>
</tr>


<tr>
<td class="org-right">4</td>
<td class="org-left">analyzer-d4-passivedns/bin/pdns-ingestion.py: pops a specific D4 analyzer redis queue and pushes into a redis DB that is the REST API's backend</td>
</tr>


<tr>
<td class="org-right">5</td>
<td class="org-left">analyzer-d4-passivedns/bin/pdns-cof-server.py: serves the REST API</td>
</tr>
</tbody>
</table>


<a id="org35fa5e8"></a>

# Preparation

We distribute a Virtual Machine (VM) for this tutorial (tested under Virtual Box
6.0&#x2013;please don't use this in production): [click here](https://www.circl.lu/assets/files/D4_DEMO.ova)

    ff215397d757b6dc6351f84c18884383fb5fc5fe1613e42ff6e996327c40b2a7  D4_DEMO.ova

To install your own D4-PassiveDNS instance in production follow the Appendix and
this end of this page.

The functioning of D4 requires the opening of several ports on the VM, here is
the current setup after importing the .ova file into Virtual Box (VB):

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-right" />

<col  class="org-right" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">Service</th>
<th scope="col" class="org-right">Host IP</th>
<th scope="col" class="org-right">Host port</th>
<th scope="col" class="org-right">Guest port</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">D4 server - Admin Web Interface</td>
<td class="org-right">127.0.0.1</td>
<td class="org-right">7000</td>
<td class="org-right">7000</td>
</tr>


<tr>
<td class="org-left">D4 server - ssh</td>
<td class="org-right">127.0.0.1</td>
<td class="org-right">2222</td>
<td class="org-right">22</td>
</tr>


<tr>
<td class="org-left">D4 server - tls d4</td>
<td class="org-right">127.0.0.1</td>
<td class="org-right">4443</td>
<td class="org-right">4443</td>
</tr>


<tr>
<td class="org-left">D4 server - passive DNS lookup</td>
<td class="org-right">127.0.0.1</td>
<td class="org-right">8400</td>
<td class="org-right">8400</td>
</tr>
</tbody>
</table>

This VM already contains all the needed D4 components, that we will now
configure to set up a full D4-PassiveDNS chain.

For testing purpose (generate DNS traffic inside the guest VM), we will use SSH
as a SOCKS5 proxy. Fire up the VM and use a terminal to reach it from the host:

    ssh -D 1337 -E /dev/null d4@127.0.0.1 -p 2222 #d4's account password is 'Password1234'.

You can use can use this terminal to interact with the VM, the SOCKS proxy will
stay accessible as long as this SSH connection remains open.

To use this proxy with any web browser, for instance chromium:

    chromium --proxy-server="socks5://127.0.0.1:1337" --proxy-bypass-list="<-loopback>"


<a id="orgec39e5c"></a>

# Set up


<a id="org066917f"></a>

## Passive DNS Collection

Two components are used for the collection: [passivedns](https://github.com/gamelinux/passivedns) and [d4-goclient](https://github.com/D4-project/d4-goclient).
passivedns is installed system-wide, for demonstration purpose launch passivedns
using the following command:

    sudo passivedns -i eth0 -l /dev/stdout

Use your proxied web-browser (set up as explained above) to see the passivedns
records printing on screen in the following form:

    1558960214.117262||10.0.2.15||10.0.2.3||IN||hubt.pornhub.com.||CNAME||hubtraffic.com.||3600||1

The output of this command will be piped into d4-goclient, but we need to specify the correct parameters to reach the server.
Fortunately, the configuration is already done in ~/go/src/github.com/D4-project/d4-goclient/conf.vbox/
Each of these parameter is written in a file with the same name. These are detailed in the following table:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">parameter</th>
<th scope="col" class="org-left">description</th>
<th scope="col" class="org-right">value</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">destination</td>
<td class="org-left">address and port of the receiving D4 server</td>
<td class="org-right">127.0.0.1:4443</td>
</tr>


<tr>
<td class="org-left">source</td>
<td class="org-left">where to look for input data</td>
<td class="org-right">stdin</td>
</tr>


<tr>
<td class="org-left">snaplen</td>
<td class="org-left">D4 packet size</td>
<td class="org-right">4096</td>
</tr>


<tr>
<td class="org-left">type</td>
<td class="org-left">type of D4 packets sent, this is used by d4-server to know how to handle the data received</td>
<td class="org-right">8</td>
</tr>


<tr>
<td class="org-left">uuid</td>
<td class="org-left">sensor's unique identifier</td>
<td class="org-right">automatically provisioned</td>
</tr>


<tr>
<td class="org-left">key</td>
<td class="org-left">a Pre-Shared Key used to authenticate the sensor to the server</td>
<td class="org-right">"private key to change"</td>
</tr>


<tr>
<td class="org-left">version</td>
<td class="org-left">D4 protocol version</td>
<td class="org-right">1</td>
</tr>
</tbody>
</table>

We can now point this configuration to the d4-goclient by using the -c flag, and
combine both commands:

    cd ~/go/src/github.com/D4-project/d4-goclient
    sudo passivedns -i eth0 -l /dev/stdout | ./d4-amd64l -c conf.vbox

**Protip**: change the destination to stdout to observe D4 protocol at work! 

**Protip**: for more convenience, you can prefer launching this task in a screen:

    cd ~/go/src/github.com/D4-project/d4-goclient
    screen -dmS "pdns-collection"
    screen -S "pdns-collection" -X screen -t "collection" bash -c "sudo passivedns -i eth0 -l /dev/stdout | ./d4-amd64l -c conf.vbox; read x;"

If you are only interested into how to set up a D4 sensor **congratulations!** you
are done, your sensor is streaming its passivedns capture to the specified D4
server (**contact us at info@circl.lu if you want to push on ours!**).


<a id="orgfb19cd2"></a>

## D4-core server

[D4-core server](https://github.com/D4-project/d4-core) is in charge of managing sensors and analyzers. Point a
non-proxied web browser to the following address: <http://127.0.0.1:7000> to reach
it. In the following view, D4-server lists numbers of packets received by D4
packets type and sensor uuid:

![img](/assets/images/sensors.png "D4-server landing-page")

On the status page, one can list all connected sensors. If your passivedns
collection works, you should have one sensor appearing as connected:

![img](/assets/images/status.png "D4-server sensor-status page")

Clicking on the uuid leads to the detailed status page of a sensor, along with
some statistics on various available server commands:

![img](/assets/images/sensor_detail.png "D4-server detailed sensor-status page")

What is of interest of for us now is located under the "server management" page.

What we need to do here is to create a redis queue that will be the link between
the d4-server worker (remember the #3 up there on the first diagram) that
unpacks D4 type 8 packets, and analyzer-d4-passivedns (4). In order to create
this queue, scroll down the page and locate the "Add New
Analyzer Queue" box:

![img](/assets/images/queue.png "Adding an analyzer queue")

Input the following:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-right" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">field</th>
<th scope="col" class="org-left">description</th>
<th scope="col" class="org-right">value</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">#1</td>
<td class="org-left">D4 type: DNS capture type is 8</td>
<td class="org-right">8</td>
</tr>


<tr>
<td class="org-left">#2</td>
<td class="org-left">uuid: click on the left-end side button to generate one</td>
<td class="org-right">&#xa0;</td>
</tr>


<tr>
<td class="org-left">#3</td>
<td class="org-left">Description of what this analyzer do</td>
<td class="org-right">pdns web service</td>
</tr>
</tbody>
</table>

Note that you can create duplicate redis queues and that analyzers will fetch
from. Input a informative description in the description field is a good idea
for not losing track of what is going on your server.


<a id="org907c1ab"></a>

## analyzer-d4-passivedns

Now that the redis queue is ready to be used by our analyzer, we need set it up
to use it. [Analyzer-d4-passivedns](https://github.com/D4-project/analyzer-d4-passivedns) is located in d4's HOME. cd to
~/analyzer-d4-passivedns/etc to modify analyzer.conf (vim and nano are
installed):

    [global]
    my-uuid = uuidthatappearinthed4interface 
    d4-server = 127.0.0.1:6380
    # INFO|DEBUG
    logging-level = INFO

Copy-paste the uuid of the Redis queue you just created for your analyzer.

![img](/assets/images/uuid.png "Adding an analyzer queue")

If you browse a website using your proxied web browser, you should see items
populating this redis queue. This counter will soon decrease to 0 as we will
launch the analyzer that will consume these items.


<a id="org3f36b7b"></a>

## Final steps

Now that everything is in place. We need to launch the analyzer.
Execute the launch-server.sh script located under ~/analyzer-d4-passivedns.
This will create screen session called pdns with the passivedns executables in tabs.

    cd ~/analyzer-d4-passivedns
    ./launch_server.py

**Protip**: You can reattach screen and navigate tabs:

    screen -r pdns # reatach detached screen
    # Use Ctrl+a " to switch tabs
    # Use Ctrl+a d to detach the current screen

By pointing your webbrowser to <http://127.0.0.1:7000/server_management> you can
observe that the analyzer queue is now emptied as soon as new entries enter the
queue:

![img](/assets/images/emptyqueue.png "Adding an analyzer queue")

All passive DNS records corresponding to the domains that have been resolved by
the Guest VM are now accessible through the passive DNS REST API ([see IETF draft
on Passive DNS Common Output Format for details](https://tools.ietf.org/html/draft-dulaunoy-dnsop-passive-dns-cof-06)):

![img](/assets/images/pdnsquery.png)


<a id="org01228af"></a>

# Appendix : Installing a server

For the people that wish to host their own server on a proper VM/machine we go
through the server installation process (as it is detailed in [d4-core project
repository](https://github.com/D4-project/d4-core/tree/master/server))

The server requires having python 3.6 on a GNU/Linux distro (alas we only tested on debian and ubuntu so far).
To install the server follow these steps:

    git clone https://github.com/D4-project/d4-core.git
    cd d4-core/server
    ./install_server.sh
    cd gen_cert
    ./gen_root.sh
    ./gen_cert.sh
    cd ..
    ./LAUNCH.sh -l

The last step launches the required server components in screen that one can list/reattach using:

    screen -ls #list available screens
    screen -r Flask_D4 #reattach Flask_D4 screen, output of the web server
    screen -r Workers_D4 #reattach Workers', all worker debugging output
    screen -r Server_D4 #reattach Server's, d4 decapsulation output errors
    screen -r Redis_D4 #reattach Redis's, db

**Protip**: most of our screen sessions have tabs (navigate using ctrl+a ")

All logs are located in ./logs

To kill the server use:

    ./LAUCNH.sh -k


<a id="org3959502"></a>

# Appendix : Installing a sensor

There are two clients available for creating a D4 sensor: 

-   the one included in [d4-core](https://github.com/D4-project/d4-core/tree/master/client), written in C,
-   [d4-goclient](https://github.com/D4-project/d4-goclient) that you already used during this tutorial.


<a id="orga42d98c"></a>

## C version

This client has already been successfully tested under linux/amd64 and
openbsd/amd64 systems to stream data from Unix Standard Input. The main
advantage of this implementation is that it is lighweight (~37KB), and only does
D4 encapsulation (so it is easier to audit).

To install the C client, do the following:

    git clone https://github.com/D4-project/d4-core
    cd client/
    git submodule init
    git submodule update
    make d4

The config files work in the same manner as the Go client. The main different is
that the C client does not provide TLS connectivity by itself. 

Therefore in order to ship D4 encapsulated data to a remote server, one needs to
pipe the output of the client into socat or netcat:

    # conf/destination is set to stdout
    sudo passivedns -i eth0 -l /dev/stdout | ./d4 -c ./conf | socat - OPENSSL-CONNECT:$D4-SERVER-IP-ADDRESS:$PORT,verify=0


<a id="org167865b"></a>

## d4-goclient

The Golang client is much heavier but also provides more features out of the box
(eg. tls, retries on disconnect, etc.). The main advantage of this client is its
portability across architectures and operating systems.

To install the Go client, do the following:

    go get github.com/satori/go.uuid
    go get github.com/D4-project/d4-goclient
    make amd64l # for amd64

To compile easily for other arch/os, one can rely on [gox](https://github.com/mitchellh/gox):

    go get github.com/mitchellh/gox
    gox

