CREATE PROGRAM bed_aud_mic_susc_loinc:dba
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
 DECLARE sub_piece(string=vc,delim=vc,num=i4,default=vc) = vc
 DECLARE high_volume_cnt = i4 WITH protect, noconstant(0)
 DECLARE row_nbr = i4 WITH protect, noconstant(0)
 DECLARE cell_nbr = i4 WITH protect, noconstant(0)
 DECLARE i18n_handle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE cur_size = i4 WITH private, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE new_size = i4 WITH private, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE analyte_column = i2 WITH protect, constant(3)
 DECLARE attachment_column = i2 WITH protect, constant(16)
 SET reply->status_data.status = "F"
 SET stat = uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   row_cnt = count(cims.concept_ident_mic_susc_id)
   FROM concept_ident_mic_susc cims
   WHERE cims.concept_ident_mic_susc_id > 0.0
    AND cims.active_ind=1
    AND cims.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cims.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   HEAD PAGE
    high_volume_cnt = row_cnt
   FOOT PAGE
    row + 0
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
 SET reply->collist[1].header_text = uar_i18ngetmessage(i18n_handle,"AntibioticDescription",
  "Antibiotic Description")
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = uar_i18ngetmessage(i18n_handle,"MethodologyDisplay",
  "Methodology Display")
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = uar_i18ngetmessage(i18n_handle,"IgnoreAnalyte",
  "Ignore Analyte Code")
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteCode","Analyte Code")
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteComponent",
  "Analyte Component")
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteMethod","Analyte Method")
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteShortName",
  "Analyte Short Name")
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteProperty",
  "Analyte Property")
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteTime","Analyte Time")
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteSystem","Analyte System"
  )
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteScale","Analyte Scale")
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteClass","Analyte Class")
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteConceptCKI",
  "Analyte Concept CKI")
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteAssignUser",
  "Analyte Assign User")
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = uar_i18ngetmessage(i18n_handle,"AnalyteAssignDateTime",
  "Analyte Assign Date/Time")
 SET reply->collist[15].data_type = 1
 SET reply->collist[15].hide_ind = 0
 SET reply->collist[16].header_text = uar_i18ngetmessage(i18n_handle,"IgnoreAttachment",
  "Ignore Attachment Code")
 SET reply->collist[16].data_type = 1
 SET reply->collist[16].hide_ind = 0
 SET reply->collist[17].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentCode",
  "Attachment Code")
 SET reply->collist[17].data_type = 1
 SET reply->collist[17].hide_ind = 0
 SET reply->collist[18].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentComponent",
  "Attachment Component")
 SET reply->collist[18].data_type = 1
 SET reply->collist[18].hide_ind = 0
 SET reply->collist[19].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentMethod",
  "Attachment Method")
 SET reply->collist[19].data_type = 1
 SET reply->collist[19].hide_ind = 0
 SET reply->collist[20].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentShortName",
  "Attachment Short Name")
 SET reply->collist[20].data_type = 1
 SET reply->collist[20].hide_ind = 0
 SET reply->collist[21].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentProperty",
  "Attachment Property")
 SET reply->collist[21].data_type = 1
 SET reply->collist[21].hide_ind = 0
 SET reply->collist[22].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentTime",
  "Attachment Time")
 SET reply->collist[22].data_type = 1
 SET reply->collist[22].hide_ind = 0
 SET reply->collist[23].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentSystem",
  "Attachment System")
 SET reply->collist[23].data_type = 1
 SET reply->collist[23].hide_ind = 0
 SET reply->collist[24].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentScale",
  "Attachment Scale")
 SET reply->collist[24].data_type = 1
 SET reply->collist[24].hide_ind = 0
 SET reply->collist[25].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentClass",
  "Attachment Class")
 SET reply->collist[25].data_type = 1
 SET reply->collist[25].hide_ind = 0
 SET reply->collist[26].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentConceptCKI",
  "Attachment Concept CKI")
 SET reply->collist[26].data_type = 1
 SET reply->collist[26].hide_ind = 0
 SET reply->collist[27].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentAssignUser",
  "Attachment Assign User")
 SET reply->collist[27].data_type = 1
 SET reply->collist[27].hide_ind = 0
 SET reply->collist[28].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentAssignDateTime",
  "Attachment Assign Date/Time")
 SET reply->collist[28].data_type = 1
 SET reply->collist[28].hide_ind = 0
 SET reply->collist[29].header_text = uar_i18ngetmessage(i18n_handle,"AntibioticCode",
  "Antibiotic  Code")
 SET reply->collist[29].data_type = 2
 SET reply->collist[29].hide_ind = 0
 SET reply->collist[30].header_text = uar_i18ngetmessage(i18n_handle,"SusceptibilityMethodCode",
  "Susceptibility Method Code")
 SET reply->collist[30].data_type = 2
 SET reply->collist[30].hide_ind = 0
 SELECT INTO "nl:"
  FROM code_value cv,
   code_value cv2
  PLAN (cv
   WHERE cv.code_set=1011
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (cv2
   WHERE cv2.code_set=65
    AND cv2.active_ind=1
    AND cv2.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv2.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY build(cnvtupper(cv.description),cv.code_value), build(cv2.display_key,cv2.code_value)
  DETAIL
   row_nbr = (row_nbr+ 1)
   IF (mod(row_nbr,500)=1)
    stat = alterlist(reply->rowlist,(row_nbr+ 499))
   ENDIF
   stat = alterlist(reply->rowlist[row_nbr].celllist,30), reply->rowlist[row_nbr].celllist[1].
   string_value = cv.description, reply->rowlist[row_nbr].celllist[2].string_value = cv2.display,
   reply->rowlist[row_nbr].celllist[29].double_value = cv.code_value, reply->rowlist[row_nbr].
   celllist[30].double_value = cv2.code_value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->rowlist,row_nbr)
 SET cur_size = size(reply->rowlist,5)
 IF (cur_size < 100)
  SET batch_size = cur_size
 ELSE
  SET batch_size = 100
 ENDIF
 SET loop_cnt = ceil((cnvtreal(cur_size)/ batch_size))
 SET new_size = (loop_cnt * batch_size)
 SET start = 1
 SET stat = alterlist(reply->rowlist,new_size)
 FOR (idx = (cur_size+ 1) TO new_size)
   SET stat = alterlist(reply->rowlist[idx].celllist,30)
   SET reply->rowlist[idx].celllist[29].double_value = reply->rowlist[cur_size].celllist[29].
   double_value
   SET reply->rowlist[idx].celllist[30].double_value = reply->rowlist[cur_size].celllist[30].
   double_value
 ENDFOR
 SELECT INTO "nl:"
  locate_start = start
  FROM (dummyt d  WITH seq = value(loop_cnt)),
   concept_ident_mic_susc cims,
   nomenclature n,
   prsnl p
  PLAN (d
   WHERE initarray(start,evaluate(d.seq,1,1,(start+ batch_size))))
   JOIN (cims
   WHERE ((cims.concept_ident_mic_susc_id+ 0) > 0.0)
    AND expand(idx,start,((start+ batch_size) - 1),cims.antibiotic_cd,reply->rowlist[idx].celllist[29
    ].double_value,
    cims.method_cd,reply->rowlist[idx].celllist[30].double_value)
    AND cims.active_ind=1
    AND cims.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cims.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
    AND cims.concept_type_flag IN (1, 2))
   JOIN (n
   WHERE ((n.concept_cki=cims.concept_cki
    AND n.concept_cki != " "
    AND n.primary_vterm_ind=1
    AND n.disallowed_ind=0
    AND n.active_ind=1
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (n.nomenclature_id=0.0)) )
   JOIN (p
   WHERE (p.person_id=(cims.updt_id+ 0)))
  DETAIL
   IF (((cims.ignore_ind=1) OR (n.nomenclature_id > 0.0)) )
    row_nbr = locateval(idx,locate_start,((locate_start+ batch_size) - 1),cims.antibiotic_cd,reply->
     rowlist[idx].celllist[29].double_value,
     cims.method_cd,reply->rowlist[idx].celllist[30].double_value)
    IF (row_nbr > 0)
     IF (cims.concept_type_flag=1)
      cell_nbr = analyte_column
     ELSE
      cell_nbr = attachment_column
     ENDIF
     reply->rowlist[row_nbr].celllist[(cell_nbr+ 11)].string_value = p.name_full_formatted, reply->
     rowlist[row_nbr].celllist[(cell_nbr+ 12)].string_value = format(cnvtdatetime(cims.updt_dt_tm),
      "@SHORTDATETIME")
     IF (cims.ignore_ind=1)
      reply->rowlist[row_nbr].celllist[cell_nbr].string_value = uar_i18ngetmessage(i18n_handle,"Yes",
       "Yes")
     ENDIF
     IF (n.nomenclature_id > 0.0)
      cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = n
      .source_identifier, cell_nbr = (cell_nbr+ 1),
      reply->rowlist[row_nbr].celllist[cell_nbr].string_value = sub_piece(n.source_string,":",1,""),
      cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = sub_piece(n
       .source_string,":",6,""),
      cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = n
      .short_string, cell_nbr = (cell_nbr+ 1),
      reply->rowlist[row_nbr].celllist[cell_nbr].string_value = sub_piece(n.source_string,":",2,""),
      cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = sub_piece(n
       .source_string,":",3,""),
      cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = sub_piece(n
       .source_string,":",4,""), cell_nbr = (cell_nbr+ 1),
      reply->rowlist[row_nbr].celllist[cell_nbr].string_value = sub_piece(n.source_string,":",5,""),
      cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value =
      uar_get_code_display(n.vocab_axis_cd),
      cell_nbr = (cell_nbr+ 1), reply->rowlist[row_nbr].celllist[cell_nbr].string_value = n
      .concept_cki
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->rowlist,cur_size)
 SUBROUTINE sub_piece(string,delim,num,default)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE beginning = i4 WITH protect, noconstant(0)
   DECLARE ending = i4 WITH protect, noconstant(0)
   IF (num <= 0)
    RETURN("")
   ENDIF
   FOR (cnt = 1 TO num)
     SET beginning = (ending+ 1)
     SET ending = findstring(delim,string,beginning)
     IF (ending=0)
      IF (cnt < num)
       RETURN(default)
      ENDIF
      SET ending = (size(trim(string))+ beginning)
     ENDIF
   ENDFOR
   RETURN(substring(beginning,(ending - beginning),string))
 END ;Subroutine
#exit_script
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = "mic_susc_loinc_assoc.csv"
 ENDIF
 IF (size(trim(request->output_filename)) > 0)
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
