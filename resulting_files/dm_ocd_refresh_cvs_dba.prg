CREATE PROGRAM dm_ocd_refresh_cvs:dba
 SET fname = build("dm_ocd_refresh_cvs_",cnvtstring(ocd_number),".dat")
 SELECT INTO value(fname)
  d.*
  FROM dual d
  DETAIL
   "set x=0 go"
  WITH nocounter, maxrow = 1, maxcol = 80,
   format = variable, formfeed = none
 ;end select
END GO
