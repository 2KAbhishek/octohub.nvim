<div align = "center">

<h1><a href="https://github.com/2kabhishek/octohub.nvim">octohub.nvim</a></h1>

<a href="https://github.com/2KAbhishek/octohub.nvim/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/octohub.nvim?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/octohub.nvim/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/octohub.nvim?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/octohub.nvim/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/octohub.nvim?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/octohub.nvim/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/octohub.nvim?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/octohub.nvim/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/octohub.nvim?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/octohub.nvim/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/octohub.nvim?style=flat&color=e06c75&label="> </a>

<h3>All Your GitHub repos and more in Neovim 🐙🛠️</h3>

<figure>
  <img src="doc/images/screenshot-repos.png" alt="octohub.nvim repo picker">
  <br/>
  <figcaption>octohub.nvim repo picker</figcaption>
</figure>

<figure>
  <img src="doc/images/screenshot-stats.png" alt="octohub.nvim stats window">
  <br/>
  <figcaption>octohub.nvim stats window</figcaption>
</figure>

</div>

**octohub.nvim** is a Neovim plugin for managing and exploring GitHub repositories directly within the editor. It lets you view, filter, and sort repositories, track activity, and access profile and contribution stats, all without leaving Neovim.

## ✨ Features

[Video walkthrough of features](https://youtu.be/Sebh2aFfFPg)

- Quickly list and open any GitHub repositories, yours or others, directly from Neovim.
- Sort repositories by stars, forks, and other criteria, with support for filtering by type (forks, private repos, etc.).
- View all sorts of repository details at a glance, including issues, stars, forks, and more.
- Seamless integration with pickers for fuzzy searching and quick access to repositories.
- Display GitHub profile stats including recent activity and contributions for any user.
- View repository statistics, such as top languages and contribution metrics.
- Customizable display options for activity, contribution graphs, and repo stats.

## ⚡ Setup

### ⚙️ Requirements

- [utils.nvim](https://github.com/2kabhishek/utls.nvim) for helper functions
- [pickme.nvim](https://github.com/2kabhishek/pickme.nvim) for picker support
- The GitHub CLI tool (`gh`)

- [tmux-tea](https://github.com/2kabhishek/tmux-tea) (optional) if you want to use individual sessions for each repository
  - Using `set -g @tea-default-command 'nvim'` is recommended

### 💻 Installation

```lua
-- Lazy nvim
{
    '2kabhishek/octohub.nvim',
    cmd = {
        'OctoRepos',
        'OctoReposByCreated',
        'OctoReposByForks',
        'OctoReposByIssues',
        'OctoReposByLanguages',
        'OctoReposByNames',
        'OctoReposByPushed',
        'OctoReposBySize',
        'OctoReposByStars',
        'OctoReposByUpdated',
        'OctoReposTypeArchived',
        'OctoReposTypeForked',
        'OctoReposTypePrivate',
        'OctoReposTypeStarred',
        'OctoReposTypeTemplate',
        'OctoRepo',
        'OctoStats',
        'OctoActivityStats',
        'OctoContributionStats',
        'OctoRepoStats',
        'OctoProfile',
        'OctoRepoWeb',
    },
    -- Change these if you do not want to use default keybindings
    keys = {
        '<leader>goa',
        '<leader>goA',
        '<leader>gob',
        '<leader>goc',
        '<leader>gof',
        '<leader>goF',
        '<leader>gog',
        '<leader>goi',
        '<leader>gol',
        '<leader>goo',
        '<leader>gop',
        '<leader>goP',
        '<leader>gor',
        '<leader>gos',
        '<leader>goS',
        '<leader>got',
        '<leader>goT',
        '<leader>gou',
        '<leader>goU',
        '<leader>gow',
    },
    dependencies = {
        '2kabhishek/utils.nvim',
        '2kabhishek/pickme.nvim',
    },
    -- Add your custom configs here, keep it blank for default configs (required)
    opts = {},
},
```

## 🚀 Usage

### Configuration

octohub.nvim can be configured using the following options:

```lua
local octohub = require('octohub')

octohub.setup({
    contribution_icons = { '', '', '', '', '', '', '' }, -- Icons for different contribution levels
    projects_dir = '~/Projects/',     -- Directory where repositories are cloned
    per_user_dir = true,              -- Create a directory for each user
    sort_repos_by = '',               -- Sort repositories by various parameters
    repo_type = '',                   -- Type of repositories to display
    max_contributions = 50,           -- Max number of contributions per day to use for icon selection
    top_lang_count = 5,               -- Number of top languages to display in stats
    event_count = 5,                  -- Number of activity events to show
    window_width = 90,                -- Width in percentage of the window to display stats
    window_height = 60,               -- Height in percentage of the window to display stats
    show_recent_activity = true,      -- Show recent activity in the stats window
    show_contributions = true,        -- Show contributions in the stats window
    show_repo_stats = true,           -- Show repository stats in the stats window
    events_cache_timeout = 3600 * 6,        -- Time in seconds to cache activity events
    contributions_cache_timeout = 3600 * 6, -- Time in seconds to cache contributions data
    repo_cache_timeout = 3600 * 24 * 7,     -- Time in seconds to cache repositories
    username_cache_timeout = 3600 * 24 * 7, -- Time in seconds to cache username
    user_cache_timeout = 3600 * 24 * 7,     -- Time in seconds to cache user data
    add_default_keybindings = true,         -- Add default keybindings for the plugin
})
```

Available `sort_repos_by` options:

- `create` - Sort by creation date, `OctoReposByCreated`
- `fork` - Sort by forks, `OctoReposByForks`
- `issue` - Sort by open issues, `OctoReposByIssues`
- `language` - Sort by language, `OctoReposByLanguage`
- `name` - Sort by name, `OctoReposByNames`
- `push` - Sort by last push, `OctoReposByPushed`
- `size` - Sort by size, `OctoReposBySize`
- `star` - Sort by stars, `OctoReposByStars`
- `update` - Sort by last update, `OctoReposByUpdated`

Available `repo_type` options:

- `archive` - Archived repositories, `OctoReposTypeArchived`
- `fork` - Forked repositories, `OctoReposTypeForked`
- `private` - Private repositories, `OctoReposTypePrivate`
- `star` - Starred repositories, `OctoReposTypeStarred`
- `template` - Template repositories, `OctoReposTypeTemplate`

> Note: The `sort_repos_by` and `repo_type` options match the start of keywords, you can expand them for readability, `sort:updated` is same as `sort:update`.

### Commands

`octohub.nvim` adds the following commands:

- `:OctoRepos [user] [sort:<sort_repos_by>] [type:<repo_type>]`: Displays the repositories for a given user, sorted by the specified criteria.
  - Ex: `:OctoRepos 2kabhishek sort:updated type:fork` - Display all forked repositories for the user `2kabhishek`, sorted by the last update.
  - Ex: `:OctoRepos type:stars` - Display all repositories starred by the current user.
- `:OctoRepo <repo_name> [user]`: Opens a specified repository, optionally by a user.
  - Ex: `:OctoRepo octohub.nvim` - Clone the repository `octohub.nvim` from the current user.
  - Ex: `:OctoRepo 2kabhishek octohub.nvim` - Clone the repository `octohub.nvim` from the user `2kabhishek`.
- `:OctoRepoStats [user]`: Displays statistics for the repositories of a given user.
  - Ex: `:OctoRepoStats 2kabhishek` - Display statistics for the repositories of the user `2kabhishek`.
- `:OctoRepoWeb` - Opens the current repository in the browser.
- `OctoStats`: Displays all stats (activity, contributions, repository data).
  - Ex: `:OctoStats theprimeagen` shows stats for `theprimeagen`.
- `OctoActivityStats [username] [count:N]`: Displays recent activity for a user, with an optional count.
  - Ex: `:OctoActivityStats count:20` shows the last 20 activity events for the current user.
- `OctoContributionStats [username]`: Displays contribution stats for a user.
- `OctoProfile [username]`: Opens the GitHub profile of a user in your browser.

- `UtilsClearCache[prefix]`: Clears all the cache for a given prefix. Provided by [utils.nvim](https://github.com/2kabhishek/utils.nvim).
  - Ex: `:UtilsClearCache username` - Clears the cache for `username`

If the `user` parameter is not provided, the plugin will use the current authenticated username from `gh`

### Keybindings

By default, these are the configured keybindings.

| Keybinding    | Command                      | Description          |
| ------------- | ---------------------------- | -------------------- |
| `<leader>goo` | `:OctoRepos<CR>`             | All Repos            |
| `<leader>gob` | `:OctoReposBySize<CR>`       | Repos by Size        |
| `<leader>goc` | `:OctoReposByCreated<CR>`    | Repos by Created     |
| `<leader>gof` | `:OctoReposByForks<CR>`      | Repos by Forks       |
| `<leader>goi` | `:OctoReposByIssues<CR>`     | Repos by Issues      |
| `<leader>gol` | `:OctoReposByLanguage<CR>`   | Repos by Language    |
| `<leader>gos` | `:OctoReposByStars<CR>`      | Repos by Stars       |
| `<leader>gou` | `:OctoReposByUpdated<CR>`    | Repos by Updated     |
| `<leader>goU` | `:OctoReposByPushed<CR>`     | Repos by Pushed      |
| `<leader>goA` | `:OctoReposTypeArchived<CR>` | Archived Repos       |
| `<leader>goF` | `:OctoReposTypeForked<CR>`   | Forked Repos         |
| `<leader>goP` | `:OctoReposTypePrivate<CR>`  | Private Repos        |
| `<leader>goS` | `:OctoReposTypeStarred<CR>`  | Starred Repos        |
| `<leader>goT` | `:OctoReposTypeTemplate<CR>` | Template Repos       |
| `<leader>goa` | `:OctoActivityStats<CR>`     | Activity Stats       |
| `<leader>gog` | `:OctoContributionStats<CR>` | Contribution Graph   |
| `<leader>gor` | `:OctoRepoStats<CR>`         | Repo Stats           |
| `<leader>got` | `:OctoStats<CR>`             | All Stats            |
| `<leader>gop` | `:OctoProfile<CR>`           | Open GitHub Profile  |
| `<leader>gow` | `:OctoRepoWeb<CR>`           | Open Repo in Browser |

I recommend customizing these keybindings based on your preferences.

You can also add the following to your `which-key` configuration: `{ '<leader>go', group = 'Octohub' },`

### Telescope Integration

`octohub.nvim` adds a Telescope extension for easy searching and browsing of repositories.

> Make sure that you define the `picker_provider` as `telescope` in your pickme.nvim configuration.

To use this extension, add the following code to your configuration:

```lua
local telescope = require('telescope')

telescope.load_extension('repos')
```

You can now use the following command to show repositories in Telescope: `:Telescope repos`

### Help

Run `:help octohub` to view these docs in Neovim.

## 🏗️ What's Next

- [ ] Add more tests
- You tell me!

## ⛅ Behind The Code

### 🌈 Inspiration

I use GitHub quite a bit and wanted to get all of my most used activities done from Neovim.

### 💡 Challenges/Learnings

- The main challenges were figuring out how to interact with the GitHub API and how to display the data in a user-friendly way.
- I learned about Lua's powerful features for handling data structures and Neovim's extensibility.

### 🔍 More Info

- [nerdy.nvim](https://github.com/2kabhishek/nerdy.nvim) — Find nerd glyphs easily
- [tdo.nvim](https://github.com/2kabhishek/tdo.nvim) — Fast and simple notes in Neovim
- [termim.nvim](https://github.com/2kabhishek/termim.nvim) — Neovim terminal improved

<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

<a href="https://github.com/2kabhishek/octohub.nvim">Source</a>
| <a href="https://2kabhishek.github.io/blog" target="_blank">Blog </a>
| <a href="https://twitter.com/2kabhishek" target="_blank">Twitter </a>
| <a href="https://linkedin.com/in/2kabhishek" target="_blank">LinkedIn </a>
| <a href="https://2kabhishek.github.io/links" target="_blank">More Links </a>
| <a href="https://2kabhishek.github.io/projects" target="_blank">Other Projects </a>

</div>
