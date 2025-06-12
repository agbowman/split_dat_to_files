CREATE PROGRAM bhs_rad_rpt_custom_mammo:dba
 SET modify = predeclare
 RECORD letter_request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[*]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[1]
     2 encntr_id = f8
     2 order_id = f8
     2 study_id = f8
     2 parent_order_id = f8
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
   1 use_wp_template_flag = i2
 )
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD letter_reply(
   1 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE prsnl_name_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
 DECLARE sql_get_name_display(personid=f8,nametypecd=f8,date=q8) = c100
 DECLARE g_patnotify_cdm = c9 WITH public, constant("PATNOTIFY")
 DECLARE g_patreminder_cdm = c11 WITH public, constant("PATREMINDER")
 DECLARE g_patwarning_cdm = c10 WITH public, constant("PATWARNING")
 DECLARE g_physreminder_cdm = c12 WITH public, constant("PHYSREMINDER")
 DECLARE g_physwarning_cdm = c11 WITH public, constant("PHYSWARNING")
 DECLARE g_physsurvey_cdm = c10 WITH public, constant("PHYSSURVEY")
 DECLARE g_want_to_print = c1 WITH public, constant("P")
 DECLARE g_want_to_reprint = c1 WITH public, constant("R")
 DECLARE g_blank = c1 WITH public, constant(" ")
 DECLARE g_status_fail = c1 WITH public, constant("F")
 DECLARE g_status_zero = c1 WITH public, constant("Z")
 DECLARE g_status_success = c1 WITH public, constant("S")
 DECLARE getnotifytemplatenameandid(dstudyid=f8(value),slettername=vc(ref),dtemplateid=f8(ref)) =
 null
 DECLARE getwptemplateid(stemplatename=vc(value),dtemplateid=f8(ref)) = null
 DECLARE doi18nonstrings(ndummyvar=i2(value)) = null
 DECLARE processparameters(ndummyvar=i2(value)) = null
 DECLARE getnotificationletterstudylist(ndummyvar=i2(value)) = null
 DECLARE getreprintletterstudylist(ndummyvar=i2(value)) = null
 DECLARE getreminderletterstudylist(ndummyvar=i2(value)) = null
 DECLARE getwarningletterstudylist(ndummyvar=i2(value)) = null
 DECLARE getphysiciansurveystudylist(ndummyvar=i2(value)) = null
 DECLARE mergeduplicatephysicians(ndummyvar=i2(value)) = null
 DECLARE copylettertophysician(nletterpos=i4(value),nphysicianpos=i4(value),nnewind=i2(value)) = null
 DECLARE insertnotificationrecord(dstudyid=f8(value),dletterid=f8(value),dtemplateid=f8(value),nrows=
  i2(ref),dfollowuptypecd=f8(value)) = null
 DECLARE printsummarypage(sprintername=vc(value)) = null
 DECLARE insertlinkednotificationrecord(dparentorderid=f8(value),dletterid=f8(value),dtemplateid=f8(
   value),nrows=i2(ref),dfollowuptypecd=f8(value)) = null
 DECLARE insertnotificationhistrecord(dstudyid=f8(value),dletterid=f8(value),dtemplateid=f8(value),
  nrows=i2(ref),dfollowuptypecd=f8(value),
  nhistseq=i4(value)) = null
 DECLARE insertlinkednotificationhistrecord(dparentorderid=f8(value),dletterid=f8(value),dtemplateid=
  f8(value),nrows=i2(ref),dfollowuptypecd=f8(value)) = null
 RECORD i18n(
   1 wrong_print_ind = vc
   1 missing_template = vc
   1 missing_printer = vc
   1 unknown_letter = vc
   1 missing_print_date = vc
   1 print_from_date_incorrect = vc
   1 conversion_error = vc
   1 mr = vc
   1 ms = vc
   1 month = vc
   1 months = vc
   1 year = vc
   1 years = vc
   1 rec_follow_up = vc
   1 patient = vc
   1 dob = vc
   1 rec_dt = vc
   1 order_id = vc
   1 recommend = vc
   1 insert_failed = vc
   1 study_id = vc
   1 invalid_sum_print = vc
   1 invalid_print = vc
 )
 RECORD letter_info(
   1 letter_name = vc
   1 template_id = f8
   1 study_info[*]
     2 study_id = f8
     2 order_id = f8
     2 letter_id = f8
     2 hist_sequence = i4
     2 template_id = f8
     2 order_physician_id = f8
     2 letter_name = vc
     2 parent_order_id = f8
     2 patient_notify_cd = f8
 )
 RECORD merged_letter_info(
   1 study_info[*]
     2 study_id = f8
     2 order_id = f8
     2 order_physician_id = f8
     2 physician_patient_list = vc
     2 contained_ids[*]
       3 study_id = f8
       3 letter_id = f8
       3 hist_sequence = i4
 )
 RECORD dates(
   1 reprint_date = dq8
   1 reprint_end_date = dq8
   1 print_from_date = dq8
 )
 RECORD strings(
   1 printer = vc
   1 summary_printer = vc
   1 type_check = vc
   1 rtf_file_name = vc
   1 ps_file_name = vc
   1 temp_str = vc
 )
 DECLARE g_i18nhandle = i4 WITH public, noconstant(0)
 DECLARE g_hstat = i4 WITH public, noconstant(0)
 DECLARE g_status = c1 WITH public, noconstant(g_blank)
 DECLARE g_subevent_ndx = i4 WITH public, noconstant(0)
 DECLARE g_dummyvar = i4 WITH public, noconstant(0)
 DECLARE g_temp_int = i4 WITH public, noconstant(0)
 DECLARE g_temp_float = f8 WITH public, noconstant(0.0)
 DECLARE g_print_ind = c1 WITH public, noconstant(g_blank)
 DECLARE g_sect_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_subsect_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_letter_type = c12 WITH public, noconstant(g_blank)
 DECLARE g_letter_name = c25 WITH public, noconstant(g_blank)
 DECLARE g_sect_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_report_final_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_resolved_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_followup_type_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_pat_notify1_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_pat_notify2_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_pat_notify3_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_pat_notify4_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_pat_notify5_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_pat_notify6_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_pat_notify7_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_letter_count = i4 WITH public, noconstant(0)
 DECLARE g_letter_pos = i4 WITH public, noconstant(0)
 DECLARE g_contained_count = i4 WITH public, noconstant(0)
 DECLARE g_contained_pos = i4 WITH public, noconstant(0)
 DECLARE g_print_from_date_ind = i4 WITH public, noconstant(0)
 DECLARE g_male_sex_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_female_sex_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_proc_name = c40 WITH public, noconstant(g_blank)
 DECLARE g_num_rows = i2 WITH public, noconstant(0)
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
 SET g_hstat = uar_i18nlocalizationinit(g_i18nhandle,curprog,"",curcclrev)
 CALL doi18nonstrings(g_dummyvar)
 SET g_status = g_status_success
 CALL processparameters(g_dummyvar)
 IF (g_status=g_status_fail)
  GO TO exit_script
 ENDIF
 SET strings->type_check = "mn.follow_up_default_type_cd "
 SET g_sect_type_cd = uar_get_code_by("MEANING",223,"SECTION")
 SET g_report_final_cd = uar_get_code_by("MEANING",14202,"FINAL")
 SET g_resolved_cd = uar_get_code_by("MEANING",14270,"RESOLVED")
 CASE (g_letter_type)
  OF g_patnotify_cdm:
   SET g_followup_type_cd = uar_get_code_by("MEANING",14271,nullterm(g_patnotify_cdm))
   SET strings->type_check = concat(strings->type_check," in (",cnvtstring(g_followup_type_cd))
   SET g_pat_notify1_cd = uar_get_code_by("MEANING",14271,nullterm(concat(g_patnotify_cdm,"1")))
   SET strings->type_check = concat(strings->type_check,",",cnvtstring(g_pat_notify1_cd))
   SET g_pat_notify2_cd = uar_get_code_by("MEANING",14271,nullterm(concat(g_patnotify_cdm,"2")))
   SET strings->type_check = concat(strings->type_check,",",cnvtstring(g_pat_notify2_cd))
   SET g_pat_notify3_cd = uar_get_code_by("MEANING",14271,nullterm(concat(g_patnotify_cdm,"3")))
   SET strings->type_check = concat(strings->type_check,",",cnvtstring(g_pat_notify3_cd))
   SET g_pat_notify4_cd = uar_get_code_by("MEANING",14271,nullterm(concat(g_patnotify_cdm,"4")))
   SET strings->type_check = concat(strings->type_check,",",cnvtstring(g_pat_notify4_cd))
   SET g_pat_notify5_cd = uar_get_code_by("MEANING",14271,nullterm(concat(g_patnotify_cdm,"5")))
   SET strings->type_check = concat(strings->type_check,",",cnvtstring(g_pat_notify5_cd))
   SET g_pat_notify6_cd = uar_get_code_by("MEANING",14271,nullterm(concat(g_patnotify_cdm,"6")))
   SET strings->type_check = concat(strings->type_check,",",cnvtstring(g_pat_notify6_cd))
   SET g_pat_notify7_cd = uar_get_code_by("MEANING",14271,nullterm(concat(g_patnotify_cdm,"7")))
   SET strings->type_check = concat(strings->type_check,",",cnvtstring(g_pat_notify7_cd),")")
   SET letter_info->letter_name = g_blank
   SET letter_info->template_id = 0
   IF (g_print_ind=g_want_to_print)
    CALL getnotificationletterstudylist(g_dummyvar)
   ELSE
    CALL getreprintletterstudylist(g_dummyvar)
   ENDIF
  OF g_patreminder_cdm:
   SET g_followup_type_cd = uar_get_code_by("MEANING",14271,nullterm(g_patreminder_cdm))
   SET strings->type_check = concat(strings->type_check,"=",cnvtstring(g_followup_type_cd))
   SET letter_info->letter_name = "DEFAULT_RADPATREMINDER"
   CALL getwptemplateid(letter_info->letter_name,g_temp_float)
   SET letter_info->template_id = g_temp_float
   IF (g_print_ind=g_want_to_print)
    CALL getreminderletterstudylist(g_dummyvar)
   ELSE
    CALL getreprintletterstudylist(g_dummyvar)
   ENDIF
  OF g_patwarning_cdm:
   SET g_followup_type_cd = uar_get_code_by("MEANING",14271,nullterm(g_patwarning_cdm))
   SET strings->type_check = concat(strings->type_check,"=",cnvtstring(g_followup_type_cd))
   SET letter_info->letter_name = "DEFAULT_RADPATWARNING"
   CALL getwptemplateid(letter_info->letter_name,g_temp_float)
   SET letter_info->template_id = g_temp_float
   IF (g_print_ind=g_want_to_print)
    CALL getwarningletterstudylist(g_dummyvar)
   ELSE
    CALL getreprintletterstudylist(g_dummyvar)
   ENDIF
  OF g_physreminder_cdm:
   SET g_followup_type_cd = uar_get_code_by("MEANING",14271,nullterm(g_physreminder_cdm))
   SET strings->type_check = concat(strings->type_check,"=",cnvtstring(g_followup_type_cd))
   SET letter_info->letter_name = "DEFAULT_RADPHYSREMINDER"
   CALL getwptemplateid(letter_info->letter_name,g_temp_float)
   SET letter_info->template_id = g_temp_float
   IF (g_print_ind=g_want_to_print)
    CALL getreminderletterstudylist(g_dummyvar)
   ELSE
    CALL getreprintletterstudylist(g_dummyvar)
   ENDIF
   IF (size(letter_info->study_info,5) > 0)
    CALL mergeduplicatephysicians(g_dummyvar)
   ENDIF
  OF g_physwarning_cdm:
   SET g_followup_type_cd = uar_get_code_by("MEANING",14271,nullterm(g_physwarning_cdm))
   SET strings->type_check = concat(strings->type_check,"=",cnvtstring(g_followup_type_cd))
   SET letter_info->letter_name = "DEFAULT_RADPHYSWARNING"
   CALL getwptemplateid(letter_info->letter_name,g_temp_float)
   SET letter_info->template_id = g_temp_float
   IF (g_print_ind=g_want_to_print)
    CALL getwarningletterstudylist(g_dummyvar)
   ELSE
    CALL getreprintletterstudylist(g_dummyvar)
   ENDIF
   IF (size(letter_info->study_info,5) > 0)
    CALL mergeduplicatephysicians(g_dummyvar)
   ENDIF
  OF g_physsurvey_cdm:
   SET g_followup_type_cd = uar_get_code_by("MEANING",14271,nullterm(g_physsurvey_cdm))
   SET strings->type_check = concat(strings->type_check,"=",cnvtstring(g_followup_type_cd))
   SET letter_info->letter_name = "DEFAULT_RADPHYSSURVEY"
   CALL getwptemplateid(letter_info->letter_name,g_temp_float)
   SET letter_info->template_id = g_temp_float
   IF (g_print_ind=g_want_to_print)
    CALL getphysiciansurveystudylist(g_dummyvar)
   ELSE
    CALL getreprintletterstudylist(g_dummyvar)
   ENDIF
 ENDCASE
 IF (g_letter_type IN (g_physreminder_cdm, g_physwarning_cdm))
  SET g_letter_count = size(merged_letter_info->study_info,5)
 ELSE
  SET g_letter_count = size(letter_info->study_info,5)
 ENDIF
 IF (g_letter_count=0)
  SET g_status = g_status_zero
  GO TO exit_script
 ENDIF
 SET letter_request->use_wp_template_flag = 1
 SET letter_request->script_name = letter_info->letter_name
 FOR (g_letter_pos = 1 TO g_letter_count)
   IF (g_letter_type IN (g_physreminder_cdm, g_physwarning_cdm))
    SET letter_request->visit[1].study_id = merged_letter_info->study_info[g_letter_pos].study_id
    SET letter_request->visit[1].order_id = merged_letter_info->study_info[g_letter_pos].order_id
    SET letter_request->visit[1].parent_order_id = 0
   ELSE
    SET letter_request->visit[1].study_id = letter_info->study_info[g_letter_pos].study_id
    SET letter_request->visit[1].order_id = letter_info->study_info[g_letter_pos].order_id
    IF ((letter_request->visit[1].order_id=0))
     SET letter_request->visit[1].parent_order_id = 0
    ELSE
     SET letter_request->visit[1].parent_order_id = letter_info->study_info[g_letter_pos].
     parent_order_id
    ENDIF
    IF (g_letter_type=g_patnotify_cdm)
     CALL echo(build("G_LETTER_TYPE:",g_letter_type))
     CALL echo(build("G_PATNOTIFY_CDM:",g_patnotify_cdm))
     IF (g_print_ind=g_want_to_print)
      CALL echo(build("G_PRINT_IND:",g_print_ind))
      CALL echo(build("G_WANT_TO_PRINT:",g_want_to_print))
      SET letter_request->script_name = letter_info->study_info[g_letter_pos].letter_name
      CALL echo(build("1-LETTER_REQUEST -> SCRIPT_NAME:",letter_request->script_name))
     ELSE
      CALL getnotifytemplatenameandid(letter_request->visit[1].study_id,g_letter_name,g_temp_float)
      SET letter_request->script_name = g_letter_name
      CALL echo(build("2-LETTER_REQUEST -> SCRIPT_NAME:",letter_request->script_name))
      SET letter_info->study_info[g_letter_pos].template_id = g_temp_float
     ENDIF
    ENDIF
   ENDIF
   SET g_hstat = alterlist(letter_request->nv,0)
   SET g_hstat = alterlist(letter_request->nv,9)
   SET g_male_sex_cd = uar_get_code_by("MEANING",57,"MALE")
   SET g_female_sex_cd = uar_get_code_by("MEANING",57,"FEMALE")
   IF ( NOT (validate(max_rpt_sequence,0)))
    DECLARE max_rpt_sequence = i4 WITH protect, noconstant(0)
   ENDIF
   IF ( NOT (validate(scredentials,0)))
    DECLARE scredentials = vc WITH protect, noconstant("")
   ENDIF
   IF ( NOT (validate(prsnl_name_type_cd,0)))
    DECLARE sql_get_name_display(personid=f8,nametypecd=f8,date=q8) = c100
    DECLARE prsnl_name_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   ENDIF
   SET letter_request->nv[1].pvc_name = "VALUE=PATIENT_TITLE_COMPUTE"
   SET letter_request->nv[2].pvc_name = "VALUE=MAMMO_FOLLOW_UP_INTERVAL"
   SET letter_request->nv[3].pvc_name = "VALUE=MAMMO_PHYSICIAN_PATIENT_LIST"
   SET letter_request->nv[4].pvc_name = "VALUE=LINKED_EXAM_NAMES"
   SET letter_request->nv[5].pvc_name = "VALUE=LINKED_EXAM_COMP_DT"
   SET letter_request->nv[6].pvc_name = "VALUE=RADIOLOGIST_FULL_NAME"
   SET letter_request->nv[7].pvc_name = "VALUE=ORDERING_PHYSICIAN_FULL_NAME"
   SET letter_request->nv[8].pvc_name = "VALUE=RADIOLOGIST_CREDENTIALS"
   SET letter_request->nv[9].pvc_name = "VALUE=ORDERING_PHYSICIAN_CREDENTIALS"
   SELECT INTO "nl:"
    FROM mammo_study ms,
     person p,
     rad_fol_up_field rf,
     mammo_follow_up mf
    PLAN (ms
     WHERE (ms.study_id=letter_request->visit[1].study_id))
     JOIN (p
     WHERE ms.person_id=p.person_id)
     JOIN (mf
     WHERE ms.study_id=mf.study_id)
     JOIN (rf
     WHERE rf.follow_up_field_id=outerjoin(ms.recommendation_id))
    DETAIL
     CASE (p.sex_cd)
      OF g_male_sex_cd:
       letter_request->nv[1].pvc_value = i18n->mr
      OF g_female_sex_cd:
       letter_request->nv[1].pvc_value = i18n->ms
      ELSE
       letter_request->nv[1].pvc_value = " "
     ENDCASE
     IF (ms.recall_interval > 0)
      IF (ms.recall_interval=1)
       letter_request->nv[2].pvc_value = concat(i18n->rec_follow_up," 1 ",i18n->month)
      ELSEIF (ms.recall_interval < 12)
       letter_request->nv[2].pvc_value = concat(i18n->rec_follow_up," ",trim(cnvtstring(ms
          .recall_interval))," ",i18n->months)
      ELSEIF (ms.recall_interval=12)
       letter_request->nv[2].pvc_value = concat(i18n->rec_follow_up," 1 ",i18n->year)
      ELSEIF (ms.recall_interval=13)
       letter_request->nv[2].pvc_value = concat(i18n->rec_follow_up," 1 ",i18n->year," 1 ",i18n->
        month)
      ELSEIF (ms.recall_interval < 24)
       g_temp_int = (ms.recall_interval - 12), letter_request->nv[2].pvc_value = concat(i18n->
        rec_follow_up," 1 ",i18n->year," ",trim(cnvtstring(g_temp_int)),
        " ",i18n->months)
      ELSEIF (mod(ms.recall_interval,12)=0)
       g_temp_int = (ms.recall_interval/ 12), letter_request->nv[2].pvc_value = concat(i18n->
        rec_follow_up," ",trim(cnvtstring(g_temp_int))," ",i18n->years)
      ELSEIF (mod(ms.recall_interval,12)=1)
       g_temp_int = (ms.recall_interval/ 12), letter_request->nv[2].pvc_value = concat(i18n->
        rec_follow_up," ",trim(cnvtstring(g_temp_int))," ",i18n->years,
        " 1 ",i18n->month)
      ELSE
       g_temp_int = (ms.recall_interval/ 12), letter_request->nv[2].pvc_value = concat(i18n->
        rec_follow_up," ",trim(cnvtstring(g_temp_int))," ",i18n->years), g_temp_int = mod(ms
        .recall_interval,12),
       letter_request->nv[2].pvc_value = concat(letter_request->nv[2].pvc_value," ",trim(cnvtstring(
          g_temp_int))," ",i18n->months)
      ENDIF
     ELSE
      letter_request->nv[2].pvc_value = " "
     ENDIF
     IF (validate(merged_letter_info->study_info[1].study_id,0)=0)
      g_temp_str = concat("\u ",i18n->patient,"                  ",i18n->dob), g_temp_str = concat(
       g_temp_str,"           ",i18n->rec_dt,"       ",i18n->recommend,
       "            \u0"), g_temp_str = concat(g_temp_str,"\par ",substring(1,25,p
        .name_full_formatted))
      IF (((p.birth_dt_tm > 0) OR (p.birth_dt_tm != null)) )
       g_temp_str = concat(g_temp_str," ",format(p.birth_dt_tm,cclfmt->shortdate4yr))
      ELSE
       g_temp_str = concat(g_temp_str,"           ")
      ENDIF
      IF (((mf.recall_dt_tm > 0) OR (mf.recall_dt_tm != null)) )
       g_temp_str = concat(g_temp_str,"    ",format(mf.recall_dt_tm,cclfmt->shortdate4yr))
      ELSE
       g_temp_str = concat(g_temp_str,"              ")
      ENDIF
      g_temp_str = concat(g_temp_str,"    ",substring(1,30,rf.field_description)), letter_request->
      nv[3].pvc_value = g_temp_str
     ENDIF
    WITH nocounter
   ;end select
   SET letter_request->nv[4].pvc_value = " "
   SET letter_request->nv[5].pvc_value = " "
   IF ((letter_request->visit[1].parent_order_id > 0))
    SELECT INTO "nl:"
     FROM order_radiology orad
     WHERE (((orad.order_id=letter_request->visit[1].parent_order_id)) OR ((orad.parent_order_id=
     letter_request->visit[1].parent_order_id)))
     HEAD REPORT
      g_hstat = 0
     DETAIL
      g_proc_name = uar_get_code_description(orad.catalog_cd)
      IF (g_hstat=0)
       letter_request->nv[4].pvc_value = g_proc_name, letter_request->nv[5].pvc_value = format(orad
        .complete_dt_tm,cclfmt->shortdate4yr)
      ELSE
       letter_request->nv[4].pvc_value = concat(letter_request->nv[4].pvc_value,", ",g_proc_name),
       letter_request->nv[5].pvc_value = concat(letter_request->nv[5].pvc_value,", ",format(orad
         .complete_dt_tm,cclfmt->shortdate4yr))
      ENDIF
      g_hstat = (g_hstat+ 1)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM mammo_study ms
     WHERE (ms.study_id=letter_request->visit[1].study_id)
     DETAIL
      letter_request->nv[4].pvc_value = uar_get_code_description(ms.catalog_cd), letter_request->nv[5
      ].pvc_value = format(ms.study_dt_tm,cclfmt->shortdate4yr)
     WITH nocounter
    ;end select
   ENDIF
   SET letter_request->nv[6].pvc_value = ""
   SET letter_request->nv[8].pvc_value = ""
   IF ((letter_request->visit[1].order_id > 0))
    SELECT INTO "nl:"
     nmaxseq = max(rr.sequence)
     FROM mammo_study ms,
      rad_report rr
     PLAN (ms
      WHERE (ms.study_id=letter_request->visit[1].study_id))
      JOIN (rr
      WHERE rr.order_id=ms.order_id)
     FOOT REPORT
      max_rpt_sequence = nmaxseq
     WITH nocounter
    ;end select
   ENDIF
   SELECT
    IF ((letter_request->visit[1].order_id > 0))INTO "nl:"
     smammoprsnlfullname = sql_get_name_display(msp.prsnl_id,prsnl_name_type_cd,rr.final_dt_tm),
     scredential = uar_get_code_display(c.credential_cd)
     FROM mammo_study ms,
      mammo_study_prsnl msp,
      rad_report rr,
      dummyt d1,
      credential c
     PLAN (ms
      WHERE (ms.study_id=letter_request->visit[1].study_id))
      JOIN (msp
      WHERE msp.study_id=ms.study_id
       AND msp.prsnl_relation_flag=2)
      JOIN (rr
      WHERE rr.order_id=outerjoin(ms.order_id)
       AND rr.sequence=outerjoin(max_rpt_sequence))
      JOIN (d1
      WHERE d1.seq)
      JOIN (c
      WHERE c.prsnl_id=msp.prsnl_id
       AND c.active_ind=1
       AND c.beg_effective_dt_tm <= cnvtdatetime(rr.final_dt_tm)
       AND c.end_effective_dt_tm > cnvtdatetime(rr.final_dt_tm))
     ORDER BY ms.study_id, c.display_seq
    ELSE INTO "nl:"
     smammoprsnlfullname = sql_get_name_display(msp.prsnl_id,prsnl_name_type_cd,ms.study_dt_tm),
     scredential = uar_get_code_display(c.credential_cd)
     FROM mammo_study ms,
      mammo_study_prsnl msp,
      dummyt d1,
      credential c
     PLAN (ms
      WHERE (ms.study_id=letter_request->visit[1].study_id))
      JOIN (msp
      WHERE msp.study_id=ms.study_id
       AND msp.prsnl_relation_flag=2)
      JOIN (d1
      WHERE d1.seq=1)
      JOIN (c
      WHERE c.prsnl_id=msp.prsnl_id
       AND c.active_ind=1
       AND c.beg_effective_dt_tm <= cnvtdatetime(ms.study_dt_tm)
       AND c.end_effective_dt_tm > cnvtdatetime(ms.study_dt_tm))
     ORDER BY ms.study_id, c.display_seq
    ENDIF
    HEAD ms.study_id
     letter_request->nv[6].pvc_value = smammoprsnlfullname, ncredcnt = 0, scredentials = ""
    DETAIL
     ncredcnt = (ncredcnt+ 1)
     IF (ncredcnt > 1)
      scredentials = concat(scredentials,", ",scredential)
     ELSE
      scredentials = scredential
     ENDIF
    FOOT  ms.study_id
     letter_request->nv[8].pvc_value = scredentials,
     CALL echo(build("CREDENTIALS = ",scredentials))
    WITH nocounter, outerjoin = d1
   ;end select
   SET letter_request->nv[7].pvc_value = ""
   SET letter_request->nv[9].pvc_value = ""
   IF ((letter_request->visit[1].order_id > 0))
    SELECT INTO "nl:"
     sorderphysfullname = sql_get_name_display(orad.order_physician_id,prsnl_name_type_cd,orad
      .request_dt_tm), scredential = uar_get_code_display(c.credential_cd)
     FROM order_radiology orad,
      dummyt d1,
      credential c
     PLAN (orad
      WHERE (orad.order_id=letter_request->visit[1].order_id))
      JOIN (d1
      WHERE d1.seq=1)
      JOIN (c
      WHERE c.prsnl_id=orad.order_physician_id
       AND c.active_ind=1
       AND c.beg_effective_dt_tm <= cnvtdatetime(orad.request_dt_tm)
       AND c.end_effective_dt_tm > cnvtdatetime(orad.request_dt_tm))
     ORDER BY orad.order_id, c.display_seq
     HEAD orad.order_id
      letter_request->nv[7].pvc_value = sorderphysfullname, ncredcnt = 0, scredentials = ""
     DETAIL
      ncredcnt = (ncredcnt+ 1)
      IF (ncredcnt > 1)
       scredentials = concat(scredentials,", ",trim(scredential))
      ELSE
       scredentials = trim(scredential)
      ENDIF
     FOOT  orad.order_id
      letter_request->nv[9].pvc_value = scredentials,
      CALL echo(build("CREDENTIALS = ",scredentials))
     WITH nocounter, outerjoin = d1
    ;end select
   ENDIF
   IF (g_letter_type IN (g_physreminder_cdm, g_physwarning_cdm))
    SET letter_request->nv[3].pvc_value = merged_letter_info->study_info[g_letter_pos].
    physician_patient_list
   ENDIF
   SET modify = nopredeclare
   EXECUTE cv_get_clin_note_doc  WITH replace(request,letter_request), replace(reply,letter_reply)
   SET modify = predeclare
   IF (size(letter_reply->text,1) > 1)
    EXECUTE cpm_create_file_name "rtfletter", "dat"
    SET strings->rtf_file_name = cpm_cfn_info->file_name
    EXECUTE cpm_create_file_name "psletter", "dat"
    SET strings->ps_file_name = cpm_cfn_info->file_name
    SELECT INTO value(strings->rtf_file_name)
     FROM dummyt d
     DETAIL
      letter_reply->text
     WITH nocounter, maxcol = 32000
    ;end select
    SET g_hstat = uar_rtf2ps(nullterm(strings->rtf_file_name),nullterm(strings->ps_file_name))
    IF (g_hstat=0)
     SET g_hstat = remove(strings->rtf_file_name)
     SET spool value(strings->ps_file_name) value(strings->printer) WITH deleted
     IF (g_letter_type IN (g_physreminder_cdm, g_physwarning_cdm))
      SET g_contained_count = size(merged_letter_info->study_info[g_letter_pos].contained_ids,5)
      FOR (g_contained_pos = 1 TO g_contained_count)
       IF (g_print_ind=g_want_to_reprint)
        CALL insertnotificationhistrecord(merged_letter_info->study_info[g_letter_pos].contained_ids[
         g_contained_pos].study_id,merged_letter_info->study_info[g_letter_pos].contained_ids[
         g_contained_pos].letter_id,letter_info->template_id,g_num_rows,g_followup_type_cd,
         merged_letter_info->study_info[g_letter_pos].contained_ids[g_contained_pos].hist_sequence)
       ELSE
        CALL insertnotificationrecord(merged_letter_info->study_info[g_letter_pos].contained_ids[
         g_contained_pos].study_id,merged_letter_info->study_info[g_letter_pos].contained_ids[
         g_contained_pos].letter_id,letter_info->template_id,g_num_rows,g_followup_type_cd)
       ENDIF
       IF (g_num_rows <= 0)
        SET g_contained_pos = (g_contained_count+ 1)
       ENDIF
      ENDFOR
     ELSEIF (g_letter_type=g_patnotify_cdm)
      IF ((letter_request->visit[1].parent_order_id=0))
       IF (g_print_ind=g_want_to_reprint)
        CALL insertnotificationhistrecord(letter_request->visit[1].study_id,letter_info->study_info[
         g_letter_pos].letter_id,letter_info->study_info[g_letter_pos].template_id,g_num_rows,
         letter_info->study_info[g_letter_pos].patient_notify_cd,
         letter_info->study_info[g_letter_pos].hist_sequence)
       ELSE
        CALL insertnotificationrecord(letter_request->visit[1].study_id,letter_info->study_info[
         g_letter_pos].letter_id,letter_info->study_info[g_letter_pos].template_id,g_num_rows,
         letter_info->study_info[g_letter_pos].patient_notify_cd)
       ENDIF
      ELSE
       IF (g_print_ind=g_want_to_reprint)
        CALL insertlinkednotificationhistrecord(letter_request->visit[1].parent_order_id,letter_info
         ->study_info[g_letter_pos].letter_id,letter_info->study_info[g_letter_pos].template_id,
         g_num_rows,letter_info->study_info[g_letter_pos].patient_notify_cd)
       ELSE
        CALL insertlinkednotificationrecord(letter_request->visit[1].parent_order_id,letter_info->
         study_info[g_letter_pos].letter_id,letter_info->study_info[g_letter_pos].template_id,
         g_num_rows,letter_info->study_info[g_letter_pos].patient_notify_cd)
       ENDIF
      ENDIF
     ELSE
      IF (g_print_ind=g_want_to_reprint)
       CALL insertnotificationhistrecord(letter_request->visit[1].study_id,letter_info->study_info[
        g_letter_pos].letter_id,letter_info->template_id,g_num_rows,g_followup_type_cd,
        letter_info->study_info[g_letter_pos].hist_sequence)
      ELSE
       CALL insertnotificationrecord(letter_request->visit[1].study_id,letter_info->study_info[
        g_letter_pos].letter_id,letter_info->template_id,g_num_rows,g_followup_type_cd)
      ENDIF
     ENDIF
     IF (g_num_rows <= 0)
      SET g_status = g_status_fail
      SET strings->temp_str = concat(i18n->study_id,cnvtstring(letter_request->visit[1].study_id))
      SET g_subevent_ndx = (g_subevent_ndx+ 1)
      SET g_hstat = alter(reply->status_data.subeventstatus,g_subevent_ndx)
      SET reply->status_data.subeventstatus[g_subevent_ndx].operationname = strings->temp_str
      SET reply->status_data.subeventstatus[g_subevent_ndx].operationstatus = g_status_fail
      SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = "mammo_notification"
      SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->insert_failed
      SET g_letter_pos = (g_letter_count+ 1)
     ENDIF
    ELSE
     SET strings->temp_str = concat(i18n->order_id,cnvtstring(letter_request->visit[1].order_id))
     SET g_subevent_ndx = (g_subevent_ndx+ 1)
     SET g_hstat = alter(reply->status_data.subeventstatus,g_subevent_ndx)
     SET reply->status_data.subeventstatus[g_subevent_ndx].operationname = strings->temp_str
     SET reply->status_data.subeventstatus[g_subevent_ndx].operationstatus = g_status_fail
     SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = strings->rtf_file_name
     SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->conversion_error
    ENDIF
   ELSE
    SET strings->temp_str = concat(i18n->order_id,cnvtstring(letter_request->visit[1].order_id))
    SET g_subevent_ndx = (g_subevent_ndx+ 1)
    SET g_hstat = alter(reply->status_data.subeventstatus,g_subevent_ndx)
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationname = strings->temp_str
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationstatus = g_status_fail
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = letter_request->
    script_name
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->missing_template
   ENDIF
 ENDFOR
#exit_script
 IF ((strings->summary_printer != g_blank))
  CALL printsummarypage(strings->summary_printer)
 ENDIF
 CALL echo(build("Total Letters Processed:",g_letter_count))
 SET reply->status_data.status = g_status
 FREE RECORD letter_request
 FREE RECORD letter_reply
 FREE RECORD i18n
 FREE RECORD letter_info
 FREE RECORD merged_letter_info
 SUBROUTINE printsummarypage(sprintername)
   CALL echo("PRINTSUMMARYPAGE")
   RECORD captions(
     1 title = vc
     1 pdate = vc
     1 time = vc
     1 l_date = vc
     1 l_type = vc
     1 p_not = vc
     1 ph_sur = vc
     1 p_rem = vc
     1 ph_rem = vc
     1 p_over = vc
     1 ph_over = vc
     1 init = vc
     1 reprint = vc
     1 p_name = vc
     1 dob = vc
     1 assess = vc
     1 foll_dt = vc
     1 ord_doc = vc
     1 rad = vc
     1 message = vc
     1 rpt_nm = vc
     1 pg = vc
     1 cases = vc
     1 end_rpt = vc
     1 sum_file = vc
     1 mrn = vc
     1 recommend = vc
     1 now = vc
   )
   DECLARE ssummaryfile = c25 WITH protect, noconstant(g_blank)
   DECLARE scurdate = c12 WITH protect, noconstant(g_blank)
   DECLARE scurtime = c12 WITH protect, noconstant(g_blank)
   DECLARE sletterdate = c12 WITH protect, noconstant(g_blank)
   DECLARE sline = c168 WITH protect, noconstant(g_blank)
   DECLARE stoday = c50 WITH protect, noconstant(g_blank)
   DECLARE npagenum = c3 WITH protect, noconstant(g_blank)
   DECLARE encntrmrntypecd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
   SET captions->title = uar_i18ngetmessage(g_i18nhandle,"title",
    "M A M M O G R A P H Y   L E T T E R S   S U M M A R Y")
   SET captions->pdate = uar_i18ngetmessage(g_i18nhandle,"date","PRINT DATE:")
   SET captions->time = uar_i18ngetmessage(g_i18nhandle,"time","TIME:")
   SET captions->l_date = uar_i18ngetmessage(g_i18nhandle,"l_dt","LETTER DATE:")
   SET captions->l_type = uar_i18ngetmessage(g_i18nhandle,"l_tp","LETTER TYPE: ")
   SET captions->p_not = uar_i18ngetmessage(g_i18nhandle,"p_not","Patient Notification")
   SET captions->ph_sur = uar_i18ngetmessage(g_i18nhandle,"ph_sur","Physician Survey")
   SET captions->p_rem = uar_i18ngetmessage(g_i18nhandle,"p_rem","Patient Reminder")
   SET captions->ph_rem = uar_i18ngetmessage(g_i18nhandle,"ph_rem","Physician Reminder")
   SET captions->p_over = uar_i18ngetmessage(g_i18nhandle,"p_over","Patient Overdue Warning")
   SET captions->ph_over = uar_i18ngetmessage(g_i18nhandle,"ph_over","Physician Overdue Warning")
   SET captions->init = uar_i18ngetmessage(g_i18nhandle,"init","(Initial Printing)")
   SET captions->reprint = uar_i18ngetmessage(g_i18nhandle,"reprint","(Reprint)")
   SET captions->p_name = uar_i18ngetmessage(g_i18nhandle,"p_nm","Patient Name")
   SET captions->dob = uar_i18ngetmessage(g_i18nhandle,"dob","DOB")
   SET captions->assess = uar_i18ngetmessage(g_i18nhandle,"assess","Assess")
   SET captions->foll_dt = uar_i18ngetmessage(g_i18nhandle,"foll_dt","Fol-Up Dt")
   SET captions->ord_doc = uar_i18ngetmessage(g_i18nhandle,"ord_doc","Order Doctor")
   SET captions->rad = uar_i18ngetmessage(g_i18nhandle,"rad","Radiologist")
   SET captions->message = uar_i18ngetmessage(g_i18nhandle,"mesg","NO STUDIES QUALIFY FOR LETTERS")
   SET captions->rpt_nm = uar_i18ngetmessage(g_i18nhandle,"rpt","REPORT: MAMMOGRAPHY LETTERS SUMMARY"
    )
   SET captions->pg = uar_i18ngetmessage(g_i18nhandle,"pg","PAGE:")
   SET captions->cases = uar_i18ngetmessage(g_i18nhandle,"cases","CASES")
   SET captions->end_rpt = uar_i18ngetmessage(g_i18nhandle,"end_rpt","### END OF REPORT ###")
   SET captions->sum_file = uar_i18ngetmessage(g_i18nhandle,"sum_file","Summary file:")
   SET captions->mrn = uar_i18ngetmessage(g_i18nhandle,"mrn","MRN")
   SET captions->recommend = uar_i18ngetmessage(g_i18nhandle,"recommend","Recommendation")
   SET captions->now = uar_i18ngetmessage(g_i18nhandle,"NOW","NOW")
   SET ssummaryfile = build("mammo_",trim(cnvtstring(curtime3)),".dat")
   SET g_letter_count = size(letter_info->study_info,5)
   SELECT INTO value(ssummaryfile)
    sorderphysfullname = sql_get_name_display(letter_info->study_info[d.seq].order_physician_id,
     prsnl_name_type_cd,orad.request_dt_tm), smammoprsnlfullname1 = sql_get_name_display(rad_mp
     .prsnl_id,prsnl_name_type_cd,ms.study_dt_tm), smammoprsnlfullname2 = sql_get_name_display(rad_mp
     .prsnl_id,prsnl_name_type_cd,rr.final_dt_tm)
    FROM (dummyt d  WITH seq = value(g_letter_count)),
     mammo_study ms,
     person pat,
     encntr_alias ea,
     rad_fol_up_field folfld,
     mammo_follow_up mf,
     mammo_study_prsnl rad_mp,
     rad_fol_up_field rec_fol,
     order_radiology orad,
     rad_report rr
    PLAN (d)
     JOIN (ms
     WHERE (ms.study_id=letter_info->study_info[d.seq].study_id))
     JOIN (folfld
     WHERE folfld.follow_up_field_id=outerjoin(ms.assessment_id))
     JOIN (rec_fol
     WHERE rec_fol.follow_up_field_id=outerjoin(ms.recommendation_id))
     JOIN (mf
     WHERE mf.study_id=ms.study_id)
     JOIN (orad
     WHERE orad.order_id=outerjoin(ms.order_id))
     JOIN (rad_mp
     WHERE (rad_mp.study_id=letter_info->study_info[d.seq].study_id)
      AND rad_mp.prsnl_relation_flag=2)
     JOIN (rr
     WHERE rr.order_id=ms.order_id
      AND (rr.sequence=
     (SELECT
      max(rr2.sequence)
      FROM rad_report rr2
      WHERE rr2.order_id=ms.order_id)))
     JOIN (pat
     WHERE pat.person_id=ms.person_id)
     JOIN (ea
     WHERE ea.encntr_id=outerjoin(ms.encntr_id)
      AND ea.encntr_alias_type_cd=outerjoin(encntrmrntypecd)
      AND ea.active_ind=outerjoin(1)
      AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
      AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
    HEAD REPORT
     sline = fillstring(168,"-"), scurdate = format(curdate,"@SHORTDATE4YR;;D"), scurtime = format(
      curtime,"@TIMENOSECONDS;;M"),
     sletterdate = format(dates->reprint_date,"@SHORTDATE4YR;;D"), stoday = concat(format(curdate,
       "@WEEKDAYABBREV;;D"),g_blank,format(curdate,"@MEDIUMDATE;;D"))
    HEAD PAGE
     col 50,
     CALL center(captions->title,0,170), row + 1,
     col 1, captions->pdate, col + 2,
     scurdate, col 143, captions->time,
     col + 6, scurtime, row + 1,
     col 1, captions->l_date, col + 2,
     sletterdate, row + 2, col 1,
     captions->l_type
     CASE (g_letter_type)
      OF g_patnotify_cdm:
       captions->p_not
      OF g_physsurvey_cdm:
       captions->ph_sur
      OF g_patreminder_cdm:
       captions->p_rem
      OF g_physreminder_cdm:
       captions->ph_rem
      OF g_patwarning_cdm:
       captions->p_over
      OF g_physwarning_cdm:
       captions->ph_over
     ENDCASE
     col + 2
     IF (g_print_ind=g_want_to_print)
      captions->init
     ELSE
      captions->reprint
     ENDIF
     row + 3, col 1, captions->p_name,
     col 32, captions->mrn, col 58,
     captions->dob, col 67, captions->assess,
     col 74, captions->foll_dt, col 86,
     captions->recommend, col 112, captions->ord_doc,
     col 141, captions->rad, row + 1,
     col 1, sline, row + 1
     IF (g_letter_count=0)
      row + 1, col 1, captions->message,
      row + 2
     ENDIF
    DETAIL
     strings->temp_str = concat(trim(pat.name_last),",",trim(pat.name_first),g_blank,substring(1,1,
       pat.name_middle)), col 1,
     CALL print(substring(1,28,strings->temp_str)),
     strings->temp_str = format(pat.birth_dt_tm,"@SHORTDATE4YR;;Q"), col 29,
     CALL print(substring(1,25,ea.alias)),
     col 55, strings->temp_str, col 70,
     CALL print(substring(1,1,folfld.acr_coded_field))
     IF ((ms.recall_interval=- (1)))
      col 74, captions->now
     ELSE
      strings->temp_str = format(mf.recall_dt_tm,"@SHORTDATE4YR;;Q"), col 74, strings->temp_str
     ENDIF
     col 86,
     CALL print(substring(1,25,rec_fol.field_description)), col 112,
     CALL print(substring(1,28,trim(sorderphysfullname))), col 141,
     CALL print(substring(1,28,trim(evaluate(rr.rad_report_id,0.0,smammoprsnlfullname1,
        smammoprsnlfullname2)))),
     row + 1
     IF ((row > (maxrow - 4)))
      BREAK
     ENDIF
    FOOT PAGE
     npagenum = format(curpage,"###;;I"), col 1, sline,
     row + 1, col 1, captions->rpt_nm,
     col 72, stoday, col 148,
     captions->pg, col 155, npagenum
    FOOT REPORT
     row + 1, col 1, g_letter_count,
     col + 2, captions->cases, row + 1,
     col 50,
     CALL center(captions->end_rpt,0,170)
    WITH nocounter, landscape, compress,
     nullreport, maxrow = 45, maxcol = 170
   ;end select
   SET spool value(ssummaryfile) value(sprintername) WITH deleted
 END ;Subroutine
 SUBROUTINE insertnotificationrecord(dstudyid,dletterid,dtemplateid,nrows,dfollowuptypecd)
   CALL echo("INSERTNOTIFICATIONRECORD")
   SET g_temp_int = 0
   SELECT INTO "nl:"
    FROM mammo_notification mn
    WHERE mn.study_id=dstudyid
     AND mn.sequence >= 0
    ORDER BY mn.sequence DESC
    HEAD REPORT
     g_temp_int = (mn.sequence+ 1)
    WITH nocounter
   ;end select
   INSERT  FROM mammo_notification mn
    SET mn.study_id = dstudyid, mn.sequence = g_temp_int, mn.template_id = dtemplateid,
     mn.follow_up_default_type_cd = dfollowuptypecd, mn.letter_id = dletterid, mn.notify_dt_tm =
     cnvtdatetime(curdate,curtime3),
     mn.updt_dt_tm = cnvtdatetime(curdate,curtime3), mn.updt_id = reqinfo->updt_id, mn.updt_cnt = 0,
     mn.updt_task = 4801, mn.updt_applctx = 0
    WITH nocounter
   ;end insert
   SET nrows = curqual
   COMMIT
 END ;Subroutine
 SUBROUTINE insertnotificationhistrecord(dstudyid,dletterid,dtemplateid,nrows,dfollowuptypecd,
  nhistseq)
   CALL echo("INSERTNOTIFICATIONHISTRECORD")
   INSERT  FROM mammo_notification_hist mnh
    SET mnh.study_id = dstudyid, mnh.hist_sequence = nhistseq, mnh.template_id = dtemplateid,
     mnh.follow_up_default_type_cd = dfollowuptypecd, mnh.letter_id = dletterid, mnh.notify_dt_tm =
     cnvtdatetime(curdate,curtime3),
     mnh.updt_dt_tm = cnvtdatetime(curdate,curtime3), mnh.updt_id = reqinfo->updt_id, mnh.updt_cnt =
     0,
     mnh.updt_task = 4801, mnh.updt_applctx = 0
    WITH nocounter
   ;end insert
   SET nrows = curqual
   COMMIT
 END ;Subroutine
 SUBROUTINE insertlinkednotificationrecord(dparentorderid,dletterid,dtemplateid,nrows,dfollowuptypecd
  )
   CALL echo("INSERTLINKEDNOTIFICATIONRECORD")
   RECORD temp_study(
     1 list[*]
       2 study_id = f8
       2 sequence = i4
   )
   SET g_temp_int = 0
   SELECT INTO "nl:"
    FROM mammo_notification mn,
     order_radiology orad,
     mammo_study ms
    PLAN (orad
     WHERE orad.order_id > 0
      AND ((orad.order_id=dparentorderid) OR (orad.parent_order_id=dparentorderid)) )
     JOIN (ms
     WHERE ms.order_id=orad.order_id)
     JOIN (mn
     WHERE mn.study_id=outerjoin(ms.study_id)
      AND mn.sequence >= outerjoin(0))
    ORDER BY ms.study_id, mn.sequence DESC
    HEAD ms.study_id
     g_temp_int = (g_temp_int+ 1), g_hstat = alterlist(temp_study->list,g_temp_int), temp_study->
     list[g_temp_int].study_id = ms.study_id,
     temp_study->list[g_temp_int].sequence = (mn.sequence+ 1)
    WITH nocounter
   ;end select
   INSERT  FROM mammo_notification mn,
     (dummyt d  WITH seq = value(g_temp_int))
    SET mn.study_id = temp_study->list[d.seq].study_id, mn.sequence = temp_study->list[d.seq].
     sequence, mn.template_id = dtemplateid,
     mn.follow_up_default_type_cd = dfollowuptypecd, mn.letter_id = dletterid, mn.notify_dt_tm =
     cnvtdatetime(curdate,curtime3),
     mn.updt_dt_tm = cnvtdatetime(curdate,curtime3), mn.updt_id = reqinfo->updt_id, mn.updt_cnt = 0,
     mn.updt_task = 4801, mn.updt_applctx = 0
    PLAN (d)
     JOIN (mn
     WHERE 1=1)
    WITH nocounter
   ;end insert
   SET nrows = curqual
   COMMIT
 END ;Subroutine
 SUBROUTINE insertlinkednotificationhistrecord(dparentorderid,dletterid,dtemplateid,nrows,
  dfollowuptypecd)
   CALL echo("INSERTLINKEDNOTIFICATIONHISTRECORD ")
   RECORD temp_study(
     1 list[*]
       2 study_id = f8
       2 sequence = i4
       2 hist_sequence = i4
   )
   SET g_temp_int = 0
   SELECT INTO "nl:"
    FROM mammo_notification_hist mnh,
     order_radiology orad,
     mammo_study ms
    PLAN (orad
     WHERE orad.order_id > 0
      AND ((orad.order_id=dparentorderid) OR (orad.parent_order_id=dparentorderid)) )
     JOIN (ms
     WHERE ms.order_id=orad.order_id)
     JOIN (mnh
     WHERE mnh.study_id=outerjoin(ms.study_id))
    ORDER BY ms.study_id, mnh.hist_sequence DESC
    HEAD ms.study_id
     g_temp_int = (g_temp_int+ 1), g_hstat = alterlist(temp_study->list,g_temp_int), temp_study->
     list[g_temp_int].study_id = ms.study_id,
     temp_study->list[g_temp_int].hist_sequence = (mnh.hist_sequence+ 1)
    WITH nocounter
   ;end select
   INSERT  FROM mammo_notification_hist mnh,
     (dummyt d  WITH seq = value(g_temp_int))
    SET mnh.study_id = temp_study->list[d.seq].study_id, mnh.hist_sequence =
     IF ((temp_study->list[d.seq].hist_sequence > 0)) temp_study->list[d.seq].hist_sequence
     ELSE 1
     ENDIF
     , mnh.template_id = dtemplateid,
     mnh.follow_up_default_type_cd = dfollowuptypecd, mnh.letter_id = dletterid, mnh.notify_dt_tm =
     cnvtdatetime(curdate,curtime3),
     mnh.updt_dt_tm = cnvtdatetime(curdate,curtime3), mnh.updt_id = reqinfo->updt_id, mnh.updt_cnt =
     0,
     mnh.updt_task = 4801, mnh.updt_applctx = 0
    PLAN (d)
     JOIN (mnh)
    WITH nocounter
   ;end insert
   SET nrows = curqual
   COMMIT
 END ;Subroutine
 SUBROUTINE copylettertophysician(nletterpos,nmergedletterpos,nnewind)
   CALL echo("COPYLETTERTOPHYSICIAN")
   DECLARE ncount = i4 WITH protect, noconstant(0)
   DECLARE nstat = i4 WITH protect, noconstant(0)
   DECLARE snamestr = vc WITH protect, noconstant(g_blank)
   DECLARE sblankstr = vc WITH protect, noconstant(g_blank)
   DECLARE s25wierdblanks = c25 WITH protect, constant("")
   IF (nnewind=1)
    SET strings->temp_str = concat("\u ",i18n->patient,"                   ",i18n->dob)
    SET strings->temp_str = concat(strings->temp_str,"             ",i18n->rec_dt,"     ",i18n->
     recommend,
     "            \ul0\par")
    SET merged_letter_info->study_info[nmergedletterpos].order_id = letter_info->study_info[
    nletterpos].order_id
    SET merged_letter_info->study_info[nmergedletterpos].study_id = letter_info->study_info[
    nletterpos].study_id
    SET merged_letter_info->study_info[nmergedletterpos].order_physician_id = letter_info->
    study_info[nletterpos].order_physician_id
    SET merged_letter_info->study_info[nmergedletterpos].hist_sequence = letter_info->study_info[
    nletterpos].hist_sequence
   ELSE
    SET strings->temp_str = merged_letter_info->study_info[nmergedletterpos].physician_patient_list
   ENDIF
   SET ncount = size(merged_letter_info->study_info[nmergedletterpos].contained_ids,5)
   SET ncount = (ncount+ 1)
   SET nstat = alterlist(merged_letter_info->study_info[nmergedletterpos].contained_ids,ncount)
   SET merged_letter_info->study_info[nmergedletterpos].contained_ids[ncount].study_id = letter_info
   ->study_info[nletterpos].study_id
   SET merged_letter_info->study_info[nmergedletterpos].contained_ids[ncount].letter_id = letter_info
   ->study_info[nletterpos].letter_id
   SELECT INTO "nl:"
    FROM mammo_study ms,
     person p,
     mammo_follow_up mf,
     rad_fol_up_field rf
    PLAN (ms
     WHERE (ms.study_id=letter_info->study_info[nletterpos].study_id))
     JOIN (p
     WHERE ms.person_id=p.person_id)
     JOIN (mf
     WHERE ms.study_id=mf.study_id)
     JOIN (rf
     WHERE rf.follow_up_field_id=outerjoin(ms.recommendation_id))
    DETAIL
     snamestr = substring(1,25,p.name_full_formatted), ncount = (26 - size(snamestr,1)), sblankstr =
     substring(1,ncount,s25wierdblanks),
     s4blankstr = substring(1,4,s25wierdblanks), s10blankstr = substring(1,10,s25wierdblanks),
     strings->temp_str = concat(strings->temp_str,g_blank,snamestr,sblankstr)
     IF (((p.birth_dt_tm > 0) OR (p.birth_dt_tm != null)) )
      strings->temp_str = concat(strings->temp_str,format(p.birth_dt_tm,cclfmt->shortdate4yr),
       s4blankstr)
     ELSE
      strings->temp_str = concat(strings->temp_str,s10blankstr,s4blankstr)
     ENDIF
     IF (((mf.recall_dt_tm > 0) OR (mf.recall_dt_tm != null)) )
      strings->temp_str = concat(strings->temp_str,format(mf.recall_dt_tm,cclfmt->shortdate4yr),
       s4blankstr)
     ELSE
      strings->temp_str = concat(strings->temp_str,s10blankstr,s4blankstr)
     ENDIF
     strings->temp_str = concat(strings->temp_str,"    ",substring(1,30,rf.field_description),"\par "
      )
    WITH nocounter
   ;end select
   SET merged_letter_info->study_info[nmergedletterpos].physician_patient_list = strings->temp_str
 END ;Subroutine
 SUBROUTINE mergeduplicatephysicians(ndummyvar)
   CALL echo("MERGEDUPLICATEPHYSICIANS")
   DECLARE nstat = i4 WITH private, noconstant(0)
   DECLARE nmergedlettercount = i4 WITH private, noconstant(0)
   DECLARE nlettercount = i4 WITH private, noconstant(0)
   DECLARE nmergedletterpos = i4 WITH private, noconstant(0)
   DECLARE nletterpos = i4 WITH private, noconstant(0)
   DECLARE nmatchlocation = i4 WITH private, noconstant(0)
   SET nlettercount = size(letter_info->study_info,5)
   SET nstat = alterlist(merged_letter_info->study_info,nlettercount)
   CALL copylettertophysician(1,1,1)
   SET nmergedlettercount = 1
   IF (nlettercount > 1)
    FOR (nletterpos = 2 TO nlettercount)
      SET nmatchlocation = 0
      FOR (nmergedletterpos = 1 TO nmergedlettercount)
        IF ((letter_info->study_info[nletterpos].order_physician_id=merged_letter_info->study_info[
        nmergedletterpos].order_physician_id))
         SET nmatchlocation = nmergedletterpos
         SET nmergedletterpos = nmergedlettercount
        ENDIF
      ENDFOR
      IF (nmatchlocation > 0)
       CALL copylettertophysician(nletterpos,nmatchlocation,0)
      ELSE
       SET nmergedlettercount = (nmergedlettercount+ 1)
       CALL copylettertophysician(nletterpos,nmergedlettercount,1)
      ENDIF
    ENDFOR
   ENDIF
   SET nstat = alterlist(merged_letter_info->study_info,nmergedlettercount)
 END ;Subroutine
 SUBROUTINE getnotificationletterstudylist(ndummyvar)
   CALL echo("GETNOTIFICATIONLETTERSTUDYLIST")
   DECLARE nsize = i4 WITH protect, noconstant(100)
   DECLARE nstat = i4 WITH protect, noconstant(0)
   DECLARE ncount = i4 WITH protect, noconstant(0)
   SET nstat = alterlist(letter_info->study_info,nsize)
   SELECT INTO "nl:"
    FROM mammo_follow_up mf,
     mammo_study ms,
     rad_fol_up_field rfuf,
     order_radiology o,
     mammo_letter_detail ml,
     wp_template wt,
     resource_group rg,
     person p,
     rad_report rr
    PLAN (mf
     WHERE mf.study_id > 0
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM mammo_notification mn
      WHERE mn.study_id=mf.study_id
       AND mn.follow_up_default_type_cd IN (g_followup_type_cd, g_pat_notify1_cd, g_pat_notify2_cd,
      g_pat_notify3_cd, g_pat_notify4_cd,
      g_pat_notify5_cd, g_pat_notify6_cd, g_pat_notify7_cd)))))
     JOIN (ms
     WHERE mf.study_id=ms.study_id
      AND ms.letter_id > 0
      AND ms.active_ind=1
      AND ((g_subsect_cd=0) OR (((ms.subsection_cd+ 0)=g_subsect_cd))) )
     JOIN (rfuf
     WHERE rfuf.follow_up_field_id=ms.assessment_id)
     JOIN (o
     WHERE ((ms.order_id=o.order_id
      AND ((o.report_status_cd+ 0)=g_report_final_cd)
      AND o.parent_order_id=o.order_id) OR (ms.order_id=0
      AND ((ms.study_id+ 0) != 0)
      AND o.order_id=0)) )
     JOIN (rr
     WHERE rr.order_id=o.parent_order_id
      AND ((g_print_from_date_ind=0) OR (((datetimecmp(rr.final_dt_tm,cnvtdatetime(dates->
       print_from_date)) >= 0) OR (datetimecmp(ms.study_dt_tm,cnvtdatetime(dates->print_from_date))
      >= 0
      AND rr.order_id=0.0)) )) )
     JOIN (ml
     WHERE ml.letter_id=ms.letter_id)
     JOIN (wt
     WHERE wt.template_id=ml.template_id)
     JOIN (rg
     WHERE ((g_sect_cd=0) OR (rg.parent_service_resource_cd=g_sect_cd))
      AND ms.subsection_cd=rg.child_service_resource_cd
      AND rg.resource_group_type_cd=g_sect_type_cd
      AND rg.root_service_resource_cd=0
      AND ((rg.active_ind+ 0)=1)
      AND ((rg.beg_effective_dt_tm+ 0) < cnvtdatetime(curdate,curtime3))
      AND ((rg.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     JOIN (p
     WHERE p.person_id=ms.person_id)
    ORDER BY p.name_full_formatted, ms.study_id
    HEAD ms.study_id
     ncount = (ncount+ 1)
     IF (ncount > nsize)
      nsize = (nsize+ 100), nstat = alterlist(letter_info->study_info,nsize)
     ENDIF
     letter_info->study_info[ncount].study_id = ms.study_id, letter_info->study_info[ncount].order_id
      = ms.order_id, letter_info->study_info[ncount].letter_id = ms.letter_id,
     letter_info->study_info[ncount].template_id = wt.template_id, letter_info->study_info[ncount].
     letter_name = wt.short_desc, letter_info->study_info[ncount].order_physician_id = o
     .order_physician_id
     IF (o.parent_order_id > 0)
      letter_info->study_info[ncount].parent_order_id = o.parent_order_id
     ELSE
      letter_info->study_info[ncount].parent_order_id = o.order_id
     ENDIF
     CASE (rfuf.cerner_meaning_str)
      OF "ACR132":
       letter_info->study_info[ncount].patient_notify_cd = g_followup_type_cd
      OF "ACR141":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify1_cd
      OF "ACR145":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify2_cd
      OF "ACR149":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify3_cd
      OF "ACR152":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify4_cd
      OF "ACR1153":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify4_cd
      OF "ACR1154":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify4_cd
      OF "ACR1155":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify4_cd
      OF "ACR159":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify5_cd
      OF "ACR2356":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify6_cd
      OF "ACR2359":
       letter_info->study_info[ncount].patient_notify_cd = g_pat_notify7_cd
     ENDCASE
    WITH nocounter
   ;end select
   SET nstat = alterlist(letter_info->study_info,ncount)
 END ;Subroutine
 SUBROUTINE getreprintletterstudylist(ndummyvar)
   CALL echo("GETREPRINTLETTERSTUDYLIST")
   DECLARE nsize = i4 WITH protect, noconstant(100)
   DECLARE nstat = i4 WITH protect, noconstant(0)
   DECLARE ncount = i4 WITH protect, noconstant(0)
   SET nstat = alterlist(letter_info->study_info,nsize)
   CALL echorecord(letter_info)
   CALL echo(build("DATES -> REPRINT_DATE:",format(dates->reprint_date,";;q")))
   CALL echo(build("DATES -> REPRINT_END_DATE:",format(dates->reprint_end_date,";;q")))
   CALL echo(build("STRINGS -> TYPE_CHECK:",strings->type_check))
   SELECT INTO "nl:"
    FROM mammo_notification mn,
     mammo_study ms,
     resource_group rg,
     order_radiology o,
     person p
    PLAN (mn
     WHERE ((mn.study_id+ 0) != 0)
      AND mn.notify_dt_tm >= cnvtdatetime(dates->print_from_date)
      AND mn.notify_dt_tm <= cnvtdatetime(dates->reprint_end_date)
      AND ((mn.sequence+ 0) >= 0)
      AND parser(strings->type_check))
     JOIN (ms
     WHERE mn.study_id=ms.study_id
      AND ms.active_ind=1
      AND ((g_subsect_cd=0) OR (((ms.subsection_cd+ 0)=g_subsect_cd))) )
     JOIN (rg
     WHERE ((g_sect_cd=0) OR (rg.parent_service_resource_cd=g_sect_cd))
      AND ms.subsection_cd=rg.child_service_resource_cd
      AND rg.resource_group_type_cd=g_sect_type_cd
      AND ((rg.root_service_resource_cd+ 0)=0)
      AND ((rg.active_ind+ 0)=1)
      AND ((rg.beg_effective_dt_tm+ 0) < cnvtdatetime(curdate,curtime3))
      AND ((rg.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     JOIN (o
     WHERE o.order_id=ms.order_id
      AND ((g_letter_type != g_patnotify_cdm) OR (((o.parent_order_id+ 0)=o.order_id))) )
     JOIN (p
     WHERE p.person_id=ms.person_id)
    ORDER BY p.name_full_formatted, ms.study_id
    DETAIL
     ncount = (ncount+ 1)
     IF (ncount > nsize)
      nsize = (nsize+ 100), nstat = alterlist(letter_info->study_info,nsize)
     ENDIF
     letter_info->study_info[ncount].study_id = ms.study_id, letter_info->study_info[ncount].order_id
      = ms.order_id, letter_info->study_info[ncount].letter_id = ms.letter_id,
     letter_info->study_info[ncount].template_id = 0, letter_info->study_info[ncount].
     order_physician_id = o.order_physician_id, letter_info->study_info[ncount].patient_notify_cd =
     mn.follow_up_default_type_cd
     IF (o.parent_order_id > 0)
      letter_info->study_info[ncount].parent_order_id = o.parent_order_id
     ELSE
      letter_info->study_info[ncount].parent_order_id = o.order_id
     ENDIF
    FOOT REPORT
     stat = alterlist(letter_info->study_info,ncount)
    WITH nocounter
   ;end select
   SET nstat = alterlist(letter_info->study_info,ncount)
   IF (ncount != 0)
    SELECT INTO "nl:"
     FROM mammo_notification_hist mnh,
      (dummyt d  WITH seq = value(ncount))
     PLAN (d)
      JOIN (mnh
      WHERE (mnh.study_id=letter_info->study_info[d.seq].study_id))
     ORDER BY mnh.study_id, mnh.hist_sequence DESC
     HEAD REPORT
      hist_seq = 0
     HEAD mnh.study_id
      hist_seq = mnh.hist_sequence
     DETAIL
      IF ((letter_info->study_info[d.seq].hist_sequence=0))
       hist_seq = (hist_seq+ 1), letter_info->study_info[d.seq].hist_sequence = hist_seq
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     studyid = letter_info->study_info[d.seq].study_id
     FROM (dummyt d  WITH seq = value(ncount))
     PLAN (d
      WHERE (letter_info->study_info[d.seq].hist_sequence=0))
     ORDER BY studyid
     HEAD studyid
      hist_seq = 0
     DETAIL
      hist_seq = (hist_seq+ 1), letter_info->study_info[d.seq].hist_sequence = hist_seq
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE getreminderletterstudylist(ndummyvar)
   CALL echo("GETREMINDERLETTERSTUDYLIST")
   DECLARE nsize = i4 WITH protect, noconstant(100)
   DECLARE nstat = i4 WITH protect, noconstant(0)
   DECLARE ncount = i4 WITH protect, noconstant(0)
   SET nstat = alterlist(letter_info->study_info,nsize)
   SELECT INTO "nl:"
    FROM mammo_follow_up mf,
     mammo_study ms,
     order_radiology o,
     rad_follow_up_control rfc,
     resource_group rg,
     person p
    PLAN (rfc
     WHERE rfc.follow_up_control_id != 0.0)
     JOIN (mf
     WHERE mf.study_id != 0.0
      AND mf.case_status_cd != g_resolved_cd
      AND ((mf.recall_dt_tm != null
      AND datetimecmp(mf.recall_dt_tm,cnvtdatetime(curdate,curtime3)) <= rfc.advance_print_interval
      AND datetimecmp(mf.recall_dt_tm,cnvtdatetime(curdate,curtime3)) >= 0) OR ( EXISTS (
     (SELECT
      1
      FROM mammo_study ms2,
       rad_fol_up_field ff
      WHERE ms2.study_id=mf.study_id
       AND (ms2.recall_interval=- (1))
       AND ff.follow_up_field_id=ms2.assessment_id
       AND ff.acr_coded_field != "0"))))
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM mammo_notification mn
      WHERE mn.study_id=mf.study_id
       AND mn.follow_up_default_type_cd=g_followup_type_cd))))
     JOIN (ms
     WHERE mf.study_id=ms.study_id
      AND ms.active_ind=1
      AND ((g_subsect_cd=0) OR (((ms.subsection_cd+ 0)=g_subsect_cd)))
      AND ms.no_fol_up_req_ind=0
      AND (ms.recall_interval != - (1)))
     JOIN (o
     WHERE ((ms.order_id=o.order_id
      AND ((o.report_status_cd+ 0)=g_report_final_cd)
      AND ms.order_id != 0.0
      AND ((o.complete_dt_tm+ 0) != null)) OR (ms.order_id=0
      AND o.order_id=0)) )
     JOIN (rg
     WHERE ((g_sect_cd=0) OR (rg.parent_service_resource_cd=g_sect_cd))
      AND ms.subsection_cd=rg.child_service_resource_cd
      AND rg.resource_group_type_cd=g_sect_type_cd
      AND rg.root_service_resource_cd=0
      AND ((rg.active_ind+ 0)=1)
      AND ((rg.beg_effective_dt_tm+ 0) < cnvtdatetime(curdate,curtime3))
      AND ((rg.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     JOIN (p
     WHERE p.person_id=ms.person_id)
    ORDER BY p.name_full_formatted, ms.study_id
    DETAIL
     ncount = (ncount+ 1)
     IF (ncount > nsize)
      nsize = (nsize+ 100), nstat = alterlist(letter_info->study_info,nsize)
     ENDIF
     letter_info->study_info[ncount].study_id = ms.study_id, letter_info->study_info[ncount].order_id
      = ms.order_id, letter_info->study_info[ncount].letter_id = ms.letter_id,
     letter_info->study_info[ncount].template_id = 0, letter_info->study_info[ncount].
     order_physician_id = o.order_physician_id
     IF (o.parent_order_id > 0)
      letter_info->study_info[ncount].parent_order_id = o.parent_order_id
     ELSE
      letter_info->study_info[ncount].parent_order_id = o.order_id
     ENDIF
    WITH nocounter
   ;end select
   SET nstat = alterlist(letter_info->study_info,ncount)
 END ;Subroutine
 SUBROUTINE getwarningletterstudylist(ndummyvar)
   CALL echo("GETWARNINGLETTERSTUDYLIST")
   DECLARE nsize = i4 WITH protect, noconstant(100)
   DECLARE nstat = i4 WITH protect, noconstant(0)
   DECLARE ncount = i4 WITH protect, noconstant(0)
   SET nstat = alterlist(letter_info->study_info,nsize)
   SELECT INTO "nl:"
    FROM mammo_follow_up mf,
     mammo_study ms,
     order_radiology o,
     rad_follow_up_control rfc,
     resource_group rg,
     person p
    PLAN (rfc
     WHERE rfc.follow_up_control_id > 0)
     JOIN (mf
     WHERE mf.study_id > 0
      AND mf.case_status_cd != g_resolved_cd
      AND mf.recall_dt_tm != null
      AND datetimecmp(cnvtdatetime(curdate,curtime3),mf.recall_dt_tm) >= rfc.days_before_warning
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM mammo_notification mn
      WHERE mn.study_id=mf.study_id
       AND mn.follow_up_default_type_cd=g_followup_type_cd))))
     JOIN (ms
     WHERE mf.study_id=ms.study_id
      AND ms.active_ind=1
      AND ((g_subsect_cd=0) OR (((ms.subsection_cd+ 0)=g_subsect_cd)))
      AND ms.no_fol_up_req_ind=0
      AND (ms.recall_interval != - (1)))
     JOIN (o
     WHERE ((ms.order_id=o.order_id
      AND ((o.report_status_cd+ 0)=g_report_final_cd)
      AND ms.order_id != 0.0
      AND ((o.complete_dt_tm+ 0) != null)) OR (ms.order_id=0.0
      AND o.order_id=0.0)) )
     JOIN (rg
     WHERE ((g_sect_cd=0) OR (rg.parent_service_resource_cd=g_sect_cd))
      AND ms.subsection_cd=rg.child_service_resource_cd
      AND rg.resource_group_type_cd=g_sect_type_cd
      AND rg.root_service_resource_cd=0
      AND ((rg.active_ind+ 0)=1)
      AND ((rg.beg_effective_dt_tm+ 0) < cnvtdatetime(curdate,curtime3))
      AND ((rg.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     JOIN (p
     WHERE p.person_id=ms.person_id)
    ORDER BY p.name_full_formatted, ms.study_id
    DETAIL
     ncount = (ncount+ 1)
     IF (ncount > nsize)
      nsize = (nsize+ 100), nstat = alterlist(letter_info->study_info,nsize)
     ENDIF
     letter_info->study_info[ncount].study_id = ms.study_id, letter_info->study_info[ncount].order_id
      = ms.order_id, letter_info->study_info[ncount].letter_id = ms.letter_id,
     letter_info->study_info[ncount].template_id = 0, letter_info->study_info[ncount].
     order_physician_id = o.order_physician_id
     IF (o.parent_order_id > 0)
      letter_info->study_info[ncount].parent_order_id = o.parent_order_id
     ELSE
      letter_info->study_info[ncount].parent_order_id = o.order_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM mammo_follow_up mf,
     mammo_study ms,
     mammo_notification mn,
     rad_follow_up_control rfc,
     order_radiology o,
     resource_group rg,
     person p
    PLAN (rfc
     WHERE rfc.follow_up_control_id > 0)
     JOIN (mf
     WHERE mf.study_id > 0
      AND mf.case_status_cd != g_resolved_cd
      AND mf.recall_dt_tm != null)
     JOIN (mn
     WHERE mn.study_id=mf.study_id
      AND mn.sequence >= 0
      AND mn.follow_up_default_type_cd=g_followup_type_cd
      AND (mn.sequence=
     (SELECT
      max(mn2.sequence)
      FROM mammo_notification mn2
      WHERE mn2.study_id=mf.study_id
       AND mn2.follow_up_default_type_cd=g_followup_type_cd))
      AND datetimecmp(cnvtdatetime(curdate,curtime3),mn.notify_dt_tm) >= rfc.days_between_warning
      AND ((rfc.max_warning_letter_prints=0) OR ((rfc.max_warning_letter_prints >
     (SELECT
      count(*)
      FROM mammo_notification mn3
      WHERE mn3.study_id=mf.study_id
       AND mn3.sequence >= 0
       AND mn3.follow_up_default_type_cd=g_followup_type_cd)))) )
     JOIN (ms
     WHERE ms.study_id=mf.study_id
      AND ms.active_ind=1
      AND ((g_subsect_cd=0) OR (((ms.subsection_cd+ 0)=g_subsect_cd)))
      AND ms.no_fol_up_req_ind=0
      AND (ms.recall_interval != - (1)))
     JOIN (o
     WHERE ((ms.order_id=o.order_id
      AND ((o.report_status_cd+ 0)=g_report_final_cd)
      AND ms.order_id != 0.0
      AND ((o.complete_dt_tm+ 0) != null)) OR (ms.order_id=0
      AND o.order_id=0)) )
     JOIN (rg
     WHERE ((g_sect_cd=0) OR (rg.parent_service_resource_cd=g_sect_cd))
      AND ms.subsection_cd=rg.child_service_resource_cd
      AND rg.resource_group_type_cd=g_sect_type_cd
      AND rg.root_service_resource_cd=0
      AND ((rg.active_ind+ 0)=1)
      AND ((rg.beg_effective_dt_tm+ 0) < cnvtdatetime(curdate,curtime3))
      AND ((rg.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     JOIN (p
     WHERE p.person_id=ms.person_id)
    ORDER BY p.name_full_formatted, ms.study_id
    DETAIL
     ncount = (ncount+ 1)
     IF (ncount > nsize)
      nsize = (nsize+ 100), nstat = alterlist(letter_info->study_info,nsize)
     ENDIF
     letter_info->study_info[ncount].study_id = ms.study_id, letter_info->study_info[ncount].order_id
      = ms.order_id, letter_info->study_info[ncount].letter_id = ms.letter_id,
     letter_info->study_info[ncount].template_id = 0, letter_info->study_info[ncount].
     order_physician_id = o.order_physician_id
     IF (o.parent_order_id > 0)
      letter_info->study_info[ncount].parent_order_id = o.parent_order_id
     ELSE
      letter_info->study_info[ncount].parent_order_id = o.order_id
     ENDIF
    WITH nocounter
   ;end select
   SET nstat = alterlist(letter_info->study_info,ncount)
 END ;Subroutine
 SUBROUTINE getphysiciansurveystudylist(ndummyvar)
   CALL echo("GETPHYSICIANSURVEYSTUDYLIST")
   DECLARE nsize = i4 WITH protect, noconstant(100)
   DECLARE nstat = i4 WITH protect, noconstant(0)
   DECLARE ncount = i4 WITH protect, noconstant(0)
   SET nstat = alterlist(letter_info->study_info,nsize)
   SELECT INTO "nl:"
    FROM mammo_follow_up mf,
     rad_follow_up_control rfc,
     mammo_study ms,
     order_radiology o,
     resource_group rg,
     rad_fol_up_field folfld,
     person p,
     rad_report rr
    PLAN (rfc
     WHERE rfc.follow_up_control_id > 0)
     JOIN (mf
     WHERE mf.study_id > 0
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM mammo_notification mn
      WHERE mn.study_id=mf.study_id
       AND mn.follow_up_default_type_cd=g_followup_type_cd))))
     JOIN (ms
     WHERE mf.study_id=ms.study_id
      AND ms.active_ind=1
      AND ms.assessment_id > 0
      AND ((g_subsect_cd=0) OR (((ms.subsection_cd+ 0)=g_subsect_cd)))
      AND datetimecmp(cnvtdatetime(curdate,curtime3),ms.study_dt_tm) > rfc.days_before_survey
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM rad_fol_up_field rf,
       mammo_breast_find mambf,
       mammo_find mamf,
       mammo_find_detail mamfd
      WHERE mambf.study_id=ms.study_id
       AND mamf.breast_find_id=mambf.breast_find_id
       AND rf.edition_nbr=ms.edition_nbr
       AND rf.cerner_meaning_str IN ("ACR594", "ACR3800")
       AND mamfd.find_id=mamf.find_id
       AND mamfd.field_id=rf.follow_up_field_id
       AND mamfd.value_dt_tm IS NOT null))))
     JOIN (o
     WHERE ((ms.order_id=o.order_id
      AND ((o.report_status_cd+ 0)=g_report_final_cd)) OR (ms.order_id=0
      AND ((ms.study_id+ 0) != 0)
      AND o.order_id=0)) )
     JOIN (rr
     WHERE rr.order_id=o.parent_order_id
      AND ((g_print_from_date_ind=0) OR (((datetimecmp(rr.final_dt_tm,cnvtdatetime(dates->
       print_from_date)) >= 0) OR (datetimecmp(ms.study_dt_tm,cnvtdatetime(dates->print_from_date))
      >= 0
      AND rr.order_id=0.0)) )) )
     JOIN (folfld
     WHERE folfld.follow_up_field_id=ms.assessment_id
      AND folfld.acr_coded_field IN ("4", "4A", "4B", "4C", "5",
     "7"))
     JOIN (rg
     WHERE ((g_sect_cd=0) OR (rg.parent_service_resource_cd=g_sect_cd))
      AND ms.subsection_cd=rg.child_service_resource_cd
      AND rg.resource_group_type_cd=g_sect_type_cd
      AND rg.root_service_resource_cd=0
      AND ((rg.active_ind+ 0)=1)
      AND ((rg.beg_effective_dt_tm+ 0) < cnvtdatetime(curdate,curtime3))
      AND ((rg.end_effective_dt_tm+ 0) > cnvtdatetime(curdate,curtime3)))
     JOIN (p
     WHERE p.person_id=ms.person_id)
    ORDER BY p.name_full_formatted, ms.study_id
    HEAD ms.study_id
     ncount = (ncount+ 1)
     IF (ncount > nsize)
      nsize = (nsize+ 100), nstat = alterlist(letter_info->study_info,nsize)
     ENDIF
     letter_info->study_info[ncount].study_id = ms.study_id, letter_info->study_info[ncount].order_id
      = ms.order_id, letter_info->study_info[ncount].letter_id = ms.letter_id,
     letter_info->study_info[ncount].template_id = 0, letter_info->study_info[ncount].
     order_physician_id = o.order_physician_id
     IF (o.parent_order_id > 0)
      letter_info->study_info[ncount].parent_order_id = o.parent_order_id
     ELSE
      letter_info->study_info[ncount].parent_order_id = o.order_id
     ENDIF
    WITH nocounter
   ;end select
   SET nstat = alterlist(letter_info->study_info,ncount)
 END ;Subroutine
 SUBROUTINE processparameters(ndummyvar)
   CALL echo("PROCESSPARAMETERS")
   DECLARE ntempstart = i4 WITH private, noconstant(0)
   DECLARE ntempend = i4 WITH private, noconstant(0)
   DECLARE ntemplen = i4 WITH private, noconstant(0)
   DECLARE stempstr = c40 WITH protect, noconstant(g_blank)
   DECLARE npos = i4 WITH protect, noconstant(0)
   DECLARE ntotremain = i4 WITH protect, noconstant(0)
   DECLARE noccurences = i4 WITH protect, noconstant(0)
   DECLARE dcode_list[100] = f8 WITH protect
   DECLARE luarmsgwritestat = i4 WITH protect, noconstant(0)
   DECLARE msg_default = i4 WITH protect, noconstant(0)
   DECLARE slogevent = vc WITH protect, noconstant("")
   DECLARE slogtext = vc WITH protect, noconstant("")
   EXECUTE msgrtl
   SET msg_default = uar_msgdefhandle()
   SET strings->temp_str = build(
    "R|FMC Mammo|FMC Mammo SS|7-JUL-2009|fmcflgmammo1|PATNOTIFY|fmcflgmammo1|30-JUN-2009|")
   SET ntempstart = 1
   SET ntempend = findstring("|",strings->temp_str)
   CALL echo(build("STRINGS -> TEMP_STR:",strings->temp_str))
   CALL echo(build("G_PRINT_IND:",g_print_ind))
   SET g_temp_int = movestring(strings->temp_str,1,g_print_ind,1,1)
   CALL echo(build("G_TEMP_INT:",g_temp_int))
   CALL echo(build("G_PRINT_IND:",g_print_ind))
   CALL echo(build("G_WANT_TO_PRINT:",g_want_to_print))
   CALL echo(build("G_WANT_TO_REPRINT:",g_want_to_reprint))
   IF ( NOT (g_print_ind IN (g_want_to_print, g_want_to_reprint)))
    SET g_status = g_status_fail
    SET g_subevent_ndx = (g_subevent_ndx+ 1)
    SET g_hstat = alter(reply->status_data.subeventstatus,g_subevent_ndx)
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationname = g_blank
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationstatus = g_status
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = g_print_ind
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->wrong_print_ind
   ENDIF
   CALL echo(build("Parameter 1::Print/Reprint Indicator <",g_print_ind,">"))
   SET g_sect_cd = 0
   SET stempstr = g_blank
   SET ntempstart = (ntempend+ 1)
   SET ntempend = findstring("|",strings->temp_str,ntempstart)
   IF (ntempend > 0
    AND ntempend > ntempstart)
    SET ntemplen = movestring(strings->temp_str,ntempstart,stempstr,1,(ntempend - ntempstart))
    IF (substring(1,1,stempstr) != "|"
     AND substring(1,1,stempstr) != g_blank)
     SET noccurences = 100
     CALL uar_get_code_list_by_meaning(221,"SECTION",1,noccurences,ntotremain,
      dcode_list)
     IF (ntotremain > 0)
      SET noccurences = (noccurences+ ntotremain)
      DECLARE dcode_sect_list[value(noccurences)] = f8 WITH protect
      CALL uar_get_code_list_by_meaning(221,"SECTION",1,noccurences,ntotremain,
       dcode_sect_list)
      FOR (npos = 1 TO noccurences)
        IF (uar_get_code_display(dcode_sect_list[npos])=stempstr)
         SET g_sect_cd = dcode_sect_list[npos]
         SET npos = (noccurences+ 1)
        ENDIF
      ENDFOR
     ELSE
      FOR (npos = 1 TO noccurences)
        IF (uar_get_code_display(dcode_list[npos])=stempstr)
         SET g_sect_cd = dcode_list[npos]
         SET npos = (noccurences+ 1)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("Parameter 2::Section <",stempstr,">, Code=",g_sect_cd))
   SET g_subsect_cd = 0
   SET stempstr = g_blank
   SET ntempstart = (ntempend+ 1)
   SET ntempend = findstring("|",strings->temp_str,ntempstart)
   IF (ntempend > 0
    AND ntempend > ntempstart)
    SET ntemplen = movestring(strings->temp_str,ntempstart,stempstr,1,(ntempend - ntempstart))
    IF (substring(1,1,stempstr) != "|"
     AND substring(1,1,stempstr) != g_blank)
     SET noccurences = 100
     CALL uar_get_code_list_by_meaning(221,"SUBSECTION",1,noccurences,ntotremain,
      dcode_list)
     IF (ntotremain > 0)
      SET noccurences = (noccurences+ ntotremain)
      DECLARE dcode_subsect_list[value(noccurences)] = f8 WITH protect
      CALL uar_get_code_list_by_meaning(221,"SUBSECTION",1,noccurences,ntotremain,
       dcode_subsect_list)
      FOR (npos = 1 TO noccurences)
        IF (uar_get_code_display(dcode_subsect_list[npos])=stempstr)
         SET g_subsect_cd = dcode_subsect_list[npos]
         SET npos = (noccurences+ 1)
        ENDIF
      ENDFOR
     ELSE
      FOR (npos = 1 TO noccurences)
        IF (uar_get_code_display(dcode_list[npos])=stempstr)
         SET g_subsect_cd = dcode_list[npos]
         SET npos = (noccurences+ 1)
        ENDIF
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   CALL echo(build("Parameter 3::Subsection <",stempstr,">, Code=",g_subsect_cd))
   SET dates->reprint_date = null
   SET ntempstart = (ntempend+ 1)
   SET ntempend = findstring("|",strings->temp_str,ntempstart)
   IF (ntempend > 0
    AND ntempend > ntempstart)
    SET ntemplen = movestring(strings->temp_str,ntempstart,stempstr,1,(ntempend - ntempstart))
    SET dates->reprint_date = cnvtdatetime(build(stempstr," 00:00:00"))
    SET dates->reprint_end_date = cnvtdatetime(build(stempstr," 23:59:59"))
   ENDIF
   IF ((dates->reprint_date=0)
    AND g_print_ind=g_want_to_reprint)
    SET g_status = g_status_fail
    SET g_subevent_ndx = (g_subevent_ndx+ 1)
    SET g_hstat = alter(reply->status_data.subeventstatus,g_subevent_ndx)
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationname = g_blank
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationstatus = g_status
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = stempstr
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->
    missing_print_date
   ENDIF
   CALL echo(build("Parameter 4::Reprint Date <",format(dates->reprint_date,"@SHORTDATE4YR;;D"),">"))
   SET ntempstart = (ntempend+ 1)
   SET ntempend = findstring("|",strings->temp_str,ntempstart)
   SET strings->summary_printer = g_blank
   IF (ntempend > 0
    AND ntempend > ntempstart)
    SET strings->summary_printer = substring(ntempstart,(ntempend - ntempstart),strings->temp_str)
    IF (((substring(1,1,strings->summary_printer)="|") OR (substring(1,1,strings->summary_printer)=
    g_blank)) )
     SET strings->summary_printer = g_blank
    ELSEIF (checkqueue(strings->summary_printer)=0)
     SET g_subevent_ndx = (g_subevent_ndx+ 1)
     SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = strings->
     summary_printer
     SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->
     invalid_sum_print
     SET slogevent = "rad_rpt_custom_mammo"
     SET slogtext = build("Invalid summary printer provided: ",strings->summary_printer)
     SET luarmsgwritestat = uar_msgwrite(msg_default,0,nullterm(slogevent),0,nullterm(slogtext))
     SET strings->summary_printer = g_blank
    ENDIF
   ENDIF
   CALL echo(build("Parameter 5::Summary Printer <",strings->summary_printer,">"))
   SET g_letter_type = g_blank
   SET ntempstart = (ntempend+ 1)
   SET ntempend = findstring("|",strings->temp_str,ntempstart)
   IF (ntempend > 0
    AND ntempend > ntempstart)
    SET ntemplen = movestring(strings->temp_str,ntempstart,g_letter_type,1,(ntempend - ntempstart))
   ENDIF
   IF ( NOT (g_letter_type IN (g_patnotify_cdm, g_patreminder_cdm, g_patwarning_cdm,
   g_physreminder_cdm, g_physwarning_cdm,
   g_physsurvey_cdm)))
    SET g_status = g_status_fail
    SET g_subevent_ndx = (g_subevent_ndx+ 1)
    SET g_hstat = alter(reply->status_data.subeventstatus,g_subevent_ndx)
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationname = g_blank
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationstatus = g_status
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = g_letter_type
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->unknown_letter
   ENDIF
   CALL echo(build("Parameter 6::Letter Type <",g_letter_type,">"))
   SET strings->printer = g_blank
   SET ntempstart = (ntempend+ 1)
   SET ntempend = findstring("|",strings->temp_str,ntempstart)
   IF (ntempend > 0
    AND ntempend > ntempstart)
    SET strings->printer = substring(ntempstart,(ntempend - ntempstart),strings->temp_str)
   ENDIF
   IF (checkqueue(strings->printer)=0)
    SET g_status = g_status_fail
    SET g_subevent_ndx = (g_subevent_ndx+ 1)
    SET g_hstat = alter(reply->status_data.subeventstatus,g_subevent_ndx)
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationname = g_blank
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationstatus = g_status
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = strings->printer
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->missing_printer
    IF ((((strings->printer=g_blank)) OR (((substring(1,1,strings->printer)="|") OR (substring(1,1,
     strings->printer)=g_blank)) )) )
     SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->missing_printer
    ELSE
     SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->invalid_print
    ENDIF
   ENDIF
   CALL echo(build("Parameter 7::Letter Printer <",strings->printer,">"))
   SET ntempstart = (ntempend+ 1)
   SET ntempend = findstring("|",strings->temp_str,ntempstart)
   IF (ntempend > 0
    AND ntempend > ntempstart)
    SET stempstr = ""
    SET ntemplen = movestring(strings->temp_str,ntempstart,stempstr,1,(ntempend - ntempstart))
    IF (size(trim(stempstr,3)) > 1)
     SET dates->print_from_date = cnvtdatetime(stempstr)
     SET g_print_from_date_ind = 1
    ELSE
     SET g_print_from_date_ind = 0
     SET dates->print_from_date = null
    ENDIF
   ELSE
    SET g_print_from_date_ind = 0
    SET dates->print_from_date = null
   ENDIF
   IF (g_print_from_date_ind=1
    AND (dates->print_from_date=0))
    SET g_status = g_status_fail
    SET g_subevent_ndx = (g_subevent_ndx+ 1)
    SET g_hstat = alter(reply->status_data.subeventstatus,g_subevent_ndx)
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationname = g_blank
    SET reply->status_data.subeventstatus[g_subevent_ndx].operationstatus = g_status
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectname = stempstr
    SET reply->status_data.subeventstatus[g_subevent_ndx].targetobjectvalue = i18n->
    print_from_date_incorrect
   ENDIF
   CALL echo(build("Parameter 8::Letter Start From Date <",format(dates->print_from_date,
      "@SHORTDATE4YR;;D"),">"))
 END ;Subroutine
 SUBROUTINE doi18nonstrings(ndummyvar)
   CALL echo("DOI18NONSTRINGS")
   SET i18n->wrong_print_ind = uar_i18ngetmessage(g_i18nhandle,"wrong_print_ind",
    "Print/Reprint parameter must be either P(for print) or R(for reprint)")
   SET i18n->missing_template = uar_i18ngetmessage(g_i18nhandle,"missing_template","Missing Template"
    )
   SET i18n->missing_printer = uar_i18ngetmessage(g_i18nhandle,"missing_printer",
    "Queue name for printer not specified")
   SET i18n->unknown_letter = uar_i18ngetmessage(g_i18nhandle,"unknown_letter",
    "Unknown letter type specified")
   SET i18n->missing_print_date = uar_i18ngetmessage(g_i18nhandle,"missing_print_date",
    "Reprint option requires original print date in format DD-MON-YYYY")
   SET i18n->print_from_date_incorrect = uar_i18ngetmessage(g_i18nhandle,"print_from_date_incorrect",
    "Print from date must be in format DD-MON-YYYY")
   SET i18n->conversion_error = uar_i18ngetmessage(g_i18nhandle,"conversion_error",
    "Error converting rtf file to postscript")
   SET i18n->mr = uar_i18ngetmessage(g_i18nhandle,"mr","Mr.")
   SET i18n->ms = uar_i18ngetmessage(g_i18nhandle,"ms","Ms.")
   SET i18n->month = uar_i18ngetmessage(g_i18nhandle,"month","month")
   SET i18n->months = uar_i18ngetmessage(g_i18nhandle,"months","months")
   SET i18n->year = uar_i18ngetmessage(g_i18nhandle,"year","year")
   SET i18n->years = uar_i18ngetmessage(g_i18nhandle,"years","years")
   SET i18n->rec_follow_up = uar_i18ngetmessage(g_i18nhandle,"rec_follow_up","Recommended Follow-up:"
    )
   SET i18n->patient = uar_i18ngetmessage(g_i18nhandle,"patient","Patient")
   SET i18n->dob = uar_i18ngetmessage(g_i18nhandle,"dob","DOB")
   SET i18n->rec_dt = uar_i18ngetmessage(g_i18nhandle,"rec_dt","Recall Date")
   SET i18n->order_id = uar_i18ngetmessage(g_i18nhandle,"order_id","Order_id:")
   SET i18n->recommend = uar_i18ngetmessage(g_i18nhandle,"recommend","Recommendation")
   SET i18n->insert_failed = uar_i18ngetmessage(g_i18nhandle,"insert_failed",
    "Insert Operation Failed")
   SET i18n->study_id = uar_i18ngetmessage(g_i18nhandle,"study_id","Study_id:")
   SET i18n->invalid_sum_print = uar_i18ngetmessage(g_i18nhandle,"invalid_sum_print",
    "Queue name for summary printer not valid")
   SET i18n->invalid_print = uar_i18ngetmessage(g_i18nhandle,"invalid_print",
    "Queue name for printer not valid")
 END ;Subroutine
 SUBROUTINE getnotifytemplatenameandid(dstudyid,slettername,dtemplateid)
  CALL echo("GETNOTIFYTEMPLATENAMEANDID")
  SELECT INTO "nl:"
   FROM mammo_study ms,
    mammo_letter_detail ml,
    wp_template wt
   PLAN (ms
    WHERE ms.study_id=dstudyid)
    JOIN (ml
    WHERE ml.letter_id=ms.letter_id)
    JOIN (wt
    WHERE wt.template_id=ml.template_id)
   DETAIL
    slettername = wt.short_desc, dtemplateid = wt.template_id
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getwptemplateid(stemplatename,dtemplateid)
   CALL echo("GETWPTEMPLATEID")
   DECLARE dtemplatetypecd = f8 WITH protect, noconstant(0.0)
   DECLARE dactivitytypecd = f8 WITH protect, noconstant(0.0)
   SET dtemplateid = 0.0
   SET dtemplatetypecd = uar_get_code_by("MEANING",1303,"LETTER")
   SET dactivitytypecd = uar_get_code_by("MEANING",106,"RADIOLOGY")
   SELECT INTO "nl:"
    FROM wp_template wt
    WHERE wt.template_type_cd=dtemplatetypecd
     AND wt.short_desc=stemplatename
     AND wt.activity_type_cd=dactivitytypecd
     AND wt.active_ind=1
    DETAIL
     dtemplateid = wt.template_id
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL echorecord(reply)
END GO
