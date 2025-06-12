CREATE PROGRAM cr_srv_upd_report_requests:dba
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
 IF (validate(request) != 1)
  RECORD request(
    1 requests[*]
      2 request_type_flag = i2
      2 scope_flag = i2
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 person_id = f8
      2 encntr_id = f8
      2 xencntr_ids[*]
        3 encntr_id = f8
      2 event_ids[*]
        3 event_id = f8
      2 accession_nbr = c20
      2 order_id = f8
      2 request_prsnl_id = f8
      2 provider_prsnl_id = f8
      2 provider_reltn_cd = f8
      2 template_id = f8
      2 distribution_id = f8
      2 dist_run_type_cd = f8
      2 dist_run_dt_tm = dq8
      2 dist_seq = i4
      2 reader_group = c15
      2 route_id = f8
      2 route_stop_id = f8
      2 output_dest_cd = f8
      2 trigger_name = c100
      2 eso_trigger_id = f8
      2 eso_trigger_type = c15
      2 result_status_flag = i2
      2 use_posting_date_flag = i2
      2 user_role_profile = vc
      2 section_ids[*]
        3 section_id = f8
      2 sequence_nbr = i4
      2 dms_service_ident = vc
      2 copies_nbr = i4
      2 fax_distribute_dt_tm = dq8
      2 adhoc_fax_number = vc
      2 output_content_type = vc
      2 template_version_mode_flag = i2
      2 template_version_dt_tm = dq8
      2 prsnl_reltn_id = f8
      2 output_content_type_cd = f8
      2 file_mask = vc
      2 file_name = vc
      2 output_destinations[*]
        3 output_dest_cd = f8
        3 dms_service_ident = vc
        3 dms_fax_distribute_dt_tm = dq8
        3 dms_adhoc_fax_number = vc
        3 copies_nbr = i4
      2 non_ce_begin_dt_tm = dq8
      2 non_ce_end_dt_tm = dq8
      2 contact_info = vc
      2 custodial_org_id = f8
      2 sender_email = vc
      2 external_content_ident = vc
      2 external_content_name = vc
      2 prsnl_role_profile_uid = vc
    1 test_ind = i2
    1 requesting_locale = c5
    1 print_ind = i2
  )
 ENDIF
 IF (validate(reply) != 1)
  RECORD reply(
    1 requests[*]
      2 report_request_id = f8
      2 request_xml = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE updatereportrequest(null) = null
 DECLARE g_perform_1370009_failed = i2 WITH protect, noconstant(0)
 DECLARE g_override_print_ind = i2 WITH protect, noconstant(0)
 CALL updatereportrequest(null)
 SUBROUTINE updatereportrequest(null)
   DECLARE lapp_num = i4 WITH protect, constant(3202004)
   DECLARE ltask_num = i4 WITH protect, constant(3202004)
   DECLARE lreq_num = i4 WITH protect, constant(1370009)
   DECLARE ldefault_copies = i4 WITH protect, constant(1)
   DECLARE ecrmok = i2 WITH protect, constant(0)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE hrep = i4 WITH private, noconstant(0)
   DECLARE hstatusdata = i4 WITH protect, noconstant(0)
   DECLARE ncrmstat = i2 WITH protect, noconstant(0)
   DECLARE nsrvstat = i2 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE hrequestitem = i4 WITH protect, noconstant(0)
   DECLARE sstatus = c1 WITH protect, noconstant(" ")
   DECLARE soperationname = c25 WITH protect, noconstant(fillstring(25," "))
   DECLARE soperationstatus = c1 WITH protect, noconstant(" ")
   DECLARE stargetobjectname = c25 WITH protect, noconstant(fillstring(25," "))
   DECLARE stargetobjectvalue = vc WITH protect, noconstant(" ")
   DECLARE string15 = i4 WITH protect, constant(15)
   DECLARE string20 = i4 WITH protect, constant(20)
   DECLARE string100 = i4 WITH protect, constant(100)
   DECLARE lrequestsidx = i4 WITH protect, noconstant(0)
   DECLARE lrequestscnt = i4 WITH protect, noconstant(0)
   DECLARE hrequestsqual = i4 WITH protect, noconstant(0)
   DECLARE lsectioncnt = i4 WITH protect, noconstant(0)
   DECLARE lsectionidx = i4 WITH protect, noconstant(0)
   DECLARE hsectionqual = i4 WITH protect, noconstant(0)
   DECLARE lxencntrcnt = i4 WITH protect, noconstant(0)
   DECLARE lxencntridx = i4 WITH protect, noconstant(0)
   DECLARE hxencntrqual = i4 WITH protect, noconstant(0)
   DECLARE leventcnt = i4 WITH protect, noconstant(0)
   DECLARE leventidx = i4 WITH protect, noconstant(0)
   DECLARE heventqual = i4 WITH protect, noconstant(0)
   DECLARE loutputdestinationscnt = i4 WITH protect, noconstant(0)
   DECLARE loutputdestinationsidx = i4 WITH protect, noconstant(0)
   DECLARE houtputdestinationsqual = i4 WITH protect, noconstant(0)
   RECORD recdate(
     1 datetime = dq8
   )
   SET ncrmstat = uar_crmbeginapp(lapp_num,happ)
   IF (((ncrmstat != ecrmok) OR (happ=0)) )
    CALL handleerror("GET","F","Application Handle",cnvtstring(ncrmstat))
    CALL exit_1370009(happ,htask,hstep)
   ENDIF
   SET ncrmstat = uar_crmbegintask(happ,ltask_num,htask)
   IF (((ncrmstat != ecrmok) OR (htask=0)) )
    CALL handleerror("GET","F","Task Handle",cnvtstring(ncrmstat))
    CALL exit_1370009(happ,htask,hstep)
   ENDIF
   SET ncrmstat = uar_crmbeginreq(htask,0,lreq_num,hstep)
   IF (((ncrmstat != ecrmok) OR (hstep=0)) )
    CALL handleerror("GET","F","Req Handle",cnvtstring(ncrmstat))
    CALL exit_1370009(happ,htask,hstep)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq=0)
    CALL handleerror("GET","F","Req Handle",cnvtstring(ncrmstat))
    CALL exit_1370009(happ,htask,hstep)
   ENDIF
   SET nsrvstat = uar_srvsetshort(hreq,"update_ind",0)
   DECLARE output_content_type = vc WITH noconstant("")
   DECLARE adhoc_fax_number = vc WITH noconstant("")
   DECLARE dms_serv_ident = vc WITH noconstant("")
   DECLARE user_role_prof = vc WITH noconstant("")
   DECLARE contact_info = vc WITH noconstant("")
   DECLARE sender_email = vc WITH noconstant("")
   SET lrequestscnt = size(request->requests,5)
   FOR (lrequestsidx = 1 TO lrequestscnt)
     IF ((request->requests[lrequestsidx].eso_trigger_id > 0))
      SET g_override_print_ind = 1
     ENDIF
     SET hrequestsqual = uar_srvadditem(hreq,"requests")
     SET nsrvstat = uar_srvsetshort(hrequestsqual,"request_type_flag",request->requests[lrequestsidx]
      .request_type_flag)
     SET nsrvstat = uar_srvsetshort(hrequestsqual,"scope_flag",request->requests[lrequestsidx].
      scope_flag)
     SET recdate->datetime = request->requests[lrequestsidx].begin_dt_tm
     SET nsrvstat = uar_srvsetdate2(hrequestsqual,"begin_dt_tm",recdate)
     SET recdate->datetime = null
     SET recdate->datetime = request->requests[lrequestsidx].end_dt_tm
     SET nsrvstat = uar_srvsetdate2(hrequestsqual,"end_dt_tm",recdate)
     SET recdate->datetime = null
     SET recdate->datetime = request->requests[lrequestsidx].non_ce_begin_dt_tm
     SET nsrvstat = uar_srvsetdate2(hrequestsqual,"non_ce_begin_dt_tm",recdate)
     SET recdate->datetime = null
     SET recdate->datetime = request->requests[lrequestsidx].non_ce_end_dt_tm
     SET nsrvstat = uar_srvsetdate2(hrequestsqual,"non_ce_end_dt_tm",recdate)
     SET recdate->datetime = null
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"person_id",request->requests[lrequestsidx].
      person_id)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"encntr_id",request->requests[lrequestsidx].
      encntr_id)
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"accession_nbr",request->requests[
      lrequestsidx].accession_nbr,string20)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"order_id",request->requests[lrequestsidx].
      order_id)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"request_prsnl_id",request->requests[lrequestsidx]
      .request_prsnl_id)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"provider_prsnl_id",request->requests[lrequestsidx
      ].provider_prsnl_id)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"provider_reltn_cd",request->requests[lrequestsidx
      ].provider_reltn_cd)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"template_id",request->requests[lrequestsidx].
      template_id)
     SET nsrvstat = uar_srvsetshort(hrequestsqual,"template_version_mode_flag",request->requests[
      lrequestsidx].template_version_mode_flag)
     SET recdate->datetime = request->requests[lrequestsidx].template_version_dt_tm
     SET nsrvstat = uar_srvsetdate2(hrequestsqual,"template_version_dt_tm",recdate)
     SET recdate->datetime = null
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"distribution_id",request->requests[lrequestsidx].
      distribution_id)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"dist_run_type_cd",request->requests[lrequestsidx]
      .dist_run_type_cd)
     SET recdate->datetime = request->requests[lrequestsidx].dist_run_dt_tm
     SET nsrvstat = uar_srvsetdate2(hrequestsqual,"dist_run_dt_tm",recdate)
     SET recdate->datetime = null
     SET nsrvstat = uar_srvsetlong(hrequestsqual,"dist_seq",request->requests[lrequestsidx].dist_seq)
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"reader_group",request->requests[lrequestsidx
      ].reader_group,string15)
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"trigger_name",request->requests[lrequestsidx
      ].trigger_name,string100)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"eso_trigger_id",request->requests[lrequestsidx].
      eso_trigger_id)
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"eso_trigger_type",request->requests[
      lrequestsidx].eso_trigger_type,string15)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"output_dest_cd",request->requests[lrequestsidx].
      output_dest_cd)
     SET lxencntrcnt = size(request->requests[lrequestsidx].xencntr_ids,5)
     FOR (lxencntridx = 1 TO lxencntrcnt)
      SET hxencntrqual = uar_srvadditem(hrequestsqual,"xencntr_ids")
      SET nsrvstat = uar_srvsetdouble(hxencntrqual,"encntr_id",request->requests[lrequestsidx].
       xencntr_ids[lxencntridx].encntr_id)
     ENDFOR
     SET lsectioncnt = size(request->requests[lrequestsidx].section_ids,5)
     FOR (lsectionidx = 1 TO lsectioncnt)
      SET hsectionqual = uar_srvadditem(hrequestsqual,"sections")
      SET nsrvstat = uar_srvsetdouble(hsectionqual,"section_id",request->requests[lrequestsidx].
       section_ids[lsectionidx].section_id)
     ENDFOR
     SET leventcnt = size(request->requests[lrequestsidx].event_ids,5)
     FOR (leventidx = 1 TO leventcnt)
      SET heventqual = uar_srvadditem(hrequestsqual,"events")
      SET nsrvstat = uar_srvsetdouble(heventqual,"event_id",request->requests[lrequestsidx].
       event_ids[leventidx].event_id)
     ENDFOR
     SET user_role_prof = request->requests[lrequestsidx].user_role_profile
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"request_role_profile",user_role_prof,size(
       user_role_prof,1))
     SET user_role_prof = ""
     SET nsrvstat = uar_srvsetshort(hrequestsqual,"result_status_flag",request->requests[lrequestsidx
      ].result_status_flag)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"route_id",request->requests[lrequestsidx].
      route_id)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"route_stop_id",request->requests[lrequestsidx].
      route_stop_id)
     IF ((request->requests[lrequestsidx].copies_nbr >= ldefault_copies))
      SET nsrvstat = uar_srvsetlong(hrequestsqual,"num_copies",request->requests[lrequestsidx].
       copies_nbr)
     ELSE
      SET nsrvstat = uar_srvsetlong(hrequestsqual,"num_copies",ldefault_copies)
     ENDIF
     SET nsrvstat = uar_srvsetshort(hrequestsqual,"use_posting_date_ind",request->requests[
      lrequestsidx].use_posting_date_flag)
     SET dms_serv_ident = request->requests[lrequestsidx].dms_service_ident
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"dms_service_ident",dms_serv_ident,size(
       dms_serv_ident,1))
     SET dms_serv_ident = ""
     IF (validate(request->requests[lrequestsidx].custodial_org_id)=1)
      SET nsrvstat = uar_srvsetdouble(hrequestsqual,"custodial_org_id",request->requests[lrequestsidx
       ].custodial_org_id)
     ENDIF
     IF (validate(request->requests[lrequestsidx].sender_email)=1)
      SET sender_email = request->requests[lrequestsidx].sender_email
      SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"sender_email",sender_email,size(
        sender_email,1))
      SET sender_email = ""
     ENDIF
     SET contact_info = request->requests[lrequestsidx].contact_info
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"contact_info",contact_info,size(contact_info,
       1))
     SET contact_info = ""
     SET recdate->datetime = request->requests[lrequestsidx].fax_distribute_dt_tm
     SET nsrvstat = uar_srvsetdate2(hrequestsqual,"fax_distribute_dt_tm",recdate)
     SET recdate->datetime = null
     SET adhoc_fax_number = request->requests[lrequestsidx].adhoc_fax_number
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"adhoc_fax_number",adhoc_fax_number,size(
       adhoc_fax_number,1))
     SET adhoc_fax_number = ""
     SET output_content_type = request->requests[lrequestsidx].output_content_type
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"output_content_type",output_content_type,
      size(output_content_type,1))
     SET output_content_type = ""
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"output_content_type_cd",request->requests[
      lrequestsidx].output_content_type_cd)
     SET nsrvstat = uar_srvsetdouble(hrequestsqual,"prsnl_reltn_id",request->requests[lrequestsidx].
      prsnl_reltn_id)
     SET file_mask = request->requests[lrequestsidx].file_mask
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"file_mask",file_mask,size(file_mask,1))
     SET file_mask = ""
     SET file_name = request->requests[lrequestsidx].file_name
     SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"file_name",file_name,size(file_name,1))
     SET file_name = ""
     SET loutputdestinationscnt = size(request->requests[lrequestsidx].output_destinations,5)
     IF (validate(request->requests[lrequestsidx].external_content_ident)=1)
      SET external_content_ident = request->requests[lrequestsidx].external_content_ident
      SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"external_content_ident",
       external_content_ident,size(external_content_ident,1))
      SET external_content_ident = ""
     ENDIF
     IF (validate(request->requests[lrequestsidx].external_content_name)=1)
      SET external_content_name = request->requests[lrequestsidx].external_content_name
      SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"external_content_name",
       external_content_name,size(external_content_name,1))
      SET external_content_name = ""
     ENDIF
     IF (validate(request->requests[lrequestsidx].prsnl_role_profile_uid)=1)
      SET prsnl_role_profile_uid = request->requests[lrequestsidx].prsnl_role_profile_uid
      SET nsrvstat = uar_srvsetstringfixed(hrequestsqual,"prsnl_role_profile_uid",
       prsnl_role_profile_uid,size(prsnl_role_profile_uid,1))
      SET prsnl_role_profile_uid = ""
     ENDIF
     FOR (loutputdestinationsidx = 1 TO loutputdestinationscnt)
       SET houtputdestinationsqual = uar_srvadditem(hrequestsqual,"output_destinations")
       SET nsrvstat = uar_srvsetdouble(houtputdestinationsqual,"output_dest_cd",request->requests[
        lrequestsidx].output_destinations[loutputdestinationsidx].output_dest_cd)
       SET dms_service_ident = request->requests[lrequestsidx].output_destinations[
       loutputdestinationsidx].dms_service_ident
       SET nsrvstat = uar_srvsetstringfixed(houtputdestinationsqual,"dms_service_ident",
        dms_service_ident,size(dms_service_ident,1))
       SET dms_service_ident = ""
       SET recdate->datetime = request->requests[lrequestsidx].output_destinations[
       loutputdestinationsidx].dms_fax_distribute_dt_tm
       SET nsrvstat = uar_srvsetdate2(houtputdestinationsqual,"dms_fax_distribute_dt_tm",recdate)
       SET recdate->datetime = null
       SET dms_adhoc_fax_number = request->requests[lrequestsidx].output_destinations[
       loutputdestinationsidx].dms_adhoc_fax_number
       SET nsrvstat = uar_srvsetstringfixed(houtputdestinationsqual,"dms_adhoc_fax_number",
        dms_adhoc_fax_number,size(dms_adhoc_fax_number,1))
       SET dms_adhoc_fax_number = ""
       IF ((request->requests[lrequestsidx].output_destinations[loutputdestinationsidx].copies_nbr
        >= ldefault_copies))
        SET nsrvstat = uar_srvsetlong(houtputdestinationsqual,"copies_nbr",request->requests[
         lrequestsidx].output_destinations[loutputdestinationsidx].copies_nbr)
       ELSE
        SET nsrvstat = uar_srvsetlong(houtputdestinationsqual,"copies_nbr",ldefault_copies)
       ENDIF
     ENDFOR
   ENDFOR
   SET ncrmstat = uar_crmperform(hstep)
   IF (ncrmstat=ecrmok)
    SET hrep = uar_crmgetreply(hstep)
    SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
    SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
    IF (sstatus != "S")
     IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
      SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
      SET soperationname = uar_srvgetstringptr(hitem,"OperationName")
      SET soperationstatus = uar_srvgetstringptr(hitem,"OperationStatus")
      SET stargetobjectname = uar_srvgetstringptr(hitem,"TargetObjectName")
      SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
     ENDIF
     CALL handleerror(soperationname,soperationstatus,stargetobjectname,stargetobjectvalue)
     CALL exit_1370009(happ,htask,hstep)
    ELSE
     SET reqcnt = uar_srvgetitemcount(hrep,"requests")
     SET stat = alterlist(reply->requests,reqcnt)
     FOR (x = 1 TO reqcnt)
      SET hitem = uar_srvgetitem(hrep,"requests",(x - 1))
      SET reply->requests[x].report_request_id = uar_srvgetdouble(hitem,"report_request_id")
     ENDFOR
    ENDIF
   ELSE
    CALL handleerror("PERFORM","F","CR_UPD_REPORT_REQUESTS",cnvtstring(ncrmstat))
    CALL exit_1370009(happ,htask,hstep)
   ENDIF
   FREE RECORD recdate
   CALL sendhttprequest(hrep)
   CALL exit_1370009(happ,htask,hstep)
 END ;Subroutine
 SUBROUTINE (handleerror(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc
  ) =null)
   SET reply->status_data.status = "F"
   IF (size(reply->status_data.subeventstatus,5)=0)
    SET stat = alterlist(reply->status_data.subeventstatus,1)
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   SET g_perform_1370009_failed = 1
 END ;Subroutine
 SUBROUTINE (sendhttprequest(hrep=i4) =null)
   FREE RECORD send_request
   RECORD send_request(
     1 requests[*]
       2 request_id = f8
       2 debug_ind = i2
       2 print_ind = i2
     1 requesting_locale = c5
   )
   FREE RECORD send_reply
   RECORD send_reply(
     1 http_status_code = i4
     1 http_status = vc
     1 content_type = vc
     1 response_uri = vc
     1 response_buffer = gvc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET send_request->requesting_locale = request->requesting_locale
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(uar_srvgetitemcount(hrep,"requests")))
    HEAD REPORT
     req_cnt = 0
    DETAIL
     req_cnt += 1
     IF (mod(req_cnt,10)=1)
      stat = alterlist(send_request->requests,(req_cnt+ 9))
     ENDIF
     hrequestitem = uar_srvgetitem(hrep,"requests",(d1.seq - 1)), send_request->requests[d1.seq].
     request_id = uar_srvgetdouble(hrequestitem,"report_request_id")
     IF ((request->test_ind > 0))
      send_request->requests[d1.seq].debug_ind = 1
     ENDIF
     IF (g_override_print_ind=1)
      send_request->requests[d1.seq].print_ind = 1
     ELSE
      send_request->requests[d1.seq].print_ind = request->print_ind
     ENDIF
    FOOT REPORT
     stat = alterlist(send_request->requests,req_cnt)
    WITH nocounter
   ;end select
   CALL echorecord(send_request)
   EXECUTE cr_send_http_requests  WITH replace(request,send_request), replace(reply,send_reply)
   CALL echorecord(send_reply)
   IF ((send_reply->status_data.status != "S"))
    IF (size(send_reply->status_data.subeventstatus,5) > 0)
     SET soperationname = send_reply->status_data.subeventstatus[1].operationname
     SET soperationstatus = send_reply->status_data.subeventstatus[1].operationstatus
     SET stargetobjectname = send_reply->status_data.subeventstatus[1].targetobjectname
     SET stargetobjectvalue = send_reply->status_data.subeventstatus[1].targetobjectvalue
    ENDIF
    CALL handleerror(soperationname,soperationstatus,stargetobjectname,stargetobjectvalue)
    CALL exit_1370009(happ,htask,hstep)
   ENDIF
 END ;Subroutine
 SUBROUTINE (exit_1370009(happ=i4,htask=i4,hstep=i4) =null)
   IF (hstep != 0)
    SET ncrmstat = uar_crmendreq(hstep)
   ENDIF
   IF (htask != 0)
    SET ncrmstat = uar_crmendtask(htask)
   ENDIF
   IF (happ != 0)
    SET ncrmstat = uar_crmendapp(happ)
   ENDIF
   IF (g_perform_1370009_failed=1)
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
END GO
