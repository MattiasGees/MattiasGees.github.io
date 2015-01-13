---
layout:     post
title:      "Pelican with AsciiDoc"
subtitle:   "I decided to setup my own blog with Pelican and AsciiDoc."
date:       2014-01-26 12:00:00
author:     "Mattias Gees"
header-img: "img/pelican.jpg"
---

I decided to setup my own blog with Pelican and AsciiDoc. Pelican works with readers to convert your markup language to html. Standard support is provided for reStructuredText, Markdown and AsciiDoc. The problem is that AsciiDoc doesn't generate out of the box. This is because you need a Python library for AsciiDoc called [AsciiDocAPI](http://www.methods.co.nz/asciidoc/asciidocapi.html).

The library is distributed with the [original AsciiDoc source](http://sourceforge.net/projects/asciidoc/). You need to place the asciidocapi.py in the pelican root folder. In my case this was /Library/Python/2.7/site-packages/pelican.

After moving the document in the root folder, my AsciiDoc documents were generating to HTML. A second problem rised: the HTML files that were generated contained the word None (eg pelican-blog-None.html). After some research I found a [pull request](http://sourceforge.net/projects/asciidoc/) with a solution. I needed to add the following line to my pelican config.

```python
ASCIIDOC_OPTIONS = ["-a lang=en"]
```

If you want code highlighting then you need to pass an extra argument to the ASCIIDOC_OPTIONS variable.

```python
ASCIIDOC_OPTIONS = ["-a source-highlighter=pygments","-a lang=en"]
```

Afterwards, my blog was generating nicely with code highlighting and I was ready to post my first blog post.


**UPDATE:** I moved to Jekyll and Markdown now, but this code still works.
