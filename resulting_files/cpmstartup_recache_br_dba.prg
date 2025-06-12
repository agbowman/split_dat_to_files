CREATE PROGRAM cpmstartup_recache_br:dba
 EXECUTE cpmstartup
 SET ccl_env = cnvtupper(logical("ENVIRONMENT_MODE"))
 IF (ccl_env="*PROD*")
  SET trace = skiprecache
 ELSE
  SET trace = noskiprecache
 ENDIF
 SET trace = rdbcomment
 SET trace = error
 IF (currdbuser="V500_MPAGE")
  CALL echo("command: rdb alter session set current_schema = v500 end")
  RDB alter session set current_schema = v500
  END ;Rdb
 ENDIF
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), protect
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
 DECLARE addcodetolist(p1=f8(val),p2=vc(ref)) = null WITH protect
 DECLARE addpersonneltolist(p1=f8(val),p2=vc(ref)) = null WITH protect
 DECLARE addpersonneltolistwithdate(p1=f8(val),p2=vc(ref),p3=f8(val)) = null WITH protect
 DECLARE addphonestolist(p1=f8(val),p2=vc(ref)) = null WITH protect
 DECLARE putjsonrecordtofile(p1=vc(ref)) = null WITH protect
 DECLARE putstringtofile(p1=vc(val)) = null WITH protect
 DECLARE putunboundedstringtofile(p1=vc(ref)) = null WITH protect
 DECLARE outputcodelist(p1=vc(ref)) = null WITH protect
 DECLARE outputpersonnellist(p1=vc(ref)) = null WITH protect
 DECLARE outputphonelist(p1=vc(ref),p2=vc(ref)) = null WITH protect
 DECLARE getparametervalues(p1=i4(val),p2=vc(ref)) = null WITH protect
 DECLARE getlookbackdatebytype(p1=i4(val),p2=i4(val)) = dq8 WITH protect
 DECLARE getcodevaluesfromcodeset(p1=vc(ref),p2=vc(ref)) = null WITH protect
 DECLARE geteventsetnamesfromeventsetcds(p1=vc(ref),p2=vc(ref)) = null WITH protect
 DECLARE returnviewertype(p1=f8(val),p2=f8(val)) = vc WITH protect
 DECLARE cnvtisodttmtodq8(p1=vc) = dq8 WITH protect
 DECLARE cnvtdq8toisodttm(p1=f8) = vc WITH protect
 DECLARE getorgsecurityflag(null) = i2 WITH protect
 DECLARE getcomporgsecurityflag(p1=vc(val)) = i2 WITH protect
 DECLARE populateauthorizedorganizations(p1=f8(val),p2=vc(ref)) = null WITH protect
 DECLARE getuserlogicaldomain(p1=f8) = f8 WITH protect
 DECLARE getpersonneloverride(ppr_cd=f8(val)) = i2 WITH protect
 DECLARE cclimpersonation(null) = null WITH protect
 DECLARE geteventsetdisplaysfromeventsetcds(p1=vc(ref),p2=vc(ref)) = null WITH protect
 DECLARE decodestringparameter(description=vc(val)) = vc WITH protect
 DECLARE urlencode(json=vc(val)) = vc WITH protect
 DECLARE istaskgranted(task_number=i4(val)) = i2 WITH protect
 SUBROUTINE addcodetolist(code_value,record_data)
   IF (code_value != 0)
    IF (((codelistcnt=0) OR (locateval(code_idx,1,codelistcnt,code_value,record_data->codes[code_idx]
     .code) <= 0)) )
     SET codelistcnt = (codelistcnt+ 1)
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
 SUBROUTINE outputcodelist(record_data)
   CALL log_message("In OutputCodeList() @deprecated",log_level_debug)
 END ;Subroutine
 SUBROUTINE addpersonneltolist(prsnl_id,record_data)
   CALL addpersonneltolistwithdate(prsnl_id,record_data,current_date_time)
 END ;Subroutine
 SUBROUTINE addpersonneltolistwithdate(prsnl_id,record_data,active_date)
   DECLARE personnel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",213,"PRSNL"))
   IF (((active_date=null) OR (active_date=0.0)) )
    SET active_date = current_date_time
   ENDIF
   IF (prsnl_id != 0)
    IF (((prsnllistcnt=0) OR (locateval(prsnl_idx,1,prsnllistcnt,prsnl_id,record_data->prsnl[
     prsnl_idx].id,
     active_date,record_data->prsnl[prsnl_idx].active_date) <= 0)) )
     SET prsnllistcnt = (prsnllistcnt+ 1)
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
 SUBROUTINE outputpersonnellist(report_data)
   CALL log_message("In OutputPersonnelList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
       idx = (idx+ 1), filteredcnt = (filteredcnt+ 1), report_data->prsnl[idx].id = report_data->
       prsnl[d.seq].id,
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE addphonestolist(prsnl_id,record_data)
   IF (prsnl_id != 0)
    IF (((phonelistcnt=0) OR (locateval(phone_idx,1,phonelistcnt,prsnl_id,record_data->phone_list[
     prsnl_idx].person_id) <= 0)) )
     SET phonelistcnt = (phonelistcnt+ 1)
     IF (phonelistcnt > size(record_data->phone_list,5))
      SET stat = alterlist(record_data->phone_list,(phonelistcnt+ 9))
     ENDIF
     SET record_data->phone_list[phonelistcnt].person_id = prsnl_id
     SET prsnl_cnt = (prsnl_cnt+ 1)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE outputphonelist(report_data,phone_types)
   CALL log_message("In OutputPhoneList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
       AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
       AND ph.active_ind=1
       AND ph.phone_type_seq=1
      ORDER BY ph.parent_entity_id, phone_sorter
     ELSE
      phone_sorter = locateval(idx2,1,size(phone_types->phone_codes,5),ph.phone_type_cd,phone_types->
       phone_codes[idx2].phone_cd)
      FROM phone ph
      WHERE expand(idx,1,personcnt,ph.parent_entity_id,report_data->phone_list[idx].person_id)
       AND ph.parent_entity_name="PERSON"
       AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
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
      phonecnt = (phonecnt+ 1)
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE putstringtofile(svalue)
   CALL log_message("In PutStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE putunboundedstringtofile(trec)
   CALL log_message("In PutUnboundedStringToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE putjsonrecordtofile(record_data)
   CALL log_message("In PutJSONRecordToFile()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   RECORD _tempjson(
     1 val = gvc
   )
   SET _tempjson->val = cnvtrectojson(record_data)
   CALL putunboundedstringtofile(_tempjson)
   CALL log_message(build("Exit PutJSONRecordToFile(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getparametervalues(index,value_rec)
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
     SET value_rec->cnt = (value_rec->cnt+ 1)
     SET stat = alterlist(value_rec->qual,value_rec->cnt)
     SET value_rec->qual[value_rec->cnt].value = param_value
    ENDIF
   ELSEIF (substring(1,1,par)="C")
    SET param_value_str = parameter(index,0)
    IF (trim(param_value_str,3) != "")
     SET value_rec->cnt = (value_rec->cnt+ 1)
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
        SET value_rec->cnt = (value_rec->cnt+ 1)
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = param_value
       ENDIF
       SET lnum = (lnum+ 1)
      ELSEIF (substring(1,1,par)="C")
       SET param_value_str = parameter(index,lnum)
       IF (trim(param_value_str,3) != "")
        SET value_rec->cnt = (value_rec->cnt+ 1)
        SET stat = alterlist(value_rec->qual,value_rec->cnt)
        SET value_rec->qual[value_rec->cnt].value = trim(param_value_str,3)
       ENDIF
       SET lnum = (lnum+ 1)
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
 SUBROUTINE getlookbackdatebytype(units,flag)
   DECLARE looback_date = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00"))
   IF (units != 0)
    CASE (flag)
     OF 1:
      SET looback_date = cnvtlookbehind(build(units,",H"),cnvtdatetime(curdate,curtime3))
     OF 2:
      SET looback_date = cnvtlookbehind(build(units,",D"),cnvtdatetime(curdate,curtime3))
     OF 3:
      SET looback_date = cnvtlookbehind(build(units,",W"),cnvtdatetime(curdate,curtime3))
     OF 4:
      SET looback_date = cnvtlookbehind(build(units,",M"),cnvtdatetime(curdate,curtime3))
     OF 5:
      SET looback_date = cnvtlookbehind(build(units,",Y"),cnvtdatetime(curdate,curtime3))
    ENDCASE
   ENDIF
   RETURN(looback_date)
 END ;Subroutine
 SUBROUTINE getcodevaluesfromcodeset(evt_set_rec,evt_cd_rec)
  DECLARE csidx = i4 WITH noconstant(0)
  SELECT DISTINCT INTO "nl:"
   FROM v500_event_set_explode vese
   WHERE expand(csidx,1,evt_set_rec->cnt,vese.event_set_cd,evt_set_rec->qual[csidx].value)
   DETAIL
    evt_cd_rec->cnt = (evt_cd_rec->cnt+ 1), stat = alterlist(evt_cd_rec->qual,evt_cd_rec->cnt),
    evt_cd_rec->qual[evt_cd_rec->cnt].value = vese.event_cd
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE geteventsetnamesfromeventsetcds(evt_set_rec,evt_set_name_rec)
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
       cnt = (cnt+ 1), evt_set_name_rec->qual[pos].value = v.event_set_name, pos = locateval(index,(
        pos+ 1),evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_name_rec->cnt,"",evt_set_name_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_name_rec->cnt = (evt_set_name_rec->cnt - 1), stat = alterlist(evt_set_name_rec->qual,
        evt_set_name_rec->cnt,(pos - 1)), pos = locateval(index,pos,evt_set_name_rec->cnt,"",
        evt_set_name_rec->qual[index].value)
     ENDWHILE
     evt_set_name_rec->cnt = cnt, stat = alterlist(evt_set_name_rec->qual,evt_set_name_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE returnviewertype(eventclasscd,eventid)
   CALL log_message("In returnViewerType()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
   RETURN(sviewerflag)
 END ;Subroutine
 SUBROUTINE cnvtisodttmtodq8(isodttmstr)
   DECLARE converteddq8 = dq8 WITH protect, noconstant(0)
   SET converteddq8 = cnvtdatetimeutc2(substring(1,10,isodttmstr),"YYYY-MM-DD",substring(12,8,
     isodttmstr),"HH:MM:SS",4,
    curtimezonedef)
   RETURN(converteddq8)
 END ;Subroutine
 SUBROUTINE cnvtdq8toisodttm(dq8dttm)
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
 SUBROUTINE getcomporgsecurityflag(dminfo_name)
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
 SUBROUTINE populateauthorizedorganizations(personid,value_rec)
   DECLARE organization_cnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE por.person_id=personid
     AND por.active_ind=1
     AND por.beg_effective_dt_tm BETWEEN cnvtdatetime(lower_bound_date) AND cnvtdatetime(curdate,
     curtime3)
     AND por.end_effective_dt_tm BETWEEN cnvtdatetime(curdate,curtime3) AND cnvtdatetime(
     upper_bound_date)
    ORDER BY por.organization_id
    HEAD REPORT
     organization_cnt = 0
    DETAIL
     organization_cnt = (organization_cnt+ 1)
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
 SUBROUTINE getuserlogicaldomain(id)
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
 SUBROUTINE getpersonneloverride(ppr_cd)
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
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
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
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE geteventsetdisplaysfromeventsetcds(evt_set_rec,evt_set_disp_rec)
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
       cnt = (cnt+ 1), evt_set_disp_rec->qual[pos].value = v.event_set_cd_disp, pos = locateval(index,
        (pos+ 1),evt_set_rec->cnt,v.event_set_cd,evt_set_rec->qual[index].value)
     ENDWHILE
    FOOT REPORT
     pos = locateval(index,1,evt_set_disp_rec->cnt,"",evt_set_disp_rec->qual[index].value)
     WHILE (pos > 0)
       evt_set_disp_rec->cnt = (evt_set_disp_rec->cnt - 1), stat = alterlist(evt_set_disp_rec->qual,
        evt_set_disp_rec->cnt,(pos - 1)), pos = locateval(index,pos,evt_set_disp_rec->cnt,"",
        evt_set_disp_rec->qual[index].value)
     ENDWHILE
     evt_set_disp_rec->cnt = cnt, stat = alterlist(evt_set_disp_rec->qual,evt_set_disp_rec->cnt)
    WITH nocounter, expand = value(evaluate(floor(((evt_set_rec->cnt - 1)/ 30)),0,0,1))
   ;end select
 END ;Subroutine
 SUBROUTINE decodestringparameter(description)
   DECLARE decodeddescription = vc WITH private
   SET decodeddescription = replace(description,"%3B",";",0)
   SET decodeddescription = replace(decodeddescription,"%25","%",0)
   RETURN(decodeddescription)
 END ;Subroutine
 SUBROUTINE urlencode(json)
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
 SUBROUTINE istaskgranted(task_number)
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
      AND ag.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ag.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
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
 DECLARE log_message(logmsg=vc,loglvl=i4) = null
 SUBROUTINE log_message(logmsg,loglvl)
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
 DECLARE error_message(logstatusblockind=i2) = i2
 SUBROUTINE error_message(logstatusblockind)
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
 DECLARE error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2,
  recorddata=vc(ref)) = i2
 SUBROUTINE error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,recorddata)
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
 DECLARE error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2) = i2
 SUBROUTINE error_and_zero_check(qualnum,opname,logmsg,errorforceexit,zeroforceexit)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 DECLARE populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) = i2
 SUBROUTINE populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,
  targetobjectvalue,recorddata)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].operationstatus)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectname)))
    SET lcrslsubeventsize = (lcrslsubeventsize+ size(trim(recorddata->status_data.subeventstatus[
      lcrslsubeventcnt].targetobjectvalue)))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt = (lcrslsubeventcnt+ 1)
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
 DECLARE populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),targetobjectname=
  vc(value),targetobjectvalue=vc(value)) = i2
 SUBROUTINE populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
 END ;Subroutine
 DECLARE populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) = i2
 SUBROUTINE populate_subeventstatus_msg(operationname,operationstatus,targetobjectname,
  targetobjectvalue,loglevel)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 DECLARE check_log_level(arg_log_level=i4) = i2
 SUBROUTINE check_log_level(arg_log_level)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (validate(br_component_pos)=0)
  FREE RECORD br_component_pos
  RECORD br_component_pos(
    1 br_component_list[*]
      2 position_cd = f8
      2 component[*]
        3 br_datamart_filter_id = f8
        3 br_datamart_report_id = f8
        3 br_datamart_category_id = f8
        3 report_mean = vc
        3 filter_mean = vc
        3 label = vc
        3 link = vc
        3 group_seq = i4
        3 row_seq = i4
        3 col_seq = i4
        3 expanded = i2
        3 scroll_num = i4
        3 scroll_enabled = i2
        3 isplusadd = i2
        3 lookbackunits = i4
        3 lookbacktypeflag = i4
        3 scope = i2
        3 date_display_flag = i4
        3 filter[*]
          4 br_datamart_filter_id = f8
          4 filter_mean = vc
          4 filter_seq = i4
          4 filter_category_mean = vc
          4 filter_category_type_mean = vc
          4 codeset = f8
          4 values[*]
            5 parent_entity_id = f8
            5 parent_entity_name = vc
            5 cdf_meaning = vc
            5 group_seq = i4
            5 value_seq = i4
            5 freetext_desc = vc
            5 flex_id = f8
            5 value_type_flag = i4
            5 qualifier_flag = i2
        3 flex_ind = i2
        3 br_datamart_flex_id = f8
        3 br_datamart_value_id = f8
        3 theme = vc
        3 toggle_status = i4
  ) WITH persist
 ENDIF
 IF (validate(dyn_pri_encntrs)=0)
  FREE RECORD dyn_pri_encntrs
  RECORD dyn_pri_encntrs(
    1 prsnl_cnt = i4
    1 prsnl_list[*]
      2 prsnl_id = f8
      2 person_cnt = i4
      2 person_list[*]
        3 person_id = f8
        3 last_updt_dt_tm = dq8
        3 encntr_cnt = i4
        3 encntr_list[*]
          4 value = f8
  ) WITH persist
 ENDIF
 DECLARE getcomponentbrfilters(positioncd=f8,reportmean=vc,categorymean=vc,br_component_rec=vc(ref))
  = null WITH protect
 DECLARE getreportmeanid(categorymean=vc,reportmean=vc) = f8 WITH protect
 DECLARE insertdynpridata(personid=f8,enctrid=f8,jsonblob=gvc,viewid=f8) = null WITH protect
 DECLARE checkactivitydataissame(activitydata=vc(ref)) = null WITH protect
 DECLARE retrievedynpridata(patientid=f8,personnelid=f8,seqparam=vc,retreiveobjectname=vc,summarycomp
  =vc,
  summaryview=vc,encntr_rec=vc(ref),blobreply_rec=vc(ref),lookbackflags=vc) = null WITH protect
 DECLARE retrievedynpridatawklst(patientsrec=vc(ref),seqparam=vc,retreiveobjectname=vc,summarycomp=vc,
  summaryview=vc,
  blobreply_rec=vc(ref),personnelid=f8) = null WITH protect
 DECLARE removepersonfrompoptable(personid=f8) = null WITH protect
 DECLARE getlookbackdate(lookbackflags=vc) = dq8 WITH protect
 DECLARE removepopulation(personid=f8) = null WITH protect
 DECLARE getallbrfilters(null) = null WITH protect
 DECLARE getreportmeanids(pos_cd_list=vc(ref)) = null WITH protect
 DECLARE getpositioncodes(pos_cd_list=vc(ref)) = null WITH protect
 DECLARE populateeventlist(updatedata=vc(ref),eventset_list=vc(ref)) = null WITH protect
 DECLARE checkcelistinbrcomponent(eventset_list=vc(ref),br_component=vc(ref)) = i2 WITH protect
 DECLARE checkorderlist(updatedata=vc(ref),eventclasscd=f8) = i4 WITH protect
 DECLARE getencounters(personid=f8,prsnlid=f8,encntr_rec=vc(ref)) = null WITH protect
 DECLARE enctrcleanup(personid=f8,encntrid=f8,viewid=f8) = null WITH protect
 DECLARE loadencounterorgconfid(null) = null WITH protect
 DECLARE isprivsgranted(p1=f8(val)) = i2 WITH protect
 DECLARE setupandretrieveviewprivileges(privcd=f8,personnelid=f8,pprcd=f8) = null WITH protect
 DECLARE getprsnlgroupid(personnelid=f8,summarycomp=vc,summaryview=vc) = f8 WITH protect
 DECLARE setpendingupdate(viewid=f8,personid=f8,encntrid=f8,pendingind=i2) = null
 DECLARE active_var = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE nocompression_var = f8 WITH constant(uar_get_code_by("MEANING",120,"NOCOMP")), protect
 SUBROUTINE getprsnlgroupid(personnelid,summarycomp,summaryview)
   CALL log_message("In GetPrsnlGroupId()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE prsnlgrpid = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    FROM mp_primed_view_ref ref,
     prsnl_group_reltn pgr
    PLAN (pgr
     WHERE pgr.person_id=personnelid)
     JOIN (ref
     WHERE ref.prsnl_group_id=pgr.prsnl_group_id
      AND ref.component_config_txt=cnvtupper(summarycomp)
      AND ref.category_config_txt=cnvtupper(summaryview)
      AND ref.enabled_ind=1)
    DETAIL
     prsnlgrpid = ref.prsnl_group_id
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetPrsnlGroupId(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
   RETURN(prsnlgrpid)
 END ;Subroutine
 SUBROUTINE isprivsgranted(privcd)
   CALL log_message("In IsPrivsGranted()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE prividx = i4 WITH noconstant(0), private
   DECLARE exceptcnt = i4 WITH noconstant(0), private
   DECLARE privmode = i2 WITH noconstant(0), protect
   SET prividx = locateprivilegecode(privcd)
   IF (prividx > 0)
    IF ((priv_reply->privileges[prividx].default[1].granted_ind=1))
     IF (size(priv_reply->privileges[prividx].default[1].exceptions,5)=0)
      SET privmode = 1
     ELSE
      SET privmode = 2
     ENDIF
    ELSE
     SET exceptcnt = size(priv_reply->privileges[prividx].default[1].exceptions,5)
     IF (exceptcnt > 0)
      SET privmode = 3
     ELSE
      SET privmode = 4
     ENDIF
    ENDIF
   ELSE
    SET privmode = 4
   ENDIF
   CALL echo(build2("privMode - ",privmode))
   CALL log_message(build("Exit IsPrivsGranted(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (curdate,curtime3),begin_date_time,5)),log_level_debug)
   RETURN(privmode)
 END ;Subroutine
 SUBROUTINE setupandretrieveviewprivileges(privcd,personnelid,pprcd)
   CALL log_message("In SetupAndRetrieveViewPrivileges()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SET stat = alterlist(priv_request->privilege_criteria.privileges,1)
   SET priv_request->privilege_criteria.privileges[1].privilege_cd = privcd
   CALL getprivilegesbycodes(personnelid,pprcd)
   CALL log_message(build("Exit SetupandRetrieveViewOrderPrivileges(), Elapsed time in seconds:",
     datetimediff(cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE checkcelistinbrcomponent(eventset_list,br_component)
   CALL log_message("In CheckCeListinBrComponent()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE checkcelist = i2 WITH noconstant(0), protect
   SELECT INTO "nl:"
    br_val = br_component->component[d.seq].filter[d1.seq].values[d2.seq].parent_entity_id
    FROM (dummyt d  WITH seq = size(br_component->component,5)),
     (dummyt d1  WITH seq = 1),
     (dummyt d2  WITH seq = 1),
     (dummyt d3  WITH seq = size(eventset_list->qual,5))
    PLAN (d
     WHERE maxrec(d1,size(br_component->component[d.seq].filter,5)))
     JOIN (d1
     WHERE maxrec(d2,size(br_component->component[d.seq].filter[d1.seq].values,5)))
     JOIN (d2)
     JOIN (d3
     WHERE (eventset_list->qual[d3.seq].value=br_component->component[d.seq].filter[d1.seq].values[d2
     .seq].parent_entity_id))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET checkcelist = 1
   ENDIF
   CALL log_message(build("Exit CheckCeListinBrComponent(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
   RETURN(checkcelist)
 END ;Subroutine
 SUBROUTINE populateeventlist(updatedata,eventset_list)
   CALL log_message("In PopulateEventList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE evtsetcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    evt_cd = updatedata->data[d.seq].clineventlist[d1.seq].event_cd
    FROM (dummyt d  WITH seq = size(updatedata->data,5)),
     (dummyt d1  WITH seq = 1),
     v500_event_set_explode vese
    PLAN (d
     WHERE maxrec(d1,size(updatedata->data[d.seq].clineventlist,5)))
     JOIN (d1)
     JOIN (vese
     WHERE (vese.event_cd=updatedata->data[d.seq].clineventlist[d1.seq].event_cd))
    ORDER BY evt_cd
    HEAD evt_cd
     evtsetcnt = (evtsetcnt+ 1), stat = alterlist(eventset_list->qual,evtsetcnt), eventset_list->
     qual[evtsetcnt].value = updatedata->data[d.seq].clineventlist[d1.seq].event_cd
    DETAIL
     evtsetcnt = (evtsetcnt+ 1), stat = alterlist(eventset_list->qual,evtsetcnt), eventset_list->
     qual[evtsetcnt].value = vese.event_set_cd
    WITH nocounter
   ;end select
   CALL log_message(build("Exit PopulateEventList(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE checkorderlist(updatedata,eventclasscd)
   CALL log_message("In CheckOrderList()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE _colx = i4 WITH noconstant(0), protect
   DECLARE _coly = i4 WITH noconstant(0), protect
   DECLARE ordcnt = i4 WITH noconstant(0), protect
   FOR (_colx = 1 TO size(updatedata->data,5))
     FOR (_coly = 1 TO size(updatedata->data[_colx].orderlist,5))
       IF ((updatedata->data[_colx].orderlist[_coly].order_id > 0)
        AND (updatedata->data[_colx].orderlist[_coly].clinical_event_id=0))
        SET ordcnt = (ordcnt+ 1)
       ELSEIF ((updatedata->data[_colx].orderlist[_coly].order_id > 0)
        AND (updatedata->data[_colx].orderlist[_coly].clinical_event_id > 0)
        AND eventclasscd=0)
        SET ordcnt = (ordcnt+ 1)
       ELSEIF ((updatedata->data[_colx].orderlist[_coly].order_id > 0)
        AND (updatedata->data[_colx].orderlist[_coly].clinical_event_id > 0)
        AND (eventclasscd=updatedata->data[_colx].orderlist[_coly].event_class_cd))
        SET ordcnt = (ordcnt+ 1)
       ENDIF
     ENDFOR
   ENDFOR
   CALL log_message(build2("Order Count: ",ordcnt),log_level_debug)
   CALL log_message(build("Exit CheckOrderList(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (curdate,curtime3),begin_date_time,5)),log_level_debug)
   RETURN(ordcnt)
 END ;Subroutine
 SUBROUTINE getcomponentbrfilters(positioncd,reportmean,categorymean,br_component_rec)
   CALL log_message("In GetComponentBrFilters()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE dreportmeanid = f8 WITH constant(getreportmeanid(categorymean,reportmean)), private
   DECLARE pos = i4 WITH noconstant(0), private
   DECLARE pos1 = i4 WITH noconstant(0), private
   DECLARE num = i4 WITH noconstant(0), private
   CALL echo(build2("ReportMeanId: ",dreportmeanid))
   CALL echorecord(br_component_pos)
   IF (size(br_component_pos->br_component_list,5)=0)
    CALL getallbrfilters(null)
    IF (size(br_component_pos->br_component_list,5)=0)
     CALL log_message("Attempt to load BR_COMPONENT_POS returned empty",log_level_error)
     GO TO exit_script
    ENDIF
   ENDIF
   SET pos = locateval(num,1,size(br_component_pos->br_component_list,5),positioncd,br_component_pos
    ->br_component_list[num].position_cd)
   IF (pos > 0)
    SET pos1 = locateval(num,1,size(br_component_pos->br_component_list[pos].component,5),
     dreportmeanid,br_component_pos->br_component_list[pos].component[num].br_datamart_report_id)
    IF (pos1 > 0)
     CALL log_message(build2("Found component at ",pos,":",pos1),log_level_debug)
     SET stat = movereclist(br_component_pos->br_component_list[pos].component,br_component_rec->
      component,pos1,0,1,
      1)
    ELSE
     CALL log_message("Component Bedrock data not loaded. Exiting Script",log_level_error)
     GO TO exit_script
    ENDIF
   ELSE
    CALL log_message("Position Bedrock data not loaded",log_level_error)
   ENDIF
   CALL log_message(build("Exit GetComponentBrFilters(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getreportmeanid(categorymean,reportmean)
   CALL log_message("In GetReportMeanId()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE reportmeanid = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    bdr.report_mean, bdr.br_datamart_report_id
    FROM br_datamart_category bdc,
     br_datamart_report bdr
    PLAN (bdc
     WHERE bdc.category_mean=categorymean)
     JOIN (bdr
     WHERE bdr.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdr.report_mean=reportmean)
    DETAIL
     reportmeanid = bdr.br_datamart_report_id
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetReportMeanId(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
   RETURN(reportmeanid)
 END ;Subroutine
 SUBROUTINE checkactivitydataissame(activitydata)
   CALL log_message("In checkActivityDataIsSame()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE replyblb = gvc WITH noconstant(""), protect
   SELECT INTO "nl:"
    mpva.mp_primed_view_act_id
    FROM mp_primed_view_act mpva
    PLAN (mpva
     WHERE (mpva.mp_primed_view_ref_id=activitydata->mp_primed_view_ref_id)
      AND (mpva.encntr_id=activitydata->encntr_id))
    HEAD REPORT
     outbuf = fillstring(32767," "), activitydata->mp_primed_view_act_id = mpva.mp_primed_view_act_id
    DETAIL
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(outbuf,offset,mpva.data_blob), offset = (offset+ retlen), replyblb = notrim(
        concat(notrim(replyblb),notrim(substring(1,retlen,outbuf))))
     ENDWHILE
    WITH nocounter
   ;end select
   SET activitydata->current_json_blob = trim(replyblb,3)
   IF ((activitydata->current_json_blob=activitydata->input_json_blob))
    SET activitydata->data_changed_ind = 0
    CALL log_message("Insert Data Same as before",log_level_debug)
   ELSE
    SET activitydata->data_changed_ind = 1
    CALL log_message("Insert Data is NOT Same as before",log_level_debug)
   ENDIF
   CALL log_message(build("Exit checkActivityDataIsSame(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE insertdynpridata(personid,encntrid,jsonblob,view_id)
   CALL log_message("In InsertDynPriData()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE blobsize = i4 WITH noconstant(size(jsonblob)), protect
   CALL log_message(build2("The params, PERSON_ID:",personid," ENCNTRID:",encntrid," view_id:",
     view_id),log_level_debug)
   CALL log_message(build2("SIZE of BLOB:",blobsize),log_level_debug)
   RECORD tempactdata(
     1 person_id = f8
     1 encntr_id = f8
     1 mp_primed_view_ref_id = f8
     1 mp_primed_view_act_id = f8
     1 input_json_blob = gvc
     1 current_json_blob = gvc
     1 data_changed_ind = i4
   )
   RECORD temprefdata(
     1 data_retrieve_object_name = vc
     1 data_retrieve_seq_param = vc
     1 parent_entity_id = i4
     1 parent_entity_name = vc
     1 proxy_prsnl_id = f8
     1 prsnl_group_id = f8
     1 summary_component = vc
     1 summary_view = vc
   )
   SET tempactdata->person_id = personid
   SET tempactdata->encntr_id = encntrid
   SET tempactdata->input_json_blob = trim(jsonblob,3)
   SET tempactdata->mp_primed_view_ref_id = view_id
   SELECT INTO "nl:"
    FROM mp_primed_view_ref sref
    WHERE (sref.mp_primed_view_ref_id=tempactdata->mp_primed_view_ref_id)
     AND sref.enabled_ind=1
    DETAIL
     temprefdata->data_retrieve_object_name = sref.data_object_name, temprefdata->
     data_retrieve_seq_param = sref.data_group_name, temprefdata->parent_entity_id = sref
     .pop_parent_entity_id,
     temprefdata->parent_entity_name = sref.pop_parent_entity_name, temprefdata->proxy_prsnl_id =
     sref.proxy_prsnl_id, temprefdata->summary_component = sref.component_config_txt,
     temprefdata->summary_view = sref.category_config_txt, temprefdata->prsnl_group_id = sref
     .prsnl_group_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL log_message(build("Inactive or invalid view."),log_level_debug)
    RETURN(0)
   ENDIF
   CALL checkactivitydataissame(tempactdata)
   IF ((tempactdata->data_changed_ind=1))
    UPDATE  FROM mp_primed_view_act mpva
     SET mpva.data_blob = tempactdata->input_json_blob, mpva.load_dt_tm = cnvtdatetime(curdate,
       curtime3), mpva.updt_applctx = reqinfo->updt_applctx,
      mpva.updt_id = reqinfo->updt_id, mpva.updt_task = reqinfo->updt_task, mpva.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      mpva.updt_cnt = (mpva.updt_cnt+ 1)
     WHERE (mpva.mp_primed_view_act_id=tempactdata->mp_primed_view_act_id)
     WITH nocounter
    ;end update
    IF (curqual > 0)
     COMMIT
    ELSE
     CALL log_message(build2("Update failed. activity_id: ",tempactdata->mp_primed_view_act_id),
      log_level_debug)
    ENDIF
   ENDIF
   IF ((tempactdata->mp_primed_view_act_id=0))
    SELECT INTO "nl:"
     z = seq(mpages_seq,nextval)
     FROM dual
     DETAIL
      tempactdata->mp_primed_view_act_id = z
     WITH format, counter
    ;end select
    IF (curqual=0)
     CALL echo(build2("Failed to retrieve sequence: ",tempactdata->mp_primed_view_act_id))
     RETURN(0)
    ENDIF
    CALL echo(build2("New Activity Sequence: ",tempactdata->mp_primed_view_act_id))
    INSERT  FROM mp_primed_view_act mpva
     SET mpva.data_blob = tempactdata->input_json_blob, mpva.mp_primed_view_act_id = tempactdata->
      mp_primed_view_act_id, mpva.mp_primed_view_ref_id = tempactdata->mp_primed_view_ref_id,
      mpva.person_id = tempactdata->person_id, mpva.encntr_id = tempactdata->encntr_id, mpva
      .load_dt_tm = cnvtdatetime(curdate,curtime3),
      mpva.updt_applctx = reqinfo->updt_applctx, mpva.updt_id = reqinfo->updt_id, mpva.updt_task =
      reqinfo->updt_task,
      mpva.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     COMMIT
    ELSE
     CALL log_message(build2("Insert failed. view_id: ",tempactdata->mp_primed_view_ref_id),
      log_level_debug)
    ENDIF
   ENDIF
   FREE SET temprefdata
   CALL log_message(build("Exit InsertDynPriData(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getlookbackdate(lookbackflags)
   CALL log_message("In GetLookBackDate()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE vclookbackunits = vc WITH noconstant(""), protect
   DECLARE vclookbackunitflag = vc WITH noconstant(""), protect
   DECLARE nlookbackunits = i4 WITH noconstant(0), protect
   DECLARE nlookbackunitflag = i4 WITH noconstant(0), protect
   DECLARE lookbackdate = dq8 WITH noconstant(cnvtdatetime("01-JAN-1800 00:00:00")), protect
   DECLARE lpos = i4 WITH noconstant(0), protect
   IF (size(lookbackflags) > 0)
    SET lpos = findstring(":",lookbackflags,1,0)
    CALL echo(build("location of :",lpos))
    IF (lpos > 0)
     SET vclookbackunits = substring(1,(lpos - 1),lookbackflags)
     SET vclookbackunitflag = substring((lpos+ 1),size(lookbackflags),lookbackflags)
     SET nlookbackunits = cnvtint(vclookbackunits)
     SET nlookbackunitflag = cnvtint(vclookbackunitflag)
     CALL echo(build2("nLookbackunits:",nlookbackunits))
     CALL echo(build2("nLookbackunitflag:",nlookbackunitflag))
     SET lookbackdate = getlookbackdatebytype(nlookbackunits,nlookbackunitflag)
    ENDIF
   ENDIF
   CALL log_message(build("Exit GetLookBackDate(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
   RETURN(lookbackdate)
 END ;Subroutine
 SUBROUTINE retrievedynpridatawklst(patientsrec,seqparam,retreiveobjectname,summarycomp,summaryview,
  blobreply_rec,personnelid)
   CALL log_message("In RetrieveDynPriDataWklst()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE y = i4 WITH noconstant(0), protect
   DECLARE z = i4 WITH noconstant(0), protect
   DECLARE prsnl_group_id = f8 WITH noconstant(0.0), protect
   DECLARE patientsrecsize = i4 WITH noconstant(size(patientsrec->pts,5)), protect
   DECLARE pendingerror = i2 WITH noconstant(0), protect
   DECLARE pind = i4 WITH noconstant(0), protect
   DECLARE remove_cnt = i4 WITH noconstant(0), protect
   FREE RECORD toremove
   RECORD toremove(
     1 person_list[*]
       2 person_id = f8
   )
   SET stat = alterlist(blobreply_rec->qual,patientsrecsize)
   SET blobreply_rec->cnt = patientsrecsize
   FOR (x = 1 TO patientsrecsize)
    SET blobreply_rec->qual[x].person_id = patientsrec->pts[x].person_id
    SET blobreply_rec->qual[x].encntr_id = patientsrec->pts[x].encntr_id
   ENDFOR
   SET x = 0
   SELECT INTO "nl:"
    FROM mp_primed_view_pop mdp,
     mp_primed_view_ref ref,
     mp_primed_view_act sact
    PLAN (mdp
     WHERE expand(x,1,patientsrecsize,mdp.person_id,patientsrec->pts[x].person_id)
      AND mdp.view_error_ind=0)
     JOIN (ref
     WHERE mdp.pop_parent_entity_id=ref.pop_parent_entity_id
      AND mdp.pop_name=ref.pop_name
      AND mdp.pop_parent_entity_name=ref.pop_parent_entity_name
      AND cnvtupper(ref.data_group_name)=cnvtupper(seqparam)
      AND cnvtupper(ref.data_object_name)=cnvtupper(retreiveobjectname)
      AND cnvtupper(ref.category_config_txt)=cnvtupper(summaryview)
      AND cnvtupper(ref.component_config_txt)=cnvtupper(summarycomp)
      AND ref.enabled_ind=1)
     JOIN (sact
     WHERE sact.mp_primed_view_ref_id=ref.mp_primed_view_ref_id
      AND sact.person_id=mdp.person_id
      AND expand(y,1,patientsrecsize,sact.encntr_id,patientsrec->pts[y].encntr_id))
    ORDER BY sact.person_id, sact.encntr_id, sact.load_dt_tm DESC
    HEAD REPORT
     outbuf = fillstring(32767," "), remove_cnt = 0
    HEAD sact.person_id
     IF (((sact.pending_updt_ind=0) OR (sact.pending_updt_ind=1
      AND sact.updt_dt_tm > cnvtlookbehind("2,MIN"))) )
      pendingerror = 0
     ELSE
      pendingerror = 1, remove_cnt = (remove_cnt+ 1), stat = alterlist(toremove->person_list,
       remove_cnt),
      toremove->person_list[remove_cnt].person_id = sact.person_id
     ENDIF
    HEAD sact.encntr_id
     IF (pendingerror=0)
      pos = locateval(z,1,patientsrecsize,mdp.person_id,patientsrec->pts[z].person_id)
      WHILE (pos != 0)
       blobreply_rec->qual[pos].isinpopind = 1,pos = locateval(z,(pos+ 1),patientsrecsize,mdp
        .person_id,patientsrec->pts[z].person_id)
      ENDWHILE
      pos = locateval(z,1,patientsrecsize,sact.encntr_id,patientsrec->pts[z].encntr_id,
       sact.person_id,patientsrec->pts[z].person_id)
      IF (pos > 0)
       blobreply_rec->qual[pos].data_retrieve_object_name = ref.data_object_name, blobreply_rec->
       qual[pos].data_retrieve_seq_param = ref.data_group_name, blobreply_rec->qual[pos].
       summary_component = ref.component_config_txt,
       blobreply_rec->qual[pos].summary_view = ref.category_config_txt, blobreply_rec->qual[pos].
       mp_primed_view_act_id = sact.mp_primed_view_act_id, blobreply_rec->qual[pos].last_updt_cnt =
       sact.updt_cnt,
       blobreply_rec->qual[pos].last_updt_dt_tm = sact.updt_dt_tm, blobreply_rec->qual[pos].person_id
        = sact.person_id, blobreply_rec->qual[pos].encntr_id = sact.encntr_id,
       offset = 0, retlen = 1
       WHILE (retlen > 0)
         retlen = blobget(outbuf,offset,sact.data_blob), offset = (offset+ retlen), blobreply_rec->
         qual[pos].value = notrim(concat(notrim(blobreply_rec->qual[pos].value),notrim(substring(1,
             retlen,outbuf))))
       ENDWHILE
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (remove_cnt > 0)
    FOR (pind = 1 TO remove_cnt)
      CALL removepersonfrompoptable(toremove->person_list[pind].person_id)
    ENDFOR
   ENDIF
   CALL log_message(build("Exit RetrieveDynPriDataWklst(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE removepersonfrompoptable(personid)
   CALL log_message("In RemovePersonFromPOPTable()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   UPDATE  FROM mp_primed_view_pop spop
    SET spop.view_error_ind = 1, spop.updt_applctx = reqinfo->updt_applctx, spop.updt_id = reqinfo->
     updt_id,
     spop.updt_task = reqinfo->updt_task, spop.updt_dt_tm = cnvtdatetime(curdate,curtime3), spop
     .updt_cnt = (spop.updt_cnt+ 1)
    WHERE spop.person_id=personid
    WITH nocounter
   ;end update
   IF (curqual > 0)
    CALL log_message(build2("set error indicator for patient: ",personid),log_level_debug)
    COMMIT
   ENDIF
   CALL log_message(build("Exit RemovePersonFromPOPTable(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE removepopulation(personid)
   CALL log_message("In RemovePopulation()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DELETE  FROM mp_primed_view_pop dpp
    WHERE dpp.person_id=personid
    WITH nocounter
   ;end delete
   IF (curqual > 0)
    DELETE  FROM mp_primed_view_act dpa
     WHERE dpa.person_id=personid
     WITH nocounter
    ;end delete
   ENDIF
   CALL log_message(build("Exit RemovePopulation(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getreportmeanids(pos_cd_list)
   CALL log_message("In GetReportMeanIds()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE num = i4 WITH noconstant(0), protect
   DECLARE num1 = i4 WITH noconstant(0), protect
   SET pos_cd_list->cnt = (pos_cd_list->cnt+ 1)
   SET stat = alterlist(pos_cd_list->qual,pos_cd_list->cnt)
   SET pos_cd_list->qual[pos_cd_list->cnt].value = 0.0
   RECORD default_report_ids(
     1 cnt = i4
     1 qual[*]
       2 value = f8
   )
   SELECT INTO "nl:"
    bdr.report_mean, bdr.br_datamart_report_id
    FROM br_datamart_category bdc,
     br_datamart_report bdr,
     br_datamart_report_filter_r bdrfr,
     br_datamart_filter bdf,
     br_datamart_value bdv,
     br_datamart_flex bdx,
     mp_primed_view_ref ref
    PLAN (ref
     WHERE ref.enabled_ind=1)
     JOIN (bdc
     WHERE bdc.category_mean=ref.category_config_txt)
     JOIN (bdr
     WHERE bdr.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdr.report_mean=ref.component_config_txt)
     JOIN (bdrfr
     WHERE bdrfr.br_datamart_report_id=bdr.br_datamart_report_id)
     JOIN (bdf
     WHERE bdf.filter_category_mean="MP_SECT_PARAMS"
      AND bdf.br_datamart_filter_id=bdrfr.br_datamart_filter_id)
     JOIN (bdv
     WHERE bdv.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdv.parent_entity_name="BR_DATAMART_REPORT"
      AND bdv.parent_entity_id=bdr.br_datamart_report_id
      AND bdv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (bdx
     WHERE bdx.br_datamart_flex_id=bdv.br_datamart_flex_id
      AND expand(num,1,pos_cd_list->cnt,bdx.parent_entity_id,pos_cd_list->qual[num].value))
    ORDER BY bdx.parent_entity_id, bdr.br_datamart_report_id
    HEAD REPORT
     idcnt = 0, defaultcnt = 0
    HEAD bdx.parent_entity_id
     IF (bdx.parent_entity_id != 0)
      pos = locateval(num1,1,pos_cd_list->cnt,bdx.parent_entity_id,pos_cd_list->qual[num1].value)
     ELSE
      idcnt = 0
     ENDIF
    HEAD bdr.br_datamart_report_id
     IF (bdx.parent_entity_id=0)
      defaultcnt = (defaultcnt+ 1), stat = alterlist(default_report_ids->qual,defaultcnt),
      default_report_ids->qual[defaultcnt].value = bdr.br_datamart_report_id
     ELSE
      idcnt = (idcnt+ 1), stat = alterlist(pos_cd_list->qual[pos].report_ids,idcnt), pos_cd_list->
      qual[pos].report_ids[idcnt].value = bdr.br_datamart_report_id
     ENDIF
    FOOT  bdx.parent_entity_id
     IF (bdx.parent_entity_id != 0)
      pos_cd_list->qual[pos].report_cnt = idcnt
     ELSE
      default_report_ids->cnt = defaultcnt
     ENDIF
    WITH nocounter
   ;end select
   IF ((default_report_ids->cnt > 0))
    FOR (num = 1 TO pos_cd_list->cnt)
      IF ((pos_cd_list->qual[num].report_cnt=0))
       SET stat = moverec(default_report_ids->qual,pos_cd_list->qual[num].report_ids)
       SET pos_cd_list->qual[num].report_cnt = default_report_ids->cnt
      ENDIF
    ENDFOR
   ENDIF
   SET pos_cd_list->cnt = (pos_cd_list->cnt - 1)
   SET stat = alterlist(pos_cd_list->qual,pos_cd_list->cnt)
   CALL log_message(build("Exit GetReportMeanIds(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getpositioncodes(pos_cd_list)
   CALL log_message("In GetPositionCodes()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SELECT INTO "nl:"
    FROM mp_primed_view_ref ref,
     prsnl pr
    PLAN (ref
     WHERE ref.enabled_ind=1)
     JOIN (pr
     WHERE pr.person_id=ref.proxy_prsnl_id)
    ORDER BY ref.proxy_prsnl_id
    HEAD REPORT
     pcnt = 0
    HEAD ref.proxy_prsnl_id
     pcnt = (pcnt+ 1), stat = alterlist(pos_cd_list->qual,pcnt), pos_cd_list->qual[pcnt].value = pr
     .position_cd
    FOOT REPORT
     pos_cd_list->cnt = pcnt
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetPositionCodes(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getallbrfilters(null)
   CALL log_message("In GetAllBrFilters()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE vcreportids = vc WITH noconstant(""), protect
   DECLARE vcparserstringutil = vc WITH noconstant(""), private
   DECLARE lloadcomponentdetails = i4 WITH noconstant(0.0), private
   DECLARE lloadcomponentbasics = i4 WITH noconstant(0.0), private
   DECLARE x = i4 WITH noconstant(0), private
   DECLARE y = i4 WITH noconstant(0), private
   FREE RECORD br_component_all
   RECORD br_component_all(
     1 component[*]
       2 br_datamart_filter_id = f8
       2 br_datamart_report_id = f8
       2 br_datamart_category_id = f8
       2 report_mean = vc
       2 filter_mean = vc
       2 label = vc
       2 link = vc
       2 group_seq = i4
       2 row_seq = i4
       2 col_seq = i4
       2 expanded = i2
       2 scroll_num = i4
       2 scroll_enabled = i2
       2 isplusadd = i2
       2 lookbackunits = i4
       2 lookbacktypeflag = i4
       2 scope = i2
       2 date_display_flag = i4
       2 filter[*]
         3 br_datamart_filter_id = f8
         3 filter_mean = vc
         3 filter_seq = i4
         3 filter_category_mean = vc
         3 filter_category_type_mean = vc
         3 codeset = f8
         3 values[*]
           4 parent_entity_id = f8
           4 parent_entity_name = vc
           4 cdf_meaning = vc
           4 group_seq = i4
           4 value_seq = i4
           4 freetext_desc = vc
           4 flex_id = f8
           4 value_type_flag = i4
           4 qualifier_flag = i2
       2 flex_ind = i2
       2 br_datamart_flex_id = f8
       2 br_datamart_value_id = f8
       2 theme = vc
       2 toggle_status = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   FREE RECORD pos_cd_list
   RECORD pos_cd_list(
     1 cnt = i4
     1 qual[*]
       2 value = f8
       2 report_cnt = i4
       2 report_ids[*]
         3 value = f8
   )
   CALL getpositioncodes(pos_cd_list)
   CALL getreportmeanids(pos_cd_list)
   SET lloadcomponentbasics = 1
   SET lloadcomponentdetails = 2
   SET stat = alterlist(br_component_pos->br_component_list,pos_cd_list->cnt)
   FOR (x = 1 TO pos_cd_list->cnt)
    SET stat = initrec(br_component)
    IF ((pos_cd_list->qual[x].report_cnt > 0))
     SET vcreportids = "value("
     FOR (y = 1 TO pos_cd_list->qual[x].report_cnt)
       SET vcreportids = build2(vcreportids,pos_cd_list->qual[x].report_ids[y].value,",")
     ENDFOR
     SET vcreportids = build2(replace(vcreportids,",","",2),")")
     CALL echo(vcreportids)
     SET vcparserstringutil = concat('execute mp_get_br_component "MINE",',vcreportids,",",trim(
       cnvtstring((lloadcomponentbasics+ lloadcomponentdetails)),3),",1,",
      trim(cnvtstring(pos_cd_list->qual[x].value,17,3),3),
      ' with replace("REPLY", "BR_COMPONENT_ALL") go ')
     CALL echo(build2("CALLING BR FILTERS:",vcparserstringutil))
     CALL parser(vcparserstringutil)
     SET br_component_pos->br_component_list[x].position_cd = pos_cd_list->qual[x].value
     SET stat = moverec(br_component_all->component,br_component_pos->br_component_list[x].component)
    ENDIF
   ENDFOR
   FREE RECORD br_component_all
   FREE RECORD pos_cd_list
   CALL log_message(build("Exit GetAllBrFilters(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getencounters(personid,prsnlid,encntr_rec)
   CALL log_message("In GetEncounters()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE x = i4 WITH noconstant(0), protect
   DECLARE num = i4 WITH noconstant(0), protect
   DECLARE prsnl_pos = i4 WITH noconstant(0), protect
   DECLARE person_pos = i4 WITH noconstant(0), protect
   DECLARE retrieve_encntrs = i4 WITH noconstant(0), protect
   DECLARE last_encntr_updt_dt_tm = dq8 WITH noconstant(0), protect
   SET prsnl_pos = locateval(num,1,dyn_pri_encntrs->prsnl_cnt,prsnlid,dyn_pri_encntrs->prsnl_list[num
    ].prsnl_id)
   IF (prsnl_pos=0)
    CALL log_message(build2("IN getencounters-dyn_pri_encntrs: ","PRSNL NOT FOUND"),log_level_debug)
    CALL log_message(cnvtstring(prsnlid),log_level_debug)
    SET dyn_pri_encntrs->prsnl_cnt = (dyn_pri_encntrs->prsnl_cnt+ 1)
    SET stat = alterlist(dyn_pri_encntrs->prsnl_list,dyn_pri_encntrs->prsnl_cnt)
    SET prsnl_pos = dyn_pri_encntrs->prsnl_cnt
    SET dyn_pri_encntrs->prsnl_list[prsnl_pos].prsnl_id = prsnlid
   ENDIF
   SET person_pos = locateval(num,1,dyn_pri_encntrs->prsnl_list[prsnl_pos].person_cnt,personid,
    dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[num].person_id)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE e.person_id=personid
    ORDER BY e.updt_dt_tm DESC
    HEAD REPORT
     last_encntr_updt_dt_tm = e.updt_dt_tm
    WITH nocounter
   ;end select
   IF (person_pos=0)
    SET retrieve_encntrs = 1
    SET dyn_pri_encntrs->prsnl_list[prsnl_pos].person_cnt = (dyn_pri_encntrs->prsnl_list[prsnl_pos].
    person_cnt+ 1)
    SET person_pos = dyn_pri_encntrs->prsnl_list[prsnl_pos].person_cnt
    SET stat = alterlist(dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list,person_pos)
    SET dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[person_pos].person_id = personid
    SET dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[person_pos].last_updt_dt_tm =
    last_encntr_updt_dt_tm
   ELSEIF (cnvtdatetime(last_encntr_updt_dt_tm) > cnvtdatetime(dyn_pri_encntrs->prsnl_list[prsnl_pos]
    .person_list[person_pos].last_updt_dt_tm))
    CALL echo(build2("last_encntr_updt_dt_tm:",cnvtdatetime(last_encntr_updt_dt_tm)))
    CALL echo(build2("last_updt_dt_tm:",cnvtdatetime(dyn_pri_encntrs->prsnl_list[prsnl_pos].
       person_list[person_pos].last_updt_dt_tm)))
    SET retrieve_encntrs = 1
    SET dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[person_pos].last_updt_dt_tm =
    last_encntr_updt_dt_tm
   ENDIF
   IF (retrieve_encntrs=1)
    CALL log_message(build2("IN getencounters-dyn_pri_encntrs: ","Refreshing"),log_level_debug)
    CALL log_message(cnvtstring(personid),log_level_debug)
    RECORD 115424_request(
      1 read_not_active_ind = i2
      1 read_not_effective_ind = i2
      1 person_qual[*]
        2 person_id = f8
      1 filters
        2 encntr_type_class_cds[*]
          3 encntr_type_class_cd = f8
        2 facility_cds[*]
          3 facility_cd = f8
        2 organization_ids[*]
          3 organization_id = f8
      1 skip_org_security_ind = i2
      1 user_id = f8
      1 debug_ind = i2
      1 debug
        2 org_security_level = i4
        2 lifetime_reltn_override_level = i4
        2 use_dynamic_security_ind = i2
        2 trust_id = f8
      1 load
        2 encntr_prsnl_reltns_ind = i2
    )
    RECORD 115424_reply(
      1 person_qual_cnt = i4
      1 person_qual[*]
        2 person_id = f8
        2 encounter_qual_cnt = i4
        2 encounter_qual[*]
          3 encounter_id = f8
          3 encounter_prsnl_reltn_qual[*]
            4 encntr_prsnl_reltn_id = f8
            4 encntr_prsnl_r_cd = f8
            4 beg_effective_dt_tm = dq8
            4 end_effective_dt_tm = dq8
        2 active_encounter_cnt = i4
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET stat = alterlist(115424_request->person_qual,1)
    SET 115424_request->person_qual[1].person_id = personid
    SET 115424_request->user_id = prsnlid
    EXECUTE pm_get_encounter_by_person  WITH replace("REQUEST","115424_REQUEST"), replace("REPLY",
     "115424_REPLY")
    IF ((115424_reply->person_qual_cnt=1))
     IF ((115424_reply->person_qual[1].encounter_qual_cnt > 0))
      SET stat = alterlist(dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list,
       115424_reply->person_qual[1].encounter_qual_cnt)
      SET dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_cnt = 115424_reply->
      person_qual[1].encounter_qual_cnt
      FOR (x = 1 TO 115424_reply->person_qual[1].encounter_qual_cnt)
        SET dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list[x].value =
        115424_reply->person_qual[1].encounter_qual[x].encounter_id
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
   SET dencntr_vc = cnvtrectojson(dyn_pri_encntrs)
   CALL log_message(build2("IN getencounters-dyn_pri_encntrs: ",dencntr_vc),log_level_debug)
   SET stat = moverec(dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_list,
    encntr_rec->qual)
   SET encntr_rec->cnt = dyn_pri_encntrs->prsnl_list[prsnl_pos].person_list[person_pos].encntr_cnt
   CALL log_message(build("Exit GetEncounters(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE enctrcleanup(personid,encntrid,viewid)
   CALL log_message("In EnctrCleanUp()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DELETE  FROM mp_primed_view_act act
    WHERE act.person_id=personid
     AND act.encntr_id=encntrid
     AND act.mp_primed_view_ref_id=viewid
    WITH nocounter
   ;end delete
   IF (curqual > 0)
    COMMIT
   ENDIF
   CALL log_message(build("Exit EnctrCleanUp(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE loadencounterorgconfid(null)
   CALL log_message("In LoadEncounterOrgConfid()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="SECURITY"
      AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
    DETAIL
     IF (di.info_name="SEC_ORG_RELTN"
      AND di.info_number=1)
      encntr_org_sec_ind = 1
     ELSEIF (di.info_name="SEC_CONFID"
      AND di.info_number=1)
      confid_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   SET encntr_org_confid_loaded = 1
   CALL log_message(build("Exit LoadEncounterOrgConfid(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE setpendingupdate(viewid,personid,encntrid,pendingind)
   CALL log_message("In SetPendingUpdate()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(curdate,curtime3)), private
   DECLARE npendingind = i2 WITH noconstant(0), protect
   DECLARE sencntrparam = vc WITH noconstant(""), protect
   DECLARE nupdateind = i2 WITH noconstant(0), protect
   CALL log_message(build2("pendingInd: ",pendingind),log_level_debug)
   SET npendingind = cnvtint(pendingind)
   IF (cnvtint(encntrid)=0)
    SET sencntrparam = "1=1"
   ELSE
    SET sencntrparam = build2("mda.encntr_id = ",cnvtint(encntrid))
   ENDIF
   CALL echo(build2("sEncntrParam: ",sencntrparam))
   SELECT INTO "nl:"
    FROM mp_primed_view_pop p
    WHERE p.person_id=personid
     AND p.view_error_ind=0
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET nupdateind = 1
   ENDIF
   IF (nupdateind=1)
    UPDATE  FROM mp_primed_view_act mda
     SET mda.pending_updt_ind = npendingind, mda.updt_applctx = reqinfo->updt_applctx, mda.updt_id =
      reqinfo->updt_id,
      mda.updt_task = reqinfo->updt_task, mda.updt_dt_tm = cnvtdatetime(curdate,curtime3), mda
      .updt_cnt = (mda.updt_cnt+ 1)
     PLAN (mda
      WHERE mda.mp_primed_view_ref_id=viewid
       AND mda.person_id=personid
       AND parser(sencntrparam))
     WITH nocounter
    ;end update
    IF (curqual > 0)
     COMMIT
    ENDIF
   ENDIF
   CALL log_message(build("Exit SetPendingUpdate(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(curdate,curtime3),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 DECLARE cleanuppastrows(null) = null WITH protect
 DECLARE startdttm = dq8 WITH protect
 CALL getallbrfilters(null)
 SET startdttm = cnvtdatetime(curdate,curtime3)
 SUBROUTINE cleanuppastrows(null)
   CALL log_message("Entering cleanup past rows",log_level_debug)
   DELETE  FROM mp_dpv_act act
    WHERE act.load_dt_tm < cnvtdatetime(startdttm)
    WITH nocounter
   ;end delete
   COMMIT
   CALL log_message(build2(curqual," Rows cleaned up"),log_level_debug)
   CALL log_message("Exiting cleanup past rows",log_level_debug)
 END ;Subroutine
#exit_script
END GO
