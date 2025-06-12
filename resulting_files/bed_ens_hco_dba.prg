CREATE PROGRAM bed_ens_hco:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 hco[*]
      2 hco_id = f8
      2 hco_nbr = i4
      2 hco_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp_delete(
   1 hco[*]
     2 hco_id = f8
 )
 RECORD temp_update(
   1 hco[*]
     2 hco_id = f8
     2 hco_nbr = i4
     2 hco_name = vc
 )
 DECLARE logerror(namemsg=vc,valuemsg=vc) = null
 DECLARE hco_cnt = i4
 DECLARE error_flag = vc
 DECLARE reply_cnt = i4 WITH noconstant(0)
 DECLARE del_cnt = i4 WITH noconstant(0)
 DECLARE updt_cnt = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET error_flag = "N"
 SET data_partition_ind = 0
 RANGE OF b IS br_hco
 SET data_partition_ind = validate(b.logical_domain_id)
 FREE RANGE b
 IF (data_partition_ind=1)
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
 ENDIF
 SET hco_cnt = size(request->hco,5)
 FOR (i = 1 TO hco_cnt)
   IF ((request->hco[i].action_flag=3))
    SET del_cnt = (del_cnt+ 1)
    SET stat = alterlist(temp_delete->hco,del_cnt)
    SET temp_delete->hco[del_cnt].hco_id = request->hco[i].hco_id
   ENDIF
   IF ((request->hco[i].action_flag=2))
    SET updt_cnt = (updt_cnt+ 1)
    SET stat = alterlist(temp_update->hco,updt_cnt)
    SET temp_update->hco[updt_cnt].hco_name = request->hco[i].hco_name
    SET temp_update->hco[updt_cnt].hco_nbr = request->hco[i].hco_nbr
    SET temp_update->hco[updt_cnt].hco_id = request->hco[i].hco_id
   ENDIF
   IF ((request->hco[i].action_flag=1))
    SET reply_cnt = (reply_cnt+ 1)
    SET br_hco_id = 0.0
    SELECT INTO "nl:"
     z = seq(bedrock_seq,nextval)
     FROM dual
     DETAIL
      br_hco_id = cnvtreal(z)
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->hco,reply_cnt)
    SET reply->hco[reply_cnt].hco_name = request->hco[i].hco_name
    SET reply->hco[reply_cnt].hco_nbr = request->hco[i].hco_nbr
    SET reply->hco[reply_cnt].hco_id = br_hco_id
   ENDIF
 ENDFOR
 IF (del_cnt > 0)
  DELETE  FROM br_hco_loc_reltn b,
    (dummyt d  WITH seq = value(del_cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_hco_id=temp_delete->hco[d.seq].hco_id))
   WITH nocounter
  ;end delete
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname =
   "Error removing relation from BR_HCO_LOC_RETN table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
  DELETE  FROM br_hco b,
    (dummyt d  WITH seq = value(del_cnt))
   SET b.seq = 1
   PLAN (d)
    JOIN (b
    WHERE (b.br_hco_id=temp_delete->hco[d.seq].hco_id))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Error removing from BR_HCO table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (updt_cnt > 0)
  UPDATE  FROM br_hco b,
    (dummyt d  WITH seq = value(updt_cnt))
   SET b.hco_nbr = temp_update->hco[d.seq].hco_nbr, b.hco_name = temp_update->hco[d.seq].hco_name, b
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
    updt_applctx,
    b.updt_cnt = (b.updt_cnt+ 1)
   PLAN (d)
    JOIN (b
    WHERE (b.br_hco_id=temp_update->hco[d.seq].hco_id))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Error updating BR_HCO table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 IF (reply_cnt > 0)
  IF (data_partition_ind=1)
   INSERT  FROM br_hco b,
     (dummyt d  WITH seq = value(reply_cnt))
    SET b.logical_domain_id = acm_get_curr_logical_domain_rep->logical_domain_id, b.br_hco_id = reply
     ->hco[d.seq].hco_id, b.hco_nbr = reply->hco[d.seq].hco_nbr,
     b.hco_name = reply->hco[d.seq].hco_name, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b
     .updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
    PLAN (d)
     JOIN (b)
    WITH nocounter
   ;end insert
  ELSE
   INSERT  FROM br_hco b,
     (dummyt d  WITH seq = value(reply_cnt))
    SET b.br_hco_id = reply->hco[d.seq].hco_id, b.hco_nbr = reply->hco[d.seq].hco_nbr, b.hco_name =
     reply->hco[d.seq].hco_name,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
    PLAN (d)
     JOIN (b)
    WITH nocounter
   ;end insert
  ENDIF
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Error inserting into BR_HCO table"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE logerror(namemsg,valuemsg)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = namemsg
   SET reply->status_data.subeventstatus[1].targetobjectvalue = valuemsg
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
