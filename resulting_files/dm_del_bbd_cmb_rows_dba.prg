CREATE PROGRAM dm_del_bbd_cmb_rows:dba
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
 FREE RECORD dm_cmb_rows
 RECORD dm_cmb_rows(
   1 operation_type = vc
   1 parent_entity = vc
   1 list[4]
     2 child_entity = vc
     2 script_name = vc
     2 row_exists = i2
 )
 SET dm_errcode = 0
 SET dm_errmsg = fillstring(132," ")
 SET dm_errcode = error(dm_errmsg,1)
 SET readme_data->status = "F"
 SET readme_data->message = "ERROR: no status was logged"
 SET dm_cmb_rows->operation_type = "COMBINE"
 SET dm_cmb_rows->parent_entity = "ENCOUNTER"
 SET dm_cmb_rows->list[1].child_entity = "BBD_CONTACT_NOTE"
 SET dm_cmb_rows->list[1].script_name = "ENCNTR_CMB_BBD_CONTACT_NOTE"
 SET dm_cmb_rows->list[1].row_exists = 0
 SET dm_cmb_rows->list[2].child_entity = "BBD_DONATION_RESULTS"
 SET dm_cmb_rows->list[2].script_name = "ENCNTR_CMB_BBD_DON_RESULTS"
 SET dm_cmb_rows->list[2].row_exists = 0
 SET dm_cmb_rows->list[3].child_entity = "BBD_DONOR_CONTACT"
 SET dm_cmb_rows->list[3].script_name = "ENCNTR_CMB_BBD_DONOR_CONTACT"
 SET dm_cmb_rows->list[3].row_exists = 0
 SET dm_cmb_rows->list[4].child_entity = "BBD_DONOR_ELIGIBILITY"
 SET dm_cmb_rows->list[4].script_name = "ENCNTR_CMB_BBD_DONOR_ELIG"
 SET dm_cmb_rows->list[4].row_exists = 0
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce,
   (dummyt d  WITH seq = 4)
  PLAN (d)
   JOIN (dce
   WHERE (dce.operation_type=dm_cmb_rows->operation_type)
    AND (dce.parent_entity=dm_cmb_rows->parent_entity)
    AND (dce.child_entity=dm_cmb_rows->list[d.seq].child_entity))
  DETAIL
   IF ((dm_cmb_rows->list[1].script_name="ENCNTR_CMB_BBD_CONTACT_NOTE"))
    dm_cmb_rows->list[1].row_exists = 1
   ENDIF
   IF ((dm_cmb_rows->list[2].script_name="ENCNTR_CMB_BBD_DON_RESULTS"))
    dm_cmb_rows->list[2].row_exists = 1
   ENDIF
   IF ((dm_cmb_rows->list[3].script_name="ENCNTR_CMB_BBD_DONOR_CONTACT"))
    dm_cmb_rows->list[3].row_exists = 1
   ENDIF
   IF ((dm_cmb_rows->list[4].script_name="ENCNTR_CMB_BBD_DONOR_ELIG"))
    dm_cmb_rows->list[4].row_exists = 1
   ENDIF
  WITH nocounter
 ;end select
 SET dm_errcode = error(dm_errmsg,0)
 IF (dm_errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "ERROR: encountered CCL error while selecting from dm_cmb_exception"
  GO TO exit_script
 ENDIF
 DELETE  FROM dm_cmb_exception dce,
   (dummyt d  WITH seq = 4)
  SET dce.seq = 1
  PLAN (d
   WHERE (dm_cmb_rows->list[d.seq].row_exists=1))
   JOIN (dce
   WHERE (dce.operation_type=dm_cmb_rows->operation_type)
    AND (dce.parent_entity=dm_cmb_rows->parent_entity)
    AND (dce.child_entity=dm_cmb_rows->list[d.seq].child_entity))
  WITH nocounter
 ;end delete
 SET dm_errcode = error(dm_errmsg,0)
 IF (dm_errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message = "ERROR: encountered CCL error while deleting from dm_cmb_exception"
  ROLLBACK
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_exception dce,
   (dummyt d  WITH seq = 4)
  PLAN (d)
   JOIN (dce
   WHERE (dce.operation_type=dm_cmb_rows->operation_type)
    AND (dce.parent_entity=dm_cmb_rows->parent_entity)
    AND (dce.child_entity=dm_cmb_rows->list[d.seq].child_entity))
  WITH nocounter
 ;end select
 SET dm_errcode = error(dm_errmsg,0)
 IF (dm_errcode != 0)
  SET readme_data->status = "F"
  SET readme_data->message =
  "ERROR: encountered CCL error while selecting from dm_cmb_exception the second time"
  GO TO exit_script
 ENDIF
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "FAIL: all four rows where not properly deleted from dm_cmb_exception"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "SUCCESS: all four rows where successfully deleted from dm_cmb_exception"
#exit_script
 IF ((readme_data->readme_id > 0))
  EXECUTE dm_readme_status
 ELSE
  CALL echorecord(readme_data)
 ENDIF
END GO
