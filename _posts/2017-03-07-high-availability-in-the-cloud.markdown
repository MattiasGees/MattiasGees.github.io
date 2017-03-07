---
layout:     post
title:      "High Availability in the cloud"
subtitle:   "High Availability in the cloud"
date:       2017-03-07 16:30:00
author:     "Mattias Gees"
header-img: "img/standard.jpg "
---

Last week there was a lot of fuss about the [s3 outage](https://aws.amazon.com/message/41926/) on Amazon AWS. Immediately people started tweeting that you could better host your infrastructure in your own data center where you are in  control.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">I&#39;m not gloating over S3, I just find it interesting that so many would dump so many of their eggs in one basket.</p>&mdash; DesuExMachina🌱 (@da_667) <a href="https://twitter.com/da_667/status/836736111737208834">March 1, 2017</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I don’t want to start a discussion on public vs private cloud but rather about single region vs multi region or single vs multiple data center when you maintain your own infrastructure. When does it make sense for a company to think about multiple regions?

During the outage I tweeted about the downtime and I got some response to go multi-region and multi-cloud for your application.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Every time a cloud provider fails “You should host it on-premise”. Every time something on-premise fails ”You should host it in the cloud”!</p>&mdash; Mattias Gees (@MattiasGees) <a href="https://twitter.com/MattiasGees/status/836695430733914112">February 28, 2017</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

My reply was that this needs to be a business decision rather than a technical decision. We as technical people like to build infrastructure in the best and most reliable way. This implies investing a lot of time and energy in adapting your application and infrastructure to multi region. Time that is most of the time better invested in improving your application. You better release a new feature from which your customer benefits immediately.

So when does it pay-off to go multi region? It depends on the following factors.
Will you lose more money when your application is down compared  to set-up / maintain and test your multi region setup?
You lose credibility with your customers when you go down.
Do you have a high SLA requirement?
Some other specific requirements?

To known if you match one of those criterias is really hard. I would recommend to start using multi availability zones in AWS first. If and only if there is a huge motivation, go the multi region way.
