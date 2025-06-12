CREATE PROGRAM dcp_add_audit_info:dba
 SET modify = predeclare
 EXECUTE dcp_add_audit_info_req
 DECLARE leventcnt = i4 WITH protect, noconstant(0)
 DECLARE didenterrid = f8 WITH protect, noconstant(0.0)
 DECLARE dalertid = f8 WITH protect, noconstant(0.0)
 DECLARE dmederrid = f8 WITH protect, noconstant(0.0)
 DECLARE lingredcnt = i4 WITH protect, noconstant(0)
 DECLARE lpaterrcnt = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE errorcnt = i4 WITH noconstant(0)
 DECLARE alertcnt = i4 WITH noconstant(0)
 DECLARE alerterrorcnt = i4 WITH noconstant(0)
 DECLARE fields_exist_mae = i2 WITH noconstant(0)
 DECLARE fields_exist_ie = i2 WITH noconstant(0)
 DECLARE fields_exist_maa = i2 WITH noconstant(0)
 DECLARE fields_exist_mame = i2 WITH protect, noconstant(0)
 DECLARE fields_exist_mape = i2 WITH protect, noconstant(0)
 DECLARE needs_verify_flag = i2 WITH protect, noconstant(0)
 DECLARE verification_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE verification_tz = i4 WITH protect, noconstant(0)
 DECLARE verified_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE scheduled_dt_tm = f8 WITH protect, noconstant(0.0)
 DECLARE scheduled_tz = i4 WITH protect, noconstant(0)
 DECLARE dmedadminid = f8 WITH protect, noconstant(0.0)
 DECLARE checkforexistance(null) = null
 DECLARE populatetemplateorderid(orderid=f8,scheduled_dt_tm=f8(ref),scheduled_tz=i4(ref)) = f8
 DECLARE populateverifydata(templateorderid=f8,actionseq=i4,needs_verify_flag=i2(ref),
  verification_dt_tm=f8(ref),verification_tz=i4(ref),
  verified_prsnl_id=f8(ref)) = null
 DECLARE populatescheduleddttm(orderid=f8,scheduled_dt_tm=f8(ref),scheduled_tz=i4(ref)) = null
 CALL checkforexistance(null)
 SET leventcnt = size(request->admin_events,5)
 IF (leventcnt > 0)
  IF (fields_exist_mae=1)
   FOR (ordcnt = 1 TO leventcnt)
     SET needs_verify_flag = 0.0
     SET verification_dt_tm = 0.0
     SET verification_tz = 0.0
     SET verified_prsnl_id = 0.0
     SET dmedadminid = 0.0
     IF ((request->admin_events[ordcnt].template_order_id > 0.0))
      CALL populatetemplateorderid(request->admin_events[ordcnt].order_id,scheduled_dt_tm,
       scheduled_tz)
     ELSE
      SET request->admin_events[ordcnt].template_order_id = populatetemplateorderid(request->
       admin_events[ordcnt].order_id,scheduled_dt_tm,scheduled_tz)
     ENDIF
     CALL populateverifydata(request->admin_events[ordcnt].template_order_id,request->admin_events[
      ordcnt].documented_action_seq,needs_verify_flag,verification_dt_tm,verification_tz,
      verified_prsnl_id)
     SET request->admin_events[ordcnt].needs_verify_flag = needs_verify_flag
     SET request->admin_events[ordcnt].verification_dt_tm = verification_dt_tm
     SET request->admin_events[ordcnt].verification_tz = verification_tz
     SET request->admin_events[ordcnt].verified_prsnl_id = verified_prsnl_id
     IF ((request->admin_events[ordcnt].scheduled_dt_tm=0.0))
      SET request->admin_events[ordcnt].scheduled_dt_tm = scheduled_dt_tm
      SET request->admin_events[ordcnt].scheduled_tz = scheduled_tz
     ENDIF
   ENDFOR
   FOR (x = 1 TO leventcnt)
     SELECT INTO "nl:"
      num = seq(medadmin_seq,nextval)
      FROM dual
      DETAIL
       dmedadminid = num
      WITH nocounter
     ;end select
     INSERT  FROM med_admin_event mae
      SET mae.med_admin_event_id = dmedadminid, mae.source_application_flag = request->admin_events[x
       ].source_application_flag, mae.event_type_cd = request->admin_events[x].event_type_cd,
       mae.event_id = request->admin_events[x].event_id, mae.order_id = request->admin_events[x].
       order_id, mae.documentation_action_sequence = request->admin_events[x].documented_action_seq,
       mae.positive_patient_ident_ind = request->admin_events[x].positive_pt_identification, mae
       .positive_med_ident_ind = request->admin_events[x].positive_med_identification, mae
       .order_result_variance_ind = request->admin_events[x].order_result_variance,
       mae.clinical_warning_cnt = request->admin_events[x].clinical_warning_cnt, mae.prsnl_id =
       request->admin_events[x].prsnl_id, mae.position_cd = request->admin_events[x].position_cd,
       mae.nurse_unit_cd = request->admin_events[x].nurse_unit_cd, mae.beg_dt_tm = cnvtdatetime(
        request->admin_events[x].event_dt_tm), mae.end_dt_tm = cnvtdatetime(request->admin_events[x].
        event_dt_tm),
       mae.template_order_id = request->admin_events[x].template_order_id, mae.needs_verify_flag =
       request->admin_events[x].needs_verify_flag, mae.verification_dt_tm = cnvtdatetime(request->
        admin_events[x].verification_dt_tm),
       mae.verification_tz = request->admin_events[x].verification_tz, mae.verified_prsnl_id =
       request->admin_events[x].verified_prsnl_id, mae.scheduled_dt_tm = cnvtdatetime(request->
        admin_events[x].scheduled_dt_tm),
       mae.scheduled_tz = request->admin_events[x].scheduled_tz, mae.careaware_used_ind = request->
       admin_events[x].careaware_used_ind, mae.critical_drug_ind = 0,
       mae.event_cnt = 1, mae.updt_id = reqinfo->updt_id, mae.updt_task = reqinfo->updt_task,
       mae.updt_applctx = reqinfo->updt_applctx, mae.updt_cnt = 0, mae.updt_dt_tm = cnvtdatetime(
        curdate,curtime3)
      WITH nocounter
     ;end insert
     SET alertcnt = size(request->admin_events[x].med_admin_alerts,5)
     IF (curqual=1
      AND alertcnt > 0)
      FOR (z = 1 TO alertcnt)
        SELECT INTO "nl:"
         num = seq(medadmin_seq,nextval)
         FROM dual
         DETAIL
          dalertid = num
         WITH nocounter
        ;end select
        IF (fields_exist_maa=1)
         INSERT  FROM med_admin_alert maa
          SET maa.med_admin_alert_id = dalertid, maa.med_admin_event_id = dmedadminid, maa
           .source_application_flag = request->admin_events[x].med_admin_alerts[z].
           source_application_flag,
           maa.careaware_used_ind = request->admin_events[x].med_admin_alerts[z].careaware_used_ind,
           maa.alert_type_cd = request->admin_events[x].med_admin_alerts[z].alert_type_cd, maa
           .alert_severity_cd = request->admin_events[x].med_admin_alerts[z].alert_severity_cd,
           maa.prsnl_id = request->admin_events[x].med_admin_alerts[z].prsnl_id, maa.position_cd =
           request->admin_events[x].med_admin_alerts[z].position_cd, maa.nurse_unit_cd = request->
           admin_events[x].med_admin_alerts[z].nurse_unit_cd,
           maa.event_dt_tm = cnvtdatetime(request->admin_events[x].med_admin_alerts[z].event_dt_tm),
           maa.next_calc_dt_tm = cnvtdatetime(request->admin_events[x].med_admin_alerts[z].
            next_calc_dt_tm), maa.updt_id = reqinfo->updt_id,
           maa.updt_task = reqinfo->updt_task, maa.updt_applctx = reqinfo->updt_applctx, maa.updt_cnt
            = 0,
           maa.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WITH nocounter
         ;end insert
        ELSE
         INSERT  FROM med_admin_alert maa
          SET maa.med_admin_alert_id = dalertid, maa.alert_type_cd = request->admin_events[x].
           med_admin_alerts[z].alert_type_cd, maa.alert_severity_cd = request->admin_events[x].
           med_admin_alerts[z].alert_severity_cd,
           maa.prsnl_id = request->admin_events[x].med_admin_alerts[z].prsnl_id, maa.position_cd =
           request->admin_events[x].med_admin_alerts[z].position_cd, maa.nurse_unit_cd = request->
           admin_events[x].med_admin_alerts[z].nurse_unit_cd,
           maa.event_dt_tm = cnvtdatetime(request->admin_events[x].med_admin_alerts[z].event_dt_tm),
           maa.next_calc_dt_tm = cnvtdatetime(request->admin_events[x].med_admin_alerts[z].
            next_calc_dt_tm), maa.updt_id = reqinfo->updt_id,
           maa.updt_task = reqinfo->updt_task, maa.updt_applctx = reqinfo->updt_applctx, maa.updt_cnt
            = 0,
           maa.updt_dt_tm = cnvtdatetime(curdate,curtime3)
          WITH nocounter
         ;end insert
        ENDIF
        IF (curqual=1)
         SET lpaterrcnt = size(request->admin_events[x].med_admin_alerts[z].med_admin_pt_error,5)
         IF (lpaterrcnt > 0)
          INSERT  FROM med_admin_pt_error pe,
            (dummyt d1  WITH seq = value(lpaterrcnt))
           SET pe.med_admin_pt_error_id = seq(medadmin_seq,nextval), pe.med_admin_alert_id = dalertid,
            pe.expected_pt_id = request->admin_events[x].med_admin_alerts[z].med_admin_pt_error[d1
            .seq].expected_pt_id,
            pe.identified_pt_id = request->admin_events[x].med_admin_alerts[z].med_admin_pt_error[d1
            .seq].identified_pt_id, pe.bar_code_ident = request->admin_events[x].med_admin_alerts[z].
            med_admin_pt_error[d1.seq].identifier, pe.reason_cd = request->admin_events[x].
            med_admin_alerts[z].med_admin_pt_error[d1.seq].reason_cd,
            pe.freetext_reason = request->admin_events[x].med_admin_alerts[z].med_admin_pt_error[d1
            .seq].freetext_reason, pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task,
            pe.updt_applctx = reqinfo->updt_applctx, pe.updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(
             curdate,curtime3)
           PLAN (d1)
            JOIN (pe)
           WITH nocounter
          ;end insert
         ENDIF
         SET alerterrorcnt = size(request->admin_events[x].med_admin_alerts[z].med_admin_med_error,5)
         FOR (y = 1 TO alerterrorcnt)
           SELECT INTO "nl:"
            num = seq(medadmin_seq,nextval)
            FROM dual
            DETAIL
             dmederrid = num
            WITH nocounter
           ;end select
           IF (fields_exist_mame=1)
            IF ((request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
            template_order_id > 0.0))
             CALL populatetemplateorderid(request->admin_events[x].med_admin_alerts[z].
              med_admin_med_error[y].order_id,scheduled_dt_tm,scheduled_tz)
            ELSE
             SET request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
             template_order_id = populatetemplateorderid(request->admin_events[x].med_admin_alerts[z]
              .med_admin_med_error[y].order_id,scheduled_dt_tm,scheduled_tz)
            ENDIF
            SET needs_verify_flag = 0.0
            SET verification_dt_tm = 0.0
            SET verification_tz = 0.0
            SET verified_prsnl_id = 0.0
            CALL populateverifydata(request->admin_events[x].med_admin_alerts[z].med_admin_med_error[
             y].template_order_id,request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y]
             .action_sequence,needs_verify_flag,verification_dt_tm,verification_tz,
             verified_prsnl_id)
            SET request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
            verification_dt_tm = verification_dt_tm
            SET request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].verification_tz
             = verification_tz
            SET request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].verified_prsnl_id
             = verified_prsnl_id
            SET request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].needs_verify_flag
             = needs_verify_flag
            INSERT  FROM med_admin_med_error me
             SET me.med_admin_med_error_id = dmederrid, me.med_admin_alert_id = dalertid, me
              .person_id = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
              person_id,
              me.encounter_id = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
              encounter_id, me.order_id = request->admin_events[x].med_admin_alerts[z].
              med_admin_med_error[y].order_id, me.event_id = request->admin_events[x].
              med_admin_alerts[z].med_admin_med_error[y].event_id,
              me.action_sequence = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y
              ].action_sequence, me.admin_route_cd = request->admin_events[x].med_admin_alerts[z].
              med_admin_med_error[y].admin_route_cd, me.updt_id = reqinfo->updt_id,
              me.updt_task = reqinfo->updt_task, me.updt_applctx = reqinfo->updt_applctx, me.updt_cnt
               = 0,
              me.updt_dt_tm = cnvtdatetime(curdate,curtime3), me.scheduled_dt_tm = cnvtdatetime(
               request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].scheduled_dt_tm),
              me.scheduled_tz = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
              scheduled_tz,
              me.admin_dt_tm = cnvtdatetime(request->admin_events[x].med_admin_alerts[z].
               med_admin_med_error[y].admin_dt_tm), me.admin_tz = request->admin_events[x].
              med_admin_alerts[z].med_admin_med_error[y].admin_tz, me.reason_cd = request->
              admin_events[x].med_admin_alerts[z].med_admin_med_error[y].reason_cd,
              me.freetext_reason = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y
              ].freetext_reason, me.template_order_id = request->admin_events[x].med_admin_alerts[z].
              med_admin_med_error[y].template_order_id, me.needs_verify_flag = request->admin_events[
              x].med_admin_alerts[z].med_admin_med_error[y].needs_verify_flag,
              me.verification_dt_tm = cnvtdatetime(request->admin_events[x].med_admin_alerts[z].
               med_admin_med_error[y].verification_dt_tm), me.verification_tz = request->
              admin_events[x].med_admin_alerts[z].med_admin_med_error[y].verification_tz, me
              .verified_prsnl_id = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y
              ].verified_prsnl_id,
              me.critical_drug_ind = 0
             WITH nocounter
            ;end insert
           ELSE
            INSERT  FROM med_admin_med_error me
             SET me.med_admin_med_error_id = dmederrid, me.med_admin_alert_id = dalertid, me
              .person_id = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
              person_id,
              me.encounter_id = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
              encounter_id, me.order_id = request->admin_events[x].med_admin_alerts[z].
              med_admin_med_error[y].order_id, me.event_id = request->admin_events[x].
              med_admin_alerts[z].med_admin_med_error[y].event_id,
              me.action_sequence = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y
              ].action_sequence, me.admin_route_cd = request->admin_events[x].med_admin_alerts[z].
              med_admin_med_error[y].admin_route_cd, me.updt_id = reqinfo->updt_id,
              me.updt_task = reqinfo->updt_task, me.updt_applctx = reqinfo->updt_applctx, me.updt_cnt
               = 0,
              me.updt_dt_tm = cnvtdatetime(curdate,curtime3), me.scheduled_dt_tm = cnvtdatetime(
               request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].scheduled_dt_tm),
              me.scheduled_tz = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
              scheduled_tz,
              me.admin_dt_tm = cnvtdatetime(request->admin_events[x].med_admin_alerts[z].
               med_admin_med_error[y].admin_dt_tm), me.admin_tz = request->admin_events[x].
              med_admin_alerts[z].med_admin_med_error[y].admin_tz, me.reason_cd = request->
              admin_events[x].med_admin_alerts[z].med_admin_med_error[y].reason_cd,
              me.freetext_reason = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y
              ].freetext_reason, me.critical_drug_ind = 0
             WITH nocounter
            ;end insert
           ENDIF
           SET lingredcnt = size(request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
            med_event_ingreds,5)
           IF (curqual=1
            AND lingredcnt > 0)
            INSERT  FROM med_admin_med_event_ingrdnt mei,
              (dummyt d2  WITH seq = value(lingredcnt))
             SET mei.med_event_ingredient_id = seq(medadmin_seq,nextval), mei.catalog_cd = request->
              admin_events[x].med_admin_alerts[z].med_admin_med_error[y].med_event_ingreds[d2.seq].
              catalog_cd, mei.synonym_id = request->admin_events[x].med_admin_alerts[z].
              med_admin_med_error[y].med_event_ingreds[d2.seq].synonym_id,
              mei.strength = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
              med_event_ingreds[d2.seq].strength, mei.strength_unit_cd = request->admin_events[x].
              med_admin_alerts[z].med_admin_med_error[y].med_event_ingreds[d2.seq].strength_unit_cd,
              mei.volume = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y].
              med_event_ingreds[d2.seq].volume,
              mei.volume_unit_cd = request->admin_events[x].med_admin_alerts[z].med_admin_med_error[y
              ].med_event_ingreds[d2.seq].volume_unit_cd, mei.drug_form_cd = request->admin_events[x]
              .med_admin_alerts[z].med_admin_med_error[y].med_event_ingreds[d2.seq].drug_form_cd, mei
              .identification_process_cd = request->admin_events[x].med_admin_alerts[z].
              med_admin_med_error[y].med_event_ingreds[d2.seq].identification_process_cd,
              mei.parent_entity_id = dmederrid, mei.parent_entity_name = "MED_ADMIN_MED_ERROR", mei
              .updt_id = reqinfo->updt_id,
              mei.updt_task = reqinfo->updt_task, mei.updt_applctx = reqinfo->updt_applctx, mei
              .updt_cnt = 0,
              mei.updt_dt_tm = cnvtdatetime(curdate,curtime3)
             PLAN (d2)
              JOIN (mei)
             WITH nocounter
            ;end insert
           ENDIF
         ENDFOR
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ELSE
   INSERT  FROM med_admin_event mae,
     (dummyt d  WITH seq = value(leventcnt))
    SET mae.med_admin_event_id = seq(medadmin_seq,nextval), mae.event_id = request->admin_events[d
     .seq].event_id, mae.order_id = request->admin_events[d.seq].order_id,
     mae.documentation_action_sequence = request->admin_events[d.seq].documented_action_seq, mae
     .positive_patient_ident_ind = request->admin_events[d.seq].positive_pt_identification, mae
     .positive_med_ident_ind = request->admin_events[d.seq].positive_med_identification,
     mae.order_result_variance_ind = request->admin_events[d.seq].order_result_variance, mae
     .clinical_warning_cnt = request->admin_events[d.seq].clinical_warning_cnt, mae.prsnl_id =
     request->admin_events[d.seq].prsnl_id,
     mae.position_cd = request->admin_events[d.seq].position_cd, mae.nurse_unit_cd = request->
     admin_events[d.seq].nurse_unit_cd, mae.beg_dt_tm = cnvtdatetime(request->admin_events[d.seq].
      event_dt_tm),
     mae.end_dt_tm = cnvtdatetime(request->admin_events[d.seq].event_dt_tm), mae.event_cnt = 1, mae
     .updt_id = reqinfo->updt_id,
     mae.updt_task = reqinfo->updt_task, mae.updt_applctx = reqinfo->updt_applctx, mae.updt_cnt = 0,
     mae.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    PLAN (d)
     JOIN (mae)
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 SET errorcnt = size(request->identification_errors,5)
 FOR (x = 1 TO errorcnt)
   SELECT INTO "nl:"
    num = seq(medadmin_seq,nextval)
    FROM dual
    DETAIL
     didenterrid = num
    WITH nocounter
   ;end select
   IF (fields_exist_ie=1)
    INSERT  FROM med_admin_ident_error ie
     SET ie.med_admin_ident_error_id = didenterrid, ie.source_application_flag = request->
      identification_errors[x].source_application_flag, ie.careaware_used_ind = request->
      identification_errors[x].careaware_used_ind,
      ie.alert_type_cd = request->identification_errors[x].alert_type_cd, ie.bar_code_ident = request
      ->identification_errors[x].identifier, ie.event_dt_tm = cnvtdatetime(request->
       identification_errors[x].event_dt_tm),
      ie.prsnl_id = request->identification_errors[x].prsnl_id, ie.nurse_unit_cd = request->
      identification_errors[x].nurse_unit_cd, ie.updt_id = reqinfo->updt_id,
      ie.updt_task = reqinfo->updt_task, ie.updt_applctx = reqinfo->updt_applctx, ie.updt_cnt = 0,
      ie.updt_dt_tm = cnvtdatetime(curdate,curtime3), ie.encntr_id = request->identification_errors[x
      ].encntr_id
     WITH nocounter
    ;end insert
   ELSE
    INSERT  FROM med_admin_ident_error ie
     SET ie.med_admin_ident_error_id = didenterrid, ie.alert_type_cd = request->
      identification_errors[x].alert_type_cd, ie.bar_code_ident = request->identification_errors[x].
      identifier,
      ie.event_dt_tm = cnvtdatetime(request->identification_errors[x].event_dt_tm), ie.prsnl_id =
      request->identification_errors[x].prsnl_id, ie.nurse_unit_cd = request->identification_errors[x
      ].nurse_unit_cd,
      ie.updt_id = reqinfo->updt_id, ie.updt_task = reqinfo->updt_task, ie.updt_applctx = reqinfo->
      updt_applctx,
      ie.updt_cnt = 0, ie.updt_dt_tm = cnvtdatetime(curdate,curtime3), ie.encntr_id = request->
      identification_errors[x].encntr_id
     WITH nocounter
    ;end insert
   ENDIF
   SET lingredcnt = size(request->identification_errors[x].med_event_ingreds,5)
   IF (curqual=1
    AND lingredcnt > 0)
    INSERT  FROM med_admin_med_event_ingrdnt mei,
      (dummyt d  WITH seq = value(lingredcnt))
     SET mei.med_event_ingredient_id = seq(medadmin_seq,nextval), mei.catalog_cd = request->
      identification_errors[x].med_event_ingreds[d.seq].catalog_cd, mei.synonym_id = request->
      identification_errors[x].med_event_ingreds[d.seq].synonym_id,
      mei.strength = request->identification_errors[x].med_event_ingreds[d.seq].strength, mei
      .strength_unit_cd = request->identification_errors[x].med_event_ingreds[d.seq].strength_unit_cd,
      mei.volume = request->identification_errors[x].med_event_ingreds[d.seq].volume,
      mei.volume_unit_cd = request->identification_errors[x].med_event_ingreds[d.seq].volume_unit_cd,
      mei.drug_form_cd = request->identification_errors[x].med_event_ingreds[d.seq].drug_form_cd, mei
      .identification_process_cd = request->identification_errors[x].med_event_ingreds[d.seq].
      identification_process_cd,
      mei.parent_entity_id = didenterrid, mei.parent_entity_name = "MED_ADMIN_IDENT_ERROR", mei
      .updt_id = reqinfo->updt_id,
      mei.updt_task = reqinfo->updt_task, mei.updt_applctx = reqinfo->updt_applctx, mei.updt_cnt = 0,
      mei.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (d)
      JOIN (mei)
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 SET alertcnt = size(request->med_admin_alerts,5)
 FOR (x = 1 TO alertcnt)
   SELECT INTO "nl:"
    num = seq(medadmin_seq,nextval)
    FROM dual
    DETAIL
     dalertid = num
    WITH nocounter
   ;end select
   IF (fields_exist_maa=1)
    INSERT  FROM med_admin_alert maa
     SET maa.med_admin_alert_id = dalertid, maa.med_admin_event_id = 0.00, maa
      .source_application_flag = request->med_admin_alerts[x].source_application_flag,
      maa.careaware_used_ind = request->med_admin_alerts[x].careaware_used_ind, maa.alert_type_cd =
      request->med_admin_alerts[x].alert_type_cd, maa.alert_severity_cd = request->med_admin_alerts[x
      ].alert_severity_cd,
      maa.prsnl_id = request->med_admin_alerts[x].prsnl_id, maa.position_cd = request->
      med_admin_alerts[x].position_cd, maa.nurse_unit_cd = request->med_admin_alerts[x].nurse_unit_cd,
      maa.event_dt_tm = cnvtdatetime(request->med_admin_alerts[x].event_dt_tm), maa.next_calc_dt_tm
       = cnvtdatetime(request->med_admin_alerts[x].next_calc_dt_tm), maa.updt_id = reqinfo->updt_id,
      maa.updt_task = reqinfo->updt_task, maa.updt_applctx = reqinfo->updt_applctx, maa.updt_cnt = 0,
      maa.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ELSE
    INSERT  FROM med_admin_alert maa
     SET maa.med_admin_alert_id = dalertid, maa.alert_type_cd = request->med_admin_alerts[x].
      alert_type_cd, maa.alert_severity_cd = request->med_admin_alerts[x].alert_severity_cd,
      maa.prsnl_id = request->med_admin_alerts[x].prsnl_id, maa.position_cd = request->
      med_admin_alerts[x].position_cd, maa.nurse_unit_cd = request->med_admin_alerts[x].nurse_unit_cd,
      maa.event_dt_tm = cnvtdatetime(request->med_admin_alerts[x].event_dt_tm), maa.next_calc_dt_tm
       = cnvtdatetime(request->med_admin_alerts[x].next_calc_dt_tm), maa.updt_id = reqinfo->updt_id,
      maa.updt_task = reqinfo->updt_task, maa.updt_applctx = reqinfo->updt_applctx, maa.updt_cnt = 0,
      maa.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual=1)
    SET lpaterrcnt = size(request->med_admin_alerts[x].med_admin_pt_error,5)
    IF (lpaterrcnt > 0)
     INSERT  FROM med_admin_pt_error pe,
       (dummyt d  WITH seq = value(lpaterrcnt))
      SET pe.med_admin_pt_error_id = seq(medadmin_seq,nextval), pe.med_admin_alert_id = dalertid, pe
       .expected_pt_id = request->med_admin_alerts[x].med_admin_pt_error[d.seq].expected_pt_id,
       pe.identified_pt_id = request->med_admin_alerts[x].med_admin_pt_error[d.seq].identified_pt_id,
       pe.bar_code_ident = request->med_admin_alerts[x].med_admin_pt_error[d.seq].identifier, pe
       .reason_cd = request->med_admin_alerts[x].med_admin_pt_error[d.seq].reason_cd,
       pe.freetext_reason = request->med_admin_alerts[x].med_admin_pt_error[d.seq].freetext_reason,
       pe.updt_id = reqinfo->updt_id, pe.updt_task = reqinfo->updt_task,
       pe.updt_applctx = reqinfo->updt_applctx, pe.updt_cnt = 0, pe.updt_dt_tm = cnvtdatetime(curdate,
        curtime3)
      PLAN (d)
       JOIN (pe)
      WITH nocounter
     ;end insert
    ENDIF
    SET alerterrorcnt = size(request->med_admin_alerts[x].med_admin_med_error,5)
    FOR (y = 1 TO alerterrorcnt)
      SELECT INTO "nl:"
       num = seq(medadmin_seq,nextval)
       FROM dual
       DETAIL
        dmederrid = num
       WITH nocounter
      ;end select
      IF (fields_exist_mame=1)
       IF ((request->med_admin_alerts[x].med_admin_med_error[y].template_order_id > 0.0))
        CALL populatetemplateorderid(request->med_admin_alerts[x].med_admin_med_error[y].order_id,
         scheduled_dt_tm,scheduled_tz)
       ELSE
        SET request->med_admin_alerts[x].med_admin_med_error[y].template_order_id =
        populatetemplateorderid(request->med_admin_alerts[x].med_admin_med_error[y].order_id,
         scheduled_dt_tm,scheduled_tz)
       ENDIF
       SET needs_verify_flag = 0.0
       SET verification_dt_tm = 0.0
       SET verification_tz = 0.0
       SET verified_prsnl_id = 0.0
       CALL populateverifydata(request->med_admin_alerts[x].med_admin_med_error[y].template_order_id,
        request->med_admin_alerts[x].med_admin_med_error[y].action_sequence,needs_verify_flag,
        verification_dt_tm,verification_tz,
        verified_prsnl_id)
       SET request->med_admin_alerts[x].med_admin_med_error[y].verification_dt_tm =
       verification_dt_tm
       SET request->med_admin_alerts[x].med_admin_med_error[y].verification_tz = verification_tz
       SET request->med_admin_alerts[x].med_admin_med_error[y].verified_prsnl_id = verified_prsnl_id
       SET request->med_admin_alerts[x].med_admin_med_error[y].needs_verify_flag = needs_verify_flag
       INSERT  FROM med_admin_med_error me
        SET me.med_admin_med_error_id = dmederrid, me.med_admin_alert_id = dalertid, me.person_id =
         request->med_admin_alerts[x].med_admin_med_error[y].person_id,
         me.encounter_id = request->med_admin_alerts[x].med_admin_med_error[y].encounter_id, me
         .order_id = request->med_admin_alerts[x].med_admin_med_error[y].order_id, me.event_id =
         request->med_admin_alerts[x].med_admin_med_error[y].event_id,
         me.action_sequence = request->med_admin_alerts[x].med_admin_med_error[y].action_sequence, me
         .admin_route_cd = request->med_admin_alerts[x].med_admin_med_error[y].admin_route_cd, me
         .updt_id = reqinfo->updt_id,
         me.updt_task = reqinfo->updt_task, me.updt_applctx = reqinfo->updt_applctx, me.updt_cnt = 0,
         me.updt_dt_tm = cnvtdatetime(curdate,curtime3), me.scheduled_dt_tm = cnvtdatetime(request->
          med_admin_alerts[x].med_admin_med_error[y].scheduled_dt_tm), me.scheduled_tz = request->
         med_admin_alerts[x].med_admin_med_error[y].scheduled_tz,
         me.admin_dt_tm = cnvtdatetime(request->med_admin_alerts[x].med_admin_med_error[y].
          admin_dt_tm), me.admin_tz = request->med_admin_alerts[x].med_admin_med_error[y].admin_tz,
         me.reason_cd = request->med_admin_alerts[x].med_admin_med_error[y].reason_cd,
         me.freetext_reason = request->med_admin_alerts[x].med_admin_med_error[y].freetext_reason, me
         .template_order_id = request->med_admin_alerts[x].med_admin_med_error[y].template_order_id,
         me.needs_verify_flag = request->med_admin_alerts[x].med_admin_med_error[y].needs_verify_flag,
         me.verification_dt_tm = cnvtdatetime(request->med_admin_alerts[x].med_admin_med_error[y].
          verification_dt_tm), me.verification_tz = request->med_admin_alerts[x].med_admin_med_error[
         y].verification_tz, me.verified_prsnl_id = request->med_admin_alerts[x].med_admin_med_error[
         y].verified_prsnl_id,
         me.critical_drug_ind = 0
        WITH nocounter
       ;end insert
      ELSE
       INSERT  FROM med_admin_med_error me
        SET me.med_admin_med_error_id = dmederrid, me.med_admin_alert_id = dalertid, me.person_id =
         request->med_admin_alerts[x].med_admin_med_error[y].person_id,
         me.encounter_id = request->med_admin_alerts[x].med_admin_med_error[y].encounter_id, me
         .order_id = request->med_admin_alerts[x].med_admin_med_error[y].order_id, me.event_id =
         request->med_admin_alerts[x].med_admin_med_error[y].event_id,
         me.action_sequence = request->med_admin_alerts[x].med_admin_med_error[y].action_sequence, me
         .admin_route_cd = request->med_admin_alerts[x].med_admin_med_error[y].admin_route_cd, me
         .updt_id = reqinfo->updt_id,
         me.updt_task = reqinfo->updt_task, me.updt_applctx = reqinfo->updt_applctx, me.updt_cnt = 0,
         me.updt_dt_tm = cnvtdatetime(curdate,curtime3), me.scheduled_dt_tm = cnvtdatetime(request->
          med_admin_alerts[x].med_admin_med_error[y].scheduled_dt_tm), me.scheduled_tz = request->
         med_admin_alerts[x].med_admin_med_error[y].scheduled_tz,
         me.admin_dt_tm = cnvtdatetime(request->med_admin_alerts[x].med_admin_med_error[y].
          admin_dt_tm), me.admin_tz = request->med_admin_alerts[x].med_admin_med_error[y].admin_tz,
         me.reason_cd = request->med_admin_alerts[x].med_admin_med_error[y].reason_cd,
         me.freetext_reason = request->med_admin_alerts[x].med_admin_med_error[y].freetext_reason, me
         .critical_drug_ind = 0
        WITH nocounter
       ;end insert
      ENDIF
      SET lingredcnt = size(request->med_admin_alerts[x].med_admin_med_error[y].med_event_ingreds,5)
      IF (curqual=1
       AND lingredcnt > 0)
       INSERT  FROM med_admin_med_event_ingrdnt mei,
         (dummyt d  WITH seq = value(lingredcnt))
        SET mei.med_event_ingredient_id = seq(medadmin_seq,nextval), mei.catalog_cd = request->
         med_admin_alerts[x].med_admin_med_error[y].med_event_ingreds[d.seq].catalog_cd, mei
         .synonym_id = request->med_admin_alerts[x].med_admin_med_error[y].med_event_ingreds[d.seq].
         synonym_id,
         mei.strength = request->med_admin_alerts[x].med_admin_med_error[y].med_event_ingreds[d.seq].
         strength, mei.strength_unit_cd = request->med_admin_alerts[x].med_admin_med_error[y].
         med_event_ingreds[d.seq].strength_unit_cd, mei.volume = request->med_admin_alerts[x].
         med_admin_med_error[y].med_event_ingreds[d.seq].volume,
         mei.volume_unit_cd = request->med_admin_alerts[x].med_admin_med_error[y].med_event_ingreds[d
         .seq].volume_unit_cd, mei.drug_form_cd = request->med_admin_alerts[x].med_admin_med_error[y]
         .med_event_ingreds[d.seq].drug_form_cd, mei.identification_process_cd = request->
         med_admin_alerts[x].med_admin_med_error[y].med_event_ingreds[d.seq].
         identification_process_cd,
         mei.parent_entity_id = dmederrid, mei.parent_entity_name = "MED_ADMIN_MED_ERROR", mei
         .updt_id = reqinfo->updt_id,
         mei.updt_task = reqinfo->updt_task, mei.updt_applctx = reqinfo->updt_applctx, mei.updt_cnt
          = 0,
         mei.updt_dt_tm = cnvtdatetime(curdate,curtime3)
        PLAN (d)
         JOIN (mei)
        WITH nocounter
       ;end insert
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SUBROUTINE checkforexistance(null)
   RANGE OF mae IS med_admin_event
   RANGE OF ie IS med_admin_ident_error
   RANGE OF maa IS med_admin_alert
   RANGE OF mame IS med_admin_med_error
   RANGE OF mape IS med_admin_pt_error
   IF (validate(mae.source_application_flag)
    AND validate(mae.event_type_cd)
    AND validate(mae.template_order_id)
    AND validate(mae.verification_dt_tm)
    AND validate(mae.verification_tz)
    AND validate(mae.verified_prsnl_id)
    AND validate(mae.needs_verify_flag)
    AND validate(mae.scheduled_dt_tm)
    AND validate(mae.scheduled_tz)
    AND validate(mae.careaware_used_ind))
    SET fields_exist_mae = 1
   ENDIF
   IF (validate(ie.source_application_flag)
    AND validate(ie.careaware_used_ind))
    SET fields_exist_ie = 1
   ENDIF
   IF (validate(maa.source_application_flag)
    AND validate(maa.careaware_used_ind)
    AND validate(maa.med_admin_event_id))
    SET fields_exist_maa = 1
   ENDIF
   IF (validate(mame.template_order_id)
    AND validate(mame.verification_dt_tm)
    AND validate(mame.verification_tz)
    AND validate(mame.verified_prsnl_id)
    AND validate(mame.needs_verify_flag))
    SET fields_exist_mame = 1
   ENDIF
   FREE RANGE mae
   FREE RANGE ie
   FREE RANGE maa
   FREE RANGE mame
 END ;Subroutine
 SUBROUTINE populatetemplateorderid(orderid,scheduled_dt_tm,scheduled_tz)
   DECLARE templateorderid = f8 WITH protect, noconstant(0.0)
   DECLARE childorderid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "NL:"
    FROM orders o
    PLAN (o
     WHERE o.order_id=orderid)
    ORDER BY o.order_id
    HEAD o.order_id
     templateorderid = 0.0, scheduled_dt_tm = 0.0, scheduled_tz = 0,
     childorderid = 0.0
     IF (o.template_order_id=0)
      templateorderid = o.order_id, scheduled_dt_tm = cnvtdatetime(curdate,curtime3), scheduled_tz =
      o.current_start_tz
     ELSE
      childorderid = o.order_id, templateorderid = o.template_order_id
     ENDIF
    WITH nocounter
   ;end select
   IF (childorderid > 0.0)
    CALL populatescheduleddttm(childorderid,scheduled_dt_tm,scheduled_tz)
   ENDIF
   RETURN(templateorderid)
 END ;Subroutine
 SUBROUTINE populateverifydata(templateorderid,actionseq,needs_verify_flag,verification_dt_tm,
  verification_tz,verified_prsnl_id)
   DECLARE no_verify_needed = i2 WITH protect, constant(0)
   DECLARE verify_needed = i2 WITH protect, constant(1)
   DECLARE superceded = i2 WITH protect, constant(2)
   DECLARE verified = i2 WITH protect, constant(3)
   DECLARE rejected = i2 WITH protect, constant(4)
   DECLARE reviewed = i2 WITH protect, constant(5)
   DECLARE clinreviewflag_unset = i2 WITH protect, constant(0)
   DECLARE clinreviewflag_needs_review = i2 WITH protect, constant(1)
   DECLARE clinreviewflag_reviewed = i2 WITH protect, constant(2)
   DECLARE clinreviewflag_rejected = i2 WITH protect, constant(3)
   DECLARE clinreviewflag_dna = i2 WITH protect, constant(4)
   DECLARE clinreviewflag_superceded = i2 WITH protect, constant(5)
   SELECT INTO "NL:"
    FROM order_action oa
    PLAN (oa
     WHERE oa.order_id=templateorderid
      AND oa.action_sequence=actionseq)
    ORDER BY oa.order_id, oa.action_sequence
    DETAIL
     IF (oa.need_clin_review_flag=0)
      needs_verify_flag = oa.needs_verify_ind
     ELSE
      CASE (oa.need_clin_review_flag)
       OF clinreviewflag_unset:
        needs_verify_flag = verify_needed
       OF clinreviewflag_needs_review:
        needs_verify_flag = verify_needed
       OF clinreviewflag_reviewed:
        needs_verify_flag = verified
       OF clinreviewflag_rejected:
        needs_verify_flag = rejected
       OF clinreviewflag_dna:
        needs_verify_flag = no_verify_needed
       OF clinreviewflag_superceded:
        needs_verify_flag = superceded
      ENDCASE
     ENDIF
     IF (needs_verify_flag IN (no_verify_needed, verified, reviewed))
      verification_dt_tm = oa.action_dt_tm, verification_tz = oa.action_tz, verified_prsnl_id = oa
      .action_personnel_id
     ELSEIF (needs_verify_flag IN (verify_needed, rejected))
      verification_dt_tm = null, verification_tz = 0, verified_prsnl_id = 0.0
     ENDIF
    WITH nocounter
   ;end select
   IF (needs_verify_flag=superceded)
    SET needs_verify_flag = 0
    CALL populateverifydata(templateorderid,(actionseq+ 1),needs_verify_flag,verification_dt_tm,
     verification_tz,
     verified_prsnl_id)
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE populatescheduleddttm(orderid,scheduled_dt_tm,scheduled_tz)
  SELECT INTO "NL:"
   FROM task_activity ta
   PLAN (ta
    WHERE ta.order_id=orderid)
   ORDER BY ta.order_id
   HEAD REPORT
    scheduled_dt_tm = 0.0, scheduled_tz = 0
   HEAD ta.order_id
    scheduled_dt_tm = ta.task_dt_tm, scheduled_tz = ta.task_tz
   WITH nocounter
  ;end select
  RETURN
 END ;Subroutine
 SET reqinfo->commit_ind = 1
 SET last_mod = "014"
 SET mod_date = "06/16/2015"
 SET modify = nopredeclare
END GO
