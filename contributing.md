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
| 2 - ja3-jl | https://github.com/D4-project/sensor-d4-tls-fingerprinting json output | 
| 2 - suricata-eve | suricata eve json output | 
| 3 | generic log lines, in particular  ssh authentication logs | 
| 4 | dnscap output | 
| 8 | passivedns CSV stream |

TODO: discuss

# D4 sensor generator

TODO: describe

The easiest way to configure and register a sensors on the D4-project's instance is to
use the sensors generator located here: https://sensor.d4-project.org/

![image](/assets/images/ass1.png)
![image](/assets/images/ass2.png)
![image](/assets/images/ass3.png)
![image](/assets/images/ass4.png)
![image](/assets/images/ass5.png)
![image](/assets/images/ass6.png)
![image](/assets/images/archive.png)

# approval and D4-MISP access

TODO: define the process - onboarding should definitely be improved

- Once the sensor is generated, the uuid is registered on the server, but is
still needs to be manually approved:

- send an email to info@circl.lu with your uuid and a PGP key
- we agree on a PSK
- we can attribute additional uuids in bulk, 
- we set up a MISP account on D4-MISP
- we set up pdns / pssl account

TODO: describe

# What is available on D4-MISP

- ssh

# What other analysis is done on the data

- 


 



