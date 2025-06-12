CREATE PROGRAM dcp_get_root_event:dba
 RECORD reply(
   1 event_id = f8
   1 event_class_cd = f8
   1 event_class_disp = c40
   1 event_class_mean = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET event_id = 0.0
 SET parent_event_id = 0.0
 SET event_class_cd = 0.0
 IF ((((request->event_id=0)) OR ((request->event_id=null))) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE (ce.event_id=request->event_id)
  DETAIL
   event_id = ce.event_id, parent_event_id = ce.parent_event_id, event_class_cd = ce.event_class_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 WHILE (parent_event_id != event_id)
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE ce.event_id=parent_event_id
   DETAIL
    event_id = ce.event_id, parent_event_id = ce.parent_event_id, event_class_cd = ce.event_class_cd
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO exit_script
  ENDIF
 ENDWHILE
 IF (event_id > 0)
  SET reply->event_id = event_id
  SET reply->event_class_cd = event_class_cd
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
