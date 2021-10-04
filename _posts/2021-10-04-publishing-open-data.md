---
title: "Publishing open data in the cyber security field"
date: 2021-10-04
layout: post
categories: 
image: assets/images/graph-botnet-tor.png
---

# Publishing open data in the cyber security field

Having precise and accurate metrics about cyber security is critical in the [measurement of security](http://all.net/Metricon/measuringsecurity.tutorial.pdf) as explained by Daniel E. Geer. Many industries have their own metrics but it's often difficult to find
metrics concerning cyber security. The [VARIoT project](https://www.variot.eu/) aim is to improve the situation and especially to distribute open data related to cyber security metrics in the IoT field.

As part of this goal, CIRCL, member of the VARIoT consortium, redistributes a subset of data produced by the partners such as Shadow Server. In the mean time, an [open data security format](https://github.com/CIRCL/open-data-security) has been developed with the goal to better describe open data related to security and especially the details on how the data was gathered and evaluated.

~~~~json
{
  "human-validated": false,
  "machine-validated": true,
  "title": "Infected IoT device statistics",
  "subtitle": "Infected IoT devices detected primarily through sinkholes, honeypots and darknets",
  "description": "This is a dataset containing a country-level breakdown of infected IoT devices detected through sinkholes, honeypots and darknets operated by The Shadowserver Foundation and its partners. The data is grouped by IoT related threats. In some cases a vulnerability id
 is provided as a threat name - this is for cases when an IP was seen attempting to exploit an IoT related vulnerability by a honeypot, but no threat related information was acquired. This dataset was created as part of the EU CEF VARIoT project https://variot.eu",
  "frequency": "daily",
  "time-precision": "day",
  "source": [
    "honeypots",
    "sinkholes",
    "darknets",
    "Shadowserver"
  ],
  "license": "CC-BY-NC-SA-4.0",
  "producer": "https://www.shadowserver.org/",
  "tags": [
    "scan",
    "tlp:white"
  ],
  "link": "https://cra.circl.lu/opendata/variot/iot-exposed-infected-device-stats"
}
~~~~

As you can see above, the open data security format describes who/what validated the data, the overall description but also the frequency of update and the sources. It's a first version of the format and we will publish an Internet-Draft for the next version. If you see any missing
 fields or want to provide feedback, feel free to open an issue on the [open-data-security description format repository](https://github.com/CIRCL/open-data-security). The format is currently used in VARIoT and will be used in the [D4 Project](https://www.d4-project.org/).

The data for IoT related information (infected and exposed devices) can be downloaded from [https://cra.circl.lu/opendata](https://cra.circl.lu/opendata/variot/) but is also available through the [European Open Data Portal](https://data.europa.eu/data/datasets/infected-and-exposed-
iot-device-statistics/locale=en). The philosophy of CIRCL is to keep the data as raw as possible produced by the source to avoid loss of information and maximize the data exploitation. The dataset is daily produced by [Shadow Server](https://www.shadowserver.org/). It includes data
 about Infected IoT devices detected primarily through sinkholes, honeypots and darknets and exposed IoT devices detected by Internet-wide scanning. The dataset is constantly evolving due to the emerging new vulnerabilities that can be assessed.

We strongly hope that more producers of open data in the cyber security field use and extend the [open data security format](https://github.com/CIRCL/open-data-security) to describe their datasets in a common way.

*When you can measure what you are
speaking about, and express it in numbers,
you know something about it; but when you
cannot measure it, when you cannot express
it in numbers, your knowledge is a meagre
and unsatisfactory kind; it may be the
beginning of knowledge, but you have
scarcely, in your thoughts, advanced to the
stage of science.
          -- William Thomson, Lord Kelvin, 1883*

