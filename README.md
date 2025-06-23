# View Set <!-- omit from toc -->

Change the visibility of a group of objects

## Table of Contents <!-- omit from toc -->

- [Description](#description)
  - [Features](#features)
  - [Rational](#rational)
  - [Remarks](#remarks)
- [Disclaimer](#disclaimer)
- [Pull Requests](#pull-requests)

## Description

This adds a tool which groups entities by name and controls their visibility

### Features

- **Simple UI**: set the view set per entity, and click on the buttons on the table to toggle their visibility
- **GMod save or duplicator support**: View names now carry between saves or dupes, allowing you to still set their visibility. Set up the view sets once; never set them up again
- **Hierarchy support**: Entities will automatically set visiblity for bonemerged entities
  - Some entities may be filtered, such as the Hat Painter entities, which are intentionally invisible

### Rational

I made this tool to make it easier to composite renders together. Previously, this involved the following steps:

1. Load a GMod save
2. Remove all entities unrelated to desired render
3. Render
4. Repeat step 1 for another render

Step 4 is required to ensure the next render contains the desired entities.

Depending on the complexity of the render, steps 1 and 2 often take the longest time to perform. For step one, it may take a while to load multiple entities with Stop Motion Helper data, and the loading time is bounded by the user's hardware. For step two, there is an additional substep of ensuring that all removed entities are deleted. The time it takes increases with the number of entities in the scene.

This tool allows for the following steps:

1. Load a GMod save with View Set data
2. Toggle the visibility of all entities unrelated to a desired render
3. Render
4. Repeat step 2 for another render

This removes the need to reload a GMod save, and no entities are removed at all.

### Remarks

- This tool was made for singleplayer or peer-to-peer sessions.
- This tool uses SetNoDraw to change the visibility of entities.

## Disclaimer

**This tool has been tested in singleplayer.** Although this tool may function in multiplayer, please expect bugs and report any that you observe in the issue tracker.

## Pull Requests

When making a pull request, make sure to confine to the style seen throughout. Try to add types for new functions or data structures. I used the default [StyLua](https://github.com/JohnnyMorganz/StyLua) formatting style.
