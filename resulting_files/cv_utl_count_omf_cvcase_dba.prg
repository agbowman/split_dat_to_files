CREATE PROGRAM cv_utl_count_omf_cvcase:dba
 SELECT
  *
  FROM omf_calc_indicator oci,
   code_value cv
  WHERE oci.indicator_cd != 0
   AND oci.indicator_cd=cv.code_value
   AND cv.display_key="CVCASE*"
  WITH nocounter
 ;end select
 SELECT
  *
  FROM omf_grid_column ogc,
   code_value cv
  WHERE ogc.grid_cd != 0
   AND ogc.grid_column_cd=cv.code_value
   AND cv.display_key="CVCASE*"
  WITH nocounter
 ;end select
 SELECT
  *
  FROM omf_grid og,
   code_value cv
  WHERE og.grid_cd != 0
   AND og.view_cd=cv.code_value
   AND cv.display_key="CVCASE*"
  WITH nocounter
 ;end select
 SELECT
  *
  FROM omf_indicator oi,
   code_value cv
  WHERE oi.indicator_cd != 0
   AND oi.indicator_cd=cv.code_value
   AND cv.display_key="CVCASE*"
  WITH nocounter
 ;end select
 SELECT
  *
  FROM omf_pv_view opv,
   code_value cv
  WHERE opv.view_cd != 0
   AND opv.view_cd=cv.code_value
   AND cv.display_key="CVCASE*"
  WITH nocounter
 ;end select
 SELECT
  *
  FROM omf_view_indicator ovi,
   code_value cv1,
   code_value cv2
  WHERE ovi.view_cd != 0
   AND ovi.view_cd=cv1.code_value
   AND cv1.display_key="CVCASE*"
   AND cv2.code_value=ovi.indicator_cd
  WITH nocounter
 ;end select
 SELECT
  *
  FROM omf_vo_type ovt,
   omf_vo_type_display ovd,
   code_value cv
  WHERE ovt.vo_type_cd != 0
   AND ovt.vo_indicator_cd=cv.code_value
   AND cv.display_key="CVCASE*"
   AND ovd.vo_type_cd=ovt.vo_type_cd
  WITH nocounter
 ;end select
END GO
