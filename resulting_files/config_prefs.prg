CREATE PROGRAM config_prefs
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 60
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  c.config_name, c.config_prefs_id, c.config_value,
  c.flexed_by, c.parent_entity_id, c.parent_entity_name,
  c.rowid, c.updt_applctx, c.updt_cnt,
  c.updt_dt_tm, c.updt_id, c.updt_task
  FROM config_prefs c
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
  WITH maxrec = 100, maxcol = 300, maxrow = 500,
   dio = 08, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
