BEGIN { s=0; FS = " "} { nl++ } { s=s+$c } END \
{print "sum = " s "; N = " nl "; Avg = " s/nl}