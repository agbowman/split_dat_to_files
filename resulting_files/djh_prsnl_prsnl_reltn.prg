CREATE PROGRAM djh_prsnl_prsnl_reltn
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
  p.contributor_system_cd, p_contributor_system_disp = uar_get_code_display(p.contributor_system_cd),
  p.data_status_cd,
  p_data_status_disp = uar_get_code_display(p.data_status_cd), p.data_status_dt_tm, p
  .data_status_prsnl_id,
  p.end_effective_dt_tm, p.organization_id, p.person_id,
  p.prsnl_prsnl_reltn_cd, p_prsnl_prsnl_reltn_disp = uar_get_code_display(p.prsnl_prsnl_reltn_cd), p
  .prsnl_prsnl_reltn_id,
  p.related_person_id, p.updt_applctx, p.updt_cnt,
  p.updt_dt_tm, p.updt_id, p.updt_task
  FROM prsnl_prsnl_reltn p
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
