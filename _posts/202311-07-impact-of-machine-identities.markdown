---
layout:     post
title:      "The Impact of Machine Identities on the State of Cloud Native Security in 2023"
subtitle:   "Thoughts on The Impact of Machine Identities on the State of Cloud Native Security in 2023"
date:       2023-11-07 15:00:00
author:     "Mattias Gees"
background: "/img/keylock.jpg"
---

# My thoughts on The Impact of Machine Identities on the State of Cloud Native Security in 2023

Some of my thoughts about The Impact of Machine Identities on the State of Cloud Native Security in 2023. This is a repost of my [Linkedin](https://www.linkedin.com/posts/mattiasgees_research-the-impact-of-machine-identities-activity-7127610636041084931-Lmcv?utm_source=share&utm_medium=member_desktop) post.

1. DevSecOps, DevOps has always been about the culture aspect, bringing Developers and Operations people closer together, and working as a team for me. I still see the perception that Security people are categorised as ‘the people that say no’, while DevOps people are the ‘Cowboys’. We all aim to deliver secure software that makes the business money; now is the time to act and form a partnership between Developers, Operations and security people.

2. Shift-left, we must consider security early in the development lifecycle. This means integrating in tooling that developers use daily (e.g. GitHub) rather than as a step when going to production.

3. Lift & Shift vs rearchitecting: the most successful organisations are when they have a vision and strategy to go to the cloud. Lift & Shift is the quickest to go to the cloud, but rearchitecting applications for the cloud will give you more considerable benefits in the long term.

4. Security: we can’t treat containers in the same way as we did with VMs. Containers are ephemeral and can have a lifecycle of a few seconds. You can’t use traditional CMDBs we have relied upon for visibility, but we must look at new tooling and rethink our approaches. Adopt the appropriate tooling for policy enforcement, CVE and malware scanning and runtime security.

5. Machine Identity: Kubernetes makes heavy use of x.509 certificates. From securing access to etcd, API Servers, ServiceAccounts up to your service mesh and ingress gateways. Do you have the necessary visibility into all of these? From which CA have they been issued, and when do they expire? Venafi TLS Protect for Kubernetes helps to solve those problems.

6. Software Supply Chain Security: you want visibility and traceability in your supply chains. You need to know which process created your artefacts and how those artefacts have been created. Those questions should be answerable when considering visibility for all your images, not only 3rd party images. I see too many cases where people think that by signing their containers, they have secured their software supply chain. Consider well why you are signing and attesting artefacts and what it means in the bigger context!

7. Zero trust: Many enterprises have strategies for moving to zero trust, and the BeyondCorp example of Google has played an essential part in this. Achieving zero trust is a big challenge and requires a lot of determination and engineering before you get all the advantages of it. Machine Identity enabled by SPIFFE will be an essential enabler in this. SPIFFE will give each device and workload a unique identity, allowing you to authenticate, authorize and govern all of your workloads and devices. To achieve zero trust, you need a true partnership between Security, Platform Engineering and Developers, and with that, we are full circle and back to DevSecOps.
