CREATE PROGRAM bed_ens_alias_by_contr_system:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET ccnt = 0
 SET ccnt = size(request->code_values,5)
 FOR (c = 1 TO ccnt)
   IF ((request->code_values[c].ob_action_flag IN (1, 2, 3))
    AND (request->code_values[c].outbound_alias="<space>"))
    SET request->code_values[c].outbound_alias = " "
   ENDIF
   IF ((request->code_values[c].cv_action_flag=2))
    SET request_cv->cd_value_list[1].action_flag = 2
    SET request_cv->cd_value_list[1].code_set = request->code_set
    SET request_cv->cd_value_list[1].code_value = request->code_values[c].code_value
    SET request_cv->cd_value_list[1].display = request->code_values[c].display
    SET request_cv->cd_value_list[1].description = request->code_values[c].description
    SET request_cv->cd_value_list[1].cdf_meaning = request->code_values[c].mean
    SET request_cv->cd_value_list[1].active_ind = request->code_values[c].active_ind
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ENDIF
   SET icnt = 0
   SET icnt = size(request->code_values[c].inbound_aliases,5)
   IF (icnt > 0)
    INSERT  FROM code_value_alias cva,
      (dummyt d  WITH seq = icnt)
     SET cva.code_value = request->code_values[c].code_value, cva.contributor_source_cd = request->
      contributor_source_code_value, cva.code_set = request->code_set,
      cva.alias = request->code_values[c].inbound_aliases[d.seq].alias, cva.alias_type_meaning = " ",
      cva.primary_ind = 0,
      cva.updt_cnt = 0, cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = reqinfo->
      updt_id,
      cva.updt_task = reqinfo->updt_task, cva.updt_applctx = reqinfo->updt_applctx
     PLAN (d
      WHERE (request->code_values[c].inbound_aliases[d.seq].ib_action_flag=1))
      JOIN (cva)
     WITH nocounter
    ;end insert
    UPDATE  FROM code_value_alias cva,
      (dummyt d  WITH seq = icnt)
     SET cva.alias = request->code_values[c].inbound_aliases[d.seq].alias, cva.updt_cnt = (cva
      .updt_cnt+ 1), cva.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cva.updt_id = reqinfo->updt_id, cva.updt_task = reqinfo->updt_task, cva.updt_applctx = reqinfo
      ->updt_applctx
     PLAN (d
      WHERE (request->code_values[c].inbound_aliases[d.seq].ib_action_flag=2))
      JOIN (cva
      WHERE (cva.code_value=request->code_values[c].code_value)
       AND (cva.contributor_source_cd=request->contributor_source_code_value)
       AND (cva.code_set=request->code_set)
       AND (cva.alias=request->code_values[c].inbound_aliases[d.seq].old_alias))
     WITH nocounter
    ;end update
    DELETE  FROM code_value_alias cva,
      (dummyt d  WITH seq = icnt)
     SET cva.seq = 1
     PLAN (d
      WHERE (request->code_values[c].inbound_aliases[d.seq].ib_action_flag=3))
      JOIN (cva
      WHERE (cva.alias=request->code_values[c].inbound_aliases[d.seq].alias)
       AND (cva.code_value=request->code_values[c].code_value)
       AND (cva.contributor_source_cd=request->contributor_source_code_value)
       AND (cva.code_set=request->code_set))
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
 IF (ccnt > 0)
  INSERT  FROM code_value_outbound cvo,
    (dummyt d  WITH seq = ccnt)
   SET cvo.code_value = request->code_values[d.seq].code_value, cvo.contributor_source_cd = request->
    contributor_source_code_value, cvo.code_set = request->code_set,
    cvo.alias = request->code_values[d.seq].outbound_alias, cvo.alias_type_meaning = " ", cvo
    .updt_cnt = 0,
    cvo.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvo.updt_id = reqinfo->updt_id, cvo.updt_task =
    reqinfo->updt_task,
    cvo.updt_applctx = reqinfo->updt_applctx
   PLAN (d
    WHERE (request->code_values[d.seq].ob_action_flag=1))
    JOIN (cvo)
   WITH nocounter
  ;end insert
  UPDATE  FROM code_value_outbound cvo,
    (dummyt d  WITH seq = ccnt)
   SET cvo.alias = request->code_values[d.seq].outbound_alias, cvo.updt_cnt = (cvo.updt_cnt+ 1), cvo
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cvo.updt_id = reqinfo->updt_id, cvo.updt_task = reqinfo->updt_task, cvo.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (request->code_values[d.seq].ob_action_flag=2))
    JOIN (cvo
    WHERE (cvo.code_value=request->code_values[d.seq].code_value)
     AND (cvo.contributor_source_cd=request->contributor_source_code_value)
     AND (cvo.code_set=request->code_set))
   WITH nocounter
  ;end update
  DELETE  FROM code_value_outbound cvo,
    (dummyt d  WITH seq = ccnt)
   SET cvo.seq = 1
   PLAN (d
    WHERE (request->code_values[d.seq].ob_action_flag=3))
    JOIN (cvo
    WHERE (cvo.alias=request->code_values[d.seq].outbound_alias)
     AND (cvo.code_value=request->code_values[d.seq].code_value)
     AND (cvo.contributor_source_cd=request->contributor_source_code_value)
     AND (cvo.code_set=request->code_set))
   WITH nocounter
  ;end delete
  INSERT  FROM br_name_value b,
    (dummyt d  WITH seq = ccnt)
   SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "ALIAS_IGNORE_CV", b.br_name =
    cnvtstring(request->contributor_system_code_value),
    b.br_value = cnvtstring(request->code_values[d.seq].code_value), b.updt_cnt = 0, b.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d
    WHERE (request->code_values[d.seq].ig_action_flag=2)
     AND (request->code_values[d.seq].ignore_ind=1))
    JOIN (b)
   WITH nocounter
  ;end insert
  DELETE  FROM br_name_value b,
    (dummyt d  WITH seq = ccnt)
   SET b.seq = 1
   PLAN (d
    WHERE (request->code_values[d.seq].ig_action_flag=2)
     AND (request->code_values[d.seq].ignore_ind=0))
    JOIN (b
    WHERE b.br_nv_key1="ALIAS_IGNORE_CV"
     AND b.br_name=cnvtstring(request->contributor_system_code_value)
     AND b.br_value=cnvtstring(request->code_values[d.seq].code_value))
   WITH nocounter
  ;end delete
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
