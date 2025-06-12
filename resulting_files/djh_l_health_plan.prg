CREATE PROGRAM djh_l_health_plan
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
  h.active_ind, h.active_status_cd, h_active_status_disp = uar_get_code_display(h.active_status_cd),
  h.active_status_dt_tm, h.active_status_prsnl_id, h.beg_effective_dt_tm,
  h.data_status_cd, h_data_status_disp = uar_get_code_display(h.data_status_cd), h.data_status_dt_tm,
  h.data_status_prsnl_id, h.end_effective_dt_tm, h.financial_class_cd,
  h_financial_class_disp = uar_get_code_display(h.financial_class_cd), h.ft_entity_id, h
  .ft_entity_name,
  h.group_name, h.group_nbr, h.health_plan_id,
  h.pat_bill_pref_flag, h.plan_class_cd, h_plan_class_disp = uar_get_code_display(h.plan_class_cd),
  h.plan_desc, h.plan_name, h.plan_name_key,
  h.plan_name_key_nls, h.plan_type_cd, h_plan_type_disp = uar_get_code_display(h.plan_type_cd),
  h.policy_nbr, h.pri_concurrent_ind, h.product_cd,
  h_product_disp = uar_get_code_display(h.product_cd), h.sec_concurrent_ind, h.updt_applctx,
  h.updt_cnt, h.updt_dt_tm, h.updt_id,
  h.updt_task
  FROM health_plan h
  WHERE h.updt_id=754400
  WITH maxrec = 100, format, separator = value(_separator),
   time = value(maxsecs), skipreport = 1
 ;end select
END GO
