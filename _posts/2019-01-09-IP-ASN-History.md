---
layout: post
title:  "IP ASN History"
author: CIRCL
categories: [ open source, asn, history ]
image: assets/images/bgpranking.png
---

In the D4 project, a major activity is network packet collection from black hole monitoring. But a major challenge in the analysis is the ability to find back
the owner of an IP block in a specific time-frame. To support us (and the community), we developed a service and an open source software called [IP ASN History](https://github.com/D4-project/IPASN-History) to find the ASN announcing a IP network in a specific time range.

~~~~
curl "https://bgpranking-ng.circl.lu/ipasn_history/?ip=8.8.8.8&date="2019-01-01""
~~~~

~~~~
{
  "meta": {
    "address_family": "v4",
    "ip": "8.8.8.8",
    "source": "caida"
  },
  "response": {
    "2019-01-01T12:00:00": {
      "asn": "15169",
      "prefix": "8.8.8.0/24"
    }
  }
}
~~~~
