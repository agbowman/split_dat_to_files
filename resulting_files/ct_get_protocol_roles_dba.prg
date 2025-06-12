CREATE PROGRAM ct_get_protocol_roles:dba
 RECORD reply(
   1 persons[*]
     2 person_name = vc
     2 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE personal_cd = f8 WITH protect, noconstant(0)
 DECLARE prsn_cnt = f8 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(17296,"PERSONAL",1,personal_cd)
 SET reply->status_data.status = "F"
 SELECT DISTINCT INTO "NL:"
  FROM prot_master pm,
   prot_amendment pa,
   prot_role pr,
   prsnl p
  PLAN (pm
   WHERE (pm.prot_master_id=request->prot_master_id)
    AND pm.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (pa
   WHERE pa.prot_master_id=pm.prot_master_id
    AND pa.amendment_status_cd=pm.prot_status_cd)
   JOIN (pr
   WHERE pr.prot_amendment_id=pa.prot_amendment_id
    AND pr.prot_role_type_cd=personal_cd
    AND pr.person_id > 0
    AND pr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=pr.person_id)
  ORDER BY cnvtupper(p.name_full_formatted)
  DETAIL
   prsn_cnt += 1
   IF (mod(prsn_cnt,10)=1)
    stat = alterlist(reply->persons,(prsn_cnt+ 9))
   ENDIF
   reply->persons[prsn_cnt].person_name = p.name_full_formatted, reply->persons[prsn_cnt].person_id
    = p.person_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->persons,prsn_cnt)
 SET reply->status_data.status = "S"
 SET last_mod = "000"
 SET mod_date = "June 07, 2018"
END GO
