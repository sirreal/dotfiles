dotfiles
========

These are the dotfiles I've created for personal use. Please, use them, improve them, and share your improvements with me and the world.

## Behavior
Here's the idea:

*  Files in `link/` will be linked to your home directory (`~/`).
*  Files in `source/` will be sourced at shell login.
*  `setup/install/` contains installation lists for stuff I use and want installed on all my systems.

## Usage

1.  Clone this baby into your home directory:

  `cd ~; git clone https://github.com/SirReal/dotfiles.git .dotfiles`

2.  Customize
  *  Specifically, you're not me, so update the file at `~/.dotfiles/link/.gitconfig` with your info.
  *  More stuff?

### Cool linking tricks

This is very very alpha. I've been working on it on OSX and Debian Linux (Xubuntu) and so far so good, but don't plop it into your sever somewhere and blame me when it breaks everything.

So it's no big deal to just link everything in `link/` to your home directory. Here's where I got a bit ambitious and things get interesting. You can define custom linking locations by adding a file with the same name and appending `.target`, or customize for different os's (I use `.osx_target` and `.linux_target`). This should include the __relative path from ~/ to the actual link__ you want to create (not just the directory). Check out a few examples:

I wanted to be able to link a terminalrc file used in my [Xubuntu](http://xubuntu.org/) setup to somewhere off the beaten path. I also wanted to not clutter my OSX setup with that unneeded junk. Simple, stick the file directly into `link/` just add the file and give it 2 directives, one for linux and another empty global directive:

```
$ cd ~/.dotfiles/link
$ echo ".config/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" > xfce4-keyboard-shortcuts.xml.linux_target
$ touch xfce4-keyboard-shortcuts.xml.target
```
The .linux_target will be read on linux to set the link, and other systems will see the empty .target and abort linking.

Also useful for things like Sublime Text which have configuration directories in different places on different systems. I have a directory `ST3User/` in mr `link/` directory, with different directives for linux_target and osx_target.

## Inspiration
Big thanks to these cats:

*  mathiasbynens/dotfiles
  *  OSX setup is great
  *  general configuration stuff
*  cowboy/dotfiles
  *  I shamelessly stole the structure from @cowboy
