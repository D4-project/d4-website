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
- New analyzer to automatically compress file of type (1) added;
- New worker type (8) to queue in redis to dispatch towards the appropriate analyzer for further processing (e.g. used in the [Passive DNS analyzer](https://github.com/D4-project/analyzer-d4-passivedns));
- Manage black-lists from the sensor management interface per CIDR block;
- Custom filter per sensor is now supported;
- Many improvements in the sensor management and monitoring;

# FIC 2019 -  Forum International de la Cybersécurité in Lille (22-23 January 2019)

During the FIC 2019, D4 project was present to show the goal of the project but also the existing sensor network software.

# D4 workshop at SUNET (Sweden)

A first D4 workshop (7th February 2019) has been done at SUNET (thanks to them for hosting us). The [presentation is available online](https://github.com/D4-project/architecture/raw/master/docs/workshop/0-introduction/d4-introduction.pdf) which covers the basics behind the D4 project. Useful feedback was gathered during the workshop and especially some insightful discussions on the additional techniques of monitoring of DDoS.


