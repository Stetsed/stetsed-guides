---
title: "Hugo Blog With Github Actions"
date: 2023-06-20T09:06:38+02:00
draft: false
tags: ["Blog", "Hugo", "Github Actions"]
---

Hey everybody, per a request from the Reddit post I made asking for idears which can be found [here](https://www.reddit.com/r/selfhosted/comments/14daj2x/what_are_some_guides_you_guys_would_like_to_see/). I have decided to explain how to setup a Hugo Blog like I have done with this blog. We will be using the papermod theme which can be found [here](https://github.com/adityatelange/hugo-PaperMod). I will also be using Github Actions to automatically build and deploy the blog to github pages. Nothing would stop you from deploying this to your own server using something like NGINX, and I may make a follow up post on how to do this. 

Let's get started!

## Prerequisites
- Github Account
- Computer with Git installed and SSH/HTTPS access to your Github account

## Section 1 - Setup

### Step 1 - Creating the repository

Firstly we will need to go ahead and create a repository, we can do this by first going to [Github](https://github.com) and then logging in. Then at the top left you will want to click on "New" which will let us make a new repository. You can name it whatever you want but if you do not have a custom domain you will plan to use the URL will be https://(username).github.io/(repo-name)/ so keep that in mind when naming it. Do not add a license or a README.md as we can add those later. Now click create repository.

### Step 2 - Installing Hugo

Firstly we will want to go ahead and install hugo from our preffered package manager, I will assume your on linux and have posted examples for common linux distro's below. If you are on windows I would recommend using WSL to follow along with this guide.

```bash
# Arch Linux
pacman -Syu hugo

# Fedora
dnf install hugo

# Debian/Ubuntu
apt install hugo
```

* For other distro's please check the [Hugo Docs](https://gohugo.io/installation/linux/).

### Step 3 - Intializing the Hugo Project

Next we will want to go ahead and intialize the hugo project. So go to a folder that you wanna store it in and run the first command below. This will generate our hugo project and then we will want to go ahead and clone the theme we are using into the themes folder. Which will be command 2 below. And then lastly we want to add the theme to our hugo.toml which will be command 3 below. Note the toml section can contain ALOT of options so please reffer to my [config.toml]() for an example. Or you could switch to yml if you prefer that. An example yml file can be found [here](https://github.com/adityatelange/hugo-PaperMod/wiki/Installation#sample-configyml).


```bash
# Initialize the hugo project
hugo new site (repo-name)

# Enter the directory
cd (repo-name)

# Intialize Git Repository
git init

# Clone the theme
git clone https://github.com/adityatelange/hugo-PaperMod themes/PaperMod --depth=1

# Add the theme to hugo.toml
echo 'theme = "PaperMod"' >> config.toml
```

### Step 4 - Configure pushing to the git repository

Firstly go ahead and create a README.md and a LICENSE file, what LICENSE you pick will be up to you but if you don't care then I would recommend [UnLicense]() which basically says "Do whatever the hell you want". Now we will first want to create a .gitignore file and add the following to it.

```gitignore
# Generated files by hugo
/public/
/resources/_gen/
/assets/jsconfig.json
hugo_stats.json

# Executable may be added to repository
hugo.exe
hugo.darwin
hugo.linux

# Temporary lock file while building
/.hugo_build.lock
```

After this go ahead and run command number 1 which will add all files that aren't in the gitignore to the repository.Then go ahead and run command number 2 which will create our initial repository. Then we will run the next few commands to add the remote repository and push our intial commit to it.
```bash
# Add all files to the repository
git add -A

# Commit the files
git commit -m 'First Commit'

# Change Branch
git branch -M main

# Add remote repository
git remote add origin https://github.com/(username)/(repository).git

# Or if you are using SSH
git remote add origin git remote add origin git@github.com:(username)/(repository).git

# Push to the remote repository
git push -u origin main
```

## Section 2 - Configuring Github Actions and pages

### Step 1 - Creating the Github Action

Next we will want to go ahead and create our github action. You can go ahead and copy the github action that I use from [here](https://github.com/Stetsed/stetsed-guides/blob/main/.github/workflows/hugo.yml) and add it to your repository at .github/workflows/hugo.yml. Next we will want to go ahead and add a nojekyll file to prevent github from trying to generate a jekyll site. So go ahead and touch .nojekyll. Now we will want to go ahead and commit and push these changes to the repository.
```bash
# Touch the nojekyll file
touch .nojekyll

# Add all files to the repository
git add -A

# Commit the files
git commit -m 'Added Github Action'

# Push to the remote repository
git push
```

### Step 2 - Enabling Github Pages

Go ahead and go to Your Repository > Settings > Pages. Source to be github actions. This will make it pull from the github actions which we used earlier and it should work :D

## Section 3 - Post Setup

You can now go ahead and start writing posts and adding them to the content folder. You can also go ahead and configure the config.toml file to your liking. I would recommend checking out the [Hugo Docs](https://gohugo.io/documentation/) for more information on how to do this. Now whenever you push it will automatically build and deploy your blog to github pages. Which you can find at https://(username).github.io/(repo-name)/ assuming your not using a custom domain which you can configure in Github Pages.

```bash
# Generate a new post
hugo new posts/(post-name).md
```

I hope this guide was helpful for people trying to setup Hugo and I hope you have a lovely day.



