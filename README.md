<div align = "center">

<h1><a href="https://github.com/2kabhishek/template.nvim">template.nvim</a></h1>

<a href="https://github.com/2KAbhishek/template.nvim/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/template.nvim?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/template.nvim/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/template.nvim?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/template.nvim/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/template.nvim?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/template.nvim/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/template.nvim?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/template.nvim/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/template.nvim?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/template.nvim/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/template.nvim?style=flat&color=e06c75&label="> </a>

<h3>Ready to go Neovim template 🏗️✈️</h3>

<figure>
  <img src="doc/images/screenshot.png" alt="template.nvim in action">
  <br/>
  <figcaption>template.nvim in action</figcaption>
</figure>

</div>

template.nvim is a neovim plugin that allows neovim users to `<action>`.

## ✨ Features

- Includes a ready to go neovim plugin template
- Comes with a lint and test CI action
- Includes a Github action to auto generate vimdocs
- Comes with a ready to go README template
- Works with [mkrepo](https://github.com/2kabhishek/mkrepo)

## ⚡ Setup

### ⚙️ Requirements

- Latest version of `neovim`

### 💻 Installation

```lua
-- Lazy
{
    '2kabhishek/template.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim'
    },
    cmd = 'TemplateHello',
},

-- Packer
use '2kabhishek/template.nvim'

```

## 🚀 Usage

1. Fork the `template.nvim` repo
2. Update the plugin name, file names etc, change `template` to `your-plugin-name`
3. Add the code required for your plugin,

   - Main logic, config options for the plugin code goes into [lua/template](./lua/template.lua)
   - Supporting code goes into [lua/modules](./lua/template/) if needed
   - For adding commands and keybindngs use [plugin/template](./plugin/template.lua)
4. Add test code to the [tests](./tests/template) directory
5. Update the README
6. Tweak the [docs action](./.github/workflows/docs.yml) file to reflect your username, commit message and plugin name

   - Generating vimdocs needs write access to actions (repo settings > actions > general > workflow permissions)

### Configuration

template.nvim can be configured using the following options:

```lua
template.setup({
    name = 'template.nvim', -- Name to be greeted, 'World' by default
})
```

### Commands

`template.nvim` adds the following commands:

- `TemplateHello`: Shows a hello message with the confugred name.

### Keybindings

It is recommended to use:

- `<leader>th,` for `TemplateHello`

> NOTE: By default there are no configured keybindings.

### Help

Run `:help nerdy` for more details.

## 🏗️ What's Next

Planning to add `<feature/module>`.

### ✅ To-Do

- [x] Setup repo
- [ ] Think real hard
- [ ] Start typing

## ⛅ Behind The Code

### 🌈 Inspiration

template.nvim was inspired by [nvim-plugin-template](https://github.com/ellisonleao/nvim-plugin-template), I added some changes on top to make setting up a new plugin faster.

### 💡 Challenges/Learnings

- The main challenges were `<issue/difficulty>`
- I learned about `<learning/accomplishment>`

### 🧰 Tooling

- [dots2k](https://github.com/2kabhishek/dots2k) — Dev Environment
- [nvim2k](https://github.com/2kabhishek/nvim2k) — Personalized Editor
- [sway2k](https://github.com/2kabhishek/sway2k) — Desktop Environment
- [qute2k](https://github.com/2kabhishek/qute2k) — Personalized Browser

### 🔍 More Info

- [nerdy.nvim](https://github.com/2kabhishek/nerdy.nevim) — Find nerd glyphs easily
- [tdo.nvim](https://github.com/2KAbhishek/tdo.nvim) — Fast and simple notes in Neovim
- [termim.nvim](https://github.com/2kabhishek/termim,nvim) — Neovim terminal improved

<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

<a href="https://github.com/2KAbhishek/template.nvim">Source</a>
| <a href="https://2kabhishek.github.io/blog" target="_blank">Blog </a>
| <a href="https://twitter.com/2kabhishek" target="_blank">Twitter </a>
| <a href="https://linkedin.com/in/2kabhishek" target="_blank">LinkedIn </a>
| <a href="https://2kabhishek.github.io/links" target="_blank">More Links </a>
| <a href="https://2kabhishek.github.io/projects" target="_blank">Other Projects </a>

</div>
