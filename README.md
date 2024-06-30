# yatline.yazi
The first Yazi plugin for both header-line and status-line.

![yatline](https://github.com/imsi32/yatline.yazi/assets/81227251/dade37fb-e258-478d-8c8e-f6224f0f31c5)
![select_mode](https://github.com/imsi32/yatline.yazi/assets/81227251/2a624fb4-7154-45ae-bbb3-81c8f6836972)

## Instalation Steps
1) Download the repository.
2) If the directory is downloaded as zip file, extract it.
3) Rename the directory as `yatline.yazi`
4) Open the config directory of Yazi.
5) Copy this directory into `plugins` directory.
6) Create `init.lua` file in the main Yazi config directory.
7) Open this file and copy `require("yatline"):setup()` into it.

## Features
- Lualine-like Design
- Flexible
- Simple
- Manual Configuration

## Q&A
Q: Why does text in tabs not shows up?

A: You need to increase tab_width in theme.toml.
