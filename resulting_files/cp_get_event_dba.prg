CREATE PROGRAM cp_get_event:dba
 DECLARE uar_fmt_accession(p1,p2) = c25
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
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
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
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
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
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
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
 SET log_program_name = "CP_GET_EVENT"
 RECORD reply(
   1 rb_list[1]
     2 event_list[1]
       3 event_id = f8
       3 order_id = f8
       3 frmt_accession_nbr = vc
       3 valid_from_dt_tm = dq8
       3 valid_until_dt_tm = dq8
       3 event_cd = f8
       3 event_cd_disp = vc
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 cp_entry = i2
       3 cep_entry = i2
       3 csr_entry = i2
       3 cen_entry = i2
       3 cbr_entry = i2
       3 cm_entry = i2
       3 ccr_entry = i2
       3 cdr_entry = i2
       3 subtable_bit_map = i4
       3 result_status_cd = f8
       3 result_status_cd_disp = vc
       3 result_val = vc
       3 verified_dt_tm = dq8
       3 verified_tz = i4
       3 verified_prsnl_id = f8
       3 event_note_list[*]
         4 note_type_cd = f8
         4 note_type_cd_disp = vc
         4 note_type_cd_mean = vc
         4 note_format_cd = f8
         4 note_format_cd_disp = vc
         4 note_format_mean = vc
         4 note_dt_tm = dq8
         4 note_tz = i4
         4 blob_length = i4
         4 long_blob = gc32000
       3 event_prsnl_list[*]
         4 action_type_cd = f8
         4 action_type_cd_disp = vc
         4 action_type_cd_mean = vc
         4 action_dt_tm = dq8
         4 action_tz = i4
         4 action_prsnl_id = f8
       3 blob_result[*]
         4 format_cd = f8
         4 blob[*]
           5 blob_length = i4
           5 blob_contents = gc32768
       3 date_result_list[*]
         4 result_dt_tm = dq8
         4 result_tz = i4
         4 result_tz_ind = i2
         4 result_dt_tm_os = f8
         4 date_type_flag = i2
       3 coded_result_list[*]
         4 short_string = c60
         4 source_identifier = vc
         4 source_string = vc
         4 mnemonic = vc
       3 string_result_list[*]
         4 string_long_text_id = f8
         4 string_result_text = vc
       3 nomen_string_flag = i2
       3 event_class_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE verify_dt_tm = q8 WITH noconstant(cnvtdatetime("01-JAN-1800")), protect
 DECLARE verify_tz = i4 WITH noconstant(0), protect
 DECLARE foundauthent = i2 WITH noconstant(0), protect
 DECLARE ocfcomp_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE complete_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"COMPLETED")), protect
 DECLARE sign_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"SIGN")), protect
 DECLARE transcribe_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"TRANSCRIBE")), protect
 DECLARE perform_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"PERFORM")), protect
 DECLARE review_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"REVIEW")), protect
 DECLARE verify_cd = f8 WITH constant(uar_get_code_by("MEANING",21,"VERIFY")), protect
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 DECLARE v_until_dt = q8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00.00")), protect
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE bitmap_ce_event_prsnl = i4 WITH constant(0)
 DECLARE bitmap_ce_event_note = i4 WITH constant(1)
 DECLARE bitmap_ce_blob_result = i4 WITH constant(8)
 DECLARE bitmap_ce_blob_summary = i4 WITH constant(11)
 DECLARE bitmap_ce_coded_result = i4 WITH constant(15)
 DECLARE bitmap_ce_product = i4 WITH constant(20)
 DECLARE bitmap_ce_date_result = i4 WITH constant(22)
 DECLARE bitmap_ce_string_result = i4 WITH constant(13)
 DECLARE csm_request_viewer_task = i4 WITH constant(1030024), protect
 DECLARE cp_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cep_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cen_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cbr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE ccr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cdr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE cbs_entry_skip = i2 WITH noconstant(0), protect
 DECLARE csr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cp_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cep_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cen_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cbr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_ccr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cdr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_cbs_entry_skip = i2 WITH noconstant(0), protect
 DECLARE parent_csr_entry_skip = i2 WITH noconstant(0), protect
 DECLARE x = i4 WITH noconstant(0), protect
 DECLARE y = i4 WITH noconstant(0), protect
 DECLARE z = i4 WITH noconstant(0), protect
 DECLARE x1 = i4 WITH noconstant(0), protect
 DECLARE x2 = i4 WITH noconstant(0), protect
 DECLARE x3 = i4 WITH noconstant(0), protect
 DECLARE where_clause = vc WITH noconstant(""), protect
 DECLARE date_clause = vc WITH noconstant(""), protect
 DECLARE c1 = vc WITH noconstant(""), protect
 DECLARE c2 = vc WITH noconstant(""), protect
 DECLARE c3 = vc WITH noconstant(""), protect
 DECLARE c4 = vc WITH noconstant(""), protect
 DECLARE c5 = vc WITH noconstant(""), protect
 DECLARE idx = i4
 DECLARE idx2 = i4
 DECLARE idx3 = i4
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE nrecordsize = i4
 DECLARE builddateclause(null) = null
 DECLARE buildwhereclause(null) = null
 DECLARE getvalidevents(null) = null
 DECLARE getceeventprsnl(null) = null
 DECLARE getceblobresult(null) = null
 DECLARE getcecodedresult(null) = null
 DECLARE getceblobresult(null) = null
 DECLARE getceblobsummary(null) = null
 DECLARE getcedateresult(null) = null
 DECLARE getcestringresult(null) = null
 CALL log_message("Starting script: cp_get_event",log_level_debug)
 SET reply->status_data.status = "F"
 CALL builddateclause(null)
 CALL buildwhereclause(null)
 CALL getvalidevents(null)
 SET reply->status_data.status = "S"
 SUBROUTINE builddateclause(null)
   CALL log_message("In BuildDateClause()",log_level_debug)
   DECLARE v_date = vc
   IF ((request->date_range_ind=0))
    SET v_date = " and ce.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
   ELSE
    SET v_date = " and ce.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm)"
   ENDIF
   SET date_clause = trim(v_date)
   CALL echo(build("date clause = ",date_clause))
 END ;Subroutine
 SUBROUTINE buildwhereclause(null)
   CALL log_message("In BuildWhereClause()",log_level_debug)
   SET where_clause = concat("ce.event_id = request->event_id ",
    " and ce.event_class_cd != placehold_class_cd ",trim(date_clause))
   CALL echo(build("where clause = ",trim(where_clause)))
 END ;Subroutine
 SUBROUTINE getvalidevents(null)
   CALL log_message("In GetValidEvents()",log_level_debug)
   SELECT INTO "nl:"
    ce.clinical_event_id, ce.event_id, ce.result_val
    FROM clinical_event ce
    PLAN (ce
     WHERE parser(where_clause))
    ORDER BY cnvtdatetime(ce.valid_until_dt_tm)
    HEAD ce.event_id
     do_nothing = 0, parent_cep_entry_skip = 0, parent_cen_entry_skip = 0,
     parent_cbr_entry_skip = 0, parent_ccr_entry_skip = 0, parent_cdr_entry_skip = 0
    DETAIL
     do_nothing = 0
    FOOT  ce.event_id
     reply->rb_list[1].event_list[1].event_id = ce.event_id, reply->rb_list[1].event_list[1].order_id
      = ce.order_id, reply->rb_list[1].event_list[1].frmt_accession_nbr =
     IF ((request->format_acc_ind=1)) uar_fmt_accession(ce.accession_nbr,size(ce.accession_nbr,1))
     ELSE null
     ENDIF
     ,
     reply->rb_list[1].event_list[1].valid_from_dt_tm = ce.valid_from_dt_tm, reply->rb_list[1].
     event_list[1].valid_until_dt_tm = ce.valid_until_dt_tm, reply->rb_list[1].event_list[1].event_cd
      = ce.event_cd,
     reply->rb_list[1].event_list[1].event_class_cd = ce.event_class_cd, reply->rb_list[1].
     event_list[1].event_end_dt_tm = ce.event_end_dt_tm, reply->rb_list[1].event_list[1].event_end_tz
      = validate(ce.event_end_tz,0),
     reply->rb_list[1].event_list[1].subtable_bit_map = ce.subtable_bit_map, reply->rb_list[1].
     event_list[1].cep_entry = btest(ce.subtable_bit_map,bitmap_ce_event_prsnl)
     IF (cep_entry_skip=0
      AND (reply->rb_list[1].event_list[1].cep_entry=1))
      cep_entry_skip = 1
     ENDIF
     reply->rb_list[1].event_list[1].cen_entry = btest(ce.subtable_bit_map,bitmap_ce_event_note)
     IF (cen_entry_skip=0
      AND (reply->rb_list[1].event_list[1].cen_entry=1))
      cen_entry_skip = 1
     ENDIF
     reply->rb_list[1].event_list[1].cbr_entry = btest(ce.subtable_bit_map,bitmap_ce_blob_result)
     IF (cbr_entry_skip=0
      AND (reply->rb_list[1].event_list[1].cbr_entry=1))
      cbr_entry_skip = 1
     ENDIF
     reply->rb_list[1].event_list[1].ccr_entry = btest(ce.subtable_bit_map,bitmap_ce_coded_result)
     IF (ccr_entry_skip=0
      AND (reply->rb_list[1].event_list[1].ccr_entry=1))
      ccr_entry_skip = 1
     ENDIF
     reply->rb_list[1].event_list[1].cdr_entry = btest(ce.subtable_bit_map,bitmap_ce_date_result)
     IF (cdr_entry_skip=0
      AND (reply->rb_list[1].event_list[1].cdr_entry=1))
      cdr_entry_skip = 1
     ENDIF
     reply->rb_list[1].event_list[1].csr_entry = btest(ce.subtable_bit_map,bitmap_ce_string_result)
     IF (csr_entry_skip=0
      AND (reply->rb_list[1].event_list[1].csr_entry=1))
      csr_entry_skip = 1
     ENDIF
     reply->rb_list[1].event_list[1].result_status_cd = ce.result_status_cd, reply->rb_list[1].
     event_list[1].result_val = ce.result_val, reply->rb_list[1].event_list[1].verified_dt_tm = ce
     .verified_dt_tm,
     reply->rb_list[1].event_list[1].verified_tz = validate(ce.verified_tz,0), reply->rb_list[1].
     event_list[1].verified_prsnl_id = ce.verified_prsnl_id, reply->rb_list[1].event_list[1].
     nomen_string_flag = ce.nomen_string_flag
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETPRELIMEVENTS",1,1)
   IF (cep_entry_skip=1)
    CALL getceeventprsnl(null)
   ENDIF
   IF (cen_entry_skip=1)
    CALL getceeventnote(null)
   ENDIF
   IF (cbr_entry_skip=1)
    CALL getceblobresult(null)
   ENDIF
   IF (ccr_entry_skip=1)
    CALL getcecodedresult(null)
   ENDIF
   IF (cdr_entry_skip=1)
    CALL getcedateresult(null)
   ENDIF
   IF (cbs_entry_skip=1)
    CALL getceblobsummary(null)
   ENDIF
   IF (csr_entry_skip=1)
    CALL getcestringresult(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE getceeventprsnl(null)
   CALL log_message("In GetCeEventPrsnl()",log_level_debug)
   SET where_clause = " "
   IF ((request->date_range_ind=0))
    SET c1 =
    "and cep.valid_until_dt_tm >= cnvtdatetime(v_until_dt) and cep.action_status_cd+0 = complete_cd"
    SET c2 = "and cep.action_type_cd in (transcribe_cd, perform_cd, review_cd, verify_cd, sign_cd)"
   ELSE
    SET c1 = " and cep.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm)"
   ENDIF
   SET where_clause = concat("cep.event_id = request->event_id ",trim(c1)," ",trim(c2))
   SELECT INTO "nl:"
    cep.seq, cep.event_prsnl_id, action_type_meaning = uar_get_code_meaning(cep.action_type_cd)
    FROM ce_event_prsnl cep
    PLAN (cep
     WHERE parser(where_clause))
    ORDER BY action_type_meaning DESC, cep.action_dt_tm DESC
    HEAD REPORT
     x = 0, verify_prsnl_id = 0.0
    HEAD action_type_meaning
     IF (cep.action_type_cd=verify_cd)
      verify_prsnl_id = cep.action_prsnl_id, verify_dt_tm = cnvtdatetime(cep.action_dt_tm), verify_tz
       = validate(cep.action_tz,0)
     ENDIF
     donothing = 0
    DETAIL
     IF (cep.action_type_cd IN (sign_cd, transcribe_cd, perform_cd, review_cd))
      IF (cep.action_type_cd=sign_cd
       AND cep.action_prsnl_id=verify_prsnl_id
       AND foundauthent=0)
       x += 1, stat = alterlist(reply->rb_list[1].event_list[1].event_prsnl_list,x), reply->rb_list[1
       ].event_list[1].event_prsnl_list[x].action_type_cd = verify_cd,
       reply->rb_list[1].event_list[1].event_prsnl_list[x].action_dt_tm = cnvtdatetime(verify_dt_tm),
       reply->rb_list[1].event_list[1].event_prsnl_list[x].action_tz = verify_tz, reply->rb_list[1].
       event_list[1].event_prsnl_list[x].action_prsnl_id = cep.action_prsnl_id,
       foundauthent = 1
      ENDIF
      x += 1, stat = alterlist(reply->rb_list[1].event_list[1].event_prsnl_list,x), reply->rb_list[1]
      .event_list[1].event_prsnl_list[x].action_type_cd = cep.action_type_cd,
      reply->rb_list[1].event_list[1].event_prsnl_list[x].action_dt_tm = cep.action_dt_tm, reply->
      rb_list[1].event_list[1].event_prsnl_list[x].action_tz = validate(cep.action_tz,0), reply->
      rb_list[1].event_list[1].event_prsnl_list[x].action_prsnl_id = cep.action_prsnl_id
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_EVENT_PRSNL","GETCEEVENTPRSNL",1,0)
 END ;Subroutine
 SUBROUTINE getceeventnote(null)
   CALL log_message("In GetCeEventNote()",log_level_debug)
   SET where_clause = " "
   DECLARE cen_date = vc
   IF ((request->date_range_ind=0))
    SET cen_date = " and cen.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
   ELSE
    SET cen_date = " and cen.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm)"
   ENDIF
   SET where_clause = concat("cen.event_id = request->event_id ",trim(cen_date))
   SELECT INTO "nl:"
    blength = textlen(lb.long_blob), cen.event_note_id, lb.seq
    FROM ce_event_note cen,
     long_blob lb
    PLAN (cen
     WHERE parser(where_clause)
      AND ((cen.non_chartable_flag=0) OR (cen.updt_task=csm_request_viewer_task)) )
     JOIN (lb
     WHERE lb.parent_entity_name="CE_EVENT_NOTE"
      AND lb.parent_entity_id=cen.ce_event_note_id)
    ORDER BY cen.event_note_id, cnvtdatetime(cen.valid_until_dt_tm)
    HEAD REPORT
     x = 0
    HEAD cen.event_note_id
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  cen.event_note_id
     x += 1, stat = alterlist(reply->rb_list[1].event_list[1].event_note_list,x), reply->rb_list[1].
     event_list[1].event_note_list[x].note_type_cd = cen.note_type_cd,
     reply->rb_list[1].event_list[1].event_note_list[x].note_format_cd = cen.note_format_cd, reply->
     rb_list[1].event_list[1].event_note_list[x].note_dt_tm = cen.note_dt_tm, reply->rb_list[1].
     event_list[1].event_note_list[x].note_tz = validate(cen.note_tz,0),
     blob_out = fillstring(32000," ")
     IF (cen.compression_cd=ocfcomp_cd)
      blob_ret_len = 0,
      CALL uar_ocf_uncompress(lb.long_blob,blength,blob_out,32000,blob_ret_len), y1 = size(trim(
        blob_out)),
      reply->rb_list[1].event_list[1].event_note_list[x].long_blob = blob_out, reply->rb_list[1].
      event_list[1].event_note_list[x].blob_length = y1
     ELSE
      y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),lb.long_blob), reply->rb_list[1]
      .event_list[1].event_note_list[x].long_blob = blob_out,
      reply->rb_list[1].event_list[1].event_note_list[x].blob_length = (y1 - 8)
     ENDIF
    WITH memsort, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_EVENT_NOTE","GETCEEVENTNOTE",1,0)
 END ;Subroutine
 SUBROUTINE getceblobresult(null)
   CALL log_message("In GetCeBlobResult()",log_level_debug)
   SET where_clause = " "
   SET date_clause = " "
   DECLARE cbr_date = vc
   DECLARE cb_date = vc
   IF ((request->date_range_ind=0))
    SET cbr_date = " and cbr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
    SET cb_date = " and cb.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
   ELSE
    SET cbr_date = " and cbr.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm)"
    SET cb_date = " and cb.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm)"
   ENDIF
   SET where_clause = concat("cbr.event_id = request->event_id ",trim(cbr_date))
   SET date_clause = concat("cb.event_id = request->event_id ",trim(cb_date))
   SELECT INTO "nl:"
    blength = textlen(cb.blob_contents), cbr.event_id, cb.seq
    FROM ce_blob_result cbr,
     ce_blob cb
    PLAN (cbr
     WHERE parser(where_clause))
     JOIN (cb
     WHERE parser(date_clause))
    ORDER BY cbr.event_id, cnvtdatetime(cbr.valid_until_dt_tm), cb.event_id,
     cnvtdatetime(cb.valid_until_dt_tm)
    HEAD REPORT
     x2 = 0
    HEAD cbr.event_id
     x2 = 0, x1 += 1, stat = alterlist(reply->rb_list[1].event_list[1].blob_result,x1)
    HEAD cb.event_id
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  cb.event_id
     x2 += 1, stat = alterlist(reply->rb_list[1].event_list[1].blob_result[x1].blob,x2), blob_out =
     fillstring(32768," ")
     IF (cb.compression_cd=ocfcomp_cd)
      blob_ret_len = 0,
      CALL uar_ocf_uncompress(cb.blob_contents,blength,blob_out,32768,blob_ret_len), y1 = size(trim(
        blob_out)),
      reply->rb_list[1].event_list[1].blob_result[x1].blob[x2].blob_contents = blob_out, reply->
      rb_list[1].event_list[1].blob_result[x1].blob[x2].blob_length = y1
     ELSE
      y1 = size(trim(cb.blob_contents)), blob_out = substring(1,(y1 - 8),cb.blob_contents), reply->
      rb_list[1].event_list[1].blob_result[x1].blob[x2].blob_contents = blob_out,
      reply->rb_list[1].event_list[1].blob_result[x1].blob[x2].blob_length = (y1 - 8)
     ENDIF
    FOOT  cbr.event_id
     reply->rb_list[1].event_list[1].blob_result[x1].format_cd = cbr.format_cd
    WITH memsort, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_BLOB_RESULT","GETCEBLOBRESULT",1,0)
 END ;Subroutine
 SUBROUTINE getcedateresult(null)
   CALL log_message("In GetCeDateResult()",log_level_debug)
   SET where_clause = " "
   DECLARE cdr_date = vc
   IF ((request->date_range_ind=0))
    SET cdr_date = " and cdr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
   ELSE
    SET cdr_date = " and cdr.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm)"
   ENDIF
   SET where_clause = concat("cdr.event_id = request->event_id ",trim(cdr_date))
   SELECT INTO "nl:"
    cdr.seq, cdr.event_id
    FROM ce_date_result cdr
    PLAN (cdr
     WHERE parser(where_clause))
    ORDER BY cdr.event_id, cnvtdatetime(cdr.valid_until_dt_tm)
    HEAD REPORT
     x1 = 0
    HEAD cdr.event_id
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  cdr.event_id
     x1 += 1
     IF (mod(x1,5)=1)
      stat = alterlist(reply->rb_list[1].event_list[1].date_result_list,x1)
     ENDIF
     reply->rb_list[1].event_list[1].date_result_list[x1].result_dt_tm = cdr.result_dt_tm, reply->
     rb_list[1].event_list[1].date_result_list[x1].result_tz = abs(validate(cdr.result_tz,0))
     IF (validate(cdr.result_tz,0) < 0)
      reply->rb_list[1].event_list[1].date_result_list[x1].result_tz_ind = 1
     ELSE
      reply->rb_list[1].event_list[1].date_result_list[x1].result_tz_ind = 0
     ENDIF
     reply->rb_list[1].event_list[1].date_result_list[x1].result_dt_tm_os = cdr.result_dt_tm_os,
     reply->rb_list[1].event_list[1].date_result_list[x1].date_type_flag = cdr.date_type_flag
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_DATE_RESULT","GETCEDATERESULT",1,0)
 END ;Subroutine
 SUBROUTINE getcecodedresult(null)
   CALL log_message("In GetCeCodedResult()",log_level_debug)
   CALL log_message("In GetCeCodedResult()",log_level_debug)
   SELECT INTO "nl:"
    FROM ce_coded_result ccr,
     nomenclature n
    PLAN (ccr
     WHERE (ccr.event_id=request->event_id)
      AND ccr.valid_from_dt_tm >= cnvtdatetime(reply->rb_list[1].event_list[1].valid_from_dt_tm)
      AND ccr.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm))
     JOIN (n
     WHERE ccr.nomenclature_id=n.nomenclature_id)
    ORDER BY ccr.sequence_nbr
    HEAD REPORT
     x1 = 0
    DETAIL
     x1 += 1, stat = alterlist(reply->rb_list[1].event_list[1].coded_result_list,x1), reply->rb_list[
     1].event_list[1].coded_result_list[x1].short_string = n.short_string,
     reply->rb_list[1].event_list[1].coded_result_list[x1].source_string = n.source_string, reply->
     rb_list[1].event_list[1].coded_result_list[x1].source_identifier = n.source_identifier, reply->
     rb_list[1].event_list[1].coded_result_list[x1].mnemonic = n.mnemonic
    FOOT REPORT
     donothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_CODED_RESULT","GETCECODEDRESULT",1,0)
 END ;Subroutine
 SUBROUTINE getcestringresult(null)
   CALL log_message("In GetCeStringResult()",log_level_debug)
   SET where_clause = " "
   SET date_clause = " "
   DECLARE csr_date = vc
   DECLARE lt_date = vc
   IF ((request->date_range_ind=0))
    SET csr_date = " and csr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
   ELSE
    SET csr_date = " and csr.valid_from_dt_tm < cnvtdatetime(request->valid_from_dt_tm)"
   ENDIF
   SET where_clause = concat("csr.event_id = request->event_id ",trim(csr_date))
   SELECT INTO "nl:"
    FROM ce_string_result csr,
     long_text lt
    PLAN (csr
     WHERE parser(where_clause))
     JOIN (lt
     WHERE lt.long_text_id=csr.string_long_text_id)
    ORDER BY csr.event_id, cnvtdatetime(csr.valid_until_dt_tm)
    HEAD REPORT
     x = 0
    HEAD csr.event_id
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  csr.event_id
     x += 1, stat = alterlist(reply->rb_list[1].event_list[1].string_result_list,x)
     IF (lt.long_text_id > 0.0)
      reply->rb_list[1].event_list[1].string_result_list[x].string_long_text_id = csr
      .string_long_text_id, reply->rb_list[1].event_list[1].string_result_list[x].string_result_text
       = lt.long_text
     ELSE
      reply->rb_list[1].event_list[1].string_result_list[x].string_result_text = csr
      .string_result_text
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_STRING_RESULT","GETCESTRINGRESULT",1,0)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_get_event",log_level_debug)
END GO
