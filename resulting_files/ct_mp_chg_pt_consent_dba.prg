CREATE PROGRAM ct_mp_chg_pt_consent:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsonrequest
 RECORD reply(
   1 statuscon = c1
   1 statusrltn = c1
   1 ptconsentid = f8
   1 scs_funcstatus = c1
   1 statusfunc = c1
   1 a_c_results[*]
     2 a_key = vc
     2 stratumstatus = c1
     2 prot_stratum_id = f8
     2 stratum_id = f8
     2 suspsummary = c1
     2 cohortsummary = c1
     2 susps[*]
       3 a_key = vc
       3 suspstatus = c1
       3 prot_stratum_susp_id = f8
       3 susp_id = f8
     2 cohorts[*]
       3 a_key = vc
       3 cohortstatus = c1
       3 prot_cohort_id = f8
       3 cohort_id = f8
   1 probdesc[*]
     2 str = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD c(
   1 currentdatetime = dq8
   1 prot_amendment_id = f8
   1 consent_id = f8
   1 pt_consent_id = f8
   1 consenting_person_id = f8
   1 consenting_organization_id = f8
   1 consent_released_dt_tm = dq8
   1 consent_signed_dt_tm = dq8
   1 consent_received_dt_tm = dq8
   1 consent_nbr = i4
   1 updt_cnt = i4
   1 not_returned_dt_tm = dq8
   1 not_returned_reason_cd = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 not_returned_dt_tm = dq8
   1 not_returned_reason_cd = f8
   1 reason_for_consent_cd = f8
   1 ct_document_version_id = f8
   1 person_id = f8
   1 updt_dt_tm = dq8
 )
 RECORD audits(
   1 qual[*]
     2 eventname = vc
     2 eventtype = vc
 )
 RECORD pt_amd_assignment(
   1 reg_id = f8
   1 prot_amendment_id = f8
   1 transfer_checked_amendment_id = f8
   1 assign_start_dt_tm = dq8
   1 assign_end_dt_tm = dq8
 )
 RECORD pref_reply(
   1 pref_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD status_request(
   1 pt_prot_prescreen_id = f8
   1 status_cd = f8
   1 status_comment_text = vc
 )
 RECORD status_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD request
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE current_time_zone = i4 WITH constant(datetimezonebyname(curtimezone)), protect
 DECLARE ending_date_time = dq8 WITH constant(cnvtdatetime("31-DEC-2100")), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE lower_bound_date = vc WITH constant("01-JAN-1800 00:00:00.00"), protect
 DECLARE upper_bound_date = vc WITH constant("31-DEC-2100 23:59:59.99"), protect
 DECLARE codelistcnt = i4 WITH noconstant(0), protect
 DECLARE prsnllistcnt = i4 WITH noconstant(0), protect
 DECLARE phonelistcnt = i4 WITH noconstant(0), protect
 DECLARE code_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_idx = i4 WITH noconstant(0), protect
 DECLARE phone_idx = i4 WITH noconstant(0), protect
 DECLARE prsnl_cnt = i4 WITH noconstant(0), protect
 DECLARE mpc_ap_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_doc_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_mdoc_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_rad_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_txt_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_num_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_immun_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_med_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_date_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_done_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_mbo_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_procedure_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_grp_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mpc_hlatyping_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE eventclasscdpopulated = i2 WITH protect, noconstant(0)
 DECLARE getorgsecurityflag(null) = i2 WITH protect
 DECLARE cclimpersonation(null) = null WITH protect
 SUBROUTINE (addcodetolist(code_value=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (code_value != 0)
    IF (((codelistcnt=0) OR (locateval(code_idx,1,codelistcnt,code_value,record_data->codes[code_idx]
     .code) <= 0)) )
     SET codelistcnt += 1
     SET stat = alterlist(record_data->codes,codelistcnt)
     SET record_data->codes[codelistcnt].code = code_value
     SET record_data->codes[codelistcnt].sequence = uar_get_collation_seq(code_value)
     SET record_data->codes[codelistcnt].meaning = uar_get_code_meaning(code_value)
     SET record_data->codes[codelistcnt].display = uar_get_code_display(code_value)
     SET record_data->codes[codelistcnt].description = uar_get_code_description(code_value)
     SET record_data->codes[codelistcnt].code_set = uar_get_code_set(code_value)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputcodelist(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputCodeList() @deprecated",log_level_debug)
 END ;Subroutine
 SUBROUTINE (addpersonneltolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   CALL addpersonneltolistwithdate(prsnl_id,record_data,current_date_time)
 END ;Subroutine
 SUBROUTINE (addpersonneltolistwithdate(prsnl_id=f8(val),record_data=vc(ref),active_date=f8(val)) =
  null WITH protect)
   DECLARE personnel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   IF (((active_date=null) OR (active_date=0.0)) )
    SET active_date = current_date_time
   ENDIF
   IF (prsnl_id != 0)
    IF (((prsnllistcnt=0) OR (locateval(prsnl_idx,1,prsnllistcnt,prsnl_id,record_data->prsnl[
     prsnl_idx].id,
     active_date,record_data->prsnl[prsnl_idx].active_date) <= 0)) )
     SET prsnllistcnt += 1
     IF (prsnllistcnt > size(record_data->prsnl,5))
      SET stat = alterlist(record_data->prsnl,(prsnllistcnt+ 9))
     ENDIF
     SET record_data->prsnl[prsnllistcnt].id = prsnl_id
     IF (validate(record_data->prsnl[prsnllistcnt].active_date) != 0)
      SET record_data->prsnl[prsnllistcnt].active_date = active_date
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputpersonnellist(report_data=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPersonnelList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE prsnl_name_type_cd = f8 WITH constant(uar_get_code_by("MEANING",213,"PRSNL")), protect
   DECLARE active_date_ind = i2 WITH protect, noconstant(0)
   DECLARE filteredcnt = i4 WITH protect, noconstant(0)
   DECLARE prsnl_seq = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   IF (prsnllistcnt > 0)
    SELECT INTO "nl:"
     FROM prsnl p,
      (left JOIN person_name pn ON pn.person_id=p.person_id
       AND pn.name_type_cd=prsnl_name_type_cd
       AND pn.active_ind=1)
     PLAN (p
      WHERE expand(idx,1,size(report_data->prsnl,5),p.person_id,report_data->prsnl[idx].id))
      JOIN (pn)
     ORDER BY p.person_id, pn.end_effective_dt_tm DESC
     HEAD REPORT
      prsnl_seq = 0, active_date_ind = validate(report_data->prsnl[1].active_date,0)
     HEAD p.person_id
      IF (active_date_ind=0)
       prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id)
       IF (pn.person_id > 0)
        report_data->prsnl[prsnl_seq].provider_name.name_full = trim(pn.name_full,3), report_data->
        prsnl[prsnl_seq].provider_name.name_first = trim(pn.name_first,3), report_data->prsnl[
        prsnl_seq].provider_name.name_middle = trim(pn.name_middle,3),
        report_data->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3), report_data->
        prsnl[prsnl_seq].provider_name.username = trim(p.username,3), report_data->prsnl[prsnl_seq].
        provider_name.initials = trim(pn.name_initials,3),
        report_data->prsnl[prsnl_seq].provider_name.title = trim(pn.name_initials,3)
       ELSE
        report_data->prsnl[prsnl_seq].provider_name.name_full = trim(p.name_full_formatted,3),
        report_data->prsnl[prsnl_seq].provider_name.name_first = trim(p.name_first,3), report_data->
        prsnl[prsnl_seq].provider_name.name_last = trim(p.name_last,3),
        report_data->prsnl[prsnl_seq].provider_name.username = trim(p.username,3)
       ENDIF
      ENDIF
     DETAIL
      IF (active_date_ind != 0)
       prsnl_seq = locateval(idx,1,prsnllistcnt,p.person_id,report_data->prsnl[idx].id)
       WHILE (prsnl_seq > 0)
        IF ((report_data->prsnl[prsnl_seq].active_date BETWEEN pn.beg_effective_dt_tm AND pn
        .end_effective_dt_tm))
         IF (pn.person_id > 0)
          report_data->prsnl[prsnl_seq].person_name_id = pn.person_name_id, report_data->prsnl[
          prsnl_seq].beg_effective_dt_tm = pn.beg_effective_dt_tm, report_data->prsnl[prsnl_seq].
          end_effective_dt_tm = pn.end_effective_dt_tm,
          report_data->prsnl[prsnl_seq].provider_name.name_full = trim(pn.name_full,3), report_data->
          prsnl[prsnl_seq].provider_name.name_first = trim(pn.name_first,3), report_data->prsnl[
          prsnl_seq].provider_name.name_middle = trim(pn.name_middle,3),
          report_data->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3), report_data->
          prsnl[prsnl_seq].provider_name.username = trim(p.username,3), report_data->prsnl[prsnl_seq]
          .provider_name.initials = trim(pn.name_initials,3),
          report_data->prsnl[prsnl_seq].provider_name.title = trim(pn.name_initials,3)
         ELSE
          report_data->prsnl[prsnl_seq].provider_name.name_full = trim(p.name_full_formatted,3),
          report_data->prsnl[prsnl_seq].provider_name.name_first = trim(p.name_first,3), report_data
          ->prsnl[prsnl_seq].provider_name.name_last = trim(pn.name_last,3),
          report_data->prsnl[prsnl_seq].provider_name.username = trim(p.username,3)
         ENDIF
         IF ((report_data->prsnl[prsnl_seq].active_date=current_date_time))
          report_data->prsnl[prsnl_seq].active_date = 0
         ENDIF
        ENDIF
        ,prsnl_seq = locateval(idx,(prsnl_seq+ 1),prsnllistcnt,p.person_id,report_data->prsnl[idx].id
         )
       ENDWHILE
      ENDIF
     FOOT REPORT
      stat = alterlist(report_data->prsnl,prsnllistcnt)
     WITH nocounter
    ;end select
    CALL error_and_zero_check_rec(curqual,"PRSNL","OutputPersonnelList",1,0,
     report_data)
    IF (active_date_ind != 0)
     SELECT INTO "nl:"
      end_effective_dt_tm = report_data->prsnl[d.seq].end_effective_dt_tm, person_name_id =
      report_data->prsnl[d.seq].person_name_id, prsnl_id = report_data->prsnl[d.seq].id
      FROM (dummyt d  WITH seq = size(report_data->prsnl,5))
      ORDER BY end_effective_dt_tm DESC, person_name_id, prsnl_id
      HEAD REPORT
       filteredcnt = 0, idx = size(report_data->prsnl,5), stat = alterlist(report_data->prsnl,(idx *
        2))
      HEAD end_effective_dt_tm
       donothing = 0
      HEAD prsnl_id
       idx += 1, filteredcnt += 1, report_data->prsnl[idx].id = report_data->prsnl[d.seq].id,
       report_data->prsnl[idx].person_name_id = report_data->prsnl[d.seq].person_name_id
       IF ((report_data->prsnl[d.seq].person_name_id > 0.0))
        report_data->prsnl[idx].beg_effective_dt_tm = report_data->prsnl[d.seq].beg_effective_dt_tm,
        report_data->prsnl[idx].end_effective_dt_tm = report_data->prsnl[d.seq].end_effective_dt_tm
       ELSE
        report_data->prsnl[idx].beg_effective_dt_tm = cnvtdatetime("01-JAN-1900"), report_data->
        prsnl[idx].end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
       ENDIF
       report_data->prsnl[idx].provider_name.name_full = report_data->prsnl[d.seq].provider_name.
       name_full, report_data->prsnl[idx].provider_name.name_first = report_data->prsnl[d.seq].
       provider_name.name_first, report_data->prsnl[idx].provider_name.name_middle = report_data->
       prsnl[d.seq].provider_name.name_middle,
       report_data->prsnl[idx].provider_name.name_last = report_data->prsnl[d.seq].provider_name.
       name_last, report_data->prsnl[idx].provider_name.username = report_data->prsnl[d.seq].
       provider_name.username, report_data->prsnl[idx].provider_name.initials = report_data->prsnl[d
       .seq].provider_name.initials,
       report_data->prsnl[idx].provider_name.title = report_data->prsnl[d.seq].provider_name.title
      FOOT REPORT
       stat = alterlist(report_data->prsnl,idx), stat = alterlist(report_data->prsnl,filteredcnt,0)
      WITH nocounter
     ;end select
     CALL error_and_zero_check_rec(curqual,"PRSNL","FilterPersonnelList",1,0,
      report_data)
    ENDIF
   ENDIF
   CALL log_message(build("Exit OutputPersonnelList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addphonestolist(prsnl_id=f8(val),record_data=vc(ref)) =null WITH protect)
   IF (prsnl_id != 0)
    IF (((phonelistcnt=0) OR (locateval(phone_idx,1,phonelistcnt,prsnl_id,record_data->phone_list[
     prsnl_idx].person_id) <= 0)) )
     SET phonelistcnt += 1
     IF (phonelistcnt > size(record_data->phone_list,5))
      SET stat = alterlist(record_data->phone_list,(phonelistcnt+ 9))
     ENDIF
     SET record_data->phone_list[phonelistcnt].person_id = prsnl_id
     SET prsnl_cnt += 1
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (outputphonelist(report_data=vc(ref),phone_types=vc(ref)) =null WITH protect)
   CALL log_message("In OutputPhoneList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE personcnt = i4 WITH protect, constant(size(report_data->phone_list,5))
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx2 = i4 WITH protect, noconstant(0)
   DECLARE idx3 = i4 WITH protect, noconstant(0)
   DECLARE phonecnt = i4 WITH protect, noconstant(0)
   DECLARE prsnlidx = i4 WITH protect, noconstant(0)
   IF (phonelistcnt > 0)
    SELECT
     IF (size(phone_types->phone_codes,5)=0)
      phone_sorter = ph.phone_id
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ph.active_ind=1
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ELSE
      phone_sorter = locateval(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->
       phone_codes[idx2].phone_cd)
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ph.end_effective_dt_tm >= cnvtdatetime(sysdate)
       AND ph.active_ind=1
       AND expand(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->phone_codes[
       idx2].phone_cd)
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ENDIF
     INTO "nl:"
     HEAD ph.parent_entity_id
      phonecnt = 0, prsnlidx = locateval(idx3,1,personcnt,ph.parent_entity_id,report_data->
       phone_list[idx3].person_id)
     HEAD phone_sorter
      phonecnt += 1
      IF (size(report_data->phone_list[prsnlidx].phones,5) < phonecnt)
       stat = alterlist(report_data->phone_list[prsnlidx].phones,(phonecnt+ 5))
      ENDIF
      report_data->phone_list[prsnlidx].phones[phonecnt].phone_id = ph.phone_id, report_data->
      phone_list[prsnlidx].phones[phonecnt].phone_type_cd = ph.phone_type_cd, report_data->
      phone_list[prsnlidx].phones[phonecnt].phone_type = uar_get_code_display(ph.phone_type_cd),
      report_data->phone_list[prsnlidx].phones[phonecnt].phone_num = formatphonenumber(ph.phone_num,
       ph.phone_format_cd,ph.extension)
     FOOT  ph.parent_entity_id
      stat = alterlist(report_data->phone_list[prsnlidx].phones,phonecnt)
     WITH nocounter, expand = value(evaluate(floor(((personcnt - 1)/ 30)),0,0,1))
    ;end select
    SET stat = alterlist(report_data->phone_list,prsnl_cnt)
    CALL error_and_zero_check_rec(curqual,"PHONE","OutputPhoneList",1,0,
     report_data)
   ENDIF
   CALL log_message(build("Exit OutputPhoneList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putstringtofile(svalue=vc(val)) =null WITH protect)
   CALL log_message("In PutStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (validate(_memory_reply_string)=1)
    SET _memory_reply_string = svalue
   ELSE
    FREE RECORD putrequest
    RECORD putrequest(
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line[*]
        2 linedata = vc
      1 overflowpage[*]
        2 ofr_qual[*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
    )
    SET putrequest->source_dir =  $OUTDEV
    SET putrequest->isblob = "1"
    SET putrequest->document = svalue
    SET putrequest->document_size = size(putrequest->document)
    EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
   ENDIF
   CALL log_message(build("Exit PutStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putunboundedstringtofile(trec=vc(ref)) =null WITH protect)
   CALL log_message("In PutUnboundedStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   DECLARE curstringlength = i4 WITH noconstant(textlen(trec->val))
   DECLARE newmaxvarlen = i4 WITH noconstant(0)
   DECLARE origcurmaxvarlen = i4 WITH noconstant(0)
   IF (curstringlength > curmaxvarlen)
    SET origcurmaxvarlen = curmaxvarlen
    SET newmaxvarlen = (curstringlength+ 10000)
    SET modify maxvarlen newmaxvarlen
   ENDIF
   CALL putstringtofile(trec->val)
   IF (newmaxvarlen > 0)
    SET modify maxvarlen origcurmaxvarlen
   ENDIF
   CALL log_message(build("Exit PutUnboundedStringToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (putjsonrecordtofile(record_data=vc(ref)) =null WITH protect)
   CALL log_message("In PutJSONRecordToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   RECORD _tempjson(
     1 val = gvc
   )
   SET _tempjson->val = cnvtrectojson(record_data)
   CALL putunboundedstringtofile(_tempjson)
   CALL log_message(build("Exit PutJSONRecordToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getparametervalues(index=i4(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE par = vc WITH noconstant(""), protect
   DECLARE lnum = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(1), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE cnt2 = i4 WITH noconstant(0), protect
   DECLARE param_value = f8 WITH noconstant(0.0), protect
   DECLARE param_value_str = vc WITH noconstant(""), protect
   SET par = reflect(parameter(index,0))
   IF (validate(debug_ind,0)=1)
    CALL echo(par)
   ENDIF
   IF (((par="F8") OR (par="I4")) )
    SET param_value = parameter(index,0)
    IF (param_value > 0)
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = param_value
    ENDIF
   ELSEIF (substring(1,1,par)="C")
    SET param_value_str = parameter(index,0)
    IF (trim(param_value_str,3) != "")
     SET value_rec->cnt += 1
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
    ENDIF
   ELSEIF (substring(1,1,par)="L")
    SET lnum = 1
    WHILE (lnum > 0)
     SET par = reflect(parameter(index,lnum))
     IF (par != " ")
      IF (((par="F8") OR (par="I4")) )
       SET param_value = parameter(index,lnum)
       IF (param_value > 0)
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = param_value
       ENDIF
       SET lnum += 1
      ELSEIF (substring(1,1,par)="C")
       SET param_value_str = parameter(index,lnum)
       IF (trim(param_value_str,3) != "")
        SET value_rec->cnt += 1
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
       ENDIF
       SET lnum += 1
      ENDIF
     ELSE
      SET lnum = 0
     ENDIF
    ENDWHILE
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getlookbackdatebytype(units=i4(val),flag=i4(val)) =dq8 WITH protect)
   DECLARE looback_date = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
   IF (units != 0)
    CASE (flag)
     OF 1:
      SET looback_date = cnvtlookbehind(build(units,",H"),cnvtdatetime(sysdate))
     OF 2:
      SET looback_date = cnvtlookbehind(build(units,",D"),cnvtdatetime(sysdate))
     OF 3:
      SET looback_date = cnvtlookbehind(build(units,",W"),cnvtdatetime(sysdate))
     OF 4:
      SET looback_date = cnvtlookbehind(build(units,",M"),cnvtdatetime(sysdate))
     OF 5:
      SET looback_date = cnvtlookbehind(build(units,",Y"),cnvtdatetime(sysdate))
    ENDCASE
   ENDIF
   RETURN(looback_date)
 END ;Subroutine
 SUBROUTINE (getcodevaluesfromcodeset(evt_set_rec=vc(ref),evt_cd_rec=vc(ref)) =null WITH protect)
  DECLARE csidx = i4 WITH noconstant(0)
  SELECT DISTINCT INTO "nl:"
   FROM v500_event_set_explode vese
   WHERE expand(csidx,1,evt_set_rec->cnt,vese.event_set_cd,evt_set_rec->qual[csidx].value)
   DETAIL
    evt_cd_rec->cnt += 1, stat = alterlist(evt_cd_rec->qual,evt_cd_rec->cnt), evt_cd_rec->qual[
    evt_cd_rec->cnt].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE (geteventsetnamesfromeventsetcds(evt_set_rec=vc(ref),evt_set_name_rec=vc(ref)) =null
  WITH protect)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE expand(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
    HEAD REPORT
     cnt = 0, evt_set_name_rec->cnt = evt_set_rec->cnt, stat = alterlist(evt_set_name_rec->qual,
      evt_set_rec->cnt)
    DETAIL
     pos = locateval(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     WHILE (pos > 0)
       cnt += 1, evt_set_name_rec->qual[pos].value = v.event_set_name, pos = locateval(index,(pos+ 1),
        evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_name_rec->cnt -= 1, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt,(pos
         - 1)), pos = locateval(index,pos,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].
        value)
     ENDWHILE
     evt_set_name_rec->cnt = cnt, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE (returnviewertype(eventclasscd=f8(val),eventid=f8(val)) =vc WITH protect)
   CALL log_message("In returnViewerType()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   IF (eventclasscdpopulated=0)
    SET mpc_ap_type_cd = uar_get_code_by("MEANING",53,"AP")
    SET mpc_doc_type_cd = uar_get_code_by("MEANING",53,"DOC")
    SET mpc_mdoc_type_cd = uar_get_code_by("MEANING",53,"MDOC")
    SET mpc_rad_type_cd = uar_get_code_by("MEANING",53,"RAD")
    SET mpc_txt_type_cd = uar_get_code_by("MEANING",53,"TXT")
    SET mpc_num_type_cd = uar_get_code_by("MEANING",53,"NUM")
    SET mpc_immun_type_cd = uar_get_code_by("MEANING",53,"IMMUN")
    SET mpc_med_type_cd = uar_get_code_by("MEANING",53,"MED")
    SET mpc_date_type_cd = uar_get_code_by("MEANING",53,"DATE")
    SET mpc_done_type_cd = uar_get_code_by("MEANING",53,"DONE")
    SET mpc_mbo_type_cd = uar_get_code_by("MEANING",53,"MBO")
    SET mpc_procedure_type_cd = uar_get_code_by("MEANING",53,"PROCEDURE")
    SET mpc_grp_type_cd = uar_get_code_by("MEANING",53,"GRP")
    SET mpc_hlatyping_type_cd = uar_get_code_by("MEANING",53,"HLATYPING")
    SET eventclasscdpopulated = 1
   ENDIF
   DECLARE sviewerflag = vc WITH protect, noconstant("")
   CASE (eventclasscd)
    OF mpc_ap_type_cd:
     SET sviewerflag = "AP"
    OF mpc_doc_type_cd:
    OF mpc_mdoc_type_cd:
    OF mpc_rad_type_cd:
     SET sviewerflag = "DOC"
    OF mpc_txt_type_cd:
    OF mpc_num_type_cd:
    OF mpc_immun_type_cd:
    OF mpc_med_type_cd:
    OF mpc_date_type_cd:
    OF mpc_done_type_cd:
     SET sviewerflag = "EVENT"
    OF mpc_mbo_type_cd:
     SET sviewerflag = "MICRO"
    OF mpc_procedure_type_cd:
     SET sviewerflag = "PROC"
    OF mpc_grp_type_cd:
     SET sviewerflag = "GRP"
    OF mpc_hlatyping_type_cd:
     SET sviewerflag = "HLA"
    ELSE
     SET sviewerflag = "STANDARD"
   ENDCASE
   IF (eventclasscd=mpc_mdoc_type_cd)
    SELECT INTO "nl:"
     c2.*
     FROM clinical_event c1,
      clinical_event c2
     PLAN (c1
      WHERE c1.event_id=eventid)
      JOIN (c2
      WHERE c1.parent_event_id=c2.event_id
       AND c2.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
     HEAD c2.event_id
      IF (c2.event_class_cd=mpc_ap_type_cd)
       sviewerflag = "AP"
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit returnViewerType(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
   RETURN(sviewerflag)
 END ;Subroutine
 SUBROUTINE (cnvtisodttmtodq8(isodttmstr=vc) =dq8 WITH protect)
   DECLARE converteddq8 = dq8 WITH protect, noconstant(0)
   SET converteddq8 = cnvtdatetimeutc2(substring(1,10,isodttmstr),"YYYY-MM-DD",substring(12,8,
     isodttmstr),"HH:MM:SS",4,
    curtimezonedef)
   RETURN(converteddq8)
 END ;Subroutine
 SUBROUTINE (cnvtdq8toisodttm(dq8dttm=f8) =vc WITH protect)
   DECLARE convertedisodttm = vc WITH protect, noconstant("")
   IF (dq8dttm > 0.0)
    SET convertedisodttm = build(replace(datetimezoneformat(cnvtdatetime(dq8dttm),datetimezonebyname(
        "UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
   ELSE
    SET convertedisodttm = nullterm(convertedisodttm)
   ENDIF
   RETURN(convertedisodttm)
 END ;Subroutine
 SUBROUTINE getorgsecurityflag(null)
   DECLARE org_security_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name="SEC_ORG_RELTN"
    HEAD REPORT
     org_security_flag = 0
    DETAIL
     org_security_flag = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(org_security_flag)
 END ;Subroutine
 SUBROUTINE (getcomporgsecurityflag(dminfo_name=vc(val)) =i2 WITH protect)
   DECLARE org_security_flag = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="SECURITY"
     AND di.info_name=dminfo_name
    HEAD REPORT
     org_security_flag = 0
    DETAIL
     org_security_flag = cnvtint(di.info_number)
    WITH nocounter
   ;end select
   RETURN(org_security_flag)
 END ;Subroutine
 SUBROUTINE (populateauthorizedorganizations(personid=f8(val),value_rec=vc(ref)) =null WITH protect)
   DECLARE organization_cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE por.person_id=personid
     AND por.active_ind=1
     AND por.beg_effective_dt_tm BETWEEN cnvtdatetime(lower_bound_date) AND cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm BETWEEN cnvtdatetime(sysdate) AND cnvtdatetime(upper_bound_date)
    ORDER BY por.organization_id
    HEAD REPORT
     organization_cnt = 0
    DETAIL
     organization_cnt += 1
     IF (mod(organization_cnt,20)=1)
      stat = alterlist(value_rec->organizations,(organization_cnt+ 19))
     ENDIF
     value_rec->organizations[organization_cnt].organizationid = por.organization_id
    FOOT REPORT
     value_rec->cnt = organization_cnt, stat = alterlist(value_rec->organizations,organization_cnt)
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(value_rec)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getuserlogicaldomain(id=f8) =f8 WITH protect)
   DECLARE returnid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM prsnl p
    WHERE p.person_id=id
    DETAIL
     returnid = p.logical_domain_id
    WITH nocounter
   ;end select
   RETURN(returnid)
 END ;Subroutine
 SUBROUTINE (getpersonneloverride(ppr_cd=f8(val)) =i2 WITH protect)
   DECLARE override_ind = i2 WITH protect, noconstant(0)
   IF (ppr_cd <= 0.0)
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=ppr_cd
     AND cve.code_set=331
     AND ((cve.field_value="1") OR (cve.field_value="2"))
     AND cve.field_name="Override"
    DETAIL
     override_ind = 1
    WITH nocounter
   ;end select
   RETURN(override_ind)
 END ;Subroutine
 SUBROUTINE cclimpersonation(null)
   CALL log_message("In cclImpersonation()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   EXECUTE secrtl
   DECLARE uar_secsetcontext(hctx=i4) = i2 WITH image_axp = "secrtl", image_aix =
   "libsec.a(libsec.o)", uar = "SecSetContext",
   persist
   DECLARE seccntxt = i4 WITH public
   DECLARE namelen = i4 WITH public
   DECLARE domainnamelen = i4 WITH public
   SET namelen = (uar_secgetclientusernamelen()+ 1)
   SET domainnamelen = (uar_secgetclientdomainnamelen()+ 2)
   SET stat = memalloc(name,1,build("C",namelen))
   SET stat = memalloc(domainname,1,build("C",domainnamelen))
   SET stat = uar_secgetclientusername(name,namelen)
   SET stat = uar_secgetclientdomainname(domainname,domainnamelen)
   SET setcntxt = uar_secimpersonate(nullterm(name),nullterm(domainname))
   CALL log_message(build("Exit cclImpersonation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (geteventsetdisplaysfromeventsetcds(evt_set_rec=vc(ref),evt_set_disp_rec=vc(ref)) =null
  WITH protect)
   DECLARE index = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM v500_event_set_code v
    WHERE expand(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
    HEAD REPORT
     cnt = 0, evt_set_disp_rec->cnt = evt_set_rec->cnt, stat = alterlist(evt_set_disp_rec->qual,
      evt_set_rec->cnt)
    DETAIL
     pos = locateval(index,1,evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     WHILE (pos > 0)
       cnt += 1, evt_set_disp_rec->qual[pos].value = v.event_set_cd_disp, pos = locateval(index,(pos
        + 1),evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_disp_rec->cnt -= 1, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt,(pos
         - 1)), pos = locateval(index,pos,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].
        value)
     ENDWHILE
     evt_set_disp_rec->cnt = cnt, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE (decodestringparameter(description=vc(val)) =vc WITH protect)
   DECLARE decodeddescription = vc WITH private
   SET decodeddescription = replace(description,"%3B",";",0)
   SET decodeddescription = replace(decodeddescription,"%25","%",0)
   RETURN(decodeddescription)
 END ;Subroutine
 SUBROUTINE (urlencode(json=vc(val)) =vc WITH protect)
   DECLARE encodedjson = vc WITH private
   SET encodedjson = replace(json,char(91),"%5B",0)
   SET encodedjson = replace(encodedjson,char(123),"%7B",0)
   SET encodedjson = replace(encodedjson,char(58),"%3A",0)
   SET encodedjson = replace(encodedjson,char(125),"%7D",0)
   SET encodedjson = replace(encodedjson,char(93),"%5D",0)
   SET encodedjson = replace(encodedjson,char(44),"%2C",0)
   SET encodedjson = replace(encodedjson,char(34),"%22",0)
   RETURN(encodedjson)
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4(val)) =i2 WITH protect)
   CALL log_message("In IsTaskGranted",log_level_debug)
   DECLARE fntime = f8 WITH private, noconstant(curtime3)
   DECLARE task_granted = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM task_access ta,
     application_group ag
    PLAN (ta
     WHERE ta.task_number=task_number
      AND ta.app_group_cd > 0.0)
     JOIN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.app_group_cd=ta.app_group_cd
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     task_granted = 1
    WITH nocounter, maxqual(ta,1)
   ;end select
   CALL log_message(build("Exit IsTaskGranted - ",build2(cnvtint((curtime3 - fntime))),"0 ms"),
    log_level_debug)
   RETURN(task_granted)
 END ;Subroutine
 SET log_program_name = "ct_mp_chg_pt_consent"
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET stat = cnvtjsontorec( $JSONREQUEST)
 IF (( $JSONREQUEST=""))
  CALL populate_subeventstatus_rec("REQUEST","F","ct_mp_chg_pt_consent","Invalid JSON Request",
   "reply")
  GO TO exit_script
 ENDIF
 DECLARE time_field_ind = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->statuscon = "F"
 SET reply->statusrltn = "Z"
 DECLARE prev_consent_nbr = i2 WITH protect, noconstant(0)
 DECLARE bfalse = i2 WITH protect, constant(0)
 DECLARE btrue = i2 WITH protect, constant(1)
 DECLARE continue = i2 WITH protect, noconstant(0)
 DECLARE updatecon = i2 WITH protect, noconstant(bfalse)
 DECLARE createrltn = i2 WITH protect, noconstant(bfalse)
 DECLARE reltn_id = f8 WITH protect, noconstant(0.0)
 DECLARE participantname = vc WITH public, noconstant("")
 DECLARE con_id = vc WITH public, noconstant("")
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE lst_updt_dt_tm = vc WITH public, noconstant("")
 DECLARE transferwc_ind = i2 WITH protect, noconstant(0)
 DECLARE signeddate_ind = i2 WITH protect, noconstant(0)
 DECLARE reason_cd = f8 WITH protect, noconstant(0.00)
 DECLARE qual_count = i2 WITH protect, noconstant(0)
 DECLARE con_info_ind = i2 WITH protect, noconstant(0)
 DECLARE connotret_cd = f8 WITH protect, noconstant(0.0)
 DECLARE elig_id = f8 WITH protect, noconstant(0.0)
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE consent_id = f8 WITH protect, noconstant(0.0)
 DECLARE eligstatus_cd = f8 WITH protect, noconstant(0.0)
 DECLARE elignoverif_cd = f8 WITH protect, noconstant(0.0)
 DECLARE notenrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE notsigned_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5,"000"))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30,"July 25, 2017"))
 DECLARE regid = f8 WITH protect, noconstant(0.0)
 DECLARE unknown_cd = f8 WITH protect, noconstant(0.0)
 DECLARE newaccessionnbr = c276 WITH protect, noconstant(fillstring(276," "))
 DECLARE protocol_id = f8 WITH protect, noconstant(0.0)
 DECLARE ptregconsentreltnid = f8 WITH protect, noconstant(0.0)
 DECLARE pteligtrackingid = f8 WITH protect, noconstant(0.0)
 DECLARE reltnid = f8 WITH protect, noconstant(0.0)
 DECLARE releaseddate = dq8 WITH protect
 DECLARE signeddate = dq8 WITH protect
 DECLARE returneddate = dq8 WITH protect
 DECLARE notreturneddate = dq8 WITH protect
 DECLARE consented_cd = f8 WITH protect, noconstant(0.0)
 DECLARE enrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancel_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(17901,"CONSENTED",1,consented_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancel_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"ENROLLED",1,enrolled_cd)
 SET ptregconsentreltnid = 0.0
 SET pteligconsentreltnid = 0.0
 SET doinsert = 0
 SET conid = 0.0
 SET protocol_id = 0.0
 SET regid = 0.0
 SET unknown_cd = 0.0
 SET newaccessionnbr = fillstring(276," ")
 SET releaseddate = cnvtdatetime(request->dateconissued)
 SET signeddate = cnvtdatetime(request->dateconsigned)
 SET returneddate = cnvtdatetime(request->dateconreceived)
 SET notreturneddate = cnvtdatetime(request->not_returned_dt_tm)
 SET time_field_ind = checkdic("PT_CONSENT.CONSENT_RELEASED_TM_IND","A",0)
 SUBROUTINE (enrollconsentpatient(conid=f8(ref)) =null WITH protect)
   SELECT INTO "nl:"
    FROM prot_amendment pa
    WHERE (pa.prot_amendment_id=request->prot_amendment_id)
    DETAIL
     protocol_id = pa.prot_master_id
    WITH format, counter
   ;end select
   SELECT INTO "nl:"
    rltn.*
    FROM pt_reg_consent_reltn rltn
    WHERE rltn.consent_id=conid
     AND rltn.reg_id != 0
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dup = false
   ELSE
    SET dup = true
   ENDIF
   CALL echo(build("dup = ",dup))
   IF (dup=false)
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      regid = cnvtreal(num)
     WITH format, counter
    ;end select
    CALL echo("Insert pt_prot_reg")
    CALL echo(build("regid = ",regid))
    INSERT  FROM pt_prot_reg p_pr_r
     SET p_pr_r.off_study_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.tx_start_dt_tm =
      cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.tx_completion_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"),
      p_pr_r.first_pd_failure_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.first_pd_dt_tm
       = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.first_cr_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"),
      p_pr_r.nomenclature_id = 0.0, p_pr_r.removal_organization_id = 0.0, p_pr_r.removal_person_id =
      0.0,
      p_pr_r.enrolling_organization_id = 0.0, p_pr_r.best_response_cd = 0.0, p_pr_r
      .first_dis_rel_event_death_cd = 0.0,
      p_pr_r.diagnosis_type_cd = unknown_cd, p_pr_r.on_tx_organization_id = 0.0, p_pr_r
      .on_tx_assign_prsnl_id = 0.0,
      p_pr_r.on_tx_comment = "", p_pr_r.status_enum = 5, p_pr_r.prot_arm_id = 0.0,
      p_pr_r.prot_master_id = protocol_id, p_pr_r.beg_effective_dt_tm = cnvtdatetime(sysdate), p_pr_r
      .end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
      p_pr_r.pt_prot_reg_id = regid, p_pr_r.reg_id = regid, p_pr_r.person_id = c->person_id,
      p_pr_r.prot_accession_nbr = newaccessionnbr, p_pr_r.on_study_dt_tm = cnvtdatetime(
       "31-DEC-2100 00:00:00.00"), p_pr_r.updt_cnt = 0,
      p_pr_r.updt_applctx = reqinfo->updt_applctx, p_pr_r.updt_task = reqinfo->updt_task, p_pr_r
      .updt_id = reqinfo->updt_id,
      p_pr_r.updt_dt_tm = cnvtdatetime(sysdate), p_pr_r.removal_reason_cd = 0.0, p_pr_r
      .removal_reason_desc = "",
      p_pr_r.reason_off_tx_cd = 0.0, p_pr_r.reason_off_tx_desc = "", p_pr_r
      .off_tx_removal_organization_id = 0.0,
      p_pr_r.off_tx_removal_person_id = 0.0, p_pr_r.episode_id = 0.0
     WITH nocounter
    ;end insert
    IF (curqual=1)
     CALL echo("insert into the pt_prot_reg table : curqual = 1")
     SET doinsert = 1
    ELSE
     CALL echo("insert into the pt_prot_reg table : curqual != 1")
     SET doinsert = 0
    ENDIF
    IF (doinsert=1)
     SET pt_amd_assignment->reg_id = regid
     SET pt_amd_assignment->prot_amendment_id = request->prot_amendment_id
     SET pt_amd_assignment->transfer_checked_amendment_id = request->prot_amendment_id
     SET pt_amd_assignment->assign_start_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
     SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
     SET caaa_status = "F"
     EXECUTE ct_add_a_a_func
     IF (caaa_status != "S")
      SET doinsert = 0
     ENDIF
    ENDIF
    CALL echo(build("ConID = ",conid))
    CALL echo("Get Unique ID for pt_reg_consent_reltn")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      ptregconsentreltnid = cnvtreal(num)
     WITH format, counter
    ;end select
    CALL echo("BEFORE - Insert pt_reg_consent_reltn")
    INSERT  FROM pt_reg_consent_reltn rltn
     SET rltn.pt_reg_consent_reltn_id = ptregconsentreltnid, rltn.reg_id = regid, rltn.consent_id =
      conid,
      rltn.updt_cnt = 0, rltn.updt_applctx = reqinfo->updt_applctx, rltn.updt_task = reqinfo->
      updt_task,
      rltn.updt_id = reqinfo->updt_id, rltn.updt_dt_tm = cnvtdatetime(sysdate), rltn.active_ind = 1,
      rltn.active_status_cd = reqdata->active_status_cd, rltn.active_status_dt_tm = cnvtdatetime(
       sysdate), rltn.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    CALL echo(build("PtRegConsentReltnID = ",ptregconsentreltnid))
    CALL echo(build("RegID = ",regid))
    CALL echo(build("ConID = ",conid))
    IF (curqual=1)
     CALL echo("insert into the pt_reg_consent_reltn table : curqual = 1")
     SET doinsert = 1
    ELSE
     CALL echo("insert into the pt_reg_consent_reltn table : curqual != 1")
     SET doinsert = 0
    ENDIF
    SELECT INTO "nl:"
     FROM pt_elig_consent_reltn ecrltn
     WHERE ecrltn.consent_id=conid
     DETAIL
      pteligtrackingid = ecrltn.pt_elig_tracking_id
     WITH format, counter
    ;end select
    CALL echo("Get Unique ID for Reltn")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      reltnid = cnvtreal(num)
     WITH format, counter
    ;end select
    CALL echo("BEFORE - Insert pt_reg_elig_reltn")
    INSERT  FROM pt_reg_elig_reltn erltn
     SET erltn.pt_reg_elig_reltn_id = reltnid, erltn.reg_id = regid, erltn.pt_elig_tracking_id =
      pteligtrackingid,
      erltn.updt_cnt = 0, erltn.updt_applctx = reqinfo->updt_applctx, erltn.updt_task = reqinfo->
      updt_task,
      erltn.updt_id = reqinfo->updt_id, erltn.updt_dt_tm = cnvtdatetime(sysdate), erltn.active_ind =
      1,
      erltn.active_status_cd = reqdata->active_status_cd, erltn.active_status_dt_tm = cnvtdatetime(
       sysdate), erltn.active_status_prsnl_id = reqinfo->updt_id
    ;end insert
    IF (curqual=1)
     SET doinsert = 1
    ELSE
     SET doinsert = 0
    ENDIF
    CALL echo(build("ReltnID = ",reltnid))
    CALL echo("AFTER - Insert pt_reg_elig_reltn")
    IF (doinsert=1)
     EXECUTE ct_get_prescreen_pref  WITH replace("REPLY","PREF_REPLY")
     IF ((pref_reply->pref_value=1))
      IF (consented_cd > 0)
       IF (protocol_id > 0)
        SELECT INTO "NL:"
         FROM pt_prot_prescreen pps
         WHERE (pps.person_id=c->person_id)
          AND pps.prot_master_id=protocol_id
          AND pps.screening_status_cd != syscancel_cd
          AND pps.screening_status_cd != enrolled_cd
         DETAIL
          status_request->pt_prot_prescreen_id = pps.pt_prot_prescreen_id, status_request->status_cd
           = consented_cd, status_request->status_comment_text = ""
         WITH nocounter
        ;end select
        IF ((status_request->pt_prot_prescreen_id > 0))
         EXECUTE ct_chg_prescreen_status  WITH replace("REQUEST","STATUS_REQUEST"), replace("REPLY",
          "STATUS_REPLY")
         IF ((status_reply->status_data.status != "S"))
          SET doinsert = 0
         ELSE
          SET doinsert = doinsert
         ENDIF
        ELSE
         SET doinsert = doinsert
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 CALL echo(build("ECHO   lock  rows to update"))
 SELECT INTO "nl:"
  p_cn.*
  FROM pt_consent p_cn
  WHERE (p_cn.pt_consent_id=request->ptconsentid)
  DETAIL
   c->currentdatetime = cnvtdatetime(sysdate), c->pt_consent_id = p_cn.pt_consent_id, c->consent_id
    = p_cn.consent_id,
   c->consenting_person_id = p_cn.consenting_person_id, c->consenting_organization_id = p_cn
   .consenting_organization_id, c->consent_released_dt_tm = p_cn.consent_released_dt_tm,
   c->consent_signed_dt_tm = p_cn.consent_signed_dt_tm, c->consent_received_dt_tm = p_cn
   .consent_received_dt_tm, c->consent_nbr = p_cn.consent_nbr,
   c->updt_cnt = p_cn.updt_cnt, c->updt_dt_tm = p_cn.updt_dt_tm, c->beg_effective_dt_tm = p_cn
   .beg_effective_dt_tm,
   c->end_effective_dt_tm = p_cn.end_effective_dt_tm, c->not_returned_dt_tm = p_cn.not_returned_dt_tm,
   c->not_returned_reason_cd = p_cn.not_returned_reason_cd,
   c->reason_for_consent_cd = p_cn.reason_for_consent_cd, c->ct_document_version_id = p_cn
   .ct_document_version_id, c->person_id = p_cn.person_id
  WITH nocounter, forupdate(p_cn)
 ;end select
 SET stat = uar_get_meaning_by_codeset(17349,"TRANSFER",1,reason_cd)
 CALL echo(build("Reason_cd is ",reason_cd))
 IF ((c->reason_for_consent_cd=reason_cd))
  SET transferwc_ind = 1
 ENDIF
 SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(c->updt_dt_tm,0,
   "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
 IF (curqual=1)
  IF ((c->updt_cnt != request->updtcnt))
   CALL echo(build("C->updt_cnt  = ",c->updt_cnt))
   CALL echo(build("Request->UpdtCnt  = ",request->updtcnt))
   SET reply->status_data.status = "C"
   SET reply->statuscon = "C"
   SET continue = bfalse
  ELSE
   SET continue = btrue
  ENDIF
  CALL echo(build("ECHO   checking if data passed in is NULL or different"))
  IF (continue=btrue)
   SET stat = alterlist(audits->qual,0)
   IF ((request->ct_document_version_id != 0))
    IF ((request->ct_document_version_id != c->ct_document_version_id))
     SET updatecon = btrue
     SET con_info_ind = 1
    ENDIF
   ELSE
    SET request->ct_document_version_id = c->ct_document_version_id
   ENDIF
   IF ((request->reasonforconcd != 0))
    IF ((request->reasonforconcd != c->reason_for_consent_cd))
     SET updatecon = btrue
     SET con_info_ind = 1
    ENDIF
   ELSE
    SET request->reasonforconcd = c->reason_for_consent_cd
   ENDIF
   IF ((request->consentingperid != 0))
    IF ((request->consentingperid != c->consenting_person_id))
     SET updatecon = btrue
     SET con_info_ind = 1
    ENDIF
   ELSE
    SET request->consentingperid = c->consenting_person_id
   ENDIF
   IF ((request->consentingorgid != 0))
    IF ((request->consentingorgid != c->consenting_organization_id))
     CALL echo(build("UpdateCon = ",updatecon))
     SET updatecon = btrue
     SET con_info_ind = 1
    ENDIF
   ELSE
    SET request->consentingorgid = c->consenting_organization_id
   ENDIF
   IF (releaseddate != 0)
    IF ((releaseddate != c->consent_released_dt_tm))
     SET updatecon = btrue
     IF (time_field_ind=2)
      SET qual_count += 1
      SET stat = alterlist(audits->qual,qual_count)
      IF ((c->consent_released_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
       SET audits->qual[qual_count].eventname = "Con_Release_Dt-Tm_Mod"
       SET audits->qual[qual_count].eventtype = "Modify"
      ELSE
       SET audits->qual[qual_count].eventname = "Consent_Release_Date-Time"
       SET audits->qual[qual_count].eventtype = "Add"
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET releaseddate = c->consent_released_dt_tm
   ENDIF
   IF (signeddate != 0)
    IF ((signeddate != c->consent_signed_dt_tm))
     SET updatecon = btrue
     IF (time_field_ind=2)
      SET signeddate_ind = 1
      SET qual_count += 1
      SET stat = alterlist(audits->qual,qual_count)
      IF ((c->consent_signed_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
       SET audits->qual[qual_count].eventname = "Con_Signed_Dt-Tm_Mod"
       SET audits->qual[qual_count].eventtype = "Modify"
      ELSE
       SET audits->qual[qual_count].eventname = "Consent_Signed_Date-Time"
       SET audits->qual[qual_count].eventtype = "Add"
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET signeddate = c->consent_signed_dt_tm
   ENDIF
   IF (returneddate != 0)
    IF ((returneddate != c->consent_received_dt_tm))
     SET updatecon = btrue
     IF (time_field_ind=2)
      SET qual_count += 1
      SET stat = alterlist(audits->qual,qual_count)
      IF ((c->consent_received_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
       SET audits->qual[qual_count].eventname = "Con_Returned_Dt-Tm_Mod"
       SET audits->qual[qual_count].eventtype = "Modify"
      ELSE
       SET audits->qual[qual_count].eventname = "Consent_Returned_Date-Time"
       SET audits->qual[qual_count].eventtype = "Add"
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET returneddate = c->consent_received_dt_tm
   ENDIF
   IF (notreturneddate != 0)
    IF ((notreturneddate != c->not_returned_dt_tm))
     SET updatecon = btrue
     IF (time_field_ind=2)
      SET qual_count += 1
      SET stat = alterlist(audits->qual,qual_count)
      IF ((c->not_returned_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")))
       SET audits->qual[qual_count].eventname = "C_Not_Returned_Dt-Tm_Mod"
       SET audits->qual[qual_count].eventtype = "Modify"
      ELSE
       SET audits->qual[qual_count].eventname = "Con_Not_Returned_Dt-Tm"
       SET audits->qual[qual_count].eventtype = "Add"
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET notreturneddate = c->not_returned_dt_tm
   ENDIF
   IF ((request->not_returned_reason_cd != 0))
    IF ((request->not_returned_reason_cd != c->not_returned_reason_cd))
     SET updatecon = btrue
     IF ((c->not_returned_reason_cd != 0))
      SET qual_count += 1
      SET stat = alterlist(audits->qual,qual_count)
      SET audits->qual[qual_count].eventname = "Con_Not_Returned_Reason"
      SET audits->qual[qual_count].eventtype = "Modify"
     ENDIF
    ENDIF
   ELSE
    SET request->not_returned_reason_cd = c->not_returned_reason_cd
   ENDIF
  ENDIF
 ELSE
  SET continue = bfalse
  SET reply->status_data.status = "L"
  SET reply->statuscon = "L"
 ENDIF
 CALL echo(build("ECHO   CONTINUE = ",continue))
 CALL echo(build("ECHO   UpdateCon = ",updatecon))
 IF (continue=btrue)
  IF (updatecon=btrue)
   UPDATE  FROM pt_consent p_cn
    SET p_cn.end_effective_dt_tm = cnvtdatetime(c->currentdatetime), p_cn.updt_cnt = (request->
     updtcnt+ 1), p_cn.updt_applctx = reqinfo->updt_applctx,
     p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id = reqinfo->updt_id, p_cn.updt_dt_tm =
     cnvtdatetime(sysdate)
    WHERE (p_cn.pt_consent_id=request->ptconsentid)
    WITH nocounter
   ;end update
   IF (curqual != 1)
    SET reply->status_data.status = "F"
    SET reply->statuscon = "F"
    SET continue = bfalse
   ENDIF
   CALL echo(build("after update  con table : curqual = ",curqual))
   IF (continue=btrue)
    CALL echo("ECHO   Get Unique ID for Consent")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)"########################;rpO"
     FROM dual
     DETAIL
      consent_id = cnvtreal(num)
     WITH format, counter
    ;end select
    SET reply->ptconsentid = consent_id
    IF (time_field_ind != 2)
     INSERT  FROM pt_consent p_cn
      SET p_cn.prot_amendment_id = request->prot_amendment_id, p_cn.consenting_person_id = request->
       consentingperid, p_cn.consenting_organization_id = request->consentingorgid,
       p_cn.consent_released_dt_tm = cnvtdatetime(request->dateconissued), p_cn.consent_signed_dt_tm
        = cnvtdatetime(request->dateconsigned), p_cn.consent_received_dt_tm = cnvtdatetime(request->
        dateconreceived),
       p_cn.consent_nbr = c->consent_nbr, p_cn.not_returned_dt_tm = cnvtdatetime(request->
        not_returned_dt_tm), p_cn.not_returned_reason_cd = request->not_returned_reason_cd,
       p_cn.beg_effective_dt_tm = cnvtdatetime(c->currentdatetime), p_cn.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100 00:00:00.00"), p_cn.pt_consent_id = reply->ptconsentid,
       p_cn.consent_id = c->consent_id, p_cn.reason_for_consent_cd = request->reasonforconcd, p_cn
       .ct_document_version_id = request->ct_document_version_id,
       p_cn.person_id = c->person_id, p_cn.updt_cnt = 0, p_cn.updt_applctx = reqinfo->updt_applctx,
       p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id = reqinfo->updt_id, p_cn.updt_dt_tm =
       cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM pt_consent p_cn
      SET p_cn.prot_amendment_id = request->prot_amendment_id, p_cn.consenting_person_id = request->
       consentingperid, p_cn.consenting_organization_id = request->consentingorgid,
       p_cn.consent_released_dt_tm = cnvtdatetime(request->dateconissued), p_cn.consent_signed_dt_tm
        = cnvtdatetime(request->dateconsigned), p_cn.consent_received_dt_tm = cnvtdatetime(request->
        dateconreceived),
       p_cn.not_returned_tm_ind = request->not_returned_tm_ind, p_cn.consent_released_tm_ind =
       request->consent_released_tm_ind, p_cn.consent_signed_tm_ind = request->consent_signed_tm_ind,
       p_cn.consent_received_tm_ind = request->consent_received_tm_ind, p_cn.consent_nbr = c->
       consent_nbr, p_cn.not_returned_dt_tm = cnvtdatetime(request->not_returned_dt_tm),
       p_cn.not_returned_reason_cd = request->not_returned_reason_cd, p_cn.beg_effective_dt_tm =
       cnvtdatetime(c->currentdatetime), p_cn.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"),
       p_cn.pt_consent_id = reply->ptconsentid, p_cn.consent_id = c->consent_id, p_cn
       .reason_for_consent_cd = request->reasonforconcd,
       p_cn.ct_document_version_id = request->ct_document_version_id, p_cn.person_id = c->person_id,
       p_cn.updt_cnt = 0,
       p_cn.updt_applctx = reqinfo->updt_applctx, p_cn.updt_task = reqinfo->updt_task, p_cn.updt_id
        = reqinfo->updt_id,
       p_cn.updt_dt_tm = cnvtdatetime(sysdate)
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual=1)
     CALL echo(build("ECHO    change of pt_consent - succeeded"))
     SET reply->status_data.status = "S"
     SET reply->statuscon = "S"
    ELSE
     CALL echo(build("ECHO    change of pt_consent  - failed"))
     SET reply->statuscon = "F"
     SET reply->status_data.status = "F"
     SET continue = bfalse
    ENDIF
    CALL echo(build("after insert  con table : curqual = ",curqual))
    IF (continue=btrue)
     IF ((request->not_returned_reason_cd != 0))
      CALL echo("Request->not_returned_reason_cd != 0")
      CALL echo(build("Locking pt_elig_tracking row to update"))
      SELECT INTO "nl:"
       FROM pt_elig_consent_reltn cerltn,
        pt_consent p_cn
       PLAN (p_cn
        WHERE (p_cn.pt_consent_id=request->ptconsentid))
        JOIN (cerltn
        WHERE cerltn.consent_id=p_cn.consent_id)
       DETAIL
        elig_id = cerltn.pt_elig_tracking_id
       WITH nocounter
      ;end select
      IF (curqual != 0)
       SELECT INTO "nl:"
        FROM pt_elig_tracking pet
        PLAN (pet
         WHERE pet.pt_elig_tracking_id=elig_id)
        DETAIL
         elig_id = pet.pt_elig_tracking_id
        WITH nocounter, forupdate(pet)
       ;end select
       IF (curqual != 0)
        SET stat = uar_get_meaning_by_codeset(17285,"NOTENROLLED",1,notenrolled_cd)
        SET stat = uar_get_meaning_by_codeset(17285,"NOTRETURNED",1,notsigned_cd)
        SET stat = uar_get_meaning_by_codeset(17285,"ELIGNOVER",1,elignoverif_cd)
        SET stat = uar_get_meaning_by_codeset(17284,"CONNORET",1,connotret_cd)
        SET stat = uar_get_meaning_by_codeset(17349,"ENROLLING",1,enrolling_cd)
        IF ((request->reasonforconcd=enrolling_cd))
         SET eligstatus_cd = notenrolled_cd
        ELSE
         SET eligstatus_cd = notsigned_cd
        ENDIF
        IF (eligstatus_cd != 0.0)
         UPDATE  FROM pt_elig_tracking pet
          SET pet.elig_status_cd = eligstatus_cd, pet.reason_ineligible_cd = connotret_cd, pet
           .updt_cnt = (pet.updt_cnt+ 1),
           pet.updt_applctx = reqinfo->updt_applctx, pet.updt_task = reqinfo->updt_task, pet.updt_id
            = reqinfo->updt_id,
           pet.updt_dt_tm = cnvtdatetime(sysdate)
          WHERE pet.pt_elig_tracking_id=elig_id
          WITH nocounter
         ;end update
         CALL echo(build("ECHO   elig_id = ",elig_id))
         CALL echo(build("ECHO   UPDATING ELIG ROWS  (pre curqual check) curqual = ",curqual))
         IF (curqual=0)
          SET reply->status_data.status = "F"
          SET continue = bfalse
         ENDIF
         IF (continue=btrue)
          IF ((request->reasonforconcd=enrolling_cd))
           IF (notreturneddate != 0)
            CALL echo(build("ECHO   lock assign_elig_reltn row to update"))
            SELECT INTO "NL:"
             FROM assign_elig_reltn a_e,
              prot_cohort coh
             PLAN (a_e
              WHERE a_e.pt_elig_tracking_id=elig_id
               AND a_e.end_effective_dt_tm > cnvtdatetime(sysdate))
              JOIN (coh
              WHERE coh.cohort_id=a_e.cohort_id)
             DETAIL
              request->stratum_id = coh.stratum_id, request->cohort_id = a_e.cohort_id
             WITH nocounter
            ;end select
            IF (curqual != 0)
             UPDATE  FROM assign_elig_reltn a_e
              SET a_e.end_effective_dt_tm = cnvtdatetime(sysdate), a_e.updt_cnt = (a_e.updt_cnt+ 1),
               a_e.updt_applctx = reqinfo->updt_applctx,
               a_e.updt_task = reqinfo->updt_task, a_e.updt_id = reqinfo->updt_id, a_e.updt_dt_tm =
               cnvtdatetime(sysdate)
              WHERE a_e.pt_elig_tracking_id=elig_id
               AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
              WITH nocounter
             ;end update
             CALL echo(build("elig_id = ",elig_id))
             CALL echo(build("UPDATING ASSIGN_ELIG ROWS (pre curqual check) curqual = ",curqual))
             IF (curqual=0)
              SET reply->status_data.status = "F"
              SET continue = bfalse
             ELSE
              EXECUTE strat_coh_status_update_func
              CALL echo(build("Reply->SCS_FuncStatus = ",reply->scs_funcstatus))
              IF ((reply->scs_funcstatus != "F"))
               SET reply->status_data.status = "S"
               SET reqinfo->commit_ind = true
              ENDIF
             ENDIF
            ENDIF
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (continue=btrue)
  IF ((request->regid != 0))
   SELECT INTO "nl:"
    FROM pt_reg_consent_reltn rltn
    PLAN (rltn
     WHERE (rltn.consent_id=c->consent_id))
   ;end select
   IF (curqual=0)
    SET createrltn = btrue
   ELSE
    SET createrltn = bfalse
   ENDIF
   IF (createrltn=btrue)
    CALL echo("ECHO   Get Unique ID for Consent")
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)"########################;rpO"
     FROM dual
     DETAIL
      reltn_id = cnvtreal(num)
     WITH format, counter
    ;end select
    INSERT  FROM pt_reg_consent_reltn rltn
     SET rltn.pt_reg_consent_reltn_id = reltn_id, rltn.reg_id = request->regid, rltn.consent_id = c->
      consent_id,
      rltn.updt_cnt = 0, rltn.updt_applctx = reqinfo->updt_applctx, rltn.updt_task = reqinfo->
      updt_task,
      rltn.updt_id = reqinfo->updt_id, rltn.updt_dt_tm = cnvtdatetime(sysdate), rltn.active_ind = 1,
      rltn.active_status_cd = reqdata->active_status_cd, rltn.active_status_dt_tm = cnvtdatetime(
       sysdate), rltn.active_status_prsnl_id = reqinfo->updt_id
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->statusrltn = "F"
    ELSE
     SET reply->status_data.status = "S"
     SET reply->statusrltn = "S"
    ENDIF
   ENDIF
  ELSEIF ((request->regid=0)
   AND (request->dateconsigned != "0")
   AND (request->dateconsigned != "31-DEC-2100"))
   CALL enrollconsentpatient(c->consent_id)
  ENDIF
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
  IF (transferwc_ind=1
   AND signeddate_ind=1)
   EXECUTE cclaudit audit_mode, "PT_with_consent", "Add",
   "Person", "Patient", "Patient",
   "Origination", c->person_id, ""
  ENDIF
  IF (con_info_ind=1)
   SET qual_count += 1
   SET stat = alterlist(audits->qual,qual_count)
   SET audits->qual[qual_count].eventname = "Consent_info_Update"
   SET audits->qual[qual_count].eventtype = "Modify"
  ENDIF
  FOR (x = 1 TO qual_count)
    CASE (audits->qual[x].eventtype)
     OF "Add":
      EXECUTE cclaudit audit_mode, audits->qual[x].eventname, audits->qual[x].eventtype,
      "Person", "Patient", "Patient",
      "Origination", c->person_id, ""
     OF "Modify":
      SET con_id = build3(3,"CONSENT_ID: ",c->consent_id)
      SET participantname = concat(con_id," ",lst_updt_dt_tm," (UPDT_DT_TM)")
      EXECUTE cclaudit audit_mode, audits->qual[x].eventname, audits->qual[x].eventtype,
      "Person", "Patient", "Patient",
      "Amendment", c->person_id, participantname
    ENDCASE
  ENDFOR
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
#exit_script
 CALL putjsonrecordtofile(reply)
 CALL echo(build("Status->PtConsent = ",reply->statuscon))
 CALL echo(build("Status = ",reply->status_data.status))
 FREE RECORD pref_reply
 FREE RECORD status_request
 FREE RECORD status_reply
 SET last_mod = "003"
 SET mod_date = "Sept 27, 2024"
END GO
