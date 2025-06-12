CREATE PROGRAM dcp_get_query_temp_access_info:dba
 RECORD reply(
   1 positions[*]
     2 position_cd = f8
   1 provider_groups[*]
     2 provider_group_id = f8
   1 providers[*]
     2 provider_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE cnt2 = i4 WITH noconstant(0)
 DECLARE cnt3 = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM dcp_pl_query_temp_access qta
  WHERE (qta.template_id=request->template_id)
  DETAIL
   cnt = (cnt+ 1), cnt2 = (cnt2+ 1), cnt3 = (cnt3+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->positions,(cnt+ 9))
   ENDIF
   IF (mod(cnt2,10)=1)
    stat = alterlist(reply->provider_groups,(cnt2+ 9))
   ENDIF
   IF (mod(cnt3,10)=1)
    stat = alterlist(reply->providers,(cnt3+ 9))
   ENDIF
   reply->positions[cnt].position_cd = qta.position_cd, reply->provider_groups[cnt2].
   provider_group_id = qta.provider_group_id, reply->providers[cnt3].provider_id = qta.provider_id
  FOOT REPORT
   stat = alterlist(reply->positions,cnt), stat = alterlist(reply->provider_groups,cnt2), stat =
   alterlist(reply->providers,cnt3)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
