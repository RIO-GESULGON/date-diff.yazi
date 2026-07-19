# date-diff.yazi

Show the modification-time difference between two selected files in [Yazi](https://github.com/sxyazi/yazi).

## Requirements

- Yazi `>= 25.5.28`

## Installation

```bash
ya pkg add rio-gesulgon/date-diff
```

Or install manually into `~/.config/yazi/plugins/date-diff.yazi/`.

## Usage

Select exactly two files and trigger the plugin:

```toml
[[mgr.prepend_keymap]]
on = "<C-S-d>"
run = "plugin date-diff"
desc = "Show modification-time difference between two selected files"
```

A notification is shown with each file's modification time and the formatted duration between them.

## License

MIT
