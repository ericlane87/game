# iOS SpriteKit Skeleton

This folder contains a SpriteKit MVP you can drop into an Xcode project.

## How to use
1. Create a new Xcode project (iOS > Game > SpriteKit).
2. Replace the generated GameScene.swift and GameViewController.swift with the files in this folder.
3. Copy Info.plist additions if needed.
4. Import assets from ../art into your Asset Catalog (names must match: player, roach, collectible, ground, stoop, trashbag, car, background).
5. Add AppleSignInManager.swift and set the Sign in with Apple capability in Xcode.

## Notes
- This MVP includes menu, HUD, controls, and win/lose flow.
- Sign in with Apple is provided as a manager class; wire it to a menu button as needed.
