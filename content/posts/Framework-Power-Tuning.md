---
title: "Framework Power Tuning"
date: 2023-05-19T12:08:19+02:00
draft: false
---

This guide will show you how to tune your framework laptop on linux to achieve better performance life using TLP 

Firstly go ahead and install tlp on your platform, below are some examples for common platforms.

# TLP

```bash
# Fedora
dnf install tlp
# Need to remove the default PPD
dnf remove power-profiles-daemon

# Arch
pacman -Syu tlp

# Ubuntu
apt install tlp

```

After this we can configure the basic power saving settings, we are assuming you have intel_pstate driver which you can check with "cpupower frequency-info" and is the default for Arch, Fedora and Ubuntu. Load the below snippet into 01-basic.conf in /etc/tlp.d/

```conf
# Set the governor to performance on AC power and Powersave on battery, we are using pstate so it's about as effective as Schedutil on the normal linux drivers.

CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# Set the CPU energy/performance policies, we don't want to use power because this limits the CPU freq to 400Mhz which gives very bad performance, so we put it to balance_power.
CPU_ENERGY_PERF_POLICY_ON_AC=performance
CPU_ENERGY_PERF_POLICY_ON_BAT=balance_power

# Set intel CPU HWP dynamic boost, which gives us a slight increase in effiency. Remove this if your on AMD or not in intel_pstate
CPU_HWP_DYN_BOOST_ON_AC=1
CPU_HWP_DYN_BOOST_ON_BAT=1
```

Now the above is what gives us most of a boost, but the below you can also add. Please read the notes as some of it might not be wanted.

```conf
# Tells the PCIE Active State Power Managment to basically try to preserve as much power as possible, mixed results with this as sometimes it works other times it doesn't. Make sure to test this one as sometimes it leads to a watt or 2 HIGHER usage.
PCIE_ASPM_ON_BAT=powersupersave

# Limits the Max Frequency of the CPU on AC power so that it doesn't overheat. Modify this value and see where you find the sweet spot due to the silicon lottery this will be diffrent for everybody. Note that in a multi core workload 2 cores will still hit 100C, while the rest for me stay at around 80 with this frequency.
CPU_SCALING_MAX_FREQ_ON_AC=4200000

# If your experiencing WiFi dropouts add the below to your config file, it will disable WiFi power saving mode. Personally I do not need to use this
WIFI_PWR_ON_BAT=off
```

Now go ahead and enable the service with "systemctl enable --now tlp" and you should be saving alot of power!. I hope this guide helped and if it did you can leave a star on the [Repository](https://github.com/Stetsed/stetsed-guides). You can test how much power your device uses with the below command.

```bash
sudo intel_undervolt measure
```

## Results

This is at 50% brightness, using a 1TB SN770, 2x16GB 3600MHz DDR4 RAM, i5-1240p with 2xUSB-C and 1xUSB-A

Configuration:

- Hyprland
- Waybar
- Librewolf With Graphics Acceleration
- Neovim

[Dotfiles](https://github.com/Stetsed/.dotfiles)

|  Info   | Idle    | Editing Text Documents    | Scrolling Through Documents    | Watching 1080p Videos    |
|---------------- | --------------- | --------------- | --------------- | --------------- |
| Before TLP   | 7-8w    | 8-10w    | 10-14w    | 10-13w   |
| After TLP | 2-3w | 4-6w  |  7-9w | 10w   |

## Enable GPU Acceleration

To enable GPU acceleration for any firefox based browser following the below steps

1. Install intel-media-driver 
```bash
# Fedora
dnf install intel-media-driver

# Arch
pacman -Syu intel-media-driver

# Ubuntu
apt install intel-media-va-driver
```
2. Check about:support and check if compositing value is "WebRender", if it is not when we are in about:config later add gfx.webrender.all as a true value to force it to use it.
3. Go into about:support of your firefox browser by entering it into the URL bar.
4. Set "media.ffmpeg.vaapi.enabled" to true
5. If you are running wayland start firefox with the enviroment variable set "MOZ_ENABLE_WAYLAND" to 1.

Using GPU Acceleration before adding TLP dropped usage from about 20w to 10-13w.

# Other Optimizations

Press FN + Space to disable Keyboard backlight which usually saves around 0.5w.

# Other Guides

- Framework Official Guides: [Ubuntu](https://knowledgebase.frame.work/en_us/optimizing-ubuntu-battery-life-Sye_48Lg3) & [Fedora](https://knowledgebase.frame.work/en_us/optimizing-fedora-battery-life-r1baXZh)
- [Framework Forum Battery Life Thread](https://community.frame.work/c/framework-laptop/linux/)

- [Arch Linux Hardware Video Acceleration Wiki](https://wiki.archlinux.org/title/Hardware_video_acceleration)

- [Arch Linux Framework Wiki](https://wiki.archlinux.org/title/Framework_Laptop_13)


