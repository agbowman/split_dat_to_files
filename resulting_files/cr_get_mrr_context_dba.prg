CREATE PROGRAM cr_get_mrr_context:dba
 FREE RECORD reply
 RECORD reply(
   1 name_full_formatted = vc
   1 encntr_mrn = vc
   1 admission_dt_tm = dq8
   1 frmt_accession_nbr = vc
   1 event_title_text = vc
   1 prsnl_reltn[*]
     2 prsnl_person_id = f8
     2 prsnl_name_full_formatted = vc
     2 reltn_cd = f8
     2 reltn_disp = vc
     2 reltn_mean = vc
     2 output_dest_cd = f8
     2 device_cd = f8
     2 device_name = c20
     2 device_type_cd = f8
     2 device_type_disp = vc
     2 device_type_mean = vc
     2 dms_enabled_ind = i2
     2 dms_service_identifier = vc
   1 person_mrn = vc
   1 person_cmrn = vc
   1 fin_nbr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET log_program_name = "CR_GET_MRR_CONTEXT"
 DECLARE retrieveperoninfo(null) = null WITH protect
 DECLARE retrievepersonalias(null) = null WITH protect
 DECLARE retrievepersonpersonnelrelation(null) = null WITH protect
 DECLARE retrieveencounterinfo(null) = null WITH protect
 DECLARE retrieveencounterpersonnelrelation(null) = null WITH protect
 DECLARE retrieveorderpersonnelrelation(null) = null WITH protect
 DECLARE retrieveeventinfo(null) = null WITH protect
 DECLARE retrievedeviceforproviders(null) = null WITH protect
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE order_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ORDERDOC")), protect
 DECLARE consult_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"CONSULTDOC")), protect
 DECLARE person_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN")), protect
 DECLARE cmrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"CMRN")), protect
 DECLARE fax_type_cd = f8 WITH constant(uar_get_code_by("MEANING",3000,"FAX")), protect
 DECLARE prsnlcnt = i4 WITH noconstant(0)
 DECLARE currentdatetime = q8 WITH public, noconstant(cnvtdatetime(sysdate))
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: CR_GET_MRR_CONTEXT",log_level_debug)
 IF ((request->person_id=0))
  CALL populate_subeventstatus("DataValidation","Z","request->person_id","0")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 IF (checkprg("PFT_LOG_SOLUTION_CAPABILITY") > 0)
  CALL log_message("Log solution capability for Medical Record Request.",log_level_debug)
  FREE RECORD cap_request
  RECORD cap_request(
    1 teamname = vc
    1 capability_ident = vc
    1 entities[*]
      2 entity_id = f8
      2 entity_name = vc
  )
  SET cap_request->teamname = "CLINICAL_REPORTING"
  SET cap_request->capability_ident = "2011.1.00379.1"
  SET stat = alterlist(cap_request->entities,1)
  SET cap_request->entities[1].entity_name = "PERSON"
  SET cap_request->entities[1].entity_id = request->person_id
  EXECUTE pft_log_solution_capability  WITH replace("REQUEST","CAP_REQUEST")
  FREE RECORD cap_request
 ENDIF
 CALL retrievepersoninfo(null)
 IF ((request->encntr_id <= 0))
  CALL retrievepersonalias(null)
 ENDIF
 CALL retrievepersonpersonnelrelation(null)
 IF ((request->encntr_id > 0))
  CALL retrieveencounterinfo(null)
  CALL retrieveencounterpersonnelrelation(null)
 ENDIF
 IF (size(request->accession_nbr,1) > 0)
  SET reply->frmt_accession_nbr = uar_fmt_accession(request->accession_nbr,size(request->
    accession_nbr,1))
  CALL retrieveorderpersonnelrelation(null)
 ENDIF
 SET stat = alterlist(reply->prsnl_reltn,prsnlcnt)
 IF (prsnlcnt > 0)
  CALL retrievedeviceforproviders(null)
 ENDIF
 IF ((request->event_id > 0))
  CALL retrieveeventinfo(null)
 ENDIF
 SUBROUTINE retrievepersoninfo(null)
   CALL log_message("Retrieve person information",log_level_debug)
   SELECT INTO "nl:"
    p.name_full_formatted
    FROM person p
    PLAN (p
     WHERE (p.person_id=request->person_id)
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(currentdatetime)
      AND p.end_effective_dt_tm > cnvtdatetime(currentdatetime))
    DETAIL
     reply->name_full_formatted = p.name_full_formatted
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetPersonInfo","person table read error",1,1)
 END ;Subroutine
 SUBROUTINE retrievepersonpersonnelrelation(null)
   CALL log_message("Retrieve person personnel relation rows",log_level_debug)
   DECLARE personprsnlstat = vc WITH noconstant("")
   IF ((request->load_provider_ind=1))
    SET personprsnlstat = "1 = 1"
   ELSE
    SET personprsnlstat = "ppr.prsnl_person_id = request->requesting_prsnl_id"
   ENDIF
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     prsnl p
    PLAN (ppr
     WHERE (ppr.person_id=request->person_id)
      AND parser(personprsnlstat)
      AND ppr.active_ind=1
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(currentdatetime)
      AND ppr.end_effective_dt_tm > cnvtdatetime(currentdatetime)
      AND ppr.person_prsnl_r_cd > 0.0)
     JOIN (p
     WHERE p.person_id=ppr.prsnl_person_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(currentdatetime)
      AND p.end_effective_dt_tm > cnvtdatetime(currentdatetime))
    ORDER BY ppr.prsnl_person_id, ppr.person_prsnl_r_cd
    DETAIL
     prsnlcnt += 1
     IF (mod(prsnlcnt,10)=1)
      stat = alterlist(reply->prsnl_reltn,(prsnlcnt+ 9))
     ENDIF
     reply->prsnl_reltn[prsnlcnt].prsnl_person_id = ppr.prsnl_person_id, reply->prsnl_reltn[prsnlcnt]
     .prsnl_name_full_formatted = p.name_full_formatted, reply->prsnl_reltn[prsnlcnt].reltn_cd = ppr
     .person_prsnl_r_cd
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetPersonPersonnelRelation",
    "person_prsnl_reltn table read error",1,0)
 END ;Subroutine
 SUBROUTINE retrieveencounterinfo(null)
   CALL log_message("Retrieve encounter information",log_level_debug)
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_alias ea
    PLAN (e
     WHERE (e.encntr_id=request->encntr_id))
     JOIN (ea
     WHERE (ea.encntr_id= Outerjoin(e.encntr_id))
      AND (ea.active_ind= Outerjoin(1))
      AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(currentdatetime)))
      AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(currentdatetime))) )
    ORDER BY ea.encntr_alias_type_cd, ea.updt_dt_tm DESC
    HEAD REPORT
     reply->admission_dt_tm = cnvtdatetime(e.reg_dt_tm)
    HEAD ea.encntr_alias_type_cd
     IF (ea.encntr_alias_type_cd=mrn_cd)
      reply->encntr_mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSEIF (ea.encntr_alias_type_cd=fin_cd)
      reply->fin_nbr = cnvtalias(ea.alias,ea.alias_pool_cd)
     ENDIF
    DETAIL
     do_nothing = 0
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetEncounterInfo","encntr_alias table read error",1,0)
 END ;Subroutine
 SUBROUTINE retrieveencounterpersonnelrelation(null)
   CALL log_message("Retrieve encounter personnel relation rows",log_level_debug)
   DECLARE encntrprsnlstat = vc WITH noconstant("")
   IF ((request->load_provider_ind=1))
    SET encntrprsnlstat = "1 = 1"
   ELSE
    SET encntrprsnlstat = "epr.prsnl_person_id = request->requesting_prsnl_id"
   ENDIF
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr,
     prsnl p
    PLAN (epr
     WHERE (epr.encntr_id=request->encntr_id)
      AND parser(encntrprsnlstat)
      AND epr.active_ind=1
      AND epr.beg_effective_dt_tm <= cnvtdatetime(currentdatetime)
      AND epr.end_effective_dt_tm > cnvtdatetime(currentdatetime)
      AND epr.encntr_prsnl_r_cd > 0)
     JOIN (p
     WHERE p.person_id=epr.prsnl_person_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(currentdatetime)
      AND p.end_effective_dt_tm > cnvtdatetime(currentdatetime))
    ORDER BY epr.prsnl_person_id, epr.encntr_prsnl_r_cd
    DETAIL
     prsnlcnt += 1
     IF (mod(prsnlcnt,10)=1)
      stat = alterlist(reply->prsnl_reltn,(prsnlcnt+ 9))
     ENDIF
     reply->prsnl_reltn[prsnlcnt].prsnl_name_full_formatted = p.name_full_formatted, reply->
     prsnl_reltn[prsnlcnt].prsnl_person_id = epr.prsnl_person_id, reply->prsnl_reltn[prsnlcnt].
     reltn_cd = epr.encntr_prsnl_r_cd
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetEncntrPrsnlReltn","encntr_prsnl_reltn table read error",1,0)
 END ;Subroutine
 SUBROUTINE retrieveeventinfo(null)
   CALL log_message("Retrieve event information",log_level_debug)
   SELECT INTO "nl:"
    ce.event_id, ce.event_title_text
    FROM clinical_event ce
    WHERE (ce.event_id=request->event_id)
     AND ((ce.encntr_id+ 0)=request->encntr_id)
     AND ((ce.person_id+ 0)=request->person_id)
     AND ce.valid_until_dt_tm >= cnvtdatetime(currentdatetime)
    DETAIL
     reply->event_title_text = ce.event_title_text
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetEventInfo","clinical_event table read error",1,0)
 END ;Subroutine
 SUBROUTINE retrieveorderpersonnelrelation(null)
   CALL log_message("Retrieve order personnel relation rows",log_level_debug)
   DECLARE order_cnt = i4
   DECLARE num = i4
   DECLARE prsnl_cnt = i4
   DECLARE activate_cd = f8
   DECLARE modify_cd = f8
   DECLARE order_cd = f8
   DECLARE renew_cd = f8
   DECLARE resume_cd = f8
   DECLARE stud_activate_cd = f8
   SET stat = uar_get_meaning_by_codeset(6003,"ACTIVATE",1,activate_cd)
   SET stat = uar_get_meaning_by_codeset(6003,"MODIFY",1,modify_cd)
   SET stat = uar_get_meaning_by_codeset(6003,"ORDER",1,order_cd)
   SET stat = uar_get_meaning_by_codeset(6003,"RENEW",1,renew_cd)
   SET stat = uar_get_meaning_by_codeset(6003,"RESUME",1,resume_cd)
   SET stat = uar_get_meaning_by_codeset(6003,"STUDACTIVATE",1,stud_activate_cd)
   FREE RECORD orders
   RECORD orders(
     1 qual[*]
       2 order_id = f8
   )
   SELECT DISTINCT INTO "nl:"
    o1.order_id
    FROM accession_order_r aor,
     orders o1
    PLAN (aor
     WHERE (aor.accession=request->accession_nbr))
     JOIN (o1
     WHERE o1.order_id=aor.order_id
      AND ((o1.person_id+ 0)=request->person_id)
      AND ((o1.encntr_id+ 0)=request->encntr_id)
      AND o1.order_id > 0)
    ORDER BY o1.order_id
    HEAD REPORT
     order_cnt = 0
    HEAD o1.order_id
     order_cnt += 1
     IF (mod(order_cnt,5)=1)
      stat = alterlist(orders->qual,(order_cnt+ 4))
     ENDIF
     orders->qual[order_cnt].order_id = o1.order_id
    FOOT REPORT
     stat = alterlist(orders->qual,order_cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetOrdersForAccession","accession_order_r table read error",1,0
    )
   SET num = 0
   DECLARE orderprsnlstat = vc WITH noconstant("")
   IF ((request->load_provider_ind=1))
    SET orderprsnlstat = "1 = 1"
   ELSE
    SET orderprsnlstat = "oa.order_provider_id+0 = request->requesting_prsnl_id"
   ENDIF
   SELECT DISTINCT INTO "nl:"
    oa.order_provider_id
    FROM order_action oa,
     prsnl p
    PLAN (oa
     WHERE expand(num,1,order_cnt,oa.order_id,orders->qual[num].order_id)
      AND parser(orderprsnlstat)
      AND oa.action_type_cd IN (activate_cd, modify_cd, order_cd, renew_cd, resume_cd,
     stud_activate_cd)
      AND oa.action_rejected_ind=0)
     JOIN (p
     WHERE p.person_id=oa.order_provider_id
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(currentdatetime)
      AND p.end_effective_dt_tm > cnvtdatetime(currentdatetime))
    DETAIL
     prov_already_in_list = 0, prsnl_cnt = size(reply->prsnl_reltn,5)
     FOR (i = 1 TO prsnl_cnt)
       IF ((reply->prsnl_reltn[i].prsnl_person_id=p.person_id)
        AND (reply->prsnl_reltn[i].reltn_cd=order_doc_cd))
        i = (prsnl_cnt+ 1), prov_already_in_list = 1
       ENDIF
     ENDFOR
     IF (prov_already_in_list=0)
      prsnlcnt += 1
      IF (mod(prsnlcnt,10)=1)
       stat = alterlist(reply->prsnl_reltn,(prsnlcnt+ 9))
      ENDIF
      reply->prsnl_reltn[prsnlcnt].prsnl_person_id = oa.order_provider_id, reply->prsnl_reltn[
      prsnlcnt].prsnl_name_full_formatted = p.name_full_formatted, reply->prsnl_reltn[prsnlcnt].
      reltn_cd = order_doc_cd
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetOrderProvider","order_action table read error",1,0)
   SET num = 0
   DECLARE consultprsnlstat = vc WITH noconstant("")
   IF ((request->load_provider_ind=1))
    SET consultprsnlstat = "1 = 1"
   ELSE
    SET consultprsnlstat = "od.oe_field_value = request->requesting_prsnl_id"
   ENDIF
   SELECT DISTINCT INTO "nl:"
    od.oe_field_value
    FROM order_detail od,
     prsnl p
    PLAN (od
     WHERE expand(num,1,order_cnt,od.order_id,orders->qual[num].order_id)
      AND parser(consultprsnlstat)
      AND od.oe_field_meaning="CONSULTDOC")
     JOIN (p
     WHERE p.person_id=od.oe_field_value
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(currentdatetime)
      AND p.end_effective_dt_tm > cnvtdatetime(currentdatetime))
    ORDER BY od.order_id, od.action_sequence DESC
    HEAD REPORT
     do_nothing = 0
    HEAD od.order_id
     latest_action = 1
    HEAD od.action_sequence
     do_noting = 0
    DETAIL
     IF (latest_action=1)
      prov_already_in_list = 0, prsnl_cnt = size(reply->prsnl_reltn,5)
      FOR (i = 1 TO prsnl_cnt)
        IF ((reply->prsnl_reltn[i].prsnl_person_id=p.person_id)
         AND (reply->prsnl_reltn[i].reltn_cd=consult_doc_cd))
         i = (prsnl_cnt+ 1), prov_already_in_list = 1
        ENDIF
      ENDFOR
      IF (prov_already_in_list=0)
       prsnlcnt += 1
       IF (mod(prsnlcnt,10)=1)
        stat = alterlist(reply->prsnl_reltn,(prsnlcnt+ 9))
       ENDIF
       reply->prsnl_reltn[prsnlcnt].prsnl_person_id = od.oe_field_value, reply->prsnl_reltn[prsnlcnt]
       .prsnl_name_full_formatted = p.name_full_formatted, reply->prsnl_reltn[prsnlcnt].reltn_cd =
       consult_doc_cd
      ENDIF
     ENDIF
    FOOT  od.action_sequence
     IF (latest_action=1)
      latest_action = 0
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"GetOrderConsultDoc","order_detail table read error",1,0)
 END ;Subroutine
 SUBROUTINE retrievedeviceforproviders(null)
   CALL log_message("Retrieve device xref for providers",log_level_debug)
   SET idx = 0
   SET pos = 0
   SELECT INTO "nl:"
    dx.device_cd, d.device_type_cd
    FROM cr_destination_xref dx,
     device d,
     output_dest od,
     dms_service ds
    PLAN (dx
     WHERE expand(idx,1,prsnlcnt,dx.parent_entity_id,reply->prsnl_reltn[idx].prsnl_person_id)
      AND dx.parent_entity_name="PRSNL")
     JOIN (d
     WHERE d.device_cd=dx.device_cd)
     JOIN (od
     WHERE od.device_cd=d.device_cd)
     JOIN (ds
     WHERE (ds.dms_service_id= Outerjoin(d.dms_service_id)) )
    HEAD REPORT
     cnt1 = 0
    DETAIL
     pos = locateval(cnt1,1,prsnlcnt,dx.parent_entity_id,reply->prsnl_reltn[cnt1].prsnl_person_id)
     WHILE (pos > 0)
       reply->prsnl_reltn[cnt1].device_cd = d.device_cd, reply->prsnl_reltn[cnt1].device_name = d
       .name, reply->prsnl_reltn[cnt1].device_type_cd = d.device_type_cd,
       reply->prsnl_reltn[cnt1].output_dest_cd = od.output_dest_cd
       IF (ds.dms_service_id > 0.0
        AND d.distribution_flag=1)
        reply->prsnl_reltn[cnt1].dms_enabled_ind = 1
       ELSEIF (d.device_type_cd=fax_type_cd)
        reply->prsnl_reltn[cnt1].dms_enabled_ind = 1
       ENDIF
       reply->prsnl_reltn[cnt1].dms_service_identifier = dx.dms_service_identifier, pos = locateval(
        cnt1,(pos+ 1),prsnlcnt,dx.parent_entity_id,reply->prsnl_reltn[cnt1].prsnl_person_id)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
   CALL error_and_zero_check(curqual,"GetDeviceForProviders",
    "Getting device failed.  Exiting script.",1,0)
 END ;Subroutine
 SUBROUTINE retrievepersonalias(null)
   CALL log_message("Retrieve person alias",log_level_debug)
   SET security_ind = 0
   IF (validate(ccldminfo->mode,0))
    IF ((ccldminfo->sec_org_reltn > 0))
     SET security_ind = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     i.info_number
     FROM dm_info i
     WHERE i.info_name="SEC_ORG_RELTN"
      AND i.info_domain="SECURITY"
      AND ((i.info_number+ 0) > 0.0)
     DETAIL
      security_ind = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (security_ind=0)
    CALL log_message("Organization security is turned off in the system.",log_level_debug)
    SELECT INTO "nl:"
     pa.alias
     FROM person_alias pa
     PLAN (pa
      WHERE (pa.person_id=request->person_id)
       AND pa.person_alias_type_cd IN (person_mrn_cd, cmrn_cd)
       AND pa.active_ind=1
       AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
     ORDER BY pa.person_alias_type_cd, pa.updt_dt_tm DESC
     HEAD pa.person_alias_type_cd
      IF (pa.person_alias_type_cd=person_mrn_cd)
       reply->person_mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
      ELSEIF (pa.person_alias_type_cd=cmrn_cd)
       reply->person_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
      ENDIF
     DETAIL
      do_nothing = 0
     WITH nocounter
    ;end select
   ELSEIF (security_ind=1)
    CALL log_message("Organization security is turned on in the system.",log_level_debug)
    FREE RECORD userorgs
    RECORD userorgs(
      1 organizations[*]
        2 organization_id = f8
        2 confid_cd = f8
        2 confid_level = i4
    )
    FREE RECORD aliaspools
    RECORD useraliaspools(
      1 alias_pools[*]
        2 alias_pool_cd = f8
    )
    IF (checkprg("SAC_GET_USER_ORGANIZATIONS") > 0)
     EXECUTE sac_get_user_organizations  WITH replace("REPLY","USERORGS")
    ELSE
     SET reply->status_data.operationname = "fillreply"
     SET reply->status_data.subeventstatus[1].targetobjectname = "RetrievePersonAlias"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "Could not find sac_get_user_organizations"
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    SET totalorgs = size(userorgs->organizations,5)
    IF (totalorgs > 0)
     SET orgidx = 0
     SET orgstart = 1
     SELECT INTO "nl:"
      o.alias_pool_cd
      FROM org_alias_pool_reltn o
      WHERE o.alias_entity_name="PERSON_ALIAS"
       AND ((o.alias_pool_cd+ 0) > 0.0)
       AND o.active_ind=1
       AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND o.end_effective_dt_tm > cnvtdatetime(sysdate)
       AND expand(orgidx,orgstart,totalorgs,o.organization_id,userorgs->organizations[orgidx].
       organization_id)
      HEAD REPORT
       poolcnt = 0
      DETAIL
       poolcnt += 1
       IF (mod(poolcnt,10)=1)
        stat = alterlist(useraliaspools->alias_pools,(poolcnt+ 9))
       ENDIF
       useraliaspools->alias_pools[poolcnt].alias_pool_cd = o.alias_pool_cd
      FOOT REPORT
       stat = alterlist(useraliaspools->alias_pools,poolcnt)
      WITH nocounter, expand = 1
     ;end select
    ELSE
     CALL log_message("Org security is on and the user does not have access to any organization. ",
      log_level_debug)
    ENDIF
    SET aliaspoolcnt = size(useraliaspools->alias_pools,5)
    CALL echorecord(useraliaspools)
    IF (aliaspoolcnt > 0)
     SET poolidx = 0
     SET poolstart = 1
     SELECT INTO "nl:"
      pa.alias
      FROM person_alias pa
      PLAN (pa
       WHERE (pa.person_id=request->person_id)
        AND pa.person_alias_type_cd IN (person_mrn_cd, cmrn_cd)
        AND pa.active_ind=1
        AND pa.beg_effective_dt_tm <= cnvtdatetime(sysdate)
        AND pa.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND expand(poolidx,poolstart,aliaspoolcnt,pa.alias_pool_cd,useraliaspools->alias_pools[
        poolidx].alias_pool_cd))
      ORDER BY pa.person_alias_type_cd, pa.updt_dt_tm DESC
      HEAD pa.person_alias_type_cd
       IF (pa.person_alias_type_cd=person_mrn_cd)
        reply->person_mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
       ELSEIF (pa.person_alias_type_cd=cmrn_cd)
        reply->person_cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
       ENDIF
      DETAIL
       do_nothing = 0
      WITH nocounter, expand = 1
     ;end select
    ELSE
     CALL log_message("There is no alias pool associated to the user organization. ",log_level_debug)
    ENDIF
   ENDIF
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
 CALL log_message("End of script: CR_GET_MRR_CONTEXT",log_level_debug)
END GO
