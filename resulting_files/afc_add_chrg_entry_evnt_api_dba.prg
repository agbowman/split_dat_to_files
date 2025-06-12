CREATE PROGRAM afc_add_chrg_entry_evnt_api:dba
 CALL echo(
  "##############################################################################################")
 RECORD reply(
   1 status = i2
   1 error_desc = c200
   1 charge_event_qual = i2
   1 charge_event[*]
     2 charge_event_id = f8
     2 ext_m_event_id = f8
     2 ext_m_event_cd = f8
     2 ext_m_ref_id = f8
     2 ext_m_ref_cd = f8
     2 ext_p_event_id = f8
     2 ext_p_event_cd = f8
     2 ext_p_ref_id = f8
     2 ext_p_ref_cd = f8
     2 ext_i_event_id = f8
     2 ext_i_event_cd = f8
     2 ext_i_ref_id = f8
     2 ext_i_ref_cd = f8
     2 encntr_type_cd = f8
     2 med_service_cd = f8
     2 perf_loc_cd = f8
     2 org_id = f8
     2 fin_class_cd = f8
     2 loc_nurse_unit_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 ord_phys_id = f8
     2 verify_phys_id = f8
     2 activity_type_cd = f8
     2 misc_ind = i2
     2 misc_price = f8
     2 misc_desc = c200
     2 updt_id = f8
     2 charge_event_act_qual = i2
     2 charge_event_act[1]
       3 charge_type_cd = f8
       3 charge_event_act_id = f8
       3 cea_type_cd = f8
       3 serv_dt_tm = dq8
       3 quantity = f8
       3 reason_cd = f8
       3 service_loc_cd = f8
 )
 FREE SET hod_events
 RECORD hold_events(
   1 charge_event_qual = i2
   1 charge_events[*]
     2 charge_event_id = f8
     2 charge_event_ind = i2
     2 charge_ind = i2
     2 charge_event_act_qual = i2
     2 charge_event_acts[*]
       3 charge_event_act_id = f8
     2 charge_event_mod_qual = i2
     2 charge_event_mods[*]
       3 charge_event_mod_id = f8
 )
 DECLARE event_cnt = i2
 DECLARE act_cnt = i2
 DECLARE mod_cnt = i2
 DECLARE reply_cnt = i2
 SUBROUTINE getchargeeventid(dummy1)
   CALL echo("GetChargeEventID - Begin")
   SET hold_events->charge_event_qual = size(request->charge_event,5)
   SET stat = alterlist(hold_events->charge_events,hold_events->charge_event_qual)
   FOR (event_cnt = 1 TO hold_events->charge_event_qual)
     SET hold_events->charge_events[event_cnt].charge_event_id = 0.0
     SET hold_events->charge_events[event_cnt].charge_event_ind = 0
     SET hold_events->charge_events[event_cnt].charge_ind = 0
   ENDFOR
   CALL echo("Check for existing events")
   SELECT INTO "nl:"
    c.charge_event_id
    FROM charge_event c,
     (dummyt d1  WITH seq = value(hold_events->charge_event_qual))
    PLAN (d1
     WHERE (request->charge_event[d1.seq].ext_item_event_id != - (1)))
     JOIN (c
     WHERE (c.ext_m_event_id=request->charge_event[d1.seq].ext_master_event_id)
      AND (c.ext_m_event_cont_cd=request->charge_event[d1.seq].ext_master_event_cont_cd)
      AND (c.ext_m_reference_id=request->charge_event[d1.seq].ext_master_reference_id)
      AND (c.ext_m_reference_cont_cd=request->charge_event[d1.seq].ext_master_reference_cont_cd)
      AND (c.ext_p_event_id=request->charge_event[d1.seq].ext_parent_event_id)
      AND (c.ext_p_event_cont_cd=request->charge_event[d1.seq].ext_parent_event_cont_cd)
      AND (c.ext_p_reference_id=request->charge_event[d1.seq].ext_parent_reference_id)
      AND (c.ext_p_reference_cont_cd=request->charge_event[d1.seq].ext_parent_reference_cont_cd)
      AND (c.ext_i_event_id=request->charge_event[d1.seq].ext_item_event_id)
      AND (c.ext_i_event_cont_cd=request->charge_event[d1.seq].ext_item_event_cont_cd)
      AND (c.ext_i_reference_id=request->charge_event[d1.seq].ext_item_reference_id)
      AND (c.ext_i_reference_cont_cd=request->charge_event[d1.seq].ext_item_reference_cont_cd))
    DETAIL
     CALL echo(build("  Charge Event ID: ",c.charge_event_id)), hold_events->charge_events[d1.seq].
     charge_event_id = c.charge_event_id, hold_events->charge_events[d1.seq].charge_event_ind = 1
    WITH nocounter
   ;end select
   CALL echo("Check for charges on existing events")
   SELECT INTO "nl:"
    c.charge_item_id
    FROM charge c,
     (dummyt d1  WITH seq = value(hold_events->charge_event_qual))
    PLAN (d1
     WHERE (hold_events->charge_events[d1.seq].charge_event_ind=1))
     JOIN (c
     WHERE (c.charge_event_id=hold_events->charge_events[d1.seq].charge_event_id))
    DETAIL
     CALL echo(build("  Charge Event ID: ",c.charge_event_id)), hold_events->charge_events[d1.seq].
     charge_ind = 1
    WITH nocounter
   ;end select
   CALL echo("GetChargeEventID - End")
 END ;Subroutine
 SUBROUTINE addchargeevent(dummy2)
   CALL echo("AddChargeEvent - Begin")
   FOR (event_cnt = 1 TO hold_events->charge_event_qual)
     IF ((hold_events->charge_events[event_cnt].charge_event_ind != 1))
      SELECT INTO "nl:"
       y = seq(charge_event_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        hold_events->charge_events[event_cnt].charge_event_id = cnvtreal(y)
       WITH nocounter
      ;end select
      CALL echo("  Charge Event ID:  ",0)
      CALL echo(hold_events->charge_events[event_cnt].charge_event_id)
      IF (curqual=0)
       CALL echo("Error retrieving next charge_event_seq")
       SET reply->status = 0
       SET reply->error_desc = "AddChargeEvent-Error retreiving next charge_event_seq"
       GO TO end_of_program
      ENDIF
     ENDIF
   ENDFOR
   INSERT  FROM charge_event c,
     (dummyt d1  WITH seq = value(hold_events->charge_event_qual))
    SET c.abn_status_cd = request->charge_event[d1.seq].abn_status_cd, c.accession = substring(1,50,
      trim(request->charge_event[d1.seq].accession)), c.active_ind = 1,
     c.active_status_dt_tm = cnvtdatetime(sysdate), c.bill_item_id = 0, c.cancelled_dt_tm = null,
     c.cancelled_ind = 0, c.charge_event_id = hold_events->charge_events[d1.seq].charge_event_id, c
     .collection_priority_cd = request->charge_event[d1.seq].collection_priority_cd,
     c.contributor_system_cd = request->charge_event[d1.seq].contributor_system_cd, c.encntr_id =
     request->charge_event[d1.seq].encntr_id, c.ext_i_event_cont_cd = request->charge_event[d1.seq].
     ext_item_event_cont_cd,
     c.ext_i_event_id = request->charge_event[d1.seq].ext_item_event_id, c.ext_i_reference_cont_cd =
     request->charge_event[d1.seq].ext_item_reference_cont_cd, c.ext_i_reference_id = request->
     charge_event[d1.seq].ext_item_reference_id,
     c.ext_m_event_cont_cd = request->charge_event[d1.seq].ext_master_event_cont_cd, c.ext_m_event_id
      = request->charge_event[d1.seq].ext_master_event_id, c.ext_m_reference_cont_cd = request->
     charge_event[d1.seq].ext_master_reference_cont_cd,
     c.ext_m_reference_id = request->charge_event[d1.seq].ext_master_reference_id, c
     .ext_p_event_cont_cd = request->charge_event[d1.seq].ext_parent_event_cont_cd, c.ext_p_event_id
      = request->charge_event[d1.seq].ext_parent_event_id,
     c.ext_p_reference_cont_cd = request->charge_event[d1.seq].ext_parent_reference_cont_cd, c
     .ext_p_reference_id = request->charge_event[d1.seq].ext_parent_reference_id, c.m_bill_item_id =
     0,
     c.m_charge_event_id = 0, c.order_id = request->charge_event[d1.seq].order_id, c.perf_loc_cd =
     request->charge_event[d1.seq].perf_loc_cd,
     c.person_id = request->charge_event[d1.seq].person_id, c.p_bill_item_id = 0, c.p_charge_event_id
      = 0,
     c.reference_nbr = substring(1,60,trim(request->charge_event[d1.seq].reference_nbr)), c
     .report_priority_cd = request->charge_event[d1.seq].report_priority_cd, c.research_account_id =
     request->charge_event[d1.seq].research_acct_id,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
     c.updt_id =
     IF (validate(request->charge_event[d1.seq].charge_event_act[1].prsnl[1].prsnl_id,999) != 999)
      request->charge_event[d1.seq].charge_event_act[1].prsnl[1].prsnl_id
     ELSE reqinfo->updt_id
     ENDIF
     , c.updt_task = reqinfo->updt_task
    PLAN (d1
     WHERE (hold_events->charge_events[d1.seq].charge_event_ind != 1))
     JOIN (c)
    WITH nocounter
   ;end insert
   CALL echo("AddChargeEvent - End")
 END ;Subroutine
 SUBROUTINE addchargeeventact(dummy3)
   CALL echo("AddChargeEventAct - Begin")
   FOR (event_cnt = 1 TO hold_events->charge_event_qual)
     IF ((hold_events->charge_events[event_cnt].charge_ind != 1))
      SET hold_events->charge_events[event_cnt].charge_event_act_qual = size(request->charge_event[
       event_cnt].charge_event_act,5)
      SET stat = alterlist(hold_events->charge_events[event_cnt].charge_event_acts,hold_events->
       charge_events[event_cnt].charge_event_act_qual)
      CALL echo("  Charge Event ID:  ",0)
      CALL echo(hold_events->charge_events[event_cnt].charge_event_id)
      FOR (act_cnt = 1 TO hold_events->charge_events[event_cnt].charge_event_act_qual)
        SELECT INTO "nl:"
         y = seq(charge_event_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          hold_events->charge_events[event_cnt].charge_event_acts[act_cnt].charge_event_act_id =
          cnvtreal(y)
         WITH nocounter
        ;end select
        CALL echo("    Charge Event Act ID:  ",0)
        CALL echo(hold_events->charge_events[event_cnt].charge_event_acts[act_cnt].
         charge_event_act_id)
        IF (curqual=0)
         CALL echo("Error retreiving next charge_event_seq")
         SET reply->status = 0
         SET reply->error_desc = "AddChargeEventAct-Error retreiving next charge_event_seq"
         GO TO end_of_program
        ENDIF
      ENDFOR
      INSERT  FROM charge_event_act c,
        (dummyt d2  WITH seq = value(hold_events->charge_events[event_cnt].charge_event_act_qual))
       SET c.seq = 1, c.accession_id = request->charge_event[event_cnt].charge_event_act[d2.seq].
        accession_id, c.active_ind = 1,
        c.alpha_nomen_id = request->charge_event[event_cnt].charge_event_act[d2.seq].alpha_nomen_id,
        c.cea_misc1 = "", c.cea_misc1_id = 0,
        c.cea_misc2 = "", c.cea_misc2_id = 0, c.cea_misc3 = "",
        c.cea_misc3_id = 0, c.cea_misc4_id = 0, c.cea_prsnl_id = request->charge_event[event_cnt].
        charge_event_act[d2.seq].cea_prsnl_id,
        c.cea_type_cd = request->charge_event[event_cnt].charge_event_act[d2.seq].cea_type_cd, c
        .charge_dt_tm =
        IF ((request->charge_event[event_cnt].charge_event_act[d2.seq].charge_dt_tm <= 0)) null
        ELSE cnvtdatetime(request->charge_event[event_cnt].charge_event_act[d2.seq].charge_dt_tm)
        ENDIF
        , c.charge_event_act_id = hold_events->charge_events[event_cnt].charge_event_acts[d2.seq].
        charge_event_act_id,
        c.charge_event_id = hold_events->charge_events[event_cnt].charge_event_id, c.charge_type_cd
         = request->charge_event[event_cnt].charge_event_act[d2.seq].charge_type_cd, c.insert_dt_tm
         = cnvtdatetime(sysdate),
        c.in_lab_dt_tm = null, c.patient_loc_cd = request->charge_event[event_cnt].charge_event_act[
        d2.seq].patient_loc_cd, c.quantity = request->charge_event[event_cnt].charge_event_act[d2.seq
        ].quantity,
        c.reason_cd = request->charge_event[event_cnt].charge_event_act[d2.seq].reason_cd, c
        .reference_range_factor_id = 0, c.repeat_ind = request->charge_event[event_cnt].
        charge_event_act[d2.seq].repeat_ind,
        c.result = substring(1,100,trim(request->charge_event[event_cnt].charge_event_act[d2.seq].
          result)), c.service_dt_tm =
        IF ((request->charge_event[event_cnt].charge_event_act[d2.seq].service_dt_tm <= 0)) null
        ELSE cnvtdatetime(request->charge_event[event_cnt].charge_event_act[d2.seq].service_dt_tm)
        ENDIF
        , c.service_loc_cd = request->charge_event[event_cnt].charge_event_act[d2.seq].service_loc_cd,
        c.service_resource_cd = request->charge_event[event_cnt].charge_event_act[d2.seq].
        service_resource_cd, c.units = request->charge_event[event_cnt].charge_event_act[d2.seq].
        units, c.unit_type_cd = request->charge_event[event_cnt].charge_event_act[d2.seq].
        unit_type_cd,
        c.updt_applctx = reqinfo->updt_applctx, c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(sysdate),
        c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task
       PLAN (d2)
        JOIN (c)
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
   CALL echo("AccChargeEventAct - End")
 END ;Subroutine
 SUBROUTINE addchargeeventmod(dummy4)
   CALL echo("AddChargeEventMod - Begin")
   FOR (event_cnt = 1 TO hold_events->charge_event_qual)
     IF ((hold_events->charge_events[event_cnt].charge_event_ind != 1))
      SET hold_events->charge_events[event_cnt].charge_event_mod_qual = size(request->charge_event[
       event_cnt].charge_event_mod,5)
      SET stat = alterlist(hold_events->charge_events[event_cnt].charge_event_mods,hold_events->
       charge_events[event_cnt].charge_event_mod_qual)
      CALL echo("  Charge Event ID:  ",0)
      CALL echo(hold_events->charge_events[event_cnt].charge_event_id)
      FOR (mod_cnt = 1 TO hold_events->charge_events[event_cnt].charge_event_mod_qual)
        SET hold_events->charge_events[event_cnt].charge_event_mods[mod_cnt].charge_event_mod_id =
        0.0
        SELECT INTO "nl:"
         y = seq(charge_event_seq,nextval)"##################;rp0"
         FROM dual
         DETAIL
          hold_events->charge_events[event_cnt].charge_event_mods[mod_cnt].charge_event_mod_id =
          cnvtreal(y)
         WITH nocounter
        ;end select
        CALL echo("    Charge Event Mod ID:  ",0)
        CALL echo(hold_events->charge_events[event_cnt].charge_event_mods[mod_cnt].
         charge_event_mod_id)
        IF (curqual=0)
         CALL echo("Error retreiving next charge_event_seq")
         SET reply->status = 0
         SET reply->error_desc = "AddChargeEventMod-Error retreiving next charge_event_seq"
         GO TO end_of_program
        ENDIF
      ENDFOR
      IF ((hold_events->charge_events[event_cnt].charge_event_mod_qual > 0))
       INSERT  FROM charge_event_mod c,
         (dummyt d2  WITH seq = value(hold_events->charge_events[event_cnt].charge_event_mod_qual))
        SET c.seq = 1, c.charge_event_mod_id = hold_events->charge_events[event_cnt].
         charge_event_mods[d2.seq].charge_event_mod_id, c.charge_event_id = hold_events->
         charge_events[event_cnt].charge_event_id,
         c.charge_event_mod_type_cd = request->charge_event[event_cnt].charge_event_mod[d2.seq].
         charge_event_mod_type_cd, c.field1 = substring(1,200,trim(request->charge_event[event_cnt].
           charge_event_mod[d2.seq].field1)), c.field2 = substring(1,200,trim(request->charge_event[
           event_cnt].charge_event_mod[d2.seq].field2)),
         c.field3 = substring(1,200,trim(request->charge_event[event_cnt].charge_event_mod[d2.seq].
           field3)), c.field4 = substring(1,200,trim(request->charge_event[event_cnt].
           charge_event_mod[d2.seq].field4)), c.field5 = substring(1,200,trim(request->charge_event[
           event_cnt].charge_event_mod[d2.seq].field5)),
         c.field6 = substring(1,200,trim(request->charge_event[event_cnt].charge_event_mod[d2.seq].
           field6)), c.field7 = substring(1,200,trim(request->charge_event[event_cnt].
           charge_event_mod[d2.seq].field7)), c.field8 = substring(1,200,trim(request->charge_event[
           event_cnt].charge_event_mod[d2.seq].field8)),
         c.field9 = substring(1,200,trim(request->charge_event[event_cnt].charge_event_mod[d2.seq].
           field9)), c.field10 = substring(1,200,trim(request->charge_event[event_cnt].
           charge_event_mod[d2.seq].field10)), c.active_ind = 1,
         c.updt_cnt = 0, c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task,
         c.updt_applctx = reqinfo->updt_applctx, c.updt_dt_tm = cnvtdatetime(sysdate), c
         .active_status_cd = 0,
         c.active_status_dt_tm = cnvtdatetime(sysdate), c.field1_id = request->charge_event[event_cnt
         ].charge_event_mod[d2.seq].field1_id, c.field2_id = request->charge_event[event_cnt].
         charge_event_mod[d2.seq].field2_id,
         c.field3_id = request->charge_event[event_cnt].charge_event_mod[d2.seq].field3_id, c
         .field4_id = request->charge_event[event_cnt].charge_event_mod[d2.seq].field4_id, c
         .field5_id = request->charge_event[event_cnt].charge_event_mod[d2.seq].field5_id,
         c.nomen_id = request->charge_event[event_cnt].charge_event_mod[d2.seq].nomen_id
        PLAN (d2)
         JOIN (c)
        WITH nocounter
       ;end insert
      ENDIF
     ENDIF
   ENDFOR
   CALL echo("AddChargeEventMod - End")
 END ;Subroutine
 SUBROUTINE filloutreply(dummy5)
   CALL echo("FillOutReply - Begin")
   SET reply_cnt = 0
   FOR (event_cnt = 1 TO hold_events->charge_event_qual)
     CALL echo("  Charge Event ID:  ",0)
     CALL echo(hold_events->charge_events[event_cnt].charge_event_id,0)
     CALL echo("  Charge Event IND:  ",0)
     CALL echo(hold_events->charge_events[event_cnt].charge_event_ind,0)
     CALL echo("  Charge IND:  ",0)
     CALL echo(hold_events->charge_events[event_cnt].charge_ind)
     IF ((hold_events->charge_events[event_cnt].charge_ind != 1))
      SET reply_cnt += 1
      SET reply->charge_event_qual = reply_cnt
      SET stat = alterlist(reply->charge_event,reply_cnt)
      SET reply->charge_event[reply_cnt].charge_event_id = hold_events->charge_events[event_cnt].
      charge_event_id
      SET reply->charge_event[reply_cnt].ext_m_event_id = request->charge_event[event_cnt].
      ext_master_event_id
      SET reply->charge_event[reply_cnt].ext_m_event_cd = request->charge_event[event_cnt].
      ext_master_event_cont_cd
      SET reply->charge_event[reply_cnt].ext_m_ref_id = request->charge_event[event_cnt].
      ext_master_reference_id
      SET reply->charge_event[reply_cnt].ext_m_ref_cd = request->charge_event[event_cnt].
      ext_master_reference_cont_cd
      SET reply->charge_event[reply_cnt].ext_p_event_id = request->charge_event[event_cnt].
      ext_parent_event_id
      SET reply->charge_event[reply_cnt].ext_p_event_cd = request->charge_event[event_cnt].
      ext_parent_event_cont_cd
      SET reply->charge_event[reply_cnt].ext_p_ref_id = request->charge_event[event_cnt].
      ext_parent_reference_id
      SET reply->charge_event[reply_cnt].ext_p_ref_cd = request->charge_event[event_cnt].
      ext_parent_reference_cont_cd
      SET reply->charge_event[reply_cnt].ext_i_event_id = request->charge_event[event_cnt].
      ext_item_event_id
      SET reply->charge_event[reply_cnt].ext_i_event_cd = request->charge_event[event_cnt].
      ext_item_event_cont_cd
      SET reply->charge_event[reply_cnt].ext_i_ref_id = request->charge_event[event_cnt].
      ext_item_reference_id
      SET reply->charge_event[reply_cnt].ext_i_ref_cd = request->charge_event[event_cnt].
      ext_item_reference_cont_cd
      SET reply->charge_event[reply_cnt].perf_loc_cd = request->charge_event[event_cnt].perf_loc_cd
      SET reply->charge_event[reply_cnt].person_id = request->charge_event[event_cnt].person_id
      SET reply->charge_event[reply_cnt].encntr_id = request->charge_event[event_cnt].encntr_id
      IF ((request->charge_event[event_cnt].misc_ind=1))
       SET reply->charge_event[reply_cnt].misc_ind = 1
       IF ((request->charge_event[event_cnt].misc_price > 0))
        SET reply->charge_event[reply_cnt].misc_price = request->charge_event[event_cnt].misc_price
       ELSE
        SET reply->charge_event[reply_cnt].misc_price = 0.0
       ENDIF
       SET reply->charge_event[reply_cnt].misc_desc = request->charge_event[event_cnt].misc_desc
      ELSE
       SET reply->charge_event[reply_cnt].misc_ind = 0
       SET reply->charge_event[reply_cnt].misc_price = 0.0
       SET reply->charge_event[reply_cnt].misc_desc = " "
      ENDIF
      IF (validate(request->charge_event[event_cnt].charge_event_act[1].prsnl[1].prsnl_id,999) != 999
      )
       SET reply->charge_event[reply_cnt].updt_id = request->charge_event[event_cnt].
       charge_event_act[1].prsnl[1].prsnl_id
      ELSE
       SET reply->charge_event[reply_cnt].updt_id = 0.0
      ENDIF
      FOR (act_cnt = 1 TO hold_events->charge_events[event_cnt].charge_event_act_qual)
        IF ((request->charge_event[event_cnt].charge_event_act[act_cnt].cea_type_cd=code_val->
        13029_complete))
         SET reply->charge_event[reply_cnt].charge_event_act_qual = 1
         SET reply->charge_event[reply_cnt].charge_event_act[1].charge_type_cd = request->
         charge_event[event_cnt].charge_event_act[act_cnt].charge_type_cd
         SET reply->charge_event[reply_cnt].charge_event_act[1].charge_event_act_id = hold_events->
         charge_events[event_cnt].charge_event_acts[act_cnt].charge_event_act_id
         SET reply->charge_event[reply_cnt].charge_event_act[1].cea_type_cd = request->charge_event[
         event_cnt].charge_event_act[act_cnt].cea_type_cd
         SET reply->charge_event[reply_cnt].charge_event_act[1].serv_dt_tm = request->charge_event[
         event_cnt].charge_event_act[act_cnt].service_dt_tm
         SET reply->charge_event[reply_cnt].charge_event_act[1].quantity = request->charge_event[
         event_cnt].charge_event_act[act_cnt].quantity
         SET reply->charge_event[reply_cnt].charge_event_act[1].reason_cd = request->charge_event[
         event_cnt].charge_event_act[act_cnt].reason_cd
         SET reply->charge_event[reply_cnt].charge_event_act[1].service_loc_cd = request->
         charge_event[event_cnt].charge_event_act[act_cnt].service_loc_cd
        ELSEIF ((request->charge_event[event_cnt].charge_event_act[act_cnt].cea_type_cd=code_val->
        13029_ordering))
         SET reply->charge_event[reply_cnt].ord_phys_id = request->charge_event[event_cnt].
         charge_event_act[act_cnt].cea_prsnl_id
        ELSEIF ((request->charge_event[event_cnt].charge_event_act[act_cnt].cea_type_cd=code_val->
        13029_verifying))
         SET reply->charge_event[reply_cnt].verify_phys_id = request->charge_event[event_cnt].
         charge_event_act[act_cnt].cea_prsnl_id
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   CALL echo("Fill out activity_type_cd")
   SELECT INTO "nl:"
    b.ext_owner_cd
    FROM bill_item b,
     (dummyt d1  WITH seq = value(reply->charge_event_qual))
    PLAN (d1)
     JOIN (b
     WHERE (((reply->charge_event[d1.seq].ext_p_ref_id > 0)
      AND (reply->charge_event[d1.seq].ext_p_ref_cd > 0)
      AND (b.ext_parent_reference_id=reply->charge_event[d1.seq].ext_p_ref_id)
      AND (b.ext_parent_contributor_cd=reply->charge_event[d1.seq].ext_p_ref_cd)
      AND b.ext_child_reference_id=0
      AND b.ext_child_contributor_cd=0) OR ((reply->charge_event[d1.seq].ext_p_ref_id <= 0)
      AND (reply->charge_event[d1.seq].ext_p_ref_cd <= 0)
      AND (b.ext_parent_reference_id=reply->charge_event[d1.seq].ext_i_ref_id)
      AND (b.ext_parent_contributor_cd=reply->charge_event[d1.seq].ext_i_ref_cd)
      AND b.ext_child_reference_id=0
      AND b.ext_child_contributor_cd=0)) )
    DETAIL
     reply->charge_event[d1.seq].activity_type_cd = b.ext_owner_cd
    WITH nocounter
   ;end select
   CALL echo("Fill out encounter information")
   SELECT INTO "nl:"
    e.encntr_type_cd, e.organization_id, e.financial_class_cd,
    e.loc_nurse_unit_cd, e.med_service_cd
    FROM encounter e,
     (dummyt d1  WITH seq = value(reply->charge_event_qual))
    PLAN (d1)
     JOIN (e
     WHERE (e.encntr_id=reply->charge_event[d1.seq].encntr_id))
    DETAIL
     reply->charge_event[d1.seq].encntr_type_cd = e.encntr_type_cd, reply->charge_event[d1.seq].
     med_service_cd = e.med_service_cd, reply->charge_event[d1.seq].org_id = e.organization_id,
     reply->charge_event[d1.seq].fin_class_cd = e.financial_class_cd, reply->charge_event[d1.seq].
     loc_nurse_unit_cd = e.loc_nurse_unit_cd
    WITH nocounter
   ;end select
   CALL echo("FillOutReply - End")
 END ;Subroutine
 CALL echorecord(request)
 CALL echo(build("reqinfo->updt_id          :",reqinfo->updt_id))
 CALL echo(build("reqinfo->updt_applctx     :",reqinfo->updt_applctx))
 CALL echo(build("reqinfo->updt_appid       :",reqinfo->updt_app))
 CALL echo(build("reqinfo->updt_task        :",reqinfo->updt_task))
 CALL echo(build("reqinfo->updt_step        :",reqinfo->updt_req))
 CALL echo(build("reqinfo->updt_position_cd :",reqinfo->position_cd))
 SET reply->status = 1
 IF (size(request->charge_event,5) > 0)
  CALL getchargeeventid("dummy")
  CALL addchargeevent("dummy")
  CALL addchargeeventact("dummy")
  CALL addchargeeventmod("dummy")
  CALL echo("All rows written, committing now")
  COMMIT
  CALL filloutreply("dummy")
 ELSE
  CALL echo("Request is empty")
  SET reply->charge_event_qual = 0
 ENDIF
#end_of_program
 CALL echo(
  "##############################################################################################")
END GO
