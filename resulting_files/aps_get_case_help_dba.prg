CREATE PROGRAM aps_get_case_help:dba
 RECORD temp_rsrc_security(
   1 l_cnt = i4
   1 list[*]
     2 service_resource_cd = f8
     2 viewable_srvc_rsrc_ind = i2
   1 security_enabled = i2
 )
 RECORD default_service_type_cd(
   1 service_type_cd_list[*]
     2 service_type_cd = f8
 )
 DECLARE nres_sec_failed = i2 WITH protect, constant(0)
 DECLARE nres_sec_passed = i2 WITH protect, constant(1)
 DECLARE nres_sec_err = i2 WITH protect, constant(2)
 DECLARE nres_sec_msg_type = i2 WITH protect, constant(0)
 DECLARE ncase_sec_msg_type = i2 WITH protect, constant(1)
 DECLARE ncorr_group_sec_msg_type = i2 WITH protect, constant(2)
 DECLARE sres_sec_error_msg = c23 WITH protect, constant("RESOURCE SECURITY ERROR")
 DECLARE sres_sec_failed_msg = c24 WITH protect, constant("RESOURCE SECURITY FAILED")
 DECLARE scase_sec_failed_msg = c20 WITH protect, constant("CASE SECURITY FAILED")
 DECLARE scorr_group_sec_failed_msg = c24 WITH protect, constant("CORR GRP SECURITY FAILED")
 DECLARE m_nressecind = i2 WITH protect, noconstant(0)
 DECLARE m_sressecstatus = c1 WITH protect, noconstant("S")
 DECLARE m_nressecapistatus = i2 WITH protect, noconstant(0)
 DECLARE m_nressecerrorind = i2 WITH protect, noconstant(0)
 DECLARE m_lressecfailedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_lresseccheckedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nressecalterstatus = i2 WITH protect, noconstant(0)
 DECLARE m_lressecstatusblockcnt = i4 WITH protect, noconstant(0)
 DECLARE m_ntaskgrantedind = i2 WITH protect, noconstant(0)
 DECLARE m_sfailedmsg = c25 WITH protect
 DECLARE m_bresourceapicalled = i2 WITH protect, noconstant(0)
 SET temp_rsrc_security->l_cnt = 0
 SUBROUTINE (initresourcesecurity(resource_security_ind=i2) =null)
   IF (resource_security_ind=1)
    SET m_nressecind = true
   ELSE
    SET m_nressecind = false
   ENDIF
 END ;Subroutine
 SUBROUTINE (isresourceviewable(service_resource_cd=f8) =i2)
   DECLARE srvc_rsrc_idx = i4 WITH protect, noconstant(0)
   DECLARE l_srvc_rsrc_pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET m_lresseccheckedcnt += 1
   IF (m_nressecind=false)
    RETURN(true)
   ENDIF
   IF (m_nressecerrorind=true)
    RETURN(false)
   ENDIF
   IF (service_resource_cd=0)
    RETURN(true)
   ENDIF
   IF (m_bresourceapicalled=true)
    IF ((temp_rsrc_security->security_enabled=1)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((temp_rsrc_security->security_enabled=0)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_passed
    ELSEIF ((temp_rsrc_security->l_cnt > 0))
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ELSE
    RECORD request_3202551(
      1 prsnl_id = f8
      1 explicit_ind = i4
      1 debug_ind = i4
      1 service_type_cd_list[*]
        2 service_type_cd = f8
    )
    RECORD reply_3202551(
      1 security_enabled = i2
      1 service_resource_list[*]
        2 service_resource_cd = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET request_3202551->prsnl_id = reqinfo->updt_id
    IF (size(default_service_type_cd->service_type_cd_list,5) > 0)
     SET stat = alterlist(request_3202551->service_type_cd_list,size(default_service_type_cd->
       service_type_cd_list,5))
     FOR (idx = 1 TO size(default_service_type_cd->service_type_cd_list,5))
       SET request_3202551->service_type_cd_list[idx].service_type_cd = default_service_type_cd->
       service_type_cd_list[idx].service_type_cd
     ENDFOR
    ELSE
     SET stat = alterlist(request_3202551->service_type_cd_list,5)
     SET request_3202551->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",223,
      "SECTION")
     SET request_3202551->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",223,
      "SUBSECTION")
     SET request_3202551->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",223,
      "BENCH")
     SET request_3202551->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",223,
      "INSTRUMENT")
     SET request_3202551->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",223,
      "DEPARTMENT")
    ENDIF
    EXECUTE msvc_get_prsnl_svc_resources  WITH replace("REQUEST",request_3202551), replace("REPLY",
     reply_3202551)
    SET m_bresourceapicalled = true
    IF ((reply_3202551->status_data.status != "S"))
     SET m_nressecapistatus = nres_sec_err
    ELSEIF ((reply_3202551->security_enabled=1)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 1
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((reply_3202551->security_enabled=0)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 0
     SET m_nressecapistatus = nres_sec_passed
    ELSE
     SET temp_rsrc_security->l_cnt = size(reply_3202551->service_resource_list,5)
     SET temp_rsrc_security->security_enabled = reply_3202551->security_enabled
     IF ((temp_rsrc_security->l_cnt > 0))
      SET stat = alterlist(temp_rsrc_security->list,temp_rsrc_security->l_cnt)
      FOR (idx = 1 TO size(reply_3202551->service_resource_list,5))
       SET temp_rsrc_security->list[idx].service_resource_cd = reply_3202551->service_resource_list[
       idx].service_resource_cd
       SET temp_rsrc_security->list[idx].viewable_srvc_rsrc_ind = 1
      ENDFOR
     ENDIF
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ENDIF
   CASE (m_nressecapistatus)
    OF nres_sec_passed:
     RETURN(true)
    OF nres_sec_failed:
     SET m_lressecfailedcnt += 1
     RETURN(false)
    ELSE
     SET m_nressecerrorind = true
     RETURN(false)
   ENDCASE
 END ;Subroutine
 SUBROUTINE (getresourcesecuritystatus(fail_all_ind=i2) =c1)
  IF (m_nressecerrorind=true)
   SET m_sressecstatus = "F"
  ELSEIF (m_lresseccheckedcnt > 0
   AND m_lresseccheckedcnt=m_lressecfailedcnt)
   SET m_sressecstatus = "Z"
  ELSEIF (fail_all_ind=1
   AND m_lressecfailedcnt > 0)
   SET m_sressecstatus = "Z"
  ELSE
   SET m_sressecstatus = "S"
  ENDIF
  RETURN(m_sressecstatus)
 END ;Subroutine
 SUBROUTINE (populateressecstatusblock(message_type=i2) =null)
   IF (((m_sressecstatus="S") OR (validate(reply->status_data.status,"-1")="-1")) )
    RETURN
   ENDIF
   SET m_lressecstatusblockcnt = size(reply->status_data.subeventstatus,5)
   IF (m_lressecstatusblockcnt=1
    AND trim(reply->status_data.subeventstatus[1].operationname)="")
    SET m_ressecalterstatus = 0
   ELSE
    SET m_lressecstatusblockcnt += 1
    SET m_nressecalterstatus = alter(reply->status_data.subeventstatus,m_lressecstatusblockcnt)
   ENDIF
   CASE (message_type)
    OF ncase_sec_msg_type:
     SET m_sfailedmsg = scase_sec_failed_msg
    OF ncorr_group_sec_msg_type:
     SET m_sfailedmsg = scorr_group_sec_failed_msg
    ELSE
     SET m_sfailedmsg = sres_sec_failed_msg
   ENDCASE
   CASE (m_sressecstatus)
    OF "F":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname =
     sres_sec_error_msg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "F"
    OF "Z":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname = m_sfailedmsg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "Z"
   ENDCASE
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4) =i2)
   SET m_ntaskgrantedind = false
   SELECT INTO "nl:"
    FROM application_group ag,
     task_access ta
    PLAN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (ta
     WHERE ta.app_group_cd=ag.app_group_cd
      AND ta.task_number=task_number)
    DETAIL
     m_ntaskgrantedind = true
    WITH nocounter
   ;end select
   RETURN(m_ntaskgrantedind)
 END ;Subroutine
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
 DECLARE susername = c50 WITH protect, noconstant("")
 DECLARE nstatus = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE sunknownstring = vc WITH protect, noconstant("")
 DECLARE sstillbornstring = vc WITH protect, noconstant("")
 SET nstatus = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET sunknownstring = uar_i18ngetmessage(i18nhandle,"UNKNOWN_AGE","Unknown")
 SET sstillbornstring = uar_i18ngetmessage(i18nhandle,"STILLBORN_AGE","Stillborn")
 SELECT INTO "nl:"
  FROM prsnl pl
  WHERE (person_id=reqinfo->updt_id)
  DETAIL
   susername = pl.username
  WITH nocounter
 ;end select
 SUBROUTINE (formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) =vc WITH protect)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",trim(cnvtstring
       (reqinfo->position_cd,32,2)))))
   ENDIF
 END ;Subroutine
 RECORD reply(
   1 context_ind = i4
   1 qual[10]
     2 case_id = f8
     2 case_collect_dt_tm = dq8
     2 prefix_cd = f8
     2 accession_nbr = c21
     2 case_year = i4
     2 case_number = i4
     2 physician_name = vc
     2 specimen_cnt = i2
     2 spec_qual[*]
       3 specimen_tag_display = c7
       3 specimen_description = vc
     2 person_id = f8
     2 encntr_id = f8
     2 person_name = vc
     2 person_num = c16
     2 birth_dt_tm = dq8
     2 deceased_dt_tm = dq8
     2 age = vc
     2 sex_cd = f8
     2 sex_disp = c40
     2 birth_tz = i4
     2 fill_ext_accession_id = f8
     2 ext_acc_qual[*]
       3 accession_external_summary_id = f8
       3 active_indicator = i4
       3 update_count = i4
       3 int_identifier[*]
         4 accession_id = f8
       3 ext_identifier[*]
         4 unformatted_external_accession = c40
         4 formatted_external_accession = c40
       3 summary[*]
         4 collect_dt = dq8
         4 comment_id = f8
         4 comment_text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET spec_cnt = 1
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET mrn_alias_type_cd = 0.0
 SET ssoundextrue = "N"
 SET patient_name_where = fillstring(200," ")
 DECLARE nzeropos = i4 WITH protect, noconstant(0)
 DECLARE ssoundexnamefield = vc WITH protect, noconstant("")
 CALL initresourcesecurity(1)
 DECLARE ncaseidx = i2 WITH protect, noconstant(0)
 DECLARE nspecidx = i2 WITH protect, noconstant(0)
 IF (validate(context->context_ind,0)=0)
  RECORD context(
    1 prefix_cd = f8
    1 case_year = i4
    1 case_number = i4
    1 accession_nbr = c21
    1 first_name = vc
    1 last_name = vc
    1 ssoundexind = c1
    1 context_ind = i4
    1 soutsidecasenbr = c42
    1 person_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  IF ((request->prefix_cd > 0)
   AND (request->case_year > 0)
   AND (request->case_number > 0))
   EXECUTE aps_get_case_help_1
   GO TO exit_script
  ENDIF
  IF (textlen(trim(cnvtalphanum(request->soutsidecasenbr,3))) > 0)
   SET context->soutsidecasenbr = trim(cnvtupper(cnvtalphanum(request->soutsidecasenbr,3)))
   SET patient_name_where = build(0," = ",0)
  ELSE
   IF ((request->person_id > 0))
    SET context->person_id = request->person_id
    SET patient_name_where = build(request->person_id," = P.PERSON_ID")
   ELSE
    IF (textlen(trim(request->first_name)) > 0)
     SET context->first_name = request->first_name
    ELSE
     SET context->first_name = ""
    ENDIF
    SET context->last_name = request->last_name
    SET context->ssoundexind = request->ssoundexind
    SET last_name_field = build(cnvtupper(cnvtalphanum(request->last_name)),"*")
    SET first_name_field = build(cnvtupper(cnvtalphanum(request->first_name)),"*")
    IF ((request->ssoundexind="Y"))
     SET ssoundextrue = "Y"
     SET ssoundexnamefield = trim(soundex(last_name_field))
     SET nzeropos = findstring("0",ssoundexnamefield,1,0)
     IF (nzeropos > 0)
      SET ssoundexnamefield = build(substring(1,(nzeropos - 1),ssoundexnamefield),"*")
     ELSEIF (textlen(ssoundexnamefield) < 8)
      SET ssoundexnamefield = concat(ssoundexnamefield,"*")
     ENDIF
     SET patient_name_where = concat("P.NAME_LAST_PHONETIC = '",trim(ssoundexnamefield),"'")
     IF ((request->first_name > " "))
      SET ssoundexnamefield = soundex(first_name_field)
      SET nzeropos = findstring("0",ssoundexnamefield,1,0)
      IF (nzeropos > 0)
       SET ssoundexnamefield = build(substring(1,(nzeropos - 1),ssoundexnamefield),"*")
      ELSEIF (textlen(ssoundexnamefield) < 8)
       SET ssoundexnamefield = concat(ssoundexnamefield,"*")
      ENDIF
      SET patient_name_where = concat(trim(patient_name_where)," AND ","P.NAME_FIRST_PHONETIC = '",
       trim(ssoundexnamefield),"'")
     ENDIF
    ELSE
     SET patient_name_where = concat(" p.name_last_key = '",last_name_field,"'")
     SET patient_name_where = build(patient_name_where," and p.name_first_key = '",first_name_field,
      "'")
    ENDIF
   ENDIF
  ENDIF
  SET accession_nbr_where = build(0," = ",0)
 ELSE
  IF ((context->prefix_cd > 0)
   AND (context->case_year > 0)
   AND (context->case_number > 0))
   EXECUTE aps_get_case_help_1
   GO TO exit_script
  ENDIF
  IF (textlen(trim(cnvtalphanum(context->soutsidecasenbr,3))) > 0)
   SET patient_name_where = build(0," = ",0)
  ELSE
   IF ((context->person_id > 0))
    SET patient_name_where = build(context->person_id," = P.PERSON_ID")
   ELSE
    SET last_name_field = build(cnvtupper(cnvtalphanum(context->last_name)),"*")
    SET first_name_field = build(cnvtupper(cnvtalphanum(context->first_name)),"*")
    IF ((context->ssoundexind="Y"))
     SET ssoundextrue = "Y"
     SET ssoundexnamefield = trim(soundex(last_name_field))
     SET nzeropos = findstring("0",ssoundexnamefield,1,0)
     IF (nzeropos > 0)
      SET ssoundexnamefield = build(substring(1,(nzeropos - 1),ssoundexnamefield),"*")
     ELSEIF (textlen(ssoundexnamefield) < 8)
      SET ssoundexnamefield = concat(ssoundexnamefield,"*")
     ENDIF
     SET patient_name_where = concat("P.NAME_LAST_PHONETIC = '",trim(ssoundexnamefield),"'")
     IF ((context->first_name > " "))
      SET ssoundexnamefield = soundex(first_name_field)
      SET nzeropos = findstring("0",ssoundexnamefield,1,0)
      IF (nzeropos > 0)
       SET ssoundexnamefield = build(substring(1,(nzeropos - 1),ssoundexnamefield),"*")
      ELSEIF (textlen(ssoundexnamefield) < 8)
       SET ssoundexnamefield = concat(ssoundexnamefield,"*")
      ENDIF
      SET patient_name_where = concat(trim(patient_name_where)," AND ","P.NAME_FIRST_PHONETIC = '",
       trim(ssoundexnamefield),"'")
     ENDIF
    ELSE
     SET patient_name_where = concat(" p.name_last_key = '",last_name_field,"'")
     SET patient_name_where = build(patient_name_where," and p.name_first_key = '",first_name_field,
      "'")
    ENDIF
   ENDIF
  ENDIF
  IF (textlen(trim(context->accession_nbr)) > 0)
   SET accession_nbr_where = build("'",context->accession_nbr,"' >= pc.accession_nbr ")
  ELSE
   SET accession_nbr_where = build(0," = ",0)
  ENDIF
 ENDIF
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
 SELECT
  IF (textlen(trim(context->soutsidecasenbr)) > 0)
   FROM accession_external_smry aes,
    pathology_case pc,
    person p,
    prsnl pr,
    ap_prefix ap,
    case_specimen cs,
    ap_tag t
   PLAN (aes
    WHERE (aes.external_accession_key=context->soutsidecasenbr))
    JOIN (pc
    WHERE pc.case_id=aes.accession_id
     AND pc.cancel_cd IN (null, 0)
     AND parser(accession_nbr_where))
    JOIN (p
    WHERE pc.person_id=p.person_id)
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (ap
    WHERE ap.prefix_id=pc.prefix_id)
    JOIN (cs
    WHERE (cs.case_id= Outerjoin(pc.case_id)) )
    JOIN (t
    WHERE (t.tag_id= Outerjoin(cs.specimen_tag_id)) )
   ORDER BY pc.accession_nbr DESC, t_tag_group_id, t_tag_sequence
  ELSE
   FROM pathology_case pc,
    person p,
    prsnl pr,
    ap_prefix ap,
    case_specimen cs,
    ap_tag t
   PLAN (p
    WHERE parser(patient_name_where))
    JOIN (pc
    WHERE p.person_id=pc.person_id
     AND pc.cancel_cd IN (null, 0)
     AND parser(accession_nbr_where))
    JOIN (pr
    WHERE pc.requesting_physician_id=pr.person_id)
    JOIN (ap
    WHERE ap.prefix_id=pc.prefix_id)
    JOIN (cs
    WHERE (cs.case_id= Outerjoin(pc.case_id)) )
    JOIN (t
    WHERE (t.tag_id= Outerjoin(cs.specimen_tag_id)) )
   ORDER BY p.name_last_key DESC, case_collect_dt_tm DESC, pc.accession_nbr DESC,
    t_tag_group_id, t_tag_sequence
  ENDIF
  INTO "nl:"
  pc.case_id, case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm), pc.prefix_id,
  pc.case_year, pc.case_number, patient_exists = evaluate(nullind(p.seq),0,"Y",1,"N"),
  p.person_id, p.name_full_formatted, p.sex_cd,
  p.birth_dt_tm, p.deceased_dt_tm, pr.name_full_formatted,
  nspecrowexist = evaluate(nullind(cs.seq),0,"Y",1,"N"), cs.specimen_description, t_tag_group_id =
  evaluate(nullind(t.tag_group_id),0,t.tag_group_id,1,0.0),
  t_tag_sequence = evaluate(nullind(t.tag_sequence),0,t.tag_sequence,1,0), t_tag_disp = evaluate(
   nullind(t.tag_disp),0,t.tag_disp,1," "), deceased_date_exists = evaluate(nullind(p.deceased_dt_tm),
   1,0,1),
  nspecvalid1 = nullind(cs.cancel_cd), nspecvalid2 = evaluate(cs.cancel_cd,0.0,1,0)
  HEAD REPORT
   cnt = 0, reply->context_ind = 0, context->context_ind = 0,
   access_to_resource_ind = 0, service_resource_cd = 0.0
  HEAD pc.case_id
   access_to_resource_ind = 0, service_resource_cd = ap.service_resource_cd
   IF (isresourceviewable(service_resource_cd)=true)
    access_to_resource_ind = 1, cnt1 = 0, cnt += 1
    IF (cnt < 101)
     IF (mod(cnt,10)=1
      AND cnt != 1)
      stat = alter(reply->qual,(cnt+ 9))
     ENDIF
     reply->qual[cnt].case_id = pc.case_id, reply->qual[cnt].fill_ext_accession_id = pc.case_id,
     reply->qual[cnt].case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm),
     reply->qual[cnt].prefix_cd = pc.prefix_id, reply->qual[cnt].accession_nbr = pc.accession_nbr,
     reply->qual[cnt].case_year = pc.case_year,
     reply->qual[cnt].case_number = pc.case_number, reply->qual[cnt].physician_name = pr
     .name_full_formatted, reply->qual[cnt].encntr_id = pc.encntr_id
     IF (patient_exists="Y")
      reply->qual[cnt].person_id = p.person_id, reply->qual[cnt].person_name = p.name_full_formatted,
      reply->qual[cnt].sex_cd = p.sex_cd,
      reply->qual[cnt].birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->qual[cnt].birth_tz = p
      .birth_tz
      IF (curutc=1)
       reply->qual[cnt].age = formatage(datetimezone(p.birth_dt_tm,p.birth_tz),p.deceased_dt_tm,
        "CHRONOAGE")
      ELSE
       reply->qual[cnt].age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"CHRONOAGE")
      ENDIF
      IF (deceased_date_exists != 0)
       reply->qual[cnt].deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm)
      ELSE
       reply->qual[cnt].deceased_dt_tm = 0
      ENDIF
     ENDIF
     stat = alterlist(reply->qual[cnt].spec_qual,1)
    ENDIF
    IF (cnt=101)
     reply->context_ind = 1, context->context_ind = 1, context->accession_nbr = pc.accession_nbr
    ENDIF
   ENDIF
  DETAIL
   IF (access_to_resource_ind=1)
    IF (cnt < 101)
     IF (nspecrowexist="Y"
      AND ((nspecvalid1=1) OR (nspecvalid2=1)) )
      cnt1 += 1
      IF (cnt1 > 1)
       stat = alterlist(reply->qual[cnt].spec_qual,cnt1)
      ENDIF
      reply->qual[cnt].specimen_cnt = cnt1, reply->qual[cnt].spec_qual[cnt1].specimen_description =
      cs.specimen_description, reply->qual[cnt].spec_qual[cnt1].specimen_tag_display = t_tag_disp
     ENDIF
    ENDIF
   ENDIF
  FOOT  pc.case_id
   IF (access_to_resource_ind=1)
    IF (cnt < 101)
     IF (cnt1=0)
      stat = alterlist(reply->qual[cnt].spec_qual,0)
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
 ELSEIF (getresourcesecuritystatus(0) != "S")
  SET reply->status_data.status = getresourcesecuritystatus(0)
  CALL populateressecstatusblock(1)
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cnt=0)
  SET stat = alter(reply->qual,cnt)
  GO TO exit_script
 ELSEIF (cnt < 101)
  SET stat = alter(reply->qual,cnt)
 ENDIF
 SELECT INTO "nl:"
  frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   encntr_alias ea
  PLAN (d1
   WHERE (reply->qual[d1.seq].encntr_id > 0))
   JOIN (ea
   WHERE (ea.encntr_id=reply->qual[d1.seq].encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   reply->qual[d1.seq].person_num = frmt_mrn
  WITH nocounter
 ;end select
#exit_script
 IF (size(reply->qual,5) > 0)
  IF ((reply->status_data.status="S"))
   EXECUTE pcs_fill_ext_accs_by_acc  WITH replace("REQUESTREPLY","REPLY")
   IF ((reply->status_data.status="Z"))
    SET reply->status_data.status = "S"
   ENDIF
  ENDIF
 ENDIF
END GO
