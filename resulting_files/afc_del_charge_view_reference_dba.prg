CREATE PROGRAM afc_del_charge_view_reference:dba
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
 FREE SET omf_indicator
 RECORD omf_indicator(
   1 data[*]
     2 indicator_cd = f8
 )
 FREE SET omf_pv_view
 RECORD omf_pv_view(
   1 data[*]
     2 view_cd = f8
 )
 FREE SET omf_vo_type
 RECORD omf_vo_type(
   1 data[*]
     2 vo_type_cd = f8
     2 vo_indicator_cd = f8
 )
 FREE SET omf_grid
 RECORD omf_grid(
   1 data[*]
     2 grid_cd = f8
 )
 SET v_cnt = 0
 SELECT INTO "nl:"
  oi.indicator_cd
  FROM omf_indicator oi,
   code_value cv
  WHERE oi.indicator_cd != 0
   AND oi.indicator_cd=cv.code_value
   AND cv.code_set=14265
   AND cv.display_key="AFC*"
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_indicator->data,v_cnt), omf_indicator->data[v_cnt].
   indicator_cd = oi.indicator_cd
  WITH nocounter
 ;end select
 SET v_cnt = 0
 SELECT INTO "nl:"
  opv.view_cd
  FROM omf_pv_view opv,
   code_value cv
  WHERE opv.view_cd != 0
   AND opv.view_cd=cv.code_value
   AND cv.code_set=14265
   AND cv.active_ind=1
   AND cv.display_key="AFC*"
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_pv_view->data,v_cnt), omf_pv_view->data[v_cnt].view_cd =
   opv.view_cd
  WITH nocounter
 ;end select
 SET v_cnt = 0
 SELECT INTO "nl:"
  vot.vo_type_cd, vot.vo_indicator_cd
  FROM omf_vo_type vot,
   code_value cv
  WHERE vot.vo_type_cd != 0
   AND vot.vo_type_cd=cv.code_value
   AND cv.code_set=14210
   AND cv.display_key="AFC*"
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_vo_type->data,v_cnt), omf_vo_type->data[v_cnt].vo_type_cd
    = vot.vo_type_cd,
   omf_vo_type->data[v_cnt].vo_indicator_cd = vot.vo_indicator_cd
  WITH nocounter
 ;end select
 SET v_cnt = 0
 SELECT INTO "nl:"
  og.grid_cd
  FROM omf_grid og,
   code_value cv
  WHERE ((cv.display_key="AFC*") OR (cv.display_key="CHARGESERVICE*"))
   AND og.grid_cd != 0
   AND og.view_cd=cv.code_value
   AND cv.code_set=14265
   AND cv.active_ind=1
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_grid->data,v_cnt), omf_grid->data[v_cnt].grid_cd = og
   .grid_cd
  WITH nocounter
 ;end select
 FOR (v_cnt = 1 TO size(omf_indicator->data,5))
   DELETE  FROM omf_indicator oi
    WHERE (oi.indicator_cd=omf_indicator->data[v_cnt].indicator_cd)
   ;end delete
 ENDFOR
 FOR (v_cnt = 1 TO size(omf_pv_view->data,5))
   DELETE  FROM omf_pv_view opv
    WHERE (opv.view_cd=omf_pv_view->data[v_cnt].view_cd)
   ;end delete
 ENDFOR
 FOR (v_cnt = 1 TO size(omf_vo_type->data,5))
   DELETE  FROM omf_vo_type ovt
    WHERE (ovt.vo_type_cd=omf_vo_type->data[v_cnt].vo_type_cd)
   ;end delete
 ENDFOR
 FOR (v_cnt = 1 TO size(omf_grid->data,5))
   DELETE  FROM omf_grid og
    WHERE (og.grid_cd=omf_grid->data[v_cnt].grid_cd)
   ;end delete
 ENDFOR
 FOR (v_cnt = 1 TO size(omf_grid->data,5))
   DELETE  FROM omf_grid_column ogc
    WHERE (ogc.grid_cd=omf_grid->data[v_cnt].grid_cd)
   ;end delete
 ENDFOR
 FOR (v_cnt = 1 TO size(omf_pv_view->data,5))
   DELETE  FROM omf_view_indicator ovi
    WHERE (ovi.view_cd=omf_pv_view->data[v_cnt].view_cd)
   ;end delete
 ENDFOR
 FOR (v_cnt = 1 TO size(omf_vo_type->data,5))
   DELETE  FROM omf_vo_type_display ovtd
    WHERE (ovtd.vo_type_cd=omf_vo_type->data[v_cnt].vo_type_cd)
   ;end delete
 ENDFOR
 FOR (v_cnt = 1 TO size(omf_vo_type->data,5))
   DELETE  FROM omf_vo_indicator_group ovig
    WHERE (ovig.parent_indicator_cd=omf_vo_type->data[v_cnt].vo_indicator_cd)
   ;end delete
 ENDFOR
 FOR (v_cnt = 1 TO size(omf_indicator->data,5))
   DELETE  FROM omf_calc_indicator oci
    WHERE (oci.indicator_cd=omf_indicator->data[v_cnt].indicator_cd)
   ;end delete
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "View information deleted."
END GO
