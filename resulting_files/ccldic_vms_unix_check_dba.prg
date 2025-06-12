CREATE PROGRAM ccldic_vms_unix_check:dba
 IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2)=80700))
  SELECT INTO "ccldictmp3"
   data = fillstring(850," ")
   FROM dummyt
   DETAIL
    data
   WITH counter, noformfeed, maxrow = 1,
    maxcol = 851, append, format = fixed
  ;end select
 ENDIF
END GO
