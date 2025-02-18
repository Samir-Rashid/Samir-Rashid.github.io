---
title: "Pronoun usage in the Linux Kernel"
permalink: /linux-pronouns/
date: 2025-02-17
# tags:
  # - talk
excerpt: How are pronouns used in the Linux kernel? I analyzed the distribution of pronouns in the 6.13 Linux kernel source. Unsurprisingly, I find that male pronouns are common, but this makes female pronouns all the more unusual.
---

I analyzed the distribution of pronouns in the 6.13 Linux kernel source. Unsurprisingly, I find that male pronouns are common, but this makes female pronouns all the more unusual.

{% include toc %}

# Results

## Counts by pronoun

| Term | Count |
|------------|------|
| he/him/his | 2516 |
| she/her/hers | 33 | 
| man | many references to `man` |
| men | 3 |
| wom{a,e}n | 4 |
| person | many license usages |
| people | 779 |

The count for ["person"](https://livegrep.com/search/linux?q=file%3A%5C.c%24%20%5Cb%5CW*person%5CW*%5Cb&fold_case=auto&regex=true&context=true) is tainted by all of its usages in license verbiage. Similarly, ["man"](https://livegrep.com/search/linux?q=%5Cb%5CW*man%5CW*%5Cb&fold_case=auto&regex=true&context=true) is polluted with all the references to "man pages".

I pruned non-pronoun usages. I did not include uses of "they" or "them" because I cannot grep to distinguish between uses of the gender-neutral pronoun "they" or as the plural for neuter terms (such as referring to function calls or variable values).

## Pronoun usage over time

[![pronouns over time in Linux source](/images/pronouns/graph2.png)](https://www.vidarholen.net/contents/wordcount/#she,her,hers,he,him,his,man,woman,men,women){:target="_blank"}

[![pronouns over time in Linux source](/images/pronouns/graph1.png)](https://www.vidarholen.net/contents/wordcount/#man,woman*,men,women*,person*,people*){:target="_blank"}


# Analysis

The kernel overwhelmingly uses male pronouns. This result is expected due to the >90% male contributor population. Bitergia looked at the contributions of men and women to the Linux kernel in 2016. [Their study](https://bitergia.com/blog/reports/gender-diversity-analysis-of-the-linux-kernel-technical-contributions/) found that women produced 6.8% of git activity as 9.9% of the developer population. This analysis was  based on identifying gender from names. 

I expected there to only be uses of male or gender-neutral phrases. This hypothesis led me to inspect every usage of female pronouns.

Excluding some gender-neutral uses of "he/she", "his/her", and "[s]he", the results for grepping ["her"](https://livegrep.com/search/linux?q=%5Cb%5CW*her%5CW*%5Cb%20max_matches%3A1000&fold_case=auto&regex=true&context=true) are peculiar.

#### "her" usage

| noun which the pronoun refers to | notes |
|------------|------|
| female student | A didactic quote with a female student [[commit]](https://github.com/torvalds/linux/blob/v6.13/Documentation/process/howto.rst?plain=1#L554) |
| user of the computer | unsure of authors as commits are from before the kernel switched to git [[commit 1]](https://github.com/torvalds/linux/blob/v6.13/drivers/video/fbdev/aty/mach64_ct.c#L512) and [[commit 2]](https://github.com/torvalds/linux/blob/v6.13/net/bridge/netfilter/ebtables.c#L1070) |
| a disk transaction | [[commit]](https://github.com/torvalds/linux/blob/v6.13/fs/jfs/jfs_logmgr.c#L881) |
| busy waiter on a lock | [[commit]](https://github.com/torvalds/linux/blob/v6.13/kernel/printk/printk.c#L1935) |

### "she" usage

| noun which the pronoun refers to | notes |
|------------|------|
| scientist user | [[commit]](https://github.com/torvalds/linux/blob/v6.13/Documentation/admin-guide/LSM/Smack.rst?plain=1#L501) |
| code author | [[commit]](https://github.com/torvalds/linux/blob/v6.13/Documentation/watchdog/pcwd-watchdog.rst?plain=1#L68) |
| user | [[commit]](https://github.com/torvalds/linux/blob/v6.13/drivers/usb/gadget/function/u_fs.h#L222) |
| parody song quote | [David Bowie](https://www.phrases.org.uk/bulletin_board/47/messages/84.html) quote [[commit]](https://github.com/torvalds/linux/blob/v6.13/arch/sparc/kernel/wuf.S#L204) |
| the GPU? | This commit, by the esteemed [Alyssa Rosenzweig](https://rosenzweig.io/), was the only commit using female pronouns which I could attribute to a [woman](https://rosenzweig.io/blog/growing-up-alyssa.html). [[commit]](https://github.com/torvalds/linux/blame/v6.13/drivers/gpu/drm/panfrost/panfrost_issues.h#L113) |

### "woman"/"women"

The only reference to a ["woman"](https://livegrep.com/search/linux?q=%5Cb%5CW*woman%5CW*%5Cb&fold_case=auto&regex=true&context=true) in the kernel is in [a eulogy](https://github.com/torvalds/linux/blob/ffd294d346d185b70e28b1a28abe367bbfe53c04/lib/decompress_bunzip2.c#L23-L39)
```
I would ask that anyone benefiting from this work, especially those
using it in commercial products, consider making a donation to my local
non-profit hospice organization in the name of the woman I loved, who
passed away Feb. 12, 2003.
```

And the only usage of ["women"](https://livegrep.com/search/linux?q=%5Cb%5CW*women%5CW*%5Cb&fold_case=auto&regex=true&context=true) is in [contribution guidelines documentation](https://github.com/torvalds/linux/blob/ffd294d346d185b70e28b1a28abe367bbfe53c04/Documentation/process/howto.rst?plain=1#L506).

## Swearing in Linux

This paper shows there is a correlation between [swear word usage and code quality](https://cme.h-its.org/exelixis/pubs/JanThesis.pdf). In unrelated news, there is a large, negative trend line for the [amount of swearing in Linux](https://www.vidarholen.net/contents/wordcount/#fuck*,shit*,damn*,idiot*,retard*) over the past ten years.

## Age

The kernel continues to evolve as new developers come in. The amount of contributors joining and staying on the Linux project [keeps](https://bitergia.com/blog/opensource/demographics-of-linux-kernel-developers-how-old-are-they/) [dropping](https://www.zdnet.com/article/graying-linux-developers-look-for-new-blood/).

For example, efforts to push Rust into Linux have been causing controversy. Eventually, Linus himself will have to step down. Being a maintainer is stressful, and even [maintainers are human](https://www.redox-os.org/news/open-source-mental-health/).

Further, contributions are done less than ever by open source hackers. Linux contributions are becoming more commercial, which means that contributors' incentives may not align with that of the Linux project as a whole. [Over 90%](https://www.linuxfoundation.org/blog/blog/jonathan-corbet-on-linux-kernel-contributions-community-and-core-needs) of contributors are being paid by their employer to submit patches. Nobody wants to pay to build the infrastructure to make Linux development better (ex: Coccinelle) or to write high quality documentation. These create barriers to the natural growth of the project among younger developers and other demographics.
