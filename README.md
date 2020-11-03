# Crystal Lang QR Code

[![Build Status](https://travis-ci.com/spider-gazelle/qr-code.svg?branch=master)](https://travis-ci.com/github/spider-gazelle/qr-code)

Native crystal lang QR code, no external dependencies

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     qr-code:
       github: spider-gazelle/qr-code
   ```

2. Run `shards install`


## Uasge

```crystal
require "qr-code"

qr = QRCode.new("my string to generate", size: 4, level: :h)
puts qr.to_s

```

output

```
xxxxxxx x  x x   x x  xx  xxxxxxx
x     x  xxx  xxxxxx xxx  x     x
x xxx x  xxxxx x       xx x xxx x
... etc
```


### Doing your own rendering

```crystal
require "qr-code"

qr = QRCode.new("my string to generate", size: 4, level: :h)
qr.modules.each do |row|
  row.each do |col|
    print col ? '#' : ' '
  end

  print "\n"
end
```


### Rendering an SVG

```crystal
require "qr-code"

svg_string = QRCode.new("my string to generate").as_svg
```


## Credits

Based off the ruby gem: https://github.com/whomwah/rqrcode_core
Which was adapted from the javascript library: https://github.com/kazuhikoarase/qrcode-generator
