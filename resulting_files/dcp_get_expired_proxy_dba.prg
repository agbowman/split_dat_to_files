CREATE PROGRAM dcp_get_expired_proxy:dba
 RECORD reply(
   1 proxy_begin_dt_tm = dq8
   1 proxy_end_dt_tm = dq8
   1 list_owner_first_name = vc
   1 list_owner_last_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET datafound = 0
 SELECT INTO "nl:"
  p.prsnl_id, p.proxy_person_id
  FROM proxy p,
   prsnl pl
  PLAN (p
   WHERE (p.person_id=request->prsnl_id)
    AND (p.proxy_person_id=request->proxy_person_id))
   JOIN (pl
   WHERE pl.person_id=p.person_id)
  ORDER BY p.beg_effective_dt_tm DESC
  DETAIL
   datafound = 1, reply->proxy_begin_dt_tm = p.beg_effective_dt_tm, reply->proxy_end_dt_tm = p
   .end_effective_dt_tm,
   reply->list_owner_first_name = pl.name_first, reply->list_owner_last_name = pl.name_last
  WITH nocounter, maxqual(p,1)
 ;end select
 CALL echo(build("beg dt:",reply->proxy_begin_dt_tm))
 CALL echo(build("end dt:",reply->proxy_end_dt_tm))
 CALL echo(build("firstname:",reply->list_owner_first_name))
 CALL echo(build("lastname:",reply->list_owner_last_name))
 IF (datafound=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
