CREATE PROGRAM cp_open_exist_struct_doc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Parent Entity Name" = "",
  "Parent Entity Id" = 0,
  "Document Event Id" = 0.0,
  "Term Decoration Id" = 0.0
  WITH outdev, parent_ent_name, parent_ent_id,
  event_id, decor_id
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
 DECLARE lapp_num = i4 WITH protect, constant(3202004)
 DECLARE ltask_num = i4 WITH protect, constant(3202004)
 DECLARE ecrmok = i2 WITH protect, constant(0)
 DECLARE esrvok = i2 WITH protect, constant(0)
 DECLARE hfailind = i2 WITH protect, constant(0)
 DECLARE string40 = i4 WITH protect, constant(40)
 DECLARE hmsg = i4 WITH protect, noconstant(0)
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hrep = i4 WITH protect, noconstant(0)
 DECLARE hstatusdata = i4 WITH protect, noconstant(0)
 DECLARE ncrmstat = i2 WITH protect, noconstant(0)
 DECLARE nsrvstat = i2 WITH protect, noconstant(0)
 DECLARE g_perform_failed = i2 WITH protect, noconstant(0)
 SUBROUTINE (initializeapptaskrequest(recorddata=vc(ref),appnumber=i4(val),tasknumber=i4(val),
  requestnumber=i4(val),donotexitonfail=i2(val,0)) =null WITH protect)
   SET ncrmstat = uar_crmbeginapp(appnumber,happ)
   IF (((ncrmstat != ecrmok) OR (happ=0)) )
    IF (donotexitonfail)
     CALL echo("InitializeAppTaskRequest: BEGIN Application Handle failed")
     CALL exit_servicerequest(happ,htask,hstep)
     RETURN
    ELSE
     CALL handleerror("BEGIN","F","Application Handle",cnvtstring(ncrmstat),recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
   ENDIF
   SET ncrmstat = uar_crmbegintask(happ,tasknumber,htask)
   IF (((ncrmstat != ecrmok) OR (htask=0)) )
    IF (donotexitonfail)
     CALL echo("InitializeAppTaskRequest: BEGIN Task Handle failed")
     CALL exit_servicerequest(happ,htask,hstep)
     RETURN
    ELSE
     CALL handleerror("BEGIN","F","Task Handle",cnvtstring(ncrmstat),recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
   ENDIF
   SET ncrmstat = uar_crmbeginreq(htask,0,requestnumber,hstep)
   IF (((ncrmstat != ecrmok) OR (hstep=0)) )
    IF (donotexitonfail)
     CALL echo("InitializeAppTaskRequest: BEGIN Request Handle failed")
     CALL exit_servicerequest(happ,htask,hstep)
     RETURN
    ELSE
     CALL handleerror("BEGIN","F","Req Handle",cnvtstring(ncrmstat),recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq=0)
    IF (donotexitonfail)
     CALL echo("InitializeAppTaskRequest: GET Request Handle failed")
     CALL exit_servicerequest(happ,htask,hstep)
     RETURN
    ELSE
     CALL handleerror("GET","F","Req Handle",cnvtstring(ncrmstat),recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (initializerequest(recorddata=vc(ref),requestnumber=i4(val)) =null WITH protect)
   CALL initializeapptaskrequest(recorddata,lapp_num,ltask_num,requestnumber)
 END ;Subroutine
 SUBROUTINE (initializesrvrequest(recorddata=vc(ref),requestnumber=i4(val),donotexitonfail=i2(val,0)
  ) =null WITH protect)
   SET hmsg = uar_srvselectmessage(requestnumber)
   IF (hmsg=hfailind)
    IF (donotexitonfail)
     CALL echo("InitializeSRVRequest: Create Message handle failed")
     CALL exit_srvrequest(hmsg,hreq,hrep)
     RETURN
    ELSE
     CALL handleerror("CREATE","F","Message Handle",cnvtstring(hmsg),recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ENDIF
   ENDIF
   SET hreq = uar_srvcreaterequest(hmsg)
   IF (hreq=hfailind)
    IF (donotexitonfail)
     CALL echo("InitializeSRVRequest: Create Request Handle failed")
     CALL exit_srvrequest(hmsg,hreq,hrep)
     RETURN
    ELSE
     CALL handleerror("CREATE","F","Req Handle",cnvtstring(hreq),recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ENDIF
   ENDIF
   SET hrep = uar_srvcreatereply(hmsg)
   IF (hrep=hfailind)
    IF (donotexitonfail)
     CALL echo("InitializeSRVRequest: Create Reply Handle failed")
     CALL exit_srvrequest(hmsg,hreq,hrep)
     RETURN
    ELSE
     CALL handleerror("CREATE","F","Rep Handle",cnvtstring(hrep),recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (getproviderposition(prsnl_id=f8) =f8 WITH protect)
   DECLARE prsnl_position_cd = f8 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl p
    PLAN (p
     WHERE p.person_id=prsnl_id
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     prsnl_position_cd = p.position_cd
    WITH nocounter
   ;end select
   RETURN(prsnl_position_cd)
 END ;Subroutine
 SUBROUTINE (createdatetimefromhandle(hhandle=i4(ref),sdatedataelement=vc(val),stimezonedataelement=
  vc(val)) =vc WITH protect)
   DECLARE time_zone = i4 WITH noconstant(0), protect
   DECLARE return_val = vc WITH noconstant(""), protect
   SET stat = uar_srvgetdate(hhandle,nullterm(sdatedataelement),recdate->datetime)
   IF (stimezonedataelement != "")
    SET time_zone = uar_srvgetlong(hhandle,nullterm(stimezonedataelement))
   ENDIF
   IF (validate(recdate->datetime,0))
    SET return_val = build(replace(datetimezoneformat(cnvtdatetime(recdate->datetime),
       datetimezonebyname("UTC"),"yyyy-MM-dd HH:mm:ss",curtimezonedef)," ","T",1),"Z")
   ELSE
    SET return_val = ""
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE (handleerror(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc,
  recorddata=vc(ref)) =null WITH protect)
   SET recorddata->status_data.status = "F"
   IF (size(recorddata->status_data.subeventstatus,5)=0)
    SET stat = alterlist(recorddata->status_data.subeventstatus,1)
   ENDIF
   SET recorddata->status_data.subeventstatus[1].operationname = operationname
   SET recorddata->status_data.subeventstatus[1].operationstatus = operationstatus
   SET recorddata->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET recorddata->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   SET g_perform_failed = 1
 END ;Subroutine
 SUBROUTINE (handlenodata(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc,recorddata=vc(ref)) =null WITH protect)
   SET recorddata->status_data.status = "Z"
   IF (size(recorddata->status_data.subeventstatus,5)=0)
    SET stat = alterlist(recorddata->status_data.subeventstatus,1)
   ENDIF
   SET recorddata->status_data.subeventstatus[1].operationname = operationname
   SET recorddata->status_data.subeventstatus[1].operationstatus = operationstatus
   SET recorddata->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET recorddata->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 SUBROUTINE (exit_servicerequest(happ=i4,htask=i4,hstep=i4) =null WITH protect)
   IF (hstep != 0)
    SET ncrmstat = uar_crmendreq(hstep)
   ENDIF
   IF (htask != 0)
    SET ncrmstat = uar_crmendtask(htask)
   ENDIF
   IF (happ != 0)
    SET ncrmstat = uar_crmendapp(happ)
   ENDIF
   IF (g_perform_failed=1)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE exit_srvrequest(hmsg,hreq,hrep)
   IF (hmsg != 0)
    SET nsrvstat = uar_srvdestroyinstance(hmsg)
   ENDIF
   IF (hreq != 0)
    SET nsrvstat = uar_srvdestroyinstance(hreq)
   ENDIF
   IF (hrep != 0)
    SET nsrvstat = uar_srvdestroyinstance(hrep)
   ENDIF
   IF (g_perform_failed=1)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereply(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2) =i4 WITH protect
  )
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE sstatus = c1 WITH noconstant(" "), protect
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status: ",sstatus))
    ENDIF
    IF (sstatus="Z")
     CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(ncrmstat),recorddata)
     IF (zeroforceexit=1)
      CALL exit_servicerequest(happ,htask,hstep)
      GO TO exit_script
     ENDIF
    ELSEIF (sstatus != "S")
     IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
      SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
      SET soperationname = uar_srvgetstringptr(hitem,"OperationName")
      SET soperationstatus = uar_srvgetstringptr(hitem,"OperationStatus")
      SET stargetobjectname = uar_srvgetstringptr(hitem,"TargetObjectName")
      SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
     ENDIF
     CALL handleerror(soperationname,sstatus,stargetobjectname,stargetobjectvalue,recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatesubreply(ncrmstat=i4,hstep=i4,recorddata=vc(ref)) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE sstatus = c1 WITH noconstant(" "), protect
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status: ",sstatus))
    ENDIF
    IF (sstatus != "S"
     AND sstatus != "Z")
     IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
      SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
      SET soperationname = uar_srvgetstringptr(hitem,"OperationName")
      SET soperationstatus = uar_srvgetstringptr(hitem,"OperationStatus")
      SET stargetobjectname = uar_srvgetstringptr(hitem,"TargetObjectName")
      SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
     ENDIF
     CALL handleerror(soperationname,sstatus,stargetobjectname,stargetobjectvalue,recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereplyindicatordynamic(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2,
  recordname=vc,statusblock=vc) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE successind = i2 WITH noconstant(0), protect
   DECLARE errormessage = vc WITH noconstant(""), protect
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,nullterm(statusblock))
    SET successind = uar_srvgetshort(hstatusdata,"success_ind")
    SET errormessage = uar_srvgetstringptr(hstatusdata,"debug_error_message")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status Indicator: ",successind))
     CALL echo(build("Error Message: ",errormessage))
    ENDIF
    IF (successind != 1)
     CALL handleerror("ValidateReplyIndicator","F",srv_request,errormessage,recorddata)
     CALL exit_servicerequest(happ,htask,hstep)
    ELSEIF (trim(recordname) != "")
     SET resultlistcnt = uar_srvgetitemcount(hrep,nullterm(recordname))
     IF (resultlistcnt=0)
      IF (validate(debug_ind,0)=1)
       CALL echo(build("ZERO RESULTS found in [",trim(recordname,3),"]"))
      ENDIF
      CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(ncrmstat),recorddata)
      IF (zeroforceexit=1)
       CALL exit_servicerequest(happ,htask,hstep)
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(ncrmstat),recorddata)
    CALL exit_servicerequest(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatereplyindicator(ncrmstat=i4,hstep=i4,recorddata=vc(ref),zeroforceexit=i2,
  recordname=vc) =i4 WITH protect)
   CALL validatereplyindicatordynamic(ncrmstat,hstep,recorddata,zeroforceexit,recordname,
    "status_data")
 END ;Subroutine
 SUBROUTINE (validatesrvreplyind(nsrvstat=i4,recorddata=vc(ref),zeroforceexit=i2,recordname=vc,
  statusblock=vc) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE successind = i2 WITH noconstant(0), protect
   DECLARE errormessage = vc WITH noconstant(""), protect
   IF (nsrvstat=esrvok)
    SET hstatusdata = uar_srvgetstruct(hrep,nullterm(statusblock))
    SET successind = uar_srvgetshort(hstatusdata,"success_ind")
    SET errormessage = uar_srvgetstringptr(hstatusdata,"debug_error_message")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status Indicator: ",successind))
     CALL echo(build("Error Message: ",errormessage))
    ENDIF
    IF (successind != 1)
     CALL handleerror("ValidateReply","F",srv_request,errormessage,recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ELSEIF (trim(recordname) != "")
     SET resultlistcnt = uar_srvgetitemcount(hrep,nullterm(recordname))
     IF (resultlistcnt=0)
      IF (validate(debug_ind,0)=1)
       CALL echo(build("ZERO RESULTS found in [",trim(recordname,3),"]"))
      ENDIF
      CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(nsrvstat),recorddata)
      IF (zeroforceexit=1)
       CALL exit_srvrequest(hmsg,hreq,hrep)
       GO TO exit_script
      ENDIF
     ENDIF
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(nsrvstat),recorddata)
    CALL exit_srvrequest(hmsg,hreq,hrep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (validatesrvreply(nsrvstat=i4,recorddata=vc(ref),zeroforceexit=i2) =i4 WITH protect)
   DECLARE soperationname = vc WITH noconstant(""), protect
   DECLARE soperationstatus = vc WITH noconstant(""), protect
   DECLARE stargetobjectname = vc WITH noconstant(""), protect
   DECLARE stargetobjectvalue = vc WITH noconstant(""), protect
   DECLARE sstatus = c1 WITH noconstant(" "), protect
   IF (nsrvstat=esrvok)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (validate(debug_ind,0)=1)
     CALL echo(build("Status: ",sstatus))
    ENDIF
    IF (sstatus="Z")
     CALL handlenodata("PERFORM","Z",srv_request,cnvtstring(nsrvstat),recorddata)
     IF (zeroforceexit=1)
      CALL exit_srvrequest(hmsg,hreq,hrep)
      GO TO exit_script
     ENDIF
    ELSEIF (sstatus != "S")
     IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
      SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
      SET soperationname = uar_srvgetstringptr(hitem,"OperationName")
      SET soperationstatus = uar_srvgetstringptr(hitem,"OperationStatus")
      SET stargetobjectname = uar_srvgetstringptr(hitem,"TargetObjectName")
      SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
     ENDIF
     CALL handleerror(soperationname,sstatus,stargetobjectname,stargetobjectvalue,recorddata)
     CALL exit_srvrequest(hmsg,hreq,hrep)
    ENDIF
    RETURN(hrep)
   ELSE
    CALL handleerror("PERFORM","F",srv_request,cnvtstring(nsrvstat),recorddata)
    CALL exit_srvrequest(hmsg,hreq,hrep)
   ENDIF
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
 FREE RECORD activity
 RECORD activity(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
   1 parent_entity_version = i4
   1 top_freetext = gvc
   1 section_act
     2 dd_section_id = f8
     2 dd_sref_section_id = f8
     2 template_rltns[*]
       3 dd_sref_templ_instance_ident = vc
       3 dd_sref_chf_cmplnt_crit_id = f8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
     2 groupbys[*]
       3 dd_groupby_id = f8
       3 label = vc
       3 truth_state_mean = vc
       3 subgroupbys[*]
         4 dd_sgroupby_id = f8
         4 label = vc
         4 truth_state_mean = vc
         4 items[*]
           5 dd_item_id = f8
           5 ocid = vc
           5 truth_state_mean = vc
           5 attributes[*]
             6 dd_attribute_id = f8
             6 ocid = vc
             6 truth_state_mean = vc
             6 attribute_menu_items[*]
               7 dd_attr_menu_item_id = f8
               7 ocid = vc
               7 display_seq = i4
               7 truth_state_mean = vc
               7 comment = vc
               7 comment_format_mean = vc
               7 value_text = vc
               7 value_text_format_mean = vc
               7 value_number = f8
       3 items[*]
         4 dd_item_id = f8
         4 ocid = vc
         4 truth_state_mean = vc
         4 attributes[*]
           5 dd_attribute_id = f8
           5 ocid = vc
           5 truth_state_mean = vc
           5 attribute_menu_items[*]
             6 dd_attr_menu_item_id = f8
             6 ocid = vc
             6 display_seq = i4
             6 truth_state_mean = vc
             6 comment = vc
             6 comment_format_mean = vc
             6 value_text = vc
             6 value_text_format_mean = vc
             6 value_number = f8
     2 subsections[*]
       3 dd_section_id = f8
       3 dd_sref_section_id = f8
       3 parent_section_id = f8
       3 template_rltns[*]
         4 dd_sref_templ_instance_ident = vc
         4 dd_sref_chf_cmplnt_crit_id = f8
         4 parent_entity_id = f8
         4 parent_entity_name = vc
       3 groupbys[*]
         4 dd_groupby_id = f8
         4 label = vc
         4 truth_state_mean = vc
         4 subgroupbys[*]
           5 dd_sgroupby_id = f8
           5 label = vc
           5 truth_state_mean = vc
           5 items[*]
             6 dd_item_id = f8
             6 ocid = vc
             6 truth_state_mean = vc
             6 attributes[*]
               7 dd_attribute_id = f8
               7 ocid = vc
               7 truth_state_mean = vc
               7 attribute_menu_items[*]
                 8 dd_attr_menu_item_id = f8
                 8 ocid = vc
                 8 display_seq = i4
                 8 truth_state_mean = vc
                 8 comment = vc
                 8 comment_format_mean = vc
                 8 value_text = vc
                 8 value_text_format_mean = vc
                 8 value_number = f8
         4 items[*]
           5 dd_item_id = f8
           5 ocid = vc
           5 truth_state_mean = vc
           5 attributes[*]
             6 dd_attribute_id = f8
             6 ocid = vc
             6 truth_state_mean = vc
             6 attribute_menu_items[*]
               7 dd_attr_menu_item_id = f8
               7 ocid = vc
               7 display_seq = i4
               7 truth_state_mean = vc
               7 comment = vc
               7 comment_format_mean = vc
               7 value_text = vc
               7 value_text_format_mean = vc
               7 value_number = f8
   1 bottom_freetext = gvc
 )
 IF (validate(uar_srvgetasis)=0)
  DECLARE uar_srvgetasis(p1=i4(value),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_axp =
  "srvrtl", image_aix = "libsrv.a(libsrv.o)", uar = "SrvGetAsIs",
  persist
 ENDIF
 DECLARE addsectionactivity(subsectionindex,dest) = null WITH protect
 DECLARE addgroupbyactivity(subsectionindex,groupbyindex,dest) = null WITH protect
 DECLARE addgroupbyitemactivity(subsectionindex,groupbyindex,itemindex,dest) = null WITH protect
 DECLARE addgroupbyattributeactivity(subsectionindex,groupbyindex,itemindex,attribindex,dest) = null
 WITH protect
 DECLARE addgroupbyattributemenuitemactivity(subsectionindex,groupbyindex,itemindex,attribindex,
  menuindex,
  dest) = null WITH protect
 DECLARE addsubgroupbyactivity(subsectionindex,groupbyindex,subgroupindex,dest) = null WITH protect
 DECLARE addsubgroupbyitemactivity(subsectionindex,groupbyindex,subgroupindex,itemindex,dest) = null
 WITH protect
 DECLARE addsubgroupbyattributeactivity(subsectionindex,groupbyindex,subgroupindex,itemindex,
  attribindex,
  dest) = null WITH protect
 DECLARE addsubgroupbyattributemenuitemactivity(subsectionindex,groupbyindex,subgroupindex,itemindex,
  attribindex,
  menuindex,dest) = null WITH protect
 DECLARE copysectionstruct(src,subsectionindex) = null WITH protect
 DECLARE copygroupbystruct(src,subsectionindex,groupbyindex) = null WITH protect
 DECLARE copygroupbyitem(src,subsectionindex,groupbyindex,itemindex) = null WITH protect
 DECLARE copygroupbyattribute(src,subsectionindex,groupbyindex,itemindex,attribindex) = null WITH
 protect
 DECLARE copygroupbyattributemenuitem(src,subsectionindex,groupbyindex,itemindex,attribindex,
  menuindex) = null WITH protect
 DECLARE copysubgroupbystruct(src,subsectionindex,groupbyindex,subgroupindex) = null WITH protect
 DECLARE copysubgroupbyitem(src,subsectionindex,groupbyindex,subgroupindex,itemindex) = null WITH
 protect
 DECLARE copysubgroupbyattribute(src,subsectionindex,groupbyindex,subgroupindex,itemindex,
  attribindex) = null WITH protect
 DECLARE copysubgroupbyattributemenuitem(src,subsectionindex,groupbyindex,subgroupindex,itemindex,
  attribindex,menuindex) = null WITH protect
 DECLARE getasisstring(hsrvstruct,fieldname) = vc WITH protect
 SUBROUTINE addsectionactivity(subsectionindex,dest)
   CALL log_message("In AddSectionActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE hsectionactivity = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asection activity->section_act.subsections[subsectionindex]
    SET hsectionactivity = uar_srvadditem(dest,"subsections")
   ELSE
    SET curalias asection activity->section_act
    SET hsectionactivity = uar_srvgetstruct(dest,"section_act")
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echorecord(activity)
   ENDIF
   SET nsrvstat = uar_srvsetdouble(hsectionactivity,"dd_section_id",cnvtreal(asection->dd_section_id)
    )
   SET nsrvstat = uar_srvsetdouble(hsectionactivity,"dd_sref_section_id",cnvtreal(asection->
     dd_sref_section_id))
   SET cnt = size(asection->template_rltns,5)
   DECLARE htemplaterltn = i4 WITH private, noconstant(0)
   FOR (i = 1 TO cnt)
     SET htemplaterltn = uar_srvadditem(hsectionactivity,"template_rltns")
     SET nsrvstat = uar_srvsetstring(htemplaterltn,"dd_sref_templ_instance_ident",nullterm(asection->
       template_rltns[i].dd_sref_templ_instance_ident))
     SET nsrvstat = uar_srvsetdouble(htemplaterltn,"dd_sref_chf_cmplnt_crit_id",asection->
      template_rltns[i].dd_sref_chf_cmplnt_crit_id)
     SET nsrvstat = uar_srvsetdouble(htemplaterltn,"parent_entity_id",asection->template_rltns[i].
      parent_entity_id)
     SET nsrvstat = uar_srvsetstring(htemplaterltn,"parent_entity_name",nullterm(asection->
       template_rltns[i].parent_entity_name))
   ENDFOR
   SET cnt = size(asection->groupbys,5)
   FOR (i = 1 TO cnt)
     CALL addgroupbyactivity(subsectionindex,i,hsectionactivity)
   ENDFOR
   SET curalias asection off
   IF (subsectionindex=0)
    SET cnt = size(activity->section_act.subsections,5)
    FOR (i = 1 TO cnt)
      CALL addsectionactivity(i,hsectionactivity)
    ENDFOR
   ELSE
    SET nsrvstat = uar_srvsetdouble(hsectionactivity,"parent_section_id",activity->section_act.
     subsections[subsectionindex].parent_section_id)
   ENDIF
   CALL log_message(build("Exit AddSectionActivity(), Elapsed time:",((curtime3 - begin_time)/ 100.0)
     ),log_level_debug)
 END ;Subroutine
 SUBROUTINE addgroupbyactivity(subsectionindex,groupbyindex,dest)
   CALL log_message("In AddGroupByActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias agroupby activity->section_act.subsections[subsectionindex].groupbys[groupbyindex]
   ELSE
    SET curalias agroupby activity->section_act.groupbys[groupbyindex]
   ENDIF
   DECLARE hgroupbyactivity = i4 WITH private, noconstant(uar_srvadditem(dest,"groupbys"))
   SET nsrvstat = uar_srvsetdouble(hgroupbyactivity,"dd_groupby_id",cnvtreal(agroupby->dd_groupby_id)
    )
   SET nsrvstat = uar_srvsetstring(hgroupbyactivity,"label",nullterm(agroupby->label))
   SET nsrvstat = uar_srvsetstring(hgroupbyactivity,"truth_state_mean",nullterm(agroupby->
     truth_state_mean))
   SET cnt = size(agroupby->subgroupbys,5)
   FOR (i = 1 TO cnt)
     CALL addsubgroupbyactivity(subsectionindex,groupbyindex,i,hgroupbyactivity)
   ENDFOR
   SET cnt = size(agroupby->items,5)
   FOR (i = 1 TO cnt)
     CALL addgroupbyitemactivity(subsectionindex,groupbyindex,i,hgroupbyactivity)
   ENDFOR
   SET curalias agroupby off
   CALL log_message(build("Exit AddGroupByActivity(), Elapsed time:",((curtime3 - begin_time)/ 100.0)
     ),log_level_debug)
 END ;Subroutine
 SUBROUTINE addgroupbyitemactivity(subsectionindex,groupbyindex,itemindex,dest)
   CALL log_message("In AddGroupByItemActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias agroupbyitem activity->section_act.subsections[subsectionindex].groupbys[
    groupbyindex].items[itemindex]
   ELSE
    SET curalias agroupbyitem activity->section_act.groupbys[groupbyindex].items[itemindex]
   ENDIF
   DECLARE hitems = i4 WITH private, noconstant(uar_srvadditem(dest,"items"))
   SET nsrvstat = uar_srvsetdouble(hitems,"dd_item_id",cnvtreal(agroupbyitem->dd_item_id))
   SET nsrvstat = uar_srvsetstring(hitems,"ocid",nullterm(agroupbyitem->ocid))
   SET nsrvstat = uar_srvsetstring(hitems,"truth_state_mean",nullterm(agroupbyitem->truth_state_mean)
    )
   SET cnt = size(agroupbyitem->attributes,5)
   FOR (i = 1 TO cnt)
     CALL addgroupbyattributeactivity(subsectionindex,groupbyindex,itemindex,i,hitems)
   ENDFOR
   SET curalias agroupbyitem off
   CALL log_message(build("Exit AddGroupByItemActivity(), Elapsed time:",((curtime3 - begin_time)/
     100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addgroupbyattributeactivity(subsectionindex,groupbyindex,itemindex,attribindex,dest)
   CALL log_message("In AddGroupByAttributeActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias agroupbyattribute activity->section_act.subsections[subsectionindex].groupbys[
    groupbyindex].items[itemindex].attributes[attribindex]
   ELSE
    SET curalias agroupbyattribute activity->section_act.groupbys[groupbyindex].items[itemindex].
    attributes[attribindex]
   ENDIF
   DECLARE hattributes = i4 WITH private, noconstant(uar_srvadditem(dest,"attributes"))
   SET nsrvstat = uar_srvsetdouble(hattributes,"dd_attribute_id",cnvtreal(agroupbyattribute->
     dd_attribute_id))
   SET nsrvstat = uar_srvsetstring(hattributes,"ocid",nullterm(agroupbyattribute->ocid))
   SET nsrvstat = uar_srvsetstring(hattributes,"truth_state_mean",nullterm(agroupbyattribute->
     truth_state_mean))
   SET cnt = size(agroupbyattribute->attribute_menu_items,5)
   FOR (i = 1 TO cnt)
     CALL addgroupbyattributemenuitemactivity(subsectionindex,groupbyindex,itemindex,attribindex,i,
      hattributes)
   ENDFOR
   SET curalias agroupbyattribute off
   CALL log_message(build("Exit AddGroupByAttributeActivity(), Elapsed time:",((curtime3 - begin_time
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addgroupbyattributemenuitemactivity(subsectionindex,groupbyindex,itemindex,attribindex,
  attribmenuitemindex,dest)
   CALL log_message("In AddGroupByAttributeMenuItemActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias agroupbyattributemenuitem activity->section_act.subsections[subsectionindex].
    groupbys[groupbyindex].items[itemindex].attributes[attribindex].attribute_menu_items[
    attribmenuitemindex]
   ELSE
    SET curalias agroupbyattributemenuitem activity->section_act.groupbys[groupbyindex].items[
    itemindex].attributes[attribindex].attribute_menu_items[attribmenuitemindex]
   ENDIF
   DECLARE hattributemenuitems = i4 WITH private, noconstant(uar_srvadditem(dest,
     "attribute_menu_items"))
   SET nsrvstat = uar_srvsetdouble(hattributemenuitems,"dd_attr_menu_item_id",cnvtreal(
     agroupbyattributemenuitem->dd_attr_menu_item_id))
   SET nsrvstat = uar_srvsetstring(hattributemenuitems,"ocid",nullterm(agroupbyattributemenuitem->
     ocid))
   SET nsrvstat = uar_srvsetlong(hattributemenuitems,"display_seq",cnvtint(agroupbyattributemenuitem
     ->display_seq))
   SET nsrvstat = uar_srvsetstring(hattributemenuitems,"truth_state_mean",nullterm(
     agroupbyattributemenuitem->truth_state_mean))
   SET nsrvstat = uar_srvsetasis(hattributemenuitems,"comment",agroupbyattributemenuitem->comment,
    size(agroupbyattributemenuitem->comment))
   SET nsrvstat = uar_srvsetstring(hattributemenuitems,"comment_format_mean",nullterm(
     agroupbyattributemenuitem->comment_format_mean))
   SET nsrvstat = uar_srvsetasis(hattributemenuitems,"value_text",agroupbyattributemenuitem->
    value_text,size(agroupbyattributemenuitem->value_text))
   SET nsrvstat = uar_srvsetstring(hattributemenuitems,"value_text_format_mean",nullterm(
     agroupbyattributemenuitem->value_text_format_mean))
   SET nsrvstat = uar_srvsetdouble(hattributemenuitems,"value_number",cnvtreal(
     agroupbyattributemenuitem->value_number))
   SET curalias agroupbyattributemenuitem off
   CALL log_message(build("Exit AddGroupByAttributeMenuItemActivity(), Elapsed time:",((curtime3 -
     begin_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addsubgroupbyactivity(subsectionindex,groupbyindex,subgroupindex,dest)
   CALL log_message("In AddSubgroupByActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asubgroupby activity->section_act.subsections[subsectionindex].groupbys[groupbyindex
    ].subgroupbys[subgroupindex]
   ELSE
    SET curalias asubgroupby activity->section_act.groupbys[groupbyindex].subgroupbys[subgroupindex]
   ENDIF
   DECLARE hsubgroupbyactivity = i4 WITH private, noconstant(uar_srvadditem(dest,"subgroupbys"))
   SET nsrvstat = uar_srvsetdouble(hsubgroupbyactivity,"dd_sgroupby_id",cnvtreal(asubgroupby->
     dd_sgroupby_id))
   SET nsrvstat = uar_srvsetstring(hsubgroupbyactivity,"label",nullterm(asubgroupby->label))
   SET nsrvstat = uar_srvsetstring(hsubgroupbyactivity,"truth_state_mean",nullterm(asubgroupby->
     truth_state_mean))
   SET cnt = size(asubgroupby->items,5)
   FOR (i = 1 TO cnt)
     CALL addsubgroupbyitemactivity(subsectionindex,groupbyindex,subgroupindex,i,hsubgroupbyactivity)
   ENDFOR
   SET curalias asubgroupby off
   CALL log_message(build("Exit AddSubgroupByActivity(), Elapsed time:",((curtime3 - begin_time)/
     100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addsubgroupbyitemactivity(subsectionindex,groupbyindex,subgroupindex,itemindex,dest)
   CALL log_message("In AddSubgroupByItemActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asubgroupbyitem activity->section_act.subsections[subsectionindex].groupbys[
    groupbyindex].subgroupbys[subgroupindex].items[itemindex]
   ELSE
    SET curalias asubgroupbyitem activity->section_act.groupbys[groupbyindex].subgroupbys[
    subgroupindex].items[itemindex]
   ENDIF
   DECLARE hitems = i4 WITH private, noconstant(uar_srvadditem(dest,"items"))
   SET nsrvstat = uar_srvsetdouble(hitems,"dd_item_id",cnvtreal(asubgroupbyitem->dd_item_id))
   SET nsrvstat = uar_srvsetstring(hitems,"ocid",nullterm(asubgroupbyitem->ocid))
   SET nsrvstat = uar_srvsetstring(hitems,"truth_state_mean",nullterm(asubgroupbyitem->
     truth_state_mean))
   SET cnt = size(asubgroupbyitem->attributes,5)
   FOR (i = 1 TO cnt)
     CALL addsubgroupbyattributeactivity(subsectionindex,groupbyindex,subgroupindex,itemindex,i,
      hitems)
   ENDFOR
   SET curalias asubgroupbyitem off
   CALL log_message(build("Exit AddSubgroupByItemActivity(), Elapsed time:",((curtime3 - begin_time)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addsubgroupbyattributeactivity(subsectionindex,groupbyindex,subgroupindex,itemindex,
  attribindex,dest)
   CALL log_message("In AddSubgroupByAttributeActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asubgroupbyattribute activity->section_act.subsections[subsectionindex].groupbys[
    groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[attribindex]
   ELSE
    SET curalias asubgroupbyattribute activity->section_act.groupbys[groupbyindex].subgroupbys[
    subgroupindex].items[itemindex].attributes[attribindex]
   ENDIF
   DECLARE hattributes = i4 WITH private, noconstant(uar_srvadditem(dest,"attributes"))
   SET nsrvstat = uar_srvsetdouble(hattributes,"dd_attribute_id",cnvtreal(asubgroupbyattribute->
     dd_attribute_id))
   SET nsrvstat = uar_srvsetstring(hattributes,"ocid",nullterm(asubgroupbyattribute->ocid))
   SET nsrvstat = uar_srvsetstring(hattributes,"truth_state_mean",nullterm(asubgroupbyattribute->
     truth_state_mean))
   SET cnt = size(asubgroupbyattribute->attribute_menu_items,5)
   FOR (i = 1 TO cnt)
     CALL addsubgroupbyattributemenuitemactivity(subsectionindex,groupbyindex,subgroupindex,itemindex,
      attribindex,
      i,hattributes)
   ENDFOR
   SET curalias asubgroupbyattribute off
   CALL log_message(build("Exit AddSubgroupByAttributeActivity(), Elapsed time:",((curtime3 -
     begin_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addsubgroupbyattributemenuitemactivity(subsectionindex,groupbyindex,subgroupindex,
  itemindex,attribindex,attribmenuitemindex,dest)
   CALL log_message("In AddSubgroupByAttributeMenuItemActivity()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE nsrvstat = i4 WITH protect, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asubgroupbyattributemenuitem activity->section_act.subsections[subsectionindex].
    groupbys[groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[attribindex].
    attribute_menu_items[attribmenuitemindex]
   ELSE
    SET curalias asubgroupbyattributemenuitem activity->section_act.groupbys[groupbyindex].
    subgroupbys[subgroupindex].items[itemindex].attributes[attribindex].attribute_menu_items[
    attribmenuitemindex]
   ENDIF
   DECLARE hattributemenutitems = i4 WITH private, noconstant(uar_srvadditem(dest,
     "attribute_menu_items"))
   SET nsrvstat = uar_srvsetdouble(hattributemenutitems,"dd_attr_menu_item_id",cnvtreal(
     asubgroupbyattributemenuitem->dd_attr_menu_item_id))
   SET nsrvstat = uar_srvsetstring(hattributemenutitems,"ocid",nullterm(asubgroupbyattributemenuitem
     ->ocid))
   SET nsrvstat = uar_srvsetlong(hattributemenutitems,"display_seq",cnvtint(
     asubgroupbyattributemenuitem->display_seq))
   SET nsrvstat = uar_srvsetstring(hattributemenutitems,"truth_state_mean",nullterm(
     asubgroupbyattributemenuitem->truth_state_mean))
   SET nsrvstat = uar_srvsetasis(hattributemenutitems,"comment",asubgroupbyattributemenuitem->comment,
    size(asubgroupbyattributemenuitem->comment))
   SET nsrvstat = uar_srvsetstring(hattributemenutitems,"comment_format_mean",nullterm(
     asubgroupbyattributemenuitem->comment_format_mean))
   SET nsrvstat = uar_srvsetasis(hattributemenutitems,"value_text",asubgroupbyattributemenuitem->
    value_text,size(asubgroupbyattributemenuitem->value_text))
   SET nsrvstat = uar_srvsetstring(hattributemenutitems,"value_text_format_mean",nullterm(
     asubgroupbyattributemenuitem->value_text_format_mean))
   SET nsrvstat = uar_srvsetdouble(hattributemenutitems,"value_number",cnvtreal(
     asubgroupbyattributemenuitem->value_number))
   SET curalias asubgroupbyattributemenuitem off
   CALL log_message(build("Exit AddSubgroupByAttributeMenuItemActivity(), Elapsed time:",((curtime3
      - begin_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copysectionstruct(src,subsectionindex)
   CALL log_message("In CopySectionStruct()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asection activity->section_act.subsections[subsectionindex]
   ELSE
    SET curalias asection activity->section_act
   ENDIF
   SET asection->dd_section_id = uar_srvgetdouble(src,"dd_section_id")
   SET asection->dd_sref_section_id = uar_srvgetdouble(src,"dd_sref_section_id")
   DECLARE templatecnt = i4 WITH private, constant(uar_srvgetitemcount(src,"template_rltns"))
   DECLARE htemplaterltns = i4 WITH private, noconstant(0)
   SET stat = alterlist(asection->template_rltns,templatecnt)
   FOR (i = 1 TO templatecnt)
     SET htemplaterltns = uar_srvgetitem(src,"template_rltns",(i - 1))
     SET asection->template_rltns[i].dd_sref_templ_instance_ident = uar_srvgetstringptr(
      htemplaterltns,"dd_sref_templ_instance_ident")
     SET asection->template_rltns[i].dd_sref_chf_cmplnt_crit_id = uar_srvgetdouble(htemplaterltns,
      "dd_sref_chf_cmplnt_crit_id")
     SET asection->template_rltns[i].parent_entity_id = uar_srvgetdouble(htemplaterltns,
      "parent_entity_id")
     SET asection->template_rltns[i].parent_entity_name = uar_srvgetstringptr(htemplaterltns,
      "parent_entity_name")
   ENDFOR
   DECLARE groupbycnt = i4 WITH private, noconstant(uar_srvgetitemcount(src,"groupbys"))
   SET stat = alterlist(asection->groupbys,groupbycnt)
   FOR (i = 1 TO groupbycnt)
     CALL copygroupbystruct(uar_srvgetitem(src,"groupbys",(i - 1)),subsectionindex,i)
   ENDFOR
   SET curalias asection off
   IF (subsectionindex=0)
    DECLARE subsectioncnt = i4 WITH constant(uar_srvgetitemcount(src,"subsections")), private
    SET stat = alterlist(activity->section_act.subsections,subsectioncnt)
    FOR (i = 1 TO subsectioncnt)
      CALL copysectionstruct(uar_srvgetitem(src,"subsections",(i - 1)),i)
    ENDFOR
   ELSE
    SET activity->section_act.subsections[subsectionindex].parent_section_id = uar_srvgetdouble(src,
     "parent_section_id")
   ENDIF
   CALL log_message(build("Exit CopySectionStruct(), Elapsed time:",((curtime3 - begin_time)/ 100.0)),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE copygroupbystruct(src,subsectionindex,groupbyindex)
   CALL log_message("In CopyGroupByStruct()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias agroupby activity->section_act.subsections[subsectionindex].groupbys[groupbyindex]
   ELSE
    SET curalias agroupby activity->section_act.groupbys[groupbyindex]
   ENDIF
   SET agroupby->dd_groupby_id = uar_srvgetdouble(src,"dd_groupby_id")
   SET agroupby->label = uar_srvgetstringptr(src,"label")
   SET agroupby->truth_state_mean = uar_srvgetstringptr(src,"truth_state_mean")
   DECLARE subgroupbycnt = i4 WITH constant(uar_srvgetitemcount(src,"subgroupbys")), private
   SET stat = alterlist(agroupby->subgroupbys,subgroupbycnt)
   FOR (i = 1 TO subgroupbycnt)
     CALL copysubgroupbystruct(uar_srvgetitem(src,"subgroupbys",(i - 1)),subsectionindex,groupbyindex,
      i)
   ENDFOR
   DECLARE itemcnt = i4 WITH constant(uar_srvgetitemcount(src,"items")), private
   SET stat = alterlist(agroupby->items,itemcnt)
   FOR (i = 1 TO itemcnt)
     CALL copygroupbyitem(uar_srvgetitem(src,"items",(i - 1)),subsectionindex,groupbyindex,i)
   ENDFOR
   SET curalias agroupby off
   CALL log_message(build("Exit CopyGroupByStruct(), Elapsed time:",((curtime3 - begin_time)/ 100.0)),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE copygroupbyitem(src,subsectionindex,groupbyindex,itemindex)
   CALL log_message("In CopyGroupByItem()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias agroupbyitem activity->section_act.subsections[subsectionindex].groupbys[
    groupbyindex].items[itemindex]
   ELSE
    SET curalias agroupbyitem activity->section_act.groupbys[groupbyindex].items[itemindex]
   ENDIF
   SET agroupbyitem->dd_item_id = uar_srvgetdouble(src,"dd_item_id")
   SET agroupbyitem->ocid = uar_srvgetstringptr(src,"ocid")
   SET agroupbyitem->truth_state_mean = uar_srvgetstringptr(src,"truth_state_mean")
   DECLARE attribcnt = i4 WITH constant(uar_srvgetitemcount(src,"attributes")), private
   SET stat = alterlist(agroupbyitem->attributes,attribcnt)
   FOR (i = 1 TO attribcnt)
     CALL copygroupbyattribute(uar_srvgetitem(src,"attributes",(i - 1)),subsectionindex,groupbyindex,
      itemindex,i)
   ENDFOR
   SET curalias agroupbyitem off
   CALL log_message(build("Exit CopyGroupByItem(), Elapsed time:",((curtime3 - begin_time)/ 100.0)),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE copygroupbyattribute(src,subsectionindex,groupbyindex,itemindex,attribindex)
   CALL log_message("In CopyGroupByAttribute()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias agroupbyattribute activity->section_act.subsections[subsectionindex].groupbys[
    groupbyindex].items[itemindex].attributes[attribindex]
   ELSE
    SET curalias agroupbyattribute activity->section_act.groupbys[groupbyindex].items[itemindex].
    attributes[attribindex]
   ENDIF
   SET agroupbyattribute->dd_attribute_id = uar_srvgetdouble(src,"dd_attribute_id")
   SET agroupbyattribute->ocid = uar_srvgetstringptr(src,"ocid")
   SET agroupbyattribute->truth_state_mean = uar_srvgetstringptr(src,"truth_state_mean")
   DECLARE attributecnt = i4 WITH constant(uar_srvgetitemcount(src,"attribute_menu_items")), private
   SET stat = alterlist(agroupbyattribute->attribute_menu_items,attributecnt)
   FOR (i = 1 TO attributecnt)
     CALL copygroupbyattributemenuitem(uar_srvgetitem(src,"attribute_menu_items",(i - 1)),
      subsectionindex,groupbyindex,itemindex,attribindex,
      i)
   ENDFOR
   SET curalias agroupbyattribute off
   CALL log_message(build("Exit CopyGroupByAttribute(), Elapsed time:",((curtime3 - begin_time)/
     100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copygroupbyattributemenuitem(src,subsectionindex,groupbyindex,itemindex,attribindex,
  attribmenuitemindex)
   CALL log_message("In CopyGroupByAttributeMenuItem()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   IF (subsectionindex > 0)
    SET curalias agroupbyattributemenuitem activity->section_act.subsections[subsectionindex].
    groupbys[groupbyindex].items[itemindex].attributes[attribindex].attribute_menu_items[
    attribmenuitemindex]
   ELSE
    SET curalias agroupbyattributemenuitem activity->section_act.groupbys[groupbyindex].items[
    itemindex].attributes[attribindex].attribute_menu_items[attribmenuitemindex]
   ENDIF
   SET agroupbyattributemenuitem->dd_attr_menu_item_id = uar_srvgetdouble(src,"dd_attr_menu_item_id")
   SET agroupbyattributemenuitem->ocid = uar_srvgetstringptr(src,"ocid")
   SET agroupbyattributemenuitem->display_seq = uar_srvgetlong(src,"display_seq")
   SET agroupbyattributemenuitem->truth_state_mean = uar_srvgetstringptr(src,"truth_state_mean")
   SET agroupbyattributemenuitem->comment = getasisstring(src,"comment")
   SET agroupbyattributemenuitem->comment_format_mean = uar_srvgetstringptr(src,"comment_format_mean"
    )
   SET agroupbyattributemenuitem->value_text = getasisstring(src,"value_text")
   SET agroupbyattributemenuitem->value_text_format_mean = uar_srvgetstringptr(src,
    "value_text_format_mean")
   SET agroupbyattributemenuitem->value_number = uar_srvgetdouble(src,"value_number")
   SET curalias agroupbyattributemenuitem off
   CALL log_message(build("Exit CopyGroupByAttributeMenuItem(), Elapsed time:",((curtime3 -
     begin_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copysubgroupbystruct(src,subsectionindex,groupbyindex,subgroupindex)
   CALL log_message("In CopySubGroupByStruct()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asubgroupby activity->section_act.subsections[subsectionindex].groupbys[groupbyindex
    ].subgroupbys[subgroupindex]
   ELSE
    SET curalias asubgroupby activity->section_act.groupbys[groupbyindex].subgroupbys[subgroupindex]
   ENDIF
   SET asubgroupby->dd_sgroupby_id = uar_srvgetdouble(src,"dd_sgroupby_id")
   SET asubgroupby->label = uar_srvgetstringptr(src,"label")
   SET asubgroupby->truth_state_mean = uar_srvgetstringptr(src,"truth_state_mean")
   DECLARE itemcnt = i4 WITH constant(uar_srvgetitemcount(src,"items")), private
   SET stat = alterlist(asubgroupby->items,itemcnt)
   FOR (i = 1 TO itemcnt)
     CALL copysubgroupbyitem(uar_srvgetitem(src,"items",(i - 1)),subsectionindex,groupbyindex,
      subgroupindex,i)
   ENDFOR
   SET curalias asubgroupby off
   CALL log_message(build("Exit CopySubGroupByStruct(), Elapsed time:",((curtime3 - begin_time)/
     100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copysubgroupbyitem(src,subsectionindex,groupbyindex,subgroupindex,itemindex)
   CALL log_message("In CopySubGroupByItem()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asubgroupbyitem activity->section_act.subsections[subsectionindex].groupbys[
    groupbyindex].subgroupbys[subgroupindex].items[itemindex]
   ELSE
    SET curalias asubgroupbyitem activity->section_act.groupbys[groupbyindex].subgroupbys[
    subgroupindex].items[itemindex]
   ENDIF
   SET asubgroupbyitem->dd_item_id = uar_srvgetdouble(src,"dd_item_id")
   SET asubgroupbyitem->ocid = uar_srvgetstringptr(src,"ocid")
   SET asubgroupbyitem->truth_state_mean = uar_srvgetstringptr(src,"truth_state_mean")
   DECLARE attributecnt = i4 WITH constant(uar_srvgetitemcount(src,"attributes")), private
   SET stat = alterlist(asubgroupbyitem->attributes,attributecnt)
   FOR (i = 1 TO attributecnt)
     CALL copysubgroupbyattribute(uar_srvgetitem(src,"attributes",(i - 1)),subsectionindex,
      groupbyindex,subgroupindex,itemindex,
      i)
   ENDFOR
   SET curalias asubgroupbyitem off
   CALL log_message(build("Exit CopySubGroupByItem(), Elapsed time:",((curtime3 - begin_time)/ 100.0)
     ),log_level_debug)
 END ;Subroutine
 SUBROUTINE copysubgroupbyattribute(src,subsectionindex,groupbyindex,subgroupindex,itemindex,
  attribindex)
   CALL log_message("In CopySubGroupByAttribute()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias asubgroupbyattribute activity->section_act.subsections[subsectionindex].groupbys[
    groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[attribindex]
   ELSE
    SET curalias asubgroupbyattribute activity->section_act.groupbys[groupbyindex].subgroupbys[
    subgroupindex].items[itemindex].attributes[attribindex]
   ENDIF
   SET asubgroupbyattribute->dd_attribute_id = uar_srvgetdouble(src,"dd_attribute_id")
   SET asubgroupbyattribute->ocid = uar_srvgetstringptr(src,"ocid")
   SET asubgroupbyattribute->truth_state_mean = uar_srvgetstringptr(src,"truth_state_mean")
   DECLARE attributecnt = i4 WITH constant(uar_srvgetitemcount(src,"attribute_menu_items")), private
   SET stat = alterlist(asubgroupbyattribute->attribute_menu_items,attributecnt)
   FOR (i = 1 TO attributecnt)
     CALL copysubgroupbyattributemenuitem(uar_srvgetitem(src,"attribute_menu_items",(i - 1)),
      subsectionindex,groupbyindex,subgroupindex,itemindex,
      attribindex,i)
   ENDFOR
   SET curalias asubgroupbyattribute off
   CALL log_message(build("Exit CopySubGroupByAttribute(), Elapsed time:",((curtime3 - begin_time)/
     100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copysubgroupbyattributemenuitem(src,subsectionindex,groupbyindex,subgroupindex,itemindex,
  attribindex,attribmenuitemindex)
   CALL log_message("In CopySubGroupByAttributeMenuItem()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   IF (subsectionindex > 0)
    SET curalias asubgroupbyattributemenuitem activity->section_act.subsections[subsectionindex].
    groupbys[groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[attribindex].
    attribute_menu_items[attribmenuitemindex]
   ELSE
    SET curalias asubgroupbyattributemenuitem activity->section_act.groupbys[groupbyindex].
    subgroupbys[subgroupindex].items[itemindex].attributes[attribindex].attribute_menu_items[
    attribmenuitemindex]
   ENDIF
   SET asubgroupbyattributemenuitem->dd_attr_menu_item_id = uar_srvgetdouble(src,
    "dd_attr_menu_item_id")
   SET asubgroupbyattributemenuitem->ocid = uar_srvgetstringptr(src,"ocid")
   SET asubgroupbyattributemenuitem->display_seq = uar_srvgetlong(src,"display_seq")
   SET asubgroupbyattributemenuitem->truth_state_mean = uar_srvgetstringptr(src,"truth_state_mean")
   SET asubgroupbyattributemenuitem->comment = getasisstring(src,"comment")
   SET asubgroupbyattributemenuitem->comment_format_mean = uar_srvgetstringptr(src,
    "comment_format_mean")
   SET asubgroupbyattributemenuitem->value_text = getasisstring(src,"value_text")
   SET asubgroupbyattributemenuitem->value_text_format_mean = uar_srvgetstringptr(src,
    "value_text_format_mean")
   SET asubgroupbyattributemenuitem->value_number = uar_srvgetdouble(src,"value_number")
   SET curalias asubgroupbyattributemenuitem off
   CALL log_message(build("Exit CopySubGroupByAttributeMenuItem(), Elapsed time:",((curtime3 -
     begin_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getasisstring(hsrvstruct,fieldname)
   DECLARE text = vc WITH private, noconstant("")
   DECLARE textsize = i4 WITH private, noconstant(0)
   SET textsize = uar_srvgetasissize(hsrvstruct,nullterm(fieldname))
   SET stat = memrealloc(text,textsize,"C1")
   SET stat = uar_srvgetasis(hsrvstruct,nullterm(fieldname),text,textsize)
   RETURN(notrim(substring(1,textsize,text)))
 END ;Subroutine
 FREE RECORD reference
 RECORD reference(
   1 section[*]
     2 dd_sref_section_id = f8
     2 template_rltns[*]
       3 dd_sref_templ_instance_ident = vc
       3 chief_complaint_criteria = f8
       3 parent_entity_id = f8
       3 parent_entity_name = vc
     2 groupbys[*]
       3 value = vc
       3 display_seq = i4
       3 displayflag = i2
       3 subgroupbys[*]
         4 value = vc
         4 display_seq = i4
         4 displayflag = i2
         4 items[*]
           5 value = vc
           5 priority = i2
           5 ocid = vc
           5 display_seq = i4
           5 displayflag = i2
           5 code[*]
             6 code_system = vc
             6 value = vc
           5 attributes[*]
             6 name = vc
             6 attrib_type = vc
             6 attrib_id = vc
             6 ocid = vc
             6 priority = i2
             6 display_seq = i4
             6 displayflag = i2
             6 code[*]
               7 code_system = vc
               7 value = vc
             6 attribute_menu_items[*]
               7 value = vc
               7 caption = vc
               7 user_input = i2
               7 data_type = vc
               7 ocid = vc
               7 normalfinding = vc
               7 display_seq = i4
               7 min_value = f8
               7 max_value = f8
               7 priority = i2
               7 ui_type = vc
               7 code[*]
                 8 code_system = vc
                 8 value = vc
         4 code[*]
           5 code_system = vc
           5 value = vc
       3 items[*]
         4 value = vc
         4 priority = i2
         4 ocid = vc
         4 display_seq = i4
         4 displayflag = i2
         4 code[*]
           5 code_system = vc
           5 value = vc
         4 attributes[*]
           5 name = vc
           5 attrib_type = vc
           5 attrib_id = vc
           5 ocid = vc
           5 priority = i2
           5 display_seq = i4
           5 displayflag = i2
           5 code[*]
             6 code_system = vc
             6 value = vc
           5 attribute_menu_items[*]
             6 value = vc
             6 caption = vc
             6 user_input = i2
             6 data_type = vc
             6 ocid = vc
             6 normalfinding = vc
             6 display_seq = i4
             6 min_value = f8
             6 max_value = f8
             6 priority = i2
             6 ui_type = vc
             6 code[*]
               7 code_system = vc
               7 value = vc
       3 code[*]
         4 code_system = vc
         4 value = vc
     2 subsections[*]
       3 value = vc
       3 dd_sref_section_id = f8
       3 template_rltns[*]
         4 dd_sref_templ_instance_ident = vc
         4 chief_complaint_criteria = f8
         4 parent_entity_id = f8
         4 parent_entity_name = vc
       3 groupbys[*]
         4 value = vc
         4 display_seq = i4
         4 displayflag = i2
         4 subgroupbys[*]
           5 value = vc
           5 display_seq = i4
           5 displayflag = i2
           5 items[*]
             6 value = vc
             6 priority = i2
             6 ocid = vc
             6 display_seq = i4
             6 displayflag = i2
             6 code[*]
               7 code_system = vc
               7 value = vc
             6 attributes[*]
               7 name = vc
               7 attrib_type = vc
               7 attrib_id = vc
               7 ocid = vc
               7 priority = i2
               7 display_seq = i4
               7 displayflag = i2
               7 code[*]
                 8 code_system = vc
                 8 value = vc
               7 attribute_menu_items[*]
                 8 value = vc
                 8 caption = vc
                 8 user_input = i2
                 8 data_type = vc
                 8 ocid = vc
                 8 normalfinding = vc
                 8 display_seq = i4
                 8 min_value = f8
                 8 max_value = f8
                 8 priority = i2
                 8 ui_type = vc
                 8 code[*]
                   9 code_system = vc
                   9 value = vc
           5 code[*]
             6 code_system = vc
             6 value = vc
         4 items[*]
           5 value = vc
           5 priority = i2
           5 ocid = vc
           5 display_seq = i4
           5 displayflag = i2
           5 code[*]
             6 code_system = vc
             6 value = vc
           5 attributes[*]
             6 name = vc
             6 attrib_type = vc
             6 attrib_id = vc
             6 ocid = vc
             6 priority = i2
             6 display_seq = i4
             6 displayflag = i2
             6 code[*]
               7 code_system = vc
               7 value = vc
             6 attribute_menu_items[*]
               7 value = vc
               7 caption = vc
               7 user_input = i2
               7 data_type = vc
               7 ocid = vc
               7 normalfinding = vc
               7 display_seq = i4
               7 min_value = f8
               7 max_value = f8
               7 priority = i2
               7 ui_type = vc
               7 code[*]
                 8 code_system = vc
                 8 value = vc
         4 code[*]
           5 code_system = vc
           5 value = vc
 )
 DECLARE copyrefsectionstruct(src,sectionindex,subsectionindex) = null WITH protect
 DECLARE copyreftemplaterelationsstruct(src,sectionindex,subsectionindex,templateindex) = null WITH
 protect
 DECLARE copyrefgroupbystruct(src,sectionindex,subsectionindex,groupbyindex) = null WITH protect
 DECLARE copyrefgroupbyitem(src,sectionindex,subsectionindex,groupbyindex,itemindex) = null WITH
 protect
 DECLARE copyrefgroupbyattribute(src,sectionindex,subsectionindex,groupbyindex,itemindex,
  attribindex) = null WITH protect
 DECLARE copyrefgroupbyattributemenuitem(src,sectionindex,subsectionindex,groupbyindex,itemindex,
  attribindex,menuindex) = null WITH protect
 DECLARE copyrefsubgroupbystruct(src,sectionindex,subsectionindex,groupbyindex,subgroupindex) = null
 WITH protect
 DECLARE copyrefsubgroupbyitem(src,sectionindex,subsectionindex,groupbyindex,subgroupindex,
  itemindex) = null WITH protect
 DECLARE copyrefsubgroupbyattribute(src,sectionindex,subsectionindex,groupbyindex,subgroupindex,
  itemindex,attribindex) = null WITH protect
 DECLARE copyrefsubgroupbyattributemenuitem(src,sectionindex,subsectionindex,groupbyindex,
  subgroupindex,
  itemindex,attribindex,attribmenuitemindex) = null WITH protect
 SUBROUTINE copyrefsectionstruct(src,sectionindex,subsectionindex)
   CALL log_message("In CopyRefSectionStruct()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   CALL echo(build2("subsectionIndex: ",subsectionindex))
   IF (subsectionindex > 0)
    CALL echo(build2("using Subsection alias"))
    SET curalias rsection reference->section[sectionindex].subsections[subsectionindex]
   ELSE
    CALL echo(build2("using Parent Section alias"))
    SET curalias rsection reference->section[sectionindex]
   ENDIF
   SET rsection->dd_sref_section_id = uar_srvgetdouble(src,"dd_sref_section_id")
   CALL echo(build2("Copying template relations"))
   DECLARE templatecnt = i4 WITH constant(uar_srvgetitemcount(src,"template_rltns")), private
   SET stat = alterlist(rsection->template_rltns,templatecnt)
   FOR (i = 1 TO templatecnt)
     CALL copyreftemplaterelationsstruct(uar_srvgetitem(src,"template_rltns",(i - 1)),sectionindex,
      subsectionindex,i)
   ENDFOR
   CALL echo(build2("Copying Group By"))
   DECLARE groupcnt = i4 WITH constant(uar_srvgetitemcount(src,"groupbys")), private
   SET stat = alterlist(rsection->groupbys,groupcnt)
   FOR (i = 1 TO groupcnt)
     CALL copyrefgroupbystruct(uar_srvgetitem(src,"groupbys",(i - 1)),sectionindex,subsectionindex,i)
   ENDFOR
   SET curalias rsection off
   IF (subsectionindex=0)
    CALL echo(build2("Copying Subsections"))
    DECLARE subsectioncnt = i4 WITH constant(uar_srvgetitemcount(src,"subsections")), private
    SET stat = alterlist(reference->section[sectionindex].subsections,subsectioncnt)
    FOR (i = 1 TO subsectioncnt)
      CALL copyrefsectionstruct(uar_srvgetitem(src,"subsections",(i - 1)),sectionindex,i)
    ENDFOR
   ELSE
    SET reference->section[sectionindex].subsections[subsectionindex].value = uar_srvgetstringptr(src,
     "section_label")
   ENDIF
   CALL log_message(build("Exit CopyRefSectionStruct(), Elapsed time:",((curtime3 - begin_date_time)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyreftemplaterelationsstruct(src,sectionindex,subsectionindex,templateindex)
   CALL log_message("In CopyRefTemplateRelationsStruct()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rtemplate reference->section[sectionindex].subsections[subsectionindex].
    template_rltns[templateindex]
   ELSE
    SET curalias rtemplate reference->section[sectionindex].template_rltns[templateindex]
   ENDIF
   SET rtemplate->dd_sref_templ_instance_ident = uar_srvgetstringptr(src,
    "dd_sref_templ_instance_ident")
   SET rtemplate->chief_complaint_criteria = uar_srvgetdouble(src,"dd_sref_chf_cmplnt_crit_id")
   SET rtemplate->parent_entity_id = uar_srvgetdouble(src,"parent_entity_id")
   SET rtemplate->parent_entity_name = uar_srvgetstringptr(src,"parent_entity_name")
   SET curalias rtemplate off
   CALL log_message(build("Exit CopyRefTemplateRelationsStruct(), Elapsed time:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyrefgroupbystruct(src,sectionindex,subsectionindex,groupbyindex)
   CALL log_message("In CopyRefGroupByStruct()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE codeindex = i4 WITH protect, noconstant(0)
   DECLARE hcode = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rgroupby reference->section[sectionindex].subsections[subsectionindex].groupbys[
    groupbyindex]
    SET curalias rgroupbycodeitem reference->section[sectionindex].subsections[subsectionindex].
    groupbys[groupbyindex].code[codeindex]
   ELSE
    SET curalias rgroupby reference->section[sectionindex].groupbys[groupbyindex]
    SET curalias rgroupbycodeitem reference->section[sectionindex].groupbys[groupbyindex].code[
    codeindex]
   ENDIF
   SET rgroupby->value = uar_srvgetstringptr(src,"label")
   SET rgroupby->display_seq = uar_srvgetlong(src,"display_seq")
   SET rgroupby->displayflag = uar_srvgetshort(src,"displayflag")
   DECLARE subgroupbycnt = i4 WITH constant(uar_srvgetitemcount(src,"subgroupbys")), private
   SET stat = alterlist(rgroupby->subgroupbys,subgroupbycnt)
   FOR (i = 1 TO subgroupbycnt)
     CALL copyrefsubgroupbystruct(uar_srvgetitem(src,"subgroupbys",(i - 1)),sectionindex,
      subsectionindex,groupbyindex,i)
   ENDFOR
   DECLARE itemcnt = i4 WITH constant(uar_srvgetitemcount(src,"items")), private
   SET stat = alterlist(rgroupby->items,itemcnt)
   FOR (i = 1 TO itemcnt)
     CALL copyrefgroupbyitem(uar_srvgetitem(src,"items",(i - 1)),sectionindex,subsectionindex,
      groupbyindex,i)
   ENDFOR
   DECLARE codecnt = i4 WITH constant(uar_srvgetitemcount(src,"code")), private
   SET stat = alterlist(rgroupby->code,codecnt)
   FOR (codeindex = 1 TO codecnt)
     SET hcode = uar_srvgetitem(src,"code",(codeindex - 1))
     SET rgroupbycodeitem->code_system = uar_srvgetstringptr(hcode,"code_system")
     SET rgroupbycodeitem->value = uar_srvgetstringptr(hcode,"value")
   ENDFOR
   SET curalias rgroupby off
   SET curalias rgroupbycodeitem off
   CALL log_message(build("Exit CopyRefGroupByStruct(), Elapsed time:",((curtime3 - begin_date_time)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyrefgroupbyitem(src,sectionindex,subsectionindex,groupbyindex,itemindex)
   CALL log_message("In CopyRefGroupByItem()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE codeindex = i4 WITH protect, noconstant(0)
   DECLARE hcode = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rgroupbyitem reference->section[sectionindex].subsections[subsectionindex].groupbys[
    groupbyindex].items[itemindex]
    SET curalias rgroupbyitemcodeitem reference->section[sectionindex].subsections[subsectionindex].
    groupbys[groupbyindex].items[itemindex].code[codeindex]
   ELSE
    SET curalias rgroupbyitem reference->section[sectionindex].groupbys[groupbyindex].items[itemindex
    ]
    SET curalias rgroupbyitemcodeitem reference->section[sectionindex].groupbys[groupbyindex].items[
    itemindex].code[codeindex]
   ENDIF
   SET rgroupbyitem->value = uar_srvgetstringptr(src,"value")
   SET rgroupbyitem->priority = uar_srvgetshort(src,"priority")
   SET rgroupbyitem->ocid = uar_srvgetstringptr(src,"ocid")
   SET rgroupbyitem->display_seq = uar_srvgetlong(src,"display_seq")
   SET rgroupbyitem->displayflag = uar_srvgetshort(src,"displayflag")
   DECLARE codecnt = i4 WITH constant(uar_srvgetitemcount(src,"code")), private
   SET stat = alterlist(rgroupbyitem->code,codecnt)
   FOR (codeindex = 1 TO codecnt)
     SET hcode = uar_srvgetitem(src,"code",(codeindex - 1))
     SET rgroupbyitemcodeitem->code_system = uar_srvgetstringptr(hcode,"code_system")
     SET rgroupbyitemcodeitem->value = uar_srvgetstringptr(hcode,"value")
   ENDFOR
   DECLARE attribcnt = i4 WITH constant(uar_srvgetitemcount(src,"attributes")), private
   SET stat = alterlist(rgroupbyitem->attributes,attribcnt)
   FOR (i = 1 TO attribcnt)
     CALL copyrefgroupbyattribute(uar_srvgetitem(src,"attributes",(i - 1)),sectionindex,
      subsectionindex,groupbyindex,itemindex,
      i)
   ENDFOR
   SET curalias rgroupbyitem off
   SET curalias rgroupbyitemcodeitem off
   CALL log_message(build("Exit CopyRefGroupByItem(), Elapsed time:",((curtime3 - begin_date_time)/
     100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyrefgroupbyattribute(src,sectionindex,subsectionindex,groupbyindex,itemindex,
  attribindex)
   CALL log_message("In CopyRefGroupByAttribute()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE codeindex = i4 WITH protect, noconstant(0)
   DECLARE hcode = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rgroupbyattribute reference->section[sectionindex].subsections[subsectionindex].
    groupbys[groupbyindex].items[itemindex].attributes[attribindex]
    SET curalias rgroupbyattributecodeitem reference->section[sectionindex].subsections[
    subsectionindex].groupbys[groupbyindex].items[itemindex].attributes[attribindex].code[codeindex]
   ELSE
    SET curalias rgroupbyattribute reference->section[sectionindex].groupbys[groupbyindex].items[
    itemindex].attributes[attribindex]
    SET curalias rgroupbyattributecodeitem reference->section[sectionindex].groupbys[groupbyindex].
    items[itemindex].attributes[attribindex].code[codeindex]
   ENDIF
   SET rgroupbyattribute->name = uar_srvgetstringptr(src,"name")
   SET rgroupbyattribute->attrib_type = uar_srvgetstringptr(src,"attrib_type")
   SET rgroupbyattribute->attrib_id = uar_srvgetstringptr(src,"attribid")
   SET rgroupbyattribute->ocid = uar_srvgetstringptr(src,"ocid")
   SET rgroupbyattribute->priority = uar_srvgetshort(src,"priority")
   SET rgroupbyattribute->display_seq = uar_srvgetlong(src,"display_seq")
   SET rgroupbyattribute->displayflag = uar_srvgetshort(src,"displayflag")
   DECLARE codecnt = i4 WITH constant(uar_srvgetitemcount(src,"code")), private
   SET stat = alterlist(rgroupbyattribute->code,codecnt)
   FOR (codeindex = 1 TO codecnt)
     SET hcode = uar_srvgetitem(src,"code",(codeindex - 1))
     SET rgroupbyattributecodeitem->code_system = uar_srvgetstringptr(hcode,"code_system")
     SET rgroupbyattributecodeitem->value = uar_srvgetstringptr(hcode,"value")
   ENDFOR
   DECLARE attribcnt = i4 WITH constant(uar_srvgetitemcount(src,"attribute_menu_items")), private
   SET stat = alterlist(rgroupbyattribute->attribute_menu_items,attribcnt)
   FOR (i = 1 TO attribcnt)
     CALL copyrefgroupbyattributemenuitem(uar_srvgetitem(src,"attribute_menu_items",(i - 1)),
      sectionindex,subsectionindex,groupbyindex,itemindex,
      attribindex,i)
   ENDFOR
   SET curalias rgroupbyattribute off
   SET curalias rgroupbyattributecodeitem off
   CALL log_message(build("Exit CopyRefGroupByAttribute(), Elapsed time:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyrefgroupbyattributemenuitem(src,sectionindex,subsectionindex,groupbyindex,itemindex,
  attribindex,attribmenuitemindex)
   CALL log_message("In CopyRefGroupByAttributeMenuItem()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE codeindex = i4 WITH protect, noconstant(0)
   DECLARE hcode = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rgroupbyattributemenuitem reference->section[sectionindex].subsections[
    subsectionindex].groupbys[groupbyindex].items[itemindex].attributes[attribindex].
    attribute_menu_items[attribmenuitemindex]
    SET curalias rgroupbyattributemenuitemcodeitem reference->section[sectionindex].subsections[
    subsectionindex].groupbys[groupbyindex].items[itemindex].attributes[attribindex].
    attribute_menu_items[attribmenuitemindex].code[codeindex]
   ELSE
    SET curalias rgroupbyattributemenuitem reference->section[sectionindex].groupbys[groupbyindex].
    items[itemindex].attributes[attribindex].attribute_menu_items[attribmenuitemindex]
    SET curalias rgroupbyattributemenuitemcodeitem reference->section[sectionindex].groupbys[
    groupbyindex].items[itemindex].attributes[attribindex].attribute_menu_items[attribmenuitemindex].
    code[codeindex]
   ENDIF
   SET rgroupbyattributemenuitem->value = uar_srvgetstringptr(src,"value")
   SET rgroupbyattributemenuitem->caption = uar_srvgetstringptr(src,"caption")
   SET rgroupbyattributemenuitem->user_input = uar_srvgetshort(src,"user_input")
   SET rgroupbyattributemenuitem->data_type = uar_srvgetstringptr(src,"data_type")
   SET rgroupbyattributemenuitem->ocid = uar_srvgetstringptr(src,"ocid")
   SET rgroupbyattributemenuitem->normalfinding = uar_srvgetstringptr(src,"normalfinding")
   SET rgroupbyattributemenuitem->display_seq = uar_srvgetlong(src,"display_seq")
   SET rgroupbyattributemenuitem->min_value = uar_srvgetdouble(src,"min_value")
   SET rgroupbyattributemenuitem->max_value = uar_srvgetdouble(src,"max_value")
   SET rgroupbyattributemenuitem->priority = uar_srvgetshort(src,"priority")
   SET rgroupbyattributemenuitem->ui_type = uar_srvgetstringptr(src,"ui_type")
   DECLARE codecnt = i4 WITH constant(uar_srvgetitemcount(src,"code")), private
   SET stat = alterlist(rgroupbyattributemenuitem->code,codecnt)
   FOR (codeindex = 1 TO codecnt)
     SET hcode = uar_srvgetitem(src,"code",(codeindex - 1))
     SET rgroupbyattributemenuitemcodeitem->code_system = uar_srvgetstringptr(hcode,"code_system")
     SET rgroupbyattributemenuitemcodeitem->value = uar_srvgetstringptr(hcode,"value")
   ENDFOR
   SET curalias rgroupbyattributemenuitem off
   SET curalias rgroupbyattributemenuitemcodeitem off
   CALL log_message(build("Exit CopyRefGroupByAttributeMenuItem(), Elapsed time:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyrefsubgroupbystruct(src,sectionindex,subsectionindex,groupbyindex,subgroupindex)
   CALL log_message("In CopyRefsubgroupbystruct()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE codeindex = i4 WITH protect, noconstant(0)
   DECLARE hcode = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rsubgroupby reference->section[sectionindex].subsections[subsectionindex].groupbys[
    groupbyindex].subgroupbys[subgroupindex]
    SET curalias rsubgroupbycodeitem reference->section[sectionindex].subsections[subsectionindex].
    groupbys[groupbyindex].subgroupbys[subgroupindex].code[codeindex]
   ELSE
    SET curalias rsubgroupby reference->section[sectionindex].groupbys[groupbyindex].subgroupbys[
    subgroupindex]
    SET curalias rsubgroupbycodeitem reference->section[sectionindex].groupbys[groupbyindex].
    subgroupbys[subgroupindex].code[codeindex]
   ENDIF
   SET rsubgroupby->value = uar_srvgetstringptr(src,"label")
   SET rsubgroupby->display_seq = uar_srvgetlong(src,"display_seq")
   SET rsubgroupby->displayflag = uar_srvgetshort(src,"displayflag")
   DECLARE item_cnt = i4 WITH constant(uar_srvgetitemcount(src,"items")), private
   SET stat = alterlist(rsubgroupby->items,item_cnt)
   FOR (i = 1 TO item_cnt)
     CALL copyrefsubgroupbyitem(uar_srvgetitem(src,"items",(i - 1)),sectionindex,subsectionindex,
      groupbyindex,subgroupindex,
      i)
   ENDFOR
   DECLARE codecnt = i4 WITH constant(uar_srvgetitemcount(src,"code")), private
   SET stat = alterlist(rsubgroupby->code,codecnt)
   FOR (codeindex = 1 TO codecnt)
     SET hcode = uar_srvgetitem(src,"code",(codeindex - 1))
     SET rsubgroupbycodeitem->code_system = uar_srvgetstringptr(hcode,"code_system")
     SET rsubgroupbycodeitem->value = uar_srvgetstringptr(hcode,"value")
   ENDFOR
   SET curalias rsubgroupby off
   SET curalias rsubgroupbycodeitem off
   CALL log_message(build("Exit CopyRefsubgroupbystruct(), Elapsed time:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyrefsubgroupbyitem(src,sectionindex,subsectionindex,groupbyindex,subgroupindex,
  itemindex)
   CALL log_message("In CopyRefSubGroupByItem()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE codeindex = i4 WITH protect, noconstant(0)
   DECLARE hcode = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rsubgroupbyitem reference->section[sectionindex].subsections[subsectionindex].
    groupbys[groupbyindex].subgroupbys[subgroupindex].items[itemindex]
    SET curalias rsubgroupbyitemcodeitem reference->section[sectionindex].subsections[subsectionindex
    ].groupbys[groupbyindex].subgroupbys[subgroupindex].items[itemindex].code[codeindex]
   ELSE
    SET curalias rsubgroupbyitem reference->section[sectionindex].groupbys[groupbyindex].subgroupbys[
    subgroupindex].items[itemindex]
    SET curalias rsubgroupbyitemcodeitem reference->section[sectionindex].groupbys[groupbyindex].
    subgroupbys[subgroupindex].items[itemindex].code[codeindex]
   ENDIF
   SET rsubgroupbyitem->value = uar_srvgetstringptr(src,"value")
   SET rsubgroupbyitem->priority = uar_srvgetshort(src,"priority")
   SET rsubgroupbyitem->ocid = uar_srvgetstringptr(src,"ocid")
   SET rsubgroupbyitem->display_seq = uar_srvgetlong(src,"display_seq")
   SET rsubgroupbyitem->displayflag = uar_srvgetshort(src,"displayflag")
   DECLARE codecnt = i4 WITH constant(uar_srvgetitemcount(src,"CODE")), private
   SET stat = alterlist(rsubgroupbyitem->code,codecnt)
   FOR (codeindex = 1 TO codecnt)
     SET hcode = uar_srvgetitem(src,"code",(codeindex - 1))
     SET rsubgroupbyitemcodeitem->code_system = uar_srvgetstringptr(hcode,"code_system")
     SET rsubgroupbyitemcodeitem->value = uar_srvgetstringptr(hcode,"value")
   ENDFOR
   DECLARE attribcnt = i4 WITH constant(uar_srvgetitemcount(src,"attributes")), private
   SET stat = alterlist(rsubgroupbyitem->attributes,attribcnt)
   FOR (i = 1 TO attribcnt)
     CALL copyrefsubgroupbyattribute(uar_srvgetitem(src,"attributes",(i - 1)),sectionindex,
      subsectionindex,groupbyindex,subgroupindex,
      itemindex,i)
   ENDFOR
   SET curalias rsubgroupbyitem off
   SET curalias rsubgroupbyitemcodeitem off
   CALL log_message(build("Exit CopyRefSubGroupByItem(), Elapsed time:",((curtime3 - begin_date_time)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyrefsubgroupbyattribute(src,sectionindex,subsectionindex,groupbyindex,subgroupindex,
  itemindex,attribindex)
   CALL log_message("In CopyRefSubGroupByAttribute()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE codeindex = i4 WITH protect, noconstant(0)
   DECLARE hcode = i4 WITH private, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rsubgroupbyattribute reference->section[sectionindex].subsections[subsectionindex].
    groupbys[groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[attribindex]
    SET curalias rsubgroupbyattributecodeitem reference->section[sectionindex].subsections[
    subsectionindex].groupbys[groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[
    attribindex].code[codeindex]
   ELSE
    SET curalias rsubgroupbyattribute reference->section[sectionindex].groupbys[groupbyindex].
    subgroupbys[subgroupindex].items[itemindex].attributes[attribindex]
    SET curalias rsubgroupbyattributecodeitem reference->section[sectionindex].groupbys[groupbyindex]
    .subgroupbys[subgroupindex].items[itemindex].attributes[attribindex].code[codeindex]
   ENDIF
   SET rsubgroupbyattribute->name = uar_srvgetstringptr(src,"name")
   SET rsubgroupbyattribute->attrib_type = uar_srvgetstringptr(src,"attrib_type")
   SET rsubgroupbyattribute->attrib_id = uar_srvgetstringptr(src,"attribid")
   SET rsubgroupbyattribute->ocid = uar_srvgetstringptr(src,"ocid")
   SET rsubgroupbyattribute->priority = uar_srvgetshort(src,"priority")
   SET rsubgroupbyattribute->display_seq = uar_srvgetlong(src,"display_seq")
   SET rsubgroupbyattribute->displayflag = uar_srvgetshort(src,"displayflag")
   DECLARE codecnt = i4 WITH constant(uar_srvgetitemcount(src,"code")), private
   SET stat = alterlist(rsubgroupbyattribute->code,codecnt)
   FOR (codeindex = 1 TO codecnt)
     SET hcode = uar_srvgetitem(src,"code",(codeindex - 1))
     SET rsubgroupbyattributecodeitem->code_system = uar_srvgetstringptr(hcode,"code_system")
     SET rsubgroupbyattributecodeitem->value = uar_srvgetstringptr(hcode,"value")
   ENDFOR
   DECLARE attrib_cnt = i4 WITH constant(uar_srvgetitemcount(src,"attribute_menu_items")), private
   SET stat = alterlist(rsubgroupbyattribute->attribute_menu_items,attrib_cnt)
   FOR (i = 1 TO attrib_cnt)
     CALL copyrefsubgroupbyattributemenuitem(uar_srvgetitem(src,"attribute_menu_items",(i - 1)),
      sectionindex,subsectionindex,groupbyindex,subgroupindex,
      itemindex,attribindex,i)
   ENDFOR
   SET curalias rsubgroupbyattribute off
   SET curalias rsubgroupbyattributecodeitem off
   CALL log_message(build("Exit CopyRefSubGroupByAttribute(), Elapsed time:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE copyrefsubgroupbyattributemenuitem(src,sectionindex,subsectionindex,groupbyindex,
  subgroupindex,itemindex,attribindex,attribmenuitemindex)
   CALL log_message("In CopyRefSubGroupByAttributeMenuItem()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE codeindex = i4 WITH protect, noconstant(0)
   DECLARE hcode = i4 WITH protect, noconstant(0)
   DECLARE i = i4 WITH private, noconstant(0)
   IF (subsectionindex > 0)
    SET curalias rsubgroupbyattributemenuitem reference->section[sectionindex].subsections[
    subsectionindex].groupbys[groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[
    attribindex].attribute_menu_items[attribmenuitemindex]
    SET curalias rsubgroupbyattributemenuitemcodeitem reference->section[sectionindex].subsections[
    subsectionindex].groupbys[groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[
    attribindex].attribute_menu_items[attribmenuitemindex].code[codeindex]
   ELSE
    SET curalias rsubgroupbyattributemenuitem reference->section[sectionindex].groupbys[groupbyindex]
    .subgroupbys[subgroupindex].items[itemindex].attributes[attribindex].attribute_menu_items[
    attribmenuitemindex]
    SET curalias rsubgroupbyattributemenuitemcodeitem reference->section[sectionindex].groupbys[
    groupbyindex].subgroupbys[subgroupindex].items[itemindex].attributes[attribindex].
    attribute_menu_items[attribmenuitemindex].code[codeindex]
   ENDIF
   SET rsubgroupbyattributemenuitem->value = uar_srvgetstringptr(src,"value")
   SET rsubgroupbyattributemenuitem->caption = uar_srvgetstringptr(src,"caption")
   SET rsubgroupbyattributemenuitem->user_input = uar_srvgetshort(src,"user_input")
   SET rsubgroupbyattributemenuitem->data_type = uar_srvgetstringptr(src,"data_type")
   SET rsubgroupbyattributemenuitem->ocid = uar_srvgetstringptr(src,"ocid")
   SET rsubgroupbyattributemenuitem->normalfinding = uar_srvgetstringptr(src,"normalfinding")
   SET rsubgroupbyattributemenuitem->display_seq = uar_srvgetlong(src,"display_seq")
   SET rsubgroupbyattributemenuitem->min_value = uar_srvgetdouble(src,"min_value")
   SET rsubgroupbyattributemenuitem->max_value = uar_srvgetdouble(src,"max_value")
   SET rsubgroupbyattributemenuitem->priority = uar_srvgetshort(src,"priority")
   SET rsubgroupbyattributemenuitem->ui_type = uar_srvgetstringptr(src,"ui_type")
   DECLARE codecnt = i4 WITH constant(uar_srvgetitemcount(src,"code")), private
   SET stat = alterlist(rsubgroupbyattributemenuitem->code,codecnt)
   FOR (codeindex = 1 TO codecnt)
     SET hcode = uar_srvgetitem(src,"code",(codeindex - 1))
     SET rsubgroupbyattributemenuitemcodeitem->code_system = uar_srvgetstringptr(hcode,"code_system")
     SET rsubgroupbyattributemenuitemcodeitem->value = uar_srvgetstringptr(hcode,"value")
   ENDFOR
   SET curalias rsubgroupbyattributemenuitem off
   SET curalias rsubgroupbyattributemenuitemcodeitem off
   CALL log_message(build("Exit CopyRefSubGroupByAttributeMenuItem(), Elapsed time:",((curtime3 -
     begin_date_time)/ 100.0)),log_level_debug)
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
 SET log_program_name = "cp_open_exist_struct_doc"
 DECLARE script_start_tm = dq8 WITH constant(curtime3), private
 DECLARE main(null) = null
 DECLARE getlongtextvalues(null) = null
 DECLARE openstructuredsection(null) = null
 FREE RECORD reply
 RECORD reply(
   1 concept_cki = vc
   1 reference_json = gvc
   1 activity_json = gvc
   1 document_events
     2 json = vc
   1 term_decorations
     2 json = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 SUBROUTINE getlongtextvalues(null)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   CALL log_message("In getLongTextValues()",log_level_debug)
   DECLARE outbuf = vc WITH protect, noconstant(" ")
   DECLARE totlen = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM long_text_reference lt
    PLAN (lt
     WHERE lt.long_text_id=value( $EVENT_ID, $DECOR_ID)
      AND lt.active_ind=1)
    HEAD lt.long_text_id
     imagedatasize = blobgetlen(lt.long_text), stat = memrealloc(outbuf,1,build("C",imagedatasize)),
     totlen = blobget(outbuf,0,lt.long_text)
     CASE (lt.long_text_id)
      OF  $EVENT_ID:
       reply->document_events.json = notrim(outbuf)
      OF  $DECOR_ID:
       reply->term_decorations.json = notrim(outbuf)
     ENDCASE
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getLongTextValues(), Elapsed time:",((curtime3 - start_tm)/ 100.0)),
    log_level_debug)
 END ;Subroutine
 SUBROUTINE openstructuredsection(null)
   DECLARE entry_mode_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",29520,"WKFDOCCOMP"))
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   DECLARE i = i4 WITH private, noconstant(0)
   CALL log_message("In openStructuredSection()",log_level_debug)
   CALL initializesrvrequest(reply,969528)
   SET nsrvstat = uar_srvsetstring(hreq,"parent_entity_name",nullterm( $PARENT_ENT_NAME))
   SET nsrvstat = uar_srvsetdouble(hreq,"parent_entity_id",cnvtreal( $PARENT_ENT_ID))
   SET nsrvstat = uar_srvexecute(hmsg,hreq,hrep)
   SET hrep = validatesrvreply(nsrvstat,reply,0)
   IF (hrep != 0)
    CALL copysectionstruct(uar_srvgetstruct(hrep,"section_act"),0)
    DECLARE section_cnt = i4 WITH constant(uar_srvgetitemcount(hrep,"SECTION_REF")), private
    SET stat = alterlist(reference->section,section_cnt)
    FOR (i = 1 TO section_cnt)
      CALL copyrefsectionstruct(uar_srvgetitem(hrep,"SECTION_REF",(i - 1)),i,0)
    ENDFOR
    SET reply->reference_json = decodeinternationalcharacters(cnvtrectojson(reference,2))
    SET reply->activity_json = cnvtrectojson(activity,2)
   ENDIF
   CALL exit_srvrequest(happ,htask,hstep)
   CALL log_message(build("Exit openStructuredSection(), Elapsed time:",((curtime3 - start_tm)/ 100.0
     )),log_level_debug)
 END ;Subroutine
 SUBROUTINE main(null)
   DECLARE start_tm = dq8 WITH constant(curtime3), private
   CALL log_message("In Main()",log_level_debug)
   CALL openstructuredsection(null)
   CALL getlongtextvalues(null)
   SET stat = cnvtjsontorec(reply->reference_json)
   IF (validate(reference))
    SELECT INTO "nl:"
     FROM dd_sref_section dss
     PLAN (dss
      WHERE (dss.dd_sref_section_id=reference->section[1].dd_sref_section_id))
     HEAD REPORT
      reply->concept_cki = dss.concept_cki
     WITH nocounter
    ;end select
   ENDIF
   CALL log_message(build("Exit main(), Elapsed time:",((curtime3 - start_tm)/ 100.0)),
    log_level_debug)
 END ;Subroutine
 SET reply->status_data.status = "F"
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 CALL main(null)
 SET reply->status_data.status = "S"
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Elapsed time in seconds:",((curtime3 - script_start_tm)/ 100.0)),
  log_level_debug)
 CALL putjsonrecordtofile(reply)
END GO
