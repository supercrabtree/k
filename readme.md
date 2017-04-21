[![k.supercrabtree.com](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/k-logo.png)](http://k.supercrabtree.com)

> k is the new l, yo

## Directory listings for zsh with git features

**k** is a zsh script / plugin to make directory listings more readable, adding a bit of color and some git status information on files and directories.

### Git status on entire repos
![Repository git status](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/repo-dirs.jpg)


### Git status on files within a working tree
![Repository work tree git status](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/inside-work-tree.jpg)

### File weight colours
Files sizes are graded from green for small (< 1k), to red for huge (> 1mb).

**Human readable files sizes**  
Human readable files sizes can be shown by using the `-h` flag, which requires the `numfmt` command to be available. OS X / Darwin does not have a `numfmt` command by default, so GNU coreutils needs to be installed, which provides `gnumfmt` that `k` will also use if available. GNU coreutils can be installed on OS X with [homebrew](http://brew.sh):

```
brew install coreutils
```

![File weight colours](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/file-size-colors.jpg)


### Rotting dates
Dates fade with age.  

![Rotting dates](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/dates.jpg)


## Installation

### Using [zplug](https://github.com/b4b4r07/zplug)
Load k as a plugin in your `.zshrc`

```shell
zplug "supercrabtree/k"

```
### Using [zgen](https://github.com/tarjoilija/zgen)

Include the load command in your `.zshrc`

```shell
zgen load supercrabtree/k
zgen save
```

### Using [Antigen](https://github.com/zsh-users/antigen)

Bundle k in your `.zshrc`

```shell
antigen bundle supercrabtree/k
antigen apply
```

### As an [Oh My ZSH!](https://github.com/robbyrussell/oh-my-zsh) custom plugin

Clone k into your custom plugins repo

```shell
git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k
```
Then load as a plugin in your `.zshrc`

```shell
plugins+=(k)
```

### Manually
Clone this repository somewhere (~/k for example)

```shell
git clone git@github.com:supercrabtree/k.git $HOME/k
```
Source the script

```shell
source $HOME/k/k.sh
```
Put the same line in your `.zshrc` to have `k` available whenever you start a shell. If you don't know what your `.zshrc` is, just do this.

```shell
print "source $HOME/k/k.sh" >> $HOME/.zshrc
```

## Usage
Hit k in your shell

```shell
k
```
# 😮

## Minimum Requirements
zsh 4.3.11  
Git 1.7.2

## Contributors
[supercrabtree](https://github.com/supercrabtree)  
[chrstphrknwtn](https://github.com/chrstphrknwtn)  
[zirrostig](https://github.com/zirrostig)  
[lejeunerenard](https://github.com/lejeunerenard)  
[jozefizso](https://github.com/jozefizso)  
[unixorn](https://github.com/unixorn)  
[george-b](https://github.com/george-b)  
[philpennock](https://github.com/philpennock)  
[hoelzro](https://github.com/hoelzro)  
[srijanshetty](https://github.com/srijanshetty)  
[zblach](https://github.com/zblach)  
[mattboll](https://github.com/mattboll)  
Pull requests welcome :smile:  

## Thanks
[Paul Falstad](http://www.falstad.com/) for zsh   
[Sindre Sorhus](https://github.com/sindresorhus) for the fast git commands from zsh pure theme  
[Rupa](https://github.com/rupa/z) for that slammin' strapline  

Copyright © 2015 George Crabtree & Christopher Newton. MIT License.
