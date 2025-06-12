CREATE PROGRAM carenet_chk_omf_view_options:dba
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
 SET v_count1 = 0
 SET v_expected_count = 42
 SET run_status = "F"
 SET csv_flag = 0
 SELECT INTO "nl:"
  r.request_number
  FROM request r
  WHERE r.request_number=952287
  DETAIL
   IF (r.request_number=952287)
    csv_flag = 1
   ELSE
    csv_flag = 0
   ENDIF
  WITH nocounter
 ;end select
 IF (csv_flag=0)
  SET run_status = "S"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_vo_type ovt,
   omf_vo_type_display ovd,
   code_value cv
  WHERE ovt.vo_type_cd != 0
   AND ovt.vo_type_cd=cv.code_value
   AND cv.display="CN*"
   AND ovd.vo_type_cd=ovt.vo_type_cd
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 >= v_expected_count)
  SET run_status = "S"
 ELSE
  SET run_status = "F"
 ENDIF
#exit_script
 IF (run_status="S")
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("CARENET_OMF_VIEW_OPTIONS: Expected ",trim(cnvtstring(
     v_expected_count),3)," rows but found ",trim(cnvtstring(v_count1),3)," rows")
 ENDIF
 EXECUTE dm_readme_status
END GO
