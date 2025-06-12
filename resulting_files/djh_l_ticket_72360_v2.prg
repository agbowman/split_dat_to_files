CREATE PROGRAM djh_l_ticket_72360_v2
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
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.physician_ind, p.person_id, pa.alias,
  p.username, p.name_full_formatted, p.position_cd,
  p_position_disp = uar_get_code_display(p.position_cd), p.updt_id, p.beg_effective_dt_tm,
  pa.person_id, pa_prsnl_alias_type_disp = uar_get_code_display(pa.prsnl_alias_type_cd),
  pa_alias_pool_disp = uar_get_code_display(pa.alias_pool_cd)
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE ((p.physician_ind=1) OR (((p.position_cd=925824) OR (((p.position_cd=925841) OR (((p
   .position_cd=925830) OR (((p.position_cd=925831) OR (((p.position_cd=925842) OR (((p.position_cd=
   925825) OR (((p.position_cd=925832) OR (((p.position_cd=925833) OR (((p.position_cd=925843) OR (((
   p.position_cd=925834) OR (((p.position_cd=925835) OR (((p.position_cd=925844) OR (((p.position_cd=
   1646210) OR (((p.position_cd=925826) OR (((p.position_cd=925836) OR (((p.position_cd=925845) OR (
   ((p.position_cd=925846) OR (((p.position_cd=719476) OR (((p.position_cd=925827) OR (((p
   .position_cd=925847) OR (((p.position_cd=925828) OR (((p.position_cd=925837) OR (((p.position_cd=
   925851) OR (((p.position_cd=925852) OR (p.position_cd=925848)) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.alias_pool_cd=719676
    AND pa.prsnl_alias_type_cd=1088)
  ORDER BY pa.alias, p.name_full_formatted, p.username,
   p.person_id
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
