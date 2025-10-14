
# Adding custom words to the Word Glossary <!-- omit from toc -->
The mod exposes a basic API for other mods to add their own entries with the Word Glossary. The functions and global variables in the API will only be present if the game detects the word glossary mod installed (a side effect of putting them in `keys`, which is a global table in base-game that gets re-initialized when reloading mods).

For a complete example of the API being used, view the [Plasma's Modpack implementation](https://github.com/PlasmaFlare/plasma-baba-mods/blob/master/Lua/glossary.lua).

# Table of Contents <!-- omit from toc -->
- [Global Variables](#global-variables)
  - [`keys.IS_WORD_GLOSSARY_PRESENT`](#keysis_word_glossary_present)
- [`keys.WORD_GLOSSARY_VERSION`](#keysword_glossary_version)
- [Functions](#functions)
  - [`keys.WORD_GLOSSARY_FUNCS.add_entries_to_word_glossary`](#keysword_glossary_funcsadd_entries_to_word_glossary)
    - [Fields](#fields)
      - [`base_obj`](#base_obj)
      - [`description`](#description)
      - [`author`](#author)
      - [`group`](#group)
      - [`thumbnail`](#thumbnail)
      - [`text_type`](#text_type)
      - [`custom_type`](#custom_type)
      - [`display_name`](#display_name)
      - [`display_sprites`](#display_sprites)
      - [`truncate_text_prefix_in_display_name`](#truncate_text_prefix_in_display_name)
    - [Deprecated Fields:](#deprecated-fields)
      - [~~`name`~~](#name)
      - [~~`thumbnail_obj`~~](#thumbnail_obj)
    - [Examples:](#examples)
  - [`keys.WORD_GLOSSARY_FUNCS.register_author`](#keysword_glossary_funcsregister_author)
    - [Example](#example)
  - [`keys.WORD_GLOSSARY_FUNCS.register_custom_text_type`](#keysword_glossary_funcsregister_custom_text_type)
    - [Example](#example-1)

## Global Variables

### `keys.IS_WORD_GLOSSARY_PRESENT`
`true` if the Word Glossary Mod is initialized. `nil` if not.

This can be useful if you want your mod to be compatible with the Word Glossary Mod without having to make a separate version of your mod. Just surround your code that calls functions in `keys.WORD_GLOSSARY_FUNCS` with:
```lua
if keys.IS_WORD_GLOSSARY_PRESENT then
    --- <code that calls functions in keys.WORD_GLOSSARY_FUNCS>
end
```

## `keys.WORD_GLOSSARY_VERSION`
String for the word glossary version

## Functions

### `keys.WORD_GLOSSARY_FUNCS.add_entries_to_word_glossary`

```lua
keys.WORD_GLOSSARY_FUNCS.add_entries_to_word_glossary(entries)
```
Adds a list of word entries to the word glossary in the order presented in `entries`. 

Each word entry is a table in this format:
```lua
{
    base_obj: string
    description: string
    author: string (optional)
    group: string (optional)
    thumbnail: string or table (optional)
    text_type: int (optional)
    display_name: string (optional) 
    display_sprites: list of string or table (optional)
    truncate_text_prefix_in_display_name: boolean (optional)

    -- Deprecated fields
    name: string (optional)
    thumbnail_obj: string (optional)
}
```
#### Fields
##### `base_obj`
Type: string

This is the object registered in-game to serve as a base for getting most properties for the word entry. In most use-cases for simply adding a modded word, `base_obj` is effectively required.

The object associated with `base_obj` has to be defined in-game (aka in `editor_objlist`) in order to work.

If you want more customization without having to rely on `base_obj`, it's possible to not set `base_obj` to anything. But then you will need to provide the following fields or else it will error:
- `display_name`
- `thumbnail`
- `text_type` or `custom_type`
____

##### `description`
Type: string

Description what the text or object does.

This supports:
  - Newlines
  - Color codes (Ex: `$3,2`).
  - Control Icons (Ex: `@gamepad_editor_rotate`)
  - Lang texts (Ex: `#main_custom`)
____

##### `author`
Type: string (optional)

The author to credit for this text. (See [register_author](#keysword_glossary_funcsregister_author)).

- If the author isn't registered via "register_author", it would just show the text itself

- If left blank, the author will be shown as "N/A"

____

##### `group`
Type: string (optional)

The name of the modpack or some other group of texts that this text is a part of, if applicable.

- If left blank, it won't show any group.

____

##### `thumbnail`
Type string or table (optional)

The object/sprite to display as a thumbnail for the word entry. (Ex: `text_stable`)

- If left blank, this would be set to "text_`base_obj`". So if `base_obj` = "cut" then `thumbnail` = "text_cut".

- If thumbnail is a table, then the following fields have to be defined:
  ```lua
  {
    sprite: "baba_2",
    color: {0,3},
    sprite_in_root: false
  }
  ```
    - `sprite`: The name of the sprite in the `Sprites` folder
      - Ex: If you want to use "baba_2_1.png", use "baba_2"
    - `color`: the color of the sprite as coordinates in the current palette
      - Can also use `colour` as an alternative name for this parameter
    - `sprite_in_root`: If true, the game will look at `<baba install dir>/Data/Sprites` for the sprite. If false, the game will look at `<levelpack folder>/Sprites` for your sprite.

____

##### `text_type`
Type: int (optional)

The text type of this word entry.

- If left empty, this would be set to the text_type of the `base_obj` (or the string "object" if `base_obj` does not refer to a text)
____

##### `custom_type`
Type: string (optional)

- If not nil, this overrides the rendering of the object type with a custom string.

- If left empty, the string associated with the `text_type` will be shown.
____

##### `display_name`
Type: string (optional)

What to display as the title of this word entry.

- If left empty, this would be set to `name`.

- If the text type isn't from the base game, it will show "Other".  (See [register_custom_text_type](#keysword_glossary_funcsregister_custom_text_type)).

____

##### `display_sprites`
Type: list of items (optional)

A table representing a list of objects to display on the left side when viewing the word entry in-game.

- You can show up to a maximum of 16 objects. Any extra objects will be ignored.

- If left empty, this would be set to `{base_obj}`, or simply the base_obj.

- Each item in `display_sprites` is one of the following:
  - A string representing an object name registered in-game.
  - A table that has these fields defined:
    ```lua
    {
      sprite: "baba_2",
      color: {0,3},
      sprite_in_root: false
    }
    ```
      - `sprite`: The name of the sprite in the `Sprites` folder
        - Ex: If you want to use "baba_2_1.png", use "baba_2"
      - `color`: the color of the sprite as coordinates in the current palette
        - Can also use `colour` as an alternative name for this parameter
      - `sprite_in_root`: If true, the game will look at `<baba install dir>/Data/Sprites` for the sprite. If false, the game will look at `<levelpack folder>/Sprites` for your sprite.

##### `truncate_text_prefix_in_display_name`
Type: boolean (optional). Default: `true `

If true, the string for `display_name` will truncate every "text_" prefix.

Examples:
- If `display_name` = "text_wall", then it gets truncated to "wall"
- If `display_name` = "text_text_baba", then it gets truncated to "baba"

#### Deprecated Fields:
##### ~~`name`~~
Type: string
The name of the word entry. 

**Note:** If you were using this field for version V1 of the Word Glossary, you should still be able to use this field for V2 upwards. But it's recommended that you convert from using `name` to using `base_obj`.


##### ~~`thumbnail_obj`~~
Type string (optional)

The object to display as a thumbnail for the word entry. (Ex: `text_stable`)

**Note:** If you were using this field for version V1 of the Word Glossary, you should still be able to use this field for V2 upwards. But it's recommended that you convert from using `thumbnail_obj` to using `thumbnail`.

#### Examples:
```lua
keys.WORD_GLOSSARY_FUNCS.add_entries_to_word_glossary({

    -- Basic example. This adds text_guard to the word glossary. Thumbnails, text type, display sprites and display names are taken care of because of base_obj.
    {
        base_obj = "guard",
        author = "PlasmaFlare",
        description = "Allows objects to sacrifice themselves in order to save another object from being destroyed.",
    },


    -- Another basic example but with a more detailed description.
    -- The [[]] is another way to define a string. But it also allows newlines.
    -- The weird indentation for the description is because [[]] counts every character within the brackets, including newlines and tabs/spaces, into its value.
    -- Notice how the description also uses color codes.
    {
        base_obj = "cut",
        author = "PlasmaFlare",
        description = 
[[Gives an object the ability to split a text block into individual letters.

- The effect happens when the $5,3CUT$0,3 object walks into a text block.

- Letters cannot be cut.

- When a text block is cut, its letters are extracted out in the direction of the cut. Letter extraction can stop early at the first solid object encountered.

- If a text block gets cut from occupying the same space as a "CUT" object, letters are extracted in the direction the text block is facing.
]],
    },


    -- A more customized word entry for directional you. This has a custom thumbnail, a custom title (display_name), and 4 display sprites for showing the 4 different directions of directional you when viewing the word entry in-game.
    -- base_obj is not defined because the word entry has the required fields needed to cover for it (See base_obj documentation).
    {
        thumbnail = "text_youright",
        display_name = "directional you",
        text_type = 2,
        author = "PlasmaFlare",
        display_sprites = {"text_youup", "text_youright", "text_youleft", "text_youdown"}
        description = [[Variant of "YOU" that allows the player to move the object the direction of the arrow. Objects that are directional YOU can still trigger "WIN", and will be destroyed on "DEFEAT" object, like normal "YOU" objects.]],
    },
})
```


### `keys.WORD_GLOSSARY_FUNCS.register_author`

```lua
keys.WORD_GLOSSARY_FUNCS.register_author(author, color, custom_display)
```

----------------------------------------------------------------------------

Registers the word author and how you want to display their name in-game when viewing a word entry with the author.


- `author: string` - The author of the word to register. This will be the string to refer to the author when adding word entries.
- `color: table (optional)` - X and Y coordinates in the color palette in which to color the author name.
    - **Default:** `{0, 3}` (white)
- `custom_display: string (optional)` - If this is not nil, it overrides the default rendering of the author name with a custom format. You can take advantage of this to use color codes, or display a nickname or extra decorations for the author.
  - Ex: `$1,4plasma$3,4flare`
  - If `custom_display` is not nil, the `color` parameter of this function will be ignored

#### Example
```lua
keys.WORD_GLOSSARY_FUNCS.register_author("PlasmaFlare", {4,4} )
```

----------------------------------------------------------------------------

### `keys.WORD_GLOSSARY_FUNCS.register_custom_text_type`

```lua
keys.WORD_GLOSSARY_FUNCS.register_custom_text_type(text_type, display)
```

Registers a custom text type. Any word entry with its text type equal to `text_type` will show the string contained in `display`. **Note:** This can override the vanilla text types.

- `text_type: int` - The text type in number form.
- `display: string` - the string to display when selecting a word entry with the corresponding text type.

#### Example
```lua
-- Register texts of type 11 to show "Filler"
keys.WORD_GLOSSARY_FUNCS.register_custom_text_type(11, "Filler")
```