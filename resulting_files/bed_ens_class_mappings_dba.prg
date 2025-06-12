CREATE PROGRAM bed_ens_class_mappings:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 registries[*]
      2 registry_id = f8
      2 registry_name = vc
    1 condition_sets[*]
      2 condition_set_id = f8
      2 condition_set_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp_insert(
   1 elements[*]
     2 element_id = f8
     2 element_name = vc
     2 type_flag = i2
 )
 RECORD temp_update(
   1 elements[*]
     2 element_id = f8
     2 element_name = vc
     2 active_ind = i2
 )
 RECORD temp_conditions(
   1 conditions[*]
     2 cond_set_id = f8
     2 condition_name = vc
 )
 DECLARE registry_type = i4 WITH protect, constant(1)
 DECLARE condition_set_type = i4 WITH protect, constant(2)
 DECLARE registry_cnt = i4 WITH protect, noconstant(0)
 DECLARE condition_set_cnt = i4 WITH protect, noconstant(0)
 DECLARE condition_cnt = i4 WITH protect, noconstant(0)
 DECLARE insert_condition_cnt = i4 WITH protect, noconstant(0)
 DECLARE ins_cnt = i4 WITH protect, noconstant(0)
 DECLARE updt_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_class_id = f8 WITH protect, noconstant(0.0)
 DECLARE vparse = vc WITH protect, noconstant(
  "from_v.end_effective_dt_tm > cnvtdatetime(curdate,curtime)")
 DECLARE logical_domain_id = f8 WITH protect, noconstant(0.0)
 RANGE OF ac IS ac_class_def
 RANGE OF p IS prsnl
 IF (validate(ac.logical_domain_id)
  AND validate(p.logical_domain_id))
  IF (validate(ld_concept_person)=0)
   DECLARE ld_concept_person = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_prsnl)=0)
   DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
  ENDIF
  IF (validate(ld_concept_organization)=0)
   DECLARE ld_concept_organization = i2 WITH public, constant(3)
  ENDIF
  IF (validate(ld_concept_healthplan)=0)
   DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
  ENDIF
  IF (validate(ld_concept_alias_pool)=0)
   DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
  ENDIF
  IF (validate(ld_concept_minvalue)=0)
   DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
  ENDIF
  IF (validate(ld_concept_maxvalue)=0)
   DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
  ENDIF
  RECORD acm_get_curr_logical_domain_req(
    1 concept = i4
  )
  RECORD acm_get_curr_logical_domain_rep(
    1 logical_domain_id = f8
    1 status_block
      2 status_ind = i2
      2 error_code = i4
  )
  SET acm_get_curr_logical_domain_req->concept = ld_concept_prsnl
  EXECUTE acm_get_curr_logical_domain  WITH replace("REQUEST",acm_get_curr_logical_domain_req),
  replace("REPLY",acm_get_curr_logical_domain_rep)
  SET vparse = build2(vparse," and from_v.logical_domain_id = ",acm_get_curr_logical_domain_rep->
   logical_domain_id)
  SET logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id
 ENDIF
 FREE RANGE ac
 FREE RANGE p
 SET registry_cnt = size(request->registry,5)
 SET stat = alterlist(reply->registries,registry_cnt)
 FOR (j = 1 TO registry_cnt)
  IF ((request->registry[j].registry_id > 0))
   SET updt_cnt = (updt_cnt+ 1)
   SET stat = alterlist(temp_update->elements,updt_cnt)
   SET temp_update->elements[updt_cnt].element_id = request->registry[j].registry_id
   SET temp_update->elements[updt_cnt].element_name = request->registry[j].registry_name
   SET temp_update->elements[updt_cnt].active_ind = request->registry[j].active_ind
   SET reply->registries[j].registry_id = request->registry[j].registry_id
  ELSE
   SET ins_cnt = (ins_cnt+ 1)
   SET stat = alterlist(temp_insert->elements,ins_cnt)
   SET new_class_id = 0.0
   SELECT INTO "nl:"
    z = seq(health_status_seq,nextval)
    FROM dual
    DETAIL
     new_class_id = cnvtreal(z)
    WITH nocounter
   ;end select
   SET temp_insert->elements[ins_cnt].element_id = new_class_id
   SET temp_insert->elements[ins_cnt].type_flag = registry_type
   SET temp_insert->elements[ins_cnt].element_name = request->registry[j].registry_name
   SET reply->registries[j].registry_id = new_class_id
  ENDIF
  SET reply->registries[j].registry_name = request->registry[j].registry_name
 ENDFOR
 SET condition_set_cnt = size(request->condition_set,5)
 SET stat = alterlist(reply->condition_sets,condition_set_cnt)
 FOR (k = 1 TO condition_set_cnt)
  IF ((request->condition_set[k].condition_set_id > 0))
   SET updt_cnt = (updt_cnt+ 1)
   SET stat = alterlist(temp_update->elements,updt_cnt)
   SET temp_update->elements[updt_cnt].element_id = request->condition_set[k].condition_set_id
   SET temp_update->elements[updt_cnt].element_name = request->condition_set[k].condition_set_name
   SET temp_update->elements[updt_cnt].active_ind = request->condition_set[k].active_ind
   SET reply->condition_sets[k].condition_set_id = request->condition_set[k].condition_set_id
   SET condition_cnt = size(request->condition_set[k].condition,5)
   FOR (h = 1 TO condition_cnt)
     SET insert_condition_cnt = (insert_condition_cnt+ 1)
     SET stat = alterlist(temp_conditions->conditions,insert_condition_cnt)
     SET temp_conditions->conditions[h].cond_set_id = request->condition_set[k].condition_set_id
     SET temp_conditions->conditions[h].condition_name = request->condition_set[k].condition[h].
     condition_name
   ENDFOR
  ELSE
   SET ins_cnt = (ins_cnt+ 1)
   SET stat = alterlist(temp_insert->elements,ins_cnt)
   SET new_class_id = 0.0
   SELECT INTO "nl:"
    z = seq(health_status_seq,nextval)
    FROM dual
    DETAIL
     new_class_id = cnvtreal(z)
    WITH nocounter
   ;end select
   SET temp_insert->elements[ins_cnt].element_id = new_class_id
   SET temp_insert->elements[ins_cnt].type_flag = condition_set_type
   SET temp_insert->elements[ins_cnt].element_name = request->condition_set[k].condition_set_name
   SET reply->condition_sets[k].condition_set_id = new_class_id
   SET condition_cnt = size(request->condition_set[k].condition,5)
   FOR (h = 1 TO condition_cnt)
     SET insert_condition_cnt = (insert_condition_cnt+ 1)
     SET stat = alterlist(temp_conditions->conditions,insert_condition_cnt)
     SET temp_conditions->conditions[h].cond_set_id = new_class_id
     SET temp_conditions->conditions[h].condition_name = request->condition_set[k].condition[h].
     condition_name
   ENDFOR
  ENDIF
  SET reply->condition_sets[k].condition_set_name = request->condition_set[k].condition_set_name
 ENDFOR
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 IF (ins_cnt > 0)
  INSERT  FROM ac_class_def a,
    (dummyt d  WITH seq = value(ins_cnt))
   SET a.ac_class_def_id = temp_insert->elements[d.seq].element_id, a.active_ind = 1, a
    .begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), a.class_display_name =
    temp_insert->elements[d.seq].element_name, a.class_display_name_key = cnvtupper(cnvtalphanum(
      temp_insert->elements[d.seq].element_name)),
    a.class_type_flag = temp_insert->elements[d.seq].type_flag, a.logical_domain_id =
    logical_domain_id, a.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_cnt = 0
   PLAN (d)
    JOIN (a)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into ac_class_def table")
 ENDIF
 IF (updt_cnt > 0)
  UPDATE  FROM ac_class_def a,
    (dummyt d  WITH seq = value(updt_cnt))
   SET a.active_ind = temp_update->elements[d.seq].active_ind, a.begin_effective_dt_tm = cnvtdatetime
    (curdate,curtime3), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    a.class_display_name = temp_update->elements[d.seq].element_name, a.class_display_name_key =
    cnvtupper(cnvtalphanum(temp_update->elements[d.seq].element_name)), a.updt_dt_tm = cnvtdatetime(
     curdate,curtime3),
    a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->
    updt_applctx,
    a.updt_cnt = (a.updt_cnt+ 1)
   PLAN (d)
    JOIN (a
    WHERE (a.ac_class_def_id=temp_update->elements[d.seq].element_id)
     AND (temp_update->elements[d.seq].active_ind=1))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating (1) into ac_class_def table")
  UPDATE  FROM ac_class_def a,
    (dummyt d  WITH seq = value(updt_cnt))
   SET a.active_ind = temp_update->elements[d.seq].active_ind, a.end_effective_dt_tm = cnvtdatetime(
     curdate,curtime3), a.class_display_name = temp_update->elements[d.seq].element_name,
    a.class_display_name_key = cnvtupper(cnvtalphanum(temp_update->elements[d.seq].element_name)), a
    .updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = reqinfo->updt_id,
    a.updt_task = reqinfo->updt_task, a.updt_applctx = reqinfo->updt_applctx, a.updt_cnt = (a
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (a
    WHERE (a.ac_class_def_id=temp_update->elements[d.seq].element_id)
     AND (temp_update->elements[d.seq].active_ind=0))
   WITH nocounter
  ;end update
  CALL bederrorcheck("Error updating (0) into ac_class_def table")
  DELETE  FROM ac_class_he_rule c,
    (dummyt d  WITH seq = value(updt_cnt))
   SET c.seq = 1
   PLAN (d)
    JOIN (c
    WHERE (c.ac_class_def_id=temp_update->elements[d.seq].element_id))
   WITH nocounter
  ;end delete
  CALL bederrorcheck("Error deleting from ac_class_he_rule table")
 ENDIF
 IF (insert_condition_cnt > 0)
  INSERT  FROM ac_class_he_rule r,
    (dummyt d  WITH seq = value(insert_condition_cnt))
   SET r.ac_class_he_rule_id = seq(health_status_seq,nextval), r.ac_class_def_id = temp_conditions->
    conditions[d.seq].cond_set_id, r.health_expert_rule_txt = temp_conditions->conditions[d.seq].
    condition_name,
    r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_task =
    reqinfo->updt_task,
    r.updt_applctx = reqinfo->updt_applctx, r.updt_cnt = 0
   PLAN (d)
    JOIN (r)
   WITH nocounter
  ;end insert
  CALL bederrorcheck("Error inserting into ac_class_he_rule table")
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
