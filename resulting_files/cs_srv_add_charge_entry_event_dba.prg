CREATE PROGRAM cs_srv_add_charge_entry_event:dba
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
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
 CALL echo(concat("CS_SRV_ADD_CHARGE_ENTRY_EVENT - ",format(curdate,"MMM DD, YYYY;;D"),format(
    curtime3," - HH:MM:SS;;S")))
 DECLARE add_charge_entry_event_version = vc WITH protect, noconstant("CHARGSRV-15279.019")
 DECLARE next_nbr = f8
 DECLARE event_cnt = i2
 DECLARE event_loop = i2
 DECLARE act_cnt = i2
 DECLARE act_loop = i2
 DECLARE mod_cnt = i2
 DECLARE mod_loop = i2
 DECLARE reply_cnt = i2
 DECLARE groupcnt = i4 WITH noconstant(0)
 DECLARE mpcnt = i4 WITH noconstant(0)
 DECLARE repactloop = i2
 DECLARE repactcnt = i2
 IF ((validate(carrier_370_cd,- (1))=- (1)))
  DECLARE carrier_370_cd = f8 WITH noconstant(0.0)
  SET stat = uar_get_meaning_by_codeset(370,nullterm("CARRIER"),1,carrier_370_cd)
 ENDIF
 IF ( NOT (validate(cs354_self_pay_cd)))
  DECLARE cs354_self_pay_cd = f8 WITH protect, constant(getcodevalue(354,"SELFPAY",1))
 ENDIF
 IF ( NOT (validate(cs24451_invalid_cd)))
  DECLARE cs24451_invalid_cd = f8 WITH protect, constant(getcodevalue(24451,"INVALID",1))
 ENDIF
 IF ( NOT (validate(cs24451_cancelled_cd)))
  DECLARE cs24451_cancelled_cd = f8 WITH protect, constant(getcodevalue(24451,"CANCELLED",1))
 ENDIF
 IF ( NOT (validate(cs222_facility_cd)))
  DECLARE cs222_facility_cd = f8 WITH protect, constant(getcodevalue(222,"FACILITY",1))
 ENDIF
 IF ( NOT (validate(cs222_building_cd)))
  DECLARE cs222_building_cd = f8 WITH protect, constant(getcodevalue(222,"BUILDING",1))
 ENDIF
 IF ( NOT (validate(cs222_nurseunit_cd)))
  DECLARE cs222_nurseunit_cd = f8 WITH protect, constant(getcodevalue(222,"NURSEUNIT",1))
 ENDIF
 IF ( NOT (validate(cs222_ambulatory_cd)))
  DECLARE cs222_ambulatory_cd = f8 WITH protect, constant(getcodevalue(222,"AMBULATORY",1))
 ENDIF
 IF ( NOT (validate(cs222_room_cd)))
  DECLARE cs222_room_cd = f8 WITH protect, constant(getcodevalue(222,"ROOM",1))
 ENDIF
 IF ( NOT (validate(cs222_bed_cd)))
  DECLARE cs222_bed_cd = f8 WITH protect, constant(getcodevalue(222,"BED",1))
 ENDIF
 IF ( NOT (validate(cs4518006_copyfromcem_cd)))
  DECLARE cs4518006_copyfromcem_cd = f8 WITH protect, constant(getcodevalue(4518006,"COPYFROMCEM",1))
 ENDIF
 SUBROUTINE getnextnumber(a)
   SELECT INTO "nl:"
    y = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     next_nbr = cnvtreal(y)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getchargeeventid(b)
  CALL echo("Check for existing event and charges")
  SELECT INTO "nl:"
   ce.charge_event_id, c.charge_item_id
   FROM charge_event ce,
    dummyt d1,
    charge c,
    (dummyt d  WITH seq = value(event_cnt))
   PLAN (d)
    JOIN (ce
    WHERE (ce.ext_m_event_id=reply->charge_event[d.seq].ext_master_event_id)
     AND (ce.ext_m_event_cont_cd=reply->charge_event[d.seq].ext_master_event_cont_cd)
     AND (ce.ext_p_event_id=reply->charge_event[d.seq].ext_parent_event_id)
     AND (ce.ext_p_event_cont_cd=reply->charge_event[d.seq].ext_parent_event_cont_cd)
     AND (ce.ext_i_event_id=reply->charge_event[d.seq].ext_item_event_id)
     AND (ce.ext_i_event_cont_cd=reply->charge_event[d.seq].ext_item_event_cont_cd))
    JOIN (d1)
    JOIN (c
    WHERE c.charge_event_id=ce.charge_event_id)
   DETAIL
    IF (c.charge_item_id > 0)
     IF ((reply->charge_event[d.seq].charge_event_id != - (2)))
      reply->charge_event[d.seq].charge_event_id = - (1)
     ENDIF
    ELSE
     reply->charge_event[d.seq].charge_event_id = ce.charge_event_id
    ENDIF
   WITH outerjoin = d1, maxread(c,1), nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE addchargeevent(c)
  CALL echo("Insert into charge_event table")
  FOR (event_loop = 1 TO event_cnt)
    IF ((reply->charge_event[event_loop].charge_event_id=0)
     AND (reply->charge_event[event_loop].ext_master_event_id > 0)
     AND (reply->charge_event[event_loop].ext_master_event_cont_cd > 0)
     AND (reply->charge_event[event_loop].ext_master_reference_id > 0)
     AND (reply->charge_event[event_loop].ext_master_reference_cont_cd > 0)
     AND (reply->charge_event[event_loop].ext_item_event_id > 0)
     AND (reply->charge_event[event_loop].ext_item_event_cont_cd > 0)
     AND (reply->charge_event[event_loop].ext_item_reference_id > 0)
     AND (reply->charge_event[event_loop].ext_item_reference_cont_cd > 0))
     CALL getnextnumber("NULL")
     SET reply->charge_event[event_loop].charge_event_id = next_nbr
     INSERT  FROM charge_event c
      SET c.charge_event_id = reply->charge_event[event_loop].charge_event_id, c.ext_m_event_id =
       reply->charge_event[event_loop].ext_master_event_id, c.ext_m_event_cont_cd = reply->
       charge_event[event_loop].ext_master_event_cont_cd,
       c.ext_m_reference_id = reply->charge_event[event_loop].ext_master_reference_id, c
       .ext_m_reference_cont_cd = reply->charge_event[event_loop].ext_master_reference_cont_cd, c
       .ext_p_event_id = reply->charge_event[event_loop].ext_parent_event_id,
       c.ext_p_event_cont_cd = reply->charge_event[event_loop].ext_parent_event_cont_cd, c
       .ext_p_reference_id = reply->charge_event[event_loop].ext_parent_reference_id, c
       .ext_p_reference_cont_cd = reply->charge_event[event_loop].ext_parent_reference_cont_cd,
       c.ext_i_event_id = reply->charge_event[event_loop].ext_item_event_id, c.ext_i_event_cont_cd =
       reply->charge_event[event_loop].ext_item_event_cont_cd, c.ext_i_reference_id = reply->
       charge_event[event_loop].ext_item_reference_id,
       c.ext_i_reference_cont_cd = reply->charge_event[event_loop].ext_item_reference_cont_cd, c
       .abn_status_cd = reply->charge_event[event_loop].abn_status_cd, c.accession = substring(1,50,
        trim(reply->charge_event[event_loop].accession)),
       c.active_ind = 1, c.active_status_dt_tm = cnvtdatetime(sysdate), c.encntr_id = reply->
       charge_event[event_loop].encntr_id,
       c.person_id = reply->charge_event[event_loop].person_id, c.order_id = reply->charge_event[
       event_loop].order_id, c.perf_loc_cd = reply->charge_event[event_loop].perf_loc_cd,
       c.reference_nbr = substring(1,60,trim(reply->charge_event[event_loop].reference_nbr)), c
       .report_priority_cd = reply->charge_event[event_loop].report_priority_cd, c
       .collection_priority_cd = reply->charge_event[event_loop].collection_priority_cd,
       c.research_account_id = reply->charge_event[event_loop].research_acct_id, c.updt_applctx =
       reqinfo->updt_applctx, c.updt_cnt = 0,
       c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
       updt_task,
       c.epsdt_ind = reply->charge_event[event_loop].epsdt_ind
      WITH nocounter
     ;end insert
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE addchargeeventactprsnl(eventnum,actcnt)
   CALL echo("Insert into charge_event_act_prsnl")
   SET completefound = 0
   SET act_loop = 1
   WHILE (act_loop <= actcnt
    AND completefound=0)
    IF ((reply->charge_event[eventnum].charge_event_act[act_loop].cea_type_cd=g_cs13029->complete))
     SET completefound = 1
     SET prsnlcnt = size(reply->charge_event[eventnum].charge_event_act[act_loop].prsnl,5)
     IF ((reply->charge_event[event_loop].ord_phys_id > 0))
      SET prsnlcnt += 1
      SET stat = alterlist(reply->charge_event[eventnum].charge_event_act[act_loop].prsnl,prsnlcnt)
      SET reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[prsnlcnt].prsnl_id = reply->
      charge_event[eventnum].ord_phys_id
      SET reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[prsnlcnt].prsnl_type_cd =
      g_cs13029->ordered
     ENDIF
     IF ((reply->charge_event[event_loop].verify_phys_id > 0))
      SET prsnlcnt += 1
      SET stat = alterlist(reply->charge_event[eventnum].charge_event_act[act_loop].prsnl,prsnlcnt)
      SET reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[prsnlcnt].prsnl_id = reply->
      charge_event[eventnum].verify_phys_id
      SET reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[prsnlcnt].prsnl_type_cd =
      g_cs13029->verified
     ENDIF
     FOR (prsnlloop = 1 TO prsnlcnt)
       IF ((reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[prsnlloop].prsnl_type_cd=
       g_cs13029->ordered)
        AND (reply->charge_event[eventnum].ord_phys_id <= 0))
        SET reply->charge_event[eventnum].ord_phys_id = reply->charge_event[eventnum].
        charge_event_act[act_loop].prsnl[prsnlloop].prsnl_id
       ELSEIF ((reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[prsnlloop].
       prsnl_type_cd=g_cs13029->verified)
        AND (reply->charge_event[eventnum].verify_phys_id <= 0))
        SET reply->charge_event[eventnum].verify_phys_id = reply->charge_event[eventnum].
        charge_event_act[act_loop].prsnl[prsnlloop].prsnl_id
       ELSEIF ((reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[prsnlloop].
       prsnl_type_cd=g_cs13029->referred)
        AND (reply->charge_event[eventnum].ref_phys_id <= 0))
        SET reply->charge_event[eventnum].ref_phys_id = reply->charge_event[eventnum].
        charge_event_act[act_loop].prsnl[prsnlloop].prsnl_id
       ELSEIF ((reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[prsnlloop].
       prsnl_type_cd=g_cs13029->performed)
        AND (reply->charge_event[eventnum].perf_phys_id <= 0))
        SET reply->charge_event[eventnum].perf_phys_id = reply->charge_event[eventnum].
        charge_event_act[act_loop].prsnl[prsnlloop].prsnl_id
       ENDIF
     ENDFOR
     CALL echo("Insert prsnl list")
     INSERT  FROM charge_event_act_prsnl c,
       (dummyt d  WITH seq = value(prsnlcnt))
      SET c.seq = 1, c.charge_event_act_id = reply->charge_event[eventnum].charge_event_act[act_loop]
       .charge_event_act_id, c.prsnl_id = reply->charge_event[eventnum].charge_event_act[act_loop].
       prsnl[d.seq].prsnl_id,
       c.prsnl_type_cd = reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[d.seq].
       prsnl_type_cd, c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
       c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
       updt_task,
       c.active_ind = 1
      PLAN (d
       WHERE (reply->charge_event[eventnum].charge_event_act[act_loop].prsnl[d.seq].prsnl_type_cd > 0
       ))
       JOIN (c)
      WITH nocounter
     ;end insert
    ENDIF
    SET act_loop += 1
   ENDWHILE
 END ;Subroutine
 SUBROUTINE addchargeeventact(d)
  CALL echo("Insert into charge_event_act table")
  FOR (event_loop = 1 TO event_cnt)
    IF ((reply->charge_event[event_loop].charge_event_id > 0))
     SET act_cnt = size(reply->charge_event[event_loop].charge_event_act,5)
     IF (act_cnt > 0)
      FOR (act_loop = 1 TO act_cnt)
        IF ((reply->charge_event[event_loop].charge_event_act[act_loop].cea_type_cd=g_cs13029->
        ordering))
         SET reply->charge_event[event_loop].ord_phys_id = reply->charge_event[event_loop].
         charge_event_act[act_loop].cea_prsnl_id
        ELSEIF ((reply->charge_event[event_loop].charge_event_act[act_loop].cea_type_cd=g_cs13029->
        verifying))
         SET reply->charge_event[event_loop].verify_phys_id = reply->charge_event[event_loop].
         charge_event_act[act_loop].cea_prsnl_id
        ELSE
         CALL getnextnumber("NULL")
         SET reply->charge_event[event_loop].charge_event_act[act_loop].charge_event_act_id =
         next_nbr
        ENDIF
        IF ((reply->charge_event[event_loop].misc_ind > 0)
         AND (reply->charge_event[event_loop].charge_event_act[act_loop].misc_ind <= 0))
         SET reply->charge_event[event_loop].charge_event_act[act_loop].misc_ind = reply->
         charge_event[event_loop].misc_ind
         SET reply->charge_event[event_loop].charge_event_act[act_loop].cea_misc4_id = reply->
         charge_event[event_loop].misc_price
         SET reply->charge_event[event_loop].charge_event_act[act_loop].cea_misc3 = reply->
         charge_event[event_loop].misc_desc
        ENDIF
        IF ((reply->charge_event[event_loop].charge_event_act[act_loop].rx_quantity <= 0))
         SET reply->charge_event[event_loop].charge_event_act[act_loop].rx_quantity = reply->
         charge_event[event_loop].charge_event_act[act_loop].quantity
        ENDIF
      ENDFOR
      INSERT  FROM charge_event_act c,
        (dummyt d2  WITH seq = value(act_cnt))
       SET c.seq = 1, c.accession_id = reply->charge_event[event_loop].charge_event_act[d2.seq].
        accession_id, c.active_ind = 1,
        c.alpha_nomen_id = reply->charge_event[event_loop].charge_event_act[d2.seq].alpha_nomen_id, c
        .cea_prsnl_id = reply->charge_event[event_loop].charge_event_act[d2.seq].cea_prsnl_id, c
        .cea_type_cd = reply->charge_event[event_loop].charge_event_act[d2.seq].cea_type_cd,
        c.charge_event_act_id = reply->charge_event[event_loop].charge_event_act[d2.seq].
        charge_event_act_id, c.charge_event_id = reply->charge_event[event_loop].charge_event_id, c
        .charge_type_cd = reply->charge_event[event_loop].charge_event_act[d2.seq].charge_type_cd,
        c.insert_dt_tm = cnvtdatetime(sysdate), c.in_lab_dt_tm = null, c.patient_loc_cd = reply->
        charge_event[event_loop].charge_event_act[d2.seq].patient_loc_cd,
        c.quantity = reply->charge_event[event_loop].charge_event_act[d2.seq].rx_quantity, c
        .reason_cd = reply->charge_event[event_loop].charge_event_act[d2.seq].reason_cd, c.repeat_ind
         = reply->charge_event[event_loop].charge_event_act[d2.seq].repeat_ind,
        c.result = substring(1,200,trim(reply->charge_event[event_loop].charge_event_act[d2.seq].
          result)), c.service_dt_tm =
        IF ((reply->charge_event[event_loop].charge_event_act[d2.seq].service_dt_tm <= 0)) null
        ELSE cnvtdatetime(reply->charge_event[event_loop].charge_event_act[d2.seq].service_dt_tm)
        ENDIF
        , c.service_loc_cd = reply->charge_event[event_loop].charge_event_act[d2.seq].service_loc_cd,
        c.service_resource_cd = reply->charge_event[event_loop].charge_event_act[d2.seq].
        service_resource_cd, c.units = reply->charge_event[event_loop].charge_event_act[d2.seq].units,
        c.unit_type_cd = reply->charge_event[event_loop].charge_event_act[d2.seq].unit_type_cd,
        c.misc_ind = reply->charge_event[event_loop].charge_event_act[d2.seq].misc_ind, c
        .item_ext_price = reply->charge_event[event_loop].charge_event_act[d2.seq].cea_misc2_id, c
        .item_price = reply->charge_event[event_loop].charge_event_act[d2.seq].cea_misc4_id,
        c.cea_misc3 = substring(1,200,trim(reply->charge_event[event_loop].charge_event_act[d2.seq].
          cea_misc3)), c.item_copay = reply->charge_event[event_loop].charge_event_act[d2.seq].
        cea_misc5_id, c.item_reimbursement = reply->charge_event[event_loop].charge_event_act[d2.seq]
        .cea_misc6_id,
        c.discount_amount = reply->charge_event[event_loop].charge_event_act[d2.seq].cea_misc7_id, c
        .updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0,
        c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
        updt_task,
        c.priority_cd = reply->charge_event[event_loop].charge_event_act[d2.seq].priority_cd, c
        .item_deductible_amt = reply->charge_event[event_loop].charge_event_act[d2.seq].
        item_deductible_amt, c.patient_responsibility_flag = reply->charge_event[event_loop].
        charge_event_act[d2.seq].patient_responsibility_flag
       PLAN (d2
        WHERE (reply->charge_event[event_loop].charge_event_act[d2.seq].charge_event_act_id > 0))
        JOIN (c)
       WITH nocounter
      ;end insert
      CALL addchargeeventactprsnl(event_loop,act_cnt)
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE addchargeeventmod(e)
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
   CALL echo("Insert into charge_event_mod table")
   FOR (event_loop = 1 TO event_cnt)
     IF ((reply->charge_event[event_loop].charge_event_id > 0))
      SET mod_cnt = size(reply->charge_event[event_loop].mods.charge_mods,5)
      IF (mod_cnt > 0)
       DECLARE cemdelcnt = i4 WITH protect, noconstant(0)
       SET stat = alterlist(cemrequest->objarray,0)
       SELECT INTO "nl:"
        FROM charge_event_mod cem
        WHERE (cem.charge_event_id=reply->charge_event[event_loop].charge_event_id)
         AND cem.active_ind=1
        DETAIL
         cemdelcnt += 1, stat = alterlist(cemrequest->objarray,cemdelcnt), cemrequest->objarray[
         cemdelcnt].action_type = "DEL",
         cemrequest->objarray[cemdelcnt].charge_event_mod_id = cem.charge_event_mod_id, cemrequest->
         objarray[cemdelcnt].charge_event_id = cem.charge_event_id, cemrequest->objarray[cemdelcnt].
         updt_cnt = cem.updt_cnt
        WITH nocounter
       ;end select
       IF (size(cemrequest->objarray,5) <= 0)
        IF (validate(debug,- (1)) > 0)
         CALL echo("No charge_event_mods to inactivate")
        ENDIF
       ELSE
        EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",
         cemreply)
        IF ((cemreply->status_data.status != "S"))
         CALL logmessage(curprog,"afc_val_charge_event_mod did not return success while inactivating",
          log_debug)
         IF (validate(debug,- (1)) > 0)
          CALL echorecord(cemrequest)
          CALL echorecord(cemreply)
         ENDIF
        ENDIF
       ENDIF
       SET stat = alterlist(cemrequest->objarray,0)
       SET stat = alterlist(cemrequest->objarray,mod_cnt)
       FOR (mod_loop = 1 TO mod_cnt)
         CALL getnextnumber("NULL")
         SET reply->charge_event[event_loop].mods.charge_mods[mod_loop].mod_id = next_nbr
         SET cemrequest->objarray[mod_loop].action_type = "ADD"
         SET cemrequest->objarray[mod_loop].charge_event_mod_type_cd = reply->charge_event[event_loop
         ].mods.charge_mods[mod_loop].charge_event_mod_type_cd
         SET cemrequest->objarray[mod_loop].charge_event_mod_id = reply->charge_event[event_loop].
         mods.charge_mods[mod_loop].mod_id
         SET cemrequest->objarray[mod_loop].charge_event_id = reply->charge_event[event_loop].
         charge_event_id
         SET cemrequest->objarray[mod_loop].field1 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field1))
         SET cemrequest->objarray[mod_loop].field2 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field2))
         SET cemrequest->objarray[mod_loop].field3 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field3))
         SET cemrequest->objarray[mod_loop].field4 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field4))
         SET cemrequest->objarray[mod_loop].field5 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field5))
         SET cemrequest->objarray[mod_loop].field6 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field6))
         SET cemrequest->objarray[mod_loop].field7 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field7))
         SET cemrequest->objarray[mod_loop].field8 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field8))
         SET cemrequest->objarray[mod_loop].field9 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field9))
         SET cemrequest->objarray[mod_loop].field10 = substring(1,200,trim(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].field10))
         SET cemrequest->objarray[mod_loop].updt_cnt = 0
         SET cemrequest->objarray[mod_loop].active_ind = 1
         SET cemrequest->objarray[mod_loop].active_status_cd = 0
         SET cemrequest->objarray[mod_loop].active_status_dt_tm = cnvtdatetime(sysdate)
         IF (validate(reply->charge_event[event_loop].mods.charge_mods[mod_loop].code1_cd) != 0)
          SET cemrequest->objarray[mod_loop].code1_cd = validate(reply->charge_event[event_loop].mods
           .charge_mods[mod_loop].code1_cd,- (0.00001))
         ELSE
          SET cemrequest->objarray[mod_loop].code1_cd = 0.0
         ENDIF
         SET cemrequest->objarray[mod_loop].nomen_id = reply->charge_event[event_loop].mods.
         charge_mods[mod_loop].nomen_id
         SET cemrequest->objarray[mod_loop].field1_id = reply->charge_event[event_loop].mods.
         charge_mods[mod_loop].field1_id
         SET cemrequest->objarray[mod_loop].field2_id = reply->charge_event[event_loop].mods.
         charge_mods[mod_loop].field2_id
         SET cemrequest->objarray[mod_loop].field3_id = reply->charge_event[event_loop].mods.
         charge_mods[mod_loop].field3_id
         SET cemrequest->objarray[mod_loop].field4_id = reply->charge_event[event_loop].mods.
         charge_mods[mod_loop].field4_id
         SET cemrequest->objarray[mod_loop].field5_id = reply->charge_event[event_loop].mods.
         charge_mods[mod_loop].field5_id
         SET cemrequest->objarray[mod_loop].nomen_id = reply->charge_event[event_loop].mods.
         charge_mods[mod_loop].nomen_id
         SET cemrequest->objarray[mod_loop].cm1_nbr = reply->charge_event[event_loop].mods.
         charge_mods[mod_loop].cm1_nbr
         IF (validate(reply->charge_event[event_loop].mods.charge_mods[mod_loop].activity_dt_tm) != 0
         )
          SET cemrequest->objarray[mod_loop].activity_dt_tm = cnvtdatetime(reply->charge_event[
           event_loop].mods.charge_mods[mod_loop].activity_dt_tm)
         ELSE
          SET cemrequest->objarray[mod_loop].activity_dt_tm = null
         ENDIF
         IF (validate(reply->charge_event[event_loop].mods.charge_mods[mod_loop].charge_mod_source_cd
          ))
          SET reply->charge_event[event_loop].mods.charge_mods[mod_loop].charge_mod_source_cd =
          cs4518006_copyfromcem_cd
         ENDIF
       ENDFOR
       IF (size(cemrequest->objarray,5) <= 0)
        CALL echo("No charge_event_mods to add")
       ELSE
        EXECUTE afc_val_charge_event_mod  WITH replace("REQUEST",cemrequest), replace("REPLY",
         cemreply)
        IF ((cemreply->status_data.status != "S"))
         CALL logmessage(curprog,"afc_val_charge_event_mod did not return success while adding",
          log_debug)
         CALL echorecord(cemrequest)
         CALL echorecord(cemreply)
        ENDIF
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE addprimaryhealthplans(d)
   CALL echo("Adding primary health plans to the reply structure")
   DECLARE hpidx = i4 WITH protect, noconstant(0)
   DECLARE curhpidx = i4 WITH protect, noconstant(0)
   FOR (event_loop = 1 TO event_cnt)
     IF ((reply->charge_event[event_loop].charge_event_id > 0))
      SET act_cnt = size(reply->charge_event[event_loop].charge_event_act,5)
      IF (act_cnt > 0)
       SET groupcnt = 0
       SET mpcnt = 0.0
       SET hpidx = 0
       SET curhpidx = 0
       SELECT INTO "nl:"
        epr.health_plan_id
        FROM encntr_plan_cob epc,
         encntr_plan_cob_reltn epcr,
         encntr_plan_reltn epr
        PLAN (epc
         WHERE (epc.encntr_id=reply->charge_event[event_loop].encntr_id)
          AND epc.active_ind=1)
         JOIN (epcr
         WHERE epcr.encntr_plan_cob_id=epc.encntr_plan_cob_id
          AND epcr.active_ind=1
          AND epcr.priority_seq=1)
         JOIN (epr
         WHERE epr.encntr_plan_reltn_id=epcr.encntr_plan_reltn_id
          AND epr.active_ind=1
          AND epr.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[event_loop].
          charge_event_act[1].service_dt_tm)
          AND epr.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[event_loop].
          charge_event_act[1].service_dt_tm))
        ORDER BY epr.health_plan_id, epr.beg_effective_dt_tm
        HEAD epr.health_plan_id
         mpcnt += 1, stat = assign(validate(reply->charge_event[event_loop].primaryhealthplancount),
          mpcnt)
        DETAIL
         hpidx = locateval(curhpidx,1,groupcnt,epr.health_plan_id,reply->charge_event[event_loop].
          primaryhealthplans[curhpidx].health_plan_id)
         IF (hpidx=0)
          IF (epc.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[event_loop].
           charge_event_act[1].service_dt_tm)
           AND epc.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[event_loop].
           charge_event_act[1].service_dt_tm))
           groupcnt += 1, stat = alterlist(reply->charge_event[event_loop].primaryhealthplans,
            groupcnt), reply->charge_event[event_loop].primaryhealthplans[groupcnt].health_plan_id =
           epr.health_plan_id,
           reply->charge_event[event_loop].primaryhealthplans[groupcnt].priority_sequence = 1
          ENDIF
         ENDIF
        WITH nocounter
       ;end select
       SET groupcnt = 0
       SET mpcnt = 0
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE filloutreply(f)
   CALL echo("Look up encounter information")
   SELECT INTO "nl:"
    e.encntr_type_cd, e.organization_id, e.financial_class_cd,
    e.loc_nurse_unit_cd, e.med_service_cd, ef.bill_type_cd
    FROM encounter e,
     (dummyt d  WITH seq = value(event_cnt)),
     encntr_financial ef,
     dummyt d1
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0)
      AND (reply->charge_event[d.seq].encntr_id > 0))
     JOIN (e
     WHERE (e.encntr_id=reply->charge_event[d.seq].encntr_id))
     JOIN (d1)
     JOIN (ef
     WHERE ef.encntr_financial_id=e.encntr_financial_id
      AND ef.encntr_financial_id > 0)
    DETAIL
     reply->charge_event[d.seq].encntr_type_cd = e.encntr_type_cd, reply->charge_event[d.seq].
     encntr_type_class_cd = e.encntr_type_class_cd, reply->charge_event[d.seq].med_service_cd = e
     .med_service_cd,
     reply->charge_event[d.seq].encntr_org_id = e.organization_id, reply->charge_event[d.seq].
     fin_class_cd = e.financial_class_cd, reply->charge_event[d.seq].loc_nurse_unit_cd = e
     .loc_nurse_unit_cd,
     reply->charge_event[d.seq].encntr_bill_type_cd = ef.bill_type_cd
    WITH outerjoin = d1, nocounter
   ;end select
   CALL echo("Look up health plan")
   SELECT INTO "nl:"
    epr.health_plan_id, epr1.health_plan_id
    FROM encntr_plan_reltn epr,
     (dummyt d  WITH seq = value(event_cnt)),
     encntr_plan_cob epc,
     encntr_plan_cob_reltn epcr,
     encntr_plan_reltn epr1
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0)
      AND (reply->charge_event[d.seq].health_plan_id <= 0))
     JOIN (epr
     WHERE (epr.encntr_id=reply->charge_event[d.seq].encntr_id)
      AND epr.priority_seq=1
      AND epr.active_ind=1)
     JOIN (epc
     WHERE (epc.encntr_id= Outerjoin(epr.encntr_id))
      AND (epc.active_ind= Outerjoin(1)) )
     JOIN (epcr
     WHERE (epcr.encntr_plan_cob_id= Outerjoin(epc.encntr_plan_cob_id))
      AND (epcr.priority_seq= Outerjoin(1))
      AND (epcr.active_ind= Outerjoin(1)) )
     JOIN (epr1
     WHERE (epr1.encntr_plan_reltn_id= Outerjoin(epcr.encntr_plan_reltn_id))
      AND (epr1.active_ind= Outerjoin(1)) )
    DETAIL
     act_cnt = size(reply->charge_event[d.seq].charge_event_act,5)
     IF (epc.encntr_plan_cob_id > 0)
      IF (act_cnt > 0
       AND epc.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
       service_dt_tm)
       AND epc.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
       service_dt_tm)
       AND epr1.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
       service_dt_tm)
       AND epr1.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
       service_dt_tm))
       reply->charge_event[d.seq].health_plan_id = epr1.health_plan_id
      ENDIF
     ELSE
      IF (act_cnt > 0
       AND epr.beg_effective_dt_tm <= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
       service_dt_tm)
       AND epr.end_effective_dt_tm >= cnvtdatetime(reply->charge_event[d.seq].charge_event_act[1].
       service_dt_tm))
       reply->charge_event[d.seq].health_plan_id = epr.health_plan_id
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    o.organization_id
    FROM org_plan_reltn o,
     (dummyt d  WITH seq = value(event_cnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0.0)
      AND (reply->charge_event[d.seq].health_plan_id > 0.0))
     JOIN (o
     WHERE (o.health_plan_id=reply->charge_event[d.seq].health_plan_id)
      AND o.org_plan_reltn_cd=carrier_370_cd
      AND o.active_ind=1
      AND o.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND o.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     reply->charge_event[d.seq].insurance_org_id = o.organization_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    p.prsnl_group_id
    FROM prsnl_group_reltn p,
     (dummyt d  WITH seq = value(event_cnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0.0)
      AND (((reply->charge_event[d.seq].verify_phys_id > 0.0)) OR ((reply->charge_event[d.seq].
     perf_phys_id > 0.0))) )
     JOIN (p
     WHERE p.person_id IN (reply->charge_event[d.seq].verify_phys_id, reply->charge_event[d.seq].
     perf_phys_id)
      AND p.person_id != 0.0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     groupcnt += 1, stat = alterlist(reply->charge_event[d.seq].renderingphysgroups,groupcnt), reply
     ->charge_event[d.seq].renderingphysgroups[groupcnt].group_id = p.prsnl_group_id
    WITH nocounter
   ;end select
   SET groupcnt = 0
   SELECT INTO "nl:"
    p.prsnl_group_id
    FROM prsnl_group_reltn p,
     (dummyt d  WITH seq = value(event_cnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0.0)
      AND (reply->charge_event[d.seq].ord_phys_id > 0.0))
     JOIN (p
     WHERE (p.person_id=reply->charge_event[d.seq].ord_phys_id)
      AND p.person_id != 0.0
      AND p.active_ind=1
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     groupcnt += 1, stat = alterlist(reply->charge_event[d.seq].orderingphysgroups,groupcnt), reply->
     charge_event[d.seq].orderingphysgroups[groupcnt].group_id = p.prsnl_group_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(event_cnt)),
     person p
    PLAN (d
     WHERE (reply->charge_event[d.seq].person_id > 0.0))
     JOIN (p
     WHERE (p.person_id=reply->charge_event[d.seq].person_id)
      AND p.active_ind=true)
    DETAIL
     IF (validate(reply->charge_event[d.seq].logical_domain_id))
      reply->charge_event[d.seq].logical_domain_id = p.logical_domain_id
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE inboundpartialcredit(f)
   FOR (event_loop = 1 TO event_cnt)
     IF ((reply->charge_event[event_loop].charge_event_id=- (2)))
      SELECT INTO "nl:"
       FROM charge_event ce
       WHERE (ce.ext_m_event_id=reply->charge_event[event_loop].ext_master_event_id)
        AND (ce.ext_m_event_cont_cd=reply->charge_event[event_loop].ext_master_event_cont_cd)
        AND (ce.ext_p_event_id=reply->charge_event[event_loop].ext_parent_event_id)
        AND (ce.ext_p_event_cont_cd=reply->charge_event[event_loop].ext_parent_event_cont_cd)
        AND (ce.ext_i_event_id=reply->charge_event[event_loop].ext_item_event_id)
        AND (ce.ext_i_event_cont_cd=reply->charge_event[event_loop].ext_item_event_cont_cd)
       DETAIL
        reply->charge_event[event_loop].charge_event_id = ce.charge_event_id
       WITH nocounter
      ;end select
      IF (size(reply->charge_event[event_loop].charge_event_act,5) > 0)
       SELECT INTO "nl:"
        FROM charge_event_act cea
        WHERE (cea.charge_event_id=reply->charge_event[event_loop].charge_event_id)
        DETAIL
         reply->charge_event[event_loop].charge_event_act[1].charge_event_act_id = cea
         .charge_event_act_id
        WITH nocounter, maxqual(cea,1)
       ;end select
       UPDATE  FROM charge_event_act cea
        SET cea.quantity = reply->charge_event[event_loop].charge_event_act[1].quantity
        WHERE (cea.charge_event_act_id=reply->charge_event[event_loop].charge_event_act[1].
        charge_event_act_id)
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE getproviderspecialty(g)
   RECORD lochierarchy(
     1 list[*]
       2 level_cd = f8
   ) WITH protect
   DECLARE provider_id = f8 WITH noconstant(0.00)
   DECLARE spc_loc_cd = f8 WITH noconstant(0.00)
   DECLARE cur_cd = f8 WITH noconstant(0.00)
   DECLARE cnt = i4 WITH noconstant(0)
   DECLARE found = i2 WITH noconstant(false)
   FOR (event_loop = 1 TO event_cnt)
     SET stat = initrec(lochierarchy)
     SET provider_id = 0.00
     SET spc_loc_cd = 0.00
     SET cur_cd = 0.00
     SET cnt = 0
     SET found = false
     IF ((reply->charge_event[event_loop].verify_phys_id > 0))
      SET provider_id = reply->charge_event[event_loop].verify_phys_id
     ELSEIF ((reply->charge_event[event_loop].perf_phys_id > 0))
      SET provider_id = reply->charge_event[event_loop].perf_phys_id
     ELSEIF ((reply->charge_event[event_loop].ord_phys_id > 0))
      SET provider_id = reply->charge_event[event_loop].ord_phys_id
     ENDIF
     IF ((reply->charge_event[event_loop].perf_loc_cd > 0))
      SET spc_loc_cd = reply->charge_event[event_loop].perf_loc_cd
     ELSE
      SELECT INTO "nl:"
       FROM encounter e
       WHERE (e.encntr_id=reply->charge_event[event_loop].encntr_id)
       DETAIL
        spc_loc_cd = e.location_cd
       WITH nocounter
      ;end select
     ENDIF
     SELECT INTO "nl:"
      FROM code_value c
      WHERE c.code_value=spc_loc_cd
       AND c.active_ind=true
      DETAIL
       CASE (uar_get_code_meaning(c.code_value))
        OF "FACILITY":
         cnt = 1
        OF "BUILDING":
         cnt = 2
        OF "NURSEUNIT":
        OF "AMBULATORY":
         cnt = 3
        OF "ROOM":
         cnt = 4
        OF "BED":
         cnt = 5
       ENDCASE
      WITH nocounter
     ;end select
     SET cur_cd = spc_loc_cd
     SET stat = alterlist(lochierarchy->list,cnt)
     IF (cnt > 0)
      SET lochierarchy->list[cnt].level_cd = cur_cd
     ENDIF
     WHILE (cnt > 0)
      SELECT INTO "nl:"
       l.parent_loc_cd, l.child_loc_cd, l.location_group_type_cd
       FROM location_group l
       WHERE l.child_loc_cd=cur_cd
        AND l.active_ind=1
        AND l.root_loc_cd=0
       DETAIL
        IF (((cnt=4
         AND l.location_group_type_cd=cs222_room_cd) OR (((cnt=3
         AND ((l.location_group_type_cd=cs222_nurseunit_cd) OR (l.location_group_type_cd=
        cs222_ambulatory_cd)) ) OR (((cnt=2
         AND l.location_group_type_cd=cs222_building_cd) OR (cnt=1
         AND l.location_group_type_cd=cs222_facility_cd)) )) )) )
         cur_cd = l.parent_loc_cd, lochierarchy->list[cnt].level_cd = cur_cd
        ENDIF
       WITH nocounter
      ;end select
      SET cnt -= 1
     ENDWHILE
     SET cnt = size(alterlist(lochierarchy->list,5))
     WHILE (cnt > 0)
       SET spc_loc_cd = lochierarchy->list[cnt].level_cd
       SELECT INTO "nl:"
        FROM prsnl_specialty_reltn psr,
         prsnl_specialty_loc_reltn pslr
        PLAN (psr
         WHERE psr.prsnl_id=provider_id
          AND psr.active_ind=true
          AND psr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
          AND psr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
         JOIN (pslr
         WHERE pslr.prsnl_specialty_reltn_id=psr.prsnl_specialty_reltn_id
          AND pslr.location_cd=spc_loc_cd
          AND pslr.active_ind=true
          AND pslr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
          AND pslr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime))
        ORDER BY psr.prsnl_id, pslr.beg_effective_dt_tm
        HEAD psr.prsnl_id
         stat = assign(validate(reply->charge_event[event_loop].provider_specialty_cd),psr
          .specialty_cd)
        DETAIL
         found = true
        WITH nocounter
       ;end select
       IF (found=true)
        SET cnt = 0
       ELSE
        SET cnt -= 1
       ENDIF
     ENDWHILE
     IF (found=false)
      SELECT INTO "nl:"
       FROM prsnl_specialty_reltn psr
       WHERE psr.prsnl_id=provider_id
        AND psr.primary_ind=true
        AND psr.active_ind=true
        AND psr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
        AND psr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
       DETAIL
        stat = assign(validate(reply->charge_event[event_loop].provider_specialty_cd),psr
         .specialty_cd)
       WITH nocounter
      ;end select
     ENDIF
   ENDFOR
 END ;Subroutine
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
 SET event_cnt = size(reply->charge_event,5)
 IF (event_cnt > 0)
  CALL getchargeeventid("NULL")
  CALL addchargeevent("NULL")
  CALL addchargeeventact("NULL")
  CALL addchargeeventmod("NULL")
  CALL inboundpartialcredit("NULL")
  CALL filloutreply("NULL")
  IF (validate(reply->charge_event[1].primaryhealthplancount)=1)
   CALL addprimaryhealthplans("NULL")
  ENDIF
  IF (validate(reply->charge_event[event_cnt].provider_specialty_cd,- (1.0)) >= 0.00)
   CALL getproviderspecialty("NULL")
  ENDIF
 ELSE
  CALL echo("Request is empty")
 ENDIF
#end_of_program
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
