CREATE PROGRAM cdi_upd_form_rules:dba
 IF (validate(reply->status_data.status)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE update_rule_cnt = i4 WITH noconstant(0), public
 DECLARE delete_rule_cnt = i4 WITH noconstant(0), public
 DECLARE insert_rule_cnt = i4 WITH noconstant(0), public
 DECLARE update_criteria_cnt = i4 WITH noconstant(0), public
 DECLARE delete_criteria_cnt = i4 WITH noconstant(0), public
 DECLARE insert_criteria_cnt = i4 WITH noconstant(0), public
 DECLARE locked_row_cnt = i4 WITH noconstant(0), protect
 DECLARE tmp_cnt = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE j = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_upd_form_rules"
 SET req_rule_cnt = value(size(request->rules,5))
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 IF (req_rule_cnt > 0)
  RECORD update_rules(
    1 rules[*]
      2 cdi_form_id = f8
      2 cdi_form_rule_id = f8
      2 required_ind = i2
      2 criteria_cnt = i4
  )
  RECORD insert_rules(
    1 rules[*]
      2 cdi_form_id = f8
      2 cdi_form_rule_id = f8
      2 rule_name = vc
      2 required_ind = i2
      2 criteria_cnt = i4
  )
  RECORD delete_rules(
    1 rules[*]
      2 cdi_form_rule_id = f8
  )
  RECORD update_criteria(
    1 criteria[*]
      2 cdi_form_rule_id = f8
      2 cdi_form_criteria_id = f8
      2 variable_cd = f8
      2 comparison_flag = i2
      2 value_type_flag = i2
      2 value_cd = f8
      2 value_nbr = f8
      2 value_dt_tm = dq8
      2 value_text = vc
  )
  RECORD insert_criteria(
    1 criteria[*]
      2 cdi_form_rule_id = f8
      2 cdi_form_criteria_id = f8
      2 variable_cd = f8
      2 comparison_flag = i2
      2 value_type_flag = i2
      2 value_cd = f8
      2 value_nbr = f8
      2 value_dt_tm = dq8
      2 value_text = vc
  )
  RECORD delete_criteria(
    1 criteria[*]
      2 cdi_form_criteria_id = f8
  )
  FOR (i = 1 TO req_rule_cnt)
    IF ((request->rules[i].cdi_form_rule_id=0.0))
     SET insert_rule_cnt = (insert_rule_cnt+ 1)
    ENDIF
  ENDFOR
  SET stat = alterlist(insert_rules->rules,insert_rule_cnt)
  IF (insert_rule_cnt > 0)
   EXECUTE dm2_dar_get_bulk_seq "insert_rules->rules", insert_rule_cnt, "cdi_form_rule_id",
   1, "CDI_SEQ"
  ENDIF
  SET insert_rule_cnt = 0
  FOR (i = 1 TO req_rule_cnt)
   IF ((request->rules[i].cdi_form_rule_id=0.0))
    SET insert_rule_cnt = (insert_rule_cnt+ 1)
    SET request->rules[i].cdi_form_rule_id = insert_rules->rules[insert_rule_cnt].cdi_form_rule_id
    SET insert_rules->rules[insert_rule_cnt].cdi_form_id = request->cdi_form_id
    SET insert_rules->rules[insert_rule_cnt].required_ind = request->rules[i].required_ind
    SET insert_rules->rules[insert_rule_cnt].criteria_cnt = size(request->rules[i].criteria,5)
    IF (size(trim(request->rules[i].rule_name)) < 1)
     SET insert_rules->rules[insert_rule_cnt].rule_name = build(format(cnvtdatetime(curdate,curtime2),
       ";;Q"),"_",insert_rule_cnt)
    ELSE
     SET insert_rules->rules[insert_rule_cnt].rule_name = request->rules[i].rule_name
    ENDIF
   ELSE
    IF ((request->rules[i].delete_ind != 0))
     SET delete_rule_cnt = (delete_rule_cnt+ 1)
     IF (mod(delete_rule_cnt,10)=1)
      SET stat = alterlist(delete_rules->rules,(delete_rule_cnt+ 9))
     ENDIF
     SET delete_rules->rules[delete_rule_cnt].cdi_form_rule_id = request->rules[i].cdi_form_rule_id
    ELSE
     SET update_rule_cnt = (update_rule_cnt+ 1)
     IF (mod(update_rule_cnt,10)=1)
      SET stat = alterlist(update_rules->rules,(update_rule_cnt+ 9))
     ENDIF
     SET update_rules->rules[update_rule_cnt].cdi_form_id = request->cdi_form_id
     SET update_rules->rules[update_rule_cnt].cdi_form_rule_id = request->rules[i].cdi_form_rule_id
     SET update_rules->rules[update_rule_cnt].required_ind = request->rules[i].required_ind
    ENDIF
   ENDIF
   FOR (j = 1 TO size(request->rules[i].criteria,5))
     IF ((request->rules[i].criteria[j].cdi_form_criteria_id=0.0))
      SET insert_criteria_cnt = (insert_criteria_cnt+ 1)
      IF (mod(insert_criteria_cnt,10)=1)
       SET stat = alterlist(insert_criteria->criteria,(insert_criteria_cnt+ 9))
      ENDIF
      SET insert_criteria->criteria[insert_criteria_cnt].cdi_form_rule_id = request->rules[i].
      cdi_form_rule_id
      SET insert_criteria->criteria[insert_criteria_cnt].variable_cd = request->rules[i].criteria[j].
      variable_cd
      SET insert_criteria->criteria[insert_criteria_cnt].comparison_flag = request->rules[i].
      criteria[j].comparison_flag
      SET insert_criteria->criteria[insert_criteria_cnt].value_type_flag = request->rules[i].
      criteria[j].value_type_flag
      SET insert_criteria->criteria[insert_criteria_cnt].value_cd = request->rules[i].criteria[j].
      value_cd
      SET insert_criteria->criteria[insert_criteria_cnt].value_nbr = request->rules[i].criteria[j].
      value_nbr
      SET insert_criteria->criteria[insert_criteria_cnt].value_dt_tm = request->rules[i].criteria[j].
      value_dt_tm
      SET insert_criteria->criteria[insert_criteria_cnt].value_text = request->rules[i].criteria[j].
      value_text
     ELSE
      IF ((request->rules[i].criteria[j].delete_ind != 0))
       SET delete_criteria_cnt = (delete_criteria_cnt+ 1)
       IF (mod(delete_criteria_cnt,10)=1)
        SET stat = alterlist(delete_criteria->criteria,(delete_criteria_cnt+ 9))
       ENDIF
       SET delete_criteria->criteria[delete_criteria_cnt].cdi_form_criteria_id = request->rules[i].
       criteria[j].cdi_form_criteria_id
      ELSE
       SET update_criteria_cnt = (update_criteria_cnt+ 1)
       IF (mod(update_criteria_cnt,10)=1)
        SET stat = alterlist(update_criteria->criteria,(update_criteria_cnt+ 9))
       ENDIF
       SET update_criteria->criteria[update_criteria_cnt].cdi_form_rule_id = request->rules[i].
       cdi_form_rule_id
       SET update_criteria->criteria[update_criteria_cnt].cdi_form_criteria_id = request->rules[i].
       criteria[j].cdi_form_criteria_id
       SET update_criteria->criteria[update_criteria_cnt].variable_cd = request->rules[i].criteria[j]
       .variable_cd
       SET update_criteria->criteria[update_criteria_cnt].comparison_flag = request->rules[i].
       criteria[j].comparison_flag
       SET update_criteria->criteria[update_criteria_cnt].value_type_flag = request->rules[i].
       criteria[j].value_type_flag
       SET update_criteria->criteria[update_criteria_cnt].value_cd = request->rules[i].criteria[j].
       value_cd
       SET update_criteria->criteria[update_criteria_cnt].value_nbr = request->rules[i].criteria[j].
       value_nbr
       SET update_criteria->criteria[update_criteria_cnt].value_dt_tm = request->rules[i].criteria[j]
       .value_dt_tm
       SET update_criteria->criteria[update_criteria_cnt].value_text = request->rules[i].criteria[j].
       value_text
      ENDIF
     ENDIF
   ENDFOR
  ENDFOR
  IF (insert_criteria_cnt > 0)
   EXECUTE dm2_dar_get_bulk_seq "insert_criteria->criteria", insert_criteria_cnt,
   "cdi_form_criteria_id",
   1, "CDI_SEQ"
  ENDIF
  SELECT INTO "NL:"
   r.cdi_form_rule_id
   FROM cdi_form_rule r
   WHERE expand(num,1,update_rule_cnt,r.cdi_form_rule_id,update_rules->rules[num].cdi_form_rule_id)
   DETAIL
    tmp_cnt = (tmp_cnt+ 1)
   WITH nocounter, forupdatewait(r)
  ;end select
  SELECT INTO "NL:"
   c.cdi_form_criteria_id
   FROM cdi_form_criteria c
   WHERE expand(num,1,update_criteria_cnt,c.cdi_form_criteria_id,update_criteria->criteria[num].
    cdi_form_criteria_id)
   DETAIL
    tmp_cnt = (tmp_cnt+ 1)
   WITH nocounter, forupdatewait(c)
  ;end select
  IF (update_criteria_cnt > 0)
   UPDATE  FROM cdi_form_criteria c,
     (dummyt d  WITH seq = update_criteria_cnt)
    SET c.cdi_form_rule_id = update_criteria->criteria[d.seq].cdi_form_rule_id, c.variable_cd =
     update_criteria->criteria[d.seq].variable_cd, c.comparison_flag = update_criteria->criteria[d
     .seq].comparison_flag,
     c.value_cd = evaluate(update_criteria->criteria[d.seq].value_type_flag,1,update_criteria->
      criteria[d.seq].value_cd,null), c.value_nbr = evaluate(update_criteria->criteria[d.seq].
      value_type_flag,2,update_criteria->criteria[d.seq].value_nbr,null), c.value_dt_tm = evaluate(
      update_criteria->criteria[d.seq].value_type_flag,3,cnvtdatetime(update_criteria->criteria[d.seq
       ].value_dt_tm),null),
     c.value_text = evaluate(update_criteria->criteria[d.seq].value_type_flag,4,update_criteria->
      criteria[d.seq].value_text," "), c.updt_cnt = (c.updt_cnt+ 1), c.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     c.updt_task = reqinfo->updt_task, c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->
     updt_applctx
    PLAN (d)
     JOIN (c
     WHERE (c.cdi_form_criteria_id=update_criteria->criteria[d.seq].cdi_form_criteria_id))
    WITH nocounter
   ;end update
   SET tmp_cnt = curqual
   IF (tmp_cnt < update_criteria_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_CRITERIA"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (insert_rule_cnt > 0)
   INSERT  FROM cdi_form_rule t,
     (dummyt d  WITH seq = insert_rule_cnt)
    SET t.cdi_form_id = insert_rules->rules[d.seq].cdi_form_id, t.cdi_form_rule_id = insert_rules->
     rules[d.seq].cdi_form_rule_id, t.rule_name = insert_rules->rules[d.seq].rule_name,
     t.required_ind = insert_rules->rules[d.seq].required_ind, t.criteria_cnt = insert_rules->rules[d
     .seq].criteria_cnt, t.updt_cnt = 0,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo->updt_task, t.updt_id =
     reqinfo->updt_id,
     t.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (t)
    WITH nocounter
   ;end insert
   SET tmp_cnt = curqual
   IF (tmp_cnt < insert_rule_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_RULE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (insert_criteria_cnt > 0)
   INSERT  FROM cdi_form_criteria t,
     (dummyt d  WITH seq = insert_criteria_cnt)
    SET t.cdi_form_rule_id = insert_criteria->criteria[d.seq].cdi_form_rule_id, t
     .cdi_form_criteria_id = insert_criteria->criteria[d.seq].cdi_form_criteria_id, t.variable_cd =
     insert_criteria->criteria[d.seq].variable_cd,
     t.comparison_flag = insert_criteria->criteria[d.seq].comparison_flag, t.value_cd = evaluate(
      insert_criteria->criteria[d.seq].value_type_flag,1,insert_criteria->criteria[d.seq].value_cd,
      null), t.value_nbr = evaluate(insert_criteria->criteria[d.seq].value_type_flag,2,
      insert_criteria->criteria[d.seq].value_nbr,null),
     t.value_dt_tm = evaluate(insert_criteria->criteria[d.seq].value_type_flag,3,cnvtdatetime(
       insert_criteria->criteria[d.seq].value_dt_tm),null), t.value_text = evaluate(insert_criteria->
      criteria[d.seq].value_type_flag,4,insert_criteria->criteria[d.seq].value_text," "), t.updt_cnt
      = 0,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo->updt_task, t.updt_id =
     reqinfo->updt_id,
     t.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (t)
    WITH nocounter
   ;end insert
   SET tmp_cnt = curqual
   IF (tmp_cnt < insert_criteria_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_CRITERIA"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (delete_criteria_cnt > 0)
   DELETE  FROM cdi_form_criteria t
    WHERE expand(num,1,delete_criteria_cnt,t.cdi_form_criteria_id,delete_criteria->criteria[num].
     cdi_form_criteria_id)
     AND t.cdi_form_criteria_id != 0
    WITH nocounter
   ;end delete
   SET tmp_cnt = curqual
   IF (tmp_cnt < delete_criteria_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_CRITERIA"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    GO TO exit_script
   ENDIF
  ENDIF
  IF (delete_rule_cnt > 0)
   DELETE  FROM cdi_form_criteria t
    WHERE expand(num,1,delete_rule_cnt,t.cdi_form_rule_id,delete_rules->rules[num].cdi_form_rule_id)
     AND t.cdi_form_criteria_id != 0
    WITH nocounter
   ;end delete
   DELETE  FROM cdi_form_rule t
    WHERE expand(num,1,delete_rule_cnt,t.cdi_form_rule_id,delete_rules->rules[num].cdi_form_rule_id)
     AND t.cdi_form_rule_id != 0
    WITH nocounter
   ;end delete
   SET tmp_cnt = curqual
   IF (tmp_cnt < delete_rule_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_RULE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "NL:"
   c.cdi_form_rule_id, rule_criteria_cnt = count(c.cdi_form_criteria_id)
   FROM cdi_form_criteria c
   WHERE expand(num,1,update_rule_cnt,c.cdi_form_rule_id,update_rules->rules[num].cdi_form_rule_id)
   GROUP BY c.cdi_form_rule_id
   DETAIL
    j = locateval(i,1,update_rule_cnt,c.cdi_form_rule_id,update_rules->rules[i].cdi_form_rule_id)
    IF (j >= 0)
     update_rules->rules[j].criteria_cnt = rule_criteria_cnt
    ENDIF
   WITH nocounter, forupdatewait(r)
  ;end select
  IF (update_rule_cnt > 0)
   UPDATE  FROM cdi_form_rule r,
     (dummyt d  WITH seq = update_rule_cnt)
    SET r.cdi_form_id = update_rules->rules[d.seq].cdi_form_id, r.required_ind = update_rules->rules[
     d.seq].required_ind, r.criteria_cnt = update_rules->rules[d.seq].criteria_cnt,
     r.updt_cnt = (r.updt_cnt+ 1), r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task =
     reqinfo->updt_task,
     r.updt_id = reqinfo->updt_id, r.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (r
     WHERE (r.cdi_form_rule_id=update_rules->rules[d.seq].cdi_form_rule_id))
    WITH nocounter
   ;end update
   SET tmp_cnt = curqual
   IF (tmp_cnt < update_rule_cnt)
    SET ecode = 0
    SET emsg = fillstring(200," ")
    SET ecode = error(emsg,1)
    SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_FORM_RULE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = emsg
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
