CREATE PROGRAM care_pathways_build_driver:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Debug Indicator" = 0,
  "Static Content Location" = "",
  "IE Version" = "10"
  WITH outdev, debug_ind, static_content_loc,
  ie_version
 DECLARE staticcontentlocation = vc WITH protect, noconstant("")
 FREE SET criterion
 RECORD criterion(
   1 static_content = vc
   1 locale_id = vc
   1 debug_ind = i2
   1 logical_domain_id = f8
   1 prsnl_id = f8
   1 nodes[*]
     2 node_name = vc
 )
 FREE RECORD concept_cds
 RECORD concept_cds(
   1 codes[*]
     2 code = f8
     2 sequence = i4
     2 display = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD intention_cds
 RECORD intention_cds(
   1 codes[*]
     2 code = f8
     2 display = vc
     2 meaning = vc
 )
 FREE RECORD concept_group_cds
 RECORD concept_group_cds(
   1 codes[*]
     2 code = f8
     2 display = vc
     2 meaning = vc
 )
 FREE RECORD attribute_type_cds
 RECORD attribute_type_cds(
   1 codes[*]
     2 code = f8
     2 display = vc
     2 meaning = vc
 )
 FREE RECORD pathway_type_cds
 RECORD pathway_type_cds(
   1 codes[*]
     2 code = f8
     2 display = vc
     2 meaning = vc
 )
 FREE RECORD treatment_line_type_cds
 RECORD treatment_line_type_cds(
   1 codes[*]
     2 code = f8
     2 display = vc
     2 meaning = vc
 )
 FREE RECORD component_type_cds
 RECORD component_type_cds(
   1 codes[*]
     2 code = f8
     2 display = vc
     2 meaning = vc
 )
 FREE RECORD component_detail_reltn_cds
 RECORD component_detail_reltn_cds(
   1 codes[*]
     2 code = f8
     2 display = vc
     2 meaning = vc
 )
 FREE RECORD supported_pathway_types
 RECORD supported_pathway_types(
   1 cnt = i4
   1 qual[*]
     2 meaning = vc
 )
 FREE RECORD supported_intention_types
 RECORD supported_intention_types(
   1 cnt = i4
   1 qual[*]
     2 meaning = vc
 )
 FREE RECORD comp_req
 RECORD comp_req(
   1 components[*]
     2 name = vc
     2 report_mean = vc
     2 comp_type_mean = vc
     2 standard = i2
     2 care_pathway_only = i2
 )
 FREE RECORD node_reply
 RECORD node_reply(
   1 operating_system = c3
   1 curuser_name = vc
   1 curuser_group = i2
   1 ccluser_group = i2
   1 hnam_location = vc
   1 cclrev = i4
   1 cclrevminor = i4
   1 cclrevminor2 = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 hosts[*]
     2 host_name = vc
   1 v500_read_dba = i2
   1 compile_mode_rdb = i2
 )
 FREE RECORD bedrock_components
 RECORD bedrock_components(
   1 cnt = i4
   1 qual[*]
     2 name = vc
     2 report_mean = vc
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
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH protect
 DECLARE class_begin_ts = dm12 WITH protect, constant(systimestamp)
 CREATE CLASS mp_i18n
 init
 IF (validate(debug_ind,0)=1)
  DECLARE PRIVATE::obj_create_start = dm12 WITH constant(systimestamp)
  CALL echo("BEGIN MP_I18N object creation")
 ENDIF
 RECORD PRIVATE::settings(
   1 i18nhandle = i4
   1 domainlocale = vc
   1 locale = vc
   1 langid = vc
   1 langlocaleid = vc
   1 logprgname = vc
   1 localeobjectname = vc
   1 localefilename = vc
   1 worklistfilename = vc
   1 localefilepath = vc
   1 worklistlocalefilepath = vc
 )
 DECLARE PRIVATE::overrideind = i2 WITH protect, noconstant(0)
 DECLARE PRIVATE::locidx = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_global_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_prsnl_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_all_global_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_all_prsnl_pos = i4 WITH protect, noconstant(0)
 DECLARE PRIVATE::override_prg_global_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_user_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_global_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_usr_str = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_global_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_prg_user_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_global_val = vc WITH noconstant("")
 DECLARE PRIVATE::override_all_usr_val = vc WITH noconstant("")
 DECLARE _::getdomainlocale(null) = vc
 DECLARE _::getlocale(null) = vc
 DECLARE _::getlangid(null) = vc
 DECLARE _::getlanglocaleid(null) = vc
 DECLARE _::getlocaleobjectname(null) = vc
 DECLARE _::getlocalefilename(null) = vc
 DECLARE _::getworklistfilename(null) = vc
 DECLARE _::getlogprgname(null) = vc
 DECLARE _::geti18nhandle(null) = i4
 DECLARE _::getlocalefilepath(null) = vc
 DECLARE _::getworklistlocalefilepath(null) = vc
 DECLARE _::dump(null) = null
 DECLARE _::generatemasks(null) = null
 SUBROUTINE _::generatemasks(null)
   FREE RECORD datetimeformats
   RECORD datetimeformats(
     1 formatters
       2 decimal_point = vc
       2 thousands_sep = vc
       2 grouping = vc
       2 dollar = vc
       2 time24hr = vc
       2 time24hrnosec = vc
       2 shortdate2yr = vc
       2 fulldate2yr = vc
       2 fulldate4yr = vc
       2 fullmonth4yrnodate = vc
       2 full4yr = vc
       2 fulldatetime2yr = vc
       2 fulldatetime4yr = vc
     1 dateformats
       2 shortdate = vc
       2 mediumdate = vc
       2 longdate = vc
       2 shortdatetime = vc
       2 mediumdatetime = vc
       2 longdatetime = vc
       2 timewithseconds = vc
       2 timenoseconds = vc
       2 weekdaynumber = vc
       2 weekdayabbrev = vc
       2 weekdayname = vc
       2 monthname = vc
       2 monthnumber = vc
       2 monthabbrev = vc
       2 shortdate4yr = vc
       2 mediumdate4yr = vc
       2 shortdatetimenosec = vc
       2 datetimecondensed = vc
       2 datecondensed = vc
       2 mediumdate4yr2 = vc
       2 default = vc
       2 short_date2 = vc
       2 short_date3 = vc
       2 short_date4 = vc
       2 short_date5 = vc
       2 medium_date = vc
       2 long_date = vc
       2 short_time = vc
       2 medium_time = vc
       2 military_time = vc
       2 iso_date = vc
       2 iso_time = vc
       2 iso_date_time = vc
       2 iso_utc_date_time = vc
       2 long_date_time2 = vc
       2 long_date_time3 = vc
       2 medium_date_no_year = vc
       2 month_year = vc
     1 weekmonthnames
       2 weekabbrev = vc
       2 weekfull = vc
       2 monthabbrev = vc
       2 monthfull = vc
   ) WITH persistscript
   SET datetimeformats->dateformats.longdate = replace(cclfmt->longdate,";;d","")
   SET datetimeformats->dateformats.longdatetime = replace(cclfmt->longdatetime,";3;d","")
   SET datetimeformats->dateformats.mediumdate = replace(cclfmt->mediumdate,";;d","")
   SET datetimeformats->dateformats.mediumdatetime = replace(cclfmt->mediumdatetime,";3;d","")
   SET datetimeformats->dateformats.shortdate = replace(cclfmt->shortdate,";;d","")
   SET datetimeformats->dateformats.shortdatetime = replace(cclfmt->shortdatetime,";3;d","")
   SET datetimeformats->dateformats.timenoseconds = replace(cclfmt->timenoseconds,";3;m","")
   SET datetimeformats->dateformats.timewithseconds = replace(cclfmt->timewithseconds,";3;m","")
   SET datetimeformats->dateformats.shortdate4yr = replace(cclfmt->shortdate4yr,";;d","")
   SET datetimeformats->dateformats.mediumdate4yr = replace(cclfmt->mediumdate4yr,";;d","")
   SET datetimeformats->dateformats.shortdatetimenosec = replace(cclfmt->shortdatetimenosec,";3;d",""
    )
   SET datetimeformats->dateformats.datetimecondensed = replace(cclfmt->datetimecondensed,";3;d","")
   SET datetimeformats->dateformats.datecondensed = replace(cclfmt->datecondensed,";;d","")
   IF (validate(cclfmt->mediumdate4yr2))
    SET datetimeformats->dateformats.mediumdate4yr2 = replace(cclfmt->mediumdate4yr2,";;d","")
   ELSE
    SET datetimeformats->dateformats.mediumdate4yr2 = replace(cclfmt->shortdate4yr,";;d","")
   ENDIF
   SET datetimeformats->dateformats.monthname = replace(cclfmt->monthname,";;d","")
   SET datetimeformats->dateformats.monthabbrev = replace(cclfmt->monthabbrev,";;d","")
   SET datetimeformats->dateformats.monthnumber = replace(cclfmt->monthnumber,";;d","")
   SET datetimeformats->dateformats.weekdayabbrev = replace(cclfmt->weekdayabbrev,";;d","")
   SET datetimeformats->dateformats.weekdayname = replace(cclfmt->weekdayname,";;d","")
   SET datetimeformats->dateformats.weekdaynumber = replace(cclfmt->weekdaynumber,";;d","")
   SET datetimeformats->formatters.thousands_sep = notrim(curlocale("THOUSAND"))
   SET datetimeformats->formatters.decimal_point = curlocale("DECIMAL")
   SET datetimeformats->formatters.dollar = curlocale("DOLLAR")
   SET datetimeformats->formatters.grouping = "3"
   SET datetimeformats->formatters.time24hr = "HH:mm:ss"
   SET datetimeformats->formatters.time24hrnosec = "HH:mm"
   SET datetimeformats->formatters.full4yr = "yyyy"
   SET datetimeformats->formatters.shortdate2yr = datetimeformats->dateformats.shortdate
   SET datetimeformats->formatters.fulldate2yr = datetimeformats->dateformats.shortdate
   SET datetimeformats->formatters.fulldate4yr = datetimeformats->dateformats.shortdate4yr
   SET datetimeformats->formatters.fullmonth4yrnodate = "MMM/yyyy"
   SET datetimeformats->formatters.fulldatetime2yr = build2(datetimeformats->dateformats.shortdate,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->formatters.fulldatetime4yr = build2(datetimeformats->dateformats.shortdate4yr,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.military_time = "HH:mm"
   SET datetimeformats->dateformats.iso_date = "yyyy-MM-dd"
   SET datetimeformats->dateformats.iso_time = "HH:mm:ss"
   SET datetimeformats->dateformats.iso_date_time = "yyyy-MM-dd'T'HH:mm:ss"
   SET datetimeformats->dateformats.iso_utc_date_time = "UTC:yyyy-MM-dd'T'HH:mm:ss'Z'"
   SET datetimeformats->dateformats.short_date5 = "yyyy"
   SET datetimeformats->dateformats.default = datetimeformats->dateformats.longdatetime
   SET datetimeformats->dateformats.short_date2 = datetimeformats->dateformats.shortdate4yr
   SET datetimeformats->dateformats.short_date3 = datetimeformats->dateformats.shortdate
   SET datetimeformats->dateformats.short_date4 = "MMM/yyyy"
   SET datetimeformats->dateformats.medium_date = datetimeformats->dateformats.mediumdate4yr2
   SET datetimeformats->dateformats.long_date = datetimeformats->dateformats.longdate
   SET datetimeformats->dateformats.short_time = datetimeformats->dateformats.timenoseconds
   SET datetimeformats->dateformats.medium_time = datetimeformats->dateformats.timewithseconds
   SET datetimeformats->dateformats.long_date_time2 = build2(datetimeformats->dateformats.shortdate,
    " ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.long_date_time3 = build2(datetimeformats->dateformats.
    shortdate4yr," ",datetimeformats->dateformats.timenoseconds)
   SET datetimeformats->dateformats.medium_date_no_year = "d mmm"
   SET datetimeformats->dateformats.month_year = "MAC. yyyy"
   SET datetimeformats->weekmonthnames.weekabbrev = curlocale("WEEKABBREV")
   SET datetimeformats->weekmonthnames.weekfull = curlocale("WEEKFULL")
   SET datetimeformats->weekmonthnames.monthabbrev = curlocale("MONTHABBREV")
   SET datetimeformats->weekmonthnames.monthfull = concat(format(cnvtdatetime("01-jan-2015"),
     "mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-feb-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime(
      "01-mar-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-apr-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-may-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-jun-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-jul-2015"),
     "mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-aug-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime(
      "01-sep-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-oct-2015"),"mmmmmmmmmmmm,;;q"),
    format(cnvtdatetime("01-nov-2015"),"mmmmmmmmmmmm,;;q"),format(cnvtdatetime("01-dec-2015"),
     "mmmmmmmmmmmm;;q"))
   IF (validate(debug_ind,0)=1)
    CALL echorecord(datetimeformats)
   ENDIF
 END ;Subroutine
 SUBROUTINE (_::setlocale(str=vc) =null)
   SET private::settings->locale = str
 END ;Subroutine
 SUBROUTINE (_::setlangid(str=vc) =null)
   SET private::settings->langid = str
 END ;Subroutine
 SUBROUTINE (_::setlanglocaleid(str=vc) =null)
   SET private::settings->langlocaleid = str
 END ;Subroutine
 SUBROUTINE (_::setlogprgname(str=vc) =null)
   SET private::settings->logprgname = str
 END ;Subroutine
 SUBROUTINE (_::setlocaleobjectname(str=vc) =null)
   SET private::settings->localeobjectname = str
 END ;Subroutine
 SUBROUTINE (_::setlocalefilename(str=vc) =null)
   SET private::settings->localefilename = str
 END ;Subroutine
 SUBROUTINE (_::setlocalefilepath(str=vc) =null)
   SET private::settings->localefilepath = str
 END ;Subroutine
 SUBROUTINE (_::setdomainlocale(str=vc) =null)
   SET private::settings->domainlocale = str
 END ;Subroutine
 SUBROUTINE (_::seti18nhandle(val=i4) =null)
   SET private::settings->i18nhandle = val
 END ;Subroutine
 SUBROUTINE (_::setworklistfilename(str=vc) =null)
   SET private::settings->worklistfilename = str
 END ;Subroutine
 SUBROUTINE (_::setworklistlocalefilepath(str=vc) =null)
   SET private::settings->worklistlocalefilepath = str
 END ;Subroutine
 SUBROUTINE _::getworklistfilename(null)
   RETURN(private::settings->worklistfilename)
 END ;Subroutine
 SUBROUTINE _::getlocale(null)
   RETURN(private::settings->locale)
 END ;Subroutine
 SUBROUTINE _::getlangid(null)
   RETURN(private::settings->langid)
 END ;Subroutine
 SUBROUTINE _::getlanglocaleid(null)
   RETURN(private::settings->langlocaleid)
 END ;Subroutine
 SUBROUTINE _::getlogprgname(null)
   RETURN(private::settings->logprgname)
 END ;Subroutine
 SUBROUTINE _::getdomainlocale(null)
   DECLARE tlocale = c5 WITH private, noconstant("     ")
   SET tlocale = cnvtupper(logical("CCL_LANG"))
   IF (tlocale=" ")
    SET tlocale = cnvtupper(logical("LANG"))
    IF (tlocale IN (" ", "C"))
     SET tlocale = "EN_US"
    ENDIF
   ENDIF
   CALL _::setdomainlocale(tlocale)
   RETURN(tlocale)
 END ;Subroutine
 SUBROUTINE _::getlocaleobjectname(null)
   RETURN(private::settings->localeobjectname)
 END ;Subroutine
 SUBROUTINE _::getlocalefilename(null)
   RETURN(private::settings->localefilename)
 END ;Subroutine
 SUBROUTINE _::getlocalefilepath(null)
   RETURN(private::settings->localefilepath)
 END ;Subroutine
 SUBROUTINE _::geti18nhandle(null)
   RETURN(private::settings->i18nhandle)
 END ;Subroutine
 SUBROUTINE _::getworklistlocalefilepath(null)
   RETURN(private::settings->worklistlocalefilepath)
 END ;Subroutine
 SUBROUTINE (_::initlocale(str=vc) =null)
   DECLARE tlangid = vc WITH private, noconstant("")
   DECLARE tlanglocaleid = vc WITH private, noconstant("")
   CALL _::setlocale(trim(str,3))
   IF (textlen(_::getlocale(null))=0)
    CALL _::setlocale(_::getdomainlocale(null))
   ELSE
    IF (validate(debug_ind,0)=1)
     CALL echo(build2("Current Domain locale value: ",_::getdomainlocale(null)))
     CALL echo(build2("Overriding locale to: ",str))
    ENDIF
    SET PRIVATE::overrideind = 1
   ENDIF
   CALL _::setlangid(cnvtlower(substring(1,2,_::getlocale(null))))
   CALL _::setlanglocaleid(cnvtupper(substring(4,2,_::getlocale(null))))
   SET tlangid = _::getlangid(null)
   SET tlanglocaleid = _::getlanglocaleid(null)
   CASE (tlangid)
    OF "en":
     CALL _::setlocalefilename("locale")
     CALL _::setlocaleobjectname("en_US")
     IF (((cnvtupper(_::getlocale(null))="EN_AU") OR (cnvtupper(_::getlocale(null))="EN_GB")) )
      CALL _::setlocaleobjectname(concat(tlangid,"_",tlanglocaleid))
      CALL _::setlocalefilename(concat("locale.",tlangid,"_",tlanglocaleid))
      CALL _::setworklistfilename(concat(cnvtupper(tlangid),"_",cnvtupper(tlanglocaleid)))
     ELSE
      CALL _::setworklistfilename("EN_US")
     ENDIF
    OF "es":
    OF "de":
    OF "fr":
    OF "pt":
     CALL _::setlocalefilename(concat("locale.",tlangid))
     CALL _::setlocaleobjectname(concat(tlangid,"_",tlanglocaleid))
     IF (cnvtupper(tlangid)="PT")
      CALL _::setworklistfilename("PT_BR")
     ELSE
      CALL _::setworklistfilename(concat(cnvtupper(tlangid),"_",cnvtupper(tlangid)))
     ENDIF
    ELSE
     CALL _::setlocalefilename("locale")
     CALL _::setlocaleobjectname("en_US")
     CALL _::setworklistfilename("EN_US")
   ENDCASE
   IF ((PRIVATE::overrideind=0))
    CALL uar_i18nlocalizationinit(i18nhandle,nullterm(curprog),nullterm(""),curcclrev)
    CALL _::seti18nhandle(i18nhandle)
   ELSE
    CALL uar_i18nlocalizationinit(i18nhandle,nullterm(curprog),nullterm(_::getlocale(null)),curcclrev
     )
    CALL _::seti18nhandle(i18nhandle)
    IF (validate(debug_ind,0)=1)
     CALL echo("**** OVERRIDING VALUES IN CCLFMT ****")
     CALL echo("CCLFMT BEFORE OVERRIDE:")
     CALL echorecord(cclfmt)
    ENDIF
    EXECUTE cclstartup_locale _::getlocale(null)
    IF (validate(debug_ind,0)=1)
     CALL echo("CCLFMT AFTER OVERRIDE:")
     CALL echorecord(cclfmt)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE _::dump(null)
   CALL echorecord(PRIVATE::settings)
 END ;Subroutine
 IF (validate(log_program_name))
  CALL _::setlogprgname(log_program_name)
 ELSE
  CALL _::setlogprgname(curprog)
 ENDIF
 IF (validate(_mp_18n_override))
  IF (validate(debug_ind,0)=1)
   CALL echorecord(_mp_18n_override)
  ENDIF
  SET PRIVATE::override_prg_global_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5
    ),cnvtupper(_::getlogprgname(null)),cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   0.0,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_prg_prsnl_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5),
   cnvtupper(_::getlogprgname(null)),cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   reqinfo->updt_id,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_all_global_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5
    ),"ALL",cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   0.0,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  SET PRIVATE::override_all_prsnl_pos = locateval(PRIVATE::locidx,1,size(_mp_18n_override->scripts,5),
   "ALL",cnvtupper(_mp_18n_override->scripts[PRIVATE::locidx].name),
   reqinfo->updt_id,_mp_18n_override->scripts[PRIVATE::locidx].prsnl_id)
  IF ((PRIVATE::override_prg_prsnl_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_prsnl_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_all_prsnl_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_prsnl_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_prg_global_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_prg_global_pos].
     worklistlocalefile)
   ENDIF
  ELSEIF ((PRIVATE::override_all_global_pos > 0))
   CALL _::setlocale(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].locale)
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].localefile))
    CALL _::setlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].localefile)
   ENDIF
   IF (validate(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].worklistlocalefile))
    CALL _::setworklistlocalefilepath(_mp_18n_override->scripts[PRIVATE::override_all_global_pos].
     worklistlocalefile)
   ENDIF
  ENDIF
 ENDIF
 CALL _::initlocale(_::getlocale(null))
 IF (checkfun("LOG_MESSAGE")=7)
  CALL log_message(concat("-mp_i18n Locale file name: ",_::getlocalefilename(null)),log_level_debug)
  CALL log_message(concat("-mp_i18n Worklist Locale file name: ",_::getworklistfilename(null)),
   log_level_debug)
  CALL log_message(concat("-mp_i18n Locale object name: ",_::getlocaleobjectname(null)),
   log_level_debug)
 ENDIF
 IF (validate(debug_ind,0)=1)
  CALL echo(concat("END MP_I18N object creation, Elapsed time:",cnvtstring(timestampdiff(systimestamp,
      class_begin_ts),17,4)))
  CALL _::dump(null)
 ENDIF
 END; class scope:init
 final
 IF ((PRIVATE::overrideind=1))
  EXECUTE cclstartup_locale _::getdomainlocale(null)
  IF (checkprg("CCLSTARTUP_CUSTREFLOG") > 0)
   EXECUTE cclstartup_custreflog
  ENDIF
  IF (validate(debug_ind,0)=1)
   CALL echo("**** REVERTED OVERRIDDEN VALUES IN CCLFMT ****")
   CALL echo("CCLFMT AFTER OVERRIDE REVERT:")
   CALL echorecord(cclfmt)
  ENDIF
 ENDIF
 END; class scope:final
 WITH copy = 0
 DECLARE MP::i18n = null WITH class(mp_i18n)
 DECLARE getlocaledata(null) = null WITH protect
 DECLARE getstaticcontentlocation(null) = null WITH protect
 DECLARE generatepagehtml(null) = vc WITH protect
 DECLARE getuserinfo(null) = null WITH protect
 DECLARE retrievenodenames(null) = null WITH protect
 DECLARE getcomponentsavailableinbedrock(null) = null WITH protect
 DECLARE localefilename = vc WITH noconstant(""), protect
 DECLARE localeobjectname = vc WITH noconstant(""), protect
 DECLARE build_tool_static_content = vc WITH protect, constant("care-pathways-build-tool")
 DECLARE ssmart_comp_mean = vc WITH protect, constant("SMART_COMP")
 DECLARE iintentioncodeset = i4 WITH protect, constant(4003278)
 DECLARE iconceptgroupcodeset = i4 WITH protect, constant(4003133)
 DECLARE idetailattributetypecodeset = i4 WITH protect, constant(4003333)
 DECLARE ipathwaytypecodeset = i4 WITH protect, constant(4003197)
 DECLARE itreatmentlinetypecodeset = i4 WITH protect, constant(4003313)
 DECLARE icomponenttypecodeset = i4 WITH protect, constant(4003130)
 DECLARE icomponentdetailreltncodeset = i4 WITH protect, constant(4003134)
 DECLARE ieversion = vc WITH protect, noconstant( $IE_VERSION)
 DECLARE sieversiontag = vc WITH protect, noconstant("")
 DECLARE debug_ind = i2 WITH protect, constant( $DEBUG_IND)
 DECLARE comprecfilename = vc WITH protect, constant("pathway_to_bedrock_comp_records.json")
 SET criterion->locale_id = ""
 SET criterion->debug_ind = btest( $DEBUG_IND,0)
 CALL loadsupportedtyperecords(null)
 CALL getuserinfo(null)
 IF (textlen(trim( $STATIC_CONTENT_LOC,3))=0)
  CALL getstaticcontentlocation(null)
 ELSE
  SET criterion->static_content =  $STATIC_CONTENT_LOC
 ENDIF
 IF (ieversion="")
  SET ieversion = "10"
 ENDIF
 CALL getlocaledata(null)
 CALL getcomponentsavailableinbedrock(null)
 IF (validate(debug_ind,0)=1)
  CALL echorecord(bedrock_components)
 ENDIF
 EXECUTE cp_get_concept_list "NOFORMS" WITH replace("REPORT_DATA","CONCEPT_CDS")
 CALL retrievcodevalues(intention_cds,iintentioncodeset)
 CALL retrievcodevalues(concept_group_cds,iconceptgroupcodeset)
 CALL retrievcodevalues(attribute_type_cds,idetailattributetypecodeset)
 CALL retrievcodevalues(pathway_type_cds,ipathwaytypecodeset)
 CALL retrievcodevalues(treatment_line_type_cds,itreatmentlinetypecodeset)
 CALL retrievcodevalues(component_type_cds,icomponenttypecodeset)
 CALL retrievcodevalues(component_detail_reltn_cds,icomponentdetailreltncodeset)
 CALL retrievenodenames(null)
 CALL generatepagehtml(null)
 SUBROUTINE loadsupportedtyperecords(null)
   CALL log_message("Begin loadSupportedTypeRecords()",log_level_debug)
   DECLARE begin_curtime3 = dq8 WITH constant(curtime3), private
   DECLARE legacydebug_cd = f8 WITH constant(uar_get_code_by("MEANING",4003197,"LEGACYDEBUG")),
   protect
   DECLARE emergevent_cd = f8 WITH constant(uar_get_code_by("MEANING",4003197,"EMERGEVENT")), protect
   DECLARE guidedsched_cd = f8 WITH constant(uar_get_code_by("MEANING",4003197,"GUIDEDSCHED")),
   protect
   DECLARE guidedsched_prg_exists = i2 WITH noconstant(0), protect
   SET supported_pathway_types->cnt = 2
   SET stat = alterlist(supported_pathway_types->qual,supported_pathway_types->cnt)
   SET supported_pathway_types->qual[1].meaning = "ONCOLOGY"
   SET supported_pathway_types->qual[2].meaning = "CPM"
   IF (legacydebug_cd > 0.0)
    SET supported_pathway_types->cnt += 1
    SET stat = alterlist(supported_pathway_types->qual,supported_pathway_types->cnt)
    SET supported_pathway_types->qual[supported_pathway_types->cnt].meaning = "LEGACYDEBUG"
   ENDIF
   IF (emergevent_cd > 0.0)
    SET supported_pathway_types->cnt += 1
    SET stat = alterlist(supported_pathway_types->qual,supported_pathway_types->cnt)
    SET supported_pathway_types->qual[supported_pathway_types->cnt].meaning = "EMERGEVENT"
   ENDIF
   SET guidedsched_prg_exists = checkprg("SCH_STRUCTURED_DOC_BUILD_DATA:DBA")
   IF (guidedsched_cd > 0.0
    AND guidedsched_prg_exists > 0)
    SET supported_pathway_types->cnt += 1
    SET stat = alterlist(supported_pathway_types->qual,supported_pathway_types->cnt)
    SET supported_pathway_types->qual[supported_pathway_types->cnt].meaning = "GUIDEDSCHED"
   ENDIF
   SET supported_intention_types->cnt = 3
   SET stat = alterlist(supported_intention_types->qual,supported_intention_types->cnt)
   SET supported_intention_types->qual[1].meaning = "ASSESSMENT"
   SET supported_intention_types->qual[2].meaning = "TREATMENTS"
   SET supported_intention_types->qual[3].meaning = "REASSESSMENT"
   RECORD getreply(
     1 info_line[*]
       2 new_line = vc
     1 data_blob = gvc
     1 data_blob_size = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   RECORD getrequest(
     1 module_dir = vc
     1 module_name = vc
     1 basblob = i2
   )
   SET getrequest->module_dir = "CER_INSTALL:"
   SET getrequest->module_name = comprecfilename
   SET getrequest->basblob = 1
   EXECUTE eks_get_source  WITH replace(request,getrequest), replace(reply,getreply)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(getrequest)
    CALL echorecord(getreply)
   ENDIF
   SET stat = cnvtjsontorec(getreply->data_blob)
   IF (validate(debug_ind,0)=1)
    CALL echorecord(supported_pathway_types)
    CALL echorecord(supported_intention_types)
    CALL echorecord(comp_req)
   ENDIF
   CALL log_message(build("Exit loadSupportedTypeRecords(), Elapsed time in seconds:",((curtime3 -
     begin_curtime3)/ 100.0)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getstaticcontentlocation(null)
   DECLARE contentserverurl = vc WITH protect, noconstant("")
   DECLARE winintelprefix = vc WITH protect, noconstant("")
   IF (size(trim(criterion->static_content,3)) != 0)
    RETURN
   ENDIF
   DECLARE subtimer = dq8 WITH constant(curtime3), private
   SELECT INTO "nl:"
    FROM dm_info d
    WHERE d.info_domain="INS"
     AND d.info_name IN ("FE_WH", "CONTENT_SERVICE_URL")
    ORDER BY d.info_name
    HEAD REPORT
     IF (d.info_name="CONTENT_SERVICE_URL")
      contentserverurl = build2(trim(d.info_char,3),"/",build_tool_static_content)
     ELSE
      IF (findstring("WININTEL",cnvtupper(d.info_char))=0)
       winintelprefix = "/winintel"
      ENDIF
      contentserverurl = build2(trim(d.info_char,3),trim(winintelprefix,3),"/static_content/",
       build_tool_static_content)
     ENDIF
     criterion->static_content = contentserverurl
    WITH nocounter
   ;end select
   CALL log_message(build("GetStaticContentLocation server query, Elapsed time:",((curtime3 -
     subtimer)/ 100.0)),log_level_debug)
   IF (contentserverurl="")
    SET _memory_reply_string =
    "No Static Content passed to script or defined in CONTENT_SERVICE_URL or FE_WH"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getuserinfo(null)
   CALL log_message("In GetUserInfo()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   SELECT INTO "nl:"
    FROM person p
    WHERE (p.person_id=reqinfo->updt_id)
    DETAIL
     criterion->prsnl_id = p.person_id, criterion->logical_domain_id = p.logical_domain_id
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetUserInfo(), Elapsed time in seconds:",((curtime3 - begin_date_time
     )/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getlocaledata(null)
   CALL log_message("In GetLocaleData()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE locale = vc WITH protect, noconstant("")
   DECLARE lang_id = vc WITH noconstant(""), protect
   DECLARE lang_locale_id = vc WITH noconstant(""), protect
   SET criterion->locale_id = MP::i18n.getlocale(null)
   SET lang_id = cnvtlower(substring(1,2,criterion->locale_id))
   SET lang_locale_id = cnvtlower(substring(4,2,criterion->locale_id))
   CASE (lang_id)
    OF "en":
     IF (lang_locale_id="au")
      SET localefilename = "en_au/locale"
      SET localeobjectname = "en_AU"
     ELSEIF (lang_locale_id="gb")
      SET localefilename = "en_gb/locale"
      SET localeobjectname = "en_GB"
     ELSE
      SET localefilename = "locale"
      SET localeobjectname = "en_US"
     ENDIF
    OF "es":
     SET localefilename = "es/locale"
     SET localeobjectname = "es_ES"
    OF "de":
     SET localefilename = "de/locale"
     SET localeobjectname = "de_DE"
    OF "fr":
     SET localefilename = "fr/locale"
     SET localeobjectname = "fr_FR"
    OF "pt":
     SET localefilename = "pt_br/locale"
     SET localeobjectname = "pt_BR"
    ELSE
     SET localefilename = "locale"
     SET localeobjectname = "en_US"
   ENDCASE
   CALL log_message(build("Exit GetLocaleData(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE getcomponentsavailableinbedrock(null)
   CALL log_message("In GetComponentsAvailableInBedrock()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE comp_cntr = i4 WITH protect, noconstant(0)
   DECLARE comp_size = i4 WITH protect, constant(size(comp_req->components,5))
   SELECT INTO "nl:"
    FROM br_datamart_report bdr
    PLAN (bdr
     WHERE expand(comp_cntr,1,comp_size,bdr.report_mean,comp_req->components[comp_cntr].report_mean))
    ORDER BY bdr.report_mean
    HEAD bdr.report_mean
     bedrock_components->cnt += 1, stat = alterlist(bedrock_components->qual,bedrock_components->cnt),
     bedrock_components->qual[bedrock_components->cnt].report_mean = bdr.report_mean,
     bedrock_components->qual[bedrock_components->cnt].name = bdr.report_name
    WITH nocounter
   ;end select
   CALL log_message(build("Exit GetComponentsAvailableInBedrock(), Elapsed time in seconds:",((
     curtime3 - begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (retrievcodevalues(rec=vc(ref),cs=i4) =i4 WITH protect)
   CALL log_message("In RetrievCodeValues()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(curtime3), private
   DECLARE suberror = i2 WITH private, noconstant(0)
   DECLARE qualind = i2 WITH protect, noconstant(0)
   DECLARE searchcntr = i4 WITH protect, noconstant(0)
   DECLARE compindex = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    disp_key = substring(1,40,cv.display_key)
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=cs
      AND cv.active_ind=1)
    ORDER BY disp_key
    HEAD REPORT
     code_cnt = 0
    DETAIL
     qualind = 0
     CASE (cs)
      OF ipathwaytypecodeset:
       IF (locateval(searchcntr,1,supported_pathway_types->cnt,cv.cdf_meaning,supported_pathway_types
        ->qual[searchcntr].meaning))
        qualind = 1
       ENDIF
      OF iintentioncodeset:
       IF (locateval(searchcntr,1,supported_intention_types->cnt,cv.cdf_meaning,
        supported_intention_types->qual[searchcntr].meaning))
        qualind = 1
       ENDIF
      OF icomponenttypecodeset:
       compindex = locateval(searchcntr,1,size(comp_req->components,5),cv.cdf_meaning,comp_req->
        components[searchcntr].comp_type_mean),
       IF ( NOT (cv.cdf_meaning IN ("PW_GS_QUESTION"))
        AND compindex > 0
        AND locateval(searchcntr,1,bedrock_components->cnt,comp_req->components[compindex].
        report_mean,bedrock_components->qual[searchcntr].report_mean))
        qualind = 1
       ENDIF
      ELSE
       qualind = 1
     ENDCASE
     IF (qualind)
      code_cnt += 1
      IF (code_cnt > size(rec->codes,5))
       stat = alterlist(rec->codes,(code_cnt+ 9))
      ENDIF
      rec->codes[code_cnt].code = cv.code_value, rec->codes[code_cnt].display = cv.display, rec->
      codes[code_cnt].meaning = cv.cdf_meaning
     ENDIF
    FOOT REPORT
     stat = alterlist(rec->codes,code_cnt)
    WITH nocounter
   ;end select
   CALL log_message(build("Exit RetrievCodeValues(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE generatepagehtml(null)
   CALL log_message("In GeneratePageHTML()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH private, constant(curtime3)
   DECLARE cconstructedhtml = vc WITH protect, noconstant("")
   DECLARE clivereloadjs = vc WITH protect, noconstant("")
   DECLARE localefilepath = vc WITH protect, noconstant("")
   IF (validate(debug_ind,0)=1)
    SET clivereloadjs = '<script src="//localhost:35729/livereload.js"></script>'
   ENDIF
   SET sieversiontag = build2('<meta http-equiv="X-UA-Compatible" content="IE=',trim(replace(
      ieversion,"@44@",","),3),'">')
   SET localefilepath = trim(MP::i18n.getlocalefilepath(null),3)
   IF (localefilepath="")
    SET localefilepath = build2(criterion->static_content,"/js/locale/",localefilename,".js")
   ENDIF
   SET cconstructedhtml = build2("<!doctype html>",'<html id="ng-app" lang="en">',"<head>",
    '<title ng-attr-placeholder="{{ i18n.CONCEPT_BUILD_TOOL }}"></title>',sieversiontag,
    '<meta http-equiv="Content-Type" content="APPLINK,CCLLINK,MPAGES_EVENT,XMLCCLREQUEST,',
    'CCLLINKPOPUP,CCLNEWSESSIONWINDOW,MPAGES_SVC_EVENT" name="discern">',
    '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">',
    '	<link rel="stylesheet" href="',criterion->static_content,
    "/css/",build_tool_static_content,'.css"/>','	<script type="text/javascript">',"		var jsCrit = ",
    cnvtrectojson(criterion),";","		var jsConcepts = ",cnvtrectojson(concept_cds),";",
    "		var jsIntentions = ",cnvtrectojson(intention_cds),";","		var jsConceptGroupCds = ",
    cnvtrectojson(concept_group_cds),
    ";","		var jsAttributeTypeCds = ",cnvtrectojson(attribute_type_cds),";",
    "		var jsPathwayTypeCds = ",
    cnvtrectojson(pathway_type_cds),";","		var jsTreatmentLineTypeCds = ",cnvtrectojson(
     treatment_line_type_cds),";",
    "		var jsComponentTypeCds = ",cnvtrectojson(component_type_cds),";",
    "   var jsComponentDetailReltnCds = ",cnvtrectojson(component_detail_reltn_cds),
    ";","	</script>",'	<script type="text/javascript" src="',localefilepath,'"></script>',
    '	<script src="',criterion->static_content,"/js/",build_tool_static_content,'.js"></script>',
    '	<script type="text/javascript" src="',criterion->static_content,'/js/plugins.js"></script>',
    clivereloadjs,"</head>",
    "<body ng-app='navigator'>","   <contains-format/>","</body>","</html>")
   IF (validate(debug_ind,0)=1)
    CALL echo("**** Generated HTML is defined as follows ****")
    CALL echo(cconstructedhtml)
   ENDIF
   CALL putstringtofile(cconstructedhtml)
   CALL log_message(build("Exit GeneratePageHTML(), Elapsed time in seconds:",((curtime3 -
     begin_date_time)/ 100)),log_level_debug)
 END ;Subroutine
 SUBROUTINE retrievenodenames(null)
   EXECUTE eks_get_sysinfo  WITH replace("REPLY","NODE_REPLY")
   IF (validate(debug_ind,0)=1)
    CALL echorecord(node_reply)
   ENDIF
   SET idx = 1
   SET stat = alterlist(criterion->nodes,size(node_reply->hosts,5))
   FOR (idx = 1 TO size(node_reply->hosts,5))
     SET criterion->nodes[idx].node_name = node_reply->hosts[idx].host_name
   ENDFOR
 END ;Subroutine
#exit_script
 IF (validate(debug_ind,0)=1)
  CALL echorecord(criterion)
  CALL echorecord(concept_cds)
  CALL echorecord(intention_cds)
  CALL echorecord(concept_group_cds)
  CALL echorecord(attribute_type_cds)
  CALL echorecord(pathway_type_cds)
  CALL echorecord(treatment_line_type_cds)
  CALL echorecord(component_type_cds)
 ENDIF
 FREE RECORD criterion
 FREE RECORD concept_cds
 FREE RECORD treatment_line_cds
END GO
