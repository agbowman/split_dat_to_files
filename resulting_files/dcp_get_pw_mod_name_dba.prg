CREATE PROGRAM dcp_get_pw_mod_name:dba
 RECORD reply(
   1 condition_cnt = i4
   1 qual[*]
     2 cond_module_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET condition_cnt = 0
 SET cnt1 = 0
 SELECT INTO "nl:"
  em.module_name
  FROM eks_module em
  WHERE em.module_name="DCP*"
   AND em.active_flag="A"
  ORDER BY em.module_name
  HEAD REPORT
   cnt1 = 0
  DETAIL
   cnt1 = (cnt1+ 1)
   IF (cnt1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt1+ 20))
   ENDIF
   reply->qual[cnt1].cond_module_name = em.module_name
  FOOT REPORT
   reply->condition_cnt = cnt1, stat = alterlist(reply->qual,cnt1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
