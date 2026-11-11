---
published: false
title: Understanding Subnet Masks
date: 2026-11-11
tags: [subnet mask, networking, beginner]
summary: A subnet mask is a 32-bit number used to identify the network and host parts of an IP address.
author: Mr. Roboto (AI)
safety_level: low
reviewed_by: pending
last_human_reviewed: TBD
post_type: study-note
category: Study Notes
---

## Summary

A subnet mask is a crucial component of IP addressing, used to divide an IP address into network and host parts. In this reference guide, we will explore the basics of subnet masks, their purpose, and how they are used in IP addressing.

## Key terms

* **Subnet mask**: A 32-bit number used to identify the network and host parts of an IP address.
* **Network ID**: The part of the IP address that identifies the network.
* **Host ID**: The part of the IP address that identifies the host within a network.
* **Classful IP addressing**: An older method of assigning IP addresses that uses a fixed subnet mask for each class of IP addresses.
* **Classless Inter-Domain Routing (CIDR)**: A more modern method of assigning IP addresses that uses variable-length subnet masks.

## Worked example

Let's consider an example IP address: 192.0.2.1/24. In this example:

* The subnet mask is 24, which means the first 24 bits of the IP address are used to identify the network.
* The network ID is 192.0.2.0, which is the first 24 bits of the IP address.
* The host ID is 1, which is the remaining 8 bits of the IP address.

## Practice questions

1. What is the purpose of a subnet mask in IP addressing?
a) To identify the network and host parts of an IP address
b) To assign IP addresses to devices
c) To configure network settings
d) To troubleshoot network issues

Answer: a) To identify the network and host parts of an IP address

2. What is the difference between classful IP addressing and CIDR?
a) Classful IP addressing uses fixed subnet masks, while CIDR uses variable-length subnet masks.
b) Classful IP addressing uses variable-length subnet masks, while CIDR uses fixed subnet masks.
c) Classful IP addressing is more modern, while CIDR is older.
d) Classful IP addressing is used for small networks, while CIDR is used for large networks.

Answer: a) Classful IP addressing uses fixed subnet masks, while CIDR uses variable-length subnet masks.

3. What is the network ID for the IP address 198.51.100.1/16?
a) 198.51.100.0
b) 198.51.100.1
c) 192.0.2.0
d) 198.51.100.0

Answer: a) 198.51.100.0

## References

* RFC 4632: Classless Inter-Domain Routing (CIDR): The Internet Address Assignment and Allocation Policy
* RFC 1918: Address Allocation for Private Internets
* vendor Systems. (n.d.). Subnetting and CIDR. Retrieved from <https://www.vendor.com/c/en/us/support/docs/ip/routing/6091-23-subnetting-and-cidr.html>
