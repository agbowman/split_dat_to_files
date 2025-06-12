CREATE PROGRAM cv_utl_del_omf_cvaccg:dba
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
 SET readme_data->message = "Running cv_utl_del_omf_cvaccg."
 EXECUTE dm_readme_status
 SET failure = "F"
 DELETE  FROM omf_vo_type_display ovd
  WHERE (ovd.vo_type_cd=
  (SELECT
   ovt.vo_type_cd
   FROM omf_vo_type ovt,
    code_value cv
   WHERE cv.display_key="CVACCG*"
    AND ovt.vo_indicator_cd=cv.code_value))
 ;end delete
 DELETE  FROM omf_vo_type ovt
  WHERE (ovt.vo_indicator_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVACCG*"))
 ;end delete
 SELECT INTO "nl:"
  ovt.vo_type_cd
  FROM omf_vo_type ovt,
   omf_vo_type_display ovd,
   code_value cv
  PLAN (ovt
   WHERE ovt.vo_type_cd != 0)
   JOIN (cv
   WHERE cv.code_value=ovt.vo_indicator_cd
    AND cv.display="CVACCG*"
    AND cv.code_set=24549)
   JOIN (ovd
   WHERE ovd.vo_type_cd=ovt.vo_type_cd)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to delete from omf_vo_type, omf_vo_type_display tables."
  EXECUTE dm_readme_status
  SET failure = "T"
 ENDIF
 DELETE  FROM omf_vo_indicator_group ovig
  WHERE (ovig.parent_indicator_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVACCG*"))
 ;end delete
 SELECT INTO "nl:"
  ovig.parent_indicator_cd
  FROM omf_vo_indicator_group ovig,
   code_value cv
  WHERE ovig.parent_indicator_cd != 0
   AND ovig.parent_indicator_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display="CVACCG*"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to delete from omf_vo_indicator_group table."
  EXECUTE dm_readme_status
  SET failure = "T"
 ENDIF
 DELETE  FROM omf_calc_indicator oci
  WHERE (oci.calc_indicator_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVACCG*"))
 ;end delete
 SELECT INTO "nl:"
  oci.indicator_cd
  FROM omf_calc_indicator oci,
   code_value cv
  WHERE oci.indicator_cd != 0
   AND oci.indicator_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display="CVACCG*"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to delete from omf_calc_indicator table."
  EXECUTE dm_readme_status
  SET failure = "T"
 ENDIF
 DELETE  FROM omf_grid_column ogc
  WHERE (ogc.grid_column_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVACCG*"))
 ;end delete
 SELECT INTO "nl:"
  ogc.grid_cd
  FROM omf_grid_column ogc,
   code_value cv
  WHERE ogc.grid_cd != 0
   AND ogc.grid_column_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display="CVACCG*"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to delete from omf_grid_column table."
  EXECUTE dm_readme_status
  SET failure = "T"
 ENDIF
 DELETE  FROM omf_grid og
  WHERE (og.view_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVACCG*"))
 ;end delete
 SELECT INTO "nl:"
  og.grid_cd
  FROM omf_grid og,
   code_value cv
  WHERE og.grid_cd != 0
   AND og.view_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display="CVACCG*"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to delete from omf_grid table."
  EXECUTE dm_readme_status
  SET failure = "T"
 ENDIF
 DELETE  FROM omf_view_indicator ovi
  WHERE (ovi.view_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVACCG*"))
 ;end delete
 SELECT INTO "nl:"
  ovi.view_cd
  FROM omf_view_indicator ovi,
   code_value cv1,
   code_value cv2
  WHERE ovi.view_cd != 0
   AND ovi.view_cd=cv1.code_value
   AND cv1.display="CVACCG*"
   AND cv1.code_set=24549
   AND cv2.code_value=ovi.indicator_cd
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to delete from omf_view_indicator table."
  EXECUTE dm_readme_status
  SET failure = "T"
 ENDIF
 DELETE  FROM omf_pv_view opv
  WHERE (opv.view_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVACCG*"))
 ;end delete
 SELECT INTO "nl:"
  opv.view_cd
  FROM omf_pv_view opv,
   code_value cv
  WHERE opv.view_cd != 0
   AND opv.view_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display="CVACCG*"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to delete from omf_pv_view table."
  EXECUTE dm_readme_status
  SET failure = "T"
 ENDIF
 DELETE  FROM omf_indicator oi
  WHERE (oi.indicator_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVACCG*"))
 ;end delete
 SELECT INTO "nl:"
  oi.indicator_cd
  FROM omf_indicator oi,
   code_value cv
  WHERE oi.indicator_cd != 0
   AND oi.indicator_cd=cv.code_value
   AND cv.code_set=24549
   AND cv.display="CVACCG*"
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to delete from omf_indicator table."
  EXECUTE dm_readme_status
  SET failure = "T"
 ENDIF
 IF (failure="T")
  SET readme_data->status = "F"
  SET readme_data->message = "Readme failed"
  EXECUTE dm_readme_status
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Readme succeeded"
  EXECUTE dm_readme_status
 ENDIF
 COMMIT
END GO
