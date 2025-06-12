CREATE PROGRAM ct_get_person_prots_by_role:dba
 RECORD reply(
   1 protocols[*]
     2 prot_master_id = f8
     2 primary_mnemonic = vc
     2 prot_role_cd = f8
     2 prot_role_disp = vc
     2 prot_role_desc = c50
     2 prot_role_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE role_cnt = i2 WITH protect, noconstant(0)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 DECLARE search_for_prots_error = i2 WITH private, constant(1)
 DECLARE person_in_request = i2 WITH private, constant(2)
 IF ((request->person_id=0))
  SET fail_flag = person_in_request
  GO TO check_error
 ELSE
  SELECT DISTINCT INTO "nl:"
   pr.prot_role_cd, pm.primary_mnemonic, disp = uar_get_code_display(pr.prot_role_cd)
   FROM prot_role pr,
    prot_amendment pa,
    prot_master pm,
    (dummyt d2  WITH seq = value(cnvtint(size(request->role_list,5))))
   PLAN (d2)
    JOIN (pr
    WHERE (pr.person_id=request->person_id)
     AND (pr.prot_role_cd=request->role_list[d2.seq].prot_role_cd)
     AND pr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
    JOIN (pa
    WHERE pa.prot_amendment_id=pr.prot_amendment_id)
    JOIN (pm
    WHERE pm.prot_master_id=pa.prot_master_id
     AND pm.prot_master_id > 0
     AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY disp, pm.primary_mnemonic, pm.prot_master_id
   HEAD pm.prot_master_id
    role_cnt = (role_cnt+ 1)
    IF (mod(role_cnt,10)=1)
     stat = alterlist(reply->protocols,(role_cnt+ 9))
    ENDIF
   DETAIL
    reply->protocols[role_cnt].prot_master_id = pm.prot_master_id, reply->protocols[role_cnt].
    primary_mnemonic = pm.primary_mnemonic, reply->protocols[role_cnt].prot_role_cd = pr.prot_role_cd
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->protocols,role_cnt)
  CALL echo(build("Protocols found: ",role_cnt))
  IF (role_cnt > 0)
   IF (curqual=0)
    SET fail_flag = search_for_prots_error
    GO TO check_error
   ENDIF
  ENDIF
 ENDIF
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF search_for_prots_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Searching for protocols by role and person"
   OF person_in_request:
    SET reply->status_data.subeventstatus[1].operationname = "REQUEST"
    SET reply->status_data.subeventstatus[1].targetobjectname = "QUAL"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "No person in request"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
END GO
