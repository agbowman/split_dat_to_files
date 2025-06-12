CREATE PROGRAM djh_medrec_tab_prfs
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  IF (validate(_separator)=0)
   IF (validate(_separator)=0)
    SET _separator = " "
   ENDIF
  ENDIF
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 300
 ENDIF
 SELECT INTO  $OUTDEV
  v.active_ind, v.application_number, v_position_disp = uar_get_code_display(v.position_cd),
  n.pvc_value, v.frame_type, v.position_cd,
  v.view_name, n.parent_entity_name, n.pvc_name
  FROM view_prefs v,
   name_value_prefs n
  PLAN (v
   WHERE v.active_ind=1
    AND v.position_cd > 0
    AND v.frame_type="CHART"
    AND v.position_cd != 925860
    AND v.position_cd != 925865
    AND v.position_cd != 925864
    AND v.position_cd != 925858
    AND v.position_cd != 925857
    AND v.position_cd != 925862
    AND v.position_cd != 925861
    AND v.position_cd != 925856
    AND v.position_cd != 925859
    AND v.position_cd != 925863)
   JOIN (n
   WHERE n.active_ind=1
    AND v.view_prefs_id=n.parent_entity_id
    AND n.parent_entity_name="VIEW_PREFS"
    AND n.pvc_name="VIEW_CAPTION"
    AND n.pvc_value="Med*Rec*")
  ORDER BY v.application_number, v_position_disp, n.pvc_value
  WITH maxrec = 5, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
