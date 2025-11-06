# Git Repository Status Component

A feature-rich Git repository status component for [yatline.yazi](https://github.com/imsi32/yatline.yazi).

## Features

✨ **Comprehensive Git Information**

- Current branch name or commit hash (detached HEAD)
- Commits ahead/behind upstream
- Clean/dirty repository indicator
- Detailed file change statistics

📊 **File Change Tracking**

- Staged files
- Added files
- Modified files
- Deleted files
- Renamed files
- Untracked files

🎨 **Highly Customizable**

- Custom icons (UTF-8 or Nerd Fonts)
- Configurable colors
- Multiple display modes (detailed or compact)
- Optional features (stash count, clean indicator)

## Quick Start

1. **Copy the component file:**

   ```bash
   cp git-repo-status.lua ~/.config/yazi/plugins/yatline.yazi/
   ```

2. **Add to your Yazi config** (`~/.config/yazi/init.lua`):

   ```lua
   require("yatline"):setup({
       -- Your yatline configuration
       status_line = {
           left = {
               section_c = {
                   { type = "coloreds", custom = false, name = "git_repo_status" },
               },
           },
       },
   })

   -- Initialize git status component (auto-registers with Yatline)
   require("yatline.git-repo-status"):setup()
   ```

3. **Restart Yazi** and navigate to a Git repository!

## Documentation

Full documentation is available in [docs/Git-Repo-Status.md](docs/Git-Repo-Status.md).

## Examples

See [examples/git-status-integration.lua](examples/git-status-integration.lua) for a complete integration example.

## Display Samples

**Clean repository:**

```shell
 main ✓
```

**Dirty repository with changes:**

```shell
  main ⇡3 ✗ ●2 +1 ~2 -1 ?3 
```

- `main` - Current branch `main`
- `⇡3` - 3 commits ahead of upstream
- `✗`  - Dirty repository
- `●2` - 2 staged files
- `+1` - 1 added file
- `~2` - 2 modified files
- `-1` - 1 deleted file
- `?3` - 3 untracked files

**Compact mode:**

```shell
  main ⇡2 (5) 
```

## Requirements

- [Yazi](https://github.com/sxyazi/yazi) file manager
- [yatline.yazi](https://github.com/imsi32/yatline.yazi) plugin
- Git command-line tool

## Configuration

Customize icons and colors to match your theme:

```lua
require("yatline.git-repo-status"):setup({
    icons = {
        branch = "󰘬",
        clean = "",
        dirty = "",
        -- ... more icons
    },
    colors = {
        branch = "blue",
        clean = "green",
        dirty = "yellow",
        -- ... more colors
    },
    compact = false,
    show_clean = true,
})
```

## License

This component follows the same license as yatline.yazi.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
