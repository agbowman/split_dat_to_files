CREATE PROGRAM bed_ens_docset_task:dba
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
 FREE SET temp_dtas
 RECORD temp_dtas(
   1 task_dtas[*]
     2 ref_task_id = f8
     2 task_assay_cd = f8
     2 required_ind = i2
     2 sequence = i4
 )
 FREE SET bedrock_request
 RECORD bedrock_request(
   1 doc_sets[*]
     2 action_flag = i2
     2 doc_set_ref_id = f8
     2 reference_task_id = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET req_cnt = 0
 SET req_cnt = size(request->doc_sets,5)
 IF (req_cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(bedrock_request->doc_sets,req_cnt)
 FOR (bx = 1 TO req_cnt)
   SET bedrock_request->doc_sets[bx].action_flag = request->doc_sets[bx].action_flag
   SET bedrock_request->doc_sets[bx].doc_set_ref_id = request->doc_sets[bx].doc_set_ref_id
   SET bedrock_request->doc_sets[bx].reference_task_id = request->doc_sets[bx].reference_task_id
 ENDFOR
 SET docset_code = 0.0
 SET docset_code = uar_get_code_by("MEANING",255090,"DOCSET")
 SET active_cd = 0.0
 SET active_cd = uar_get_code_by("MEANING",48,"ACTIVE")
 SET ierrcode = 0
 INSERT  FROM task_charting_agent_r t,
   (dummyt d  WITH seq = value(req_cnt))
  SET t.task_charting_agent_r_id = seq(reference_seq,nextval), t.reference_task_id = bedrock_request
   ->doc_sets[d.seq].reference_task_id, t.charting_agent_cd = docset_code,
   t.charting_agent_entity_name = "DOC_SET_REF", t.charting_agent_entity_id = bedrock_request->
   doc_sets[d.seq].doc_set_ref_id, t.charting_agent_identifier = "",
   t.updt_id = reqinfo->updt_id, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo
   ->updt_task,
   t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0
  PLAN (d
   WHERE (bedrock_request->doc_sets[d.seq].action_flag=1))
   JOIN (t)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM task_charting_agent_r t,
   (dummyt d  WITH seq = value(req_cnt))
  SET t.seq = 1
  PLAN (d
   WHERE (bedrock_request->doc_sets[d.seq].action_flag=3))
   JOIN (t
   WHERE t.charting_agent_entity_name="DOC_SET_REF"
    AND (t.charting_agent_entity_id=bedrock_request->doc_sets[d.seq].doc_set_ref_id)
    AND (t.reference_task_id=bedrock_request->doc_sets[d.seq].reference_task_id)
    AND t.charting_agent_cd=docset_code)
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on delete")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 DELETE  FROM task_discrete_r t,
   (dummyt d  WITH seq = value(req_cnt))
  SET t.seq = 1
  PLAN (d
   WHERE (bedrock_request->doc_sets[d.seq].action_flag IN (1, 3)))
   JOIN (t
   WHERE (t.reference_task_id=bedrock_request->doc_sets[d.seq].reference_task_id))
  WITH nocounter
 ;end delete
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Error on delete from task_discrete_r")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO req_cnt)
   IF ((bedrock_request->doc_sets[x].action_flag=1))
    SET tot_dta_cnt = 0
    SET stat = alterlist(temp_dtas->task_dtas,0)
    SELECT INTO "nl:"
     FROM doc_set_section_ref_r dssrr,
      doc_set_section_ref dssr,
      doc_set_element_ref dser
     PLAN (dssrr
      WHERE (dssrr.doc_set_ref_id=bedrock_request->doc_sets[x].doc_set_ref_id)
       AND dssrr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND dssrr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND dssrr.active_ind=1)
      JOIN (dssr
      WHERE dssr.doc_set_section_ref_id=dssrr.doc_set_section_ref_id
       AND dssr.active_ind=1)
      JOIN (dser
      WHERE dser.doc_set_section_ref_id=dssr.doc_set_section_ref_id
       AND dser.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
       AND dser.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
       AND dser.active_ind=1
       AND dser.task_assay_cd > 0)
     ORDER BY dser.task_assay_cd
     HEAD REPORT
      dta_cnt = 0, tot_dta_cnt = 0, stat = alterlist(temp_dtas->task_dtas,10)
     HEAD dser.task_assay_cd
      dta_cnt = (dta_cnt+ 1), tot_dta_cnt = (tot_dta_cnt+ 1)
      IF (dta_cnt > 10)
       stat = alterlist(temp_dtas->task_dtas,(tot_dta_cnt+ 10)), dta_cnt = 1
      ENDIF
      temp_dtas->task_dtas[tot_dta_cnt].task_assay_cd = dser.task_assay_cd, temp_dtas->task_dtas[
      tot_dta_cnt].required_ind = dser.required_ind
     FOOT REPORT
      stat = alterlist(temp_dtas->task_dtas,tot_dta_cnt)
     WITH nocounter
    ;end select
    IF (tot_dta_cnt > 0)
     SET ierrcode = 0
     INSERT  FROM task_discrete_r tdr,
       (dummyt d  WITH seq = value(tot_dta_cnt))
      SET tdr.active_ind = 1, tdr.reference_task_id = bedrock_request->doc_sets[x].reference_task_id,
       tdr.required_ind = temp_dtas->task_dtas[d.seq].required_ind,
       tdr.sequence = d.seq, tdr.task_assay_cd = temp_dtas->task_dtas[d.seq].task_assay_cd, tdr
       .updt_applctx = reqinfo->updt_applctx,
       tdr.updt_cnt = 0, tdr.updt_dt_tm = cnvtdatetime(curdate,curtime3), tdr.updt_id = reqinfo->
       updt_id,
       tdr.updt_task = reqinfo->updt_task
      PLAN (d)
       JOIN (tdr)
      WITH nocounter
     ;end insert
     SET ierrcode = error(serrmsg,1)
     IF (ierrcode > 0)
      SET error_flag = "Y"
      SET stat = alterlist(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].targetobjectname = concat(
       "Error on insert task_discrete_r")
      SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FREE SET request
 RECORD request(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 careset_ind = i2
     2 ext_owner_cd = f8
     2 ext_description = c100
     2 ext_short_desc = c50
     2 workload_only_ind = i2
     2 price_qual = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
     2 child_qual = i2
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 child_seq = i4
       3 bi_id = f8
       3 ext_owner_cd = f8
 )
 FREE SET reply
 RECORD reply(
   1 bill_item_qual = i4
   1 bill_item[*]
     2 bill_item_id = f8
   1 qual[*]
     2 bill_item_id = f8
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[10]
     2 bill_item_mod_id = f8
   1 actioncnt = i2
   1 actionlist[*]
     2 action1 = vc
     2 action2 = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c20
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET task_cat_code = uar_get_code_by("MEANING",13016,"TASKCAT")
 SET task_code = uar_get_code_by("MEANING",106,"TASK")
 SET task_assay_code = uar_get_code_by("MEANING",13016,"TASK ASSAY")
 SET tot_tcnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_cnt)),
   task_discrete_r t,
   order_task o,
   discrete_task_assay a
  PLAN (d)
   JOIN (t
   WHERE (t.reference_task_id=bedrock_request->doc_sets[d.seq].reference_task_id)
    AND t.active_ind=1)
   JOIN (o
   WHERE o.reference_task_id=t.reference_task_id)
   JOIN (a
   WHERE a.task_assay_cd=t.task_assay_cd)
  ORDER BY t.reference_task_id, a.task_assay_cd
  HEAD REPORT
   tcnt = 0, tot_tcnt = 0, stat = alterlist(request->qual,10)
  HEAD t.reference_task_id
   tcnt = (tcnt+ 1), tot_tcnt = (tot_tcnt+ 1)
   IF (tcnt > 10)
    stat = alterlist(request->qual,(tot_tcnt+ 10)), tcnt = 1
   ENDIF
   request->qual[tot_tcnt].action = 1, request->qual[tot_tcnt].ext_id = t.reference_task_id, request
   ->qual[tot_tcnt].ext_contributor_cd = task_cat_code,
   request->qual[tot_tcnt].parent_qual_ind = 1, request->qual[tot_tcnt].careset_ind = 0, request->
   qual[tot_tcnt].ext_owner_cd = task_code,
   request->qual[tot_tcnt].ext_description = o.task_description, request->qual[tot_tcnt].
   ext_short_desc = trim(substring(1,50,o.task_description)), dcnt = 0,
   dtcnt = 0, stat = alterlist(request->qual[tot_tcnt].children,10)
  HEAD a.task_assay_cd
   dcnt = (dcnt+ 1), dtcnt = (dtcnt+ 1)
   IF (dcnt > 10)
    stat = alterlist(request->qual[tot_tcnt].children,(dtcnt+ 10)), dcnt = 1
   ENDIF
   request->qual[tot_tcnt].children[dtcnt].ext_id = a.task_assay_cd, request->qual[tot_tcnt].
   children[dtcnt].ext_contributor_cd = task_assay_code, request->qual[tot_tcnt].children[dtcnt].
   ext_description = a.description,
   request->qual[tot_tcnt].children[dtcnt].ext_short_desc = a.mnemonic, request->qual[tot_tcnt].
   children[dtcnt].ext_owner_cd = a.activity_type_cd
  FOOT  t.reference_task_id
   request->qual[tot_tcnt].child_qual = dtcnt, stat = alterlist(request->qual[tot_tcnt].children,
    dtcnt)
  FOOT REPORT
   request->nbr_of_recs = tot_tcnt, stat = alterlist(request->qual,tot_tcnt)
  WITH nocounter
 ;end select
 IF (tot_tcnt > 0)
  EXECUTE afc_add_reference_api
  DECLARE child_rep = vc
  SET child_rep = reply->status_data.status
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
  IF (child_rep != "S")
   SET error_flag = "Y"
   SET stat = alterlist(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectname = concat(
    "Error from afc_add_reference_api")
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   GO TO exit_script
  ENDIF
 ENDIF
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
