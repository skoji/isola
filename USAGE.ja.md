# Isola 使い方ガイド

ERBを使ったシンプルなStatic Site Generator（SSG）です。

## インストール

```bash
gem install isola
```

## 基本的な使い方

### 1. サイトディレクトリを作る

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

### 2. 設定ファイル（`_config.yaml`）

```yaml
url: https://example.com
title: My Site
destination: _site
default_language: ja
excludes:
  - README.md
```

すべて省略可能です。`destination`のデフォルトは`_site`です。

### 3. ページを書く

Markdownファイルの先頭にYAML front-matterを記述します。

```markdown
---
layout: default
title: トップページ
---

本文をMarkdownで書きます。
```

拡張子`.md.erb`にすると、Markdown内でERBが使えます。

### 4. レイアウトを作る

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

テンプレート内では以下が使えます:

- `content` — ページ本文
- `page.title` など — front-matterの値
- `site.title`, `site.url`, `site.lang` — サイト設定
- `include 'head', key: value` — インクルードの挿入

### 5. ビルド

```bash
cd my-site
isola build
```

`_site/`に生成されます。

## ファイルの処理

Isolaが処理するテンプレートエンジンは現在 **ERB**（`.erb`）と **Markdown**（`.md`, `.markdown`, `.mkd`）のみです。

拡張子の末尾から順に処理します。例えば `page.md.erb` の場合、まずERBを処理し、次にMarkdownを処理します。

処理後にまだ拡張子が残っている場合はそのまま使います。残っていない場合は `.html` が付与されます。

| ソース | 処理 | 出力 |
|---|---|---|
| `page.md` | Markdown → HTML | `page.html` |
| `page.md.erb` | ERB → Markdown → HTML | `page.html` |
| `style.css.erb` | ERB | `style.css` |
| `index.html.erb` | ERB | `index.html` |
| `*.css`, `*.js` など | なし | そのままコピー |

`_`や`.`で始まるファイル・ディレクトリは自動的に除外されます（`_layouts/`と`_includes/`を除く）。
