# Framer Sublime Text Theme / Syntax

This is a Framer-flavored theme kit for Sublime Text 3.

At the moment it is extremely hacky and provisional!

It includes:
* a UI theme, based on Sublime Material
* a color theme, based on Boxy Tomorrow
* a custom CoffeeScript syntax, based on CoffeeScript

![Screenshot](./screenshot.png?raw=true "Screenshot")

## Installation

Open your Packages folder. (Preferences > Browse Packages.)

Place the FramerSublime folder in your Packages folder.
Place the Material Theme folder in your Packages folder.

Select the Framer CoffeeScript syntax. 
(View > Syntax > Framer CoffeeScript)

Select the Material-Theme-Framer.sublime-theme.
(Preferences > Theme > Material-Theme-Framer.sublime-theme)

Select the Framer Sublime color scheme.
(Preferences > ColorScheme > FramerSublime)

## Settings

If you want to complete the look, add the following lines to your Preferences:

```json

{
	"theme": "Material-Theme-Framer.sublime-theme",
	"color_scheme": "Packages/User/FramerSublime/FramerSublime.tmTheme",
	"font_face": "Roboto Mono",
	"material_theme_accent_graphite": true,
	"material_theme_compact_panel": true,
	"material_theme_small_tab": true,
	"line_padding_bottom": 2,
  	"line_padding_top": 2,
	"caret_extra_bottom": 3,
	"caret_extra_top": 0,
	"caret_extra_width": 1,
	"highlight_line": true,
	"font_options":
	[
		"subpixel_antialias",
		"no_round"
	],
}
```