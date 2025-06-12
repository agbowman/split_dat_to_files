CREATE PROGRAM ct_get_users_pref:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 qual[*]
      2 prsnl_id = f8
      2 functionality_type = i2
      2 preference_shared = i2
      2 preference_txt = vc
      2 facilities[*]
        3 facility_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE fac_cnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET prsnl_cnt = size(request->prsnls,5)
 SELECT INTO "nl:"
  FROM ct_user_preference cup,
   (dummyt d  WITH seq = value(prsnl_cnt)),
   ct_facility_cd_group cfcg
  PLAN (d)
   JOIN (cup
   WHERE (cup.prsnl_id=request->prsnls[d.seq].prsnl_id)
    AND (cup.functionality_type_flag=request->prsnls[d.seq].functionality_type)
    AND (cup.prot_master_id=request->prsnls[d.seq].prot_id)
    AND cup.active_ind=1)
   JOIN (cfcg
   WHERE cfcg.facility_group_id=cup.ct_facility_cd_group_id)
  ORDER BY cup.prsnl_id, cfcg.facility_group_id
  HEAD REPORT
   qual_cnt = 0
  HEAD cup.prsnl_id
   qual_cnt += 1
   IF (mod(qual_cnt,10)=1)
    stat = alterlist(reply->qual,(qual_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].prsnl_id = cup.prsnl_id, reply->qual[qual_cnt].preference_shared = cup
   .preference_status_flag, reply->qual[qual_cnt].preference_txt = cup.preference_text,
   reply->qual[qual_cnt].functionality_type = cup.functionality_type_flag, fac_cnt = 0
  DETAIL
   fac_cnt += 1
   IF (mod(fac_cnt,10)=1)
    stat = alterlist(reply->qual[qual_cnt].facilities,(fac_cnt+ 9))
   ENDIF
   reply->qual[qual_cnt].facilities[fac_cnt].facility_cd = cfcg.facility_cd
  FOOT  cup.prsnl_id
   stat = alterlist(reply->qual[qual_cnt].facilities,fac_cnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,qual_cnt)
 SET reply->status_data.status = "S"
 SET last_mod = "000"
 SET mod_date = "June 14, 2018"
END GO
