SleekRoll 1.0.0 - WoW 3.3.5a (Interface 30300)

INSTALL
Exit WoW. Extract the SleekRoll folder into World of Warcraft/Interface/AddOns.
The final path must be Interface/AddOns/SleekRoll/SleekRoll.toc.
Enable SleekRoll in the character-selection AddOns menu.

USE
/sr          Open the movable options window (also /sr options).
Adjust Width, Height, and Scale with sliders. Click Growth direction to switch
between Up and Down. The window also has preview, unlock, lock, and reset buttons.
Changes apply immediately and save automatically. Close with X or Escape.
The Celtic knotwork fills the entire loot window and fades horizontally from
33% opacity at the left edge to 0% at the right edge.
It stretches with the window and matches each item's quality color, beneath
text and buttons. There is no opacity control; old opacity settings are removed.
An opaque black backing sizes to each item name, with a small amount of padding,
to keep the text readable. It updates when rows are reused or resized.
The fade is baked into Media/KnotworkFade.tga, with rarity tint applied separately.
Install the entire folder including Media/KnotworkFade.tga and restart WoW.
The older commands below remain available as shortcuts.
/sr test     Toggle two sample rows. Clicking a sample button closes the preview.
/sr unlock   Show the drag handle. Drag it to move all loot rows.
/sr lock     Hide the handle and preview. Real loot rows still appear normally.
/sr reset    Reset the position and show the handle.
/sr size 420 90   Set row width and height independently (changes shape).
/sr scale 1.2     Scale the whole layout, including text and buttons.
/sr growth up     Stack loot windows upward above the handle.
/sr growth down   Stack loot windows downward below the handle (default).
Growth direction applies immediately to real rolls and preview rows and saves
after logout/reload. /sr reset also restores downward growth.
Width range: 200-720. Height range: 32-180. Scale range: 0.6-1.8.
Roll icons shrink slightly at narrow widths to keep all four options accessible.
Below height 73, rows use a compact single-line layout with the item name on
the left and roll icons on the right. Long names may be truncated at narrow widths.
Use /sr test first to see changes immediately. Settings apply to all rows
and are saved. /sr reset restores both position and size defaults.
The full /sleekroll command also works. Position persists after logout/reload.

DESIGN
360 x 73 dark rows, quality-colored accent and timer, cropped item icons,
and original WoW dice (Need), coin (Greed), disenchant, and X (Pass) icons.
Hover real roll icons for their original tooltips. Icons remain square as the
window width changes. Rows stack in your chosen direction.
Hover the item icon for its tooltip. Original modified-click behavior remains.
Blizzard handles eligibility, roll clicks, cancellation, and confirmation prompts.
The original client's four simultaneous group-loot frames remain the limit.
Button labels and commands are English.

COMPATIBILITY AND CHECKS
Designed against the archived 3.3.5 FrameXML:
https://github.com/wowgaming/3.3.5-interface-files
Disable any other addon that replaces or skins group-loot frames.
This addon has not been tested inside a running WoW client.
Before regular use, check /sr test, drag and /reload persistence, then a real
group roll: eligible/ineligible options, Need/Greed/Disenchant/Pass, binding
confirmation, several simultaneous items, cancellation, and timer expiry.
To report an error, enable /console scriptErrors 1 and capture its text.
