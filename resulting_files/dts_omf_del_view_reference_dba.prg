CREATE PROGRAM dts_omf_del_view_reference:dba
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
 FREE SET dts_indicator
 RECORD dts_indicator(
   1 qual[*]
     2 cki = vc
 )
 FREE SET dts_view
 RECORD dts_view(
   1 cki = vc
 )
 FREE SET dts_viewop
 RECORD dts_viewop(
   1 qual[*]
     2 cki = vc
 )
 FREE SET dts_grid
 RECORD dts_grid(
   1 cki = vc
 )
 DECLARE rdm_errmsg = c132 WITH public, noconstant(" ")
 DECLARE errcode = i4 WITH public, noconstant(0)
 SET v_cnt = 0
 DECLARE rows_count = i4 WITH public, noconstant(0)
 SET rows_count = 57
 SET stat = alterlist(dts_indicator->qual,rows_count)
 SET dts_indicator->qual[1].cki = "CKI.CODEVALUE!2946951"
 SET dts_indicator->qual[2].cki = "CKI.CODEVALUE!2946950"
 SET dts_indicator->qual[3].cki = "CKI.CODEVALUE!52427"
 SET dts_indicator->qual[4].cki = "CKI.CODEVALUE!52428"
 SET dts_indicator->qual[5].cki = "CKI.CODEVALUE!52448"
 SET dts_indicator->qual[6].cki = "CKI.CODEVALUE!52450"
 SET dts_indicator->qual[7].cki = "CKI.CODEVALUE!2220285"
 SET dts_indicator->qual[8].cki = "CKI.CODEVALUE!52449"
 SET dts_indicator->qual[9].cki = "CKI.CODEVALUE!52447"
 SET dts_indicator->qual[10].cki = "CKI.CODEVALUE!2220204"
 SET dts_indicator->qual[11].cki = "CKI.CODEVALUE!2698987"
 SET dts_indicator->qual[12].cki = "CKI.CODEVALUE!2946947"
 SET dts_indicator->qual[13].cki = "CKI.CODEVALUE!2946948"
 SET dts_indicator->qual[14].cki = "CKI.CODEVALUE!52435"
 SET dts_indicator->qual[15].cki = "CKI.CODEVALUE!52439"
 SET dts_indicator->qual[16].cki = "CKI.CODEVALUE!2220203"
 SET dts_indicator->qual[17].cki = "CKI.CODEVALUE!2946955"
 SET dts_indicator->qual[18].cki = "CKI.CODEVALUE!2946956"
 SET dts_indicator->qual[19].cki = "CKI.CODEVALUE!52446"
 SET dts_indicator->qual[20].cki = "CKI.CODEVALUE!52434"
 SET dts_indicator->qual[21].cki = "CKI.CODEVALUE!52437"
 SET dts_indicator->qual[22].cki = "CKI.CODEVALUE!52442"
 SET dts_indicator->qual[23].cki = "CKI.CODEVALUE!52444"
 SET dts_indicator->qual[24].cki = "CKI.CODEVALUE!52440"
 SET dts_indicator->qual[25].cki = "CKI.CODEVALUE!52451"
 SET dts_indicator->qual[26].cki = "CKI.CODEVALUE!2946938"
 SET dts_indicator->qual[27].cki = "CKI.CODEVALUE!2220201"
 SET dts_indicator->qual[28].cki = "CKI.CODEVALUE!2220202"
 SET dts_indicator->qual[29].cki = "CKI.CODEVALUE!52514"
 SET dts_indicator->qual[30].cki = "CKI.CODEVALUE!52612"
 SET dts_indicator->qual[31].cki = "CKI.CODEVALUE!52513"
 SET dts_indicator->qual[32].cki = "CKI.CODEVALUE!52613"
 SET dts_indicator->qual[33].cki = "CKI.CODEVALUE!52443"
 SET dts_indicator->qual[34].cki = "CKI.CODEVALUE!2220284"
 SET dts_indicator->qual[35].cki = "CKI.CODEVALUE!2946954"
 SET dts_indicator->qual[36].cki = "CKI.CODEVALUE!2220335"
 SET dts_indicator->qual[37].cki = "CKI.CODEVALUE!2220279"
 SET dts_indicator->qual[38].cki = "CKI.CODEVALUE!2220331"
 SET dts_indicator->qual[39].cki = "CKI.CODEVALUE!2220333"
 SET dts_indicator->qual[40].cki = "CKI.CODEVALUE!2220348"
 SET dts_indicator->qual[41].cki = "CKI.CODEVALUE!2220332"
 SET dts_indicator->qual[42].cki = "CKI.CODEVALUE!52445"
 SET dts_indicator->qual[43].cki = "CKI.CODEVALUE!2220199"
 SET dts_indicator->qual[44].cki = "CKI.CODEVALUE!2220200"
 SET dts_indicator->qual[45].cki = "CKI.CODEVALUE!52433"
 SET dts_indicator->qual[46].cki = "CKI.CODEVALUE!52432"
 SET dts_indicator->qual[47].cki = "CKI.CODEVALUE!2946949"
 SET dts_indicator->qual[48].cki = "CKI.CODEVALUE!2946952"
 SET dts_indicator->qual[49].cki = "CKI.CODEVALUE!52430"
 SET dts_indicator->qual[50].cki = "CKI.CODEVALUE!52429"
 SET dts_indicator->qual[51].cki = "CKI.CODEVALUE!2946957"
 SET dts_indicator->qual[52].cki = "CKI.CODEVALUE!52425"
 SET dts_indicator->qual[53].cki = "CKI.CODEVALUE!52426"
 SET dts_indicator->qual[54].cki = "CKI.CODEVALUE!2946958"
 SET dts_indicator->qual[55].cki = "CKI.CODEVALUE!2946953"
 SET dts_indicator->qual[56].cki = "CKI.CODEVALUE!52441"
 SET dts_indicator->qual[57].cki = "CKI.CODEVALUE!2220283"
 SELECT INTO "nl:"
  oi.indicator_cd
  FROM omf_indicator oi,
   code_value cv,
   (dummyt d  WITH seq = value(rows_count))
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=14265
    AND (cv.cki=dts_indicator->qual[d.seq].cki))
   JOIN (oi
   WHERE oi.indicator_cd != 0
    AND oi.indicator_cd=cv.code_value)
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_indicator->data,v_cnt), omf_indicator->data[v_cnt].
   indicator_cd = oi.indicator_cd
  WITH nocounter
 ;end select
 SET v_cnt = 0
 SET dts_view->cki = "CKI.CODEVALUE!52384"
 SELECT INTO "nl:"
  opv.view_cd
  FROM omf_pv_view opv,
   code_value cv
  WHERE opv.view_cd != 0
   AND opv.view_cd=cv.code_value
   AND cv.code_set=14265
   AND cv.active_ind=1
   AND (cv.cki=dts_view->cki)
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_pv_view->data,v_cnt), omf_pv_view->data[v_cnt].view_cd =
   opv.view_cd
  WITH nocounter
 ;end select
 SET v_cnt = 0
 SET rows_count = 3
 SET stat = alterlist(dts_viewop->qual,rows_count)
 SET dts_viewop->qual[1].cki = "CKI.CODEVALUE!54316"
 SET dts_viewop->qual[2].cki = "CKI.CODEVALUE!52452"
 SET dts_viewop->qual[3].cki = "CKI.CODEVALUE!54317"
 SELECT INTO "nl:"
  vot.vo_type_cd, vot.vo_indicator_cd
  FROM omf_vo_type vot,
   code_value cv,
   (dummyt d  WITH seq = value(rows_count))
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=14210
    AND (cv.cki=dts_viewop->qual[d.seq].cki))
   JOIN (vot
   WHERE vot.vo_type_cd != 0
    AND vot.vo_type_cd=cv.code_value)
  DETAIL
   v_cnt = (v_cnt+ 1), stat = alterlist(omf_vo_type->data,v_cnt), omf_vo_type->data[v_cnt].vo_type_cd
    = vot.vo_type_cd,
   omf_vo_type->data[v_cnt].vo_indicator_cd = vot.vo_indicator_cd
  WITH nocounter
 ;end select
 SET v_cnt = 0
 SET dts_grid->cki = "CKI.CODEVALUE!52421"
 SELECT INTO "nl:"
  og.grid_cd
  FROM omf_grid og,
   code_value cv
  WHERE og.grid_cd != 0
   AND og.grid_cd=cv.code_value
   AND cv.code_set=14265
   AND cv.active_ind=1
   AND (cv.cki=dts_grid->cki)
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
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FOR (v_cnt = 1 TO size(omf_pv_view->data,5))
   DELETE  FROM omf_pv_view opv
    WHERE (opv.view_cd=omf_pv_view->data[v_cnt].view_cd)
   ;end delete
 ENDFOR
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FOR (v_cnt = 1 TO size(omf_vo_type->data,5))
   DELETE  FROM omf_vo_type ovt
    WHERE (ovt.vo_type_cd=omf_vo_type->data[v_cnt].vo_type_cd)
   ;end delete
 ENDFOR
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FOR (v_cnt = 1 TO size(omf_grid->data,5))
   DELETE  FROM omf_grid og
    WHERE (og.grid_cd=omf_grid->data[v_cnt].grid_cd)
   ;end delete
 ENDFOR
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FOR (v_cnt = 1 TO size(omf_grid->data,5))
   DELETE  FROM omf_grid_column ogc
    WHERE (ogc.grid_cd=omf_grid->data[v_cnt].grid_cd)
   ;end delete
 ENDFOR
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FOR (v_cnt = 1 TO size(omf_pv_view->data,5))
   DELETE  FROM omf_view_indicator ovi
    WHERE (ovi.view_cd=omf_pv_view->data[v_cnt].view_cd)
   ;end delete
 ENDFOR
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FOR (v_cnt = 1 TO size(omf_vo_type->data,5))
   DELETE  FROM omf_vo_type_display ovtd
    WHERE (ovtd.vo_type_cd=omf_vo_type->data[v_cnt].vo_type_cd)
   ;end delete
 ENDFOR
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FOR (v_cnt = 1 TO size(omf_vo_type->data,5))
   DELETE  FROM omf_vo_indicator_group ovig
    WHERE (ovig.parent_indicator_cd=omf_vo_type->data[v_cnt].vo_indicator_cd)
   ;end delete
 ENDFOR
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
 FOR (v_cnt = 1 TO size(omf_indicator->data,5))
   DELETE  FROM omf_calc_indicator oci
    WHERE (oci.indicator_cd=omf_indicator->data[v_cnt].indicator_cd)
   ;end delete
 ENDFOR
 SET errcode = error(rdm_errmsg,0)
 IF (errcode != 0)
  SET readme_data->message = rdm_errmsg
  SET readme_data->status = "F"
  GO TO exit_script
 ENDIF
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "dts_omf_del_view_reference successful."
 ENDIF
END GO
