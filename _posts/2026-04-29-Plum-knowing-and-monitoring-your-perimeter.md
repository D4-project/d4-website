---
title: "Plum: knowing and monitoring your perimeter"
date: 2026-04-29
layout: post
categories: 
---

[Plum](https://github.com/D4-project/Plum-Island/tree/v0.2604.0), for *Proactive Land Uncovering & Monitoring*, is an orchestration tool to learn, monitor, and document an exposure surface. It coordinates work between scanning agents, keeps historical results, and makes observations searchable over time.

This project, part of D4 which was initialy co-funded by the European Union, is still young, but it already addresses a concrete need: helping CIRCL to keep a global view of Luxembourg's IP space, especially in the context of NIS2-related activities. The goal is not only to scan, but to maintain actionable knowledge of the national perimeter, its visible exposures and allows vulnerability discovery in the context of incident response.

## Knowing what is exposed

Plum first answers a simple question: what is actually exposed on my perimeter?

You provide the perimeter to monitor:

- IP addresses, ranges, or any FQDNs;

Then Plum collects and organizes observations from scans:

- open ports;
- services, banners, and NSE scripts;
- HTTP titles, web servers, cookies, ETags, and favicons;
- TLS certificates, subjects, issuers, and SANs;
- tags applied by flexible detection rules.

This knowledge is primarily used to detect potentially vulnerable devices or unexpected exposures. It also helps track changes: a new port, a moved service, an unusual certificate, a technology to monitor, or an exposure that reappears.

## Difference from a Shodan/Onyphe/Census-like engine

First, Plum is Open source, you may deploy it on premise for your own need.

Plum may look like an exposure search engine, but its logic is different from a any commercial service like Shodan. Such tools provides an external view built from its own scans. Plum let you monitor your own exposure surface, with your own rules, frequencies, and priorities.

The user controls IP ranges, FQDNs, scan profiles, scan frequency, priorities, NSE scripts, and tagging or reporting rules.

The perimeter is therefore not limited to IP ranges. Plum can also work from a FQDN base, which is useful for tracking services behind virtual hosts, CDNs, reverse proxies or shared infrastructures. In practice, Plum combines a network view by IP with a business or application view by name.

Another important difference: Plum is designed to be easy to deploy. It can be installed for a local need, a security team, a CSIRT, or an operator that wants to monitor its own perimeter without relying only on an external view.

## Scan strategies and agents

Plum is built around three concepts:

- `Targets`, which represent the monitored assets;
- `ScanProfiles`, which define what to scan and how;
- `Plum agents`, which fetch jobs and execute scans.

Agents are designed to be easy to deploy anywhere. Execution points can be added where they are useful: internal infrastructure, observation networks, dedicated environments, or specific scanning positions. The server keeps orchestration and history; agents execute the jobs.

`ScanProfiles` make it possible to build scan strategies: a frequent web profile, a broader but less frequent profile, a TLS profile, a specific script for a given need, or a high-priority profile for an urgent investigation.

For now, Plum is currently centered on `nmap` and will be extended to other scanning technologies. This is a logical first step: nmap provides a robust base for discovering ports, identifying services, and running NSE scripts. The ambition is to extend this base later with `masscan`, custom scripts, and various open source vulnerability-checking tools.

## History and deduplication

Each collected result is stored with first-seen and last-seen timestamps. Plum therefore does not only look at the current state: it keeps memory of what appeared, what remained stable, and what came back.

To optimize report volume and avoid repeating the same observations, we build a parsing script named [`nmap2json`](https://github.com/D4-project/nmap2json). This parser produces a stable fingerprint named `hsh256` (Hash Smart Hash). This is not a raw hash. Before computing the SHA-256, the document is normalized: timestamps are excluded, structures are sorted, and volatile HTTP header values are ignored in the hash calculation, such as session cookies, HTTP dates, UUIDs, ETags, CF-Ray, request-id,
CSP nonces, etc…

If the same result is seen several times, Plum keeps the oldest `first_seen` and updates the most recent `last_seen`. A stable service is therefore not emitted as a new result in every report: reports can focus on what appears, changes, or reappears.

## Qualification, search, and reports

An open port is often the first useful element. But to produce a useful report, the observation also needs qualification: is it a new port, a stable service, a technology to track, a sensitive exposure, or a potentially vulnerable device?

Plum is not a vulnerability scanner, it will never do. It prepares the ground for reporting and prioritization: it collects the information needed to know what to test, where to look, and which hosts should be highlighted. Plum is more an ASR, attack surface reduction software.

Tagging rules automatically qualify observations: technology, interesting exposure, configuration to monitor, application family, or indicator useful for vulnerability research. Plum already ships with around thirty rules that create tags, and these rules are flexible and editable. Tags then become searchable, exportable, and usable in reports.

To exploit this data, Plum exposes two complementary search modes:

- token search in documents;
- structured search over extracted fields.

Structured search can filter on many fields such as `ip`, `net`, `port`, `fqdn_requested`, `http_title`, `http_server`, `banner`, `x509_subject`, `x509_san`, or `tag`. Modifiers such as `.lk` (`like`) and `.bg` (`begin`) provide partial or prefix matching.

Example:

![](https://hdoc.csirt-tooling.org/uploads/04b23d2c-3a81-419e-bb1f-d1b118e42aee.png)

The same queries feed Markdown reports. This is where temporal deduplication becomes useful: a report can focus on new ports, exposed services, detected tags, devices to investigate, or changes observed during a period, wihout repeating already-known observations unnecessarily.


## What comes next?

The next logical step is to extend the execution engine. A first direction is integrating `masscan` for fast scouting over large perimeters, then triggering more precise nmap scans on discovered surfaces and also `custom scripts` to allow specific scans in the context of emergency notificaton. 

A second direction is integrating other open source scanners, especially vulnerability-oriented tools. Plum could then select the relevant targets, launch the right tool, keep the result history, and make everything searchable in one place.

Today, Plum is co-founded through the European Project [FETTA]( https://www.circl.lu/pub/press/20240131/), and even in early stage, It already monitor regularly around two million IPs. This is a drop in the ocean at the scale of the global Internet, but it represents the current surface of the Luxembourgish Internet. For CIRCL, this capability helps monitor that perimeter and supports the knowledge and monitoring work required in the NIS2 context.

![](https://hdoc.csirt-tooling.org/uploads/c54f9130-471a-43c3-a9ec-77892a0a4a8b.png)


## Disclaimer

Co-funded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European Cybersecurity Competence Centre. Neither the European Union nor the granting authority can be held responsible for them.
