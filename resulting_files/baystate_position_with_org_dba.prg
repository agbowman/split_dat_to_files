CREATE PROGRAM baystate_position_with_org:dba
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 IF (validate(_separator)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT INTO  $OUTDEV
  p.person_id, p_position_disp = uar_get_code_display(p.position_cd), p.position_cd,
  p.username, p.name_full_formatted, po.organization_id,
  o.org_name, p.name_last, p.name_first,
  p.name_first_key, p.name_last_key, p.email,
  p_contributor_system_disp = uar_get_code_display(p.contributor_system_cd), p.contributor_system_cd,
  p.active_ind,
  p_active_status_disp = uar_get_code_display(p.active_status_cd), p.active_status_cd, p
  .beg_effective_dt_tm,
  p.end_effective_dt_tm, p.log_access_ind, p.physician_ind,
  p_physician_status_disp = uar_get_code_display(p.physician_status_cd), p.physician_status_cd, o
  .organization_id
  FROM prsnl p,
   prsnl_org_reltn po,
   organization o
  PLAN (p
   WHERE p.active_ind=1
    AND p.active_status_cd=188.00
    AND  NOT (p.position_cd IN (0, 441.00, 283540467.00, 319324234.00))
    AND p.prsnl_type_cd=906.00
    AND  NOT (p.person_id IN (21709719)))
   JOIN (po
   WHERE p.person_id=po.person_id
    AND po.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE po.organization_id=o.organization_id
    AND o.organization_id IN (589745.00))
  ORDER BY p_position_disp, p.name_last
  WITH maxrec = 17500, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
