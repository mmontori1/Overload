| ![Image](images/Overload1.png) | **Overload** | ![Image](images/blackSub.png) |
| :-- | ------------ | --: |

Menu bar app for Mac and PC that allows you to check your ping for online games (such as League and Overwatch)

# Intro

Are you tired of jumping into a ranked game, and finding out you're getting ping spikes which makes the game unplayable? Now you can check before you play and save yourself from dropping elo unnecessarily!

# Project Description

This project was started during MHacks Nano. You can check out the devpost here. Our goal was to create a small, simple application from your menu bar for both Mac and PC to check your ping for various games. Currently, we've added multiple server support for League of Legends and Overwatch, as well as other additional settings. The Mac and PC builds works different and don't have all the same functionality and settings, but both display ping latency and switching between other games and servers.

# How to use
## Mac

Once the app is running, click on the submarine icon on the menu bar, and it'll display some options. You can start pinging from there, or open the window to start pinging. You can only see the latency, stats, and settings within the window you open from the Open button. 

## PC

Once the app is running, right click the submarine icon and select the game and server in the context menu. To check your ping, hover your mouse over the icon for an exact value.

# How to check out the source code
## Mac

Clone the source code, and make sure to install the Cocoa pod dependencies once you're inside the Overload folder within the Mac directory for this project. 

```
pod install
```

Open the Overload.xcworkspace file, and you should be ready to go!

## PC

If you don't already have Microsoft Visual Studio, make sure to download it. Clone the source code, and navigate to the Overload.sln. Double click the file and the project should open up in Visual Studio.

# How to download the App

We haven't submitted the application for the App Store or Windows Store, so you can check out the current build from here.

## Mac
Drag and Drop the Overload.app from the builds folder, and run it!

## PC
Download OverloadSetup.msi from the build folder. After following the setup prompt, there should be a new desktop shortcut labeled: Overload (Active). 
