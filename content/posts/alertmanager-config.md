---
title: "Monitoring & Alerting"
tags: ['Tech', 'Kubernetes', 'Prometheus', 'Grafana', 'Alertmanager', 'Thanos', 'Scaling', 'Monitoring', 'Alerting']
date: 2021-03-03T14:27:11Z
draft: false
---

# Introduction

Recently I've been working a lot in the monitoring & alerting space. Which entailed 0 monitoring & alerting to monitoring of over 6 clusters, while that doesn't sound a lot the process and approach we took would allow us to scale that number to 100+ clusters including production.

## The Approach

As we started with **zero** monitoring, this gave me the chance to start something from complete scratch which doesn't come along often. We've been planning on getting at least some monitoring in for some time now and with a few days in my calendar free I thought "why not". There was of course some requirements;

* have a single location to view all of the metrics
* scale and grow with the ever changing list of environments/cluster we're building and operating
* everything as code. I repeat everything as code.

## The planning

While I've played around with Prometheus, Grafana and Alertmanager I've never got to the point of having multiple clusters all being displayed in one single planel.

_"Monitoring one cluster is trival, mulitple clusters is where the fun begins."_ - Me, sometime after attempting to monitoring multiple clusters.

At this point I was looking for a solution which would tick all of the above requirements in one kubernetes manifests. Turns out that definitely wasn't the case, as there's quite a few moving parts to the final solution. When doing some research I came across a fun tool called [Thanos](https://thanos.io/). Thanos sounded absolutely perfect on paper, ticking every box of the requirements. So where's the downfall you ask? Well appart from the many moving parts (which you'd get in any kubernetes related monitoring system) there really wasn't one. So I followed this ["Intro to Thanos"](https://www.youtube.com/watch?v=m0JgWlTc60Q) video and came across a solution which would allow us to have minimal componenets running within the clusters we wanted to monitor (leaf clusters from here on in) and a scaleable approach to centralised monitoring through the use of [Thanos Reciever](https://thanos.io/tip/components/receive.md/).

## The excution

As we're deploying this entire stack with Kubernetes and EKS, I decided the best place to start was with Helm and the community charts. Turns out
