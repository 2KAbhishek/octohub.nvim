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

<h3>All Your GitHub Repos in Neovim 🐙📂</h3>

<figure>
  <img src="doc/images/screenshot.png" alt="octorepos.nvim in action">
  <br/>
  <figcaption>octorepos.nvim in action</figcaption>
</figure>

</div>

`octorepos.nvim` is a Neovim plugin that lets you manage and explore your GitHub repositories directly from within Neovim.
With this plugin, you can view, filter, and sort repositories, all without leaving your editor.

## ✨ Features

- Quickly list and open any GitHub repositories, yours or others, directly from Neovim.
- Sort repositories by stars, forks, and other criteria, with support for filtering by type (forks, private, etc.).
- View all sorts of repository details at a glance, including issues, stars, forks, and more.
- Seamless integration with Telescope for fuzzy searching and quick access to repositories.

## ⚡ Setup

### ⚙️ Requirements

- Latest version of `neovim`
- Authenticated `gh` CLI
- [tmux-tea](https://github.com/2kabhishek/tmux-tea) (optional) if you want to use individual sessions for each repository

### 💻 Installation

```lua
-- Lazy nvim
{
    '2kabhishek/octorepos.nvim',
    cmd = { 'OctoRepos', 'OctoRepo', 'OctoRepoStats', 'OctoRepoWeb' },
    keys = {
        '<leader>goo',
        '<leader>gof',
        '<leader>goi',
        '<leader>goh',
        '<leader>gop',
        '<leader>goc',
        '<leader>gor',
        '<leader>gow',
        '<leader>gon',
    },
    dependencies = { '2kabhishek/utils.nvim', 'nvim-telescope/telescope.nvim' },
    opts = {},
},
```

## 🚀 Usage

### Configuration

octorepos.nvim can be configured using the following options:

```lua
local octorepos = require('octorepos')

octorepos.setup({
    top_lang_count = 5,               -- Number of top languages to display in stats
    per_user_dir = true,              -- Create a directory for each user
    projects_dir = '~/Projects/',     -- Directory where repositories are cloned
    sort_repos_by = '',               -- Sort repositories by various parameters
    repo_type = '',                   -- Type of repositories to display
    repo_cache_timeout = 3600 * 24,   -- Time in seconds to cache repositories
    username_cache_timeout = 3600 * 24 * 7,  -- Time in seconds to cache username
    add_default_keybindings = true,   -- Add default keybindings for the plugin
})
```

### Commands

`octorepos.nvim` adds the following commands:

- `:OctoRepos [user] [sort:<criteria>] [type:<repo_type>]`: Displays the repositories for a given user, sorted by the specified criteria.
  - Available sorting criteria: `stars`, `forks`, `updated`, `created`, `pushed`, `name`, `size`, `watchers`, `issues`
  - Available repository types: `private`, `fork`, `template`, `archived`
  - Ex: `:OctoRepos 2kabhishek sort:updated type:fork` - Display all forked repositories for the user `2kabhishek`, sorted by the last update.
- `:OctoRepo <repo_name> [user]`: Opens a specified repository, optionally by a user.
  - Ex: `:OctoRepo octorepos.nvim` - Clone the repository `octorepos.nvim` from the current user.
  - Ex: `:OctoRepo 2kabhishek octorepos.nvim` - Clone the repository `octorepos.nvim` from the user `2kabhishek`.
- `:OctoRepoStats [user]`: Displays statistics for the repositories of a given user.
  - Ex: `:OctoRepoStats 2kabhishek` - Display statistics for the repositories of the user `2kabhishek`.
- `:OctoRepoWeb` - Opens the current repository in the browser.

If the `user` parameter is not provided, the plugin will use the current authenticated username from `gh`

### Keybindings

By default, these are the configured keybindings.

| Keybinding    | Command                       | Description            |
| ------------- | ----------------------------- | ---------------------- |
| `<leader>goo` | `:OctoRepos<CR>`              | All Repos              |
| `<leader>gof` | `:OctoRepos sort:stars<CR>`   | Top Starred Repos      |
| `<leader>goi` | `:OctoRepos sort:issues<CR>`  | Repos With Issues      |
| `<leader>goh` | `:OctoRepos sort:updated<CR>` | Recently Updated Repos |
| `<leader>gop` | `:OctoRepos type:private<CR>` | Private Repos          |
| `<leader>goc` | `:OctoRepos type:fork<CR>`    | Forked Repos           |
| `<leader>gor` | `:OctoRepo<CR>`               | Open / Clone Repo      |
| `<leader>gow` | `:OctoRepoWeb<CR>`            | Open Repo in Browser   |
| `<leader>gon` | `:OctoRepoStats<CR>`          | Repo Stats             |

I recommend customizing these keybindings based on your preferences.

### Telescope Integration

`octorepos.nvim` adds a Telescope extension for easy searching and browsing of repositories.

To use this extension, add the following code to your configuration:

```lua
local telescope = require('telescope')

telescope.load_extension('repos')
```

You can now use the following command to show repositories in Telescope: `:Telescope repos`

### Help

Run `:help octorepos` to view these docs in Neovim.

## 🏗️ What's Next

- [ ] Add more tests
- You tell me!

## ⛅ Behind The Code

### 🌈 Inspiration

I wanted to be able to manage my GitHub repositories directly from Neovim, without having to switch to a browser or terminal.

### 💡 Challenges/Learnings

- The main challenges were figuring out how to interact with the GitHub API and how to display the data in a user-friendly way.
- I learned about Lua's powerful features for handling data structures and Neovim's extensibility.

### 🔍 More Info

- [octostats.nvim](https://github.com/2kabhishek/octostats.nevim) — All your GitHub stats in Neovim
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
