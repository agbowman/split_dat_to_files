CREATE PROGRAM bed_aud_ap_ords_protocols:dba
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
     2 active_ind = i2
     2 assays[*]
       3 mnemonic = vc
       3 active_ind = i2
       3 protocols[*]
         4 display = vc
         4 prefix = vc
         4 pathologist = vc
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
    ap_processing_grp_r apgr,
    ap_specimen_protocol asp,
    code_value cv
   PLAN (oc
    WHERE oc.catalog_type_cd=gen_lab_cd
     AND oc.activity_type_cd=ap_cd
     AND oc.activity_subtype_cd IN (ap_bill_cd, ap_proc_cd)
     AND oc.resource_route_lvl=1)
    JOIN (orl
    WHERE orl.catalog_cd=oc.catalog_cd)
    JOIN (ptr
    WHERE ptr.catalog_cd=oc.catalog_cd
     AND ptr.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ptr.task_assay_cd)
    JOIN (apgr
    WHERE apgr.task_assay_cd=outerjoin(dta.task_assay_cd)
     AND apgr.parent_entity_name=outerjoin("AP_SPECIMEN_PROTOCOL"))
    JOIN (asp
    WHERE asp.protocol_id=apgr.parent_entity_id)
    JOIN (cv
    WHERE cv.code_value=outerjoin(asp.specimen_cd)
     AND cv.code_set=outerjoin(1306)
     AND cv.active_ind=outerjoin(1))
   ORDER BY oc.primary_mnemonic, dta.mnemonic, cv.display,
    oc.catalog_cd, dta.task_assay_cd
   HEAD oc.catalog_cd
    high_volume_cnt = high_volume_cnt
   HEAD dta.task_assay_cd
    high_volume_cnt = high_volume_cnt
   DETAIL
    IF (cv.code_value > 0
     AND cv.active_ind=1
     AND ((oc.active_ind=0) OR (dta.active_ind=0)) )
     high_volume_cnt = (high_volume_cnt+ 1)
    ENDIF
   WITH nocounter
  ;end select
  CALL echo(build("***** high_volume_cnt = ",high_volume_cnt))
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
 SET pcnt = 0
 SELECT DISTINCT INTO "NL:"
  FROM order_catalog oc,
   orc_resource_list orl,
   profile_task_r ptr,
   discrete_task_assay dta,
   ap_processing_grp_r apgr,
   ap_specimen_protocol asp,
   ap_prefix ap,
   person p,
   code_value cv
  PLAN (oc
   WHERE oc.catalog_type_cd=gen_lab_cd
    AND oc.activity_type_cd=ap_cd
    AND oc.activity_subtype_cd IN (ap_bill_cd, ap_proc_cd)
    AND oc.resource_route_lvl=1)
   JOIN (orl
   WHERE orl.catalog_cd=oc.catalog_cd)
   JOIN (ptr
   WHERE ptr.catalog_cd=oc.catalog_cd
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd)
   JOIN (apgr
   WHERE apgr.task_assay_cd=outerjoin(dta.task_assay_cd)
    AND apgr.parent_entity_name=outerjoin("AP_SPECIMEN_PROTOCOL"))
   JOIN (asp
   WHERE asp.protocol_id=apgr.parent_entity_id)
   JOIN (ap
   WHERE ap.prefix_id=outerjoin(asp.prefix_id)
    AND ap.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.person_id=outerjoin(asp.pathologist_id)
    AND p.active_ind=outerjoin(1))
   JOIN (cv
   WHERE cv.code_value=outerjoin(asp.specimen_cd)
    AND cv.code_set=outerjoin(1306)
    AND cv.active_ind=outerjoin(1))
  ORDER BY oc.primary_mnemonic, dta.mnemonic, cv.display,
   oc.catalog_cd, dta.task_assay_cd
  HEAD oc.catalog_cd
   total_ords = (total_ords+ 1), tcnt = (tcnt+ 1), stat = alterlist(temp->tqual,tcnt),
   temp->tqual[tcnt].primary_synonym = oc.primary_mnemonic, temp->tqual[tcnt].active_ind = oc
   .active_ind, acnt = 0
  HEAD dta.task_assay_cd
   acnt = (acnt+ 1), stat = alterlist(temp->tqual[tcnt].assays,acnt), temp->tqual[tcnt].assays[acnt].
   mnemonic = dta.mnemonic,
   temp->tqual[tcnt].assays[acnt].active_ind = dta.active_ind, pcnt = 0
  DETAIL
   IF (cv.code_value > 0
    AND cv.active_ind=1)
    pcnt = (pcnt+ 1), stat = alterlist(temp->tqual[tcnt].assays[acnt].protocols,pcnt), temp->tqual[
    tcnt].assays[acnt].protocols[pcnt].display = cv.display,
    temp->tqual[tcnt].assays[acnt].protocols[pcnt].prefix = ap.prefix_name, temp->tqual[tcnt].assays[
    acnt].protocols[pcnt].pathologist = p.name_full_formatted
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,7)
 SET reply->collist[1].header_text = "Billing/Processing Task Orderable"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Billing/Processing Task Orderable Active Indicator"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Assay"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Assay Active Indicator"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Specimen Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Prefix"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Pathologist"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET tot_ords_with_issue = 0
 SET row_nbr = 0
 FOR (x = 1 TO tcnt)
   SET ord_has_issue = 0
   SET acnt = size(temp->tqual[x].assays,5)
   FOR (a = 1 TO acnt)
    SET pcnt = size(temp->tqual[x].assays[a].protocols,5)
    FOR (p = 1 TO pcnt)
      IF ((((temp->tqual[x].active_ind=0)) OR ((temp->tqual[x].assays[a].active_ind=0))) )
       SET row_nbr = (row_nbr+ 1)
       SET stat = alterlist(reply->rowlist,row_nbr)
       SET stat = alterlist(reply->rowlist[row_nbr].celllist,7)
       SET reply->rowlist[row_nbr].celllist[1].string_value = temp->tqual[x].primary_synonym
       IF ((temp->tqual[x].active_ind=1))
        SET reply->rowlist[row_nbr].celllist[2].string_value = "active"
       ELSE
        SET reply->rowlist[row_nbr].celllist[2].string_value = "inactive"
       ENDIF
       SET reply->rowlist[row_nbr].celllist[3].string_value = temp->tqual[x].assays[a].mnemonic
       IF (temp->tqual[x].assays[a].active_ind)
        SET reply->rowlist[row_nbr].celllist[4].string_value = "active"
       ELSE
        SET reply->rowlist[row_nbr].celllist[4].string_value = "inactive"
       ENDIF
       SET reply->rowlist[row_nbr].celllist[5].string_value = temp->tqual[x].assays[a].protocols[p].
       display
       SET reply->rowlist[row_nbr].celllist[6].string_value = temp->tqual[x].assays[a].protocols[p].
       prefix
       SET reply->rowlist[row_nbr].celllist[7].string_value = temp->tqual[x].assays[a].protocols[p].
       pathologist
       SET ord_has_issue = 1
      ENDIF
    ENDFOR
   ENDFOR
   IF (ord_has_issue=1)
    SET tot_ords_with_issue = (tot_ords_with_issue+ 1)
   ENDIF
 ENDFOR
 IF (row_nbr > 0)
  SET reply->run_status_flag = 3
 ELSE
  SET reply->run_status_flag = 1
 ENDIF
 SET stat = alterlist(reply->statlist,1)
 SET reply->statlist[1].statistic_meaning = "APORDSASSAYSPROTOCOLS"
 SET reply->statlist[1].total_items = total_ords
 SET reply->statlist[1].qualifying_items = tot_ords_with_issue
 IF (tot_ords_with_issue > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
#exit_script
 CALL echorecord(reply)
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("ap_inactive_ords_with_active_protocols.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
