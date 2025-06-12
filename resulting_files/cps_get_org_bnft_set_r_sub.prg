CREATE PROGRAM cps_get_org_bnft_set_r_sub
 SET kount = 0
 SELECT INTO "nl:"
  p.*
  FROM org_bnft_set_r p
  WHERE  $1
   AND  $2
   AND  $3
   AND active_ind=1
  DETAIL
   kount += 1
   IF (mod(kount,100)=1)
    stat = alter(reply->org_bnft_set_r,(kount+ 100))
   ENDIF
   reply->org_bnft_set_r[kount].org_bnft_set_id = p.org_bnft_set_id, reply->org_bnft_set_r[kount].
   organization_id = p.organization_id, reply->org_bnft_set_r[kount].hp_bnft_set_id = p
   .hp_bnft_set_id,
   reply->org_bnft_set_r[kount].description = p.description, reply->org_bnft_set_r[kount].
   coverage_status_cd = p.coverage_status_cd, reply->org_bnft_set_r[kount].beg_effective_dt_tm = p
   .beg_effective_dt_tm,
   reply->org_bnft_set_r[kount].end_effective_dt_tm = p.end_effective_dt_tm,
   CALL echo("ORG_BNFT_SET_ID :",0),
   CALL echo(p.org_bnft_set_id)
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "P"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->org_bnft_set_r,kount)
 SET reply->org_bnft_set_r_qual = kount
 CALL echo("status:",0)
 CALL echo(reply->status_data.status)
 CALL echo("kount:",0)
 CALL echo(kount)
END GO
