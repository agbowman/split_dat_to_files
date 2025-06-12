CREATE PROGRAM ct_mp_add_pt_enrollments:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "JSON Request:" = ""
  WITH outdev, jsonrequest
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
 SET log_program_name = "CT_MP_ADD_PT_ENROLLMENTS"
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
 DECLARE g_debug_ind = i2 WITH protect, noconstant(0)
 IF (validate(debug_on,0))
  IF (debug_on=1)
   SET g_debug_ind = 1
  ENDIF
 ENDIF
 RECORD reply(
   1 rowstatus[*]
     2 status = c1
     2 ptprtreg = c1
     2 protmaster = c1
     2 pteligtrackingrltn = c1
     2 ptprtregid = f8
     2 conid = f8
     2 newaccessionnbr = vc
     2 prescreen_chg_ind = i2
     2 accession_nbr = c1
     2 episode_id = f8
     2 person_id = f8
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
 RECORD pt_amd_assignment(
   1 reg_id = f8
   1 prot_amendment_id = f8
   1 transfer_checked_amendment_id = f8
   1 assign_start_dt_tm = dq8
   1 assign_end_dt_tm = dq8
 )
 RECORD acc_tgt_request(
   1 prot_amendment_id = f8
   1 prot_master_id = f8
   1 requiredaccrualcd = f8
   1 person_id = f8
   1 person_list[*]
     2 person_id = f8
   1 participation_type_cd = f8
   1 application_nbr = i4
   1 pref_domain = vc
   1 pref_section = vc
   1 pref_name = vc
 )
 RECORD acc_tgt_reply(
   1 grouptargetaccrual = i2
   1 grouptargetaccrued = i2
   1 targetaccrual = i2
   1 totalaccrued = i2
   1 excludedpersonind = i2
   1 bfound = i2
   1 accrual_estimate_only_ind = i2
   1 track_tw_accrual = i2
   1 excluded_person_cnt = i4
   1 over_accrual_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (batchlistremoveperson(prot_master_id=f8,person_id=f8) =i2)
   CALL echo(build("BatchListRemovePerson::prot_master_id = ",prot_master_id))
   CALL echo(build("BatchListRemovePerson::person_id = ",person_id))
   DELETE  FROM ct_pt_prot_batch_list bl
    WHERE bl.person_id=person_id
     AND bl.prot_master_id=prot_master_id
    WITH nocounter
   ;end delete
   IF (curqual=0)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE new = i2 WITH protect, noconstant(0)
 DECLARE x = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE numofinserts = i2 WITH protect, noconstant(0)
 DECLARE curregupdtcnt = f8 WITH protect, noconstant(0.0)
 DECLARE accessionnbrnext = i2 WITH protect, noconstant(0)
 DECLARE accessionnbrprefix = c255 WITH protect, noconstant(fillstring(255," "))
 DECLARE accessionnbrsigdig = i2 WITH protect, noconstant(0)
 DECLARE cval = f8 WITH protect, noconstant(0.0)
 DECLARE cmean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE doinsert = i2 WITH protect, noconstant(0)
 DECLARE commitrow = i2 WITH protect, noconstant(0)
 DECLARE conid = f8 WITH protect, noconstant(0.0)
 DECLARE regid = f8 WITH protect, noconstant(0.0)
 DECLARE reltnid = f8 WITH protect, noconstant(0.0)
 DECLARE protid = f8 WITH protect, noconstant(0.0)
 DECLARE enrolling_cd = f8 WITH protect, noconstant(0.0)
 DECLARE unknown_cd = f8 WITH protect, noconstant(0.0)
 DECLARE schema_exists = i2 WITH protect, noconstant(0)
 DECLARE newaccessionnbr = c276 WITH protect, noconstant(fillstring(276," "))
 DECLARE dup_found = i2 WITH protect, noconstant(0)
 DECLARE enrolled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE syscancel_cd = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
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
 RECORD episoderequest(
   1 person_id = f8
   1 options = vc
   1 episode[*]
     2 episode_id = f8
     2 delete_ind = i2
     2 display = vc
     2 episode_type_cd = f8
     2 options = vc
     2 encounter[*]
       3 encntr_id = f8
       3 delete_ind = i2
       3 options = vc
     2 end_effective_dt_tm = dq8
 )
 RECORD episodereply(
   1 episode[*]
     2 episode_id = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET accessionnbrprefix = fillstring(255," ")
 SET newaccessionnbr = fillstring(276," ")
 SET cmean = fillstring(12," ")
 SET commitrow = false
 IF (( $JSONREQUEST=""))
  CALL populate_subeventstatus_rec("REQUEST","F","ct_mp_add_pt_enrollments","Invalid JSON Request",
   "reply")
  GO TO exit_script
 ENDIF
 FREE RECORD request
 SET stat = cnvtjsontorec( $JSONREQUEST)
 CALL echorecord(request)
 SET numofinserts = size(request->es,5)
 SET stat = alterlist(reply->rowstatus,numofinserts)
 SET schema_exists = checkdic("PT_PROT_REG.STATUS_ENUM","A",0)
 SET stat = uar_get_meaning_by_codeset(17270,"UNKNOWN",1,unknown_cd)
 SET stat = uar_get_meaning_by_codeset(17349,"ENROLLING",1,enrolling_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"ENROLLED",1,enrolled_cd)
 SET stat = uar_get_meaning_by_codeset(17901,"SYSCANCEL",1,syscancel_cd)
 CALL echo(build("NumOfInserts = ",numofinserts))
 FOR (i = 1 TO numofinserts)
   SET reply->rowstatus[i].status = "F"
   SET reply->rowstatus[i].ptprtreg = "F"
   SET reply->rowstatus[i].protmaster = "F"
   SET reply->rowstatus[i].pteligtrackingrltn = "Z"
   SET reply->rowstatus[i].accession_nbr = "F"
   SET doinsert = true
   IF ((request->batch_enroll_ind=1))
    IF (doinsert=true)
     SET acc_tgt_request->prot_master_id = request->es[i].protmasterid
     SET acc_tgt_request->prot_amendment_id = request->es[i].protamendmentid
     SET acc_tgt_request->person_id = request->es[i].personid
     EXECUTE ct_get_validate_target_accrual  WITH replace("REQUEST","ACC_TGT_REQUEST"), replace(
      "REPLY","ACC_TGT_REPLY")
     IF ((acc_tgt_reply->status_data.status != "S"))
      SET reply->rowstatus[i].status = "F"
      SET doinsert = false
     ELSE
      IF ((acc_tgt_reply->accrual_estimate_only_ind=0))
       IF ((acc_tgt_reply->over_accrual_ind=1))
        SET doinsert = false
        SET reply->rowstatus[i].status = "T"
       ENDIF
      ENDIF
     ENDIF
     FREE RECORD acc_tgt_request
     FREE RECORD acc_tgt_reply
    ENDIF
   ENDIF
   IF (size(trim(request->es[i].protaccessionnbr),1)=0)
    IF (doinsert=true)
     SELECT INTO "nl:"
      pr_m.*
      FROM prot_master pr_m,
       prot_amendment pr_am
      WHERE (pr_am.prot_amendment_id=request->es[i].protamendmentid)
       AND pr_m.prot_master_id=pr_am.prot_master_id
      DETAIL
       protid = pr_m.prot_master_id, accessionnbrnext = (pr_m.accession_nbr_last+ 1),
       accessionnbrprefix = pr_m.accession_nbr_prefix,
       accessionnbrsigdig = pr_m.accession_nbr_sig_dig
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET reply->rowstatus[i].status = "F"
      SET reply->rowstatus[i].protmaster = "L"
      SET doinsert = false
     ENDIF
    ENDIF
    IF (doinsert=true)
     SET dup_found = 1
     WHILE (dup_found=1)
       SET newaccessionnbr = build(accessionnbrnext)
       SET len = size(build(newaccessionnbr),1)
       CALL echo(build("len = ",len))
       CALL echo(build("AccessionNbrSigDig - len = ",(accessionnbrsigdig - len)))
       FOR (k = 1 TO (accessionnbrsigdig - len))
         SET newaccessionnbr = build("0",build(newaccessionnbr))
       ENDFOR
       SET newaccessionnbr = build(accessionnbrprefix,newaccessionnbr)
       SET dup_found = 0
       SELECT INTO "nl:"
        ppr.prot_master_id, ppr.person_id, ppr.end_effective_dt_tm,
        ppr.prot_accession_nbr, ppr.*
        FROM pt_prot_reg ppr
        WHERE (ppr.prot_master_id=request->es[i].protmasterid)
        ORDER BY ppr.person_id, ppr.end_effective_dt_tm DESC
        HEAD ppr.person_id
         IF (ppr.prot_accession_nbr=newaccessionnbr)
          dup_found = 1
         ENDIF
        WITH nocounter
       ;end select
       IF (dup_found=1)
        SET accessionnbrnext += 1
       ENDIF
     ENDWHILE
     UPDATE  FROM prot_master pr_m
      SET pr_m.accession_nbr_last = accessionnbrnext
      WHERE pr_m.prot_master_id=protid
      WITH nocounter
     ;end update
     IF (curqual=1)
      SET reply->rowstatus[i].protmaster = "S"
     ELSE
      SET doinsert = false
     ENDIF
    ENDIF
   ELSE
    SET dup_found = 0
    SELECT INTO "nl:"
     pt.prot_accession_nbr
     FROM pt_prot_reg pt
     WHERE (pt.prot_master_id=request->es[i].protmasterid)
      AND (pt.prot_accession_nbr=request->es[i].protaccessionnbr)
      AND pt.end_effective_dt_tm >= cnvtdatetime(sysdate)
     DETAIL
      dup_found = 1
     WITH nocounter
    ;end select
    IF (dup_found=1)
     SET reply->rowstatus[i].status = "F"
     SET reply->rowstatus[i].accession_nbr = "U"
     SET doinsert = false
    ELSE
     SET newaccessionnbr = request->es[i].protaccessionnbr
    ENDIF
   ENDIF
   IF (doinsert=true)
    CALL echo("INSIDE EPISODE INSERT")
    SET reply->rowstatus[i].episode_id = 0.0
    IF ((request->es[i].episode_type_cd > 0))
     SET episoderequest->person_id = request->es[i].personid
     SET stat = alterlist(episoderequest->episode,1)
     SET episoderequest->episode[1].episode_type_cd = request->es[i].episode_type_cd
     SELECT INTO "nl:"
      pm.primary_mnemonic
      FROM prot_master pm
      WHERE (pm.prot_master_id=request->es[i].protmasterid)
       AND pm.end_effective_dt_tm >= cnvtdatetime(sysdate)
      DETAIL
       episoderequest->episode[1].display = pm.primary_mnemonic
      WITH nocounter
     ;end select
     SET tmp = i
     CALL echorecord(episoderequest)
     EXECUTE pm_epi_upt_episodes  WITH replace("REQUEST","EPISODEREQUEST"), replace("REPLY",
      "EPISODEREPLY")
     SET i = tmp
     CALL echorecord(episodereply)
     IF ((episodereply->status_data.status="S"))
      IF (size(episodereply->episode,5) > 0)
       SET reply->rowstatus[i].episode_id = episodereply->episode[1].episode_id
      ENDIF
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     num = seq(protocol_def_seq,nextval)
     FROM dual
     DETAIL
      regid = cnvtreal(num)
     WITH format, counter
    ;end select
    CALL echo("Insert pt_prot_reg")
    CALL echo(build("regid = ",regid))
    IF (schema_exists=2)
     INSERT  FROM pt_prot_reg p_pr_r
      SET p_pr_r.off_study_dt_tm =
       IF ((request->es[i].dateoffstudy != "0")) cnvtdatetime(request->es[i].dateoffstudy)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       , p_pr_r.tx_start_dt_tm =
       IF ((request->es[i].dateontherapy != "0")) cnvtdatetime(request->es[i].dateontherapy)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       , p_pr_r.tx_completion_dt_tm =
       IF ((request->es[i].dateofftherapy != "0")) cnvtdatetime(request->es[i].dateofftherapy)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       ,
       p_pr_r.first_pd_failure_dt_tm =
       IF ((request->es[i].datefirstpdfail != "0")) cnvtdatetime(request->es[i].datefirstpdfail)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       , p_pr_r.first_pd_dt_tm =
       IF ((request->es[i].datefirstpd != "0")) cnvtdatetime(request->es[i].datefirstpd)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       , p_pr_r.first_cr_dt_tm =
       IF ((request->es[i].datefirstcr != "0")) cnvtdatetime(request->es[i].datefirstcr)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       ,
       p_pr_r.nomenclature_id =
       IF ((request->es[i].nomenclatureid != 0)) request->es[i].nomenclatureid
       ELSE 0.0
       ENDIF
       , p_pr_r.removal_organization_id =
       IF ((request->es[i].removalorgid != 0)) request->es[i].removalorgid
       ELSE 0.0
       ENDIF
       , p_pr_r.removal_person_id =
       IF ((request->es[i].removalperid != 0)) request->es[i].removalperid
       ELSE 0.0
       ENDIF
       ,
       p_pr_r.enrolling_organization_id =
       IF ((request->es[i].enrollingorgid != 0)) request->es[i].enrollingorgid
       ELSE 0.0
       ENDIF
       , p_pr_r.best_response_cd =
       IF ((request->es[i].bestresp_cd != 0)) request->es[i].bestresp_cd
       ELSE 0.0
       ENDIF
       , p_pr_r.first_dis_rel_event_death_cd =
       IF ((request->es[i].firstdisrelevent_cd != 0)) request->es[i].firstdisrelevent_cd
       ELSE 0.0
       ENDIF
       ,
       p_pr_r.diagnosis_type_cd =
       IF ((request->es[i].diagtype_cd != 0)) request->es[i].diagtype_cd
       ELSE unknown_cd
       ENDIF
       , p_pr_r.on_tx_organization_id =
       IF ((request->es[i].ontxorgid != 0)) request->es[i].ontxorgid
       ELSE 0.0
       ENDIF
       , p_pr_r.on_tx_assign_prsnl_id =
       IF ((request->es[i].ontxperid != 0)) request->es[i].ontxperid
       ELSE 0.0
       ENDIF
       ,
       p_pr_r.on_tx_comment = request->es[i].ontxcomment, p_pr_r.status_enum = request->es[i].
       statusenum, p_pr_r.prot_arm_id = request->es[i].protarmid,
       p_pr_r.prot_master_id = request->es[i].protmasterid, p_pr_r.beg_effective_dt_tm = cnvtdatetime
       (sysdate), p_pr_r.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
       p_pr_r.pt_prot_reg_id = regid, p_pr_r.reg_id = regid, p_pr_r.person_id = request->es[i].
       personid,
       p_pr_r.prot_accession_nbr = newaccessionnbr, p_pr_r.on_study_dt_tm = cnvtdatetime(request->es[
        i].dateonstudy), p_pr_r.updt_cnt = 0,
       p_pr_r.updt_applctx = reqinfo->updt_applctx, p_pr_r.updt_task = reqinfo->updt_task, p_pr_r
       .updt_id = reqinfo->updt_id,
       p_pr_r.updt_dt_tm = cnvtdatetime(sysdate), p_pr_r.removal_reason_cd = request->es[i].
       removalreasoncd, p_pr_r.removal_reason_desc = request->es[i].removalreasondesc,
       p_pr_r.reason_off_tx_cd = request->es[i].offtxremovalreasoncd, p_pr_r.reason_off_tx_desc =
       request->es[i].offtxremovalreasondesc, p_pr_r.off_tx_removal_organization_id = request->es[i].
       removaltxorgid,
       p_pr_r.off_tx_removal_person_id = request->es[i].removaltxperid, p_pr_r.episode_id = reply->
       rowstatus[i].episode_id
      WITH nocounter
     ;end insert
    ELSE
     INSERT  FROM pt_prot_reg p_pr_r
      SET p_pr_r.off_study_dt_tm =
       IF ((request->es[i].dateoffstudy != "0")) cnvtdatetime(request->es[i].dateoffstudy)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       , p_pr_r.tx_start_dt_tm =
       IF ((request->es[i].dateontherapy != "0")) cnvtdatetime(request->es[i].dateontherapy)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       , p_pr_r.tx_completion_dt_tm =
       IF ((request->es[i].dateofftherapy != "0")) cnvtdatetime(request->es[i].dateofftherapy)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       ,
       p_pr_r.first_pd_failure_dt_tm =
       IF ((request->es[i].datefirstpdfail != "0")) cnvtdatetime(request->es[i].datefirstpdfail)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       , p_pr_r.first_pd_dt_tm =
       IF ((request->es[i].datefirstpd != "0")) cnvtdatetime(request->es[i].datefirstpd)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       , p_pr_r.first_cr_dt_tm =
       IF ((request->es[i].datefirstcr != "0")) cnvtdatetime(request->es[i].datefirstcr)
       ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
       ENDIF
       ,
       p_pr_r.nomenclature_id =
       IF ((request->es[i].nomenclatureid != 0)) request->es[i].nomenclatureid
       ELSE 0.0
       ENDIF
       , p_pr_r.removal_organization_id =
       IF ((request->es[i].removalorgid != 0)) request->es[i].removalorgid
       ELSE 0.0
       ENDIF
       , p_pr_r.removal_person_id =
       IF ((request->es[i].removalperid != 0)) request->es[i].removalperid
       ELSE 0.0
       ENDIF
       ,
       p_pr_r.enrolling_organization_id =
       IF ((request->es[i].enrollingorgid != 0)) request->es[i].enrollingorgid
       ELSE 0.0
       ENDIF
       , p_pr_r.best_response_cd =
       IF ((request->es[i].bestresp_cd != 0)) request->es[i].bestresp_cd
       ELSE 0.0
       ENDIF
       , p_pr_r.first_dis_rel_event_death_cd =
       IF ((request->es[i].firstdisrelevent_cd != 0)) request->es[i].firstdisrelevent_cd
       ELSE 0.0
       ENDIF
       ,
       p_pr_r.diagnosis_type_cd =
       IF ((request->es[i].diagtype_cd != 0)) request->es[i].diagtype_cd
       ELSE unknown_cd
       ENDIF
       , p_pr_r.prot_arm_id = request->es[i].protarmid, p_pr_r.prot_master_id = request->es[i].
       protmasterid,
       p_pr_r.beg_effective_dt_tm = cnvtdatetime(sysdate), p_pr_r.end_effective_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00:00.00"), p_pr_r.pt_prot_reg_id = regid,
       p_pr_r.reg_id = regid, p_pr_r.person_id = request->es[i].personid, p_pr_r.prot_accession_nbr
        = newaccessionnbr,
       p_pr_r.on_study_dt_tm = cnvtdatetime(request->es[i].dateonstudy), p_pr_r.updt_cnt = 0, p_pr_r
       .updt_applctx = reqinfo->updt_applctx,
       p_pr_r.updt_task = reqinfo->updt_task, p_pr_r.updt_id = reqinfo->updt_id, p_pr_r.updt_dt_tm =
       cnvtdatetime(sysdate),
       p_pr_r.removal_reason_cd = request->es[i].removalreasoncd, p_pr_r.removal_reason_desc =
       request->es[i].removalreasondesc, p_pr_r.reason_off_tx_cd = request->es[i].
       offtxremovalreasoncd,
       p_pr_r.reason_off_tx_desc = request->es[i].offtxremovalreasondesc, p_pr_r
       .off_tx_removal_organization_id = request->es[i].removaltxorgid, p_pr_r
       .off_tx_removal_person_id = request->es[i].removaltxperid,
       p_pr_r.episode_id = reply->rowstatus[i].episode_id
      WITH nocounter
     ;end insert
    ENDIF
    IF (curqual=1)
     SET doinsert = true
     SET reply->rowstatus[i].ptprtreg = "S"
    ELSE
     SET doinsert = false
    ENDIF
   ENDIF
   IF (doinsert=true)
    SET pt_amd_assignment->reg_id = regid
    SET pt_amd_assignment->prot_amendment_id = request->es[i].protamendmentid
    SET pt_amd_assignment->transfer_checked_amendment_id = request->es[i].
    transfer_checked_amendment_id
    CALL echo(request->es[i].dateonstudy)
    IF ((request->es[i].dateamendmentassigned="0"))
     SET pt_amd_assignment->assign_start_dt_tm = cnvtdatetime(request->es[i].dateonstudy)
    ELSE
     SET pt_amd_assignment->assign_start_dt_tm = cnvtdatetime(request->es[i].dateamendmentassigned)
    ENDIF
    IF ((request->es[i].dateoffstudy > "0"))
     SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime(request->es[i].dateoffstudy)
    ELSE
     SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
    ENDIF
    SET caaa_status = "F"
    EXECUTE ct_add_a_a_func
    IF (caaa_status != "S")
     SET doinsert = false
    ENDIF
   ENDIF
   IF (doinsert=true)
    IF ((request->es[i].pteligtrackingid != 0))
     SET doinsert = false
     CALL echo("Get Unique ID for Reltn")
     SELECT INTO "nl:"
      num = seq(protocol_def_seq,nextval)
      FROM dual
      DETAIL
       reltnid = cnvtreal(num)
      WITH format, counter
     ;end select
     CALL echo("BEFORE - Insert pt_reg_elig_reltn")
     INSERT  FROM pt_reg_elig_reltn rltn
      SET rltn.pt_reg_elig_reltn_id = reltnid, rltn.reg_id = regid, rltn.pt_elig_tracking_id =
       request->es[i].pteligtrackingid,
       rltn.updt_cnt = 0, rltn.updt_applctx = reqinfo->updt_applctx, rltn.updt_task = reqinfo->
       updt_task,
       rltn.updt_id = reqinfo->updt_id, rltn.updt_dt_tm = cnvtdatetime(sysdate), rltn.active_ind = 1,
       rltn.active_status_cd = reqdata->active_status_cd, rltn.active_status_dt_tm = cnvtdatetime(
        sysdate), rltn.active_status_prsnl_id = reqinfo->updt_id
     ;end insert
     IF (curqual=1)
      SET doinsert = true
      SET reply->rowstatus[i].pteligtrackingrltn = "S"
     ELSE
      SET doinsert = false
     ENDIF
     CALL echo(build("ReltnID = ",reltnid))
     CALL echo(build("RegID = ",regid))
     CALL echo(build("Request->Es[i]->PtEligTrackingID = ",request->es[i].pteligtrackingid))
     CALL echo("AFTER - Insert pt_reg_elig_reltn")
    ENDIF
   ELSE
    SET doinsert = false
   ENDIF
   IF (doinsert=true)
    EXECUTE ct_get_prescreen_pref  WITH replace("REPLY","PREF_REPLY")
    IF ((pref_reply->pref_value=1))
     IF (enrolled_cd > 0)
      IF ((request->es[i].protmasterid > 0))
       SELECT INTO "NL:"
        FROM pt_prot_prescreen pps
        WHERE (pps.person_id=request->es[i].personid)
         AND (pps.prot_master_id=request->es[i].protmasterid)
         AND pps.screening_status_cd != syscancel_cd
        DETAIL
         status_request->pt_prot_prescreen_id = pps.pt_prot_prescreen_id, status_request->status_cd
          = enrolled_cd, status_request->status_comment_text = ""
        WITH nocounter
       ;end select
       IF ((status_request->pt_prot_prescreen_id > 0))
        EXECUTE ct_chg_prescreen_status  WITH replace("REQUEST","STATUS_REQUEST"), replace("REPLY",
         "STATUS_REPLY")
        IF ((status_reply->status_data.status != "S"))
         SET doinsert = false
        ELSE
         SET reply->rowstatus[i].prescreen_chg_ind = 1
         SET doinsert = doinsert
        ENDIF
       ELSE
        SET doinsert = doinsert
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (doinsert=true)
    IF (enrolled_cd > 0)
     IF ((request->es[i].protmasterid > 0))
      SELECT INTO "nl:"
       FROM ct_pt_prot_batch_list bl
       WHERE (bl.person_id=request->es[i].personid)
        AND (bl.prot_master_id=request->es[i].protmasterid)
       WITH nocounter
      ;end select
      IF (curqual > 0)
       CALL batchlistremoveperson(request->es[i].protmasterid,request->es[i].personid)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET reqinfo->commit_ind = doinsert
   IF (doinsert=true)
    SET reply->rowstatus[i].status = "S"
    SET reply->rowstatus[i].ptprtregid = regid
    SET reply->rowstatus[i].conid = conid
    SET reply->rowstatus[i].newaccessionnbr = newaccessionnbr
    SET reply->rowstatus[i].person_id = request->es[i].personid
    CALL echo("COMMIT")
    COMMIT
   ELSE
    CALL echo("ROLLBACK")
    ROLLBACK
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 CALL echo("Reply->status_data->status =",0)
 CALL echo(reply->status_data.status,1)
 CALL echo(build("NewAccessionNbr = ",newaccessionnbr))
 CALL echo(build("AccessionNbrSigDig = ",accessionnbrsigdig))
 CALL echo(build("ReltnID = ",reltnid))
 CALL echo(build("RegID = ",regid))
 CALL echo(build("Request->Es[1]->PtEligTrackingID = ",request->es[1].pteligtrackingid))
 CALL echo("CommitRow = ",0)
 CALL echo(commitrow,1)
 CALL echo("-------------------------------------------------------------")
 FOR (i = 1 TO numofinserts)
   CALL echo(build("Reply->RowStatus[i]->ProtMaster = ",reply->rowstatus[i].protmaster))
   CALL echo("Reply->RowStatus[i]->PtPrtReg = ",0)
   CALL echo(reply->rowstatus[i].ptprtreg,1)
   CALL echo(build("Reply->RowStatus[i]->PtEligTrackingRltn = ",reply->rowstatus[i].
     pteligtrackingrltn))
   CALL echo("Reply->RowStatus[i]->Status = ",0)
   CALL echo(reply->rowstatus[i].status,1)
   CALL echo("-------------------------------------------------------------")
 ENDFOR
#noecho
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
 FREE RECORD status_request
 FREE RECORD status_reply
 FREE RECORD pref_reply
 IF (g_debug_ind=1)
  CALL echorecord(reply)
 ELSE
  CALL putjsonrecordtofile(reply)
 ENDIF
 SET last_mod = "002"
 SET mod_date = "FEB 17, 2023"
END GO
