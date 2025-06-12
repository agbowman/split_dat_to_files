CREATE PROGRAM cp_get_polled_request:dba
 RECORD reply(
   1 chart_request_id = f8
   1 request_type = i4
   1 scope_flag = i2
   1 event_ind = i2
   1 event_id = f8
   1 person_id = f8
   1 person_name = c50
   1 encntr_id = f8
   1 order_id = f8
   1 accession_nbr = c20
   1 frmt_accession_nbr = vc
   1 chart_format_id = f8
   1 distribution_id = f8
   1 distribution_name = vc
   1 dist_run_dt_tm = dq8
   1 dist_run_type_cd = f8
   1 dist_initiator_ind = i2
   1 dist_terminator_ind = i2
   1 date_range_ind = i2
   1 begin_dt_tm = dq8
   1 end_dt_tm = dq8
   1 page_range_ind = i2
   1 begin_page = i4
   1 end_page = i4
   1 addl_copies = i4
   1 print_complete_flag = i2
   1 chart_pending_flag = i2
   1 output_dest_cd = f8
   1 output_device_cd = f8
   1 request_prsnl_id = f8
   1 recover_cnt = i4
   1 rrd_deliver_dt_tm = dq8
   1 rrd_country_access = c3
   1 rrd_area_code = c10
   1 rrd_exchange = c10
   1 rrd_phone_suffix = c30
   1 trigger_id = f8
   1 trigger_type = c15
   1 prsnl_person_id = f8
   1 prsnl_person_r_cd = f8
   1 prsnl_reltn_id = f8
   1 prsnl_org_id = f8
   1 file_storage_cd = f8
   1 file_storage_disp = c40
   1 file_storage_mean = c12
   1 file_storage_loc = vc
   1 resubmit_cnt = i4
   1 total_pages = i4
   1 mcis_ind = i2
   1 chart_route_id = f8
   1 sequence_group_id = f8
   1 req_prov_list[*]
     2 provider_id = f8
     2 provider_role_cd = f8
     2 copy_ind = i2
   1 encntr_list[*]
     2 encntr_id = f8
   1 chart_section_list[*]
     2 chart_section_id = f8
   1 chart_batch_id = f8
   1 suppress_mrpnodata_ind = i2
   1 group_order_id = f8
   1 order_group_flag = i4
   1 order_list[*]
     2 order_id = f8
   1 result_lookup_ind = i2
   1 cr_mask_id = f8
   1 user_role_profile = vc
   1 chart_trigger_id = f8
   1 trigger_name = vc
   1 request_dt_tm = dq8
   1 non_ce_begin_dt_tm = dq8
   1 non_ce_end_dt_tm = dq8
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
 SET log_program_name = "CP_GET_POLLED_REQUEST"
 DECLARE uar_fmt_accession(p1,p2) = c25
 DECLARE getchartrequestrow(null) = null
 DECLARE getcrossencounterlist(null) = null
 DECLARE getorderlevellist(null) = null
 DECLARE getchartsectionidlist(null) = null
 SET reply->status_data.status = "F"
 CALL log_message("Starting script: cp_get_polled_request",log_level_debug)
 CALL getchartrequestrow(null)
 IF ((reply->scope_flag=5))
  CALL getcrossencounterlist(null)
 ELSEIF ((reply->scope_flag=3))
  CALL getorderlevellist(null)
 ENDIF
 IF ((reply->trigger_id > 0))
  SELECT INTO "nl:"
   FROM chart_request_event crev
   WHERE (crev.chart_request_id=request->chart_request_id)
   DETAIL
    reply->event_id = crev.event_id
   WITH nocounter
  ;end select
 ENDIF
 CALL getchartsectionidlist(null)
 SET reply->status_data.status = "S"
 SUBROUTINE getchartrequestrow(null)
   CALL log_message("In GetChartRequestRow()",log_level_debug)
   SELECT INTO "nl:"
    FROM chart_request cr,
     chart_distribution cd,
     person p,
     prsnl_reltn pr,
     prsnl_org_reltn por
    PLAN (cr
     WHERE (cr.chart_request_id=request->chart_request_id))
     JOIN (cd
     WHERE (cd.distribution_id= Outerjoin(cr.distribution_id)) )
     JOIN (p
     WHERE p.person_id=cr.person_id)
     JOIN (pr
     WHERE (pr.prsnl_reltn_id= Outerjoin(cr.prsnl_reltn_id))
      AND (pr.prsnl_reltn_id> Outerjoin(0)) )
     JOIN (por
     WHERE (por.prsnl_org_reltn_id= Outerjoin(pr.parent_entity_id)) )
    HEAD REPORT
     reply->chart_request_id = cr.chart_request_id, reply->request_type = cr.request_type, reply->
     scope_flag = cr.scope_flag,
     reply->event_ind = cr.event_ind, reply->person_id = cr.person_id, reply->person_name = substring
     (1,50,p.name_full_formatted),
     reply->encntr_id = cr.encntr_id, reply->order_id = cr.order_id, reply->accession_nbr = cr
     .accession_nbr
     IF (cr.scope_flag=4)
      reply->frmt_accession_nbr = uar_fmt_accession(cr.accession_nbr,size(cr.accession_nbr,1))
     ELSE
      reply->frmt_accession_nbr = ""
     ENDIF
     reply->chart_format_id = cr.chart_format_id, reply->distribution_id = cr.distribution_id, reply
     ->distribution_name = cd.dist_descr,
     reply->dist_run_dt_tm = cr.dist_run_dt_tm, reply->dist_run_type_cd = cr.dist_run_type_cd, reply
     ->dist_initiator_ind = cr.dist_initiator_ind,
     reply->dist_terminator_ind = cr.dist_terminator_ind, reply->date_range_ind = cr.date_range_ind,
     reply->begin_dt_tm = cr.begin_dt_tm,
     reply->end_dt_tm = cr.end_dt_tm, reply->page_range_ind = cr.page_range_ind, reply->begin_page =
     cr.begin_page,
     reply->end_page = cr.end_page, reply->addl_copies = cr.addl_copies, reply->print_complete_flag
      = cr.print_complete_flag,
     reply->chart_pending_flag = cr.chart_pending_flag, reply->output_dest_cd = cr.output_dest_cd,
     reply->output_device_cd = cr.output_device_cd,
     reply->request_prsnl_id = cr.request_prsnl_id, reply->recover_cnt = cr.recover_cnt, reply->
     rrd_deliver_dt_tm = cr.rrd_deliver_dt_tm,
     reply->rrd_country_access = cr.rrd_country_access, reply->rrd_area_code = cr.rrd_area_code,
     reply->rrd_exchange = cr.rrd_exchange,
     reply->rrd_phone_suffix = cr.rrd_phone_suffix, reply->trigger_id = cr.trigger_id, reply->
     trigger_type = cr.trigger_type,
     reply->prsnl_person_id = cr.prsnl_person_id, reply->prsnl_person_r_cd = cr.prsnl_person_r_cd,
     reply->prsnl_reltn_id = cr.prsnl_reltn_id,
     reply->prsnl_org_id =
     IF (pr.parent_entity_name="ORGANIZATION") pr.parent_entity_id
     ELSEIF (pr.parent_entity_name="PRSNL_ORG_RELTN") por.organization_id
     ENDIF
     , reply->file_storage_cd = cr.file_storage_cd, reply->file_storage_loc = cr
     .file_storage_location,
     reply->resubmit_cnt = cr.resubmit_cnt, reply->total_pages = cr.total_pages, reply->mcis_ind = cr
     .mcis_ind,
     reply->chart_route_id = cr.chart_route_id, reply->sequence_group_id = cr.sequence_group_id,
     reply->chart_batch_id = cr.chart_batch_id,
     reply->suppress_mrpnodata_ind = cr.suppress_mrpnodata_ind, reply->order_group_flag = cr
     .order_group_flag, reply->group_order_id = cr.group_order_id,
     reply->result_lookup_ind = cr.result_lookup_ind, reply->cr_mask_id = cr.cr_mask_id, reply->
     user_role_profile = validate(cr.user_role_profile,""),
     reply->trigger_name = validate(cr.trigger_name,""), reply->chart_trigger_id = validate(cr
      .chart_trigger_id,""), reply->request_dt_tm = cr.request_dt_tm,
     reply->non_ce_begin_dt_tm = cr.non_ce_begin_dt_tm, reply->non_ce_end_dt_tm = cr.non_ce_end_dt_tm
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_REQUEST","GetChartRequestRow",1,1)
 END ;Subroutine
 SUBROUTINE getcrossencounterlist(null)
   CALL log_message("In GetCrossEncounterList()",log_level_debug)
   SELECT INTO "nl:"
    FROM chart_request_encntr cre
    WHERE (cre.chart_request_id=request->chart_request_id)
    HEAD REPORT
     encntr_num = 0
    DETAIL
     encntr_num += 1
     IF (mod(encntr_num,10)=1)
      stat = alterlist(reply->encntr_list,(encntr_num+ 9))
     ENDIF
     reply->encntr_list[encntr_num].encntr_id = cre.encntr_id
    FOOT REPORT
     stat = alterlist(reply->encntr_list,encntr_num)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_REQUEST_ENCNTR","GetCrossEncounterList",1,0)
 END ;Subroutine
 SUBROUTINE getorderlevellist(null)
   CALL log_message("In GetOrderLevelList()",log_level_debug)
   SELECT INTO "nl:"
    FROM chart_request_order cro
    WHERE (cro.chart_request_id=request->chart_request_id)
    ORDER BY cro.chart_request_order_id
    HEAD REPORT
     order_num = 0
    DETAIL
     order_num += 1
     IF (mod(order_num,10)=1)
      stat = alterlist(reply->order_list,(order_num+ 9))
     ENDIF
     reply->order_list[order_num].order_id = cro.order_id
    FOOT REPORT
     stat = alterlist(reply->order_list,order_num)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_REQUEST_ORDER","GetOrderLevelList",1,0)
 END ;Subroutine
 SUBROUTINE getchartsectionidlist(null)
   CALL log_message("In GetOrderLevelList()",log_level_debug)
   SELECT INTO "nl:"
    crs.chart_section_id
    FROM chart_request_section crs
    WHERE (crs.chart_request_id=request->chart_request_id)
    HEAD REPORT
     section_nbr = 0
    DETAIL
     section_nbr += 1
     IF (mod(section_nbr,10)=1)
      stat = alterlist(reply->chart_section_list,(section_nbr+ 9))
     ENDIF
     reply->chart_section_list[section_nbr].chart_section_id = crs.chart_section_id
    FOOT REPORT
     stat = alterlist(reply->chart_section_list,section_nbr)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_REQUEST_SECTION","GetChartSectionIdList",1,0)
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_get_polled_request",log_level_debug)
END GO
