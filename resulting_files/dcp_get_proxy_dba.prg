CREATE PROGRAM dcp_get_proxy:dba
 RECORD reply(
   1 proxy_cnt = i4
   1 qual[5]
     2 proxy_id = f8
     2 person_id = f8
     2 person_name = vc
     2 person_name_last = vc
     2 person_name_first = vc
     2 proxy_person_id = f8
     2 proxy_person_name = vc
     2 proxy_person_name_last = vc
     2 proxy_person_name_first = vc
     2 active_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET reply->proxy_cnt = 0
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET proxy_type_cd = 0.0
 SET code_set = 16189
 SET cdf_meaning = request->proxy_meaning
 EXECUTE cpm_get_cd_for_cdf
 SET proxy_type_cd = code_value
 IF (proxy_type_cd=0.0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET temp_dt_tm = cnvtdatetime(curdate,curtime3)
 SET temp_dt_tm = datetimeadd(cnvtdatetime(curdate,curtime3),(15/ 1440.0))
 SELECT
  IF ((request->person_id_is_proxy_ind=1))
   PLAN (p
    WHERE (p.proxy_person_id=request->person_id)
     AND p.proxy_type_cd=proxy_type_cd
     AND (((request->active_only_ind=1)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(temp_dt_tm)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR ((request->active_only_ind=0)))
    )
    JOIN (p1
    WHERE p.person_id=p1.person_id)
    JOIN (p2
    WHERE p.proxy_person_id=p2.person_id)
  ELSE
   PLAN (p
    WHERE (p.person_id=request->person_id)
     AND p.proxy_type_cd=proxy_type_cd
     AND (((request->active_only_ind=1)
     AND p.active_ind=1) OR ((request->active_only_ind=0))) )
    JOIN (p1
    WHERE p.person_id=p1.person_id)
    JOIN (p2
    WHERE p.proxy_person_id=p2.person_id)
  ENDIF
  INTO "nl:"
  FROM proxy p,
   prsnl p1,
   prsnl p2
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].proxy_id = p.proxy_id, reply->qual[count1].person_id = p.person_id, reply->
   qual[count1].person_name = p1.name_full_formatted,
   reply->qual[count1].person_name_last = p1.name_last, reply->qual[count1].person_name_first = p1
   .name_first, reply->qual[count1].proxy_person_id = p.proxy_person_id,
   reply->qual[count1].proxy_person_name = p2.name_full_formatted, reply->qual[count1].
   proxy_person_name_last = p2.name_last, reply->qual[count1].proxy_person_name_first = p2.name_first,
   reply->qual[count1].active_ind = p.active_ind, reply->qual[count1].beg_effective_dt_tm = p
   .beg_effective_dt_tm, reply->qual[count1].end_effective_dt_tm = p.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
#exit_script
 CALL echo(build("status:",reply->status_data.status))
 SET reply->proxy_cnt = count1
 CALL echo(build("count1:",reply->proxy_cnt))
 FOR (x = 1 TO count1)
  CALL echo(build("person name:",reply->qual[x].person_name))
  CALL echo(build("proxy name:",reply->qual[x].proxy_person_name))
 ENDFOR
END GO
