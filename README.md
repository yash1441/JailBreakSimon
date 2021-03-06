# JailBreakSimon
A JailBreak Warden rewrite with additional features.

*Based on CS 1.6 JailBreak plugins. Some code is taken from various authors, credits to the them for their work.*

# Requirements
- simon.inc for compiling the addons.
- [Hosties + LastRequest](https://forums.alliedmods.net/showthread.php?t=237045) for checking OnAvailableLR and other JailBreak related stuff.
- [SmartJailDoors](https://github.com/Kailo97/smartjaildoors) for opening and closing cell doors.
- [EmitSoundAny](https://forums.alliedmods.net/showthread.php?t=237045) for playing countdown sounds.

# CVARs
**Core**
- ```jb_simon_msg``` "0 - normal chat messages, 1 - hint & centre text messages"
- ```jb_tag_enabled``` "Allow Simon to be added to the server tags?"
- ```jb_beacon_enabled``` "Enable or Disable beacon on Simon"

**Menu**
- ```jb_menu_enabled``` "0 - disable, 1 - enable"
- ```jb_freeday_time``` "Duration of a Freeday in float in minutes."

**Box**
- ```jb_box_enabled``` "Enable or Disable this plugin."

# Commands
**Core**
- ```!simon``` | ```!s``` "Become Simon or leave the position."
- ```!nomic``` "Switch to Terrorist if you have no microphone."
- ```!remove``` "Remove someone from the position of Simon. Needs ADMFLAG_GENERIC."

**Menu**
- ```!menu``` "Opens the menu."
![Menu Screenshot](https://steamuserimages-a.akamaihd.net/ugc/576821368994132225/F1D85894F45EBEBF9371E86DA1B62036FDF6E610/)
- ```!amenu``` "Opents the Admin's menu."
- ```!cells``` "Shortcut for Open/Close Cells."
- ```!fd``` | ```!freeday``` "Shortcut for Freeday menu. Specific person or everyone."
- ```!divide``` | ```!teams``` "Shortcut for Team Division menu. Divide by 2/3/4 and remove the divisions."
![Team Screenshot](https://steamuserimages-a.akamaihd.net/ugc/496889383573420745/C48FF9A3B6FB0987768C3C912E7BC7FDF0A35A81/)
- ```!hp``` "Shortcut for Giving Prisoners 100 HP."
- ```!countdown``` | ```!cd``` "Shortcut for Countdown menu if without any parameter else starts countdown of specified amount of seconds. Plays sound when the countdown is/reaches less than or equal to 15 seconds."
- ```!rebels``` "Shortcut for Checking Rebels."

**Box**
- ```!box``` "Enable/Disable box mode for prisoners."
![Box Screenshot](https://steamuserimages-a.akamaihd.net/ugc/576821368994132717/4EAB66B681C553AFC2B387E9BD5CD119148C3CFC/)

**Freekill**
- ```!freekill``` | ```!fk``` "Ask a CT for respawn upon getting Freekilled. Won't work twice so won't spam."

# TODO
- Add option to play/stop music.
- Test jb_ball.smx addon and if not working then update with [Simple Ball Plugin](https://forums.alliedmods.net/showthread.php?p=2423345).
- Add simon.inc support in jb_box and jb_freekill addons.
