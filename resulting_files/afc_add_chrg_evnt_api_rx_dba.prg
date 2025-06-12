CREATE PROGRAM afc_add_chrg_evnt_api_rx:dba
 SET max_act = 0
 SET max_mod = 0
 SET script_name = "AFC_ADD_CHRG_EVNT_API_RX "
 CALL echo(script_name,0)
 CALL echo(concat(format(curdate,"mm/dd/yy;;d")," ",format(curtime3,"hh:mm:ss;;s")))
 CALL echo(build("request->action_type:",request->action_type))
 RECORD reply(
   1 error_qual = i2
   1 error_information[*]
     2 error_code = i2
     2 error_msg = c132
   1 charge_event_qual = i2
   1 charge_event[*]
     2 charge_event_id = f8
     2 updt_ce_ind = i2
     2 charge_event_act_qual = i2
     2 charge_event_act[*]
       3 charge_event_act_id = f8
       3 cea_type_cd = f8
       3 service_resource_cd = f8
     2 charge_event_mod_qual = i2
     2 charge_event_mod[*]
       3 charge_event_mod_id = f8
 )
 SET error_code = 1
 SET error_msg = fillstring(132," ")
 SET error_count = 0
 SET error_clear = 0
 SET msg_clear = fillstring(132," ")
 CALL initialize("init")
 CALL uptchargeevent("event")
 CALL checkdupcollection("go")
 CALL logreply("LOG")
 GO TO end_program
 SUBROUTINE initialize(str)
   CALL echo("Initialize")
   CALL echo("    in request->charge_event_qual: ",0)
   CALL echo(request->charge_event_qual)
   SET request->charge_event_qual = size(request->charge_event,5)
   SET reply->charge_event_qual = request->charge_event_qual
   CALL echo("    actual request->charge_event_qual: ",0)
   CALL echo(request->charge_event_qual)
   SET stat = alterlist(reply->charge_event,request->charge_event_qual)
   SET max_act = 0
   SET max_mod = 0
   IF ((request->charge_event_qual <= 0))
    GO TO end_program
   ENDIF
   FOR (i = 1 TO request->charge_event_qual)
     CALL echo(build("    m_ref_id: ",request->charge_event[i].ext_master_reference_id))
     CALL echo(build("    m_ref_cd: ",request->charge_event[i].ext_master_reference_cont_cd))
     CALL echo(build("    i_ref_id: ",request->charge_event[i].ext_item_reference_id))
     CALL echo(build("    i_ref_cd: ",request->charge_event[i].ext_item_reference_cont_cd))
     CALL echo(build("    person_id: ",request->charge_event[i].person_id))
     CALL echo(build("    encntr_id: ",request->charge_event[i].encntr_id))
     IF (size(request->charge_event[i].charge_event_act,5) > max_act)
      SET max_act = size(request->charge_event[i].charge_event_act,5)
     ENDIF
     SET request->charge_event[i].charge_event_act_qual = size(request->charge_event[i].
      charge_event_act,5)
     SET stat = alterlist(reply->charge_event[i].charge_event_act,request->charge_event[i].
      charge_event_act_qual)
     SET reply->charge_event[i].charge_event_act_qual = request->charge_event[i].
     charge_event_act_qual
     CALL echo("    charge event act qual ",0)
     CALL echo(request->charge_event[i].charge_event_act_qual)
     SET request->charge_event[i].charge_event_mod_qual = size(request->charge_event[i].
      charge_event_mod,5)
     SET stat = alterlist(reply->charge_event[i].charge_event_mod,request->charge_event[i].
      charge_event_act_qual)
     SET reply->charge_event[i].charge_event_mod_qual = request->charge_event[i].
     charge_event_mod_qual
     IF ((request->charge_event[i].charge_event_mod_qual > max_mod))
      SET max_mod = request->charge_event[i].charge_event_mod_qual
     ENDIF
     CALL getchargeeventid(i)
     IF ((reply->charge_event[i].updt_ce_ind <= 0))
      CALL addchargeevent(i)
     ENDIF
     FOR (a = 1 TO request->charge_event[i].charge_event_act_qual)
       CALL echo(build("    charge_event_act[",a,"]"))
       IF ((reply->charge_event[i].updt_ce_ind=2))
        SET reply->charge_event[i].charge_event_act[a].charge_event_act_id = - (1)
       ENDIF
       SET typ_cd = request->charge_event[i].charge_event_act[a].cea_type_cd
       SET type_mean = fillstring(12," ")
       SET type_mean = uar_get_code_meaning(typ_cd)
       CALL echo(concat("type_mean: ",type_mean))
       IF (substring((size(trim(type_mean,3)) - 2),3,trim(type_mean,3)) != "ING")
        CALL echo(build("    CHARGE_TYPE_CD: ",request->charge_event[i].charge_event_act[a].
          charge_type_cd))
        CALL echo("    Evaluate prsnl ids...")
        SET reply->charge_event[i].charge_event_act[a].service_resource_cd = request->charge_event[i]
        .charge_event_act[a].service_resource_cd
        CALL echo("    service_dt_tm: ",0)
        CALL echo(request->charge_event[i].charge_event_act[a].service_dt_tm)
       ELSE
        SET reply->charge_event[i].charge_event_act[a].charge_event_act_id = - (1)
        CALL echo(concat("MEANING NOT PROCESSED: ",type_mean))
       ENDIF
       CALL echo("    request cea_type_cd ",0)
       CALL echo(request->charge_event[i].charge_event_act[a].cea_type_cd)
     ENDFOR
     CALL addchargeeventact(i)
     FOR (a = 1 TO request->charge_event[i].charge_event_mod_qual)
       SET reply->charge_event[i].charge_event_mod[a].charge_event_mod_id = 0.0
       SET request->charge_event[i].charge_event_mod[a].field6 = request->charge_event[i].
       charge_event_mod[a].field2
       SET request->charge_event[i].charge_event_mod[a].field7 = request->charge_event[i].
       charge_event_mod[a].field3
     ENDFOR
     CALL addchargeeventmod(i)
   ENDFOR
   CALL echo("END initialize")
 END ;Subroutine
 SUBROUTINE getchargeeventid(x1)
   CALL echo("GetChargeEventID")
   SELECT INTO "nl:"
    c.charge_item_id, ce.charge_event_id, ce.cancelled_ind
    FROM charge_event ce,
     dummyt d,
     charge c
    PLAN (ce
     WHERE (ce.ext_m_event_id=request->charge_event[x1].ext_master_event_id)
      AND (ce.ext_m_event_cont_cd=request->charge_event[x1].ext_master_event_cont_cd)
      AND (ce.ext_p_event_id=request->charge_event[x1].ext_parent_event_id)
      AND (ce.ext_p_event_cont_cd=request->charge_event[x1].ext_parent_event_cont_cd)
      AND (ce.ext_i_event_id=request->charge_event[x1].ext_item_event_id)
      AND (ce.ext_i_event_cont_cd=request->charge_event[x1].ext_item_event_cont_cd))
     JOIN (d)
     JOIN (c
     WHERE c.charge_event_id=ce.charge_event_id)
    DETAIL
     CALL echo(build("Rad Result->detail: ",ce.charge_event_id))
     IF (c.charge_item_id > 0)
      reply->charge_event[x1].updt_ce_ind = 2
     ELSE
      reply->charge_event[x1].updt_ce_ind = 1
     ENDIF
     reply->charge_event[x1].charge_event_id = ce.charge_event_id
    WITH outerjoin = d, nocounter
   ;end select
   CALL echo("END GetChargeEventID")
 END ;Subroutine
 SUBROUTINE addchargeevent(i2)
   CALL echo("AddChargeEvent")
   SET new_nbr = 0.0
   SELECT INTO "nl:"
    y = seq(charge_event_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_nbr = cnvtreal(y)
    WITH nocounter
   ;end select
   IF (curqual=0)
    RETURN
   ENDIF
   IF ((request->charge_event[i2].ext_item_event_id=- (1)))
    IF ((request->charge_event[i2].ext_item_event_cont_cd=code_val->13016_charge_event))
     SET request->charge_event[i2].ext_master_event_id = new_nbr
     SET request->charge_event[i2].ext_item_event_id = new_nbr
     CALL echo("ext_m_event_id = -1 with unexpected cont_cd")
    ENDIF
   ENDIF
   SET error_clear = error(msg_clear,1)
   INSERT  FROM charge_event c
    SET c.charge_event_id = new_nbr, c.ext_m_event_id =
     IF ((request->charge_event[i2].ext_master_event_id=0)) 0
     ELSE request->charge_event[i2].ext_master_event_id
     ENDIF
     , c.ext_m_event_cont_cd =
     IF ((request->charge_event[i2].ext_master_event_cont_cd=0)) 0
     ELSE request->charge_event[i2].ext_master_event_cont_cd
     ENDIF
     ,
     c.ext_m_reference_id =
     IF ((request->charge_event[i2].ext_master_reference_id=0)) 0
     ELSE request->charge_event[i2].ext_master_reference_id
     ENDIF
     , c.ext_m_reference_cont_cd =
     IF ((request->charge_event[i2].ext_master_reference_cont_cd=0)) 0
     ELSE request->charge_event[i2].ext_master_reference_cont_cd
     ENDIF
     , c.ext_p_event_id =
     IF ((request->charge_event[i2].ext_parent_event_id=0)) 0
     ELSE request->charge_event[i2].ext_parent_event_id
     ENDIF
     ,
     c.ext_p_event_cont_cd =
     IF ((request->charge_event[i2].ext_parent_event_cont_cd=0)) 0
     ELSE request->charge_event[i2].ext_parent_event_cont_cd
     ENDIF
     , c.ext_p_reference_id =
     IF ((request->charge_event[i2].ext_parent_reference_id=0)) 0
     ELSE request->charge_event[i2].ext_parent_reference_id
     ENDIF
     , c.ext_p_reference_cont_cd =
     IF ((request->charge_event[i2].ext_parent_reference_cont_cd=0)) 0
     ELSE request->charge_event[i2].ext_parent_reference_cont_cd
     ENDIF
     ,
     c.ext_i_event_id =
     IF ((request->charge_event[i2].ext_item_event_id=0)) 0
     ELSE request->charge_event[i2].ext_item_event_id
     ENDIF
     , c.ext_i_event_cont_cd =
     IF ((request->charge_event[i2].ext_item_event_cont_cd=0)) 0
     ELSE request->charge_event[i2].ext_item_event_cont_cd
     ENDIF
     , c.ext_i_reference_id =
     IF ((request->charge_event[i2].ext_item_reference_id=0)) 0
     ELSE request->charge_event[i2].ext_item_reference_id
     ENDIF
     ,
     c.ext_i_reference_cont_cd =
     IF ((request->charge_event[i2].ext_item_reference_cont_cd=0)) 0
     ELSE request->charge_event[i2].ext_item_reference_cont_cd
     ENDIF
     , c.bill_item_id = 0, c.order_id =
     IF ((request->charge_event[i2].order_id=0)) 0
     ELSE request->charge_event[i2].order_id
     ENDIF
     ,
     c.contributor_system_cd =
     IF ((request->charge_event[i2].contributor_system_cd=0)) 0
     ELSE request->charge_event[i2].contributor_system_cd
     ENDIF
     , c.reference_nbr = substring(1,60,trim(request->charge_event[i2].reference_nbr)), c
     .research_account_id = request->charge_event[i2].research_acct_id,
     c.cancelled_ind = 0, c.cancelled_dt_tm = null, c.person_id =
     IF ((request->charge_event[i2].person_id=0)) 0
     ELSE request->charge_event[i2].person_id
     ENDIF
     ,
     c.encntr_id =
     IF ((request->charge_event[i2].encntr_id=0)) 0
     ELSE request->charge_event[i2].encntr_id
     ENDIF
     , c.collection_priority_cd =
     IF ((request->charge_event[i2].collection_priority_cd=0)) 0
     ELSE request->charge_event[i2].collection_priority_cd
     ENDIF
     , c.report_priority_cd =
     IF ((request->charge_event[i2].report_priority_cd=0)) 0
     ELSE request->charge_event[i2].report_priority_cd
     ENDIF
     ,
     c.accession = substring(1,50,trim(request->charge_event[i2].accession)), c.active_ind = 1, c
     .active_status_dt_tm = cnvtdatetime(sysdate),
     c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate), c.updt_id = reqinfo->updt_id
    WITH nocounter
   ;end insert
   SET error_code = error(error_msg,0)
   IF (error_code=288)
    CALL getchargeeventid(i2)
   ELSE
    WHILE (error_code != 0)
      SET error_count += 1
      SET reply->error_qual = error_count
      SET stat = alterlist(reply->error_information,error_count)
      SET reply->error_information[error_count].error_code = error_code
      SET reply->error_information[error_count].error_msg = error_msg
      SET error_code = error(error_msg,0)
    ENDWHILE
   ENDIF
   IF (curqual=0)
    SET reply->charge_event[i2].charge_event_id = 0.0
    RETURN
   ELSE
    SET reply->charge_event[i2].charge_event_id = new_nbr
   ENDIF
   COMMIT
   CALL echo("END AddChargeEvent")
 END ;Subroutine
 SUBROUTINE addchargeeventact(i2)
   CALL echo("AddChargeEventAct")
   SET new_nbr = 0.0
   FOR (m = 1 TO request->charge_event[i2].charge_event_act_qual)
     IF ((reply->charge_event[i2].charge_event_act[m].charge_event_act_id != - (1)))
      SET new_nbr = 0.0
      SET reply->charge_event[i2].charge_event_act[m].charge_event_act_id = 0.0
      SET typ_cd = request->charge_event[i2].charge_event_act[m].cea_type_cd
      IF ((( NOT (typ_cd IN (code_val->13029_performed, code_val->13029_performing))) OR ((request->
      action_type="PRF"))) )
       SELECT INTO "nl:"
        y = seq(charge_event_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_nbr = cnvtreal(y)
        WITH nocounter
       ;end select
       IF (curqual=0)
        CALL echo("could not get seq for charge_event_act")
        RETURN
       ELSE
        CALL echo(build("AddChargeEventAct - i2: ",i2," : m: ",m," : new_nbr: ",
          new_nbr))
        SET reply->charge_event[i2].charge_event_act[m].charge_event_act_id = new_nbr
        SET reply->charge_event[i2].charge_event_act[m].cea_type_cd = request->charge_event[i2].
        charge_event_act[m].cea_type_cd
        CALL echo("service dt_tm  ",0)
        CALL echo(request->charge_event[i2].charge_event_act[m].service_dt_tm)
        CALL echo("charge dt_tm  ",0)
        CALL echo(request->charge_event[i2].charge_event_act[m].charge_dt_tm)
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
   SET error_clear = error(msg_clear,1)
   INSERT  FROM charge_event_act c,
     (dummyt d2  WITH seq = value(max_act))
    SET c.seq = 1, c.charge_event_act_id = reply->charge_event[i2].charge_event_act[d2.seq].
     charge_event_act_id, c.charge_event_id =
     IF ((reply->charge_event[i2].charge_event_id=0)) 0
     ELSE reply->charge_event[i2].charge_event_id
     ENDIF
     ,
     c.cea_type_cd = request->charge_event[i2].charge_event_act[d2.seq].cea_type_cd, c.cea_prsnl_id
      =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].cea_prsnl_id=0)) 0
     ELSE request->charge_event[i2].charge_event_act[d2.seq].cea_prsnl_id
     ENDIF
     , c.service_resource_cd =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].service_resource_cd=0)) 0
     ELSE request->charge_event[i2].charge_event_act[d2.seq].service_resource_cd
     ENDIF
     ,
     c.service_dt_tm =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].service_dt_tm <= 0)) null
     ELSE cnvtdatetime(request->charge_event[i2].charge_event_act[d2.seq].service_dt_tm)
     ENDIF
     , c.charge_dt_tm =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].charge_dt_tm <= 0)) null
     ELSE cnvtdatetime(request->charge_event[i2].charge_event_act[d2.seq].charge_dt_tm)
     ENDIF
     , c.charge_type_cd =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].charge_type_cd=0)) 0
     ELSE request->charge_event[i2].charge_event_act[d2.seq].charge_type_cd
     ENDIF
     ,
     c.reference_range_factor_id =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].reference_range_factor_id=0)) 0
     ELSE request->charge_event[i2].charge_event_act[d2.seq].reference_range_factor_id
     ENDIF
     , c.alpha_nomen_id = request->charge_event[i2].charge_event_act[d2.seq].alpha_nomen_id, c
     .quantity = request->charge_event[i2].charge_event_act[d2.seq].quantity,
     c.units = request->charge_event[i2].charge_event_act[d2.seq].units, c.unit_type_cd =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].unit_type_cd=0)) 0
     ELSE request->charge_event[i2].charge_event_act[d2.seq].unit_type_cd
     ENDIF
     , c.patient_loc_cd =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].patient_loc_cd=0)) 0
     ELSE request->charge_event[i2].charge_event_act[d2.seq].patient_loc_cd
     ENDIF
     ,
     c.service_loc_cd =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].service_loc_cd=0)) 0
     ELSE request->charge_event[i2].charge_event_act[d2.seq].service_loc_cd
     ENDIF
     , c.reason_cd =
     IF ((request->charge_event[i2].charge_event_act[d2.seq].reason_cd=0)) 0
     ELSE request->charge_event[i2].charge_event_act[d2.seq].reason_cd
     ENDIF
     , c.accession_id = request->charge_event[i2].charge_event_act[d2.seq].accession_id,
     c.repeat_ind = request->charge_event[i2].charge_event_act[d2.seq].repeat_ind, c.insert_dt_tm =
     cnvtdatetime(sysdate), c.active_ind = 1,
     c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_dt_tm = cnvtdatetime(sysdate),
     c.result = substring(1,100,trim(request->charge_event[i2].charge_event_act[d2.seq].result)), c
     .cea_misc1 = substring(1,200,trim(request->charge_event[i2].charge_event_act[d2.seq].details)),
     c.cea_misc1_id = request->charge_event[i2].charge_event_act[d2.seq].price_sched_id,
     c.cea_misc2_id = request->charge_event[i2].charge_event_act[d2.seq].ext_price, c.cea_misc3_id =
     request->charge_event[i2].charge_event_act[d2.seq].cost, c.cea_misc4_id = request->charge_event[
     i2].charge_event_act[d2.seq].item_price,
     c.cea_misc2 = substring(1,200,trim(request->charge_event[i2].charge_event_act[d2.seq].bill_code)
      ), c.cea_misc3 = substring(1,200,trim(request->charge_event[i2].charge_event_act[d2.seq].
       item_desc)), c.misc_ind = request->charge_event[i2].charge_event_act[d2.seq].misc_ind
    PLAN (d2
     WHERE (d2.seq <= request->charge_event[i2].charge_event_act_qual)
      AND (reply->charge_event[i2].charge_event_act[d2.seq].charge_event_act_id > 0))
     JOIN (c)
    WITH nocounter
   ;end insert
   SET error_code = error(error_msg,0)
   WHILE (error_code != 0)
     SET error_count += 1
     SET reply->error_qual = error_count
     SET stat = alterlist(reply->error_information,error_count)
     SET reply->error_information[error_count].error_code = error_code
     SET reply->error_information[error_count].error_msg = error_msg
     SET error_code = error(error_msg,0)
   ENDWHILE
   IF (curqual=0)
    CALL echo("oops  charge_event_act::insert")
    RETURN
   ENDIF
   CALL echo("END AccChargeEventAct")
 END ;Subroutine
 SUBROUTINE addchargeeventmod(i2)
   CALL echo("AddChargeEventMod")
   SET new_nbr = 0.0
   IF (max_mod > 0)
    FOR (m = 1 TO request->charge_event[i2].charge_event_mod_qual)
      IF ((request->charge_event[i2].charge_event_mod[m].charge_event_mod_type_cd >= 1.0))
       SET new_nbr = 0.0
       SELECT INTO "nl:"
        y = seq(charge_event_seq,nextval)"##################;rp0"
        FROM dual
        DETAIL
         new_nbr = cnvtreal(y)
        WITH nocounter
       ;end select
       IF (curqual=0)
        CALL echo("could not get seq for charge_event_mod")
        RETURN
       ELSE
        CALL echo(build("AddChargeEventMod - i: ",i," : m: ",m," : new_nbr: ",
          new_nbr))
        SET reply->charge_event[i2].charge_event_mod[m].charge_event_mod_id = new_nbr
       ENDIF
      ENDIF
    ENDFOR
    SET error_clear = error(msg_clear,1)
    INSERT  FROM charge_event_mod c,
      (dummyt d2  WITH seq = value(max_mod))
     SET c.seq = 1, c.charge_event_mod_id = reply->charge_event[i2].charge_event_mod[d2.seq].
      charge_event_mod_id, c.charge_event_id =
      IF ((reply->charge_event[i2].charge_event_id=0)) 0
      ELSE reply->charge_event[i2].charge_event_id
      ENDIF
      ,
      c.charge_event_mod_type_cd = request->charge_event[i2].charge_event_mod[d2.seq].
      charge_event_mod_type_cd, c.field1 = substring(1,200,trim(request->charge_event[i2].
        charge_event_mod[d2.seq].field1)), c.field2 = substring(1,200,trim(request->charge_event[i2].
        charge_event_mod[d2.seq].field2)),
      c.field3 = substring(1,200,trim(request->charge_event[i2].charge_event_mod[d2.seq].field3)), c
      .field4 = substring(1,200,trim(request->charge_event[i2].charge_event_mod[d2.seq].field4)), c
      .active_ind = 1,
      c.updt_cnt = 0, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx,
      c.updt_dt_tm = cnvtdatetime(sysdate), c.active_status_cd = 0, c.active_status_dt_tm =
      cnvtdatetime(sysdate),
      c.field1_id =
      IF ((request->charge_event[i2].charge_event_mod[d2.seq].field1=null)) 0
      ELSE cnvtreal(request->charge_event[i2].charge_event_mod[d2.seq].field1)
      ENDIF
      , c.field2_id =
      IF ((request->charge_event[i2].charge_event_mod[d2.seq].field4=null)) 0
      ELSE cnvtreal(request->charge_event[i2].charge_event_mod[d2.seq].field4)
      ENDIF
      , c.field6 = substring(1,200,trim(request->charge_event[i2].charge_event_mod[d2.seq].field6)),
      c.field7 = substring(1,200,trim(request->charge_event[i2].charge_event_mod[d2.seq].field7))
     PLAN (d2
      WHERE (d2.seq <= request->charge_event[i2].charge_event_mod_qual)
       AND (request->charge_event[i2].charge_event_mod[d2.seq].charge_event_mod_type_cd >= 1.0)
       AND (reply->charge_event[i2].charge_event_mod[d2.seq].charge_event_mod_id > 0))
      JOIN (c)
     WITH nocounter
    ;end insert
    SET error_code = error(error_msg,0)
    WHILE (error_code != 0)
      SET error_count += 1
      SET reply->error_qual = error_count
      SET stat = alterlist(reply->error_information,error_count)
      SET reply->error_information[error_count].error_code = error_code
      SET reply->error_information[error_count].error_msg = error_msg
      SET error_code = error(error_msg,0)
    ENDWHILE
    IF (curqual=0)
     CALL echo("oops  charge_event_mod::insert")
     RETURN
    ENDIF
   ENDIF
   CALL echo("END AddChargeEventMod")
 END ;Subroutine
 SUBROUTINE uptchargeevent(i)
   CALL echo("UptChargeEvent")
   UPDATE  FROM charge_event c,
     (dummyt d1  WITH seq = value(request->charge_event_qual))
    SET c.accession =
     IF (trim(request->charge_event[d1.seq].accession,3)="") c.accession
     ELSE substring(1,50,trim(request->charge_event[d1.seq].accession))
     ENDIF
     , c.person_id =
     IF ((request->charge_event[d1.seq].person_id=0)) c.person_id
     ELSE request->charge_event[d1.seq].person_id
     ENDIF
     , c.encntr_id =
     IF ((request->charge_event[d1.seq].encntr_id=0)) c.encntr_id
     ELSE request->charge_event[d1.seq].encntr_id
     ENDIF
     ,
     c.updt_dt_tm = cnvtdatetime(sysdate)
    PLAN (d1
     WHERE (reply->charge_event[d1.seq].updt_ce_ind=1))
     JOIN (c
     WHERE (c.charge_event_id=reply->charge_event[d1.seq].charge_event_id))
    WITH nocounter
   ;end update
   CALL echo("End UptChargeEvent")
 END ;Subroutine
 SUBROUTINE checkdupcollection(dummy)
   CALL echo("CheckDupCollection")
   SELECT INTO "nl:"
    cea.charge_event_act_id
    FROM charge_event_act cea,
     (dummyt d1  WITH seq = value(request->charge_event_qual)),
     (dummyt d2  WITH seq = value(max_act))
    PLAN (d1)
     JOIN (d2
     WHERE (d2.seq <= request->charge_event[d1.seq].charge_event_act_qual)
      AND (request->charge_event[d1.seq].charge_event_act[d2.seq].cea_type_cd IN (code_val->
     13029_collected, code_val->13029_collecting))
      AND (request->charge_event[d1.seq].charge_event_act[d2.seq].charge_type_cd=code_val->
     13028_collection))
     JOIN (cea
     WHERE (cea.charge_event_id=reply->charge_event[d1.seq].charge_event_id)
      AND (cea.charge_event_act_id != reply->charge_event[d1.seq].charge_event_act[d2.seq].
     charge_event_act_id)
      AND (cea.cea_type_cd=request->charge_event[d1.seq].charge_event_act[d2.seq].cea_type_cd)
      AND (cea.charge_type_cd=request->charge_event[d1.seq].charge_event_act[d2.seq].charge_type_cd)
      AND cea.service_dt_tm=cnvtdatetime(request->charge_event[d1.seq].charge_event_act[d2.seq].
      service_dt_tm))
    HEAD cea.charge_event_id
     CALL echo("Collection Duplicate, return -1"), reply->charge_event[d1.seq].charge_event_act[d2
     .seq].charge_event_act_id = - (1)
    WITH nocounter
   ;end select
   CALL echo("END CheckDupCollection")
 END ;Subroutine
 SUBROUTINE logreply(dummyvar)
   CALL echo("***** REPLY *****")
   CALL echo(build("charge_event_qual: ",reply->charge_event_qual))
   SELECT INTO "nl:"
    ce = reply->charge_event[d1.seq].charge_event_id, cea = reply->charge_event[d1.seq].
    charge_event_act[d2.seq].charge_event_act_id, cea_type_cd = reply->charge_event[d1.seq].
    charge_event_act[d2.seq].cea_type_cd,
    sr_cd = reply->charge_event[d1.seq].charge_event_act[d2.seq].service_resource_cd
    FROM (dummyt d1  WITH seq = value(size(reply->charge_event,5))),
     (dummyt d2  WITH seq = value(max_act))
    PLAN (d1)
     JOIN (d2
     WHERE (d2.seq <= reply->charge_event[d1.seq].charge_event_act_qual))
    HEAD ce
     CALL echo(""),
     CALL echo(build("charge_event[",d1.seq,"]")),
     CALL echo(build("    charge_event_id:",ce)),
     CALL echo(build("    updt_ce_ind:",reply->charge_event[d1.seq].updt_ce_ind)),
     CALL echo(build("    charge_event_act_qual:",reply->charge_event[d1.seq].charge_event_act_qual))
    DETAIL
     CALL echo(build("    charge_event_act[",d2.seq,"]")),
     CALL echo(build("        charge_event_act_id:",cea)),
     CALL echo(build("        cea_type_cd:",cea_type_cd,"    ",uar_get_code_display(cea_type_cd))),
     CALL echo(build("        service_resource_cd:",sr_cd))
    WITH nocounter
   ;end select
   CALL echo("")
   CALL echo("***** END REPLY *****")
 END ;Subroutine
#end_program
END GO
