CREATE PROGRAM cp_retrieve_pathway_trail_data:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Pathway ID" = 0.0,
  "Pathway Instance ID" = 0.0,
  "Person ID" = 0.0,
  "Encounter ID" = 0.0
  WITH outdev, pathway_id, instance_id,
  person_id, encounter_id
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
 DECLARE instance_id = f8 WITH constant(cnvtreal( $INSTANCE_ID)), protect
 DECLARE person_id = f8 WITH constant(cnvtreal( $PERSON_ID)), protect
 DECLARE encounter_id = f8 WITH constant(cnvtreal( $ENCOUNTER_ID)), protect
 DECLARE prsnl_id = f8 WITH constant(reqinfo->updt_id), protect
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE save_doc_act_det_mean = vc WITH constant("SAVEDOC"), protect
 DECLARE trail_json_act_det_mean = vc WITH constant("TRAILJSON"), protect
 DECLARE doccontent_comp_det_reltn_cd = f8 WITH constant(uar_get_code_by("MEANING",4003134,
   "DOCCONTENT")), protect
 DECLARE action_cnt = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE ppr_cd = f8 WITH noconstant(getpprcode(person_id,encounter_id,prsnl_id)), protect
 DECLARE main(null) = null
 DECLARE getsessions(null) = null
 DECLARE getsessionactions(null) = null
 DECLARE getsessionactiondetails(null) = null
 DECLARE buildsessionsignedorders(null) = null
 DECLARE addversionnbrforsavedoc(null) = null
 DECLARE seteventidstatus(null) = null
 IF ( NOT (validate(raw_data)))
  RECORD raw_data(
    1 action_cnt = i4
    1 actions[*]
      2 encntr_id = f8
      2 node_id = f8
      2 node_display = vc
      2 cp_component_id = f8
      2 action_id = f8
      2 action_mean = vc
      2 action_dt_tm = dq8
      2 action_prsnl_id = f8
      2 action_prsnl_name = vc
      2 action_detail_id = f8
      2 action_detail_status_mean = vc
      2 action_detail_prsnl_id = f8
      2 action_detail_prsnl_name = vc
      2 action_detail_dt_tm = dq8
      2 action_detail_entity_id = f8
      2 action_detail_entity_id_status = vc
      2 action_detail_entity_name = vc
      2 action_detail_entity_mean = vc
      2 action_detail_entity_value = vc
      2 trigger_in_error_action_ind = i2
      2 action_detail_text = vc
      2 version_nbr = i2
  )
 ENDIF
 FREE RECORD temp_event_details
 RECORD temp_event_details(
   1 event_ids[*]
     2 event_id = f8
 )
 FREE RECORD signed_orders
 RECORD signed_orders(
   1 action_cnt = i4
   1 actions[*]
     2 encntr_id = f8
     2 node_id = f8
     2 node_display = vc
     2 cp_component_id = f8
     2 action_id = f8
     2 action_mean = vc
     2 action_dt_tm = dq8
     2 action_prsnl_id = f8
     2 action_prsnl_name = vc
     2 action_detail_id = f8
     2 action_detail_status_mean = vc
     2 action_detail_prsnl_id = f8
     2 action_detail_prsnl_name = vc
     2 action_detail_dt_tm = dq8
     2 action_detail_entity_id = f8
     2 action_detail_entity_id_status = vc
     2 action_detail_entity_name = vc
     2 action_detail_entity_mean = vc
     2 action_detail_entity_value = vc
     2 trigger_in_error_action_ind = i2
     2 action_detail_text = vc
     2 version_nbr = i2
 )
 FREE RECORD selected_orders
 RECORD selected_orders(
   1 action_cnt = i4
   1 actions[*]
     2 encntr_id = f8
     2 node_id = f8
     2 node_display = vc
     2 cp_component_id = f8
     2 action_id = f8
     2 action_mean = vc
     2 action_dt_tm = dq8
     2 action_prsnl_id = f8
     2 action_prsnl_name = vc
     2 action_detail_id = f8
     2 action_detail_status_mean = vc
     2 action_detail_prsnl_id = f8
     2 action_detail_prsnl_name = vc
     2 action_detail_dt_tm = dq8
     2 action_detail_entity_id = f8
     2 action_detail_entity_id_status = vc
     2 action_detail_entity_name = vc
     2 action_detail_entity_mean = vc
     2 action_detail_entity_value = vc
     2 trigger_in_error_action_ind = i2
     2 action_detail_text = vc
     2 version_nbr = i2
 )
 FREE RECORD ce_request
 RECORD ce_request(
   1 event_id = f8
   1 query_mode = i4
   1 subtable_bit_map_ind = i2
   1 valid_from_dt_tm_ind = i2
   1 valid_from_dt_tm = dq8
 ) WITH protect
 FREE RECORD ce_record
 RECORD ce_record(
   1 rb_list[*]
     2 clinical_event_id = f8
     2 event_id = f8
     2 reference_nbr = vc
     2 valid_until_dt_tm = dq8
     2 clinsig_updt_dt_tm = dq8
     2 view_level = i4
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_cd_disp = vc
     2 series_ref_nbr = vc
     2 person_id = f8
     2 encntr_id = f8
     2 parent_event_id = f8
     2 valid_from_dt_tm = dq8
     2 event_class_cd = f8
     2 event_cd = f8
     2 event_cd_disp = vc
     2 event_title_text = vc
     2 event_start_dt_tm = dq8
     2 event_end_dt_tm = dq8
     2 result_status_cd = f8
     2 result_status_cd_disp = vc
     2 publish_flag = i2
     2 normalcy_cd = f8
     2 normalcy_cd_disp = vc
     2 normalcy_cd_mean = vc
     2 collating_seq = vc
     2 result_val = vc
     2 result_units_cd = f8
     2 result_units_cd_disp = vc
     2 verified_dt_tm = dq8
     2 verified_prsnl_id = f8
     2 performed_dt_tm = dq8
     2 performed_prsnl_id = f8
     2 normal_low = vc
     2 normal_high = vc
     2 critical_low = vc
     2 critical_high = vc
     2 updt_dt_tm = dq8
     2 contributor_system_cd = f8
     2 contributor_system_cd_disp = vc
     2 accession_nbr = vc
     2 resource_cd = f8
     2 resource_cd_disp = vc
     2 normal_ref_range_txt = vc
     2 blob_result[*]
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_until_dt_tm = dq8
       3 max_sequence_nbr = i4
       3 format_cd = f8
       3 blob[*]
         4 blob_length = i4
         4 compression_cd = f8
         4 blob_contents = gvc
         4 blob_text = vc
     2 child_event_list[*]
       3 clinical_event_id = f8
       3 event_id = f8
       3 valid_until_dt_tm = dq8
       3 clinsig_updt_dt_tm = dq8
       3 view_level = i4
       3 parent_event_id = f8
       3 valid_from_dt_tm = dq8
       3 event_class_cd = f8
       3 event_class_cd_disp = vc
       3 event_cd = f8
       3 event_cd_disp = vc
       3 event_title_text = vc
       3 event_tag = vc
       3 event_start_dt_tm = dq8
       3 event_end_dt_tm = dq8
       3 result_val = vc
       3 result_units_cd = f8
       3 result_units_cd_disp = vc
       3 result_status_cd = f8
       3 result_status_cd_disp = vc
       3 publish_flag = i2
       3 collating_seq = vc
       3 verified_dt_tm = dq8
       3 verified_prsnl_id = f8
       3 updt_dt_tm = dq8
       3 blob_result[*]
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 max_sequence_nbr = i4
         4 format_cd = f8
         4 blob[*]
           5 blob_length = i4
           5 compression_cd = f8
           5 blob_contents = gvc
           5 blob_text = vc
         4 blob_handle = vc
       3 date_result[*]
         4 event_id = f8
         4 result_dt_tm = dq8
       3 event_note_list[*]
         4 ce_event_note_id = f8
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 event_note_id = f8
         4 event_id = f8
         4 note_type_cd = f8
         4 note_type_cd_disp = vc
         4 note_type_cd_mean = vc
         4 note_format_cd = f8
         4 note_format_cd_disp = vc
         4 note_format_cd_mean = vc
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 entry_method_cd = f8
         4 entry_method_cd_disp = vc
         4 entry_method_cd_mean = vc
         4 note_prsnl_id = f8
         4 note_dt_tm = dq8
         4 note_dt_tm_ind = i2
         4 record_status_cd = f8
         4 record_status_cd_disp = vc
         4 record_status_cd_mean = vc
         4 compression_cd = f8
         4 compression_cd_disp = vc
         4 compression_cd_mean = vc
         4 checksum = i4
         4 checksum_ind = i2
         4 long_blob = gvc
         4 long_blob_txt = vc
         4 long_blob_length = i4
         4 long_text = vc
         4 long_text_id = f8
         4 non_chartable_flag = i2
         4 importance_flag = i2
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_id = f8
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
         4 note_tz = i4
       3 security_label_list[*]
         4 clinical_event_sec_lbl_id = f8
         4 event_id = f8
         4 sensitivity_reason_cd = f8
         4 sensitivity_reason_cd_disp = vc
         4 created_by_prsnl_id = f8
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
         4 action_prsnl_id = f8
         4 updt_id = f8
         4 updt_dt_tm = dq8
         4 updt_task = i4
         4 updt_applctx = i4
         4 updt_cnt = i4
       3 child_event_list[*]
         4 clinical_event_id = f8
         4 event_id = f8
         4 valid_until_dt_tm = dq8
         4 clinsig_updt_dt_tm = dq8
         4 view_level = i4
         4 parent_event_id = f8
         4 valid_from_dt_tm = dq8
         4 event_class_cd = f8
         4 event_class_cd_disp = vc
         4 event_cd = f8
         4 event_cd_disp = vc
         4 event_title_text = vc
         4 event_start_dt_tm = dq8
         4 event_end_dt_tm = dq8
         4 result_val = vc
         4 result_units_cd = f8
         4 result_units_cd_disp = vc
         4 result_status_cd = f8
         4 result_status_cd_disp = vc
         4 publish_flag = i2
         4 collating_seq = vc
         4 verified_dt_tm = dq8
         4 verified_prsnl_id = f8
         4 updt_dt_tm = dq8
         4 blob_result[*]
           5 event_id = f8
           5 valid_from_dt_tm = dq8
           5 valid_until_dt_tm = dq8
           5 max_sequence_nbr = i4
           5 format_cd = f8
           5 blob[*]
             6 blob_length = i4
             6 compression_cd = f8
             6 blob_contents = gvc
             6 blob_text = vc
           5 blob_summary[*]
             6 ce_blob_summary_id = f8
             6 blob_summary_id = f8
             6 long_blob = gvc
         4 date_result[*]
           5 event_id = f8
           5 result_dt_tm = dq8
         4 event_note_list[*]
           5 ce_event_note_id = f8
           5 valid_until_dt_tm = dq8
           5 valid_until_dt_tm_ind = i2
           5 event_note_id = f8
           5 event_id = f8
           5 note_type_cd = f8
           5 note_type_cd_disp = vc
           5 note_type_cd_mean = vc
           5 note_format_cd = f8
           5 note_format_cd_disp = vc
           5 note_format_cd_mean = vc
           5 valid_from_dt_tm = dq8
           5 valid_from_dt_tm_ind = i2
           5 entry_method_cd = f8
           5 entry_method_cd_disp = vc
           5 entry_method_cd_mean = vc
           5 note_prsnl_id = f8
           5 note_dt_tm = dq8
           5 note_dt_tm_ind = i2
           5 record_status_cd = f8
           5 record_status_cd_disp = vc
           5 record_status_cd_mean = vc
           5 compression_cd = f8
           5 compression_cd_disp = vc
           5 compression_cd_mean = vc
           5 checksum = i4
           5 checksum_ind = i2
           5 long_blob = gvc
           5 long_blob_txt = vc
           5 long_blob_length = i4
           5 long_text = vc
           5 long_text_id = f8
           5 non_chartable_flag = i2
           5 importance_flag = i2
           5 updt_dt_tm = dq8
           5 updt_dt_tm_ind = i2
           5 updt_id = f8
           5 updt_task = i4
           5 updt_task_ind = i2
           5 updt_cnt = i4
           5 updt_cnt_ind = i2
           5 updt_applctx = i4
           5 updt_applctx_ind = i2
           5 note_tz = i4
         4 security_label_list[*]
           5 clinical_event_sec_lbl_id = f8
           5 event_id = f8
           5 sensitivity_reason_cd = f8
           5 sensitivity_reason_cd_disp = vc
           5 created_by_prsnl_id = f8
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 active_ind = i2
           5 action_prsnl_id = f8
           5 updt_id = f8
           5 updt_dt_tm = dq8
           5 updt_task = i4
           5 updt_applctx = i4
           5 updt_cnt = i4
         4 child_event_list[*]
           5 clinical_event_id = f8
           5 event_id = f8
           5 parent_event_id = f8
           5 event_class_cd = f8
           5 event_class_cd_disp = vc
           5 event_cd = f8
           5 event_cd_disp = vc
           5 event_title_text = vc
           5 event_start_dt_tm = dq8
           5 event_end_dt_tm = dq8
           5 result_val = vc
           5 result_units_cd = f8
           5 result_units_cd_disp = vc
           5 result_status_cd = f8
           5 result_status_cd_disp = vc
           5 collating_seq = vc
           5 date_result[*]
             6 event_id = f8
             6 result_dt_tm = dq8
           5 event_note_list[*]
             6 event_note_id = f8
           5 security_label_list[*]
             6 clinical_event_sec_lbl_id = f8
             6 event_id = f8
             6 sensitivity_reason_cd = f8
             6 sensitivity_reason_cd_disp = vc
             6 created_by_prsnl_id = f8
             6 beg_effective_dt_tm = dq8
             6 end_effective_dt_tm = dq8
             6 active_ind = i2
             6 action_prsnl_id = f8
             6 updt_id = f8
             6 updt_dt_tm = dq8
             6 updt_task = i4
             6 updt_applctx = i4
             6 updt_cnt = i4
           5 child_event_list[*]
             6 clinical_event_id = f8
             6 event_id = f8
             6 parent_event_id = f8
             6 event_class_cd = f8
             6 event_class_cd_disp = vc
             6 event_cd = f8
             6 event_cd_disp = vc
             6 event_title_text = vc
             6 event_start_dt_tm = dq8
             6 event_end_dt_tm = dq8
             6 result_val = vc
             6 result_units_cd = f8
             6 result_units_cd_disp = vc
             6 result_status_cd = f8
             6 result_status_cd_disp = vc
             6 collating_seq = vc
             6 date_result[*]
               7 event_id = f8
               7 result_dt_tm = dq8
             6 event_note_list[*]
               7 event_note_id = f8
             6 security_label_list[*]
               7 clinical_event_sec_lbl_id = f8
               7 event_id = f8
               7 sensitivity_reason_cd = f8
               7 sensitivity_reason_cd_disp = vc
               7 created_by_prsnl_id = f8
               7 beg_effective_dt_tm = dq8
               7 end_effective_dt_tm = dq8
               7 active_ind = i2
               7 action_prsnl_id = f8
               7 updt_id = f8
               7 updt_dt_tm = dq8
               7 updt_task = i4
               7 updt_applctx = i4
               7 updt_cnt = i4
       3 contributor_system_cd = f8
     2 event_note_list[*]
       3 ce_event_note_id = f8
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 event_note_id = f8
       3 event_id = f8
       3 note_type_cd = f8
       3 note_type_cd_disp = vc
       3 note_type_cd_mean = vc
       3 note_format_cd = f8
       3 note_format_cd_disp = vc
       3 note_format_cd_mean = vc
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 entry_method_cd = f8
       3 entry_method_cd_disp = vc
       3 entry_method_cd_mean = vc
       3 note_prsnl_id = f8
       3 note_dt_tm = dq8
       3 note_dt_tm_ind = i2
       3 record_status_cd = f8
       3 record_status_cd_disp = vc
       3 record_status_cd_mean = vc
       3 compression_cd = f8
       3 compression_cd_disp = vc
       3 compression_cd_mean = vc
       3 checksum = i4
       3 checksum_ind = i2
       3 long_blob = gvc
       3 long_blob_txt = vc
       3 long_blob_length = i4
       3 long_text = vc
       3 long_text_id = f8
       3 non_chartable_flag = i2
       3 importance_flag = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 note_tz = i4
     2 event_prsnl_list[*]
       3 ce_event_prsnl_id = f8
       3 event_prsnl_id = f8
       3 person_id = f8
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 action_type_cd = f8
       3 action_type_cd_disp = vc
       3 request_dt_tm = dq8
       3 request_dt_tm_ind = i2
       3 request_prsnl_id = f8
       3 request_prsnl_ft = vc
       3 request_comment = vc
       3 action_dt_tm = dq8
       3 action_dt_tm_ind = i2
       3 action_prsnl_id = f8
       3 action_prsnl_ft = vc
       3 proxy_prsnl_id = f8
       3 proxy_prsnl_ft = vc
       3 action_status_cd = f8
       3 action_status_cd_disp = vc
       3 action_comment = vc
       3 change_since_action_flag = i2
       3 change_since_action_flag_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 long_text_id = f8
       3 long_text = vc
       3 linked_event_id = f8
       3 request_tz = i4
       3 action_tz = i4
       3 system_comment = vc
       3 digital_signature_ident = vc
       3 action_prsnl_group_id = f8
       3 request_prsnl_group_id = f8
       3 receiving_person_id = f8
       3 receiving_person_ft = vc
     2 specimen_coll[*]
       3 event_id = f8
       3 specimen_id = f8
       3 collect_dt_tm = dq8
       3 source_type_cd = f8
       3 source_type_cd_disp = vc
       3 collect_loc_cd = f8
       3 collect_loc_cd_disp = vc
       3 recvd_dt_tm = dq8
       3 body_site_cd_disp = vc
     2 date_result[*]
       3 event_id = f8
       3 result_dt_tm = dq8
     2 microbiology_list[*]
       3 event_id = f8
       3 micro_seq_nbr = i4
       3 micro_seq_nbr_ind = i2
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 organism_cd = f8
       3 organism_cd_disp = vc
       3 organism_cd_desc = vc
       3 organism_cd_mean = vc
       3 organism_occurrence_nbr = i4
       3 organism_occurrence_nbr_ind = i2
       3 organism_type_cd = f8
       3 organism_type_cd_disp = vc
       3 organism_type_cd_mean = vc
       3 observation_prsnl_id = f8
       3 biotype = vc
       3 probability = f8
       3 positive_ind = i2
       3 positive_ind_ind = i2
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 susceptibility_list[*]
         4 event_id = f8
         4 micro_seq_nbr = i4
         4 micro_seq_nbr_ind = i2
         4 suscep_seq_nbr = i4
         4 suscep_seq_nbr_ind = i2
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 susceptibility_test_cd = f8
         4 susceptibility_test_cd_disp = vc
         4 susceptibility_test_cd_mean = vc
         4 detail_susceptibility_cd = f8
         4 detail_susceptibility_cd_disp = vc
         4 detail_susceptibility_cd_mean = vc
         4 panel_antibiotic_cd = f8
         4 panel_antibiotic_cd_disp = vc
         4 panel_antibiotic_cd_mean = vc
         4 antibiotic_cd = f8
         4 antibiotic_cd_disp = vc
         4 antibiotic_cd_desc = vc
         4 antibiotic_cd_mean = vc
         4 diluent_volume = f8
         4 diluent_volume_ind = i2
         4 result_cd = f8
         4 result_cd_disp = vc
         4 result_cd_mean = vc
         4 result_text_value = vc
         4 result_numeric_value = f8
         4 result_numeric_value_ind = i2
         4 result_unit_cd = f8
         4 result_unit_cd_disp = vc
         4 result_unit_cd_mean = vc
         4 result_dt_tm = dq8
         4 result_dt_tm_ind = i2
         4 result_prsnl_id = f8
         4 susceptibility_status_cd = f8
         4 susceptibility_status_cd_disp = vc
         4 susceptibility_status_cd_mean = vc
         4 abnormal_flag = i2
         4 abnormal_flag_ind = i2
         4 chartable_flag = i2
         4 chartable_flag_ind = i2
         4 nomenclature_id = f8
         4 antibiotic_note = vc
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_id = f8
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
         4 result_tz = i4
     2 suscep_footnote_r_list[*]
       3 event_id = f8
       3 valid_from_dt_tm = dq8
       3 valid_from_dt_tm_ind = i2
       3 valid_until_dt_tm = dq8
       3 valid_until_dt_tm_ind = i2
       3 micro_seq_nbr = i4
       3 micro_seq_nbr_ind = i2
       3 suscep_seq_nbr = i4
       3 suscep_seq_nbr_ind = i2
       3 suscep_footnote_id = f8
       3 updt_dt_tm = dq8
       3 updt_dt_tm_ind = i2
       3 updt_id = f8
       3 updt_task = i4
       3 updt_task_ind = i2
       3 updt_cnt = i4
       3 updt_cnt_ind = i2
       3 updt_applctx = i4
       3 updt_applctx_ind = i2
       3 suscep_footnote[*]
         4 event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_from_dt_tm_ind = i2
         4 valid_until_dt_tm = dq8
         4 valid_until_dt_tm_ind = i2
         4 ce_suscep_footnote_id = f8
         4 suscep_footnote_id = f8
         4 checksum = i4
         4 checksum_ind = i2
         4 compression_cd = f8
         4 format_cd = f8
         4 contributor_system_cd = f8
         4 blob_length = i4
         4 blob_length_ind = i2
         4 reference_nbr = vc
         4 long_blob = gvc
         4 long_text = vc
         4 updt_dt_tm = dq8
         4 updt_dt_tm_ind = i2
         4 updt_id = f8
         4 updt_task = i4
         4 updt_task_ind = i2
         4 updt_cnt = i4
         4 updt_cnt_ind = i2
         4 updt_applctx = i4
         4 updt_applctx_ind = i2
     2 security_label_list[*]
       3 clinical_event_sec_lbl_id = f8
       3 event_id = f8
       3 sensitivity_reason_cd = f8
       3 sensitivity_reason_cd_disp = vc
       3 created_by_prsnl_id = f8
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
       3 action_prsnl_id = f8
       3 updt_id = f8
       3 updt_dt_tm = dq8
       3 updt_task = i4
       3 updt_applctx = i4
       3 updt_cnt = i4
   1 prsnl[*]
     2 id = f8
     2 person_name_id = f8
     2 active_date = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 provider_name
       3 name_full = vc
       3 name_first = vc
       3 name_middle = vc
       3 name_last = vc
       3 username = vc
       3 initials = vc
       3 title = vc
   1 codes[*]
     2 sequence = i4
     2 code = f8
     2 code_set = f8
     2 display = vc
     2 description = vc
     2 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 IF ( NOT (validate(pathway_trail_data)))
  RECORD pathway_trail_data(
    1 action_cnt = i4
    1 actions[*]
      2 encntr_id = f8
      2 node_id = f8
      2 node_display = vc
      2 cp_component_id = f8
      2 action_id = f8
      2 action_mean = vc
      2 action_dt_tm = dq8
      2 action_prsnl_id = f8
      2 action_prsnl_name = vc
      2 action_detail_id = f8
      2 action_detail_status_mean = vc
      2 action_detail_prsnl_id = f8
      2 action_detail_prsnl_name = vc
      2 action_detail_dt_tm = dq8
      2 action_detail_entity_id = f8
      2 action_detail_entity_id_status = vc
      2 action_detail_entity_name = vc
      2 action_detail_entity_mean = vc
      2 action_detail_entity_value = vc
      2 trigger_in_error_action_ind = i2
      2 action_detail_text = vc
      2 version_nbr = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SUBROUTINE (getutcdttm(dq8dttm=dq8) =dq8)
   DECLARE utcdttm = dq8 WITH protect, noconstant(dq8dttm)
   IF (curutc)
    SET utcdttm = dq8dttm
   ELSE
    SET utcdttm = cnvtdatetimeutc(dq8dttm,3)
   ENDIF
   RETURN(utcdttm)
 END ;Subroutine
 SUBROUTINE (getpprcode(person_id=f8,encounter_id=f8,prsnl_id=f8) =f8)
   DECLARE dpprcode = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    ppr.person_prsnl_r_cd
    FROM person_prsnl_reltn ppr
    WHERE ppr.person_id=person_id
     AND ppr.prsnl_person_id=prsnl_id
     AND ppr.active_ind=1
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(cur_dt_tm)
     AND ppr.end_effective_dt_tm > cnvtdatetime(cur_dt_tm)
    DETAIL
     dpprcode = ppr.person_prsnl_r_cd
    WITH nocounter
   ;end select
   IF (dpprcode=0)
    SELECT INTO "nl:"
     epr.encntr_prsnl_r_cd
     FROM encntr_prsnl_reltn epr
     WHERE epr.encntr_id=encounter_id
      AND epr.prsnl_person_id=prsnl_id
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm <= cnvtdatetime(cur_dt_tm)
      AND epr.end_effective_dt_tm > cnvtdatetime(cur_dt_tm)
     DETAIL
      dpprcode = epr.encntr_prsnl_r_cd
     WITH nocounter
    ;end select
   ENDIF
   RETURN(dpprcode)
 END ;Subroutine
 SUBROUTINE getsessions(null)
   DECLARE start_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE void_cd = f8 WITH constant(uar_get_code_by("MEANING",4003352,"VOID"))
   SELECT INTO "nl:"
    FROM cp_pathway_activity cpa
    PLAN (cpa
     WHERE cpa.cp_pathway_id=cnvtreal( $PATHWAY_ID)
      AND cpa.pathway_instance_id=instance_id
      AND cpa.person_id=person_id
      AND cpa.pathway_activity_status_cd != void_cd)
    DETAIL
     action_cnt += 1
     IF (action_cnt > size(raw_data->actions,5))
      stat = alterlist(raw_data->actions,(action_cnt+ 10))
     ENDIF
     raw_data->actions[action_cnt].action_dt_tm = getutcdttm(cpa.beg_effective_dt_tm), raw_data->
     actions[action_cnt].action_detail_entity_name = "SESSION", raw_data->actions[action_cnt].
     action_detail_entity_value = uar_get_code_display(cpa.pathway_activity_status_cd),
     raw_data->actions[action_cnt].action_prsnl_id = cpa.prsnl_id, raw_data->actions[action_cnt].
     encntr_id = cpa.encntr_id
    FOOT REPORT
     raw_data->action_cnt = action_cnt, stat = alterlist(raw_data->actions,action_cnt)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getSessions(), Elapsed time in seconds:",((curtime3 - start_curtime3)
     / 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsessionactions(null)
   DECLARE start_curtime3 = dq8 WITH constant(curtime3), private
   SELECT INTO "nl:"
    FROM cp_pathway_action cpa,
     (left JOIN cp_pathway_action_detail cpad ON cpad.cp_pathway_action_id=cpa.cp_pathway_action_id),
     cp_node cn
    PLAN (cpa
     WHERE cpa.pathway_instance_id=instance_id)
     JOIN (cpad)
     JOIN (cn
     WHERE cn.cp_node_id=cpa.cp_node_id)
    DETAIL
     CASE (uar_get_code_meaning(cpad.cp_action_detail_type_cd))
      OF "ORDSELECT":
       CALL addsessionactionfromtable(selected_orders)
      OF "SIGNACT":
       CALL addsessionactionfromtable(signed_orders)
      ELSE
       CALL addsessionactionfromtable(raw_data)
     ENDCASE
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getSessionActions(), Elapsed time in seconds:",((curtime3 -
     start_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addsessionactionfromtable(actionsrecord=vc(ref)) =null)
   DECLARE start_curtime3 = dq8 WITH constant(curtime3), private
   SET actionsrecord->action_cnt += 1
   SET stat = alterlist(actionsrecord->actions,actionsrecord->action_cnt)
   SET actionsrecord->actions[actionsrecord->action_cnt].encntr_id = cpa.encntr_id
   SET actionsrecord->actions[actionsrecord->action_cnt].node_id = cn.cp_node_id
   SET actionsrecord->actions[actionsrecord->action_cnt].node_display = cn.node_display
   SET actionsrecord->actions[actionsrecord->action_cnt].cp_component_id = cpa.cp_component_id
   SET actionsrecord->actions[actionsrecord->action_cnt].action_id = cpa.cp_pathway_action_id
   SET actionsrecord->actions[actionsrecord->action_cnt].action_mean = uar_get_code_meaning(cpa
    .action_type_cd)
   SET actionsrecord->actions[actionsrecord->action_cnt].action_dt_tm = getutcdttm(cpa.action_dt_tm)
   SET actionsrecord->actions[actionsrecord->action_cnt].action_prsnl_id = cpa.prsnl_id
   SET actionsrecord->actions[actionsrecord->action_cnt].action_detail_id = cpad
   .cp_pathway_action_detail_id
   SET actionsrecord->actions[actionsrecord->action_cnt].action_detail_status_mean =
   uar_get_code_meaning(cpad.action_detail_status_cd)
   SET actionsrecord->actions[actionsrecord->action_cnt].action_detail_prsnl_id = cpad.updt_id
   SET actionsrecord->actions[actionsrecord->action_cnt].action_detail_dt_tm = getutcdttm(cpad
    .updt_dt_tm)
   SET actionsrecord->actions[actionsrecord->action_cnt].action_detail_entity_id = cpad
   .action_detail_entity_id
   SET actionsrecord->actions[actionsrecord->action_cnt].action_detail_entity_mean =
   uar_get_code_meaning(cpad.cp_action_detail_type_cd)
   SET actionsrecord->actions[actionsrecord->action_cnt].action_detail_entity_name = cpad
   .action_detail_entity_name
   SET actionsrecord->actions[actionsrecord->action_cnt].action_detail_text = cpad.action_detail_text
   CALL log_message(build("Exit addSessionActionFromTable(), Elapsed time in seconds:",((curtime3 -
     start_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addversionnbrforsavedoc(null)
   DECLARE start_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE actcntr = i4 WITH noconstant(0), protect
   DECLARE searchcntr = i4 WITH noconstant(0), protect
   DECLARE actindx = i4 WITH noconstant(0), protect
   DECLARE compdetindx = i4 WITH noconstant(0), protect
   DECLARE trailjsonactindx = i4 WITH noconstant(0), protect
   DECLARE act_list_size = i4 WITH constant(size(raw_data->actions,5)), protect
   DECLARE mapcntr = i4 WITH noconstant(0), protect
   DECLARE mapindx = i4 WITH noconstant(0), protect
   FREE RECORD comp_detail_version_map
   RECORD comp_detail_version_map(
     1 cnt = i4
     1 qual[*]
       2 cp_component_id = f8
       2 comp_detail_ident = vc
       2 comp_detail_version_nbr = i4
   )
   SELECT INTO "nl:"
    FROM cp_component_detail ccd
    PLAN (ccd
     WHERE expand(actcntr,1,act_list_size,save_doc_act_det_mean,raw_data->actions[actcntr].
      action_detail_entity_mean,
      ccd.cp_component_id,raw_data->actions[actcntr].cp_component_id)
      AND ccd.component_detail_reltn_cd=doccontent_comp_det_reltn_cd)
    ORDER BY ccd.cp_component_detail_id
    DETAIL
     comp_detail_version_map->cnt += 1, stat = alterlist(comp_detail_version_map->qual,
      comp_detail_version_map->cnt), comp_detail_version_map->qual[comp_detail_version_map->cnt].
     comp_detail_ident = ccd.component_ident,
     comp_detail_version_map->qual[comp_detail_version_map->cnt].cp_component_id = ccd
     .cp_component_id, comp_detail_version_map->qual[comp_detail_version_map->cnt].
     comp_detail_version_nbr = ccd.version_nbr
    WITH expand = 1
   ;end select
   SELECT INTO "nl:"
    FROM dd_sdoc_section dd,
     dd_sdoc_sect_templ_reltn ddstr
    PLAN (dd
     WHERE expand(actcntr,1,act_list_size,save_doc_act_det_mean,raw_data->actions[actcntr].
      action_detail_entity_mean,
      dd.parent_entity_id,raw_data->actions[actcntr].action_detail_entity_id))
     JOIN (ddstr
     WHERE ddstr.dd_sdoc_section_id=dd.dd_sdoc_section_id)
    ORDER BY dd.parent_entity_id, ddstr.dd_sref_templ_instance_ident
    HEAD dd.parent_entity_id
     actindx = locateval(searchcntr,1,act_list_size,save_doc_act_det_mean,raw_data->actions[
      searchcntr].action_detail_entity_mean,
      dd.parent_entity_id,raw_data->actions[searchcntr].action_detail_entity_id)
    HEAD ddstr.dd_sref_templ_instance_ident
     compdetindx = locateval(searchcntr,1,comp_detail_version_map->cnt,raw_data->actions[actindx].
      cp_component_id,comp_detail_version_map->qual[searchcntr].cp_component_id,
      ddstr.dd_sref_templ_instance_ident,comp_detail_version_map->qual[searchcntr].comp_detail_ident)
     IF (compdetindx > 0)
      raw_data->actions[actindx].version_nbr = comp_detail_version_map->qual[compdetindx].
      comp_detail_version_nbr
     ENDIF
     trailjsonactindx = locateval(searchcntr,1,act_list_size,raw_data->actions[actindx].action_id,
      raw_data->actions[searchcntr].action_id,
      trail_json_act_det_mean,raw_data->actions[searchcntr].action_detail_entity_mean)
     IF (trailjsonactindx > 0)
      raw_data->actions[trailjsonactindx].version_nbr = raw_data->actions[actindx].version_nbr
     ENDIF
    WITH expand = 1
   ;end select
   IF (validate(debug_ind,0))
    CALL echorecord(comp_detail_version_map)
   ENDIF
   CALL log_message(build("Exit addVersionNbrForSaveDoc(), Elapsed time in seconds:",((curtime3 -
     start_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getsessionactiondetails(null)
   DECLARE start_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE pos = i4 WITH noconstant(0), protect
   DECLARE outbuf = vc WITH protect, noconstant(" ")
   DECLARE totlen = i4 WITH protect, noconstant(0)
   DECLARE textsize = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     cp_node cn
    PLAN (d1
     WHERE (raw_data->action_cnt > 0)
      AND (raw_data->actions[d1.seq].action_detail_entity_name="CP_NODE"))
     JOIN (cn
     WHERE (cn.cp_node_id=raw_data->actions[d1.seq].action_detail_entity_id))
    DETAIL
     raw_data->actions[d1.seq].action_detail_entity_value = cn.node_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     long_text lt
    PLAN (d1
     WHERE (raw_data->action_cnt > 0)
      AND (raw_data->actions[d1.seq].action_detail_entity_name="LONG_TEXT"))
     JOIN (lt
     WHERE (lt.long_text_id=raw_data->actions[d1.seq].action_detail_entity_id))
    DETAIL
     textsize = blobgetlen(lt.long_text), stat = memrealloc(outbuf,1,build("C",textsize)), totlen =
     blobget(outbuf,0,lt.long_text),
     raw_data->actions[d1.seq].action_detail_entity_value = notrim(outbuf)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     order_catalog_synonym ocs
    PLAN (d1
     WHERE (raw_data->action_cnt > 0)
      AND (raw_data->actions[d1.seq].action_detail_entity_name="ORDER_CATALOG_SYNONYM"))
     JOIN (ocs
     WHERE (ocs.synonym_id=raw_data->actions[d1.seq].action_detail_entity_id))
    DETAIL
     IF ((raw_data->actions[d1.seq].action_detail_text > " "))
      raw_data->actions[d1.seq].action_detail_entity_value = build(ocs.mnemonic," (",raw_data->
       actions[d1.seq].action_detail_text,")")
     ELSE
      raw_data->actions[d1.seq].action_detail_entity_value = ocs.mnemonic
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     regimen_catalog rc
    PLAN (d1
     WHERE (raw_data->action_cnt > 0)
      AND (raw_data->actions[d1.seq].action_detail_entity_name="REGIMEN_CATALOG"))
     JOIN (rc
     WHERE (rc.regimen_catalog_id=raw_data->actions[d1.seq].action_detail_entity_id))
    DETAIL
     raw_data->actions[d1.seq].action_detail_entity_value = rc.regimen_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     pathway_catalog pc
    PLAN (d1
     WHERE (raw_data->action_cnt > 0)
      AND (raw_data->actions[d1.seq].action_detail_entity_name="PATHWAY_CATALOG"))
     JOIN (pc
     WHERE (pc.pathway_catalog_id=raw_data->actions[d1.seq].action_detail_entity_id))
    DETAIL
     raw_data->actions[d1.seq].action_detail_entity_value = pc.description
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     pathway_customized_plan pc
    PLAN (d1
     WHERE (raw_data->action_cnt > 0)
      AND (raw_data->actions[d1.seq].action_detail_entity_name="PATHWAY_CUSTOMIZED_PLAN"))
     JOIN (pc
     WHERE (pc.pathway_customized_plan_id=raw_data->actions[d1.seq].action_detail_entity_id))
    DETAIL
     raw_data->actions[d1.seq].action_detail_entity_value = pc.plan_name
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     code_value cv
    PLAN (d1
     WHERE (raw_data->action_cnt > 0)
      AND (raw_data->actions[d1.seq].action_detail_entity_name="CODE_VALUE"))
     JOIN (cv
     WHERE (cv.code_value=raw_data->actions[d1.seq].action_detail_entity_id))
    DETAIL
     raw_data->actions[d1.seq].action_detail_entity_value = cv.display
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     order_sentence os,
     order_catalog_synonym ocs
    PLAN (d1
     WHERE (raw_data->action_cnt > 0)
      AND (raw_data->actions[d1.seq].action_detail_entity_name="ORDER_SENTENCE"))
     JOIN (os
     WHERE (os.order_sentence_id=raw_data->actions[d1.seq].action_detail_entity_id))
     JOIN (ocs
     WHERE ocs.synonym_id=os.parent_entity_id
      AND os.parent_entity_name="ORDER_CATALOG_SYNONYM")
    DETAIL
     IF ((raw_data->actions[d1.seq].action_detail_text > " "))
      raw_data->actions[d1.seq].action_detail_entity_value = build(ocs.mnemonic," (",raw_data->
       actions[d1.seq].action_detail_text,")")
     ELSE
      raw_data->actions[d1.seq].action_detail_entity_value = ocs.mnemonic
     ENDIF
    WITH nocounter
   ;end select
   CALL log_message(build("Exit getSessionActionDetails(), Elapsed time in seconds:",((curtime3 -
     start_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE buildsessionsignedorders(null)
   DECLARE start_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE o_cntr = i4 WITH noconstant(0), protect
   DECLARE o_idx = i4 WITH noconstant(0), protect
   DECLARE s_idx = i4 WITH noconstant(0), protect
   DECLARE search_cntr = i4 WITH noconstant(0), protect
   IF (validate(debug_ind,0))
    CALL echorecord(selected_orders)
    CALL echorecord(signed_orders)
   ENDIF
   SELECT INTO "nl:"
    FROM orders o
    PLAN (o
     WHERE expand(o_cntr,1,signed_orders->action_cnt,"ORDERS",signed_orders->actions[o_cntr].
      action_detail_entity_name,
      o.order_id,signed_orders->actions[o_cntr].action_detail_entity_id))
    ORDER BY o.order_id
    HEAD o.order_id
     FOR (o_idx = 1 TO signed_orders->action_cnt)
       IF ((signed_orders->actions[o_idx].action_detail_entity_name="ORDERS")
        AND (signed_orders->actions[o_idx].action_detail_entity_id=o.order_id))
        IF (o.pathway_catalog_id=0)
         s_idx = locateval(search_cntr,1,selected_orders->action_cnt,signed_orders->actions[o_idx].
          action_id,selected_orders->actions[search_cntr].action_id,
          "ORDER_CATALOG_SYNONYM",selected_orders->actions[search_cntr].action_detail_entity_name,o
          .synonym_id,selected_orders->actions[search_cntr].action_detail_entity_id)
         IF (s_idx > 0)
          raw_data->action_cnt += 1, stat = alterlist(raw_data->actions,raw_data->action_cnt), stat
           = movereclist(selected_orders->actions,raw_data->actions,s_idx,raw_data->action_cnt,1,
           false),
          raw_data->actions[raw_data->action_cnt].action_detail_text = signed_orders->actions[o_idx].
          action_detail_text
         ENDIF
        ENDIF
       ENDIF
     ENDFOR
    WITH expand = 1
   ;end select
   IF (validate(debug_ind,0))
    CALL echorecord(raw_data)
   ENDIF
   CALL log_message(build("Exit buildSessionSignedOrders(), Elapsed time in seconds:",((curtime3 -
     start_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (buildsessionsignedplans(customind=i2) =null)
   DECLARE start_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE search_cntr = i4 WITH noconstant(0), protect
   SELECT
    IF (customind=1)
     FROM (dummyt d1  WITH seq = selected_orders->action_cnt),
      cp_pathway_action_detail cpad,
      cp_pathway_action cpa,
      pathway_customized_plan pcp,
      pathway p,
      dummyt d2
     PLAN (d1
      WHERE (selected_orders->actions[d1.seq].action_detail_entity_name="PATHWAY_CUSTOMIZED_PLAN"))
      JOIN (cpad
      WHERE (cpad.cp_pathway_action_detail_id=selected_orders->actions[d1.seq].action_detail_id))
      JOIN (cpa
      WHERE cpa.cp_pathway_action_id=cpad.cp_pathway_action_id)
      JOIN (pcp
      WHERE pcp.pathway_customized_plan_id=cpad.action_detail_entity_id)
      JOIN (p
      WHERE p.pathway_catalog_id=pcp.pathway_catalog_id
       AND p.started_ind=1)
      JOIN (d2
      WHERE p.order_dt_tm BETWEEN cnvtlookbehind("30,S",cpa.action_dt_tm) AND cnvtlookahead("30,S",
       cpa.action_dt_tm))
    ELSE
     FROM (dummyt d1  WITH seq = selected_orders->action_cnt),
      cp_pathway_action_detail cpad,
      cp_pathway_action cpa,
      pathway p,
      dummyt d2
     PLAN (d1
      WHERE (selected_orders->actions[d1.seq].action_detail_entity_name="PATHWAY_CATALOG"))
      JOIN (cpad
      WHERE (cpad.cp_pathway_action_detail_id=selected_orders->actions[d1.seq].action_detail_id))
      JOIN (cpa
      WHERE cpa.cp_pathway_action_id=cpad.cp_pathway_action_id)
      JOIN (p
      WHERE p.pw_cat_group_id=cpad.action_detail_entity_id
       AND p.started_ind=1)
      JOIN (d2
      WHERE p.order_dt_tm BETWEEN cnvtlookbehind("30,S",cpa.action_dt_tm) AND cnvtlookahead("30,S",
       cpa.action_dt_tm))
    ENDIF
    ORDER BY p.pathway_id
    HEAD p.pathway_id
     IF (validate(debug_ind,0))
      CALL echo("Found plan"),
      CALL echo(build("  p.order_dt_tm -- > ",format(p.order_dt_tm,"@SHORTDATETIME"))),
      CALL echo(build("  cpa.action_dt_tm -- > ",format(cpa.action_dt_tm,"@SHORTDATETIME"))),
      CALL echo(build("  cpad.updt_dt_tm -- > ",format(cpad.updt_dt_tm,"@SHORTDATETIME"))),
      CALL echo(build(" cnvtdatetime(selected_orders->actions[d1.seq].action_detail_dt_tm -- > ",
       format(cnvtdatetime(selected_orders->actions[d1.seq].action_detail_dt_tm),"@SHORTDATETIME")))
     ENDIF
     IF (((p.pathway_customized_plan_id=0
      AND locateval(search_cntr,1,raw_data->action_cnt,selected_orders->actions[d1.seq].action_id,
      raw_data->actions[search_cntr].action_id,
      selected_orders->actions[d1.seq].action_detail_entity_id,raw_data->actions[search_cntr].
      action_detail_entity_id,selected_orders->actions[d1.seq].action_detail_entity_mean,raw_data->
      actions[search_cntr].action_detail_entity_mean)=0) OR (p.pathway_customized_plan_id > 0
      AND locateval(search_cntr,1,raw_data->action_cnt,selected_orders->actions[d1.seq].action_id,
      raw_data->actions[search_cntr].action_id,
      p.pathway_customized_plan_id,raw_data->actions[search_cntr].action_detail_entity_id,
      "PATHWAY_CUSTOMIZED_PLAN",raw_data->actions[search_cntr].action_detail_entity_name,
      selected_orders->actions[d1.seq].action_detail_entity_mean,
      raw_data->actions[search_cntr].action_detail_entity_mean)=0)) )
      raw_data->action_cnt += 1, stat = alterlist(raw_data->actions,raw_data->action_cnt), stat =
      movereclist(selected_orders->actions,raw_data->actions,d1.seq,raw_data->action_cnt,1,
       false)
      IF (p.pathway_customized_plan_id > 0)
       raw_data->actions[raw_data->action_cnt].action_detail_entity_name = "PATHWAY_CUSTOMIZED_PLAN",
       raw_data->actions[raw_data->action_cnt].action_detail_entity_id = p.pathway_customized_plan_id
      ENDIF
      raw_data->actions[raw_data->action_cnt].action_detail_text = p.description
     ENDIF
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0))
    CALL echorecord(raw_data)
   ENDIF
   CALL log_message(build("Exit buildSessionSignedPlans(), Elapsed time in seconds:",((curtime3 -
     start_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getprsnlname(null)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt),
     prsnl p
    PLAN (d1
     WHERE (raw_data->action_cnt > 0))
     JOIN (p
     WHERE (((p.person_id=raw_data->actions[d1.seq].action_prsnl_id)) OR ((p.person_id=raw_data->
     actions[d1.seq].action_detail_prsnl_id))) )
    DETAIL
     IF ((p.person_id=raw_data->actions[d1.seq].action_prsnl_id))
      raw_data->actions[d1.seq].action_prsnl_name = p.name_full_formatted
     ENDIF
     IF ((p.person_id=raw_data->actions[d1.seq].action_detail_prsnl_id))
      raw_data->actions[d1.seq].action_detail_prsnl_name = p.name_full_formatted
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE seteventidstatus(null)
   DECLARE query_mode = f8 WITH protect, constant(336551937)
   DECLARE eventcntr = i4 WITH noconstant(0), protect
   DECLARE actionidx = i4 WITH noconstant(0), protect
   DECLARE searchcntr = i4 WITH noconstant(0), protect
   FOR (eventcntr = 1 TO size(temp_event_details->event_ids,5))
     SET cur_event_id = temp_event_details->event_ids[eventcntr].event_id
     SET stat = initrec(ce_request)
     SET ce_request->event_id = cur_event_id
     SET ce_request->query_mode = query_mode
     SET ce_request->subtable_bit_map_ind = 1
     SET ce_request->valid_from_dt_tm_ind = 1
     EXECUTE mp_event_detail_query  WITH replace("REQUEST","CE_REQUEST"), replace("REPLY","CE_RECORD"
      )
     IF (size(ce_record->rb_list,5) > 0)
      SET actionidx = locateval(searchcntr,1,size(pathway_trail_data->actions,5),cur_event_id,
       pathway_trail_data->actions[searchcntr].action_detail_entity_id)
      SET pathway_trail_data->actions[actionidx].action_detail_entity_id_status = uar_get_displaykey(
       ce_record->rb_list[1].result_status_cd)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE sortdata(null)
   DECLARE searchcntr = i4 WITH noconstant(0), protect
   DECLARE eventcnt = i4 WITH noconstant(0), protect
   SET pathway_trail_data->action_cnt = raw_data->action_cnt
   SET stat = alterlist(pathway_trail_data->actions,raw_data->action_cnt)
   SET idx = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = raw_data->action_cnt)
    PLAN (d1
     WHERE (raw_data->action_cnt > 0))
    ORDER BY raw_data->actions[d1.seq].action_dt_tm DESC
    DETAIL
     idx += 1, pathway_trail_data->actions[idx].encntr_id = raw_data->actions[d1.seq].encntr_id,
     pathway_trail_data->actions[idx].node_id = raw_data->actions[d1.seq].node_id,
     pathway_trail_data->actions[idx].node_display = raw_data->actions[d1.seq].node_display,
     pathway_trail_data->actions[idx].cp_component_id = raw_data->actions[d1.seq].cp_component_id,
     pathway_trail_data->actions[idx].action_id = raw_data->actions[d1.seq].action_id,
     pathway_trail_data->actions[idx].action_mean = raw_data->actions[d1.seq].action_mean,
     pathway_trail_data->actions[idx].action_dt_tm = raw_data->actions[d1.seq].action_dt_tm,
     pathway_trail_data->actions[idx].action_prsnl_name = raw_data->actions[d1.seq].action_prsnl_name,
     pathway_trail_data->actions[idx].action_detail_id = raw_data->actions[d1.seq].action_detail_id,
     pathway_trail_data->actions[idx].action_detail_status_mean = raw_data->actions[d1.seq].
     action_detail_status_mean, pathway_trail_data->actions[idx].action_detail_prsnl_name = raw_data
     ->actions[d1.seq].action_detail_prsnl_name,
     pathway_trail_data->actions[idx].action_detail_dt_tm = raw_data->actions[d1.seq].
     action_detail_dt_tm, pathway_trail_data->actions[idx].action_detail_entity_id = raw_data->
     actions[d1.seq].action_detail_entity_id, pathway_trail_data->actions[idx].
     action_detail_entity_name = raw_data->actions[d1.seq].action_detail_entity_name,
     pathway_trail_data->actions[idx].action_detail_entity_mean = raw_data->actions[d1.seq].
     action_detail_entity_mean, pathway_trail_data->actions[idx].action_detail_entity_value =
     raw_data->actions[d1.seq].action_detail_entity_value, pathway_trail_data->actions[idx].
     action_detail_text = raw_data->actions[d1.seq].action_detail_text,
     pathway_trail_data->actions[idx].version_nbr = raw_data->actions[d1.seq].version_nbr
     IF ((raw_data->actions[d1.seq].action_detail_entity_mean="SIGNEVENT")
      AND locateval(searchcntr,1,size(temp_event_details->event_ids,5),raw_data->actions[d1.seq].
      action_detail_entity_id,temp_event_details->event_ids[searchcntr].event_id)=0)
      eventcnt += 1, stat = alterlist(temp_event_details->event_ids,eventcnt), temp_event_details->
      event_ids[eventcnt].event_id = raw_data->actions[d1.seq].action_detail_entity_id
     ENDIF
     IF (idx=1
      AND (((pathway_trail_data->actions[idx].action_detail_entity_mean=save_doc_act_det_mean)) OR ((
     pathway_trail_data->actions[idx].action_detail_entity_mean=trail_json_act_det_mean))) )
      pathway_trail_data->actions[idx].trigger_in_error_action_ind = 1
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE main(null)
  CALL getsessions(null)
  IF ((raw_data->action_cnt > 0))
   CALL getsessionactions(null)
   CALL addversionnbrforsavedoc(null)
   CALL buildsessionsignedorders(null)
   CALL buildsessionsignedplans(1)
   CALL buildsessionsignedplans(0)
   CALL getsessionactiondetails(null)
   CALL getprsnlname(null)
   CALL sortdata(null)
   CALL seteventidstatus(null)
  ELSE
   SET pathway_trail_data->status_data.status = "Z"
   GO TO exit_script
  ENDIF
 END ;Subroutine
 CALL log_message(build("Starting Script:",log_program_name),log_level_debug)
 SET pathway_trail_data->status_data.status = "F"
 CALL main(null)
 SET pathway_trail_data->status_data.status = "S"
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - script_start_curtime3)/ 100.0)),
  log_level_debug)
 IF (( $OUTDEV != "NOFORMS"))
  CALL putjsonrecordtofile(pathway_trail_data)
 ENDIF
END GO
