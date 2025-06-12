CREATE PROGRAM cs_srv_add_charge_event:dba
 SET cs_srv_add_charge_event_version = "CHARGSRV-14677.mod.027"
 CALL echo(concat("CS_SRV_ADD_CHARGE_EVENT - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 RECORD cemrequest(
   1 objarray[*]
     2 action_type = c3
     2 charge_event_mod_id = f8
     2 charge_event_id = f8
     2 charge_event_mod_type_cd = f8
     2 field1 = vc
     2 field2 = vc
     2 field3 = vc
     2 field4 = vc
     2 field5 = vc
     2 field6 = vc
     2 field7 = vc
     2 field8 = vc
     2 field9 = vc
     2 field10 = vc
     2 updt_cnt = i4
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 code1_cd = f8
     2 nomen_id = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 cm1_nbr = f8
     2 activity_dt_tm = dq8
 ) WITH protect
 RECORD cemreply(
   1 pft_status_data
     2 status = c1
     2 subeventstatus[*]
       3 status = c1
       3 table_name = vc
       3 pk_values = vc
   1 mod_objs[*]
     2 entity_type = vc
     2 mod_recs[*]
       3 table_name = vc
       3 pk_values = vc
       3 mod_flds[*]
         4 field_name = vc
         4 field_type = vc
         4 field_value_obj = vc
         4 field_value_db = vc
   1 failure_stack
     2 failures[*]
       3 programname = vc
       3 routinename = vc
       3 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE next_nbr = f8
 DECLARE eventrepcnt = i2
 DECLARE eventreploop = i2
 DECLARE actrepcnt = i2
 DECLARE actreploop = i2
 DECLARE modrepcnt = i2
 DECLARE modreploop = i2
 DECLARE chargecnt = i2
 DECLARE chargemodcnt = i2
 DECLARE cancel_ind = i2
 DECLARE parent_script = c50
 DECLARE badencntrid = f8
 DECLARE badpersonid = f8
 DECLARE chkloopcnt = i4 WITH public, noconstant(0)
 DECLARE batch_size = i4 WITH protect, noconstant(10)
 DECLARE batch_count = i4 WITH protect, noconstant(0)
 DECLARE startindex = i4 WITH protect, noconstant(1)
 DECLARE event_count = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 SET parent_script = "CS_SRV_ADD_CHARGE_EVENT"
 SUBROUTINE getnextnumber(a)
   SELECT INTO "nl:"
    y = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     next_nbr = cnvtreal(y)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE checkdupcollection(a_repnum)
   CALL echo("Check for duplicate collections")
   DECLARE chkloopcnt = i4 WITH public, noconstant(0)
   FOR (chkloopcnt = 1 TO actrepcnt)
     IF ((reply->charge_event[a_repnum].charge_event_act[chkloopcnt].cea_type_cd=g_cs13029->collected
     )
      AND (reply->charge_event[a_repnum].charge_event_act[chkloopcnt].charge_type_cd=g_cs13028->
     collection))
      SELECT INTO "nl:"
       FROM charge_event ce
       WHERE (ce.encntr_id=reply->charge_event[a_repnum].encntr_id)
        AND (ce.ext_m_reference_id=reply->charge_event[a_repnum].ext_master_reference_id)
        AND (ce.ext_m_reference_cont_cd=reply->charge_event[a_repnum].ext_master_reference_cont_cd)
        AND (ce.ext_i_reference_id=reply->charge_event[a_repnum].ext_item_reference_id)
        AND (ce.ext_i_reference_cont_cd=reply->charge_event[a_repnum].ext_item_reference_cont_cd)
        AND  EXISTS (
       (SELECT
        cea.charge_event_act_id
        FROM charge_event_act cea
        WHERE (cea.charge_event_id=(ce.charge_event_id+ 0))
         AND (cea.cea_type_cd=g_cs13029->collected)
         AND (cea.charge_type_cd=g_cs13028->collection)
         AND cea.service_dt_tm=cnvtdatetime(reply->charge_event[a_repnum].charge_event_act[chkloopcnt
         ].service_dt_tm)
         AND (cea.cea_prsnl_id=reply->charge_event[a_repnum].charge_event_act[chkloopcnt].
        cea_prsnl_id)))
       DETAIL
        reply->charge_event[a_repnum].charge_event_id = - (1)
       WITH nocounter
      ;end select
      IF ((reply->charge_event[a_repnum].charge_event_id=- (1)))
       SET chkloopcnt = actrepcnt
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getchargeeventid(b_repnum)
   CALL echo("Check for existing charge_event")
   SET badencntrid = 0
   SET badpersonid = 0
   IF ((reply->charge_event[b_repnum].ext_item_event_cont_cd=g_cs13016->rad_result)
    AND (reply->action_type != "SNC"))
    SELECT INTO "nl:"
     c.charge_event_id, c.encntr_id, c.person_id
     FROM charge_event c
     WHERE (c.ext_m_event_id=reply->charge_event[b_repnum].ext_master_event_id)
      AND (c.ext_m_event_cont_cd=reply->charge_event[b_repnum].ext_master_event_cont_cd)
      AND (c.ext_p_event_id=reply->charge_event[b_repnum].ext_parent_event_id)
      AND (c.ext_p_event_cont_cd=reply->charge_event[b_repnum].ext_parent_event_cont_cd)
      AND (c.ext_i_event_cont_cd=reply->charge_event[b_repnum].ext_item_event_cont_cd)
      AND (c.ext_i_reference_id=reply->charge_event[b_repnum].ext_item_reference_id)
     DETAIL
      reply->charge_event[b_repnum].charge_event_id = c.charge_event_id
      IF ((reply->action_type != "SKP")
       AND (reply->action_type != "SNC"))
       IF ((reply->charge_event[b_repnum].encntr_id=0))
        reply->charge_event[b_repnum].encntr_id = c.encntr_id
       ENDIF
       IF ((reply->charge_event[b_repnum].person_id=0))
        reply->charge_event[b_repnum].person_id = c.person_id
       ENDIF
       IF ((reply->charge_event[b_repnum].encntr_id != c.encntr_id)
        AND c.encntr_id > 0)
        badencntrid = reply->charge_event[b_repnum].encntr_id, reply->charge_event[b_repnum].
        encntr_id = c.encntr_id
       ENDIF
       IF ((reply->charge_event[b_repnum].person_id != c.person_id)
        AND c.person_id > 0)
        badpersonid = reply->charge_event[b_repnum].person_id, reply->charge_event[b_repnum].
        person_id = c.person_id
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     c.charge_event_id, c.encntr_id, c.person_id
     FROM charge_event c
     WHERE (c.ext_m_event_id=reply->charge_event[b_repnum].ext_master_event_id)
      AND (c.ext_m_event_cont_cd=reply->charge_event[b_repnum].ext_master_event_cont_cd)
      AND (c.ext_p_event_id=reply->charge_event[b_repnum].ext_parent_event_id)
      AND (c.ext_p_event_cont_cd=reply->charge_event[b_repnum].ext_parent_event_cont_cd)
      AND (c.ext_i_event_id=reply->charge_event[b_repnum].ext_item_event_id)
      AND (c.ext_i_event_cont_cd=reply->charge_event[b_repnum].ext_item_event_cont_cd)
      AND (c.ext_i_reference_id=reply->charge_event[b_repnum].ext_item_reference_id)
     DETAIL
      reply->charge_event[b_repnum].charge_event_id = c.charge_event_id
      IF ((reply->action_type != "SKP")
       AND (reply->action_type != "SNC"))
       IF ((reply->charge_event[b_repnum].encntr_id=0))
        reply->charge_event[b_repnum].encntr_id = c.encntr_id
       ENDIF
       IF ((reply->charge_event[b_repnum].person_id=0))
        reply->charge_event[b_repnum].person_id = c.person_id
       ENDIF
       IF ((reply->charge_event[b_repnum].encntr_id != c.encntr_id)
        AND c.encntr_id > 0)
        badencntrid = reply->charge_event[b_repnum].encntr_id, reply->charge_event[b_repnum].
        encntr_id = c.encntr_id
       ENDIF
       IF ((reply->charge_event[b_repnum].person_id != c.person_id)
        AND c.person_id > 0)
        badpersonid = reply->charge_event[b_repnum].person_id, reply->charge_event[b_repnum].
        person_id = c.person_id
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE addchargeevent(c_repnum)
   SET error_code = 1
   SET error_msg = fillstring(132," ")
   SET error_count = 0
   SET error_clear = 0
   SET msg_clear = fillstring(132," ")
   SET updateind = 0
   IF ((reply->charge_event[c_repnum].charge_event_id > 0))
    SET updateind = 1
   ELSE
    CALL getnextnumber("NULL")
    SET reply->charge_event[c_repnum].charge_event_id = next_nbr
    IF ((reply->charge_event[c_repnum].ext_master_event_id=- (1))
     AND (reply->charge_event[c_repnum].ext_master_event_cont_cd=g_cs13016->charge_event))
     SET reply->charge_event[c_repnum].ext_master_event_id = next_nbr
     SET reply->charge_event[c_repnum].ext_item_event_id = next_nbr
    ENDIF
    CALL echo("Insert into charge_event table")
    SET error_clear = error(msg_clear,1)
    INSERT  FROM charge_event c
     SET c.ext_m_event_id = reply->charge_event[c_repnum].ext_master_event_id, c.ext_m_event_cont_cd
       = reply->charge_event[c_repnum].ext_master_event_cont_cd, c.ext_m_reference_id = reply->
      charge_event[c_repnum].ext_master_reference_id,
      c.ext_m_reference_cont_cd = reply->charge_event[c_repnum].ext_master_reference_cont_cd, c
      .ext_p_event_id = reply->charge_event[c_repnum].ext_parent_event_id, c.ext_p_event_cont_cd =
      reply->charge_event[c_repnum].ext_parent_event_cont_cd,
      c.ext_p_reference_id = reply->charge_event[c_repnum].ext_parent_reference_id, c
      .ext_p_reference_cont_cd = reply->charge_event[c_repnum].ext_parent_reference_cont_cd, c
      .ext_i_event_id = reply->charge_event[c_repnum].ext_item_event_id,
      c.ext_i_event_cont_cd = reply->charge_event[c_repnum].ext_item_event_cont_cd, c
      .ext_i_reference_id = reply->charge_event[c_repnum].ext_item_reference_id, c
      .ext_i_reference_cont_cd = reply->charge_event[c_repnum].ext_item_reference_cont_cd,
      c.abn_status_cd = reply->charge_event[c_repnum].abn_status_cd, c.accession = substring(1,50,
       trim(reply->charge_event[c_repnum].accession)), c.active_ind = 1,
      c.active_status_dt_tm = cnvtdatetime(sysdate), c.bill_item_id = 0, c.cancelled_dt_tm = null,
      c.cancelled_ind = 0, c.charge_event_id = reply->charge_event[c_repnum].charge_event_id, c
      .collection_priority_cd = reply->charge_event[c_repnum].collection_priority_cd,
      c.report_priority_cd = reply->charge_event[c_repnum].report_priority_cd, c.encntr_id = reply->
      charge_event[c_repnum].encntr_id, c.person_id = reply->charge_event[c_repnum].person_id,
      c.order_id = reply->charge_event[c_repnum].order_id, c.perf_loc_cd = reply->charge_event[
      c_repnum].perf_loc_cd, c.reference_nbr = substring(1,60,trim(reply->charge_event[c_repnum].
        reference_nbr)),
      c.research_account_id = reply->charge_event[c_repnum].research_acct_id, c.updt_applctx =
      reqinfo->updt_applctx, c.updt_cnt = 0,
      c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
      updt_task,
      c.epsdt_ind = reply->charge_event[c_repnum].epsdt_ind, c.health_plan_id = reply->charge_event[
      c_repnum].health_plan_id
     WITH nocounter
    ;end insert
   ENDIF
   SET error_code = error(error_msg,0)
   IF (error_code=288)
    FOR (chkloopcnt = 1 TO actrepcnt)
      IF ((reply->charge_event[c_repnum].charge_event_act[chkloopcnt].cea_type_cd=g_cs13029->
      collected)
       AND (reply->charge_event[c_repnum].charge_event_act[chkloopcnt].charge_type_cd=g_cs13028->
      collection))
       SET reply->charge_event[c_repnum].charge_event_id = - (1)
      ENDIF
    ENDFOR
    IF ((reply->charge_event[c_repnum].charge_event_id != - (1)))
     CALL getchargeeventid(c_repnum)
     SET updateind = 1
    ENDIF
   ENDIF
   IF ((reply->charge_event[c_repnum].charge_event_id != - (1)))
    SET ordereventind = 0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(actrepcnt))
     WHERE (reply->charge_event[c_repnum].charge_event_act[d.seq].cea_type_cd=g_cs13029->ordered)
     DETAIL
      ordereventind = 1
     WITH nocounter
    ;end select
    IF (updateind=1)
     CALL echo("Update into charge_event table")
     IF ((reply->action_type != "SNC"))
      UPDATE  FROM charge_event c
       SET c.abn_status_cd =
        IF ((reply->charge_event[c_repnum].abn_status_cd=0)
         AND ordereventind=0) c.abn_status_cd
        ELSE reply->charge_event[c_repnum].abn_status_cd
        ENDIF
        , c.accession =
        IF ((reply->charge_event[c_repnum].accession="")
         AND ordereventind=0) c.accession
        ELSE substring(1,50,trim(reply->charge_event[c_repnum].accession))
        ENDIF
        , c.reference_nbr =
        IF ((reply->charge_event[c_repnum].reference_nbr="")) c.reference_nbr
        ELSE substring(1,60,trim(reply->charge_event[c_repnum].reference_nbr))
        ENDIF
        ,
        c.collection_priority_cd =
        IF ((reply->charge_event[c_repnum].collection_priority_cd=0)
         AND ordereventind=0) c.collection_priority_cd
        ELSE reply->charge_event[c_repnum].collection_priority_cd
        ENDIF
        , c.encntr_id =
        IF ((reply->charge_event[c_repnum].encntr_id=0)) c.encntr_id
        ELSE reply->charge_event[c_repnum].encntr_id
        ENDIF
        , c.order_id =
        IF ((reply->charge_event[c_repnum].order_id=0)
         AND ordereventind=0) c.order_id
        ELSE reply->charge_event[c_repnum].order_id
        ENDIF
        ,
        c.perf_loc_cd =
        IF ((reply->charge_event[c_repnum].perf_loc_cd=0)
         AND ordereventind=0) c.perf_loc_cd
        ELSE reply->charge_event[c_repnum].perf_loc_cd
        ENDIF
        , c.person_id =
        IF ((reply->charge_event[c_repnum].person_id=0)) c.person_id
        ELSE reply->charge_event[c_repnum].person_id
        ENDIF
        , c.report_priority_cd =
        IF ((reply->charge_event[c_repnum].report_priority_cd=0)
         AND ordereventind=0) c.report_priority_cd
        ELSE reply->charge_event[c_repnum].report_priority_cd
        ENDIF
        ,
        c.research_account_id =
        IF ((reply->charge_event[c_repnum].research_acct_id=0)
         AND ordereventind=0) c.research_account_id
        ELSE reply->charge_event[c_repnum].research_acct_id
        ENDIF
        , c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt+ 1),
        c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
        updt_task,
        c.health_plan_id =
        IF ((reply->charge_event[c_repnum].health_plan_id=0)) c.health_plan_id
        ELSE reply->charge_event[c_repnum].health_plan_id
        ENDIF
       WHERE (c.charge_event_id=reply->charge_event[c_repnum].charge_event_id)
       WITH nocounter
      ;end update
     ENDIF
     IF ((((g_srvproperties->labsharepresent=0)) OR ((reply->action_type="SNC"))) )
      CALL echo("Read all current event info into reply")
      SELECT INTO "nl:"
       c.research_account_id, c.collection_priority_cd, c.report_priority_cd,
       c.perf_loc_cd
       FROM charge_event c
       WHERE (c.charge_event_id=reply->charge_event[c_repnum].charge_event_id)
       DETAIL
        reply->charge_event[c_repnum].research_acct_id = c.research_account_id, reply->charge_event[
        c_repnum].collection_priority_cd = c.collection_priority_cd, reply->charge_event[c_repnum].
        report_priority_cd = c.report_priority_cd,
        reply->charge_event[c_repnum].perf_loc_cd = c.perf_loc_cd, reply->charge_event[c_repnum].
        abn_status_cd = c.abn_status_cd, reply->charge_event[c_repnum].cancelled_ind = c
        .cancelled_ind,
        reply->charge_event[c_repnum].epsdt_ind = c.epsdt_ind, reply->charge_event[c_repnum].order_id
         = c.order_id, reply->charge_event[c_repnum].accession = c.accession
        IF (c.health_plan_id > 0)
         reply->charge_event[c_repnum].health_plan_id = c.health_plan_id
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    IF ((g_srvproperties->labsharepresent=1)
     AND (reply->action_type != "SNC"))
     IF (updateind=0)
      SELECT INTO "nl:"
       FROM charge_event c
       PLAN (c
        WHERE (c.charge_event_id=reply->charge_event[c_repnum].charge_event_id))
       WITH nocounter, forupdatewait(c)
      ;end select
     ENDIF
     CALL echo("Read all current event info into reply")
     SELECT INTO "nl:"
      c.research_account_id, c.collection_priority_cd, c.report_priority_cd,
      c.perf_loc_cd
      FROM charge_event c
      WHERE (c.charge_event_id=reply->charge_event[c_repnum].charge_event_id)
      DETAIL
       reply->charge_event[c_repnum].research_acct_id = c.research_account_id, reply->charge_event[
       c_repnum].collection_priority_cd = c.collection_priority_cd, reply->charge_event[c_repnum].
       report_priority_cd = c.report_priority_cd,
       reply->charge_event[c_repnum].perf_loc_cd = c.perf_loc_cd, reply->charge_event[c_repnum].
       abn_status_cd = c.abn_status_cd, reply->charge_event[c_repnum].cancelled_ind = c.cancelled_ind,
       reply->charge_event[c_repnum].epsdt_ind = c.epsdt_ind, reply->charge_event[c_repnum].order_id
        = c.order_id, reply->charge_event[c_repnum].accession = c.accession
       IF (c.health_plan_id > 0)
        reply->charge_event[c_repnum].health_plan_id = c.health_plan_id
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE setupactsandmods(d_repnum)
   SET loaded_srv_res_cd = 0.0
   FOR (actreploop = 1 TO actrepcnt)
     IF ((reply->charge_event[d_repnum].charge_event_act[actreploop].cea_type_cd=g_cs13029->loaded))
      SET loaded_srv_res_cd = reply->charge_event[d_repnum].charge_event_act[actreploop].
      service_resource_cd
     ENDIF
   ENDFOR
   SET newsize = actrepcnt
   FOR (actreploop = 1 TO actrepcnt)
     IF ((reply->action_type != "SNC"))
      CALL getnextnumber("NULL")
      SET reply->charge_event[d_repnum].charge_event_act[actreploop].charge_event_act_id = next_nbr
     ENDIF
     IF ((reply->charge_event[d_repnum].charge_event_act[actreploop].rx_quantity <= 0))
      SET reply->charge_event[d_repnum].charge_event_act[actreploop].rx_quantity = reply->
      charge_event[d_repnum].charge_event_act[actreploop].quantity
     ENDIF
     IF (((badencntrid > 0) OR (badpersonid > 0))
      AND actreploop=1)
      CALL echo("Bad person or encntr, adding diagnostics mod")
      SET curmodcnt = size(reply->charge_event[d_repnum].mods.charge_mods,5)
      SET curmodcnt += 1
      SET stat = alterlist(reply->charge_event[d_repnum].mods.charge_mods,curmodcnt)
      SET reply->charge_event[d_repnum].mods.charge_mods[curmodcnt].charge_event_mod_type_cd =
      g_cs13019->srv_diag
      SET reply->charge_event[d_repnum].mods.charge_mods[curmodcnt].field1_id = next_nbr
      SET reply->charge_event[d_repnum].mods.charge_mods[curmodcnt].field2_id = g_cs18269->badencntr
      SET reply->charge_event[d_repnum].mods.charge_mods[curmodcnt].field3_id = badencntrid
      SET reply->charge_event[d_repnum].mods.charge_mods[curmodcnt].field4_id = badpersonid
      SET reply->charge_event[d_repnum].mods.charge_mods[curmodcnt].field6 =
      "Bad person or encntr in request"
     ENDIF
     IF ((reply->charge_event[d_repnum].charge_event_act[actreploop].service_dt_tm <= 0))
      SET reply->charge_event[d_repnum].charge_event_act[actreploop].service_dt_tm = cnvtdatetime(
       sysdate)
     ENDIF
     IF ((reply->charge_event[d_repnum].misc_ind > 0)
      AND (reply->charge_event[d_repnum].charge_event_act[actreploop].misc_ind <= 0))
      SET reply->charge_event[d_repnum].charge_event_act[actreploop].misc_ind = reply->charge_event[
      d_repnum].misc_ind
      SET reply->charge_event[d_repnum].charge_event_act[actreploop].cea_misc4_id = reply->
      charge_event[d_repnum].misc_price
      SET reply->charge_event[d_repnum].charge_event_act[actreploop].cea_misc3 = reply->charge_event[
      d_repnum].misc_desc
     ENDIF
     IF ((reply->charge_event[d_repnum].charge_event_act[actreploop].cea_type_cd=g_cs13029->ordered))
      SET reply->charge_event[d_repnum].ord_loc_cd = reply->charge_event[d_repnum].charge_event_act[
      actreploop].service_loc_cd
     ENDIF
     IF ((reply->charge_event[d_repnum].charge_event_act[actreploop].service_resource_cd <= 0))
      IF ((((reply->charge_event[d_repnum].charge_event_act[actreploop].cea_type_cd=g_cs13029->
      ordered)) OR ((((reply->charge_event[d_repnum].charge_event_act[actreploop].cea_type_cd=
      g_cs13029->complete)) OR ((reply->charge_event[d_repnum].charge_event_act[actreploop].
      cea_type_cd=g_cs13029->collected)
       AND (reply->charge_event[d_repnum].charge_event_act[actreploop].service_resource_cd=0))) )) )
       IF (loaded_srv_res_cd > 0)
        SET reply->charge_event[d_repnum].charge_event_act[actreploop].service_resource_cd =
        loaded_srv_res_cd
       ELSE
        SELECT INTO "nl:"
         c.service_resource_cd
         FROM charge_event_act c
         WHERE (c.charge_event_id=reply->charge_event[d_repnum].charge_event_id)
          AND c.service_resource_cd > 0
         DETAIL
          reply->charge_event[d_repnum].charge_event_act[actreploop].service_resource_cd = c
          .service_resource_cd
         WITH maxrec = value(1), nocounter
        ;end select
       ENDIF
      ENDIF
     ENDIF
     CALL echo("Check cea_prsnl_id to see if it is in phlebotomy group")
     SELECT INTO "nl:"
      pgr.prsnl_group_id
      FROM prsnl_group_reltn pgr,
       prsnl_group pg
      PLAN (pgr
       WHERE (pgr.person_id=reply->charge_event[d_repnum].charge_event_act[actreploop].cea_prsnl_id)
        AND pgr.active_ind=1)
       JOIN (pg
       WHERE pg.prsnl_group_id=pgr.prsnl_group_id
        AND (pg.prsnl_group_type_cd=g_cs13016->phlebcharge))
      DETAIL
       reply->charge_event[d_repnum].charge_event_act[actreploop].phleb_group_ind = 1
      WITH nocounter
     ;end select
     CALL echo("Check for setup activity")
     IF ((reply->charge_event[d_repnum].charge_event_act[actreploop].cea_type_cd=g_cs13029->performed
     )
      AND (reply->charge_event[d_repnum].charge_event_act[actreploop].accession_id > 0)
      AND (g_srvproperties->workloadind=1))
      SET setupfound = 0
      SELECT INTO "nl:"
       cea.cea_type_cd, cea.accession_id, cea.service_resource_cd
       FROM charge_event_act cea
       WHERE (cea.cea_type_cd=g_cs13029->setup)
        AND (cea.accession_id=reply->charge_event[d_repnum].charge_event_act[actreploop].accession_id
       )
        AND (cea.service_resource_cd=reply->charge_event[d_repnum].charge_event_act[actreploop].
       service_resource_cd)
       DETAIL
        setupfound = 1
       WITH nocounter
      ;end select
      IF (setupfound=0)
       CALL echo("Add setup activity")
       SET newsize += 1
       SET stat = alterlist(reply->charge_event[d_repnum].charge_event_act,newsize)
       CALL getnextnumber("NULL")
       SET reply->charge_event[d_repnum].charge_event_act[newsize].charge_event_act_id = next_nbr
       SET reply->charge_event[d_repnum].charge_event_act[newsize].cea_type_cd = g_cs13029->setup
       SET reply->charge_event[d_repnum].charge_event_act[newsize].accession_id = reply->
       charge_event[d_repnum].charge_event_act[actreploop].accession_id
       SET reply->charge_event[d_repnum].charge_event_act[newsize].alpha_nomen_id = reply->
       charge_event[d_repnum].charge_event_act[actreploop].alpha_nomen_id
       SET reply->charge_event[d_repnum].charge_event_act[newsize].cea_prsnl_id = reply->
       charge_event[d_repnum].charge_event_act[actreploop].cea_prsnl_id
       SET reply->charge_event[d_repnum].charge_event_act[newsize].charge_event_id = reply->
       charge_event[d_repnum].charge_event_act[actreploop].charge_event_id
       SET reply->charge_event[d_repnum].charge_event_act[newsize].charge_type_cd = reply->
       charge_event[d_repnum].charge_event_act[actreploop].charge_type_cd
       SET reply->charge_event[d_repnum].charge_event_act[newsize].quantity = reply->charge_event[
       d_repnum].charge_event_act[actreploop].quantity
       SET reply->charge_event[d_repnum].charge_event_act[newsize].rx_quantity = reply->charge_event[
       d_repnum].charge_event_act[actreploop].rx_quantity
       SET reply->charge_event[d_repnum].charge_event_act[newsize].reason_cd = reply->charge_event[
       d_repnum].charge_event_act[actreploop].reason_cd
       SET reply->charge_event[d_repnum].charge_event_act[newsize].result = reply->charge_event[
       d_repnum].charge_event_act[actreploop].result
       SET reply->charge_event[d_repnum].charge_event_act[newsize].service_dt_tm = reply->
       charge_event[d_repnum].charge_event_act[actreploop].service_dt_tm
       SET reply->charge_event[d_repnum].charge_event_act[newsize].service_loc_cd = reply->
       charge_event[d_repnum].charge_event_act[actreploop].service_loc_cd
       SET reply->charge_event[d_repnum].charge_event_act[newsize].service_resource_cd = reply->
       charge_event[d_repnum].charge_event_act[actreploop].service_resource_cd
       SET reply->charge_event[d_repnum].charge_event_act[newsize].units = reply->charge_event[
       d_repnum].charge_event_act[actreploop].units
       SET reply->charge_event[d_repnum].charge_event_act[newsize].unit_type_cd = reply->
       charge_event[d_repnum].charge_event_act[actreploop].unit_type_cd
      ENDIF
     ENDIF
   ENDFOR
   SET actrepcnt = newsize
   IF ((reply->action_type != "SNC"))
    SET modrepcnt = size(reply->charge_event[d_repnum].mods.charge_mods,5)
    FOR (modreploop = 1 TO modrepcnt)
     CALL getnextnumber("NULL")
     SET reply->charge_event[d_repnum].mods.charge_mods[modreploop].mod_id = next_nbr
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE addchargeeventactprsnl(e_repnum)
   FOR (actloop = 1 TO actrepcnt)
    SET prsnlcnt = size(reply->charge_event[e_repnum].charge_event_act[actloop].prsnl,5)
    IF (prsnlcnt > 0)
     INSERT  FROM charge_event_act_prsnl c,
       (dummyt d  WITH seq = value(prsnlcnt))
      SET c.seq = 1, c.charge_event_act_id = reply->charge_event[e_repnum].charge_event_act[actloop].
       charge_event_act_id, c.prsnl_id = reply->charge_event[e_repnum].charge_event_act[actloop].
       prsnl[d.seq].prsnl_id,
       c.prsnl_type_cd =
       IF ((reply->charge_event[e_repnum].charge_event_act[actloop].prsnl[d.seq].prsnl_type_cd > 0))
        reply->charge_event[e_repnum].charge_event_act[actloop].prsnl[d.seq].prsnl_type_cd
       ELSE reply->charge_event[e_repnum].charge_event_act[actloop].cea_type_cd
       ENDIF
       , c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
       c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
       updt_applctx,
       c.active_ind = 1
      PLAN (d)
       JOIN (c)
      WITH nocounter
     ;end insert
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE addchargeeventact(f_repnum)
   IF (actrepcnt > 0)
    CALL echo("Insert into charge_event_act table")
    SET foundreverse = 0
    SET foundordered = 0
    FOR (actloop = 1 TO size(reply->charge_event[f_repnum].charge_event_act,5))
     IF ((reply->charge_event[f_repnum].charge_event_act[actloop].cea_type_cd=g_cs13029->reverse))
      SET foundreverse = actloop
     ENDIF
     IF ((reply->charge_event[f_repnum].charge_event_act[actloop].cea_type_cd=g_cs13029->ordered))
      IF (foundreverse != 0
       AND foundreverse < actloop)
       SET foundordered = actloop
      ENDIF
     ENDIF
    ENDFOR
    IF (foundordered != 0)
     CALL echo("Inactivate all charge_event_acts when a REVERSE is received with new ORDERED")
     IF ((g_srvproperties->labsharepresent=1)
      AND (g_srvproperties->modifycompleteind=1))
      UPDATE  FROM charge_event_act c
       SET c.active_ind = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = (c.updt_cnt+ 1)
       WHERE (c.charge_event_id=reply->charge_event[f_repnum].charge_event_id)
        AND c.active_ind=1
        AND  NOT (c.cea_type_cd IN (g_cs13029->inlab, g_cs13029->collected, g_cs13029->loaded,
       g_cs13029->complete))
       WITH nocounter
      ;end update
     ELSEIF ((g_srvproperties->labsharepresent=1))
      UPDATE  FROM charge_event_act c
       SET c.active_ind = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = (c.updt_cnt+ 1)
       WHERE (c.charge_event_id=reply->charge_event[f_repnum].charge_event_id)
        AND c.active_ind=1
        AND  NOT (c.cea_type_cd IN (g_cs13029->inlab, g_cs13029->collected, g_cs13029->loaded))
       WITH nocounter
      ;end update
     ELSEIF ((g_srvproperties->modifycompleteind=1))
      UPDATE  FROM charge_event_act c
       SET c.active_ind = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = (c.updt_cnt+ 1)
       WHERE (c.charge_event_id=reply->charge_event[f_repnum].charge_event_id)
        AND c.active_ind=1
        AND (c.cea_type_cd != g_cs13029->complete)
       WITH nocounter
      ;end update
     ELSE
      UPDATE  FROM charge_event_act c
       SET c.active_ind = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = (c.updt_cnt+ 1)
       WHERE (c.charge_event_id=reply->charge_event[f_repnum].charge_event_id)
        AND c.active_ind=1
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    IF ((g_srvproperties->labsharepresent=1)
     AND (reply->action_type != "SNC"))
     SET founduncol = 0
     FOR (actloop = 1 TO size(reply->charge_event[f_repnum].charge_event_act,5))
       IF ((reply->charge_event[f_repnum].charge_event_act[actloop].cea_type_cd=g_cs13029->
       uncoluninlab))
        SET founduncol = 1
       ENDIF
     ENDFOR
     IF (founduncol=1)
      UPDATE  FROM charge_event_act c
       SET c.active_ind = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_cnt = (c.updt_cnt+ 1)
       WHERE (c.charge_event_id=reply->charge_event[f_repnum].charge_event_id)
        AND c.active_ind=1
        AND c.cea_type_cd IN (g_cs13029->inlab, g_cs13029->collected)
       WITH nocounter
      ;end update
     ENDIF
    ENDIF
    INSERT  FROM charge_event_act c,
      (dummyt d  WITH seq = value(actrepcnt))
     SET c.seq = 1, c.accession_id = reply->charge_event[f_repnum].charge_event_act[d.seq].
      accession_id, c.active_ind = 1,
      c.alpha_nomen_id = reply->charge_event[f_repnum].charge_event_act[d.seq].alpha_nomen_id, c
      .misc_ind = reply->charge_event[f_repnum].charge_event_act[d.seq].misc_ind, c.cea_misc1 =
      substring(1,200,trim(reply->charge_event[f_repnum].charge_event_act[d.seq].cea_misc1)),
      c.cea_misc2 = substring(1,200,trim(reply->charge_event[f_repnum].charge_event_act[d.seq].
        cea_misc2)), c.cea_misc3 = substring(1,200,trim(reply->charge_event[f_repnum].
        charge_event_act[d.seq].cea_misc3)), c.cea_misc1_id = reply->charge_event[f_repnum].
      charge_event_act[d.seq].cea_misc1_id,
      c.item_ext_price = reply->charge_event[f_repnum].charge_event_act[d.seq].cea_misc2_id, c
      .cea_misc3_id = reply->charge_event[f_repnum].charge_event_act[d.seq].cea_misc3_id, c
      .item_price = reply->charge_event[f_repnum].charge_event_act[d.seq].cea_misc4_id,
      c.item_copay = reply->charge_event[f_repnum].charge_event_act[d.seq].cea_misc5_id, c
      .item_reimbursement = reply->charge_event[f_repnum].charge_event_act[d.seq].cea_misc6_id, c
      .discount_amount = reply->charge_event[f_repnum].charge_event_act[d.seq].cea_misc7_id,
      c.cea_prsnl_id = reply->charge_event[f_repnum].charge_event_act[d.seq].cea_prsnl_id, c
      .cea_type_cd = reply->charge_event[f_repnum].charge_event_act[d.seq].cea_type_cd, c
      .charge_event_act_id = reply->charge_event[f_repnum].charge_event_act[d.seq].
      charge_event_act_id,
      c.charge_event_id = reply->charge_event[f_repnum].charge_event_id, c.charge_type_cd = reply->
      charge_event[f_repnum].charge_event_act[d.seq].charge_type_cd, c.insert_dt_tm = cnvtdatetime(
       sysdate),
      c.in_lab_dt_tm = null, c.quantity = reply->charge_event[f_repnum].charge_event_act[d.seq].
      rx_quantity, c.reason_cd = reply->charge_event[f_repnum].charge_event_act[d.seq].reason_cd,
      c.result = substring(1,200,trim(reply->charge_event[f_repnum].charge_event_act[d.seq].result)),
      c.service_dt_tm = cnvtdatetime(reply->charge_event[f_repnum].charge_event_act[d.seq].
       service_dt_tm), c.service_loc_cd = reply->charge_event[f_repnum].charge_event_act[d.seq].
      service_loc_cd,
      c.service_resource_cd = reply->charge_event[f_repnum].charge_event_act[d.seq].
      service_resource_cd, c.units = reply->charge_event[f_repnum].charge_event_act[d.seq].units, c
      .unit_type_cd = reply->charge_event[f_repnum].charge_event_act[d.seq].unit_type_cd,
      c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
      c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.activity_dt_tm = cnvtdatetime
      (reply->charge_event[f_repnum].charge_event_act[d.seq].ceact_dt_tm),
      c.priority_cd = reply->charge_event[f_repnum].charge_event_act[d.seq].priority_cd, c
      .item_deductible_amt = reply->charge_event[f_repnum].charge_event_act[d.seq].
      item_deductible_amt, c.patient_responsibility_flag = reply->charge_event[f_repnum].
      charge_event_act[d.seq].patient_responsibility_flag
     PLAN (d)
      JOIN (c)
     WITH nocounter
    ;end insert
    IF (foundordered != 0
     AND (g_srvproperties->labsharepresent=1))
     SELECT INTO "nl:"
      FROM charge_event_act c
      WHERE (c.charge_event_id=reply->charge_event[f_repnum].charge_event_id)
       AND c.cea_type_cd IN (g_cs13029->inlab, g_cs13029->collected, g_cs13029->loaded)
       AND c.active_ind=1
      HEAD REPORT
       cntact = size(reply->charge_event[f_repnum].charge_event_act,5)
      DETAIL
       cntact += 1, stat = alterlist(reply->charge_event[f_repnum].charge_event_act,cntact), reply->
       charge_event[f_repnum].charge_event_act[cntact].accession_id = c.accession_id,
       reply->charge_event[f_repnum].charge_event_act[cntact].alpha_nomen_id = c.alpha_nomen_id,
       reply->charge_event[f_repnum].charge_event_act[cntact].misc_ind = c.misc_ind, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc1 = c.cea_misc1,
       reply->charge_event[f_repnum].charge_event_act[cntact].cea_misc2 = c.cea_misc2, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc3 = c.cea_misc3, reply->charge_event[
       f_repnum].charge_event_act[cntact].cea_misc1_id = c.cea_misc1_id,
       reply->charge_event[f_repnum].charge_event_act[cntact].cea_misc2_id = c.item_ext_price, reply
       ->charge_event[f_repnum].charge_event_act[cntact].cea_misc3_id = c.cea_misc3_id, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc4_id = c.item_price,
       reply->charge_event[f_repnum].charge_event_act[cntact].cea_misc5_id = c.item_copay, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc6_id = c.item_reimbursement, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc7_id = c.discount_amount,
       reply->charge_event[f_repnum].charge_event_act[cntact].cea_prsnl_id = c.cea_prsnl_id, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_type_cd = c.cea_type_cd, reply->
       charge_event[f_repnum].charge_event_act[cntact].charge_event_act_id = c.charge_event_act_id,
       reply->charge_event[f_repnum].charge_event_act[cntact].charge_type_cd = c.charge_type_cd,
       reply->charge_event[f_repnum].charge_event_act[cntact].in_lab_dt_tm = c.in_lab_dt_tm, reply->
       charge_event[f_repnum].charge_event_act[cntact].quantity = c.quantity,
       reply->charge_event[f_repnum].charge_event_act[cntact].reason_cd = c.reason_cd, reply->
       charge_event[f_repnum].charge_event_act[cntact].result = c.result, reply->charge_event[
       f_repnum].charge_event_act[cntact].service_dt_tm = c.service_dt_tm,
       reply->charge_event[f_repnum].charge_event_act[cntact].service_loc_cd = c.service_loc_cd,
       reply->charge_event[f_repnum].charge_event_act[cntact].service_resource_cd = c
       .service_resource_cd, reply->charge_event[f_repnum].charge_event_act[cntact].units = c.units,
       reply->charge_event[f_repnum].charge_event_act[cntact].unit_type_cd = c.unit_type_cd, reply->
       charge_event[f_repnum].charge_event_act[cntact].ceact_dt_tm = c.activity_dt_tm, reply->
       charge_event[f_repnum].charge_event_act[cntact].priority_cd = c.priority_cd,
       reply->charge_event[f_repnum].charge_event_act[cntact].item_deductible_amt = c
       .item_deductible_amt, reply->charge_event[f_repnum].charge_event_act[cntact].
       patient_responsibility_flag = c.patient_responsibility_flag
      WITH nocounter
     ;end select
    ENDIF
    IF (foundordered != 0
     AND (g_srvproperties->modifycompleteind=1))
     SELECT INTO "nl:"
      FROM charge_event_act c
      WHERE (c.charge_event_id=reply->charge_event[f_repnum].charge_event_id)
       AND (c.cea_type_cd=g_cs13029->complete)
       AND c.active_ind=1
      HEAD REPORT
       cntact = size(reply->charge_event[f_repnum].charge_event_act,5)
      DETAIL
       cntact += 1, stat = alterlist(reply->charge_event[f_repnum].charge_event_act,cntact), reply->
       charge_event[f_repnum].charge_event_act[cntact].accession_id = c.accession_id,
       reply->charge_event[f_repnum].charge_event_act[cntact].alpha_nomen_id = c.alpha_nomen_id,
       reply->charge_event[f_repnum].charge_event_act[cntact].misc_ind = c.misc_ind, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc1 = c.cea_misc1,
       reply->charge_event[f_repnum].charge_event_act[cntact].cea_misc2 = c.cea_misc2, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc3 = c.cea_misc3, reply->charge_event[
       f_repnum].charge_event_act[cntact].cea_misc1_id = c.cea_misc1_id,
       reply->charge_event[f_repnum].charge_event_act[cntact].cea_misc2_id = c.item_ext_price, reply
       ->charge_event[f_repnum].charge_event_act[cntact].cea_misc3_id = c.cea_misc3_id, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc4_id = c.item_price,
       reply->charge_event[f_repnum].charge_event_act[cntact].cea_misc5_id = c.item_copay, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc6_id = c.item_reimbursement, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_misc7_id = c.discount_amount,
       reply->charge_event[f_repnum].charge_event_act[cntact].cea_prsnl_id = c.cea_prsnl_id, reply->
       charge_event[f_repnum].charge_event_act[cntact].cea_type_cd = c.cea_type_cd, reply->
       charge_event[f_repnum].charge_event_act[cntact].charge_event_act_id = c.charge_event_act_id,
       reply->charge_event[f_repnum].charge_event_act[cntact].charge_type_cd = c.charge_type_cd,
       reply->charge_event[f_repnum].charge_event_act[cntact].in_lab_dt_tm = c.in_lab_dt_tm, reply->
       charge_event[f_repnum].charge_event_act[cntact].quantity = c.quantity,
       reply->charge_event[f_repnum].charge_event_act[cntact].reason_cd = c.reason_cd, reply->
       charge_event[f_repnum].charge_event_act[cntact].result = c.result, reply->charge_event[
       f_repnum].charge_event_act[cntact].service_dt_tm = c.service_dt_tm,
       reply->charge_event[f_repnum].charge_event_act[cntact].service_loc_cd = c.service_loc_cd,
       reply->charge_event[f_repnum].charge_event_act[cntact].service_resource_cd = c
       .service_resource_cd, reply->charge_event[f_repnum].charge_event_act[cntact].units = c.units,
       reply->charge_event[f_repnum].charge_event_act[cntact].unit_type_cd = c.unit_type_cd, reply->
       charge_event[f_repnum].charge_event_act[cntact].ceact_dt_tm = c.activity_dt_tm, reply->
       charge_event[f_repnum].charge_event_act[cntact].priority_cd = c.priority_cd,
       reply->charge_event[f_repnum].charge_event_act[cntact].item_deductible_amt = c
       .item_deductible_amt, reply->charge_event[f_repnum].charge_event_act[cntact].
       patient_responsibility_flag = c.patient_responsibility_flag
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE addchargeeventmod(g_repnum)
   DECLARE cemcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(cemrequest->objarray,0)
   CALL echo("Inactivate all charge_event_mods when a REVERSE is received")
   SELECT INTO "nl:"
    FROM charge_event_mod c,
     (dummyt d  WITH seq = value(size(reply->charge_event[g_repnum].charge_event_act,5)))
    PLAN (d
     WHERE (reply->charge_event[g_repnum].charge_event_act[d.seq].cea_type_cd=g_cs13029->reverse))
     JOIN (c
     WHERE (c.charge_event_id=reply->charge_event[g_repnum].charge_event_id)
      AND c.active_ind=1)
    DETAIL
     cemcnt += 1, stat = alterlist(cemrequest->objarray,cemcnt), cemrequest->objarray[cemcnt].
     action_type = "DEL",
     cemrequest->objarray[cemcnt].charge_event_mod_id = c.charge_event_mod_id, cemrequest->objarray[
     cemcnt].charge_event_id = c.charge_event_id, cemrequest->objarray[cemcnt].updt_cnt = c.updt_cnt
    WITH nocounter
   ;end select
   IF (size(cemrequest->objarray,5) <= 0)
    IF (validate(debug,- (1)) > 0)
     CALL echo("No charge_event_mods to inactivate")
    ENDIF
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",cemreply)
    IF ((cemreply->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cemrequest)
      CALL echorecord(cemreply)
     ENDIF
    ENDIF
   ENDIF
   SET cemcnt = 0
   SET stat = alterlist(cemrequest->objarray,0)
   CALL echo("Inactivate all icd9 diagnosis mods before we write the new ones")
   SELECT INTO "nl:"
    FROM charge_event_mod c,
     (dummyt d  WITH seq = value(size(reply->charge_event[g_repnum].charge_event_act,5)))
    PLAN (d
     WHERE (((reply->charge_event[g_repnum].charge_event_act[d.seq].cea_type_cd=g_cs13029->ordered))
      OR ((reply->charge_event[g_repnum].charge_event_act[d.seq].cea_type_cd=g_cs13029->complete))) )
     JOIN (c
     WHERE (c.charge_event_id=reply->charge_event[g_repnum].charge_event_id)
      AND (c.charge_event_mod_type_cd=g_cs13019->bill_code)
      AND (c.field1_id=g_cs13019->icd9)
      AND c.active_ind=1)
    DETAIL
     cemcnt += 1, stat = alterlist(cemrequest->objarray,cemcnt), cemrequest->objarray[cemcnt].
     action_type = "DEL",
     cemrequest->objarray[cemcnt].charge_event_mod_id = c.charge_event_mod_id, cemrequest->objarray[
     cemcnt].charge_event_id = c.charge_event_id, cemrequest->objarray[cemcnt].updt_cnt = c.updt_cnt
    WITH nocounter
   ;end select
   IF (size(cemrequest->objarray,5) <= 0)
    IF (validate(debug,- (1)) > 0)
     CALL echo("No charge_event_mods to inactivate")
    ENDIF
   ELSE
    EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",cemreply)
    IF ((cemreply->status_data.status != "S"))
     CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
     IF (validate(debug,- (1)) > 0)
      CALL echorecord(cemrequest)
      CALL echorecord(cemreply)
     ENDIF
    ENDIF
   ENDIF
   IF (modrepcnt > 0)
    CALL echo("Insert into charge_event_mod table")
    SET stat = alterlist(cemrequest->objarray,0)
    SET stat = alterlist(cemrequest->objarray,modrepcnt)
    DECLARE idx0 = i4 WITH protect, noconstant(0)
    FOR (idx0 = 1 TO modrepcnt)
      SET cemrequest->objarray[idx0].action_type = "ADD"
      SET cemrequest->objarray[idx0].charge_event_mod_id = reply->charge_event[g_repnum].mods.
      charge_mods[idx0].mod_id
      SET cemrequest->objarray[idx0].charge_event_id = reply->charge_event[g_repnum].charge_event_id
      SET cemrequest->objarray[idx0].charge_event_mod_type_cd = reply->charge_event[g_repnum].mods.
      charge_mods[idx0].charge_event_mod_type_cd
      SET cemrequest->objarray[idx0].field1 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field1))
      SET cemrequest->objarray[idx0].field2 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field2))
      SET cemrequest->objarray[idx0].field3 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field3))
      SET cemrequest->objarray[idx0].field4 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field4))
      SET cemrequest->objarray[idx0].field5 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field5))
      SET cemrequest->objarray[idx0].field6 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field6))
      SET cemrequest->objarray[idx0].field7 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field7))
      SET cemrequest->objarray[idx0].field8 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field8))
      SET cemrequest->objarray[idx0].field9 = substring(1,200,trim(reply->charge_event[g_repnum].mods
        .charge_mods[idx0].field9))
      SET cemrequest->objarray[idx0].field10 = substring(1,200,trim(reply->charge_event[g_repnum].
        mods.charge_mods[idx0].field10))
      SET cemrequest->objarray[idx0].updt_cnt = 0
      SET cemrequest->objarray[idx0].active_ind = 1
      SET cemrequest->objarray[idx0].active_status_cd = 0
      SET cemrequest->objarray[idx0].active_status_dt_tm = cnvtdatetime(sysdate)
      SET cemrequest->objarray[idx0].nomen_id = reply->charge_event[g_repnum].mods.charge_mods[idx0].
      nomen_id
      SET cemrequest->objarray[idx0].field1_id = reply->charge_event[g_repnum].mods.charge_mods[idx0]
      .field1_id
      SET cemrequest->objarray[idx0].field2_id = reply->charge_event[g_repnum].mods.charge_mods[idx0]
      .field2_id
      SET cemrequest->objarray[idx0].field3_id = reply->charge_event[g_repnum].mods.charge_mods[idx0]
      .field3_id
      SET cemrequest->objarray[idx0].field4_id = reply->charge_event[g_repnum].mods.charge_mods[idx0]
      .field4_id
      SET cemrequest->objarray[idx0].field5_id = reply->charge_event[g_repnum].mods.charge_mods[idx0]
      .field5_id
      SET cemrequest->objarray[idx0].cm1_nbr = reply->charge_event[g_repnum].mods.charge_mods[idx0].
      cm1_nbr
      IF (validate(reply->charge_event[g_repnum].mods.charge_mods[idx0].code1_cd))
       SET cemrequest->objarray[idx0].code1_cd = reply->charge_event[g_repnum].mods.charge_mods[idx0]
       .code1_cd
      ENDIF
      IF (validate(reply->charge_event[g_repnum].mods.charge_mods[idx0].activity_dt_tm) != 0)
       SET cemrequest->objarray[idx0].activity_dt_tm = cnvtdatetime(reply->charge_event[g_repnum].
        mods.charge_mods[idx0].activity_dt_tm)
      ELSE
       SET cemrequest->objarray[idx0].activity_dt_tm = null
      ENDIF
    ENDFOR
    IF (size(cemrequest->objarray,5) <= 0)
     IF (validate(debug,- (1)) > 0)
      CALL echo("No charge_event_mods to add")
     ENDIF
    ELSE
     EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",cemreply)
     IF ((cemreply->status_data.status != "S"))
      CALL logmessage(curprog,"afc_val_charge_event_mod did not return success",log_debug)
      IF (validate(debug,- (1)) > 0)
       CALL echorecord(cemrequest)
       CALL echorecord(cemreply)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
 SET eventrepcnt = size(reply->charge_event,5)
 FOR (eventreploop = 1 TO eventrepcnt)
   IF ((reply->charge_event[eventreploop].ext_master_reference_id > 0)
    AND (reply->charge_event[eventreploop].ext_master_reference_cont_cd > 0)
    AND (reply->charge_event[eventreploop].ext_item_reference_id > 0)
    AND (reply->charge_event[eventreploop].ext_item_reference_cont_cd > 0))
    CALL getchargeeventid(eventreploop)
   ENDIF
 ENDFOR
 IF ((g_srvproperties->labsharepresent=1)
  AND (reply->action_type != "SNC"))
  SET event_count = size(reply->charge_event,5)
  SET batch_count = ceil((cnvtreal(event_count)/ batch_size))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(batch_count)),
    charge_event c
   PLAN (d
    WHERE initarray(startindex,evaluate(d.seq,1,1,(startindex+ batch_size))))
    JOIN (c
    WHERE expand(idx1,startindex,least(((startindex+ batch_size) - 1),event_count),c.charge_event_id,
     reply->charge_event[idx1].charge_event_id)
     AND c.charge_event_id != 0.0)
   WITH nocounter, forupdatewait(c)
  ;end select
 ENDIF
 FOR (eventreploop = 1 TO eventrepcnt)
   IF ((reply->charge_event[eventreploop].ext_master_reference_id > 0)
    AND (reply->charge_event[eventreploop].ext_master_reference_cont_cd > 0)
    AND (reply->charge_event[eventreploop].ext_item_reference_id > 0)
    AND (reply->charge_event[eventreploop].ext_item_reference_cont_cd > 0))
    SET actrepcnt = size(reply->charge_event[eventreploop].charge_event_act,5)
    CALL checkdupcollection(eventreploop)
    IF ((reply->charge_event[eventreploop].charge_event_id != - (1)))
     CALL addchargeevent(eventreploop)
     IF ((reply->charge_event[eventreploop].charge_event_id != - (1)))
      CALL setupactsandmods(eventreploop)
      IF ((reply->action_type != "SNC"))
       CALL addchargeeventact(eventreploop)
       CALL addchargeeventactprsnl(eventreploop)
       CALL addchargeeventmod(eventreploop)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 EXECUTE cs_srv_get_charge_event
#end_of_program
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
