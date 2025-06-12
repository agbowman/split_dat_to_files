CREATE PROGRAM cp_import_sdoc_templates:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
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
 FREE RECORD audit_init_request
 RECORD audit_init_request(
   1 object_name = vc
   1 object_params = vc
   1 output_device = vc
   1 temp_file = vc
   1 report_type = c12
   1 person_id = f8
   1 omf_object_cd = f8
   1 long_text = vc
   1 crm_reqnum = i4
 ) WITH persistscript
 FREE RECORD audit_init_reply
 RECORD audit_init_reply(
   1 report_audit_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 SUBROUTINE (logblobindata(objectname=vc,longtext=vc,tempfile=vc) =null WITH protect)
   SET audit_init_request->object_name = objectname
   SET audit_init_request->object_params = "Blob In"
   SET audit_init_request->long_text = longtext
   SET audit_init_request->report_type = "REPORT"
   SET audit_init_request->output_device = "MINE"
   EXECUTE ccl_add_rpt_audit  WITH replace("REQUEST",audit_init_request), replace("REPLY",
    audit_init_reply)
 END ;Subroutine
 SUBROUTINE (updateauditinitreply(status=vc) =null WITH protect)
   IF ((audit_init_reply->report_audit_id > 0))
    UPDATE  FROM ccl_report_audit cra
     SET cra.status = status, cra.end_dt_tm = cnvtdatetime(sysdate), cra.updt_cnt = 1,
      cra.updt_id = reqinfo->updt_id, cra.updt_dt_tm = cnvtdatetime(sysdate)
     WHERE (cra.report_event_id=audit_init_reply->report_audit_id)
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE (setauditinitreplystatusbyprogramreplystatus(reply=vc(ref)) =null WITH protect)
  IF (validate(debug_ind,0)=1)
   CALL echorecord(audit_init_reply)
  ENDIF
  IF ((reply->status_data.status="S"))
   CALL updateauditinitreply("SUCCESS")
  ELSE
   CALL updateauditinitreply("FAILED")
  ENDIF
 END ;Subroutine
 DECLARE filterdoccomponentdetails(null) = null WITH protect
 SUBROUTINE (checkforexistingactivepathway(pathwayname=vc,pathwaytypecd=f8,logicaldomainid=f8) =f8
  WITH protect)
   CALL log_message("Begin CheckForExistingPathway()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE active_pathway_status = f8 WITH constant(uar_get_code_by("MEANING",4003198,"ACTIVE")),
   protect
   DECLARE existingpathwayid = f8 WITH noconstant(- (1)), protect
   SELECT INTO "NL:"
    FROM cp_pathway cp
    WHERE cp.logical_domain_id=logicaldomainid
     AND cnvtupper(cp.pathway_name)=cnvtupper(pathwayname)
     AND cp.pathway_status_cd=active_pathway_status
     AND cp.pathway_type_cd=pathwaytypecd
    DETAIL
     existingpathwayid = cp.cp_pathway_id
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echo(build("ExistingPathwayId: ",existingpathwayid))
   ENDIF
   CALL log_message(build("Exit CheckForExistingPathway(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(existingpathwayid)
 END ;Subroutine
 SUBROUTINE (decodexmlspecialcharacters(identifier=vc) =vc WITH protect)
   CALL log_message("In decodeXmlSpecialCharacters()",log_level_debug)
   SET identifier = replace(identifier,"&gt;",">",0)
   SET identifier = replace(identifier,"&lt;","<",0)
   SET identifier = replace(identifier,"&#34;",'"',0)
   SET identifier = replace(identifier,"&#39;","'",0)
   RETURN(identifier)
   CALL log_message("Exit decodeXmlSpecialCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (encodeinternationalcharacters(stringtoencode=vc) =vc WITH protect)
   CALL log_message("In encodeInternationalCharacters()",log_level_debug)
   DECLARE encodedstring = vc WITH protect, noconstant(stringtoencode)
   SET encodedstring = replace(encodedstring,"","~#192;",0)
   SET encodedstring = replace(encodedstring,"","~#193;",0)
   SET encodedstring = replace(encodedstring,"","~#194;",0)
   SET encodedstring = replace(encodedstring,"","~#195;",0)
   SET encodedstring = replace(encodedstring,"","~#196;",0)
   SET encodedstring = replace(encodedstring,"","~#197;",0)
   SET encodedstring = replace(encodedstring,"","~#198;",0)
   SET encodedstring = replace(encodedstring,"","~#199;",0)
   SET encodedstring = replace(encodedstring,"","~#200;",0)
   SET encodedstring = replace(encodedstring,"","~#201;",0)
   SET encodedstring = replace(encodedstring,"","~#202;",0)
   SET encodedstring = replace(encodedstring,"","~#203;",0)
   SET encodedstring = replace(encodedstring,"","~#204;",0)
   SET encodedstring = replace(encodedstring,"","~#205;",0)
   SET encodedstring = replace(encodedstring,"","~#206;",0)
   SET encodedstring = replace(encodedstring,"","~#207;",0)
   SET encodedstring = replace(encodedstring,"","~#208;",0)
   SET encodedstring = replace(encodedstring,"","~#209;",0)
   SET encodedstring = replace(encodedstring,"","~#210;",0)
   SET encodedstring = replace(encodedstring,"","~#211;",0)
   SET encodedstring = replace(encodedstring,"","~#212;",0)
   SET encodedstring = replace(encodedstring,"","~#213;",0)
   SET encodedstring = replace(encodedstring,"","~#214;",0)
   SET encodedstring = replace(encodedstring,"","~#216;",0)
   SET encodedstring = replace(encodedstring,"","~#217;",0)
   SET encodedstring = replace(encodedstring,"","~#218;",0)
   SET encodedstring = replace(encodedstring,"","~#219;",0)
   SET encodedstring = replace(encodedstring,"","~#220;",0)
   SET encodedstring = replace(encodedstring,"","~#221;",0)
   SET encodedstring = replace(encodedstring,"","~#222;",0)
   SET encodedstring = replace(encodedstring,"","~#223;",0)
   SET encodedstring = replace(encodedstring,"","~#224;",0)
   SET encodedstring = replace(encodedstring,"","~#225;",0)
   SET encodedstring = replace(encodedstring,"","~#226;",0)
   SET encodedstring = replace(encodedstring,"","~#227;",0)
   SET encodedstring = replace(encodedstring,"","~#228;",0)
   SET encodedstring = replace(encodedstring,"","~#229;",0)
   SET encodedstring = replace(encodedstring,"","~#230;",0)
   SET encodedstring = replace(encodedstring,"","~#231;",0)
   SET encodedstring = replace(encodedstring,"","~#232;",0)
   SET encodedstring = replace(encodedstring,"","~#233;",0)
   SET encodedstring = replace(encodedstring,"","~#234;",0)
   SET encodedstring = replace(encodedstring,"","~#235;",0)
   SET encodedstring = replace(encodedstring,"","~#236;",0)
   SET encodedstring = replace(encodedstring,"","~#237;",0)
   SET encodedstring = replace(encodedstring,"","~#238;",0)
   SET encodedstring = replace(encodedstring,"","~#239;",0)
   SET encodedstring = replace(encodedstring,"","~#240;",0)
   SET encodedstring = replace(encodedstring,"","~#241;",0)
   SET encodedstring = replace(encodedstring,"","~#242;",0)
   SET encodedstring = replace(encodedstring,"","~#243;",0)
   SET encodedstring = replace(encodedstring,"","~#244;",0)
   SET encodedstring = replace(encodedstring,"","~#245;",0)
   SET encodedstring = replace(encodedstring,"","~#246;",0)
   SET encodedstring = replace(encodedstring,"","~#248;",0)
   SET encodedstring = replace(encodedstring,"","~#249;",0)
   SET encodedstring = replace(encodedstring,"","~#250;",0)
   SET encodedstring = replace(encodedstring,"","~#251;",0)
   SET encodedstring = replace(encodedstring,"","~#252;",0)
   SET encodedstring = replace(encodedstring,"","~#253;",0)
   SET encodedstring = replace(encodedstring,"","~#254;",0)
   SET encodedstring = replace(encodedstring,"","~#255;",0)
   SET encodedstring = replace(encodedstring,"","~#338;",0)
   SET encodedstring = replace(encodedstring,"","~#339;",0)
   SET encodedstring = replace(encodedstring,"","~#352;",0)
   SET encodedstring = replace(encodedstring,"","~#353;",0)
   SET encodedstring = replace(encodedstring,"","~#376;",0)
   SET encodedstring = replace(encodedstring,"","~#402;",0)
   SET encodedstring = replace(encodedstring,"","~#142;",0)
   SET encodedstring = replace(encodedstring,"","~#158;",0)
   SET encodedstring = replace(encodedstring,"","~#161;",0)
   SET encodedstring = replace(encodedstring,"","~#162;",0)
   SET encodedstring = replace(encodedstring,"","~#164;",0)
   SET encodedstring = replace(encodedstring,"","~#165;",0)
   SET encodedstring = replace(encodedstring,"","~#166;",0)
   SET encodedstring = replace(encodedstring,"","~#167;",0)
   SET encodedstring = replace(encodedstring,"","~#168;",0)
   SET encodedstring = replace(encodedstring,"","~#169;",0)
   SET encodedstring = replace(encodedstring,"","~#170;",0)
   SET encodedstring = replace(encodedstring,"","~#171;",0)
   SET encodedstring = replace(encodedstring,"","~#172;",0)
   SET encodedstring = replace(encodedstring,"","~#174;",0)
   SET encodedstring = replace(encodedstring,"","~#175;",0)
   SET encodedstring = replace(encodedstring,"","~#176;",0)
   SET encodedstring = replace(encodedstring,"","~#177;",0)
   SET encodedstring = replace(encodedstring,"","~#179;",0)
   SET encodedstring = replace(encodedstring,"","~#178;",0)
   SET encodedstring = replace(encodedstring,"","~#180;",0)
   SET encodedstring = replace(encodedstring,"","~#181;",0)
   SET encodedstring = replace(encodedstring,"","~#182;",0)
   SET encodedstring = replace(encodedstring,"","~#183;",0)
   SET encodedstring = replace(encodedstring,"","~#184;",0)
   SET encodedstring = replace(encodedstring,"","~#185;",0)
   SET encodedstring = replace(encodedstring,"","~#186;",0)
   SET encodedstring = replace(encodedstring,"","~#187;",0)
   SET encodedstring = replace(encodedstring,"","~#188;",0)
   SET encodedstring = replace(encodedstring,"","~#189;",0)
   SET encodedstring = replace(encodedstring,"","~#190;",0)
   SET encodedstring = replace(encodedstring,"","~#191;",0)
   SET encodedstring = replace(encodedstring,"","~#247;",0)
   SET encodedstring = replace(encodedstring,"","~#215;",0)
   SET encodedstring = replace(encodedstring,"","~#136;",0)
   SET encodedstring = replace(encodedstring,"","~#152;",0)
   SET encodedstring = replace(encodedstring,"","~#150;",0)
   SET encodedstring = replace(encodedstring,"","~#151;",0)
   SET encodedstring = replace(encodedstring,"","~#145;",0)
   SET encodedstring = replace(encodedstring,"","~#146;",0)
   SET encodedstring = replace(encodedstring,"","~#130;",0)
   SET encodedstring = replace(encodedstring,"","~#147;",0)
   SET encodedstring = replace(encodedstring,"","~#148;",0)
   SET encodedstring = replace(encodedstring,"","~#132;",0)
   SET encodedstring = replace(encodedstring,"","~#134;",0)
   SET encodedstring = replace(encodedstring,"","~#135;",0)
   SET encodedstring = replace(encodedstring,"","~#149;",0)
   SET encodedstring = replace(encodedstring,"","~#133;",0)
   SET encodedstring = replace(encodedstring,"","~#137;",0)
   SET encodedstring = replace(encodedstring,"","~#139;",0)
   SET encodedstring = replace(encodedstring,"","~#155;",0)
   SET encodedstring = replace(encodedstring,"","~#128;",0)
   SET encodedstring = replace(encodedstring,"","~#153;",0)
   SET encodedstring = replace(encodedstring,"","~#163;",0)
   RETURN(encodedstring)
   CALL log_message("Exit encodeInternationalCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (decodeinternationalcharacters(stringtodecode=vc) =vc WITH protect)
   CALL log_message("In decodeInternationalCharacters()",log_level_debug)
   DECLARE decodedstring = vc WITH protect, noconstant(stringtodecode)
   SET decodedstring = replace(decodedstring,"~#192;","",0)
   SET decodedstring = replace(decodedstring,"~#193;","",0)
   SET decodedstring = replace(decodedstring,"~#194;","",0)
   SET decodedstring = replace(decodedstring,"~#195;","",0)
   SET decodedstring = replace(decodedstring,"~#196;","",0)
   SET decodedstring = replace(decodedstring,"~#197;","",0)
   SET decodedstring = replace(decodedstring,"~#198;","",0)
   SET decodedstring = replace(decodedstring,"~#199;","",0)
   SET decodedstring = replace(decodedstring,"~#200;","",0)
   SET decodedstring = replace(decodedstring,"~#201;","",0)
   SET decodedstring = replace(decodedstring,"~#202;","",0)
   SET decodedstring = replace(decodedstring,"~#203;","",0)
   SET decodedstring = replace(decodedstring,"~#204;","",0)
   SET decodedstring = replace(decodedstring,"~#205;","",0)
   SET decodedstring = replace(decodedstring,"~#206;","",0)
   SET decodedstring = replace(decodedstring,"~#207;","",0)
   SET decodedstring = replace(decodedstring,"~#208;","",0)
   SET decodedstring = replace(decodedstring,"~#209;","",0)
   SET decodedstring = replace(decodedstring,"~#210;","",0)
   SET decodedstring = replace(decodedstring,"~#211;","",0)
   SET decodedstring = replace(decodedstring,"~#212;","",0)
   SET decodedstring = replace(decodedstring,"~#213;","",0)
   SET decodedstring = replace(decodedstring,"~#214;","",0)
   SET decodedstring = replace(decodedstring,"~#216;","",0)
   SET decodedstring = replace(decodedstring,"~#217;","",0)
   SET decodedstring = replace(decodedstring,"~#218;","",0)
   SET decodedstring = replace(decodedstring,"~#219;","",0)
   SET decodedstring = replace(decodedstring,"~#220;","",0)
   SET decodedstring = replace(decodedstring,"~#221;","",0)
   SET decodedstring = replace(decodedstring,"~#222;","",0)
   SET decodedstring = replace(decodedstring,"~#223;","",0)
   SET decodedstring = replace(decodedstring,"~#224;","",0)
   SET decodedstring = replace(decodedstring,"~#225;","",0)
   SET decodedstring = replace(decodedstring,"~#226;","",0)
   SET decodedstring = replace(decodedstring,"~#227;","",0)
   SET decodedstring = replace(decodedstring,"~#228;","",0)
   SET decodedstring = replace(decodedstring,"~#229;","",0)
   SET decodedstring = replace(decodedstring,"~#230;","",0)
   SET decodedstring = replace(decodedstring,"~#231;","",0)
   SET decodedstring = replace(decodedstring,"~#232;","",0)
   SET decodedstring = replace(decodedstring,"~#233;","",0)
   SET decodedstring = replace(decodedstring,"~#234;","",0)
   SET decodedstring = replace(decodedstring,"~#235;","",0)
   SET decodedstring = replace(decodedstring,"~#236;","",0)
   SET decodedstring = replace(decodedstring,"~#237;","",0)
   SET decodedstring = replace(decodedstring,"~#238;","",0)
   SET decodedstring = replace(decodedstring,"~#239;","",0)
   SET decodedstring = replace(decodedstring,"~#240;","",0)
   SET decodedstring = replace(decodedstring,"~#241;","",0)
   SET decodedstring = replace(decodedstring,"~#242;","",0)
   SET decodedstring = replace(decodedstring,"~#243;","",0)
   SET decodedstring = replace(decodedstring,"~#244;","",0)
   SET decodedstring = replace(decodedstring,"~#245;","",0)
   SET decodedstring = replace(decodedstring,"~#246;","",0)
   SET decodedstring = replace(decodedstring,"~#248;","",0)
   SET decodedstring = replace(decodedstring,"~#249;","",0)
   SET decodedstring = replace(decodedstring,"~#250;","",0)
   SET decodedstring = replace(decodedstring,"~#251;","",0)
   SET decodedstring = replace(decodedstring,"~#252;","",0)
   SET decodedstring = replace(decodedstring,"~#253;","",0)
   SET decodedstring = replace(decodedstring,"~#254;","",0)
   SET decodedstring = replace(decodedstring,"~#255;","",0)
   SET decodedstring = replace(decodedstring,"~#338;","",0)
   SET decodedstring = replace(decodedstring,"~#339;","",0)
   SET decodedstring = replace(decodedstring,"~#352;","",0)
   SET decodedstring = replace(decodedstring,"~#353;","",0)
   SET decodedstring = replace(decodedstring,"~#376;","",0)
   SET decodedstring = replace(decodedstring,"~#402;","",0)
   SET decodedstring = replace(decodedstring,"~#142;","",0)
   SET decodedstring = replace(decodedstring,"~#158;","",0)
   SET decodedstring = replace(decodedstring,"~#161;","",0)
   SET decodedstring = replace(decodedstring,"~#162;","",0)
   SET decodedstring = replace(decodedstring,"~#164;","",0)
   SET decodedstring = replace(decodedstring,"~#165;","",0)
   SET decodedstring = replace(decodedstring,"~#166;","",0)
   SET decodedstring = replace(decodedstring,"~#167;","",0)
   SET decodedstring = replace(decodedstring,"~#168;","",0)
   SET decodedstring = replace(decodedstring,"~#169;","",0)
   SET decodedstring = replace(decodedstring,"~#170;","",0)
   SET decodedstring = replace(decodedstring,"~#171;","",0)
   SET decodedstring = replace(decodedstring,"~#172;","",0)
   SET decodedstring = replace(decodedstring,"~#174;","",0)
   SET decodedstring = replace(decodedstring,"~#175;","",0)
   SET decodedstring = replace(decodedstring,"~#176;","",0)
   SET decodedstring = replace(decodedstring,"~#177;","",0)
   SET decodedstring = replace(decodedstring,"~#178;","",0)
   SET decodedstring = replace(decodedstring,"~#179;","",0)
   SET decodedstring = replace(decodedstring,"~#180;","",0)
   SET decodedstring = replace(decodedstring,"~#181;","",0)
   SET decodedstring = replace(decodedstring,"~#182;","",0)
   SET decodedstring = replace(decodedstring,"~#183;","",0)
   SET decodedstring = replace(decodedstring,"~#184;","",0)
   SET decodedstring = replace(decodedstring,"~#185;","",0)
   SET decodedstring = replace(decodedstring,"~#186;","",0)
   SET decodedstring = replace(decodedstring,"~#187;","",0)
   SET decodedstring = replace(decodedstring,"~#188;","",0)
   SET decodedstring = replace(decodedstring,"~#189;","",0)
   SET decodedstring = replace(decodedstring,"~#190;","",0)
   SET decodedstring = replace(decodedstring,"~#191;","",0)
   SET decodedstring = replace(decodedstring,"~#247;","",0)
   SET decodedstring = replace(decodedstring,"~#215;","",0)
   SET decodedstring = replace(decodedstring,"~#136;","",0)
   SET decodedstring = replace(decodedstring,"~#152;","",0)
   SET decodedstring = replace(decodedstring,"~#150;","",0)
   SET decodedstring = replace(decodedstring,"~#151;","",0)
   SET decodedstring = replace(decodedstring,"~#145;","",0)
   SET decodedstring = replace(decodedstring,"~#146;","",0)
   SET decodedstring = replace(decodedstring,"~#130;","",0)
   SET decodedstring = replace(decodedstring,"~#147;","",0)
   SET decodedstring = replace(decodedstring,"~#148;","",0)
   SET decodedstring = replace(decodedstring,"~#132;","",0)
   SET decodedstring = replace(decodedstring,"~#134;","",0)
   SET decodedstring = replace(decodedstring,"~#135;","",0)
   SET decodedstring = replace(decodedstring,"~#149;","",0)
   SET decodedstring = replace(decodedstring,"~#133;","",0)
   SET decodedstring = replace(decodedstring,"~#137;","",0)
   SET decodedstring = replace(decodedstring,"~#139;","",0)
   SET decodedstring = replace(decodedstring,"~#155;","",0)
   SET decodedstring = replace(decodedstring,"~#128;","",0)
   SET decodedstring = replace(decodedstring,"~#153;","",0)
   SET decodedstring = replace(decodedstring,"~#163;","",0)
   RETURN(decodedstring)
   CALL log_message("Exit decodeInternationalCharacters()",log_level_debug)
 END ;Subroutine
 SUBROUTINE (checkforexistingconcept(conceptdisplay=vc) =f8 WITH protect)
   CALL log_message("Begin CheckForExistingConcept()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE conceptcodeset = i4 WITH constant(4003132), protect
   DECLARE conceptid = f8 WITH noconstant(- (1)), protect
   DECLARE displaykey = vc WITH noconstant(""), protect
   SET displaykey = trim(cnvtupper(cnvtalphanum(substring(1,40,conceptdisplay))))
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=conceptcodeset
     AND cv.display_key=displaykey
     AND cv.active_ind=1
    DETAIL
     conceptid = cv.code_value
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echo(build("ExistingConceptId: ",conceptid))
   ENDIF
   CALL log_message(build("Exit CheckForExistingConcept(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
   RETURN(conceptid)
 END ;Subroutine
 SUBROUTINE filterdoccomponentdetails(null)
   CALL log_message("In filterDocComponentDetails()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE node_cntr = i4 WITH noconstant(0), protect
   DECLARE node_size = i4 WITH noconstant(0), protect
   DECLARE act_node_size = i4 WITH noconstant(0), protect
   DECLARE act_node_indx = i4 WITH noconstant(0), protect
   DECLARE doc_comp_indx = i4 WITH noconstant(0), protect
   DECLARE doc_comp_det_indx = i4 WITH noconstant(0), protect
   DECLARE search_cntr = i4 WITH noconstant(0), protect
   DECLARE cur_comp_det_version_nbr = i4 WITH noconstant(0), protect
   DECLARE latest_doc_content_det_indx = i4 WITH noconstant(0), protect
   DECLARE latest_doc_events_det_indx = i4 WITH noconstant(0), protect
   DECLARE latest_doc_decor_det_indx = i4 WITH noconstant(0), protect
   DECLARE comp_det_doc_content_mean = vc WITH constant("DOCCONTENT"), protect
   DECLARE comp_det_doc_events_mean = vc WITH constant("DOCEVENTS"), protect
   DECLARE comp_det_term_dec_mean = vc WITH constant("DOCTERMDEC"), protect
   SET node_size = size(reply->node_list,5)
   SET act_node_size = size(reply->pathway_instance.pathway_actions.node_list,5)
   FOR (node_cntr = 1 TO node_size)
     SET doc_comp_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].component_list,5),
      "GUIDEDTRMNT",reply->node_list[node_cntr].component_list[search_cntr].comp_type_cd_meaning)
     IF (doc_comp_indx=0)
      SET doc_comp_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].component_list,5),
       "PATHWAY_DOC",reply->node_list[node_cntr].component_list[search_cntr].comp_type_cd_meaning)
     ENDIF
     IF (doc_comp_indx > 0)
      SET latest_doc_content_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
       comp_det_doc_content_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
       comp_detail_list[search_cntr].detail_reltn_cd_mean)
      IF (latest_doc_content_det_indx > 0)
       SET reply->node_list[node_cntr].current_assoc_doc_instance_ident = reply->node_list[node_cntr]
       .component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].entity_ident
       SET reply->node_list[node_cntr].current_assoc_doc_version_text = reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].version_text
       SET reply->node_list[node_cntr].current_assoc_doc_version_flag = reply->node_list[node_cntr].
       component_list[doc_comp_indx].comp_detail_list[latest_doc_content_det_indx].version_flag
       SET latest_doc_events_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
         component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
        comp_det_doc_events_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
        comp_detail_list[search_cntr].detail_reltn_cd_mean)
       IF (latest_doc_events_det_indx > 0)
        SET reply->node_list[node_cntr].current_assoc_doc_events_id = reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[latest_doc_events_det_indx].entity_id
       ENDIF
       SET latest_doc_decor_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
         component_list[doc_comp_indx].comp_detail_list,5),1,reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[search_cntr].default_ind,
        comp_det_term_dec_mean,reply->node_list[node_cntr].component_list[doc_comp_indx].
        comp_detail_list[search_cntr].detail_reltn_cd_mean)
       IF (latest_doc_decor_det_indx > 0)
        SET reply->node_list[node_cntr].current_assoc_doc_decor_id = reply->node_list[node_cntr].
        component_list[doc_comp_indx].comp_detail_list[latest_doc_decor_det_indx].entity_id
       ENDIF
       SET cur_comp_det_version_nbr = - (1)
       SET act_node_indx = locateval(search_cntr,1,act_node_size,reply->node_list[node_cntr].
        cp_node_id,reply->pathway_instance.pathway_actions.node_list[search_cntr].node_id)
       IF (act_node_indx > 0)
        IF (textlen(trim(reply->pathway_instance.pathway_actions.node_list[act_node_indx].
          last_saved_doc_instance_ident)) > 0)
         SET reply->node_list[node_cntr].last_saved_doc_instance_ident = reply->pathway_instance.
         pathway_actions.node_list[act_node_indx].last_saved_doc_instance_ident
         SET doc_comp_det_indx = locateval(search_cntr,1,size(reply->node_list[node_cntr].
           component_list[doc_comp_indx].comp_detail_list,5),reply->pathway_instance.pathway_actions.
          node_list[act_node_indx].last_saved_doc_instance_ident,reply->node_list[node_cntr].
          component_list[doc_comp_indx].comp_detail_list[search_cntr].entity_ident)
         IF (doc_comp_det_indx > 0)
          SET cur_comp_det_version_nbr = reply->node_list[node_cntr].component_list[doc_comp_indx].
          comp_detail_list[doc_comp_det_indx].version_nbr
         ENDIF
        ENDIF
       ENDIF
       IF ((cur_comp_det_version_nbr > - (1)))
        CALL filtercomponentdetails(node_cntr,doc_comp_indx,build2("version_nbr = ",
          cur_comp_det_version_nbr))
       ELSE
        CALL filtercomponentdetails(node_cntr,doc_comp_indx,"default_ind = 1")
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   CALL log_message(build("Exit filterDocComponentDetails(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (filtercomponentdetails(nodeindx=i4,compindx=i4,comparefield=vc) =null WITH protect)
   CALL log_message("In filterComponentDetails()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE det_cntr = i4 WITH noconstant(1), protect
   DECLARE det_size = i4 WITH noconstant(0), protect
   DECLARE to_keep = i4 WITH noconstant(0), protect
   DECLARE compare_eval = vc WITH noconstant(""), protect
   SET det_size = size(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,5)
   WHILE (det_cntr <= det_size)
     SET compare_eval = build("reply->node_list[",nodeindx,"]->component_list[",compindx,
      "]->comp_detail_list[",
      det_cntr,"].",comparefield)
     IF (validate(debug_ind,0)=1)
      CALL echo(build(" det_cntr -- > ",det_cntr))
      CALL echo(build(" det_size -- > ",det_size))
      CALL echo(build(" compare_eval -- > ",compare_eval))
      CALL echo(build(" parser(compare_eval) -- > ",parser(compare_eval)))
     ENDIF
     IF ((reply->node_list[nodeindx].component_list[compindx].comp_detail_list[det_cntr].
     detail_reltn_cd_mean="ORDEROPTS"))
      SET to_keep += 1
      SET det_cntr += 1
     ELSEIF ( NOT (parser(compare_eval)))
      SET stat = alterlist(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,(
       det_size - 1),to_keep)
      SET det_size = size(reply->node_list[nodeindx].component_list[compindx].comp_detail_list,5)
     ELSE
      SET to_keep += 1
      SET det_cntr += 1
     ENDIF
   ENDWHILE
   CALL log_message(build("Exit filterComponentDetails(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SET log_program_name = "cp_import_sdoc_template"
 DECLARE irequest_number = i4 WITH protect, constant(969524)
 DECLARE itask_number = i4 WITH protect, constant(3202004)
 DECLARE iapp_number = i4 WITH protect, constant(reqinfo->updt_app)
 DECLARE begin_prgcurtime3 = dq8 WITH constant(curtime3), protect
 DECLARE documentation_type_name = vc WITH protect, constant("Care Pathways Documentation")
 DECLARE documentation_type_code = vc WITH protect, constant(
  "CERNER!F666CDA7-3EAB-4664-AF4C-DC0CCEA39DE2")
 DECLARE documentation_concept_cki = vc WITH protect, constant(
  "CERNER!F666CDA7-3EAB-4664-AF4C-DC0CCEA39DE2")
 DECLARE documentation_merge_ind = i2 WITH protect, constant(1)
 DECLARE documentation_entry_mode = vc WITH protect, constant("WKFDOCCOMP")
 DECLARE clnid_tag = vc WITH protect, constant("CLNID")
 DECLARE version_tag = vc WITH protect, constant("VERSION")
 DECLARE section_tag = vc WITH protect, constant("SECTION")
 DECLARE name_tag = vc WITH protect, constant("NAME")
 DECLARE main(null) = null
 DECLARE processrequestrecord(null) = null
 DECLARE fillinreqcallservice(null) = null
 FREE RECORD xmltemplatesimportreq
 RECORD xmltemplatesimportreq(
   1 template_cnt = i4
   1 qual[*]
     2 xml_blob = vc
 )
 FREE RECORD xml_template_details
 RECORD xml_template_details(
   1 template_cnt = i4
   1 templates[*]
     2 clin_doc_id = vc
     2 clin_doc_version = vc
     2 clin_doc_sec_name = vc
     2 clin_doc_sec_code = vc
     2 clin_doc_name = vc
     2 xml_content = vc
 )
 FREE RECORD xml_templates_import_rep
 RECORD xml_templates_import_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE main(null)
   CALL log_message("Begin main()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   SET xml_templates_import_rep->status_data.status = "S"
   IF (validate(request->blob_in))
    IF ((request->blob_in > " "))
     CALL logblobindata("CP_IMPORT_SDOC_TEMPLATES",request->blob_in, $OUTDEV)
     IF (validate(debug_ind,0)=1)
      CALL echo("XML Import Template Request : xmlTemplatesImportReq")
      CALL echorecord(xmltemplatesimportreq)
     ENDIF
     SET jrec = cnvtjsontorec(request->blob_in)
     IF (jrec != 1)
      CALL reporterrorandexit("Invalid blob in data","main","F")
     ELSE
      IF (validate(debug_ind,0)=1)
       CALL echorecord(xmltemplatesimportreq)
      ENDIF
      CALL processrequestrecord(null)
     ENDIF
    ELSE
     CALL reporterrorandexit("Empty blob content","main","F")
    ENDIF
   ENDIF
   CALL log_message(build("Exit main(), Elapsed time in seconds:",((curtime3 - begin_curtime3)/ 100.0
     )),log_level_debug)
 END ;Subroutine
 SUBROUTINE processrequestrecord(null)
   CALL log_message("Begin processRequestRecord()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE template_length = i4 WITH protect, noconstant(size(xmltemplatesimportreq->qual,5))
   DECLARE t_cnt = i2 WITH protect, noconstant(1)
   DECLARE currclindocval = vc WITH protect, noconstant("")
   DECLARE currclindocverval = vc WITH protect, noconstant("")
   DECLARE currclindocsecval = vc WITH protect, noconstant("")
   DECLARE currclindocnmval = vc WITH protect, noconstant("")
   DECLARE currsectioncode = vc WITH protect, noconstant("")
   DECLARE currxmlcontent = vc WITH protect, noconstant("")
   DECLARE et_cnt = i2 WITH protect, noconstant(0)
   IF (template_length=0)
    CALL reporterrorandexit("No Templates found","processRequestRecord","Z")
   ELSE
    FOR (t_cnt = 1 TO template_length)
      SET currxmlcontent = xmltemplatesimportreq->qual[t_cnt].xml_blob
      SET currclindocval = getvalueintags(clnid_tag,currxmlcontent)
      SET currclindocverval = getvalueintags(version_tag,currxmlcontent)
      SET currclindocsecval = getvalueintags(section_tag,currxmlcontent)
      SET currclindocnmval = getvalueintags(name_tag,currxmlcontent)
      IF (textlen(currclindocval) > 0
       AND textlen(currclindocverval) > 0
       AND textlen(currclindocsecval) > 0
       AND textlen(currclindocnmval) > 0)
       SET et_cnt += 1
       SET xml_template_details->template_cnt = et_cnt
       SET stat = alterlist(xml_template_details->templates,et_cnt)
       SET xml_template_details->templates[et_cnt].clin_doc_id = currclindocval
       SET xml_template_details->templates[et_cnt].clin_doc_name = currclindocnmval
       SET xml_template_details->templates[et_cnt].clin_doc_sec_code = currclindocsecval
       SET xml_template_details->templates[et_cnt].clin_doc_version = currclindocverval
       SET xml_template_details->templates[et_cnt].xml_content = currxmlcontent
      ELSE
       IF (validate(debug_ind,0)=1)
        CALL echo(build("currClinDocVal --> ",currclindocval))
        CALL echo(build("currClinDocVerVal --> ",currclindocverval))
        CALL echo(build("currClinDocSecVal --> ",currclindocsecval))
        CALL echo(build("currClinDocNmVal --> ",currclindocnmval))
       ENDIF
       CALL reporterrorandexit(build("extract: ",t_cnt),"processRequestRecord","F")
      ENDIF
    ENDFOR
   ENDIF
   IF ((xml_template_details->template_cnt > 0))
    CALL fillinreqcallservice(null)
   ENDIF
   CALL log_message(build("Exit processRequestRecord(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getvalueintags(tagname=vc,xmltext=vc) =vc)
   DECLARE begintag = vc WITH protect, constant(concat("<",tagname,">"))
   DECLARE endtag = vc WITH protect, constant(concat("</",tagname,">"))
   DECLARE begidx = i4 WITH protect, noconstant(0)
   DECLARE endidx = i4 WITH protect, noconstant(0)
   DECLARE valueintag = vc WITH protect, noconstant("")
   SET begidx = (findstring(begintag,xmltext)+ size(begintag))
   IF (begidx > 0)
    SET endidx = findstring(endtag,xmltext,begidx)
    SET valueintag = substring(begidx,(endidx - begidx),xmltext)
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echo(build("getValueInTags : tagName --> ",begintag))
    CALL echo(build("getValueInTags : value --> ",trim(valueintag,3)))
   ENDIF
   RETURN(trim(valueintag,3))
 END ;Subroutine
 SUBROUTINE (getattributevalue(attributename=vc,xmltext=vc) =vc)
   DECLARE begidx = i4 WITH protect, noconstant(0)
   DECLARE endidx = i4 WITH protect, noconstant(0)
   DECLARE begintext = vc WITH protect, noconstant(concat(attributename,'="'))
   DECLARE valueinattr = vc WITH protect, noconstant("")
   SET begidx = (findstring(begintext,xmltext)+ size(begintext))
   IF (begidx > 0)
    SET endidx = findstring('"',xmltext,begidx)
    SET valueinattr = substring(begidx,(endidx - begidx),xmltext)
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echo(build("getAttributeValue: attributeName --> ",begintext))
    CALL echo(build("getAttributeValue: valueInAttr --> ",valueinattr))
   ENDIF
   RETURN(valueinattr)
 END ;Subroutine
 SUBROUTINE fillinreqcallservice(null)
   CALL log_message("Begin fillInReqCallService()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE template_cnt = i4 WITH protect, constant(xml_template_details->template_cnt)
   DECLARE cntr = i4 WITH protect, noconstant(0)
   FREE RECORD request
   RECORD request(
     1 sections[*]
       2 name = vc
       2 concept_cki = vc
       2 code = vc
       2 merge_template_ind = i2
     1 chf_cmplnt[*]
       2 ocid = vc
       2 concept[*]
         3 concept_cki = vc
     1 entry_mode_mean = vc
     1 templates[*]
       2 xml_text = vc
     1 criteria[*]
       2 chf_cmplnt_ident = vc
       2 chf_cmplnt_name = vc
       2 minage_months = i4
       2 maxage_months = i4
       2 sex_mean = vc
       2 positions[*]
         3 position_cd = f8
       2 encntr_types[*]
         3 encntr_type_cd = f8
       2 ocid = vc
       2 template_clinids[*]
         3 cln_ident = vc
     1 delete
       2 sections[*]
         3 concept_cki = vc
       2 chf_cmplnt[*]
         3 ocid = vc
       2 template_idents[*]
         3 cln_ident = vc
       2 criteria[*]
         3 chf_cmplnt_ident = vc
   )
   FREE RECORD reply
   RECORD reply(
     1 status_data
       2 status = c1
       2 subeventstatus[*]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET stat = alterlist(request->sections,1)
   SET request->sections[1].code = documentation_type_code
   SET request->sections[1].concept_cki = documentation_concept_cki
   SET request->sections[1].merge_template_ind = documentation_merge_ind
   SET request->sections[1].name = documentation_type_name
   SET request->entry_mode_mean = documentation_entry_mode
   SET stat = alterlist(request->templates,template_cnt)
   SELECT
    clin_doc_ident = trim(substring(1,1000,xml_template_details->templates[d1.seq].clin_doc_id),3),
    version = cnvtint(xml_template_details->templates[d1.seq].clin_doc_version)
    FROM (dummyt d1  WITH seq = template_cnt)
    ORDER BY clin_doc_ident, version
    DETAIL
     cntr += 1, request->templates[cntr].xml_text = encodeinternationalcharacters(
      xml_template_details->templates[d1.seq].xml_content)
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echo(" TDBEXECUTE request ")
    CALL echorecord(request)
   ENDIF
   SET stat = tdbexecute(iapp_number,itask_number,irequest_number,"REC",request,
    "REC",reply)
   IF (validate(debug_ind,0)=1)
    CALL echo(build(" TDBEXECUTE Status -- > ",stat))
    CALL echorecord(reply)
   ENDIF
   IF ((reply->status_data.status="F"))
    CALL reporterrorandexit("Failed to insert templates","fillInReqCallService","F")
   ENDIF
   CALL log_message(build("Exit fillInReqCallService(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (reporterrorandexit(errortext=vc,subroutinename=vc,status=vc) =null)
   IF (validate(debug_ind,0)=1)
    CALL echo(build("Error Occured in --> ",subroutinename," -->",errortext))
   ENDIF
   SET xml_templates_import_rep->status_data.status = status
   SET xml_templates_import_rep->status_data.subeventstatus.operationname = build(subroutinename,":",
    errortext)
   SET xml_templates_import_rep->status_data.subeventstatus.operationstatus = status
   GO TO exit_script
 END ;Subroutine
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 CALL main(null)
#exit_script
 CALL setauditinitreplystatusbyprogramreplystatus(xml_templates_import_rep)
 IF (validate(debug_ind,0)=1)
  CALL echorecord(xml_templates_import_rep)
 ENDIF
 CALL putjsonrecordtofile(xml_templates_import_rep)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - begin_prgcurtime3)/ 100.0)),
  log_level_debug)
END GO
