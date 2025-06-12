CREATE PROGRAM bed_aud_bb_loinc:dba
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
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE analyte_column = i2 WITH protect, constant(3)
 DECLARE attachment_column = i2 WITH protect, constant(13)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE antigen_code_set = i4 WITH constant(1612)
 DECLARE antigen = vc WITH protect, noconstant("")
 DECLARE antibody = vc WITH protect, noconstant("")
 DECLARE orderable = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET antigen = uar_i18ngetmessage(i18nhandle,"antigen","Antigen")
 SET antibody = uar_i18ngetmessage(i18nhandle,"antibody","Antibody")
 SET orderable = uar_i18ngetmessage(i18nhandle,"orderable","Orderable")
 SET high_volume_cnt = 0
 IF ((request->skip_volume_check_ind=0))
  SELECT DISTINCT INTO "nl:"
   FROM concept_ident_bb_dta cibd
   WHERE cibd.concept_ident_bb_dta_id > 0
    AND cibd.active_ind=1
    AND cibd.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   ORDER BY cibd.task_assay_cd
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
  SELECT DISTINCT INTO "nl:"
   FROM concept_ident_bb_code cibc
   WHERE cibc.concept_ident_bb_code_id > 0
    AND cibc.active_ind=1
    AND cibc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   ORDER BY cibc.code_value
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
 SET stat = alterlist(reply->collist,25)
 SET reply->collist[1].header_text = "Assay Short Name"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Assay Description"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Ignore Analyte Code"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Analyte Code"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Analyte Component"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = "Analyte System"
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = "Analyte Time"
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = "Analyte Scale"
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = "Analyte Property"
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = "Analyte Method"
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = "Analyte Short Name"
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = "Analyte Class"
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = "Analyte Concept CKI"
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = "Attachment Code"
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = "Attachment Component"
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = "Attachment System"
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = "Attachment Time"
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = "Attachment Scale"
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = "Attachment Property"
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = "Attachment Method"
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = "Attachment Short Name"
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = "Attachment Class"
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = "Attachment Concept CKI"
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = "Task Assay Code"
 SET reply->collist[24].data_type = 2
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = "Assay Type"
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET cell_nbr = 0
 SET row_nbr = 0
 SELECT INTO "NL:"
  FROM concept_ident_bb_code cibc,
   nomenclature n
  PLAN (cibc
   WHERE cibc.concept_ident_bb_code_id > 0
    AND cibc.active_ind=1
    AND cibc.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cibc.concept_type_flag IN (1, 2))
   JOIN (n
   WHERE ((n.concept_cki=cibc.concept_cki
    AND n.primary_vterm_ind=1
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n.principle_type_cd=0.0
    AND n.nomenclature_id=0.0)) )
  ORDER BY cibc.code_set, cibc.code_value
  HEAD cibc.code_set
   row + 0
  HEAD cibc.code_value
   row_nbr = (row_nbr+ 1)
   IF (row_nbr > size(reply->rowlist,5))
    stat = alterlist(reply->rowlist,(row_nbr+ 499))
   ENDIF
   stat = alterlist(reply->rowlist[row_nbr].celllist,25), reply->rowlist[row_nbr].celllist[1].
   string_value = uar_get_code_display(cibc.code_value), reply->rowlist[row_nbr].celllist[2].
   string_value = uar_get_code_description(cibc.code_value),
   reply->rowlist[row_nbr].celllist[24].double_value = cibc.code_value
   IF (cibc.code_set=antigen_code_set)
    reply->rowlist[row_nbr].celllist[25].string_value = antigen
   ELSE
    reply->rowlist[row_nbr].celllist[25].string_value = antibody
   ENDIF
  DETAIL
   IF (cibc.concept_type_flag=1)
    cell_nbr = analyte_column
    IF (cibc.ignore_ind=1)
     reply->rowlist[row_nbr].celllist[cell_nbr].string_value = "Yes"
    ELSE
     reply->rowlist[row_nbr].celllist[cell_nbr].string_value = " "
    ENDIF
   ELSE
    cell_nbr = attachment_column
   ENDIF
   IF (n.nomenclature_id > 0)
    cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = replace(cibc
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
  FOOT  cibc.code_value
   row + 0
  FOOT  cibc.code_set
   row + 0
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM concept_ident_bb_dta cibd,
   nomenclature n
  PLAN (cibd
   WHERE cibd.concept_ident_bb_dta_id > 0
    AND cibd.active_ind=1
    AND cibd.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cibd.concept_type_flag IN (1, 2))
   JOIN (n
   WHERE ((n.concept_cki=cibd.concept_cki
    AND n.primary_vterm_ind=1
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n.principle_type_cd=0.0
    AND n.nomenclature_id=0.0)) )
  ORDER BY cibd.task_assay_cd
  HEAD cibd.task_assay_cd
   row_nbr = (row_nbr+ 1)
   IF (row_nbr > size(reply->rowlist,5))
    stat = alterlist(reply->rowlist,(row_nbr+ 499))
   ENDIF
   stat = alterlist(reply->rowlist[row_nbr].celllist,25), reply->rowlist[row_nbr].celllist[1].
   string_value = uar_get_code_display(cibd.task_assay_cd), reply->rowlist[row_nbr].celllist[2].
   string_value = uar_get_code_description(cibd.task_assay_cd),
   reply->rowlist[row_nbr].celllist[24].double_value = cibd.task_assay_cd, reply->rowlist[row_nbr].
   celllist[25].string_value = orderable
  DETAIL
   IF (cibd.concept_type_flag=1)
    cell_nbr = analyte_column
    IF (cibd.ignore_ind=1)
     reply->rowlist[row_nbr].celllist[cell_nbr].string_value = "Yes"
    ELSE
     reply->rowlist[row_nbr].celllist[cell_nbr].string_value = " "
    ENDIF
   ELSE
    cell_nbr = attachment_column
   ENDIF
   IF (n.nomenclature_id > 0)
    cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = replace(cibd
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
  FOOT  cibd.task_assay_cd
   row + 0
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->rowlist,row_nbr)
#exit_script
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("bb_loinc_assoc.csv")
 ENDIF
 IF (size(trim(request->output_filename)) > 0)
  EXECUTE bed_rpt_file
 ENDIF
END GO
