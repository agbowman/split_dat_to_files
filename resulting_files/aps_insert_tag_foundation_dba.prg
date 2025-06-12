CREATE PROGRAM aps_insert_tag_foundation:dba
 RECORD reply(
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
 SET failed = "F"
 SET tag_group_id = 0.0
 SET group_cnt = 0
 SET x = 0
 SET group_cnt = size(request->group_qual,5)
 FOR (x = 1 TO group_cnt)
   SELECT INTO "nl:"
    t.tag_group_id
    FROM tag_group_foundation t
    WHERE (request->group_qual[x].group_desc=t.description)
    HEAD REPORT
     tag_group_id = 0.0
    DETAIL
     tag_group_id = t.tag_group_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     seq_nbr = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      tag_group_id = cnvtreal(seq_nbr)
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
    INSERT  FROM tag_group_foundation tg
     SET tg.tag_group_id = tag_group_id, tg.description = request->group_qual[x].group_desc, tg
      .updt_dt_tm = cnvtdatetime(curdate,curtime),
      tg.updt_id = reqinfo->updt_id, tg.updt_task = reqinfo->updt_task, tg.updt_applctx = reqinfo->
      updt_applctx,
      tg.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "TAG_GROUP_FOUNDATION"
     SET failed = "T"
     GO TO exit_script
    ENDIF
   ENDIF
   INSERT  FROM tag_foundation t,
     (dummyt d  WITH seq = value(size(request->group_qual[x].qual,5)))
    SET t.tag_group_id = tag_group_id, t.tag_display = request->group_qual[x].qual[d.seq].display, t
     .tag_sequence = request->group_qual[x].qual[d.seq].sequence,
     t.updt_dt_tm = cnvtdatetime(curdate,curtime), t.updt_id = reqinfo->updt_id, t.updt_task =
     reqinfo->updt_task,
     t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0
    PLAN (d)
     JOIN (t
     WHERE 0.0=t.tag_group_id
      AND (request->group_qual[x].qual[d.seq].sequence=t.tag_sequence))
    WITH nocounter, outerjoin = d, dontexist
   ;end insert
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "TAG_FOUNDATION"
    SET failed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reply->status_data.status = "F"
  ROLLBACK
 ENDIF
END GO
