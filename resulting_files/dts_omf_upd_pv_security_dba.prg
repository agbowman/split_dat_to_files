CREATE PROGRAM dts_omf_upd_pv_security:dba
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
 FREE SET omf_grid
 RECORD omf_grid(
   1 data[*]
     2 old_grid_cd = f8
     2 new_grid_cd = f8
     2 display_key = vc
 )
 SET v_cnt = 0
 SET csv_flag = 0
 SET run_status = "F"
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
  cv1.code_value, cv2.code_value, cv2.display_key
  FROM code_value cv1,
   code_value cv2
  WHERE cv1.code_set=14265
   AND cv1.cdf_meaning="GRID"
   AND cv1.active_ind=1
   AND cv1.display_key=cv2.display_key
   AND cv2.code_set=26513
   AND cv2.cdf_meaning="GRID"
   AND cv2.active_ind=1
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_grid->data,v_cnt), omf_grid->data[v_cnt].old_grid_cd =
   cv1.code_value,
   omf_grid->data[v_cnt].new_grid_cd = cv2.code_value, omf_grid->data[v_cnt].display_key = cv2
   .display_key
  WITH nocounter
 ;end select
 UPDATE  FROM omf_pv_security_filter pv,
   (dummyt d1  WITH seq = value(size(omf_grid->data,5)))
  SET pv.grid_cd = omf_grid->data[d1.seq].new_grid_cd
  PLAN (d1)
   JOIN (pv
   WHERE (pv.grid_cd=omf_grid->data[d1.seq].old_grid_cd))
 ;end update
 SELECT INTO "nl:"
  tablecount = count(*)
  FROM omf_pv_security_filter pv
  WHERE (pv.grid_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=14265
    AND (cv.display_key=
   (SELECT
    cv2.display_key
    FROM code_value cv2
    WHERE cv2.code_set=26513
     AND cv2.cdf_meaning="GRID"))))
  DETAIL
   IF (tablecount > 0)
    run_status = "F"
   ELSE
    run_status = "S"
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (run_status="S")
  SET readme_data->status = "S"
  SET readme_data->message = "dts_omf_upd_pv_security successful"
 ELSE
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = "dts_omf_upd_pv_security failed"
 ENDIF
END GO
