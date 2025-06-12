CREATE PROGRAM ct_get_facilities:dba
 RECORD reply(
   1 facility_list[*]
     2 facility_display = vc
     2 facility_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE userorgstr = vc WITH protect
 DECLARE faccode = f8 WITH protect, noconstant(0)
 DECLARE count = i2 WITH protect, noconstant(0)
 DECLARE fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE org_security = i2 WITH protect, noconstant(0)
 SET org_security = request->org_security
 SET reply->status_data.status = "F"
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
 SET stat = uar_get_meaning_by_codeset(222,"FACILITY",1,faccode)
 IF ((org_security=- (1)))
  RECORD org_sec_reply(
    1 orgsecurityflag = i2
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
  EXECUTE ct_get_org_security  WITH replace("REPLY","ORG_SEC_REPLY")
  CALL echo(build("org_sec_reply->OrgSecurityFlag: ",org_sec_reply->orgsecurityflag))
  SET org_security = org_sec_reply->orgsecurityflag
 ENDIF
 IF (org_security=1)
  SET userorgstr = builduserorglist("l.organization_id")
 ELSE
  SET userorgstr = "1=1"
 ENDIF
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
    stat = alterlist(reply->facility_list,(fac_cnt+ 9))
   ENDIF
   reply->facility_list[fac_cnt].facility_display = cnvtupper(f.display), reply->facility_list[
   fac_cnt].facility_cd = f.code_value
  FOOT REPORT
   stat = alterlist(reply->facility_list,fac_cnt)
  WITH nocounter, orahintcbo(" GATHER_PLAN_STATISTICS ")
 ;end select
 SET reply->status_data.status = "S"
 SET last_mod = "001"
 SET mod_date = "Nov 25, 2019"
END GO
