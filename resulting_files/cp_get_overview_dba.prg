CREATE PROGRAM cp_get_overview:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person ID" = 0.0,
  "Encounter ID" = 0.0,
  "Personnel ID" = 0.0
  WITH outdev, pid, eid,
  prid
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
 DECLARE script_start_curtime3 = dq8 WITH constant(curtime3), private
 DECLARE cp_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4003197,"CPM"))
 DECLARE pathway_status_proposed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4003352,
   "PROPOSED"))
 DECLARE pathway_type_oncology = f8 WITH protect, constant(uar_get_code_by("MEANING",4003197,
   "ONCOLOGY"))
 DECLARE pathway_type_legacydebug = f8 WITH protect, constant(uar_get_code_by("MEANING",4003197,
   "LEGACYDEBUG"))
 DECLARE user_logic_domain_id = f8 WITH protect, constant(getuserlogicaldomain(reqinfo->updt_id))
 DECLARE system_suggested_pathway_action_type_cd = f8 WITH protect, constant(uar_get_code_by(
   "MEANING",4003135,"SYSPWSUGGEST"))
 DECLARE suggested_by_rfv_action_detail_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   4003199,"SUGGESTBYRFV"))
 DECLARE suggested_by_dx_action_detail_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   4003199,"SUGGESTBYDX"))
 DECLARE suggested_by_ord_action_detail_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",
   4003199,"SUGGESTBYORD"))
 DECLARE suggested_by_rule_action_detail_type_cd = f8 WITH protect, constant(uar_get_code_by(
   "MEANING",4003199,"RULESUGGEST"))
 DECLARE suggested_by_prsnl_meaning = vc WITH protect, constant("SUGGESTBYPRSNL")
 DECLARE suggested_by_rfv_meaning = vc WITH protect, constant("SUGGESTBYRFV")
 DECLARE suggested_by_dx_meaning = vc WITH protect, constant("SUGGESTBYDX")
 DECLARE suggested_by_ord_meaning = vc WITH protect, constant("SUGGESTBYORD")
 DECLARE suggested_by_rule_meaning = vc WITH protect, constant("RULESUGGEST")
 DECLARE main(null) = null
 DECLARE getprovidername(null) = null WITH protect
 DECLARE getpathwayactivity(null) = null WITH protect
 DECLARE getsuggestedpathways(null) = null WITH protect
 DECLARE getpathwaylist(null) = null WITH protect
 DECLARE getdefaultbylastactivity(null) = null WITH protect
 DECLARE removedeletedpathwaysfromavailable(null) = null WITH protect
 IF ( NOT (validate(pathway_activity_reply)))
  RECORD pathway_activity_reply(
    1 activity_cnt = i4
    1 activity_qual[*]
      2 pathway_name = vc
      2 auto_added_ind = i2
      2 beg_effective_dt_tm = dq8
      2 comment_txt = vc
      2 cp_pathway_activity_id = f8
      2 cp_pathway_id = f8
      2 pathway_instance_id = f8
      2 encntr_id = f8
      2 end_effective_dt_tm = dq8
      2 pathway_activity_status_cd = f8
      2 pathway_activity_status_mean = vc
      2 person_id = f8
      2 rowid = vc
      2 updt_id = f8
      2 updt_name = vc
      2 updt_dt_tm = dq8
      2 off_pathway_ind = i2
      2 clinical_trial_ind = i2
      2 diagnosis_nomen_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(pathway_suggestions_reply)))
  RECORD pathway_suggestions_reply(
    1 person_id = f8
    1 encounter_id = f8
    1 suggested_pathway_cnt = i4
    1 suggested_pathways[*]
      2 pathway_id = f8
      2 pathway_name = vc
      2 pathway_type_cd = f8
      2 concept_cd = f8
      2 qualifying_nomenclature_cnt = i4
      2 qualifying_nomenclature[*]
        3 nomenclature_id = f8
        3 nomenclature_display = vc
        3 problem_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 provider_name = vc
    1 activity_cnt = i4
    1 activity_qual[*]
      2 pathway_name = vc
      2 auto_added_ind = i2
      2 beg_effective_dt_tm = dq8
      2 comment_txt = vc
      2 cp_pathway_activity_id = f8
      2 cp_pathway_id = f8
      2 pathway_instance_id = f8
      2 encntr_id = f8
      2 end_effective_dt_tm = dq8
      2 pathway_activity_status_cd = f8
      2 pathway_activity_status_mean = vc
      2 person_id = f8
      2 rowid = vc
      2 updt_id = f8
      2 updt_name = vc
      2 updt_dt_tm = dq8
      2 off_pathway_ind = i2
      2 clinical_trial_ind = i2
      2 diagnosis_nomen_id = f8
    1 suggest_cnt = i4
    1 suggest_qual[*]
      2 pathway_name = vc
      2 cp_pathway_id = f8
      2 cp_instance_id = f8
      2 proposed_by_name = vc
      2 proposed_by_id = f8
      2 proposed_by_cred = vc
      2 propose_dt_tm = dq8
      2 pathway_status_meaning = vc
      2 proposed_by_source_meaning = vc
      2 proposed_by_source_name = vc
      2 pathway_diagram_url = vc
    1 pathway_list_cnt = i4
    1 pathway_list[*]
      2 cp_pathway_id = f8
      2 pathway_name = vc
      2 pathway_diagram_url = vc
      2 default_category_mean = vc
      2 deleted_pathway_flag = i2
      2 pathway_status_cd = f8
    1 pathway_activity_status_display
      2 complete_display = vc
      2 active_display = vc
      2 void_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SUBROUTINE main(null)
   DECLARE main_start_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("In main()",log_level_debug)
   CALL getpathwaylist(null)
   CALL getprovidername(null)
   CALL getpathwayactivity(null)
   CALL getsuggestedpathways(null)
   CALL getdefaultcategorymeans(null)
   CALL getdefaultbylastactivity(null)
   CALL getpathwayactivitystatustypes(null)
   CALL removedeletedpathwaysfromavailable(null)
   CALL log_message(build("Exit main(), Elapsed time in seconds:",((curtime3 - main_start_curtime3)/
     100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getdefaultbylastactivity(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getDefaultByLastActivity()",log_level_debug)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE active_pathway_status = f8 WITH constant(uar_get_code_by("MEANING",4003352,"ACTIVE"))
   DECLARE savedoc_pathway_status = f8 WITH constant(uar_get_code_by("MEANING",4003199,"SAVEDOC"))
   DECLARE order_select_status = f8 WITH constant(uar_get_code_by("MEANING",4003199,"ORDSELECT"))
   DECLARE treat_select_status = f8 WITH constant(uar_get_code_by("MEANING",4003199,"TREATSEL"))
   IF ((reply->activity_cnt > 0))
    SELECT INTO "NL:"
     FROM cp_node cn,
      cp_pathway_action cpa,
      cp_pathway_action cpa2,
      cp_pathway_activity cpat,
      encounter e,
      cp_pathway_action_detail cpad1,
      cp_pathway_action_detail cpad2
     PLAN (e
      WHERE (e.person_id= $PID))
      JOIN (cpa
      WHERE cpa.encntr_id=e.encntr_id
       AND expand(idx,1,reply->activity_cnt,cpa.pathway_instance_id,reply->activity_qual[idx].
       pathway_instance_id,
       "ACTIVE",reply->activity_qual[idx].pathway_activity_status_mean))
      JOIN (cn
      WHERE cn.cp_node_id=cpa.cp_node_id
       AND cn.active_ind=1)
      JOIN (cpat
      WHERE cpat.pathway_instance_id=cpa.pathway_instance_id
       AND cpat.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND cpat.person_id=e.person_id)
      JOIN (cpad1
      WHERE cpad1.cp_pathway_action_id=cpa.cp_pathway_action_id
       AND cpad1.cp_action_detail_type_cd=treat_select_status)
      JOIN (cpa2
      WHERE cpa2.cp_node_id=cpa.cp_node_id
       AND cpa2.pathway_instance_id=cpa.pathway_instance_id
       AND cpa2.action_dt_tm > cpa.action_dt_tm)
      JOIN (cpad2
      WHERE cpad2.cp_pathway_action_id=cpa2.cp_pathway_action_id
       AND cpad2.cp_action_detail_type_cd IN (savedoc_pathway_status, order_select_status))
     ORDER BY cpa.action_dt_tm DESC
     HEAD cpa.pathway_instance_id
      IF (cpat.pathway_activity_status_cd=active_pathway_status)
       pos = locateval(idx,1,reply->pathway_list_cnt,cn.cp_pathway_id,reply->pathway_list[idx].
        cp_pathway_id)
       IF (pos > 0)
        reply->pathway_list[pos].default_category_mean = cn.category_mean
       ENDIF
      ENDIF
     WITH nocounter, expand = 1
    ;end select
   ENDIF
   CALL log_message(build("Exit getDefaultByLastActivity(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getprovidername(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin getProviderName()",log_level_debug)
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM prsnl p
    PLAN (p
     WHERE p.person_id=cnvtreal( $PRID))
    HEAD REPORT
     reply->provider_name = p.name_full_formatted
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getProviderName(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getpathwayactivity(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE vcparserstring = vc WITH noconstant(""), protect
   DECLARE activity_cnt = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   CALL log_message("Begin getPathwayActivity()",log_level_debug)
   SET vcparserstring = build("execute cp_get_pathway_activity ^NOFORMS^, ", $PID,",0.0 go")
   CALL parser(vcparserstring)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = pathway_activity_reply->activity_cnt)
    PLAN (d1)
    HEAD d1.seq
     IF (locateval(idx,1,reply->pathway_list_cnt,pathway_activity_reply->activity_qual[d1.seq].
      cp_pathway_id,reply->pathway_list[idx].cp_pathway_id) > 0)
      activity_cnt += 1
      IF (activity_cnt > size(reply->activity_qual,5))
       stat = alterlist(reply->activity_qual,(activity_cnt+ 10))
      ENDIF
      stat = movereclist(pathway_activity_reply->activity_qual,reply->activity_qual,d1.seq,(
       activity_cnt - 1),1,
       true)
     ENDIF
    FOOT REPORT
     reply->activity_cnt = activity_cnt, stat = alterlist(reply->activity_qual,activity_cnt)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getPathwayActivity(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsuggestedpathways(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   DECLARE pcnt = i2 WITH private, noconstant(0)
   DECLARE cur_source_meaning = vc WITH noconstant(""), protect
   DECLARE cur_source_name = vc WITH noconstant(""), protect
   DECLARE pathway_status_active = f8 WITH protect, constant(uar_get_code_by("MEANING",4003198,
     "ACTIVE"))
   CALL log_message("Begin getSuggestedPathways()",log_level_debug)
   SELECT INTO "nl:"
    FROM cp_pathway_activity cpa,
     (left JOIN cp_pathway_action cpac ON cpac.pathway_instance_id=cpa.pathway_instance_id
      AND cpac.action_type_cd=system_suggested_pathway_action_type_cd),
     (left JOIN cp_pathway_action_detail cpacd ON cpacd.cp_pathway_action_id=cpac
     .cp_pathway_action_id
      AND ((cpacd.action_detail_entity_name IN ("NOMENCLATURE", "ORDER_CATALOG_SYNONYM",
     "ORDER_SENTENCE")) OR (cpacd.cp_action_detail_type_cd IN (
     suggested_by_rule_action_detail_type_cd))) ),
     (left JOIN nomenclature n ON n.nomenclature_id=cpacd.action_detail_entity_id),
     (left JOIN order_catalog_synonym ocs ON ocs.synonym_id=cpacd.action_detail_entity_id),
     (left JOIN order_sentence os ON os.order_sentence_id=cpacd.action_detail_entity_id
      AND os.parent_entity_name="ORDER_CATALOG_SYNONYM"),
     (left JOIN order_catalog_synonym os_ocs ON os_ocs.synonym_id=os.parent_entity_id),
     cp_pathway cp,
     prsnl pr
    PLAN (cpa
     WHERE (cpa.encntr_id= $EID)
      AND (cpa.person_id= $PID)
      AND cpa.pathway_activity_status_cd=pathway_status_proposed_cd
      AND cpa.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (cp
     WHERE cp.cp_pathway_id=cpa.cp_pathway_id
      AND cp.pathway_type_cd IN (cp_type_cd, pathway_type_oncology, pathway_type_legacydebug)
      AND cp.active_ind=1
      AND cp.pathway_status_cd=pathway_status_active
      AND cp.logical_domain_id=user_logic_domain_id)
     JOIN (pr
     WHERE pr.person_id=cpa.prsnl_id)
     JOIN (cpac)
     JOIN (cpacd)
     JOIN (n)
     JOIN (ocs)
     JOIN (os)
     JOIN (os_ocs)
    ORDER BY cpa.updt_dt_tm, cpa.pathway_instance_id, cpac.cp_pathway_action_id,
     cpacd.cp_pathway_action_detail_id
    HEAD REPORT
     pcnt = 0
    HEAD cpa.pathway_instance_id
     pcnt += 1
     IF (size(reply->suggest_qual,5) < pcnt)
      stat = alterlist(reply->suggest_qual,(pcnt+ 10))
     ENDIF
     reply->suggest_qual[pcnt].cp_pathway_id = cp.cp_pathway_id, reply->suggest_qual[pcnt].
     pathway_name = cp.pathway_name, reply->suggest_qual[pcnt].proposed_by_id = cpa.prsnl_id,
     reply->suggest_qual[pcnt].proposed_by_name = pr.name_full_formatted, reply->suggest_qual[pcnt].
     cp_instance_id = cpa.pathway_instance_id, reply->suggest_qual[pcnt].propose_dt_tm = getutcdttm(
      cpa.beg_effective_dt_tm),
     reply->suggest_qual[pcnt].pathway_status_meaning = uar_get_code_meaning(cpa
      .pathway_activity_status_cd), reply->suggest_qual[pcnt].proposed_by_cred = uar_get_code_display
     (pr.position_cd)
    DETAIL
     IF (cpac.pathway_instance_id > 0
      AND cpac.action_type_cd=system_suggested_pathway_action_type_cd
      AND cpacd.action_detail_entity_id > 0)
      IF (cpacd.cp_action_detail_type_cd=suggested_by_rfv_action_detail_type_cd)
       cur_source_meaning = suggested_by_rfv_meaning, cur_source_name = n.source_string
      ELSEIF (cpacd.cp_action_detail_type_cd=suggested_by_dx_action_detail_type_cd)
       cur_source_meaning = suggested_by_dx_meaning, cur_source_name = n.source_string
      ELSEIF (cpacd.cp_action_detail_type_cd=suggested_by_ord_action_detail_type_cd
       AND cpacd.action_detail_entity_name="ORDER_CATALOG_SYNONYM")
       cur_source_meaning = suggested_by_ord_meaning, cur_source_name = ocs.mnemonic
      ELSEIF (cpacd.cp_action_detail_type_cd=suggested_by_ord_action_detail_type_cd
       AND cpacd.action_detail_entity_name="ORDER_SENTENCE")
       cur_source_meaning = suggested_by_ord_meaning, cur_source_name = concat(trim(os_ocs.mnemonic,3
         )," ",trim(os.order_sentence_display_line,3))
      ENDIF
     ELSEIF (cpac.pathway_instance_id > 0
      AND cpac.action_type_cd=system_suggested_pathway_action_type_cd
      AND cpacd.cp_action_detail_type_cd=suggested_by_rule_action_detail_type_cd)
      cur_source_meaning = suggested_by_rule_meaning, cur_source_name = cpacd.action_detail_text
     ELSE
      cur_source_name = pr.name_full_formatted, cur_source_meaning = suggested_by_prsnl_meaning
     ENDIF
    FOOT  cpa.pathway_instance_id
     reply->suggest_qual[pcnt].proposed_by_source_meaning = cur_source_meaning, reply->suggest_qual[
     pcnt].proposed_by_source_name = cur_source_name
    FOOT REPORT
     stat = alterlist(reply->suggest_qual,pcnt), reply->suggest_cnt = pcnt
    WITH nocounter
   ;end select
   IF ((reply->suggest_cnt > 0))
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = reply->suggest_cnt),
      cp_pathway c
     PLAN (d1)
      JOIN (c
      WHERE (c.cp_pathway_id=reply->suggest_qual[d1.seq].cp_pathway_id))
     ORDER BY d1.seq
     HEAD d1.seq
      reply->suggest_qual[d1.seq].pathway_diagram_url = c.pathway_diagram_url
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit getSuggestedPathways(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE PUBLIC::getutcdttm(dq8dttm)
   DECLARE utcdttm = dq8 WITH protect, noconstant(dq8dttm)
   IF (curutc)
    SET utcdttm = dq8dttm
   ELSE
    SET utcdttm = cnvtdatetimeutc(dq8dttm,3)
   ENDIF
   RETURN(utcdttm)
 END ;Subroutine
 SUBROUTINE getpathwaylist(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE pathway_status_active = f8 WITH protect, constant(uar_get_code_by("MEANING",4003198,
     "ACTIVE"))
   DECLARE pathway_type_oncology = f8 WITH protect, constant(uar_get_code_by("MEANING",4003197,
     "ONCOLOGY"))
   DECLARE pathway_type_legacydebug = f8 WITH protect, constant(uar_get_code_by("MEANING",4003197,
     "LEGACYDEBUG"))
   DECLARE pathway_type_cpm = f8 WITH protect, constant(uar_get_code_by("MEANING",4003197,"CPM"))
   DECLARE user_logical_domain_id = f8 WITH protect, constant(getuserlogicaldomain(reqinfo->updt_id))
   DECLARE cnt = i4 WITH noconstant(0), protect
   CALL log_message("Begin getPathwayList()",log_level_debug)
   SELECT INTO "nl:"
    pathway_name = cnvtupper(cp.pathway_name)
    FROM cp_pathway cp
    PLAN (cp
     WHERE cp.pathway_type_cd IN (pathway_type_oncology, pathway_type_cpm, pathway_type_legacydebug)
      AND cp.logical_domain_id=user_logical_domain_id)
    ORDER BY pathway_name DESC
    HEAD cp.cp_pathway_id
     cnt += 1
     IF (cnt > size(reply->pathway_list,5))
      stat = alterlist(reply->pathway_list,(cnt+ 10))
     ENDIF
     reply->pathway_list[cnt].cp_pathway_id = cp.cp_pathway_id, reply->pathway_list[cnt].pathway_name
      = cp.pathway_name, reply->pathway_list[cnt].pathway_diagram_url = cp.pathway_diagram_url,
     reply->pathway_list[cnt].pathway_status_cd = cp.pathway_status_cd
     IF ((reply->pathway_list[cnt].pathway_status_cd != pathway_status_active))
      reply->pathway_list[cnt].deleted_pathway_flag = 1
     ENDIF
    FOOT REPORT
     reply->pathway_list_cnt = cnt, stat = alterlist(reply->pathway_list,cnt)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getPathwayList(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getdefaultcategorymeans(null)
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE pos = i4 WITH noconstant(0), protect
   DECLARE default_category_mean = vc WITH noconstant(""), protect
   SELECT INTO "nl:"
    FROM cp_node cn
    PLAN (cn
     WHERE expand(idx,1,reply->pathway_list_cnt,cn.cp_pathway_id,reply->pathway_list[idx].
      cp_pathway_id)
      AND cn.active_ind=1)
    ORDER BY cn.cp_pathway_id, cn.collation_seq, cn.node_display,
     cn.cp_node_id
    HEAD cn.cp_pathway_id
     pos = locateval(idx,1,reply->pathway_list_cnt,cn.cp_pathway_id,reply->pathway_list[idx].
      cp_pathway_id), default_category_mean = ""
    HEAD cn.cp_node_id
     IF (default_category_mean="")
      default_category_mean = cn.category_mean
     ENDIF
    FOOT  cn.cp_pathway_id
     IF (pos > 0)
      reply->pathway_list[pos].default_category_mean = default_category_mean
     ENDIF
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE getpathwayactivitystatustypes(null)
   SET reply->pathway_activity_status_display.complete_display = uar_get_code_display(uar_get_code_by
    ("MEANING",4003352,"COMPLETE"))
   SET reply->pathway_activity_status_display.active_display = uar_get_code_display(uar_get_code_by(
     "MEANING",4003352,"ACTIVE"))
   SET reply->pathway_activity_status_display.void_display = uar_get_code_display(uar_get_code_by(
     "MEANING",4003352,"VOID"))
 END ;Subroutine
 SUBROUTINE removedeletedpathwaysfromavailable(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin removeDeletedPathwaysFromAvailable()",log_level_debug)
   DECLARE pathwaysize = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE inactpos = i4 WITH noconstant(0), protect
   SET pathwaysize = size(reply->pathway_list,5)
   SET idx = 1
   WHILE (idx <= pathwaysize)
     IF ((reply->pathway_list[idx].deleted_pathway_flag=1))
      SET stat = alterlist(reply->pathway_list,(pathwaysize - 1),(idx - 1))
      SET pathwaysize -= 1
     ELSE
      SET idx += 1
     ENDIF
   ENDWHILE
   FOR (x = 1 TO size(reply->activity_qual,5))
     SET inactivatedpathwayname = reply->activity_qual[x].pathway_name
     SET inactpos = findstring("INACTIVATED",cnvtupper(inactivatedpathwayname))
     IF (inactpos > 0)
      SET reply->activity_qual[x].pathway_name = substring(0,(inactpos - 2),inactivatedpathwayname)
     ENDIF
   ENDFOR
   CALL log_message(build("Exit removeDeletedPathwaysFromAvailable(), Elapsed time in seconds:",((
     curtime3 - begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 CALL log_message(build("Starting Script:",log_program_name),log_level_debug)
 SET reply->status_data.status = "F"
 CALL main(null)
 SET reply->status_data.status = "S"
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - script_start_curtime3)/ 100.0)),
  log_level_debug)
 IF (( $OUTDEV != "NOFORMS"))
  CALL putjsonrecordtofile(reply)
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echorecord(reply)
 ENDIF
END GO
