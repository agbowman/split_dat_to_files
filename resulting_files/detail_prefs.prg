CREATE PROGRAM detail_prefs
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
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  d.active_ind, d.position_cd, d_position_disp = uar_get_code_display(d.position_cd),
  d.application_number, d.comp_name, d.view_name,
  d.comp_seq, d.detail_prefs_id, d.person_id,
  d.prsnl_id, d.updt_applctx, d.updt_cnt,
  d.updt_dt_tm, d.updt_id, d.updt_task,
  d.view_seq
  FROM detail_prefs d
  WHERE d.position_cd > 0
  ORDER BY d_position_disp, d.comp_name, d.view_name,
   d.application_number
  HEAD REPORT
   y_pos = 18,
   SUBROUTINE offset(yval)
     CALL print(format((y_pos+ yval),"###"))
   END ;Subroutine report
  HEAD PAGE
   y_pos = 36
  WITH maxcol = 300, maxrow = 500, dio = 08,
   format, separator = value(_separator), time = value(maxsecs),
   skipreport = 1
 ;end select
END GO
