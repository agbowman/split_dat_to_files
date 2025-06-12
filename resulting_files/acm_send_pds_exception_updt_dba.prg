CREATE PROGRAM acm_send_pds_exception_updt:dba
 IF ((validate(ipm_logmsg_exists,- (999))=- (999)))
  DECLARE pm_logmsg(spm_message=vc,ipm_loglevel=i2) = null
  DECLARE pm_get_error(error=i2) = vc
  DECLARE ipmmsglvl_audit = i2 WITH constant(2)
  DECLARE ipmmsglvl_debug = i2 WITH constant(4)
  DECLARE ipmmsglvl_info = i2 WITH constant(3)
  DECLARE ipmmsglvl_error = i2 WITH constant(0)
  DECLARE ipmmsglvl_warning = i2 WITH constant(1)
  DECLARE pm_log_handle = i4 WITH public, noconstant(0)
  DECLARE pm_log_status = i4 WITH public, noconstant(0)
  DECLARE cscript_name = c32 WITH public, noconstant(" ")
  DECLARE ipm_logmsg_exists = i2 WITH public, noconstant(1)
  SUBROUTINE pm_logmsg(spm_message,ipm_loglevel)
    IF ((ipm_loglevel > - (1))
     AND textlen(trim(spm_message,3)) > 0)
     CALL uar_syscreatehandle(pm_log_handle,pm_log_status)
     IF (pm_log_handle != 0)
      CALL uar_sysevent(pm_log_handle,ipm_loglevel,cscript_name,nullterm(spm_message))
      CALL uar_sysdestroyhandle(pm_log_handle)
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 DECLARE call_echo_ind = i4 WITH protect, noconstant(0)
 EXECUTE crmrtl
 EXECUTE srvrtl
 EXECUTE secrtl
 DECLARE hprop = i4 WITH protect, noconstant(0)
 DECLARE spropname = vc WITH protect, noconstant("")
 DECLARE sroleprofile = vc WITH protect, noconstant("")
 DECLARE happ = i4 WITH protect, noconstant(0)
 DECLARE htask = i4 WITH protect, noconstant(0)
 DECLARE hstep = i4 WITH protect, noconstant(0)
 DECLARE hreply = i4 WITH protect, noconstant(0)
 DECLARE hrequest = i4 WITH protect, noconstant(0)
 DECLARE hversion = i4 WITH protect, noconstant(0)
 DECLARE hpatient = i4 WITH protect, noconstant(0)
 DECLARE hpersonname = i4 WITH protect, noconstant(0)
 DECLARE haddress = i4 WITH protect, noconstant(0)
 DECLARE hphone = i4 WITH protect, noconstant(0)
 DECLARE hstatus = i4 WITH protect, noconstant(0)
 SET hstep = 0
 SET htask = 0
 SET happ = 0
 SET crmstatus = uar_crmbeginapp(3202004,happ)
 IF (crmstatus)
  SET failed = execute_error
  SET table_name = concat("Begin app(3202004) failed with status: ",cnvtstring(crmstatus))
  IF (call_echo_ind)
   CALL echo(concat("Begin app 3202004 failed with status: ",cnvtstring(crmstatus)))
  ENDIF
  CALL pm_logmsg(concat("Begin app(3202004) failed with status: ",cnvtstring(crmstatus)),0)
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbegintask(happ,3202004,htask)
 IF (crmstatus)
  SET failed = execute_error
  SET table_name = concat("Begin task(3202004) failed with status: ",cnvtstring(crmstatus))
  IF (call_echo_ind)
   CALL echo(concat("Begin task 3202004 failed with status: ",cnvtstring(crmstatus)))
  ENDIF
  CALL pm_logmsg(concat("Begin task(3202004) failed with status: ",cnvtstring(crmstatus)),0)
  GO TO exit_task
 ENDIF
 SET crmstatus = uar_crmbeginreq(htask,0,4135133,hstep)
 IF (crmstatus)
  SET failed = execute_error
  SET table_name = concat("Begin req(4135133) failed with status: ",cnvtstring(crmstatus))
  IF (call_echo_ind)
   CALL echo(concat("Begin req 4135133 failed with status: ",cnvtstring(crmstatus)))
  ENDIF
  CALL pm_logmsg(concat("Begin req 4135133 failed with status: ",cnvtstring(crmstatus)),0)
  GO TO exit_req
 ENDIF
 SET hrequest = uar_crmgetrequest(hstep)
 SET hprop = uar_srvcreateproperty()
 SET stat = uar_secgetclientattributesext(5,hprop)
 SET spropname = uar_srvfirstproperty(hprop)
 SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
 SET stat = uar_srvdestroyhandle(hprop)
 SET hitem = uar_srvadditem(hrequest,"transaction_relation")
 SET stat = uar_srvsetdouble(hitem,"parent_entity_id",local_person_id)
 SET stat = uar_srvsetstring(hitem,"parent_entity_name","PERSON")
 SET hinfo = uar_srvgetstruct(hrequest,"info")
 SET stat = uar_srvsetdouble(hinfo,"transaction_cd",loadcodevalue(25375,"PDSGENUPDATE",0))
 SET stat = uar_srvsetdouble(hinfo,"update_type_cd",loadcodevalue(23050,"CHANGED",0))
 SET hversion = uar_srvgetstruct(hinfo,"version")
 SET stat = uar_srvsetstring(hversion,"major","3")
 SET stat = uar_srvsetstring(hversion,"minor","1")
 SET stat = uar_srvsetstring(hversion,"patch","10")
 SET stat = uar_srvsetshort(hinfo,"performer_logon_type_flag",user_log_type_flag)
 SET stat = uar_srvsetstring(hinfo,"performer_role_profile",nullterm(sroleprofile))
 SET hpatient = uar_srvgetstruct(hinfo,"patient")
 SET stat = uar_srvsetdouble(hpatient,"person_id",local_person_id)
 SET stat = uar_srvsetstring(hpatient,"serial_change_number",nullterm(get_pds_exception_by_id_reply->
   pds_person_data.source_version_number))
 SET halias = uar_srvadditem(hpatient,"alias_qual")
 SET stat = uar_srvsetstring(halias,"alias",nullterm(get_pds_exception_by_id_reply->local_person_data
   .nhs_number))
 SET stat = uar_srvsetdouble(halias,"alias_type_cd",loadcodevalue(4,"SSN",0))
 SET stat = uar_srvsetdouble(halias,"alias_pool_cd",get_pds_exception_by_id_reply->local_person_data.
  nhs_alias_pool_cd)
 SET stat = uar_srvsetshort(halias,"action",action_chg)
 IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.birth_info_ind
  AND acm_reconcile_req->birth_info_keep_local_ind)
  SET stat = uar_srvsetdate(hpatient,"birth_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply->
    local_person_data.birth_dt_tm))
  SET stat = uar_srvsetshort(hpatient,"birth_prec_flag",get_pds_exception_by_id_reply->
   local_person_data.birth_prec_flag)
  SET stat = uar_srvsetlong(hpatient,"birth_tz",get_pds_exception_by_id_reply->local_person_data.
   birth_tz)
  IF ((get_pds_exception_by_id_reply->pds_person_data.birth_dt_tm=0))
   SET stat = uar_srvsetshort(hpatient,"birth_date_action",action_add)
  ELSE
   SET stat = uar_srvsetshort(hpatient,"birth_date_action",action_chg)
  ENDIF
 ENDIF
 IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.current_name_ind
  AND acm_reconcile_req->current_name_keep_local_ind)
  SET hpersonname = uar_srvadditem(hpatient,"person_name")
  SET stat = uar_srvsetdouble(hpersonname,"person_id",local_person_id)
  SET stat = uar_srvsetstring(hpersonname,"name_first",nullterm(get_pds_exception_by_id_reply->
    local_person_data.current_name.name_first))
  SET stat = uar_srvsetstring(hpersonname,"name_last",nullterm(get_pds_exception_by_id_reply->
    local_person_data.current_name.name_last))
  SET stat = uar_srvsetstring(hpersonname,"name_prefix",nullterm(get_pds_exception_by_id_reply->
    local_person_data.current_name.name_prefix))
  SET stat = uar_srvsetstring(hpersonname,"name_suffix",nullterm(get_pds_exception_by_id_reply->
    local_person_data.current_name.name_suffix))
  SET stat = uar_srvsetstring(hpersonname,"name_middle",nullterm(get_pds_exception_by_id_reply->
    local_person_data.current_name.name_middle))
  SET stat = uar_srvsetdate(hpersonname,"beg_effective_dt_tm",cnvtdatetime(
    get_pds_exception_by_id_reply->local_person_data.current_name.beg_effective_dt_tm))
  SET stat = uar_srvsetdate(hpersonname,"end_effective_dt_tm",cnvtdatetime(
    get_pds_exception_by_id_reply->local_person_data.current_name.end_effective_dt_tm))
  SET stat = uar_srvsetdouble(hpersonname,"name_type_cd",current_name_type_cd)
  IF (trim(get_pds_exception_by_id_reply->pds_person_data.current_name.source_identifier,3)="")
   SET stat = uar_srvsetshort(hpersonname,"action",action_add)
  ELSE
   SET stat = uar_srvsetstring(hpersonname,"source_identifier",nullterm(get_pds_exception_by_id_reply
     ->pds_person_data.current_name.source_identifier))
   SET stat = uar_srvsetshort(hpersonname,"action",action_chg)
  ENDIF
 ENDIF
 IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.home_address_ind
  AND acm_reconcile_req->home_address_keep_local_ind)
  SET haddress = uar_srvadditem(hpatient,"address")
  SET stat = uar_srvsetdouble(haddress,"parent_entity_id",local_person_id)
  SET stat = uar_srvsetstring(haddress,"parent_entity_name","PERSON")
  SET stat = uar_srvsetstring(haddress,"street_addr",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_address.street_addr))
  SET stat = uar_srvsetstring(haddress,"street_addr2",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_address.street_addr2))
  SET stat = uar_srvsetstring(haddress,"street_addr3",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_address.street_addr3))
  SET stat = uar_srvsetstring(haddress,"street_addr4",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_address.city))
  SET stat = uar_srvsetstring(haddress,"street_addr5",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_address.county))
  SET stat = uar_srvsetstring(haddress,"zipcode",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_address.zipcode))
  SET stat = uar_srvsetstring(haddress,"postal_identifier",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_address.postal_identifier))
  SET stat = uar_srvsetstring(haddress,"comment_txt",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_address.comment_txt))
  SET stat = uar_srvsetdate(haddress,"beg_effective_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply
    ->local_person_data.home_address.beg_effective_dt_tm))
  SET stat = uar_srvsetdate(haddress,"end_effective_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply
    ->local_person_data.home_address.end_effective_dt_tm))
  SET stat = uar_srvsetdouble(haddress,"address_type_cd",home_addr_type_cd)
  IF (trim(get_pds_exception_by_id_reply->pds_person_data.home_address.source_identifier,3)="")
   SET stat = uar_srvsetshort(haddress,"action",action_add)
  ELSE
   SET stat = uar_srvsetstring(haddress,"source_identifier",nullterm(get_pds_exception_by_id_reply->
     pds_person_data.home_address.source_identifier))
   SET stat = uar_srvsetshort(haddress,"action",action_chg)
  ENDIF
  SET hphone = uar_srvadditem(hpatient,"phone")
  SET stat = uar_srvsetstring(hphone,"parent_entity_name","PERSON")
  SET stat = uar_srvsetdouble(hphone,"parent_entity_id",local_person_id)
  SET stat = uar_srvsetstring(hphone,"phone_num",nullterm(get_pds_exception_by_id_reply->
    local_person_data.home_phone.phone_number))
  SET stat = uar_srvsetdouble(hphone,"contact_method_cd",get_pds_exception_by_id_reply->
   local_person_data.home_phone.contact_method_cd)
  SET stat = uar_srvsetdouble(hphone,"phone_type_cd",home_ph_type_cd)
  SET stat = uar_srvsetdate(hphone,"beg_effective_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply->
    local_person_data.home_phone.beg_effective_dt_tm))
  SET stat = uar_srvsetdate(hphone,"end_effective_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply->
    local_person_data.home_phone.end_effective_dt_tm))
  IF (trim(get_pds_exception_by_id_reply->pds_person_data.home_phone.source_identifier,3)="")
   SET stat = uar_srvsetshort(hphone,"action",action_add)
  ELSE
   SET stat = uar_srvsetstring(hphone,"source_identifier",nullterm(get_pds_exception_by_id_reply->
     pds_person_data.home_phone.source_identifier))
   SET stat = uar_srvsetshort(hphone,"action",action_chg)
  ENDIF
 ENDIF
 IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.mailing_address_ind
  AND acm_reconcile_req->mailing_address_keep_local_ind)
  SET haddress = uar_srvadditem(hpatient,"address")
  SET stat = uar_srvsetstring(haddress,"parent_entity_name","PERSON")
  SET stat = uar_srvsetdouble(haddress,"parent_entity_id",local_person_id)
  SET stat = uar_srvsetstring(haddress,"street_addr",nullterm(get_pds_exception_by_id_reply->
    local_person_data.mailing_address.street_addr))
  SET stat = uar_srvsetstring(haddress,"street_addr2",nullterm(get_pds_exception_by_id_reply->
    local_person_data.mailing_address.street_addr2))
  SET stat = uar_srvsetstring(haddress,"street_addr3",nullterm(get_pds_exception_by_id_reply->
    local_person_data.mailing_address.street_addr3))
  SET stat = uar_srvsetstring(haddress,"street_addr4",nullterm(get_pds_exception_by_id_reply->
    local_person_data.mailing_address.city))
  SET stat = uar_srvsetstring(haddress,"street_addr5",nullterm(get_pds_exception_by_id_reply->
    local_person_data.mailing_address.county))
  SET stat = uar_srvsetstring(haddress,"zipcode",nullterm(get_pds_exception_by_id_reply->
    local_person_data.mailing_address.zipcode))
  SET stat = uar_srvsetstring(haddress,"postal_identifier",nullterm(get_pds_exception_by_id_reply->
    local_person_data.mailing_address.postal_identifier))
  SET stat = uar_srvsetstring(haddress,"comment_txt",nullterm(get_pds_exception_by_id_reply->
    local_person_data.mailing_address.comment_txt))
  SET stat = uar_srvsetdate(haddress,"beg_effective_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply
    ->local_person_data.mailing_address.beg_effective_dt_tm))
  SET stat = uar_srvsetdate(haddress,"end_effective_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply
    ->local_person_data.mailing_address.end_effective_dt_tm))
  SET stat = uar_srvsetdouble(haddress,"address_type_cd",mailing_addr_type_cd)
  IF (trim(get_pds_exception_by_id_reply->pds_person_data.mailing_address.source_identifier,3)="")
   SET stat = uar_srvsetshort(haddress,"action",action_add)
  ELSE
   SET stat = uar_srvsetstring(haddress,"source_identifier",nullterm(get_pds_exception_by_id_reply->
     pds_person_data.mailing_address.source_identifier))
   SET stat = uar_srvsetshort(haddress,"action",action_chg)
  ENDIF
 ENDIF
 IF (get_pds_exception_by_id_reply->local_person_data.comparison_data.temp_address_ind
  AND acm_reconcile_req->temp_address_keep_local_ind)
  SET haddress = uar_srvadditem(hpatient,"address")
  SET stat = uar_srvsetdouble(haddress,"parent_entity_id",local_person_id)
  SET stat = uar_srvsetstring(haddress,"parent_entity_name","PERSON")
  SET stat = uar_srvsetstring(haddress,"street_addr",nullterm(get_pds_exception_by_id_reply->
    local_person_data.temp_address.street_addr))
  SET stat = uar_srvsetstring(haddress,"street_addr2",nullterm(get_pds_exception_by_id_reply->
    local_person_data.temp_address.street_addr2))
  SET stat = uar_srvsetstring(haddress,"street_addr3",nullterm(get_pds_exception_by_id_reply->
    local_person_data.temp_address.street_addr3))
  SET stat = uar_srvsetstring(haddress,"street_addr4",nullterm(get_pds_exception_by_id_reply->
    local_person_data.temp_address.city))
  SET stat = uar_srvsetstring(haddress,"street_addr5",nullterm(get_pds_exception_by_id_reply->
    local_person_data.temp_address.county))
  SET stat = uar_srvsetstring(haddress,"zipcode",nullterm(get_pds_exception_by_id_reply->
    local_person_data.temp_address.zipcode))
  SET stat = uar_srvsetstring(haddress,"postal_identifier",nullterm(get_pds_exception_by_id_reply->
    local_person_data.temp_address.postal_identifier))
  SET stat = uar_srvsetstring(haddress,"comment_txt",nullterm(get_pds_exception_by_id_reply->
    local_person_data.temp_address.comment_txt))
  SET stat = uar_srvsetdate(haddress,"beg_effective_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply
    ->local_person_data.temp_address.beg_effective_dt_tm))
  SET stat = uar_srvsetdate(haddress,"end_effective_dt_tm",cnvtdatetime(get_pds_exception_by_id_reply
    ->local_person_data.temp_address.end_effective_dt_tm))
  SET stat = uar_srvsetdouble(haddress,"address_type_cd",temp_addr_type_cd)
  IF (trim(get_pds_exception_by_id_reply->pds_person_data.temp_address.source_identifier,3)="")
   SET stat = uar_srvsetshort(haddress,"action",action_add)
  ELSE
   SET stat = uar_srvsetstring(haddress,"source_identifier",nullterm(get_pds_exception_by_id_reply->
     pds_person_data.temp_address.source_identifier))
   SET stat = uar_srvsetshort(haddress,"action",action_chg)
  ENDIF
 ENDIF
 SET crmstatus = uar_crmperform(hstep)
 IF (crmstatus)
  SET failed = execute_error
  SET table_name = concat("Perform failed with status: ",cnvtstring(crmstatus))
  IF (call_echo_ind)
   CALL echo(concat("Perform failed(4135133) with status: ",cnvtstring(crmstatus)))
   CALL echo("REQUEST 4135133:")
   CALL uar_sisrvdump(hrequest)
  ENDIF
  CALL pm_logmsg(concat("Perform failed with status: ",cnvtstring(crmstatus)),0)
  GO TO exit_step
 ENDIF
 SET hreply = uar_crmgetreply(hstep)
 SET hstatus = uar_srvgetstruct(hreply,"status_data")
 SET status = uar_srvgetstringptr(hstatus,"status")
 IF (status != "S")
  SET failed = execute_error
  SET table_name = "PDS update from acm_send_pds_exception_updt failed: status = F"
  CALL pm_logmsg("PDS update from acm_send_pds_exception_updt failed: status = F",0)
  IF (call_echo_ind)
   CALL echo(build("Perform 4135133 returned status: = ",crmstatus))
   CALL echo("4135133 REQUEST:")
   CALL uar_sisrvdump(hrequest)
   CALL echo("4135133 REPLY")
   CALL uar_sisrvdump(hreply)
  ENDIF
 ENDIF
#exit_step
 SET stat = uar_crmendreq(hstep)
#exit_req
 SET stat = uar_crmendtask(htask)
#exit_task
 SET stat = uar_crmendapp(happ)
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
