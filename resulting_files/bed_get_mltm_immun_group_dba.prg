CREATE PROGRAM bed_get_mltm_immun_group:dba
 FREE SET reply
 RECORD reply(
   1 imm_exist_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET immunization_code_value = 0.0
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE v.event_set_name_key="IMMUNIZATIONS"
   AND trim(cnvtupper(v.event_set_name))="IMMUNIZATIONS"
  DETAIL
   immunization_code_value = v.event_set_cd
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM v500_event_set_canon vec
  WHERE vec.event_set_cd=immunization_code_value
  DETAIL
   reply->imm_exist_ind = 1
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
