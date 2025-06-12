CREATE PROGRAM dcp_upd_pregnancy:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 pregnancy_id = f8
   1 pregnancy_group_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 edd_list[*]
     2 edd_reference = f8
     2 edd_id = f8
   1 edd_action_list[*]
     2 edd_id = f8
     2 action_id = f8
     2 action_reference = f8
   1 comments[*]
     2 comment_reference = f8
     2 pregnancy_comment_id = f8
     2 offspring_id = f8
     2 long_text_id = f8
   1 offspring[*]
     2 offspring_reference = f8
     2 offspring_id = f8
     2 offspring_group_id = f8
   1 complications[*]
     2 complication_reference = f8
     2 pregnancy_complication_id = f8
     2 complication_instance_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD rec_dt_tm
 RECORD rec_dt_tm(
   1 current_dt_tm = dq8
   1 endof_dt_tm = dq8
 )
 DECLARE preg_cnt = i4 WITH public, noconstant(size(request->preg_struct,5))
 DECLARE comment_cnt = i4 WITH public, noconstant(size(request->comments,5))
 DECLARE complication_cnt = i4 WITH public, noconstant(size(request->complications,5))
 DECLARE action_cnt = i4 WITH public, noconstant(size(request->edd_action_list,5))
 DECLARE edd_cnt = i4 WITH public, noconstant(size(request->edd_list,5))
 DECLARE pregnancy_group_id = f8 WITH public, noconstant(0.0)
 DECLARE pregnancy_id = f8 WITH public, noconstant(0.0)
 DECLARE new_id = f8 WITH public, noconstant(0.0)
 DECLARE active_ind = i2 WITH public, noconstant(1)
 SET rec_dt_tm->current_dt_tm = cnvtdatetime(curdate,curtime3)
 SET rec_dt_tm->endof_dt_tm = cnvtdatetime("31-Dec-2100")
 DECLARE validaterequest(null) = i2
 DECLARE updatepregnancy(null) = null
 DECLARE generatepregids(null) = f8
 DECLARE endeffectivepregnancy(pregid=f8) = null
 DECLARE updatereltn(reltn_cd=f8,parent_name=vc,parent_id=f8,child_name=vc,child_id=f8) = null
 DECLARE insertcomments(null) = null
 DECLARE updatecomplications(null) = null
 DECLARE updateedd(null) = null
 DECLARE insertactions(null) = null
 DECLARE updateoffspring(null) = null
 IF (validaterequest(null)=1)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
  CALL updatepregnancy(null)
  CALL updateedd(null)
  CALL insertactions(null)
  CALL insertcomments(null)
  CALL updateoffspring(null)
  CALL updatecomplications(null)
 ELSE
  SET failed = input_error
  SET table_name = "none"
 ENDIF
 SUBROUTINE validaterequest(null)
   DECLARE validated = i2 WITH noconstant(0)
   IF ((request->pregnancy_group_id != 0.0)
    AND (request->pregnancy_id != 0.0)
    AND preg_cnt <= 1)
    SET validated = 1
   ELSEIF ((request->pregnancy_group_id=0.0)
    AND (request->pregnancy_id=0.0)
    AND preg_cnt=1)
    SET validated = 1
   ENDIF
   IF ((request->pregnancy_group_id=0.0))
    SET pregnancy_group_id = generatepregids(null)
    SET pregnancy_id = pregnancy_group_id
   ELSE
    SET pregnancy_group_id = request->pregnancy_group_id
    SET pregnancy_id = generatepregids(null)
   ENDIF
   RETURN(validated)
 END ;Subroutine
 SUBROUTINE updatepregnancy(null)
   IF (preg_cnt=1)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    IF ((request->pregnancy_id != 0))
     CALL endeffectivepregnancy(request->pregnancy_id)
    ENDIF
    INSERT  FROM pregnancy p
     SET p.pregnancy_id = pregnancy_id, p.pregnancy_group_id = pregnancy_group_id, p.person_id =
      request->person_id,
      p.pregnancy_seq = request->preg_struct[preg_cnt].pregnancy_seq, p.sensitive_ind = request->
      preg_struct[preg_cnt].sensitive_ind, p.resolution_dt_tm =
      IF ((request->preg_struct[preg_cnt].resolution_dt_tm < 1)) null
      ELSE cnvtdatetime(request->preg_struct[preg_cnt].resolution_dt_tm)
      ENDIF
      ,
      p.abortive_outcome_ind = request->preg_struct[preg_cnt].abortive_outcome_ind, p
      .preterm_labor_ind = request->preg_struct[preg_cnt].preterm_labor_ind, p.length_of_labor =
      request->preg_struct[preg_cnt].length_of_labor,
      p.outcome_age_flag = request->preg_struct[preg_cnt].outcome_age_flag, p.outcome_gestational_age
       = request->preg_struct[preg_cnt].outcome_gestational_age, p.outcome_dt_tm =
      IF ((request->preg_struct[preg_cnt].outcome_dt_tm < 1)) null
      ELSE cnvtdatetime(request->preg_struct[preg_cnt].outcome_dt_tm)
      ENDIF
      ,
      p.outcome_tz = request->preg_struct[preg_cnt].outcome_tz, p.location_cd = request->preg_struct[
      preg_cnt].location_cd, p.ft_location = request->preg_struct[preg_cnt].location,
      p.ft_description = request->preg_struct[preg_cnt].description, p.ft_labor_method = request->
      preg_struct[preg_cnt].labor_method, p.ft_delivery_method = request->preg_struct[preg_cnt].
      delivery_method,
      p.ft_anesthesia = request->preg_struct[preg_cnt].anesthesia, p.ft_abortive_outcome = request->
      preg_struct[preg_cnt].abortive_outcome, p.beg_effective_dt_tm = cnvtdatetime(rec_dt_tm->
       current_dt_tm),
      p.end_effective_dt_tm = cnvtdatetime(rec_dt_tm->endof_dt_tm), p.active_ind = active_ind, p
      .updt_applctx = reqinfo->updt_applctx,
      p.updt_cnt = 0, p.updt_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), p.updt_id = reqinfo->
      updt_id,
      p.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET reply->pregnancy_id = pregnancy_id
    SET reply->pregnancy_group_id = pregnancy_group_id
    SET reply->beg_effective_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm)
    SET reply->end_effective_dt_tm = cnvtdatetime(rec_dt_tm->endof_dt_tm)
    SET ierrcode = error(serrmsg,0)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "pregnancy_id"
     GO TO exit_script
    ENDIF
    DECLARE description_cnt = i4 WITH public, noconstant(size(request->preg_struct[preg_cnt].
      codified_descriptions,5))
    DECLARE labor_method_cnt = i4 WITH public, noconstant(size(request->preg_struct[preg_cnt].
      codified_labor_methods,5))
    DECLARE delivery_method_cnt = i4 WITH public, noconstant(size(request->preg_struct[preg_cnt].
      codified_delivery_methods,5))
    DECLARE anesthesia_cnt = i4 WITH public, noconstant(size(request->preg_struct[preg_cnt].
      codified_anesthesia_codes,5))
    DECLARE abortive_outcome_cnt = i4 WITH public, noconstant(size(request->preg_struct[preg_cnt].
      codified_abortive_outcomes,5))
    DECLARE reltn_cnt = f8 WITH noconstant(0.0), private
    SET reltn_cd = uar_get_code_by("MEANING",23549,"PREGDESCRIP")
    FOR (i = 1 TO description_cnt)
      CALL updatereltn(reltn_cd,"PREGNANCY",pregnancy_id,"NOMENCLATURE",request->preg_struct[preg_cnt
       ].codified_descriptions[i].nomenclature_id)
    ENDFOR
    SET reltn_cd = uar_get_code_by("MEANING",23549,"LABORMETHOD")
    FOR (i = 1 TO labor_method_cnt)
      CALL updatereltn(reltn_cd,"PREGNANCY",pregnancy_id,"NOMENCLATURE",request->preg_struct[preg_cnt
       ].codified_labor_methods[i].nomenclature_id)
    ENDFOR
    SET reltn_cd = uar_get_code_by("MEANING",23549,"DELIVMETHOD")
    FOR (i = 1 TO delivery_method_cnt)
      CALL updatereltn(reltn_cd,"PREGNANCY",pregnancy_id,"NOMENCLATURE",request->preg_struct[preg_cnt
       ].codified_delivery_methods[i].nomenclature_id)
    ENDFOR
    SET reltn_cd = uar_get_code_by("MEANING",23549,"PREGANESTH")
    FOR (i = 1 TO anesthesia_cnt)
      CALL updatereltn(reltn_cd,"PREGNANCY",pregnancy_id,"NOMENCLATURE",request->preg_struct[preg_cnt
       ].codified_anesthesia_codes[i].nomenclature_id)
    ENDFOR
    SET reltn_cd = uar_get_code_by("MEANING",23549,"ABORTOUTCOME")
    FOR (i = 1 TO abortive_outcome_cnt)
      CALL updatereltn(reltn_cd,"PREGNANCY",pregnancy_id,"NOMENCLATURE",request->preg_struct[preg_cnt
       ].codified_abortive_outcomes[i].nomenclature_id)
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE generatepregids(null)
  SELECT INTO "nl:"
   num = seq(pregnancy_seq,nextval)
   FROM dual
   DETAIL
    new_id = cnvtreal(num)
   WITH nocounter
  ;end select
  RETURN(new_id)
 END ;Subroutine
 SUBROUTINE endeffectivepregnancy(x)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   UPDATE  FROM pregnancy p
    SET p.end_effective_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), p.active_ind = 0, p
     .updt_applctx = reqinfo->updt_applctx,
     p.updt_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), p.updt_id = reqinfo->updt_id, p.updt_task
      = reqinfo->updt_task
    WHERE p.pregnancy_id=x
     AND (p.pregnancy_group_id=request->pregnancy_group_id)
    WITH nocounter
   ;end update
   SET pregnancy_id = generatepregids(null)
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode > 0)
    SET failed = update_error
    SET table_name = "pregnancy"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE updatereltn(reltn_cd,parent_name,parent_id,child_name,child_id)
   INSERT  FROM nomen_entity_reltn n
    SET n.nomen_entity_reltn_id = cnvtreal(seq(entity_reltn_seq,nextval)), n.reltn_type_cd = reltn_cd,
     n.reltn_subtype_cd = 0.0,
     n.parent_entity_name = parent_name, n.parent_entity_id = parent_id, n.child_entity_name =
     child_name,
     n.child_entity_id = child_id, n.nomenclature_id =
     IF (child_name="NOMENCLATURE") child_id
     ELSE null
     ENDIF
     , n.beg_effective_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm),
     n.end_effective_dt_tm = cnvtdatetime(rec_dt_tm->endof_dt_tm), n.updt_applctx = reqinfo->
     updt_applctx, n.updt_cnt = 0,
     n.updt_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), n.updt_id = reqinfo->updt_id, n.updt_task
      = reqinfo->updt_task
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode > 0)
    SET failed = insert_error
    SET table_name = "nomen_entity_reltn"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE insertcomments(null)
   IF (comment_cnt > 0)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SET stat = alterlist(reply->comments,comment_cnt)
    DECLARE pregnancy_comment_id = f8 WITH public, noconstant(0.0)
    DECLARE long_text_id = f8 WITH public, noconstant(0.0)
    FOR (i = 1 TO comment_cnt)
      SET pregnancy_comment_id = generatepregids(null)
      SELECT INTO "nl:"
       nextseqnum = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        long_text_id = cnvtreal(nextseqnum)
       WITH nocounter
      ;end select
      INSERT  FROM long_text lt
       SET lt.long_text_id = long_text_id, lt.parent_entity_name = "PREGNANCY_COMMENT", lt
        .parent_entity_id = pregnancy_comment_id,
        lt.long_text = request->comments[i].text, lt.updt_applctx = reqinfo->updt_applctx, lt
        .updt_cnt = 0,
        lt.updt_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), lt.updt_id = reqinfo->updt_id, lt
        .updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (ierrcode > 0)
       SET failed = insert_error
       SET table_name = "long_text"
       GO TO exit_script
      ENDIF
      INSERT  FROM pregnancy_comment pc
       SET pc.pregnancy_comment_id = pregnancy_comment_id, pc.pregnancy_group_id = pregnancy_group_id,
        pc.comment_prsnl_id = request->comments[i].comment_prsnl_id,
        pc.comment_dt_tm = cnvtdatetime(request->comments[i].comment_dt_tm), pc.comment_tz = request
        ->comments[i].comment_tz, pc.long_text_id = long_text_id,
        pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = 0, pc.updt_dt_tm = cnvtdatetime(
         rec_dt_tm->current_dt_tm),
        pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      SET reply->comments[i].comment_reference = request->comments[i].comment_reference
      SET reply->comments[i].pregnancy_comment_id = pregnancy_comment_id
      SET reply->comments[i].long_text_id = long_text_id
      SET ierrcode = error(serrmsg,0)
      IF (ierrcode > 0)
       SET failed = insert_error
       SET table_name = "pregnancy_comment"
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE updateedd(null)
   IF (edd_cnt > 0)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DECLARE edd_id = f8 WITH public, noconstant(0.0)
    SET stat = alterlist(reply->edd_list,edd_cnt)
    FOR (i = 1 TO edd_cnt)
      IF ((request->edd_list[i].edd_id=0.0))
       SET edd_id = generatepregids(null)
       INSERT  FROM edd e
        SET e.edd_id = edd_id, e.pregnancy_group_id = pregnancy_group_id, e.event_id = request->
         edd_list[i].event_id,
         e.edd_flag = request->edd_list[i].edd_flag
        WITH nocounter
       ;end insert
       SET reply->edd_list[i].edd_reference = request->edd_list[i].edd_reference
       SET reply->edd_list[i].edd_id = edd_id
       IF (ierrcode > 0)
        SET failed = insert_error
        SET table_name = "edd"
        GO TO exit_script
       ENDIF
      ELSE
       UPDATE  FROM edd e
        SET e.edd_id = request->edd_list[i].edd_id, e.pregnancy_group_id = pregnancy_group_id, e
         .event_id = request->edd_list[i].event_id,
         e.edd_flag = request->edd_list[i].edd_flag
        WHERE (e.edd_id=request->edd_list[i].edd_id)
        WITH nocounter
       ;end update
       SET reply->edd_list[i].edd_reference = request->edd_list[i].edd_reference
       SET reply->edd_list[i].edd_id = request->edd_list[i].edd_id
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode > 0)
        SET failed = update_error
        SET table_name = "edd"
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE insertactions(null)
   IF (action_cnt > 0)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    DECLARE edd_action_id = f8 WITH public, noconstant(0.0)
    SET stat = alterlist(reply->edd_action_list,action_cnt)
    FOR (i = 1 TO action_cnt)
      SET edd_action_id = generatepregids(null)
      IF ((request->edd_action_list[i].edd_id=0))
       FOR (j = 1 TO edd_cnt)
         IF ((reply->edd_list[j].edd_reference=request->edd_action_list[i].edd_reference))
          SET reply->edd_action_list[i].edd_id = reply->edd_list[j].edd_id
         ENDIF
       ENDFOR
      ELSE
       SET reply->edd_action_list[i].edd_id = request->edd_action_list[i].edd_id
      ENDIF
      SET reply->edd_action_list[i].action_id = edd_action_id
      SET reply->edd_action_list[i].action_reference = request->edd_action_list[i].action_reference
      INSERT  FROM edd_action ea
       SET ea.edd_action_id = edd_action_id, ea.edd_id = reply->edd_action_list[i].edd_id, ea
        .action_prsnl_id = request->edd_action_list[i].prsnl_id,
        ea.action_flag = request->edd_action_list[i].action_flag, ea.action_dt_tm = cnvtdatetime(
         request->edd_action_list[i].action_dt_tm), ea.action_tz = request->edd_action_list[i].
        action_tz,
        ea.active_ind = active_ind, ea.updt_applctx = reqinfo->updt_applctx, ea.updt_cnt = 0,
        ea.updt_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), ea.updt_id = reqinfo->updt_id, ea
        .updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      SET ierrcode = error(serrmsg,0)
      IF (ierrcode > 0)
       SET failed = insert_error
       SET table_name = "edd_action"
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE updateoffspring(null)
   DECLARE offspring_cnt = i4 WITH constant(size(request->offspring,5)), private
   DECLARE updt_cnt = i4 WITH noconstant(0)
   DECLARE instance_id = f8 WITH noconstant(0.0)
   DECLARE group_id = f8 WITH noconstant(0.0)
   DECLARE reltn_cd = f8 WITH noconstant(0.0), private
   DECLARE item_cnt = i4 WITH noconstant(0), private
   SET stat = alterlist(reply->offspring,offspring_cnt)
   FOR (i = 1 TO offspring_cnt)
     SET updt_cnt = 0
     SET instance_id = generatepregids(null)
     IF ((request->offspring[i].offspring_group_id != 0.0))
      SET group_id = request->offspring[i].offspring_group_id
      UPDATE  FROM preg_offspring p
       SET p.end_effective_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), p.active_ind = 0, p
        .updt_applctx = reqinfo->updt_applctx,
        p.updt_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), p.updt_id = reqinfo->updt_id, p
        .updt_task = reqinfo->updt_task
       WHERE (p.pregnancy_offspring_group_id=request->offspring[i].offspring_group_id)
        AND p.active_ind=1
       WITH nocounter
      ;end update
     ELSE
      SET group_id = instance_id
     ENDIF
     CALL echo(build("updt_cnt",updt_cnt))
     INSERT  FROM preg_offspring p
      SET p.pregnancy_offspring_id = instance_id, p.pregnancy_offspring_group_id = group_id, p
       .pregnancy_group_id = pregnancy_group_id,
       p.fetus_label = request->offspring[i].fetal_label, p.person_id = request->offspring[i].
       person_id, p.gender_cd = request->offspring[i].gender_cd,
       p.outcome_dt_tm = cnvtdatetime(request->offspring[i].outcome_dt_tm), p.outcome_tz = request->
       offspring[i].outcome_tz, p.offspring_seq = request->offspring[i].offspring_seq,
       p.outcome_gestational_age = request->offspring[i].outcome_gestational_age, p.birth_weight =
       request->offspring[i].birth_weight, p.birth_weight_unit_cd = request->offspring[i].
       birth_weight_unit_cd,
       p.ft_anesthesia = request->offspring[i].ft_anesthesia, p.ft_delivery_method = request->
       offspring[i].ft_delivery_method, p.ft_outcome = request->offspring[i].ft_outcome,
       p.length_of_labor = request->offspring[i].length_of_labor, p.living_flag = request->offspring[
       i].living_ind, p.beg_effective_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm),
       p.end_effective_dt_tm = cnvtdatetime(rec_dt_tm->endof_dt_tm), p.active_ind = 1, p.updt_applctx
        = reqinfo->updt_applctx,
       p.updt_cnt = updt_cnt, p.updt_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), p.updt_id =
       reqinfo->updt_id,
       p.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,0)
     IF (ierrcode > 0)
      SET failed = insert_error
      SET table_name = "PREG_OFFSPRING"
      GO TO exit_script
     ENDIF
     SET item_cnt = size(request->offspring[i].anesthesia_codes,5)
     SET reltn_cd = uar_get_code_by("MEANING",23549,"PREGANESTH")
     FOR (j = 1 TO item_cnt)
       CALL updatereltn(reltn_cd,"PREG_OFFSPRING",instance_id,"NOMENCLATURE",request->offspring[i].
        anesthesia_codes[j].nomenclature_id)
     ENDFOR
     SET item_cnt = size(request->offspring[i].delivery_method_codes,5)
     SET reltn_cd = uar_get_code_by("MEANING",23549,"DELIVMETHOD")
     FOR (j = 1 TO item_cnt)
       CALL updatereltn(reltn_cd,"PREG_OFFSPRING",instance_id,"NOMENCLATURE",request->offspring[i].
        delivery_method_codes[j].nomenclature_id)
     ENDFOR
     SET item_cnt = size(request->offspring[i].outcome_codes,5)
     SET reltn_cd = uar_get_code_by("MEANING",23549,"PREGOUTCOME")
     FOR (j = 1 TO item_cnt)
       CALL updatereltn(reltn_cd,"PREG_OFFSPRING",instance_id,"NOMENCLATURE",request->offspring[i].
        outcome_codes[j].nomenclature_id)
     ENDFOR
     SET reply->offspring[i].offspring_reference = request->offspring[i].offspring_reference
     SET reply->offspring[i].offspring_id = instance_id
     SET reply->offspring[i].offspring_group_id = group_id
   ENDFOR
 END ;Subroutine
 SUBROUTINE updatecomplications(null)
   IF (complication_cnt > 0)
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SET stat = alterlist(reply->complications,complication_cnt)
    DECLARE updt_cnt = i4 WITH noconstant(0)
    DECLARE pregnancy_complication_id = f8 WITH public, noconstant(0.0)
    FOR (i = 1 TO complication_cnt)
      SET updt_cnt = 0
      SET pregnancy_complication_id = generatepregids(null)
      IF ((request->complications[i].pregnancy_complication_id != 0.0))
       UPDATE  FROM pregnancy_complications pc
        SET pc.end_effective_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), pc.active_ind = 0, pc
         .updt_applctx = reqinfo->updt_applctx,
         pc.updt_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), pc.updt_id = reqinfo->updt_id, pc
         .updt_task = reqinfo->updt_task
        WHERE (pc.pregnancy_complication_id=request->complications[i].pregnancy_complication_id)
         AND p.active_ind=1
        WITH nocounter
       ;end update
      ENDIF
      INSERT  FROM pregnancy_complication pc
       SET pc.pregnancy_complication_id = pregnancy_complication_id, pc.pregnancy_group_id =
        pregnancy_group_id, pc.complication_instance_id = request->complications[i].
        complication_instance_id,
        pc.parent_entity_name = request->complications[i].parent_entity, pc.parent_entity_id =
        request->complications[i].parent_entity_id, pc.priority = request->complications[i].priority,
        pc.complication_flag = request->complications[i].complication_flag, pc.beg_effective_dt_tm =
        cnvtdatetime(rec_dt_tm->current_dt_tm), pc.end_effective_dt_tm = cnvtdatetime(rec_dt_tm->
         endof_dt_tm),
        pc.active_status_prsnl_id = reqinfo->updt_id, pc.active_status_cd = 1, pc.active_ind = 1,
        pc.active_status_dt_tm = cnvtdatetime(rec_dt_tm->current_dt_tm), pc.updt_dt_tm = cnvtdatetime
        (rec_dt_tm->current_dt_tm), pc.updt_applctx = reqinfo->updt_applctx,
        pc.updt_id = reqinfo->updt_id, pc.updt_task = reqinfo->updt_task, pc.updt_cnt = 0
       WITH nocounter
      ;end insert
      SET reply->complications[i].complication_reference = request->complications[i].
      complication_reference
      SET reply->complications[i].complication_instance_id = request->complications[i].
      complication_instance_id
      SET reply->complications[i].pregnancy_complication_id = pregnancy_complication_id
      SET ierrcode = error(serrmsg,0)
      IF (ierrcode > 0)
       SET failed = update_error
       SET table_name = "pregnancy_complication"
       GO TO exit_script
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
  SET reqinfo->commit_ind = false
 ENDIF
 SET script_version = "001 08/09/05 am010569"
END GO
