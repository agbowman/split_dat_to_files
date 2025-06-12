CREATE PROGRAM bed_aud_mic_report_att_loinc:dba
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
 DECLARE i18n_handle = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE general_lab = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"GENERAL LAB"))
 DECLARE micro = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"MICROBIOLOGY"))
 DECLARE primary = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 SET reply->status_data.status = "F"
 SET stat = uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)
 IF ((request->skip_volume_check_ind=0))
  SELECT INTO "nl:"
   row_cnt = count(cimr.concept_ident_mic_rpt_id)
   FROM concept_ident_mic_rpt cimr
   WHERE cimr.concept_ident_mic_rpt_id > 0.0
    AND cimr.concept_type_flag=2
    AND cimr.active_ind=1
    AND cimr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cimr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
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
 SET stat = alterlist(reply->collist,15)
 SET reply->collist[1].header_text = uar_i18ngetmessage(i18n_handle,"OrderCatalogItem",
  "Order Catalog Item")
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = uar_i18ngetmessage(i18n_handle,"IgnoreAttachment",
  "Ignore Attachment Code")
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentCode",
  "Attachment Code")
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentComponent",
  "Attachment Component")
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentMethod",
  "Attachment Method")
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET reply->collist[6].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentSystem",
  "Attachment System")
 SET reply->collist[6].data_type = 1
 SET reply->collist[6].hide_ind = 0
 SET reply->collist[7].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentShortName",
  "Attachment Short Name")
 SET reply->collist[7].data_type = 1
 SET reply->collist[7].hide_ind = 0
 SET reply->collist[8].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentProperty",
  "Attachment Property")
 SET reply->collist[8].data_type = 1
 SET reply->collist[8].hide_ind = 0
 SET reply->collist[9].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentScale",
  "Attachment Scale")
 SET reply->collist[9].data_type = 1
 SET reply->collist[9].hide_ind = 0
 SET reply->collist[10].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentTime",
  "Attachment Time")
 SET reply->collist[10].data_type = 1
 SET reply->collist[10].hide_ind = 0
 SET reply->collist[11].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentClass",
  "Attachment Class")
 SET reply->collist[11].data_type = 1
 SET reply->collist[11].hide_ind = 0
 SET reply->collist[12].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentConceptCKI",
  "Attachment Concept CKI")
 SET reply->collist[12].data_type = 1
 SET reply->collist[12].hide_ind = 0
 SET reply->collist[13].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentAssignUser",
  "Attachment Assign User")
 SET reply->collist[13].data_type = 1
 SET reply->collist[13].hide_ind = 0
 SET reply->collist[14].header_text = uar_i18ngetmessage(i18n_handle,"AttachmentAssignDateTime",
  "Attachment Assign Date/Time")
 SET reply->collist[14].data_type = 1
 SET reply->collist[14].hide_ind = 0
 SET reply->collist[15].header_text = uar_i18ngetmessage(i18n_handle,"OrderCatalogItemCode",
  "Order Catalog Item Code")
 SET reply->collist[15].data_type = 2
 SET reply->collist[15].hide_ind = 0
 SELECT INTO "nl:"
  order_catalog_sort = build(cnvtupper(uar_get_code_display(oc.catalog_cd)),oc.catalog_cd)
  FROM order_catalog oc,
   order_catalog_synonym ocs,
   collection_info_qualifiers ciq,
   concept_ident_mic_rpt cimr,
   nomenclature n,
   prsnl p
  PLAN (oc
   WHERE oc.catalog_type_cd=general_lab
    AND oc.activity_type_cd=micro
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd=primary
    AND ocs.active_ind=1)
   JOIN (ciq
   WHERE ciq.catalog_cd=ocs.catalog_cd)
   JOIN (cimr
   WHERE cimr.catalog_cd=outerjoin(ocs.catalog_cd)
    AND ((cimr.concept_ident_mic_rpt_id+ 0) > outerjoin(0.0))
    AND cimr.service_resource_cd=outerjoin(0.0)
    AND cimr.task_cd=outerjoin(0.0)
    AND cimr.org_class_flag=outerjoin(0)
    AND cimr.source_cd=outerjoin(0.0)
    AND cimr.concept_type_flag=outerjoin(2)
    AND cimr.active_ind=outerjoin(1)
    AND cimr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND cimr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (n
   WHERE n.concept_cki=outerjoin(cimr.concept_cki)
    AND n.concept_cki != outerjoin(" ")
    AND n.primary_vterm_ind=outerjoin(1)
    AND n.disallowed_ind=outerjoin(0)
    AND n.active_ind=outerjoin(1)
    AND n.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND n.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   JOIN (p
   WHERE p.person_id=outerjoin(cimr.updt_id))
  ORDER BY order_catalog_sort
  HEAD REPORT
   row_nbr = 0
  HEAD order_catalog_sort
   row_nbr = (row_nbr+ 1)
   IF (mod(row_nbr,500)=1)
    stat = alterlist(reply->rowlist,(row_nbr+ 499))
   ENDIF
   stat = alterlist(reply->rowlist[row_nbr].celllist,15), reply->rowlist[row_nbr].celllist[1].
   string_value = uar_get_code_display(oc.catalog_cd), reply->rowlist[row_nbr].celllist[15].
   double_value = oc.catalog_cd
   IF (((cimr.ignore_ind=1) OR (n.nomenclature_id > 0.0)) )
    IF (cimr.ignore_ind=1)
     reply->rowlist[row_nbr].celllist[2].string_value = uar_i18ngetmessage(i18n_handle,"Yes","Yes")
    ENDIF
    IF (n.nomenclature_id > 0.0)
     reply->rowlist[row_nbr].celllist[3].string_value = n.source_identifier, reply->rowlist[row_nbr].
     celllist[4].string_value = sub_piece(n.source_string,":",1,""), reply->rowlist[row_nbr].
     celllist[5].string_value = sub_piece(n.source_string,":",6,""),
     reply->rowlist[row_nbr].celllist[6].string_value = sub_piece(n.source_string,":",4,""), reply->
     rowlist[row_nbr].celllist[7].string_value = n.short_string, reply->rowlist[row_nbr].celllist[8].
     string_value = sub_piece(n.source_string,":",2,""),
     reply->rowlist[row_nbr].celllist[9].string_value = sub_piece(n.source_string,":",5,""), reply->
     rowlist[row_nbr].celllist[10].string_value = sub_piece(n.source_string,":",3,""), reply->
     rowlist[row_nbr].celllist[11].string_value = uar_get_code_display(n.vocab_axis_cd),
     reply->rowlist[row_nbr].celllist[12].string_value = n.concept_cki
    ENDIF
    reply->rowlist[row_nbr].celllist[13].string_value = p.name_full_formatted, reply->rowlist[row_nbr
    ].celllist[14].string_value = format(cnvtdatetime(cimr.updt_dt_tm),"@SHORTDATETIME")
   ENDIF
  DETAIL
   row + 0
  FOOT  order_catalog_sort
   row + 0
  FOOT REPORT
   stat = alterlist(reply->rowlist,row_nbr)
  WITH nocounter
 ;end select
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
  SET reply->output_filename = "mic_report_att_loinc_assoc.csv"
 ENDIF
 IF (size(trim(request->output_filename)) > 0)
  EXECUTE bed_rpt_file
 ENDIF
 SET reply->status_data.status = "S"
END GO
