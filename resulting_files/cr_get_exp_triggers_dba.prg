CREATE PROGRAM cr_get_exp_triggers:dba
 RECORD reply(
   1 qual[*]
     2 trigger_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE trigger_cnt = i4
 DECLARE name = vc
 DECLARE nameupper = vc
 SET name = trim(request->trigger_name,3)
 IF (size(name) > 0)
  SET nameupper = concat(trim(cnvtupper(cnvtalphanum(name)),3),"*")
  SELECT DISTINCT INTO "nl:"
   FROM expedite_trigger c
   WHERE ((c.expedite_trigger_id+ 0) > 0)
    AND c.name_key=patstring(nameupper)
   ORDER BY cnvtupper(c.name)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(reply->qual,(count1+ 9))
    ENDIF
    reply->qual[count1].trigger_name = c.name
   FOOT REPORT
    stat = alterlist(reply->qual,count1)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
