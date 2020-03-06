---
title: "Analyzing TCP port scan"
date: "2020-03-06"
layout: "post"
author: alexis
image: assets/images/earth.jpg
---

A few years ago, the
[Mirai](https://en.wikipedia.org/wiki/Mirai_(malware))
botnet was talked about because it caused a few major
[DDoS](https://en.wikipedia.org/wiki/Denial-of-service_attack#Distributed_attack)
attacks around August 2016. The author later released the source code
on [hackforums](https://hackforums.net/showthread.php?tid=5420472)
under the name **Anna-senpai**. The source code of it is now available on
[GitHub](https://github.com/jgamblin/Mirai-Source-Code).

Mirai botnet included a few innovative ideas that allowed it to spread
blazing fast. One of them was to use a stateless port scanner.
Stateless means that no state is kept during a port scan, and so, no memory
needs to be used. This allows even low-spec hardware with few available
memory (such as IoT devices) to scan a large number of IPs.

# TCP Handshake

If you are unfamiliar with the TCP handshake, I recommend you reading the following
[Wikipedia](https://en.wikipedia.org/wiki/Transmission_Control_Protocol#Connection_establishment)
article about it. Here's a small reminder:

{% include image.html
	url="/assets/images/tcp-handshake.png"
	alt="TCP Handshake"
	caption='TCP handshake from <a href="https://www.johnpfernandes.com/2018/12/08/the-tcp-3-way-handshake/">johnpfernandes.com</a>'
%}

From the [TCP RFC 793](https://tools.ietf.org/html/rfc793#page-27):
```
1) A --> B  SYN my sequence number is X
2) A <-- B  ACK your sequence number is X
3) A <-- B  SYN my sequence number is Y
4) A --> B  ACK your sequence number is Y
```

Because steps `2)` and `3)` are sent in a single packet, we call it a
3-way handshake. The sequence number sent from A to B is called the
Initial Sequence Number 1 or ISN1. The sequence number sent from B to A
is called the ISN2.

According to the [TCP RFC](https://tools.ietf.org/html/rfc793#page-27),
when a client initiates a connection to a server, it should use an ISN
generator *which selects a new 32 bit ISN*. The generated number, then
needs to be saved on the client-side, waiting for the SYN+ACK from the
server. The
[Mirai ISN generator](https://github.com/jgamblin/Mirai-Source-Code/blob/3273043e1ef9c0bb41bd9fcdc5317f7b797a2a94/mirai/bot/scanner.c#L225)
is very simple:

{% include image.html
	url="/assets/images/mirai-isn.png"
	alt="Mirai ISN generator"
	caption="Mirai ISN generator"
%}

The ISN is simply set to the destination IP. This way, the scanner does
not have to save the ISN into memory and
[checks](https://github.com/jgamblin/Mirai-Source-Code/blob/3273043e1ef9c0bb41bd9fcdc5317f7b797a2a94/mirai/bot/scanner.c#L270)
the SYN+ASK this way:

{% include image.html
	url="/assets/images/mirai-check.png"
	alt="Mirai Sequence number check"
	caption="Mirai Sequence number check"
%}

When a Mirai scanner receives a valid TCP SYN+ACK, it opens a socket
using the built-in TCP API, so the ISN is managed by the operating system.
This way, the connections kept in memory are only connections to open
ports, and memory is not wasted with half-open TCP connections.


# Identification
The `tcp->seq = ip->dst_addr` is easily identifiable (either by the
human eye, either by a computer) because
all packets going to the same IP (even from different IPs) have all the
same ISN. This can be seen looking at the ISN1 numbers or the
[graphics](https://twitter.com/adulau/status/1199971233154174976).
Thanks to this pattern, we identified such scans on ports unused by the initial
[Mirai scanner](https://github.com/jgamblin/Mirai-Source-Code/blob/3273043e1ef9c0bb41bd9fcdc5317f7b797a2a94/mirai/bot/scanner.c#L217).
Indeed, the initial Mirai scanner was only looking at port `23` (9 out of
10 times) and port `2323` (1 out of 10 times):

{% include image.html
	url="/assets/images/mirai-port.png"
	alt="Mirai TCP Port selection"
	caption="Mirai TCP Port selection"
%}

An easy fix to get the scanner less identifiable is to XOR the
destination IP with source IP. This pattern is still trivial to check
with code, but would be less identifiable by the human eye because the
ISN number would change more often.

# Statistics
At D4, we have some packet captures coming from a black hole. A black
hole is a monitoring network that has never been announced. As such, it
should never receive traffic, except for Internet scans, mistaken
systems and spoofed requests' backscatter. By curiosity, we were
wondering how the Mirai scanner trick is used and which ports are
most targeted. We made a few statistics with data collected from
**2020-01-16** to **2020-02-26** for a total of **42** days. Here are
the most interesting ones:


## Port 37215

The winner is port 37215 with 96.35% of Mirai-like scan:
{% include image.html
	url="/assets/images/isn/37215.png"
	alt="Port 37215 Graphic"
	caption="Port 37215 - 96.35%"
%}

Scan of port 37215 mainly targets
[CVE-2017-17215](https://cve.circl.lu/cve/CVE-2017-17215)
affecting the router Huawei HG532 with unpatched firmware, making it
possible for a remote user to execute arbitrary shell commands. The
official security notice is available
[here](https://www.huawei.com/en/psirt/security-notices/huawei-sn-20171130-01-hg532-en).
Further analysis is available
[here](https://medium.com/@knownsec404team/huawei-hg532-series-router-remote-command-execution-analyzation-a531d96d5339).


## Port 9530

Second place is given to port 9530 with a very interesting pattern. This
port started to be actively scanned on **2020-02-11**:

{% include image.html
	url="/assets/images/isn/9530.png"
	alt="Port 9530 Graphic"
	caption="Port 37215 - 95.97%"
%}

This is in sync with
[ICS data](https://isc.sans.edu/port.html?port=9530):

{% include image.html
	url="/assets/images/sans-isc-port-9530.png"
	alt="ISC Scanning data of port 9530"
	caption="ISC Scanning data of port 9530"
%}

This scan happened a few days after the
[full disclosure](https://habr.com/en/post/486856/)
of a 0-day vulnerability affecting Xiongmai *security* camera from
Vladislav Yarmak on 4 February 2020. This vulnerability allows an attacker
to open a Telnet daemon on port 9527. Connecting with default
credentials, an attacker can execute shell commands as root. The
official security notice is available
[here](http://www.xiongmaitech.com/en/index.php/news/info/12/68).

PS: according to an
[article](https://www.osm-s.com/en/2017/11/30/ip-camera-security-horror/)
from OSM Solutions, this backdoor is a feature (not a bug).


## HTTP ports 8[0-8]+
HTTP port **80**, along with its most common alternatives **81**, **82**,
**83**, **85**, **88**, **8000**, **8001**, **8080**, **8081** are the
ones widely used for device administration. If the device's owner did not
change the administration password, there is a chance the valid password
will be hardcoded and weak. Even if the password is complex, there is a
chance the HTTP server is old and is subject to a public vulnerability,
as we will see it [later](#port-4567).
The Mirai-like scanner developed a massive interest in those in
January. In February, a few ports are forsaken: **82**, **83**, **85**
and **8081**. We can guess the success rate was not high enough:

{% include gallery.html
	gallery="http-ports"
	images=site.data.http-ports
%}


## Port 4567
This port is used by the protocol Technical Report 069 or TR-069.
Interesting information can be found on
[Wikipedia](https://en.wikipedia.org/wiki/TR-069)
and in the
[specification](https://www.broadband-forum.org/technical/download/TR-069_Amendment-6.pdf)
from the
[Broadband Forum](https://en.wikipedia.org/wiki/Broadband_Forum)
(updated in 2018). This protocol is used for routers remote
administration and firmware upgrades.

{% include image.html
	url="/assets/images/isn/4567.png"
	alt="Port 4567 Graphic"
	caption="Port 4567 - 82.16%"
%}

According to [ISC](https://isc.sans.edu/port.html?port=4567),
it is used by Verizon and other ISPs having Actiontec
routers. We can find really old complaints about that back to
[2007 for Verizon](https://www.dslreports.com/forum/r19531564-Port-4567-The-Evil-Port),
[2010 for BT](https://community.bt.com/t5/Archive-Staging/port-4567-backdoor/td-p/59703),
[2014 for Century Link](https://superuser.com/questions/832571/port-4567-open-on-router-to-tram-traffic-should-i-worry)
or more recently in
[2019 for Plusnet](https://community.plus.net/t5/My-Router/Ports-4567-and-6161-on-Plusnet-Hub-One-open/td-p/1688887).
As we can see, this feature looks quite standard and is widely used. What
about security? Here's an overview:

{% include image.html
	url="/assets/images/tr-069-security.png"
	alt="TR-069 Security"
	caption="TR-069 Security"
%}

The protocol makes use of a shared secret between the Customer Premise
Equipment (CPE) and the Auto-Configuration Server (ACS) but gives no
hint about the exchange of the secret. Because it is not standard, not
all ISPs will have the same way of exchanging the secret. We can
assume some may take the easy way out and use a common default password
for all devices.

Even when secure and unique passwords are used, some devices make use of
outdated web servers allowing authentication bypass. As an example, an
[analysis](https://web.archive.org/web/20190508230250/https://www.rsaconference.com/writable/presentations/file_upload/hta-r04-the-internet-of-tr-069-things-one-exploit-to-rule-them-all_final_copy1.pdf)
from Shahar Tal and Lior Oppenheim in 2015 revealed that more than 13 million
devices were using RomPager 4.07 (released in 2002). An
[exploit](https://www.exploit-db.com/exploits/39739)
is now publicly available since 2016.


## Telnet ports 23(23)?
Unsurprisingly, since it was the original Mirai target ports, Telnet
ports **23** and **2323** have a very high Mirai-like rate:

{% include gallery.html
	gallery="telnet-ports"
	images=site.data.telnet-ports
%}

## Port 5555
This port is used by the
[Android Debug Bridge (ADB)](https://developer.android.com/studio/command-line/adb)
daemon on Android devices. As its name suggests, it is used for
debugging purposes. Stock Android does not allow debugging by default.
The user has to enable USB debugging first in the hidden developer menu
and then run `tcpip` command over USB to
[enable network debugging](https://developer.android.com/studio/command-line/adb#wireless)
. Moreover, Android 4.2.2,
[released in February 2013](https://developer.android.com/studio/releases/platforms#revision-2-february-2013),
added a security layer: the user has to unlock the device and accept the
USB connection. It is hardly possible that a large number of users ran
through all those steps to generate that interest:

{% include image.html
	url="/assets/images/isn/5555.png"
	alt="Port 5555 Graphic"
	caption="Port 5555 - 72.81%"
%}

According to 
[an article](https://blog.netlab.360.com/early-warning-adb-miner-a-mining-botnet-utilizing-android-adb-is-now-rapidly-spreading-en/)
from Hui Wang on Netlab and
[an analysis](https://doublepulsar.com/root-bridge-how-thousands-of-internet-connected-android-devices-now-have-no-security-and-are-b46a68cb0f20)
from Kevin Beaumont on DoublePulsar in February 2018, some manufacturers
shipped Android devices with the network ADB bridge enabled and
unauthenticated. Most devices are phones and TVs. Massive scans
targeting this port started back in February 2018. At that time, the
malware was using
infected devices to mine cryptocurrencies. I doubt that a TV or a
smartphone is very efficient for this job, but maybe this was profitable
on a large scale. We can also find other analyses
[from TrendMicro](https://blog.trendmicro.com/trendlabs-security-intelligence/open-adb-ports-being-exploited-to-spread-possible-satori-variant-in-android-devices/)
and
[from ISC](https://isc.sans.edu/diary/Worm+%28Mirai%3F%29+Exploiting+Android+Debug+Bridge+%28Port+5555tcp%29/23856)
proving that the botnet was still active in July 2018.

## Port 26
Port **26** is also interesting because we can see a huge increase
in traffic from **2020-02-18**. Mirai-like scan accounts for 47.43% of
scans on this port.

{% include image.html
	url="/assets/images/isn/26.png"
	alt="Port 26 Graphic"
	caption="Port 26 - 47.43%"
%}

An analysis has already been done by the
[Internet Storm Center](https://isc.sans.edu/forums/diary/Next+up+whats+up+with+TCP+port+26/25564/)
and it seems like the scanner is trying to connect to a Telnet-like
terminal. This may be explained by some network devices exposing a
Telnet on this port.


---


# Future work

{% include inline-image.html
	url="/assets/images/aim.png"
	alt="Target"
%}

During the next few weeks, we have planned to set up a few honeypots to
emulate vulnerable devices and carry out interesting attacks. We hope to
get more information about the current botnet ecosystem to confirm or
invalidate our thoughts.

# Any idea?

{% include inline-image.html
	url="/assets/images/idea.png"
	alt="Idea"
%}

For non-described ports, we are still unsure about what kind of hardware
the attacker is trying to detect. If you have any idea about that, feel
free to contact us at [d4@circl.lu](mailto:d4@circl.lu).

# Data

Here are the ports receiving the more Mirai-like scans:

IP==DST_IP is Mirai-like scans for this port / all scans for this port * 100

| Port | ISN==DST_IP |
|---|---|
| [37215](#port-37215) | 96.35% |
| [9530](#port-9530) | 95.97% |
| [8080](#http-ports-80-8) | 82.57% |
| [4567](#port-4567) | 82.16% |
| [2323](#telnet-ports-2323) | 79.64% |
| [23](#telnet-ports-2323) | 78.29% |
| [5555](#port-5555) | 72.81% |
| [88](#http-ports-80-8) | 66.07% |
| [85](#http-ports-80-8) | 53.74% |
| [8000](#http-ports-80-8) | 50.62% |
| 34567 | 50.25% |
| [26](#port-26) | 47.43% |
| [83](#http-ports-80-8) | 45.92% |
| [2223](#telnet-ports-2323) | 38.67% |
| 60001 | 36.75% |
| 52869 | 35.21% |
| [82](#http-ports-80-8) | 34.68% |
| [80](#http-ports-80-8) | 27.70% |
| 9090 | 23.20% |
| [81](#http-ports-80-8) | 20.73% |
| 9001 | 19.48% |
| 5500 | 19.19% |
| [8081](#http-ports-80-8) | 19.17% |
| 9527 | 15.98% |
| 1588 | 13.29% |
| 9000 | 12.52% |
| 9731 | 11.75% |
| 2480 | 6.27% |
| 340 | 4.73% |
| 1024 | 4.63% |
| 49451 | 4.09% |
| 5984 | 4.05% |
| [8001](#http-ports-80-8) | 4.03% |

<br>

# Graphics
Here are the graphics of those aforementioned ports:

{% include gallery.html
	gallery="graphics"
	images=site.data.analyzer-d4-isn-graphics
%}

Image from [Unsplash](https://unsplash.com/),
icons from [FlatIcon](https://www.flaticon.com/).

