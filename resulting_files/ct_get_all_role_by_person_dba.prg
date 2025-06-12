CREATE PROGRAM ct_get_all_role_by_person:dba
 RECORD reply(
   1 qual[*]
     2 prot_role_cd = f8
     2 prot_role_disp = vc
     2 prot_role_desc = c50
     2 prot_role_mean = c12
   1 organization_id = f8
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
 DECLARE search_for_roles_error = i2 WITH private, constant(1)
 DECLARE person_in_request = i2 WITH private, constant(2)
 IF ((request->person_id=0))
  SET fail_flag = person_in_request
  GO TO check_error
 ELSE
  SELECT DISTINCT INTO "nl:"
   pr.prot_role_cd, disp = uar_get_code_display(pr.prot_role_cd)
   FROM prot_role pr
   PLAN (pr
    WHERE (pr.person_id=request->person_id)
     AND pr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
     AND pr.prot_role_cd > 0)
   ORDER BY disp, pr.prot_role_cd
   HEAD pr.prot_role_cd
    role_cnt = (role_cnt+ 1)
    IF (mod(role_cnt,10)=1)
     stat = alterlist(reply->qual,(role_cnt+ 9))
    ENDIF
    reply->qual[role_cnt].prot_role_cd = pr.prot_role_cd, reply->organization_id = pr.organization_id
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,role_cnt)
  CALL echo(build("Roles found: ",role_cnt))
  IF (role_cnt > 0)
   IF (curqual=0)
    SET fail_flag = search_for_roles_error
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
   OF search_for_roles_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Searching for roles by person"
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
