CREATE PROGRAM ct_get_episode_enctr_reltn:dba
 RECORD reply(
   1 related_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 SET reply->related_ind = 0
 SELECT INTO "nl:"
  FROM episode_encntr_reltn eer
  WHERE (eer.encntr_id=request->encounter_id)
   AND (eer.episode_id=request->episode_id)
   AND eer.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   AND eer.active_ind=1
  DETAIL
   reply->related_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
 SET last_mod = "000"
 SET mod_date = "May 7, 2008"
END GO
