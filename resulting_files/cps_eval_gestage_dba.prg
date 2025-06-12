CREATE PROGRAM cps_eval_gestage:dba
 RECORD reply(
   1 display_item[*]
     2 display_text = vc
     2 dll_name = vc
     2 comp_name = vc
     2 priority = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE gaab_threshold = i4
 SET gaab_threshold = 280
 DECLARE pos = i4
 DECLARE num = i4
 DECLARE start = i4
 SET start = 1
 SET pos = locateval(num,start,size(request->properties,5),"gaab_threshold",request->properties[num].
  name)
 SET reply->status_data.status = "Z"
 IF (pos > 0)
  IF (cnvtint(request->properties[pos].value) > 0)
   SET gaab_threshold = cnvtint(request->properties[pos].value)
  ENDIF
 ENDIF
 SELECT
  p.gest_age_at_birth
  FROM person_patient p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.gest_age_at_birth != null
    AND p.gest_age_at_birth > 0
    AND p.gest_age_at_birth < gaab_threshold)
  DETAIL
   stat = alterlist(reply->display_item,1), reply->display_item[1].dll_name = "CpsGestAge", reply->
   display_item[1].priority = 50,
   reply->status_data.status = "S"
 ;end select
END GO
