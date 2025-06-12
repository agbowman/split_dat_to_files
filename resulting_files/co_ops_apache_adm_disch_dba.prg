CREATE PROGRAM co_ops_apache_adm_disch:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD created_ra_reply(
   1 count_ra_records_created = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD disch_reply(
   1 ops_event = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD next_day_reply(
   1 num_rec_with_icu_day_created = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 EXECUTE co_ops_create_icu_rec  WITH replace("REPLY","CREATED_RA_REPLY")
 IF ((created_ra_reply->status_data.subeventstatus="F"))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  CALL set_reply_status(icu_reply->status_data.status,created_ra_reply->status_data.subeventstatus[1]
   .operationname,created_ra_reply->status_data.subeventstatus[1].operationstatus,created_ra_reply->
   status_data.subeventstatus[1].targetobjectname,created_ra_reply->status_data.subeventstatus[1].
   targetobjectvalue)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 EXECUTE co_ops_create_next_day_rec  WITH replace("REPLY","NEXT_DAY_REPLY")
 IF ((next_day_reply->status_data.subeventstatus="F"))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  CALL set_reply_status(icu_reply->status_data.status,next_day_reply->status_data.subeventstatus[1].
   operationname,next_day_reply->status_data.subeventstatus[1].operationstatus,next_day_reply->
   status_data.subeventstatus[1].targetobjectname,next_day_reply->status_data.subeventstatus[1].
   targetobjectvalue)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 EXECUTE dcp_apache_ops_discharge  WITH replace("REPLY","DISCH_REPLY")
 IF ((disch_reply->status_data.subeventstatus="F"))
  SET reqinfo->commit_ind = 0
  SET reply->status_data.status = "F"
  CALL set_reply_status(icu_reply->status_data.status,disch_reply->status_data.subeventstatus[1].
   operationname,disch_reply->status_data.subeventstatus[1].operationstatus,disch_reply->status_data.
   subeventstatus[1].targetobjectname,disch_reply->status_data.subeventstatus[1].targetobjectvalue)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SUBROUTINE set_reply_status(status,opsname,opstatus,targetname,targetvalue)
   SET reply->status_data.status = status
   SET reply->status_data.subeventstatus[1].operationname = opsname
   SET reply->status_data.subeventstatus[1].operationstatus = opstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetvalue
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
END GO
