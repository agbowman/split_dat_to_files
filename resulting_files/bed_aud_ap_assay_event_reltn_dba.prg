CREATE PROGRAM bed_aud_ap_assay_event_reltn:dba
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
     2 activity_type = vc
     2 catalog_type = vc
     2 assay_disp = vc
     2 assay_desc = vc
     2 event_code_disp = vc
     2 event_set_name = vc
     2 event_set_disp = vc
     2 event_set_desc = vc
 )
 DECLARE activity_code_value = f8
 DECLARE act_type = vc WITH public
 DECLARE cat_type = vc WITH public
 SELECT INTO "NL:"
  cv.code_value
  FROM code_value cv
  WHERE cv.cdf_meaning="AP"
   AND cv.code_set=106
   AND cv.active_ind=1
  DETAIL
   activity_code_value = cv.code_value, act_type = cv.display
  WITH nocounter
 ;end select
 DECLARE ap_report_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=5801
    AND cv.cdf_meaning="APREPORT"
    AND cv.active_ind=1)
  DETAIL
   ap_report_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE gen_lab_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB"
    AND cv.active_ind=1)
  DETAIL
   gen_lab_cd = cv.code_value, cat_type = cv.display
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   hv_cnt = count(*)
   FROM discrete_task_assay dta,
    order_catalog oc,
    profile_task_r ptr,
    code_value_event_r cver,
    v500_event_code vec,
    v500_event_set_explode vese,
    v500_event_set_code vesc
   PLAN (oc
    WHERE oc.catalog_type_cd=gen_lab_cd
     AND oc.activity_type_cd=activity_code_value
     AND oc.activity_subtype_cd=ap_report_cd
     AND oc.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.activity_type_cd=activity_code_value
     AND dta.active_ind=1)
    JOIN (cver
    WHERE cver.parent_cd=outerjoin(dta.task_assay_cd))
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
  IF (high_volume_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM discrete_task_assay dta,
   order_catalog oc,
   profile_task_r ptr,
   code_value_event_r cver,
   v500_event_code vec,
   v500_event_set_explode vese,
   v500_event_set_code vesc
  PLAN (oc
   WHERE oc.catalog_type_cd=gen_lab_cd
    AND oc.activity_type_cd=activity_code_value
    AND oc.activity_subtype_cd=ap_report_cd
    AND oc.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.activity_type_cd=activity_code_value
    AND dta.active_ind=1)
   JOIN (cver
   WHERE cver.parent_cd=outerjoin(dta.task_assay_cd))
   JOIN (vec
   WHERE vec.event_cd=outerjoin(cver.event_cd))
   JOIN (vese
   WHERE vese.event_cd=outerjoin(vec.event_cd)
    AND vese.event_set_level=outerjoin(0))
   JOIN (vesc
   WHERE vesc.event_set_cd=outerjoin(vese.event_set_cd))
  ORDER BY dta.mnemonic_key_cap, vec.event_cd_disp, vesc.event_set_cd_disp
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt), temp->tqual[tcnt].activity_type = act_type,
   temp->tqual[tcnt].catalog_type = cat_type, temp->tqual[tcnt].assay_disp = dta.mnemonic, temp->
   tqual[tcnt].assay_desc = dta.description,
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
 SET reply->collist[3].header_text = "Assay Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assay Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Event Code Display (Paper Chart)"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Event Set Name"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Event Set Display (PowerChart Flowsheet)"
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
   SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].assay_disp
   SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].assay_desc
   SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].event_code_disp
   SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].event_set_name
   SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].event_set_disp
   SET reply->rowlist[row_nbr].celllist[8].string_value = temp->tqual[x].event_set_desc
 ENDFOR
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_assays_to_evntcd_evntset.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
