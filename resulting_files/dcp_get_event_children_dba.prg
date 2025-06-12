CREATE PROGRAM dcp_get_event_children:dba
 RECORD reply(
   1 event_list[*]
     2 event_id = f8
     2 event_cd = f8
     2 catalog_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 IF ((((request->event_id=0)) OR ((request->event_id=null))) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ce.event_id, ce.event_cd, ce.catalog_cd
  FROM clinical_event ce
  WHERE (ce.parent_event_id=request->event_id)
  DETAIL
   count = (count+ 1)
   IF (count > size(reply->event_list,5))
    stat = alterlist(reply->event_list,(count+ 5))
   ENDIF
   reply->event_list[count].event_id = ce.event_id, reply->event_list[count].event_cd = ce.event_cd,
   reply->event_list[count].catalog_cd = ce.catalog_cd
  FOOT REPORT
   stat = alterlist(reply->event_list,count)
  WITH nocounter
 ;end select
 IF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
