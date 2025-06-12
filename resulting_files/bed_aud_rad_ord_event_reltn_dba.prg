CREATE PROGRAM bed_aud_rad_ord_event_reltn:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 paramlist[*]
      2 param_type_mean = vc
      2 pdate1 = dq8
      2 pdate2 = dq8
      2 vlist[*]
        3 dbl_value = f8
        3 string_value = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 tqual[*]
     2 catalog_type = vc
     2 activity_type = vc
     2 mill_name = vc
     2 dept_name = vc
     2 event_code_disp = vc
     2 event_set_name = vc
     2 event_set_disp = vc
     2 event_set_desc = vc
 )
 DECLARE radcat = f8 WITH public, noconstant(0.0)
 DECLARE rad = f8 WITH public, noconstant(0.0)
 DECLARE act_type = vc WITH public
 DECLARE cat_type = vc WITH public
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   rad = cv.code_value, act_type = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   radcat = cv.code_value, cat_type = cv.display
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM order_catalog oc,
    code_value_event_r cver,
    v500_event_code vec,
    v500_event_set_explode vese,
    v500_event_set_code vesc
   PLAN (oc
    WHERE oc.activity_type_cd=rad
     AND oc.catalog_type_cd=radcat
     AND oc.active_ind=1)
    JOIN (cver
    WHERE cver.parent_cd=outerjoin(oc.catalog_cd))
    JOIN (vec
    WHERE vec.event_cd=outerjoin(cver.event_cd))
    JOIN (vese
    WHERE vese.event_cd=outerjoin(vec.event_cd)
     AND vese.event_set_level=outerjoin(0))
    JOIN (vesc
    WHERE vesc.event_set_cd=outerjoin(vese.event_set_cd))
   DETAIL
    high_volume_cnt = hv_cnt
   WITH nocounter
  ;end select
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   code_value_event_r cver,
   v500_event_code vec,
   v500_event_set_explode vese,
   v500_event_set_code vesc
  PLAN (oc
   WHERE oc.activity_type_cd=rad
    AND oc.catalog_type_cd=radcat
    AND oc.active_ind=1)
   JOIN (cver
   WHERE cver.parent_cd=outerjoin(oc.catalog_cd))
   JOIN (vec
   WHERE vec.event_cd=outerjoin(cver.event_cd))
   JOIN (vese
   WHERE vese.event_cd=outerjoin(vec.event_cd)
    AND vese.event_set_level=outerjoin(0))
   JOIN (vesc
   WHERE vesc.event_set_cd=outerjoin(vese.event_set_cd))
  ORDER BY oc.primary_mnemonic, vec.event_cd_disp, vesc.event_set_cd_disp
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].catalog_type = cat_type,
   temp->tqual[tcnt].activity_type = act_type, temp->tqual[tcnt].mill_name = oc.primary_mnemonic,
   temp->tqual[tcnt].dept_name = oc.dept_display_name,
   temp->tqual[tcnt].event_code_disp = vec.event_cd_disp, temp->tqual[tcnt].event_set_name = vesc
   .event_set_name, temp->tqual[tcnt].event_set_disp = vesc.event_set_cd_disp,
   temp->tqual[tcnt].event_set_desc = vesc.event_set_cd_descr
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,8)
 SET reply->collist[1].header_text = "Catalog Type"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Activity Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Millennium Name (Primary Synonym)"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Department Name (Label Display)"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Event Code Display"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Event Set Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Event Set Display"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Event Set Description"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET row_nbr = (row_nbr+ 1)
   SET stat = alterlist(reply->rowlist,row_nbr)
   SET stat = alterlist(reply->rowlist[row_nbr].celllist,8)
   SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].catalog_type
   SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].activity_type
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].mill_name
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].dept_name
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].event_code_disp
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].event_set_name
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].event_set_disp
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].event_set_desc
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("rad_ord_to_evntcode_evntset.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
