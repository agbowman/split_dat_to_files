CREATE PROGRAM aps_add_billing_tasks:dba
 RECORD reply(
   1 task_qual[1]
     2 processing_task_id = f8
   1 updt_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET comment_cnt = 0
 SET nbr_add_tasks = 0
 SET nbr_chg_tasks = 0
 SET nbr_del_tasks = 0
 SET nbr_items = 0
 SET updt_cnts_array[1000] = 0
 SET cnt = 0
 SET x = 0
 DECLARE ordered_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE verified_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE cancelled_status_cd = f8 WITH public, noconstant(0.0)
 DECLARE order_id_array[1000] = f8 WITH public, noconstant(0.0)
 SET reply->updt_id = reqinfo->updt_id
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1305
   AND ((cv.cdf_meaning="VERIFIED") OR (((cv.cdf_meaning="CANCEL") OR (cv.cdf_meaning="ORDERED")) ))
  HEAD REPORT
   verified_status_cd = 0.0, cancelled_status_cd = 0.0, ordered_status_cd = 0.0
  DETAIL
   IF (cv.cdf_meaning="VERIFIED")
    verified_status_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="CANCEL")
    cancelled_status_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ORDERED")
    ordered_status_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET nbr_add_tasks = cnvtint(size(request->task_add_qual,5))
 IF (nbr_add_tasks > 0)
  SET stat = alter(reply->task_qual,nbr_add_tasks)
  FOR (x = 1 TO nbr_add_tasks)
   SELECT INTO "nl:"
    seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     reply->task_qual[x].processing_task_id = seq_nbr
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
  ENDFOR
  FOR (x = 1 TO nbr_add_tasks)
    IF (textlen(trim(request->task_add_qual[x].comment)) > 0)
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      HEAD REPORT
       comment_cnt = 0
      DETAIL
       request->task_add_qual[x].comments_long_text_id = seq_nbr, comment_cnt = (comment_cnt+ 1)
      WITH format, counter
     ;end select
    ENDIF
  ENDFOR
  INSERT  FROM long_text lt,
    (dummyt d  WITH seq = value(nbr_add_tasks))
   SET lt.long_text_id = request->task_add_qual[d.seq].comments_long_text_id, lt.long_text = request
    ->task_add_qual[d.seq].comment, lt.parent_entity_id = request->task_add_qual[d.seq].
    processing_task_id,
    lt.parent_entity_name = "PROCESSING_TASK_COMMENTS", lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime
    (curdate,curtime3),
    lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
    updt_applctx,
    lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
    cnvtdatetime(curdate,curtime3),
    lt.active_status_prsnl_id = reqinfo->updt_id
   PLAN (d
    WHERE (request->task_add_qual[d.seq].comments_long_text_id != 0))
    JOIN (lt
    WHERE (lt.long_text_id=request->task_add_qual[d.seq].comments_long_text_id))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != comment_cnt)
   GO TO insert_long_text_failed
  ENDIF
  INSERT  FROM processing_task pt,
    (dummyt d  WITH seq = value(nbr_add_tasks))
   SET pt.processing_task_id = reply->task_qual[d.seq].processing_task_id, pt.case_id = request->
    case_id, pt.case_specimen_id = request->task_add_qual[d.seq].case_specimen_id,
    pt.case_specimen_tag_id = request->task_add_qual[d.seq].case_specimen_tag_cd, pt.cassette_id =
    request->task_add_qual[d.seq].cassette_id, pt.cassette_tag_id = request->task_add_qual[d.seq].
    cassette_tag_cd,
    pt.slide_id = request->task_add_qual[d.seq].slide_id, pt.slide_tag_id = request->task_add_qual[d
    .seq].slide_tag_cd, pt.create_inventory_flag = 0,
    pt.task_assay_cd = request->task_add_qual[d.seq].task_assay_cd, pt.priority_cd = request->
    task_add_qual[d.seq].priority_cd, pt.research_account_id = request->task_add_qual[d.seq].
    research_account_id,
    pt.service_resource_cd = request->task_add_qual[d.seq].service_resource_cd, pt
    .comments_long_text_id = request->task_add_qual[d.seq].comments_long_text_id, pt.request_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pt.request_prsnl_id = reqinfo->updt_id, pt.status_cd =
    IF ((request->task_add_qual[d.seq].verifying_prsnl_id != 0.0)) verified_status_cd
    ELSE ordered_status_cd
    ENDIF
    , pt.status_prsnl_id =
    IF ((request->task_add_qual[d.seq].verifying_prsnl_id != 0.0)) request->task_add_qual[d.seq].
     verifying_prsnl_id
    ELSE reqinfo->updt_id
    ENDIF
    ,
    pt.status_dt_tm = cnvtdatetime(curdate,curtime3), pt.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    pt.updt_id = reqinfo->updt_id,
    pt.updt_task = reqinfo->updt_task, pt.updt_cnt = 0, pt.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (pt
    WHERE (pt.processing_task_id=request->task_add_qual[d.seq].processing_task_id))
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_add_tasks)
   GO TO insert_processing_task_failed
  ENDIF
  INSERT  FROM ap_ops_exception aoe,
    (dummyt d  WITH seq = value(nbr_add_tasks))
   SET aoe.parent_id = reply->task_qual[d.seq].processing_task_id, aoe.action_flag = 4, aoe
    .active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   PLAN (d)
    JOIN (aoe
    WHERE (reply->task_qual[d.seq].processing_task_id=aoe.parent_id)
     AND aoe.action_flag=4)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_add_tasks)
   GO TO insert_ops_exception_failed
  ENDIF
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed,
     (dummyt d  WITH seq = value(nbr_add_tasks))
    SET aoed.action_flag = 4, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = reply->task_qual[d.seq].processing_task_id, aoed.sequence = 1, aoed
     .updt_applctx = reqinfo->updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (aoed
     WHERE (reply->task_qual[d.seq].processing_task_id=aoed.parent_id)
      AND aoed.action_flag=4
      AND aoed.sequence=1)
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (curqual != nbr_add_tasks)
    GO TO insert_ops_exception_detail_failed
   ENDIF
  ENDIF
  INSERT  FROM ap_ops_exception aoe,
    (dummyt d  WITH seq = value(nbr_add_tasks))
   SET aoe.parent_id = reply->task_qual[d.seq].processing_task_id, aoe.action_flag = 7, aoe
    .active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   PLAN (d
    WHERE (request->task_add_qual[d.seq].verifying_prsnl_id != 0.0))
    JOIN (aoe
    WHERE (reply->task_qual[d.seq].processing_task_id=aoe.parent_id)
     AND aoe.action_flag=7)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  INSERT  FROM ap_ops_exception_detail aoed,
    (dummyt d  WITH seq = value(nbr_add_tasks))
   SET aoed.parent_id = reply->task_qual[d.seq].processing_task_id, aoed.action_flag = 7, aoed
    .sequence = 1,
    aoed.field_meaning = "VERIFYING_PRSNL_ID", aoed.field_id = request->task_add_qual[d.seq].
    verifying_prsnl_id, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime),
    aoed.updt_id = reqinfo->updt_id, aoed.updt_task = reqinfo->updt_task, aoed.updt_applctx = reqinfo
    ->updt_applctx,
    aoed.updt_cnt = 0
   PLAN (d
    WHERE (request->task_add_qual[d.seq].verifying_prsnl_id != 0.0))
    JOIN (aoed
    WHERE (reply->task_qual[d.seq].processing_task_id=aoed.parent_id)
     AND aoed.action_flag=7
     AND aoed.sequence=1)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  INSERT  FROM ap_ops_exception_detail aoed,
    (dummyt d  WITH seq = value(nbr_add_tasks))
   SET aoed.parent_id = reply->task_qual[d.seq].processing_task_id, aoed.action_flag = 7, aoed
    .sequence = 2,
    aoed.field_meaning = "DATE_OF_SERVICE", aoed.field_id = request->task_add_qual[d.seq].
    date_of_service_cd, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime),
    aoed.updt_id = reqinfo->updt_id, aoed.updt_task = reqinfo->updt_task, aoed.updt_applctx = reqinfo
    ->updt_applctx,
    aoed.updt_cnt = 0
   PLAN (d
    WHERE (request->task_add_qual[d.seq].verifying_prsnl_id != 0.0))
    JOIN (aoed
    WHERE (reply->task_qual[d.seq].processing_task_id=aoed.parent_id)
     AND aoed.action_flag=7
     AND aoed.sequence=2)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed,
     (dummyt d  WITH seq = value(nbr_add_tasks))
    SET aoed.action_flag = 7, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = reply->task_qual[d.seq].processing_task_id, aoed.sequence = 3, aoed
     .updt_applctx = reqinfo->updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (request->task_add_qual[d.seq].verifying_prsnl_id != 0.0))
     JOIN (aoed
     WHERE (reply->task_qual[d.seq].processing_task_id=aoed.parent_id)
      AND aoed.action_flag=7
      AND aoed.sequence=3)
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
  ENDIF
 ENDIF
 SET nbr_chg_tasks = cnvtint(size(request->task_chg_qual,5))
 IF (nbr_chg_tasks > 0)
  SELECT INTO "nl:"
   pt.case_specimen_id
   FROM processing_task pt,
    (dummyt d  WITH seq = value(nbr_chg_tasks))
   PLAN (d)
    JOIN (pt
    WHERE (pt.processing_task_id=request->task_chg_qual[d.seq].processing_task_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1), order_id_array[nbr_items] = pt.order_id, updt_cnts_array[nbr_items]
     = pt.updt_cnt
   WITH nocounter, forupdate(pt)
  ;end select
  IF (nbr_items != nbr_chg_tasks)
   GO TO lock_processing_task_failed
  ENDIF
  FOR (x = 1 TO nbr_chg_tasks)
    IF ((request->task_chg_qual[x].updt_cnt != updt_cnts_array[x]))
     IF ((request->task_chg_qual[x].order_id != order_id_array[x])
      AND (order_id_array[x] != 0))
      SET x = x
     ELSE
      GO TO lock_processing_task_failed
     ENDIF
    ENDIF
  ENDFOR
  FOR (x = 1 TO nbr_chg_tasks)
    IF (textlen(trim(request->task_chg_qual[x].comment)) > 0
     AND (request->task_chg_qual[x].comments_long_text_id=0))
     SELECT INTO "nl:"
      seq_nbr = seq(long_data_seq,nextval)
      FROM dual
      DETAIL
       request->task_chg_qual[x].comments_long_text_id = seq_nbr
      WITH format, counter
     ;end select
     INSERT  FROM long_text lt,
       (dummyt d  WITH seq = value(1))
      SET lt.long_text_id = request->task_chg_qual[x].comments_long_text_id, lt.long_text = request->
       task_chg_qual[x].comment, lt.parent_entity_id = request->task_chg_qual[x].processing_task_id,
       lt.parent_entity_name = "PROCESSING_TASK_COMMENTS", lt.updt_cnt = 0, lt.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
       updt_applctx,
       lt.active_ind = 1, lt.active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm =
       cnvtdatetime(curdate,curtime3),
       lt.active_status_prsnl_id = reqinfo->updt_id
      PLAN (d)
       JOIN (lt
       WHERE (lt.long_text_id=request->task_chg_qual[x].comments_long_text_id))
      WITH nocounter, outerjoin = d, dontexist
     ;end insert
     IF (curqual != 1)
      GO TO insert_long_text_failed
     ENDIF
    ELSEIF ((request->task_chg_qual[x].comments_long_text_id > 0)
     AND textlen(trim(request->task_chg_qual[x].comment))=0)
     SELECT INTO "nl:"
      lt.long_text_id
      FROM long_text lt
      PLAN (lt
       WHERE (request->task_chg_qual[x].comments_long_text_id=lt.long_text_id)
        AND (request->task_chg_qual[x].lt_updt_cnt=lt.updt_cnt))
      WITH nocounter, forupdate(lt)
     ;end select
     IF (curqual != 1)
      GO TO lock_long_text_failed
     ENDIF
     DELETE  FROM long_text lt
      WHERE (lt.long_text_id=request->task_chg_qual[x].comments_long_text_id)
      WITH nocounter
     ;end delete
     IF (curqual != 1)
      GO TO delete_long_text_failed
     ENDIF
    ELSEIF ((request->task_chg_qual[x].comments_long_text_id > 0)
     AND textlen(trim(request->task_chg_qual[x].comment)) != 0)
     SELECT INTO "nl:"
      lt.long_text_id
      FROM long_text lt
      PLAN (lt
       WHERE (request->task_chg_qual[x].comments_long_text_id=lt.long_text_id)
        AND (request->task_chg_qual[x].lt_updt_cnt=lt.updt_cnt))
      WITH nocounter, forupdate(lt)
     ;end select
     IF (curqual != 1)
      GO TO lock_long_text_failed
     ENDIF
     UPDATE  FROM long_text lt
      SET lt.long_text = trim(request->task_chg_qual[x].comment), lt.updt_dt_tm = cnvtdatetime(
        curdate,curtime3), lt.updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt = (lt
       .updt_cnt+ 1)
      PLAN (lt
       WHERE (lt.long_text_id=request->task_chg_qual[x].comments_long_text_id)
        AND (lt.updt_cnt=request->task_chg_qual[x].lt_updt_cnt))
      WITH nocounter
     ;end update
     IF (curqual != 1)
      GO TO update_long_text_failed
     ENDIF
    ENDIF
  ENDFOR
  UPDATE  FROM processing_task pt,
    (dummyt d  WITH seq = value(nbr_chg_tasks))
   SET pt.research_account_id = request->task_chg_qual[d.seq].research_account_id, pt
    .service_resource_cd = request->task_chg_qual[d.seq].service_resource_cd, pt
    .comments_long_text_id = request->task_chg_qual[d.seq].comments_long_text_id,
    pt.status_cd =
    IF ((request->task_chg_qual[d.seq].verifying_prsnl_id != 0.0)) verified_status_cd
    ELSE pt.status_cd
    ENDIF
    , pt.status_prsnl_id =
    IF ((request->task_chg_qual[d.seq].verifying_prsnl_id != 0.0)) request->task_chg_qual[d.seq].
     verifying_prsnl_id
    ELSE pt.status_prsnl_id
    ENDIF
    , pt.status_dt_tm =
    IF ((request->task_chg_qual[d.seq].verifying_prsnl_id != 0.0)) cnvtdatetime(curdate,curtime3)
    ELSE pt.status_dt_tm
    ENDIF
    ,
    pt.updt_dt_tm = cnvtdatetime(curdate,curtime3), pt.updt_id = reqinfo->updt_id, pt.updt_task =
    reqinfo->updt_task,
    pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1)
   PLAN (d)
    JOIN (pt
    WHERE (pt.processing_task_id=request->task_chg_qual[d.seq].processing_task_id))
   WITH nocounter
  ;end update
  IF (curqual != nbr_chg_tasks)
   GO TO update_processing_task_failed
  ENDIF
  INSERT  FROM ap_ops_exception aoe,
    (dummyt d  WITH seq = value(nbr_chg_tasks))
   SET aoe.parent_id = request->task_chg_qual[d.seq].processing_task_id, aoe.action_flag = 7, aoe
    .active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   PLAN (d
    WHERE (request->task_chg_qual[d.seq].verifying_prsnl_id != 0.0))
    JOIN (aoe
    WHERE (request->task_chg_qual[d.seq].processing_task_id=aoe.parent_id)
     AND aoe.action_flag=7)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  INSERT  FROM ap_ops_exception_detail aoed,
    (dummyt d  WITH seq = value(nbr_chg_tasks))
   SET aoed.parent_id = request->task_chg_qual[d.seq].processing_task_id, aoed.action_flag = 7, aoed
    .sequence = 1,
    aoed.field_meaning = "VERIFYING_PRSNL_ID", aoed.field_id = request->task_chg_qual[d.seq].
    verifying_prsnl_id, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime),
    aoed.updt_id = reqinfo->updt_id, aoed.updt_task = reqinfo->updt_task, aoed.updt_applctx = reqinfo
    ->updt_applctx,
    aoed.updt_cnt = 0
   PLAN (d
    WHERE (request->task_chg_qual[d.seq].verifying_prsnl_id != 0.0))
    JOIN (aoed
    WHERE (request->task_chg_qual[d.seq].processing_task_id=aoed.parent_id)
     AND aoed.action_flag=7
     AND aoed.sequence=1)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  INSERT  FROM ap_ops_exception_detail aoed,
    (dummyt d  WITH seq = value(nbr_chg_tasks))
   SET aoed.parent_id = request->task_chg_qual[d.seq].processing_task_id, aoed.action_flag = 7, aoed
    .sequence = 2,
    aoed.field_meaning = "DATE_OF_SERVICE", aoed.field_id = request->task_chg_qual[d.seq].
    date_of_service_cd, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime),
    aoed.updt_id = reqinfo->updt_id, aoed.updt_task = reqinfo->updt_task, aoed.updt_applctx = reqinfo
    ->updt_applctx,
    aoed.updt_cnt = 0
   PLAN (d
    WHERE (request->task_chg_qual[d.seq].verifying_prsnl_id != 0.0))
    JOIN (aoed
    WHERE (request->task_chg_qual[d.seq].processing_task_id=aoed.parent_id)
     AND aoed.action_flag=7
     AND aoed.sequence=2)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed,
     (dummyt d  WITH seq = value(nbr_chg_tasks))
    SET aoed.action_flag = 7, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = request->task_chg_qual[d.seq].processing_task_id, aoed.sequence = 3, aoed
     .updt_applctx = reqinfo->updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (request->task_chg_qual[d.seq].verifying_prsnl_id != 0.0))
     JOIN (aoed
     WHERE (request->task_chg_qual[d.seq].processing_task_id=aoed.parent_id)
      AND aoed.action_flag=7
      AND aoed.sequence=3)
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
  ENDIF
 ENDIF
 SET nbr_del_tasks = cnvtint(size(request->task_del_qual,5))
 IF (nbr_del_tasks > 0)
  SELECT INTO "nl:"
   pt.processing_task_id
   FROM processing_task pt,
    (dummyt d  WITH seq = value(nbr_del_tasks))
   PLAN (d)
    JOIN (pt
    WHERE (pt.processing_task_id=request->task_del_qual[d.seq].processing_task_id))
   HEAD REPORT
    nbr_items = 0
   DETAIL
    nbr_items = (nbr_items+ 1), updt_cnts_array[nbr_items] = pt.updt_cnt, order_id_array[nbr_items]
     = pt.order_id
   WITH nocounter, forupdate(pt)
  ;end select
  IF (nbr_items != nbr_del_tasks)
   GO TO lock_processing_task_failed
  ENDIF
  FOR (x = 1 TO nbr_del_tasks)
    IF ((request->task_del_qual[x].updt_cnt != updt_cnts_array[x]))
     IF ((request->task_del_qual[x].order_id != order_id_array[x])
      AND (order_id_array[x] != 0))
      SET x = x
     ELSE
      GO TO lock_processing_task_failed
     ENDIF
    ENDIF
  ENDFOR
  UPDATE  FROM processing_task pt,
    (dummyt d  WITH seq = value(nbr_del_tasks))
   SET pt.cassette_id = 0.0, pt.slide_id = 0.0, pt.status_cd = cancelled_status_cd,
    pt.status_prsnl_id = reqinfo->updt_id, pt.status_dt_tm = cnvtdatetime(curdate,curtime3), pt
    .cancel_cd = request->task_del_qual[d.seq].cancel_cd,
    pt.cancel_prsnl_id = reqinfo->updt_id, pt.cancel_dt_tm = cnvtdatetime(curdate,curtime3), pt
    .comments_long_text_id = 0.0,
    pt.updt_dt_tm = cnvtdatetime(curdate,curtime3), pt.updt_id = reqinfo->updt_id, pt.updt_task =
    reqinfo->updt_task,
    pt.updt_applctx = reqinfo->updt_applctx, pt.updt_cnt = (pt.updt_cnt+ 1)
   PLAN (d)
    JOIN (pt
    WHERE (pt.processing_task_id=request->task_del_qual[d.seq].processing_task_id))
   WITH nocounter
  ;end update
  IF (curqual != nbr_del_tasks)
   GO TO update_processing_task_failed
  ENDIF
  INSERT  FROM ap_ops_exception aoe,
    (dummyt d  WITH seq = value(nbr_del_tasks))
   SET aoe.parent_id = request->task_del_qual[d.seq].processing_task_id, aoe.action_flag = 7, aoe
    .active_ind = 1,
    aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe.updt_task =
    reqinfo->updt_task,
    aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
   PLAN (d)
    JOIN (aoe
    WHERE (request->task_del_qual[d.seq].processing_task_id=aoe.parent_id)
     AND aoe.action_flag=7)
   WITH nocounter, outerjoin = d, dontexist
  ;end insert
  IF (curqual != nbr_del_tasks)
   GO TO insert_ops_exception_failed
  ENDIF
  IF (curutc=1)
   INSERT  FROM ap_ops_exception_detail aoed,
     (dummyt d  WITH seq = value(nbr_del_tasks))
    SET aoed.action_flag = 7, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
     aoed.parent_id = request->task_del_qual[d.seq].processing_task_id, aoed.sequence = 1, aoed
     .updt_applctx = reqinfo->updt_applctx,
     aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo->
     updt_id,
     aoed.updt_task = reqinfo->updt_task
    PLAN (d)
     JOIN (aoed
     WHERE (request->task_del_qual[d.seq].processing_task_id=aoed.parent_id)
      AND aoed.action_flag=7
      AND aoed.sequence=1)
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (curqual != nbr_del_tasks)
    GO TO insert_ops_exception_detail_failed
   ENDIF
  ENDIF
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(nbr_del_tasks))
   SET lt.long_text_id = request->task_del_qual[d.seq].comments_long_text_id
   PLAN (d
    WHERE (request->task_del_qual[d.seq].comments_long_text_id > 0))
    JOIN (lt
    WHERE (lt.long_text_id=request->task_del_qual[d.seq].comments_long_text_id))
   WITH nocounter
  ;end delete
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHNET_SEQ"
 SET failed = "T"
 GO TO exit_script
#insert_long_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#lock_long_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#update_long_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#delete_long_text_failed
 SET reply->status_data.subeventstatus[1].operationname = "DELETE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_TEXT"
 SET failed = "T"
 GO TO exit_script
#insert_processing_task_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#lock_processing_task_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#update_processing_task_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PROCESSING_TASK"
 SET failed = "T"
 GO TO exit_script
#insert_ops_exception_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION"
 SET failed = "T"
 GO TO exit_script
#insert_ops_exception_detail_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_OPS_EXCEPTION_DETAIL"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
