CREATE PROGRAM cs_srv_add_charge_event_rx:dba
 DECLARE cs_srv_add_charge_event_rx_version = vc WITH private, noconstant("293524.008")
 CALL echo(concat("CS_SRV_ADD_CHARGE_EVENT_RX - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 DECLARE next_nbr = f8
 DECLARE eventrepcnt = i2
 DECLARE eventreploop = i2
 DECLARE actrepcnt = i2
 DECLARE actreploop = i2
 DECLARE modrepcnt = i2
 DECLARE modreploop = i2
 SUBROUTINE getnextnumber(a)
   SELECT INTO "nl:"
    y = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     next_nbr = cnvtreal(y)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getchargeeventid(a_repnum)
  CALL echo("Check for existing charge_event record")
  SELECT INTO "nl:"
   c.charge_event_id, c.encntr_id, c.person_id
   FROM charge_event c
   WHERE (c.ext_m_event_id=reply->charge_event[a_repnum].ext_master_event_id)
    AND (c.ext_m_event_cont_cd=reply->charge_event[a_repnum].ext_master_event_cont_cd)
    AND (c.ext_p_event_id=reply->charge_event[a_repnum].ext_parent_event_id)
    AND (c.ext_p_event_cont_cd=reply->charge_event[a_repnum].ext_parent_event_cont_cd)
    AND (c.ext_i_event_id=reply->charge_event[a_repnum].ext_item_event_id)
    AND (c.ext_i_event_cont_cd=reply->charge_event[a_repnum].ext_item_event_cont_cd)
   DETAIL
    reply->charge_event[a_repnum].charge_event_id = c.charge_event_id
    IF ((reply->charge_event[a_repnum].encntr_id=0))
     reply->charge_event[a_repnum].encntr_id = c.encntr_id
    ENDIF
    IF ((reply->charge_event[a_repnum].person_id=0))
     reply->charge_event[a_repnum].person_id = c.person_id
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE addchargeevent(b_repnum)
   SET error_code = 1
   SET error_msg = fillstring(132," ")
   SET error_count = 0
   SET error_clear = 0
   SET msg_clear = fillstring(132," ")
   SET updateind = 0
   CALL getchargeeventid(b_repnum)
   IF ((reply->charge_event[b_repnum].charge_event_id > 0))
    SET updateind = 1
   ELSE
    CALL getnextnumber("NULL")
    SET reply->charge_event[b_repnum].charge_event_id = next_nbr
    CALL echo("Insert into charge_event table")
    SET error_clear = error(msg_clear,1)
    INSERT  FROM charge_event c
     SET c.charge_event_id = reply->charge_event[b_repnum].charge_event_id, c.ext_m_event_id = reply
      ->charge_event[b_repnum].ext_master_event_id, c.ext_m_event_cont_cd = reply->charge_event[
      b_repnum].ext_master_event_cont_cd,
      c.ext_m_reference_id = reply->charge_event[b_repnum].ext_master_reference_id, c
      .ext_m_reference_cont_cd = reply->charge_event[b_repnum].ext_master_reference_cont_cd, c
      .ext_p_event_id = reply->charge_event[b_repnum].ext_parent_event_id,
      c.ext_p_event_cont_cd = reply->charge_event[b_repnum].ext_parent_event_cont_cd, c
      .ext_p_reference_id = reply->charge_event[b_repnum].ext_parent_reference_id, c
      .ext_p_reference_cont_cd = reply->charge_event[b_repnum].ext_parent_reference_cont_cd,
      c.ext_i_event_id = reply->charge_event[b_repnum].ext_item_event_id, c.ext_i_event_cont_cd =
      reply->charge_event[b_repnum].ext_item_event_cont_cd, c.ext_i_reference_id = reply->
      charge_event[b_repnum].ext_item_reference_id,
      c.ext_i_reference_cont_cd = reply->charge_event[b_repnum].ext_item_reference_cont_cd, c
      .abn_status_cd = reply->charge_event[b_repnum].abn_status_cd, c.accession = substring(1,50,trim
       (reply->charge_event[b_repnum].accession)),
      c.active_ind = 1, c.active_status_dt_tm = cnvtdatetime(sysdate), c.bill_item_id = 0,
      c.cancelled_dt_tm = null, c.cancelled_ind = 0, c.collection_priority_cd = reply->charge_event[
      b_repnum].collection_priority_cd,
      c.report_priority_cd = reply->charge_event[b_repnum].report_priority_cd, c.encntr_id = reply->
      charge_event[b_repnum].encntr_id, c.person_id = reply->charge_event[b_repnum].person_id,
      c.order_id = reply->charge_event[b_repnum].order_id, c.perf_loc_cd = reply->charge_event[
      b_repnum].perf_loc_cd, c.reference_nbr = substring(1,60,trim(reply->charge_event[b_repnum].
        reference_nbr)),
      c.research_account_id = reply->charge_event[b_repnum].research_acct_id, c.updt_applctx =
      reqinfo->updt_applctx, c.updt_cnt = 0,
      c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
      updt_task,
      c.health_plan_id = reply->charge_event[b_repnum].health_plan_id
     WITH nocounter
    ;end insert
   ENDIF
   SET error_code = error(error_msg,0)
   IF (error_code=288)
    CALL getchargeeventid(b_repnum)
    SET updateind = 1
   ENDIF
   IF (updateind=1)
    CALL echo("Update charge_event table")
    UPDATE  FROM charge_event c
     SET c.abn_status_cd =
      IF ((reply->charge_event[b_repnum].abn_status_cd=0)) c.abn_status_cd
      ELSE reply->charge_event[b_repnum].abn_status_cd
      ENDIF
      , c.accession =
      IF ((reply->charge_event[b_repnum].accession="")) c.accession
      ELSE substring(1,50,trim(reply->charge_event[b_repnum].accession))
      ENDIF
      , c.reference_nbr =
      IF ((reply->charge_event[b_repnum].reference_nbr="")) c.reference_nbr
      ELSE substring(1,60,trim(reply->charge_event[b_repnum].reference_nbr))
      ENDIF
      ,
      c.collection_priority_cd =
      IF ((reply->charge_event[b_repnum].collection_priority_cd=0)) c.collection_priority_cd
      ELSE reply->charge_event[b_repnum].collection_priority_cd
      ENDIF
      , c.encntr_id =
      IF ((reply->charge_event[b_repnum].encntr_id=0)) c.encntr_id
      ELSE reply->charge_event[b_repnum].encntr_id
      ENDIF
      , c.order_id =
      IF ((reply->charge_event[b_repnum].order_id=0)) c.order_id
      ELSE reply->charge_event[b_repnum].order_id
      ENDIF
      ,
      c.perf_loc_cd =
      IF ((reply->charge_event[b_repnum].perf_loc_cd=0)) c.perf_loc_cd
      ELSE reply->charge_event[b_repnum].perf_loc_cd
      ENDIF
      , c.person_id =
      IF ((reply->charge_event[b_repnum].person_id=0)) c.person_id
      ELSE reply->charge_event[b_repnum].person_id
      ENDIF
      , c.report_priority_cd =
      IF ((reply->charge_event[b_repnum].report_priority_cd=0)) c.report_priority_cd
      ELSE reply->charge_event[b_repnum].report_priority_cd
      ENDIF
      ,
      c.research_account_id =
      IF ((reply->charge_event[b_repnum].research_acct_id=0)) c.research_account_id
      ELSE reply->charge_event[b_repnum].research_acct_id
      ENDIF
      , c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = (c.updt_cnt+ 1),
      c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->
      updt_task,
      c.health_plan_id =
      IF ((reply->charge_event[b_repnum].health_plan_id=0)) c.health_plan_id
      ELSE reply->charge_event[b_repnum].health_plan_id
      ENDIF
     WHERE (c.charge_event_id=reply->charge_event[b_repnum].charge_event_id)
     WITH nocounter
    ;end update
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE setupactsandmods(c_repnum)
   CALL echo("Get new charge_event_act and charge_event_mod id")
   SET actrepcnt = size(reply->charge_event[c_repnum].charge_event_act,5)
   FOR (actreploop = 1 TO actrepcnt)
    CALL getnextnumber("NULL")
    SET reply->charge_event[c_repnum].charge_event_act[actreploop].charge_event_act_id = next_nbr
   ENDFOR
   SET modrepcnt = size(reply->charge_event[c_repnum].mods.charge_mods,5)
   FOR (modreploop = 1 TO modrepcnt)
    CALL getnextnumber("NULL")
    SET reply->charge_event[c_repnum].mods.charge_mods[modreploop].mod_id = next_nbr
   ENDFOR
 END ;Subroutine
 SUBROUTINE addchargeeventact(d_repnum)
  IF (actrepcnt > 0)
   CALL echo("Insert into charge_event_act table")
   INSERT  FROM charge_event_act c,
     (dummyt d  WITH seq = value(actrepcnt))
    SET c.seq = 1, c.accession_id = reply->charge_event[d_repnum].charge_event_act[d.seq].
     accession_id, c.active_ind = 1,
     c.alpha_nomen_id = reply->charge_event[d_repnum].charge_event_act[d.seq].alpha_nomen_id, c
     .cea_misc1 = substring(1,200,trim(reply->charge_event[d_repnum].charge_event_act[d.seq].
       cea_misc1)), c.cea_misc2 = substring(1,200,trim(reply->charge_event[d_repnum].
       charge_event_act[d.seq].cea_misc2)),
     c.cea_misc3 = substring(1,200,trim(reply->charge_event[d_repnum].charge_event_act[d.seq].
       cea_misc3)), c.cea_misc1_id = reply->charge_event[d_repnum].charge_event_act[d.seq].
     cea_misc1_id, c.item_ext_price = reply->charge_event[d_repnum].charge_event_act[d.seq].
     cea_misc2_id,
     c.cea_misc3_id = reply->charge_event[d_repnum].charge_event_act[d.seq].cea_misc3_id, c
     .item_price = reply->charge_event[d_repnum].charge_event_act[d.seq].cea_misc4_id, c.item_copay
      = reply->charge_event[d_repnum].charge_event_act[d.seq].cea_misc5_id,
     c.item_reimbursement = reply->charge_event[d_repnum].charge_event_act[d.seq].cea_misc6_id, c
     .discount_amount = reply->charge_event[d_repnum].charge_event_act[d.seq].cea_misc7_id, c
     .cea_prsnl_id = reply->charge_event[d_repnum].charge_event_act[d.seq].cea_prsnl_id,
     c.cea_type_cd = reply->charge_event[d_repnum].charge_event_act[d.seq].cea_type_cd, c.misc_ind =
     reply->charge_event[d_repnum].charge_event_act[d.seq].misc_ind, c.charge_event_act_id = reply->
     charge_event[d_repnum].charge_event_act[d.seq].charge_event_act_id,
     c.charge_event_id = reply->charge_event[d_repnum].charge_event_id, c.charge_type_cd = reply->
     charge_event[d_repnum].charge_event_act[d.seq].charge_type_cd, c.insert_dt_tm = cnvtdatetime(
      sysdate),
     c.in_lab_dt_tm = null, c.quantity = reply->charge_event[d_repnum].charge_event_act[d.seq].
     rx_quantity, c.reason_cd = reply->charge_event[d_repnum].charge_event_act[d.seq].reason_cd,
     c.result = substring(1,200,trim(reply->charge_event[d_repnum].charge_event_act[d.seq].result)),
     c.service_dt_tm =
     IF ((reply->charge_event[d_repnum].charge_event_act[d.seq].service_dt_tm <= 0)) null
     ELSE cnvtdatetime(reply->charge_event[d_repnum].charge_event_act[d.seq].service_dt_tm)
     ENDIF
     , c.service_loc_cd = reply->charge_event[d_repnum].charge_event_act[d.seq].service_loc_cd,
     c.service_resource_cd = reply->charge_event[d_repnum].charge_event_act[d.seq].
     service_resource_cd, c.units = reply->charge_event[d_repnum].charge_event_act[d.seq].units, c
     .unit_type_cd = reply->charge_event[d_repnum].charge_event_act[d.seq].unit_type_cd,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
     c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.priority_cd = reply->
     charge_event[d_repnum].charge_event_act[d.seq].priority_cd
    PLAN (d)
     JOIN (c)
    WITH nocounter
   ;end insert
  ENDIF
  COMMIT
 END ;Subroutine
 SUBROUTINE addchargeeventmod(e_repnum)
  IF (modrepcnt > 0)
   CALL echo("Insert into charge_event_mod table")
   INSERT  FROM charge_event_mod c,
     (dummyt d  WITH seq = value(modrepcnt))
    SET c.seq = 1, c.charge_event_mod_id = reply->charge_event[e_repnum].mods.charge_mods[d.seq].
     mod_id, c.charge_event_id = reply->charge_event[e_repnum].charge_event_id,
     c.charge_event_mod_type_cd = reply->charge_event[e_repnum].mods.charge_mods[d.seq].
     charge_event_mod_type_cd, c.field1 = substring(1,200,trim(reply->charge_event[e_repnum].mods.
       charge_mods[d.seq].field1)), c.field2 = substring(1,200,trim(reply->charge_event[e_repnum].
       mods.charge_mods[d.seq].field2)),
     c.field3 = substring(1,200,trim(reply->charge_event[e_repnum].mods.charge_mods[d.seq].field3)),
     c.field4 = substring(1,200,trim(reply->charge_event[e_repnum].mods.charge_mods[d.seq].field4)),
     c.field5 = substring(1,200,trim(reply->charge_event[e_repnum].mods.charge_mods[d.seq].field5)),
     c.field6 = substring(1,200,trim(reply->charge_event[e_repnum].mods.charge_mods[d.seq].field6)),
     c.field7 = substring(1,200,trim(reply->charge_event[e_repnum].mods.charge_mods[d.seq].field7)),
     c.field8 = substring(1,200,trim(reply->charge_event[e_repnum].mods.charge_mods[d.seq].field8)),
     c.field9 = substring(1,200,trim(reply->charge_event[e_repnum].mods.charge_mods[d.seq].field9)),
     c.field10 = substring(1,200,trim(reply->charge_event[e_repnum].mods.charge_mods[d.seq].field10)),
     c.active_ind = 1,
     c.updt_cnt = 0, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime(sysdate), c.active_status_cd
      = 0,
     c.active_status_dt_tm = cnvtdatetime(sysdate), c.field1_id = reply->charge_event[e_repnum].mods.
     charge_mods[d.seq].field1_id, c.field2_id = reply->charge_event[e_repnum].mods.charge_mods[d.seq
     ].field2_id,
     c.field3_id = reply->charge_event[e_repnum].mods.charge_mods[d.seq].field3_id, c.field4_id =
     reply->charge_event[e_repnum].mods.charge_mods[d.seq].field4_id, c.field5_id = reply->
     charge_event[e_repnum].mods.charge_mods[d.seq].field5_id,
     c.nomen_id = reply->charge_event[e_repnum].mods.charge_mods[d.seq].nomen_id, c.cm1_nbr = reply->
     charge_event[e_repnum].mods.charge_mods[d.seq].cm1_nbr
    PLAN (d)
     JOIN (c)
    WITH nocounter
   ;end insert
  ENDIF
  COMMIT
 END ;Subroutine
 SUBROUTINE filloutreply(b)
   CALL echo("Look up research org id")
   SELECT INTO "nl:"
    r.organization_id
    FROM research_account r,
     (dummyt d  WITH seq = value(eventrepcnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].research_acct_id > 0))
     JOIN (r
     WHERE (r.research_account_id=reply->charge_event[d.seq].research_acct_id))
    DETAIL
     reply->charge_event[d.seq].research_org_id = r.organization_id
    WITH nocounter
   ;end select
   CALL echo("Look up encounter info")
   SELECT INTO "nl:"
    e.encntr_type_cd, e.organization_id, e.financial_class_cd,
    e.loc_nurse_unit_cd, e.med_service_cd, ef.bill_type_cd
    FROM encounter e,
     (dummyt d  WITH seq = value(eventrepcnt)),
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
     med_service_cd = e.med_service_cd, reply->charge_event[d.seq].encntr_org_id = e.organization_id,
     reply->charge_event[d.seq].fin_class_cd = e.financial_class_cd, reply->charge_event[d.seq].
     loc_nurse_unit_cd = e.loc_nurse_unit_cd, reply->charge_event[d.seq].encntr_bill_type_cd = ef
     .bill_type_cd
    WITH outerjoin = d1, nocounter
   ;end select
   CALL echo("Look up health plan")
   SELECT INTO "nl:"
    e.health_plan_id
    FROM encntr_plan_reltn e,
     (dummyt d  WITH seq = value(eventrepcnt))
    PLAN (d
     WHERE (reply->charge_event[d.seq].charge_event_id > 0)
      AND (reply->charge_event[d.seq].health_plan_id <= 0))
     JOIN (e
     WHERE (e.encntr_id=reply->charge_event[d.seq].encntr_id)
      AND e.priority_seq=1
      AND e.active_ind=1
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     IF ((reply->charge_event[d.seq].health_plan_id <= 0))
      reply->charge_event[d.seq].health_plan_id = e.health_plan_id
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(eventrepcnt)),
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
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
 SET eventrepcnt = size(reply->charge_event,5)
 FOR (eventreploop = 1 TO eventrepcnt)
   CALL addchargeevent(eventreploop)
   CALL setupactsandmods(eventreploop)
   CALL addchargeeventact(eventreploop)
   CALL addchargeeventmod(eventreploop)
 ENDFOR
 CALL filloutreply("NULL")
#end_of_program
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(reply)
 ENDIF
END GO
