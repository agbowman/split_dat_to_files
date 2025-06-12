CREATE PROGRAM dvd3
 PROMPT
  "Output to" = "MINE"
  WITH outdev
 TRANSLATE INTO  $OUTDEV bhs_genview_immun_check_amb:dba
END GO
