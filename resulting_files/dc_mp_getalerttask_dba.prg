CREATE PROGRAM dc_mp_getalerttask:dba
 PROMPT
  "Output to File/Printer/MINE                    " = "MINE",
  "Main category mean:                          " = "",
  "Person Id:                                   " = 0.0,
  "Encounter Id:                                " = 0.0,
  "Alert duration:                              " = 0.0,
  "Order Synonym ids:                           " = 0.0,
  "Order w/o tasks Synonym ids:                 " = 0.0
  WITH outdev, main_cat_mean, person_id,
  encntr_id, alert_duration, synonym_id_array,
  synonym_wo_tasks_id_array
 FREE SET filters_rec
 RECORD filters_rec(
   1 alert[*]
     2 link_address = vc
     2 display_name = vc
   1 lab_events[*]
     2 event_cd = vc
     2 seq_no = i4
   1 lab_events_lower[*]
     2 seq_no = i4
     2 ftxt = vc
     2 operator = vc
   1 lab_events_higher[*]
     2 seq_no = i4
     2 ftxt = vc
     2 operator = vc
   1 med_admin_event[*]
     2 event_cd = vc
     2 seq_no = i4
   1 med_admin_event_cnt[*]
     2 seq_no = i4
     2 ftxt = vc
     2 operator = vc
 )
 FREE SET record_data
 RECORD record_data(
   1 alertexistcnt = i4
   1 alertexistqual[*]
     2 alertexistlinkaddress = vc
     2 alertexistdisplayname = vc
     2 alertexistdatetime = vc
   1 ordercnt = i4
   1 orderqual[*]
     2 ordercv = f8
     2 orderdisp = vc
     2 orderclindisp = vc
     2 orderdtdisp = vc
     2 orderstopdtdisp = vc
   1 orderwocnt = i4
   1 orderwoqual[*]
     2 orderwocv = f8
     2 orderwodisp = vc
     2 orderwoclindisp = vc
     2 orderwodtdisp = vc
   1 medadmincnt = i4
   1 medadminqual[*]
     2 medadmincv = f8
     2 medadmindisp = vc
     2 medadminunit = vc
     2 medadminvalue = vc
     2 medadmindt = vc
   1 labeventcnt = i4
   1 labeventqual[*]
     2 labeventcv = f8
     2 labeventdisp = vc
     2 labeventunit = vc
     2 labeventvalue = vc
     2 labeventdt = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD order_alert_rec
 RECORD order_alert_rec(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 FREE RECORD order_alert_wo_tasks_rec
 RECORD order_alert_wo_tasks_rec(
   1 cnt = i4
   1 qual[*]
     2 value = f8
 )
 FREE RECORD med_admin_events_rec
 RECORD med_admin_events_rec(
   1 qual[*]
     2 medadmincv = f8
     2 medadmindisp = vc
     2 medadminunit = vc
     2 medadminvalue = vc
     2 medadmindt = vc
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
 DECLARE sscript_name = vc WITH protect, constant("dc_mp_getAlertTask")
 DECLARE script_version = vc WITH protect, noconstant(" ")
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE json_str = vc WITH protect
 DECLARE smprphsclinalerts = vc WITH protect, noconstant(trim( $2))
 DECLARE dpid = f8 WITH protect, noconstant(cnvtreal( $3))
 DECLARE deid = f8 WITH protect, noconstant(cnvtreal( $4))
 DECLARE slookback = vc WITH protect, noconstant(build( $ALERT_DURATION,",H"))
 DECLARE dauthcd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE dmodcd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE daltercd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE dactivecd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ACTIVE"))
 DECLARE dordered = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,nullterm("ORDERED")))
 DECLARE dactive_record_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dpharmacy_activity_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,
   "PHARMACY"))
 DECLARE dmed_event_class_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE errmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE getbrfilters(null) = vc
 DECLARE getdiscernexpertalerts(null) = i4
 DECLARE getorderalerts(null) = i4
 DECLARE getorderalertswithouttasks(null) = i4
 DECLARE getmedicationadministrationevents(null) = i4
 DECLARE getlabevents(null) = i4
 SET record_data->status_data.status = "F"
 CALL getparametervalues(6,order_alert_rec)
 CALL getparametervalues(7,order_alert_wo_tasks_rec)
 CALL getbrfilters(0)
 SET lstat = getdiscernexpertalerts(0)
 SET lstat = getorderalerts(0)
 SET lstat = getorderalertswithouttasks(0)
 SET lstat = getmedicationadministrationevents(0)
 SET lstat = getlabevents(0)
 SET record_data->status_data.status = "S"
 GO TO set_return
 SUBROUTINE getlabevents(null)
   DECLARE cesize = i4 WITH protect, noconstant(0)
   DECLARE lowsize = i4 WITH protect, noconstant(0)
   DECLARE highsize = i4 WITH protect, noconstant(0)
   DECLARE lcnt = i4 WITH protect, noconstant(0)
   DECLARE ceidx = i4 WITH protect, noconstant(0)
   DECLARE eventidx = i4 WITH protect, noconstant(0)
   DECLARE threshidx = i4 WITH protect, noconstant(0)
   DECLARE upidx = i4 WITH protect, noconstant(0)
   DECLARE lowidx = i4 WITH protect, noconstant(0)
   DECLARE eventseq = i4 WITH protect, noconstant(0)
   DECLARE eventqualifies = i2 WITH protect, noconstant(true)
   DECLARE upperqualifies = i2 WITH protect, noconstant(true)
   DECLARE lowerqualifies = i2 WITH protect, noconstant(true)
   DECLARE upperexists = i2 WITH protect, noconstant(false)
   DECLARE lowerexists = i2 WITH protect, noconstant(false)
   SET cesize = size(filters_rec->lab_events,5)
   SET lowsize = size(filters_rec->lab_events_lower,5)
   SET highsize = size(filters_rec->lab_events_higher,5)
   IF (cesize > 0)
    SELECT INTO "nl:"
     FROM clinical_event ce,
      order_catalog oc
     PLAN (ce
      WHERE ce.person_id=dpid
       AND expand(eventidx,1,cesize,ce.event_cd,cnvtreal(filters_rec->lab_events[eventidx].event_cd))
       AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
       AND ce.result_status_cd IN (dauthcd, dmodcd, daltercd, dactivecd)
       AND ce.result_val > " "
       AND ce.record_status_cd=dactive_record_status_cd
       AND ce.event_end_dt_tm BETWEEN cnvtlookbehind(slookback) AND cnvtdatetime(sysdate))
      JOIN (oc
      WHERE oc.catalog_cd=ce.catalog_cd)
     ORDER BY ce.person_id, ce.event_cd
     HEAD REPORT
      lcnt = 0
     DETAIL
      eventqualifies = true, upperqualifies = true, lowerqualifies = true,
      upperexists = false, lowerexists = false
      IF (((highsize > 0) OR (lowsize > 0)) )
       eventidx = locateval(ceidx,1,cesize,ce.event_cd,cnvtreal(filters_rec->lab_events[ceidx].
         event_cd)), eventseq = filters_rec->lab_events[eventidx].seq_no
       IF (highsize > 0)
        threshidx = locateval(upidx,1,highsize,eventseq,filters_rec->lab_events_higher[upidx].seq_no)
        IF (threshidx > 0)
         upperexists = true, upperqualifies = operator(cnvtreal(ce.result_val),trim(filters_rec->
           lab_events_higher[threshidx].operator),cnvtreal(trim(filters_rec->lab_events_higher[
            threshidx].ftxt)))
        ENDIF
       ENDIF
       IF (lowsize > 0)
        threshidx = locateval(lowidx,1,lowsize,eventseq,filters_rec->lab_events_lower[lowidx].seq_no)
        IF (threshidx > 0)
         lowerexists = true, lowerqualifies = operator(cnvtreal(ce.result_val),trim(filters_rec->
           lab_events_lower[threshidx].operator),cnvtreal(trim(filters_rec->lab_events_lower[
            threshidx].ftxt)))
        ENDIF
       ENDIF
      ENDIF
      IF (upperexists=true
       AND lowerexists=false)
       eventqualifies = upperqualifies
      ELSEIF (upperexists=false
       AND lowerexists=true)
       eventqualifies = lowerqualifies
      ELSEIF (upperexists=true
       AND lowerexists=true)
       eventqualifies = bor(upperqualifies,lowerqualifies)
      ENDIF
      IF (eventqualifies=true)
       lcnt += 1
       IF (size(record_data->labeventqual,5) < lcnt)
        lstat = alterlist(record_data->labeventqual,(lcnt+ 5))
       ENDIF
       record_data->labeventqual[lcnt].labeventcv = ce.event_cd
       IF (ce.order_id > 0
        AND ce.catalog_cd > 0
        AND oc.activity_type_cd=dpharmacy_activity_type_cd
        AND ce.event_class_cd=dmed_event_class_cd)
        record_data->labeventqual[lcnt].labeventdisp = trim(oc.primary_mnemonic)
       ELSE
        record_data->labeventqual[lcnt].labeventdisp = trim(uar_get_code_display(ce.event_cd))
       ENDIF
       record_data->labeventqual[lcnt].labeventunit = trim(uar_get_code_display(ce.result_units_cd)),
       record_data->labeventqual[lcnt].labeventvalue = trim(ce.result_val), record_data->
       labeventqual[lcnt].labeventdt = format(cnvtdatetimeutc(ce.event_end_dt_tm,3),
        "YYYY-MM-DDTHH:MM:SSZ;;Q")
      ENDIF
     FOOT REPORT
      lstat = alterlist(record_data->labeventqual,lcnt), record_data->labeventcnt = lcnt
     WITH nocounter
    ;end select
   ENDIF
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select (GetLabEvents):",errmsg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getmedicationadministrationevents(null)
   DECLARE mesize = i4 WITH protect, noconstant(0)
   DECLARE countsize = i4 WITH protect, noconstant(0)
   DECLARE qualifiedeventscount = i4 WITH protect, noconstant(0)
   DECLARE medadmineventidx = i4 WITH protect, noconstant(0)
   DECLARE medadmineventcountidx = i4 WITH protect, noconstant(0)
   DECLARE eventidx = i4 WITH protect, noconstant(0)
   DECLARE meidx = i4 WITH protect, noconstant(0)
   DECLARE mecntidx = i4 WITH protect, noconstant(0)
   DECLARE qualifiesevent = i2 WITH protect, noconstant(false)
   DECLARE ltempidx = i4 WITH protect, noconstant(0)
   DECLARE ltotalidx = i4 WITH protect, noconstant(0)
   SET mesize = size(filters_rec->med_admin_event,5)
   SET countsize = size(filters_rec->med_admin_event_cnt,5)
   SELECT INTO "nl:"
    ce.event_cd
    FROM clinical_event ce,
     order_catalog oc
    PLAN (ce
     WHERE expand(eventidx,1,mesize,ce.event_cd,cnvtreal(filters_rec->med_admin_event[eventidx].
       event_cd))
      AND ce.person_id=dpid
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100")
      AND ce.result_status_cd IN (dauthcd, dmodcd, daltercd, dactivecd)
      AND ce.result_val > " "
      AND ce.record_status_cd=dactive_record_status_cd
      AND ce.event_end_dt_tm BETWEEN cnvtlookbehind(slookback) AND cnvtdatetime(sysdate))
     JOIN (oc
     WHERE oc.catalog_cd=ce.catalog_cd)
    ORDER BY ce.event_cd, ce.event_id
    HEAD ce.event_cd
     lcnt = 0, meidx = 0, mecntidx = 0,
     ltempidx = 1, medadmineventcountidx = 0, qualifiesevent = false,
     medadmineventidx = locateval(meidx,1,mesize,ce.event_cd,cnvtreal(filters_rec->med_admin_event[
       meidx].event_cd))
     IF (medadmineventidx > 0)
      medadmineventcountidx = locateval(mecntidx,1,countsize,filters_rec->med_admin_event[
       medadmineventidx].seq_no,filters_rec->med_admin_event_cnt[mecntidx].seq_no)
     ENDIF
    DETAIL
     IF (medadmineventidx > 0)
      lcnt += 1, qualifiedeventscount += 1
      IF (size(med_admin_events_rec->qual,5) < lcnt)
       lstat = alterlist(med_admin_events_rec->qual,(lcnt+ 5))
      ENDIF
      IF (medadmineventcountidx=0)
       qualifiesevent = true
      ENDIF
      med_admin_events_rec->qual[lcnt].medadmincv = ce.event_cd
      IF (ce.order_id > 0
       AND ce.catalog_cd > 0
       AND oc.activity_type_cd=dpharmacy_activity_type_cd
       AND ce.event_class_cd=dmed_event_class_cd)
       med_admin_events_rec->qual[lcnt].medadmindisp = trim(oc.primary_mnemonic)
      ELSE
       med_admin_events_rec->qual[lcnt].medadmindisp = trim(uar_get_code_display(ce.event_cd))
      ENDIF
      med_admin_events_rec->qual[lcnt].medadminunit = trim(uar_get_code_display(ce.result_units_cd)),
      med_admin_events_rec->qual[lcnt].medadminvalue = trim(ce.result_val), med_admin_events_rec->
      qual[lcnt].medadmindt = format(cnvtdatetimeutc(ce.event_end_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;;Q")
     ENDIF
    FOOT  ce.event_cd
     IF (lcnt > 0
      AND medadmineventcountidx > 0)
      qualifiesevent = operator(cnvtreal(lcnt),trim(filters_rec->med_admin_event_cnt[
        medadmineventcountidx].operator),cnvtreal(trim(filters_rec->med_admin_event_cnt[
         medadmineventcountidx].ftxt)))
     ENDIF
     IF (qualifiesevent)
      IF (size(record_data->medadminqual,5) < qualifiedeventscount)
       lstat = alterlist(record_data->medadminqual,(qualifiedeventscount+ 5))
      ENDIF
      WHILE (ltempidx <= lcnt)
        ltotalidx += 1, record_data->medadminqual[ltotalidx].medadmincv = med_admin_events_rec->qual[
        ltempidx].medadmincv, record_data->medadminqual[ltotalidx].medadmindisp =
        med_admin_events_rec->qual[ltempidx].medadmindisp,
        record_data->medadminqual[ltotalidx].medadminunit = med_admin_events_rec->qual[ltempidx].
        medadminunit, record_data->medadminqual[ltotalidx].medadminvalue = med_admin_events_rec->
        qual[ltempidx].medadminvalue, record_data->medadminqual[ltotalidx].medadmindt =
        med_admin_events_rec->qual[ltempidx].medadmindt,
        ltempidx += 1
      ENDWHILE
     ELSE
      qualifiedeventscount -= lcnt
     ENDIF
     lstat = alterlist(med_admin_events_rec->qual,0)
    FOOT REPORT
     lstat = alterlist(record_data->medadminqual,qualifiedeventscount), record_data->medadmincnt =
     qualifiedeventscount
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select (GetMedicationAdministrationEvents):",errmsg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getorderalertswithouttasks(null)
   DECLARE ordsize = i4 WITH protect, noconstant(0)
   DECLARE ordidx = i4 WITH protect, noconstant(0)
   IF ((order_alert_wo_tasks_rec->cnt > 0))
    SET ordsize = order_alert_wo_tasks_rec->cnt
    SELECT INTO "nl:"
     FROM orders o
     PLAN (o
      WHERE o.person_id=dpid
       AND expand(ordidx,1,ordsize,o.synonym_id,order_alert_wo_tasks_rec->qual[ordidx].value)
       AND o.order_status_cd=cnvtreal(dordered)
       AND o.active_ind=1
       AND o.template_order_id=0
       AND o.updt_dt_tm <= cnvtdatetime(sysdate)
       AND o.orig_order_dt_tm BETWEEN cnvtlookbehind(slookback) AND cnvtdatetime(sysdate))
     ORDER BY o.person_id, o.ordered_as_mnemonic, o.orig_order_dt_tm DESC
     HEAD REPORT
      lcnt = 0
     DETAIL
      lcnt += 1
      IF (size(record_data->orderwoqual,5) < lcnt)
       lstat = alterlist(record_data->orderwoqual,(lcnt+ 5))
      ENDIF
      record_data->orderwoqual[lcnt].orderwocv = cnvtreal(o.catalog_cd), record_data->orderwoqual[
      lcnt].orderwodisp = trim(o.ordered_as_mnemonic), record_data->orderwoqual[lcnt].orderwoclindisp
       = trim(o.clinical_display_line),
      record_data->orderwoqual[lcnt].orderwodtdisp = format(cnvtdatetimeutc(o.orig_order_dt_tm,3),
       "YYYY-MM-DDTHH:MM:SSZ;;Q")
     FOOT REPORT
      lstat = alterlist(record_data->orderwoqual,lcnt), record_data->orderwocnt = lcnt
     WITH nocounter
    ;end select
   ENDIF
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select (GetOrderAlertsWithoutTasks):",errmsg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getorderalerts(null)
   DECLARE ordsize = i4 WITH protect, noconstant(0)
   DECLARE ordidx = i4 WITH protect, noconstant(0)
   IF ((order_alert_rec->cnt > 0))
    SET ordsize = order_alert_rec->cnt
    SELECT INTO "nl:"
     FROM orders o
     PLAN (o
      WHERE o.person_id=dpid
       AND expand(ordidx,1,ordsize,o.synonym_id,order_alert_rec->qual[ordidx].value)
       AND o.order_status_cd=cnvtreal(dordered)
       AND o.active_ind=1
       AND o.updt_dt_tm <= cnvtdatetime(sysdate)
       AND o.orig_order_dt_tm BETWEEN cnvtlookbehind(slookback) AND cnvtdatetime(sysdate))
     ORDER BY o.person_id, o.ordered_as_mnemonic, o.order_id
     HEAD REPORT
      lcnt = 0
     DETAIL
      lcnt += 1
      IF (size(record_data->orderqual,5) < lcnt)
       lstat = alterlist(record_data->orderqual,(lcnt+ 5))
      ENDIF
      record_data->orderqual[lcnt].ordercv = cnvtreal(o.catalog_cd), record_data->orderqual[lcnt].
      orderdisp = trim(o.ordered_as_mnemonic), record_data->orderqual[lcnt].orderclindisp = trim(o
       .clinical_display_line),
      record_data->orderqual[lcnt].orderdtdisp = format(cnvtdatetimeutc(o.orig_order_dt_tm,3),
       "YYYY-MM-DDTHH:MM:SSZ;;Q"), record_data->orderqual[lcnt].orderstopdtdisp = format(
       cnvtdatetimeutc(o.projected_stop_dt_tm,3),"YYYY-MM-DDTHH:MM:SSZ;;Q")
     FOOT REPORT
      lstat = alterlist(record_data->orderqual,lcnt), record_data->ordercnt = lcnt
     WITH nocounter
    ;end select
   ENDIF
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select (GetOrderAlerts):",errmsg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getdiscernexpertalerts(null)
   DECLARE linksize = i4 WITH protect, noconstant(0)
   SET linksize = size(filters_rec->alert,5)
   SELECT INTO "nl:"
    ede.person_id
    FROM (dummyt d1  WITH seq = linksize),
     eks_dlg_event ede
    PLAN (d1
     WHERE d1.seq <= linksize)
     JOIN (ede
     WHERE ede.person_id=dpid
      AND ede.active_ind=1
      AND ede.updt_dt_tm <= cnvtdatetime(sysdate)
      AND ede.dlg_dt_tm BETWEEN cnvtlookbehind(slookback) AND cnvtdatetime(sysdate))
    ORDER BY ede.person_id, ede.dlg_event_id
    HEAD REPORT
     lcnt = 0
    DETAIL
     linkaddress = trim(substring((findstring("!",cnvtlower(ede.modify_dlg_name))+ 1),size(cnvtlower(
         ede.modify_dlg_name),1),cnvtlower(ede.modify_dlg_name)))
     IF (trim(cnvtlower(linkaddress))=trim(cnvtlower(filters_rec->alert[d1.seq].link_address)))
      lcnt += 1
      IF (size(record_data->alertexistqual,5) < lcnt)
       lstat = alterlist(record_data->alertexistqual,(lcnt+ 5))
      ENDIF
      record_data->alertexistqual[lcnt].alertexistlinkaddress = trim(linkaddress), record_data->
      alertexistqual[lcnt].alertexistdisplayname = filters_rec->alert[d1.seq].display_name,
      record_data->alertexistqual[lcnt].alertexistdatetime = format(cnvtdatetimeutc(ede.dlg_dt_tm,3),
       "YYYY-MM-DDTHH:MM:SSZ;;Q")
     ENDIF
    FOOT REPORT
     lstat = alterlist(record_data->alertexistqual,lcnt), record_data->alertexistcnt = lcnt
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select (GetDiscernExpertAlerts):",errmsg)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getbrfilters(null)
   DECLARE bedrockjson = vc WITH protect, noconstant("")
   DECLARE jsonstat = i4 WITH protect, noconstant(0)
   IF (validate(request->blob_in,"") != "")
    SET bedrockjson = trim(request->blob_in,3)
   ENDIF
   SET jsonstat = cnvtjsontorec(bedrockjson)
   IF (jsonstat=0)
    CALL errorhandler("F","JSON Parsing failed","Syntax error while parsing Bedrock JSON blob")
   ENDIF
 END ;Subroutine
 SUBROUTINE (ajaxreply(jsonstr=vc) =null)
   IF (trim(jsonstr) != "")
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
    RECORD putreply(
      1 info_line[*]
        2 new_line = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET putrequest->source_dir =  $1
    SET putrequest->isblob = "1"
    SET putrequest->document_size = size(jsonstr)
    SET putrequest->document = jsonstr
    EXECUTE eks_put_source  WITH replace(request,"PUTREQUEST"), replace(reply,"PUTREPLY")
   ENDIF
 END ;Subroutine
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(record_data->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (record_data->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET lstat = alter(record_data->status_data.subeventstatus,error_cnt)
   ENDIF
   SET record_data->status_data.status = "F"
   SET record_data->status_data.subeventstatus[error_cnt].operationname = sscript_name
   SET record_data->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET record_data->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET record_data->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO set_return
 END ;Subroutine
#set_return
 SET json_str = trim(cnvtrectojson(record_data))
 CALL ajaxreply(json_str)
 CALL echo(json_str)
#exit_script
 SET script_version = "004 08/07/2023 AF075662"
 FREE SET record_data
 FREE SET filters_rec
END GO
