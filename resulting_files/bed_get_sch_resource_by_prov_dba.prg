CREATE PROGRAM bed_get_sch_resource_by_prov:dba
 FREE SET reply
 RECORD reply(
   1 providers[*]
     2 person_id = f8
     2 resource
       3 code_value = f8
       3 mnemonic = vc
       3 booking_limit = i2
     2 schedule_template_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14490
    AND c.cdf_meaning="ACTIVE"
    AND c.active_ind=1)
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 SET cnt = 0
 SET tot_providers = size(request->providers,5)
 IF (tot_providers=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = tot_providers),
   sch_resource sr
  PLAN (d)
   JOIN (sr
   WHERE (sr.person_id=request->providers[d.seq].person_id)
    AND sr.active_ind=1)
  ORDER BY sr.person_id
  HEAD sr.person_id
   cnt = (cnt+ 1), stat = alterlist(reply->providers,cnt), reply->providers[cnt].person_id = sr
   .person_id,
   reply->providers[cnt].resource.code_value = sr.resource_cd, reply->providers[cnt].resource.
   mnemonic = sr.mnemonic, reply->providers[cnt].resource.booking_limit = sr.quota
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->providers,5))),
    sch_def_apply s
   PLAN (d)
    JOIN (s
    WHERE (s.resource_cd=reply->providers[d.seq].resource.code_value)
     AND s.beg_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND s.end_dt_tm >= cnvtdatetime(curdate,curtime3)
     AND s.def_state_cd=active_cd
     AND s.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->providers[d.seq].schedule_template_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (size(reply->providers,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
