CREATE PROGRAM bed_get_mltm_med_group:dba
 FREE SET reply
 RECORD reply(
   1 med_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->med_exist_ind = 0
 SET medication_code_value = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key="MEDICATIONS"
   AND trim(cnvtupper(v.event_set_name))="MEDICATIONS"
  DETAIL
   medication_code_value = v.event_set_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM v500_event_set_canon vec
  WHERE vec.event_set_cd=medication_code_value
  DETAIL
   reply->med_exist_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
