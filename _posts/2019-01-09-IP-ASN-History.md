---
layout: post
title:  "IP ASN History"
author: CIRCL
categories: [ open source, asn, history ]
image: assets/images/bgpranking.png
---

In the D4 project, a major activity is network packet collection from black hole monitoring. But a major challenge in the analysis is the ability to find back
the owner of an IP block in a specific time-frame. To support us (and the community), we developed a service and an open source software called [IP ASN History](https://github.com/D4-project/IPASN-History) to find the ASN announcing a IP network in a specific time range.

You can run yourself a IP ASN History server as the source includes the complete code to run your own.

We also provide an API to our IP ASN History server which can be reached via a ReST API.

As example, you can query a specific IP address in a specific time range:

~~~~
curl "https://bgpranking-ng.circl.lu/ipasn_history/?ip=8.8.8.8&date="2019-01-01""
~~~~

and IP ASN History will return a JSON with the following metadata:

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

A more advanced API is available which can be easily used with [IP ASN History Python client](https://github.com/D4-project/IPASN-History/tree/master/client).

~~~~python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
from ipasnhistory.query import Query
import requests

q = Query()

response = q.meta()
print(response)
print(json.dumps(response, indent=2))

response = q.query('146.185.222.49')
print(json.dumps(response, indent=2))

response = q.query('146.185.222.49', first='2018-11-01', last='2018-11-25')
print(json.dumps(response, indent=2))

# --------- web

print('Meta info')
r = requests.get('http://127.0.0.1:5006/meta')
print(r.json())

print('Interval with first / last')
r = requests.get('http://127.0.0.1:5006/?ip=8.8.8.8&first=2018-09-01')
print(r.json())

print('Interval with first only')
query = {'ip': '8.8.7.7', 'first': '2018-09-01'}
r = requests.post('http://127.0.0.1:5006', data=query)
print(r.json())

print('One day only')
query = {'ip': '8.8.7.7', 'first': '2018-11-05'}
r = requests.post('http://127.0.0.1:5006', data=query)
print(r.json())

print('Cache only')
query = {'ip': '8.8.7.7', 'first': '2018-11-05', 'cache_only': True}
r = requests.post('http://127.0.0.1:5006', data=query)
print(r.json())

print('Precision delta')
query = {'ip': '8.8.7.7', 'date': '2018-11-08', 'precision_delta': json.dumps({'days': 2})}
r = requests.post('http://127.0.0.1:5006', data=query)
print(r.json())

print('Latest')
query = {'ip': '8.8.7.7'}
r = requests.post('http://127.0.0.1:5006', data=query)
print(r.json())
~~~~

The current ASN history used is the [CAIDA dataset](http://data.caida.org/datasets/routing/) but the software will be extended to support additional BGP Format such as MRT or alike to include your own from [openbgpd](http://www.openbgpd.org/) or from other RIRs such as [RIPE](https://www.ripe.net/analyse/internet-measurements/routing-information-service-ris/ris-raw-data).


