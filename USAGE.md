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
    <title><%= page[:title] %></title>
  </head>
  <body>
    <%= content %>
  </body>
</html>
```

The following are available in templates:

- `content` — page body
- `page[:title]`, `page[:lang]` etc. — front-matter values (including `lang` from site config; you can overwrite in the page front-matter)
- `site[:title]`, `site[:url]` etc. — site configuration
- `include 'head', key: value` — insert an include

### 5. Build

```bash
cd my-site
isola build
```

Output is generated in `_site/`.

### 6. Development Server

```bash
cd my-site
isola serve
```

Builds the site and starts a local development server. By default, the server listens on `http://127.0.0.1:4444`. You can change the host and port in `_config.yaml`:

```yaml
host: 127.0.0.1
port: 4444
```

The server watches for file changes and automatically rebuilds the site. HTML pages that contain a `</body>` tag are injected with a live-reload script, so the browser refreshes automatically after each rebuild. Live reload only works for HTML files with a `</body>` tag.

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

## Multi-Language Support

Isola supports building multi-language sites. Pages for the default language live at the site root, while other languages are placed in subdirectories named by language code.

### Configuration

Add `default_language` and `languages` to `_config.yaml`:

```yaml
default_language: ja
languages:
  ja:
    label: "日本語"
  en:
    label: "English"
    title: "My Site (EN)"
```

Each language entry can override any site-level configuration value. For example, `site[:title]` returns `"My Site (EN)"` when rendering English pages.

### Directory Structure

```
my-site/
├── _config.yaml
├── _layouts/
│   ├── default.html.erb       # Shared layout (used by all languages)
│   └── en/default.html.erb    # English-specific layout override
├── _includes/
│   ├── head.html.erb          # Shared include
│   └── en/head.html.erb       # English-specific include override
├── index.md                   # Default language (ja) page
└── en/index.md                # English page
```

- **Pages**: Default-language pages live at the root. Other languages go in `<lang>/` subdirectories (e.g. `en/index.md`).
- **Layouts and includes**: Place language-specific overrides under `_layouts/<lang>/` or `_includes/<lang>/`. If a language-specific version is not found, the shared version is used as a fallback.

### Template Variables

In addition to the standard template variables, multi-language sites provide:

- `page[:lang]` — the language of the current page (e.g. `:ja`, `:en`)
- `page[:translations]` — a hash of `{lang: output_path}` for all available translations of the current page

#### Generating hreflang Links

Use `page[:translations]` to output alternate-language links:

```erb
<% page[:translations].each do |lang, url| %>
  <link rel="alternate" hreflang="<%= lang %>" href="<%= url %>">
<% end %>
```

### Output

The output mirrors the source structure:

| Source | Output |
|---|---|
| `index.md` | `_site/index.html` |
| `en/index.md` | `_site/en/index.html` |
