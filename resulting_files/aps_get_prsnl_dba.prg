CREATE PROGRAM aps_get_prsnl:dba
 RECORD reply(
   1 qual[10]
     2 cdf_meaning = c12
     2 prsnl_id = f8
     2 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SELECT INTO "nl:"
  c.cdf_meaning, p.person_id, p.name_full_formatted
  FROM code_value c,
   prsnl_group pg,
   prsnl_group_reltn pgr,
   prsnl p,
   (dummyt d  WITH seq = value(cnvtint(size(request->qual,5))))
  PLAN (d)
   JOIN (c
   WHERE 357=c.code_set
    AND (request->qual[d.seq].cdf_meaning=c.cdf_meaning))
   JOIN (pg
   WHERE c.code_value=pg.prsnl_group_type_cd
    AND pg.active_ind=1
    AND pg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (pgr
   WHERE pg.prsnl_group_id=pgr.prsnl_group_id
    AND 1=pgr.active_ind)
   JOIN (p
   WHERE parser(
    IF ((request->ret_flag=1)) "pgr.person_id = p.person_id"
    ELSE "pgr.person_id = p.person_id and  p.active_ind = 1"
    ENDIF
    ))
  ORDER BY p.person_id, c.cdf_meaning
  HEAD p.person_id
   row + 0
  HEAD c.cdf_meaning
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].cdf_meaning = c.cdf_meaning, reply->qual[cnt].prsnl_id = p.person_id, reply->
   qual[cnt].name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cnt != 0)
  SET stat = alter(reply->qual,cnt)
 ELSE
  SET stat = alter(reply->qual,1)
 ENDIF
END GO
