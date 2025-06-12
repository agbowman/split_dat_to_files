CREATE PROGRAM aps_solcap_foreign_order_alias:dba
 EXECUTE prefrtl
 FREE SET prefvalues
 RECORD prefvalues(
   1 prefs[*]
     2 value = vc
 )
 DECLARE prefstat = i4 WITH noconstant(0)
 SUBROUTINE (loadpreferences(sys_con=i2,facilitycd=f8,positioncd=f8,sectionname=vc,sectionid=vc,group
  =vc,subgroup=vc,entry=vc) =i2)
   DECLARE hpref = i4 WITH noconstant(0)
   DECLARE hgroup = i4 WITH noconstant(0)
   DECLARE hsubgroup = i4 WITH noconstant(0)
   DECLARE hsection = i4 WITH noconstant(0)
   SET prefstat = initrec(prefvalues)
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    RETURN(- (1))
   ENDIF
   IF (sys_con=1)
    SET prefstat = uar_prefaddcontext(hpref,"default","system")
    IF (prefstat != 1)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (facilitycd > 0)
    SET prefstat = uar_prefaddcontext(hpref,"facility",nullterm(cnvtstring(facilitycd,19,2)))
    IF (prefstat != 1)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (positioncd > 0)
    SET prefstat = uar_prefaddcontext(hpref,"position",nullterm(cnvtstring(positioncd,19,2)))
    IF (prefstat != 1)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prefstat = uar_prefsetsection(hpref,nullterm(sectionname))
   IF (prefstat != 1)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(- (1))
   ENDIF
   SET hgroup = uar_prefcreategroup()
   IF (hgroup=0)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(- (1))
   ENDIF
   SET prefstat = uar_prefsetgroupname(hgroup,nullterm(sectionid))
   IF (prefstat != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(group)) > 0)
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(group))
    IF (hsubgroup=0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(subgroup)) > 0)
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(subgroup))
    IF (hsubgroup=0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prefstat = uar_prefaddgroup(hpref,hgroup)
   IF (prefstat != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(- (1))
   ENDIF
   SET prefstat = uar_prefperform(hpref)
   IF (prefstat != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(- (1))
   ENDIF
   CALL uar_prefdestroygroup(hgroup)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm(sectionname))
   IF (hsection=0)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(- (1))
   ENDIF
   SET hgroup = uar_prefgetgroupbyname(hsection,nullterm(sectionid))
   IF (hgroup=0)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(group)) > 0)
    SET hsubgroup = uar_prefgetsubgroup(hgroup,0)
    IF (hsubgroup=0)
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(subgroup)) > 0)
    SET hsubgroup = uar_prefgetsubgroup(hsubgroup,0)
    IF (hsubgroup=0)
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(- (1))
    ENDIF
   ENDIF
   DECLARE fac_pref_result = i2 WITH noconstant(- (1))
   IF (hsubgroup > 0)
    SET fac_pref_result = getpreferencevalue(hsubgroup,entry)
   ELSE
    SET fac_pref_result = getpreferencevalue(hgroup,entry)
   ENDIF
   IF (hsection > 0)
    CALL uar_prefdestroysection(hsection)
   ENDIF
   IF (hsubgroup > 0)
    CALL uar_prefdestroygroup(hsubgroup)
   ENDIF
   IF (hgroup > 0)
    CALL uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hpref > 0)
    CALL uar_prefdestroyinstance(hpref)
   ENDIF
   RETURN(fac_pref_result)
 END ;Subroutine
 SUBROUTINE (getpreferencevalue(hgroup=i4,entry=vc) =i2)
   DECLARE entryname = c255 WITH noconstant("")
   DECLARE len = i4 WITH noconstant(255)
   DECLARE success_ind = i2 WITH noconstant(- (1))
   DECLARE hentry = i4 WITH noconstant(0)
   DECLARE pref_val_count = i4 WITH noconstant(0)
   DECLARE idxval = i4 WITH noconstant(0)
   DECLARE pref_val_disp = c255 WITH noconstant("")
   DECLARE hval = i4 WITH noconstant(0)
   DECLARE entrycnt = i4 WITH noconstant(0)
   SET prefstat = uar_prefgetgroupentrycount(hgroup,entrycnt)
   IF (prefstat != 1)
    RETURN(- (1))
   ENDIF
   DECLARE idxentry = i4 WITH noconstant(0)
   FOR (idxentry = 0 TO (entrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hgroup,idxentry)
     IF (hentry=0)
      RETURN(- (1))
     ENDIF
     SET len = 255
     SET entryname = fillstring(255,"")
     SET prefstat = uar_prefgetentryname(hentry,entryname,len)
     IF (prefstat != 1)
      CALL uar_prefdestroyentry(hentry)
      RETURN(- (1))
     ENDIF
     IF (prefstat=1
      AND nullterm(entryname)=entry)
      DECLARE attrcnt = i4 WITH noconstant(0)
      SET prefstat = uar_prefgetentryattrcount(hentry,attrcnt)
      IF (prefstat != 1)
       CALL uar_prefdestroyentry(hentry)
       RETURN(- (1))
      ENDIF
      DECLARE idxattr = i4 WITH noconstant(0)
      FOR (idxattr = 0 TO (attrcnt - 1))
        DECLARE hattr = i4 WITH noconstant(0)
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        IF (hattr != 0)
         SET len = 255
         DECLARE attrname = c255 WITH noconstant("")
         SET prefstat = uar_prefgetattrname(hattr,attrname,len)
         IF (prefstat != 1)
          CALL uar_prefdestroyentry(hentry)
          CALL uar_prefdestroyattr(hattr)
          RETURN(- (1))
         ENDIF
         IF (prefstat=1
          AND trim(attrname)="prefvalue")
          SET pref_val_count = 0
          SET prefstat = uar_prefgetattrvalcount(hattr,pref_val_count)
          IF (((prefstat != 1) OR (pref_val_count=0)) )
           CALL uar_prefdestroyentry(hentry)
           CALL uar_prefdestroyattr(hattr)
           RETURN(- (1))
          ENDIF
          SET idxval = 0
          SET prefstat = alterlist(prefvalues->prefs,pref_val_count)
          SET success_ind = 1
          FOR (idxval = 0 TO (pref_val_count - 1))
            SET hval = 0
            SET pref_val_disp = fillstring(255," ")
            SET len = 255
            SET hval = uar_prefgetattrval(hattr,pref_val_disp,len,idxval)
            SET prefvalues->prefs[(idxval+ 1)].value = nullterm(pref_val_disp)
          ENDFOR
         ENDIF
        ENDIF
        IF (hattr > 0)
         CALL uar_prefdestroyattr(hattr)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (hentry > 0)
    CALL uar_prefdestroyentry(hentry)
   ENDIF
   RETURN(success_ind)
 END ;Subroutine
 DECLARE solcap_cnt = i4 WITH protect, noconstant(0)
 DECLARE fac_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE pref_value = i2 WITH protect, noconstant(- (1))
 DECLARE pref_foreign_order_alias = vc WITH protect, constant("enable foreign order alias log-in")
 DECLARE pref_val_yes = vc WITH protect, constant("Yes")
 SET solcap_cnt += 1
 SET stat = alterlist(reply->solcap,solcap_cnt)
 SET reply->solcap[solcap_cnt].identifier = "PJ003141.2"
 SET reply->solcap[solcap_cnt].degree_of_use_num = 0
 SET reply->solcap[solcap_cnt].degree_of_use_str = "No"
 SELECT INTO "nl:"
  cv.code_value, cv.display, fac_disp_sort = cnvtupper(uar_get_code_display(cv.code_value))
  FROM code_value cv
  WHERE cv.code_set=220
   AND cv.cdf_meaning="FACILITY"
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.end_effective_dt_tm >= cnvtdatetime(sysdate)
  ORDER BY fac_disp_sort
  DETAIL
   fac_cnt += 1
   IF (mod(fac_cnt,10)=1)
    stat = alterlist(reply->solcap[solcap_cnt].facility,(fac_cnt+ 9))
   ENDIF
   reply->solcap[solcap_cnt].facility[fac_cnt].display = cv.display, reply->solcap[solcap_cnt].
   facility[fac_cnt].value_str = "No", pref_value = loadpreferences(1,cv.code_value,0.0,"application",
    "apsMaintainCase",
    "application settings","",pref_foreign_order_alias)
   IF (pref_value=1)
    idx = 0, pos = 0, pos = locateval(idx,1,size(prefvalues->prefs,5),pref_val_yes,prefvalues->prefs[
     idx].value)
    IF (pos > 0)
     reply->solcap[solcap_cnt].facility[fac_cnt].value_str = "Yes", reply->solcap[solcap_cnt].
     degree_of_use_str = "Yes", reply->solcap[solcap_cnt].degree_of_use_num += 1
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->solcap[solcap_cnt].facility,fac_cnt)
  WITH nocounter
 ;end select
END GO
