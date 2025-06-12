CREATE PROGRAM dm_delete_dm_ref_tables:dba
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
 DECLARE dm_ref_dom_name = c30
 DECLARE dm_ref_dom_grp_name = c30
 DECLARE dm_ref_dom_r_name = c30
 SELECT INTO "nl:"
  FROM dm_tables_doc dtd
  WHERE dtd.table_name IN ("DM_REF_DOMAIN", "DM_REF_DOMAIN_GROUP", "DM_REF_DOMAIN_R")
  DETAIL
   IF (dtd.table_name="DM_REF_DOMAIN")
    dm_ref_dom_name = dtd.full_table_name
   ELSEIF (dtd.table_name="DM_REF_DOMAIN_GROUP")
    dm_ref_dom_grp_name = dtd.full_table_name
   ELSEIF (dtd.table_name="DM_REF_DOMAIN_R")
    dm_ref_dom_r_name = dtd.full_table_name
   ENDIF
  WITH nocounter
 ;end select
 DELETE  FROM dm_afd_tables dat
  WHERE dat.owner=currdbuser
   AND dat.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_columns dac
  WHERE dac.owner=currdbuser
   AND dac.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_indexes dai
  WHERE dai.owner=currdbuser
   AND dai.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_index_columns daic
  WHERE daic.owner=currdbuser
   AND daic.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_constraints dac2
  WHERE dac2.owner=currdbuser
   AND dac2.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end delete
 DELETE  FROM dm_afd_cons_columns dacc
  WHERE dacc.owner=currdbuser
   AND dacc.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end delete
 SELECT INTO "nl:"
  FROM dm_afd_tables dat
  WHERE dat.owner=currdbuser
   AND dat.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: Rows not properly deleted from DM_AFD_TABLES"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_afd_columns dac
  WHERE dac.owner=currdbuser
   AND dac.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: Rows not properly deleted from DM_AFD_COLUMNS"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_afd_indexes dai
  WHERE dai.owner=currdbuser
   AND dai.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: Rows not properly deleted from DM_AFD_INDEXES"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_afd_index_columns daic
  WHERE daic.owner=currdbuser
   AND daic.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: Rows not properly deleted from DM_AFD_INDEX_COLUMNS"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_afd_constraints dac2
  WHERE dac2.owner=currdbuser
   AND dac2.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: Rows not properly deleted from DM_AFD_CONSTRAINTS"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_afd_cons_columns dacc
  WHERE dacc.owner=currdbuser
   AND dacc.table_name IN (dm_ref_dom_name, dm_ref_dom_grp_name, dm_ref_dom_r_name)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: Rows not properly deleted from DM_AFD_CONS_COLUMNS"
  GO TO exit_script
 ENDIF
 COMMIT
 SET readme_data->status = "S"
 SET readme_data->message =
 "SUCCESS: DM_REF_DOMAIN* tables successfully deleted from the DM_AFD* tables."
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ENDIF
END GO
