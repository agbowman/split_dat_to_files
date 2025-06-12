CREATE PROGRAM dts_get_position_cds:dba
 RECORD reply(
   1 qual[*]
     2 position_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET privilege_cd = 0.0
 SET priv_value_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_value = 0.0
 SET code_set = 6016
 SET cdf_meaning = "SIGNDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET privilege_cd = code_value
 SET code_set = 6017
 SET cdf_meaning = "NO"
 EXECUTE cpm_get_cd_for_cdf
 SET priv_value_cd = code_value
 SELECT INTO "nl:"
  p.position_cd
  FROM privilege pr,
   priv_loc_reltn p
  PLAN (pr
   WHERE pr.privilege_cd=privilege_cd
    AND pr.active_ind=1
    AND pr.priv_value_cd=priv_value_cd)
   JOIN (p
   WHERE p.priv_loc_reltn_id=pr.priv_loc_reltn_id)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].position_cd = p.position_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,cnt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
