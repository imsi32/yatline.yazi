# Git Status Component - Architecture Diagram

```txt
┌─────────────────────────────────────────────────────────────────────┐
│                         Yazi File Manager                           │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                    yatline Plugin                           │    │
│  │                                                             │    │
│  │  ┌──────────────────────────────────────────────────────┐   │    │
│  │  │           Status Line Components                     │   │    │
│  │  │                                                      │   │    │
│  │  │  Section A    Section B       Section C              │   │    │
│  │  │  ┌────────┐  ┌────────┐      ┌──────────────────┐    │   │    │
│  │  │  │ Mode   │  │ Size   │      │ Git Status ★     │    │   │   │
│  │  │  └────────┘  └────────┘      └──────────────────┘     │   │   │
│  │  │                                       │               │   │   │
│  │  └───────────────────────────────────────┼───────────────┘   │   │
│  │                                          │                   │   │
│  │  ┌───────────────────────────────────────▼───────────────┐  │   │
│  │  │       yatline.coloreds.get.git_repo_status()          │  │   │
│  │  └───────────────────────────────────────┬───────────────┘  │   │
│  └──────────────────────────────────────────┼──────────────────┘   │
│                                             │                       │
└─────────────────────────────────────────────┼───────────────────────┘
                                              │
                    ┌─────────────────────────▼─────────────────────┐
                    │     git-repo-status.lua Component             │
                    │                                               │
                    │  ┌──────────────────────────────────────┐   │
                    │  │  M.get_status()                      │   │
                    │  │  - Gets current directory from cx    │   │
                    │  │  - Calls get_git_info()             │   │
                    │  │  - Formats as coloreds array        │   │
                    │  └────────────────┬─────────────────────┘   │
                    │                   │                          │
                    │  ┌────────────────▼──────────────────────┐  │
                    │  │  get_git_info(path)                   │  │
                    │  │  - Executes Git commands              │  │
                    │  │  - Parses output                      │  │
                    │  │  - Returns info table                 │  │
                    │  └────────────────┬──────────────────────┘  │
                    │                   │                          │
                    │  ┌────────────────▼──────────────────────┐  │
                    │  │  format_git_info(info, config)        │  │
                    │  │  - Applies icons                      │  │
                    │  │  - Applies colors                     │  │
                    │  │  - Returns [{text, color}, ...]      │  │
                    │  └───────────────────────────────────────┘  │
                    │                                               │
                    └───────────────────┬───────────────────────────┘
                                        │
                        ┌───────────────▼────────────────┐
                        │     Git Repository             │
                        │                                │
                        │  Commands executed:            │
                        │  - git rev-parse               │
                        │  - git symbolic-ref            │
                        │  - git rev-list                │
                        │  - git status --porcelain      │
                        │  - git stash list              │
                        └────────────────────────────────┘


Data Flow
═════════

1. User Configuration
   └─> M.setup(config) - Merges user config with defaults

2. Component Registration
   └─> yatline.coloreds.get.git_repo_status = M.get_status

3. Runtime Execution (every render)
   └─> yatline calls git_repo_status()
       └─> M.get_status()
           └─> get_git_info(path)
               ├─> Git command: check if in repo
               ├─> Git command: get branch
               ├─> Git command: get ahead/behind
               ├─> Git command: get file status
               └─> Git command: get stash count
           └─> format_git_info(info, config)
               └─> Returns: {{"  main ", "blue"}, {"⇡3 ", "green"}, ...}
       └─> yatline renders coloreds with proper styling


Output Example
══════════════

Config:
  show_branch = true
  show_ahead_behind = true
  compact = false

Git State:
  Branch: main
  Ahead: 3 commits
  Behind: 0 commits
  Staged: 2 files
  Modified: 1 file
  Untracked: 3 files

Coloreds Output:
  [
    {"  main ", "blue"},
    {"⇡3 ", "green"},
    {"✗ ", "yellow"},
    {"●2 ", "cyan"},
    {"~1 ", "yellow"},
    {"?3 ", "magenta"}
  ]

Rendered Display:
  [blue] main [green]⇡3 [yellow]✗ [cyan]●2 [yellow]~1 [magenta]?3


Configuration Flow
══════════════════

Default Config
     │
     ├─> Icons (branch, clean, dirty, etc.)
     ├─> Colors (blue, green, yellow, etc.)
     └─> Display Options (show_branch, compact, etc.)
     │
     ▼
User Config (passed to setup())
     │
     └─> Merged with defaults
         │
         ▼
    Runtime Config
         │
         ├─> Used by format_git_info()
         └─> Determines what to display and how
```

## Component Lifecycle

```txt
┌──────────────────────────────────────────────────────────────┐
│                    Initialization Phase                       │
└───────────────────────────────┬──────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
  require()              M.setup(config)      Register with yatline
  Load module         Merge configuration    Set as coloreds getter
        │                       │                       │
        └───────────────────────┴───────────────────────┘
                                │
┌───────────────────────────────▼──────────────────────────────┐
│                      Runtime Phase                            │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                │  (triggered on every render)
                                │
                ┌───────────────▼───────────────┐
                │  yatline renders status line  │
                └───────────────┬───────────────┘
                                │
                ┌───────────────▼───────────────┐
                │  calls git_repo_status()      │
                └───────────────┬───────────────┘
                                │
                ┌───────────────▼───────────────┐
                │  M.get_status() executed      │
                └───────────────┬───────────────┘
                                │
                        ┌───────┴───────┐
                        │               │
                        ▼               ▼
                 get_git_info()   format_git_info()
                        │               │
                        └───────┬───────┘
                                │
                ┌───────────────▼───────────────┐
                │  Return coloreds array        │
                └───────────────┬───────────────┘
                                │
                ┌───────────────▼───────────────┐
                │  yatline applies styling      │
                └───────────────┬───────────────┘
                                │
                ┌───────────────▼───────────────┐
                │  Rendered in status line      │
                └───────────────────────────────┘
```
