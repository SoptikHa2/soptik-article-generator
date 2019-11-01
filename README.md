# Soptik
*The ultimate static HTML webpage generator.*

## Instalation
Clone this git repository. Run `compile.sh`. Make sure to have installed `gawk` (not just `awk`) and `bc`.

## Usage

```
./compile.sh <directory_with_md_files> [output_directory] [--no-tags]
```

## What is this?

Soptik is yet another simple webpage generator, built to learn awk.
This generator uses standart tools found on every Linux machine, without
the need to download everything else. It's just \*sh script and awk (requires 'gawk').

And it's pretty fast as well. On my computer, 23 files, with total of 22975 words (or 192K) were processed in under a second (0,57s)!

You can see live example at [soptik.tech](https://soptik.tech/articles).

# Source files structure

Everything is compiled from markdown files, which are anotated to help awk with processing.
Supported markdown file looks like this:

````markdown
[ building-soptik-page-generator, 2019-08-09, soptik, markdown, awk ]
How I built the Soptik page generator
This is summary paragraph, or *perex*. How I built the Soptik page generator, what I used and how it works.

Everything began in *2019*, when I decided to build **the best** editor out there. With help
from [this wonderful guide](https://developer.ibm.com/tutorials/l-awk1/) (beware, there are
other parts, just not linked - edit URL to get there), I was able to make it work!

# Code

```
# No syntax highlighting yet :-(
for file in *".md" {
	do-magic "$file"
}
```

# Quotes

Do you know this quote?

## Quote about quotes

> Quotes are amazing.
Quote lover

````

First line has to contain metadata, enclosed inside `[ ... ]` (optional, but recommended)
and delimited by `,`. All whitespaces are ignored. First field is URL and name of resulting
.html file. Second field is date, and the
rest are tags. *Soptik* generates list of tags, so tags are clickable and one can filter by them.
Second line is heading, which gets formated differently than anything else in the article.
Third line (which can be empty) is summary paragraph, which is shown at index page.

Please note that the order in which the articles are processed (the previous-next links and the index file content) is the default alphabetical one, but reversed. This way, if you name article files with datetime (such as `2019-09-16.md`), you'll get them sorted at the index page, from the newest one to the oldest one. If you want different html filename (and url), specify it in metadata. Only files with `.md` extension are processed.

# Support
Firefox gets first-class support and is the primary browser I test in. However, output of this program is valid HTML with minimum JS (only used for search via tags), so it should work in every browser - including lynx. 

# Special files and navigation
The first thing Soptik does is copying preset files into output directory. You can provide your own files, which will override the default ones. You can see default files in `/resources`.

- `head.html` is basic HTML <head>, it contains metadata and link to `base.css`.
- `head.index.html` is contents of `index.html` before article list - for example big heading with your site name.
- `tail.index.html` is contents of `index.html` after article list - for example link to tag list or the annoying cookies stripe.
- `tail.html` is essentially just HTML that closes `body` and `html` tags, but you can put your favorite cookies notification here instead.
- `base.css` defines dimensions and position of various elements on site, and imports by default `base-dark.css`, which provides colors. You can edit `base.css` to instead link to `base-light.css` for white theme, or make your own one.
- `tags.html` and `head.tags.html` is tag list. It's used to display list of tags and filter articles based on selected tag.

Please note that there is a special javascript file: `tags.js`. You can override it, but please don't, unless you know what you're doing. This file allows filtering tags. So when you click on tag name, it displays you only articles with specified tag name, and not all of them. This is the only place where we use javascript by default, and it's unfortunately required for the correct functionality.

You can always turn tags off with option `--no-tags`.
