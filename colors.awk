# Processes a (somewhat modified) X11 color chart
# and produces a color scheme that LibreOffice
# can use instead of its own.
#
# The input table can have empty lines.
# Fields are separated by spaces.
# Lines with a single field are color prefixes.
# Lines with seven fields have:
#   $1 = color name
#   $2 to $4 = R, G, B in hex
#   $5 to $7 = R, G, B in decimal
#
# Federico Kereki, 09/22/2012

BEGIN {
  # We'll create 8 variations of each color; 4
  # lighter ones, plus the original color, plus 3
  # darker ones. We'll split the range between the
  # color and black or white in 6 steps, so there
  # will be a margin between the extremes and our
  # variations.
  VARIATIONS = 8
  INITIAL = 4
  STEPS = 6

  # The following constants come in handy
  # to shorten printf lines for publication
  DC = "draw:color"
  DN = "draw:name"
  UR = "urn:oasis:names:tc:opendocument:"
  XM = "xmlns:"

  # Print the header for the color table
  printf "<?xml version='1.0' " \
    "encoding='UTF-8'?>\n" \
    "<ooo:color-table\n" \
    XM "office='" UR XM "office:1.0' \n" \
    XM "draw='" UR XM "drawing:1.0'\n" \
    XM "xlink='http://www.w3.org/1999/xlink'\n" \
    XM "svg='http://www.w3.org/2000/svg'\n" \
    XM "ooo='http://openoffice.org/2004/office'>\n"
}


NF==1 {
  colorPrefix = $1
}

NF==7 && colorPrefix=="BASIC" {
  printf "<" DC " " DN "='BASIC/%s' " \
    DC "='#%02x%02x%02x'/>\n", \
    $1, $5, $6, $7
}

NF==7 && colorPrefix!="BASIC" {
  for (i=INITIAL; i>INITIAL-VARIATIONS; i--) {
    if (i<0) {
      red = $5 + round(i * $5 / STEPS)
      green = $6 + round(i * $6 / STEPS)
      blue = $7 + round(i * $7 / STEPS)
    } else {
      red = $5 + round(i * (255-$5) / STEPS)
      green = $6 + round(i * (255-$6) / STEPS)
      blue = $7 + round(i * (255-$7) / STEPS)
    }

    if (i==0) {
      printf "<" DC " " DN "='%s/%s' " \
        DC "='#%02x%02x%02x'/>\n", \
        colorPrefix, $1, red, green, blue
    } else {
      printf "<" DC " " DN "='%s/%s%+i' " \
        DC "='#%02x%02x%02x'/>\n", \
        colorPrefix, $1, i, red, green, blue
    }
  }
}


END {  
  # Print the footer for the color table
  print "</ooo:color-table>\n"
}


function round(r) {
  return int(0.5 + r);
}

