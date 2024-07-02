---
title: "Version Fingerprinting Tricks: Automating Software Identification for Vulnerability Scanners"
date: 2024-07-02
layout: post
categories: 
image: assets/images/fingerprint-1.png
---

# Version Fingerprinting Tricks: Automating Software Identification for Vulnerability Scanners

## The Problem with Coordinated Vulnerability Disclosure

In an ideal world, security researchers report vulnerabilities to the vendor or responsible entity, allowing them time to fix the issue before public disclosure.

For CSIRTs, this is only a minor part of the Coordinated Vulnerability Disclosure (CVD) process. Finding vulnerable and exposed hosts is critical for notifying organizations with vulnerable configurations, such as unpatched systems, misconfigured systems, or even unknown systems.

For more details on CVD, refer to [this resource](https://csirtsnetwork.eu/homepage/cvd).

## The CSIRT Roles with Coordinated Vulnerability Disclosure

1. **Scanning Network**: Finding vulnerable networks within your infrastructure or constituency, partially relying on sources like ShadowServer, LeakIX, Onyphe, Censys, and Shodan.
2. **Confirming Vulnerabilities**: Not all publicly available scanners have accurate results; some may be outdated.
3. **Tracking Vulnerable Hosts**: Maintaining records of identified vulnerabilities for effective monitoring and remediation.

We will explore improving the above processes through version fingerprinting. The presentation was given at [FIRST.org 2024 conference](https://www.first.org/conference/2024/program) in Fukuoka, Japan. 

## Mass vs. Targeted Notifications

### Mass Notifications

**Pros:**
- Faster
- Wide reach
- Few technical resources required
- Public awareness

**Cons:**
- Panic and overhead ("crying wolf")
- Alert fatigue
- High human resources required
- Lack of customization / impersonal
- Visibility issues, with "Good Samaritan" scanners being blocked

**Pros in Detail:**
- **Speed and Efficiency**: Mass notifications allow the CSIRT to quickly inform a large number of entities about the vulnerability, enabling faster overall response and mitigation efforts.
- **Wide Reach**: Ensures that all potentially affected parties are aware of the vulnerability, reducing the risk of some entities remaining unaware and thus vulnerable.
- **Resource Management**: Saves time and resources compared to contacting each entity individually, which can be particularly resource-intensive.

### Targeted Notifications

**Pros:**
- Customized and personal
- Reduced alert fatigue
- Better engagement

**Cons:**
- Slower
- Limited reach
- More technical resources required
- Less public awareness

## Case Studies: Microsoft Exchange and GitLab

### Microsoft Exchange

Using Nmap scripts to identify Microsoft Exchange versions can significantly improve the accuracy of vulnerability detection and notification. Here are some steps and tools:

- **NMAP Script (ms-exchange-version.nse)**: Extracts the X-OWA-Version header and build number from OWA (Outlook Web Access) path.
- **Export Tool**: Find metadata of the detected MS Exchange build number/version.
- **Show CVEs**: Using `--showcves` to display CVEs that affect that specific version.

One of the biggest challenges when identifying MS Exchange versions is that the CPE used in the vulnerability reports (Affected Configurations) does not point to a specific build number of the product. 
To overcome this issue an automated tool was created to create a dictionary of the CVEs affecting each build number.

![Fingerpring Microsoft Exchange and difficulties of track CPE/version of Exchange](/assets/images/fingerprint-1.png)


References and tooling developed:

- [Microsoft Exchange Build Numbers](https://learn.microsoft.com/en-us/exchange/new-features/build-numbers-and-release-dates)
- [Nmap Script for MS Exchange](https://github.com/righel/ms-exchange-version-nse)

### GitLab

![](/assets/images/fingerprint-2.png)

![](/assets/images/fingerprint-3.png)

GitLab version detection can also be automated with Nmap scripting:

- **NMAP Script (gitlab-version.nse)**: Retrieves the GitLab version from headers.

References and tooling developed:

- [GitLab Version Detection Script](https://github.com/righel/gitlab-version-nse)

## Vulnerability Persistence Post-Notification

Key takeaways for vendors and CSIRTs:

1. **Precise Common Platform Enumerations (CPEs)**: When publishing a vulnerability via a CNA/CVE program, ensure detailed and accurate information about affected configurations.
2. **Comprehensive Information Sharing**: Helps people patch their systems more effectively and aids CSIRTs in identifying and notifying the right entities.
3. **Scanning and Detection**: Worth doing for common products with a large user base and critical information. Reusable by other communities for similar purposes.

## References

- [GitLab Version NSE](https://github.com/righel/gitlab-version-nse)
- [MS Exchange Version NSE](https://github.com/righel/ms-exchange-version-nse)
- [Vulnerability CIRCL](https://vulnerability.circl.lu/)
- [CVE Search](https://github.com/cve-search)

## Contact

- Alexandre Dulaunoy: <alexandre.dulaunoy@circl.lu>
- Luciano Righetti: <luciano.righetti@circl.lu>

