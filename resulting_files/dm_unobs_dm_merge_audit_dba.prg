CREATE PROGRAM dm_unobs_dm_merge_audit:dba
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
 SET row_exists = "N"
 DELETE  FROM dm_info d
  WHERE d.info_domain="OBSOLETE_OBJECT"
   AND d.info_name IN ("XIE1DM_MERGE_AUDIT", "XIE2DM_MERGE_AUDIT", "XIE3DM_MERGE_AUDIT",
  "XIE4DM_MERGE_AUDIT", "XPKDM_MERGE_AUDIT",
  "DM_MERGE_AUDIT", "DM_MERGE_AUDIT3350")
  WITH nocounter
 ;end delete
 COMMIT
 SELECT INTO "NL:"
  FROM dm_tables_doc dtd
  WHERE dtd.table_name IN ("DM_MERGE_AUDIT", "DM_MERGE_AUDIT3350")
   AND dtd.drop_ind=1
  DETAIL
   row_exists = "Y"
  WITH nocounter
 ;end select
 IF (row_exists="Y")
  UPDATE  FROM dm_tables_doc dtd
   SET dtd.drop_ind = 0, dtd.updt_cnt = (dtd.updt_cnt+ 1)
   WHERE dtd.table_name IN ("DM_MERGE_AUDIT", "DM_MERGE_AUDIT3350")
    AND dtd.drop_ind=1
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 SET row_exists = "N"
 SELECT INTO "NL:"
  FROM dm_indexes_doc did
  WHERE did.index_name IN ("XIE1DM_MERGE_AUDIT", "XIE2DM_MERGE_AUDIT", "XIE3DM_MERGE_AUDIT",
  "XIE4DM_MERGE_AUDIT", "XPKDM_MERGE_AUDIT")
   AND did.drop_ind=1
  DETAIL
   row_exists = "Y"
  WITH nocounter
 ;end select
 IF (row_exists="Y")
  UPDATE  FROM dm_indexes_doc did
   SET did.drop_ind = 0, did.updt_cnt = (did.updt_cnt+ 1)
   WHERE did.index_name IN ("XIE1DM_MERGE_AUDIT", "XIE2DM_MERGE_AUDIT", "XIE3DM_MERGE_AUDIT",
   "XIE4DM_MERGE_AUDIT", "XPKDM_MERGE_AUDIT")
    AND did.drop_ind=1
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 SELECT INTO "NL:"
  FROM dm_info d
  WHERE d.info_domain="OBSOLETE_OBJECT"
   AND d.info_name IN ("XIE1DM_MERGE_AUDIT", "XIE2DM_MERGE_AUDIT", "XIE3DM_MERGE_AUDIT",
  "XIE4DM_MERGE_AUDIT", "XPKDM_MERGE_AUDIT",
  "DM_MERGE_AUDIT", "DM_MERGE_AUDIT3350")
  DETAIL
   readme_data->message = "Error: Could not delete rows from dm_info for DM_MERGE_AUDIT table"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM dm_tables_doc dtd
  WHERE dtd.table_name IN ("DM_MERGE_AUDIT", "DM_MERGE_AUDIT3350")
   AND dtd.drop_ind=1
  DETAIL
   readme_data->message =
   "Error: Could not set Drop indicator = 0 for the DM_MERGE_AUDIT table on dm_tables_doc."
  WITH nocounter
 ;end select
 IF (curqual > 0)
  GO TO exit_script
 ENDIF
 SELECT INTO "NL:"
  FROM dm_indexes_doc did
  WHERE did.index_name IN ("XIE1DM_MERGE_AUDIT", "XIE2DM_MERGE_AUDIT", "XIE3DM_MERGE_AUDIT",
  "XIE4DM_MERGE_AUDIT", "XPKDM_MERGE_AUDIT")
   AND did.drop_ind=1
  DETAIL
   readme_data->message =
   "Error: Could not set Drop indicator = 0 for the DM_MERGE_AUDIT table on dm_indexes_doc."
  WITH nocounter
 ;end select
 IF (curqual > 0)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "SUCCESS: Rows to obsolete DM_MERGE_AUDIT have been removed"
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
