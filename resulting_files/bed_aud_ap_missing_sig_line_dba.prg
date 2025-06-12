CREATE PROGRAM bed_aud_ap_missing_sig_line:dba
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
     2 primary_synonym = vc
     2 dta_with_sig_line = i2
 )
 FREE RECORD count
 RECORD count(
   1 qual[*]
     2 primary_synonym = vc
     2 dta_with_sig_line = i2
 )
 SET reply->run_status_flag = 1
 DECLARE gen_lab_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB"
    AND cv.active_ind=1)
  DETAIL
   gen_lab_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE ap_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="AP"
    AND cv.active_ind=1)
  DETAIL
   ap_cd = cv.code_value
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
 SET high_volume_cnt = 0
 SET cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   FROM order_catalog oc,
    orc_resource_list orl,
    profile_task_r ptr,
    discrete_task_assay dta,
    sign_line_dta_r sldr,
    sign_line_format slf
   PLAN (oc
    WHERE oc.catalog_type_cd=gen_lab_cd
     AND oc.activity_type_cd=ap_cd
     AND oc.activity_subtype_cd=ap_report_cd
     AND oc.resource_route_lvl=1
     AND oc.active_ind=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd
     AND orl.active_ind=1)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.active_ind=1)
    JOIN (sldr
    WHERE sldr.task_assay_cd=outerjoin(dta.task_assay_cd))
    JOIN (slf
    WHERE slf.format_id=outerjoin(sldr.format_id))
   ORDER BY oc.catalog_cd
   HEAD oc.catalog_cd
    cnt = (cnt+ 1), stat = alterlist(count->qual,cnt), count->qual[cnt].primary_synonym = oc
    .primary_mnemonic
   DETAIL
    IF (sldr.task_assay_cd > 0
     AND slf.format_id > 0
     AND slf.active_ind=1)
     count->qual[cnt].dta_with_sig_line = 1
    ENDIF
   WITH nocounter
  ;end select
  IF (cnt > 0)
   FOR (x = 1 TO cnt)
     IF ((count->qual[cnt].dta_with_sig_line=0))
      SET high_volume_cnt = (high_volume_cnt+ 1)
     ENDIF
   ENDFOR
  ENDIF
  CALL echo(high_volume_cnt)
  IF (high_volume_cnt > 5000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 3000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET total_reports = 0
 SELECT INTO "NL:"
  FROM order_catalog oc,
   orc_resource_list orl,
   profile_task_r ptr,
   discrete_task_assay dta,
   sign_line_dta_r sldr,
   sign_line_format slf
  PLAN (oc
   WHERE oc.catalog_type_cd=gen_lab_cd
    AND oc.activity_type_cd=ap_cd
    AND oc.activity_subtype_cd=ap_report_cd
    AND oc.resource_route_lvl=1
    AND oc.active_ind=1)
   JOIN (orl
   WHERE orl.catalog_cd=oc.catalog_cd
    AND orl.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
   JOIN (sldr
   WHERE sldr.task_assay_cd=outerjoin(dta.task_assay_cd))
   JOIN (slf
   WHERE slf.format_id=outerjoin(sldr.format_id))
  ORDER BY oc.primary_mnemonic, oc.catalog_cd
  HEAD oc.catalog_cd
   total_reports = (total_reports+ 1), stat = alterlist(temp->tqual,total_reports), temp->tqual[
   total_reports].primary_synonym = oc.primary_mnemonic
  DETAIL
   IF (sldr.task_assay_cd > 0
    AND slf.format_id > 0
    AND slf.active_ind=1)
    temp->tqual[total_reports].dta_with_sig_line = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,1)
 SET reply->collist[1].header_text = "Report"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET row_nbr = 0
 FOR (x = 1 TO total_reports)
   IF ((temp->tqual[x].dta_with_sig_line=0))
    SET row_nbr = (row_nbr+ 1)
    SET stat = alterlist(reply->rowlist,row_nbr)
    SET stat = alterlist(reply->rowlist[row_nbr].celllist,1)
    SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].primary_synonym
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "APRPTMISSINGSIGLINE"
 SET reply->statlist[1].total_items = total_reports
 SET reply->statlist[1].qualifying_items = row_nbr
 IF (row_nbr > 0)
  SET reply->statlist[1].status_flag = 3
  SET reply->run_status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
  SET reply->run_status_flag = 1
 ENDIF
#exit_script
 CALL echorecord(reply)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_reports_missing_signature_line.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
