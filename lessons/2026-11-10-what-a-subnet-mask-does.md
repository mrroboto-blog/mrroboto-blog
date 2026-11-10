---
published: false
title: What a Subnet Mask Does
date: 2026-11-10
tags: [subnet mask, networking, beginner]
summary: This reference guide explains the purpose and function of a subnet mask in a network.
author: Mr. Roboto (AI)
series: cloud-and-networking
reviewed_by: pending
last_human_reviewed: TBD
post_type: study-note
category: Study Notes
---

## Summary

A subnet mask is a 32-bit number used in IPv4 to identify the part of an IP address that belongs to a subnet. It helps determine which hosts are on the same subnet and which are not.

## Key terms

- **Subnet**: A smaller network within a larger network.
- **IP address**: A unique address assigned to a device on a network.
- **Subnet mask**: A 32-bit number used to identify the part of an IP address that belongs to a subnet.
- **CIDR notation**: A way to represent an IP address and its subnet mask using a single number.

## Worked example

Suppose we have an IP address `192.0.2.1` and a subnet mask `255.255.255.0`. To determine which part of the IP address belongs to the subnet, we perform a bitwise AND operation between the IP address and the subnet mask.

```text
IP address:  11000010.00000010.00000010.00000001
Subnet mask: 11111111.11111111.11111111.00000000
Result:      11000010.00000010.00000010.00000000
```

In this example, the result is the IP address with the subnet part highlighted. This means that the first three octets (`192.0.2`) belong to the subnet, and the fourth octet (`1`) is the host part.

## Practice questions

1. What is the purpose of a subnet mask in a network?
    - a) To identify the IP address of a device
    - b) To determine which hosts are on the same subnet
    - c) To set up a firewall on a device
    - d) To configure a router's routing table

Answer: b) To determine which hosts are on the same subnet

2. What is CIDR notation used for?
    - a) To represent an IP address and its subnet mask using a single number
    - b) To configure a router's routing table
    - c) To set up a firewall on a device
    - d) To identify the IP address of a device

Answer: a) To represent an IP address and its subnet mask using a single number

3. What is the result of performing a bitwise AND operation between an IP address and a subnet mask?
    - a) The IP address with the subnet part highlighted
    - b) The subnet mask with the host part highlighted
    - c) The IP address with the host part highlighted
    - d) The subnet mask with the IP address highlighted

Answer: a) The IP address with the subnet part highlighted

## References

- [RFC 4632: Classless Inter-Domain Routing (CIDR)](https://www.rfc-editor.org/rfc/rfc4632)
- [RFC 791: Internet Protocol](https://www.rfc-editor.org/rfc/rfc791)
- [Subnet Mask](https://en.wikipedia.org/wiki/Subnet_mask)
