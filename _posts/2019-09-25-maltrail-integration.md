---
title: "Building a distributed Maltrail sensor network using D4"
date: 2019-09-25
layout: post
categories:
tags:
image: assets/images/maltrail.png
---

# Table of Contents

1.  [Follow Along](#orgdbf23be)
2.  [Setting up D4 server to receive Maltrail data](#orgc6c5d43)
3.  [Launch the D4 UDP exporter](#org01e368c)
4.  [Launch the maltrail server](#org1abaa31)
5.  [Launching Maltrail / D4 sensor](#org9f1bc98)
6.  [Use it](#orge111cb8)
7.  [Appendix A: Installing a Maltrail / D4 sensor](#org19e355b)
8.  [Appendix B:  Installing and Launching the Maltrail Server](#org16fd70c)


# Introduction

[D4-core](https://github.com/D4-project/d4-core) introduced a new feature
recently: an analyzer to export D4 streams in UDP. This allows to send data out
of a D4 server to other services that expect UDP: one such service is
[Maltrail](https://github.com/stamparm/Maltrail). Using D4 project for building a complete distributed sensor
network using Maltrail is really simple. In this blog post, we will explain
all the steps and provide a VM if you want to test and evaluate the solution before
deploying.

**From Maltrail's README**: Maltrail is a malicious traffic detection system,
utilizing publicly available (black)lists containing malicious and/or generally
suspicious trails, along with static trails compiled from various AV reports and
custom user defined lists.

Maltrail is based on the **Traffic -> Sensor <-> Server <-> Client**
architecture. **Sensor(s)** is a standalone component running on the monitoring
node (e.g. Linux platform connected passively to the SPAN/mirroring port or
transparently inline on a Linux bridge) or at the standalone machine (e.g.
Honeypot) where it "monitors" the passing **Traffic** for blacklisted
items/trails (i.e. domain names, URLs and/or IPs). In case of a positive match,
it sends the event details to the (central) **Server** where they are being
stored inside the appropriate logging directory (i.e. `LOG_DIR` described in the
Configuration section). If **Sensor** is being run on the same machine as
**Server** (default configuration), logs are stored directly into the local
logging directory. Otherwise, they are being sent via UDP messages to the remote
server (i.e. `LOG_SERVER` described in the Configuration section).

![img](/assets/images/maltrail_arch.png "Maltrail Architecture")

As communication between sensors and server are carried out over UDP, one
should not push Maltrail traffic over untrusted networks without proper
tunneling. Fortunately, this is exactly what D4 proposes to do: in this blogpost,
we showcase how one can multiplex Maltrail **Sensor<->Server** communication
into D4, and cross untrusted networks while guaranteeing confidentiality and
authenticity of Maltrail data.


<a id="orgdbf23be"></a>

# Follow Along

You can use [this virtual machine](https://d4-project.org/D4_maltrail.ova) to follow along.

{% highlight shell %}
a9e0535bdc7d195a152840df59a02dfa49a885c0ef09ad46de3d712a5faaaa4d  D4_maltrail.ova
{% endhighlight %}

The functioning of D4 requires the opening of several ports on the VM, here is
the current setup after importing the .ova file into Virtual Box (VB**:

|---|---|---|---|
| Service | Host IP | Host port | Guest port |
|---|---|---|---|
| D4 server - Admin Web Interface | 127.0.0.1 | 7000 | 7000 |
| D4 server - ssh | 127.0.0.1 | 2222 | 22 |
| D4 server - tls d4 | 127.0.0.1 | 4443 | 4443 |
| Maltrail server | 127.0.0.1 | 8338 | 8338 |
|---|---|---|---|


This VM already contains all the needed D4 and Maltrail components, that we will
now configure to set up a full **Maltrail over D4** chain.

For testing purpose (generate HTTP traffic inside the guest VM for maltrail to
do its job), we will use SSH as a SOCKS5 proxy. Fire up the VM and use a
terminal to reach it from the host:

{% highlight shell %}
ssh -D 1337 -E /dev/null d4@127.0.0.1 -p 2222 #d4's account password is 'Password1234'.
{% endhighlight %}

To use this proxy with any web browser, for instance chromium:

{% highlight shell %}
chromium --proxy-server="socks5://127.0.0.1:1337" --proxy-bypass-list="<-loopback>"
{% endhighlight %}

You can use this terminal to interact with the VM, the SOCKS proxy will
stay accessible as long as this SSH connection remains open.

Now that we have a ssh connection opened on the VM, the first step we have to
perform is to retrieve the D4 admin password generated during the installation:

{% highlight shell %}
cat d4-core/server/DEFAULT_PASSWORD
{% endhighlight %}

This will output the credentials needed to connect for the first time on D4 [web
interface](https://127.0.0.1:7000).


<a id="orgc6c5d43"></a>

# Setting up D4 server to receive Maltrail data

Point your (unproxied if you use the VM) web-browser to D4's web interface
([here if you use the VM](http://127.0.0.1:7000)). And move to the "server
management" tab. Add a new 254 type and in the "Type Name" box, enter
"maltrail".

![img](/assets/images/maltrail_type.png "Adding Maltrail Type")

Move to the bottom of the page and create a queue for the maltrail type by
clicking on the type field and entering "254", and by clicking "Type Name" field
and entering "maltrail". Click on the UUID generator button on the left end side
of this box if you don't want to provide one by yourself.

![img](/assets/images/maltrail_queue.png "Adding Maltrail Queue")


<a id="org01e368c"></a>

# Launch the D4 UDP exporter

This UDP exporter will ship Maltrail data out of d4 redis queue towards the
maltrail server.

{% highlight shell %}
screen
. ~/d4-core/server/D4ENV/bin/activate
cd ~/d4-core/server/analyzer/analyzer-d4-export
./d4_export_udp.py -t Maltrail -u uuid-of-your-maltrail-redis-queue -p 8338 -i 127.0.0.1
{% endhighlight %}


<a id="org1abaa31"></a>

# Launch the maltrail server

The Maltrail server will receive aggregated data from D4 and provides a web
interface available at <http://127.0.0.1:8338> to explore the trails (default
credentials: admin:changeme!).

{% highlight shell %}
screen
cd ~/maltrail
python server.py
{% endhighlight %}


<a id="org9f1bc98"></a>

# Launching Maltrail / D4 sensor

{% highlight shell %}
screen
cd ~/maltrail
sudo python sensor.py -q --console 2>&1 | d4-goclient -c ~/conf.maltrail
{% endhighlight %}


<a id="orge111cb8"></a>

# Use it

The easiest way to ensure that the whole pipeline is in working order is to input:

{% highlight shell %}
ping -c 1 136.161.101.53
{% endhighlight %}

and check in Maltrail web interface that you get an event.

For additional fun, you can use the web browser proxied by the VM, browse some
'legit' news website and check out maltrail output ;)

![img](/assets/images/maltrail_web.png "Adding Maltrail Queue")


<a id="org19e355b"></a>

# Appendix A: Installing a Maltrail / D4 sensor

{% highlight shell %}
sudo apt-get install git python-pcapy
git clone https://github.com/stamparm/maltrail.git
{% endhighlight %}

In order to ship Maltrail data with d4, we need to create the proper configuration file in d4 client's config folder:

|---|---|---|
| parameter | description | value |
|---|---|---|
| destination | address and port of the receiving D4 server | 127.0.0.1:4443 |
| source | where to look for input data | stdin |
| snaplen | D4 packet size | 4096 |
| type | type of D4 packets sent, this is used by d4-server to know how to handle the data received | 2 |
| uuid | sensor's unique identifier | automatically provisioned |
| key | a Pre-Shared Key used to authenticate the sensor to the server | "private key to change" |
| version | D4 protocol version | 1 |
|---|---|---|

As we chose **type 2**, we also need a meta-header.json file to describe the data we send:

{% highlight json %}
{ "type": "maltrail" }
{% endhighlight %}


<a id="org16fd70c"></a>

# Appendix B:  Installing and Launching the Maltrail Server

From your home folder:

{% highlight shell %}
[[ -d maltrail ]] || git clone https://github.com/stamparm/maltrail.git
cd maltrail
python server.py
{% endhighlight %}
