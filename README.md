![k](https://raw.githubusercontent.com/supercrabtree/k/master/k-logo.png)

> k is the new l, yo

## Directory listings for zsh with git features. 
k is a zsh script to make directory listings more readable, adding a bit of color and some git information.

### Git status on entire repos
Red for dirty, green for committed.

Turns this:  
![repos-ls](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/repos-ls.jpg)

Into this:  
![repos-k](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/repos-k.jpg)

### Git status on files within a working tree
Red for dirty, green for committed, orange for untracked, grey for ingored.

Turns this:  
![status-ls](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/status-ls.jpg)

Into this:  
![status-k](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/status-k.jpg)

### File weight colours
Files sizes are graded from green for small (< 1k), to red for huge (> 1mb).

Turns this:  
![status-ls](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/size-ls.jpg)

Into this:  
![status-k](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/size-k.jpg)

### Rotting dates

Dates fade with age.  
![repos-k](https://raw.githubusercontent.com/supercrabtree/k/gh-pages/repos-k.jpg)


## Usage
Put `k.sh` somewhere, and source it in your `.zshrc`.

```shell
source ~/path-to/k/k.sh
```

hit k

```shell
k
```

profit

## Requirements
zsh >= 4.3.11
Git >= 1.7.2


## Thanks
[Paul Falstad](http://www.falstad.com/) for zsh  
[Robby Russell](https://github.com/robbyrussell) for making the shell fun with oh my zsh  
[Sindre Sorhus](https://github.com/sindresorhus) for fast git commands from zsh pure theme  
[Rupa](https://github.com/rupa/z) for that slammin' strapline  

## Contributing
Pull requests welcome.

Copyright © 2014 George Crabtree & Christopher Newton. MIT License
