CREATE PROGRAM cp_get_event_list_haplo:dba
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
 SET log_program_name = "CP_GET_EVENT_LIST_HAPLO"
 FREE RECORD reply
 RECORD reply(
   1 rb_list[1]
     2 chartable_ind = i2
     2 hla_typing_event_cd = f8
     2 hla_typing_event_cd_disp = vc
     2 hla_haplo_event_cd = f8
     2 hla_haplo_event_cd_disp = vc
     2 order_list[*]
       3 order_id = f8
       3 long_text = gc32000
       3 order_mnemonic = vc
       3 person_name = vc
       3 comment_dt_tm = dq8
       3 comment_tz = i4
     2 haplo_list[*]
       3 person_id = f8
       3 person_type_ind = i2
       3 person_name = vc
       3 person_reltn_cd = f8
       3 person_reltn_cd_disp = vc
       3 collation_seq = i4
       3 person_aborh_cd = f8
       3 person_aborh_cd_disp = vc
       3 person_rh_cd = f8
       3 person_rh_cd_disp = vc
       3 person_alias_type_cd = f8
       3 person_alias_type_cd_disp = vc
       3 person_mrn = vc
       3 hla_typing_event_id = f8
       3 event_end_dt_tm = dq8
       3 event_end_tz = i4
       3 cep_entry = i2
       3 cen_entry = i2
       3 csr_entry = i2
       3 event_list[*]
         4 person_id = f8
         4 person_name = vc
         4 event_id = f8
         4 order_id = f8
         4 clinical_event_id = f8
         4 parent_event_id = f8
         4 valid_from_dt_tm = dq8
         4 valid_until_dt_tm = dq8
         4 view_level = i4
         4 event_cd = f8
         4 event_cd_disp = vc
         4 catalog_cd = f8
         4 event_end_dt_tm = dq8
         4 event_end_tz = i4
         4 resource_cd = f8
         4 result_status_cd = f8
         4 result_status_cd_disp = vc
         4 subtable_bit_map = i4
         4 cep_entry = i2
         4 cen_entry = i2
         4 csr_entry = i2
         4 normalcy_cd = f8
         4 normalcy_cd_disp = vc
         4 result_val = vc
         4 result_units_cd = f8
         4 result_units_cd_disp = vc
         4 task_assay_cd = f8
         4 verified_dt_tm = dq8
         4 verified_tz = i4
         4 verified_prsnl_id = f8
         4 normal_high = vc
         4 normal_low = vc
         4 string_result_list[*]
           5 result_text = vc
           5 haplotype_id = vc
           5 haplotype_result = vc
           5 result_format_cd = f8
         4 event_note_list[*]
           5 note_type_cd = f8
           5 note_type_cd_disp = vc
           5 note_type_cd_mean = vc
           5 note_format_cd = f8
           5 note_format_cd_disp = vc
           5 note_format_cd_mean = vc
           5 note_dt_tm = dq8
           5 note_tz = i4
           5 blob_length = i4
           5 long_blob = gc32000
         4 event_prsnl_list[*]
           5 action_type_cd = f8
           5 action_type_cd_disp = vc
           5 action_dt_tm = dq8
           5 action_tz = i4
           5 action_prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE gethlatyingeventcd(null) = null
 DECLARE gethlahaploeventcd(null) = null
 DECLARE getdonorrecipient(null) = null
 DECLARE determinerelationship(null) = null
 DECLARE gethladata(null) = null
 DECLARE max_event_list = i4 WITH noconstant(0)
 DECLARE donrec_nbr = i2 WITH noconstant(0)
 DECLARE recp_flag = i2 WITH constant(0)
 DECLARE donor_flag = i2 WITH constant(1)
 DECLARE unknown_flag = i2 WITH constant(2)
 DECLARE blank_flag = i2 WITH constant(3)
 DECLARE max_collation_seq = i4 WITH constant(999)
 DECLARE hla01_cd = f8 WITH constant(uar_get_code_by("MEANING",73,"HLA01")), protect
 DECLARE hla03_cd = f8 WITH constant(uar_get_code_by("MEANING",73,"HLA03")), protect
 DECLARE hla_donrec_cd = f8 WITH constant(uar_get_code_by("MEANING",351,"HLA DONREC")), protect
 DECLARE donor_cd = f8 WITH constant(uar_get_code_by("MEANING",40,"DONOR")), protect
 DECLARE recipient_cd = f8 WITH constant(uar_get_code_by("MEANING",40,"RECIPIENT")), protect
 DECLARE genetic_cd = f8 WITH constant(uar_get_code_by("MEANING",351,"GENETIC")), protect
 DECLARE ocfcomp_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE ordcomm_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT")), protect
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN")), protect
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mod_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE alt_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE super_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"SUPERSEDED")), protect
 DECLARE deleted_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"DELETED")), protect
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 DECLARE csm_request_viewer_task = i4 WITH constant(1030024), protect
 CALL log_message("Begin script: cp_get_event_list_haplo",log_level_debug)
 SET reply->status_data.status = "S"
 CALL gethlatyingeventcd(null)
 CALL gethlahaploeventcd(null)
 CALL getdonorrecipient(null)
 CALL determinerelationship(null)
 CALL gethladata(null)
 SUBROUTINE gethlatyingeventcd(null)
   CALL log_message("In GetHLATyingEventCd()",log_level_debug)
   SELECT INTO "nl:"
    c.event_cd
    FROM code_value_event_r c
    WHERE c.parent_cd=hla01_cd
    DETAIL
     reply->rb_list[1].hla_typing_event_cd = c.event_cd
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CODE_VALUE_EVENT_R","GETHLATYINGEVENTCD",1,1)
   SET code_nbr = size(request->code_list,5)
   SELECT INTO "NL:"
    ese.event_cd
    FROM (dummyt d  WITH seq = value(code_nbr)),
     v500_event_set_explode ese
    PLAN (d
     WHERE (request->code_list[d.seq].procedure_type_flag=0))
     JOIN (ese
     WHERE (ese.event_set_cd=request->code_list[d.seq].code)
      AND (ese.event_cd=reply->rb_list[1].hla_typing_event_cd))
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"V500_EVENT_SET_EXPLODE","GETHLATYINGEVENTCD",1,1)
   SET stemp = build("hla_typing_event_cd = ",reply->rb_list[1].hla_typing_event_cd)
   CALL log_message(stemp,log_level_debug)
 END ;Subroutine
 SUBROUTINE gethlahaploeventcd(null)
   CALL log_message("In GetHLAHaploEventCd()",log_level_debug)
   SELECT INTO "nl:"
    c.event_cd
    FROM code_value_event_r c
    WHERE c.parent_cd=hla03_cd
    DETAIL
     reply->rb_list[1].hla_haplo_event_cd = c.event_cd
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CODE_VALUE_EVENT_R","GETHLAHAPLOEVENTCD",1,1)
   SET stemp = build("hla_haplo_event_cd = ",reply->rb_list[1].hla_haplo_event_cd)
   CALL log_message(stemp,log_level_debug)
 END ;Subroutine
 SUBROUTINE getdonorrecipient(null)
   CALL log_message("In GetDonorRecipient()",log_level_debug)
   SELECT INTO "nl:"
    ppr.related_person_id
    FROM person_person_reltn ppr
    WHERE (ppr.person_id=request->person_id)
     AND ppr.person_reltn_type_cd=hla_donrec_cd
     AND ppr.person_reltn_cd=donor_cd
     AND ppr.related_person_reltn_cd=recipient_cd
     AND ppr.active_ind=1
    HEAD REPORT
     x = 0
    DETAIL
     x += 1
     IF (mod(x,10)=1)
      stat = alterlist(reply->rb_list[1].haplo_list,(x+ 9))
     ENDIF
     IF (x=1)
      reply->rb_list[1].haplo_list[x].person_id = ppr.person_id, x += 1
     ENDIF
     reply->rb_list[1].haplo_list[x].person_id = ppr.related_person_id
    FOOT REPORT
     stat = alterlist(reply->rb_list[1].haplo_list,x)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"PERSON_PERSON_RELTN","GETDONORRECIPIENT",1,0)
   IF (curqual=0)
    SELECT INTO "nl:"
     ppr.*
     FROM person_person_reltn ppr
     WHERE (ppr.person_id=request->person_id)
      AND ppr.person_reltn_type_cd=hla_donrec_cd
      AND ppr.related_person_reltn_cd=donor_cd
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"PERSON_PERSON_RELTN2","GETDONORRECIPIENT",1,0)
    IF (curqual=0)
     SET reply->rb_list[1].chartable_ind = 1
     SET stat = alterlist(reply->rb_list[1].haplo_list,1)
     SET reply->rb_list[1].haplo_list[1].person_id = request->person_id
     SET donrec_nbr = 1
     CALL setdonorrecipienttypeflag(donrec_nbr)
     SET stemp = "********* NO PERSON_PERSON_RELTN HLA DONREC ROW AT ALL *************"
     CALL log_message(stemp,log_level_debug)
    ELSE
     SET reply->rb_list[1].chartable_ind = 0
     SET stemp = "********* HLA HAPLOTYPE DONOR ONLY CHART ************"
     CALL log_message(stemp,log_level_debug)
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->rb_list[1].chartable_ind = 1
    SET donrec_nbr = size(reply->rb_list[1].haplo_list,5)
    CALL echo(build("donor number :",donrec_nbr))
    CALL setdonorrecipienttypeflag(donrec_nbr)
   ENDIF
 END ;Subroutine
 SUBROUTINE (setdonorrecipienttypeflag(donrec_nbr=i2) =null)
   CALL log_message("In SetDonorRecipientTypeFlag()",log_level_debug)
   SET reply->rb_list[1].haplo_list[1].person_type_ind = recp_flag
   FOR (i = 2 TO donrec_nbr)
     SET reply->rb_list[1].haplo_list[i].person_type_ind = donor_flag
   ENDFOR
 END ;Subroutine
 SUBROUTINE determinerelationship(null)
   CALL log_message("In DetermineRelationship()",log_level_debug)
   SELECT INTO "nl:"
    p.person_reltn_cd
    FROM (dummyt d  WITH seq = value(donrec_nbr)),
     person_person_reltn p
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=request->person_id)
      AND p.person_reltn_type_cd=genetic_cd
      AND (p.related_person_id=reply->rb_list[1].haplo_list[d.seq].person_id))
    ORDER BY d.seq
    HEAD d.seq
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  d.seq
     IF (d.seq != 1)
      reply->rb_list[1].haplo_list[d.seq].person_reltn_cd = p.person_reltn_cd
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"PERSON_PERSON_RELTN","DETERMINERELATIONSHIP",1,0)
 END ;Subroutine
 SUBROUTINE gethladata(null)
   CALL log_message("In GetHLAData()",log_level_debug)
   FOR (i = 1 TO donrec_nbr)
     SET reply->rb_list[1].haplo_list[i].collation_seq = max_collation_seq
   ENDFOR
   SELECT INTO "nl:"
    cv.collation_seq
    FROM (dummyt d  WITH seq = value(donrec_nbr)),
     code_value cv
    PLAN (d)
     JOIN (cv
     WHERE cv.code_set=40
      AND (cv.code_value=reply->rb_list[1].haplo_list[d.seq].person_reltn_cd))
    ORDER BY d.seq
    HEAD d.seq
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  d.seq
     reply->rb_list[1].haplo_list[d.seq].collation_seq = cv.collation_seq
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CODE_VALUE","GETCOLLATIONSEQ",1,0)
   SELECT INTO "nl:"
    p.person_id
    FROM (dummyt d  WITH seq = value(donrec_nbr)),
     person p
    PLAN (d)
     JOIN (p
     WHERE (p.person_id=reply->rb_list[1].haplo_list[d.seq].person_id))
    ORDER BY d.seq
    HEAD d.seq
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  d.seq
     reply->rb_list[1].haplo_list[d.seq].person_name = p.name_full_formatted
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"PERSON","GETRECDONORNAME",1,0)
   SELECT INTO "nl:"
    pa.person_id
    FROM (dummyt d  WITH seq = value(donrec_nbr)),
     person_aborh pa
    PLAN (d)
     JOIN (pa
     WHERE (pa.person_id=reply->rb_list[1].haplo_list[d.seq].person_id)
      AND pa.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  d.seq
     reply->rb_list[1].haplo_list[d.seq].person_aborh_cd = pa.abo_cd, reply->rb_list[1].haplo_list[d
     .seq].person_rh_cd = pa.rh_cd
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"PERSON_ABORH","GETPERSONABO",1,0)
   SELECT INTO "nl:"
    pa.person_alias_type_cd
    FROM (dummyt d  WITH seq = value(donrec_nbr)),
     person_alias pa
    PLAN (d)
     JOIN (pa
     WHERE (pa.person_id=reply->rb_list[1].haplo_list[d.seq].person_id)
      AND pa.person_alias_type_cd=mrn_cd
      AND pa.active_ind != 0
      AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ((pa.end_effective_dt_tm > cnvtdatetime(sysdate)) OR (pa.end_effective_dt_tm=null)) )
    HEAD d.seq
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  d.seq
     reply->rb_list[1].haplo_list[d.seq].person_alias_type_cd = pa.person_alias_type_cd, reply->
     rb_list[1].haplo_list[d.seq].person_mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"PERSON_ALIAS","GETPERSONMRN",1,0)
   DECLARE cep_entry_skip = i2 WITH noconstant(0)
   DECLARE cen_entry_skip = i2 WITH noconstant(0)
   DECLARE csr_entry_skip = i2 WITH noconstant(0)
   DECLARE parent_cep_entry_skip = i2 WITH noconstant(0)
   DECLARE parent_cen_entry_skip = i2 WITH noconstant(0)
   DECLARE parent_csr_entry_skip = i2 WITH noconstant(0)
   DECLARE date_clause = vc
   DECLARE date_clause1 = vc
   DECLARE status_clause = vc
   DECLARE c1 = vc
   DECLARE c2 = vc
   DECLARE c3 = vc
   DECLARE c4 = vc
   DECLARE c5 = vc
   DECLARE v_until_dt = q8 WITH constant(cnvtdatetime("31-DEC-2100 00:00:00.00")), protect
   IF ((request->date_range_ind=1))
    IF ((request->begin_dt_tm > 0))
     SET s_date = cnvtdatetime(request->begin_dt_tm)
    ELSE
     SET s_date = cnvtdatetime("01-jan-1800 00:00:00.00")
    ENDIF
    IF ((request->end_dt_tm > 0))
     SET e_date = cnvtdatetime(request->end_dt_tm)
    ELSE
     SET e_date = cnvtdatetime("31-dec-2100 23:59:59.99")
    ENDIF
    IF ((request->request_type=2)
     AND (request->mcis_ind=0))
     SET date_clause = " (ce.verified_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
    ELSE
     IF ((request->result_lookup_ind=1))
      SET date_clause =
      " (ce.event_end_dt_tm+0 between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
     ELSE
      SET date_clause =
      " (ce.clinsig_updt_dt_tm+0 between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
     ENDIF
    ENDIF
   ELSE
    SET date_clause = "1=1"
   ENDIF
   CALL echo(concat("date clause = ",date_clause))
   SET status_clause = " (ce.result_status_cd in (auth_cd, mod_cd, alt_cd, super_cd)"
   SET status_clause = concat(status_clause," and ce.event_class_cd != placehold_class_cd")
   SET status_clause = concat(status_clause," and ce.record_status_cd != deleted_cd)")
   CALL echo(build("status clause = ",status_clause))
   SELECT INTO "nl:"
    ce.event_id
    FROM (dummyt d  WITH seq = value(donrec_nbr)),
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE parser(date_clause)
      AND parser(status_clause)
      AND (ce.person_id=reply->rb_list[1].haplo_list[d.seq].person_id)
      AND (ce.event_cd=reply->rb_list[1].hla_typing_event_cd)
      AND ce.view_level=1
      AND ce.publish_flag=1)
    ORDER BY d.seq
    HEAD d.seq
     do_nothing = 0
    DETAIL
     do_nothing = 0
    FOOT  d.seq
     reply->rb_list[1].haplo_list[d.seq].hla_typing_event_id = ce.event_id, reply->rb_list[1].
     haplo_list[d.seq].event_end_dt_tm = ce.event_end_dt_tm, reply->rb_list[1].haplo_list[d.seq].
     event_end_tz = validate(ce.event_end_tz,0)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETHLADATA",1,0)
   IF (curqual=0)
    GO TO exit_script
   ENDIF
   SET date_clause1 = "ce.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
   CALL echo(build("date clause1 = ",date_clause1))
   SELECT INTO "nl:"
    ce.event_id
    FROM (dummyt d  WITH seq = value(donrec_nbr)),
     clinical_event ce
    PLAN (d)
     JOIN (ce
     WHERE parser(date_clause1)
      AND (ce.person_id=reply->rb_list[1].haplo_list[d.seq].person_id)
      AND (ce.parent_event_id=reply->rb_list[1].haplo_list[d.seq].hla_typing_event_id)
      AND (ce.event_cd=reply->rb_list[1].hla_haplo_event_cd)
      AND ce.record_status_cd != deleted_cd
      AND ce.view_level=0
      AND ce.publish_flag=1)
    ORDER BY d.seq, cnvtdatetime(ce.event_end_dt_tm) DESC, ce.event_id
    HEAD d.seq
     x = 0, y = 0, parent_cep_entry_skip = 0,
     parent_cen_entry_skip = 0, parent_csr_entry_skip = 0
    HEAD ce.event_end_dt_tm
     do_nothing = 0
    DETAIL
     IF (y < 2)
      x += 1
      IF (mod(x,10)=1)
       stat = alterlist(reply->rb_list[1].haplo_list[d.seq].event_list,(x+ 9))
      ENDIF
      reply->rb_list[1].haplo_list[d.seq].event_list[x].person_name = reply->rb_list[1].haplo_list[d
      .seq].person_name, reply->rb_list[1].haplo_list[d.seq].event_list[x].person_id = ce.person_id,
      reply->rb_list[1].haplo_list[d.seq].event_list[x].event_id = ce.event_id,
      reply->rb_list[1].haplo_list[d.seq].event_list[x].order_id = ce.order_id, reply->rb_list[1].
      haplo_list[d.seq].event_list[x].clinical_event_id = ce.clinical_event_id, reply->rb_list[1].
      haplo_list[d.seq].event_list[x].parent_event_id = ce.parent_event_id,
      reply->rb_list[1].haplo_list[d.seq].event_list[x].valid_from_dt_tm = ce.valid_from_dt_tm, reply
      ->rb_list[1].haplo_list[d.seq].event_list[x].valid_until_dt_tm = ce.valid_until_dt_tm, reply->
      rb_list[1].haplo_list[d.seq].event_list[x].view_level = ce.view_level,
      reply->rb_list[1].haplo_list[d.seq].event_list[x].catalog_cd = ce.catalog_cd, reply->rb_list[1]
      .haplo_list[d.seq].event_list[x].event_cd = ce.event_cd, reply->rb_list[1].haplo_list[d.seq].
      event_list[x].event_end_dt_tm = ce.event_end_dt_tm,
      reply->rb_list[1].haplo_list[d.seq].event_list[x].event_end_tz = validate(ce.event_end_tz,0),
      reply->rb_list[1].haplo_list[d.seq].event_list[x].resource_cd = ce.resource_cd, reply->rb_list[
      1].haplo_list[d.seq].event_list[x].result_status_cd = ce.result_status_cd,
      reply->rb_list[1].haplo_list[d.seq].event_list[x].subtable_bit_map = ce.subtable_bit_map, reply
      ->rb_list[1].haplo_list[d.seq].event_list[x].cep_entry = btest(ce.subtable_bit_map,0)
      IF ((reply->rb_list[1].haplo_list[d.seq].event_list[x].cep_entry=1))
       cep_entry_skip = 1, parent_cep_entry_skip = 1
      ENDIF
      reply->rb_list[1].haplo_list[d.seq].event_list[x].cen_entry = btest(ce.subtable_bit_map,1)
      IF ((reply->rb_list[1].haplo_list[d.seq].event_list[x].cen_entry=1))
       CALL echo("entry for ce_event_note is 1 "), cen_entry_skip = 1, parent_cen_entry_skip = 1
      ENDIF
      reply->rb_list[1].haplo_list[d.seq].event_list[x].csr_entry = btest(ce.subtable_bit_map,13)
      IF ((reply->rb_list[1].haplo_list[d.seq].event_list[x].csr_entry=1))
       csr_entry_skip = 1, parent_csr_entry_skip = 1
      ENDIF
      reply->rb_list[1].haplo_list[d.seq].event_list[x].normalcy_cd = ce.normalcy_cd, reply->rb_list[
      1].haplo_list[d.seq].event_list[x].result_val = ce.result_val, reply->rb_list[1].haplo_list[d
      .seq].event_list[x].result_units_cd = ce.result_units_cd,
      reply->rb_list[1].haplo_list[d.seq].event_list[x].task_assay_cd = ce.task_assay_cd, reply->
      rb_list[1].haplo_list[d.seq].event_list[x].verified_dt_tm = ce.verified_dt_tm, reply->rb_list[1
      ].haplo_list[d.seq].event_list[x].verified_tz = validate(ce.verified_tz,0),
      reply->rb_list[1].haplo_list[d.seq].event_list[x].verified_prsnl_id = ce.verified_prsnl_id,
      reply->rb_list[1].haplo_list[d.seq].event_list[x].normal_high = ce.normal_high, reply->rb_list[
      1].haplo_list[d.seq].event_list[x].normal_low = ce.normal_low,
      y += 1
     ENDIF
    FOOT  ce.event_end_dt_tm
     IF (y < 2)
      y += 1
     ENDIF
    FOOT  d.seq
     IF (x > max_event_list)
      max_event_list = x
     ENDIF
     stat = alterlist(reply->rb_list[1].haplo_list[d.seq].event_list,x), reply->rb_list[1].
     haplo_list[d.seq].cep_entry = parent_cep_entry_skip, reply->rb_list[1].haplo_list[d.seq].
     cen_entry = parent_cen_entry_skip,
     reply->rb_list[1].haplo_list[d.seq].csr_entry = parent_csr_entry_skip
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETHLADATA",1,0)
   IF (max_event_list=0)
    GO TO exit_script
   ENDIF
   CALL echo(build("max_event_list = ",max_event_list))
   SET result_text = fillstring(200," ")
   IF (csr_entry_skip=1)
    SET date_clause1 = " "
    SET c1 = "csr.event_id = reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_id"
    SET c2 = " and csr.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
    SET date_clause1 = concat(trim(c1)," ",trim(c2))
    SELECT INTO "nl:"
     csr.seq, csr.event_id
     FROM (dummyt d1  WITH seq = value(donrec_nbr)),
      (dummyt d2  WITH seq = value(max_event_list)),
      ce_string_result csr
     PLAN (d1
      WHERE (reply->rb_list[1].haplo_list[d1.seq].csr_entry=1))
      JOIN (d2
      WHERE d2.seq <= size(reply->rb_list[1].haplo_list[d1.seq].event_list,5)
       AND (reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].csr_entry=1))
      JOIN (csr
      WHERE parser(date_clause1))
     HEAD d1.seq
      do_nothing = 0
     HEAD d2.seq
      x1 = 0
     DETAIL
      x1 += 1
      IF (mod(x1,5)=1)
       stat = alterlist(reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].string_result_list,(
        x1+ 4))
      ENDIF
      pos = findstring(";",csr.string_result_text), len = textlen(trim(csr.string_result_text)),
      CALL echo(build("pos = ",pos)),
      CALL echo(build("len = ",len)), reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].
      string_result_list[x1].result_text = csr.string_result_text
      IF (pos != 0)
       reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].string_result_list[x1].haplotype_id =
       substring(1,(pos - 1),csr.string_result_text), reply->rb_list[1].haplo_list[d1.seq].
       event_list[d2.seq].string_result_list[x1].haplotype_result = substring((pos+ 1),(len - pos),
        csr.string_result_text)
      ELSE
       reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].string_result_list[x1].haplotype_id =
       " ", reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].string_result_list[x1].
       haplotype_result = csr.string_result_text
      ENDIF
      reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].string_result_list[x1].result_format_cd
       = csr.string_result_format_cd
     FOOT  d2.seq
      stat = alterlist(reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].string_result_list,x1)
     FOOT  d1.seq
      do_nothing = 0
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CE_CODED_RESULT","GETHLADATA",1,0)
   ENDIF
   CALL echo("OK")
   IF (cep_entry_skip=1)
    SET date_clause1 = " "
    SET c1 = "cep.event_id = reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_id"
    SET c2 = " and cep.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
    SET date_clause1 = concat(trim(c1)," ",trim(c2))
    SELECT INTO "nl:"
     cep.seq, cep.event_id
     FROM (dummyt d1  WITH seq = value(donrec_nbr)),
      (dummyt d2  WITH seq = value(max_event_list)),
      ce_event_prsnl cep
     PLAN (d1
      WHERE (reply->rb_list[1].haplo_list[d1.seq].cep_entry=1))
      JOIN (d2
      WHERE d2.seq <= size(reply->rb_list[1].haplo_list[d1.seq].event_list,5)
       AND (reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].cep_entry=1))
      JOIN (cep
      WHERE parser(date_clause1))
     ORDER BY d1.seq, d2.seq
     HEAD d1.seq
      do_nothing = 0
     HEAD d2.seq
      x1 = 0
     DETAIL
      x1 += 1
      IF (mod(x1,5)=1)
       stat = alterlist(reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_prsnl_list,(x1
        + 4))
      ENDIF
      reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_prsnl_list[x1].action_type_cd =
      cep.action_type_cd, reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_prsnl_list[x1
      ].action_dt_tm = cep.action_dt_tm, reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].
      event_prsnl_list[x1].action_tz = validate(cep.action_tz,0),
      reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_prsnl_list[x1].action_prsnl_id =
      cep.action_prsnl_id
     FOOT  d2.seq
      stat = alterlist(reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_prsnl_list,x1)
     FOOT  d1.seq
      do_nothing = 0
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CE_CODED_RESULT","GETHLADATA",1,0)
   ENDIF
   IF (cen_entry_skip=1)
    CALL echo("enter event note")
    SET date_clause1 = " "
    SET c1 = "cen.event_id = reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_id"
    SET c2 = " and cen.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
    SET date_clause1 = concat(trim(c1)," ",trim(c2))
    SELECT INTO "nl:"
     cen.event_id, lb.seq, textlen_lb_long_blob = textlen(lb.long_blob)
     FROM (dummyt d1  WITH seq = value(donrec_nbr)),
      (dummyt d2  WITH seq = value(max_event_list)),
      ce_event_note cen,
      long_blob lb
     PLAN (d1
      WHERE (reply->rb_list[1].haplo_list[d1.seq].cen_entry=1))
      JOIN (d2
      WHERE d2.seq <= size(reply->rb_list[1].haplo_list[d1.seq].event_list,5)
       AND (reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].cen_entry=1))
      JOIN (cen
      WHERE parser(date_clause1)
       AND ((cen.non_chartable_flag=0) OR (cen.updt_task=csm_request_viewer_task)) )
      JOIN (lb
      WHERE lb.parent_entity_name="CE_EVENT_NOTE"
       AND lb.parent_entity_id=cen.ce_event_note_id)
     HEAD d1.seq
      do_nothing = 0
     HEAD d2.seq
      x1 = 0
     DETAIL
      x1 += 1
      IF (mod(x1,5)=1)
       stat = alterlist(reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list,(x1+
        4))
      ENDIF
      reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list[x1].note_type_cd = cen
      .note_type_cd, reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list[x1].
      note_format_cd = cen.note_format_cd, reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].
      event_note_list[x1].note_dt_tm = cen.note_dt_tm,
      reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list[x1].note_tz = validate(
       cen.note_tz,0)
      IF (cen.compression_cd=ocfcomp_cd)
       blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," "), blob_out3 = fillstring(
        32000," "),
       blob_ret_len = 0,
       CALL uar_ocf_uncompress(lb.long_blob,textlen_lb_long_blob,blob_out,32000,blob_ret_len), y1 =
       size(trim(blob_out)),
       reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list[x1].long_blob =
       blob_out, reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list[x1].
       blob_length = y1
      ELSE
       blob_out2 = fillstring(32000," "), y1 = size(trim(lb.long_blob)), blob_out2 = substring(1,(y1
         - 8),lb.long_blob),
       reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list[x1].long_blob =
       blob_out2, reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list[x1].
       blob_length = (y1 - 8)
      ENDIF
     FOOT  d2.seq
      stat = alterlist(reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_note_list,x1)
     FOOT  d1.seq
      do_nothing = 0
     WITH nocounter
    ;end select
   ENDIF
   IF (request->order_cmnt_ind)
    SELECT DISTINCT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(donrec_nbr)),
      (dummyt d2  WITH seq = value(max_event_list)),
      order_comment oc,
      long_text lt,
      orders o
     PLAN (d1)
      JOIN (d2
      WHERE d2.seq <= size(reply->rb_list[1].haplo_list[d1.seq].event_list,5))
      JOIN (oc
      WHERE (oc.order_id=reply->rb_list[1].haplo_list[d1.seq].event_list[d2.seq].order_id)
       AND oc.comment_type_cd=ordcomm_cd)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
      JOIN (o
      WHERE o.order_id=oc.order_id)
     ORDER BY oc.order_id, oc.action_sequence
     HEAD REPORT
      x = 0
     FOOT  oc.order_id
      x += 1, stat = alterlist(reply->rb_list[1].order_list,x), reply->rb_list[1].order_list[x].
      order_id = oc.order_id,
      reply->rb_list[1].order_list[x].long_text = lt.long_text, reply->rb_list[1].order_list[x].
      order_mnemonic = o.order_mnemonic, reply->rb_list[1].order_list[x].person_name = reply->
      rb_list[1].haplo_list[d1.seq].person_name,
      reply->rb_list[1].order_list[x].comment_dt_tm = reply->rb_list[1].haplo_list[d1.seq].
      event_list[d2.seq].event_end_dt_tm, reply->rb_list[1].order_list[x].comment_tz = reply->
      rb_list[1].haplo_list[d1.seq].event_list[d2.seq].event_end_tz
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
END GO
