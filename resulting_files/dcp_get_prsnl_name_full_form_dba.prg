CREATE PROGRAM dcp_get_prsnl_name_full_form:dba
 RECORD reply(
   1 get_list[*]
     2 person_id = f8
     2 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE nbr_to_get = i4 WITH constant(size(request->person_list,5))
 IF (nbr_to_get > 0)
  SELECT INTO "nl:"
   p.person_id
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    prsnl psl
   PLAN (d)
    JOIN (psl
    WHERE (psl.person_id=request->person_list[d.seq].person_id)
     AND psl.active_ind=1
     AND psl.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND psl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY psl.person_id
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (count1 > size(reply->get_list,5))
     stat = alterlist(reply->get_list,(count1+ 10))
    ENDIF
    reply->get_list[count1].person_id = psl.person_id, reply->get_list[count1].name_full_formatted =
    psl.name_full_formatted
   FOOT REPORT
    stat = alterlist(reply->get_list,count1)
   WITH check
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
