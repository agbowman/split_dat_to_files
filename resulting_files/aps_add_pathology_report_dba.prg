CREATE PROGRAM aps_add_pathology_report:dba
 RECORD rpt(
   1 rpt_cnt = i2
   1 qual[*]
     2 catalog_cd = f8
     2 section_cnt = i2
     2 section[*]
       3 task_assay_cd = f8
       3 result_type_cd = f8
       3 sign_line_ind = i2
       3 section_sequence = i4
       3 required_ind = i2
 )
#script
 SET failed = "F"
 SET rpt_cnt = 0
 SET rpt_seq = 0
 IF ((validate(reply->case_id,- (1))=- (1)))
  RECORD reply(
    1 report_qual[*]
      2 report_id = f8
      2 report_sequence = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET status_cd = 0.0
  SET detail_status_cd = 0.0
  SET reply->status_data.status = "F"
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE c.code_set=1305
    AND c.cdf_meaning IN ("ORDERED", "PENDING")
   HEAD REPORT
    status_cd = 0.0, detail_status_cd = 0.0
   DETAIL
    IF (c.cdf_meaning="ORDERED")
     status_cd = c.code_value
    ELSE
     detail_status_cd = c.code_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET nbr_reply = 0
 SET nbr_of_reports = cnvtint(size(request->report_qual,5))
 SET stat = alterlist(reply->report_qual,nbr_of_reports)
 SET stat = alterlist(rpt->qual,nbr_of_reports)
#next_report
 FOR (x = 1 TO nbr_of_reports)
  SELECT INTO "nl:"
   d.task_assay_cd, p.catalog_cd, p.pending_ind
   FROM profile_task_r p,
    discrete_task_assay d
   PLAN (p
    WHERE (request->report_qual[x].report_catalog_cd=p.catalog_cd)
     AND p.active_ind=1
     AND sysdate BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)
    JOIN (d
    WHERE p.task_assay_cd=d.task_assay_cd)
   HEAD REPORT
    rpt_cnt = (rpt_cnt+ 1), rpt->rpt_cnt = rpt_cnt, rpt->qual[rpt_cnt].catalog_cd = p.catalog_cd,
    sec_cnt = 0, stat = alterlist(rpt->qual[rpt_cnt].section,5)
   DETAIL
    sec_cnt = (sec_cnt+ 1)
    IF (mod(sec_cnt,5)=1
     AND sec_cnt != 1)
     stat = alterlist(rpt->qual[rpt_cnt].section,(sec_cnt+ 4))
    ENDIF
    rpt->qual[rpt_cnt].section[sec_cnt].task_assay_cd = d.task_assay_cd, rpt->qual[rpt_cnt].section[
    sec_cnt].result_type_cd = d.default_result_type_cd, rpt->qual[rpt_cnt].section[sec_cnt].
    sign_line_ind = d.signature_line_ind,
    rpt->qual[rpt_cnt].section[sec_cnt].section_sequence = p.sequence, rpt->qual[rpt_cnt].section[
    sec_cnt].required_ind = p.pending_ind
   FOOT REPORT
    stat = alterlist(rpt->qual[rpt_cnt].section,sec_cnt)
   WITH nocounter
  ;end select
  IF (curqual != 0)
   SELECT INTO "nl:"
    seq_nbr = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     reply->report_qual[x].report_id = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    GO TO seq_failed
   ENDIF
  ELSE
   SET reply->report_qual[x].report_id = 0.0
   GO TO rpt_failed
  ENDIF
 ENDFOR
 SET y = 1
#insert_report
 FOR (y = y TO rpt->rpt_cnt)
   IF ((reply->report_qual[y].report_id != 0.0))
    SELECT INTO "nl:"
     cr.report_sequence
     FROM case_report cr
     PLAN (cr
      WHERE (request->case_id=cr.case_id)
       AND (request->report_qual[y].report_catalog_cd=cr.catalog_cd))
     HEAD REPORT
      rpt_seq = 0
     DETAIL
      IF (cr.report_sequence > rpt_seq)
       rpt_seq = cr.report_sequence
      ENDIF
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->report_qual[y].report_sequence = 0
    ELSE
     SET reply->report_qual[y].report_sequence = (rpt_seq+ 1)
    ENDIF
    INSERT  FROM case_report cr
     SET cr.case_id = request->case_id, cr.report_id = reply->report_qual[y].report_id, cr.catalog_cd
       = rpt->qual[y].catalog_cd,
      cr.report_sequence = reply->report_qual[y].report_sequence, cr.status_cd = status_cd, cr
      .status_prsnl_id = reqinfo->updt_id,
      cr.status_dt_tm = cnvtdatetime(curdate,curtime), cr.request_dt_tm = cnvtdatetime(request->
       report_qual[y].request_dt_tm), cr.request_prsnl_id = reqinfo->updt_id,
      cr.updt_id = reqinfo->updt_id, cr.updt_dt_tm = cnvtdatetime(curdate,curtime), cr.updt_task =
      reqinfo->updt_task,
      cr.updt_applctx = reqinfo->updt_applctx, cr.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET nbr_reply = (nbr_reply+ 1)
     IF (nbr_reply > 1)
      SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
     ENDIF
     SET reply->status_data.subeventstatus[nbr_reply].operationname = "INSERT"
     SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
     SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "CASE_REPORT"
     SET failed = "T"
     SET reply->report_qual[y].report_id = 0.0
     SET reqinfo->commit_ind = 0
     SET y = (y+ 1)
     GO TO insert_report
    ELSE
     IF ((request->report_qual[y].comments_long_text_id=0)
      AND textlen(trim(request->report_qual[y].comments)) > 0)
      SET new_comments_long_text_id = 0.00
      SELECT INTO "nl:"
       seq_nbr = seq(long_data_seq,nextval)
       FROM dual
       DETAIL
        new_comments_long_text_id = seq_nbr
       WITH format, counter
      ;end select
      IF (curqual=0)
       GO TO exit_script
      ENDIF
     ELSE
      SET new_comments_long_text_id = request->report_qual[y].comments_long_text_id
     ENDIF
     IF ((request->report_qual[y].comments_long_text_id=0)
      AND textlen(trim(request->report_qual[y].comments)) > 0)
      SET s_active_cd = 0.0
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE cv.code_set=48
        AND cv.cdf_meaning="ACTIVE"
        AND cv.active_ind=1
       HEAD REPORT
        s_active_cd = 0.0
       DETAIL
        s_active_cd = cv.code_value
       WITH nocounter
      ;end select
      INSERT  FROM long_text lt
       SET lt.long_text_id = new_comments_long_text_id, lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime
        (curdate,curtime3),
        lt.updt_id = reqinfo->updt_id, lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->
        updt_applctx,
        lt.active_ind = 1, lt.active_status_cd = s_active_cd, lt.active_status_dt_tm = cnvtdatetime(
         curdate,curtime3),
        lt.active_status_prsnl_id = reqinfo->updt_id, lt.parent_entity_name = "REPORT_TASK", lt
        .parent_entity_id = reply->report_qual[y].report_id,
        lt.long_text = request->report_qual[y].comments
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET nbr_reply = (nbr_reply+ 1)
       IF (nbr_reply > 1)
        SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
       ENDIF
       SET reply->status_data.subeventstatus[nbr_reply].operationname = "INSERT"
       SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
       SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE "
       SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "LONG_TEXT"
       SET failed = "T"
       SET reqinfo->commit_ind = 0
       GO TO exit_script
      ENDIF
     ENDIF
     INSERT  FROM report_task rt
      SET rt.report_id = reply->report_qual[y].report_id, rt.service_resource_cd = request->
       report_qual[y].processing_location_cd, rt.responsible_resident_id = request->report_qual[y].
       responsible_resident_id,
       rt.responsible_pathologist_id = request->report_qual[y].responsible_pathologist_id, rt
       .priority_cd = request->report_qual[y].request_priority_cd, rt.comments_long_text_id =
       new_comments_long_text_id,
       rt.updt_id = reqinfo->updt_id, rt.updt_dt_tm = cnvtdatetime(curdate,curtime), rt.updt_task =
       reqinfo->updt_task,
       rt.updt_applctx = reqinfo->updt_applctx, rt.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET nbr_reply = (nbr_reply+ 1)
      IF (nbr_reply > 1)
       SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
      ENDIF
      SET reply->status_data.subeventstatus[nbr_reply].operationname = "INSERT"
      SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
      SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE"
      SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "REPORT_TASK"
      SET failed = "T"
      SET reply->report_qual[y].report_id = 0.0
      SET reqinfo->commit_ind = 0
      SET y = (y+ 1)
      GO TO insert_report
     ELSE
      INSERT  FROM report_detail_task rt,
        (dummyt d  WITH seq = value(cnvtint(size(rpt->qual[y].section,5))))
       SET rt.case_id = request->case_id, rt.report_id = reply->report_qual[y].report_id, rt
        .task_assay_cd = rpt->qual[y].section[d.seq].task_assay_cd,
        rt.result_type_cd = rpt->qual[y].section[d.seq].result_type_cd, rt.signature_footnote_ind =
        rpt->qual[y].section[d.seq].sign_line_ind, rt.section_sequence = rpt->qual[y].section[d.seq].
        section_sequence,
        rt.required_ind = rpt->qual[y].section[d.seq].required_ind, rt.status_cd = detail_status_cd,
        rt.updt_dt_tm = cnvtdatetime(curdate,curtime),
        rt.updt_id = reqinfo->updt_id, rt.updt_task = reqinfo->updt_task, rt.updt_applctx = reqinfo->
        updt_applctx,
        rt.updt_cnt = 0
       PLAN (d)
        JOIN (rt
        WHERE (reply->report_qual[y].report_id=rt.report_id)
         AND (rpt->qual[y].section[d.seq].task_assay_cd=rt.task_assay_cd))
       WITH nocounter, outerjoin = d, dontexist
      ;end insert
      IF (curqual=0)
       SET nbr_reply = (nbr_reply+ 1)
       IF (nbr_reply > 1)
        SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
       ENDIF
       SET reply->status_data.subeventstatus[nbr_reply].operationname = "INSERT"
       SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
       SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE"
       SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "REPORT_DETAIL_TASK"
       SET failed = "T"
       SET reply->report_qual[y].report_id = 0.0
      ELSE
       INSERT  FROM ap_ops_exception aoe
        SET aoe.parent_id = reply->report_qual[y].report_id, aoe.action_flag = 3, aoe.active_ind = 1,
         aoe.updt_dt_tm = cnvtdatetime(curdate,curtime), aoe.updt_id = reqinfo->updt_id, aoe
         .updt_task = reqinfo->updt_task,
         aoe.updt_applctx = reqinfo->updt_applctx, aoe.updt_cnt = 0
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET nbr_reply = (nbr_reply+ 1)
        IF (nbr_reply > 1)
         SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
        ENDIF
        SET reply->status_data.subeventstatus[nbr_reply].operationname = "INSERT"
        SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
        SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE"
        SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "AP_OPS_EXCEPTION"
        SET failed = "T"
        SET reply->report_qual[y].report_id = 0.0
       ENDIF
       IF (curutc=1)
        INSERT  FROM ap_ops_exception_detail aoed
         SET aoed.action_flag = 3, aoed.field_meaning = "TIME_ZONE", aoed.field_nbr = curtimezoneapp,
          aoed.parent_id = reply->report_qual[y].report_id, aoed.sequence = 1, aoed.updt_applctx =
          reqinfo->updt_applctx,
          aoed.updt_cnt = 0, aoed.updt_dt_tm = cnvtdatetime(curdate,curtime), aoed.updt_id = reqinfo
          ->updt_id,
          aoed.updt_task = reqinfo->updt_task
         WITH nocounter
        ;end insert
        IF (curqual=0)
         SET nbr_reply = (nbr_reply+ 1)
         IF (nbr_reply > 1)
          SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
         ENDIF
         SET reply->status_data.subeventstatus[nbr_reply].operationname = "INSERT"
         SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
         SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE"
         SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue =
         "AP_OPS_EXCEPTION_DETAIL"
         SET failed = "T"
         SET reply->report_qual[y].report_id = 0.0
        ENDIF
       ENDIF
      ENDIF
      IF (failed="T")
       SET reqinfo->commit_ind = 0
       GO TO exit_script
      ENDIF
     ENDIF
     IF ((request->report_qual[y].comments_long_text_id > 0))
      SELECT INTO "nl:"
       lt.*
       FROM long_text lt
       WHERE (request->report_qual[y].comments_long_text_id=lt.long_text_id)
       DETAIL
        cur_updt_cnt = lt.updt_cnt
       WITH forupdate(lt)
      ;end select
      IF ((request->lt_updt_cnt != cur_updt_cnt))
       SET nbr_reply = (nbr_reply+ 1)
       IF (nbr_reply > 1)
        SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
       ENDIF
       SET reply->status_data.subeventstatus[nbr_reply].operationname = "LOCK"
       SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
       SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE "
       SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "LONG_TEXT"
       SET failed = "T"
       GO TO exit_script
      ENDIF
      SET cur_updt_cnt = (cur_updt_cnt+ 1)
      UPDATE  FROM long_text lt
       SET lt.long_text = trim(request->report_qual[y].comments), lt.updt_dt_tm = cnvtdatetime(
         curdate,curtime), lt.updt_id = reqinfo->updt_id,
        lt.updt_task = reqinfo->updt_task, lt.updt_applctx = reqinfo->updt_applctx, lt.updt_cnt =
        cur_updt_cnt
       WHERE (request->report_qual[y].comments_long_text_id=lt.long_text_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET nbr_reply = (nbr_reply+ 1)
       IF (nbr_reply > 1)
        SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
       ENDIF
       SET reply->status_data.subeventstatus[nbr_reply].operationname = "UPDATE"
       SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
       SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE "
       SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "LONG_TEXT"
       SET failed = "T"
       SET reqinfo->commit_ind = 0
       GO TO exit_script
      ENDIF
     ENDIF
     SET reqinfo->commit_ind = 1
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#seq_failed
 SET nbr_reply = (nbr_reply+ 1)
 IF (nbr_reply > 1)
  SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
 ENDIF
 SET reply->status_data.subeventstatus[nbr_reply].operationname = "NEXTVAL"
 SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
 SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "SEQ"
 SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "REFERENCE_SEQ"
 SET failed = "T"
 GO TO exit_script
#rpt_failed
 SET nbr_reply = (nbr_reply+ 1)
 IF (nbr_reply > 1)
  SET stat = alter(reply->status_data.subeventstatus,nbr_reply)
 ENDIF
 SET reply->status_data.subeventstatus[nbr_reply].operationname = "SELECT"
 SET reply->status_data.subeventstatus[nbr_reply].operationstatus = "F"
 SET reply->status_data.subeventstatus[nbr_reply].targetobjectname = "TABLE "
 SET reply->status_data.subeventstatus[nbr_reply].targetobjectvalue = "PROFILE_TASK_R "
 SET failed = "T"
 SET x = (x+ 1)
 GO TO next_report
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
END GO
