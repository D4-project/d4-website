---
layout: post
title:  "D4 software stack - new version released"
author: CIRCL
categories: [ d4, sensor network, d4 project, core software ]
image: assets/images/d4-sensors.jpg
---

Following the Programming Methodology Framework aka
[PMF](https://tools.ietf.org/id/draft-dulaunoy-programming-methodology-framework-00.html),
we choose to release D4 software component early. All interested parties are
invited to install and use those piece of software, and to report bugs for
further improvements.

# New Versions

## D4-core version bumped 

 [D4-core](https://github.com/D4-project/d4-core/releases/tag/v0.3) server and
 client are bumped to version 0.3 and
 [D4-goclient](https://github.com/D4-project/d4-goclient/releases/tag/v0.2) to
 version 0.2.
 
* [D4-core server](https://github.com/D4-project/d4-core/tree/master/server):
  * new kick functionality to remove sensor per UUID
  * extended types is now supported by the D4 server
  * many bugs fixed (following intensive existing new sensor such as Passive DNS and Passive SSL)
  * statistics per sensor added to the UI
  * various improvements including save JSON to disk and others depending of the type

* [D4-core client](https://github.com/D4-project/d4-core/tree/master/client):
  * improvement to compile on older version of Linux + OpenBSD

* [D4-goclient](https://github.com/D4-project/d4-goclient):
  * support for extended types (type 254)
  * DNS resolution
  * multiple bugs were fixed
  
## [IPASN-History 1.0](https://github.com/D4-project/IPASN-History/releases/tag/1.0)

* support for BGP dumps
* load [RIPE dumps](https://www.ripe.net/analyse/internet-measurements/routing-information-service-ris/ris-raw-data) announces in addition to [CAIDA](http://data.caida.org/datasets/routing/)

## [BGP Ranking 1.0](https://github.com/D4-project/BGP-Ranking/releases/tag/1.0)

* Complete port of BGP Ranking to python 3.6
* ARDB back end

# New Software

## [sensor-d4-tls-fingerprinting 0.1](https://github.com/D4-project/sensor-d4-tls-fingerprinting/releases) 

* extracts TLS certificates from pcap files or network interfaces
* fingerprints TLS client/server interactions with ja3/ja3s
* fingerprints TLS interactions with TLSH fuzzy hashing
* write certificates in a folder
* export in JSON to files, or stdout

## [analyzer-d4-passivessl](https://github.com/D4-project/analyzer-d4-passivessl/releases/tag/0.1)

* create a Postgresql database that stores data about TLS sessions, certificates (and chains of certificates), public keys, and related fuzzyhashes provided by sensor-d4-tls-fingerprinting
* provide Postgres function to query sessions by TLSH fuzzy hash / threshold
* fetch TLS sessions from a d4-core server redis queue
* fetch TLS sessions from a folder containing their json descriptions

