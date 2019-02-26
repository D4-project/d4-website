---
layout: post
title:  "D4 core version 0.2 has been released"
author: CIRCL
categories: [ d4, sensor network, d4 project, core software ]
image: assets/images/d4-sensors.jpg
---

# New version released - v0.2 of D4 core

After the initial design and implementation of the [D4 protocol](https://github.com/D4-project/architecture/tree/master/format), we released
a new version of the [D4 core server software](https://github.com/D4-project/d4-core) which includes the following changes:

- Support for IPv6 has been added;
- Compression with gzip has been added to the type (1:pcap) analyzer;
- New worker type (8:dnscap). It pushes dnscap lines in a redis queue towards the appropriate analyzer for further processing (e.g. used in the [Passive DNS analyzer](https://github.com/D4-project/analyzer-d4-passivedns));
- Manage black-lists from the sensor management interface per CIDR block;
- Custom filter per sensor is now supported;
- Many improvements in the sensor management and monitoring.

# New release - v0.1 of D4-goclient 

<p align="center">
  <img alt="d4-goclient" src="https://raw.githubusercontent.com/D4-project/d4-goclient/master/media/gopherd4.png" width="140" />
  <p align="center">
    <a href="https://github.com/D4-project/d4-goclient/releases/latest"><img alt="Release" src="https://img.shields.io/github/release/D4-project/d4-goclient/all.svg"></a>
    <a href="https://github.com/D4-project/d4-goclient/blob/master/LICENSE"><img alt="Software License" src="https://img.shields.io/badge/License-MIT-yellow.svg"></a>
    <a href="https://goreportcard.com/report/github.com/D4-Project/d4-goclient"><img alt="Go Report Card" src="https://goreportcard.com/badge/github.com/D4-Project/d4-goclient"></a>
  </p>
</p>

We release a first version of the cross-platform Go client. It has the following features:

 - Encapsulates whatever it is given in input with D4 protocol;
 - Retries on connection lost;
 - Can connect directly to a D4-server to avoid using socat for transport;
 - Can verify D4-server's certificate against a user-provided CA certificate.

# FIC 2019 -  Forum International de la Cybersécurité in Lille (22-23 January 2019)

During the FIC 2019, D4 project was present to show the goal of the project but also the existing sensor network software.

# D4 workshop at SUNET (Sweden)

A first D4 workshop (7th February 2019) has been done at SUNET (thanks to them for hosting us). The [presentation is available online](https://github.com/D4-project/architecture/raw/master/docs/workshop/0-introduction/d4-introduction.pdf) which covers the basics behind the D4 project. Useful feedback was gathered during the workshop and especially some insightful discussions on the additional techniques of monitoring of DDoS.


