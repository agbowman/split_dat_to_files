CREATE PROGRAM aps_get_label_by_codeset:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 print_status_data
      2 print_directory = c19
      2 print_filename = c40
      2 print_dir_and_filename = c60
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 label_job_data
      2 job_directory = vc
      2 job_filename = vc
      2 job_dir_and_filename = vc
      2 job_content = gvc
      2 suppress_spool_ind = i2
      2 line_template = vc
  )
 ENDIF
 RECORD data(
   1 maxlabel = i2
   1 current_dt_tm_string = c8
   1 resrc[1]
     2 service_resource_cd = f8
     2 service_resource_disp = vc
     2 label[*]
       3 worklist_nbr = i4
       3 service_resource_cd = f8
       3 mnemonic = vc
       3 description = vc
       3 request_dt_tm = dq8
       3 request_dt_tm_string = c8
       3 priority_cd = f8
       3 priority_disp = c15
       3 case_specimen_id = f8
       3 case_specimen_tag_cd = f8
       3 case_specimen_tag_disp = c15
       3 case_specimen_tag_seq = i4
       3 cassette_id = f8
       3 cassette_tag_cd = f8
       3 cassette_tag_disp = c15
       3 cassette_tag_seq = i4
       3 cassette_sep_disp = c1
       3 cassette_origin_modifier = c7
       3 slide_id = f8
       3 slide_tag_cd = f8
       3 slide_tag_disp = c15
       3 slide_tag_seq = i4
       3 slide_sep_disp = c1
       3 slide_origin_modifier = c7
       3 spec_blk_sld_tag_disp = c15
       3 spec_blk_tag_disp = c15
       3 blk_sld_tag_disp = c15
       3 prefix_cd = f8
       3 accession_nbr = c21
       3 fmt_accession_nbr = c21
       3 acc_site_pre_yy_nbr = c21
       3 acc_site = c5
       3 acc_pre = c2
       3 acc_yy = c2
       3 acc_yyyy = c4
       3 acc_nbr = c7
       3 case_year = i4
       3 case_number = i4
       3 responsible_pathologist_id = f8
       3 responsible_pathologist_name_full = vc
       3 responsible_pathologist_name_last = vc
       3 responsible_pathologist_initial = c2
       3 responsible_resident_id = f8
       3 responsible_resident_name_full = vc
       3 responsible_resident_name_last = vc
       3 responsible_resident_initial = c2
       3 requesting_physician_id = f8
       3 requesting_physician_name_full = vc
       3 requesting_physician_name_last = vc
       3 case_received_dt_tm = dq8
       3 case_received_dt_tm_string = c8
       3 case_collect_dt_tm = dq8
       3 case_collect_dt_tm_string = c8
       3 mrn_alias = vc
       3 fin_nbr_alias = vc
       3 encntr_id = f8
       3 person_id = f8
       3 name_full_formatted = vc
       3 name_last = vc
       3 birth_dt_tm = dq8
       3 birth_dt_tm_string = c8
       3 deceased_dt_tm = dq8
       3 age = vc
       3 sex_cd = f8
       3 sex_disp = vc
       3 sex_desc = vc
       3 admit_doc_name = vc
       3 admit_doc_name_last = vc
       3 organization_id = f8
       3 loc_bed_cd = f8
       3 loc_bed_disp = c15
       3 loc_building_cd = f8
       3 loc_building_disp = c15
       3 loc_facility_cd = f8
       3 loc_facility_disp = c15
       3 location_cd = f8
       3 location_disp = c15
       3 loc_nurse_unit_cd = f8
       3 loc_nurse_unit_disp = c15
       3 loc_room_cd = f8
       3 loc_room_disp = c15
       3 loc_nurse_room_bed_disp = vc
       3 encntr_type_cd = f8
       3 encntr_type_disp = c15
       3 encntr_type_desc = vc
       3 adequacy_ind = i2
       3 adequacy_string = vc
       3 specimen_cd = f8
       3 specimen_disp = c15
       3 specimen_description = vc
       3 received_fixative_cd = f8
       3 received_fixative_disp = c15
       3 received_fixative_desc = vc
       3 fixative_added_cd = f8
       3 fixative_added_disp = c15
       3 fixative_added_desc = vc
       3 fixative_cd = f8
       3 fixative_disp = c15
       3 fixative_desc = vc
       3 supplemental_tag = c2
       3 pieces = c3
       3 sl_supplemental_tag = c2
       3 stain_task_assay_cd = f8
       3 stain_mnemonic = vc
       3 stain_description = vc
       3 inventory_type = i2
       3 inventory_code = vc
       3 location_code = vc
       3 compartment_code = vc
       3 spec_tracking_loc_disp = vc
       3 compartment_disp = vc
       3 storage_shelf_disp = vc
       3 organization_name = vc
       3 domain = vc
       3 identifier_type = vc
       3 identifier_code = vc
       3 identifier_disp = vc
       3 hopper = vc
       3 cassette_color = vc
       3 generic_field1 = vc
       3 generic_field2 = vc
       3 generic_field3 = vc
 )
 RECORD printer(
   1 output_dest_cd = f8
   1 name = vc
   1 label_program_prefix = vc
   1 label_program = vc
   1 label_x_pos = i4
   1 label_y_pos = i4
   1 device_cd = f8
   1 flatfile = vc
   1 hopper_name = vc
   1 script = vc
 )
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
 DECLARE lcs_track_comment = i4 WITH protect, constant(4002589)
 DECLARE lcs_disposal_reason = i4 WITH protect, constant(2073)
 DECLARE lcs_keyboard_macro = i4 WITH protect, constant(4002513)
 DECLARE lcs_qa_comments = i4 WITH protect, constant(4002593)
 DECLARE nbatch_size = i4 WITH protect, constant(20)
 DECLARE nloopcnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE hi18nhandle = i4 WITH protect, noconstant(0)
 DECLARE ncodesetcnt = i4 WITH protect, noconstant(0)
 DECLARE nlabelcnt = i4 WITH protect, noconstant(0)
 DECLARE nstat = i2 WITH protect, noconstant(0)
 DECLARE printer_name = vc WITH protect, noconstant("")
 DECLARE sdomain = vc WITH protect, noconstant(" ")
 DECLARE sdisposalreason = vc WITH protect, noconstant(" ")
 DECLARE skeyboardmacro = vc WITH protect, noconstant(" ")
 DECLARE sqacomments = vc WITH protect, noconstant(" ")
 DECLARE strackcomment = vc WITH protect, noconstant(" ")
 DECLARE stemp = vc WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 EXECUTE pcs_label_integration_util
 SET nstat = uar_i18nlocalizationinit(hi18nhandle,curprog,"",curcclrev)
 SET sdisposalreason = uar_i18ngetmessage(hi18nhandle,"DISPOSAL_REASON","Disposal Reason")
 SET skeyboardmacro = uar_i18ngetmessage(hi18nhandle,"KEYBOARD_MACRO","Keyboard Macro")
 SET sqacomments = uar_i18ngetmessage(hi18nhandle,"QA_COMMENTS","QA Comment")
 SET strackcomment = uar_i18ngetmessage(hi18nhandle,"TRACK_COMMENT","Track Comment")
 SET sdomain = trim(cnvtupper(logical("ENVIRONMENT")))
 SET ncodesetcnt = size(request->code_set_list,5)
 IF (ncodesetcnt=0)
  SET reply->status_data.status = "Z"
  CALL addsubeventstatus("INPUT","Z","REQUEST->CODE_SET_LIST","No code set specified.")
  GO TO exit_script
 ENDIF
 SET nloopcnt = ceil((cnvtreal(ncodesetcnt)/ nbatch_size))
 SELECT INTO "nl:"
  o.output_dest_cd, o.name, o.label_prefix,
  o.label_program_name, o.label_xpos, o.label_ypos
  FROM output_dest o
  PLAN (o
   WHERE (o.output_dest_cd=request->output_dest_cd))
  DETAIL
   printer->output_dest_cd = o.output_dest_cd, printer->name = o.name, printer->label_program_prefix
    = o.label_prefix,
   printer->label_program = o.label_program_name, printer->label_x_pos = o.label_xpos, printer->
   label_y_pos = o.label_ypos,
   printer->device_cd = o.device_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  CALL addsubeventstatus("SELECT","F","OUTPUT_DEST","Unable to retrieve output destination info.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.name
  FROM device d
  PLAN (d
   WHERE (printer->device_cd=d.device_cd))
  DETAIL
   printer_name = trim(d.name)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  CALL addsubeventstatus("SELECT","F","DEVICE","Unable to retrieve device name.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM (dummyt d  WITH seq = value(nloopcnt)),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE expand(idx,(((d.seq - 1) * nbatch_size)+ 1),minval(ncodesetcnt,(d.seq * nbatch_size)),cv
    .code_set,request->code_set_list[idx].code_set)
    AND cv.code_value > 0
    AND cv.active_ind=1
    AND cnvtdatetime(sysdate) BETWEEN cv.begin_effective_dt_tm AND cv.end_effective_dt_tm)
  ORDER BY cv.code_set, cnvtupper(cv.display)
  DETAIL
   stemp = getbarcodebycodeset(cv.code_set,cv.code_value,cv.cdf_meaning)
   IF (size(trim(stemp),1) > 0)
    nlabelcnt += 1
    IF (nlabelcnt > size(data->resrc[1].label,5))
     nstat = alterlist(data->resrc[1].label,(nlabelcnt+ 9))
    ENDIF
    data->resrc[1].label[nlabelcnt].identifier_code = stemp, data->resrc[1].label[nlabelcnt].
    identifier_disp = substring(1,40,cv.display)
    CASE (cv.code_set)
     OF lcs_disposal_reason:
      data->resrc[1].label[nlabelcnt].identifier_type = substring(1,15,sdisposalreason)
     OF lcs_keyboard_macro:
      data->resrc[1].label[nlabelcnt].identifier_type = substring(1,15,skeyboardmacro)
     OF lcs_qa_comments:
      data->resrc[1].label[nlabelcnt].identifier_type = substring(1,15,sqacomments)
     OF lcs_track_comment:
      data->resrc[1].label[nlabelcnt].identifier_type = substring(1,15,strackcomment)
    ENDCASE
    data->resrc[1].label[nlabelcnt].domain = substring(1,15,sdomain)
   ENDIF
  FOOT REPORT
   nstat = alterlist(data->resrc[1].label,nlabelcnt)
  WITH nocounter
 ;end select
 IF (nlabelcnt=0)
  SET reply->status_data.status = "Z"
  CALL addsubeventstatus("SELECT","Z","CODE_VALUE","No labels qualified.")
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name_logical "aps_bc", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 IF ( NOT (validate(label_job_data,0)))
  RECORD label_job_data(
    1 fields[*]
      2 name = vc
      2 size = i2
    1 job_directory = vc
    1 job_file_suffix = vc
    1 format_file_name = vc
    1 printer_name = vc
    1 copies = i4
  )
 ENDIF
 DECLARE field_cnt = i4 WITH protect, noconstant(0)
 SET field_cnt = 122
 SET stat = alterlist(label_job_data->fields,field_cnt)
 SET label_job_data->fields[1].name = "NBR_OF_LABELS"
 SET label_job_data->fields[2].name = "LABEL_SEQ"
 SET label_job_data->fields[3].name = "CURRENT_DT_TM_STRING"
 SET label_job_data->fields[4].name = "SERVICE_RESOURCE_CD"
 SET label_job_data->fields[5].name = "SERVICE_RESOURCE_DISP"
 SET label_job_data->fields[6].name = "WORKLIST_NBR"
 SET label_job_data->fields[7].name = "MNEMONIC"
 SET label_job_data->fields[8].name = "DESCRIPTION"
 SET label_job_data->fields[9].name = "REQUEST_DT_TM"
 SET label_job_data->fields[10].name = "REQUEST_DT_TM_STRING"
 SET label_job_data->fields[11].name = "PRIORITY_CD"
 SET label_job_data->fields[12].name = "PRIORITY_DISP"
 SET label_job_data->fields[13].name = "CASE_SPECIMEN_ID"
 SET label_job_data->fields[14].name = "CASE_SPECIMEN_TAG_CD"
 SET label_job_data->fields[15].name = "CASE_SPECIMEN_TAG_DISP"
 SET label_job_data->fields[16].name = "CASSETTE_ID"
 SET label_job_data->fields[17].name = "CASSETTE_TAG_CD"
 SET label_job_data->fields[18].name = "CASSETTE_TAG_DISP"
 SET label_job_data->fields[19].name = "CASSETTE_SEP_DISP"
 SET label_job_data->fields[20].name = "CASSETTE_ORIGIN_MODIFIER"
 SET label_job_data->fields[21].name = "SLIDE_ID"
 SET label_job_data->fields[22].name = "SLIDE_TAG_CD"
 SET label_job_data->fields[23].name = "SLIDE_TAG_DISP"
 SET label_job_data->fields[24].name = "SLIDE_SEP_DISP"
 SET label_job_data->fields[25].name = "SLIDE_ORIGIN_MODIFIER"
 SET label_job_data->fields[26].name = "SPEC_BLK_SLD_TAG_DISP"
 SET label_job_data->fields[27].name = "SPEC_BLK_TAG_DISP"
 SET label_job_data->fields[28].name = "BLK_SLD_TAG_DISP"
 SET label_job_data->fields[29].name = "PREFIX_CD"
 SET label_job_data->fields[30].name = "ACCESSION_NBR"
 SET label_job_data->fields[31].name = "FMT_ACCESSION_NBR"
 SET label_job_data->fields[32].name = "ACC_SITE_PRE_YY_NBR"
 SET label_job_data->fields[33].name = "ACC_SITE"
 SET label_job_data->fields[34].name = "ACC_PRE"
 SET label_job_data->fields[35].name = "ACC_YY"
 SET label_job_data->fields[36].name = "ACC_YYYY"
 SET label_job_data->fields[37].name = "ACC_NBR"
 SET label_job_data->fields[38].name = "CASE_YEAR"
 SET label_job_data->fields[39].name = "CASE_NUMBER"
 SET label_job_data->fields[40].name = "RESPONSIBLE_PATHOLOGIST_ID"
 SET label_job_data->fields[41].name = "RESPONSIBLE_PATHOLOGIST_NAME_FULL"
 SET label_job_data->fields[42].name = "RESPONSIBLE_PATHOLOGIST_NAME_LAST"
 SET label_job_data->fields[43].name = "RESPONSIBLE_PATHOLOGIST_INITIAL"
 SET label_job_data->fields[44].name = "RESPONSIBLE_RESIDENT_ID"
 SET label_job_data->fields[45].name = "RESPONSIBLE_RESIDENT_NAME_FULL"
 SET label_job_data->fields[46].name = "RESPONSIBLE_RESIDENT_NAME_LAST"
 SET label_job_data->fields[47].name = "RESPONSIBLE_RESIDENT_INITIAL"
 SET label_job_data->fields[48].name = "REQUESTING_PHYSICIAN_ID"
 SET label_job_data->fields[49].name = "REQUESTING_PHYSICIAN_NAME_FULL"
 SET label_job_data->fields[50].name = "REQUESTING_PHYSICIAN_NAME_LAST"
 SET label_job_data->fields[51].name = "CASE_RECEIVED_DT_TM"
 SET label_job_data->fields[52].name = "CASE_RECEIVED_DT_TM_STRING"
 SET label_job_data->fields[53].name = "CASE_COLLECT_DT_TM"
 SET label_job_data->fields[54].name = "CASE_COLLECT_DT_TM_STRING"
 SET label_job_data->fields[55].name = "MRN_ALIAS"
 SET label_job_data->fields[56].name = "FIN_NBR_ALIAS"
 SET label_job_data->fields[57].name = "ENCNTR_ID"
 SET label_job_data->fields[58].name = "PERSON_ID"
 SET label_job_data->fields[59].name = "NAME_FULL_FORMATTED"
 SET label_job_data->fields[60].name = "NAME_LAST"
 SET label_job_data->fields[61].name = "BIRTH_DT_TM"
 SET label_job_data->fields[62].name = "BIRTH_DT_TM_STRING"
 SET label_job_data->fields[63].name = "DECEASED_DT_TM"
 SET label_job_data->fields[64].name = "AGE"
 SET label_job_data->fields[65].name = "SEX_CD"
 SET label_job_data->fields[66].name = "SEX_DISP"
 SET label_job_data->fields[67].name = "SEX_DESC"
 SET label_job_data->fields[68].name = "ADMIT_DOC_NAME"
 SET label_job_data->fields[69].name = "ADMIT_DOC_NAME_LAST"
 SET label_job_data->fields[70].name = "ORGANIZATION_ID"
 SET label_job_data->fields[71].name = "LOC_BED_CD"
 SET label_job_data->fields[72].name = "LOC_BED_DISP"
 SET label_job_data->fields[73].name = "LOC_BUILDING_CD"
 SET label_job_data->fields[74].name = "LOC_BUILDING_DISP"
 SET label_job_data->fields[75].name = "LOC_FACILITY_CD"
 SET label_job_data->fields[76].name = "LOC_FACILITY_DISP"
 SET label_job_data->fields[77].name = "LOCATION_CD"
 SET label_job_data->fields[78].name = "LOCATION_DISP"
 SET label_job_data->fields[79].name = "LOC_NURSE_UNIT_CD"
 SET label_job_data->fields[80].name = "LOC_NURSE_UNIT_DISP"
 SET label_job_data->fields[81].name = "LOC_ROOM_CD"
 SET label_job_data->fields[82].name = "LOC_ROOM_DISP"
 SET label_job_data->fields[83].name = "LOC_NURSE_ROOM_BED_DISP"
 SET label_job_data->fields[84].name = "ENCNTR_TYPE_CD"
 SET label_job_data->fields[85].name = "ENCNTR_TYPE_DISP"
 SET label_job_data->fields[86].name = "ENCNTR_TYPE_DESC"
 SET label_job_data->fields[87].name = "ADEQUACY_IND"
 SET label_job_data->fields[88].name = "ADEQUACY_STRING"
 SET label_job_data->fields[89].name = "SPECIMEN_CD"
 SET label_job_data->fields[90].name = "SPECIMEN_DISP"
 SET label_job_data->fields[91].name = "SPECIMEN_DESCRIPTION"
 SET label_job_data->fields[92].name = "RECEIVED_FIXATIVE_CD"
 SET label_job_data->fields[93].name = "RECEIVED_FIXATIVE_DISP"
 SET label_job_data->fields[94].name = "RECEIVED_FIXATIVE_DESC"
 SET label_job_data->fields[95].name = "FIXATIVE_ADDED_CD"
 SET label_job_data->fields[96].name = "FIXATIVE_ADDED_DISP"
 SET label_job_data->fields[97].name = "FIXATIVE_ADDED_DESC"
 SET label_job_data->fields[98].name = "FIXATIVE_CD"
 SET label_job_data->fields[99].name = "FIXATIVE_DISP"
 SET label_job_data->fields[100].name = "FIXATIVE_DESC"
 SET label_job_data->fields[101].name = "SUPPLEMENTAL_TAG"
 SET label_job_data->fields[102].name = "PIECES"
 SET label_job_data->fields[103].name = "SL_SUPPLEMENTAL_TAG"
 SET label_job_data->fields[104].name = "STAIN_TASK_ASSAY_CD"
 SET label_job_data->fields[105].name = "STAIN_MNEMONIC"
 SET label_job_data->fields[106].name = "STAIN_DESCRIPTION"
 SET label_job_data->fields[107].name = "INVENTORY_CODE"
 SET label_job_data->fields[108].name = "LOCATION_CODE"
 SET label_job_data->fields[109].name = "COMPARTMENT_CODE"
 SET label_job_data->fields[110].name = "SPEC_TRACKING_LOC_DISP"
 SET label_job_data->fields[111].name = "STORAGE_SHELF_DISP"
 SET label_job_data->fields[112].name = "COMPARTMENT_DISP"
 SET label_job_data->fields[113].name = "ORGANIZATION_NAME"
 SET label_job_data->fields[114].name = "DOMAIN"
 SET label_job_data->fields[115].name = "IDENTIFIER_TYPE"
 SET label_job_data->fields[116].name = "IDENTIFIER_CODE"
 SET label_job_data->fields[117].name = "IDENTIFIER_DISP"
 SET label_job_data->fields[118].name = "HOPPER"
 SET label_job_data->fields[119].name = "CASSETTE_COLOR"
 SET label_job_data->fields[120].name = "GENERIC_FIELD1"
 SET label_job_data->fields[121].name = "GENERIC_FIELD2"
 SET label_job_data->fields[122].name = "GENERIC_FIELD3"
 EXECUTE value(concat(trim(printer->label_program_prefix),trim(printer->label_program)))
 IF (size(printer->flatfile) > 0)
  IF (checkprg("APS_LABEL_RULE") > 0)
   EXECUTE aps_label_rule
  ENDIF
  EXECUTE value(concat("APS_LABEL_JOB_",printer->flatfile))
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 IF ((reply->label_job_data.suppress_spool_ind=0))
  SET spool value(reply->print_status_data.print_dir_and_filename) value(printer_name) WITH copy = 1
 ENDIF
#exit_script
END GO
