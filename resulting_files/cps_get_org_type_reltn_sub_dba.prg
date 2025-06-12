CREATE PROGRAM cps_get_org_type_reltn_sub:dba
 SET reply->status_data[1].status = "F"
 SET count = 0
 SELECT INTO "nl:"
  p.*
  FROM org_type_reltn p
  WHERE  $1
   AND active_ind=1
  DETAIL
   count += 1
   IF (mod(count,100)=1)
    stat = alter(reply->org_type_reltn,(count+ 100))
   ENDIF
   reply->org_type_reltn[count].organization_id = p.organization_id, reply->org_type_reltn[count].
   org_type_cd = p.org_type_cd, reply->org_type_reltn[count].beg_effective_dt_tm = p
   .beg_effective_dt_tm,
   reply->org_type_reltn[count].end_effective_dt_tm = p.end_effective_dt_tm
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alter(reply->org_type_reltn,count)
 SET reply->org_type_reltn_qual = count
 CALL echo("status:",0)
 CALL echo(reply->status_data.status)
 CALL echo("count:",0)
 CALL echo(count)
END GO
