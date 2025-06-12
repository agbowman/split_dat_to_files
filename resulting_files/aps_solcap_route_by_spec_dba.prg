CREATE PROGRAM aps_solcap_route_by_spec:dba
 DECLARE solcap_cnt = i4 WITH protect, noconstant(0)
 DECLARE fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE pref_value = vc WITH protect, noconstant("")
 EXECUTE prefrtl
 DECLARE loadfacilitypreference(facilitycd=f8,sectionname=vc,sectionid=vc,group=vc,subgroup=vc,
  entry=vc) = vc
 DECLARE getpreferencevalue(hgroup=i4,entry=vc) = vc
 SET solcap_cnt = (solcap_cnt+ 1)
 SET stat = alterlist(reply->solcap,solcap_cnt)
 SET reply->solcap[solcap_cnt].identifier = "2016.1.00703.1"
 SET reply->solcap[solcap_cnt].degree_of_use_num = 0
 SET reply->solcap[solcap_cnt].degree_of_use_str = "No"
 SET reply->solcap[solcap_cnt].distinct_user_count = 0
 SET pref_value = loadfacilitypreference(0.0,"module","Anatomic Pathology","","",
  "route tasks by specimen location")
 IF (cnvtupper(pref_value)="YES")
  SET reply->solcap[solcap_cnt].degree_of_use_str = "Yes"
 ENDIF
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
  ORDER BY cv.display
  DETAIL
   pref_value = loadfacilitypreference(cv.code_value,"module","Anatomic Pathology","","",
    "route tasks by specimen location")
   IF (cnvtupper(pref_value)="YES")
    fac_cnt = (fac_cnt+ 1)
    IF (mod(fac_cnt,10)=1)
     stat = alterlist(reply->solcap[solcap_cnt].facility,(fac_cnt+ 9))
    ENDIF
    reply->solcap[solcap_cnt].facility[fac_cnt].display = cv.display, reply->solcap[solcap_cnt].
    facility[fac_cnt].value_str = "Yes", reply->solcap[solcap_cnt].degree_of_use_str = "Yes"
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->solcap[solcap_cnt].facility,fac_cnt)
  WITH nocounter
 ;end select
 SUBROUTINE loadfacilitypreference(facilitycd,sectionname,sectionid,group,subgroup,entry)
   DECLARE prefstat = i4 WITH noconstant(0)
   DECLARE hpref = i4 WITH noconstant(0)
   DECLARE hgroup = i4 WITH noconstant(0)
   DECLARE hsubgroup = i4 WITH noconstant(0)
   DECLARE hsection = i4 WITH noconstant(0)
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    RETURN("Unknown - probably not logged in.")
   ENDIF
   SET prefstat = uar_prefaddcontext(hpref,nullterm("default"),nullterm("system"))
   IF (prefstat != 1)
    CALL uar_prefdestroyinstance(hpref)
    RETURN("Unknown")
   ENDIF
   IF (facilitycd != 0)
    SET prefstat = uar_prefaddcontext(hpref,nullterm("facility"),nullterm(cnvtstring(facilitycd,19,2)
      ))
    IF (prefstat != 1)
     CALL uar_prefdestroyinstance(hpref)
     RETURN("Unknown")
    ENDIF
   ENDIF
   SET prefstat = uar_prefsetsection(hpref,nullterm(sectionname))
   IF (prefstat != 1)
    CALL uar_prefdestroyinstance(hpref)
    RETURN("Unknown")
   ENDIF
   SET hgroup = uar_prefcreategroup()
   IF (hgroup=0)
    CALL uar_prefdestroyinstance(hpref)
    RETURN("Unknown")
   ENDIF
   SET prefstat = uar_prefsetgroupname(hgroup,nullterm(sectionid))
   IF (prefstat != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN("Unknown")
   ENDIF
   IF (size(trim(group),1) > 0)
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(group))
    IF (hsubgroup=0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     RETURN("Unknown")
    ENDIF
   ENDIF
   IF (size(trim(subgroup),1) > 0)
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(subgroup))
    IF (hsubgroup=0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     RETURN("Unknown")
    ENDIF
   ENDIF
   SET prefstat = uar_prefaddgroup(hpref,hgroup)
   IF (prefstat != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN("Unknown")
   ENDIF
   SET prefstat = uar_prefperform(hpref)
   IF (prefstat != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN("Unknown")
   ENDIF
   CALL uar_prefdestroygroup(hgroup)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm(sectionname))
   IF (hsection=0)
    CALL uar_prefdestroyinstance(hpref)
    RETURN("Unknown")
   ENDIF
   SET hgroup = uar_prefgetgroupbyname(hsection,nullterm(sectionid))
   IF (hgroup=0)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroyinstance(hpref)
    RETURN("Unknown")
   ENDIF
   IF (size(trim(subgroup),1) > 0)
    SET hsubgroup = uar_prefgetsubgroup(hsubgroup,0)
    IF (hsubgroup=0)
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroyinstance(hpref)
     RETURN("Unknown")
    ENDIF
   ENDIF
   IF (size(trim(group),1) > 0)
    DECLARE result = vc WITH constant(getpreferencevalue(hsubgroup,entry))
   ELSE
    DECLARE result = vc WITH constant(getpreferencevalue(hgroup,entry))
   ENDIF
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroyinstance(hpref)
   RETURN(result)
 END ;Subroutine
 SUBROUTINE getpreferencevalue(hgroup,entry)
   FREE SET prefstat
   DECLARE prefstat = i4 WITH noconstant(0)
   DECLARE entryname = c255 WITH noconstant("")
   DECLARE len = i4 WITH noconstant(255)
   DECLARE entrycnt = i4 WITH noconstant(0)
   SET prefstat = uar_prefgetgroupentrycount(hgroup,entrycnt)
   IF (prefstat != 1)
    RETURN("Unknown")
   ENDIF
   DECLARE idxentry = i4 WITH noconstant(0)
   FOR (idxentry = 0 TO (entrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hgroup,idxentry)
     IF (hentry=0)
      RETURN("Unknown")
     ENDIF
     SET len = 255
     SET entryname = fillstring(255,"")
     SET prefstat = uar_prefgetentryname(hentry,entryname,len)
     IF (prefstat=1
      AND nullterm(entryname)=entry)
      DECLARE attrcnt = i4 WITH noconstant(0)
      SET prefstat = uar_prefgetentryattrcount(hentry,attrcnt)
      IF (prefstat != 1)
       RETURN("Unknown")
      ENDIF
      DECLARE idxattr = i4 WITH noconstant(0)
      FOR (idxattr = 0 TO (attrcnt - 1))
        DECLARE hattr = i4 WITH noconstant(0)
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        IF (hattr != 0)
         SET len = 255
         DECLARE attrname = c255 WITH noconstant("")
         SET prefstat = uar_prefgetattrname(hattr,attrname,len)
         IF (prefstat=1
          AND trim(attrname)="prefvalue")
          SET len = 255
          DECLARE val = c255 WITH noconstant("")
          SET prefstat = uar_prefgetattrval(hattr,val,len,0)
          IF (prefstat != 1)
           RETURN("Unknown")
          ENDIF
          RETURN(trim(val))
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN("Unknown")
 END ;Subroutine
END GO
