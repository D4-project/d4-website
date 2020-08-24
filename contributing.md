---
layout: page
title: Contributing
---

# Joining D4 communities

D4 servers can be operated by communities of security researchers and
practitioners to collect and analyze data at a bigger scale that one could
operate on its own. CIRCL operates several D4 servers among which one
(crq.circl.lu) is open to anyone interested in sharing data publicly under the
realm of D4-project.  D4-project intends to share publicly the results of the
analyses performed on the submitted data through a MISP instance.

# What kind of data

crq.circl.lu accepts the following data types:

| type | description |
|-------|--------|
| 1 | pcap (libpcap 2.4) | 
| 2 - ja3-jl | [sensor-d4-tls-fingerprinting](https://github.com/D4-project/sensor-d4-tls-fingerprinting) json output | 
| 2 - suricata-eve | suricata eve json output | 
| 3 | generic log lines, in particular  ssh authentication logs | 
| 4 | dnscap output | 
| 8 | passivedns CSV stream |

<br>

# D4 sensor generator

crq.circl.lu hosts a
[d4-sensor-generator](https://github.com/D4-project/d4-sensor-generator)
instance at the following location:
[https://sensor.d4-project.org/](https://sensor.d4-project.org/). The sensor
generator eases user on-boarding by automating the sensor configuration and
part of its registration on crq. Adding a sensor to crq using the generator is
a 7-step process:

- Go to [https://sensor.d4-project.org/](https://sensor.d4-project.org/):

![Assistant entry point](/assets/images/ass1.png)

- Specify whehter you prefer configuring a C or a Golang Client: 

![Client language selection](/assets/images/ass2.png)

- Specify for which OS and architecture you want this client:

![Client architecture](/assets/images/ass3.png)

- Select which type of data this client should send:

![Type selection](/assets/images/ass4.png)

- Select what is the destination server:

![Specify destination server](/assets/images/ass5.png)

- Optionally give contact information:

![Contact email form](/assets/images/ass6.png)

- Download the resulting archive:

![Download archive](/assets/images/ass7.png)

The archive contains the client compiled for the os/architecture (as well as the source code), and a `configs` folder containing the preconfigured settings for your sensor.

![Archive content](/assets/images/archive.png)

# approval and D4-MISP access

Once the sensor is generated, its uuid is registered on the server but it still
needs to be manually approved for the server to accept the data sent.  In order
to be able to send data, you need to send an email to info@circl.lu containing:
the sensor uuid (located in configs/uuid) and your PGP public key.  Following
this:

- we will approve the sensor and send you back a passphrase for this sensor,
- we set up a MISP account on D4-MISP for you to have access to the analysis results,
- we set up pdns / pssl API access for your to use.
