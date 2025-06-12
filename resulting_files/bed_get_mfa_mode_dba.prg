CREATE PROGRAM bed_get_mfa_mode:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 mfa_mode = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 EXECUTE prefrtl
 DECLARE nstat = i2 WITH protect, noconstant(0)
 DECLARE hgroup = i4 WITH protect, noconstant(0)
 DECLARE hsubgroup = i4 WITH protect, noconstant(0)
 DECLARE hsection = i4 WITH protect, noconstant(0)
 DECLARE entrycnt = i4 WITH protect, noconstant(0)
 DECLARE idxentry = i4 WITH protect, noconstant(0)
 DECLARE hentry = i4 WITH protect, noconstant(0)
 DECLARE entryname = c255 WITH protect, noconstant("")
 DECLARE attrcnt = i4 WITH protect, noconstant(0)
 DECLARE idxattr = i4 WITH protect, noconstant(0)
 DECLARE entryname = c255 WITH protect, noconstant("")
 DECLARE hattr = i4 WITH protect, noconstant(0)
 DECLARE attrname = c255 WITH protect, noconstant("")
 DECLARE valcnt = i4 WITH protect, noconstant(0)
 DECLARE value = c255 WITH protect, noconstant("")
 DECLARE hrepgroup = i4 WITH protect, noconstant(0)
 DECLARE subgroupname = c255 WITH protect, noconstant("")
 DECLARE mfamodeid = f8 WITH protect, noconstant(0)
 DECLARE len = i4 WITH protect, noconstant(255)
 DECLARE default = vc WITH protect, constant("default")
 DECLARE system = vc WITH protect, constant("system")
 DECLARE component = vc WITH protect, constant("component")
 DECLARE om = vc WITH protect, constant("om")
 DECLARE powerorders = vc WITH protect, constant("powerorders")
 DECLARE orderentry = vc WITH protect, constant("orderentry")
 DECLARE mfapreferencename = vc WITH protect, constant("erxcsdualauth")
 SET hpref = uar_prefcreateinstance(0)
 SET nstat = uar_prefaddcontext(hpref,nullterm(default),nullterm(system))
 SET nstat = uar_prefsetsection(hpref,nullterm(component))
 SET hgroup = uar_prefcreategroup()
 SET nstat = uar_prefsetgroupname(hgroup,nullterm(om))
 SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(powerorders))
 SET hsubgroup = uar_prefaddsubgroup(hsubgroup,nullterm(orderentry))
 SET nstat = uar_prefaddgroup(hpref,hgroup)
 SET nstat = uar_prefperform(hpref)
 SET hsection = uar_prefgetsectionbyname(hpref,nullterm(component))
 SET hrepgroup = uar_prefgetgroupbyname(hsection,nullterm(om))
 SET hsubgroup = uar_prefgetsubgroup(hrepgroup,0)
 SET hsubgroup = uar_prefgetsubgroup(hsubgroup,0)
 SET subgroupname = fillstring(value(len)," ")
 SET stat = uar_prefgetgroupname(hsubgroup,subgroupname,len)
 SET nstat = uar_prefgetgroupentrycount(hsubgroup,entrycnt)
 FOR (idxentry = 0 TO (entrycnt - 1))
   SET hentry = uar_prefgetgroupentry(hsubgroup,idxentry)
   SET len = 255
   SET entryname = fillstring(value(len)," ")
   SET nstat = uar_prefgetentryname(hentry,entryname,len)
   SET entryname = trim(entryname,3)
   IF (entryname=mfapreferencename)
    SET nstat = uar_prefgetentryattrcount(hentry,attrcnt)
    FOR (idxattr = 0 TO (attrcnt - 1))
      SET hattr = uar_prefgetentryattr(hentry,idxattr)
      SET len = 255
      SET attrname = fillstring(value(len)," ")
      SET nstat = uar_prefgetattrname(hattr,attrname,len)
      IF (attrname="prefvalue")
       SET nstat = uar_prefgetattrvalcount(hattr,valcnt)
       SET len = 255
       SET value = fillstring(value(len)," ")
       SET nstat = uar_prefgetattrval(hattr,value,len,0)
       SET value = trim(value,3)
      ENDIF
      SET stat = uar_prefdestroyentry(hattr)
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = uar_prefdestroyinstance(hpref)
 SET stat = uar_prefdestroygroup(hgroup)
 SET mfamodeid = cnvtreal(value)
 CALL echo(build("mfa mode id from prefdir_entrydata:",mfamodeid))
 IF (mfamodeid=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM mfa_mode mm
  PLAN (mm
   WHERE mm.mfa_mode_id=mfamodeid)
  DETAIL
   reply->mfa_mode = mm.mode_name
  WITH nocounter
 ;end select
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
