CREATE PROGRAM dcp_add_note_type:dba
 RECORD reply(
   1 qual[*]
     2 note_type_id = f8
     2 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET note_type_id = 0
 DECLARE cs_table = c50
 DECLARE nt_cnt = i4 WITH noconstant(0)
 DECLARE failed = c1 WITH noconstant("F")
 SET nt_cnt = cnvtint(size(request->note_type,5))
 INSERT  FROM note_type nt,
   (dummyt d  WITH seq = value(nt_cnt))
  SET nt.seq = 1, nt.note_type_id = cnvtreal(seq(reference_seq,nextval)), nt.note_type_description =
   request->note_type[d.seq].note_type_description,
   nt.event_cd = request->note_type[d.seq].event_cd, nt.banner_ind = request->note_type[d.seq].
   banner_ind, nt.device_name = request->note_type[d.seq].device_name,
   nt.publish_level = request->note_type[d.seq].publish_level, nt.data_status_ind = 1, nt
   .default_level_flag = evaluate(request->note_type[d.seq].level_valid_ind,1,request->note_type[d
    .seq].default_level_flag,0),
   nt.override_level_ind = evaluate(request->note_type[d.seq].level_valid_ind,1,request->note_type[d
    .seq].override_level_ind,1), nt.updt_dt_tm = cnvtdatetime(curdate,curtime), nt.updt_id = reqinfo
   ->updt_id,
   nt.updt_task = reqinfo->updt_task, nt.updt_applctx = reqinfo->updt_applctx, nt.updt_cnt = 0
  PLAN (d)
   JOIN (nt)
  WITH nocounter, outerjoin = d
 ;end insert
 IF (curqual != nt_cnt)
  SET failed = "T"
  SET cs_table = "NOTE TYPE"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM note_type nt1,
   (dummyt d1  WITH seq = value(nt_cnt))
  PLAN (d1)
   JOIN (nt1
   WHERE (nt1.event_cd=request->note_type[d1.seq].event_cd))
  HEAD REPORT
   event_count = 0
  DETAIL
   event_count = (event_count+ 1)
   IF (event_count > size(reply->qual,5))
    stat = alterlist(reply->qual,(event_count+ 5))
   ENDIF
   reply->qual[event_count].event_cd = nt1.event_cd, reply->qual[event_count].note_type_id = nt1
   .note_type_id
  FOOT REPORT
   stat = alterlist(reply->qual,event_count)
  WITH nocounter
 ;end select
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = cs_table
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
