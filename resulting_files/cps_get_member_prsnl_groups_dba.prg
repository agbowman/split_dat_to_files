CREATE PROGRAM cps_get_member_prsnl_groups:dba
 RECORD reply(
   1 qual[1]
     2 prsnl_group_id = f8
     2 prsnl_group_name = vc
     2 prsnl_group_type_cd = f8
     2 prsnl_group_type_disp = c40
     2 prsnl_group_type_desc = c60
     2 prsnl_group_type_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  p.prsnl_group_reltn_id
  FROM prsnl_group_reltn p,
   prsnl_group pg
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((p.end_effective_dt_tm=null) OR (p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))) )
   JOIN (pg
   WHERE p.prsnl_group_id=pg.prsnl_group_id)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=2)
    stat = alter(reply->qual,(count1+ 9))
   ENDIF
   reply->qual[count1].prsnl_group_id = p.prsnl_group_id, reply->qual[count1].prsnl_group_type_cd =
   pg.prsnl_group_type_cd, reply->qual[count1].prsnl_group_name = pg.prsnl_group_name
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alter(reply->qual,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
