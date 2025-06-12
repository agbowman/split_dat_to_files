CREATE PROGRAM bhs_athn_get_auto_verify_prefs
 FREE RECORD result
 RECORD result(
   1 facility_cd = f8
   1 facility_disp = vc
   1 nurse_unit_cd = f8
   1 nurse_unit_disp = vc
   1 autoverifywithautoproductassign_pref_val = vc
   1 autoverifywithautoproductassign_pref_ctx = vc
   1 autoproductassign_pref_val = vc
   1 autoproductassign_pref_ctx = vc
   1 futureautoverifywithautoproductassign_pref_val = vc
   1 futureautoverifywithautoproductassign_pref_ctx = vc
   1 futureautoproductassign_pref_val = vc
   1 futureautoproductassign_pref_ctx = vc
   1 bypassrxprocess_pref_val = vc
   1 bypassrxprocess_pref_ctx = vc
   1 call_auto_verify_server_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE loadsectionpreferences(locationcd=f8,facilitycd=f8,sectionname=vc,sectionid=vc) = i4
 DECLARE loadgroupprefs(locationcd=f8,facilitycd=f8,sectionname=vc,sectionid=vc,group=vc) = i4
 DECLARE getpreferencevalue(hgroup=i4,entrycnt=i4,entry=vc) = vc
 DECLARE getsubgroupbyname(hparent=i4,name=vc) = i4
 DECLARE calculatecallavserverindicator(null) = i4
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
 SET result->nurse_unit_cd =  $3
 SET result->nurse_unit_disp = uar_get_code_display(result->nurse_unit_cd)
 EXECUTE prefrtl
 SET stat = loadsectionpreferences(result->nurse_unit_cd,0.0,"config","pharmacy")
 IF (stat=fail)
  CALL echo("LOADSECTIONPREFERENCES FOR NURSE UNIT FAILED")
 ENDIF
 SET stat = loadsectionpreferences(0.0,result->facility_cd,"config","pharmacy")
 IF (stat=fail)
  CALL echo("LOADSECTIONPREFERENCES FOR FACILITY FAILED")
 ENDIF
 SET stat = loadsectionpreferences(0.0,0.0,"config","pharmacy")
 IF (stat=fail)
  CALL echo("LOADSECTIONPREFERENCES FOR SYSTEM FAILED")
 ENDIF
 SET stat = loadgroupprefs(result->nurse_unit_cd,0.0,"config","pharmacy","inpatient")
 IF (stat=fail)
  CALL echo("LOADGROUPPREFS FOR NURSE UNIT FAILED")
 ENDIF
 SET stat = loadgroupprefs(0.0,result->facility_cd,"config","pharmacy","inpatient")
 IF (stat=fail)
  CALL echo("LOADGROUPPREFS FOR FACILITY FAILED")
 ENDIF
 SET stat = loadgroupprefs(0.0,0.0,"config","pharmacy","inpatient")
 IF (stat=fail)
  CALL echo("LOADGROUPPREFS FOR SYSTEM FAILED")
 ENDIF
 SET stat = calculatecallavserverindicator(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 CALL echojson(result, $1)
 FREE RECORD result
 SUBROUTINE loadsectionpreferences(locationcd,facilitycd,sectionname,sectionid)
   DECLARE prefstat = i4 WITH noconstant(0)
   DECLARE hpref = i4 WITH noconstant(0)
   DECLARE hgroup = i4 WITH noconstant(0)
   DECLARE hsection = i4 WITH noconstant(0)
   DECLARE entrycnt = i4 WITH noconstant(0)
   DECLARE facilityctx = vc WITH noconstant("")
   DECLARE locationctx = vc WITH noconstant("")
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    RETURN("UNKNOWN - PROBABLY NOT LOGGED IN.")
   ENDIF
   IF (locationcd > 0.0)
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
   SET prefstat = uar_prefgetgroupentrycount(hgroup,entrycnt)
   IF (prefstat != 1)
    CALL echo("UAR_PREFGETGROUPENTRYCOUNT FAILED...EXITING")
    RETURN(fail)
   ENDIF
   CALL echo(build("GROUPENTRYCNT:",entrycnt))
   IF ((((result->autoverifywithautoproductassign_pref_val="")) OR ((result->
   autoverifywithautoproductassign_pref_val=c_unknown))) )
    SET result->autoverifywithautoproductassign_pref_val = getpreferencevalue(hgroup,entrycnt,
     "autoverifywithautoproductassign")
    IF (locationcd > 0.0)
     SET result->autoverifywithautoproductassign_pref_ctx = uar_get_code_display(locationcd)
    ELSEIF (facilitycd > 0.0)
     SET result->autoverifywithautoproductassign_pref_ctx = uar_get_code_display(facilitycd)
    ELSE
     SET result->autoverifywithautoproductassign_pref_ctx = "SYSTEM"
    ENDIF
   ENDIF
   IF ((((result->autoproductassign_pref_val="")) OR ((result->autoproductassign_pref_val=c_unknown)
   )) )
    SET result->autoproductassign_pref_val = getpreferencevalue(hgroup,entrycnt,"autoproductassign")
    IF (locationcd > 0.0)
     SET result->autoproductassign_pref_ctx = uar_get_code_display(locationcd)
    ELSEIF (facilitycd > 0.0)
     SET result->autoproductassign_pref_ctx = uar_get_code_display(facilitycd)
    ELSE
     SET result->autoproductassign_pref_ctx = "SYSTEM"
    ENDIF
   ENDIF
   IF ((((result->futureautoproductassign_pref_val="")) OR ((result->futureautoproductassign_pref_val
   =c_unknown))) )
    SET result->futureautoproductassign_pref_val = getpreferencevalue(hgroup,entrycnt,
     "futureautoproductassign")
    IF (locationcd > 0.0)
     SET result->futureautoproductassign_pref_ctx = uar_get_code_display(locationcd)
    ELSEIF (facilitycd > 0.0)
     SET result->futureautoproductassign_pref_ctx = uar_get_code_display(facilitycd)
    ELSE
     SET result->futureautoproductassign_pref_ctx = "SYSTEM"
    ENDIF
   ENDIF
   IF ((((result->futureautoverifywithautoproductassign_pref_val="")) OR ((result->
   futureautoverifywithautoproductassign_pref_val=c_unknown))) )
    SET result->futureautoverifywithautoproductassign_pref_val = getpreferencevalue(hgroup,entrycnt,
     "futureautoverifywithautoproductassign")
    IF (locationcd > 0.0)
     SET result->futureautoverifywithautoproductassign_pref_ctx = uar_get_code_display(locationcd)
    ELSEIF (facilitycd > 0.0)
     SET result->futureautoverifywithautoproductassign_pref_ctx = uar_get_code_display(facilitycd)
    ELSE
     SET result->futureautoverifywithautoproductassign_pref_ctx = "SYSTEM"
    ENDIF
   ENDIF
   CALL uar_prefdestroysection(hsection)
   CALL uar_prefdestroyinstance(hpref)
   RETURN(success)
 END ;Subroutine
 SUBROUTINE loadgroupprefs(locationcd,facilitycd,sectionname,sectionid,group)
   DECLARE prefstat = i4 WITH noconstant(0)
   DECLARE hpref = i4 WITH noconstant(0)
   DECLARE hgroup = i4 WITH noconstant(0)
   DECLARE hsubgroup = i4 WITH noconstant(0)
   DECLARE hsection = i4 WITH noconstant(0)
   DECLARE entrycnt = i4 WITH noconstant(0)
   DECLARE facilityctx = vc WITH noconstant("")
   DECLARE locationctx = vc WITH noconstant("")
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    RETURN("UNKNOWN - PROBABLY NOT LOGGED IN.")
   ENDIF
   IF (locationcd > 0.0)
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
   SET hsubgroup = getsubgroupbyname(hgroup,group)
   IF (hsubgroup=0)
    CALL echo(build("GETSUBGROUPBYNAME:",group," FAILED...EXITING"))
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroyinstance(hpref)
    RETURN(fail)
   ENDIF
   SET prefstat = uar_prefgetgroupentrycount(hsubgroup,entrycnt)
   IF (prefstat != 1)
    CALL echo("UAR_PREFGETGROUPENTRYCOUNT FAILED...EXITING")
    RETURN(fail)
   ENDIF
   CALL echo(build("GROUPENTRYCNT:",entrycnt))
   IF ((((result->bypassrxprocess_pref_val="")) OR ((result->bypassrxprocess_pref_val=c_unknown))) )
    SET result->bypassrxprocess_pref_val = getpreferencevalue(hsubgroup,entrycnt,"bypassrxprocess")
    IF (locationcd > 0.0)
     SET result->bypassrxprocess_pref_ctx = uar_get_code_display(locationcd)
    ELSEIF (facilitycd > 0.0)
     SET result->bypassrxprocess_pref_ctx = uar_get_code_display(facilitycd)
    ELSE
     SET result->bypassrxprocess_pref_ctx = "SYSTEM"
    ENDIF
   ENDIF
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
     CALL echo(build("ENTRYNAME:",entryname))
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
        CALL echo(build("ATTRNAME:",attrname))
        IF (prefstat=1
         AND trim(attrname,3)="prefvalue")
         SET len = 255
         SET prefstat = uar_prefgetattrval(hattr,val,len,0)
         CALL echo(build("VAL:",val))
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
 SUBROUTINE calculatecallavserverindicator(null)
  IF ((result->bypassrxprocess_pref_val != "1")
   AND (((result->autoproductassign_pref_val="1")) OR ((((result->
  autoverifywithautoproductassign_pref_val="1")) OR ((((result->futureautoproductassign_pref_val="1")
  ) OR ((result->futureautoverifywithautoproductassign_pref_val="1"))) )) )) )
   SET result->call_auto_verify_server_ind = 1
  ENDIF
  RETURN(success)
 END ;Subroutine
END GO
