---
permalink: /
title: "Welcome Traveler, to Samir's Hypertext Garden!"
excerpt: 'I am a hardcore hacker on operating systems, hardware, and programming languages. Come visit my digital garden to see what I am growing.'
author_profile: true
redirect_from:
  - /about/
  - /about.html
  - /now/
  - /now.html
---
{% include base_path %}

<div class="notice notice--announcement" markdown="1">
#### I plan on attending [Open Sauce](https://opensauce.com/) (July 18-20, 2025 in San Mateo, California) and [TockWorld](https://world.tockos.org/tockworld8), which is happening with [RustConf](https://rustconf.com/) (Sept 2-5, 2025 in Seattle, Washington). Reach out if you'd like to meet me there!
</div>

I am a hardcore software engineer and researcher building multiplanetary cellular service at [Starlink](https://starlink.com/).
I contribute to the Rust-based [Tock Operating System](https://tockos.org/), where I secure devices such as roots of trust and FIDO security keys.

My research tries to make systems understandable, safe, and correct. 

I work on the [Flux](https://github.com/flux-rs/flux) verification tool for Rust. We are using Flux to formally guarantee that an OS is secure. Our research applies lightweight formal methods (refinement types) to show that you can easily prove useful properties at compile time, such as the memory isolation guarantee of an embedded operating system. This project *proves* that it is impossible for an attacker to ever violate process isolation guarantees in Tock OS. Tock OS is a security-focused operating system for embedded devices, is written in Rust, and is used as the root of trust in millions of devices. You can [click here](https://godsped.com/safe-firmware/) to learn more about how we are applying lightweight formal verification to do this.

I am advised by Professors [Pat Pannuto](https://patpannuto.com/) and [Ranjit Jhala](https://ranjitjhala.github.io/). I previously TAed for Professor Pat Pannuto's [Wireless Embedded Systems (CSE 222C)](https://cseweb.ucsd.edu/classes/wi25/cse222C-a/index.html) and Professor [Geoffrey Voelker's](https://cseweb.ucsd.edu/~voelker/) [Operating Systems (CSE 120)](https://cseweb.ucsd.edu/classes/fa24/cse120-a/).
In my free time, I am a mentor for [FIRST Robotics Team 812](https://www.themidnightmechanics.com/) where I hope to inspire high schoolers with a "sense of wonder" through hands on experience.

I graduated with my bachelor's from UC San Diego, double majoring in Math and Computer Science and minoring in Classical Studies. Outside of class, I was a member of [Triton Unmanned Aerial Systems](https://tritonuas.com/) club working working as a jack-of-all-trades and on 3D path planning for our autonomous plane. 

During my undergrad, I worked with Professor [Pat Pannuto](https://patpannuto.com/) on the Rust-based [Tock Operating System](https://tockos.org/). Tock takes advantage of Rust type-safety to offer fault isolation, dynamic memory management, and concurrency that are not typically available to power constrained microcontrollers. We revisited network interface design and abstractions. Our goal was to integrate fair sharing of limited radio on-time and network bandwidth. I am particularly interested in how interfaces can be used to make compile-time guarantees about network operation. Tock's secure [OpenThread port](https://book.tockos.org/course/thread-net/overview) came out of this project, and my colleages are continuing work to get compile-time guarantees about energy efficiency. Previously, I was a member of [The Computing for Social Good Lab at UCSD](https://melsherief.eng.ucsd.edu/research) where I researched mental burnout and problem gambling on social media using NLP.

<!-- I am actively interested in new positions at this time. I am interested in work where I can work on formal verification and/or systems software (Operating Systems, Low-Level, or Performance) and prefer to be able to open source my work. Please check my [resume](https://godsped.com/cv) for links to my past experiences. -->
<!-- update alongside hire.md -->

## Interests

Software keeps getting larger and harder to understand. Currently, there is no easy way to check if a system is meeting its specifications or to confirm assumptions about its behavior. The only options are unreliable manual testing or to create costly formal proofs to match code's behavior with a specification. I believe this unmanageable complexity is already stifling innovation and will be the biggest problem in future software. Thus, the most impactful and urgent area of software engineering is to make verifying large systems practical. Lowering barriers to making safe software will encourage better software. I dream of a world where software was designed to be observable, debuggable, and safe.

I am interested in investigating the applications machine learning techniques and its intersection with various fields, particularly NLP. I see computers' knowledge of human language as the next big interface for humans to utilize computing power more naturally. I look forward to computers gaining a semantic understanding of language. (Looks like all of these have been accomplished since I wrote this!)

I am also passionate about the application of simulation in developing robust systems. In Triton UAS, I looked into using Blender simulations to accelerate software development on aerial vehicles. Simulations can be integrated into automated testing pipelines and used for human sanity-check verification during rapid development cycles.

## About Me

👋 Hey, I'm Samir, but you can call me Samir.

My recent hobby has been an Among Us addiction. I also have been going through my backlog of things I've been meaning to do (like giving this site a little love 🫀). If you have any recommendations, I enjoy discovering new music and seeing all the interesting genres people come up with. Despite my true love being software and me being wholly incompetent at the physical engineering disciplines, I enjoy fiddling around with hardware. I hope to spend more time working on physical projects.

I'd love to talk about anything! Feel free to suggest a time that works [here](https://calendly.com/samir0/30min) 🕰.

### Things I love

- ⚙ understanding complex systems
- 💻 keeping an organized workspace against relentless entropy
- 🤔 shows & movies that make you think
- 📕 sci-fi: *Neuromancer* is a recent recommendation
- 👀 [privacy](https://xkcd.com/1553/)
- 🎵 discovering new music
- 🏃‍♂️ XC running
- 💾 people who do proper backups
- 🪄 the magic when things just work
- 🪐 intellectualizing at night
- 📰 current favorite [Wikipedia article](https://en.wikipedia.org/wiki/Corrupted_Blood_incident)
- 🦍 current favorite [game](https://store.steampowered.com/app/1533390/Gorilla_Tag/)
- 🐳 current favorite [movie](https://www.themoviedb.org/movie/555604-guillermo-del-toro-s-pinocchio)
- 📜 some favorite research papers: [THE](https://dl.acm.org/doi/pdf/10.1145/363095.363143), [Scheduler Activations](https://dl.acm.org/doi/pdf/10.1145/146941.146944), [Singularity](https://courses.cs.washington.edu/courses/cse551/15sp/papers/singularity-osr07.pdf), [RLBox](https://www.usenix.org/system/files/sec20-narayan.pdf), [Omniglot](https://patpannuto.com/pubs/schuermann2025omniglot.pdf)

### Quotes

<div class="commentary-author">Casey Handmer</div>
<div class="commentary-body">
If your vision for the future
includes elements that will not occur
by themselves, you have to build them
</div>

<div class="commentary-author">Chris Lewicki</div>
<div class="commentary-body">
Make what’s possible, <em>inevitable</em>
</div>

<div class="commentary-author">JFK</div>
<div class="commentary-body">
We choose to go to the Moon
</div>

<div class="commentary-author">Kishore Nallan</div>
<div class="commentary-body">
The unreasonable effectiveness of just showing up everyday
</div>

<div class="commentary-author">Samir Rashid</div>
<div class="commentary-body">
Everything is understandable
</div>


## For more info

Message me through any of the contacts in the sidebar. Email is preferable.

Here's my [GPG key]({{ base_path }}/pgp.txt).
You can also find it on my [Keybase](https://keybase.io/samirrashid) or hosted on the [OpenPGP keyserver](https://keys.openpgp.org/vks/v1/by-fingerprint/DE65F61B7AD669C839721530A81CA0CA8957AC94).

## Feedback

I would love to hear your feedback, constructive or otherwise. As an effort for personal CI/CD and behavioral refactoring, I have made [this anonymous feedback box](https://www.admonymous.co/samir).

*[NLP]: Natural Language Processing
*[TAed]: Teaching Assistant
