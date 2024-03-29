```
                           _                 _                              ~
                       ___(_)_ __ ___  _ __ | | ___                         ~
                      / __| | '_ ` _ \| '_ \| |/ _ \                        ~
                      \__ \ | | | | | | |_) | |  __/                        ~
                      |___/_|_| |_| |_| .__/|_|\___|                        ~
                                      |_|                                   ~
           _     _       _     _ _       _     _   _                        ~
          | |__ (_) __ _| |__ | (_) __ _| |__ | |_(_)_ __   __ _            ~
          | '_ \| |/ _` | '_ \| | |/ _` | '_ \| __| | '_ \ / _` |           ~
          | | | | | (_| | | | | | | (_| | | | | |_| | | | | (_| |           ~
          |_| |_|_|\__, |_| |_|_|_|\__, |_| |_|\__|_|_| |_|\__, |           ~
                   |___/           |___/                   |___/            ~
       
==============================================================================
Section 1: Description                               *simple_highlighting*

Script is designed to be easy and quick to use and satisfy the following
functionality:
1. Highlight multiple different words in multiple different highlight styles.
2. Keep the highlights between buffers.
3. Change search pattern to a highlighted style

==============================================================================
Section 2: Brief example of usage:
  * Place your cursor on a word and use "\h" to highlight it with default slot.
  * Type "\h" over another word to add it to the default slot
  * Run "\h" on a word already in the default highlight slot to remove it
  * ":Hd 3" will change the default slot to slot 3
  * 5\h will highlight the word under the cursor in 5's highlight slot.
  * Change buffer or open new window and highlights will remain the same
  * ":Hc 2"  will clear all the of slots 2's highlights.
  * ":Hs"     to changes the search pattern to all the current highlighted word
  * ":Hc"     will clear all highlights.
  * ":Ha 1 \<aa" will add the regular expression "\<aa" to highlight slot 1
  * ":Hw highlights.so" will save all the curent highlight settings

==============================================================================
Section 3: Detailed description of use:


KEYBINDING

<leader> default is \

[number] "<leader>h"
This key mapping can be changed if you look at section 5 settings.

In normal mode this will highlight the whole word under the cursor. Where
the highlighted colour/slot is determined by the preceding number. If
no preceding number is provided it will instead use the specified default
slot set using ex command Hd, see below, which is initialised to slot 1.

In visual mode this will highlight the selected text into the supplied
colour/slot, determined by the preceding number if any. This will not do whole
words.

If you want to use your own key mapping instead of "<leader>h". You can do so
by placing the following in your init.vim/.vimrc file:
	nmap <Leader>h <Plug>HighlightWordUnderCursor
Where "<Leader>h" is replaced with your preferred key binding.

Slot numbers can be between 1 to 9, the default slot is specified by Hd,
see below.

If a word (or pattern) is added to a slot that already contains it
the pattern will be removed.


CHANGING / REMOVING SLOTS

If the word/pattern you are trying to highlight already exits in a slot
it will be removed from the previous slot. If the previous slot is the
same as the one new one (you are trying to add it to the same slot twice)
it will simply remove the word/pattern.


COMMANDS

*Hc* *HighlightClear*
	:Hc [1 4 ...]
Clears the highlighted patterns in slot numbers listed or all if no:hel
number(s) are passed. If you just which to remove one word from the slot
please see changing / removing slots above

*Hs* *HighlightSearch*
	:Hs [1 4 ...]
Changes the search pattern to the highlighted slot numbers listed or
all if no number(s) passed

*Ha* *HighlightAddMultiple*
	:Ha <slot_number> <pattern> [additional patterns ...]
Adds the pattern and any additional patterns (space separated) to the
highlight slot specified in <slot_number>. The patterns support regular
expressions. To include a space use \ as escape character (eg "\ ")

*Hw* *HighlightWrite*
	:Hw <file_location> [1 4 ...]
Create a vim source file at <file_location> containing the settings for
the slot number(s) passed (or all slots if no numbers are passed)

*Hwb* *HighlightCommandsBuffer*
	:Hwb [1 4 ...]
Create a new buffer containing the settings for the slot number(s) passed
(or all slots if no numbers are passed).
 
To load the file created from HighlightWrite or HighlightCommandsBuffer
simply source it using
	:source <file_location>

*Hd* *HighlightDefault*
	:Hd <slot number>
Will change the default slot to the slot number specified.

==============================================================================
Section 4: To install

Please use your preferred packaged manager by adding it into your
init.vim/.vimrc file

Plug example:
	Plug 'pevhall/simple_highlighting'

minpac example:
	call minpac#add('pevhall/simple_highlighting')


==============================================================================
Section 5: init.vim/.vimrc Settings

If the slot colours look too much the same please try setting the following in
your init.vim/.vimrc:
	set termguicolors

If you want to change the default key mapping from "<Leader>h". Please
add the follwing in your init.vim/.vimrc:
	nmap <Leader>h <Plug>HighlightWordUnderCursor
	vmap <Leader>h <Plug>HighlightWordUnderCursor
Where "<Leader>h" is replaced with your prefered key binding.

If you are having a conflict with this plugin overriding other plugin's
colours or vise versa. You can try changing the priority of this
plugin. You can do this by setting
	let g:highlightPriority = -1
Values can be positive or negative. A higher value will give the plugin
a higher priority making it override others. A value of 1 will override
the inbuilt search highlighting (which you probably don't want).
0 is currently the default. Chosen so that it is overriding  coc's
CocActionAsync('highlight') by default. This plugin will always override
regular syntax highlighting

==============================================================================
Section 6: Wrap up

Minor issues:

Currently highlighting through visual selection will treat every line as
a new match pattern. The vim function matchadd doesn't seem to work with new
lines in it.

When highliting through visual block selection and you if you have different
levels of tabs between the lines this will cause the wrong text to be
selected. If you need to do this I currently recommend using a macro.

Limitation:

Currently users cannot specify there own highlighting colours for different
slots and/or change the number of slots. Let me know if this is something you
would like to see added.
```
