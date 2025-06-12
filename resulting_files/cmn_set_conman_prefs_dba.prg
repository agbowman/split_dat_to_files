CREATE PROGRAM cmn_set_conman_prefs:dba
 PROMPT
  "output device:  " = "MINE",
  "username:  " = "",
  "report name:  " = " ",
  "report params:  " = " "
  WITH outdev, username, report_name,
  report_params
 EXECUTE prefrtl
 DECLARE findpreference(sentryname=vc) = i2
 DECLARE addpreference(sentryname=vc) = i2
 DECLARE getpreferencevalue(nprefindex=i2) = vc
 DECLARE setfirstpreferencevalue(nprefindex=i2,sprefvalue=vc) = i2
 DECLARE setnextpreferencevalue(nprefindex=i2,sprefvalue=vc) = i2
 DECLARE getpreferenceerrmsg(dummy=i2) = vc
 DECLARE loadpreferences(ssystemctx=vc,sfacilityctx=vc,spositionctx=vc,suserctx=vc,ssectionname=vc,
  ssectionid=vc) = i2
 DECLARE updatepreferences(scontext=vc,scontextid=vc,ssectionname=vc,ssectionid=vc,sgroupname=vc,
  nprefindex=i2) = i2
 DECLARE deletepreferences(scontext=vc,scontextid=vc,ssectionname=vc,ssectionid=vc,sgroupname=vc,
  nprefindex=i2) = i2
 DECLARE unloadpreferences(dummy=i2) = null
 DECLARE clearpreferencerecord(dummy=i2) = null
 DECLARE readpreferences(hgetgroup=h) = i2
 DECLARE checkprefstatus(nsuccessind=i2) = i2
 DECLARE clearpreferences(dummy=i2) = null
 DECLARE clearpreferenceerr(dummy=i2) = null
 DECLARE testpreferences(dummy=i2) = null
 RECORD preferences(
   1 hprefdir = h
   1 hprefsection = h
   1 hprefsectionid = h
   1 hprefgroup = h
   1 hprefentry = h
   1 hprefattr = h
   1 entry_qual[*]
     2 name = vc
     2 values[*]
       3 value = vc
   1 lprefstat = h
   1 npreferr = i2
   1 spreferrmsg = c255
 ) WITH protect
 SUBROUTINE findpreference(sentryname)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE iprefentry = i2 WITH private, noconstant(0)
   SET nprefentrycnt = size(preferences->entry_qual,5)
   FOR (iprefentry = 1 TO nprefentrycnt)
     IF (cnvtlower(preferences->entry_qual[iprefentry].name)=trim(cnvtlower(sentryname)))
      RETURN(iprefentry)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE addpreference(sentryname)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE nprefindex = i2 WITH private, noconstant(0)
   SET nprefindex = findpreference(sentryname)
   IF (nprefindex=0)
    SET nprefentrycnt = size(preferences->entry_qual,5)
    SET nprefindex = (nprefentrycnt+ 1)
    SET stat = alterlist(preferences->entry_qual,nprefindex)
    SET preferences->entry_qual[nprefindex].name = trim(sentryname)
    SET stat = alterlist(preferences->entry_qual[nprefindex].values,0)
   ENDIF
   RETURN(nprefindex)
 END ;Subroutine
 SUBROUTINE getpreferencevalue(nprefindex)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE nprefvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   DECLARE sprefvalue = vc WITH private, noconstant("")
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (nprefindex <= nprefentrycnt
    AND nprefindex > 0)
    SET nprefvaluecnt = size(preferences->entry_qual[nprefindex].values,5)
    IF (nprefvaluecnt > 0)
     SET sprefvalue = preferences->entry_qual[nprefindex].values[1].value
     FOR (iprefvalue = 2 TO nprefvaluecnt)
       SET sprefvalue = concat(sprefvalue,"|",preferences->entry_qual[nprefindex].values[iprefvalue].
        value)
     ENDFOR
    ENDIF
   ENDIF
   RETURN(sprefvalue)
 END ;Subroutine
 SUBROUTINE setfirstpreferencevalue(nprefindex,sprefvalue)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (nprefindex <= nprefentrycnt
    AND nprefindex > 0)
    SET iprefvalue = 1
    SET stat = alterlist(preferences->entry_qual[nprefindex].values,iprefvalue)
    SET preferences->entry_qual[nprefindex].values[iprefvalue].value = trim(sprefvalue)
   ENDIF
   RETURN(iprefvalue)
 END ;Subroutine
 SUBROUTINE setnextpreferencevalue(nprefindex,sprefvalue)
   DECLARE nprefentrycnt = i2 WITH private, noconstant(0)
   DECLARE nprefvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (nprefindex <= nprefentrycnt
    AND nprefindex > 0)
    SET nprefvaluecnt = size(preferences->entry_qual[nprefindex].values,5)
    SET iprefvalue = (nprefvaluecnt+ 1)
    SET stat = alterlist(preferences->entry_qual[nprefindex].values,iprefvalue)
    SET preferences->entry_qual[nprefindex].values[iprefvalue].value = trim(sprefvalue)
   ENDIF
   RETURN(iprefvalue)
 END ;Subroutine
 SUBROUTINE getpreferenceerrmsg(dummy)
   RETURN(trim(preferences->spreferrmsg))
 END ;Subroutine
 SUBROUTINE clearpreferences(dummy)
  SET stat = alterlist(preferences->entry_qual,0)
  CALL checkprefstatus(1)
 END ;Subroutine
 SUBROUTINE clearpreferenceerr(dummy)
   SET preferences->lprefstat = 0
   SET preferences->npreferr = 0
   SET preferences->spreferrmsg = ""
 END ;Subroutine
 SUBROUTINE unloadpreferences(dummy)
  CALL checkprefstatus(1)
  FREE RECORD preferences
 END ;Subroutine
 SUBROUTINE loadpreferences(ssystemctx,sfacilityctx,spositionctx,suserctx,ssectionname,ssectionid)
   DECLARE nsubgroupcnt = i4 WITH private, noconstant(0)
   DECLARE isubgroup = i4 WITH private, noconstant(0)
   IF (validate(cursysbit,32)=32)
    DECLARE nsubgroupcntw = i4 WITH private, noconstant(0)
    DECLARE isubgroupw = i4 WITH private, noconstant(0)
   ELSE
    DECLARE nsubgroupcntw = h WITH private, noconstant(0)
    DECLARE isubgroupw = h WITH private, noconstant(0)
   ENDIF
   CALL clearpreferences(0)
   CALL clearpreferenceerr(0)
   SET preferences->hprefdir = uar_prefcreateinstance(0)
   IF ((preferences->hprefdir=0))
    SET preferences->npreferr = uar_prefgetlasterror()
    SET preferences->lprefstat = uar_prefformatmessage(preferences->spreferrmsg,255)
    RETURN(checkprefstatus(0))
   ENDIF
   IF (textlen(trim(ssystemctx)) > 0)
    SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm("default"),
     nullterm(ssystemctx))
    IF ((preferences->lprefstat != 1))
     RETURN(checkprefstatus(0))
    ENDIF
   ENDIF
   IF (textlen(trim(sfacilityctx)) > 0)
    SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm("facility"),
     nullterm(sfacilityctx))
    IF ((preferences->lprefstat != 1))
     RETURN(checkprefstatus(0))
    ENDIF
   ENDIF
   IF (textlen(trim(spositionctx)) > 0)
    SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm("position"),
     nullterm(spositionctx))
    IF ((preferences->lprefstat != 1))
     RETURN(checkprefstatus(0))
    ENDIF
   ENDIF
   IF (textlen(trim(suserctx)) > 0)
    SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm("user"),nullterm(
      suserctx))
    IF ((preferences->lprefstat != 1))
     RETURN(checkprefstatus(0))
    ENDIF
   ENDIF
   SET preferences->lprefstat = uar_prefsetsection(preferences->hprefdir,nullterm(ssectionname))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefsectionid = uar_prefcreategroup()
   IF ((preferences->hprefsectionid=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetgroupname(preferences->hprefsectionid,nullterm(ssectionid)
    )
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddgroup(preferences->hprefdir,preferences->hprefsectionid)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefperform(preferences->hprefdir)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   IF ((preferences->hprefsectionid > 0))
    CALL uar_prefdestroyinstance(preferences->hprefsectionid)
    SET preferences->hprefsectionid = 0
   ENDIF
   SET preferences->hprefsection = uar_prefgetsectionbyname(preferences->hprefdir,nullterm(
     ssectionname))
   IF ((preferences->hprefsection=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefsectionid = uar_prefgetgroupbyname(preferences->hprefsection,nullterm(
     ssectionid))
   IF ((preferences->hprefsectionid=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefgroup = preferences->hprefsectionid
   IF (readpreferences(preferences->hprefsectionid)=0)
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefgetsubgroupcount(preferences->hprefsectionid,nsubgroupcntw)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET nsubgroupcnt = nsubgroupcntw
   FOR (isubgroup = 1 TO nsubgroupcnt)
     SET isubgroupw = isubgroup
     SET preferences->hprefgroup = uar_prefgetsubgroup(preferences->hprefsectionid,(isubgroupw - 1))
     IF ((preferences->hprefgroup=0))
      RETURN(checkprefstatus(0))
     ENDIF
     IF (readpreferences(preferences->hprefgroup)=0)
      RETURN(checkprefstatus(0))
     ELSE
      CALL uar_prefdestroygroup(preferences->hprefgroup)
      SET preferences->hprefgroup = 0
     ENDIF
   ENDFOR
   RETURN(checkprefstatus(1))
 END ;Subroutine
 SUBROUTINE checkprefstatus(nsuccessind)
   IF (nsuccessind != 1)
    IF (textlen(trim(preferences->spreferrmsg))=0)
     SET preferences->npreferr = uar_prefgetlasterror()
     SET preferences->lprefstat = uar_prefformatmessage(preferences->spreferrmsg,255)
    ENDIF
   ENDIF
   IF ((preferences->hprefdir > 0))
    CALL uar_prefdestroyinstance(preferences->hprefdir)
    SET preferences->hprefdir = 0
   ENDIF
   IF ((preferences->hprefgroup > 0))
    IF ((preferences->hprefgroup != preferences->hprefsectionid))
     CALL uar_prefdestroygroup(preferences->hprefgroup)
    ENDIF
    SET preferences->hprefgroup = 0
   ENDIF
   IF ((preferences->hprefsection > 0))
    CALL uar_prefdestroyinstance(preferences->hprefsection)
    SET preferences->hprefsection = 0
   ENDIF
   IF ((preferences->hprefsectionid > 0))
    CALL uar_prefdestroyinstance(preferences->hprefsectionid)
    SET preferences->hprefsectionid = 0
   ENDIF
   IF ((preferences->hprefentry > 0))
    CALL uar_prefdestroyentry(preferences->hprefentry)
    SET preferences->hprefentry = 0
   ENDIF
   IF ((preferences->hprefattr > 0))
    CALL uar_prefdestroyinstance(preferences->hprefattr)
    SET preferences->hprefattr = 0
   ENDIF
   RETURN(nsuccessind)
 END ;Subroutine
 SUBROUTINE readpreferences(hprefgroup)
   DECLARE npref_len = i2 WITH private, constant(255)
   DECLARE lentry = i4 WITH private, noconstant(0)
   DECLARE sprefstring = c255 WITH private, noconstant("")
   DECLARE sattrnamestring = c255 WITH private, noconstant("")
   DECLARE sattrvalstring = c255 WITH private, noconstant(" ")
   DECLARE lentrynamelen = i4 WITH private, noconstant(npref_len)
   DECLARE lgroupentrycnt = i4 WITH private, noconstant(0)
   DECLARE lentryattrcnt = i4 WITH private, noconstant(0)
   DECLARE lattrvalcnt = i4 WITH private, noconstant(0)
   DECLARE lentryattr = i4 WITH private, noconstant(0)
   DECLARE lattrval = i4 WITH private, noconstant(0)
   DECLARE nprefindex = i2 WITH private, noconstant(0)
   IF (validate(cursysbit,32)=32)
    DECLARE lattrnamelen = i4 WITH private, noconstant(npref_len)
    DECLARE lattrvallen = i4 WITH private, noconstant(npref_len)
    DECLARE lgroupentrycntw = i4 WITH private, noconstant(0)
    DECLARE lentryw = i4 WITH private, noconstant(0)
    DECLARE lattrvalcntw = i4 WITH private, noconstant(0)
    DECLARE lattrvalw = i4 WITH private, noconstant(0)
   ELSE
    DECLARE lattrnamelen = h WITH private, noconstant(npref_len)
    DECLARE lattrvallen = h WITH private, noconstant(npref_len)
    DECLARE lgroupentrycntw = h WITH private, noconstant(0)
    DECLARE lentryw = h WITH private, noconstant(0)
    DECLARE lattrvalcntw = h WITH private, noconstant(0)
    DECLARE lattrvalw = h WITH private, noconstant(0)
   ENDIF
   SET preferences->lprefstat = uar_prefgetgroupentrycount(hprefgroup,lgroupentrycntw)
   IF ((preferences->lprefstat != 1))
    RETURN(0)
   ENDIF
   SET lgroupentrycnt = lgroupentrycntw
   FOR (lentry = 1 TO lgroupentrycnt)
     SET lentryw = lentry
     SET preferences->hprefentry = uar_prefgetgroupentry(hprefgroup,(lentryw - 1))
     IF ((preferences->hprefentry=0))
      RETURN(0)
     ENDIF
     SET sprefstring = ""
     SET lentrynamelen = npref_len
     SET preferences->lprefstat = uar_prefgetentryname(preferences->hprefentry,sprefstring,
      lentrynamelen)
     IF ((preferences->lprefstat != 1))
      RETURN(0)
     ENDIF
     SET nprefindex = addpreference(sprefstring)
     IF (nprefindex=0)
      SET preferences->spreferrmsg = "Error adding preference to record."
      RETURN(0)
     ENDIF
     SET preferences->lprefstat = uar_prefgetentryattrcount(preferences->hprefentry,lentryattrcnt)
     IF ((preferences->lprefstat != 1))
      RETURN(0)
     ENDIF
     FOR (lentryattr = 1 TO lentryattrcnt)
       SET preferences->hprefattr = uar_prefgetentryattr(preferences->hprefentry,(lentryattr - 1))
       IF ((preferences->hprefattr=0))
        RETURN(0)
       ENDIF
       SET sattrnamestring = ""
       SET preferences->lprefstat = uar_prefgetattrname(preferences->hprefattr,sattrnamestring,
        lattrnamelen)
       IF ((preferences->lprefstat != 1))
        RETURN(0)
       ENDIF
       IF (sattrnamestring="prefvalue")
        SET preferences->lprefstat = uar_prefgetattrvalcount(preferences->hprefattr,lattrvalcntw)
        IF ((preferences->lprefstat != 1))
         RETURN(0)
        ENDIF
        SET lattrvalcnt = lattrvalcntw
        FOR (lattrval = 1 TO lattrvalcnt)
          SET sattrvalstring = ""
          SET lattrvallen = npref_len
          SET lattrvalw = lattrval
          SET preferences->lprefstat = uar_prefgetattrval(preferences->hprefattr,sattrvalstring,
           lattrvallen,(lattrvalw - 1))
          IF ((preferences->lprefstat != 1))
           RETURN(0)
          ENDIF
          IF (lattrval=1)
           CALL setfirstpreferencevalue(nprefindex,nullterm(sattrvalstring))
          ELSE
           CALL setnextpreferencevalue(nprefindex,nullterm(sattrvalstring))
          ENDIF
        ENDFOR
       ENDIF
       CALL uar_prefdestroyinstance(preferences->hprefattr)
       SET preferences->hprefattr = 0
     ENDFOR
     CALL uar_prefdestroyinstance(preferences->hprefentry)
     SET preferences->hprefentry = 0
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updatepreferences(scontextname,scontextid,ssectionname,ssectionid,sgroupname,nprefindex)
   DECLARE nattrvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iattrvalue = i2 WITH private, noconstant(0)
   DECLARE nprefvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   DECLARE sprefvalue = vc WITH private, noconstant("")
   CALL clearpreferenceerr(0)
   SET preferences->hprefdir = uar_prefcreateinstance(1)
   IF ((preferences->hprefdir=0))
    SET preferences->npreferr = uar_prefgetlasterror()
    SET preferences->lprefstat = uar_prefformatmessage(preferences->spreferrmsg,255)
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm(scontextname),
    nullterm(scontextid))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetsection(preferences->hprefdir,nullterm(ssectionname))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefsectionid = uar_prefcreategroup()
   IF ((preferences->hprefsectionid=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetgroupname(preferences->hprefsectionid,nullterm(ssectionid)
    )
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddgroup(preferences->hprefdir,preferences->hprefsectionid)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   IF (textlen(trim(sgroupname)) > 0)
    SET preferences->hprefgroup = uar_prefaddsubgroup(preferences->hprefsectionid,nullterm(sgroupname
      ))
    IF ((preferences->hprefgroup=0))
     RETURN(checkprefstatus(0))
    ENDIF
   ELSE
    SET preferences->hprefgroup = preferences->hprefsectionid
   ENDIF
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (((nprefindex > nprefentrycnt) OR (nprefindex <= 0)) )
    SET preferences->spreferrmsg = "Invalid preference index passed to UpdatePreferences."
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefentry = uar_prefaddentrytogroup(preferences->hprefgroup,nullterm(preferences
     ->entry_qual[nprefindex].name))
   IF ((preferences->hprefentry=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefattr = uar_prefaddattrtoentry(preferences->hprefentry,nullterm("prefvalue"))
   IF ((preferences->hprefattr=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET nprefvaluecnt = size(preferences->entry_qual[nprefindex].values,5)
   FOR (iprefvalue = 1 TO nprefvaluecnt)
     SET sprefvalue = preferences->entry_qual[nprefindex].values[iprefvalue].value
     SET preferences->lprefstat = uar_prefaddattrval(preferences->hprefattr,nullterm(sprefvalue))
     IF ((preferences->lprefstat != 1))
      RETURN(checkprefstatus(0))
     ENDIF
   ENDFOR
   SET preferences->lprefstat = uar_prefperform(preferences->hprefdir)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   RETURN(checkprefstatus(1))
 END ;Subroutine
 SUBROUTINE deletepreferences(scontextname,scontextid,ssectionname,ssectionid,sgroupname,nprefindex)
   DECLARE nattrvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iattrvalue = i2 WITH private, noconstant(0)
   DECLARE nprefvaluecnt = i2 WITH private, noconstant(0)
   DECLARE iprefvalue = i2 WITH private, noconstant(0)
   DECLARE sprefvalue = vc WITH private, noconstant("")
   CALL clearpreferenceerr(0)
   SET preferences->hprefdir = uar_prefcreateinstance(2)
   IF ((preferences->hprefdir=0))
    SET preferences->npreferr = uar_prefgetlasterror()
    SET preferences->lprefstat = uar_prefformatmessage(preferences->spreferrmsg,255)
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddcontext(preferences->hprefdir,nullterm(scontextname),
    nullterm(scontextid))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetsection(preferences->hprefdir,nullterm(ssectionname))
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefsectionid = uar_prefcreategroup()
   IF ((preferences->hprefsectionid=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefsetgroupname(preferences->hprefsectionid,nullterm(ssectionid)
    )
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefaddgroup(preferences->hprefdir,preferences->hprefsectionid)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   IF (textlen(trim(sgroupname)) > 0)
    SET preferences->hprefgroup = uar_prefaddsubgroup(preferences->hprefsectionid,nullterm(sgroupname
      ))
    IF ((preferences->hprefgroup=0))
     RETURN(checkprefstatus(0))
    ENDIF
   ELSE
    SET preferences->hprefgroup = preferences->hprefsectionid
   ENDIF
   SET nprefentrycnt = size(preferences->entry_qual,5)
   IF (((nprefindex > nprefentrycnt) OR (nprefindex <= 0)) )
    SET preferences->spreferrmsg = "Invalid preference index passed to UpdatePreferences."
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->hprefentry = uar_prefaddentrytogroup(preferences->hprefgroup,nullterm(preferences
     ->entry_qual[nprefindex].name))
   IF ((preferences->hprefentry=0))
    RETURN(checkprefstatus(0))
   ENDIF
   SET preferences->lprefstat = uar_prefperform(preferences->hprefdir)
   IF ((preferences->lprefstat != 1))
    RETURN(checkprefstatus(0))
   ENDIF
   RETURN(checkprefstatus(1))
 END ;Subroutine
 SUBROUTINE testpreferences(dummy)
   DECLARE nprefidx = i2 WITH private, noconstant(0)
   DECLARE sprefvalue = vc WITH private, noconstant("")
   CALL echo("beginning preferences test...")
   CALL loadpreferences("system","","","","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   CALL echorecord(preferences)
   SET nprefidx = findpreference("glb clients")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("system preference value is: ",sprefvalue))
   SET nprefidx = addpreference("glb clients")
   IF (nprefidx=0)
    CALL echo("AddPreference: Error")
   ENDIF
   IF (setfirstpreferencevalue(nprefidx,"All")=0)
    CALL echo("SetFirstPreferenceValue: Error")
   ENDIF
   CALL updatepreferences("user","8058.00","glb_app","DeptOrderEntry","facilitycontext",
    nprefidx)
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("UpdatePreferences: Error")
   ELSE
    CALL echo("user preference value updated to: all")
   ENDIF
   CALL loadpreferences("system","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = findpreference("glb clients")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("current preference value is: ",sprefvalue))
   CALL echorecord(preferences)
   CALL loadpreferences("","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = findpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("current preference value is: ",sprefvalue))
   CALL echorecord(preferences)
   SET nprefidx = addpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("AddPreference: Error")
   ENDIF
   CALL deletepreferences("user","8058.00","glb_app","DeptOrderEntry","facilitycontext",
    nprefidx)
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("DeletePreferences: Error")
   ELSE
    CALL echo("user preference value deleted")
   ENDIF
   CALL loadpreferences("system","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = findpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("Current preference value is: ",sprefvalue))
   CALL loadpreferences("","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = addpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("AddPreference: Error")
   ENDIF
   IF (setfirstpreferencevalue(nprefidx,"Registry")=0)
    CALL echo("SetFirstPreferenceValue: Error")
   ENDIF
   IF (setnextpreferencevalue(nprefidx,"User")=0)
    CALL echo("SetFirstPreferenceValue: Error")
   ENDIF
   CALL updatepreferences("user","8058.00","glb_app","DeptOrderEntry","facilitycontext",
    nprefidx)
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("UpdatePreferences: Error")
   ELSE
    CALL echo("user preference value updated to: registry, user")
   ENDIF
   CALL loadpreferences("system","","","8058.00","glb_app",
    "DeptOrderEntry")
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("LoadPreferences: Error")
   ENDIF
   SET nprefidx = findpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("FindPreference: Error")
   ENDIF
   SET sprefvalue = getpreferencevalue(nprefidx)
   CALL echo(build("current preference value is: ",sprefvalue))
   SET nprefidx = addpreference("kevin test")
   IF (nprefidx=0)
    CALL echo("AddPreference: Error")
   ENDIF
   CALL deletepreferences("user","8058.00","glb_app","DeptOrderEntry","facilitycontext",
    nprefidx)
   IF (textlen(getpreferenceerrmsg(0)) > 0)
    CALL echo("DeletePreferences: Error")
   ELSE
    CALL echo("user preference value deleted")
   ENDIF
   CALL unloadpreferences(0)
   CALL echo("testing complete.")
 END ;Subroutine
 SUBROUTINE clearpreferencerecord(dummy)
   CALL checkprefstatus(1)
   SET preferences->hprefdir = 0
   SET preferences->hprefsection = 0
   SET preferences->hprefsectionid = 0
   SET preferences->hprefgroup = 0
   SET preferences->hprefentry = 0
   SET preferences->hprefattr = 0
   SET stat = alterlist(preferences->entry_qual,0)
   SET preferences->lprefstat = 0
   SET preferences->npreferr = 0
   SET preferences->spreferrmsg = ""
 END ;Subroutine
 RECORD reply(
   1 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE PUBLIC::showmessage(id_ten_t=vc) = null
 SUBROUTINE PUBLIC::showmessage(id_ten_t)
   SET reply->text = id_ten_t
   SELECT
    x = 0
    FROM dummyt
    DETAIL
     id_ten_t
    WITH nocounter
   ;end select
   CALL echo("")
   CALL echo("*******************************************************************************")
   CALL echo(id_ten_t)
   CALL echo("*******************************************************************************")
   CALL echo("")
   SET failed = "T"
   GO TO exit_script
 END ;Subroutine
 DECLARE failed = vc WITH protect, noconstant("F")
 SET reply->status_data.status = "F"
 IF ((reqinfo->updt_id=0.0))
  CALL showmessage("The CCL session must be authenticated when running this script")
 ENDIF
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE lnbrvalues = i4 WITH protect, noconstant(0)
 DECLARE prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE str_prsnl_id = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM prsnl p
  WHERE p.username=cnvtupper( $USERNAME)
  DETAIL
   prsnl_id = p.person_id
  WITH nocounter
 ;end select
 SET str_prsnl_id = trim(concat(format(prsnl_id,";T(1)"),".00"),3)
 SET nstatus = loadpreferences("","","",str_prsnl_id,"application",
  "configuration-manager")
 IF (nstatus=0)
  GO TO script_failed
 ENDIF
 DECLARE entry_name_report_name = vc WITH protect, constant("report-name")
 SET lindex = findpreference(entry_name_report_name)
 IF (lindex=0
  AND textlen(trim( $REPORT_NAME,3)) > 0)
  SET lindex = addpreference(entry_name_report_name)
 ENDIF
 IF (lindex > 0)
  IF (textlen(trim( $REPORT_NAME,3)) > 0)
   SET lnbrvalues = setfirstpreferencevalue(lindex, $REPORT_NAME)
   SET nstatus = updatepreferences("user",str_prsnl_id,"application","configuration-manager","",
    lindex)
  ELSE
   SET nstatus = deletepreferences("user",str_prsnl_id,"application","configuration-manager","",
    lindex)
  ENDIF
  IF (nstatus=0)
   GO TO script_failed
  ENDIF
 ENDIF
 DECLARE entry_name_report_params = vc WITH protect, constant("report-params")
 SET lindex = findpreference(entry_name_report_params)
 IF (lindex=0
  AND textlen(trim( $REPORT_PARAMS,3)) > 0)
  SET lindex = addpreference(entry_name_report_params)
 ENDIF
 IF (lindex > 0)
  IF (textlen(trim( $REPORT_PARAMS,3)) > 0)
   SET lnbrvalues = setfirstpreferencevalue(lindex, $REPORT_PARAMS)
   SET nstatus = updatepreferences("user",str_prsnl_id,"application","configuration-manager","",
    lindex)
  ELSE
   SET nstatus = deletepreferences("user",str_prsnl_id,"application","configuration-manager","",
    lindex)
  ENDIF
  IF (nstatus=0)
   GO TO script_failed
  ENDIF
 ENDIF
 GO TO exit_script
#script_failed
 SET failed = "T"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = getpreferenceerrmsg(0)
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
 CALL unloadpreferences(1)
 CALL echorecord(reply)
 IF (validate(_memory_reply_string)=true)
  SET _memory_reply_string = cnvtrectojson(reply)
 ENDIF
END GO
