CREATE PROGRAM cp_get_trmnt_opts:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Id" = 0.0,
  "Encounter ID" = 0.0,
  "Personnel ID" = 0.0,
  "PPR CD" = 0.0,
  "Alt sel cat Ids" = 0.0,
  "Viewable Encounters" = 0.0,
  "CP Node Id" = 0.0,
  "Instance Identifier" = ""
  WITH outdev, person_id, encntr_id,
  prsnl_id, ppr_cd, alt_sel_cat_ids,
  viewable_encntrs, cp_node_id, instance_ident
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
 DECLARE getvenuetypelistflex(p1=i2(val),p2=i2(val),p1=vc(ref)) = null WITH protect
 SUBROUTINE (getencntrinfo(encntr_id=f8(val),encntr_rec=vc(ref)) =null WITH protect)
   CALL log_message("In GetEncntrInfo()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE cs_order_encntr_group = f8 WITH protect, constant(29100.0)
   DECLARE enc_class_type_validated = i2 WITH protect, constant(validate(encntr_rec->
     encntr_class_type_cd))
   DECLARE encntr_class_type_code = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE e.encntr_id=encntr_id
    DETAIL
     encntr_rec->encntr_type_cd = e.encntr_type_cd, encntr_rec->facility_cd = e.loc_facility_cd,
     encntr_class_type_code = e.encntr_type_class_cd
    WITH nocounter
   ;end select
   IF (enc_class_type_validated)
    SET encntr_rec->encntr_class_type_cd = encntr_class_type_code
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_group cvg,
     code_value cv,
     code_value_extension cve
    PLAN (cvg
     WHERE (cvg.child_code_value=encntr_rec->encntr_type_cd))
     JOIN (cv
     WHERE cv.code_value=cvg.parent_code_value
      AND cv.code_set=cs_order_encntr_group
      AND cv.active_ind=1)
     JOIN (cve
     WHERE cve.code_value=cv.code_value)
    HEAD REPORT
     encntr_rec->order_encntr_group_cd = cv.code_value, encntr_rec->encntr_venue_type = cnvtint(cve
      .field_value)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetEncntrInfo(), Elapsed time in seconds:",((curtime3 - begin_time)/
     100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (getpowerordersprefs(iselvenuetype=i2(val),iencvenuetype=i2(val),prefinforec=vc(ref)) =
  null WITH protect)
   CALL log_message("In GetPowerOrdersPrefs()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE virt_view_ind = i4 WITH constant(0), protect
   DECLARE fav_folders_ind = i4 WITH constant(1), protect
   DECLARE cust_powerplan_ind = i4 WITH constant(2), protect
   DECLARE fav_sort_ind = i4 WITH constant(3), protect
   DECLARE future_new_ord_ind = i4 WITH constant(4), protect
   DECLARE dsch_new_ord_ind = i4 WITH constant(5), protect
   DECLARE default_venue_ind = i4 WITH constant(6), protect
   DECLARE prefcnt = i4 WITH protect, noconstant(0)
   DECLARE prefmask = i4 WITH protect, noconstant(prefinforec->prefinfomask)
   DECLARE ord_comp_ven_outpat = i2 WITH protect, constant(2)
   DECLARE dpositioncd = f8 WITH protect, noconstant(reqinfo->position_cd)
   DECLARE duserid = f8 WITH protect, noconstant(reqinfo->updt_id)
   DECLARE application_num = i4 WITH protect, constant(reqinfo->updt_app)
   DECLARE brxorderspreffound = i2 WITH protect, noconstant(0)
   DECLARE borderspreffound = i2 WITH protect, noconstant(0)
   DECLARE str = vc WITH protect, noconstant("")
   DECLARE notfnd = vc WITH protect, constant("<not_found>")
   DECLARE num = i4 WITH protect, noconstant(1)
   DECLARE pvc_str = vc WITH protect, noconstant("")
   DECLARE pref_not_configured = i2 WITH protect, constant(0)
   DECLARE pref_allow = i2 WITH protect, constant(1)
   DECLARE pref_reject = i2 WITH protect, constant(2)
   DECLARE pref_warn = i2 WITH protect, constant(3)
   FREE RECORD pvc_name_rec
   RECORD pvc_name_rec(
     1 pvc_cnt = i4
     1 pvc_list[*]
       2 pvc_name = vc
   ) WITH protect
   SET stat = alterlist(pvc_name_rec->pvc_list,10)
   IF (btest(prefmask,virt_view_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "VIRTUAL_ORDER_CATALOG"
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "RX_VIRTUAL_ORDER_CATALOG"
   ENDIF
   IF (btest(prefmask,fav_folders_ind))
    SET prefcnt += 1
    IF (iencvenuetype=ord_comp_ven_outpat)
     IF (iselvenuetype=1)
      SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "AMBINOFFICE_CATALOG_BROWSER_HOME"
     ELSE
      SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "AMBUL_CATALOG_BROWSER_HOME"
     ENDIF
     SET prefcnt += 1
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "AMBUL_CATALOG_BROWSER_ROOT"
     SET prefcnt += 1
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "AMBINOFFICE_CATALOG_BROWSER_ROOT"
    ELSE
     IF (iselvenuetype=1)
      SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "INPT_CATALOG_BROWSER_HOME"
     ELSE
      SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DSCHMEDS_CATALOG_BROWSER_HOME"
     ENDIF
     SET prefcnt += 1
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "INPT_CATALOG_BROWSER_ROOT"
     SET prefcnt += 1
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DSCHMEDS_CATALOG_BROWSER_ROOT"
    ENDIF
   ENDIF
   IF (btest(prefmask,cust_powerplan_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "PLAN_FAVORITES"
   ENDIF
   IF (btest(prefmask,fav_sort_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "FAVORITES_SORT"
   ENDIF
   IF (btest(prefmask,future_new_ord_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "FUTURE_NEW_ORDER"
   ENDIF
   IF (btest(prefmask,dsch_new_ord_ind))
    SET prefcnt += 1
    SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DSCH_NEW_ORDER"
   ENDIF
   IF (btest(prefmask,default_venue_ind))
    SET prefcnt += 1
    IF (iencvenuetype=ord_comp_ven_outpat)
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DEFAULT_OUTPATIENT_VENUE"
    ELSE
     SET pvc_name_rec->pvc_list[prefcnt].pvc_name = "DEFAULT_INPATIENT_VENUE"
    ENDIF
   ENDIF
   SET stat = alterlist(pvc_name_rec->pvc_list,prefcnt)
   SET pvc_name_rec->pvc_cnt = prefcnt
   SELECT INTO "nl:"
    FROM app_prefs ap,
     name_value_prefs nv
    PLAN (ap
     WHERE ap.prsnl_id IN (0.0, duserid)
      AND ap.position_cd IN (0.0, dpositioncd)
      AND ap.application_number=application_num)
     JOIN (nv
     WHERE nv.parent_entity_id=ap.app_prefs_id
      AND nv.parent_entity_name="APP_PREFS"
      AND expand(num,1,pvc_name_rec->pvc_cnt,nv.pvc_name,pvc_name_rec->pvc_list[num].pvc_name)
      AND nv.active_ind > 0)
    ORDER BY nv.pvc_name, ap.prsnl_id DESC, ap.position_cd DESC
    HEAD nv.pvc_name
     str = "0.0", num = 1
     CASE (trim(cnvtupper(nv.pvc_name)))
      OF "INPT_CATALOG_BROWSER_ROOT":
      OF "AMBINOFFICE_CATALOG_BROWSER_ROOT":
       pvc_str = evaluate(findstring(";",nv.pvc_value),0,build(nv.pvc_value,";"),nv.pvc_value),
       WHILE (str != notfnd)
         str = piece(pvc_str,";",num,notfnd)
         IF (isnumeric(str) > 0)
          prefinforec->inpat_fav_cnt += 1, stat = alterlist(prefinforec->inpat_fav,prefinforec->
           inpat_fav_cnt), prefinforec->inpat_fav[prefinforec->inpat_fav_cnt].value = cnvtreal(str)
         ENDIF
         num += 1
       ENDWHILE
      OF "DSCHMEDS_CATALOG_BROWSER_ROOT":
      OF "AMBUL_CATALOG_BROWSER_ROOT":
       pvc_str = evaluate(findstring(";",nv.pvc_value),0,build(nv.pvc_value,";"),nv.pvc_value),
       WHILE (str != notfnd)
         str = piece(pvc_str,";",num,notfnd)
         IF (isnumeric(str) > 0)
          prefinforec->rx_fav_cnt += 1, stat = alterlist(prefinforec->rx_fav,prefinforec->rx_fav_cnt),
          prefinforec->rx_fav[prefinforec->rx_fav_cnt].value = cnvtreal(str)
         ENDIF
         num += 1
       ENDWHILE
      OF "INPT_CATALOG_BROWSER_HOME":
      OF "DSCHMEDS_CATALOG_BROWSER_HOME":
      OF "AMBINOFFICE_CATALOG_BROWSER_HOME":
      OF "AMBUL_CATALOG_BROWSER_HOME":
       pvc_str = evaluate(findstring(";",nv.pvc_value),0,build(nv.pvc_value,";"),nv.pvc_value),
       WHILE (str != notfnd)
         str = piece(pvc_str,";",num,notfnd)
         IF (isnumeric(str) > 0)
          prefinforec->home_fav_cnt += 1, stat = alterlist(prefinforec->home_fav,prefinforec->
           home_fav_cnt), prefinforec->home_fav[prefinforec->home_fav_cnt].value = cnvtreal(str)
         ENDIF
         num += 1
       ENDWHILE
      OF "RX_VIRTUAL_ORDER_CATALOG":
       IF (brxorderspreffound=0
        AND trim(nv.pvc_value,3)="PTFAC/VORC")
        prefinforec->filterrxordersflag = 1, brxorderspreffound = 1
       ELSEIF (brxorderspreffound=0)
        prefinforec->filterrxordersflag = 0, brxorderspreffound = 1
       ENDIF
      OF "VIRTUAL_ORDER_CATALOG":
       IF (borderspreffound=0
        AND trim(nv.pvc_value,3)="PTFAC/VORC")
        prefinforec->filterordersflag = 1, borderspreffound = 1
       ELSEIF (borderspreffound=0)
        prefinforec->filterordersflag = 0, borderspreffound = 1
       ENDIF
      OF "PLAN_FAVORITES":
       IF (trim(nv.pvc_value,3)="1")
        prefinforec->allowplanfavs = 1
       ENDIF
      OF "FAVORITES_SORT":
       IF (trim(nv.pvc_value,3)="1")
        prefinforec->favssort = 1
       ENDIF
      OF "FUTURE_NEW_ORDER":
       IF (trim(nv.pvc_value,3)="ALLOW")
        prefinforec->futureneworderpref = pref_allow
       ELSEIF (trim(nv.pvc_value,3)="REJECT")
        prefinforec->futureneworderpref = pref_reject
       ELSEIF (trim(nv.pvc_value,3)="WARN")
        prefinforec->futureneworderpref = pref_warn
       ENDIF
      OF "DSCH_NEW_ORDER":
       IF (findstring("ALLOW",nv.pvc_value,1,0)=1)
        prefinforec->dischneworderpref = pref_allow
       ELSEIF (findstring("REJECT",nv.pvc_value,1,0)=1)
        prefinforec->dischneworderpref = pref_reject
       ELSEIF (findstring("WARN",nv.pvc_value,1,0)=1)
        prefinforec->dischneworderpref = pref_warn
       ENDIF
      OF "DEFAULT_OUTPATIENT_VENUE":
      OF "DEFAULT_INPATIENT_VENUE":
       prefinforec->default_venue_val = cnvtreal(nv.pvc_value)
     ENDCASE
    WITH nocounter
   ;end select
   IF (validate(debug_ind)=1)
    CALL echorecord(prefinforec)
   ENDIF
   CALL log_message(build("Exit GetPowerOrdersPrefs(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getvenuetypelistflex(iencvenuetype,bdischneworderpref,venuetyperec,venuepref)
   CALL log_message("In GetVenueTypeListFlex()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE ord_comp_ven_outpat = i2 WITH protect, constant(2)
   DECLARE cs_54732 = i4 WITH constant(54732), protect
   DECLARE cv_54732_ambuloffice = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"AMBULOFFICE")),
   private
   DECLARE cv_54732_ambulatory = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"AMBULATORY")),
   private
   DECLARE cv_54732_inpatient = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"INPATIENT")),
   private
   DECLARE cv_54732_dischargemed = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"DISCHARGEMED"
     )), private
   DECLARE cv_54732_docmedbyhx = f8 WITH constant(uar_get_code_by("MEANING",cs_54732,"DOCMEDBYHX")),
   private
   DECLARE out_orders_rx = i2 WITH constant(2), private
   DECLARE out_orders_meds = i2 WITH constant(3), private
   DECLARE in_orders_med = i2 WITH constant(1), private
   DECLARE in_discharge_meds_rx = i2 WITH constant(2), private
   DECLARE vtidx = i4 WITH noconstant(0), private
   DECLARE vtidx2 = i4 WITH noconstant(0), private
   DECLARE venuedefault = i4 WITH noconstant(0), private
   IF (iencvenuetype=ord_comp_ven_outpat)
    SET venuedefault = evaluate2(
     IF (venuepref=2) out_orders_rx
     ELSEIF (venuepref=4) out_orders_meds
     ELSE 0
     ENDIF
     )
    IF (bdischneworderpref=2)
     SET stat = alterlist(venuetyperec->venue_type_list,1)
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_ambulatory)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 2
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
    ELSE
     SET stat = alterlist(venuetyperec->venue_type_list,2)
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_ambuloffice)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 3
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_ambulatory)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 2
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
    ENDIF
   ELSE
    SET venuedefault = evaluate2(
     IF (venuepref=1) in_orders_med
     ELSEIF (venuepref=8) in_discharge_meds_rx
     ELSE 0
     ENDIF
     )
    IF (bdischneworderpref=2)
     SET stat = alterlist(venuetyperec->venue_type_list,1)
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_dischargemed)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 2
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
    ELSE
     SET stat = alterlist(venuetyperec->venue_type_list,2)
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_dischargemed)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 2
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
     SET vtidx += 1
     SET venuetyperec->venue_type_list[vtidx].display = uar_get_code_display(cv_54732_inpatient)
     SET vtidx2 = 1
     SET stat = alterlist(venuetyperec->venue_type_list[vtidx].source_component_list,vtidx2)
     SET venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value = 1
     IF ((venuetyperec->venue_type_list[vtidx].source_component_list[vtidx2].value=venuedefault))
      SET venuetyperec->venue_type_list[vtidx].default_ind = 1
     ENDIF
    ENDIF
   ENDIF
   IF (validate(debug_ind)=1)
    CALL echorecord(venuetyperec)
   ENDIF
   CALL log_message(build("Exit GetVenueTypeListFlex(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrievefeaturetoggle(togglename=vc) =i2 WITH protect)
   CALL log_message("In RetrieveFeatureToggle()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   FREE RECORD featuretogglerequest
   RECORD featuretogglerequest(
     1 togglename = vc
     1 username = vc
     1 positioncd = f8
     1 systemidentifier = vc
     1 solutionname = vc
   ) WITH protect
   FREE RECORD featuretogglereply
   RECORD featuretogglereply(
     1 togglename = vc
     1 isenabled = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET featuretogglerequest->togglename = togglename
   IF (checkprg("SYS_CHECK_FEATURE_TOGGLE") > 0)
    EXECUTE sys_check_feature_toggle  WITH replace("REQUEST",featuretogglerequest), replace("REPLY",
     featuretogglereply)
    IF ((featuretogglereply->status_data.status="S"))
     RETURN(featuretogglereply->isenabled)
    ELSE
     CALL log_message("Failed to get feature toggles",log_level_debug)
    ENDIF
   ELSE
    CALL log_message("Failed to get feature toggles - Feature toggle script unavailable.",
     log_level_debug)
   ENDIF
   RETURN(0)
   CALL log_message(build("Exit RetrieveFeatureToggle(),Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 EXECUTE prefrtl
 DECLARE str_len = i4 WITH protect, constant(255)
 DECLARE hpref = i4 WITH protect, noconstant(0)
 DECLARE pref_rec_initiated_ind = i2 WITH protect, noconstant(0)
 DECLARE initprefrequest(null) = null WITH protect
 DECLARE addprefqual(null) = i4 WITH protect
 IF (validate(prefrequest)=0)
  RECORD prefrequest(
    1 pref_qual[*]
      2 uid = vc
      2 context_cnt = i4
      2 contexts[*]
        3 context = vc
        3 context_id = vc
      2 section = vc
      2 section_id = vc
      2 group_cnt = i4
      2 groups[*]
        3 group = vc
      2 pref_name = vc
  )
 ENDIF
 IF (validate(prefreply)=0)
  RECORD prefreply(
    1 pref_qual_cnt = i4
    1 pref_qual[*]
      2 uid = vc
      2 values[*]
        3 value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SUBROUTINE initprefrequest(null)
   IF (pref_rec_initiated_ind=0)
    SET pref_rec_initiated_ind = initrec(prefrequest)
    SET stat = initrec(prefreply)
   ENDIF
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    SET prefreply->status_data.status = "F"
    SET prefreply->status_data.subeventstatus[1].targetobjectname = "MP_GET_PREF_MANAGER_PREFS"
    SET prefreply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to create pref instance."
   ENDIF
 END ;Subroutine
 SUBROUTINE addprefqual(null)
   IF (pref_rec_initiated_ind=0)
    SET pref_rec_initiated_ind = initrec(prefrequest)
    SET stat = initrec(prefreply)
   ENDIF
   DECLARE prefcnt = i4 WITH protect, noconstant(size(prefrequest->pref_qual,5))
   SET prefcnt += 1
   SET stat = alterlist(prefrequest->pref_qual,prefcnt)
   RETURN(prefcnt)
 END ;Subroutine
 SUBROUTINE (addcontext(prefqualidx=i4,context=vc,contextid=vc) =null WITH protect)
   DECLARE contextcnt = i4 WITH protect, noconstant(size(prefrequest->pref_qual[prefqualidx].contexts,
     5))
   DECLARE dcontextfloat = f8 WITH protect, noconstant(0.0)
   SET contextcnt += 1
   SET stat = alterlist(prefrequest->pref_qual[prefqualidx].contexts,contextcnt)
   SET prefrequest->pref_qual[prefqualidx].contexts[contextcnt].context = context
   SET dcontextfloat = cnvtreal(contextid)
   IF (contextid="0.0")
    SET prefrequest->pref_qual[prefqualidx].contexts[contextcnt].context_id = "0.00"
   ELSEIF (dcontextfloat > 0.0)
    SET prefrequest->pref_qual[prefqualidx].contexts[contextcnt].context_id = trim(format(
      dcontextfloat,"##############.##;;f"),3)
   ELSE
    SET prefrequest->pref_qual[prefqualidx].contexts[contextcnt].context_id = contextid
   ENDIF
   SET prefrequest->pref_qual[prefqualidx].context_cnt = contextcnt
 END ;Subroutine
 SUBROUTINE (setsectiondata(prefqualidx=i4,section=vc,sectionid=vc) =null WITH protect)
  SET prefrequest->pref_qual[prefqualidx].section = section
  SET prefrequest->pref_qual[prefqualidx].section_id = sectionid
 END ;Subroutine
 SUBROUTINE (addgroup(prefqualidx=i4,groupname=vc) =null WITH protect)
   DECLARE groupcnt = i4 WITH protect, noconstant(size(prefrequest->pref_qual[prefqualidx].groups,5))
   SET groupcnt += 1
   SET stat = alterlist(prefrequest->pref_qual[prefqualidx].groups,groupcnt)
   SET prefrequest->pref_qual[prefqualidx].groups[groupcnt].group = groupname
   SET prefrequest->pref_qual[prefqualidx].group_cnt = groupcnt
 END ;Subroutine
 SUBROUTINE (setprefname(prefqualidx=i4,prefname=vc) =null WITH protect)
   SET prefrequest->pref_qual[prefqualidx].pref_name = prefname
 END ;Subroutine
 SUBROUTINE (retrievepreferences(continueonfail=i2) =null WITH protect)
   DECLARE i = i4 WITH protect, noconstant(0)
   DECLARE lprefindx = i4 WITH protect, noconstant(0)
   DECLARE nstat = i2 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE entrycnt = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE len = i4 WITH protect, noconstant(str_len)
   DECLARE entryname = c255 WITH protect, noconstant("")
   DECLARE attrcnt = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE attrname = c255 WITH protect, noconstant("")
   DECLARE valcnt = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE value = c1024 WITH protect, noconstant("")
   DECLARE hrepgroup = i4 WITH protect, noconstant(0)
   DECLARE subgroupcnt = i4 WITH protect, noconstant(0)
   DECLARE subgroupname = c255 WITH protect, noconstant("")
   DECLARE preflen = i4 WITH protect, noconstant(1024)
   IF (validate(debug_ind)=1)
    CALL echorecord(prefrequest)
   ENDIF
   DECLARE prefcnt = i4 WITH protect, constant(size(prefrequest->pref_qual,5))
   SET stat = alterlist(prefreply->pref_qual,prefcnt)
   FOR (lprefindx = 1 TO size(prefrequest->pref_qual,5))
     FOR (i = 1 TO size(prefrequest->pref_qual[lprefindx].contexts,5))
      SET nstat = uar_prefaddcontext(hpref,value(prefrequest->pref_qual[lprefindx].contexts[i].
        context),value(prefrequest->pref_qual[lprefindx].contexts[i].context_id))
      IF (validate(debug_ind)=1)
       CALL echo(build2("uar_PrefAddContext: ",nstat))
       CALL echo(build2("Added context: ",value(prefrequest->pref_qual[lprefindx].contexts[i].context
          )," with context_id: ",value(prefrequest->pref_qual[lprefindx].contexts[i].context_id)))
      ENDIF
     ENDFOR
     SET nstat = uar_prefsetsection(hpref,value(prefrequest->pref_qual[lprefindx].section))
     SET hgroup = uar_prefcreategroup()
     SET nstat = uar_prefsetgroupname(hgroup,value(prefrequest->pref_qual[lprefindx].section_id))
     RECORD reqgroups(
       1 handles[*]
         2 handle = i4
     )
     SET stat = alterlist(reqgroups->handles,(size(prefrequest->pref_qual[lprefindx].groups,5)+ 1))
     SET reqgroups->handles[1].handle = hgroup
     SET hsubgroup = hgroup
     FOR (i = 1 TO size(prefrequest->pref_qual[lprefindx].groups,5))
      SET hsubgroup = uar_prefaddsubgroup(hsubgroup,value(prefrequest->pref_qual[lprefindx].groups[i]
        .group))
      SET reqgroups->handles[(i+ 1)].handle = hsubgroup
     ENDFOR
     IF (validate(debug_ind)=1)
      CALL echorecord(reqgroups)
     ENDIF
     SET nstat = uar_prefaddgroup(hpref,hgroup)
     SET nstat = uar_prefperform(hpref)
     IF (nstat <= 0)
      SET prefreply->status_data.status = "F"
      SET prefreply->status_data.subeventstatus[1].targetobjectname = "MP_GET_PREF_MANAGER_PREFS"
      SET prefreply->status_data.subeventstatus[1].targetobjectvalue = "Failed to run pref query."
      FOR (i = 1 TO size(reqgroups->handles,5))
        IF ((reqgroups->handles[i].handle > 0))
         CALL uar_prefdestroygroup(reqgroups->handles[i].handle)
        ENDIF
      ENDFOR
      CALL uar_prefdestroyinstance(hpref)
      IF (continueonfail=1)
       RETURN(null)
      ENDIF
      GO TO exit_script
     ENDIF
     SET hsection = uar_prefgetsectionbyname(hpref,value(prefrequest->pref_qual[lprefindx].section))
     IF (validate(debug_ind)=1)
      CALL echo(build2("uar_PrefGetSectionByName: ",hsection," ",prefrequest->pref_qual[lprefindx].
        section))
     ENDIF
     SET hrepgroup = uar_prefgetgroupbyname(hsection,value(prefrequest->pref_qual[lprefindx].
       section_id))
     IF (validate(debug_ind)=1)
      CALL echo(build2("uar_PrefGetGroupByName: ",hrepgroup," ",prefrequest->pref_qual[lprefindx].
        section_id))
     ENDIF
     RECORD repgroups(
       1 handles[*]
         2 handle = i4
     )
     SET stat = alterlist(repgroups->handles,prefrequest->pref_qual[lprefindx].group_cnt)
     SET hsubgroup = hrepgroup
     FOR (i = 1 TO prefrequest->pref_qual[lprefindx].group_cnt)
       IF (hsubgroup=0)
        SET prefreply->status_data.status = "F"
        SET prefreply->status_data.subeventstatus[1].targetobjectname = "ORM_GET_PREFMGR_PREF"
        SET prefreply->status_data.subeventstatus[1].targetobjectvalue =
        "Failed to reach pref directory."
        GO TO exit_script
       ENDIF
       SET hsubgroup = uar_prefgetsubgroup(hsubgroup,0)
       SET repgroups->handles[i].handle = hsubgroup
     ENDFOR
     IF (validate(debug_ind)=1)
      CALL echorecord(repgroups)
     ENDIF
     IF (validate(debug_ind)=1)
      SET len = str_len
      SET subgroupname = fillstring(value(len)," ")
      SET stat = uar_prefgetgroupname(hsubgroup,subgroupname,len)
      CALL echo(build2("uar_PrefGetSubGroup: ",trim(subgroupname,3)))
     ENDIF
     SET nstat = uar_prefgetgroupentrycount(hsubgroup,entrycnt)
     IF (validate(debug_ind)=1)
      CALL echo(build2("entryCnt: ",entrycnt))
     ENDIF
     FOR (idxentry = 0 TO (entrycnt - 1))
       SET hentry = uar_prefgetgroupentry(hsubgroup,idxentry)
       SET len = str_len
       SET entryname = fillstring(value(len)," ")
       SET nstat = uar_prefgetentryname(hentry,entryname,len)
       SET entryname = trim(entryname,3)
       IF ((entryname=prefrequest->pref_qual[lprefindx].pref_name))
        IF (validate(debug_ind)=1)
         CALL echo(build2("entryName: ",entryname))
        ENDIF
        SET nstat = uar_prefgetentryattrcount(hentry,attrcnt)
        FOR (idxattr = 0 TO (attrcnt - 1))
          SET hattr = uar_prefgetentryattr(hentry,idxattr)
          SET len = str_len
          SET attrname = fillstring(value(len)," ")
          SET nstat = uar_prefgetattrname(hattr,attrname,len)
          IF (attrname="prefvalue")
           IF (validate(debug_ind)=1)
            CALL echo(build2("attrName: ",attrname))
           ENDIF
           SET nstat = uar_prefgetattrvalcount(hattr,valcnt)
           SET nstat = alterlist(prefreply->pref_qual[lprefindx].values,valcnt)
           FOR (idxval = 0 TO (valcnt - 1))
             SET preflen = 1024
             SET value = fillstring(value(preflen)," ")
             SET nstat = uar_prefgetattrval(hattr,value,preflen,idxval)
             SET value = trim(value,3)
             IF (validate(debug_ind)=1)
              CALL echo(build2("attrValue: ",value))
             ENDIF
             SET prefreply->pref_qual[lprefindx].values[(idxval+ 1)].value = value
           ENDFOR
          ENDIF
          IF (hattr > 0)
           CALL uar_prefdestroyattr(hattr)
          ENDIF
        ENDFOR
       ENDIF
       IF (hentry > 0)
        CALL uar_prefdestroyentry(hentry)
       ENDIF
     ENDFOR
     IF (hrepgroup > 0)
      CALL uar_prefdestroygroup(hrepgroup)
     ENDIF
     FOR (i = 1 TO size(reqgroups->handles,5))
       IF ((reqgroups->handles[i].handle > 0))
        CALL uar_prefdestroygroup(reqgroups->handles[i].handle)
       ENDIF
     ENDFOR
     FOR (i = 1 TO size(repgroups->handles,5))
       IF ((repgroups->handles[i].handle > 0))
        CALL uar_prefdestroygroup(repgroups->handles[i].handle)
       ENDIF
     ENDFOR
     CALL uar_prefdestroysection(hsection)
   ENDFOR
   IF (validate(debug_ind)=1)
    CALL echorecord(prefreply)
   ENDIF
   CALL uar_prefdestroyinstance(hpref)
   SET pref_rec_initiated_ind = 0
 END ;Subroutine
 SUBROUTINE getpreferencevaluecount(prefqualidx)
   RETURN(size(prefreply->pref_qual[prefqualidx].values,5))
 END ;Subroutine
 SUBROUTINE (getpreferencevalue(prefqualidx=i4,valueidx=i4) =vc WITH protect)
   IF (prefqualidx <= size(prefreply->pref_qual,5))
    RETURN(prefreply->pref_qual[prefqualidx].values[valueidx].value)
   ELSE
    RETURN(- (1))
   ENDIF
 END ;Subroutine
 DECLARE script_start_curtime3 = dq8 WITH constant(curtime3), private
 DECLARE look_back_dt_tm = dq8 WITH constant(cnvtlookbehind("2,Y",cnvtdatetime(sysdate))), protect
 DECLARE bisoutpatientencounter = i2 WITH protect, noconstant(0)
 DECLARE bfilterprodlevelflag = i2 WITH protect, noconstant(0)
 DECLARE customizedplancnt = i4 WITH protect, noconstant(0)
 DECLARE input_person_id = f8 WITH protect, constant(cnvtreal( $PERSON_ID))
 DECLARE input_encntr_id = f8 WITH protect, constant(cnvtreal( $ENCNTR_ID))
 DECLARE input_prsnl_id = f8 WITH protect, constant(cnvtreal( $PRSNL_ID))
 DECLARE input_ppr_cd = f8 WITH protect, constant(cnvtreal( $PPR_CD))
 DECLARE input_cp_node_id = f8 WITH protect, constant(cnvtreal( $CP_NODE_ID))
 DECLARE ord_cat_cd_pharmacy = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE y_mnemonic_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICPROD")
  )
 DECLARE n_mnemonic_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADETOP"))
 DECLARE m_mnemonic_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICTOP"))
 DECLARE z_mnemonic_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADEPROD"))
 DECLARE pharmacy_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE ord_comp_ven_outpat = i2 WITH protect, constant(2)
 DECLARE normal0 = i4 WITH protect, constant(0)
 DECLARE normal1 = i4 WITH protect, constant(1)
 DECLARE supergroup = i4 WITH protect, constant(2)
 DECLARE careplan = i4 WITH protect, constant(3)
 DECLARE orderset = i4 WITH protect, constant(6)
 DECLARE multi_ingredient = i4 WITH protect, constant(8)
 DECLARE interval_test = i4 WITH protect, constant(9)
 DECLARE freetext = i4 WITH protect, constant(10)
 DECLARE tpn = i4 WITH protect, constant(11)
 SET curalias treatment_reply_child treatment_reply->parent[parentindex].child[childindex]
 IF ( NOT (validate(_memory_reply_string)))
  DECLARE _memory_reply_string = vc WITH noconstant(""), protect
 ENDIF
 IF ( NOT (validate(treatment_reply)))
  RECORD treatment_reply(
    1 person_id = f8
    1 encntr_id = f8
    1 cbt_mean = vc
    1 intention_mean = vc
    1 parent[*]
      2 category_id = f8
      2 description = vc
      2 hide_ind = i2
      2 hide_reason = vc
      2 open_ind = i2
      2 open_reason = vc
      2 recommend_ind = i2
      2 recommend_reason = vc
      2 child[*]
        3 sequence = i4
        3 list_type = i4
        3 category_id = f8
        3 description = vc
        3 synonym_id = f8
        3 synonym = vc
        3 sentence_id = f8
        3 sentence = vc
        3 comment_id = f8
        3 sentence_comment = vc
        3 path_cat_id = f8
        3 path_cat_syn_id = f8
        3 path_cat_syn_name = vc
        3 plan_description = vc
        3 pathway_customized_plan_id = f8
        3 customized_pathway_name = vc
        3 customized_pathway[*]
          4 pathway_customized_plan_id = f8
          4 customized_pathway_name = vc
        3 reg_cat_id = f8
        3 reg_cat_syn_id = f8
        3 reg_cat_syn_display = vc
        3 catalog_cd = f8
        3 orderable_type_flag = i4
        3 hide_ind = i2
        3 hide_reason = vc
        3 open_ind = i2
        3 open_reason = vc
        3 recommend_ind = i2
        3 recommend_reason = vc
        3 usage_flag = i2
        3 catalog_type_meaning = vc
        3 catalog_type_cd = f8
        3 mnemonic_type_cd = f8
        3 infacility = i2
        3 isadmincapable = i2
        3 isrxcapable = i2
        3 synonyms[*]
          4 sequence = i4
          4 list_type = i4
          4 synonym_id = f8
          4 synonym = vc
          4 sentence_id = f8
          4 sentence = vc
          4 comment_id = f8
          4 sentence_comment = vc
          4 path_cat_id = f8
          4 path_cat_syn_id = f8
          4 path_cat_syn_name = vc
          4 plan_description = vc
          4 reg_cat_id = f8
          4 reg_cat_syn_id = f8
          4 reg_cat_syn_display = vc
          4 catalog_cd = f8
          4 orderable_type_flag = i4
          4 hide_ind = i2
          4 hide_reason = vc
          4 recommend_ind = i2
          4 recommend_reason = vc
          4 usage_flag = i2
          4 infacility = i2
          4 mnemonic_type_cd = f8
          4 isadmincapable = i2
          4 isrxcapable = i2
    1 oc_id = vc
    1 venue_type_list[*]
      2 display = vc
      2 default_ind = i2
      2 source_component_list[*]
        3 value = i2
    1 ordered_info
      2 cnt = i4
      2 qual[*]
        3 parent_entity_id = f8
        3 parent_entity_name = vc
        3 last_ordered_dt_tm = dq8
        3 last_ordered_dt_tm_disp = vc
        3 future_ind = i2
    1 usage_flags
      2 cnt = i4
      2 qual[*]
        3 sentence_id = f8
        3 usage_flag = i2
    1 freetext_suggestions
      2 cnt = i4
      2 qual[*]
        3 parent_entity_id = f8
        3 parent_entity_name = vc
        3 freetext_value = gvc
        3 response_ident = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD viewable_encntr_list
 RECORD viewable_encntr_list(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 FREE RECORD flat_order_list
 RECORD flat_order_list(
   1 sentence_cnt = i4
   1 sentences[*]
     2 id = f8
     2 display = vc
   1 synonym_cnt = i4
   1 synonyms[*]
     2 id = f8
     2 display = vc
     2 infacility = i2
     2 isrxcapable = i2
     2 isadmincapable = i2
   1 plan_cnt = i4
   1 plans[*]
     2 id = f8
     2 display = vc
   1 regimen_cnt = i4
   1 regimens[*]
     2 id = f8
     2 display = vc
 )
 IF ( NOT (validate(prefinforec)))
  RECORD prefinforec(
    1 prefinfomask = i4
    1 filterrxordersflag = i2
    1 filterordersflag = i2
    1 allowplanfavs = i2
    1 favssort = i2
    1 futureneworderpref = i2
    1 dischneworderpref = i2
    1 inpat_fav_cnt = i4
    1 inpat_fav[*]
      2 value = f8
    1 rx_fav_cnt = i4
    1 rx_fav[*]
      2 value = f8
    1 hx_fav_cnt = i4
    1 hx_fav[*]
      2 value = f8
    1 home_fav_cnt = i4
    1 home_fav[*]
      2 value = f8
    1 default_venue_val = i2
  ) WITH protect
 ENDIF
 FREE RECORD altsellist
 RECORD altsellist(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 FREE RECORD altselcatrec
 RECORD altselcatrec(
   1 ccnt = i4
   1 category_ids[*]
     2 category_id = f8
 )
 FREE RECORD encntr_rec
 RECORD encntr_rec(
   1 facility_cd = f8
   1 encntr_type_cd = f8
   1 order_encntr_group_cd = f8
   1 encntr_venue_type = i2
 )
 FREE RECORD alt_sel_req
 RECORD alt_sel_req(
   1 virtual_view_offset = i4
   1 alt_sel_list[*]
     2 alt_sel_category_id = f8
     2 owner_id = f8
     2 long_description_key_cap = vc
   1 order_encntr_group_cd = f8
   1 usage_flag = i2
   1 facility_cd = f8
   1 get_hidden_orders_flag = i2
   1 source_list[*]
     2 source_component_flag = i2
   1 view_plans_ind = i2
   1 view_regimens_ind = i2
   1 apply_facility_on_med_ind = i2
   1 apply_facility_on_nonmed_ind = i2
   1 plan_facility_cd = f8
   1 view_orders_ind = i2
   1 load_preferred_ordering_ind = i2
 )
 FREE RECORD customplansreply
 RECORD customplansreply(
   1 customized_plans[*]
     2 pathway_customized_plan_id = f8
     2 name = vc
     2 pathway_catalog_id = f8
     2 owner_id = f8
     2 status_flag = i4
     2 create_dt_tm = dq8
     2 supporting_documentation[*]
       3 evidence_id = f8
       3 evidence_locator = vc
       3 reference_text_ind = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE main(null) = null WITH protect
 DECLARE buildfolders(null) = null WITH protect
 DECLARE getfavorders(null) = null WITH protect
 DECLARE processreply(null) = null WITH protect
 DECLARE querycustomizedplans(null) = null WITH protect
 DECLARE retrieveordersentenceinfo(null) = null WITH protect
 DECLARE retrieveorderfacilityinfo(null) = null WITH protect
 DECLARE loadordereditems(null) = null WITH protect
 DECLARE retrievefreetextvalues(null) = null WITH protect
 SUBROUTINE main(null)
   CALL getparametervalues(6,altsellist)
   CALL getparametervalues(7,viewable_encntr_list)
   SET treatment_reply->person_id = input_person_id
   SET treatment_reply->encntr_id = input_encntr_id
   SET treatment_reply->status_data.status = "F"
   CALL getencntrinfo(input_encntr_id,encntr_rec)
   IF ((encntr_rec->encntr_venue_type=ord_comp_ven_outpat))
    SET bisoutpatientencounter = 1
   ENDIF
   SET prefinforec->prefinfomask = 69
   CALL getpowerordersprefs(0,encntr_rec->encntr_venue_type,prefinforec)
   CALL getproductlevelpref(null)
   SET viewable_encntr_list->cnt += 1
   SET stat = alterlist(viewable_encntr_list->qual,viewable_encntr_list->cnt)
   CALL getvenuetypelistflex(encntr_rec->encntr_venue_type,prefinforec->dischneworderpref,
    treatment_reply,prefinforec->default_venue_val)
   IF ((prefinforec->allowplanfavs=1))
    CALL querycustomizedplans(null)
   ENDIF
   CALL buildfolders(null)
   CALL getfavorders(null)
   CALL processreply(null)
   CALL retrieveordersentenceinfo(null)
   CALL retrieveorderfacilityinfo(null)
   CALL loadordereditems(null)
   CALL retrievefreetextvalues(null)
 END ;Subroutine
 SUBROUTINE buildfolders(null)
   CALL log_message("In buildFolders()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE catcnt = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE parentfoldercnt = i4 WITH noconstant(0), protect
   SET stat = alterlist(altselcatrec->category_ids,altsellist->cnt)
   SELECT INTO "nl:"
    FROM alt_sel_cat c,
     alt_sel_list l
    PLAN (c
     WHERE expand(idx,1,altsellist->cnt,c.alt_sel_category_id,altsellist->qual[idx].value))
     JOIN (l
     WHERE (l.alt_sel_category_id= Outerjoin(c.alt_sel_category_id)) )
    ORDER BY cnvtupper(c.long_description), c.alt_sel_category_id, l.sequence
    HEAD c.alt_sel_category_id
     parentfoldercnt += 1, catcnt += 1, stat = alterlist(treatment_reply->parent,parentfoldercnt),
     stat = alterlist(altselcatrec->category_ids,catcnt), treatment_reply->parent[parentfoldercnt].
     category_id = c.alt_sel_category_id, altselcatrec->category_ids[catcnt].category_id = c
     .alt_sel_category_id,
     treatment_reply->parent[parentfoldercnt].description = c.long_description
    WITH expand = 1, nocounter
   ;end select
   SET altselcatrec->ccnt = catcnt
   IF (validate(debug_ind,0)=1)
    CALL echorecord(altselcatrec)
    CALL echorecord(treatment_reply)
   ENDIF
   CALL log_message(build("Exit buildFolders(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getfavorders(dummy)
   CALL log_message("In getFavOrders()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE favsize = i4 WITH noconstant(0), private
   DECLARE childsize = i4 WITH noconstant(0), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   SET stat = initrec(alt_sel_req)
   IF ((altselcatrec->ccnt > 0))
    SET stat = alterlist(alt_sel_req->alt_sel_list,altselcatrec->ccnt)
    FOR (x = 1 TO altselcatrec->ccnt)
      SET alt_sel_req->alt_sel_list[x].alt_sel_category_id = altselcatrec->category_ids[x].
      category_id
    ENDFOR
   ENDIF
   SET stat = alterlist(alt_sel_req->source_list,1)
   SET alt_sel_req->source_list[1].source_component_flag = 0
   SET alt_sel_req->order_encntr_group_cd = encntr_rec->order_encntr_group_cd
   SET alt_sel_req->facility_cd = encntr_rec->facility_cd
   SET alt_sel_req->view_plans_ind = 1
   SET alt_sel_req->view_regimens_ind = 1
   SET alt_sel_req->view_orders_ind = 1
   SET alt_sel_req->plan_facility_cd = encntr_rec->facility_cd
   IF (validate(debug_ind,0)=1)
    CALL echorecord(alt_sel_req)
   ENDIF
   EXECUTE mp_get_alt_sel  WITH replace("REQUEST","ALT_SEL_REQ")
   IF ((reply->status_data.status="F"))
    CALL handleerror(reply->status_data.subeventstatus[1].operationname,reply->status_data.
     subeventstatus[1].operationstatus,reply->status_data.subeventstatus[1].operationtargetobjectname,
     reply->status_data.subeventstatus[1].operationtargetobjectvalue,report_data)
   ELSE
    SET favsize = size(reply->get_list,5)
    CALL error_and_zero_check_rec(favsize,log_program_name,"GetFavOrders",1,0,
     treatment_reply)
   ENDIF
   CALL log_message(build("Exit getFavOrders(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE processreply(null)
   CALL log_message("In processReply()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE ccnt = i4 WITH noconstant(0), protect
   DECLARE customizedplanposition = i4 WITH noconstant(0), protect
   DECLARE customizedplanindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = size(treatment_reply->parent,5)),
     (dummyt d2  WITH seq = size(reply->get_list,5)),
     (dummyt d3  WITH seq = 1)
    PLAN (d1)
     JOIN (d2
     WHERE (reply->get_list[d2.seq].alt_sel_category_id=treatment_reply->parent[d1.seq].category_id)
      AND maxrec(d3,size(reply->get_list[d2.seq].child_list,5)))
     JOIN (d3
     WHERE (reply->get_list[d2.seq].child_list[d3.seq].list_type IN (2, 6, 7)))
    ORDER BY d1.seq, d2.seq, d3.seq
    HEAD d1.seq
     ccnt = size(treatment_reply->parent[d1.seq].child,5)
    HEAD d3.seq
     ccnt += 1, stat = alterlist(treatment_reply->parent[d1.seq].child,ccnt), treatment_reply->
     parent[d1.seq].child[ccnt].sequence = reply->get_list[d2.seq].child_list[d3.seq].sequence,
     treatment_reply->parent[d1.seq].child[ccnt].list_type = reply->get_list[d2.seq].child_list[d3
     .seq].list_type, treatment_reply->parent[d1.seq].child[ccnt].category_id = reply->get_list[d2
     .seq].child_list[d3.seq].child_alt_sel_cat_id, treatment_reply->parent[d1.seq].child[ccnt].
     description = reply->get_list[d2.seq].child_list[d3.seq].mnemonic,
     treatment_reply->parent[d1.seq].child[ccnt].synonym_id = reply->get_list[d2.seq].child_list[d3
     .seq].synonym_id, treatment_reply->parent[d1.seq].child[ccnt].synonym = reply->get_list[d2.seq].
     child_list[d3.seq].mnemonic, treatment_reply->parent[d1.seq].child[ccnt].sentence_id = reply->
     get_list[d2.seq].child_list[d3.seq].order_sentence_id,
     treatment_reply->parent[d1.seq].child[ccnt].sentence = reply->get_list[d2.seq].child_list[d3.seq
     ].order_sentence_disp_line, treatment_reply->parent[d1.seq].child[ccnt].path_cat_id = reply->
     get_list[d2.seq].child_list[d3.seq].pathway_catalog_id, treatment_reply->parent[d1.seq].child[
     ccnt].path_cat_syn_id = reply->get_list[d2.seq].child_list[d3.seq].pw_cat_synonym_id,
     treatment_reply->parent[d1.seq].child[ccnt].path_cat_syn_name = reply->get_list[d2.seq].
     child_list[d3.seq].pw_synonym_name, treatment_reply->parent[d1.seq].child[ccnt].plan_description
      = reply->get_list[d2.seq].child_list[d3.seq].plan_display_description, treatment_reply->parent[
     d1.seq].child[ccnt].catalog_cd = reply->get_list[d2.seq].child_list[d3.seq].catalog_cd,
     treatment_reply->parent[d1.seq].child[ccnt].orderable_type_flag = reply->get_list[d2.seq].
     child_list[d3.seq].orderable_type_flag, treatment_reply->parent[d1.seq].child[ccnt].
     catalog_type_cd = reply->get_list[d2.seq].child_list[d3.seq].catalog_type_cd, treatment_reply->
     parent[d1.seq].child[ccnt].catalog_type_meaning = uar_get_code_meaning(treatment_reply->parent[
      d1.seq].child[ccnt].catalog_type_cd),
     treatment_reply->parent[d1.seq].child[ccnt].reg_cat_id = reply->get_list[d2.seq].child_list[d3
     .seq].regimen_catalog_id, treatment_reply->parent[d1.seq].child[ccnt].reg_cat_syn_display =
     reply->get_list[d2.seq].child_list[d3.seq].regimen_synonym, treatment_reply->parent[d1.seq].
     child[ccnt].reg_cat_syn_id = reply->get_list[d2.seq].child_list[d3.seq].
     regimen_catalog_synonym_id,
     treatment_reply->parent[d1.seq].child[ccnt].mnemonic_type_cd = reply->get_list[d2.seq].
     child_list[d3.seq].mnemonic_type_cd,
     CALL buildflatorderlist(reply->get_list[d2.seq].child_list[d3.seq].synonym_id,reply->get_list[d2
     .seq].child_list[d3.seq].order_sentence_id,reply->get_list[d2.seq].child_list[d3.seq].
     pathway_catalog_id,reply->get_list[d2.seq].child_list[d3.seq].regimen_catalog_id)
     IF ((reply->get_list[d2.seq].child_list[d3.seq].pathway_catalog_id > 0)
      AND customizedplancnt > 0)
      CALL addcustomizedplans(d1.seq,ccnt,reply->get_list[d2.seq].child_list[d3.seq].
      pathway_catalog_id)
     ENDIF
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echo("After populating child folder synonyms")
    CALL echorecord(flat_order_list)
    CALL echorecord(treatment_reply)
   ENDIF
   CALL log_message(build("Exit processReply(), Elapsed time in seconds:",((curtime3 - begin_curtime3
     )/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (addcustomizedplans(parentindex=i4,childindex=i4,pathway_catalog_id=f8) =null WITH
  protect)
   CALL log_message("In addCustomizedPlans()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE customizedplanposition = i4 WITH noconstant(0), protect
   DECLARE customizedplanindex = i4 WITH protect, noconstant(0)
   DECLARE customized_pathway_length = i4 WITH protect, noconstant(0)
   IF (pathway_catalog_id=0)
    RETURN
   ENDIF
   IF (customizedplancnt=0)
    RETURN
   ENDIF
   IF (((parentindex=0) OR (childindex=0)) )
    RETURN
   ENDIF
   SET customizedplanposition = locateval(customizedplanindex,1,customizedplancnt,pathway_catalog_id,
    customplansreply->customized_plans[customizedplanindex].pathway_catalog_id)
   WHILE (customizedplanposition > 0)
     SET customized_pathway_length = (size(treatment_reply->parent[parentindex].child[childindex].
      customized_pathway,5)+ 1)
     SET stat = alterlist(treatment_reply->parent[parentindex].child[childindex].customized_pathway,
      customized_pathway_length)
     SET treatment_reply_child->customized_pathway[customized_pathway_length].
     pathway_customized_plan_id = customplansreply->customized_plans[customizedplanposition].
     pathway_customized_plan_id
     SET treatment_reply_child->customized_pathway[customized_pathway_length].customized_pathway_name
      = customplansreply->customized_plans[customizedplanposition].name
     SET customizedplanposition = locateval(customizedplanindex,(customizedplanposition+ 1),
      customizedplancnt,pathway_catalog_id,customplansreply->customized_plans[customizedplanindex].
      pathway_catalog_id)
   ENDWHILE
   CALL log_message(build("Exit addCustomizedPlans(), Elapsed time in seconds:",((curtime3 -
     begin_time)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getproductlevelpref(null)
   CALL log_message("In GetProductLevelPref()",log_level_debug)
   DECLARE begin_time = dq8 WITH constant(curtime3), private
   DECLARE ivaluecnt = i4 WITH protect, noconstant(0)
   DECLARE prefindx = i4 WITH protect, noconstant(0)
   CALL initprefrequest(null)
   SET prefindx = addprefqual(null)
   CALL addcontext(prefindx,"user",cnvtstring(input_prsnl_id,17,16))
   CALL addcontext(prefindx,"position",cnvtstring(reqinfo->position_cd,17,16))
   IF ((encntr_rec->facility_cd > 0.0))
    CALL addcontext(prefindx,"facility",cnvtstring(encntr_rec->facility_cd,17,16))
   ENDIF
   CALL addcontext(prefindx,"default","system")
   CALL setsectiondata(prefindx,"component","om")
   CALL addgroup(prefindx,"powerorders")
   CALL addgroup(prefindx,"orderentry")
   CALL setprefname(prefindx,"displayonlyproductlevelmeds")
   CALL retrievepreferences(null)
   SET ivaluecnt = getpreferencevaluecount(prefindx)
   IF (ivaluecnt > 0)
    SET bfilterprodlevelflag = cnvtint(getpreferencevalue(prefindx,0))
   ENDIF
   CALL error_and_zero_check_rec(curqual,log_program_name,"GetProductLevelPref",1,0,
    treatment_reply)
   CALL log_message(build("Exit GetProductLevelPref(), Elapsed time in seconds:",((curtime3 -
     begin_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (buildflatorderlist(synonym_id=f8,sentence_id=f8,path_cat_id=f8,reg_cat_id=f8) =null
  WITH protect)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   CALL log_message("Begin buildFlatOrderList()",log_level_debug)
   DECLARE itemindex = i4 WITH noconstant(0), protect
   DECLARE tempindex = i4 WITH noconstant(0), protect
   IF (synonym_id > 0)
    SET itemindex = locateval(tempindex,1,flat_order_list->synonym_cnt,synonym_id,flat_order_list->
     synonyms[tempindex].id)
    IF (itemindex=0)
     SET flat_order_list->synonym_cnt += 1
     SET stat = alterlist(flat_order_list->synonyms,flat_order_list->synonym_cnt)
     SET flat_order_list->synonyms[flat_order_list->synonym_cnt].id = synonym_id
    ENDIF
    IF (sentence_id > 0)
     SET itemindex = locateval(tempindex,1,flat_order_list->sentence_cnt,sentence_id,flat_order_list
      ->sentences[tempindex].id)
     IF (itemindex=0)
      SET flat_order_list->sentence_cnt += 1
      SET stat = alterlist(flat_order_list->sentences,flat_order_list->sentence_cnt)
      SET flat_order_list->sentences[flat_order_list->sentence_cnt].id = sentence_id
     ENDIF
    ENDIF
   ENDIF
   IF (path_cat_id > 0)
    SET itemindex = locateval(tempindex,1,flat_order_list->plan_cnt,path_cat_id,flat_order_list->
     plans[tempindex].id)
    IF (itemindex=0)
     SET flat_order_list->plan_cnt += 1
     SET stat = alterlist(flat_order_list->plans,flat_order_list->plan_cnt)
     SET flat_order_list->plans[flat_order_list->plan_cnt].id = path_cat_id
    ENDIF
   ENDIF
   IF (reg_cat_id > 0)
    SET itemindex = locateval(tempindex,1,flat_order_list->regimen_cnt,reg_cat_id,flat_order_list->
     regimens[tempindex].id)
    IF (itemindex=0)
     SET flat_order_list->regimen_cnt += 1
     SET stat = alterlist(flat_order_list->regimens,flat_order_list->regimen_cnt)
     SET flat_order_list->regimens[flat_order_list->regimen_cnt].id = reg_cat_id
    ENDIF
   ENDIF
   CALL log_message("Begin buildFlatOrderList()",log_level_debug)
   CALL log_message(build("Exit buildFlatOrderList(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadordereditems(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   FREE RECORD order_history_reply
   RECORD order_history_reply(
     1 cnt = i4
     1 qual[*]
       2 parent_entity_id = f8
       2 parent_entity_name = vc
       2 last_ordered_dt_tm = dq8
       2 last_ordered_dt_tm_disp = vc
       2 future_ind = i2
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   CALL log_message("Begin loadOrderedItems()",log_level_debug)
   EXECUTE cp_get_ordered_synonyms  $OUTDEV, input_person_id, input_encntr_id,
   input_prsnl_id, input_ppr_cdd, 2,
   5
   SET treatment_reply->ordered_info.cnt += order_history_reply->cnt
   SET stat = moverec(order_history_reply->qual,treatment_reply->ordered_info.qual)
   CALL log_message(build("Exit loadOrderedItems(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE querycustomizedplans(null)
   IF (validate(debug_ind,0)=1)
    CALL echo("Entering queryCustomizedPlans subroutine")
   ENDIF
   DECLARE position_cd = f8 WITH protect, constant(reqinfo->position_cd)
   DECLARE irequest_number = i4 WITH protect, constant(601471)
   DECLARE itask_number = i4 WITH protect, constant(3202004)
   DECLARE iapp_number = i4 WITH protect, constant(reqinfo->updt_app)
   DECLARE srv_request = vc WITH protect, constant("QueryCustomizedPlans")
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE pcntr = i4 WITH protect, noconstant(0)
   FREE RECORD custom_plan_request
   RECORD custom_plan_request(
     1 criteria
       2 pathway_catalog_id = f8
       2 owner_id = f8
     1 context
       2 provider_id = f8
       2 position_cd = f8
       2 ppr_cd = f8
   ) WITH protect
   FREE RECORD pp_updt_rec
   RECORD pp_updt_rec(
     1 cnt = i4
     1 qual[*]
       2 old_path_cat_id = f8
       2 new_path_cat_id = f8
   ) WITH protec
   CALL log_message("Begin queryCustomizedPlans",log_level_debug)
   SET custom_plan_request->criteria.owner_id = input_prsnl_id
   SET custom_plan_request->context.provider_id = input_prsnl_id
   SET custom_plan_request->context.position_cd = position_cd
   SET custom_plan_request->context.ppr_cd = input_ppr_cd
   IF (validate(debug_ind,0)=1)
    CALL echorecord(custom_plan_request)
   ENDIF
   SET stat = tdbexecute(iapp_number,itask_number,irequest_number,"REC",custom_plan_request,
    "REC",customplansreply)
   IF (validate(debug_ind,0)=1)
    CALL echo(build(" TDBEXECUTE Status --- > ",stat))
    CALL echorecord(customplansreply)
   ENDIF
   SET customizedplancnt = size(customplansreply->customized_plans,5)
   SELECT INTO "nl:"
    FROM pathway_catalog pc1,
     pathway_catalog pc2
    PLAN (pc1
     WHERE expand(pcntr,1,customizedplancnt,pc1.pathway_catalog_id,customplansreply->
      customized_plans[pcntr].pathway_catalog_id))
     JOIN (pc2
     WHERE pc2.version_pw_cat_id=pc1.version_pw_cat_id
      AND pc2.active_ind=1)
    ORDER BY pc1.pathway_catalog_id
    HEAD pc1.pathway_catalog_id
     IF (pc1.pathway_catalog_id != pc2.pathway_catalog_id)
      pp_updt_rec->cnt += 1, stat = alterlist(pp_updt_rec->qual,pp_updt_rec->cnt), pp_updt_rec->qual[
      pp_updt_rec->cnt].old_path_cat_id = pc1.pathway_catalog_id,
      pp_updt_rec->qual[pp_updt_rec->cnt].new_path_cat_id = pc2.pathway_catalog_id
     ENDIF
    WITH expand = 1
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = pp_updt_rec->cnt),
     (dummyt d2  WITH seq = customizedplancnt)
    PLAN (d1)
     JOIN (d2
     WHERE (customplansreply->customized_plans[d2.seq].pathway_catalog_id=pp_updt_rec->qual[d1.seq].
     old_path_cat_id))
    HEAD d2.seq
     customplansreply->customized_plans[d2.seq].pathway_catalog_id = pp_updt_rec->qual[d1.seq].
     new_path_cat_id
    WITH nocounter
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(pp_updt_rec)
    CALL echorecord(customplansreply)
   ENDIF
   CALL log_message(build("Exit queryCustomizedPlans(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveordersentenceinfo(null)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE sentence_idx = i4 WITH noconstant(0), protect
   DECLARE pcnt = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE startidx = i4 WITH noconstant(0), protect
   CALL log_message("Begin retrieveOrderSentenceInfo()",log_level_debug)
   SELECT INTO "nl:"
    FROM order_sentence os,
     filter_entity_reltn fer
    PLAN (os
     WHERE expand(idx,1,flat_order_list->sentence_cnt,os.order_sentence_id,flat_order_list->
      sentences[idx].id))
     JOIN (fer
     WHERE (((fer.filter_entity1_id= Outerjoin(encntr_rec->facility_cd)) ) OR ((fer.filter_entity1_id
     = Outerjoin(0.0)) ))
      AND (fer.parent_entity_id= Outerjoin(os.order_sentence_id))
      AND (fer.parent_entity_name= Outerjoin("ORDER_SENTENCE")) )
    ORDER BY os.order_sentence_id
    HEAD os.order_sentence_id
     cnt += 1
     IF (cnt > size(treatment_reply->usage_flags.qual,5))
      stat = alterlist(treatment_reply->usage_flags.qual,(cnt+ 10))
     ENDIF
     IF (((os.parent_entity2_name="ALT_SEL_CAT") OR ((((fer.filter_entity1_id=encntr_rec->facility_cd
     )) OR (fer.filter_entity1_id=0.0))
      AND fer.parent_entity_id=os.order_sentence_id
      AND fer.parent_entity_name="ORDER_SENTENCE")) )
      treatment_reply->usage_flags.qual[cnt].sentence_id = os.order_sentence_id, treatment_reply->
      usage_flags.qual[cnt].usage_flag = os.usage_flag
     ENDIF
     FOR (pcnt = 1 TO size(treatment_reply->parent,5))
      sentence_idx = locateval(idx,1,size(treatment_reply->parent[pcnt].child,5),os.order_sentence_id,
       treatment_reply->parent[pcnt].child[idx].sentence_id),
      IF (sentence_idx > 0)
       treatment_reply->parent[pcnt].child[sentence_idx].sentence = os.order_sentence_display_line,
       treatment_reply->parent[pcnt].child[sentence_idx].usage_flag = os.usage_flag, startidx = (
       sentence_idx+ 1)
       WHILE (sentence_idx > 0)
         sentence_idx = locateval(idx,startidx,size(treatment_reply->parent[pcnt].child,5),os
          .order_sentence_id,treatment_reply->parent[pcnt].child[idx].sentence_id)
         IF (sentence_idx > 0)
          treatment_reply->parent[pcnt].child[sentence_idx].sentence = os.order_sentence_display_line,
          treatment_reply->parent[pcnt].child[sentence_idx].usage_flag = os.usage_flag
         ENDIF
         startidx = (sentence_idx+ 1)
       ENDWHILE
      ENDIF
     ENDFOR
    WITH nocounter, expand = 1
   ;end select
   SET treatment_reply->usage_flags.cnt = cnt
   SET stat = alterlist(treatment_reply->usage_flags.qual,cnt)
   CALL log_message(build("Exit retrieveOrderSentenceInfo(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrieveorderfacilityinfo(null)
   CALL log_message("Begin retrieveOrderFacilityInfo()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE synonym_id = f8 WITH noconstant(0.0), protect
   DECLARE path_cat_syn_id = f8 WITH noconstant(0.0), protect
   DECLARE reg_cat_syn_id = f8 WITH noconstant(0.0), protect
   DECLARE synonym_index = i4 WITH noconstant(0), protect
   DECLARE pathway_index = i4 WITH noconstant(0), protect
   DECLARE sentence_idx = i4 WITH noconstant(0), protect
   DECLARE order_sentence_idx = i4 WITH noconstant(0), protect
   DECLARE pcnt = i4 WITH noconstant(0), protect
   DECLARE ccnt = i4 WITH noconstant(0), protect
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM ocs_facility_r ocsfr
    PLAN (ocsfr
     WHERE expand(idx,1,flat_order_list->synonym_cnt,ocsfr.synonym_id,flat_order_list->synonyms[idx].
      id)
      AND ocsfr.facility_cd IN (0.0, encntr_rec->facility_cd))
    ORDER BY ocsfr.synonym_id
    HEAD ocsfr.synonym_id
     cnt += 1, synonym_index = locateval(idx,1,flat_order_list->synonym_cnt,ocsfr.synonym_id,
      flat_order_list->synonyms[idx].id)
     IF (synonym_index > 0)
      flat_order_list->synonyms[synonym_index].infacility = 1
     ENDIF
    WITH nocounter, expand = 1
   ;end select
   FOR (pcnt = 1 TO size(treatment_reply->parent,5))
     FOR (ccnt = 1 TO size(treatment_reply->parent[pcnt].child,5))
       SET synonym_id = treatment_reply->parent[pcnt].child[ccnt].synonym_id
       SET path_cat_syn_id = treatment_reply->parent[pcnt].child[ccnt].path_cat_syn_id
       SET reg_cat_syn_id = treatment_reply->parent[pcnt].child[ccnt].reg_cat_syn_id
       SET mnemonictype = treatment_reply->parent[pcnt].child[ccnt].mnemonic_type_cd
       SET catalog_type_cd = treatment_reply->parent[pcnt].child[ccnt].catalog_type_cd
       IF (synonym_id > 0.0)
        SET synonym_index = locateval(idx,1,flat_order_list->synonym_cnt,treatment_reply->parent[pcnt
         ].child[ccnt].synonym_id,flat_order_list->synonyms[idx].id)
        SET order_sentence_idx = locateval(sentence_idx,1,size(treatment_reply->usage_flags.qual,5),
         treatment_reply->parent[pcnt].child[ccnt].sentence_id,treatment_reply->usage_flags.qual[
         sentence_idx].sentence_id)
        IF ((treatment_reply->parent[pcnt].child[ccnt].sentence_id != 0)
         AND order_sentence_idx=0)
         SET treatment_reply->parent[pcnt].child[ccnt].infacility = 0
        ELSE
         SET treatment_reply->parent[pcnt].child[ccnt].infacility = flat_order_list->synonyms[idx].
         infacility
        ENDIF
        CASE (treatment_reply->parent[pcnt].child[ccnt].usage_flag)
         OF 0:
          SET treatment_reply->parent[pcnt].child[ccnt].isrxcapable = applyallvenuefiltering(
           treatment_reply->parent[pcnt].child[ccnt].orderable_type_flag,treatment_reply->parent[pcnt
           ].child[ccnt].mnemonic_type_cd,2,treatment_reply->parent[pcnt].child[ccnt].infacility,
           treatment_reply->parent[pcnt].child[ccnt].catalog_type_cd)
          SET treatment_reply->parent[pcnt].child[ccnt].isadmincapable = applyallvenuefiltering(
           treatment_reply->parent[pcnt].child[ccnt].orderable_type_flag,treatment_reply->parent[pcnt
           ].child[ccnt].mnemonic_type_cd,1,treatment_reply->parent[pcnt].child[ccnt].infacility,
           treatment_reply->parent[pcnt].child[ccnt].catalog_type_cd)
         OF 1:
          SET treatment_reply->parent[pcnt].child[ccnt].isadmincapable = applyallvenuefiltering(
           treatment_reply->parent[pcnt].child[ccnt].orderable_type_flag,treatment_reply->parent[pcnt
           ].child[ccnt].mnemonic_type_cd,treatment_reply->parent[pcnt].child[ccnt].usage_flag,
           treatment_reply->parent[pcnt].child[ccnt].infacility,treatment_reply->parent[pcnt].child[
           ccnt].catalog_type_cd)
         OF 2:
          SET treatment_reply->parent[pcnt].child[ccnt].isrxcapable = applyallvenuefiltering(
           treatment_reply->parent[pcnt].child[ccnt].orderable_type_flag,treatment_reply->parent[pcnt
           ].child[ccnt].mnemonic_type_cd,treatment_reply->parent[pcnt].child[ccnt].usage_flag,
           treatment_reply->parent[pcnt].child[ccnt].infacility,treatment_reply->parent[pcnt].child[
           ccnt].catalog_type_cd)
        ENDCASE
       ELSEIF (((path_cat_syn_id > 0.0) OR (reg_cat_syn_id > 0.0)) )
        SET treatment_reply->parent[pcnt].child[ccnt].infacility = 1
        SET treatment_reply->parent[pcnt].child[ccnt].isadmincapable = 1
        IF (bisoutpatientencounter)
         SET treatment_reply->parent[pcnt].child[ccnt].isrxcapable = 1
        ENDIF
       ENDIF
     ENDFOR
   ENDFOR
   CALL log_message(build("Exit retrieveOrderFacilityInfo(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (applyallvenuefiltering(orderabletypeflag=i4,mnemonictype=f8,usageflag=i2,
  facilityviewable=i2,catalogtype=f8) =null WITH protect)
   CALL log_message("In applyAllVenueFiltering()",log_level_debug)
   DECLARE return_true = i2 WITH private, constant(1)
   IF (bisoutpatientencounter)
    IF ( NOT (orderabletypeflag IN (normal0, normal1, supergroup, orderset, multi_ingredient,
    freetext)))
     RETURN(0)
    ENDIF
   ELSE
    IF ( NOT (orderabletypeflag IN (normal0, normal1, supergroup, careplan, orderset,
    multi_ingredient, interval_test, freetext, tpn)))
     RETURN(0)
    ENDIF
    IF (orderabletypeflag=orderset
     AND usageflag=2)
     RETURN(0)
    ENDIF
    IF (bfilterprodlevelflag=1
     AND usageflag=2
     AND  NOT (mnemonictype IN (y_mnemonic_type_cd, n_mnemonic_type_cd, m_mnemonic_type_cd,
    z_mnemonic_type_cd)))
     RETURN(0)
    ENDIF
   ENDIF
   IF ( NOT (facilityviewable))
    IF ((prefinforec->filterordersflag=1)
     AND usageflag != 2)
     RETURN(0)
    ELSEIF ((prefinforec->filterrxordersflag=1)
     AND usageflag=2)
     RETURN(0)
    ENDIF
   ENDIF
   IF (usageflag=2
    AND catalogtype != pharmacy_type_cd)
    RETURN(0)
   ENDIF
   CALL log_message("Exiting applyAllVenueFiltering()",log_level_debug)
   RETURN(return_true)
 END ;Subroutine
 SUBROUTINE retrievefreetextvalues(null)
   CALL log_message("Begin retrieveFreeTextValues()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE cnt = i4 WITH noconstant(0), protect
   DECLARE instanceident = vc WITH protect, constant(trim(decodeinternationalcharacters(
       $INSTANCE_IDENT)))
   DECLARE behaviorqualstr = vc WITH protect, noconstant("")
   SET behaviorqualstr = build("cnb.cp_node_id = ",cnvtreal(input_cp_node_id),
    ' and cnb.reaction_type_mean = "SUGGEST_FREE_TEXT"')
   IF (instanceident="")
    SET behaviorqualstr = build2(behaviorqualstr," and cnb.instance_ident in (NULL,'') ")
   ELSE
    SET behaviorqualstr = build2(behaviorqualstr," and cnb.instance_ident =  '",instanceident,"'")
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echo(build(" behaviorQualStr -- > ",behaviorqualstr))
   ENDIF
   SELECT INTO "nl:"
    FROM cp_node_behavior cnb,
     long_text_reference ltr
    PLAN (cnb
     WHERE parser(behaviorqualstr))
     JOIN (ltr
     WHERE ltr.long_text_id=cnb.reaction_entity_id)
    HEAD ltr.long_text_id
     cnt += 1
     IF (cnt > size(treatment_reply->freetext_suggestions.qual,5))
      stat = alterlist(treatment_reply->freetext_suggestions.qual,(cnt+ 10))
     ENDIF
     treatment_reply->freetext_suggestions.qual[cnt].parent_entity_id = ltr.long_text_id,
     treatment_reply->freetext_suggestions.qual[cnt].parent_entity_name = cnb.reaction_entity_name,
     treatment_reply->freetext_suggestions.qual[cnt].freetext_value = ltr.long_text
     IF (textlen(trim(cnb.long_response_ident,3)) > 0)
      treatment_reply->freetext_suggestions.qual[cnt].response_ident = trim(cnb.long_response_ident)
     ELSE
      treatment_reply->freetext_suggestions.qual[cnt].response_ident = trim(cnb.response_ident)
     ENDIF
    FOOT REPORT
     treatment_reply->freetext_suggestions.cnt = cnt, stat = alterlist(treatment_reply->
      freetext_suggestions.qual,cnt)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit retrieveFreeTextValues(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 CALL log_message(build("Starting Script:",log_program_name),log_level_debug)
 SET treatment_reply->status_data.status = "F"
 CALL main(null)
 SET treatment_reply->status_data.status = "S"
#exit_script
 SET curalias treatment_reply_child off
 CALL echorecord(treatment_reply)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",((curtime3 - script_start_curtime3)/ 100.0)),
  log_level_debug)
 IF (( $OUTDEV != "NOFORMS"))
  CALL putjsonrecordtofile(treatment_reply)
 ENDIF
END GO
