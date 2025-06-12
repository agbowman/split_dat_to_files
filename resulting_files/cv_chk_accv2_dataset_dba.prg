CREATE PROGRAM cv_chk_accv2_dataset:dba
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
 SET failure = "F"
 SET v_count1 = 0
 SET xref_flag = 0
 SET response_flag = 0
 SET dataset_flag = 0
 SET xref_actual_cnt = 0
 SET response_actual_cnt = 0
 SET dataset_actual_cnt = 0
 SET readme_type = "accv2_DATASET:"
 SELECT INTO "nl:"
  table_count = count(*)
  FROM cv_dataset cd
  WHERE cnvtupper(trim(cd.dataset_internal_name))="ACC02"
  DETAIL
   dataset_actual_cnt = table_count
  WITH nocounter
 ;end select
 IF (dataset_actual_cnt=0)
  SET failure = "T"
  SET dataset_flag = 1
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM cv_xref cx,
   cv_dataset cd
  WHERE cx.dataset_id=cd.dataset_id
   AND cnvtupper(trim(cx.xref_internal_name))="ACC02*"
  DETAIL
   xref_actual_cnt = table_count
  WITH nocounter
 ;end select
 IF (xref_actual_cnt=0)
  SET failure = "T"
  SET xref_flag = 1
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM cv_dataset cd,
   cv_xref cx,
   cv_response cr
  WHERE cd.dataset_id=cx.dataset_id
   AND cx.xref_id=cr.xref_id
   AND cnvtupper(trim(cr.response_internal_name))="ACC02*"
  DETAIL
   response_actual_cnt = table_count
  WITH nocounter
 ;end select
 IF (response_actual_cnt=0)
  SET failure = "T"
  SET response_flag = 1
 ENDIF
 IF (failure="T")
  DECLARE error_msg = vc
  SET error_msg = " Incorrect accv2 Dataset file readme counts found in the following tables:"
  IF (dataset_flag=1)
   SET error_msg = concat(error_msg," cv_dataset")
  ENDIF
  IF (xref_flag=1)
   SET error_msg = concat(error_msg," cv_xref")
  ENDIF
  IF (response_flag=1)
   SET error_msg = concat(error_msg," cv_response")
  ENDIF
  CALL echo(error_msg)
  SET readme_data->message = concat(readme_type,error_msg)
  SET readme_data->status = "F"
 ELSE
  SET readme_data->message = concat(readme_type," Readme Successful.")
  SET readme_data->status = "S"
  CALL echo("CVNet ACCv2 Dataset has been successfully loaded!")
 ENDIF
 EXECUTE dm_readme_status
 COMMIT
END GO
