CREATE PROGRAM bed_ens_ic_disclaim_supress:dba
 IF ( NOT (validate(reply,0)))
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
 DECLARE long_text_id = f8 WITH protect
 DECLARE new_id = f8 WITH protect
 DECLARE req_size = i4 WITH protect
 FREE SET temp_req
 RECORD temp_req(
   1 req_items[*]
     2 action_flag = i2
     2 disclaimer_text = vc
     2 suppression_ind = i2
     2 organism_code_value = f8
     2 facility_code_value = f8
     2 group_id = f8
     2 antibiotic_code_value = f8
     2 new_long_text_id = f8
     2 new_dsc_id = f8
     2 upt_long_text_id = f8
     2 upt_org_dsc_id = f8
 )
 SET req_size = size(request->items,5)
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(temp_req->req_items,req_size)
 FOR (x = 1 TO req_size)
   IF ((request->items[x].action_flag=1))
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    CALL bederrorcheck("Sequence Error")
    IF ((request->items[x].disclaimer_text > " "))
     SELECT INTO "nl:"
      j = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       long_text_id = cnvtreal(j)
      WITH format, nocounter
     ;end select
    ENDIF
    SET temp_req->req_items[x].new_long_text_id = long_text_id
    SET temp_req->req_items[x].new_dsc_id = new_id
   ENDIF
   SET temp_req->req_items[x].action_flag = request->items[x].action_flag
   SET temp_req->req_items[x].disclaimer_text = request->items[x].disclaimer_text
   SET temp_req->req_items[x].suppression_ind = request->items[x].suppression_ind
   SET temp_req->req_items[x].organism_code_value = request->items[x].organism_code_value
   SET temp_req->req_items[x].facility_code_value = request->items[x].facility_code_value
   SET temp_req->req_items[x].group_id = request->items[x].group_id
   SET temp_req->req_items[x].antibiotic_code_value = request->items[x].anitbiotic_code_value
 ENDFOR
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(req_size)),
   lh_cnt_ic_antibgrm_org_dsc dsc
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag IN (2, 3)))
   JOIN (dsc
   WHERE (dsc.antibiotic_cd=temp_req->req_items[d.seq].antibiotic_code_value)
    AND (dsc.facility_cd=temp_req->req_items[d.seq].facility_code_value)
    AND (dsc.lh_cnt_ic_antibgrm_group_id=temp_req->req_items[d.seq].group_id)
    AND (dsc.organism_cd=temp_req->req_items[d.seq].organism_code_value))
  DETAIL
   temp_req->req_items[d.seq].upt_long_text_id = dsc.long_text_id, temp_req->req_items[d.seq].
   upt_org_dsc_id = dsc.lh_cnt_ic_antibgrm_org_dsc_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("Select Error")
 CALL echorecord(temp_req)
 INSERT  FROM long_text_reference lt,
   (dummyt d  WITH seq = value(req_size))
  SET lt.long_text_id = temp_req->req_items[d.seq].new_long_text_id, lt.parent_entity_name =
   "LH_CNT_IC_ANTIBGRM_ORG_DSC", lt.parent_entity_id = temp_req->req_items[d.seq].new_dsc_id,
   lt.long_text = temp_req->req_items[d.seq].disclaimer_text, lt.active_ind = 1, lt.updt_applctx =
   reqinfo->updt_applctx,
   lt.updt_id = reqinfo->updt_id, lt.updt_cnt = 0, lt.updt_task = reqinfo->updt_task,
   lt.updt_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=1)
    AND (temp_req->req_items[d.seq].disclaimer_text > " ")
    AND (temp_req->req_items[d.seq].new_long_text_id > 0.0))
   JOIN (lt)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Insert disclaimer suppresion long text table Error")
 INSERT  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
   (dummyt d  WITH seq = value(req_size))
  SET dsc.antibiotic_cd = temp_req->req_items[d.seq].antibiotic_code_value, dsc.facility_cd =
   temp_req->req_items[d.seq].facility_code_value, dsc.lh_cnt_ic_antibgrm_group_id = temp_req->
   req_items[d.seq].group_id,
   dsc.long_text_id = temp_req->req_items[d.seq].new_long_text_id, dsc.organism_cd = temp_req->
   req_items[d.seq].organism_code_value, dsc.suppress_ind = temp_req->req_items[d.seq].
   suppression_ind,
   dsc.lh_cnt_ic_antibgrm_org_dsc_id = temp_req->req_items[d.seq].new_dsc_id, dsc.updt_applctx =
   reqinfo->updt_applctx, dsc.updt_id = reqinfo->updt_id,
   dsc.updt_cnt = 0, dsc.updt_task = reqinfo->updt_task, dsc.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=1)
    AND (temp_req->req_items[d.seq].new_dsc_id > 0.0))
   JOIN (dsc)
  WITH nocounter
 ;end insert
 CALL bederrorcheck("Disclaimer Suppression Insert Error")
 UPDATE  FROM long_text_reference lt,
   (dummyt d  WITH seq = value(req_size))
  SET lt.long_text = temp_req->req_items[d.seq].disclaimer_text, lt.updt_applctx = reqinfo->
   updt_applctx, lt.updt_id = reqinfo->updt_id,
   lt.updt_cnt = (lt.updt_cnt+ 1), lt.updt_task = reqinfo->updt_task, lt.updt_dt_tm = cnvtdatetime(
    curdate,curtime3)
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=2)
    AND (temp_req->req_items[d.seq].upt_long_text_id > 0.0)
    AND (temp_req->req_items[d.seq].disclaimer_text > " "))
   JOIN (lt
   WHERE (lt.long_text_id=temp_req->req_items[d.seq].upt_long_text_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Insert disclaimer suppresion long text table Error")
 FOR (x = 1 TO req_size)
   IF ((temp_req->req_items[x].upt_long_text_id=0)
    AND (temp_req->req_items[x].action_flag=2)
    AND (temp_req->req_items[x].disclaimer_text > " "))
    SELECT INTO "nl:"
     j = seq(long_data_seq,nextval)
     FROM dual
     DETAIL
      temp_req->req_items[x].upt_long_text_id = cnvtreal(j)
     WITH format, nocounter
    ;end select
    INSERT  FROM long_text_reference lt
     SET lt.long_text_id = temp_req->req_items[x].upt_long_text_id, lt.parent_entity_name =
      "LH_CNT_IC_ANTIBGRM_ORG_DSC", lt.parent_entity_id = temp_req->req_items[x].upt_org_dsc_id,
      lt.long_text = temp_req->req_items[x].disclaimer_text, lt.active_ind = 1, lt.updt_applctx =
      reqinfo->updt_applctx,
      lt.updt_id = reqinfo->updt_id, lt.updt_cnt = 0, lt.updt_task = reqinfo->updt_task,
      lt.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     PLAN (lt)
     WITH nocounter
    ;end insert
    CALL bederrorcheck("Insert disclaimer suppresion long text table Error")
   ENDIF
 ENDFOR
 UPDATE  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
   (dummyt d  WITH seq = value(req_size))
  SET dsc.suppress_ind = temp_req->req_items[d.seq].suppression_ind, dsc.updt_applctx = reqinfo->
   updt_applctx, dsc.updt_id = reqinfo->updt_id,
   dsc.updt_cnt = 0, dsc.updt_task = reqinfo->updt_task, dsc.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   dsc.long_text_id =
   IF ((temp_req->req_items[d.seq].disclaimer_text > " ")) temp_req->req_items[d.seq].
    upt_long_text_id
   ELSE 0.0
   ENDIF
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=2))
   JOIN (dsc
   WHERE (dsc.antibiotic_cd=temp_req->req_items[d.seq].antibiotic_code_value)
    AND (dsc.facility_cd=temp_req->req_items[d.seq].facility_code_value)
    AND (dsc.lh_cnt_ic_antibgrm_group_id=temp_req->req_items[d.seq].group_id)
    AND (dsc.organism_cd=temp_req->req_items[d.seq].organism_code_value))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Disclaimer Suppression Insert Error")
 DELETE  FROM long_text_reference lt,
   (dummyt d  WITH seq = value(req_size))
  SET lt.seq = 1
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=2)
    AND (temp_req->req_items[d.seq].upt_long_text_id > 0.0)
    AND (temp_req->req_items[d.seq].disclaimer_text IN (" ", "", null)))
   JOIN (lt
   WHERE (lt.long_text_id=temp_req->req_items[d.seq].upt_long_text_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Disclaimer Text Delete Error")
 DELETE  FROM lh_cnt_ic_antibgrm_org_dsc dsc,
   (dummyt d  WITH seq = value(req_size))
  SET dsc.seq = 1
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=3)
    AND (temp_req->req_items[d.seq].upt_org_dsc_id > 0.0))
   JOIN (dsc
   WHERE (dsc.lh_cnt_ic_antibgrm_org_dsc_id=temp_req->req_items[d.seq].upt_org_dsc_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Disclaimer Delete Error")
 DELETE  FROM long_text_reference lt,
   (dummyt d  WITH seq = value(req_size))
  SET lt.seq = 1
  PLAN (d
   WHERE (temp_req->req_items[d.seq].action_flag=3)
    AND (temp_req->req_items[d.seq].upt_long_text_id > 0.0))
   JOIN (lt
   WHERE (lt.long_text_id=temp_req->req_items[d.seq].upt_long_text_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Long Text Delete Error")
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
