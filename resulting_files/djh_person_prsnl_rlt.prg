CREATE PROGRAM djh_person_prsnl_rlt
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
  p.active_status_dt_tm, p.active_status_prsnl_id, p.computer_name,
  p.comp_caption, p.person_id, p.ppa_cnt,
  p.ppa_comment, p.ppa_first_dt_tm, p.ppa_first_tz,
  p.ppa_id, p.ppa_last_dt_tm, p.ppa_last_tz,
  p.ppa_type_cd, p_ppa_type_disp = uar_get_code_display(p.ppa_type_cd), p.ppr_cd,
  p_ppr_disp = uar_get_code_display(p.ppr_cd), p.prsnl_id, p.updt_applctx,
  p.updt_cnt, p.updt_dt_tm, p.updt_id,
  p.updt_task, p.view_caption
  FROM person_prsnl_activity p
  WITH maxrec = 10, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
