CREATE PROGRAM aps_chg_sign_line:dba
 RECORD reply(
   1 updt_cnt = i4
   1 format_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET cur_updt_cnt = 0
 SET number_to_del = 0
 SET number_to_add = size(request->detail_qual,5)
 SELECT INTO "nl:"
  slf.description
  FROM sign_line_format slf
  PLAN (slf
   WHERE cnvtupper(request->description)=cnvtupper(slf.description)
    AND (request->format_id != slf.format_id))
  DETAIL
   reply->updt_cnt = slf.updt_cnt, request->updt_cnt = reply->updt_cnt, reply->format_id = slf
   .format_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "P"
  GO TO exit_script
 ENDIF
 IF ((request->format_id=0.00))
  SELECT INTO "nl:"
   seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    request->format_id = cnvtreal(seq_nbr)
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO seq_failed
  ENDIF
  INSERT  FROM sign_line_format slf
   SET slf.format_id = request->format_id, slf.description = request->description, slf.active_ind =
    request->active_ind,
    slf.updt_cnt = 0, slf.updt_dt_tm = cnvtdatetime(curdate,curtime3), slf.updt_id = reqinfo->updt_id,
    slf.updt_task = reqinfo->updt_task, slf.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_format"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("format_id: ",request->
    format_id)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ELSE
  IF ((request->action_flag="c"))
   SELECT INTO "nl:"
    slf.description
    FROM sign_line_format slf
    WHERE (slf.format_id=request->format_id)
    DETAIL
     cur_updt_cnt = slf.updt_cnt
    WITH nocounter, forupdate(slf)
   ;end select
   IF (curqual=0)
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Lock"
    SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_format"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("format_id: ",request->
     format_id)
    ROLLBACK
    GO TO exit_script
   ENDIF
   IF ((request->updt_cnt != cur_updt_cnt))
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "VerifyChg"
    SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_format"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("format_id: ",request->
     format_id)
    ROLLBACK
    GO TO exit_script
   ENDIF
   UPDATE  FROM sign_line_format slf
    SET slf.description = request->description, slf.active_ind = request->active_ind, slf.updt_cnt =
     (slf.updt_cnt+ 1),
     slf.updt_dt_tm = cnvtdatetime(curdate,curtime3), slf.updt_id = reqinfo->updt_id, slf.updt_task
      = reqinfo->updt_task,
     slf.updt_applctx = reqinfo->updt_applctx
    WHERE (slf.format_id=request->format_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET stat = alter(reply->status_data.subeventstatus,1)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Update"
    SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_format"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = build("format_id: ",request->
     format_id)
    ROLLBACK
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (number_to_add > 0)
  SELECT INTO "nl:"
   slfd.format_id
   FROM sign_line_format_detail slfd
   WHERE (slfd.format_id=request->format_id)
   HEAD REPORT
    number_to_del = 0
   DETAIL
    number_to_del = (number_to_del+ 1)
   WITH nocounter
  ;end select
  DELETE  FROM sign_line_format_detail slfd,
    (dummyt d  WITH seq = value(number_to_del))
   SET slfd.format_id = request->format_id
   PLAN (d)
    JOIN (slfd
    WHERE (slfd.format_id=request->format_id))
   WITH nocounter
  ;end delete
  IF (curqual != number_to_del)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Delete"
   SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_format_detail"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_del: ",number_to_del
    )
   ROLLBACK
   GO TO exit_script
  ENDIF
  INSERT  FROM sign_line_format_detail slfd,
    (dummyt d  WITH seq = value(number_to_add))
   SET slfd.format_id = request->format_id, slfd.sequence = request->detail_qual[d.seq].sequence,
    slfd.line_nbr = request->detail_qual[d.seq].line_nbr,
    slfd.column_pos = request->detail_qual[d.seq].column_pos, slfd.data_element_cd = request->
    detail_qual[d.seq].data_elem_cd, slfd.data_element_format_cd = request->detail_qual[d.seq].
    data_elem_fmt_cd,
    slfd.literal_display = request->detail_qual[d.seq].literal_display, slfd.literal_size = request->
    detail_qual[d.seq].literal_size, slfd.max_size = request->detail_qual[d.seq].max_size,
    slfd.suppress_line_ind = request->detail_qual[d.seq].suppress_line_ind, slfd.updt_cnt = 0, slfd
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    slfd.updt_id = reqinfo->updt_id, slfd.updt_task = reqinfo->updt_task, slfd.updt_applctx = reqinfo
    ->updt_applctx
   PLAN (d)
    JOIN (slfd)
   WITH nocounter
  ;end insert
  IF (curqual != number_to_add)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_format_detail"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("number_to_add: ",number_to_add
    )
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 COMMIT
 SET reply->format_id = request->format_id
 SET reply->updt_cnt = request->updt_cnt
 SET reply->status_data.status = "S"
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHNET_SEQ"
 GO TO exit_script
#exit_script
END GO
