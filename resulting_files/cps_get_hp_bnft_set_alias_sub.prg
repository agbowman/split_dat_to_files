CREATE PROGRAM cps_get_hp_bnft_set_alias_sub
 SET kount = 0
 SELECT INTO "nl:"
  p.*
  FROM hp_bnft_set_alias p,
   hp_bnft_set h
  PLAN (p
   WHERE  $1
    AND  $2
    AND p.active_ind=1)
   JOIN (h
   WHERE h.hp_bnft_set_id=p.hp_bnft_set_id)
  DETAIL
   kount = (kount+ 1)
   IF (mod(kount,100)=1)
    stat = alter(reply->hp_bnft_set_alias,(kount+ 100))
   ENDIF
   reply->hp_bnft_set_alias[kount].bnft_set_alias_id = p.bnft_set_alias_id, reply->hp_bnft_set_alias[
   kount].hp_bnft_set_id = p.hp_bnft_set_id, reply->hp_proc_limit[kount].bnft_set_description = h
   .description,
   reply->hp_bnft_set_alias[kount].alias = p.alias, reply->hp_bnft_set_alias[kount].
   beg_effective_dt_tm = p.beg_effective_dt_tm, reply->hp_bnft_set_alias[kount].end_effective_dt_tm
    = p.end_effective_dt_tm,
   CALL echo("BNFT_SET_ALIAS_id:",0),
   CALL echo(p.bnft_set_alias_id)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alter(reply->hp_bnft_set_alias,kount)
 SET reply->hp_bnft_set_alias_qual = kount
 CALL echo("status:",0)
 CALL echo(reply->status_data.status)
 CALL echo("kount:",0)
 CALL echo(kount)
END GO
