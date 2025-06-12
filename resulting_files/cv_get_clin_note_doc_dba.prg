CREATE PROGRAM cv_get_clin_note_doc:dba
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(sysdate),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt += 1
 ENDIF
 SUBROUTINE (cv_log_createhandle(dummy=i2) =null)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 SUBROUTINE (cv_log_current_default(dummy=i2) =null)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 SUBROUTINE (cv_echo(string=vc) =null)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_message(log_message_param=vc) =null)
   SET cv_log_err_num += 1
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_message_status(object_name_param=vc,operation_status_param=c1,
  operation_name_param=vc,target_object_value_param=vc) =null)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event += 1
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event += 1
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_check_err(opname=vc,opstatus=c1,targetname=vc) =null)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
 IF (validate(reply,"notdefined") != "notdefined")
  CALL cv_log_message("reply is already defined!")
 ELSE
  RECORD reply(
    1 text = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(request,"notdefined") != "notdefined")
  CALL cv_log_message("request is already defined!")
 ELSE
  CALL cv_log_message("Record request not found")
  SET failure = "T"
  SET reply->status_data.subeventstatus[1].operationname = "Record Request not found"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  GO TO exit_script
 ENDIF
 IF (validate(cv_cl_internal,"notdefined") != "notdefined")
  CALL cv_log_message("cv_cl_internal is already defined!")
 ELSE
  RECORD cv_cl_internal(
    1 person_id = f8
    1 encntr_id = f8
    1 events[*]
      2 event_cd = f8
      2 result_val = vc
      2 mnemonic = vc
  )
 ENDIF
 IF (validate(t_record,"notdefined") != "notdefined")
  CALL cv_log_message("t_record is already defined!")
 ELSE
  RECORD t_record(
    1 person[*]
      2 person_id = f8
    1 visit[*]
      2 encntr_id = f8
      2 order_id = f8
      2 study_id = f8
      2 order_physician_id = f8
      2 encntr_facility_cd = f8
      2 discipline_type_cd = f8
      2 catalog_cd = f8
      2 dtstudydttm = dq8
    1 rtf_report = vc
    1 template_qual_cnt = i4
    1 template_qual[*]
      2 template_name = vc
      2 template = vc
      2 parent_template_index = i4
      2 parent_tag_index = i4
      2 tag_qual_cnt = i4
      2 tag_qual[*]
        3 tag = vc
        3 tag_start = i4
        3 tag_end = i4
        3 tag_type = i4
        3 tag_modifier1 = vc
        3 tag_modifier2 = vc
        3 tag_modifier3 = vc
        3 tag1_fld = vc
        3 tag1_tbl = vc
        3 format_function = vc
        3 primary_key = vc
        3 where_field = vc
        3 where_codeset = vc
        3 where_cdf = vc
        3 value = vc
  )
 ENDIF
 IF (validate(t_radiology_record,"notdefined") != "notdefined")
  CALL cv_log_message("t_radiology_record is already defined!")
 ELSE
  RECORD t_radiology_record(
    1 radiology_exam_cd = f8
    1 radiologist_id = f8
    1 assessment_id = f8
    1 recommendation_id = f8
    1 assess_pat_lvl_id = f8
    1 mgmt_pat_lvl_id = f8
    1 overall_assess_pat_lvl_id = f8
    1 assess_left_breast_id = f8
    1 mgmt_left_breast_id = f8
    1 overall_assess_left_breast_id = f8
    1 assess_right_breast_id = f8
    1 mgmt_right_breast_id = f8
    1 overall_assess_right_breast_id = f8
    1 exam_facility_cd = f8
    1 exam_dept_cd = f8
    1 seq_exam_id = f8
  )
 ENDIF
 IF (validate(bufparse,"notdefined") != "notdefined")
  CALL cv_log_message("bufparse is already defined!")
 ELSE
  RECORD bufparse(
    1 item1[*]
      2 item2[*]
        3 text = vc
  )
 ENDIF
 DECLARE updateassessmentmgmttagvalues(null) = null
 SET tag_semicolon = ";"
 SET tag_equal = "="
 SET tag_start = "_<"
 SET tag_end = ">"
 SET blankstring = " "
 SET tag_template = "TEMPLATE"
 SET tag_eventcode = "EVENTCODE"
 DECLARE tag_value = c5 WITH public, constant("VALUE")
 DECLARE primarykeyfield = c11 WITH public, constant("PRIMARY_KEY")
 DECLARE tagtype4value = i2 WITH public, constant(4)
 DECLARE tagtypeall = i2 WITH public, constant(0)
 DECLARE g_section_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_subsection_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_dept_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_bldg_cd = f8 WITH public, noconstant(0.0)
 DECLARE g_fac_cd = f8 WITH public, noconstant(0.0)
 DECLARE alias = c5 WITH public, constant("ALIAS")
 SET eventcodeset = 72
 SET tagnamecodeset = 26633
 SET formatreplace = "_REPVAL_"
 SET cvex_fn_fieldname = "FIELD_NAME"
 SET cvex_fn_formatfunction = "FORMAT_FUNCTION"
 SET cvex_fn_primarykey = "PRIMARY_KEY"
 SET cvex_fn_wherecvis = "WHERE_CV_IS"
 SET cvex_fn_where_activeind = "WHERE_ACTIVE_IND"
 SET cvex_fn_where_effective_greater = "WHERE_EFFECTIVE_GREATER"
 SET cvex_fn_where_effective_less = "WHERE_EFFECTIVE_LESS"
 SET tagtype1tblfld = 1
 SET tagtype2template = 2
 SET tagtype3eventcode = 3
 SET dmprefs_domain = "CVNET"
 SET dmprefs_section = "CORRESPONDENCE_LETTERS"
 SET dmprefs_name = "MAX_TEMPLATES"
 SET g_maxtemplates = 0
 SET g_gettagtype = - (1)
 SET g_where_cv_is = fillstring(256," ")
 SET failure = "F"
 DECLARE nv_index = i4 WITH public, noconstant[0]
 DECLARE nv_size = i4 WITH public, noconstant[0]
 DECLARE use_wp_template_ind = i2 WITH public, noconstant[0]
 DECLARE order_type_cd = f8 WITH public, noconstant[0.0]
 DECLARE strtextandtag = vc WITH public, noconstant[" "]
 DECLARE strtagtoreplace = vc WITH public, noconstant[" "]
 DECLARE strtagvalue = vc WITH public, noconstant[" "]
 DECLARE strreplaced = vc WITH public, noconstant[" "]
 DECLARE h = i2 WITH public, noconstant(0)
 DECLARE shistory = vc WITH public, noconstant("")
 DECLARE renew_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",6003,"RENEW"))
 DECLARE modify_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE activate_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",6003,"ACTIVATE"))
 DECLARE mdsubsectioncd = f8 WITH protect, noconstant(0.0)
 DECLARE mddepartmentcd = f8 WITH protect, noconstant(0.0)
 DECLARE mdsectioncd = f8 WITH protect, noconstant(0.0)
 DECLARE mdserviceresourcecd = f8 WITH protect, noconstant(0.0)
 DECLARE mlhomeaddrflag = i4 WITH protect, noconstant(0)
 DECLARE mlmailaddrflag = i4 WITH protect, noconstant(0)
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET shistory = uar_i18ngetmessage(i18nhandle,"history","HISTORY")
 SET cv_log_my_files = 1
 CALL cv_log_message(build("script_name:",request->script_name))
 EXECUTE cv_log_struct  WITH replace(request,request)
 SET t_radiology_record->radiology_exam_cd = uar_get_code_by("MEANING",6000,"RADIOLOGY")
 SET order_type_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET stat = alterlist(t_record->person,1)
 SET t_record->person[1].person_id = validate(request->person[1].person_id,0)
 SET stat = alterlist(t_record->visit,1)
 IF (size(request->visit,5) > 0)
  SET t_record->visit[1].encntr_id = validate(request->visit[1].encntr_id,0)
  SET t_record->visit[1].order_id = validate(request->visit[1].order_id,0)
  SET t_record->visit[1].study_id = validate(request->visit[1].study_id,0)
 ENDIF
 IF ((t_record->person[1].person_id=0)
  AND (t_record->visit[1].encntr_id=0)
  AND (t_record->visit[1].order_id=0)
  AND (t_record->visit[1].study_id=0))
  SET cv_log_level = cv_log_error
  CALL cv_log_current_default(0)
  CALL cv_log_message("All parameter ids, patient_id, encntr_id, order_id and study_id are 0")
  SET failure = "T"
  GO TO exit_script
 ENDIF
 DECLARE getpacketserviceresinfo(null) = i4
 DECLARE getpacketexamroomhierarchy(null) = i4
 DECLARE geterhierarchyforolw(null) = i4
 IF ( NOT (validate(temp_serv_res,0)))
  RECORD temp_serv_res(
    1 nbr_of_examrooms = i4
    1 exam_rooms[*]
      2 exam_room_cd = f8
      2 lsequence = i4
      2 subsection_cd = f8
      2 active_ind = i4
      2 rel_active_ind = i4
    1 nbr_of_subsections = i4
    1 subsections[*]
      2 subsection_cd = f8
      2 lsequence = i4
      2 section_cd = f8
      2 active_ind = i4
    1 nbr_of_sections = i4
    1 sections[*]
      2 active_ind = i4
      2 section_cd = f8
      2 lsequence = i4
      2 active_ind = i2
      2 department_cd = f8
      2 transcript_que_cd = f8
      2 sect_temp_multi_flag = i2
      2 nbr_exam_on_req = i4
      2 prelim_ind = i2
      2 expedite_nursing_ind = i2
      2 nbr_of_printers = i4
      2 printers[*]
        3 output_dest_cd = f8
        3 usage_type_cd = f8
        3 name = vc
        3 printer_que = vc
        3 script = vc
        3 label_x_pos = i4
        3 label_y_pos = i4
        3 printer_type_cd = f8
        3 printer_dio = vc
        3 print_point_cd = f8
    1 nbr_of_departments = i4
    1 departments[*]
      2 department_cd = f8
      2 lsequence = i4
      2 active_ind = i2
      2 institution_cd = f8
      2 linstitution_seq = i4
  ) WITH public
 ENDIF
 IF ( NOT (validate(exam_room_h,0)))
  RECORD exam_room_h(
    1 nbr_of_examrooms = i4
    1 exam_rooms[*]
      2 exam_room_cd = f8
      2 lexamroom_seq = i4
      2 subsection_cd = f8
      2 lsubsection_seq = i4
      2 active_ind = i4
      2 section_cd = f8
      2 lsection_seq = i4
      2 department_cd = f8
      2 ldepartment_seq = i4
      2 institution_cd = f8
      2 linstitution_seq = i4
  ) WITH public
 ENDIF
 IF ( NOT (validate(temp_exam_rooms,0)))
  RECORD temp_exam_rooms(
    1 qual_size = i4
    1 qual[*]
      2 exam_room_cd = f8
  ) WITH public
  SET temp_exam_rooms->qual_size = 0
 ENDIF
 SUBROUTINE getpacketexamroomhierarchy(null)
   DECLARE lstat = i4 WITH protect, noconstant(0)
   DECLARE lndx = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE lexrmndx = i4 WITH protect, noconstant(0)
   DECLARE lsubsectndx = i4 WITH protect, noconstant(0)
   DECLARE lsectndx = i4 WITH protect, noconstant(0)
   DECLARE ldeptndx = i4 WITH protect, noconstant(0)
   IF ( NOT (size(temp_serv_res->exam_rooms,5) > 0))
    SET stat = getpacketserviceresinfo(null)
    IF (stat=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET lstat = alterlist(exam_room_h->exam_rooms,temp_serv_res->nbr_of_examrooms)
   SET lexrmndx = locateval(i,1,temp_serv_res->nbr_of_examrooms,1,temp_serv_res->exam_rooms[i].
    active_ind,
    1,temp_serv_res->exam_rooms[i].rel_active_ind)
   WHILE (lexrmndx != 0)
     SET lndx += 1
     SET lsectndx = 0
     SET ldeptndx = 0
     SET exam_room_h->nbr_of_examrooms = lndx
     SET exam_room_h->exam_rooms[lndx].exam_room_cd = temp_serv_res->exam_rooms[lexrmndx].
     exam_room_cd
     SET exam_room_h->exam_rooms[lndx].subsection_cd = temp_serv_res->exam_rooms[lexrmndx].
     subsection_cd
     SET exam_room_h->exam_rooms[lndx].active_ind = temp_serv_res->exam_rooms[lexrmndx].active_ind
     SET exam_room_h->exam_rooms[lndx].lexamroom_seq = temp_serv_res->exam_rooms[lexrmndx].lsequence
     SET lsubsectndx = locateval(i,1,temp_serv_res->nbr_of_subsections,exam_room_h->exam_rooms[lndx].
      subsection_cd,temp_serv_res->subsections[i].subsection_cd,
      1,temp_serv_res->subsections[i].active_ind)
     IF (lsubsectndx != 0)
      SET exam_room_h->exam_rooms[lndx].lsubsection_seq = temp_serv_res->subsections[lsubsectndx].
      lsequence
      SET exam_room_h->exam_rooms[lndx].section_cd = temp_serv_res->subsections[lsubsectndx].
      section_cd
      SET lsectndx = locateval(i,1,temp_serv_res->nbr_of_sections,exam_room_h->exam_rooms[lndx].
       section_cd,temp_serv_res->sections[i].section_cd,
       1,temp_serv_res->sections[i].active_ind)
     ENDIF
     IF (lsectndx != 0)
      SET exam_room_h->exam_rooms[lndx].lsection_seq = temp_serv_res->sections[lsectndx].lsequence
      SET exam_room_h->exam_rooms[lndx].department_cd = temp_serv_res->sections[lsectndx].
      department_cd
      SET ldeptndx = locateval(i,1,temp_serv_res->nbr_of_departments,exam_room_h->exam_rooms[lndx].
       department_cd,temp_serv_res->departments[i].department_cd,
       1,temp_serv_res->departments[i].active_ind)
     ENDIF
     IF (ldeptndx != 0)
      SET exam_room_h->exam_rooms[lndx].ldepartment_seq = temp_serv_res->departments[ldeptndx].
      lsequence
      SET exam_room_h->exam_rooms[lndx].institution_cd = temp_serv_res->departments[ldeptndx].
      institution_cd
      SET exam_room_h->exam_rooms[lndx].linstitution_seq = temp_serv_res->departments[ldeptndx].
      linstitution_seq
     ENDIF
     SET lexrmndx = locateval(i,(lexrmndx+ 1),temp_serv_res->nbr_of_examrooms,1,temp_serv_res->
      exam_rooms[i].active_ind,
      1,temp_serv_res->exam_rooms[i].rel_active_ind)
   ENDWHILE
   SET lstat = alterlist(exam_room_h->exam_rooms,lndx)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getpacketserviceresinfo(null)
   DECLARE happ = i4 WITH noconstant(0), private
   DECLARE htask = i4 WITH noconstant(0), private
   DECLARE hstep = i4 WITH noconstant(0), private
   DECLARE hreq = i4 WITH noconstant(0), private
   DECLARE hitem = i4 WITH noconstant(0), private
   DECLARE hitem2 = i4 WITH noconstant(0), private
   DECLARE hrep = i4 WITH noconstant(0), private
   SET crmstat = uar_crmbeginapp(490000,happ)
   IF (crmstat > 0)
    CALL echo("Failed to begin app")
    RETURN(0)
   ENDIF
   SET stat = uar_crmbegintask(happ,490000,htask)
   IF (((stat != 0) OR (htask=0)) )
    CALL echo("Bad BeginTask")
    RETURN(0)
   ENDIF
   SET stat = uar_crmbeginreq(htask,"",490000,hstep)
   IF (((stat != 0) OR (hstep=0)) )
    CALL echo("Bad BeginReq")
    RETURN(0)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq=0)
    RETURN(0)
   ENDIF
   SET stat = uar_crmperform(hstep)
   IF (stat != 0)
    RETURN(0)
   ENDIF
   SET hrep = uar_crmgetreply(hstep)
   IF (hrep=0)
    RETURN(0)
   ENDIF
   SET temp_serv_res->nbr_of_examrooms = uar_srvgetitemcount(hrep,"exam_rooms")
   SET stat = alterlist(temp_serv_res->exam_rooms,temp_serv_res->nbr_of_examrooms)
   FOR (i = 1 TO temp_serv_res->nbr_of_examrooms)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"exam_rooms",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     SET temp_serv_res->exam_rooms[i].exam_room_cd = uar_srvgetdouble(hresult,"exam_room_cd")
     SET temp_serv_res->exam_rooms[i].active_ind = uar_srvgetshort(hresult,"active_ind")
     SET temp_serv_res->exam_rooms[i].subsection_cd = uar_srvgetdouble(hresult,"subsection_cd")
     SET temp_serv_res->exam_rooms[i].rel_active_ind = uar_srvgetshort(hresult,"rel_active_ind")
     SET temp_serv_res->exam_rooms[i].lsequence = uar_srvgetlong(hresult,"lSequence")
   ENDFOR
   SET temp_serv_res->nbr_of_subsections = uar_srvgetitemcount(hrep,"subsections")
   SET stat = alterlist(temp_serv_res->subsections,temp_serv_res->nbr_of_subsections)
   FOR (i = 1 TO temp_serv_res->nbr_of_subsections)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"subsections",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     SET temp_serv_res->subsections[i].subsection_cd = uar_srvgetdouble(hresult,"subsection_cd")
     SET temp_serv_res->subsections[i].lsequence = uar_srvgetlong(hresult,"lSequence")
     SET temp_serv_res->subsections[i].active_ind = uar_srvgetshort(hresult,"active_ind")
     SET temp_serv_res->subsections[i].section_cd = uar_srvgetdouble(hresult,"section_cd")
   ENDFOR
   SET temp_serv_res->nbr_of_sections = uar_srvgetitemcount(hrep,"sections")
   SET stat = alterlist(temp_serv_res->sections,temp_serv_res->nbr_of_sections)
   FOR (i = 1 TO temp_serv_res->nbr_of_sections)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"sections",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     SET temp_serv_res->sections[i].section_cd = uar_srvgetdouble(hresult,"section_cd")
     SET temp_serv_res->sections[i].lsequence = uar_srvgetlong(hresult,"lSequence")
     SET temp_serv_res->sections[i].active_ind = uar_srvgetshort(hresult,"active_ind")
     SET temp_serv_res->sections[i].department_cd = uar_srvgetdouble(hresult,"department_cd")
     SET temp_serv_res->sections[i].nbr_exam_on_req = uar_srvgetlong(hresult,"nbr_exam_on_req")
     SET temp_serv_res->sections[i].nbr_of_printers = uar_srvgetitemcount(hresult,"printers")
     SET stat = alterlist(temp_serv_res->sections[i].printers,temp_serv_res->sections[i].
      nbr_of_printers)
     FOR (j = 1 TO temp_serv_res->sections[i].nbr_of_printers)
       SET pidx = (j - 1)
       SET hlist = uar_srvgetitem(hresult,"printers",pidx)
       SET temp_serv_res->sections[i].printers[j].output_dest_cd = uar_srvgetdouble(hlist,
        "output_dest_cd")
       SET temp_serv_res->sections[i].printers[j].usage_type_cd = uar_srvgetdouble(hlist,
        "usage_type_cd")
       SET temp_serv_res->sections[i].printers[j].name = uar_srvgetstringptr(hlist,"name")
       SET temp_serv_res->sections[i].printers[j].printer_que = uar_srvgetstringptr(hlist,
        "printer_que")
       SET temp_serv_res->sections[i].printers[j].script = uar_srvgetstringptr(hlist,"script")
       SET temp_serv_res->sections[i].printers[j].label_x_pos = uar_srvgetlong(hlist,"label_x_pos")
       SET temp_serv_res->sections[i].printers[j].label_y_pos = uar_srvgetlong(hlist,"label_y_pos")
       SET temp_serv_res->sections[i].printers[j].printer_type_cd = uar_srvgetdouble(hlist,
        "printer_type_cd")
       SET temp_serv_res->sections[i].printers[j].print_point_cd = uar_srvgetdouble(hlist,
        "print_point_cd")
     ENDFOR
   ENDFOR
   SET temp_serv_res->nbr_of_departments = uar_srvgetitemcount(hrep,"departments")
   CALL echo(build("nbr_of_departments; ",temp_serv_res->nbr_of_departments))
   SET stat = alterlist(temp_serv_res->departments,temp_serv_res->nbr_of_departments)
   FOR (i = 1 TO temp_serv_res->nbr_of_departments)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"departments",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     SET temp_serv_res->departments[i].department_cd = uar_srvgetdouble(hresult,"department_cd")
     SET temp_serv_res->departments[i].lsequence = uar_srvgetlong(hresult,"lSequence")
     SET temp_serv_res->departments[i].active_ind = uar_srvgetshort(hresult,"active_ind")
     SET temp_serv_res->departments[i].institution_cd = uar_srvgetdouble(hresult,"institution_cd")
     SET temp_serv_res->departments[i].linstitution_seq = uar_srvgetlong(hresult,"lInstitution_seq")
   ENDFOR
   IF (hstep > 0)
    CALL uar_crmendreq(hstep)
   ENDIF
   IF (htask > 0)
    CALL uar_crmendtask(htask)
   ENDIF
   IF (mod(cnvtint(substring(4,4,curprcname)),1024)=54)
    CALL uar_crmendapp(happ)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getinstforlib(lib_trk_cd=f8) =f8)
   DECLARE happ = i4 WITH noconstant(0), private
   DECLARE htask = i4 WITH noconstant(0), private
   DECLARE hstep = i4 WITH noconstant(0), private
   DECLARE hreq = i4 WITH noconstant(0), private
   DECLARE hitem = i4 WITH noconstant(0), private
   DECLARE hitem2 = i4 WITH noconstant(0), private
   DECLARE hrep = i4 WITH noconstant(0), private
   DECLARE lib_grp_cd = f8
   SET crmstat = uar_crmbeginapp(490000,happ)
   IF (crmstat > 0)
    CALL echo("Failed to begin app")
    RETURN(0)
   ENDIF
   SET stat = uar_crmbegintask(happ,490000,htask)
   IF (((stat != 0) OR (htask=0)) )
    CALL echo("Bad BeginTask")
    RETURN(0)
   ENDIF
   SET stat = uar_crmbeginreq(htask,"",490000,hstep)
   IF (((stat != 0) OR (hstep=0)) )
    CALL echo("Bad BeginReq")
    RETURN(0)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq=0)
    RETURN(0)
   ENDIF
   SET stat = uar_crmperform(hstep)
   IF (stat != 0)
    RETURN(0)
   ENDIF
   SET hrep = uar_crmgetreply(hstep)
   IF (hrep=0)
    RETURN(0)
   ENDIF
   SET lib_trk_cnt = uar_srvgetitemcount(hrep,"lib_trk_points")
   FOR (i = 1 TO lib_trk_cnt)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"lib_trk_points",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     IF (uar_srvgetdouble(hresult,"service_resource_cd")=lib_trk_cd)
      SET lib_grp_cd = uar_srvgetdouble(hresult,"lib_grp_cd")
      SET i = lib_trk_cnt
     ENDIF
   ENDFOR
   SET lib_grp_cnt = uar_srvgetitemcount(hrep,"lib_groups")
   FOR (i = 1 TO lib_grp_cnt)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"lib_groups",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     IF (uar_srvgetdouble(hresult,"lib_grp_cd")=lib_grp_cd)
      SET inst_cd = uar_srvgetdouble(hresult,"institution_cd")
      SET i = lib_grp_cnt
     ENDIF
   ENDFOR
   IF (hstep > 0)
    CALL uar_crmendreq(hstep)
   ENDIF
   IF (htask > 0)
    CALL uar_crmendtask(htask)
   ENDIF
   IF (mod(cnvtint(substring(4,4,curprcname)),1024)=54)
    CALL uar_crmendapp(happ)
   ENDIF
   RETURN(inst_cd)
 END ;Subroutine
 SUBROUTINE (getdeptandsectforexrm(exam_room_cd=f8(val),dept_cd=f8(ref),section_cd=f8(ref)) =i2)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE lndx = i4 WITH protect, noconstant(0)
   IF (size(exam_room_h->exam_rooms,5)=0)
    IF (getpacketexamroomhierarchy("LOAD")=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET lndx = locateval(i,1,exam_room_h->nbr_of_examrooms,exam_room_cd,exam_room_h->exam_rooms[i].
    exam_room_cd)
   IF (lndx != 0)
    SET section_cd = exam_room_h->exam_rooms[lndx].section_cd
    SET dept_cd = exam_room_h->exam_rooms[lndx].department_cd
    RETURN(1)
   ENDIF
   SET section_cd = 0.0
   SET dept_cd = 0.0
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (getexamroominfo(exam_room_cd=f8(val),subsection_cd=f8(ref),section_cd=f8(ref),
  department_cd=f8(ref),institution_cd=f8(ref)) =i4)
   IF (size(exam_room_h->exam_rooms,5)=0)
    SET stat = getpacketexamroomhierarchy("LOAD")
    IF (stat=0)
     RETURN(0)
    ENDIF
   ENDIF
   FOR (i = 1 TO exam_room_h->nbr_of_examrooms)
     IF ((exam_room_h->exam_rooms[i].exam_room_cd=exam_room_cd))
      SET subsection_cd = exam_room_h->exam_rooms[i].subsection_cd
      SET section_cd = exam_room_h->exam_rooms[i].section_cd
      SET department_cd = exam_room_h->exam_rooms[i].department_cd
      SET institution_cd = exam_room_h->exam_rooms[i].institution_cd
      RETURN(1)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE geterhierarchyforolw(null)
   IF ( NOT (size(temp_serv_res->exam_rooms,5) > 0))
    SET stat = getserviceresinfo(2)
    IF (stat=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET count = 0
   SELECT INTO "nl:"
    rel_ind = temp_serv_res->exam_rooms[d.seq].rel_active_ind, exam_room = temp_serv_res->exam_rooms[
    d.seq].exam_room_cd
    FROM (dummyt d  WITH seq = value(size(temp_serv_res->exam_rooms,5)))
    ORDER BY exam_room, rel_ind DESC
    HEAD exam_room
     count += 1, stat = alterlist(exam_room_h->exam_rooms,count), exam_room_h->nbr_of_examrooms =
     count,
     exam_room_h->exam_rooms[count].exam_room_cd = temp_serv_res->exam_rooms[d.seq].exam_room_cd,
     exam_room_h->exam_rooms[count].subsection_cd = temp_serv_res->exam_rooms[d.seq].subsection_cd,
     exam_room_h->exam_rooms[count].active_ind = temp_serv_res->exam_rooms[d.seq].active_ind
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (getserviceresinfo(active_ind=i4) =i4)
   DECLARE iactive_ind = i4 WITH protect
   SET iactive_ind = active_ind
   DECLARE happ = i4 WITH noconstant(0), private
   DECLARE htask = i4 WITH noconstant(0), private
   DECLARE hstep = i4 WITH noconstant(0), private
   DECLARE hreq = i4 WITH noconstant(0), private
   DECLARE hitem = i4 WITH noconstant(0), private
   DECLARE hitem2 = i4 WITH noconstant(0), private
   DECLARE hrep = i4 WITH noconstant(0), private
   SET crmstat = uar_crmbeginapp(490000,happ)
   IF (crmstat > 0)
    CALL echo("Failed to begin app")
    RETURN(0)
   ENDIF
   SET stat = uar_crmbegintask(happ,490000,htask)
   IF (((stat != 0) OR (htask=0)) )
    CALL echo("Bad BeginTask")
    RETURN(0)
   ENDIF
   SET stat = uar_crmbeginreq(htask,"",490000,hstep)
   IF (((stat != 0) OR (hstep=0)) )
    CALL echo("Bad BeginReq")
    RETURN(0)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq=0)
    RETURN(0)
   ENDIF
   SET stat = uar_crmperform(hstep)
   IF (stat != 0)
    RETURN(0)
   ENDIF
   SET hrep = uar_crmgetreply(hstep)
   IF (hrep=0)
    RETURN(0)
   ENDIF
   SET temp_serv_res->nbr_of_examrooms = uar_srvgetitemcount(hrep,"exam_rooms")
   SET stat = alterlist(temp_serv_res->exam_rooms,temp_serv_res->nbr_of_examrooms)
   FOR (i = 1 TO temp_serv_res->nbr_of_examrooms)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"exam_rooms",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     SET temp_serv_res->exam_rooms[i].exam_room_cd = uar_srvgetdouble(hresult,"exam_room_cd")
     SET temp_serv_res->exam_rooms[i].active_ind = uar_srvgetshort(hresult,"active_ind")
     SET temp_serv_res->exam_rooms[i].rel_active_ind = uar_srvgetshort(hresult,"rel_active_ind")
     CASE (iactive_ind)
      OF 1:
       IF (uar_srvgetshort(hresult,"rel_active_ind")=1)
        SET temp_serv_res->exam_rooms[i].subsection_cd = uar_srvgetdouble(hresult,"subsection_cd")
       ENDIF
      OF 0:
       IF (uar_srvgetshort(hresult,"rel_active_ind")=0)
        SET temp_serv_res->exam_rooms[i].subsection_cd = uar_srvgetdouble(hresult,"subsection_cd")
       ENDIF
      ELSE
       SET temp_serv_res->exam_rooms[i].subsection_cd = uar_srvgetdouble(hresult,"subsection_cd")
     ENDCASE
   ENDFOR
   SET temp_serv_res->nbr_of_subsections = uar_srvgetitemcount(hrep,"subsections")
   SET stat = alterlist(temp_serv_res->subsections,temp_serv_res->nbr_of_subsections)
   FOR (i = 1 TO temp_serv_res->nbr_of_subsections)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"subsections",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     SET temp_serv_res->subsections[i].subsection_cd = uar_srvgetdouble(hresult,"subsection_cd")
     SET temp_serv_res->subsections[i].active_ind = uar_srvgetshort(hresult,"active_ind")
     CASE (iactive_ind)
      OF 1:
       IF (uar_srvgetshort(hresult,"rel_active_ind")=1)
        SET temp_serv_res->subsections[i].section_cd = uar_srvgetdouble(hresult,"section_cd")
       ENDIF
      OF 0:
       IF (uar_srvgetshort(hresult,"rel_active_ind")=0)
        SET temp_serv_res->subsections[i].section_cd = uar_srvgetdouble(hresult,"section_cd")
       ENDIF
      ELSE
       SET temp_serv_res->subsections[i].section_cd = uar_srvgetdouble(hresult,"section_cd")
     ENDCASE
   ENDFOR
   SET temp_serv_res->nbr_of_sections = uar_srvgetitemcount(hrep,"sections")
   SET stat = alterlist(temp_serv_res->sections,temp_serv_res->nbr_of_sections)
   FOR (i = 1 TO temp_serv_res->nbr_of_sections)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"sections",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     SET temp_serv_res->sections[i].section_cd = uar_srvgetdouble(hresult,"section_cd")
     SET temp_serv_res->sections[i].active_ind = uar_srvgetshort(hresult,"active_ind")
     CASE (iactive_ind)
      OF 1:
       IF (uar_srvgetshort(hresult,"rel_active_ind")=1)
        SET temp_serv_res->sections[i].department_cd = uar_srvgetdouble(hresult,"department_cd")
       ENDIF
      OF 0:
       IF (uar_srvgetshort(hresult,"rel_active_ind")=0)
        SET temp_serv_res->sections[i].department_cd = uar_srvgetdouble(hresult,"department_cd")
       ENDIF
      ELSE
       SET temp_serv_res->sections[i].department_cd = uar_srvgetdouble(hresult,"department_cd")
     ENDCASE
     SET temp_serv_res->sections[i].nbr_exam_on_req = uar_srvgetlong(hresult,"nbr_exam_on_req")
     SET temp_serv_res->sections[i].nbr_of_printers = uar_srvgetitemcount(hresult,"printers")
     SET stat = alterlist(temp_serv_res->sections[i].printers,temp_serv_res->sections[i].
      nbr_of_printers)
     FOR (j = 1 TO temp_serv_res->sections[i].nbr_of_printers)
       SET pidx = (j - 1)
       SET hlist = uar_srvgetitem(hresult,"printers",pidx)
       SET temp_serv_res->sections[i].printers[j].output_dest_cd = uar_srvgetdouble(hlist,
        "output_dest_cd")
       SET temp_serv_res->sections[i].printers[j].usage_type_cd = uar_srvgetdouble(hlist,
        "usage_type_cd")
       SET temp_serv_res->sections[i].printers[j].name = uar_srvgetstringptr(hlist,"name")
       SET temp_serv_res->sections[i].printers[j].printer_que = uar_srvgetstringptr(hlist,
        "printer_que")
       SET temp_serv_res->sections[i].printers[j].script = uar_srvgetstringptr(hlist,"script")
       SET temp_serv_res->sections[i].printers[j].label_x_pos = uar_srvgetlong(hlist,"label_x_pos")
       SET temp_serv_res->sections[i].printers[j].label_y_pos = uar_srvgetlong(hlist,"label_y_pos")
       SET temp_serv_res->sections[i].printers[j].printer_type_cd = uar_srvgetdouble(hlist,
        "printer_type_cd")
       SET temp_serv_res->sections[i].printers[j].print_point_cd = uar_srvgetdouble(hlist,
        "print_point_cd")
     ENDFOR
   ENDFOR
   SET temp_serv_res->nbr_of_departments = uar_srvgetitemcount(hrep,"departments")
   CALL echo(build("nbr_of_departments; ",temp_serv_res->nbr_of_departments))
   SET stat = alterlist(temp_serv_res->departments,temp_serv_res->nbr_of_departments)
   FOR (i = 1 TO temp_serv_res->nbr_of_departments)
     SET idx = (i - 1)
     SET hresult = uar_srvgetitem(hrep,"departments",idx)
     IF (hresult=0)
      RETURN(0)
     ENDIF
     SET temp_serv_res->departments[i].department_cd = uar_srvgetdouble(hresult,"department_cd")
     SET temp_serv_res->departments[i].active_ind = uar_srvgetshort(hresult,"active_ind")
     CASE (iactive_ind)
      OF 1:
       IF (uar_srvgetshort(hresult,"rel_active_ind")=1)
        SET temp_serv_res->departments[i].institution_cd = uar_srvgetdouble(hresult,"institution_cd")
       ENDIF
      OF 0:
       IF (uar_srvgetshort(hresult,"rel_active_ind")=0)
        SET temp_serv_res->departments[i].institution_cd = uar_srvgetdouble(hresult,"institution_cd")
       ENDIF
      ELSE
       SET temp_serv_res->departments[i].institution_cd = uar_srvgetdouble(hresult,"institution_cd")
     ENDCASE
   ENDFOR
   IF (hstep > 0)
    CALL uar_crmendreq(hstep)
   ENDIF
   IF (htask > 0)
    CALL uar_crmendtask(htask)
   ENDIF
   IF (mod(cnvtint(substring(4,4,curprcname)),1024)=54)
    CALL uar_crmendapp(happ)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (loadtempexamroomsbysubsect(rec=vc(ref)) =null)
   DECLARE exam_cnt = i4 WITH protect, noconstant(0)
   DECLARE subsect_size = i4 WITH protect, constant(size(rec->subsection_list,5))
   DECLARE y = i4 WITH protect, noconstant(0)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE stat = i4 WITH protect, noconstant(0)
   CALL echo("*** START LoadTempExamRoomsBySubSect ***")
   IF ((exam_room_h->nbr_of_examrooms != 0))
    FOR (x = 1 TO subsect_size)
      FOR (y = 1 TO exam_room_h->nbr_of_examrooms)
        IF ((exam_room_h->exam_rooms[y].subsection_cd=rec->subsection_list[x].subsection_cd))
         SET exam_cnt += 1
         IF (exam_cnt > size(temp_exam_rooms->qual,5))
          SET resize_stat = alterlist(temp_exam_rooms->qual,(exam_cnt+ 9))
         ENDIF
         SET temp_exam_rooms->qual[exam_cnt].exam_room_cd = exam_room_h->exam_rooms[y].exam_room_cd
        ENDIF
      ENDFOR
    ENDFOR
    SET stat = alterlist(temp_exam_rooms->qual,exam_cnt)
    SET temp_exam_rooms->qual_size = exam_cnt
   ELSE
    CALL echo("Record exam_room_h is empty. Load exam rooms before calling this sub.")
    SET temp_exam_rooms->qual_size = 0
   ENDIF
   CALL echo(build2("*** END LoadTempExamRoomsBySubSect ***",char(13)))
 END ;Subroutine
 SUBROUTINE (getdeptandsectforsubsect(dsubsectioncd=f8(val),ddeptcd=f8(ref),dsectioncd=f8(ref)) =i2)
   DECLARE lndx = i4 WITH protect, noconstant(0)
   DECLARE lndxfound = i4 WITH protect, noconstant(0)
   IF (size(exam_room_h->exam_rooms,5)=0)
    IF (getpacketexamroomhierarchy("LOAD")=0)
     RETURN(0)
    ENDIF
   ENDIF
   SET lndxfound = locateval(lndx,1,exam_room_h->nbr_of_examrooms,dsubsectioncd,exam_room_h->
    exam_rooms[lndx].subsection_cd)
   IF (lndxfound != 0)
    SET dsectioncd = exam_room_h->exam_rooms[lndxfound].section_cd
    SET ddeptcd = exam_room_h->exam_rooms[lndxfound].department_cd
    RETURN(1)
   ENDIF
   SET dsectioncd = 0.0
   SET ddeptcd = 0.0
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (getinstofservresource(dservresparentcd=f8,dservrescd=f8) =f8)
   DECLARE happ = i4 WITH noconstant(0), private
   DECLARE htask = i4 WITH noconstant(0), private
   DECLARE hstep = i4 WITH noconstant(0), private
   DECLARE hreq = i4 WITH noconstant(0), private
   DECLARE hitem = i4 WITH noconstant(0), private
   DECLARE hitem2 = i4 WITH noconstant(0), private
   DECLARE hrep = i4 WITH noconstant(0), private
   DECLARE lcount = i4 WITH protect, noconstant(0)
   DECLARE lsrvgrpcnt = i4 WITH protect, noconstant(0)
   DECLARE lsrvnextgrpcnt = i4 WITH protect, noconstant(0)
   DECLARE lndx = i4 WITH protect, noconstant(0)
   DECLARE dinstitutioncd = f8 WITH protect, noconstant(0.00)
   DECLARE dparentservgroupcd = f8 WITH protect, noconstant(0.00)
   DECLARE ddepartment_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,nullterm(
      "DEPARTMENT")))
   DECLARE dsection_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,nullterm("SECTION"))
    )
   DECLARE dlibtrkpt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,nullterm("LIBTRKPT"
      )))
   DECLARE dlibgroup_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,nullterm("LIBGRP"))
    )
   SET crmstat = uar_crmbeginapp(490000,happ)
   IF (crmstat > 0)
    CALL echo("Failed to begin app")
    RETURN(0)
   ENDIF
   SET stat = uar_crmbegintask(happ,490000,htask)
   IF (((stat != 0) OR (htask=0)) )
    CALL echo("Bad BeginTask")
    RETURN(0)
   ENDIF
   SET stat = uar_crmbeginreq(htask,"",490000,hstep)
   IF (((stat != 0) OR (hstep=0)) )
    CALL echo("Bad BeginReq")
    RETURN(0)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq=0)
    RETURN(0)
   ENDIF
   SET stat = uar_crmperform(hstep)
   IF (stat != 0)
    RETURN(0)
   ENDIF
   SET hrep = uar_crmgetreply(hstep)
   IF (hrep=0)
    RETURN(0)
   ENDIF
   CASE (dservresparentcd)
    OF dlibgroup_cd:
     SET lsrvgrpcnt = uar_srvgetitemcount(hrep,"lib_groups")
     FOR (lcount = 1 TO lsrvgrpcnt)
       SET lndx = (lcount - 1)
       SET hresult = uar_srvgetitem(hrep,"lib_groups",lndx)
       IF (hresult=0)
        RETURN(0)
       ENDIF
       IF (uar_srvgetdouble(hresult,"lib_grp_cd")=dservrescd)
        SET dinstitutioncd = uar_srvgetdouble(hresult,"institution_cd")
        SET lcount = lsrvgrpcnt
       ENDIF
     ENDFOR
    OF ddepartment_cd:
     SET lsrvgrpcnt = uar_srvgetitemcount(hrep,"departments")
     FOR (lcount = 1 TO lsrvgrpcnt)
       SET lndx = (lcount - 1)
       SET hresult = uar_srvgetitem(hrep,"departments",lndx)
       IF (hresult=0)
        RETURN(0)
       ENDIF
       IF (uar_srvgetdouble(hresult,"department_cd")=dservrescd)
        SET dinstitutioncd = uar_srvgetdouble(hresult,"institution_cd")
        SET lcount = lsrvgrpcnt
       ENDIF
     ENDFOR
    OF dlibtrkpt_cd:
     SET lsrvgrpcnt = uar_srvgetitemcount(hrep,"lib_trk_points")
     FOR (lcount = 1 TO lsrvgrpcnt)
       SET lndx = (lcount - 1)
       SET hresult = uar_srvgetitem(hrep,"lib_trk_points",lndx)
       IF (hresult=0)
        RETURN(0)
       ENDIF
       IF (uar_srvgetdouble(hresult,"service_resource_cd")=dservrescd)
        SET dparentservgroupcd = uar_srvgetdouble(hresult,"lib_grp_cd")
        SET lcount = lsrvgrpcnt
       ENDIF
     ENDFOR
     SET lsrvnextgrpcnt = uar_srvgetitemcount(hrep,"lib_groups")
     FOR (lcount = 1 TO lsrvnextgrpcnt)
       SET lndx = (lcount - 1)
       SET hresult = uar_srvgetitem(hrep,"lib_groups",lndx)
       IF (hresult=0)
        RETURN(0)
       ENDIF
       IF (uar_srvgetdouble(hresult,"lib_grp_cd")=dparentservgroupcd)
        SET dinstitutioncd = uar_srvgetdouble(hresult,"institution_cd")
        SET lcount = lsrvnextgrpcnt
       ENDIF
     ENDFOR
    OF dsection_cd:
     SET lsrvgrpcnt = uar_srvgetitemcount(hrep,"sections")
     FOR (lcount = 1 TO lsrvgrpcnt)
       SET lndx = (lcount - 1)
       SET hresult = uar_srvgetitem(hrep,"sections",lndx)
       IF (hresult=0)
        RETURN(0)
       ENDIF
       IF (uar_srvgetdouble(hresult,"section_cd")=dservrescd)
        SET dparentservgroupcd = uar_srvgetdouble(hresult,"department_cd")
        SET lcount = lsrvgrpcnt
       ENDIF
     ENDFOR
     SET lsrvnextgrpcnt = uar_srvgetitemcount(hrep,"departments")
     FOR (lcount = 1 TO lsrvnextgrpcnt)
       SET lndx = (lcount - 1)
       SET hresult = uar_srvgetitem(hrep,"departments",lndx)
       IF (hresult=0)
        RETURN(0)
       ENDIF
       IF (uar_srvgetdouble(hresult,"department_cd")=dparentservgroupcd)
        SET dinstitutioncd = uar_srvgetdouble(hresult,"institution_cd")
        SET lcount = lsrvnextgrpcnt
       ENDIF
     ENDFOR
   ENDCASE
   IF (hstep > 0)
    CALL uar_crmendreq(hstep)
   ENDIF
   IF (htask > 0)
    CALL uar_crmendtask(htask)
   ENDIF
   IF (mod(cnvtint(substring(4,4,curprcname)),1024)=54)
    CALL uar_crmendapp(happ)
   ENDIF
   RETURN(dinstitutioncd)
 END ;Subroutine
 IF ((t_record->visit[1].order_id=0)
  AND (t_record->visit[1].study_id > 0))
  SELECT INTO "nl:"
   FROM mammo_study ms,
    encounter e,
    location l
   PLAN (ms
    WHERE (ms.study_id=t_record->visit[1].study_id))
    JOIN (e
    WHERE e.encntr_id=ms.encntr_id)
    JOIN (l
    WHERE (l.location_cd= Outerjoin(e.loc_facility_cd)) )
   DETAIL
    t_record->visit[1].encntr_id = ms.encntr_id, t_record->person[1].person_id = ms.person_id,
    t_record->visit[1].encntr_facility_cd = l.organization_id,
    t_record->visit[1].catalog_cd = ms.catalog_cd, t_record->visit[1].discipline_type_cd = 0
    IF (ms.edition_nbr <= 40)
     t_radiology_record->assessment_id = ms.assessment_id, t_radiology_record->recommendation_id = ms
     .recommendation_id
    ENDIF
   WITH nocounter
  ;end select
  CALL updateassessmentmgmttagvalues(null)
  SELECT INTO "nl:"
   FROM mammo_study_prsnl msp,
    rad_mammo_study_assess_mgmt_r rmsam
   PLAN (msp
    WHERE (msp.study_id=t_record->visit[1].study_id)
     AND msp.prsnl_relation_flag IN (2, 98))
    JOIN (rmsam
    WHERE (rmsam.study_id= Outerjoin(msp.study_id))
     AND (rmsam.final_assess_ind= Outerjoin(1)) )
   DETAIL
    IF (msp.prsnl_relation_flag=2)
     IF (rmsam.radiologist_id > 0.0)
      t_radiology_record->radiologist_id = rmsam.radiologist_id
     ELSE
      t_radiology_record->radiologist_id = msp.prsnl_id
     ENDIF
    ELSE
     t_record->visit[1].order_physician_id = msp.prsnl_id
    ENDIF
   WITH nocounter
  ;end select
  SET g_section_cd = uar_get_code_by("MEANING",223,"SECTION")
  SET g_dept_cd = uar_get_code_by("MEANING",223,"DEPARTMENT")
  SELECT INTO "nl:"
   FROM mammo_study ms
   PLAN (ms
    WHERE (ms.study_id=t_record->visit[1].study_id))
   DETAIL
    t_radiology_record->exam_facility_cd = 0, t_radiology_record->seq_exam_id = ms.seq_exam_id,
    mdsubsectioncd = ms.subsection_cd,
    t_record->visit[1].dtstudydttm = ms.study_dt_tm
   WITH nocounter
  ;end select
  CALL getdeptandsectforsubsect(mdsubsectioncd,mddepartmentcd,mdsectioncd)
  SET t_radiology_record->exam_dept_cd = mddepartmentcd
 ELSEIF ((t_record->visit[1].order_id > 0))
  SELECT INTO "nl:"
   FROM orders o,
    encounter e,
    location l
   PLAN (o
    WHERE (o.order_id=t_record->visit[1].order_id))
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (l
    WHERE (l.location_cd= Outerjoin(e.loc_facility_cd)) )
   DETAIL
    t_record->visit[1].encntr_id = o.encntr_id, t_record->person[1].person_id = o.person_id, t_record
    ->visit[1].catalog_cd = o.catalog_cd,
    t_record->visit[1].encntr_facility_cd = l.organization_id, t_record->visit[1].discipline_type_cd
     = o.catalog_type_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM order_action oa
   WHERE (oa.order_id=t_record->visit[1].order_id)
    AND oa.action_type_cd IN (order_type_cd, renew_type_cd, modify_type_cd, activate_type_cd)
   ORDER BY oa.action_sequence
   DETAIL
    t_record->visit[1].order_physician_id = oa.order_provider_id
   WITH nocounter
  ;end select
 ELSEIF ((t_record->visit[1].encntr_id > 0))
  SELECT INTO "nl:"
   FROM encounter e,
    location l
   PLAN (e
    WHERE (e.encntr_id=t_record->visit[1].encntr_id))
    JOIN (l
    WHERE (l.location_cd= Outerjoin(e.loc_facility_cd)) )
   DETAIL
    t_record->person[1].person_id = e.person_id, t_record->visit[1].encntr_facility_cd = e
    .loc_facility_cd, t_record->visit[1].discipline_type_cd = 0,
    t_record->visit[1].order_physician_id = 0, t_record->visit[1].catalog_cd = 0
   WITH nocounter
  ;end select
 ELSE
  SET t_record->visit[1].encntr_facility_cd = 0
  SET t_record->visit[1].discipline_type_cd = 0
  SET t_record->visit[1].order_physician_id = 0
  SET t_record->visit[1].catalog_cd = 0
 ENDIF
 CALL cv_log_message(build("After finding ids, person_id:",t_record->person[1].person_id))
 CALL cv_log_message(build("encntr_id:",t_record->visit[1].encntr_id))
 CALL cv_log_message(build("order_id:",t_record->visit[1].order_id))
 CALL cv_log_message(build("study_id:",t_record->visit[1].study_id))
 CALL cv_log_message(build("catalog_cd:",t_record->visit[1].catalog_cd))
 CALL cv_log_message(build("order_physician_id:",t_record->visit[1].order_physician_id))
 CALL cv_log_message(build("encntr_facility_cd:",t_record->visit[1].encntr_facility_cd))
 CALL cv_log_message(build("discipline_type_cd:",t_record->visit[1].discipline_type_cd))
 IF ((t_record->visit[1].discipline_type_cd=t_radiology_record->radiology_exam_cd))
  SET g_section_cd = uar_get_code_by("MEANING",223,"SECTION")
  SET g_subsection_cd = uar_get_code_by("MEANING",223,"SUBSECTION")
  SET g_dept_cd = uar_get_code_by("MEANING",223,"DEPARTMENT")
  SET g_bldg_cd = uar_get_code_by("MEANING",222,"BUILDING")
  SET g_fac_cd = uar_get_code_by("MEANING",222,"FACILITY")
  SELECT INTO "nl:"
   FROM rad_report_prsnl rrp,
    rad_report rr
   PLAN (rr
    WHERE (rr.order_id=t_record->visit[1].order_id))
    JOIN (rrp
    WHERE rrp.rad_report_id=rr.rad_report_id
     AND rrp.prsnl_relation_flag=2)
   ORDER BY rr.sequence
   DETAIL
    t_radiology_record->radiologist_id = rrp.report_prsnl_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM rad_exam re,
    service_resource sr,
    location_group bld_lg,
    location_group fac_lg
   PLAN (re
    WHERE (re.order_id=t_record->visit[1].order_id))
    JOIN (sr
    WHERE (sr.service_resource_cd= Outerjoin(re.service_resource_cd))
     AND ((sr.beg_effective_dt_tm+ 0)< Outerjoin(cnvtdatetime(sysdate)))
     AND ((sr.end_effective_dt_tm+ 0)> Outerjoin(cnvtdatetime(sysdate)))
     AND ((sr.active_ind+ 0)= Outerjoin(1)) )
    JOIN (bld_lg
    WHERE (bld_lg.child_loc_cd= Outerjoin(sr.location_cd))
     AND (bld_lg.location_group_type_cd= Outerjoin(g_bldg_cd))
     AND (bld_lg.root_loc_cd= Outerjoin(0))
     AND ((bld_lg.beg_effective_dt_tm+ 0)< Outerjoin(cnvtdatetime(sysdate)))
     AND ((bld_lg.end_effective_dt_tm+ 0)> Outerjoin(cnvtdatetime(sysdate)))
     AND ((bld_lg.active_ind+ 0)= Outerjoin(1)) )
    JOIN (fac_lg
    WHERE (fac_lg.child_loc_cd= Outerjoin(bld_lg.parent_loc_cd))
     AND (fac_lg.location_group_type_cd= Outerjoin(g_fac_cd))
     AND (fac_lg.root_loc_cd= Outerjoin(0))
     AND ((fac_lg.beg_effective_dt_tm+ 0)< Outerjoin(cnvtdatetime(sysdate)))
     AND ((fac_lg.end_effective_dt_tm+ 0)> Outerjoin(cnvtdatetime(sysdate)))
     AND ((fac_lg.active_ind+ 0)= Outerjoin(1)) )
   DETAIL
    t_radiology_record->exam_facility_cd = fac_lg.parent_loc_cd, mdserviceresourcecd = re
    .service_resource_cd
   WITH nocounter
  ;end select
  CALL getdeptandsectforexrm(mdserviceresourcecd,mddepartmentcd,mdsectioncd)
  SET t_radiology_record->exam_dept_cd = mddepartmentcd
  SELECT INTO "nl:"
   FROM mammo_study ms
   WHERE (ms.study_id=t_record->visit[1].study_id)
   DETAIL
    IF (ms.edition_nbr <= 40)
     t_radiology_record->assessment_id = ms.assessment_id, t_radiology_record->recommendation_id = ms
     .recommendation_id
    ENDIF
    t_record->visit[1].dtstudydttm = ms.study_dt_tm
   WITH nocounter
  ;end select
  CALL updateassessmentmgmttagvalues(null)
 ENDIF
 CALL cv_log_message(build("Radiology ids are, radiologist_id:",t_radiology_record->radiologist_id))
 CALL cv_log_message(build("exam_dept_cd:",t_radiology_record->exam_dept_cd))
 CALL cv_log_message(build("exam_facility_cd:",t_radiology_record->exam_facility_cd))
 CALL cv_log_message(build("assessment_id:",t_radiology_record->assessment_id))
 CALL cv_log_message(build("recommendation_id:",t_radiology_record->recommendation_id))
 SET t_record->template_qual_cnt = 1
 SET stat = alterlist(t_record->template_qual,t_record->template_qual_cnt)
 SET t_record->template_qual[1].template_name = trim(request->script_name,3)
 SET use_wp_template_ind = validate(request->use_wp_template_flag,0)
 IF (use_wp_template_ind=0)
  SET t_record->template_qual[1].template_name = substring(7,94,trim(request->script_name,3))
 ENDIF
 SET t_record->template_qual[1].parent_template_index = - (1)
 SET t_record->template_qual[1].parent_tag_index = - (1)
 CALL getmaxtemplates(1)
 SET template_index = 1
 WHILE ((template_index <= t_record->template_qual_cnt))
   CALL gettemplate(template_index)
   CALL gettemplatetags(template_index,tagtype2template)
   IF (failure="T")
    GO TO exit_script
   ENDIF
   IF (template_index < g_maxtemplates)
    FOR (tag_index = 1 TO t_record->template_qual[template_index].tag_qual_cnt)
      IF ((t_record->template_qual[template_index].tag_qual[tag_index].tag_modifier1=tag_template))
       SET t_record->template_qual_cnt += 1
       SET stat = alterlist(t_record->template_qual,t_record->template_qual_cnt)
       SET t_record->template_qual[t_record->template_qual_cnt].template_name = t_record->
       template_qual[template_index].tag_qual[tag_index].tag_modifier2
       SET t_record->template_qual[t_record->template_qual_cnt].parent_template_index =
       template_index
       SET t_record->template_qual[t_record->template_qual_cnt].parent_tag_index = tag_index
      ENDIF
    ENDFOR
   ENDIF
   SET template_index += 1
 ENDWHILE
 SET template_index = t_record->template_qual_cnt
 SET stop = 2
 SET replaced_template = fillstring(32000," ")
 WHILE (template_index >= stop)
   SET parent_template_index = t_record->template_qual[template_index].parent_template_index
   SET parent_tag_index = t_record->template_qual[template_index].parent_tag_index
   SET tagstart = t_record->template_qual[parent_template_index].tag_qual[parent_tag_index].tag_start
   SET tagend = t_record->template_qual[parent_template_index].tag_qual[parent_tag_index].tag_end
   SET templen = size(t_record->template_qual[parent_template_index].template,1)
   SET replaced_template = concat(substring(1,(tagstart - 1),t_record->template_qual[
     parent_template_index].template),t_record->template_qual[template_index].template,substring((
     tagend+ 1),(templen - tagend),t_record->template_qual[parent_template_index].template))
   SET t_record->template_qual[parent_template_index].template = replaced_template
   SET template_index -= 1
 ENDWHILE
 CALL gettemplatetags(1,tagtypeall)
 IF (failure="T")
  GO TO exit_script
 ENDIF
 CALL cv_log_message(build("After getting all template tags, num tags:",t_record->template_qual[1].
   tag_qual_cnt))
 IF ((t_record->template_qual[1].tag_qual_cnt=0))
  SET reply->text = t_record->template_qual[1].template
  GO TO dump_records
 ENDIF
 SELECT INTO "nl:"
  FROM address adr
  WHERE (adr.parent_entity_id=t_record->person[1].person_id)
   AND adr.parent_entity_name="PERSON"
   AND adr.active_ind=1
   AND adr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
   AND adr.end_effective_dt_tm >= cnvtdatetime(sysdate)
  DETAIL
   IF (uar_get_code_meaning(adr.address_type_cd)="MAILING")
    mlmailaddrflag = 1
   ELSEIF (uar_get_code_meaning(adr.address_type_cd)="HOME")
    mlhomeaddrflag = 1
   ENDIF
  WITH nocounter
 ;end select
 SET istart = 0
 SET istop = 0
 SET ilen = 0
 SET itemp = 0
 SET strformatpre = fillstring(256," ")
 SET strformatpost = fillstring(256," ")
 CALL buffer_reset(1)
 SET pbindex = 1
 SELECT INTO "nl:"
  FROM (dummyt d8  WITH seq = value(size(t_record->template_qual[1].tag_qual,5))),
   code_value cv,
   code_value_extension where_cvex,
   code_value_extension cvex
  PLAN (d8)
   JOIN (cv
   WHERE (t_record->template_qual[1].tag_qual[d8.seq].tag_type=tagtype1tblfld)
    AND (t_record->template_qual[1].tag_qual[d8.seq].tag_modifier1=cnvtupper(trim(cv.display,3)))
    AND cv.code_set=tagnamecodeset)
   JOIN (where_cvex
   WHERE cv.code_value=where_cvex.code_value
    AND where_cvex.field_name=primarykeyfield)
   JOIN (cvex
   WHERE cv.code_value=cvex.code_value)
  ORDER BY cv.definition, where_cvex.field_value, d8.seq,
   cvex.field_name
  HEAD REPORT
   tbl_disp = fillstring(100," "), name_disp = fillstring(100," "), format_disp = fillstring(100," "),
   key_disp = fillstring(100," "), where_key = fillstring(100," "), first = 1
  HEAD cv.definition
   itemp = 1
  HEAD where_cvex.field_value
   first = 1
  HEAD d8.seq
   tbl_disp = fillstring(100," "), name_disp = fillstring(100," "), format_disp = fillstring(100," "),
   key_disp = fillstring(100," "), where_key = fillstring(100," "), format_pre = fillstring(100," "),
   format_post = fillstring(100," "), where_active_ind = fillstring(100," "), where_effective_greater
    = fillstring(100," "),
   where_effective_less = fillstring(100," ")
  HEAD cvex.field_name
   itemp = 1
  DETAIL
   CASE (cnvtupper(trim(cvex.field_name,3)))
    OF cvex_fn_fieldname:
     t_record->template_qual[1].tag_qual[d8.seq].tag1_tbl = trim(cv.definition,3),t_record->
     template_qual[1].tag_qual[d8.seq].tag1_fld = trim(cvex.field_value,3),name_disp = build(
      "t_record->template_qual[1]->tag_qual[",d8.seq,"].value"),
     tbl_disp = trim(cv.definition,3),
     IF (cvex.field_value=alias)
      format_disp = "=cnvtalias(t.alias, t.alias_pool_cd)", t_record->template_qual[1].tag_qual[d8
      .seq].format_function = format_disp
     ENDIF
    OF cvex_fn_formatfunction:
     IF (textlen(trim(format_disp))=0)
      t_record->template_qual[1].tag_qual[d8.seq].format_function = trim(cvex.field_value,3), istart
       = findstring(formatreplace,cnvtupper(trim(cvex.field_value,3)))
      IF (istart > 0)
       istop = ((istart+ size(formatreplace)) - 1), format_pre = substring(1,(istart - 1),trim(cvex
         .field_value,3)), format_post = substring((istop+ 1),(size(trim(cvex.field_value,3)) - istop
        ),trim(cvex.field_value,3)),
       format_disp = build(" = ",format_pre,"t.",t_record->template_qual[1].tag_qual[d8.seq].tag1_fld,
        format_post)
      ELSE
       format_disp = concat(" = t.",t_record->template_qual[1].tag_qual[d8.seq].tag1_fld)
      ENDIF
     ENDIF
    OF cvex_fn_primarykey:
     t_record->template_qual[1].tag_qual[d8.seq].primary_key = trim(cvex.field_value,3),key_disp =
     trim(cvex.field_value,3)
    OF cvex_fn_wherecvis:
     istart = findstring(tag_semicolon,trim(cvex.field_value,3),1),t_record->template_qual[1].
     tag_qual[d8.seq].where_field = trim(substring(1,(istart - 1),trim(cvex.field_value,3)),3),istop
      = findstring(tag_semicolon,trim(cvex.field_value,3),(istart+ 1)),
     t_record->template_qual[1].tag_qual[d8.seq].where_codeset = trim(substring((istart+ 1),((istop
        - istart) - 1),trim(cvex.field_value,3)),3),ilen = size(trim(cvex.field_value,3),1),t_record
     ->template_qual[1].tag_qual[d8.seq].where_cdf = trim(substring((istop+ 1),(ilen - istop),trim(
        cvex.field_value,3)),3),
     where_key = trim(cvex.field_value,3)
    OF cvex_fn_where_activeind:
     where_active_ind = trim(cvex.field_value,3)
    OF cvex_fn_where_effective_greater:
     where_effective_greater = trim(cvex.field_value,3)
    OF cvex_fn_where_effective_less:
     where_effective_less = trim(cvex.field_value,3)
   ENDCASE
  FOOT  cvex.field_name
   itemp = 1
  FOOT  d8.seq
   IF (first=1)
    first = 0,
    CALL buffer_add(pbindex,"select into 'nl:'"),
    CALL buffer_add(pbindex,"from"),
    CALL buffer_add(pbindex,build(tbl_disp," t")),
    CALL buffer_add(pbindex,build("where t.",key_disp))
    IF (where_active_ind != blankstring)
     CALL buffer_add(pbindex,build("and t.",where_active_ind)),
     CALL buffer_add(pbindex,build("and t.",where_effective_greater)),
     CALL buffer_add(pbindex,build("and t.",where_effective_less))
    ENDIF
    CALL buildwherecvis(d8.seq)
    IF (g_where_cv_is != blankstring)
     CALL buffer_add(pbindex,g_where_cv_is)
    ENDIF
    CASE (tbl_disp)
     OF "PHONE":
      CALL buffer_add(pbindex," and t.phone_type_seq = 1 ")
     OF "ADDRESS":
      IF (cv.display != "ENCNTR_FACILITY*")
       CALL buffer_add(pbindex," and t.address_type_seq=1 ")
      ELSE
       CALL buffer_add(pbindex," order t.address_type_seq desc ")
      ENDIF
    ENDCASE
    CALL buffer_add(pbindex,"detail")
   ENDIF
   CALL buffer_add(pbindex,build(name_disp," ",format_disp))
  FOOT  where_cvex.field_value
   CALL buffer_add(pbindex,"with nocounter go"),
   CALL buffer_add_dim(1), pbindex += 1
  FOOT  cv.definition
   itemp = 1
  WITH nocounter, maxcol = 10000
 ;end select
 EXECUTE cv_log_struct  WITH replace(request,bufparse)
 SET x = 0
 FOR (dumpind = 1 TO pbindex)
  CALL buffer_perform(dumpind)
  SET x += 1
 ENDFOR
 SET cv_cl_internal->person_id = t_record->person[1].person_id
 SET cv_cl_internal->encntr_id = t_record->visit[1].encntr_id
 CALL buffer_reset(1)
 SET pbindex = 1
 SELECT INTO "nl:"
  tagmod3 = t_record->template_qual[1].tag_qual[d7.seq].tag_modifier3
  FROM (dummyt d7  WITH seq = value(size(t_record->template_qual[1].tag_qual,5))),
   code_value cv
  PLAN (d7)
   JOIN (cv
   WHERE (t_record->template_qual[1].tag_qual[d7.seq].tag_type=tagtype3eventcode)
    AND (trim(cv.display_key,3)=t_record->template_qual[1].tag_qual[d7.seq].tag_modifier2)
    AND cv.code_set=eventcodeset)
  ORDER BY tagmod3
  HEAD tagmod3
   count = 1
  DETAIL
   stat = alterlist(cv_cl_internal->events,size(t_record->template_qual[1].tag_qual,5)),
   cv_cl_internal->events[d7.seq].event_cd = cv.code_value
  FOOT  tagmod3
   CALL buffer_add(pbindex,concat("execute ",t_record->template_qual[1].tag_qual[d7.seq].
    tag_modifier3," go")),
   CALL buffer_add_dim(1), pbindex += 1
  WITH nocounter
 ;end select
 EXECUTE cv_log_struct  WITH replace(request,bufparse)
 FOR (dumpind = 1 TO pbindex)
   CALL buffer_perform(dumpind)
 ENDFOR
 FOR (tag_index = 1 TO t_record->template_qual[1].tag_qual_cnt)
   IF ((t_record->template_qual[1].tag_qual[tag_index].tag_type=tagtype3eventcode))
    SET t_record->template_qual[1].tag_qual[tag_index].value = cv_cl_internal->events[tag_index].
    result_val
   ENDIF
 ENDFOR
 EXECUTE cv_log_struct  WITH replace(request,cv_cl_internal)
 SET nv_size = size(request->nv,5)
 IF (nv_size > 0)
  FOR (tag_index = 1 TO t_record->template_qual[1].tag_qual_cnt)
    IF ((t_record->template_qual[1].tag_qual[tag_index].tag_type=tagtype4value))
     SET t_record->template_qual[1].tag_qual[tag_index].value = ""
     FOR (nv_index = 1 TO nv_size)
       IF ((request->nv[nv_index].pvc_name=t_record->template_qual[1].tag_qual[tag_index].tag))
        SET t_record->template_qual[1].tag_qual[tag_index].value = request->nv[nv_index].pvc_value
        SET nv_index = nv_size
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
 ENDIF
 SET istart = 0
 SET istop = 0
 FOR (tag_index = 1 TO t_record->template_qual[1].tag_qual_cnt)
   SET strtagtoreplace = concat(tag_start,trim(t_record->template_qual[1].tag_qual[tag_index].tag,3),
    tag_end)
   SET strtagvalue = trim(t_record->template_qual[1].tag_qual[tag_index].value,3)
   IF ((t_record->template_qual[1].tag_qual[tag_index].tag1_fld=alias))
    IF (size(trim(strtagvalue))=0
     AND (t_radiology_record->seq_exam_id != 0))
     SET strtagvalue = shistory
    ENDIF
   ENDIF
   IF (tag_index=1)
    SET istart = 1
   ELSE
    SET istart = (t_record->template_qual[1].tag_qual[(tag_index - 1)].tag_end+ 1)
   ENDIF
   IF ((tag_index != t_record->template_qual[1].tag_qual_cnt))
    SET istop = t_record->template_qual[1].tag_qual[tag_index].tag_end
   ELSE
    SET istop = textlen(t_record->template_qual[1].template)
   ENDIF
   SET strtextandtag = substring(istart,((istop - istart)+ 1),t_record->template_qual[1].template)
   SET strreplaced = replace(strtextandtag,strtagtoreplace,strtagvalue,0)
   SET t_record->rtf_report = concat(t_record->rtf_report,strreplaced)
 ENDFOR
 SET reply->text = t_record->rtf_report
