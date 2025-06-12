CREATE PROGRAM aps_chg_db_tag_groups:dba
 RECORD reply(
   1 tag_group_cd = f8
   1 tag_desc = vc
   1 tag_qual[1]
     2 tag_cd = f8
     2 tag_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationstatus = c1
       3 operationname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET reply->tag_desc = request->tag_desc
 SET failed = "F"
 SET new_tag_group_id = 0.0
 SET new_tag_cnt = 0
 SET tg_updt_cnt = 0
 SET cur_updt_cnt[500] = 0
 SET count1 = 0
 IF ((request->action="A"))
  SELECT INTO "nl:"
   seq_nbr = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_tag_group_id = cnvtreal(seq_nbr)
   WITH format, counter
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM ap_tag_group tg
   SET tg.tag_group_id = new_tag_group_id, tg.tag_desc = request->tag_desc, tg.updt_cnt = 0,
    tg.updt_dt_tm = cnvtdatetime(curdate,curtime), tg.updt_id = reqinfo->updt_id, tg.updt_task =
    reqinfo->updt_task,
    tg.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  SET reply->tag_group_cd = new_tag_group_id
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG_GROUP"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ELSEIF ((request->action="C"))
  SELECT INTO "nl:"
   tg.*
   FROM ap_tag_group tg
   WHERE (request->tag_group_cd=tg.tag_group_id)
   DETAIL
    tg_updt_cnt = tg.updt_cnt
   WITH nocounter, forupdate(tg)
  ;end select
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG_GROUP"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  IF ((tg_updt_cnt != request->updt_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "COUNTER SYNC"
   SET reply->status_data.subeventstatus[1].operationstatus = "C"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG_GROUP"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  UPDATE  FROM ap_tag_group tg
   SET tg.tag_desc = request->tag_desc, tg.updt_dt_tm = cnvtdatetime(curdate,curtime), tg.updt_id =
    reqinfo->updt_id,
    tg.updt_task = reqinfo->updt_task, tg.updt_applctx = reqinfo->updt_applctx, tg.updt_cnt = (
    tg_updt_cnt+ 1)
   WHERE (request->tag_group_cd=tg.tag_group_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG_GROUP"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  SET new_tag_group_id = request->tag_group_cd
  SET reply->tag_group_cd = new_tag_group_id
 ELSEIF ( NOT ((request->action IN ("A", "C"))))
  SET new_tag_group_id = request->tag_group_cd
  SET reply->tag_group_cd = new_tag_group_id
 ENDIF
 IF ((request->tag_add_cnt > 0))
  FOR (new_tag_cnt = 1 TO cnvtint(size(request->tag_add_qual,5)))
   SELECT INTO "nl:"
    seq_nbr = seq(reference_seq,nextval)"##################;rp0"
    FROM dual d
    PLAN (d)
    HEAD REPORT
     tag_cnt = 0
    DETAIL
     IF (new_tag_cnt > cnvtint(size(reply->tag_qual,5)))
      stat = alter(reply->tag_qual,new_tag_cnt)
     ENDIF
     reply->tag_qual[new_tag_cnt].tag_cd = seq_nbr
    WITH format, counter
   ;end select
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "REFERENCE_SEQ (tags)"
    SET failed = "T"
    GO TO exit_script
   ENDIF
  ENDFOR
  INSERT  FROM ap_tag t,
    (dummyt d  WITH seq = value(request->tag_add_cnt))
   SET t.tag_id = reply->tag_qual[d.seq].tag_cd, t.tag_group_id = new_tag_group_id, t.tag_disp =
    request->tag_add_qual[d.seq].tag_disp,
    t.tag_sequence = request->tag_add_qual[d.seq].tag_sequence, t.active_ind = 1, t.updt_dt_tm =
    cnvtdatetime(curdate,curtime),
    t.updt_id = reqinfo->updt_id, t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->
    updt_applctx,
    t.updt_cnt = 0, reply->tag_qual[d.seq].tag_sequence = request->tag_add_qual[d.seq].tag_sequence
   PLAN (d)
    JOIN (t
    WHERE (request->tag_add_qual[d.seq].tag_sequence=t.tag_sequence))
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((request->tag_chg_cnt > 0))
  SELECT INTO "nl:"
   t.*
   FROM ap_tag t,
    (dummyt d  WITH seq = value(request->tag_chg_cnt))
   PLAN (d)
    JOIN (t
    WHERE (request->tag_chg_qual[d.seq].tag_cd=t.tag_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), cur_updt_cnt[count1] = t.updt_cnt
   WITH nocounter, forupdate(t)
  ;end select
  IF (((curqual=0) OR ((count1 != request->tag_chg_cnt))) )
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
   SET failed = "T"
   GO TO exit_script
  ENDIF
  FOR (x = 1 TO request->tag_chg_cnt)
    IF ((request->tag_chg_qual[x].updt_cnt != cur_updt_cnt[x]))
     SET reply->status_data.subeventstatus[1].operationname = "COUNTER SYNC"
     SET reply->status_data.subeventstatus[1].operationstatus = "C"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
     SET failed = "T"
     GO TO exit_script
    ENDIF
  ENDFOR
  UPDATE  FROM ap_tag t,
    (dummyt d  WITH seq = value(request->tag_chg_cnt))
   SET t.tag_group_id = new_tag_group_id, t.tag_disp = request->tag_chg_qual[d.seq].tag_disp, t
    .active_ind = request->tag_chg_qual[d.seq].tag_active_ind,
    t.tag_sequence = request->tag_chg_qual[d.seq].tag_sequence, t.updt_dt_tm = cnvtdatetime(curdate,
     curtime), t.updt_id = reqinfo->updt_id,
    t.updt_task = reqinfo->updt_task, t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = (
    cur_updt_cnt[d.seq]+ 1)
   PLAN (d)
    JOIN (t
    WHERE (request->tag_chg_qual[d.seq].tag_cd=t.tag_id))
   WITH nocounter
  ;end update
  IF ((curqual != request->tag_chg_cnt))
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_TAG"
   SET failed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
