CREATE PROGRAM bed_aud_ap_incmplt_rpt_his_grp:dba
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
     2 assays[*]
       3 mnemonic = vc
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
 DECLARE interp_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE text_type_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning IN ("4", "1")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="4")
    interp_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="1")
    text_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT DISTINCT INTO "nl:"
   FROM order_catalog oc,
    orc_resource_list orl,
    profile_task_r ptr,
    discrete_task_assay dta,
    report_history_grouping_r rhgr
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
     AND dta.default_result_type_cd IN (interp_type_cd, text_type_cd)
     AND dta.active_ind=1)
    JOIN (rhgr
    WHERE rhgr.task_assay_cd=outerjoin(dta.task_assay_cd))
   ORDER BY oc.primary_mnemonic, dta.mnemonic, oc.catalog_cd
   HEAD oc.catalog_cd
    high_volume_cnt = high_volume_cnt
   DETAIL
    IF (rhgr.task_assay_cd=0)
     high_volume_cnt = (high_volume_cnt+ 1)
    ENDIF
   WITH nocounter
  ;end select
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
 SET acnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog oc,
   orc_resource_list orl,
   profile_task_r ptr,
   discrete_task_assay dta,
   report_history_grouping_r rhgr
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
    AND dta.default_result_type_cd IN (interp_type_cd, text_type_cd)
    AND dta.active_ind=1)
   JOIN (rhgr
   WHERE rhgr.task_assay_cd=outerjoin(dta.task_assay_cd))
  ORDER BY oc.primary_mnemonic, dta.mnemonic, oc.catalog_cd
  HEAD oc.catalog_cd
   total_reports = (total_reports+ 1), stat = alterlist(temp->tqual,total_reports), temp->tqual[
   total_reports].primary_synonym = oc.primary_mnemonic,
   acnt = 0
  DETAIL
   IF (rhgr.task_assay_cd=0)
    acnt = (acnt+ 1), stat = alterlist(temp->tqual[total_reports].assays,acnt), temp->tqual[
    total_reports].assays[acnt].mnemonic = dta.mnemonic
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,2)
 SET reply->collist[1].header_text = "Report"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET rpts_missing_group = 0
 SET row_nbr = 0
 FOR (x = 1 TO total_reports)
  SET acnt = size(temp->tqual[x].assays,5)
  IF (acnt > 0)
   SET rpts_missing_group = (rpts_missing_group+ 1)
   FOR (a = 1 TO acnt)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,2)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].primary_synonym
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].assays[a].mnemonic
   ENDFOR
  ENDIF
 ENDFOR
 IF (row_nbr > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "APRPTMISSINGHISTGRP"
 SET reply->statlist[1].total_items = total_reports
 SET reply->statlist[1].qualifying_items = rpts_missing_group
 IF (rpts_missing_group > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 CALL echorecord(reply)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_reports_missing_history_grouping.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
