#!/bin/sh

build_number=$1

for file in tmp/junit_reports/*.xml; do
  output_file=`echo "${file}" | sed -e "s/.xml$/.html/"`
  xsltproc -o "${output_file}" support/tools/base.xsl "${file}"
done

cat <<BEGIN_HTML_TEMPLATE
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
   <title>Test results</title>
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
   <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
   <script type="text/javascript"><!--
    \$(function() {   
      \$("pre").hide();
      \$("a.type").click(function(e) {
        \$(this).next().toggle();
      })
    })
    --></script>
   <style type="text/css"><!--
   body { font-family: 'Helvetica Neue', 'Liberation Sans', Arial, sans-serif; }
   #test { clear : both; }
   h2 { font-size: 1.2em; font-weight: bold; clear:both;margin-top:1.5em;
   padding:0;}
   pre {
    background: #E4EBEF;
    border: 1px dashed #A4C3D4;
    color: black;
    font-size: 1.2em;
    font-weight: bold;
    margin-bottom: 1em;
    padding: 1em;   
   }
   ul { margin : 0; padding : 0; }
   ul li { list-style-type : none; clear : both;}
   span.timing {
      float : left; 
      width : 9ex;
      background : #A4C3D4;
      color : #fff;
      font-weight : bold;
      padding : 0.2em;
    }
   .failure span.timing { background : #BA3335 }
   span.name {
    float : left;
    padding-left : 1ex;
   }
   .failure span.name { color : #BA3335 }
   a.type { color : #BA3335; font-weight : bold; display:block;
   margin-left: 10ex;padding-left:0.3em;}
   --></style>
  </head>
  <body>
  <h1>deltacloud-core build #$build_number</h1>
BEGIN_HTML_TEMPLATE
cat tmp/junit_reports/*.html
cat <<END_HTML_TEMPLATE
  </body>
</html>
END_HTML_TEMPLATE
