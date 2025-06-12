CREATE PROGRAM 77889_md_tab_names
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
 SELECT INTO  $OUTDEV
  v.application_number, v.frame_type, v.position_cd,
  v_position_disp = uar_get_code_display(v.position_cd), v.view_name, v.view_prefs_id,
  v.view_seq, n.name_value_prefs_id, n.parent_entity_id,
  n.parent_entity_name, n.pvc_name, n.pvc_value,
  n.updt_id, n.updt_applctx, n.sequence
  FROM view_prefs v,
   name_value_prefs n
  PLAN (v
   WHERE v.active_ind=1
    AND v.application_number=600005
    AND ((v.position_cd=925824) OR (((v.position_cd=966300) OR (((v.position_cd=925841) OR (((v
   .position_cd=925830) OR (((v.position_cd=925831) OR (((v.position_cd=925842) OR (((v.position_cd=
   925825) OR (((v.position_cd=925832) OR (((v.position_cd=925833) OR (((v.position_cd=925843) OR (((
   v.position_cd=925834) OR (((v.position_cd=966301) OR (((v.position_cd=925835) OR (((v.position_cd=
   925844) OR (((v.position_cd=1646210) OR (((v.position_cd=925826) OR (((v.position_cd=925836) OR (
   ((v.position_cd=925845) OR (((v.position_cd=925846) OR (((v.position_cd=719476) OR (((v
   .position_cd=925827) OR (((v.position_cd=925847) OR (((v.position_cd=925828) OR (((v.position_cd=
   925837) OR (((v.position_cd=925850) OR (((v.position_cd=925851) OR (((v.position_cd=925852) OR (v
   .position_cd=925848)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   ))
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
