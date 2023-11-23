# Vi Editor Cheat Sheet

Vi is a powerful and widely used text editor in Linux. Below are some useful operations and commands to navigate and edit text in vi.

## Modes

- **Normal Mode:** The default mode for navigation and executing commands.
- **Insert Mode:** Allows you to insert and edit text.
- **Visual Mode:** Enables text selection for copying or deleting.

## Navigation

- `h` : Move cursor left.
- `j` : Move cursor down.
- `k` : Move cursor up.
- `l` : Move cursor right.
- `0` : Move to the beginning of the line.
- `$` : Move to the end of the line.
- `gg` : Move to the beginning of the file.
- `G` : Move to the end of the file.
- `Ctrl + b` : Move back one full screen.
- `Ctrl + f` : Move forward one full screen.

## Editing

### Inserting and Appending

- `i` : Enter insert mode before the cursor.
- `I` : Enter insert mode at the beginning of the line.
- `a` : Enter insert mode after the cursor.
- `A` : Enter insert mode at the end of the line.
- `o` : Open a new line below the current line and enter insert mode.
- `O` : Open a new line above the current line and enter insert mode.

### Deleting

- `x` : Delete the character under the cursor.
- `dd` : Delete the current line.
- `D` : Delete from the cursor position to the end of the line.

### Copying and Pasting

- `yy` : Yank (copy) the current line.
- `p` : Paste the yanked text after the cursor.
- `P` : Paste the yanked text before the cursor.

### Undo and Redo

- `u` : Undo the last change.
- `Ctrl + r` : Redo the last undone change.

## Searching and Replacing

- `/pattern` : Search forward for the specified pattern.
- `?pattern` : Search backward for the specified pattern.
- `n` : Move to the next occurrence of the search pattern.
- `N` : Move to the previous occurrence of the search pattern.
- `:s/old/new/g` : Replace all occurrences of "old" with "new" in the entire file.
- `:n,ms/old/new/g` : Replace all occurrences in the range from line `n` to line `m`.

## Saving and Quitting

- `:w` : Save changes to the file.
- `:wq` or `:x` : Save changes and quit.
- `:q!` : Quit without saving changes.

Remember to press `Esc` to switch to normal mode before executing most commands.

For more information, you can refer to the `vi` manual by typing `man vi` in the terminal.



**Happy editing!**