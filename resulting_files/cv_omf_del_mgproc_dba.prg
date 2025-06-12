CREATE PROGRAM cv_omf_del_mgproc:dba
 DELETE  FROM omf_vo_type_display ovd
  WHERE (ovd.vo_type_cd=
  (SELECT
   ovt.vo_type_cd
   FROM omf_vo_type ovt,
    code_value cv
   WHERE cv.display_key="CVPROC*"
    AND ovt.vo_indicator_cd=cv.code_value))
  WITH nocounter
 ;end delete
 DELETE  FROM omf_vo_type ovt
  WHERE (ovt.vo_indicator_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVPROC*"))
  WITH nocounter
 ;end delete
 DELETE  FROM omf_vo_indicator_group ovig
  WHERE (ovig.parent_indicator_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVPROC*"))
  WITH nocounter
 ;end delete
 DELETE  FROM omf_calc_indicator oci
  WHERE (oci.calc_indicator_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVPROC*"))
  WITH nocounter
 ;end delete
 DELETE  FROM omf_grid_column ogc
  WHERE (ogc.grid_column_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVPROC*"))
  WITH nocounter
 ;end delete
 DELETE  FROM omf_grid og
  WHERE (og.view_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVPROC*"))
  WITH nocounter
 ;end delete
 DELETE  FROM omf_view_indicator ovi
  WHERE (ovi.view_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVPROC*"))
  WITH nocounter
 ;end delete
 DELETE  FROM omf_pv_view opv
  WHERE (opv.view_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVPROC*"))
  WITH nocounter
 ;end delete
 DELETE  FROM omf_indicator oi
  WHERE (oi.indicator_cd=
  (SELECT
   cv.code_value
   FROM code_value cv
   WHERE cv.display_key="CVPROC*"))
  WITH nocounter
 ;end delete
 COMMIT
END GO
