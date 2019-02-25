---
layout: page
title: software
---

The D4 project is composed of various open source software to run a complete sensor network including analysing traffic to discover DDoS activities, malicious activities or even collect Passive DNS records.

![D4 overview](https://raw.githubusercontent.com/D4-project/architecture/master/docs/diagram/d4-overview.png)

# D4 core software

The D4 core software are the open source software components designed to run a D4 sensor or running a complete sensor network including server, sensors and components.

## Server

- version 0.2 - [D4 server](https://github.com/D4-project/d4-core) is an implementation D4 server written in Python 3.6 which can handle D4 clients (sensors), manage the sensors registration and dispatch to the analyzers.

## d4 client

- version 0.2 - [D4 client](https://github.com/D4-project/d4-core#d4-core-client) is a simple and minimal C implementation of the D4 encapsulation protocol.

## d4 goclient

- version 0.1 - [d4-goclient](https://github.com/D4-project/d4-goclient) is a D4 project client (sensor) implementing the D4 encapsulation protocol. The client can be used on different targets and architectures to collect network capture, logs, specific network monitoring and send it back to a D4 server.

# D4 add-on software

D4 is composed of different building blocks which can be used depending of your need and requirements.

## analyzer-d4-passivedns

analyzer-d4-passivedns is an analyzer for a D4 network sensor. The analyser can process data produced by D4 sensors (in [passivedns](https://github.com/gamelinux/passivedns) CSV format (more to come)) and ingest them into a Passive DNS server which can be queried later to search for the Passive DNS records.

- version 0.0 - [analyzer-d4-passivedns](https://github.com/D4-project/analyzer-d4-passivedns)

The analyzer includes a compliant Passive DNS ReST server compliant to [Common Output Format](https://tools.ietf.org/html/draft-dulaunoy-dnsop-passive-dns-cof-04).

## sensor-d4-tls-fingerprinting

Extract TLS certificates from pcap files or network interfaces, fingerprint TLS client/server interactions with ja3/ja3s

- version 0.0 - [sensor-d4-tls-fingerprinting](https://github.com/D4-project/sensor-d4-tls-fingerprinting)

## analyzer-d4-pibs

analyzer-d4-pibs is a Passive Identification of BackScatter analyzer for the D4 sensor network capturing raw packet in pcap.

- version 0.0 - [analyzer-d4-pibs](https://github.com/D4-project/analyzer-d4-pibs)
