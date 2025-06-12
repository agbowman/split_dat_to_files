CREATE PROGRAM ct_mp_add_chg_cohort_assign:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "StratumId:" = 0,
  "CohortId:" = 0,
  "RegId:" = 0,
  "PtEligTrackingId" = 0
  WITH outdev, stratumid, cohortid,
  regid, pteligtrackingid
 DECLARE g_debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(debug_on,0))
  IF (debug_on=1)
   SET g_debug_ind = 1
  ENDIF
 ENDIF
 FREE RECORD request
 RECORD request(
   1 stratum_id = f8
   1 cohort_id = f8
   1 reg_id = f8
   1 pt_elig_tracking_id = f8
   1 prot_amendment_id = f8
   1 change_ind = i4
   1 ss[*]
     2 status_chg_reason_cd = f8
     2 a_key = vc
     2 delete_indicator = i2
     2 stratum_id = f8
     2 parent_stratum_id = f8
     2 organization_id = f8
     2 stratum_label = c100
     2 stratum_cd = f8
     2 stratum_description = vc
     2 stratum_status_cd = f8
     2 stratum_cohort_type_cd = f8
     2 length_evaluation = i4
     2 length_evaluation_uom_cd = f8
     2 prot_stratum_id = f8
     2 updt_cnt = i4
     2 susps[*]
       3 prot_stratum_susp_id = f8
       3 reason_cd = f8
       3 comment_txt = vc
       3 susp_effective_dt_tm = dq8
       3 susp_end_dt_tm = dq8
       3 updt_cnt = i4
     2 cs[*]
       3 status_chg_reason_cd = f8
       3 delete_indicator = i2
       3 prot_cohort_id = f8
       3 parent_cohort_id = f8
       3 pt_accrual = i4
       3 cohort_status_cd = f8
       3 prot_cohort_description = vc
       3 cohort_label = c30
       3 valid_from_dt_tm = dq8
       3 valid_to_dt_tm = dq8
       3 updt_cnt = i4
 )
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
 SET log_program_name = "ct_mp_add_chg_cohort_assign"
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
 RECORD reply(
   1 reg_status = c1
   1 assign_reg_reltn_id = f8
   1 elig_status = c1
   1 assign_elig_reltn_id = f8
   1 coh_status = c1
   1 strat_status = c1
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
   1 debug[*]
     2 str = vc
 )
 RECORD old(
   1 curdatetime = dq8
   1 cohort_id = f8
   1 assign_id = f8
   1 stratum_id = f8
   1 cohort_label = vc
   1 stratum_cohort_type_cd = f8
 )
 RECORD audit(
   1 qual[*]
     2 eventname = vc
     2 eventtype = vc
 )
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE lst_updt_dt_tm_str = vc WITH protect, noconstant("")
 DECLARE assign_name = vc WITH protect, noconstant("")
 DECLARE assign_id = f8 WITH protect, noconstant(0.0)
 DECLARE assign_id_audit = vc WITH protect, noconstant("")
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE cohort_label_new = vc WITH protect, noconstant("")
 DECLARE qual_count = i2 WITH protect, noconstant(0)
 DECLARE row_count = i4 WITH protect, noconstant(0)
 DECLARE current_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE stratum_cohort_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET false = 0
 SET true = 1
 SET continue = false
 SET reply->status_data.status = "F"
 SET reply->reg_status = "Z"
 SET reply->elig_status = "Z"
 SET reply->coh_status = "F"
 SET reply->strat_status = "F"
 SET assignregreltnid = 0.0
 SET assigneligreltnid = 0.0
 SET cohort_open = 0.0
 SET stratum_open = 0.0
 SET parentstratumid = 0.0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET cset = 18778
 SET cmean = "OPEN"
 EXECUTE ct_get_cv
 SET cohort_open = cval
 CALL echo(build("COHORT_OPEN  = ",cohort_open))
 SET request->stratum_id =  $STRATUMID
 SET request->cohort_id =  $COHORTID
 SET request->reg_id =  $REGID
 SET request->pt_elig_tracking_id =  $PTELIGTRACKINGID
 IF ((request->cohort_id > 0))
  CALL echo("1")
  SELECT INTO "NL:"
   FROM prot_cohort coh
   WHERE (coh.cohort_id=request->cohort_id)
    AND coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND coh.cohort_status_cd=cohort_open
   DETAIL
    request->stratum_id = coh.stratum_id, cohort_label_new = coh.cohort_label
   WITH counter
  ;end select
  IF (curqual=1)
   SET reply->coh_status = "O"
   SET cset = 18775
   SET cmean = "OPEN"
   EXECUTE ct_get_cv
   SET stratum_open = cval
   CALL echo("2")
   SELECT INTO "NL:"
    FROM prot_stratum strat
    WHERE (strat.stratum_id=request->stratum_id)
     AND strat.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND strat.stratum_status_cd=stratum_open
    WITH counter
   ;end select
   IF (curqual=1)
    SET reply->strat_status = "O"
    SET continue = true
    CALL echo("3")
   ELSE
    IF ((request->pt_elig_tracking_id > 0))
     SET continue = false
     SET assigncount = 0
     SELECT INTO "nl:"
      FROM assign_elig_reltn a_e
      WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
       AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      DETAIL
       assigncount += 1
      WITH counter
     ;end select
     IF (curqual=1)
      SET continue = true
      SET reply->strat_status = "O"
     ELSE
      SET reply->strat_status = "C"
      SET continue = false
     ENDIF
    ELSE
     CALL echo("4")
     SET reply->strat_status = "C"
     SET continue = false
    ENDIF
   ENDIF
  ELSE
   CALL echo("5")
   IF ((request->pt_elig_tracking_id > 0))
    SET continue = false
    SET assigncount = 0
    SELECT INTO "nl:"
     FROM assign_elig_reltn a_e
     WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
      AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     DETAIL
      assigncount += 1
     WITH counter
    ;end select
    IF (curqual=1)
     SET continue = true
     SET reply->coh_status = "O"
     SET reply->strat_status = "Z"
    ELSE
     SET reply->coh_status = "C"
     SET reply->strat_status = "Z"
     SET continue = false
    ENDIF
   ELSE
    SET reply->coh_status = "C"
    SET reply->strat_status = "Z"
    SET continue = false
   ENDIF
  ENDIF
  IF (continue=true)
   CALL echo("6")
   IF ((request->reg_id > 0))
    SET continue = false
    CALL echo("7")
    SELECT INTO "nl:"
     a_r.*
     FROM assign_reg_reltn a_r
     WHERE (a_r.reg_id=request->reg_id)
      AND a_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     DETAIL
      old->curdatetime = cnvtdatetime(sysdate), old->cohort_id = a_r.cohort_id, old->assign_id = a_r
      .assign_reg_reltn_id
     WITH counter, forupdate(a_r)
    ;end select
    IF (curqual=1)
     IF ((old->cohort_id != request->cohort_id))
      CALL echo("8")
      UPDATE  FROM assign_reg_reltn a_r
       SET a_r.end_effective_dt_tm = cnvtdatetime(old->curdatetime), a_r.updt_cnt = (a_r.updt_cnt+ 1),
        a_r.updt_applctx = reqinfo->updt_applctx,
        a_r.updt_task = reqinfo->updt_task, a_r.updt_id = reqinfo->updt_id, a_r.updt_dt_tm =
        cnvtdatetime(sysdate)
       WHERE (a_r.assign_reg_reltn_id=old->assign_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET reply->reg_status = "F"
      ELSE
       CALL echo("9")
       SELECT INTO "nl:"
        num = seq(protocol_def_seq,nextval)"########################;rpO"
        FROM dual
        DETAIL
         assignregreltnid = cnvtreal(num)
        WITH format, counter
       ;end select
       SET continue = true
       CALL echo("10")
      ENDIF
     ENDIF
    ELSE
     CALL echo("11")
     SET old->curdatetime = cnvtdatetime(sysdate)
     SELECT INTO "nl:"
      num = seq(protocol_def_seq,nextval)"########################;rpO"
      FROM dual
      DETAIL
       assignregreltnid = cnvtreal(num)
      WITH format, counter
     ;end select
     SET continue = true
     CALL echo("12")
    ENDIF
    IF (continue=true)
     CALL echo("13")
     SET current_dt_tm = cnvtdatetime(sysdate)
     INSERT  FROM assign_reg_reltn a_r
      SET a_r.assign_reg_reltn_id = assignregreltnid, a_r.cohort_id = request->cohort_id, a_r.reg_id
        = request->reg_id,
       a_r.beg_effective_dt_tm = cnvtdatetime(old->curdatetime), a_r.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100 00:00:00.00"), a_r.updt_cnt = 0,
       a_r.updt_applctx = reqinfo->updt_applctx, a_r.updt_task = reqinfo->updt_task, a_r.updt_id =
       reqinfo->updt_id,
       a_r.updt_dt_tm = cnvtdatetime(current_dt_tm)
      WITH nocounter
     ;end insert
     IF (curqual=1)
      SET reply->reg_status = "S"
      SET lst_updt_dt_tm_str = build("lst_updt_dt_tm_str: ",datetimezoneformat(cnvtdatetime(
         current_dt_tm),0,"MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
      SET assign_name = "ASSIGN_REG_RELTN_ID : "
      SET assign_id = assignregreltnid
      SET reply->assign_elig_reltn_id = assignregreltnid
      CALL echo("14")
     ELSE
      SET reply->reg_status = "F"
      CALL echo("15")
     ENDIF
    ENDIF
   ENDIF
   IF ((request->pt_elig_tracking_id > 0))
    CALL echo("16")
    SET continue = false
    SELECT INTO "nl:"
     a_e.*
     FROM assign_elig_reltn a_e
     WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
      AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     DETAIL
      old->curdatetime = cnvtdatetime(sysdate), old->cohort_id = a_e.cohort_id, old->assign_id = a_e
      .assign_elig_reltn_id
     WITH counter, forupdate(a_e)
    ;end select
    CALL echo("17")
    IF (curqual=1)
     CALL echo("18")
     IF ((old->cohort_id != request->cohort_id))
      CALL echo("19")
      UPDATE  FROM assign_elig_reltn a_e
       SET a_e.end_effective_dt_tm = cnvtdatetime(old->curdatetime), a_e.updt_cnt = (a_e.updt_cnt+ 1),
        a_e.updt_applctx = reqinfo->updt_applctx,
        a_e.updt_task = reqinfo->updt_task, a_e.updt_id = reqinfo->updt_id, a_e.updt_dt_tm =
        cnvtdatetime(sysdate)
       WHERE (a_e.assign_elig_reltn_id=old->assign_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET reply->elig_status = "F"
      ELSE
       CALL echo("201")
       SELECT INTO "nl:"
        num = seq(protocol_def_seq,nextval)"########################;rpO"
        FROM dual
        DETAIL
         assigneligreltnid = cnvtreal(num)
        WITH format, counter
       ;end select
       SET continue = true
      ENDIF
     ENDIF
     CALL echo("test")
    ELSE
     CALL echo("21")
     SET old->curdatetime = cnvtdatetime(sysdate)
     SELECT INTO "nl:"
      num = seq(protocol_def_seq,nextval)"########################;rpO"
      FROM dual
      DETAIL
       assigneligreltnid = cnvtreal(num)
      WITH format, counter
     ;end select
     SET continue = true
     CALL echo("23")
    ENDIF
    IF (continue=true)
     CALL echo("24")
     SET current_dt_tm = cnvtdatetime(sysdate)
     INSERT  FROM assign_elig_reltn a_e
      SET a_e.cohort_id = request->cohort_id, a_e.assign_elig_reltn_id = assigneligreltnid, a_e
       .pt_elig_tracking_id = request->pt_elig_tracking_id,
       a_e.beg_effective_dt_tm = cnvtdatetime(old->curdatetime), a_e.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100 00:00:00.00"), a_e.updt_cnt = 0,
       a_e.updt_applctx = reqinfo->updt_applctx, a_e.updt_task = reqinfo->updt_task, a_e.updt_id =
       reqinfo->updt_id,
       a_e.updt_dt_tm = cnvtdatetime(current_dt_tm)
      WITH nocounter
     ;end insert
     IF (curqual=1)
      SET reply->elig_status = "S"
      IF (((lst_updt_dt_tm_str="") OR (assign_name="")) )
       SET lst_updt_dt_tm_str = build("lst_updt_dt_tm_str: ",datetimezoneformat(cnvtdatetime(
          current_dt_tm),0,"MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
       SET assign_name = "ASSIGN_ELIG_RELTN_ID : "
       SET assign_id = assigneligreltnid
      ENDIF
     ELSE
      SET reply->elig_status = "F"
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSE
  CALL echo("26")
  SELECT INTO "nl:"
   a_r.*
   FROM assign_reg_reltn a_r
   WHERE (a_r.reg_id=request->reg_id)
    AND a_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    old->curdatetime = cnvtdatetime(sysdate), old->cohort_id = a_r.cohort_id, old->assign_id = a_r
    .assign_reg_reltn_id
   WITH counter, forupdate(a_r)
  ;end select
  IF (curqual=1)
   CALL echo("27")
   IF ((old->cohort_id != request->cohort_id))
    SET current_dt_tm = cnvtdatetime(sysdate)
    UPDATE  FROM assign_reg_reltn a_r
     SET a_r.end_effective_dt_tm = cnvtdatetime(old->curdatetime), a_r.updt_cnt = (a_r.updt_cnt+ 1),
      a_r.updt_applctx = reqinfo->updt_applctx,
      a_r.updt_task = reqinfo->updt_task, a_r.updt_id = reqinfo->updt_id, a_r.updt_dt_tm =
      cnvtdatetime(sysdate)
     WHERE (a_r.assign_reg_reltn_id=old->assign_id)
     WITH nocounter
    ;end update
    IF (curqual=1)
     CALL echo("28")
     SET reply->reg_status = "S"
     SET reply->status_data.status = "S"
     SET lst_updt_dt_tm_str = build("lst_updt_dt_tm_str: ",datetimezoneformat(cnvtdatetime(
        current_dt_tm),0,"MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
     SET assign_name = "ASSIGN_REG_RELTN_ID : "
     SET assign_id = old->assign_id
    ELSE
     SET reply->reg_status = "F"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 CALL echo("test1")
 SET reqinfo->commit_ind = false
 IF (((continue=true) OR (continue=false
  AND (request->cohort_id=0))) )
  IF ((reply->reg_status != "F"))
   IF ((reply->elig_status != "F"))
    IF (continue=true)
     EXECUTE strat_coh_status_update_func
    ENDIF
    IF ((reply->scs_funcstatus != "F"))
     SET reply->status_data.status = "S"
     IF ((old->cohort_id != 0)
      AND (old->cohort_id != request->cohort_id)
      AND (request->cohort_id != 0))
      SELECT INTO "NL:"
       FROM prot_cohort coh
       WHERE (coh.cohort_id=old->cohort_id)
       DETAIL
        old->stratum_id = coh.stratum_id
       WITH counter
      ;end select
      IF (curqual=1)
       SET qual_count += 1
       SET stat = alterlist(audit->qual,qual_count)
       SET audit->qual[qual_count].eventtype = "Modify"
       IF ((old->stratum_id=request->stratum_id))
        SET audit->qual[qual_count].eventname = "Cohort_Modify"
       ELSE
        SET audit->qual[qual_count].eventname = "Stratum_Modify"
        SELECT INTO "NL:"
         FROM prot_stratum ps
         WHERE ps.stratum_id IN (old->stratum_id, request->stratum_id)
         DETAIL
          IF ((ps.stratum_id=old->stratum_id))
           old->stratum_cohort_type_cd = ps.stratum_cohort_type_cd
          ELSE
           stratum_cohort_type_cd = ps.stratum_cohort_type_cd
          ENDIF
         WITH counter
        ;end select
        IF (curqual != 0)
         IF (uar_get_code_meaning(old->stratum_cohort_type_cd) != "DEFAULT"
          AND uar_get_code_meaning(stratum_cohort_type_cd) != "DEFAULT")
          SET qual_count += 1
          SET stat = alterlist(audit->qual,qual_count)
          SET audit->qual[qual_count].eventname = "Cohort_Modify"
          SET audit->qual[qual_count].eventtype = "Modify"
         ELSEIF (uar_get_code_meaning(old->stratum_cohort_type_cd) != "DEFAULT"
          AND uar_get_code_meaning(stratum_cohort_type_cd)="DEFAULT")
          SET qual_count += 1
          SET stat = alterlist(audit->qual,qual_count)
          SET audit->qual[qual_count].eventname = "Cohort_Delete"
          SET audit->qual[qual_count].eventtype = "Delete"
         ELSEIF (uar_get_code_meaning(old->stratum_cohort_type_cd)="DEFAULT"
          AND uar_get_code_meaning(stratum_cohort_type_cd) != "DEFAULT")
          SET qual_count += 1
          SET stat = alterlist(audit->qual,qual_count)
          SET audit->qual[qual_count].eventname = "Cohort_Add"
          SET audit->qual[qual_count].eventtype = "Add"
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ELSEIF ((old->cohort_id != 0)
      AND (old->cohort_id != request->cohort_id)
      AND (request->cohort_id=0))
      SELECT INTO "NL:"
       FROM prot_cohort coh
       WHERE (coh.cohort_id=old->cohort_id)
       DETAIL
        old->stratum_id = coh.stratum_id
       WITH counter
      ;end select
      IF (curqual=1)
       SELECT INTO "NL:"
        FROM prot_stratum ps
        WHERE (ps.stratum_id=old->stratum_id)
        DETAIL
         old->stratum_cohort_type_cd = ps.stratum_cohort_type_cd
        WITH counter
       ;end select
       IF (curqual != 0)
        SET qual_count += 1
        SET stat = alterlist(audit->qual,qual_count)
        SET audit->qual[qual_count].eventname = "Stratum_Delete"
        SET audit->qual[qual_count].eventtype = "Delete"
        IF ( NOT (uar_get_code_meaning(old->stratum_cohort_type_cd)="DEFAULT"))
         SET qual_count += 1
         SET stat = alterlist(audit->qual,qual_count)
         SET audit->qual[qual_count].eventname = "Cohort_Delete"
         SET audit->qual[qual_count].eventtype = "Delete"
        ENDIF
       ENDIF
      ENDIF
     ELSEIF ((old->cohort_id=0)
      AND (old->cohort_id != request->cohort_id)
      AND (request->cohort_id > 0))
      SELECT INTO "NL:"
       FROM prot_stratum ps
       WHERE (ps.stratum_id=request->stratum_id)
       DETAIL
        stratum_cohort_type_cd = ps.stratum_cohort_type_cd
       WITH counter
      ;end select
      IF (curqual != 0)
       SET qual_count += 1
       SET stat = alterlist(audit->qual,qual_count)
       SET audit->qual[qual_count].eventname = "Stratum_Add"
       SET audit->qual[qual_count].eventtype = "Add"
       IF ( NOT (uar_get_code_meaning(stratum_cohort_type_cd)="DEFAULT"))
        SET qual_count += 1
        SET stat = alterlist(audit->qual,qual_count)
        SET audit->qual[qual_count].eventname = "Cohort_Add"
        SET audit->qual[qual_count].eventtype = "Add"
       ENDIF
      ENDIF
     ENDIF
     SELECT INTO "NL:"
      FROM pt_prot_reg preg
      WHERE (preg.reg_id=request->reg_id)
      DETAIL
       person_id = preg.person_id
      WITH counter
     ;end select
     SET reqinfo->commit_ind = true
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((reply->reg_status="S"))
  SET reqinfo->commit_ind = true
 ENDIF
 CALL echo(build("commit: ",reqinfo->commit_ind))
 IF ((reply->status_data.status="S"))
  SET assign_id_audit = build3(3,assign_name,assign_id)
  SET participantname = concat(assign_id_audit," ",lst_updt_dt_tm_str," (UPDT_DT_TM)")
  CALL echorecord(audit,"RECORDRESULTSAUDITS",1)
  FOR (x = 1 TO qual_count)
    CASE (audit->qual[x].eventtype)
     OF "Add":
      EXECUTE cclaudit audit_mode, audit->qual[x].eventname, audit->qual[x].eventtype,
      "Person", "Patient", "Patient",
      "Origination", person_id, ""
     OF "Modify":
      EXECUTE cclaudit audit_mode, audit->qual[x].eventname, audit->qual[x].eventtype,
      "Person", "Patient", "Patient",
      "Amendment", person_id, participantname
     OF "Delete":
      EXECUTE cclaudit audit_mode, audit->qual[x].eventname, audit->qual[x].eventtype,
      "Person", "Patient", "Patient",
      "Destruction", person_id, participantname
    ENDCASE
  ENDFOR
 ENDIF
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
 IF (g_debug_ind=1)
  CALL echorecord(reply)
 ELSE
  CALL putjsonrecordtofile(reply)
 ENDIF
 SET last_mod = "003"
 SET mod_date = "Jan 30, 2021"
END GO
