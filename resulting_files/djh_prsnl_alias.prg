CREATE PROGRAM djh_prsnl_alias
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
  p.alias_pool_cd, p_alias_pool_disp = uar_get_code_display(p.alias_pool_cd), p.active_status_dt_tm,
  p.active_status_prsnl_id, p.alias, p.beg_effective_dt_tm,
  p.check_digit, p.check_digit_method_cd, p_check_digit_method_disp = uar_get_code_display(p
   .check_digit_method_cd),
  p.contributor_system_cd, p_contributor_system_disp = uar_get_code_display(p.contributor_system_cd),
  p.data_status_cd,
  p_data_status_disp = uar_get_code_display(p.data_status_cd), p.data_status_dt_tm, p
  .data_status_prsnl_id,
  p.end_effective_dt_tm, p.person_id, p.prsnl_alias_id,
  p.prsnl_alias_sub_type_cd, p_prsnl_alias_sub_type_disp = uar_get_code_display(p
   .prsnl_alias_sub_type_cd), p.prsnl_alias_type_cd,
  p_prsnl_alias_type_disp = uar_get_code_display(p.prsnl_alias_type_cd), p.updt_applctx, p.updt_cnt,
  p.updt_dt_tm, p.updt_id, p.updt_task
  FROM prsnl_alias p
  WHERE p.active_ind=1
   AND p.alias_pool_cd != 0.00
   AND p.alias_pool_cd != 674610
   AND p.alias_pool_cd != 674618
   AND p.alias_pool_cd != 674620
   AND p.alias_pool_cd != 674619
   AND p.alias_pool_cd != 674621
   AND p.alias_pool_cd != 719676
   AND p.alias_pool_cd != 719674
   AND p.alias_pool_cd != 674609
  ORDER BY p_alias_pool_disp
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
