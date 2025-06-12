CREATE PROGRAM afc_upd_pv_security_name:dba
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
 SET readme_data->message = "Executing afc_upd_pv_security_name."
 FREE SET omf_grid
 RECORD omf_grid(
   1 data[*]
     2 old_grid_cd = f8
     2 new_grid_cd = f8
     2 display_key = vc
 )
 SET v_cnt = 0
 SELECT INTO "nl:"
  cv1.code_value, cv2.code_value, cv2.display_key
  FROM code_value cv1,
   code_value cv2
  WHERE cv1.code_set=14265
   AND cv1.cdf_meaning="GRID"
   AND cv1.active_ind=1
   AND cv1.display_key=cv2.display_key
   AND cv2.code_set=26793
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
  cv1.code_value, cv2.code_value, cv2.display_key
  FROM code_value cv1,
   code_value cv2,
   omf_pv_security_filter o
  PLAN (cv1
   WHERE cv1.code_set=14265
    AND cv1.cdf_meaning="GRID"
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.display_key=cv1.display_key
    AND cv2.code_set=26793
    AND cv2.cdf_meaning="GRID"
    AND cv2.active_ind=1)
   JOIN (o
   WHERE o.grid_cd=cv1.code_value)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET readme_data->status = "S"
  SET readme_data->message = "Grid security updated."
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Grid security update unsuccessful."
 ENDIF
 EXECUTE dm_readme_status
END GO
