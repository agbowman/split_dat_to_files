CREATE PROGRAM bed_aud_ap_incmplt_parms:dba
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
     2 activity_subtype_cd = f8
     2 activity_subtype_disp = vc
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
 DECLARE ap_bill_cd = f8 WITH public, noconstant(0.0)
 DECLARE ap_proc_cd = f8 WITH public, noconstant(0.0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=5801
    AND cv.cdf_meaning IN ("APBILLING", "APPROCESS")
    AND cv.active_ind=1)
  DETAIL
   IF (cv.cdf_meaning="APBILLING")
    ap_bill_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="APPROCESS")
    ap_proc_cd = cv.code_value
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
    ap_task_assay_addl apaa
   PLAN (oc
    WHERE oc.catalog_type_cd=gen_lab_cd
     AND oc.activity_type_cd=ap_cd
     AND oc.activity_subtype_cd IN (ap_bill_cd, ap_proc_cd)
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
    JOIN (apaa
    WHERE apaa.task_assay_cd=outerjoin(dta.task_assay_cd))
   ORDER BY oc.primary_mnemonic, dta.mnemonic, oc.catalog_cd
   HEAD oc.catalog_cd
    high_volume_cnt = high_volume_cnt
   DETAIL
    IF (((apaa.task_assay_cd=0) OR (((oc.activity_subtype_cd=ap_bill_cd
     AND apaa.date_of_service_cd IN (0, null)) OR (oc.activity_subtype_cd=ap_proc_cd
     AND apaa.task_type_flag IN (0, null))) )) )
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
 SET total_ords = 0
 SET tcnt = 0
 SET acnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog oc,
   code_value cv,
   orc_resource_list orl,
   profile_task_r ptr,
   discrete_task_assay dta,
   ap_task_assay_addl apaa
  PLAN (oc
   WHERE oc.catalog_type_cd=gen_lab_cd
    AND oc.activity_type_cd=ap_cd
    AND oc.activity_subtype_cd IN (ap_bill_cd, ap_proc_cd)
    AND oc.resource_route_lvl=1
    AND oc.active_ind=1)
   JOIN (cv
   WHERE cv.code_value=oc.activity_subtype_cd
    AND cv.active_ind=1)
   JOIN (orl
   WHERE orl.catalog_cd=oc.catalog_cd
    AND orl.active_ind=1)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
   JOIN (apaa
   WHERE apaa.task_assay_cd=outerjoin(dta.task_assay_cd))
  ORDER BY cv.display, oc.primary_mnemonic, dta.mnemonic,
   oc.catalog_cd
  HEAD oc.catalog_cd
   total_ords = (total_ords+ 1), tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].primary_synonym = oc.primary_mnemonic, temp->tqual[tcnt].activity_subtype_cd =
   oc.activity_subtype_cd, temp->tqual[tcnt].activity_subtype_disp = cv.display,
   acnt = 0
  DETAIL
   IF (((apaa.task_assay_cd=0) OR (((oc.activity_subtype_cd=ap_bill_cd
    AND apaa.date_of_service_cd IN (0, null)) OR (oc.activity_subtype_cd=ap_proc_cd
    AND apaa.task_type_flag IN (0, null))) )) )
    acnt = (acnt+ 1), stat = alterlist(temp->tqual[tcnt].assays,acnt), temp->tqual[tcnt].assays[acnt]
    .mnemonic = dta.mnemonic
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,4)
 SET reply->collist[1].header_text = "Billing/Processing Task Orderable"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Subactivity Type"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay With No Default Bill Task Date of Service"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assay With No Inventory and Association Defined"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET total_incmplt_ords = 0
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET acnt = size(temp->tqual[x].assays,5)
   IF (acnt > 0)
    SET total_incmplt_ords = (total_incmplt_ords+ 1)
   ENDIF
   FOR (a = 1 TO acnt)
     SET row_nbr = (row_nbr+ 1)
     SET stat = alterlist(reply->rowlist,row_nbr)
     SET stat = alterlist(reply->rowlist[row_nbr].celllist,4)
     SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].primary_synonym
     SET reply->rowlist[row_nbr].celllist[2].string_value = temp->tqual[x].activity_subtype_disp
     IF ((temp->tqual[x].activity_subtype_cd=ap_bill_cd))
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].assays[a].mnemonic
     ELSE
      SET reply->rowlist[row_nbr].celllist[4].string_value = temp->tqual[x].assays[a].mnemonic
     ENDIF
   ENDFOR
 ENDFOR
 IF (row_nbr > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "APINCMPLTPARMS"
 SET reply->statlist[1].total_items = total_ords
 SET reply->statlist[1].qualifying_items = total_incmplt_ords
 IF (total_incmplt_ords > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 CALL echorecord(reply)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_incmplt_bill_and_proc_parms.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
