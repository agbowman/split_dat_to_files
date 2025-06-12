CREATE PROGRAM bhs_athn_get_order_pad_pref
 FREE RECORD result
 RECORD result(
   1 facility_cd = f8
   1 facility_disp = vc
   1 location_cd = f8
   1 location_disp = vc
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
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE kdx = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE c_unknown = vc WITH protect, constant("UNKNOWN")
 SET result->status_data.status = "F"
 SET result->facility_cd =  $2
 SET result->facility_disp = uar_get_code_display(result->facility_cd)
 SET result->location_cd =  $3
 SET result->location_disp = uar_get_code_display(result->location_cd)
 SET stat = alterlist(result->list,1)
 SET result->list[1].pref_name = "inppharmorderstarttimepad"
 EXECUTE prefrtl
 IF ((result->location_cd > 0.0))
  SET stat = loadpreferences(0.0,result->location_cd,0.0,"component","om",
   "powerorders","orderentry")
  IF (stat=fail)
   CALL echo("LOADPREFERENCES FOR LOCATION FAILED")
  ENDIF
 ENDIF
 IF ((result->facility_cd > 0.0))
  SET stat = loadpreferences(0.0,0.0,result->facility_cd,"component","om",
   "powerorders","orderentry")
  IF (stat=fail)
   CALL echo("LOADPREFERENCES FOR FACILITY_CD FAILED")
  ENDIF
 ENDIF
 SET stat = loadpreferences(0.0,0.0,0.0,"component","om",
  "powerorders","orderentry")
 IF (stat=fail)
  CALL echo("LOADPREFERENCES FOR SYSTEM FAILED")
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(result)
 ELSE
  CALL echojson(result,moutputdevice)
 ENDIF
 FREE RECORD result
 FREE RECORD result
 SUBROUTINE (loadpreferences(positioncd=f8,locationcd=f8,facilitycd=f8,sectionname=vc,sectionid=vc,
  group=vc,subgroup=vc) =i4)
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
      SET result->list[kdx].pref_val = getpreferencevalue(hsubgroup,entrycnt,result->list[kdx].
       pref_name)
     ENDIF
   ENDFOR
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroyinstance(hpref)
   RETURN(success)
 END ;Subroutine
 SUBROUTINE (getpreferencevalue(hgroup=i4,entrycnt=i4,entry=vc) =vc)
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
 SUBROUTINE (getsubgroupbyname(hparent=i4,name=vc) =i4)
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
END GO
