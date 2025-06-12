CREATE PROGRAM bed_get_result_copy_check:dba
 FREE SET reply
 RECORD reply(
   1 exists_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->exists_ind = 0
 SET rcdeliveryrecord_cd = 0.0
 SET rcdeliveryrecordsource_cd = 0.0
 SET rcdeliveryrecordtarget_cd = 0.0
 SET allspecialtysections_cd = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name IN ("RCDELIVERYRECORD", "RCDELIVERYRECORDSOURCE", "RCDELIVERYRECORDTARGET",
  "ALL SPECIALTY SECTIONS")
  DETAIL
   IF (v.event_set_name="RCDELIVERYRECORD")
    rcdeliveryrecord_cd = v.event_set_cd
   ELSEIF (v.event_set_name="RCDELIVERYRECORDSOURCE")
    rcdeliveryrecordsource_cd = v.event_set_cd
   ELSEIF (v.event_set_name="RCDELIVERYRECORDTARGET")
    rcdeliveryrecordtarget_cd = v.event_set_cd
   ELSEIF (v.event_set_name="ALL SPECIALTY SECTIONS")
    allspecialtysections_cd = v.event_set_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (((rcdeliveryrecord_cd=0.0) OR (((rcdeliveryrecordsource_cd=0.0) OR (((rcdeliveryrecordtarget_cd=
 0.0) OR (allspecialtysections_cd=0.0)) )) )) )
  GO TO exit_script
 ENDIF
 SET found_source = 0
 SET found_target = 0
 SELECT INTO "nl:"
  FROM v500_event_set_canon v
  WHERE v.event_set_cd IN (rcdeliveryrecordsource_cd, rcdeliveryrecordtarget_cd)
   AND v.parent_event_set_cd=rcdeliveryrecord_cd
  DETAIL
   IF (v.event_set_cd=rcdeliveryrecordsource_cd)
    found_source = 1
   ELSEIF (v.event_set_cd=rcdeliveryrecordtarget_cd)
    found_target = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((found_source=0) OR (found_target=0)) )
  GO TO exit_script
 ENDIF
 SET found_ind = 0
 SELECT INTO "nl:"
  FROM v500_event_set_canon v
  WHERE v.event_set_cd=rcdeliveryrecord_cd
   AND v.parent_event_set_cd=allspecialtysections_cd
  DETAIL
   found_ind = 1
  WITH nocounter
 ;end select
 IF (found_ind=0)
  GO TO exit_script
 ENDIF
 SET reply->exists_ind = 1
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
