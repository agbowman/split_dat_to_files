CREATE PROGRAM dcp_get_org_security:dba
 RECORD reply(
   1 encntr_org_security_ind = i2
   1 confid_security_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dminfo_ok = i2 WITH noconstant(0), private
 SET reply->status_data.status = "F"
 SET reply->encntr_org_security_ind = 0
 SET reply->confid_security_ind = 0
 SET dminfo_ok = validate(ccldminfo->mode,0)
 IF (dminfo_ok=1)
  SET reply->encntr_org_security_ind = ccldminfo->sec_org_reltn
  SET reply->confid_security_ind = ccldminfo->sec_confid
 ELSE
  SELECT INTO "nl:"
   FROM dm_info dmi
   WHERE dmi.info_domain="SECURITY"
    AND dmi.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID")
    AND dmi.info_number=1
   DETAIL
    IF (dmi.info_name="SEC_ORG_RELTN")
     reply->encntr_org_security_ind = 1
    ELSE
     reply->confid_security_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
END GO
