CREATE PROGRAM dcp_save_regimen:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE cstatus = c1 WITH protect, noconstant("Z")
 DECLARE regimen_cnt = i4 WITH constant(value(size(request->regimenlist,5)))
 DECLARE regimen_attribute_cnt = i4 WITH protect, noconstant(0)
 DECLARE regimen_element_cnt = i4 WITH protect, noconstant(0)
 DECLARE regimen_element_r_cnt = i4 WITH protect, noconstant(0)
 DECLARE updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE statuscd = f8 WITH protect, noconstant(0.0)
 DECLARE regimen_detail_action_id = f8 WITH noconstant(0.0), protect
 DECLARE long_text_id = f8 WITH noconstant(0.0), protect
 DECLARE regimen_diagnosis_cnt = i4 WITH protect, noconstant(0)
 DECLARE update_diagnosis_idx = i2 WITH constant(1), protect
 DECLARE action_create = i2 WITH constant(1), protect
 DECLARE action_update = i2 WITH constant(2), protect
 DECLARE action_skip = i2 WITH constant(6), protect
 DECLARE action_child_update = i2 WITH constant(7), protect
 DECLARE regimen_order_cd = f8 WITH constant(uar_get_code_by("MEANING",4002500,"ORDER")), protect
 DECLARE regimen_modify_cd = f8 WITH constant(uar_get_code_by("MEANING",4002500,"MODIFY")), protect
 DECLARE detail_pending_cd = f8 WITH constant(uar_get_code_by("MEANING",4002515,"PENDING")), protect
 DECLARE detail_started_cd = f8 WITH constant(uar_get_code_by("MEANING",4002515,"STARTED")), protect
 DECLARE detail_cancelled_cd = f8 WITH constant(uar_get_code_by("MEANING",4002515,"CANCELLED")),
 protect
 DECLARE detail_skipped_cd = f8 WITH constant(uar_get_code_by("MEANING",4002515,"SKIPPED")), protect
 DECLARE detail_add_cd = f8 WITH constant(uar_get_code_by("MEANING",4002532,"ADD")), protect
 DECLARE detail_modify_cd = f8 WITH constant(uar_get_code_by("MEANING",4002532,"MODIFY")), protect
 DECLARE detail_skip_cd = f8 WITH constant(uar_get_code_by("MEANING",4002532,"SKIP")), protect
 DECLARE regimen_diagnosis_reltn_cd = f8 WITH constant(uar_get_code_by("MEANING",23549,"REGIMENDIAG")
  ), protect
 FOR (i = 1 TO regimen_cnt)
   IF ((request->regimenlist[i].action_type=action_create))
    SET cstatus = insert_regimen(i)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
    SET cstatus = insert_regimen_action(i,regimen_order_cd)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ELSEIF ((((request->regimenlist[i].action_type=action_update)) OR ((request->regimenlist[i].
   action_type=action_child_update))) )
    SET cstatus = update_regimen(i)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
    SET cstatus = insert_regimen_action(i,regimen_modify_cd)
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ELSE
    SET cstatus = "F"
    CALL report_failure("UNKNOWN","F","DCP_SAVE_REGIMEN",build("Unknown action type on regimen ",
      value(request->regimenlist[i].regimen_id)),i)
   ENDIF
   SET regimen_attribute_cnt = value(size(request->regimenlist[i].attributelist,5))
   FOR (j = 1 TO regimen_attribute_cnt)
    IF ((request->regimenlist[i].attributelist[j].action_type=action_create))
     SET cstatus = insert_regimen_attribute(i,j)
    ELSEIF ((((request->regimenlist[i].attributelist[j].action_type=action_update)) OR ((request->
    regimenlist[i].attributelist[j].action_type=action_child_update))) )
     SET cstatus = update_regimen_attribute(i,j)
    ELSE
     SET cstatus = "F"
     CALL report_failure("UNKNOWN","F","DCP_SAVE_REGIMEN",build(
       "Unknown action type on regimen attribute ",value(request->regimenlist[i].attributelist[j].
        regimen_attribute_id)),i)
    ENDIF
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ENDFOR
   SET regimen_element_cnt = value(size(request->regimenlist[i].elementlist,5))
   FOR (j = 1 TO regimen_element_cnt)
    IF ((request->regimenlist[i].elementlist[j].action_type=action_create))
     SET cstatus = insert_regimen_detail(i,j)
     IF (cstatus="F")
      GO TO exit_script
     ENDIF
     SET cstatus = insert_regimen_detail_action(i,j,detail_add_cd)
    ELSEIF ((((request->regimenlist[i].elementlist[j].action_type=action_update)) OR ((request->
    regimenlist[i].elementlist[j].action_type=action_child_update))) )
     SET cstatus = update_regimen_detail(i,j)
     IF (cstatus="F")
      GO TO exit_script
     ENDIF
     SET cstatus = insert_regimen_detail_action(i,j,detail_modify_cd)
    ELSEIF ((request->regimenlist[i].elementlist[j].action_type=action_skip))
     IF ((request->regimenlist[i].action_type=action_create))
      SET cstatus = insert_regimen_detail(i,j)
      IF (cstatus="F")
       GO TO exit_script
      ENDIF
     ELSE
      SET cstatus = update_regimen_detail(i,j)
      IF (cstatus="F")
       GO TO exit_script
      ENDIF
     ENDIF
     SET cstatus = insert_regimen_detail_action(i,j,detail_skip_cd)
    ELSE
     SET cstatus = "F"
     CALL report_failure("UNKNOWN","F","DCP_SAVE_REGIMEN",build(
       "Unknown action type on regimen element ",value(request->regimenlist[i].elementlist[j].
        regimen_detail_id)),i)
    ENDIF
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ENDFOR
   SET regimen_element_r_cnt = value(size(request->regimenlist[i].relationlist,5))
   FOR (j = 1 TO regimen_element_r_cnt)
    IF ((request->regimenlist[i].relationlist[j].action_type=action_create))
     SET cstatus = insert_regimen_detail_r(i,j)
    ELSEIF ((((request->regimenlist[i].relationlist[j].action_type=action_update)) OR ((request->
    regimenlist[i].relationlist[j].action_type=action_child_update))) )
     SET cstatus = update_regimen_detail_r(i,j)
    ELSE
     SET cstatus = "F"
     CALL report_failure("UNKNOWN","F","DCP_SAVE_REGIMEN",build(
       "Unknown action type on regimen element relation ",value(request->regimenlist[i].relationlist[
        j].regimen_detail_r_id)),i)
    ENDIF
    IF (cstatus="F")
     GO TO exit_script
    ENDIF
   ENDFOR
   IF (size(request->regimenlist[i].updatediagnosislist,5)=update_diagnosis_idx)
    SET regimen_diagnosis_cnt = value(size(request->regimenlist[i].updatediagnosislist[
      update_diagnosis_idx].diagnosislist,5))
    SET cstatus = update_regimen_diagnosis(i,update_diagnosis_idx)
   ENDIF
 ENDFOR
 SUBROUTINE (insert_regimen(idx=i4) =c1)
   INSERT  FROM regimen r
    SET r.person_id = request->regimenlist[idx].person_id, r.encntr_id = request->regimenlist[idx].
     encntr_id, r.regimen_id = request->regimenlist[idx].regimen_id,
     r.regimen_catalog_id = request->regimenlist[idx].regimen_catalog_id, r.regimen_description =
     request->regimenlist[idx].regimen_description, r.regimen_name = request->regimenlist[idx].
     regimen_name,
     r.ordered_as_name = request->regimenlist[idx].ordered_as_name, r.regimen_status_cd = request->
     regimenlist[idx].regimen_status_cd, r.requested_start_dt_tm = cnvtdatetime(request->regimenlist[
      idx].requested_start_dt_tm),
     r.requested_start_tz = request->regimenlist[idx].patient_tz, r.order_dt_tm = cnvtdatetime(
      request->regimenlist[idx].order_dt_tm), r.order_tz = request->regimenlist[idx].patient_tz,
     r.end_dt_tm = cnvtdatetime(request->regimenlist[idx].end_dt_tm), r.end_tz = request->
     regimenlist[idx].patient_tz, r.updt_applctx = reqinfo->updt_applctx,
     r.updt_cnt = 0, r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id = reqinfo->updt_id,
     r.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN","Unable to insert REGIMEN record",idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_regimen(idx=i4) =c1)
   SET updt_cnt = 0
   SELECT INTO "n1:"
    r.*
    FROM regimen r
    WHERE (r.regimen_id=request->regimenlist[idx].regimen_id)
    HEAD REPORT
     updt_cnt = r.updt_cnt
    WITH forupdate(r), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN","Unable to lock REGIMEN record",idx)
    RETURN("F")
   ENDIF
   IF ((updt_cnt != request->regimenlist[idx].updt_cnt))
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN",
     "UPDT_CNT does not match request->updt_cnt for REGIMEN record",idx)
    RETURN("F")
   ENDIF
   UPDATE  FROM regimen r
    SET r.regimen_status_cd = request->regimenlist[idx].regimen_status_cd, r.requested_start_dt_tm =
     cnvtdatetime(request->regimenlist[idx].requested_start_dt_tm), r.requested_start_tz = request->
     regimenlist[idx].patient_tz,
     r.order_dt_tm = cnvtdatetime(request->regimenlist[idx].order_dt_tm), r.order_tz = request->
     regimenlist[idx].patient_tz, r.end_dt_tm = cnvtdatetime(request->regimenlist[idx].end_dt_tm),
     r.end_tz = request->regimenlist[idx].patient_tz, r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_id
      = reqinfo->updt_id,
     r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = (r
     .updt_cnt+ 1)
    WHERE (r.regimen_id=request->regimenlist[idx].regimen_id)
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN","Unable to update REGIMEN record",idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_regimen_action(idx=i4,regimen_action_cd=f8) =c1)
   INSERT  FROM regimen_action ra
    SET ra.regimen_action_id = seq(carenet_seq,nextval), ra.action_dt_tm = cnvtdatetime(sysdate), ra
     .action_tz = request->regimenlist[idx].user_tz,
     ra.regimen_id = request->regimenlist[idx].regimen_id, ra.action_type_cd = value(
      regimen_action_cd), ra.action_prsnl_id = reqinfo->updt_id,
     ra.updt_dt_tm = cnvtdatetime(sysdate), ra.updt_id = reqinfo->updt_id, ra.updt_task = reqinfo->
     updt_task,
     ra.updt_cnt = 0, ra.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN","Unable to insert REGIMEN_ACTION record",idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_regimen_detail_action(idx=i4,idx2=i4,regimen_detail_action_cd=f8) =c1)
   SET regimen_detail_action_id = 0.0
   SET long_text_id = 0.0
   SELECT INTO "nl:"
    nextseqnum = seq(carenet_seq,nextval)
    FROM dual
    DETAIL
     regimen_detail_action_id = nextseqnum
    WITH nocounter
   ;end select
   IF (regimen_detail_action_id=0.0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN",
     "Unable to generate new regimen_detail_action_id for REGIMEN_DETAIL_ACTION table",idx)
    RETURN("F")
   ENDIF
   IF (regimen_detail_action_cd=detail_skip_cd)
    IF ((request->regimenlist[idx].elementlist[idx2].actioninfo.action_reason != null))
     SELECT INTO "nl:"
      nextseqnum = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       long_text_id = nextseqnum
      WITH nocounter
     ;end select
     IF (long_text_id=0.0)
      CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN",
       "Unable to generate new long_text_id for LONG_TEXT table",idx)
      RETURN("F")
     ENDIF
     INSERT  FROM long_text lt
      SET lt.long_text_id = long_text_id, lt.long_text = request->regimenlist[idx].elementlist[idx2].
       actioninfo.action_reason, lt.parent_entity_id = regimen_detail_action_id,
       lt.parent_entity_name = "REGIMEN_DETAIL_ACTION", lt.active_ind = 1, lt.active_status_cd =
       reqdata->active_status_cd,
       lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
       lt.updt_dt_tm = cnvtdatetime(sysdate),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
   INSERT  FROM regimen_detail_action rda
    SET rda.regimen_detail_action_id = regimen_detail_action_id, rda.regimen_id = request->
     regimenlist[idx].regimen_id, rda.regimen_detail_id = request->regimenlist[idx].elementlist[idx2]
     .regimen_detail_id,
     rda.action_reason_cd = request->regimenlist[idx].elementlist[idx2].actioninfo.action_reason_cd,
     rda.long_text_id = long_text_id, rda.action_type_cd = value(regimen_detail_action_cd),
     rda.action_prsnl_id = reqinfo->updt_id, rda.action_dt_tm = cnvtdatetime(sysdate), rda.action_tz
      = request->regimenlist[idx].user_tz,
     rda.updt_dt_tm = cnvtdatetime(sysdate), rda.updt_id = reqinfo->updt_id, rda.updt_task = reqinfo
     ->updt_task,
     rda.updt_cnt = 0, rda.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN",
     "Unable to insert REGIMEN_DETAIL_ACTION record",idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_regimen_attribute(idx=i4,idx2=i4) =c1)
   INSERT  FROM regimen_attribute ra
    SET ra.regimen_attribute_id = request->regimenlist[idx].attributelist[idx2].regimen_attribute_id,
     ra.regimen_cat_attribute_r_id = request->regimenlist[idx].attributelist[idx2].
     regimen_cat_attribute_id, ra.regimen_id = request->regimenlist[idx].regimen_id,
     ra.attribute_display = request->regimenlist[idx].attributelist[idx2].attribute_display, ra
     .attribute_display_flag = request->regimenlist[idx].attributelist[idx2].attribute_display_flag,
     ra.attribute_mean = request->regimenlist[idx].attributelist[idx2].attribute_mean,
     ra.code_set = request->regimenlist[idx].attributelist[idx2].code_set, ra.value_id = request->
     regimenlist[idx].attributelist[idx2].default_value_id, ra.value_name = request->regimenlist[idx]
     .attributelist[idx2].default_value_name,
     ra.input_type_flag = request->regimenlist[idx].attributelist[idx2].input_type_flag, ra.sequence
      = request->regimenlist[idx].attributelist[idx2].sequence, ra.updt_dt_tm = cnvtdatetime(sysdate),
     ra.updt_id = reqinfo->updt_id, ra.updt_task = reqinfo->updt_task, ra.updt_cnt = 0,
     ra.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN","Unable to insert REGIMEN_ATTRIBUTE record",
     idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_regimen_attribute(idx=i4,idx2=i4) =c1)
   SELECT INTO "n1:"
    ra.*
    FROM regimen_attribute ra
    WHERE (ra.regimen_attribute_id=request->regimenlist[idx].attributelist[idx2].regimen_attribute_id
    )
    WITH forupdate(r), nocounter
   ;end select
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN","Unable to lock REGIMEN_ATTRIBUTE record",idx
     )
    RETURN("F")
   ENDIF
   UPDATE  FROM regimen_attribute ra
    SET ra.value_id = request->regimenlist[idx].attributelist[idx2].default_value_id, ra.value_name
      = request->regimenlist[idx].attributelist[idx2].default_value_name, ra.updt_dt_tm =
     cnvtdatetime(sysdate),
     ra.updt_id = reqinfo->updt_id, ra.updt_task = reqinfo->updt_task, ra.updt_applctx = reqinfo->
     updt_applctx,
     ra.updt_cnt = (ra.updt_cnt+ 1)
    WHERE (ra.regimen_attribute_id=request->regimenlist[idx].attributelist[idx2].regimen_attribute_id
    )
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN","Unable to update REGIMEN_ATTRIBUTE record",
     idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_regimen_detail(idx=i4,idx2=i4) =c1)
   SET statuscd = determine_regimen_detail_status(idx,idx2)
   IF ((request->regimenlist[idx].elementlist[idx2].reference_entity_name="LONG_TEXT_REFERENCE"))
    SELECT INTO "nl:"
     nextseqnum = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      long_text_id = nextseqnum, request->regimenlist[idx].elementlist[idx2].activity_entity_id =
      long_text_id
     WITH nocounter
    ;end select
    IF (long_text_id=0.0)
     CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN",
      "Unable to generate new long_text_id for LONG_TEXT table",idx)
     RETURN("F")
    ENDIF
    INSERT  FROM long_text lt
     SET lt.long_text_id = long_text_id, lt.long_text = request->regimenlist[idx].elementlist[idx2].
      note_text, lt.parent_entity_id = request->regimenlist[idx].elementlist[idx2].regimen_detail_id,
      lt.parent_entity_name = "REGIMEN_DETAIL_ACTION", lt.active_ind = 1, lt.active_status_cd =
      reqdata->active_status_cd,
      lt.active_status_dt_tm = cnvtdatetime(sysdate), lt.active_status_prsnl_id = reqinfo->updt_id,
      lt.updt_dt_tm = cnvtdatetime(sysdate),
      lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_cnt = 0,
      lt.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN","Unable to insert note into LONG_TEXT table",
      idx)
     RETURN("F")
    ENDIF
   ENDIF
   INSERT  FROM regimen_detail rd
    SET rd.regimen_detail_id = request->regimenlist[idx].elementlist[idx2].regimen_detail_id, rd
     .regimen_cat_detail_id = request->regimenlist[idx].elementlist[idx2].regimen_cat_detail_id, rd
     .regimen_id = request->regimenlist[idx].regimen_id,
     rd.activity_entity_id = request->regimenlist[idx].elementlist[idx2].activity_entity_id, rd
     .activity_entity_name = request->regimenlist[idx].elementlist[idx2].activity_entity_name, rd
     .reference_entity_id = request->regimenlist[idx].elementlist[idx2].reference_entity_id,
     rd.reference_entity_name = request->regimenlist[idx].elementlist[idx2].reference_entity_name, rd
     .regimen_detail_sequence = request->regimenlist[idx].elementlist[idx2].regimen_detail_sequence,
     rd.cycle_nbr = request->regimenlist[idx].elementlist[idx2].cycle_nbr,
     rd.start_dt_tm = cnvtdatetime(request->regimenlist[idx].elementlist[idx2].start_dt_tm), rd
     .start_tz = request->regimenlist[idx].patient_tz, rd.regimen_detail_status_cd = statuscd,
     rd.updt_dt_tm = cnvtdatetime(sysdate), rd.updt_id = reqinfo->updt_id, rd.updt_task = reqinfo->
     updt_task,
     rd.updt_cnt = 0, rd.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN","Unable to insert REGIMEN_DETAIL record",idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (update_regimen_detail(idx=i4,idx2=i4) =c1)
   SET statuscd = determine_regimen_detail_status(idx,idx2)
   UPDATE  FROM regimen_detail rd
    SET rd.activity_entity_id = request->regimenlist[idx].elementlist[idx2].activity_entity_id, rd
     .activity_entity_name = request->regimenlist[idx].elementlist[idx2].activity_entity_name, rd
     .regimen_detail_sequence = request->regimenlist[idx].elementlist[idx2].regimen_detail_sequence,
     rd.start_dt_tm = cnvtdatetime(request->regimenlist[idx].elementlist[idx2].start_dt_tm), rd
     .start_tz = request->regimenlist[idx].patient_tz, rd.regimen_detail_status_cd = statuscd,
     rd.regimen_detail_sequence = request->regimenlist[idx].elementlist[idx2].regimen_detail_sequence,
     rd.updt_dt_tm = cnvtdatetime(sysdate), rd.updt_id = reqinfo->updt_id,
     rd.updt_task = reqinfo->updt_task, rd.updt_cnt = (rd.updt_cnt+ 1), rd.updt_applctx = reqinfo->
     updt_applctx
    WHERE (rd.regimen_detail_id=request->regimenlist[idx].elementlist[idx2].regimen_detail_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN","Unable to update REGIMEN_DETAIL record",idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (insert_regimen_detail_r(idx=i4,idx2=i4) =c1)
   INSERT  FROM regimen_detail_r rdr
    SET rdr.regimen_detail_r_id = request->regimenlist[idx].relationlist[idx2].regimen_detail_r_id,
     rdr.regimen_detail_s_id = request->regimenlist[idx].relationlist[idx2].regimen_detail_s_id, rdr
     .regimen_detail_t_id = request->regimenlist[idx].relationlist[idx2].regimen_detail_t_id,
     rdr.regimen_id = request->regimenlist[idx].regimen_id, rdr.type_mean = request->regimenlist[idx]
     .relationlist[idx2].type_mean, rdr.offset_value = request->regimenlist[idx].relationlist[idx2].
     offset_value,
     rdr.offset_unit_cd = request->regimenlist[idx].relationlist[idx2].offset_unit_cd, rdr.updt_dt_tm
      = cnvtdatetime(sysdate), rdr.updt_id = reqinfo->updt_id,
     rdr.updt_task = reqinfo->updt_task, rdr.updt_cnt = 0, rdr.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN","Unable to insert REGIMEN_DETAIL_R record",
     idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE update_regimen_detail_r(idx,idx2)
   UPDATE  FROM regimen_detail_r rdr
    SET rdr.regimen_detail_s_id = request->regimenlist[idx].relationlist[idx2].regimen_detail_s_id,
     rdr.regimen_detail_t_id = request->regimenlist[idx].relationlist[idx2].regimen_detail_t_id, rdr
     .offset_value = request->regimenlist[idx].relationlist[idx2].offset_value,
     rdr.offset_unit_cd = request->regimenlist[idx].relationlist[idx2].offset_unit_cd, rdr.updt_dt_tm
      = cnvtdatetime(sysdate), rdr.updt_id = reqinfo->updt_id,
     rdr.updt_task = reqinfo->updt_task, rdr.updt_cnt = (rdr.updt_cnt+ 1), rdr.updt_applctx = reqinfo
     ->updt_applctx
    WHERE (rdr.regimen_detail_r_id=request->regimenlist[idx].relationlist[idx2].regimen_detail_r_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    CALL report_failure("UPDATE","F","DCP_SAVE_REGIMEN","Unable to update REGIMEN_DETAIL_R record",
     idx)
    RETURN("F")
   ENDIF
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (determine_regimen_detail_status(idx=i4,idx2=i4) =f8)
   IF ((((request->regimenlist[idx].elementlist[idx2].regimen_detail_status_cd=detail_cancelled_cd))
    OR ((request->regimenlist[idx].elementlist[idx2].regimen_detail_status_cd=detail_skipped_cd))) )
    RETURN(value(request->regimenlist[idx].elementlist[idx2].regimen_detail_status_cd))
   ELSEIF ((request->regimenlist[idx].elementlist[idx2].action_type=action_skip))
    RETURN(detail_skipped_cd)
   ELSEIF ((request->regimenlist[idx].elementlist[idx2].activity_entity_id > 0.0))
    RETURN(detail_started_cd)
   ELSE
    RETURN(detail_pending_cd)
   ENDIF
 END ;Subroutine
 SUBROUTINE (update_regimen_diagnosis(idx=i4,idx2=i4) =c1)
   DECLARE regimendxcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    rowcnt = count(*)
    FROM nomen_entity_reltn ner
    WHERE (ner.parent_entity_id=request->regimenlist[idx].regimen_id)
    HEAD REPORT
     regimendxcnt = rowcnt
    WITH nocounter
   ;end select
   IF (regimendxcnt >= 1)
    DELETE  FROM nomen_entity_reltn ner
     WHERE (ner.parent_entity_id=request->regimenlist[idx].regimen_id)
    ;end delete
    IF (curqual=0)
     CALL report_failure("DELETE","F","DCP_SAVE_REGIMEN","Unable to delete row on NOMEN_ENTITY_RELTN",
      idx)
     RETURN("F")
    ENDIF
   ENDIF
   FOR (idiagnosisidx = 1 TO regimen_diagnosis_cnt)
     DECLARE new_reltn_id = f8 WITH protect, noconstant(0.0)
     SELECT INTO "nl:"
      nextseqnum = seq(entity_reltn_seq,nextval)
      FROM dual
      DETAIL
       new_reltn_id = cnvtreal(nextseqnum)
      WITH nocounter
     ;end select
     IF (new_reltn_id <= 0)
      CALL report_failure("INSERT","F","DCP_UPD_PLAN_NOMEN_RELTN",
       "Failed to generate unique id for NOMEN_ENTITY_RELTN table",idx)
      GO TO exit_script
     ENDIF
     INSERT  FROM nomen_entity_reltn ner
      SET ner.nomen_entity_reltn_id = new_reltn_id, ner.nomenclature_id = request->regimenlist[idx].
       updatediagnosislist[idx2].diagnosislist[idiagnosisidx].nomenclature_id, ner.parent_entity_name
        = "REGIMEN",
       ner.parent_entity_id = request->regimenlist[idx].regimen_id, ner.child_entity_name =
       "DIAGNOSIS", ner.child_entity_id = request->regimenlist[idx].updatediagnosislist[idx2].
       diagnosislist[idiagnosisidx].diagnosis_id,
       ner.reltn_type_cd = regimen_diagnosis_reltn_cd, ner.person_id = request->regimenlist[idx].
       person_id, ner.encntr_id = request->regimenlist[idx].encntr_id,
       ner.active_ind = 1, ner.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00"), ner
       .beg_effective_dt_tm = cnvtdatetime(sysdate),
       ner.activity_type_cd = 0, ner.priority = (idiagnosisidx+ 1), ner.reltn_subtype_cd = 0,
       ner.updt_dt_tm = cnvtdatetime(sysdate), ner.updt_id = reqinfo->updt_id, ner.updt_task =
       reqinfo->updt_task,
       ner.updt_cnt = 0, ner.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL report_failure("INSERT","F","DCP_SAVE_REGIMEN",
       "Failed to insert new row(s) into NOMEN_ENTITY_RELTN table",idx)
      GO TO exit_script
     ENDIF
   ENDFOR
   RETURN("S")
 END ;Subroutine
 SUBROUTINE (report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc,idx=i4) =null)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET cnt = size(reply->status_data.subeventstatus,5)
   IF (((cnt != 1) OR (cnt=1
    AND (reply->status_data.subeventstatus[1].operationstatus != null))) )
    SET cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,value(cnt))
   ENDIF
   SET reply->status_data.subeventstatus[cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[cnt].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[cnt].targetobjectvalue = trim(targetvalue)
   CALL audit_event(opname,targetname,targetvalue,idx)
 END ;Subroutine
 SUBROUTINE (audit_event(opname=vc,targetname=vc,targetvalue=vc,idx=i4) =null)
   FREE SET audit_req
   RECORD audit_req(
     1 audit_list[*]
       2 event_type = c12
       2 event_name = c12
       2 event_message = c255
       2 event_dt_tm = dq8
       2 event_entity_id = f8
       2 event_entity_name = c30
       2 event_enum = i4
       2 person_id = f8
       2 encntr_id = f8
       2 user_id = f8
       2 app_nbr = f8
   )
   SET stat = alterlist(audit_req->audit_list,1)
   SET audit_req->audit_list[1].event_type = trim(opname)
   SET audit_req->audit_list[1].event_name = "SAVE_REGIMEN"
   SET audit_req->audit_list[1].event_message = trim(targetvalue)
   SET audit_req->audit_list[1].event_dt_tm = cnvtdatetime(curdate,curtime)
   SET audit_req->audit_list[1].event_entity_id = request->regimenlist[idx].regimen_id
   SET audit_req->audit_list[1].event_entity_name = trim(targetname)
   SET audit_req->audit_list[1].event_enum = 0
   SET audit_req->audit_list[1].person_id = request->regimenlist[idx].person_id
   SET audit_req->audit_list[1].encntr_id = request->regimenlist[idx].encntr_id
   SET audit_req->audit_list[1].user_id = reqinfo->updt_id
   SET audit_req->audit_list[1].app_nbr = reqinfo->updt_app
   EXECUTE dcp_add_plan_audit_event  WITH replace("REQUEST",audit_req)
   COMMIT
 END ;Subroutine
#exit_script
 IF (cstatus="S")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SET reply->status_data.status = cstatus
 CALL echorecord(reply)
END GO
