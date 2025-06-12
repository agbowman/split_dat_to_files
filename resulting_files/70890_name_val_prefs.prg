CREATE PROGRAM 70890_name_val_prefs
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
 SELECT INTO  $OUTDEV
  v.application_number, v.frame_type, v.position_cd,
  v_position_disp = uar_get_code_display(v.position_cd), v.view_name, v.view_prefs_id,
  v.view_seq, n.name_value_prefs_id, n.parent_entity_id,
  n.parent_entity_name, n.pvc_name, n.pvc_value,
  n.updt_id, n.updt_applctx
  FROM view_prefs v,
   name_value_prefs n
  PLAN (v
   WHERE v.active_ind=1
    AND v.application_number=600005
    AND v.position_cd > 0
    AND v.position_cd != 925860
    AND v.position_cd != 925865
    AND v.position_cd != 925864
    AND v.position_cd != 925858
    AND v.position_cd != 925857
    AND v.position_cd != 925862
    AND v.position_cd != 925861
    AND v.position_cd != 925856
    AND v.position_cd != 925859
    AND v.position_cd != 925863
    AND v.frame_type="CHART")
   JOIN (n
   WHERE n.active_ind=1
    AND v.view_prefs_id=n.parent_entity_id
    AND n.parent_entity_name="VIEW_PREFS"
    AND n.pvc_name="VIEW_CAPTION")
  ORDER BY v_position_disp, v.view_seq
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
