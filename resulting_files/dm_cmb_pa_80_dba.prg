CREATE PROGRAM dm_cmb_pa_80:dba
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
 EXECUTE dm_dbimport "cer_install:dm_cmb_pa_80.csv", "dm_dm_cmb_exception_import", 10
 IF ((readme_data->status="F"))
  GO TO end_program
 ENDIF
 DECLARE dm_cnt = i4 WITH public
 SET dm_cnt = size(requestin->list_0,5)
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce,
   (dummyt d  WITH seq = dm_cnt)
  PLAN (d
   WHERE (requestin->list_0[d.seq].delete_row_ind="0"))
   JOIN (dce
   WHERE (dce.operation_type=requestin->list_0[d.seq].operation_type)
    AND (dce.parent_entity=requestin->list_0[d.seq].parent_entity)
    AND (dce.child_entity=requestin->list_0[d.seq].child_entity))
  WITH outerjoin = d, dontexist
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "ERROR: dm_cmb_exception import failed."
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: all rows imported into dm_cmb_exception"
  COMMIT
 ENDIF
#end_program
 EXECUTE dm_readme_status
END GO
