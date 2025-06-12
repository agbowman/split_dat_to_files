CREATE PROGRAM dm2_fill_oe_format_parent:dba
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
 DECLARE fofp_oe_table_cnt = i4
 DECLARE fofp_dm_table_cnt = i4
 DECLARE fofp_rel_cnt = i4
 DECLARE fofp_max_id = f8
 DECLARE fofp_table_name = vc
 DECLARE fofp_env_id = f8
 IF (currdb="DB2UDB")
  SET fofp_table_name = "ORDER_ENTRY_7777"
 ELSE
  SET fofp_table_name = "ORDER_ENTRY_FORMAT_PARENT"
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="DM_ENV_ID"
  DETAIL
   fofp_env_id = d.info_number
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->message = concat(
   "Readme FAILURE. DM2_FILL_OE_FORMAT_PARENT - The current environment is not set.",
   "  Run DM_SET_ENV_ID.")
  SET readme_data->status = "F"
  GO TO exit_here
 ENDIF
 SELECT INTO "nl:"
  fofpa = max(dc.log_id)"#############.##"
  FROM dm_chg_log dc
  DETAIL
   rptbuf = reportinfo(2), fofp_max_id = cnvtreal(substring(1,15,rptbuf))
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  fofpcnt = count(*)
  FROM dm_env_reltn dm
  WHERE dm.relationship_type="REFERENCE MERGE"
   AND dm.parent_env_id=fofp_env_id
  DETAIL
   fofp_rel_cnt = fofpcnt
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  fofcnt = count(*)
  FROM order_entry_format_parent oe
  WHERE oe.oe_format_id > 0
  DETAIL
   fofp_oe_table_cnt = fofcnt
  WITH nocounter
 ;end select
 IF (fofp_rel_cnt > 0)
  EXECUTE dm2_ref_chg_tbl "ORDER_ENTRY_FORMAT_PARENT"
 ENDIF
 SELECT INTO "NL:"
  finalcnt = count(*)
  FROM dm_chg_log d
  WHERE d.log_id >= fofp_max_id
   AND d.table_name=fofp_table_name
  DETAIL
   fofp_dm_table_cnt = finalcnt
  WITH nocounter
 ;end select
 IF ((fofp_dm_table_cnt >= (fofp_oe_table_cnt * fofp_rel_cnt)))
  SET readme_data->message = build("Readme SUCCESS. DM2_FILL_OE_FORMAT_PARENT.")
  SET readme_data->status = "S"
 ELSE
  SET readme_data->message = concat(
   "Readme FAILURE. DM2_FILL_OE_FORMAT_PARENT - The DM_CHG_LOG table doesn't ",
   "have all the rows for the ORDER_ENTRY_FORMAT_PARENT table.")
  SET readme_data->status = "F"
 ENDIF
#exit_here
 EXECUTE dm_readme_status
 CALL echo(readme_data->message)
END GO
