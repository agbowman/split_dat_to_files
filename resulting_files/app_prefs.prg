CREATE PROGRAM app_prefs
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
  a.active_ind, a.application_number, a.app_prefs_id,
  a.position_cd, a_position_disp = uar_get_code_display(a.position_cd), a.prsnl_id,
  a.updt_applctx, a.updt_cnt, a.updt_dt_tm,
  a.updt_id, a.updt_task
  FROM app_prefs a
  WHERE a.position_cd > 0
   AND a.application_number=600005
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
  WITH maxrec = 1000, maxcol = 300, maxrow = 500,
   dio = 08, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
