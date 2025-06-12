CREATE PROGRAM cps_get_proxy_group:dba
 RECORD reply(
   1 qual[1]
     2 prsnl_group_id = f8
     2 prsnl_group_type_cd = f8
     2 prsnl_group_type_disp = vc
     2 prsnl_desc = vc
     2 prsnl_group_type_mean = c12
     2 prsnl_group_type_name = vc
     2 prsnl_group_type_desc = vc
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 prsnl_group_list[1]
       3 prsnl_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET code_set = 357
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "PROXY"
 EXECUTE cpm_get_cd_for_cdf
 SET proxy_type_cd = code_value
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET count2 = 0
 SELECT INTO "nl:"
  p.prsnl_group_id, pgn.person_id
  FROM prsnl_group p,
   prsnl_group_reltn pgn
  PLAN (p
   WHERE p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND p.prsnl_group_type_cd=proxy_type_cd)
   JOIN (pgn
   WHERE pgn.prsnl_group_id=p.prsnl_group_id)
  HEAD p.prsnl_group_id
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].prsnl_group_id = p.prsnl_group_id, reply->qual[count1].prsnl_group_type_cd = p
   .prsnl_group_type_cd, reply->qual[count1].prsnl_group_type_name = p.prsnl_group_name,
   reply->qual[count1].prsnl_group_type_desc = p.prsnl_group_desc, reply->qual[count1].
   service_resource_cd = p.service_resource_cd, count2 = 0
  DETAIL
   count2 = (count2+ 1)
   IF (mod(count2,10)=2)
    stat = alter(reply->qual.prsnl_group_list,(count2+ 9))
   ENDIF
   reply->qual[count1].prsnl_group_list[count2].prsnl_id = pgn.person_id
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
