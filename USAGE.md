# Isola Usage Guide

A simple Static Site Generator (SSG) using ERB.

## Installation

```bash
gem install isola
```

## Basic Usage

### 1. Create a site directory

```
my-site/
├── _config.yaml
├── _layouts/
│   └── default.html.erb
├── _includes/
│   └── head.html.erb
├── index.md
└── css/
    └── main.css
```

### 2. Configuration (`_config.yaml`)

```yaml
url: https://example.com
title: My Site
destination: _site
default_language: en
excludes:
  - README.md
```

All fields are optional. The default `destination` is `_site`.

### 3. Write pages

Add YAML front-matter at the top of your Markdown files.

```markdown
---
layout: default
title: Top Page
---

Write your content in Markdown.
```

Use the `.md.erb` extension to enable ERB inside Markdown.

### 4. Create layouts

`_layouts/default.html.erb`:

```erb
<html>
  <head>
    <title><%= page.title %></title>
  </head>
  <body>
    <%= content %>
  </body>
</html>
```

The following are available in templates:

- `content` — page body
- `page.title` etc. — front-matter values
- `site.title`, `site.url`, `site.lang` — site configuration
- `include 'head', key: value` — insert an include

### 5. Build

```bash
cd my-site
isola build
```

Output is generated in `_site/`.

## File Processing

Isola currently supports only **ERB** (`.erb`) and **Markdown** (`.md`, `.markdown`, `.mkd`) as template engines.

Extensions are processed from right to left. For example, `page.md.erb` is first processed as ERB, then as Markdown.

If an extension remains after processing, it is kept as-is. If no extension remains, `.html` is used.

| Source | Processing | Output |
|---|---|---|
| `page.md` | Markdown → HTML | `page.html` |
| `page.md.erb` | ERB → Markdown → HTML | `page.html` |
| `style.css.erb` | ERB | `style.css` |
| `index.html.erb` | ERB | `index.html` |
| `*.css`, `*.js` etc. | None | Copied as-is |

Files and directories starting with `_` or `.` are excluded automatically (except `_layouts/` and `_includes/`).
