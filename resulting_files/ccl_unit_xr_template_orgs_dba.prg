CREATE PROGRAM ccl_unit_xr_template_orgs:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 organizations[*]
      2 organization_id = f8
      2 confid_cd = f8
      2 confid_level = f8
  )
 ENDIF
 CALL echo("Entering ccl_unit_xr_template_orgs script")
 CALL echo(build("reqinfo updt_id = ",reqinfo->updt_id))
 IF ((reqinfo->updt_id=123456.0))
  SET stat = alterlist(reply->organizations,1)
  SET reply->organizations[1].organization_id = 234.0
 ELSEIF ((reqinfo->updt_id=234567.0))
  SET stat = alterlist(reply->organizations,1)
  SET reply->organizations[1].organization_id = 123.0
 ENDIF
 CALL echorecord(reply)
 CALL echo("Exiting ccl_unit_xr_template_orgs script")
END GO
