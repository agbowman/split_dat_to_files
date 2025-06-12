CREATE PROGRAM cdi_get_logical_domain:dba
 RECORD reply(
   1 logical_domain_id = f8
   1 logical_domain_name = vc
   1 logical_domain_key = vc
   1 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT
  IF ((request->username_ind=1))
   PLAN (p
    WHERE p.username=cnvtupper(request->username)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (d
    WHERE p.logical_domain_id=d.logical_domain_id)
  ELSE
   PLAN (p
    WHERE (p.person_id=reqinfo->updt_id)
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    JOIN (d
    WHERE p.logical_domain_id=d.logical_domain_id)
  ENDIF
  INTO "nl:"
  d.active_ind, d.mnemonic, d.mnemonic_key
  FROM prsnl p,
   logical_domain d
  DETAIL
   reply->active_ind = d.active_ind, reply->logical_domain_id = d.logical_domain_id, reply->
   logical_domain_name = d.mnemonic,
   reply->logical_domain_key = d.mnemonic_key
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
