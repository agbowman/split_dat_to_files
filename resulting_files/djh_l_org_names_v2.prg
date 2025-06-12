CREATE PROGRAM djh_l_org_names_v2
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
  o.active_ind, o.organization_id, o.org_class_cd,
  o_org_class_disp = uar_get_code_display(o.org_class_cd), o.org_name, o.active_ind,
  o.active_status_cd, o_active_status_disp = uar_get_code_display(o.active_status_cd), o
  .active_status_dt_tm,
  o.active_status_prsnl_id, o.beg_effective_dt_tm, o.contributor_source_cd,
  o_contributor_source_disp = uar_get_code_display(o.contributor_source_cd), o.contributor_system_cd,
  o_contributor_system_disp = uar_get_code_display(o.contributor_system_cd),
  o.data_status_cd, o_data_status_disp = uar_get_code_display(o.data_status_cd), o.data_status_dt_tm,
  o.data_status_prsnl_id, o.end_effective_dt_tm, o.federal_tax_id_nbr,
  o.ft_entity_id, o.ft_entity_name, o.organization_id,
  o.org_class_cd, o_org_class_disp = uar_get_code_display(o.org_class_cd), o.org_name,
  o.org_name_key, o.org_name_key_nls, o.org_status_cd,
  o_org_status_disp = uar_get_code_display(o.org_status_cd), o.rowid, o.updt_applctx,
  o.updt_cnt, o.updt_dt_tm, o.updt_id,
  o.updt_task
  FROM organization o
  WHERE o.org_class_cd=1211
   AND o.contributor_system_cd != 679337
   AND o.org_name > " "
  ORDER BY o.org_name
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
