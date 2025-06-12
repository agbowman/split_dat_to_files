CREATE PROGRAM cv_omf_upd_pv_security_name:dba
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
   AND cv2.code_set=24549
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
 COMMIT
END GO
