CREATE PROGRAM bed_get_iview_es_by_concki:dba
 FREE SET reply
 RECORD reply(
   1 code_value = f8
   1 event_set_name = vc
   1 display = vc
   1 description = vc
   1 status_code_value = f8
   1 display_association_ind = i2
   1 accumulation_ind = i2
   1 primitive_ind = i2
   1 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value c,
   v500_event_set_code v
  PLAN (c
   WHERE (c.concept_cki=request->concept_cki))
   JOIN (v
   WHERE v.event_set_cd=c.code_value)
  HEAD c.code_value
   reply->code_value = c.code_value, reply->event_set_name = v.event_set_name, reply->display = v
   .event_set_cd_disp,
   reply->description = c.description, reply->status_code_value = v.event_set_status_cd, reply->
   display_association_ind = v.display_association_ind,
   reply->accumulation_ind = v.accumulation_ind, reply->cki = c.cki
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM v500_event_set_explode v
  PLAN (v
   WHERE (v.event_set_cd=reply->code_value)
    AND v.event_set_level=0)
  DETAIL
   reply->primitive_ind = 1
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
