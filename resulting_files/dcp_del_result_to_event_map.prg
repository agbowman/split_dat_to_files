CREATE PROGRAM dcp_del_result_to_event_map
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
 DECLARE index1 = i4 WITH noconstant(0)
 DECLARE totcount1 = i4 WITH noconstant(0)
 SET reply->status_data.status = "S"
 SET totcount1 = cnvtint(size(request->eventstomap,5))
 FOR (index1 = 1 TO totcount1)
   DELETE  FROM corr_event_set_mapping cesm
    WHERE (cesm.correspondence_type_cd=request->correspond_type_cd)
     AND (cesm.event_set_name=request->eventstomap[index1].event_set_name)
     AND (cesm.mapped_event_set_name=request->eventstomap[index1].mapped_event_set_name)
     AND (cesm.inheritance_flag=request->eventstomap[index1].inherit_flag)
    WITH nocounter
   ;end delete
 ENDFOR
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.subeventstatus.operationname =
 "Delete map result event set to letter event set"
 SET reply->status_data.subeventstatus.targetobjectname = "Table:CORR_EVENT_SET_MAPPING"
 SET reply->status_data.subeventstatus.targetobjectvalue = "dcp_del_result_to_event_map"
 IF ((reply->status_data.status="S"))
  SET reply->status_data.subeventstatus.operationstatus = "S"
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.subeventstatus.operationstatus = "F"
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
