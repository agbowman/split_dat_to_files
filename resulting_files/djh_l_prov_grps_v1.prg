CREATE PROGRAM djh_l_prov_grps_v1
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
  p.active_ind, p_prsnl_group_class_disp = uar_get_code_display(p.prsnl_group_class_cd), p
  .prsnl_group_desc,
  p.prsnl_group_name, p_active_status_disp = uar_get_code_display(p.active_status_cd), p
  .active_status_cd,
  p.active_status_dt_tm, p.active_status_prsnl_id, p.beg_effective_dt_tm,
  p.end_effective_dt_tm, p.prsnl_group_class_cd, p.prsnl_group_id,
  p.prsnl_group_name_key, p.prsnl_group_name_key_nls, p_prsnl_group_type_disp = uar_get_code_display(
   p.prsnl_group_type_cd),
  p.prsnl_group_type_cd, p.updt_dt_tm, p.updt_id
  FROM prsnl_group p
  WHERE p.active_ind >= 0
   AND p.prsnl_group_class_cd=11156
   AND p.prsnl_group_name > " "
   AND p.prsnl_group_name_key > " "
  ORDER BY p.prsnl_group_name
  WITH nocounter, separator = " ", format
 ;end select
END GO
