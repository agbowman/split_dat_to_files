CREATE PROGRAM dcp_add_result_to_event_map:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE failed = i2 WITH private, noconstant(0)
 INSERT  FROM corr_event_set_mapping cesm,
   (dummyt d  WITH seq = value(size(request->eventstomap,5)))
  SET cesm.corr_event_set_mapping_id = cnvtreal(seq(reference_seq,nextval)), cesm
   .correspondence_type_cd = request->correspond_type_cd, cesm.event_set_name = request->eventstomap[
   d.seq].event_set_name,
   cesm.mapped_event_set_name = request->eventstomap[d.seq].mapped_event_set_name, cesm
   .inheritance_flag = request->eventstomap[d.seq].inherit_flag, cesm.updt_dt_tm = cnvtdatetime(
    curdate,curtime),
   cesm.updt_id = reqinfo->updt_id, cesm.updt_task = reqinfo->updt_task, cesm.updt_applctx = reqinfo
   ->updt_applctx,
   cesm.updt_cnt = 0
  PLAN (d)
   JOIN (cesm)
  WITH nocounter
 ;end insert
 IF (curqual != size(request->eventstomap,5))
  SET reply->status_data.status = "F"
  SET failed = 1
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.subeventstatus.operationname = "dcp_add_result_to_event_map"
 SET reply->status_data.subeventstatus.targetobjectname = "CORR_EVENT_SET_MAPPING"
 SET reply->status_data.subeventstatus.targetobjectvalue = "Map result event set to letter event set"
 IF (failed=0)
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
