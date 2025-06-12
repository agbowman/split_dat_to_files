CREATE PROGRAM djh_clin_notes_list
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
  SET maxsecs = 300
 ENDIF
 SELECT INTO  $OUTDEV
  a.description, v.application_number, v.position_cd,
  v.prsnl_id, v_position_disp = uar_get_code_display(v.position_cd), v.frame_type,
  v.view_name, n.pvc_value, v.view_prefs_id,
  n.pvc_name, p.person_id, p.position_cd,
  p.name_full_formatted, p_position_disp = uar_get_code_display(p.position_cd), n.parent_entity_id,
  n.parent_entity_name
  FROM view_prefs v,
   application a,
   prsnl p,
   name_value_prefs n
  PLAN (v
   WHERE v.view_name="CLINNOTES"
    AND v.frame_type="CHART"
    AND v.application_number=600005
    AND v.position_cd > 0)
   JOIN (a
   WHERE v.application_number=a.application_number)
   JOIN (p
   WHERE outerjoin(v.prsnl_id)=p.person_id)
   JOIN (n
   WHERE v.view_prefs_id=n.parent_entity_id
    AND n.parent_entity_name="VIEW_PREFS"
    AND n.pvc_name="VIEW_CAPTION")
  ORDER BY a.description, v.frame_type, p_position_disp,
   p.name_full_formatted
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
