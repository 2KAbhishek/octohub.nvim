<div align = "center">

<h1><a href="https://github.com/2kabhishek/octostats.nvim">octostats.nvim</a></h1>

<a href="https://github.com/2KAbhishek/octostats.nvim/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/octostats.nvim?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/octostats.nvim/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/octostats.nvim?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/octostats.nvim/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/octostats.nvim?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/octostats.nvim/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/octostats.nvim?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/octostats.nvim/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/octostats.nvim?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/octostats.nvim/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/octostats.nvim?style=flat&color=e06c75&label="> </a>

<h3>All Your GitHub Stats in Neovim 🐙📊</h3>

<figure>
  <img src="doc/images/screenshot.png" alt="octostats.nvim in action">
  <br/>
  <figcaption>octostats.nvim in action</figcaption>
</figure>

</div>

`octostats.nvim` is a Neovim plugin that brings your GitHub profile and contribution stats directly into Neovim.
With this plugin, you can view activity events, contributions, repository stats, and more — all from within your editor.

## ✨ Features

- Display GitHub profile stats including recent activity and contributions for any user.
- View repository statistics, such as top languages and contribution metrics.
- Customizable display options for activity, contribution graphs, and repo stats.

## ⚡ Setup

### ⚙️ Requirements

- Latest version of `neovim`
- Authenticated `gh` CLI

### 💻 Installation

```lua
-- Lazy
{
    '2kabhishek/octostats.nvim',
    cmd = { 'OctoStats', 'OctoProfile', 'OctoActivityStats', 'OctoContributionStats' },
    keys = { '<leader>gos', '<leader>gop', '<leader>goa', '<leader>gog' },
    dependencies = {
        '2kabhishek/utils.nvim',
        '2kabhishek/octorepos.nvim', -- Optional, if you want to view repo stats
    },
    opts = {},
},
```

## 🚀 Usage

### Configuration

`octostats.nvim` can be configured using the following options:

```lua
require('octostats').setup({
    max_contributions = 50,                -- Max number of contributions per day to use for icon selection
    event_count = 5,                       -- Number of activity events to show
    contrib_icons = { '', '', '', '', '', '', '' }, -- Icons for different contribution levels
    window_width = 90,                     -- Width in percentage of the window to display stats
    window_height = 60,                    -- Height in percentage of the window to display stats
    show_recent_activity = true,           -- Show recent activity in the stats window
    show_contributions = true,             -- Show contributions in the stats window
    show_repo_stats = true,                -- Show repository stats in the stats window
    events_cache_timeout = 60 * 30,        -- Cache timeout for activity events (30 minutes)
    contributions_cache_timeout = 3600 * 4, -- Cache timeout for contributions data (4 hours)
    user_cache_timeout = 3600 * 24 * 7,    -- Cache timeout for user data (7 days)
    add_default_keybindings = true,        -- Add default keybindings for the plugin
})
```

### Commands

`octostats.nvim` introduces the following commands to interact with your GitHub data:

- `OctoStats`: Displays all stats (activity, contributions, repository data).
  - Ex: `:OctoStats theprimeagen` shows stats for `theprimeagen`.
- `OctoActivityStats [username] [count:N]`: Displays recent activity for a user, with an optional count.
  - Ex: `:OctoActivityStats count:20` shows the last 20 activity events for the current user.
- `OctoContributionStats [username]`: Displays contribution stats for a user.
- `OctoProfile [username]`: Opens the GitHub profile of a user in your browser.

If the `user` parameter is not provided, the plugin will use the current authenticated username from `gh`

### Keybindings

By default, these are the configured keybindings.

| Keybinding    | Command                           | Description         |
| ------------- | --------------------------------- | ------------------- |
| `<leader>gos` | `:OctoStats<CR>`                  | All Stats           |
| `<leader>goa` | `:OctoActivityStats count:20<CR>` | Activity Stats      |
| `<leader>gog` | `:OctoContributionStats<CR>`      | Contribution Graph  |
| `<leader>gop` | `:OctoProfile<CR>`                | Open GitHub Profile |

I recommend customizing these keybindings based on your preferences.

### Help

Run `:help octostats` to view these docs in Neovim.

## 🏗️ What's Next

- [ ] Adding tests for the plugin

## ⛅ Behind The Code

### 🌈 Inspiration

`octostats.nvim` was inspired by the need to quickly access GitHub data without leaving the Neovim environment.

### 💡 Challenges/Learnings

- Integrating GitHub's API efficiently while minimizing API call limits was challenging. I learned how to implement caching effectively in Neovim.

### 🔍 More Info

- [octorepos.nvim](https://github.com/2kabhishek/octorepos.nevim) — All your GitHub repositories in Neovim
- [nerdy.nvim](https://github.com/2kabhishek/nerdy.nevim) — Find nerd glyphs easily
- [tdo.nvim](https://github.com/2KAbhishek/tdo.nvim) — Fast and simple notes in Neovim
- [termim.nvim](https://github.com/2kabhishek/termim,nvim) — Neovim terminal improved

<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

<a href="https://github.com/2KAbhishek/octostats.nvim">Source</a>
| <a href="https://2kabhishek.github.io/blog" target="_blank">Blog </a>
| <a href="https://twitter.com/2kabhishek" target="_blank">Twitter </a>
| <a href="https://linkedin.com/in/2kabhishek" target="_blank">LinkedIn </a>
| <a href="https://2kabhishek.github.io/links" target="_blank">More Links </a>
| <a href="https://2kabhishek.github.io/projects" target="_blank">Other Projects </a>

</div>
