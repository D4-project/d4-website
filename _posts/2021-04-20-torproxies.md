---
title: "Monitoring botnets that use Tor proxies"
date: 2021-04-20
layout: post
categories: 
tags: 
---


[Tor](https://www.torproject.org/) is an onion routing protocol that can used to protect users' anonymity and
circumvent censorship. Tor allows for the hosting of hidden-services that are
services only accessible through Tor.

Several services online exist to alleviate the burden of installing Tor to
navigate such services, with the main drawback of completely losing anonymity
and other guarantees of confidentiality and integrity of exchanges while using
them.

If such discrepancy between the provided service and the risk to use make such
service almost useless for regular users, it is very appealing for cyber
criminals in search for hosting solution for their command and control
infrastructure.

For almost 6 months we operated one of such HTTP to Tor proxy to get a sense of
the characteristics of the traffic that go through them.

We gave a talk "Industrialize the Tracking of Botnet Operations – A Practical Case with Large Coin-Mining Threat-Actor(s)" at [FIRST CTI SIG summit 2021](https://www.first.org/events/web/cti-sig-summit-2021/) about the topic.
- The [supporting slides](/assets/slides/20210419-FIRST-torproxies.pdf)
- and the open source [analysis software](https://github.com/d4-project/d4-pretensor) part of the D4 Project.

<div style="text-align: center; padding-top: 2cm;">
<iframe width="730" height="415" src="https://www.youtube.com/embed/VGsuXvZknJ8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
</div>
