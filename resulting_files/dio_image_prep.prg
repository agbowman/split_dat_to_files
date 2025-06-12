CREATE PROGRAM dio_image_prep
 PROMPT
  "Enter output file = " = "dio_image"
 FREE DEFINE rtl2
 DEFINE rtl2 concat("ccluserdir:",trim( $1),".eps")
 SELECT INTO concat("ccluserdir:",trim( $1),".xps")
  FROM rtl2t r
  WHERE r.line != " "
  DETAIL
   ",^{PS/",
   CALL print(trim(check(r.line))), "/}^, row+1",
   row + 1
  WITH counter, noheading, format = variable,
   maxcol = 255, noformfeed, maxrow = 1
 ;end select
 FREE DEFINE rtl2
END GO
