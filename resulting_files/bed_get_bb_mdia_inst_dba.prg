CREATE PROGRAM bed_get_bb_mdia_inst:dba
 FREE SET reply
 RECORD reply(
   1 selected_instruments[*]
     2 code_value = f8
     2 display = vc
   1 available_instruments[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET scnt = 0
 SET acnt = 0
 DECLARE bb_cd = f8
 SET bb_cd = uar_get_code_by("MEANING",106,"BB")
 SELECT INTO "nl:"
  FROM code_value_group c
  PLAN (c
   WHERE (c.parent_code_value=request->model_code_value)
    AND c.code_set=221)
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->selected_instruments,scnt), reply->selected_instruments[
   scnt].code_value = c.child_code_value,
   reply->selected_instruments[scnt].display = uar_get_code_display(c.child_code_value)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value c,
   service_resource s
  PLAN (c
   WHERE c.code_set=221
    AND c.cdf_meaning="INSTRUMENT"
    AND c.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    g.child_code_value
    FROM code_value_group g,
     code_value v
    WHERE g.code_set=221
     AND g.child_code_value=c.code_value
     AND v.code_value=g.parent_code_value
     AND v.code_set=73
     AND v.cdf_meaning="BLOODBANK"))))
   JOIN (s
   WHERE s.service_resource_cd=c.code_value
    AND s.activity_type_cd=bb_cd
    AND s.active_ind=1)
  ORDER BY c.display
  HEAD c.code_value
   acnt = (acnt+ 1), stat = alterlist(reply->available_instruments,acnt), reply->
   available_instruments[acnt].code_value = c.code_value,
   reply->available_instruments[acnt].display = c.display
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
