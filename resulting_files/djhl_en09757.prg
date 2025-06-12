CREATE PROGRAM djhl_en09757
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
  p.active_ind, p_active_status_disp = uar_get_code_display(p.active_status_cd), p.active_status_cd,
  p.active_status_dt_tm, p.active_status_prsnl_id, p.beg_effective_dt_tm,
  p_contributor_system_disp = uar_get_code_display(p.contributor_system_cd), p.contributor_system_cd,
  p_data_status_disp = uar_get_code_display(p.data_status_cd),
  p.data_status_cd, p.data_status_dt_tm, p.data_status_prsnl_id,
  p.end_effective_dt_tm, p_prsnl_group_class_disp = uar_get_code_display(p.prsnl_group_class_cd), p
  .prsnl_group_class_cd,
  p.prsnl_group_desc, p.prsnl_group_id, p.prsnl_group_name,
  p.prsnl_group_name_key, p.prsnl_group_name_key_nls, p_prsnl_group_type_disp = uar_get_code_display(
   p.prsnl_group_type_cd),
  p.prsnl_group_type_cd, p_service_resource_disp = uar_get_code_display(p.service_resource_cd), p
  .service_resource_cd,
  p.updt_applctx, p.updt_cnt, p.updt_dt_tm,
  p.updt_id, p.updt_task
  FROM prsnl_group p
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
