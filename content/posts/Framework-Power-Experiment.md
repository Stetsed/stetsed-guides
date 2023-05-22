---
title: "Framework Power Experiment"
date: 2023-05-22T09:27:16+02:00
draft: true
---

Today in this post I will be going through my experiments into the framework laptops power draw. 

## Testing Methodology

- I have written a [Program](https://github.com/Stetsed/framework-power-measurment) in Rust which takes the details of the battery that reports voltage and current, and then multiply those together for wattage. 
- I add this program to my Hyprland startup config, and then let it run for 600 cycles which making a measurment every second means it measures for 10 minutes.
- I then set the settings for this run in my Hyprland config depending on what I am running but the base setup is my [Dotfiles](https://github.com/Stetsed/.dotfiles) with the execs: Waybar, Eww, Discord, Librewolf disabled except the scenario I'm testing, so for example if task is librewolf I leave librewolf uncommented, and if I am testing the settings "waybar-eww-daemon" I would leave the eww daemon part enabled. I am also running it with TLP enabled using the settings following my [Framework Power Tuning Guide](https://stetsed.github.io/stetsed-guides/posts/framework-power-tuning/)
- I then compile these measurments into there respective documents, so for example if I am analyzing the terminal power usage I would cat them out into terminal.csv, all of the csv files I will link to in the end of this trial.
- I then make graphs of this data using the website [RawGraphs](https://app.rawgraphs.io/) using a line Graph with time being the X axis, wattage being the Y axis, settings being the lines and task being the color.

### Notes

Due to my program reading files and writing files it does add some level of overhead, I have tried to reduce it by writing it in Rust although it's not optimal and could be improved(By example logging all data to memory first and then writing to file at the end), but it's good enough to give us a reading on power usage.


## Hardware
- Intel i5-1240p
- 32GB 3600Mhz DDR4 RAM
- SN770 1TB NVME SSD
- 2x USB-C, 1x USB-A, 1x Displayport Card

## Usual Power Saving Tips

Here I will use my config with waybar as the default with no eww daemon, and browser and discord disabled. This section will be dedicated to the usual power saving tips that people recommend. The below list will be where I change it and what I change for the situtations, I do these changes one at a time and revert them after I have tested that run. The results from this will be in usual-power-saving. 

Default: nvme.noacpi=0, i915.enable_psr=2, PCIE_ASPM_ON_BAT=default, Displayport Card

- Kernel Command Line: nvme.noacpi=1,i915.enable_psr=0,i915.enable_psr=1
- TLP Settings: PCIE_ASPM_ON_BAT=powersupersave
- Hardware Changes: No Display Port Card

## Results Desktop

### Fall to idle rate
So after we have compiled the resources what can we see? Firstly we have the untrimmed image which you can find below, as we can see we start with a spike, this makes sense as it's the computer starting up so that requires more power. However what is interesting is how long it takes for each one to reach an idle state. Firstly we see that the No DisplayPort peaks by far the lowest and reaches a low idle state the fastest, I have to make assumptions but I presume when the display port card is plugged in and it boots up it first spikes to it's maximum usage, but then decreases because it goes into a sleep mode, but without the Displayport card this never happens so it can reach this state faster.

Next we can see that the default settings are the second fastest to climb to a low idle state, I presume this is because of it's use of PSR2 which has optimized algorithms for detecting when it should go to sleep. While we can see the when we enable PSR1 it first hangs a bit at a higher usage before climbing down into a low idle state. Next we see that both noacpi and PCIE_SUPERSAVE make very little diffrence in the time it takes for it to reach a low idle state.

![Image 1](/stetsed-guides/untrimmed-desktop-power.png)

### Idle Rate

Nextly I have trimmed the first 100 seconds off so we can have a closer look at the idle rates of consumption. You can see this chart in the below image, we are going to go ahead and ignore the few that are still high at the beginning and focus more on the rest. Firstly let's get the obvious out of the way, disabling PSR by setting it to 0 while having desktop effects such as blur etc makes your battery life abismal so whenever you can use atleast PSR1. Next whatever PCIE_SUPERSAVE is doing is clearly messing something up. It spikes every so often which could in my theory be caused by it putting something to sleep, that thing being required and it taking energy to wake it back up from sleep. Nextly we see that there is some spike in my config at around the time of 320, but it seems to be consistent over all runs so I am unsure what caused it besides some sort of background process.

We can also see that the winner of lowest power is no display port, it stays about 0.1-0.2w below the others in this table, this probally means that although the V2 display port card is an improvement it's still not using no power but this is to be expected, but it's still alot better than V1 and as it only requires a flashing it's highly recommended to update your V1 to a V2 if you can which you can find instructions for [here](https://guides.frame.work/Guide/DisplayPort+Expansion+Card+Power+Saving+Firmware+Update/194?lang=en), as before it used anywhere from 1-3w extra.

Looking at the rest we don't see much of a diffrence in terms of usage with them all flucuating at around 3.5w of usage.

![Image 2](/stetsed-guides/trimmed-desktop-power.png)

## Momentary Conclusion
So with this part of our Experiment done it seems like we can come to a momentary conclusion. Firstly enabling even PSR1 is miles better than not having it enabled, although this might differ if you don't have blur or other such things on your desktop. And although PSR1 and PSR2 might in the end reach basically the same idle state PSR1 takes longer to get there which is most likley due to improved algorithms in PSR2

Secondly the V2 Displayport card is a massive improvement in terms of power usage, although I didn't do the same test before updating the card when I had that I could see anywhere from 1-3w extra power usage when having it plugged in which can be massive especially for idle usage.

Lastly the other 2 settings we tested those being PCIE_SUPERSAVE and nvme.noacpi=1, the the first one leads to varied results and has momentary spikes which might be it being too agressive with it putting devices to sleep. nvme.noacpi=1 didn't seem to make any real diffrence in this experiment using the SN770 but generally I would advise against it as it tells the SSD to not use it's ACPI tables which for a few SSD's can reduce power usage but if your using the SN770 or other SSD's which have good power managment then it can either do nothing or harm your power usage.


## Todo
* Measure all scenarious while watching a video in browser
* Measure all scenarious while doing a simulated real life use case
  * Create a script to simulate browsing, text editing, and other workspace activities.


