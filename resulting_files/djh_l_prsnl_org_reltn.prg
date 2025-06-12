CREATE PROGRAM djh_l_prsnl_org_reltn
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
  p.active_ind, p.active_status_cd, p_active_status_disp = uar_get_code_display(p.active_status_cd),
  p.active_status_dt_tm, p.active_status_prsnl_id, p.beg_effective_dt_tm,
  p.end_effective_dt_tm, p.organization_id, p.person_id,
  p.prsnl_org_reltn_id, p.updt_applctx, p.updt_cnt,
  p.updt_dt_tm, p.updt_id, p.updt_task,
  o.active_ind, o.active_status_cd, o_active_status_disp = uar_get_code_display(o.active_status_cd),
  o.active_status_dt_tm, o.active_status_prsnl_id, o.organization_id,
  o.org_class_cd, o_org_class_disp = uar_get_code_display(o.org_class_cd), o.org_name
  FROM prsnl_org_reltn p,
   organization o
  PLAN (p
   WHERE p.person_id=754400
    AND p.organization_id=1791383.00)
   JOIN (o
   WHERE p.organization_id=o.organization_id)
  ORDER BY o.org_name
  WITH maxrec = 200, noheading, format = variable,
   time = value(maxsecs)
 ;end select
END GO
