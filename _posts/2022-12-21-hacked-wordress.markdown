---
layout:     post
title:      "Hacked Wordpress"
subtitle:   "How I recovered from a hacked wordpress"
date:       2022-12-21 10:00:00
author:     "Mattias Gees"
background: "/img/wordpress.jpeg"
---

# Hacked Wordpress

In my free time, I am helping a non-profit by hosting their simple WordPress website. The website is fairly well visited during certain times of year but in general, requires very little maintenance from my side. This WordPress website runs on a dedicated VM on Digital Ocean and has been running hassle-free for the last couple of years. At regular intervals, I update (and reboot) the Ubunutu OS and at the same time, I try to stay on top of making sure that WordPress and its plugins are up to date.

Recently an update of the theme went unnoticed and as always there was a vulnerability in the theme that got exploited. The hacked WordPress started redirecting visitors to the website to a shady website, this only happened on the initial visit. I had to start digging into the problem and recover from it.

This isn't the first time I had to deal with hacked WordPress websites as I have a history of working in Managed Hosting where this is a regular occurrence. Before starting to try to recover from a hacked website, make sure you take a website of your files and database. In case you delete too much, make sure you can always restore from your backup.

## Sucuri Security

I started digging into some dedicated free tooling that exists for WordPress to help pinpoint WordPress files that have been modified and shouldn't be. There are a lot of tools out there, but I am very happy with the base functionality that Sucuri Security offers which points out modified files, URLs with malicious code and many other useful data.

![Sucuri Security](/img/sucuri_security.png "Sucuri Security")

The first thing I did was restore and delete the files that Sucuri Security highlighted as problems. After that, I noticed that one of the loaded Javascript files came from a plugin which wasn't supposed to be installed and I just removed the whole folder. During this time I kept checking that the site was still functioning as expected and didn't make the situation worse.

We were not out of the woods yet, we cleaned the filesystem, but the redirects were still happening and Securi Security was still detecting malicious payloads on certain URLs.

## Database

I started digging into the database and could see in the `wp_options` table different rows with malicious content in them. I was able to identify this by running the following SQL query:

```
SELECT * FROM atni.wp_options WHERE option_value like '%eval(String%';
```

This revealed a few wp_options where malicious code has been injected, after investigating my Wordpress settings more, I was able to find multiple places in my theme where valid users wanted to inject custom code to place ads or other custom code. This was being exploited and deleted multiple malicious entries. By rerunning the above SQL query, I was able to validate I got all the entries. The Securi Security plugin was able to validate this as well.

## Monitoring

I keep monitoring the situation with Securi Security to make sure I was able to clean up everything. Besides that, I also made sure to rotate all the database passwords and other secrets. Luckily this website doesn't host any sensitive data. To learn more about securing your WordPress install read the [hardening guide](https://wordpress.org/support/article/hardening-wordpress/) on the official WordPress website.
