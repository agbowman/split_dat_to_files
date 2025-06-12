CREATE PROGRAM bhs_athn_get_ord_entry_prefs
 FREE RECORD result
 RECORD result(
   1 facility_cd = f8
   1 facility_disp = vc
   1 location_cd = f8
   1 location_disp = vc
   1 position_cd = f8
   1 position_disp = vc
   1 list[*]
     2 pref_name = vc
     2 pref_val = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE loadpreferences(positioncd=f8,locationcd=f8,facilitycd=f8,sectionname=vc,sectionid=vc,
  group=vc,subgroup=vc) = i4
 DECLARE getpreferencevalue(hgroup=i4,entrycnt=i4,entry=vc) = vc
 DECLARE getsystempreference(entry=vc) = vc
 DECLARE getsubgroupbyname(hparent=i4,name=vc) = i4
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE c_unknown = vc WITH protect, constant("UNKNOWN")
 SET result->status_data.status = "F"
 SET result->facility_cd =  $3
 SET result->facility_disp = uar_get_code_display(result->facility_cd)
 SET result->location_cd =  $4
 SET result->location_disp = uar_get_code_display(result->location_cd)
 SET result->position_cd =  $5
 SET result->position_disp = uar_get_code_display(result->position_cd)
 DECLARE prefnameparam = vc WITH protect, noconstant("")
 DECLARE prefnamecnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET prefnameparam = trim( $2,3)
 CALL echo(build2("PREFNAMEPARAM IS: ",prefnameparam))
 WHILE (size(prefnameparam) > 0)
   SET endpos = (findstring(";",prefnameparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(prefnameparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,prefnameparam)
    CALL echo(build("PARAM:",param))
    SET prefnamecnt = (prefnamecnt+ 1)
    SET stat = alterlist(result->list,prefnamecnt)
    SET result->list[prefnamecnt].pref_name = cnvtlower(param)
   ENDIF
   SET prefnameparam = substring((endpos+ 2),(size(prefnameparam) - endpos),prefnameparam)
   CALL echo(build("PREFNAMEPARAM:",prefnameparam))
   CALL echo(build("SIZE(PREFNAMEPARAM):",size(prefnameparam)))
 ENDWHILE
 EXECUTE prefrtl
 IF ((result->position_cd > 0.0))
  SET stat = loadpreferences(result->position_cd,0.0,0.0,"config","pharmacy",
   "inpatient","orderentry")
  IF (stat=fail)
   CALL echo("LOADPREFERENCES FOR POSITION_CD FAILED")
  ENDIF
 ENDIF
 IF ((result->location_cd > 0.0))
  SET stat = loadpreferences(0.0,result->location_cd,0.0,"config","pharmacy",
   "inpatient","orderentry")
  IF (stat=fail)
   CALL echo("LOADPREFERENCES FOR LOCATION FAILED")
  ENDIF
 ENDIF
 IF ((result->facility_cd > 0.0))
  SET stat = loadpreferences(0.0,0.0,result->facility_cd,"config","pharmacy",
   "inpatient","orderentry")
  IF (stat=fail)
   CALL echo("LOADPREFERENCES FOR FACILITY_CD FAILED")
  ENDIF
 ENDIF
 SET stat = loadpreferences(0.0,0.0,0.0,"config","pharmacy",
  "inpatient","orderentry")
 IF (stat=fail)
  CALL echo("LOADPREFERENCES FOR SYSTEM FAILED")
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 CALL echojson(result, $1)
 FREE RECORD result
 SUBROUTINE loadpreferences(positioncd,locationcd,facilitycd,sectionname,sectionid,group,subgroup)
   DECLARE prefstat = i4 WITH noconstant(0)
   DECLARE hpref = i4 WITH noconstant(0)
   DECLARE hgroup = i4 WITH noconstant(0)
   DECLARE hsubgroup = i4 WITH noconstant(0)
   DECLARE hsection = i4 WITH noconstant(0)
   DECLARE entrycnt = i4 WITH noconstant(0)
   DECLARE facilityctx = vc WITH noconstant("")
   DECLARE locationctx = vc WITH noconstant("")
   DECLARE positionctx = vc WITH noconstant("")
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    RETURN("UNKNOWN - PROBABLY NOT LOGGED IN.")
   ENDIF
   IF (positioncd > 0.0)
    SET positionctx = cnvtstring(positioncd,19,2)
    CALL echo(build("POSITIONCTX:",positionctx))
    SET prefstat = uar_prefaddcontext(hpref,nullterm("POSITION"),nullterm(positionctx))
    IF (prefstat != 1)
     CALL echo("UAR_PREFADDCONTEXT:POSITION FAILED...EXITING")
     CALL uar_prefdestroyinstance(hpref)
     RETURN(fail)
    ENDIF
   ELSEIF (locationcd > 0.0)
    SET locationctx = cnvtstring(locationcd,19,2)
    CALL echo(build("LOCATIONCTX:",locationctx))
    SET prefstat = uar_prefaddcontext(hpref,nullterm("NURSE UNIT"),nullterm(locationctx))
    IF (prefstat != 1)
     CALL echo("UAR_PREFADDCONTEXT:LOCATION FAILED...EXITING")
     CALL uar_prefdestroyinstance(hpref)
     RETURN(fail)
    ENDIF
   ELSEIF (facilitycd > 0.0)
    SET facilityctx = cnvtstring(facilitycd,19,2)
    CALL echo(build("FACILITYCTX:",facilityctx))
    SET prefstat = uar_prefaddcontext(hpref,nullterm("FACILITY"),nullterm(facilityctx))
    IF (prefstat != 1)
     CALL echo("UAR_PREFADDCONTEXT:FACILITY FAILED...EXITING")
     CALL uar_prefdestroyinstance(hpref)
     RETURN(fail)
    ENDIF
   ELSE
    SET prefstat = uar_prefaddcontext(hpref,nullterm("DEFAULT"),nullterm("SYSTEM"))
    IF (prefstat != 1)
     CALL echo("UAR_PREFADDCONTEXT:SYSTEM FAILED...EXITING")
     CALL uar_prefdestroyinstance(hpref)
     RETURN(c_unknown)
    ENDIF
   ENDIF
   SET prefstat = uar_prefsetsection(hpref,nullterm(sectionname))
   IF (prefstat != 1)
    CALL echo("UAR_PREFSETSECTION FAILED...EXITING")
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   SET hgroup = uar_prefcreategroup()
   IF (hgroup=0)
    CALL echo("UAR_PREFCREATEGROUP FAILED...EXITING")
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   SET prefstat = uar_prefsetgroupname(hgroup,nullterm(sectionid))
   IF (prefstat != 1)
    CALL echo("UAR_PREFSETGROUPNAME FAILED...EXITING")
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(group))
   IF (hsubgroup=0)
    CALL echo(build("UAR_PREFADDSUBGROUP:",group," FAILED...EXITING"))
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   IF (subgroup != "")
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(subgroup))
    IF (hsubgroup=0)
     CALL echo(build("UAR_PREFADDSUBGROUP:",subgroup," FAILED...EXITING"))
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(fail)
    ENDIF
   ENDIF
   SET prefstat = uar_prefaddgroup(hpref,hgroup)
   IF (prefstat != 1)
    CALL echo("UAR_PREFADDGROUP FAILED...EXITING")
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   SET prefstat = uar_prefperform(hpref)
   IF (prefstat != 1)
    CALL echo("UAR_PREFPERFORM FAILED...EXITING")
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   CALL uar_prefdestroygroup(hgroup)
   SET hsection = uar_prefgetsectionbyname(hpref,nullterm(sectionname))
   IF (hsection=0)
    CALL echo("UAR_PREFGETSECTIONBYNAME FAILED...EXITING")
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   SET hgroup = uar_prefgetgroupbyname(hsection,nullterm(sectionid))
   IF (hgroup=0)
    CALL echo("UAR_PREFGETGROUPBYNAME FAILED...EXITING")
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   IF (group != "")
    SET hsubgroup = getsubgroupbyname(hgroup,group)
    IF (hsubgroup=0)
     CALL echo(build("GETSUBGROUPBYNAME:",group," FAILED...EXITING"))
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(fail)
    ENDIF
   ENDIF
   IF (subgroup != ""
    AND hsubgroup > 0)
    SET hsubgroup = getsubgroupbyname(hsubgroup,subgroup)
    IF (hsubgroup=0)
     CALL echo(build("GETSUBGROUPBYNAME:",subgroup," FAILED...EXITING"))
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroyinstance(hpref)
     RETURN(fail)
    ENDIF
   ENDIF
   SET prefstat = uar_prefgetgroupentrycount(hsubgroup,entrycnt)
   IF (prefstat != 1)
    CALL echo("UAR_PREFGETGROUPENTRYCOUNT FAILED...EXITING")
    RETURN(fail)
   ENDIF
   CALL echo(build("GROUPENTRYCNT:",entrycnt))
   FOR (kdx = 1 TO size(result->list,5))
     IF ((((result->list[kdx].pref_val="")) OR ((result->list[kdx].pref_val=c_unknown))) )
      IF ((result->list[kdx].pref_name="dosecalculator"))
       SET result->list[kdx].pref_val = getsystempreference(result->list[kdx].pref_name)
      ELSE
       SET result->list[kdx].pref_val = getpreferencevalue(hsubgroup,entrycnt,result->list[kdx].
        pref_name)
      ENDIF
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroyinstance(hpref)
   RETURN(success)
 END ;Subroutine
 SUBROUTINE getpreferencevalue(hgroup,entrycnt,entry)
   FREE SET prefstat
   DECLARE prefstat = i4 WITH noconstant(0)
   DECLARE entryname = c255 WITH noconstant("")
   DECLARE len = i4 WITH noconstant(255)
   DECLARE attrname = c255 WITH noconstant("")
   DECLARE attrcnt = i4 WITH noconstant(0)
   DECLARE hattr = i4 WITH noconstant(0)
   DECLARE val = c255 WITH noconstant("")
   CALL echo(build("HGROUP:",hgroup))
   CALL echo(build("ENTRY:",entry))
   FOR (idx = 0 TO (entrycnt - 1))
     SET hentry = uar_prefgetgroupentry(hgroup,idx)
     IF (hentry=0)
      RETURN(c_unknown)
     ENDIF
     SET len = 255
     SET entryname = fillstring(255,"")
     SET prefstat = uar_prefgetentryname(hentry,entryname,len)
     IF (prefstat=1
      AND nullterm(entryname)=entry)
      SET prefstat = uar_prefgetentryattrcount(hentry,attrcnt)
      IF (prefstat != 1)
       RETURN(c_unknown)
      ENDIF
      CALL echo(build("ATTRCNT:",attrcnt))
      FOR (jdx = 0 TO (attrcnt - 1))
       SET hattr = uar_prefgetentryattr(hentry,jdx)
       IF (hattr != 0)
        SET len = 255
        SET prefstat = uar_prefgetattrname(hattr,attrname,len)
        IF (prefstat=1
         AND trim(attrname,3)="prefvalue")
         SET len = 255
         SET prefstat = uar_prefgetattrval(hattr,val,len,0)
         IF (prefstat != 1)
          RETURN(c_unknown)
         ENDIF
         RETURN(trim(val,3))
        ENDIF
       ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(c_unknown)
 END ;Subroutine
 SUBROUTINE getsubgroupbyname(hparent,name)
   DECLARE groupcnt = i4 WITH protect, noconstant(0)
   DECLARE subgroupname = vc WITH protect, noconstant("")
   DECLARE strlen = i4 WITH protect, constant(255)
   DECLARE gdx = i4 WITH protect, noconstant(0)
   DECLARE hsgroup = i4 WITH protect, noconstant(0)
   SET prefstat = uar_prefgetsubgroupcount(hparent,groupcnt)
   IF (prefstat != 1)
    RETURN(0)
   ENDIF
   CALL echo(build("SUBGROUPCOUNT:",groupcnt))
   FOR (gdx = 0 TO (groupcnt - 1))
     SET hsgroup = uar_prefgetsubgroup(hparent,gdx)
     IF (hsgroup=0)
      RETURN(0)
     ENDIF
     SET subgroupname = fillstring(255,"")
     SET prefstat = uar_prefgetgroupname(hsgroup,subgroupname,strlen)
     IF (prefstat != 0
      AND nullterm(subgroupname)=name)
      CALL echo(build("SUBGROUP FOUND! - NAME=",name,";HSGROUP=",hsgroup))
      RETURN(hsgroup)
     ENDIF
   ENDFOR
   CALL echo("SUBGROUP NOT FOUND!")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getsystempreference(entry)
   DECLARE val = vc WITH protect, noconstant(c_unknown)
   SELECT INTO "NL:"
    FROM dm_prefs dp
    PLAN (dp
     WHERE dp.application_nbr=380000
      AND dp.pref_domain="PHARMNET-INPATIENT"
      AND dp.pref_section="OEPARAM"
      AND dp.pref_name=cnvtupper(entry))
    DETAIL
     val = trim(cnvtstring(dp.pref_nbr),3)
    WITH nocounter, time = 30
   ;end select
   RETURN(val)
 END ;Subroutine
END GO
