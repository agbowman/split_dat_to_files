CREATE PROGRAM bed_get_iview_hierarchy_check:dba
 IF ( NOT (validate(reply)))
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
 ENDIF
 SET reply->status_data.status = "F"
 SET reply->exists_ind = 0
 SET workingviewsections_cd = 0.0
 SET allspecialtysections_cd = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key IN ("WORKINGVIEWSECTIONS", "ALLSPECIALTYSECTIONS")
  DETAIL
   IF (v.event_set_name_key="WORKINGVIEWSECTIONS")
    workingviewsections_cd = v.event_set_cd
   ELSEIF (v.event_set_name_key="ALLSPECIALTYSECTIONS")
    allspecialtysections_cd = v.event_set_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (((workingviewsections_cd=0.0) OR (allspecialtysections_cd=0.0)) )
  GO TO exit_script
 ENDIF
 SET found_ind = 0
 SELECT INTO "nl:"
  FROM v500_event_set_canon v
  WHERE v.parent_event_set_cd=workingviewsections_cd
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
