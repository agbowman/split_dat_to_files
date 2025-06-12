CREATE PROGRAM ct_get_facility_list:dba
 IF ( NOT (validate(facilitylist)))
  RECORD facilitylist(
    1 skip = i2
    1 org_security_ind = i2
    1 org_security_fnd = i2
    1 facility_list[*]
      2 facility_display = vc
      2 facility_cd = f8
  )
 ENDIF
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE userorgstr = vc WITH protect
 DECLARE faccode = f8 WITH protect, noconstant(0)
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE fac_cnt = i2 WITH protect, noconstant(0)
 RECORD user_org_reply(
   1 organizations[*]
     2 organization_id = f8
     2 confid_cd = f8
     2 confid_level = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE userorgsize = i2 WITH protect, noconstant(0)
 DECLARE orgidx = i2 WITH protect, noconstant(0)
 DECLARE orgstr = vc WITH protect
 SUBROUTINE (builduserorglist(tablestr=vc) =vc)
   EXECUTE ct_get_user_orgs  WITH replace("REPLY","USER_ORG_REPLY")
   SET userorgsize = size(user_org_reply->organizations,5)
   IF (userorgsize > 0)
    SET orgstr = build("expand(orgIdx, 1, userOrgSize, ",tablestr,
     ", user_org_reply->organizations[orgIdx]->organization_id)")
   ELSE
    SET orgstr = "1=1"
   ENDIF
   RETURN(orgstr)
 END ;Subroutine
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
 IF ((facilitylist->skip=0))
  EXECUTE ccl_prompt_api_dataset "dataset"
 ENDIF
 SET stat = uar_get_meaning_by_codeset(222,"FACILITY",1,faccode)
 IF ((facilitylist->org_security_fnd=0))
  RECORD org_sec_reply(
    1 orgsecurityflag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
  CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
  SET facilitylist->org_security_ind = org_sec_reply->orgsecurityflag
 ENDIF
 IF ((facilitylist->org_security_ind=1))
  SET userorgstr = builduserorglist("l.organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
 IF ((facilitylist->skip=0))
  SELECT DISTINCT INTO "NL:"
   item_display = f.display, item_keyvalue = f.code_value
   FROM code_value f,
    location_group lg,
    location l,
    organization org
   PLAN (lg
    WHERE lg.location_group_type_cd=faccode
     AND lg.active_ind=1)
    JOIN (f
    WHERE f.code_value=lg.parent_loc_cd
     AND f.cdf_meaning="FACILITY"
     AND f.active_ind=1)
    JOIN (l
    WHERE l.location_cd=f.code_value
     AND parser(userorgstr))
    JOIN (org
    WHERE org.organization_id=l.organization_id
     AND (org.logical_domain_id=domain_reply->logical_domain_id))
   ORDER BY cnvtupper(f.display)
   HEAD REPORT
    stat = makedataset(1000)
   DETAIL
    stat = writerecord(0)
   FOOT REPORT
    stat = closedataset(0)
   WITH maxrow = 1, reporthelp, check
  ;end select
 ELSE
  SELECT DISTINCT INTO "NL:"
   item_display = f.display, item_keyvalue = f.code_value
   FROM code_value f,
    location_group lg,
    location l,
    organization org
   PLAN (lg
    WHERE lg.location_group_type_cd=faccode
     AND lg.active_ind=1)
    JOIN (f
    WHERE f.code_value=lg.parent_loc_cd
     AND f.cdf_meaning="FACILITY"
     AND f.active_ind=1)
    JOIN (l
    WHERE l.location_cd=f.code_value
     AND parser(userorgstr))
    JOIN (org
    WHERE org.organization_id=l.organization_id
     AND (org.logical_domain_id=domain_reply->logical_domain_id))
   ORDER BY cnvtupper(f.display)
   HEAD REPORT
    fac_cnt = 0
   DETAIL
    fac_cnt += 1
    IF (mod(fac_cnt,10)=1)
     stat = alterlist(facilitylist->facility_list,(fac_cnt+ 9))
    ENDIF
    facilitylist->facility_list[fac_cnt].facility_display = f.display, facilitylist->facility_list[
    fac_cnt].facility_cd = f.code_value
   FOOT REPORT
    stat = alterlist(facilitylist->facility_list,fac_cnt)
   WITH nocounter
  ;end select
 ENDIF
 SET last_mod = "001"
 SET mod_date = "Nov 25, 2008"
END GO
