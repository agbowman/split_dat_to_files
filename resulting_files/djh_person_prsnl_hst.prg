CREATE PROGRAM djh_person_prsnl_hst
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
  p.end_effective_dt_tm, p.ft_prsnl_name, p.internal_seq,
  p.person_id, p.person_prsnl_reltn_id, p.person_prsnl_r_cd,
  p_person_prsnl_r_disp = uar_get_code_display(p.person_prsnl_r_cd), p.priority_seq, p
  .prsnl_person_id,
  p.source_identifier, p.updt_applctx, p.updt_cnt,
  p.updt_dt_tm, p.updt_id, p.updt_task
  FROM person_prsnl_reltn p
  WHERE p.person_id=1228508
  WITH maxrec = 50, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
