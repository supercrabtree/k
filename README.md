![k](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHAAAABwCAYAAADG4PRLAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAABK5JREFUeNrsnbFO21AUhm/SqqKIIagDlSpUI1WqOuFMrbrEPEBF2DomMwtI3TqQNzA8QRjYE54A5wnipVOHZOzUpB3bwfWx7qUXlyDROCH/9f9LRyYxhHC+/Cf3HNuhohYjLxeihrW/loav3FKcxtS6PdDbcS4KVaWAxxAYgQbk66gp6jZNNehYA45y0JcmAdRKo5dGwpgrejqXS3nRSznspjFh4guPic6ttyh4HYJbGshOkeDkPW3IxC49hkUs9Hy67sHd6BNeCSESHgjEWX1gIfWXKnxQUM/f+WjGavMj87Vyeq4NF93lQE+7j5OU1Z3k1O2RXN6BYRrvmKeV1Zo21+VtDpQdI7oPwoU7ZoZatXY0CQ9CNc1K5QHuMzcw2s+X0JruNSgcbUoZNQ4MmA84BXYJbTAfcGrYADl1wZNvvwcmzAekKlW2DtgtRZXlE7uMCkAPZt38uam2Lg6J7a88KIBP3rxQa29fEVsOIAWsKntA7F6QDnTAgRQBUg8JMGAaYBXQgSyhFAFSBEiAFAFSBEgRIAFSBEgtS4+ZgpvyfV/VajU1Ho+zoAOB1Gw21XA4VL1eL4PIEgrmvG63q6bTqdrb21NxHLOEIsG7urrKXHdwcAADjw5MJdBMyWy326rf73MVigRPnOd5Xgbv/PycbQQaPCmfp6enkPCMYD4vZeviMHn5NSzksdIFSyKSrcL+DJnyAXQIXvkAhmGYwUv7vSQtowSIBLDVarkGDwvgPGHgjUYjl+BhAXz/7Hny6XU92V7fuNfPpSvNDN5kMsm+duzFifNkBd63D+0M5H3gCThH4SVOj9LsERnSfJONvG7UZThtRmRRFDn5d1ZdhWemLKgjslIDlOG0CyOyUgKUshkEQQbu+PjY+Zlu1TV4ab+XwZPSWQY5A/Do6CiDJyvNMjjPOYC7u7vZVgDKaRFlkTN9oCmZ4kL7Nh0IJCmd4kCBKCWVAMFkn1EWhuG1GwkQEKKclGtWpQQICFFOD5StQJSmngDBJGVUnCgQzViNAAEhihPt2SgBgkmOQkhLYR+dIEAwmdGafXyQAAEhShiIBAgoc2zQXInkgkp3dZJ5P3Rl5FbKayMEmhm5dTodAkRs9M3I7eTkBHpaU9qrkwxEM61BhVjq6wPzEBEb/dJfoYs+cuOHHGiIciwRceRGgFajjzhyk/9eJmOJAOHJbq9vqO2nG+rLz+/qx+9fC/kdYB/0E0EBpP4FyBIKLgJ0AOCAaYDVgA50wIFjpgFWYwIEByhthHSsE+YCUpv8N+TYqphFTMRc4DXxdh8YMx9wim2A7AUBe8CshuobXMgALmDSmBoHyiWtfeYERn3N7MYs9JJ5gdE1q4p1p5TRkd5Sqytx3s5tDmQZBSufeQeKvDSGdOFKu6+urPFn/miE7DhjnlZWZyo3u67M+EZxoc98rVzjXs/fOet4YNuus9RKlM57X4Xj6+Y+YTxoTOaphoQIDM+GOGQylx6Fr0M6dOPSXNdZ1Jup9IldglwYuK7O8cIljX4rjR4TP3f0dC7/a3hSKQhmkEZD12yfk5w724FYhxzPi+Zt1yoLLLV2KA3Yhu7aoCDOwRhY0y07CtUfAQYAMBE56OwO18MAAAAASUVORK5CYII=)


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

## Minimum Requirements
zsh 4.3.11  
Git 1.7.2

## Contributers
Pull requests welcome.  
[supercrabtree](https://github.com/supercrabtree) 56  
[chrstphrknwtn](https://github.com/chrstphrknwtn) 38  
[zirrostig](https://github.com/zirrostig) 19  
[lejeunerenard](https://github.com/lejeunerenard) 2  
[george-b](https://github.com/george-b) 1  
[pixcrabtree](https://github.com/pixcrabtree) 1  
[jozefizso](https://github.com/jozefizso) 1  
[philpennock](https://github.com/philpennock) 1  
[hoelzro](https://github.com/hoelzro) 1  
[srijanshetty](https://github.com/srijanshetty) 1  
[mattboll](https://github.com/mattboll) 1  

Would really like to make this posix complient so that it can be used with bash, and others. But don't really know anything about shell scripting, so if you think you could help that would be cooool :)

## Thanks
[Paul Falstad](http://www.falstad.com/) for zsh  
[Robby Russell](https://github.com/robbyrussell) for making the shell fun with oh my zsh  
[Sindre Sorhus](https://github.com/sindresorhus) for fast git commands from zsh pure theme  
[Rupa](https://github.com/rupa/z) for that slammin' strapline  

Copyright © 2014 George Crabtree & Christopher Newton. MIT License