#dump_records
 EXECUTE cv_log_struct  WITH replace(request,t_record)
 EXECUTE cv_log_struct  WITH replace(request,bufparse)
 SET out_file = fillstring(100," ")
 FOR (template_index = 1 TO t_record->template_qual_cnt)
   CALL buffer_reset(1)
   SET out_file = build("cer_temp:cv_cl_template_",template_index,".rtf")
   CALL buffer_add(1,build("select into '",out_file,"'"))
   CALL buffer_add(1,"from dual d")
   CALL buffer_add(1,"detail")
   CALL buffer_add(1,"   t_record->template_qual[template_index]->template, row + 1")
   CALL buffer_add(1,"with nocounter, maxcol = 32000 go")
   CALL buffer_perform(1)
 ENDFOR
 SELECT INTO "cer_temp:cv_cl_report.rtf"
  FROM dual d
  DETAIL
   reply->text, row + 1
  WITH nocounter, maxcol = 32000
 ;end select
#exit_script
 IF (failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 EXECUTE cv_log_struct  WITH replace(request,reply)
 SUBROUTINE buffer_reset(cv_dummy)
  FOR (item1ind = 1 TO size(bufparse->item1,5))
    SET buffer_stat = alterlist(bufparse->item1[item1ind].item2,0)
  ENDFOR
  SET buffer_stat = alterlist(bufparse->item1,1)
 END ;Subroutine
 SUBROUTINE buffer_add_dim(cv_dummy)
   SET buffer_stat = alterlist(bufparse->item1,(size(bufparse->item1,5)+ 1))
 END ;Subroutine
 SUBROUTINE buffer_add(prm_ba_i1,prm_str)
   IF (((prm_ba_i1 < 1) OR (prm_ba_i1 > size(bufparse->item1,5))) )
    CALL echo(build("illegal array index in buffer_add:",prm_ba_i1))
   ELSE
    SET buffer_stat = alterlist(bufparse->item1[prm_ba_i1].item2,(size(bufparse->item1[prm_ba_i1].
      item2,5)+ 1))
    SET bufparse->item1[prm_ba_i1].item2[size(bufparse->item1[prm_ba_i1].item2,5)].text = prm_str
   ENDIF
 END ;Subroutine
 SUBROUTINE buffer_perform(prm_bp_i1)
   IF (((prm_bp_i1 < 1) OR (prm_bp_i1 > size(bufparse->item1,5))) )
    CALL echo(build("illegal array index in buffer_perform:",prm_bp_i1))
   ELSE
    FOR (item2ind = 1 TO size(bufparse->item1[prm_bp_i1].item2,5))
      CALL parser(bufparse->item1[prm_bp_i1].item2[item2ind].text)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE buffer_dump(prm_bd_i1)
   IF (((prm_bd_i1 < 1) OR (prm_bd_i1 > size(bufparse->item1,5))) )
    CALL echo(build("illegal array index in buffer_dump:",prm_bd_i1))
   ELSE
    FOR (item2ind = 1 TO size(bufparse->item1[prm_bd_i1].item2,5))
      CALL cv_log_message(bufparse->item1[prm_bd_i1].item2[item2ind].text)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE buildwherecvis(prm_tagindex)
   SET g_where_cv_is = fillstring(256," ")
   IF (size(t_record->template_qual[1].tag_qual[prm_tagindex].where_field,1) > 0
    AND size(t_record->template_qual[1].tag_qual[prm_tagindex].where_codeset,1) > 0
    AND size(t_record->template_qual[1].tag_qual[prm_tagindex].where_cdf,1) > 0)
    SET get_cd = 0.0
    SET cdf_meaning = fillstring(12," ")
    SET cdf_meaning = t_record->template_qual[1].tag_qual[prm_tagindex].where_cdf
    IF ((t_record->template_qual[1].tag_qual[prm_tagindex].where_codeset="212")
     AND cdf_meaning="HOME")
     IF (mlmailaddrflag=1)
      SET cdf_meaning = "MAILING"
     ELSEIF (mlhomeaddrflag=1)
      SET cdf_meaning = "HOME"
     ELSE
      SET cdf_meaning = "TEMPORARY"
     ENDIF
    ENDIF
    CALL uar_get_meaning_by_codeset(cnvtint(t_record->template_qual[1].tag_qual[prm_tagindex].
      where_codeset),cdf_meaning,1,get_cd)
    SET g_where_cv_is = build("and t.",t_record->template_qual[1].tag_qual[prm_tagindex].where_field,
     " = ",get_cd)
   ENDIF
   SET g_where_cv_is = trim(g_where_cv_is,3)
 END ;Subroutine
 SUBROUTINE gettemplate(prm_gt_index)
   DECLARE dtemplatetypecd = f8 WITH protect, noconstant(0.0)
   DECLARE dactivitytypecd = f8 WITH protect, noconstant(0.0)
   IF (use_wp_template_ind > 0)
    SET dtemplatetypecd = uar_get_code_by("MEANING",1303,"LETTER")
    SET dactivitytypecd = uar_get_code_by("MEANING",106,"RADIOLOGY")
    SELECT INTO "nl:"
     FROM long_text lt,
      wp_template wp,
      wp_template_text wpt
     PLAN (wp
      WHERE wp.template_type_cd=dtemplatetypecd
       AND wp.short_desc=cnvtupper(t_record->template_qual[prm_gt_index].template_name)
       AND wp.activity_type_cd=dactivitytypecd)
      JOIN (wpt
      WHERE wp.template_id=wpt.template_id)
      JOIN (lt
      WHERE wpt.long_text_id=lt.long_text_id)
     DETAIL
      t_record->template_qual[prm_gt_index].template = lt.long_text
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM long_blob lb,
      clinical_note_template cnt
     PLAN (cnt
      WHERE cnvtupper(trim(cnt.template_name,3))=cnvtupper(t_record->template_qual[prm_gt_index].
       template_name))
      JOIN (lb
      WHERE lb.long_blob_id=cnt.long_blob_id)
     DETAIL
      t_record->template_qual[prm_gt_index].template = lb.long_blob
     WITH nocounter
    ;end select
   ENDIF
   IF (curqual=0)
    SET cv_log_level = cv_log_error
    CALL cv_log_current_default(0)
    CALL cv_log_message(build("Failure in selecting template: ",t_record->template_qual[prm_gt_index]
      .template_name))
    SET failure = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE gettagtype(prm_gtt2_tag)
   IF (findstring(tag_eventcode,cnvtupper(prm_gtt2_tag))=1)
    SET g_gettagtype = tagtype3eventcode
   ELSEIF (findstring(tag_template,cnvtupper(prm_gtt2_tag))=1)
    SET g_gettagtype = tagtype2template
   ELSEIF (findstring(tag_value,cnvtupper(prm_gtt2_tag))=1)
    SET g_gettagtype = tagtype4value
   ELSE
    SET g_gettagtype = tagtype1tblfld
   ENDIF
 END ;Subroutine
 SUBROUTINE gettagmodifiers(prm_gtm_tempind,prm_gtm_tagind)
   SET equal_loc = findstring(tag_equal,t_record->template_qual[prm_gtm_tempind].tag_qual[
    prm_gtm_tagind].tag)
   SET semicol_loc = findstring(tag_semicolon,t_record->template_qual[prm_gtm_tempind].tag_qual[
    prm_gtm_tagind].tag)
   IF (equal_loc=0)
    SET mod1_stop = size(t_record->template_qual[prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag,1)
   ELSE
    SET mod1_stop = (equal_loc - 1)
   ENDIF
   IF (semicol_loc=0)
    SET mod2_stop = size(t_record->template_qual[prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag,1)
   ELSE
    SET mod2_stop = (semicol_loc - 1)
   ENDIF
   SET mod3_stop = size(t_record->template_qual[prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag,1)
   IF (mod1_stop > 0)
    SET t_record->template_qual[prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag_modifier1 = cnvtupper(
     trim(substring(1,mod1_stop,t_record->template_qual[prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag
       ),3))
   ENDIF
   IF (mod2_stop > mod1_stop)
    SET t_record->template_qual[prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag_modifier2 = cnvtupper(
     trim(substring((mod1_stop+ 2),((mod2_stop - mod1_stop) - 1),t_record->template_qual[
       prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag),3))
   ENDIF
   IF (mod3_stop > mod2_stop)
    SET t_record->template_qual[prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag_modifier3 = cnvtupper(
     trim(substring((mod2_stop+ 2),((mod3_stop - mod2_stop) - 1),t_record->template_qual[
       prm_gtm_tempind].tag_qual[prm_gtm_tagind].tag),3))
   ENDIF
 END ;Subroutine
 SUBROUTINE gettemplatetags(prm_gtt_index,prm_gtt_tagtype)
   SET t_record->template_qual[prm_gtt_index].tag_qual_cnt = 0
   SET t_beg = 1
   SET t_end = 0
   SET t_beg2 = 0
   SET t_tag = fillstring(256," ")
   SET t_temp = 0
   WHILE (t_beg > 0)
     SET t_temp = t_beg
     SET t_beg = findstring(tag_start,t_record->template_qual[prm_gtt_index].template,t_beg)
     IF (t_beg > 0)
      SET t_beg2 = findstring(tag_start,t_record->template_qual[prm_gtt_index].template,(t_beg+ size(
        tag_start)))
     ELSE
      SET t_beg2 = 0
     ENDIF
     SET t_end = findstring(tag_end,t_record->template_qual[prm_gtt_index].template,t_temp)
     IF (t_beg > 0
      AND t_end > t_beg
      AND ((t_beg2=0) OR (t_beg2 > t_end)) )
      SET g_gettagtype = - (1)
      SET t_tag = substring((t_beg+ size(tag_start)),((((t_end - t_beg)+ 1) - size(tag_start)) - size
       (tag_end)),t_record->template_qual[prm_gtt_index].template)
      CALL gettagtype(t_tag)
      IF (((prm_gtt_tagtype=tagtypeall) OR (prm_gtt_tagtype=g_gettagtype)) )
       SET t_record->template_qual[prm_gtt_index].tag_qual_cnt += 1
       IF (mod(t_record->template_qual[prm_gtt_index].tag_qual_cnt,10)=1)
        SET stat = alterlist(t_record->template_qual[prm_gtt_index].tag_qual,(t_record->
         template_qual[prm_gtt_index].tag_qual_cnt+ 10))
       ENDIF
       SET t_record->template_qual[prm_gtt_index].tag_qual[t_record->template_qual[prm_gtt_index].
       tag_qual_cnt].tag = t_tag
       SET t_record->template_qual[prm_gtt_index].tag_qual[t_record->template_qual[prm_gtt_index].
       tag_qual_cnt].tag_start = t_beg
       SET t_record->template_qual[prm_gtt_index].tag_qual[t_record->template_qual[prm_gtt_index].
       tag_qual_cnt].tag_end = t_end
       SET t_record->template_qual[prm_gtt_index].tag_qual[t_record->template_qual[prm_gtt_index].
       tag_qual_cnt].tag_type = g_gettagtype
       CALL gettagmodifiers(prm_gtt_index,t_record->template_qual[prm_gtt_index].tag_qual_cnt)
      ENDIF
      SET t_beg = (t_end+ size(tag_end))
     ELSEIF (((t_beg > 0) OR (t_end > 0)) )
      SET cv_log_level = cv_log_error
      CALL cv_log_current_default(0)
      SET t_tag = substring(t_beg,((t_end - t_beg)+ 1),t_record->template_qual[prm_gtt_index].
       template)
      CALL cv_log_message(build("Ill-formed tag:",t_tag))
      CALL cv_log_message(build("   t_beg:",t_beg," t_beg2:",t_beg2," t_end:",
        t_end))
      SET t_beg = 0
     ENDIF
   ENDWHILE
   SET stat = alterlist(t_record->template_qual[prm_gtt_index].tag_qual,t_record->template_qual[
    prm_gtt_index].tag_qual_cnt)
 END ;Subroutine
 SUBROUTINE getmaxtemplates(cv_dummy)
  SET g_maxtemplates = 100
  SELECT INTO "NL:"
   FROM dm_prefs dp
   WHERE trim(dp.pref_domain,3)=dmprefs_domain
    AND trim(dp.pref_section,3)=dmprefs_section
    AND trim(dp.pref_name,3)=dmprefs_name
   DETAIL
    g_maxtemplates = dp.pref_nbr
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE updateassessmentmgmttagvalues(null)
   DECLARE lmaassesspatlvlspf = i4 WITH public, constant(66)
   DECLARE lmamgmtpatlvlspf = i4 WITH public, constant(67)
   DECLARE lmaassessrtbreastspf = i4 WITH public, constant(68)
   DECLARE lmamgmtrtbreastspf = i4 WITH public, constant(69)
   DECLARE lmaassessltbreastspf = i4 WITH public, constant(70)
   DECLARE lmamgmtltbreastspf = i4 WITH public, constant(71)
   DECLARE lusassesspatlvlspf = i4 WITH public, constant(75)
   DECLARE lusmgmtpatlvlspf = i4 WITH public, constant(76)
   DECLARE lusassessrtbreastspf = i4 WITH public, constant(78)
   DECLARE lusmgmtrtbreastspf = i4 WITH public, constant(79)
   DECLARE lusassessltbreastspf = i4 WITH public, constant(80)
   DECLARE lusmgmtltbreastspf = i4 WITH public, constant(81)
   DECLARE lmriassesspatlvlspf = i4 WITH public, constant(85)
   DECLARE lmrimgmtpatlvlspf = i4 WITH public, constant(86)
   DECLARE lmriassessrtbreastspf = i4 WITH public, constant(92)
   DECLARE lmrimgmtrtbreastspf = i4 WITH public, constant(93)
   DECLARE lmriassessltbreastspf = i4 WITH public, constant(94)
   DECLARE lmrimgmtltbreastspf = i4 WITH public, constant(95)
   DECLARE loverallassesspatlvlspf = i4 WITH public, constant(72)
   DECLARE loverallassessrtbreastspf = i4 WITH public, constant(73)
   DECLARE loverallassessltbreastspf = i4 WITH public, constant(74)
   SELECT INTO "nl:"
    FROM rad_mammo_study_assess_mgmt_r rmsa,
     mammo_study ms
    PLAN (ms
     WHERE (ms.study_id=t_record->visit[1].study_id)
      AND ms.edition_nbr >= 50)
     JOIN (rmsa
     WHERE rmsa.study_id=ms.study_id)
    DETAIL
     CASE (rmsa.special_process_flag)
      OF lmaassesspatlvlspf:
      OF lusassesspatlvlspf:
      OF lmriassesspatlvlspf:
      OF 115:
      OF 119:
      OF 124:
      OF 128:
      OF 133:
      OF 137:
       IF (rmsa.final_assess_ind=1)
        t_radiology_record->assess_pat_lvl_id = rmsa.follow_up_field_id
       ENDIF
      OF lmamgmtpatlvlspf:
      OF lusmgmtpatlvlspf:
      OF lmrimgmtpatlvlspf:
       t_radiology_record->mgmt_pat_lvl_id = rmsa.follow_up_field_id
      OF lmaassessrtbreastspf:
      OF lusassessrtbreastspf:
      OF lmriassessrtbreastspf:
      OF 116:
      OF 120:
      OF 125:
      OF 129:
      OF 134:
      OF 138:
       IF (rmsa.final_assess_ind=1)
        t_radiology_record->assess_right_breast_id = rmsa.follow_up_field_id
       ENDIF
      OF lmamgmtrtbreastspf:
      OF lusmgmtrtbreastspf:
      OF lmrimgmtrtbreastspf:
       t_radiology_record->mgmt_right_breast_id = rmsa.follow_up_field_id
      OF lmaassessltbreastspf:
      OF lusassessltbreastspf:
      OF lmriassessltbreastspf:
      OF 117:
      OF 121:
      OF 126:
      OF 130:
      OF 135:
      OF 139:
       IF (rmsa.final_assess_ind=1)
        t_radiology_record->assess_left_breast_id = rmsa.follow_up_field_id
       ENDIF
      OF lmamgmtltbreastspf:
      OF lusmgmtltbreastspf:
      OF lmrimgmtltbreastspf:
       t_radiology_record->mgmt_left_breast_id = rmsa.follow_up_field_id
      OF loverallassesspatlvlspf:
       t_radiology_record->overall_assess_pat_lvl_id = rmsa.follow_up_field_id
      OF loverallassessrtbreastspf:
       t_radiology_record->overall_assess_right_breast_id = rmsa.follow_up_field_id
      OF loverallassessltbreastspf:
       t_radiology_record->overall_assess_left_breast_id = rmsa.follow_up_field_id
     ENDCASE
    WITH nocounter
   ;end select
 END ;Subroutine
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(sysdate),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE (cv_log_destroyhandle(dummy=i2) =null)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt -= 1
   ENDIF
 END ;Subroutine
END GO
