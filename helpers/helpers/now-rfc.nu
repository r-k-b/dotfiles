#!/usr/bin/env nu

let rfc = (date now | format date "%+")
let epoch = (date now | format date "%s" | numfmt --grouping)
$"($rfc) | unix time ($epoch)"

