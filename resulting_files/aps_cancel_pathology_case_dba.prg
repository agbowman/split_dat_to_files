CREATE PROGRAM aps_cancel_pathology_case:dba
 RECORD reply(
   1 order_qual[*]
     2 id = f8
     2 order_id = f8
     2 action_flag = i2
   1 event_qual[*]
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 specimen[*]
     2 case_specimen_id = f8
     2 slide_cnt = i2
     2 slide_qual[*]
       3 slide_id = f8
       3 pt_exists = c1
     2 cassette_cnt = i2
     2 cassette_qual[*]
       3 cassette_id = f8
       3 pt_exists = c1
       3 slide_cnt = i2
       3 slide_qual[*]
         4 slide_id = f8
         4 pt_exists = c1
 )
 RECORD case_event(
   1 accession_nbr = c20
   1 event_id = f8
 )
 RECORD temp_entities(
   1 entity_qual[*]
     2 entity_id = f8
 )
 RECORD temp_comments(
   1 comment_qual[*]
     2 long_text_id = f8
 )
 RECORD temp_items(
   1 item_qual[*]
     2 parent_entity_id = f8
     2 parent_entity_name = c32
 )
 RECORD temp_reports(
   1 report_qual[*]
     2 report_id = f8
 )
 RECORD temp_tasks(
   1 task_qual[*]
     2 processing_task_id = f8
 )
 RECORD event(
   1 qual[1]
     2 parent_cd = f8
     2 event_cd = f8
 )
 RECORD purge_input(
   1 qual[1]
     2 blob_identifier = vc
 )
 RECORD purge_output(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD inventory(
   1 list[*]
     2 content_table_name = vc
     2 content_table_id = f8
   1 del_qual_cnt = i4
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET m_spec_cnt = 0
 SET m_cass_cnt = 0
 SET m_slid_cnt = 0
 SET m_spec_slid_cnt = 0
 SET cancel_status_cd = uar_get_code_by("MEANING",1305,"CANCEL")
 SET verified_status_cd = uar_get_code_by("MEANING",1305,"VERIFIED")
 SET corrected_status_cd = uar_get_code_by("MEANING",1305,"CORRECTED")
 SET signinproc_status_cd = uar_get_code_by("MEANING",1305,"SIGNINPROC")
 SET csigninproc_status_cd = uar_get_code_by("MEANING",1305,"CSIGNINPROC")
 SET code_set = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET x = 1
 SET order_cnt = 0
 SET event_cnt = 0
 SET comment_cnt = 0
 SET entity_cnt = 0
 SET report_cnt = 0
 SET task_cnt = 0
 SET item_cnt = 0
 SET report_index = 0
 SET deleted_status_cd = 0.0
 DECLARE case_uid = c128
 SET stat = alterlist(temp->specimen,1)
 SET stat = alterlist(temp->specimen[1].slide_qual,1)
 SET stat = alterlist(temp->specimen[1].cassette_qual,1)
 SET stat = alterlist(temp->specimen[1].cassette_qual[1].slide_qual,1)
 SET stat = alterlist(reply->order_qual,1)
 SELECT INTO "nl:"
  cr.report_id
  FROM case_report cr
  WHERE cr.status_cd IN (signinproc_status_cd, csigninproc_status_cd, corrected_status_cd,
  verified_status_cd)
   AND (cr.case_id=request->case_id)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pc.case_id
  FROM pathology_case pc
  WHERE (request->case_id=pc.case_id)
   AND pc.cancel_cd=0.0
  DETAIL
   case_event->accession_nbr = pc.accession_nbr, case_uid = pc.dataset_uid
  WITH nocounter, forupdate(pc)
 ;end select
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  GO TO exit_script
 ENDIF
 UPDATE  FROM pathology_case pc
  SET pc.case_id = request->case_id, pc.cancel_cd = request->cancel_cd, pc.cancel_dt_tm =
   cnvtdatetime(sysdate),
   pc.cancel_id = reqinfo->updt_id, pc.updt_dt_tm = cnvtdatetime(curdate,curtime), pc.updt_id =
   reqinfo->updt_id,
   pc.updt_task = reqinfo->updt_task, pc.updt_applctx = reqinfo->updt_applctx, pc.updt_cnt = (pc
   .updt_cnt+ 1)
  WHERE (pc.case_id=request->case_id)
   AND pc.cancel_cd=0.0
 ;end update
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  GO TO exit_script
 ENDIF
 IF (textlen(trim(case_event->accession_nbr)) > 0)
  EXECUTE aps_get_case_event_id
 ENDIF
 SET report_cnt = 0
 SET order_cnt = 0
 SELECT INTO "nl:"
  cr.case_id, cr.report_id
  FROM case_report cr
  PLAN (cr
   WHERE (request->case_id=cr.case_id)
    AND cr.cancel_cd=0.0
    AND  NOT (cr.status_cd IN (signinproc_status_cd, csigninproc_status_cd, corrected_status_cd,
   verified_status_cd)))
  DETAIL
   IF (cr.event_id > 0.0)
    event_cnt += 1, stat = alterlist(reply->event_qual,event_cnt), reply->event_qual[event_cnt].
    event_id = cr.event_id
   ENDIF
   report_cnt += 1
   IF (mod(report_cnt,10)=1)
    stat = alterlist(temp_reports->report_qual,(report_cnt+ 9))
   ENDIF
   temp_reports->report_qual[report_cnt].report_id = cr.report_id
  FOOT REPORT
   stat = alterlist(temp_reports->report_qual,report_cnt)
  WITH nocounter, forupdate(cr)
 ;end select
 IF (curqual != 0)
  SELECT INTO "nl:"
   rt.order_id
   FROM (dummyt d  WITH seq = value(report_cnt)),
    report_task rt
   PLAN (d)
    JOIN (rt
    WHERE (rt.report_id=temp_reports->report_qual[d.seq].report_id)
     AND ((rt.order_id+ 0) > 0))
   DETAIL
    order_cnt += 1
    IF (mod(order_cnt,10)=1)
     stat = alterlist(reply->order_qual,(order_cnt+ 9))
    ENDIF
    reply->order_qual[order_cnt].id = rt.report_id, reply->order_qual[order_cnt].order_id = rt
    .order_id, reply->order_qual[order_cnt].action_flag = 6
   FOOT REPORT
    stat = alterlist(reply->order_qual,order_cnt)
   WITH nocounter
  ;end select
  UPDATE  FROM case_report cr
   SET cr.case_id = request->case_id, cr.status_cd = cancel_status_cd, cr.status_dt_tm = cnvtdatetime
    (sysdate),
    cr.status_prsnl_id = reqinfo->updt_id, cr.cancel_cd = request->cancel_cd, cr.cancel_dt_tm =
    cnvtdatetime(sysdate),
    cr.cancel_prsnl_id = reqinfo->updt_id, cr.updt_dt_tm = cnvtdatetime(curdate,curtime), cr.updt_id
     = reqinfo->updt_id,
    cr.updt_task = reqinfo->updt_task, cr.updt_applctx = reqinfo->updt_applctx, cr.updt_cnt = (cr
    .updt_cnt+ 1)
   WHERE (cr.case_id=request->case_id)
    AND cr.cancel_cd=0.0
    AND  NOT (cr.status_cd IN (signinproc_status_cd, csigninproc_status_cd, corrected_status_cd,
   verified_status_cd))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_REPORT"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  cs.case_specimen_id, cassette_id = decode(c.seq,c.cassette_id,0.0), join_path = decode(s.seq,"S",s1
   .seq,"S1"," ")
  FROM case_specimen cs,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   cassette c,
   slide s,
   slide s1
  PLAN (cs
   WHERE (request->case_id=cs.case_id)
    AND cs.cancel_cd IN (null, 0.0))
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (c
   WHERE cs.case_specimen_id=c.case_specimen_id)
   JOIN (d2
   WHERE 1=d2.seq)
   JOIN (s
   WHERE c.cassette_id=s.cassette_id)
   ) ORJOIN ((d3
   WHERE 1=d3.seq)
   JOIN (s1
   WHERE cs.case_specimen_id=s1.case_specimen_id)
   ))
  ORDER BY cs.case_specimen_id, cassette_id
  HEAD REPORT
   spec_slid_cnt = 0, cass_cnt = 0, slid_cnt = 0,
   inv_cnt = 0
  HEAD cs.case_specimen_id
   spec_slid_cnt = 0, cass_cnt = 0, m_spec_cnt += 1,
   stat = alterlist(temp->specimen,m_spec_cnt), temp->specimen[m_spec_cnt].case_specimen_id = cs
   .case_specimen_id, temp->specimen[m_spec_cnt].cassette_cnt = 0,
   temp->specimen[m_spec_cnt].slide_cnt = 0
   IF ((request->cancel_cd != 0))
    inv_cnt += 1, stat = alterlist(inventory->list,inv_cnt), inventory->list[inv_cnt].
    content_table_name = "CASE_SPECIMEN",
    inventory->list[inv_cnt].content_table_id = cs.case_specimen_id
   ENDIF
  HEAD cassette_id
   slid_cnt = 0
   IF (cassette_id > 0.0)
    cass_cnt += 1, stat = alterlist(temp->specimen[m_spec_cnt].cassette_qual,cass_cnt), temp->
    specimen[m_spec_cnt].cassette_qual[cass_cnt].cassette_id = cassette_id,
    temp->specimen[m_spec_cnt].cassette_cnt = cass_cnt, temp->specimen[m_spec_cnt].cassette_qual[
    cass_cnt].slide_cnt = 0
    IF (cass_cnt > m_cass_cnt)
     m_cass_cnt = cass_cnt
    ENDIF
    IF ((request->cancel_cd != 0))
     inv_cnt += 1, stat = alterlist(inventory->list,inv_cnt), inventory->list[inv_cnt].
     content_table_name = "CASSETTE",
     inventory->list[inv_cnt].content_table_id = cassette_id
    ENDIF
   ENDIF
  DETAIL
   CASE (join_path)
    OF "S":
     slid_cnt += 1,stat = alterlist(temp->specimen[m_spec_cnt].cassette_qual[cass_cnt].slide_qual,
      slid_cnt),
     IF (slid_cnt > m_slid_cnt)
      m_slid_cnt = slid_cnt
     ENDIF
     ,temp->specimen[m_spec_cnt].cassette_qual[cass_cnt].slide_qual[slid_cnt].slide_id = s.slide_id,
     temp->specimen[m_spec_cnt].cassette_qual[cass_cnt].slide_cnt = slid_cnt,
     IF ((request->cancel_cd != 0))
      inv_cnt += 1, stat = alterlist(inventory->list,inv_cnt), inventory->list[inv_cnt].
      content_table_name = "SLIDE",
      inventory->list[inv_cnt].content_table_id = s.slide_id
     ENDIF
    OF "S1":
     spec_slid_cnt += 1,stat = alterlist(temp->specimen[m_spec_cnt].slide_qual,spec_slid_cnt),
     IF (spec_slid_cnt > m_spec_slid_cnt)
      m_spec_slid_cnt = spec_slid_cnt
     ENDIF
     ,temp->specimen[m_spec_cnt].slide_qual[spec_slid_cnt].slide_id = s1.slide_id,temp->specimen[
     m_spec_cnt].slide_cnt = spec_slid_cnt,
     IF ((request->cancel_cd != 0))
      inv_cnt += 1, stat = alterlist(inventory->list,inv_cnt), inventory->list[inv_cnt].
      content_table_name = "SLIDE",
      inventory->list[inv_cnt].content_table_id = s1.slide_id
     ENDIF
   ENDCASE
  FOOT  cassette_id
   IF (cass_cnt > 0)
    stat = alterlist(temp->specimen[m_spec_cnt].cassette_qual[cass_cnt].slide_qual,slid_cnt)
   ENDIF
  FOOT  cs.case_specimen_id
   stat = alterlist(temp->specimen[m_spec_cnt].cassette_qual,cass_cnt), stat = alterlist(temp->
    specimen[m_spec_cnt].slide_qual,spec_slid_cnt)
  FOOT REPORT
   inventory->del_qual_cnt = inv_cnt
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 SET stat = alterlist(temp->specimen,m_spec_cnt)
 IF ((inventory->del_qual_cnt > 0))
  EXECUTE scs_del_storage_content  WITH replace("REQUEST","INVENTORY"), replace("REPLY","REPLY")
  IF ((reply->status_data.status="F"))
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 FREE RECORD inventory
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  cs.case_id
  FROM case_specimen cs
  PLAN (cs
   WHERE (request->case_id=cs.case_id)
    AND cs.cancel_cd=0.0)
  WITH nocounter, forupdate(cs)
 ;end select
 IF (curqual != 0)
  UPDATE  FROM case_specimen cs
   SET cs.case_id = request->case_id, cs.cancel_cd = request->cancel_cd, cs.updt_dt_tm = cnvtdatetime
    (curdate,curtime),
    cs.updt_id = reqinfo->updt_id, cs.updt_task = reqinfo->updt_task, cs.updt_applctx = reqinfo->
    updt_applctx,
    cs.updt_cnt = (cs.updt_cnt+ 1)
   WHERE (cs.case_id=request->case_id)
    AND cs.cancel_cd=0.0
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "CASE_SPECIMEN"
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  pt.case_id
  FROM processing_task pt
  WHERE (request->case_id=pt.case_id)
   AND  NOT (pt.status_cd IN (cancel_status_cd, verified_status_cd))
  HEAD REPORT
   task_cnt = 0
  DETAIL
   IF (pt.create_inventory_flag != 4)
    task_cnt += 1
    IF (mod(task_cnt,10)=1)
     stat = alterlist(temp_tasks->task_qual,(task_cnt+ 9))
    ENDIF
    temp_tasks->task_qual[task_cnt].processing_task_id = pt.processing_task_id
   ENDIF
   IF (pt.order_id > 0.0)
    order_cnt += 1, stat = alterlist(reply->order_qual,order_cnt)
    IF (pt.create_inventory_flag=4)
     reply->order_qual[order_cnt].id = pt.case_specimen_id, reply->order_qual[order_cnt].order_id =
     pt.order_id, reply->order_qual[order_cnt].action_flag = 5
    ELSE
     reply->order_qual[order_cnt].id = pt.processing_task_id, reply->order_qual[order_cnt].order_id
      = pt.order_id, reply->order_qual[order_cnt].action_flag = 7
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_tasks->task_qual,task_cnt)
  WITH nocounter, forupdate(pt)
 ;end select
 SET stat = alterlist(reply->order_qual,order_cnt)
 IF (curqual != 0)
  UPDATE  FROM processing_task pt
   SET pt.case_id = request->case_id, pt.status_cd = cancel_status_cd, pt.status_dt_tm = cnvtdatetime
    (sysdate),
    pt.status_prsnl_id = reqinfo->updt_id, pt.cancel_cd = request->cancel_cd, pt.cancel_dt_tm =
    cnvtdatetime(sysdate),
    pt.cancel_prsnl_id = reqinfo->updt_id, pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id
     = reqinfo->updt_id,
    pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt
    .updt_cnt+ 1)
   WHERE (pt.case_id=request->case_id)
    AND  NOT (pt.status_cd IN (cancel_status_cd, verified_status_cd))
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (order_cnt > 0)
  INSERT  FROM ap_ops_exception aoe,
    (dummyt d  WITH seq = value(order_cnt))
   SET aoe.parent_id = reply->order_qual[d.seq].id, aoe.action_flag = reply->order_qual[d.seq].
    action_flag, aoe.active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   PLAN (d)
    JOIN (aoe
    WHERE (aoe.parent_id=reply->order_qual[d.seq].id)
     AND (aoe.action_flag=reply->order_qual[d.seq].action_flag))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != order_cnt)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION"
   GO TO exit_script
  ENDIF
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed,
     (dummyt d  WITH seq = value(order_cnt))
    SET aoed.action_flag = reply->order_qual[d.seq].action_flag, aoed.field_meaning = "TIME_ZONE",
     aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = reply->order_qual[d.seq].id, aoed.sequence = 1, aoed.updt_applctx = reqinfo->
     updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (aoed
     WHERE (aoed.parent_id=reply->order_qual[d.seq].id)
      AND (aoed.action_flag=reply->order_qual[d.seq].action_flag))
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (curqual != order_cnt)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION_DETAIL"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  join_path = decode(pt1.seq,"S",pt2.seq,"C",pt3.seq,
   "S1"," ")
  FROM processing_task pt1,
   processing_task pt2,
   processing_task pt3,
   (dummyt d1  WITH seq = value(evaluate(m_spec_cnt,0,1,m_spec_cnt))),
   (dummyt d2  WITH seq = value(evaluate(m_spec_slid_cnt,0,1,m_spec_slid_cnt))),
   (dummyt d3  WITH seq = value(evaluate(m_cass_cnt,0,1,m_cass_cnt))),
   (dummyt d4  WITH seq = value(evaluate(m_slid_cnt,0,1,m_slid_cnt))),
   (dummyt d5  WITH seq = value(evaluate(m_cass_cnt,0,1,m_cass_cnt)))
  PLAN (d1)
   JOIN (((d2
   WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
   JOIN (pt1
   WHERE (temp->specimen[d1.seq].case_specimen_id=pt1.case_specimen_id)
    AND (temp->specimen[d1.seq].slide_qual[d2.seq].slide_id=pt1.slide_id)
    AND pt1.cassette_id IN (null, 0)
    AND pt1.status_cd != cancel_status_cd)
   ) ORJOIN ((((d3
   WHERE (d3.seq <= temp->specimen[d1.seq].cassette_cnt))
   JOIN (pt2
   WHERE (temp->specimen[d1.seq].case_specimen_id=pt2.case_specimen_id)
    AND (temp->specimen[d1.seq].cassette_qual[d3.seq].cassette_id=pt2.cassette_id)
    AND pt2.slide_id IN (null, 0)
    AND pt2.status_cd != cancel_status_cd)
   ) ORJOIN ((d5
   WHERE (d5.seq <= temp->specimen[d1.seq].cassette_cnt))
   JOIN (d4
   WHERE (d4.seq <= temp->specimen[d1.seq].cassette_qual[d5.seq].slide_cnt))
   JOIN (pt3
   WHERE (temp->specimen[d1.seq].case_specimen_id=pt3.case_specimen_id)
    AND (temp->specimen[d1.seq].cassette_qual[d5.seq].cassette_id=pt3.cassette_id)
    AND (temp->specimen[d1.seq].cassette_qual[d5.seq].slide_qual[d4.seq].slide_id=pt3.slide_id)
    AND pt3.status_cd != cancel_status_cd)
   )) ))
  DETAIL
   CASE (join_path)
    OF "S":
     temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists = "Y"
    OF "C":
     temp->specimen[d1.seq].cassette_qual[d3.seq].pt_exists = "Y"
    OF "S1":
     temp->specimen[d1.seq].cassette_qual[d5.seq].pt_exists = "Y",temp->specimen[d1.seq].
     cassette_qual[d5.seq].slide_qual[d4.seq].pt_exists = "Y"
   ENDCASE
  WITH nocounter
 ;end select
 IF (m_cass_cnt > 0)
  IF (m_slid_cnt > 0)
   SELECT INTO "nl:"
    pt.case_id
    FROM processing_task pt,
     (dummyt d1  WITH seq = value(m_spec_cnt)),
     (dummyt d2  WITH seq = value(m_cass_cnt)),
     (dummyt d3  WITH seq = value(m_slid_cnt))
    PLAN (d1)
     JOIN (d2
     WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
     JOIN (d3
     WHERE (d3.seq <= temp->specimen[d1.seq].cassette_qual[d2.seq].slide_cnt))
     JOIN (pt
     WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].slide_id=pt.slide_id)
      AND (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].pt_exists != "Y"))
    WITH nocounter, forupdate(pt)
   ;end select
   IF (curqual != 0)
    UPDATE  FROM processing_task pt,
      (dummyt d1  WITH seq = value(m_spec_cnt)),
      (dummyt d2  WITH seq = value(m_cass_cnt)),
      (dummyt d3  WITH seq = value(m_slid_cnt))
     SET pt.slide_id = 0.0, pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo->
      updt_id,
      pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt
      .updt_cnt+ 1)
     PLAN (d1)
      JOIN (d2
      WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
      JOIN (d3
      WHERE (d3.seq <= temp->specimen[d1.seq].cassette_qual[d2.seq].slide_cnt))
      JOIN (pt
      WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].slide_id=pt.slide_id)
       AND (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].pt_exists != "Y"))
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = "T"
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
     GO TO exit_script
    ENDIF
    DELETE  FROM slide s,
      (dummyt d1  WITH seq = value(m_spec_cnt)),
      (dummyt d2  WITH seq = value(m_cass_cnt)),
      (dummyt d3  WITH seq = value(m_slid_cnt))
     SET s.seq = 1
     PLAN (d1)
      JOIN (d2
      WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
      JOIN (d3
      WHERE (d3.seq <= temp->specimen[d1.seq].cassette_qual[d2.seq].slide_cnt))
      JOIN (s
      WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].slide_id=s.slide_id)
       AND  NOT (s.slide_id IN (0, null))
       AND (temp->specimen[d1.seq].cassette_qual[d2.seq].slide_qual[d3.seq].pt_exists != "Y"))
     WITH nocounter
    ;end delete
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   pt.case_id
   FROM processing_task pt,
    (dummyt d1  WITH seq = value(m_spec_cnt)),
    (dummyt d2  WITH seq = value(m_cass_cnt))
   PLAN (d1)
    JOIN (d2
    WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
    JOIN (pt
    WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].cassette_id=pt.cassette_id)
     AND (temp->specimen[d1.seq].cassette_qual[d2.seq].pt_exists != "Y"))
   WITH nocounter, forupdate(pt)
  ;end select
  IF (curqual != 0)
   UPDATE  FROM processing_task pt,
     (dummyt d1  WITH seq = value(m_spec_cnt)),
     (dummyt d2  WITH seq = value(m_cass_cnt))
    SET pt.cassette_id = 0.0, pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo->
     updt_id,
     pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt
     .updt_cnt+ 1)
    PLAN (d1)
     JOIN (d2
     WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
     JOIN (pt
     WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].cassette_id=pt.cassette_id)
      AND (temp->specimen[d1.seq].cassette_qual[d2.seq].pt_exists != "Y"))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
    GO TO exit_script
   ENDIF
   DELETE  FROM cassette c,
     (dummyt d1  WITH seq = value(m_spec_cnt)),
     (dummyt d2  WITH seq = value(m_cass_cnt))
    SET c.seq = 1
    PLAN (d1)
     JOIN (d2
     WHERE (d2.seq <= temp->specimen[d1.seq].cassette_cnt))
     JOIN (c
     WHERE (temp->specimen[d1.seq].cassette_qual[d2.seq].cassette_id=c.cassette_id)
      AND  NOT (c.cassette_id IN (0, null))
      AND (temp->specimen[d1.seq].cassette_qual[d2.seq].pt_exists != "Y"))
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 IF (m_spec_slid_cnt > 0)
  SELECT INTO "nl:"
   pt.case_id
   FROM processing_task pt,
    (dummyt d1  WITH seq = value(m_spec_cnt)),
    (dummyt d2  WITH seq = value(m_spec_slid_cnt))
   PLAN (d1)
    JOIN (d2
    WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
    JOIN (pt
    WHERE (temp->specimen[d1.seq].slide_qual[d2.seq].slide_id=pt.slide_id)
     AND (temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists != "Y"))
   WITH nocounter, forupdate(pt)
  ;end select
  IF (curqual != 0)
   UPDATE  FROM processing_task pt,
     (dummyt d1  WITH seq = value(m_spec_cnt)),
     (dummyt d2  WITH seq = value(m_spec_slid_cnt))
    SET pt.slide_id = 0.0, pt.updt_dt_tm = cnvtdatetime(curdate,curtime), pt.updt_id = reqinfo->
     updt_id,
     pt.updt_task = reqinfo->updt_task, pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt
     .updt_cnt+ 1)
    PLAN (d1)
     JOIN (d2
     WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
     JOIN (pt
     WHERE (temp->specimen[d1.seq].slide_qual[d2.seq].slide_id=pt.slide_id)
      AND (temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists != "Y"))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
    GO TO exit_script
   ENDIF
   DELETE  FROM slide s,
     (dummyt d1  WITH seq = value(m_spec_cnt)),
     (dummyt d2  WITH seq = value(m_spec_slid_cnt))
    SET s.seq = 1
    PLAN (d1)
     JOIN (d2
     WHERE (d2.seq <= temp->specimen[d1.seq].slide_cnt))
     JOIN (s
     WHERE (temp->specimen[d1.seq].slide_qual[d2.seq].slide_id=s.slide_id)
      AND  NOT (s.slide_id IN (0, null))
      AND (temp->specimen[d1.seq].slide_qual[d2.seq].pt_exists != "Y"))
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
 DELETE  FROM long_text lt
  WHERE (request->case_id=lt.parent_entity_id)
   AND lt.parent_entity_name="AP_PROMPT_TEST"
  WITH nocounter
 ;end delete
 DELETE  FROM ap_prompt_test apt
  WHERE (request->case_id=apt.accession_id)
  WITH nocounter
 ;end delete
 IF ((request->case_id > 0)
  AND (request->cancel_cd > 0))
  DELETE  FROM ap_digital_slide_info adsi
   WHERE adsi.ap_digital_slide_id IN (
   (SELECT
    ads.ap_digital_slide_id
    FROM ap_digital_slide ads
    WHERE (ads.case_id=request->case_id)))
  ;end delete
  DELETE  FROM ap_digital_slide ads
   WHERE (ads.case_id=request->case_id)
  ;end delete
 ENDIF
 SELECT INTO "nl:"
  rdi.report_detail_id, br.blob_ref_id
  FROM report_detail_image rdi,
   blob_reference br,
   (dummyt d1  WITH seq = value(report_cnt))
  PLAN (d1)
   JOIN (rdi
   WHERE (rdi.report_id=temp_reports->report_qual[d1.seq].report_id))
   JOIN (br
   WHERE br.parent_entity_name="REPORT_DETAIL_IMAGE"
    AND br.parent_entity_id=rdi.report_detail_id
    AND br.valid_from_dt_tm < cnvtdatetime(sysdate)
    AND br.valid_until_dt_tm > cnvtdatetime(sysdate))
  HEAD REPORT
   item_cnt = 0
  DETAIL
   item_cnt += 1
   IF (mod(item_cnt,10)=1)
    stat = alterlist(temp_items->item_qual,(item_cnt+ 9))
   ENDIF
   temp_items->item_qual[item_cnt].parent_entity_id = br.blob_ref_id, temp_items->item_qual[item_cnt]
   .parent_entity_name = "BLOB_REFERENCE"
  WITH nocounter
 ;end select
 SET code_set = 48
 SET cdf_meaning = "DELETED"
 EXECUTE cpm_get_cd_for_cdf
 SET deleted_status_cd = code_value
 SET code_set = 73
 SET cdf_meaning = "APS02"
 EXECUTE cpm_get_cd_for_cdf
 SET event->qual[1].parent_cd = code_value
 EXECUTE aps_get_event_codes
 IF ((case_event->event_id > 0))
  SELECT INTO "nl:"
   ce1.event_id, ce2.event_id
   FROM clinical_event ce1,
    clinical_event ce2,
    (dummyt d1  WITH seq = 1)
   PLAN (ce1
    WHERE (ce1.event_id=case_event->event_id)
     AND ce1.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce1.valid_from_dt_tm < cnvtdatetime(sysdate))
    JOIN (d1)
    JOIN (ce2
    WHERE ce2.parent_event_id=ce1.event_id
     AND ce2.valid_until_dt_tm > cnvtdatetime(sysdate)
     AND ce2.valid_from_dt_tm < cnvtdatetime(sysdate)
     AND (ce2.event_cd=event->qual[1].event_cd)
     AND ce2.record_status_cd != deleted_status_cd)
   DETAIL
    item_cnt += 1
    IF (mod(item_cnt,10)=1)
     stat = alterlist(temp_items->item_qual,(item_cnt+ 9))
    ENDIF
    temp_items->item_qual[item_cnt].parent_entity_id = ce2.event_id, temp_items->item_qual[item_cnt].
    parent_entity_name = "CLINICAL_EVENT"
   WITH nocounter, outerjoin = d1
  ;end select
 ENDIF
 SET stat = alterlist(temp_items->item_qual,item_cnt)
 SET report_index = 0
 FOR (report_index = 1 TO report_cnt)
  SET request->report_id = temp_reports->report_qual[report_index].report_id
  EXECUTE aps_del_departmental_images
 ENDFOR
 SET item_cnt += 1
 SET stat = alterlist(temp_items->item_qual,item_cnt)
 SET temp_items->item_qual[item_cnt].parent_entity_id = request->case_id
 SET temp_items->item_qual[item_cnt].parent_entity_name = "PATHOLOGY_CASE"
 SELECT INTO "nl:"
  afe.entity_id
  FROM ap_folder_entity afe,
   (dummyt d1  WITH seq = value(item_cnt))
  PLAN (d1)
   JOIN (afe
   WHERE (afe.parent_entity_name=temp_items->item_qual[d1.seq].parent_entity_name)
    AND (afe.parent_entity_id=temp_items->item_qual[d1.seq].parent_entity_id))
  HEAD REPORT
   entity_cnt = 0, comment_cnt = 0
  DETAIL
   entity_cnt += 1
   IF (mod(entity_cnt,10)=1)
    stat = alterlist(temp_entities->entity_qual,(entity_cnt+ 9))
   ENDIF
   temp_entities->entity_qual[entity_cnt].entity_id = afe.entity_id
   IF (afe.comment_id > 0)
    comment_cnt += 1
    IF (mod(comment_cnt,10)=1)
     stat = alterlist(temp_comments->comment_qual,(comment_cnt+ 9))
    ENDIF
    temp_comments->comment_qual[comment_cnt].long_text_id = afe.comment_id
   ENDIF
  FOOT REPORT
   stat = alterlist(temp_entities->entity_qual,entity_cnt), stat = alterlist(temp_comments->
    comment_qual,comment_cnt)
  WITH nocounter
 ;end select
 IF (entity_cnt > 0)
  DELETE  FROM ap_folder_entity afe,
    (dummyt d  WITH seq = value(entity_cnt))
   SET afe.entity_id = temp_entities->entity_qual[d.seq].entity_id
   PLAN (d)
    JOIN (afe
    WHERE (afe.entity_id=temp_entities->entity_qual[d.seq].entity_id))
   WITH nocounter
  ;end delete
  IF (curqual != entity_cnt)
   SET failed = "T"
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ENTITY"
   GO TO exit_script
  ENDIF
  IF (comment_cnt > 0)
   DELETE  FROM long_text lt,
     (dummyt d  WITH seq = value(comment_cnt))
    SET lt.long_text_id = temp_comments->comment_qual[d.seq].long_text_id
    PLAN (d)
     JOIN (lt
     WHERE (lt.long_text_id=temp_comments->comment_qual[d.seq].long_text_id))
    WITH nocounter
   ;end delete
   IF (curqual != comment_cnt)
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (textlen(trim(case_uid)) > 0)
  IF (((textlen(trim(case_uid)) != 1) OR (trim(case_uid) != "0")) )
   SET purge_input->qual[1].blob_identifier = case_uid
   EXECUTE aps_add_blobs_to_purge
   IF ((purge_output->status_data.status != "S"))
    SET failed = "T"
    SET reply->status_data.subeventstatus[1].operationname = purge_output->status_data.
    subeventstatus[1].operationname
    SET reply->status_data.subeventstatus[1].operationstatus = purge_output->status_data.
    subeventstatus[1].operationstatus
    SET reply->status_data.subeventstatus[1].targetobjectname = purge_output->status_data.
    subeventstatus[1].targetobjectname
    SET reply->status_data.subeventstatus[1].targetobjectvalue = purge_output->status_data.
    subeventstatus[1].targetobjectvalue
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
