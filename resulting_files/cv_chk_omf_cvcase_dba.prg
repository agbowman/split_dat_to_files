CREATE PROGRAM cv_chk_omf_cvcase:dba
 SET error_msg = fillstring(200," ")
 SET failure = "F"
 SET v_count1 = 0
 SET v_cnt_indicator = 307
 SET v_cnt_pv_view = 3
 SET v_cnt_view_options = 181
 SET v_cnt_view_indicator = 341
 SET v_cnt_grid = 3
 SET v_cnt_grid_column = 6
 SET v_cnt_calc_indicator = 4
 SET v_indicator_flag = 0
 SET v_pv_view_flag = 0
 SET v_view_options_flag = 0
 SET v_view_indicator_flag = 0
 SET v_grid_flag = 0
 SET v_grid_column_flag = 0
 SET v_calc_indicator_flag = 0
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_indicator oi,
   code_value cv
  WHERE oi.indicator_cd != 0
   AND oi.indicator_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display IN ("CVCASE*")
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_cnt_indicator)
  SET failure = "T"
  SET v_indicator_flag = 1
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_pv_view opv,
   code_value cv
  WHERE opv.view_cd != 0
   AND opv.view_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display IN ("CVCASE*")
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_cnt_pv_view)
  SET failure = "T"
  SET v_pv_view_flag = 1
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_vo_type ovt,
   omf_vo_type_display ovd,
   code_value cv
  PLAN (ovt
   WHERE ovt.vo_type_cd != 0)
   JOIN (cv
   WHERE cv.code_value=ovt.vo_indicator_cd
    AND cv.code_set=24549
    AND cv.display IN ("CVCASE*"))
   JOIN (ovd
   WHERE ovd.vo_type_cd=ovt.vo_type_cd)
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_cnt_view_options)
  SET failure = "T"
  SET v_view_options_flag = 1
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_view_indicator ovi,
   code_value cv
  WHERE ovi.view_cd != 0
   AND ovi.view_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display IN ("CVCASE2*")
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_cnt_view_indicator)
  SET failure = "T"
  SET v_view_indicator_flag = 1
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_grid og,
   code_value cv
  WHERE og.grid_cd != 0
   AND og.view_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display IN ("CVCASE*")
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_cnt_grid)
  SET failure = "T"
  SET v_grid_flag = 1
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_grid_column ogc,
   code_value cv
  WHERE ogc.grid_cd != 0
   AND ogc.grid_column_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display IN ("CVCASE*")
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_cnt_grid_column)
  SET failure = "T"
  SET v_grid_column_flag = 1
 ENDIF
 SELECT INTO "nl:"
  table_count = count(*)
  FROM omf_calc_indicator oci,
   code_value cv
  WHERE oci.indicator_cd != 0
   AND oci.indicator_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display IN ("CVCASE*")
  DETAIL
   v_count1 = table_count
  WITH nocounter
 ;end select
 IF (v_count1 < v_cnt_calc_indicator)
  SET failure = "T"
  SET v_calc_indicator_flag = 1
 ENDIF
 IF (failure="T")
  SET error_msg = "Incorrect counts found on the following tables: "
  IF (v_indicator_flag=1)
   SET error_msg = concat(trim(error_msg,3),",omf_indicator_cvcase")
  ENDIF
  IF (v_pv_view_flag=1)
   SET error_msg = concat(trim(error_msg,3),",omf_pv_view_cvcase")
  ENDIF
  IF (v_view_options_flag=1)
   SET error_msg = concat(trim(error_msg,3),",omf_vo_type/omf_vo_type_display_cvcase")
  ENDIF
  IF (v_view_indicator_flag=1)
   SET error_msg = concat(trim(error_msg,3),",omf_view_indicator_cvcase")
  ENDIF
  IF (v_grid_flag=1)
   SET error_msg = concat(trim(error_msg,3),",omf_grid_cvcase")
  ENDIF
  IF (v_grid_column_flag=1)
   SET error_msg = concat(trim(error_msg,3),",omf_grid_column_cvcase")
  ENDIF
  IF (v_calc_indicator_flag=1)
   SET error_msg = concat(trim(error_msg,3),",omf_calc_indicator_cvcase")
  ENDIF
  CALL echo(error_msg)
 ELSE
  CALL echo("CVNet OMF ACC I Views successfully loaded!")
 ENDIF
END GO
