CREATE PROGRAM bed_aud_loinc:dba
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
 DECLARE analyte_column = i2 WITH protect, constant(6)
 DECLARE attachment_column = i2 WITH protect, constant(17)
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT DISTINCT INTO "nl:"
   FROM concept_identifier_dta cid
   WHERE cid.concept_identifier_dta_id > 0
    AND cid.active_ind=1
    AND cid.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   ORDER BY cid.task_assay_cd, cid.service_resource_cd, cid.specimen_type_cd
   DETAIL
    high_volume_cnt = (high_volume_cnt+ 1)
   WITH nocounter
  ;end select
  IF (high_volume_cnt > 20000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (high_volume_cnt > 10000)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(reply->collist,30)
 SET reply->collist[1].header_text = "Assay Short Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Service Resource"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Service Resource Subactivity Type"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Specimen Type"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Ignore Analyte Code"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Analyte Code"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Analyte Component"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Analyte System"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Analyte Time"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Analyte Scale"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Analyte Property"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Analyte Method"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Analyte Short Name"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Analyte Class"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Analyte Concept CKI"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Ignore Attachment Code"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Attachment Code"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Attachment Component"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Attachment System"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Attachment Time"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Attachment Scale"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Attachment Property"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Attachment Method"
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Attachment Short Name"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = "Attachment Class"
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = "Attachment Concept CKI"
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 0
 SET reply->collist[28].header_text = "Task Assay Code"
 SET reply->collist[28].data_type = 2
 SET reply->collist[28].hide_ind = 0
 SET reply->collist[29].header_text = "Service Resource Code"
 SET reply->collist[29].data_type = 2
 SET reply->collist[29].hide_ind = 0
 SET reply->collist[30].header_text = "Specimen Type Code"
 SET reply->collist[30].data_type = 2
 SET reply->collist[30].hide_ind = 0
 SET cell_nbr = 0
 SET row_nbr = 0
 SELECT INTO "NL:"
  FROM concept_identifier_dta cid,
   nomenclature n,
   service_resource sr
  PLAN (cid
   WHERE cid.concept_identifier_dta_id > 0
    AND cid.active_ind=1
    AND cid.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cid.concept_type_flag IN (1, 2))
   JOIN (n
   WHERE ((n.concept_cki=cid.concept_cki
    AND n.primary_vterm_ind=1
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n.principle_type_cd=0.0
    AND n.nomenclature_id=0.0)) )
   JOIN (sr
   WHERE sr.service_resource_cd=cid.service_resource_cd)
  ORDER BY cid.task_assay_cd, cid.service_resource_cd, cid.specimen_type_cd
  HEAD cid.task_assay_cd
   row + 0
  HEAD cid.service_resource_cd
   row + 0
  HEAD cid.specimen_type_cd
   row_nbr = (row_nbr+ 1)
   IF (mod(row_nbr,500)=1)
    stat = alterlist(reply->rowlist,(row_nbr+ 499))
   ENDIF
   stat = alterlist(reply->rowlist[row_nbr].celllist,30), reply->rowlist[row_nbr].celllist[1].
   string_value = uar_get_code_display(cid.task_assay_cd), reply->rowlist[row_nbr].celllist[2].
   string_value = uar_get_code_description(cid.task_assay_cd),
   reply->rowlist[row_nbr].celllist[3].string_value = uar_get_code_display(cid.service_resource_cd),
   reply->rowlist[row_nbr].celllist[4].string_value = uar_get_code_display(sr.activity_subtype_cd),
   reply->rowlist[row_nbr].celllist[5].string_value = uar_get_code_display(cid.specimen_type_cd),
   reply->rowlist[row_nbr].celllist[28].double_value = cid.task_assay_cd, reply->rowlist[row_nbr].
   celllist[29].double_value = cid.service_resource_cd, reply->rowlist[row_nbr].celllist[30].
   double_value = cid.specimen_type_cd
  DETAIL
   IF (cid.concept_type_flag=1)
    cell_nbr = analyte_column
   ELSE
    cell_nbr = attachment_column
   ENDIF
   IF (cid.ignore_ind=1)
    reply->rowlist[row_nbr].celllist[cell_nbr].string_value = "Yes"
   ELSE
    reply->rowlist[row_nbr].celllist[cell_nbr].string_value = " "
   ENDIF
   IF (n.nomenclature_id > 0)
    cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = replace(cid
     .concept_cki,"LOINC!","",1), cell_nbr = (cell_nbr+ 1),
    reply->rowlist[row_nbr].celllist[cell_nbr].string_value = piece(n.source_string,":",1," "),
    cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = piece(n
     .source_string,":",4," "),
    cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = piece(n
     .source_string,":",3," "), cell_nbr = (cell_nbr+ 1),
    reply->rowlist[row_nbr].celllist[cell_nbr].string_value = piece(n.source_string,":",5," "),
    cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = piece(n
     .source_string,":",2," "),
    cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = piece(n
     .source_string,":",6," "), cell_nbr = (cell_nbr+ 1),
    reply->rowlist[row_nbr].celllist[cell_nbr].string_value = n.short_string, cell_nbr = (cell_nbr+ 1
    ), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = uar_get_code_display(n.vocab_axis_cd
     ),
    cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = n.concept_cki
   ENDIF
  FOOT  cid.specimen_type_cd
   row + 0
  FOOT  cid.service_resource_cd
   row + 0
  FOOT  cid.task_assay_cd
   row + 0
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->rowlist,row_nbr)
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("glb_loinc_assos.csv")
 ENDIF
 IF (size(trim(request->output_filename)) > 0)
  EXECUTE bed_rpt_file
 ENDIF
END GO
