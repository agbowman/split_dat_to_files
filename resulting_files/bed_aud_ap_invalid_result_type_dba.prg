CREATE PROGRAM bed_aud_ap_invalid_result_type:dba
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
     2 resources[*]
       3 display = vc
       3 assays[*]
         4 mnemonic = vc
         4 result_type = f8
         4 sr_result_type = f8
 )
 FREE RECORD count
 RECORD count(
   1 tqual[*]
     2 primary_synonym = vc
     2 resources[*]
       3 display = vc
       3 assays[*]
         4 mnemonic = vc
         4 result_type = f8
         4 sr_result_type = f8
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
 DECLARE alpha_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE interp_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE text_type_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning IN ("2", "4", "1")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="2")
    alpha_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="4")
    interp_type_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="1")
    text_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SET total_reports = 0
  SET rcnt = 0
  SET acnt = 0
  SELECT DISTINCT INTO "NL:"
   FROM order_catalog oc,
    orc_resource_list orl,
    profile_task_r ptr,
    assay_processing_r apr,
    code_value cv,
    discrete_task_assay dta
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
    JOIN (apr
    WHERE apr.service_resource_cd=orl.service_resource_cd
     AND apr.task_assay_cd=ptr.task_assay_cd
     AND apr.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=apr.service_resource_cd
     AND cv.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd
     AND dta.active_ind=1)
   ORDER BY oc.primary_mnemonic, oc.catalog_cd, cv.display,
    apr.service_resource_cd, ptr.sequence, dta.mnemonic,
    dta.task_assay_cd
   HEAD oc.catalog_cd
    total_reports = (total_reports+ 1), stat = alterlist(count->tqual,total_reports), count->tqual[
    total_reports].primary_synonym = oc.primary_mnemonic,
    rcnt = 0
   HEAD apr.service_resource_cd
    rcnt = (rcnt+ 1), stat = alterlist(count->tqual[total_reports].resources,rcnt), count->tqual[
    total_reports].resources[rcnt].display = cv.display,
    acnt = 0
   HEAD dta.task_assay_cd
    acnt = (acnt+ 1), stat = alterlist(count->tqual[total_reports].resources[rcnt].assays,acnt),
    count->tqual[total_reports].resources[rcnt].assays[acnt].mnemonic = dta.mnemonic,
    count->tqual[total_reports].resources[rcnt].assays[acnt].result_type = dta.default_result_type_cd,
    count->tqual[total_reports].resources[rcnt].assays[acnt].sr_result_type = apr
    .default_result_type_cd
   WITH nocounter
  ;end select
  SET high_volume_cnt = 0
  FOR (x = 1 TO total_reports)
   SET rcnt = size(count->tqual[x].resources,5)
   FOR (r = 1 TO rcnt)
    SET acnt = size(count->tqual[x].resources[r].assays,5)
    FOR (a = 1 TO acnt)
      IF ((count->tqual[total_reports].resources[rcnt].assays[acnt].sr_result_type IN (alpha_type_cd,
      interp_type_cd, text_type_cd))
       AND (count->tqual[x].resources[r].assays[a].result_type IN (alpha_type_cd, interp_type_cd,
      text_type_cd))
       AND (count->tqual[total_reports].resources[rcnt].assays[acnt].sr_result_type=count->tqual[x].
      resources[r].assays[a].result_type))
       SET x = x
      ELSE
       SET high_volume_cnt = (high_volume_cnt+ 1)
      ENDIF
    ENDFOR
   ENDFOR
  ENDFOR
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
 SET rcnt = 0
 SET acnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog oc,
   orc_resource_list orl,
   profile_task_r ptr,
   assay_processing_r apr,
   code_value cv,
   discrete_task_assay dta
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
   JOIN (apr
   WHERE apr.service_resource_cd=orl.service_resource_cd
    AND apr.task_assay_cd=ptr.task_assay_cd
    AND apr.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=apr.service_resource_cd
    AND cv.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
  ORDER BY oc.primary_mnemonic, oc.catalog_cd, cv.display,
   apr.service_resource_cd, ptr.sequence, dta.mnemonic,
   dta.task_assay_cd
  HEAD oc.catalog_cd
   total_reports = (total_reports+ 1), stat = alterlist(temp->tqual,total_reports), temp->tqual[
   total_reports].primary_synonym = oc.primary_mnemonic,
   rcnt = 0
  HEAD apr.service_resource_cd
   rcnt = (rcnt+ 1), stat = alterlist(temp->tqual[total_reports].resources,rcnt), temp->tqual[
   total_reports].resources[rcnt].display = cv.display,
   acnt = 0
  HEAD dta.task_assay_cd
   acnt = (acnt+ 1), stat = alterlist(temp->tqual[total_reports].resources[rcnt].assays,acnt), temp->
   tqual[total_reports].resources[rcnt].assays[acnt].mnemonic = dta.mnemonic,
   temp->tqual[total_reports].resources[rcnt].assays[acnt].result_type = dta.default_result_type_cd,
   temp->tqual[total_reports].resources[rcnt].assays[acnt].sr_result_type = apr
   .default_result_type_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,6)
 SET reply->collist[1].header_text = "Report"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Service Resource"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Service Resource Incorrect Result Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Assay Incorrect Result Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Result Type Mismatch"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET total_invalid_resources = 0
 SET total_invalid_assays = 0
 SET total_mismatch = 0
 SET row_nbr = 0
 FOR (x = 1 TO total_reports)
  SET rcnt = size(temp->tqual[x].resources,5)
  FOR (r = 1 TO rcnt)
   SET acnt = size(temp->tqual[x].resources[r].assays,5)
   FOR (a = 1 TO acnt)
     IF ((temp->tqual[x].resources[r].assays[a].sr_result_type IN (alpha_type_cd, interp_type_cd,
     text_type_cd))
      AND (temp->tqual[x].resources[r].assays[a].result_type IN (alpha_type_cd, interp_type_cd,
     text_type_cd))
      AND (temp->tqual[x].resources[r].assays[a].sr_result_type=temp->tqual[x].resources[r].assays[a]
     .result_type))
      SET x = x
     ELSE
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,6)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].primary_synonym
      SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].resources[r].display
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].resources[r].assays[a].
      mnemonic
      IF ((temp->tqual[x].resources[r].assays[a].sr_result_type IN (alpha_type_cd, interp_type_cd,
      text_type_cd)))
       SET x = x
      ELSE
       SET reply->rowlist[row_nbr].celllist[4].string_value = "X"
       SET total_invalid_resources = (total_invalid_resources+ 1)
      ENDIF
      IF ((temp->tqual[x].resources[r].assays[a].result_type IN (alpha_type_cd, interp_type_cd,
      text_type_cd)))
       SET x = x
      ELSE
       SET reply->rowlist[row_nbr].celllist[5].string_value = "X"
       SET total_invalid_assays = (total_invalid_assays+ 1)
      ENDIF
      IF ((temp->tqual[x].resources[r].assays[a].sr_result_type != temp->tqual[x].resources[r].
      assays[a].result_type))
       SET reply->rowlist[row_nbr].celllist[6].string_value = "X"
       SET total_mismatch = (total_mismatch+ 1)
      ENDIF
     ENDIF
   ENDFOR
  ENDFOR
 ENDFOR
 IF (row_nbr > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,3)
 SET reply->statlist[1].statistic_meaning = "APRPTINVRESTYPE"
 SET reply->statlist[1].total_items = total_reports
 SET reply->statlist[1].qualifying_items = total_invalid_resources
 IF (total_invalid_resources > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].statistic_meaning = "APRPTINVDTATYPE"
 SET reply->statlist[2].total_items = total_reports
 SET reply->statlist[2].qualifying_items = total_invalid_assays
 IF (total_invalid_assays > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].statistic_meaning = "APRPTTYPEMISMATCH"
 SET reply->statlist[3].total_items = total_reports
 SET reply->statlist[3].qualifying_items = total_mismatch
 IF (total_mismatch > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
#exit_script
 CALL echorecord(reply)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_reports_with_incorrect_result_type.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
