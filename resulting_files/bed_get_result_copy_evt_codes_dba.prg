CREATE PROGRAM bed_get_result_copy_evt_codes:dba
 FREE SET reply
 RECORD reply(
   1 source_event_codes[*]
     2 code_value = f8
     2 display = vc
     2 event_set_name = vc
   1 target_event_codes[*]
     2 code_value = f8
     2 display = vc
     2 event_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET rcdeliveryrecordsource_cd = 0.0
 SET rcdeliveryrecordtarget_cd = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name IN ("RCDELIVERYRECORDSOURCE", "RCDELIVERYRECORDTARGET")
  DETAIL
   IF (v.event_set_name="RCDELIVERYRECORDSOURCE")
    rcdeliveryrecordsource_cd = v.event_set_cd
   ELSEIF (v.event_set_name="RCDELIVERYRECORDTARGET")
    rcdeliveryrecordtarget_cd = v.event_set_cd
   ENDIF
  WITH nocounter
 ;end select
 IF (((rcdeliveryrecordsource_cd=0.0) OR (rcdeliveryrecordtarget_cd=0.0)) )
  GO TO exit_script
 ENDIF
 SET scnt = 0
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM v500_event_set_explode v1,
   v500_event_code v2
  PLAN (v1
   WHERE v1.event_set_cd IN (rcdeliveryrecordsource_cd, rcdeliveryrecordtarget_cd))
   JOIN (v2
   WHERE v2.event_cd=v1.event_cd)
  DETAIL
   IF (v1.event_set_cd=rcdeliveryrecordsource_cd)
    scnt = (scnt+ 1), stat = alterlist(reply->source_event_codes,scnt), reply->source_event_codes[
    scnt].code_value = v2.event_cd,
    reply->source_event_codes[scnt].display = v2.event_cd_disp, reply->source_event_codes[scnt].
    event_set_name = v2.event_set_name
   ELSE
    tcnt = (tcnt+ 1), stat = alterlist(reply->target_event_codes,tcnt), reply->target_event_codes[
    tcnt].code_value = v2.event_cd,
    reply->target_event_codes[tcnt].display = v2.event_cd_disp, reply->target_event_codes[tcnt].
    event_set_name = v2.event_set_name
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
