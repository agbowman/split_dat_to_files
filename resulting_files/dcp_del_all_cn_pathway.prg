CREATE PROGRAM dcp_del_all_cn_pathway
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET dcp_info_ind = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="PATHWAYS"
  DETAIL
   dcp_info_ind = 1
  WITH nocounter
 ;end select
 IF (dcp_info_ind=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "DATA MANAGEMENT", di.info_name = "PATHWAYS", di.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    di.updt_cnt = 0, di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task,
    di.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 SET table_exists = "F"
 SELECT INTO "NL:"
  FROM user_tab_columns utc
  WHERE utc.table_name="CN_PATHWAY_ST"
  DETAIL
   table_exists = "T"
  WITH nocounter
 ;end select
 IF (table_exists="F")
  SET readme_data->status = "S"
  SET readme_data->message = "New table, readme not needed to remove duplicates."
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 IF (currdb="ORACLE")
  CALL parser("rdb truncate table CN_PW_OUTCOME_ST reuse storage go")
  CALL parser("rdb truncate table CN_PW_ORDER_ST reuse storage go")
  CALL parser("rdb truncate table CN_PW_OUTCOME_ACT_ST reuse storage go")
  CALL parser("rdb truncate table CN_PW_ORDER_AUDIT_ST reuse storage go")
  CALL parser("rdb truncate table CN_PW_FOCUS_ST reuse storage go")
  CALL parser("rdb truncate table CN_PW_VARIANCE_ST reuse storage go")
  CALL parser("rdb truncate table CN_PW_CARE_CAT_ST reuse storage go")
  CALL parser("rdb truncate table CN_PW_TIME_FRAME_ST reuse storage go")
  CALL parser("rdb truncate table CN_PATHWAY_ST reuse storage go")
  COMMIT
  SET stat = callprg(dm_add_zero_rows,"CN_PW_OUTCOME_ST")
  SET stat = callprg(dm_add_zero_rows,"CN_PW_ORDER_ST")
  SET stat = callprg(dm_add_zero_rows,"CN_PW_OUTCOME_ACT_ST")
  SET stat = callprg(dm_add_zero_rows,"CN_PW_ORDER_AUDIT_ST")
  SET stat = callprg(dm_add_zero_rows,"CN_PW_FOCUS_ST")
  SET stat = callprg(dm_add_zero_rows,"CN_PW_VARIANCE_ST")
  SET stat = callprg(dm_add_zero_rows,"CN_PW_CARE_CAT_ST")
  SET stat = callprg(dm_add_zero_rows,"CN_PW_TIME_FRAME_ST")
  SET stat = callprg(dm_add_zero_rows,"CN_PATHWAY_ST")
  COMMIT
 ELSE
  SET readme_data->message = "Auto success on db2"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  GO TO exit_script
 ENDIF
 SET errmsg = fillstring(132," ")
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->message = trim(errmsg)
  SET readme_data->status = "F"
  EXECUTE dm_readme_status
 ELSE
  SET readme_data->message = "Readme:dcp_del_all_cn_pathway completed successfully"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
 ENDIF
#exit_script
END GO
