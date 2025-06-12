CREATE PROGRAM cps_get_all_person_proxy:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET reply->status_data.status = "F"
 SET type_count = size(request->type_list,5)
 SET count1 = 0
 SET stat = alterlist(reply->qual,5)
 SELECT INTO "nl:"
  FROM proxy p,
   prsnl p1,
   prsnl p2,
   (dummyt d  WITH seq = value(type_count))
  PLAN (d)
   JOIN (p
   WHERE (request->type_list[d.seq].proxy_type_cd=p.proxy_type_cd)
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND p.proxy_person_id > 0)
   JOIN (p1
   WHERE p.person_id=p1.person_id)
   JOIN (p2
   WHERE p.proxy_person_id=p2.person_id)
  ORDER BY p.person_id
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].proxy_id = p.proxy_id, reply->qual[count1].person_id = p.person_id, reply->
   qual[count1].person_name = p1.name_full_formatted,
   reply->qual[count1].proxy_person_id = p.proxy_person_id, reply->qual[count1].proxy_person_name =
   p2.name_full_formatted, reply->qual[count1].active_ind = p.active_ind,
   reply->qual[count1].beg_effective_dt_tm = p.beg_effective_dt_tm, reply->qual[count1].
   end_effective_dt_tm = p.end_effective_dt_tm, reply->qual[count1].proxy_type_cd = p.proxy_type_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "PROXY"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->qual,count1)
#exit_script
 SET reply->proxy_cnt = count1
END GO
