# Soptik
*The ultimate static HTML webpage generate.*

Soptik is yet another simple webpage generator, build to learn awk.
This generator uses standart tools found on every Linux machine, without
the need to download everything else. Just \*sh scripts and awk (requires 'gawk').

Everything is compiled from markdown files, which are anotated to help awk with processing.
Supported markdown file looks like this:

````markdown
[ building-soptik-page-generator, 2019-08-09, soptik, markdown, awk ]
How I built the Soptik page generator

Everything began in *2019*, when I decided to build **the best** editor out there. With help
from [this wonderful guide](https://developer.ibm.com/tutorials/l-awk1/) (beware, there are
other parts, just not linked - edit URL to get there), I was able to make it work!

# Code

```
# No syntax highlighting yet :-(
for file in "*.md" {
	do-magic "$file"
}
```

# Quotes

Do you know this quote? I really like it!

## My favorite quote

> Don't flip the web pyramid!
- Jan Hus

````

First line has to contain metadata, enclosed inside `[ ... ]` (optional, but recommended)
and delimited by `,`. All whitespaces are ignored. First field is URL and name of resulting
.html file. It's recommended to be the same (or at least simmilar to) original .md filename,
so you won't get confused when you want to fix the typo. Second field is date, and the
rest are tags. *Soptik* generates list of tags, so tags are clickable and one can filter by them.
Second line is heading, which gets formated differently than anything else in the article.

## Special files and navigation
*Soptik* generates few things on it's own, in order to make the whole thing less PIA to set up.
One thing is HTML \<head\>. It contains just basics, such as responsivity settings, title,
utf-8 encoding, and sometimes a javascript file. And all .js and .css files provided by user.

Another part is of cours tail, that gets appended to all generated files. It contains navigation
(prev/next article) and link to index file.

Index file is generated automatically as well, and contains list of articles ordered by date.

Tag index file can be reached by clicking any tag. It contains list of tags, sorted by
their frequency. If user has enabled javascript, posts can be filtered by clicking on individual tags.

User-provided files `index.html`, `head.html` and `tail.html` have higher priority. 
Tag navigation can be turned off by passing `--no-tags` option when compiling.

An example is in `web-source` and `web-output` folders.
