CREATE PROGRAM dm_del_pmpostprocess_cmb:dba
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
 FREE RECORD dm_rec
 RECORD dm_rec(
   1 list[4]
     2 operation_type = vc
     2 parent_entity = vc
     2 child_entity = vc
     2 dm_row_exists = c1
 )
 SET dm_rec->list[1].operation_type = "COMBINE"
 SET dm_rec->list[1].parent_entity = "PERSON"
 SET dm_rec->list[1].child_entity = "PM_POST_PROCESS"
 SET dm_rec->list[1].dm_row_exists = "N"
 SET dm_rec->list[2].operation_type = "COMBINE"
 SET dm_rec->list[2].parent_entity = "ENCOUNTER"
 SET dm_rec->list[2].child_entity = "PM_POST_PROCESS"
 SET dm_rec->list[2].dm_row_exists = "N"
 SET dm_rec->list[3].operation_type = "UNCOMBINE"
 SET dm_rec->list[3].parent_entity = "PERSON"
 SET dm_rec->list[3].child_entity = "PM_POST_PROCESS"
 SET dm_rec->list[3].dm_row_exists = "N"
 SET dm_rec->list[4].operation_type = "UNCOMBINE"
 SET dm_rec->list[4].parent_entity = "ENCOUNTER"
 SET dm_rec->list[4].child_entity = "PM_POST_PROCESS"
 SET dm_rec->list[4].dm_row_exists = "N"
 SET readme_data->status = "F"
 SET readme_data->message = "FAIL: did not delete rows properly"
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce,
   (dummyt d  WITH seq = 4)
  PLAN (d)
   JOIN (dce
   WHERE (dce.operation_type=dm_rec->list[d.seq].operation_type)
    AND (dce.parent_entity=dm_rec->list[d.seq].parent_entity)
    AND (dce.child_entity=dm_rec->list[d.seq].child_entity)
    AND (dce.child_entity=dm_rec->list[d.seq].child_entity))
  DETAIL
   dm_rec->list[d.seq].dm_row_exists = "Y"
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: rows are not currently in the table"
  GO TO exit_script
 ENDIF
 DELETE  FROM dm_cmb_exception dce,
   (dummyt d  WITH seq = 4)
  SET dce.seq = 1
  PLAN (d
   WHERE (dm_rec->list[d.seq].dm_row_exists="Y"))
   JOIN (dce
   WHERE (dce.operation_type=dm_rec->list[d.seq].operation_type)
    AND (dce.parent_entity=dm_rec->list[d.seq].parent_entity)
    AND (dce.child_entity=dm_rec->list[d.seq].child_entity)
    AND (dce.child_entity=dm_rec->list[d.seq].child_entity))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: delete from dm_cmb_exception failed"
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: rows successfully deleted"
  COMMIT
 ENDIF
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
