CREATE PROGRAM ct_get_org_security:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orgsecurityflag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE bstat = i2 WITH protect, noconstant(0)
 DECLARE org_security_off = i2 WITH protect, constant(0)
 DECLARE org_security_on = i2 WITH protect, constant(1)
 SET reply->status_data.status = failed
 RECORD pref_request(
   1 pref_entry = vc
 )
 RECORD pref_reply(
   1 pref_value = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->orgsecurityflag = org_security_off
 SELECT INTO "nl:"
  FROM dm_info dmi
  WHERE dmi.info_domain="SECURITY"
   AND dmi.info_name="SEC_ORG_RELTN"
   AND dmi.info_number > 0.0
  DETAIL
   reply->orgsecurityflag = org_security_on,
   CALL echo("here")
  WITH nocounter
 ;end select
 IF ((reply->orgsecurityflag=org_security_on))
  SET pref_request->pref_entry = "pt_org_security"
  EXECUTE ct_get_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
  CALL echo(build("pref",pref_reply->pref_value))
  IF ((pref_reply->pref_value=1))
   SET reply->orgsecurityflag = org_security_on
  ELSE
   SET reply->orgsecurityflag = org_security_off
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET last_mod = "000"
 SET mod_date = "May 12, 2008"
END GO
