CREATE PROGRAM djh_122931_prsnl_addr
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
  p.name_full_formatted, p_position_disp = uar_get_code_display(p.position_cd), p.active_ind,
  a.active_status_cd, a_active_status_disp = uar_get_code_display(a.active_status_cd), p.username,
  a.street_addr, a.street_addr2, a.street_addr3,
  a.street_addr4, a.state, a.zipcode,
  p.physician_ind, p.person_id, a.parent_entity_id,
  p.active_status_cd, p.position_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd)
  FROM prsnl p,
   address a
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_status_cd=188
    AND p.position_cd != 441)
   JOIN (a
   WHERE p.person_id=a.parent_entity_id
    AND a.active_status_cd=188)
  ORDER BY p.name_full_formatted
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
