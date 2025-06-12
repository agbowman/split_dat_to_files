CREATE PROGRAM bb_act_upd_upload_review:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD error_status(
   1 statuslist[*]
     2 status = i4
     2 module_name = c40
     2 errnum = i4
     2 errmsg = c132
 )
 DECLARE nuploadreviewsize = i4 WITH noconstant(size(request->uploadreviews,5))
 DECLARE nreviewdocssize = i4 WITH noconstant(request->max_review_doc_rows)
 DECLARE success_count = i4 WITH noconstant(0)
 DECLARE nindex1 = i2 WITH noconstant(0)
 DECLARE nindex2 = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE serrormsg = c132 WITH noconstant(fillstring(255," "))
 DECLARE nerrorcheck = i2 WITH noconstant(error(serrormsg,1))
 DECLARE sscriptname = c25 WITH constant("BB_ACT_UPD_UPLOAD_REVIEW")
 DECLARE statuscheck(nlevel) = i2
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 INSERT  FROM long_text lt,
   (dummyt d1  WITH seq = value(nuploadreviewsize)),
   (dummyt d2  WITH seq = value(nreviewdocssize))
  SET lt.active_ind = request->uploadreviews[d1.seq].reviewdocs[d2.seq].active_ind, lt
   .active_status_cd = reqdata->active_status_cd, lt.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = request->uploadreviews[d1.seq].
   reviewdocs[d2.seq].long_text, lt.long_text_id = request->uploadreviews[d1.seq].reviewdocs[d2.seq].
   long_text_id,
   lt.parent_entity_id = request->uploadreviews[d1.seq].reviewdocs[d2.seq].bb_upload_long_text_r_id,
   lt.parent_entity_name = "BB_UPLOAD_LONG_TEXT_R", lt.updt_applctx = reqinfo->updt_applctx,
   lt.updt_cnt = 0, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id,
   lt.updt_task = reqinfo->updt_task
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->uploadreviews[d1.seq].reviewdocs,5)
    AND (request->uploadreviews[d1.seq].reviewdocs[d2.seq].add_ind=1)
    AND (request->uploadreviews[d1.seq].reviewdocs[d2.seq].long_text_id > 0.0))
   JOIN (lt)
  WITH nocounter, status(request->uploadreviews[d1.seq].reviewdocs[d2.seq].status)
 ;end insert
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF ((request->lt_add_cnt=statuscheck(2)))
   SET reply->status_data.status = "S"
  ELSE
   CALL errorhandler(sscriptname,"F","LONG_TEXT insert",
    "Insert count doesn't match number of records inserted.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","LONG_TEXT insert",serrormsg)
 ENDIF
 SELECT INTO "nl:"
  lt.*
  FROM long_text lt,
   (dummyt d1  WITH seq = value(nuploadreviewsize)),
   (dummyt d2  WITH seq = value(nreviewdocssize))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->uploadreviews[d1.seq].reviewdocs,5)
    AND (request->uploadreviews[d1.seq].reviewdocs[d2.seq].change_ind=1))
   JOIN (lt
   WHERE (lt.long_text_id=request->uploadreviews[d1.seq].reviewdocs[d2.seq].long_text_id)
    AND (lt.updt_cnt=request->uploadreviews[d1.seq].reviewdocs[d2.seq].long_text_updt_cnt)
    AND lt.long_text_id > 0.0)
  WITH nocounter, forupdate(lt)
 ;end select
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF ((request->lt_chg_cnt=curqual))
   SET reply->status_data.status = "S"
  ELSE
   CALL errorhandler(sscriptname,"F","LONG_TEXT row lock",
    "Error locking the records for the LONG_TEXT update.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","LONG_TEXT row lock",serrormsg)
 ENDIF
 UPDATE  FROM long_text lt,
   (dummyt d1  WITH seq = value(nuploadreviewsize)),
   (dummyt d2  WITH seq = value(nreviewdocssize))
  SET lt.active_ind = request->uploadreviews[d1.seq].reviewdocs[d2.seq].active_ind, lt
   .active_status_cd =
   IF ((request->uploadreviews[d1.seq].reviewdocs[d2.seq].active_ind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   , lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
   lt.active_status_prsnl_id = reqinfo->updt_id, lt.long_text = request->uploadreviews[d1.seq].
   reviewdocs[d2.seq].long_text, lt.parent_entity_id = request->uploadreviews[d1.seq].reviewdocs[d2
   .seq].bb_upload_long_text_r_id,
   lt.parent_entity_name = "BB_UPLOAD_LONG_TEXT_R", lt.updt_applctx = reqinfo->updt_applctx, lt
   .updt_cnt = (lt.updt_cnt+ 1),
   lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task =
   reqinfo->updt_task
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->uploadreviews[d1.seq].reviewdocs,5)
    AND (request->uploadreviews[d1.seq].reviewdocs[d2.seq].change_ind=1))
   JOIN (lt
   WHERE (lt.long_text_id=request->uploadreviews[d1.seq].reviewdocs[d2.seq].long_text_id)
    AND (lt.updt_cnt=request->uploadreviews[d1.seq].reviewdocs[d2.seq].long_text_updt_cnt)
    AND lt.long_text_id > 0.0)
  WITH nocounter, status(request->uploadreviews[d1.seq].reviewdocs[d2.seq].status)
 ;end update
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF ((request->lt_chg_cnt=statuscheck(2)))
   SET reply->status_data.status = "S"
  ELSE
   CALL errorhandler(sscriptname,"F","LONG_TEXT update",
    "Update count doesn't match number of records updated.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","LONG_TEXT update",serrormsg)
 ENDIF
 INSERT  FROM bb_upload_long_text_r bult,
   (dummyt d1  WITH seq = value(nuploadreviewsize)),
   (dummyt d2  WITH seq = value(nreviewdocssize))
  SET bult.action_cd = request->uploadreviews[d1.seq].reviewdocs[d2.seq].action_cd, bult.active_ind
    = request->uploadreviews[d1.seq].reviewdocs[d2.seq].active_ind, bult.active_status_cd = reqdata->
   active_status_cd,
   bult.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bult.active_status_prsnl_id = reqinfo->
   updt_id, bult.bb_upload_long_text_r_id = request->uploadreviews[d1.seq].reviewdocs[d2.seq].
   bb_upload_long_text_r_id,
   bult.bb_upload_review_id = request->uploadreviews[d1.seq].bb_upload_review_id, bult.long_text_id
    = request->uploadreviews[d1.seq].reviewdocs[d2.seq].long_text_id, bult.updt_applctx = reqinfo->
   updt_applctx,
   bult.updt_cnt = 0, bult.updt_dt_tm = cnvtdatetime(curdate,curtime3), bult.updt_id = reqinfo->
   updt_id,
   bult.updt_task = reqinfo->updt_task
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->uploadreviews[d1.seq].reviewdocs,5)
    AND (request->uploadreviews[d1.seq].reviewdocs[d2.seq].add_ind=1))
   JOIN (bult)
  WITH nocounter, status(request->uploadreviews[d1.seq].reviewdocs[d2.seq].status)
 ;end insert
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF ((request->ultr_add_cnt=statuscheck(2)))
   SET reply->status_data.status = "S"
  ELSE
   CALL errorhandler(sscriptname,"F","BB_UPLOAD_LONG_TEXT_R insert",
    "Insert count doesn't match number of records inserted.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","BB_UPLOAD_LONG_TEXT_R insert",serrormsg)
 ENDIF
 SELECT INTO "nl:"
  bult.*
  FROM bb_upload_long_text_r bult,
   (dummyt d1  WITH seq = value(nuploadreviewsize)),
   (dummyt d2  WITH seq = value(nreviewdocssize))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->uploadreviews[d1.seq].reviewdocs,5)
    AND (request->uploadreviews[d1.seq].reviewdocs[d2.seq].change_ind=1))
   JOIN (bult
   WHERE (bult.bb_upload_long_text_r_id=request->uploadreviews[d1.seq].reviewdocs[d2.seq].
   bb_upload_long_text_r_id)
    AND (bult.updt_cnt=request->uploadreviews[d1.seq].reviewdocs[d2.seq].updt_cnt))
  WITH nocounter, forupdate(bult)
 ;end select
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF ((request->ultr_chg_cnt=curqual))
   SET reply->status_data.status = "S"
  ELSE
   CALL errorhandler(sscriptname,"F","BB_UPLOAD_LONG_TEXT_R row lock",
    "Error locking the records for the BB_UPLOAD_LONG_TEXT_R update.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","BB_UPLOAD_LONG_TEXT_R row lock",serrormsg)
 ENDIF
 UPDATE  FROM bb_upload_long_text_r bult,
   (dummyt d1  WITH seq = value(nuploadreviewsize)),
   (dummyt d2  WITH seq = value(nreviewdocssize))
  SET bult.action_cd = request->uploadreviews[d1.seq].reviewdocs[d2.seq].action_cd, bult.active_ind
    = request->uploadreviews[d1.seq].reviewdocs[d2.seq].active_ind, bult.active_status_cd =
   IF ((request->uploadreviews[d1.seq].reviewdocs[d2.seq].action_cd=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   ,
   bult.active_status_dt_tm = cnvtdatetime(curdate,curtime3), bult.active_status_prsnl_id = reqinfo->
   updt_id, bult.bb_upload_review_id = request->uploadreviews[d1.seq].bb_upload_review_id,
   bult.long_text_id = request->uploadreviews[d1.seq].reviewdocs[d2.seq].long_text_id, bult
   .updt_applctx = reqinfo->updt_applctx, bult.updt_cnt = (bult.updt_cnt+ 1),
   bult.updt_dt_tm = cnvtdatetime(curdate,curtime3), bult.updt_id = reqinfo->updt_id, bult.updt_task
    = reqinfo->updt_task
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(request->uploadreviews[d1.seq].reviewdocs,5)
    AND (request->uploadreviews[d1.seq].reviewdocs[d2.seq].change_ind=1))
   JOIN (bult
   WHERE (bult.bb_upload_long_text_r_id=request->uploadreviews[d1.seq].reviewdocs[d2.seq].
   bb_upload_long_text_r_id)
    AND (bult.updt_cnt=request->uploadreviews[d1.seq].reviewdocs[d2.seq].updt_cnt)
    AND bult.bb_upload_long_text_r_id > 0.0)
  WITH nocounter, status(request->uploadreviews[d1.seq].reviewdocs[d2.seq].status)
 ;end update
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF ((request->ultr_chg_cnt=statuscheck(2)))
   SET reply->status_data.status = "S"
  ELSE
   CALL errorhandler(sscriptname,"F","BB_UPLOAD_LONG_TEXT_R update",
    "Update count doesn't match number of records updated.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","BB_UPLOAD_LONG_TEXT_R update",serrormsg)
 ENDIF
 SELECT INTO "nl:"
  bur.*
  FROM bb_upload_review bur,
   (dummyt d  WITH seq = value(nuploadreviewsize))
  PLAN (d)
   JOIN (bur
   WHERE (bur.bb_upload_review_id=request->uploadreviews[d.seq].bb_upload_review_id)
    AND (bur.updt_cnt=request->uploadreviews[d.seq].updt_cnt)
    AND (request->uploadreviews[d.seq].change_ind=1)
    AND bur.bb_upload_review_id > 0.0)
  WITH nocounter, forupdate(bur)
 ;end select
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  IF ((request->ur_chg_cnt=curqual))
   SET reply->status_data.status = "S"
  ELSE
   CALL errorhandler(sscriptname,"F","BB_UPLOAD_REVIEW row lock",
    "Error locking the records for the BB_UPLOAD_REVIEW update.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","BB_UPLOAD_REVIEW row lock",serrormsg)
 ENDIF
 SET stat = alterlist(error_status->statuslist,0)
 SET stat = alterlist(error_status->statuslist,nuploadreviewsize)
 UPDATE  FROM bb_upload_review bur,
   (dummyt d  WITH seq = value(nuploadreviewsize))
  SET bur.reviewed_ind = request->uploadreviews[d.seq].reviewed_ind, bur.updt_applctx = reqinfo->
   updt_applctx, bur.updt_cnt = (bur.updt_cnt+ 1),
   bur.updt_dt_tm = cnvtdatetime(curdate,curtime3), bur.updt_id = reqinfo->updt_id, bur.updt_task =
   reqinfo->updt_task
  PLAN (d)
   JOIN (bur
   WHERE (bur.bb_upload_review_id=request->uploadreviews[d.seq].bb_upload_review_id)
    AND (bur.updt_cnt=request->uploadreviews[d.seq].updt_cnt)
    AND (request->uploadreviews[d.seq].change_ind=1)
    AND bur.bb_upload_review_id > 0.0)
  WITH nocounter, status(error_status->statuslist[d.seq].status)
 ;end update
 SET nerrorcheck = error(serrormsg,0)
 IF (nerrorcheck=0)
  SET success_count = 0
  IF ((request->ur_chg_cnt=statuscheck(1)))
   SET reply->status_data.status = "S"
  ELSE
   CALL errorhandler(sscriptname,"F","BB_UPLOAD_REVIEW update",
    "Update count doesn't match number of records updated.")
  ENDIF
 ELSE
  CALL errorhandler(sscriptname,"F","BB_UPLOAD_REVIEW update",serrormsg)
 ENDIF
 SET stat = alterlist(error_status->statuslist,0)
 SUBROUTINE statuscheck(nlevel)
   SET success_count = 0
   IF (nlevel=1)
    FOR (nindex1 = 1 TO size(error_status->statuslist,5))
      IF ((error_status->statuslist[nindex1].status=1))
       SET success_count = (success_count+ 1)
      ENDIF
    ENDFOR
   ELSE
    FOR (nindex1 = 1 TO size(request->uploadreviews,5))
      FOR (nindex2 = 1 TO size(request->uploadreviews[nindex1].reviewdocs,5))
        IF ((request->uploadreviews[nindex1].reviewdocs[nindex2].status=1))
         SET success_count = (success_count+ 1)
         SET request->uploadreviews[nindex1].reviewdocs[nindex2].status = 0
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
   RETURN(success_count)
 END ;Subroutine
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = operationname
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((request->debug_ind=1))
  CALL echorecord(request)
  CALL echorecord(reply)
 ENDIF
END GO
