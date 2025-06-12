CREATE PROGRAM acc_get_setup:dba
 EXECUTE prefrtl
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
 SUBROUTINE (findpreference(sentryname=vc) =i2)
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
 SUBROUTINE (addpreference(sentryname=vc) =i2)
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
 SUBROUTINE (getpreferencevalue(nprefindex=i2) =vc)
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
 SUBROUTINE (setfirstpreferencevalue(nprefindex=i2,sprefvalue=vc) =i2)
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
 SUBROUTINE (setnextpreferencevalue(nprefindex=i2,sprefvalue=vc) =i2)
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
 SUBROUTINE (getpreferenceerrmsg(dummy=i2) =vc)
   RETURN(trim(preferences->spreferrmsg))
 END ;Subroutine
 SUBROUTINE (clearpreferences(dummy=i2) =null)
  SET stat = alterlist(preferences->entry_qual,0)
  CALL checkprefstatus(1)
 END ;Subroutine
 SUBROUTINE (clearpreferenceerr(dummy=i2) =null)
   SET preferences->lprefstat = 0
   SET preferences->npreferr = 0
   SET preferences->spreferrmsg = ""
 END ;Subroutine
 SUBROUTINE (unloadpreferences(dummy=i2) =null)
  CALL checkprefstatus(1)
  FREE RECORD preferences
 END ;Subroutine
 SUBROUTINE (loadpreferences(ssystemctx=vc,sfacilityctx=vc,spositionctx=vc,suserctx=vc,ssectionname=
  vc,ssectionid=vc) =i2)
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
 SUBROUTINE (checkprefstatus(nsuccessind=i2) =i2)
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
 SUBROUTINE (readpreferences(hprefgroup=h) =i2)
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
 SUBROUTINE (updatepreferences(scontextname=vc,scontextid=vc,ssectionname=vc,ssectionid=vc,sgroupname
  =vc,nprefindex=i2) =i2)
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
 SUBROUTINE (deletepreferences(scontextname=vc,scontextid=vc,ssectionname=vc,ssectionid=vc,sgroupname
  =vc,nprefindex=i2) =i2)
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
 SUBROUTINE (testpreferences(dummy=i2) =null)
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
 SUBROUTINE (clearpreferencerecord(dummy=i2) =null)
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
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 site_code_length = i4
    1 year_display_length = i4
    1 julian_sequence_length = i4
    1 prefix_sequence_length = i4
    1 default_site_cd = f8
    1 default_site_disp = c40
    1 accept_future_days = i4
    1 assign_future_days = i4
    1 site_qual[*]
      2 site_prefix_cd = f8
      2 site_prefix_disp = c40
      2 format_qual[*]
        3 accession_format_cd = f8
        3 accession_format_disp = c40
        3 accession_format_mean = c12
        3 accession_assign_pool_id = f8
        3 activity_type_cd = f8
        3 activity_type_disp = c40
        3 activity_type_mean = c12
    1 pool_qual[*]
      2 pool_id = f8
      2 description = vc
      2 initial_value = f8
      2 increment_value = f8
    1 foreign_accession_ind = i2
    1 foreign_format_qual[*]
      2 format_cd = f8
      2 format_mask = vc
      2 regexp = vc
      2 reuse_ind = i2
      2 container_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE nindex = i2 WITH protect, noconstant(0)
 DECLARE foreign_accession_pattern = vc WITH protect, constant("Foreign_Accession_Pattern")
 DECLARE foreign_accession_reuse = vc WITH protect, constant("Foreign_Accession_Reuse")
 DECLARE foreign_accession_formatting = vc WITH protect, constant("Foreign_Accession_Formatting")
 DECLARE foreign_accession_container_id = vc WITH protect, constant("Foreign_Accession_Container_ID")
 SET accession_setup_id = 72696.00
 SET reply->status_data.status = "P"
 SET reply->site_code_length = 5
 SET reply->julian_sequence_length = 6
 SET reply->prefix_sequence_length = 7
 SET reply->year_display_length = 4
 SET reply->default_site_cd = 0
 SET reply->accept_future_days = 30
 SET reply->assign_future_days = 1825
 SELECT INTO "nl:"
  a.accession_setup_id, assign_ind = nullind(a.assign_future_days), accept_ind = nullind(a
   .accept_future_days)
  FROM accession_setup a
  PLAN (a
   WHERE a.accession_setup_id=accession_setup_id)
  DETAIL
   reply->site_code_length = a.site_code_length, reply->julian_sequence_length = a
   .julian_sequence_length, reply->prefix_sequence_length = a.alpha_sequence_length,
   reply->year_display_length = a.year_display_length, reply->default_site_cd = a.default_site_cd
   IF (assign_ind=0)
    reply->assign_future_days = a.assign_future_days
   ENDIF
   IF (accept_ind=0)
    reply->accept_future_days = a.accept_future_days
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL subevent_add("SELECT","Z","ACCESSION_SETUP","ACCESSION_SETUP select failed")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  aax.site_prefix_cd, aax.accession_format_cd, aap.accession_assignment_pool_id
  FROM accession_assign_xref aax,
   accession_assign_pool aap
  PLAN (aax
   WHERE aax.accession_assignment_pool_id > 0)
   JOIN (aap
   WHERE aap.accession_assignment_pool_id=aax.accession_assignment_pool_id)
  ORDER BY aax.site_prefix_cd, aax.accession_format_cd
  HEAD REPORT
   site = 0
  HEAD aax.site_prefix_cd
   site += 1, format = 0
   IF (site > size(reply->site_qual,5))
    stat = alterlist(reply->site_qual,(site+ 10))
   ENDIF
   reply->site_qual[site].site_prefix_cd = aax.site_prefix_cd
  DETAIL
   format += 1
   IF (format > size(reply->site_qual[site].format_qual,5))
    stat = alterlist(reply->site_qual[site].format_qual,(format+ 10))
   ENDIF
   reply->site_qual[site].format_qual[format].accession_format_cd = aax.accession_format_cd, reply->
   site_qual[site].format_qual[format].accession_assign_pool_id = aax.accession_assignment_pool_id,
   reply->site_qual[site].format_qual[format].activity_type_cd = aax.activity_type_cd,
   pool = 1
   WHILE (pool > 0)
     IF (pool > size(reply->pool_qual,5))
      pool = 0
     ELSE
      IF ((reply->pool_qual[pool].pool_id=aap.accession_assignment_pool_id))
       pool = - (1)
      ELSE
       pool += 1
      ENDIF
     ENDIF
   ENDWHILE
   IF (pool=0)
    pool = size(reply->pool_qual,5)
    IF (pool=0)
     pool += 1
    ENDIF
    stat = alterlist(reply->pool_qual,(pool+ 1)), reply->pool_qual[pool].pool_id = aap
    .accession_assignment_pool_id, reply->pool_qual[pool].description = aap.description,
    reply->pool_qual[pool].initial_value = aap.initial_value, reply->pool_qual[pool].increment_value
     = aap.increment_value
   ENDIF
  FOOT  aax.site_prefix_cd
   stat = alterlist(reply->site_qual[site].format_qual,format)
  FOOT REPORT
   stat = alterlist(reply->site_qual,site)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL subevent_add("SELECT","Z","ACCESSION_ASIGN_XREF / ACCESSION_ASSIGN_POOL",
   "Accession POOL lookup failed")
 ENDIF
 SET nstatus = loadpreferences("system","","","","config",
  "Laboratory")
 IF (nstatus != 0)
  SET nindex = findpreference("enable foreign accession accept")
  IF (nindex > 0)
   IF (getpreferencevalue(nindex)="Yes")
    SET reply->foreign_accession_ind = 1
   ENDIF
  ENDIF
 ENDIF
 IF ((reply->foreign_accession_ind=1))
  SELECT INTO "nl:"
   FROM code_value_extension cve,
    code_value_extension cve_reuse,
    code_value_extension cve_formatting,
    code_value_extension cve_containerid
   PLAN (cve
    WHERE cve.code_set=2057
     AND cve.field_name=foreign_accession_pattern)
    JOIN (cve_reuse
    WHERE (cve_reuse.code_value= Outerjoin(cve.code_value))
     AND (cve_reuse.field_name= Outerjoin(foreign_accession_reuse)) )
    JOIN (cve_formatting
    WHERE (cve_formatting.code_value= Outerjoin(cve.code_value))
     AND (cve_formatting.field_name= Outerjoin(foreign_accession_formatting)) )
    JOIN (cve_containerid
    WHERE (cve_containerid.code_value= Outerjoin(cve.code_value))
     AND (cve_containerid.field_name= Outerjoin(foreign_accession_container_id)) )
   HEAD REPORT
    idx = 0
   DETAIL
    IF (uar_get_code_meaning(cve.code_value)="FOREIGN")
     idx += 1, stat = alterlist(reply->foreign_format_qual,idx), reply->foreign_format_qual[idx].
     format_cd = cve.code_value,
     reply->foreign_format_qual[idx].regexp = cve.field_value
     IF (cve_reuse.field_value IN ("1", "Y", "Yes", "YES"))
      reply->foreign_format_qual[idx].reuse_ind = 1
     ENDIF
     reply->foreign_format_qual[idx].format_mask = cve_formatting.field_value
     IF (cve_containerid.field_value IN ("M", "HNAM", "Millennium", "MILLENNIUM"))
      reply->foreign_format_qual[idx].container_flag = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (size(reply->site_qual,5) > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
