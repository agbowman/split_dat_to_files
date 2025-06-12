CREATE PROGRAM dcp_add_role_note:dba
 RECORD reply(
   1 qual[1]
     2 note_type_list_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET rn_cnt = cnvtint(size(request->qual,5))
 SET stat = alter(reply->qual,rn_cnt)
 FOR (x = 1 TO rn_cnt)
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->qual[x].note_type_list_id = cnvtreal(y)
   WITH format, counter
  ;end select
  IF (curqual=0)
   GO TO seq_failed
  ENDIF
 ENDFOR
 INSERT  FROM note_type_list ntl,
   (dummyt d  WITH seq = value(rn_cnt))
  SET ntl.note_type_list_id = reply->qual[d.seq].note_type_list_id, ntl.role_type_cd = request->qual[
   d.seq].role_type_cd, ntl.note_type_id = request->qual[d.seq].note_type_id,
   ntl.seq_num = request->qual[d.seq].seq_num, ntl.prsnl_id = 0, ntl.updt_dt_tm = cnvtdatetime(
    curdate,curtime),
   ntl.updt_id = reqinfo->updt_id, ntl.updt_task = reqinfo->updt_task, ntl.updt_applctx = reqinfo->
   updt_applctx,
   ntl.updt_cnt = 0
  PLAN (d)
   JOIN (ntl)
  WITH nocounter
 ;end insert
 IF (curqual != rn_cnt)
  SET failed = "T"
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NOTE_TYPE_LIST"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
