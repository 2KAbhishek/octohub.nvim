<div align = "center">

<h1><a href="https://github.com/2kabhishek/octorepos.nvim">octorepos.nvim</a></h1>

<a href="https://github.com/2KAbhishek/octorepos.nvim/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/octorepos.nvim?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/octorepos.nvim/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/octorepos.nvim?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/octorepos.nvim/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/octorepos.nvim?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/octorepos.nvim/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/octorepos.nvim?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/octorepos.nvim/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/octorepos.nvim?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/octorepos.nvim/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/octorepos.nvim?style=flat&color=e06c75&label="> </a>

<h3>Manage Your GitHub Repositories with Ease 🐙</h3>

<figure>
  <img src="doc/images/screenshot.png" alt="octorepos.nvim in action">
  <br/>
  <figcaption>octorepos.nvim in action</figcaption>
</figure>

</div>

`octorepos.nvim` is a Neovim plugin that allows users to manage and display their GitHub repositories efficiently.

## ✨ Features

- Displays repositories based on user input.
- Supports sorting and filtering by repository type.
- Caches repository data for faster access.
- Provides integration with Telescope for searching repositories.

## ⚡ Setup

### ⚙️ Requirements

- Latest version of `neovim`

### 💻 Installation

````lua
-- Lazy
{
    '2kabhishek/octorepos.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim'  -- Required for Telescope integration
    },
    cmd = { 'OctoRepos', 'OctoRepo', 'OctoRepoStats' },
},

-- Packer
use {
    '2kabhishek/octorepos.nvim',
    requires = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
}

## 🚀 Usage

### Configuration

octorepos.nvim can be configured using the following options:

```lua
local octorepos = require('octorepos')

octorepos.setup({
    top_lang_count = 5,               -- Number of top languages to display
    per_user_dir = true,              -- Create a directory for each user
    projects_dir = '~/Projects/GitHub/',  -- Directory where repositories are cloned
    sort_repos_by = '',               -- Sort repositories by various parameters
    repo_type = '',                   -- Type of repositories to display
    repo_cache_timeout = 3600 * 24,   -- Time in seconds to cache repositories
    username_cache_timeout = 3600 * 24 * 7,  -- Time in seconds to cache username
})
````

### Commands

`octorepos.nvim` adds the following commands:

- `:OctoRepos [user] [sort:<criteria>] [type:<repo_type>]`: Displays the repositories for a given user, sorted by the specified criteria.
- `:OctoRepo <repo_name> [user]`: Opens a specified repository, optionally by a user.
- `:OctoRepoStats [repo_name]`: Displays statistics for a specified repository.

### Keybindings

It is recommended to use:

- `<leader>go` for `:OctoRepos`
- `<leader>gO` for `:OctoRepo`
- `<leader>gn` for `:OctoRepoStats`

> NOTE: By default, there are no configured keybindings.

### Help

Run `:help octorepos` for more details.

## 🏗️ What's Next

Planning to add support for advanced filtering options and repository contributions tracking.

### ✅ To-Do

- [ ] Add more tests
- [ ] Enhance documentation

## ⛅ Behind The Code

### 🌈 Inspiration

`octorepos.nvim` was inspired by various GitHub management tools and Neovim plugin structures, focusing on usability and performance.

### 💡 Challenges/Learnings

- The main challenges were managing API rate limits and caching efficiently.
- I learned about Lua's powerful features for handling data structures and Neovim's extensibility.

### 🔍 More Info

- [nerdy.nvim](https://github.com/2kabhishek/nerdy.nvim) — Find nerd glyphs easily
- [tdo.nvim](https://github.com/2kabhishek/tdo.nvim) — Fast and simple notes in Neovim
- [termim.nvim](https://github.com/2kabhishek/termim.nvim) — Neovim terminal improved

<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

<a href="https://github.com/2kabhishek/octorepos.nvim">Source</a>
| <a href="https://2kabhishek.github.io/blog" target="_blank">Blog </a>
| <a href="https://twitter.com/2kabhishek" target="_blank">Twitter </a>
| <a href="https://linkedin.com/in/2kabhishek" target="_blank">LinkedIn </a>
| <a href="https://2kabhishek.github.io/links" target="_blank">More Links </a>
| <a href="https://2kabhishek.github.io/projects" target="_blank">Other Projects </a>

</div>
