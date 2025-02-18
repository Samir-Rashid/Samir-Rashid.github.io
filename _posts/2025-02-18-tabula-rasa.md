---
title: "*Tabula Rasa*: Starting Safe Stays Safe"
permalink: /tabula-rasa/
date: 2025-02-18
tags:
  - research
---

I'm ecstatic to share that we won best paper at The 3rd Workshop on Security and Privacy in Connected Embedded Systems (SPICES 2024). My collaborators and I studied the security of embedded operating systems and their usage *in the wild*.

> [You can read the full paper here, or read on for some relevant excerpts.](https://patpannuto.com/pubs/potyondy2024tabularasa.pdf)

Embedded and connected devices have become a ubiquitous and
integral part of our world. From medical devices and smart home
products to industrial controllers, these devices perform an increasing set of complex, critical tasks. To abstract these complexities, embedded operating systems (OSes) evolved to provide rich
development environments and high-level abstractions, such as
platform-independent hardware models and separable tasks. Despite the availability of these abstractions and isolation mechanisms
for tasks, we find that in practice many embedded applications lack
strong isolation and do not enable security reinforcements. This
paper explores projects using embedded OSes to quantify how configurable security features are used and how they factor into the
given project’s design.

Historically, embedded devices did not offer connectivity. For
instance, industrial controllers or automotive Electronic Control
Units (ECUs) required a technician physically access and “plug-into”
the device. As embedded devices have evolved into the Internet of
Things (IoT), many now offer internet connectivity to gather data,
offer remote control, and provide firmware updates. Developers
now expect embedded OSes to provide library features such as
over-the-air updates and network stacks. Internet connectivity and
the global scale of many billions of deployed devices implies that
embedded devices now face an attack surface more akin to that of a
traditional operating system. As such, the security embedded OSes
provide is paramount.

With this connectivity, embedded devices now
face a more complex attack surface, underscoring the importance
of device security. Embedded operating systems are able to span
diverse application and hardware domains because they are highly
configurable. This flexibility, however, implies that downstream
embedded applications may be flexible in how they use security
features. This paper investigates how downstream applications use
configurable security features in practice. We find that a majority of
applications do not alter the default configuration provided by their
chosen runtime, and as a result, do not utilize available security
options. Early evidence suggests that this under-utilization is due
to both runtime and development overhead.


**Result 1**: Zephyr & FreeRTOS MPU Feature Usage. 

Zephyr and
FreeRTOS offer similar MPU-based security configurations,
and both disable process isolation and stack overflow protection by default. Of surveyed Zephyr and FreeRTOS applications, 17% of Zephyr and 8% of FreeRTOS projects enable
both process isolation and hardware stack guards. We subsequently observe that 89% of surveyed FreeRTOS/Zephyr
projects do not enable the full suite of opt-in, configurable
MPU security features. We do not include RIOT in this
result as RIOT does not support MPU process isolation.

**Result 2**: SW/HW Stackguard Usage. 

Surveyed FreeRTOS repositories exhibit a more than sixfold increase of software-based stackguards usage in comparison to hardware-based
stack guard usage.

**Result 3**: Opt-out Configuration Usage. 

For RIOT platforms possessing an MPU, RIOT enables `mpu_stack_guard` by default.
We find that no surveyed project disables this feature.

**Result 4**: Runtime Overhead. 

Our preliminary benchmarking of Zephyr in Result 4 finds that
hardware security features impose a mere 224 cycle overhead per
context switch. This result agrees with the documentation
excerpts and shows an overhead that is in fact noticeable, but likely
only problematic for high performance applications. We argue that
**the vast majority of IoT embedded applications do not require “every last drop of performance,” but instead that the primary overhead
impeding the usage of configurable security features is not performance but developer overhead.**


This paper shows the disparity between the configurable security
features the studied embedded OSes offer and the features that
are actually used *in the wild*. Our preliminary results and analysis
suggest the primary overhead limiting the use of these features is
developer overhead. Nonetheless, further investigation is required
to gain a more complete understanding of why these features are
left disabled by developers. So long as downstream applications
see limited use in enabling such optional features, the potential
security benefits embedded OSes can provide is left unrealized. This
is particularly problematic given the increased attack surface of
modern IoT devices.

<a class="btn" style="" href="https://patpannuto.com/pubs/potyondy2024tabularasa.pdf">Read the full paper</a>
