---
title: "Use-Case: Sharing Publicly"
date: 2019-06-17
layout: post
categories: 
tags: 
---

# Table of Contents

1.  [Architecture Overview](#org49d213c)
2.  [Network Collection](#org320be59)
3.  [Preparing the private D4 server](#org0e4d1b2)
4.  [Analysis](#orgf1603da)
    1.  [analyzer-d4-stdout](#org92e8e8c)
    2.  [tcprewrite](#orgf62b20f)
    3.  [d4-client](#orgf54e5d8)
5.  [DDoS Analysis Public server](#orgcf8b6ef)

[D4-core](https://github.com/D4-project/d4-core) introduced a new feature recently: a default analyzer to write directly
to standard output. This allows the piping of D4 output streams into any other
UNIX tools, opening the door to more data analyses and data sharing!

We apply this data flow and processing to network captures, but it applies to
other type of data supported by D4 (eg. passiveDNS, passiveSSL, etc.)


<a id="org49d213c"></a>

# Architecture Overview

In the following, we demonstrate data mixing and sanitization of several network
sensors on a D4 server, as well as the forwarding of the result to another D4
server. The typical use-case is the hosting of a D4 server in-premises that
strips out the collected data of personal information before sharing with a
public DDoS backscatter-traffic analyzer. See the picture below, the green area
represents the private perimeter, and the red area the public one.

![img](/assets/images/mixing.png "Network capture sharing use-case")

The area of interest are the following (red circles on the picture above):

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-right" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-right">#</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-right">1</td>
<td class="org-left">network captures: tcpdump pipes its standard output to d4-goclient for streaming to a private D4 server,</td>
</tr>


<tr>
<td class="org-right">2</td>
<td class="org-left">data mixing and sanitizing: the private D4 server receives network capture streams and stores these in pcap files in rotation. These files, after compression are marked as ready for analysis in a redis queue (The analysis is detailed below),</td>
</tr>


<tr>
<td class="org-right">3</td>
<td class="org-left">result of the analysis (the sanitization) is forwarded to the public D4 server,</td>
</tr>


<tr>
<td class="org-right">4</td>
<td class="org-left">the public D4 server mixes data from several sensors / servers and analyze the data for DDoS backscatter traffic.</td>
</tr>
</tbody>
</table>

**Follow along**: You can use the updated version of the [passidns tutorial](http://localhost:4000/2019/05/28/tuto-pdns.html)'s [virtal machine](https://www.circl.lu/assets/files/D4_DEMO-1.ova) (sha256):


<a id="org320be59"></a>

# Network Collection

Let first dig into the network collection: we use `tcpdump` to collect packets,
and the default [Clang client](https://github.com/D4-project/d4-core/tree/master/client) or the [Golang client](https://github.com/D4-project/d4-goclient) to forward packets to the
public D4 server ([HOWTO install](https://d4-project.org/2019/05/28/passive-dns-tutorial.html#org3959502)).

-   We use `tcpdump` with the following parameters:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">parameter</th>
<th scope="col" class="org-left">Description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">-n</td>
<td class="org-left">no DNS resolution</td>
</tr>


<tr>
<td class="org-left">-s0</td>
<td class="org-left">set snaplen to default 262144 for compatiblity</td>
</tr>


<tr>
<td class="org-left">-w -</td>
<td class="org-left">write to stdout</td>
</tr>
</tbody>
</table>

-   Clang client:

The Clang client requires to have a relay, here we use `socat`:

    $ sudo tcpdump -n -s0 -w - | ./d4 -c ./conf | socat - OPENSSL-CONNECT:$D4-SERVER-IP-ADDRESS:$PORT,verify=0

Use the command above and in the ./conf folder create the following files:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">parameter</th>
<th scope="col" class="org-left">description</th>
<th scope="col" class="org-left">value</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">destination</td>
<td class="org-left">address and port of the receiving D4 server</td>
<td class="org-left">stdout</td>
</tr>


<tr>
<td class="org-left">source</td>
<td class="org-left">where to look for input data</td>
<td class="org-left">stdin</td>
</tr>


<tr>
<td class="org-left">snaplen</td>
<td class="org-left">D4 packet size</td>
<td class="org-left">4096</td>
</tr>


<tr>
<td class="org-left">type</td>
<td class="org-left">type of D4 packets sent, this is used by d4-server to know how to handle the data received</td>
<td class="org-left">1</td>
</tr>


<tr>
<td class="org-left">uuid</td>
<td class="org-left">sensor's unique identifier</td>
<td class="org-left">automatically provisioned</td>
</tr>


<tr>
<td class="org-left">key</td>
<td class="org-left">a Pre-Shared Key used to authenticate the sensor to the server</td>
<td class="org-left">"private key to change"</td>
</tr>


<tr>
<td class="org-left">version</td>
<td class="org-left">D4 protocol version</td>
<td class="org-left">1</td>
</tr>
</tbody>
</table>

-   Golang client:

    $ sudo tcpdump -n -s0 -w - | ./d4-goclient -c ./conf

With the Clang client, use the command above and in the ./conf folder create the following files:

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


<a id="org0e4d1b2"></a>

# Preparing the private D4 server

In order to have a analyzer for network caputes, the public D4 server needs to
have a redis queue for `type 1` data. Once the server is launched, point your browser to
<http://127.0.0.1:7000/server_management> and create a new queue as follows:

![img](/assets/images/create-new-analyzer.png "Create a new analyzer queue")

To obtain a new redis queue for your analyzer to consume:

![img](/assets/images/analyzer-queue-new-queue.png "Newly created queue")

**protip**: When clicking on the number of item in the queue (in the following
screenshot 10001 elements), the webapp display a preview of the elements in the
queue:

![img](/assets/images/analyzer-queue-click.png "Click for analyzer queue's details")

![img](/assets/images/analyzer-queue-detail.png "Detail")


<a id="orgf1603da"></a>

# Analysis

Let's build the analyzer command from the ground up, keep in mind that:

-   it queries the analyzer redis queue (filled with path to files ready for analysis),
-   unpacks these files,
-   rewrites the content of each file to remove sensitive content,
-   forwards the result the public D4 server.


<a id="org92e8e8c"></a>

## analyzer-d4-stdout

Analyzer-d4-stdout is part of [d4-core](https://github.com/D4-project/d4-core) and allows for popping an analyzer redis
queue and outputting its content on standard output. Used with the `- f` flag,
it behaves differently: it streams the content of files pointed out by the redis
queue.

    $ ./d4-stdout.py -t 1 -u 84723644-0841-4580-97e9-23e98682739c  -f 

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">parameter</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">-t</td>
<td class="org-left">d4 type of data: type 1, pcap</td>
</tr>


<tr>
<td class="org-left">-u</td>
<td class="org-left">uuid of the analyzer redis queue we created: 84723644-0841-4580-97e9-23e98682739c</td>
</tr>


<tr>
<td class="org-left">-f</td>
<td class="org-left">Fetch files instead of reading raw content of the queue</td>
</tr>
</tbody>
</table>

Then we pipe the result in zcat, for to remove compression:

    $ ./d4-stdout.py -t 1 -u 84723644-0841-4580-97e9-23e98682739c  -f | zcat

We are now ready to remove sensitive information from these files.


<a id="orgf62b20f"></a>

## tcprewrite

`tcprewrite` is part of `tcpreplay`, and is a tool to rewrite packets stored in pcap files.
In the following we replace private IP addresses with phony ones:

    $ ./d4-stdout.py -t 1 -u 84723644-0841-4580-97e9-23e98682739c -f | zcat | tcprewrite --pnat=10.1.0.0/16:192.168.0.0/16 -i - -o -

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="org-left">parameter</th>
<th scope="col" class="org-left">description</th>
</tr>
</thead>

<tbody>
<tr>
<td class="org-left">&#x2013;pnat=10.1.0.0/16:192.168.0.0/16</td>
<td class="org-left">Replace 10.1 by 192.168</td>
</tr>


<tr>
<td class="org-left">-i -</td>
<td class="org-left">read from stdin</td>
</tr>


<tr>
<td class="org-left">-o -</td>
<td class="org-left">write to stdout</td>
</tr>
</tbody>
</table>


<a id="orgf54e5d8"></a>

## d4-client

The data is now ready to ship towards the public server! We can now use our
favorite client for D4 transmission. For instance:

    $ ./d4-stdout.py -t 1 -u 84723644-0841-4580-97e9-23e98682739c -f | zcat | tcprewrite --pnat=10.1.0.0/16:192.168.0.0/16 -i - -o - | d4-goclient -c ~/go/src/github.com/d4-goclient/conf.sample 


<a id="orgcf8b6ef"></a>

# DDoS Analysis Public server

We don't cover the deployment of the public server in this article but [CIRCL](http://circl.lu) is
in the process of building such a server. Please get in touch with us if you
want to want to beta test the platform.

