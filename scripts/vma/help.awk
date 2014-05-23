BEGIN {
  debug_level=0
  section=""
  split("", dataarr)
  dataarrc=0
  # array of sections that we print
  sectarr[0]="Script"
  sectarr[1]="Purpose"
  sectarr[2]="Usage"
  sectarr[3]="Examples"
  first_section=0
  # should we print new line after section
  new_line_after_section=1
  # should we ignore empty lines
  ignore_empty_lines=1
}

# Search for comments
/^--/ {
  # start of new section
  if($0 ~ /^--[ 	]*((\w+ )?\w+:)/) { 
    debug( "new section")
    # if section not empty, we print that section
    if(section!="") { 
      print_section()
    }
    # extract section information
    section=gensub(":.*", "", "g", gensub("^--[ 	]*", "", "g", $0))
    push_array()
  } 
  else {
    push_array()
  }
}

# Exit on first non comment string
$0 !~ /^--/ { exit }

END {
}

# extend data array
function push_array() {
  lline=$0
  debug( "push array invoked")
  if(section!="") {
    if(!ignore_empty_lines) {
      dataarr[dataarrc++]=gensub("^--", "", "g", lline)
    } else {
      # ignore empty llines
      if(gensub("^--[ 	]*$", "", "g", lline)!="") {
        debug("non empty lline")
        dataarr[dataarrc++]=gensub("^--", "", "g", lline)
      } else {
        debug("empty")
        debug("_"gensub("^--[ 	]*$", "", "g", lline)"_")
      }
    }
  }
}

# generic print section routine
function print_section() {
  need_print=0
  debug( "section="section)
  debug( "routine print_section invoked")
  for(k in sectarr) {
    if(section ~ sectarr[k]) { need_print=1 }
  }
  if(need_print) { debug("need print") } else { debug("not need print") }
  if(need_print) {
    # add empty line on first section
    if(!first_section++) { print "" }
    for(i=0;i<dataarrc;i++) {
      printf(" %s\n", dataarr[i])
    }
    if(new_line_after_section) { print "" }
  }
  dataarrc=0
}

# debugging routine
function debug(pstr) {
  if(debug_level) { print pstr }
}
