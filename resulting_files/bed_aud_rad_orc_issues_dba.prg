CREATE PROGRAM bed_aud_rad_orc_issues:dba
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
   1 o_cnt = i4
   1 olist[*]
     2 catalog_cd = f8
     2 primary_mnemonic = vc
     2 primary_mnemonic_key_cap = vc
     2 no_acc_class_ind = i2
     2 ind_of_ord_not_set_ind = i2
     2 no_oef_ind = i2
     2 no_actsubtype_ind = i2
     2 missing_folders_ind = i2
     2 no_folders_ind = i2
     2 no_ec_ind = i2
     2 no_report_ind = i2
     2 no_exam_ind = i2
     2 no_exam_rooms_ind = i2
 )
 SET crad = 0.0
 SET creportdta = 0.0
 SET cexamdta = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   crad = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning="11"
    AND cv.active_ind=1)
  DETAIL
   cexamdta = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.cdf_meaning="1"
    AND cv.active_ind=1)
  DETAIL
   creportdta = cv.code_value
  WITH nocounter
 ;end select
 SET high_volume_cnt = 0
 SELECT INTO "nl:"
  hv_cnt = count(*)
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.activity_type_cd=crad
    AND oc.active_ind=1
    AND oc.orderable_type_flag != 6
    AND oc.bill_only_ind IN (0, null)
    AND ((oc.concept_cki=null) OR (oc.concept_cki != "CERNER!AEBiWAEBlb0Px7iVn4waeg")) )
  DETAIL
   high_volume_cnt = hv_cnt
  WITH nocounter
 ;end select
 CALL echo(high_volume_cnt)
 IF ((request->skip_volume_check_ind=0))
  IF (high_volume_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET temp->o_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog oc
  PLAN (oc
   WHERE oc.activity_type_cd=crad
    AND oc.active_ind=1
    AND oc.orderable_type_flag != 6
    AND oc.bill_only_ind IN (0, null)
    AND ((oc.concept_cki=null) OR (oc.concept_cki != "CERNER!AEBiWAEBlb0Px7iVn4waeg")) )
  HEAD REPORT
   o_cnt = 0
  DETAIL
   o_cnt = (o_cnt+ 1), temp->o_cnt = o_cnt, stat = alterlist(temp->olist,o_cnt),
   temp->olist[o_cnt].catalog_cd = oc.catalog_cd, temp->olist[o_cnt].primary_mnemonic = oc
   .primary_mnemonic, temp->olist[o_cnt].primary_mnemonic_key_cap = cnvtupper(oc.primary_mnemonic)
   IF (oc.oe_format_id=0)
    temp->olist[o_cnt].no_oef_ind = 1
   ELSE
    temp->olist[o_cnt].no_oef_ind = 0
   ENDIF
   IF (oc.resource_route_lvl != 2)
    temp->olist[o_cnt].ind_of_ord_not_set_ind = 1
   ELSE
    temp->olist[o_cnt].ind_of_ord_not_set_ind = 0
   ENDIF
   IF (oc.activity_subtype_cd=0)
    temp->olist[o_cnt].no_actsubtype_ind = 1
   ELSE
    temp->olist[o_cnt].no_actsubtype_ind = 0
   ENDIF
   temp->olist[o_cnt].no_acc_class_ind = 1, temp->olist[o_cnt].no_folders_ind = 0, temp->olist[o_cnt]
   .missing_folders_ind = 0,
   temp->olist[o_cnt].no_ec_ind = 1, temp->olist[o_cnt].no_report_ind = 1, temp->olist[o_cnt].
   no_exam_ind = 1,
   temp->olist[o_cnt].no_exam_rooms_ind = 1
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->collist,13)
 SET reply->collist[1].header_text = "Primary Synonym"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "No Accession Class"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "No Order Entry Format"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "No Subactivity Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "No Order Folders"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Missing Order Folders"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "No Event Code"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "No Exam or Report Segments"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Missing Exam Segment Only"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Missing Report Segment Only"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "No Exam Rooms"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Independent of Order Not Set"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "catalog_cd"
 SET reply->collist[13].data_type = 2
 SET reply->collist[13].hide_ind = 1
 IF ((temp->o_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   procedure_specimen_type pst
  PLAN (d)
   JOIN (pst
   WHERE (pst.catalog_cd=temp->olist[d.seq].catalog_cd))
  DETAIL
   temp->olist[d.seq].no_acc_class_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   code_value_event_r cver
  PLAN (d)
   JOIN (cver
   WHERE (cver.parent_cd=temp->olist[d.seq].catalog_cd))
  DETAIL
   temp->olist[d.seq].no_ec_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   profile_task_r ptr,
   assay_resource_list arl,
   exam_room_lib_grp_reltn erlgr
  PLAN (d)
   JOIN (ptr
   WHERE (ptr.catalog_cd=temp->olist[d.seq].catalog_cd)
    AND ptr.active_ind=1)
   JOIN (arl
   WHERE arl.task_assay_cd=ptr.task_assay_cd
    AND arl.active_ind=1)
   JOIN (erlgr
   WHERE erlgr.service_resource_cd=arl.service_resource_cd
    AND  NOT ( EXISTS (
   (SELECT
    er.lib_group_cd
    FROM exam_folder er
    WHERE (er.catalog_cd=temp->olist[d.seq].catalog_cd)
     AND er.lib_group_cd=erlgr.lib_group_cd))))
  DETAIL
   temp->olist[d.seq].missing_folders_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   exam_folder ef
  PLAN (d
   WHERE (temp->olist[d.seq].no_folders_ind=0))
   JOIN (ef
   WHERE (ef.catalog_cd=temp->olist[d.seq].catalog_cd))
  DETAIL
   temp->olist[d.seq].no_folders_ind = 1
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt),
   profile_task_r ptr,
   discrete_task_assay dta,
   assay_resource_list arl
  PLAN (d)
   JOIN (ptr
   WHERE (ptr.catalog_cd=temp->olist[d.seq].catalog_cd)
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1
    AND dta.default_result_type_cd IN (cexamdta, creportdta))
   JOIN (arl
   WHERE arl.task_assay_cd=outerjoin(dta.task_assay_cd)
    AND arl.active_ind=outerjoin(1))
  DETAIL
   IF (dta.default_result_type_cd=cexamdta)
    temp->olist[d.seq].no_exam_ind = 0
    IF (arl.task_assay_cd > 0)
     temp->olist[d.seq].no_exam_rooms_ind = 0
    ENDIF
   ELSE
    temp->olist[d.seq].no_report_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET row_nbr = 0
 SET no_acc_class_cnt = 0
 SET ind_of_ord_not_set_cnt = 0
 SET no_oef_cnt = 0
 SET no_actsubtype_cnt = 0
 SET missing_folders_cnt = 0
 SET no_folders_cnt = 0
 SET no_ec_cnt = 0
 SET no_exam_or_report_cnt = 0
 SET no_report_cnt = 0
 SET no_exam_cnt = 0
 SET no_exam_rooms_cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = temp->o_cnt)
  PLAN (d)
  ORDER BY temp->olist[d.seq].primary_mnemonic_key_cap
  DETAIL
   IF ((((temp->olist[d.seq].no_acc_class_ind=1)) OR ((((temp->olist[d.seq].ind_of_ord_not_set_ind=1)
   ) OR ((((temp->olist[d.seq].no_oef_ind=1)) OR ((((temp->olist[d.seq].no_actsubtype_ind=1)) OR ((((
   temp->olist[d.seq].no_folders_ind=1)) OR ((((temp->olist[d.seq].missing_folders_ind=1)) OR ((((
   temp->olist[d.seq].no_ec_ind=1)) OR ((((temp->olist[d.seq].no_report_ind=1)) OR ((((temp->olist[d
   .seq].no_exam_ind=1)) OR ((temp->olist[d.seq].no_exam_rooms_ind=1))) )) )) )) )) )) )) )) )) )
    row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
     rowlist[row_nbr].celllist,13),
    reply->rowlist[row_nbr].celllist[1].string_value = temp->olist[d.seq].primary_mnemonic
    IF ((temp->olist[d.seq].no_acc_class_ind=1))
     no_acc_class_cnt = (no_acc_class_cnt+ 1), reply->rowlist[row_nbr].celllist[2].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[2].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_oef_ind=1))
     no_oef_cnt = (no_oef_cnt+ 1), reply->rowlist[row_nbr].celllist[3].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[3].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_actsubtype_ind=1))
     no_actsubtype_cnt = (no_actsubtype_cnt+ 1), reply->rowlist[row_nbr].celllist[4].string_value =
     "X"
    ELSE
     reply->rowlist[row_nbr].celllist[4].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_folders_ind=1))
     no_folders_cnt = (no_folders_cnt+ 1), reply->rowlist[row_nbr].celllist[5].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[5].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].missing_folders_ind=1))
     missing_folders_cnt = (missing_folders_cnt+ 1), reply->rowlist[row_nbr].celllist[6].string_value
      = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[6].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_ec_ind=1))
     no_ec_cnt = (no_ec_cnt+ 1), reply->rowlist[row_nbr].celllist[7].string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[7].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].no_report_ind=1)
     AND (temp->olist[d.seq].no_exam_ind=1))
     no_exam_or_report_cnt = (no_exam_or_report_cnt+ 1), reply->rowlist[row_nbr].celllist[8].
     string_value = "X", reply->rowlist[row_nbr].celllist[9].string_value = " ",
     reply->rowlist[row_nbr].celllist[10].string_value = " "
    ELSEIF ((temp->olist[d.seq].no_exam_ind=1))
     no_exam_cnt = (no_exam_cnt+ 1), reply->rowlist[row_nbr].celllist[8].string_value = " ", reply->
     rowlist[row_nbr].celllist[9].string_value = "X",
     reply->rowlist[row_nbr].celllist[10].string_value = " "
    ELSEIF ((temp->olist[d.seq].no_report_ind=1))
     no_report_cnt = (no_report_cnt+ 1), reply->rowlist[row_nbr].celllist[8].string_value = " ",
     reply->rowlist[row_nbr].celllist[9].string_value = " ",
     reply->rowlist[row_nbr].celllist[10].string_value = "X"
    ENDIF
    IF ((temp->olist[d.seq].no_exam_rooms_ind=1))
     no_exam_rooms_cnt = (no_exam_rooms_cnt+ 1), reply->rowlist[row_nbr].celllist[11].string_value =
     "X"
    ELSE
     reply->rowlist[row_nbr].celllist[11].string_value = " "
    ENDIF
    IF ((temp->olist[d.seq].ind_of_ord_not_set_ind=1))
     ind_of_ord_not_set_cnt = (ind_of_ord_not_set_cnt+ 1), reply->rowlist[row_nbr].celllist[12].
     string_value = "X"
    ELSE
     reply->rowlist[row_nbr].celllist[12].string_value = " "
    ENDIF
    reply->rowlist[row_nbr].celllist[13].double_value = temp->olist[d.seq].catalog_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (no_acc_class_cnt=0
  AND ind_of_ord_not_set_cnt=0
  AND no_oef_cnt=0
  AND no_actsubtype_cnt=0
  AND missing_folders_cnt=0
  AND no_folders_cnt=0
  AND no_ec_cnt=0
  AND no_exam_or_report_cnt=0
  AND no_report_cnt=0
  AND no_exam_cnt=0
  AND no_exam_rooms_cnt=0)
  SET reply->run_status_flag = 1
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
 SET stat = alterlist(reply->statlist,11)
 SET reply->statlist[1].total_items = high_volume_cnt
 SET reply->statlist[1].qualifying_items = no_acc_class_cnt
 SET reply->statlist[1].statistic_meaning = "RADORCNOACCCLASS"
 IF (no_acc_class_cnt > 0)
  SET reply->statlist[1].status_flag = 3
 ELSE
  SET reply->statlist[1].status_flag = 1
 ENDIF
 SET reply->statlist[2].total_items = high_volume_cnt
 SET reply->statlist[2].qualifying_items = ind_of_ord_not_set_cnt
 SET reply->statlist[2].statistic_meaning = "RADORCINDOFORDNOTSET"
 IF (ind_of_ord_not_set_cnt > 0)
  SET reply->statlist[2].status_flag = 3
 ELSE
  SET reply->statlist[2].status_flag = 1
 ENDIF
 SET reply->statlist[3].total_items = high_volume_cnt
 SET reply->statlist[3].qualifying_items = no_oef_cnt
 SET reply->statlist[3].statistic_meaning = "RADORCNOOEF"
 IF (no_oef_cnt > 0)
  SET reply->statlist[3].status_flag = 3
 ELSE
  SET reply->statlist[3].status_flag = 1
 ENDIF
 SET reply->statlist[4].total_items = high_volume_cnt
 SET reply->statlist[4].qualifying_items = no_actsubtype_cnt
 SET reply->statlist[4].statistic_meaning = "RADORCNOACTSUBTYPE"
 IF (no_actsubtype_cnt > 0)
  SET reply->statlist[4].status_flag = 3
 ELSE
  SET reply->statlist[4].status_flag = 1
 ENDIF
 SET reply->statlist[5].total_items = high_volume_cnt
 SET reply->statlist[5].qualifying_items = no_folders_cnt
 SET reply->statlist[5].statistic_meaning = "RADORCNOFOLDERS"
 IF (no_folders_cnt > 0)
  SET reply->statlist[5].status_flag = 3
 ELSE
  SET reply->statlist[5].status_flag = 1
 ENDIF
 SET reply->statlist[6].total_items = high_volume_cnt
 SET reply->statlist[6].qualifying_items = no_ec_cnt
 SET reply->statlist[6].statistic_meaning = "RADORCNOEVENTCD"
 IF (no_ec_cnt > 0)
  SET reply->statlist[6].status_flag = 3
 ELSE
  SET reply->statlist[6].status_flag = 1
 ENDIF
 SET reply->statlist[7].total_items = high_volume_cnt
 SET reply->statlist[7].qualifying_items = no_exam_or_report_cnt
 SET reply->statlist[7].statistic_meaning = "RADORCNOEXAMORREPORT"
 IF (no_exam_or_report_cnt > 0)
  SET reply->statlist[7].status_flag = 3
 ELSE
  SET reply->statlist[7].status_flag = 1
 ENDIF
 SET reply->statlist[8].total_items = high_volume_cnt
 SET reply->statlist[8].qualifying_items = no_exam_cnt
 SET reply->statlist[8].statistic_meaning = "RADORCNOEXAM"
 IF (no_exam_cnt > 0)
  SET reply->statlist[8].status_flag = 3
 ELSE
  SET reply->statlist[8].status_flag = 1
 ENDIF
 SET reply->statlist[9].total_items = high_volume_cnt
 SET reply->statlist[9].qualifying_items = no_report_cnt
 SET reply->statlist[9].statistic_meaning = "RADORCNOREPORT"
 IF (no_report_cnt > 0)
  SET reply->statlist[9].status_flag = 3
 ELSE
  SET reply->statlist[9].status_flag = 1
 ENDIF
 SET reply->statlist[10].total_items = high_volume_cnt
 SET reply->statlist[10].qualifying_items = no_exam_rooms_cnt
 SET reply->statlist[10].statistic_meaning = "RADORCNOEXAMROOMS"
 IF (no_exam_rooms_cnt > 0)
  SET reply->statlist[10].status_flag = 3
 ELSE
  SET reply->statlist[10].status_flag = 1
 ENDIF
 SET reply->statlist[11].total_items = high_volume_cnt
 SET reply->statlist[11].qualifying_items = missing_folders_cnt
 SET reply->statlist[11].statistic_meaning = "RADORCMISSINGFOLDERS"
 IF (missing_folders_cnt > 0)
  SET reply->statlist[11].status_flag = 3
 ELSE
  SET reply->statlist[11].status_flag = 1
 ENDIF
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("rad_orc_issues_audit.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
END GO
