CREATE PROGRAM dm_calculate_days:dba
 SET target_size = (target_size * 0.9)
 SET ndays = floor(((target_size - tstatic)/ tbytes_day))
 IF (ndays < 90)
  SET tempstr = fillstring(132," ")
  SET fname = "dm_calculate_sizing2.log"
  SELECT INTO value(fname)
   *
   FROM dual
   DETAIL
    tempstr = "Number of days less than a quarter ...... Aborting", tempstr, row + 1,
    tempstr = "Please increase the database size and run sizing again", tempstr, row + 1
   WITH nocounter, maxcol = 512, formfeed = none,
    maxrow = 1
  ;end select
 ENDIF
END GO
