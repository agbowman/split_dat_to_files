CREATE PROGRAM ct_get_default_roles:dba
 SET modify = predeclare
 RECORD reply(
   1 defroles[*]
     2 prot_default_role_id = f8
     2 person_id = f8
     2 person_name = vc
     2 organization_id = f8
     2 org_name = vc
     2 prot_role_cd = f8
     2 prot_role_disp = vc
     2 prot_role_desc = vc
     2 prot_role_mean = vc
     2 role_type_cd = f8
     2 role_type_disp = vc
     2 role_type_desc = vc
     2 role_type_mean = vc
     2 position_cd = f8
     2 position_disp = vc
     2 position_desc = vc
     2 position_mean = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 SET reply->status_data.status = "F"
 DECLARE fail_flag = i2 WITH private, noconstant(0)
 DECLARE rolecnt = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE search_for_roles_error = i2 WITH private, constant(1)
 SELECT INTO "nl:"
  FROM prot_default_roles pdr,
   organization org,
   person p
  PLAN (pdr
   WHERE (pdr.logical_domain_id=domain_reply->logical_domain_id))
   JOIN (org
   WHERE org.organization_id=pdr.organization_id)
   JOIN (p
   WHERE p.person_id=pdr.person_id)
  DETAIL
   rolecnt += 1
   IF (mod(rolecnt,10)=1)
    stat = alterlist(reply->defroles,(rolecnt+ 9))
   ENDIF
   reply->defroles[rolecnt].prot_default_role_id = pdr.prot_default_role_id, reply->defroles[rolecnt]
   .person_id = pdr.person_id, reply->defroles[rolecnt].person_name = p.name_full_formatted,
   reply->defroles[rolecnt].organization_id = pdr.organization_id, reply->defroles[rolecnt].org_name
    = org.org_name, reply->defroles[rolecnt].prot_role_cd = pdr.prot_role_cd,
   reply->defroles[rolecnt].role_type_cd = pdr.role_type_cd, reply->defroles[rolecnt].position_cd =
   pdr.position_cd
  WITH nocounter
 ;end select
 CALL echo(build("rolecnt is ",rolecnt))
 SET stat = alterlist(reply->defroles,rolecnt)
 IF (rolecnt > 0)
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET fail_flag = search_for_roles_error
   GO TO check_error
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "Z"
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
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Searching for default roles"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectname = ""
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "February 11, 2019"
END GO
