CREATE PROGRAM cv_get_ref_letter_info:dba
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 EXECUTE prefrtl
 RECORD preferences(
   1 hprefdir = i4
   1 hprefsection = i4
   1 hprefsectionid = i4
   1 hprefgroup = i4
   1 hprefsubgroup = i4
   1 hprefentry = i4
   1 hprefattr = i4
   1 entry_qual[*]
     2 name = vc
     2 values[*]
       3 value = vc
   1 lprefstat = i4
   1 npreferr = i2
   1 spreferrmsg = c255
 )
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
  vc,ssectionid=vc,ssubgroup1name=vc,ssubgroup2name=vc) =i2)
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
   IF (textlen(trim(ssubgroup1name)) > 0)
    IF (readpreferencessubgroup(preferences->hprefsectionid,ssubgroup1name) != 1)
     RETURN(checkprefstatus(0))
    ENDIF
    SET preferences->hprefsubgroup = preferences->hprefgroup
    IF (textlen(trim(ssubgroup2name)) > 0)
     IF (readpreferencessubgroup(preferences->hprefsubgroup,ssubgroup2name) != 1)
      RETURN(checkprefstatus(0))
     ENDIF
    ENDIF
   ENDIF
   RETURN(checkprefstatus(1))
 END ;Subroutine
 SUBROUTINE (readpreferencessubgroup(p_hgroup=i4,p_ssubgroupname=vc) =i4)
   DECLARE lsubgroupcnt = i4 WITH private, noconstant(0)
   DECLARE lsubgroupidx = i4 WITH private, noconstant(0)
   DECLARE ssubgroupname = c255 WITH private, noconstant("")
   DECLARE lsubgroupnamelen = i4 WITH private, noconstant(255)
   SET preferences->lprefstat = uar_prefgetsubgroupcount(p_hgroup,lsubgroupcnt)
   IF ((preferences->lprefstat != 1))
    RETURN(0)
   ENDIF
   FOR (lsubgroupidx = 1 TO lsubgroupcnt)
     SET preferences->hprefgroup = uar_prefgetsubgroup(p_hgroup,(lsubgroupidx - 1))
     IF ((preferences->hprefgroup=0))
      CALL cv_log_msg(cv_warning,build("Failed to get SubGroup:",lsubgroupidx))
      RETURN(0)
     ENDIF
     SET preferences->lprefstat = uar_prefgetgroupname(preferences->hprefgroup,ssubgroupname,
      lsubgroupnamelen)
     CALL cv_log_msg(cv_info,build(ssubgroupname,"::",lsubgroupnamelen,"::",preferences->lprefstat))
     IF (cnvtlower(trim(ssubgroupname))=cnvtlower(trim(p_ssubgroupname)))
      CALL cv_log_msg(cv_debug,"Matched SubGroupName")
      IF (readpreferences(preferences->hprefgroup)=0)
       CALL cv_log_msg(cv_warning,build("Failed to ReadPreferences on SubGroup:",lsubgroupidx))
       RETURN(0)
      ENDIF
      RETURN(1)
     ELSE
      CALL cv_log_msg(cv_audit,build("Didn't match:",cnvtlower(trim(ssubgroupname)),"!=",cnvtlower(
         trim(p_ssubgroupname))))
      CALL uar_prefdestroygroup(preferences->hprefgroup)
      SET preferences->hprefgroup = 0
     ENDIF
   ENDFOR
   RETURN(0)
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
    IF ( NOT ((preferences->hprefgroup IN (preferences->hprefsectionid, preferences->hprefsubgroup)))
    )
     CALL uar_prefdestroygroup(preferences->hprefgroup)
    ENDIF
    SET preferences->hprefgroup = 0
   ENDIF
   IF ((preferences->hprefsubgroup > 0))
    CALL uar_prefdestroygroup(preferences->hprefsubgroup)
    SET preferences->hprefsubgroup = 0
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
 SUBROUTINE (readpreferences(hprefgroup=i4) =i2)
   DECLARE npref_len = i2 WITH private, constant(255)
   DECLARE npref_val_len = i2 WITH private, constant(2047)
   DECLARE lentry = i4 WITH private, noconstant(0)
   DECLARE sprefstring = c255 WITH private, noconstant("")
   DECLARE sattrnamestring = c255 WITH private, noconstant("")
   DECLARE sattrvalstring = c2047 WITH private, noconstant("")
   DECLARE lattrnamelen = i4 WITH private, noconstant(npref_len)
   DECLARE lentrynamelen = i4 WITH private, noconstant(npref_len)
   DECLARE lgroupentrycnt = i4 WITH private, noconstant(0)
   DECLARE lentryattrcnt = i4 WITH private, noconstant(0)
   DECLARE lattrvalcnt = i4 WITH private, noconstant(0)
   DECLARE lattrvallen = i4 WITH private, noconstant(npref_val_len)
   DECLARE lentryattr = i4 WITH private, noconstant(0)
   DECLARE lattrval = i4 WITH private, noconstant(0)
   DECLARE nprefindex = i2 WITH private, noconstant(0)
   SET preferences->lprefstat = uar_prefgetgroupentrycount(hprefgroup,lgroupentrycnt)
   CALL cv_log_msg(cv_debug,build("GroupEntryCnt:",lgroupentrycnt))
   IF ((preferences->lprefstat != 1))
    RETURN(0)
   ENDIF
   FOR (lentry = 1 TO lgroupentrycnt)
     SET preferences->hprefentry = uar_prefgetgroupentry(hprefgroup,(lentry - 1))
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
     CALL cv_log_msg(cv_debug,build("sPrefString:",sprefstring,":"))
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
        SET preferences->lprefstat = uar_prefgetattrvalcount(preferences->hprefattr,lattrvalcnt)
        IF ((preferences->lprefstat != 1))
         RETURN(0)
        ENDIF
        FOR (lattrval = 1 TO lattrvalcnt)
          SET sattrvalstring = ""
          SET lattrvallen = npref_val_len
          SET preferences->lprefstat = uar_prefgetattrval(preferences->hprefattr,sattrvalstring,
           lattrvallen,(lattrval - 1))
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
   SET preferences->hprefsubgroup = 0
 END ;Subroutine
 IF (validate(reply->status_data.status)=0)
  FREE SET reply
  RECORD reply(
    1 ref_phys[*]
      2 ref_phys_id = f8
    1 template_id = f8
    1 chart_format_id = f8
    1 on_off_ind = i2
    1 include_report_ind = i2
    1 task_assay_cd = f8
    1 default_output_dest_cd = f8
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE refer_cnt = i4 WITH protect
 DECLARE task_assay_str = vc WITH protect
 DECLARE prsnl_id_str = vc WITH protect
 DECLARE position_cd_str = vc WITH protect
 DECLARE g_task_assay_cd = f8 WITH protect, noconstant(validate(request->task_assay_cd,0.0))
 DECLARE req_catalog_cd = f8 WITH protect, noconstant(validate(request->catalog_cd,0.0))
 DECLARE c_step_type_refletter = f8 WITH protect, noconstant(uar_get_code_by("MEANING",4001923,
   "REFLETTER"))
 DECLARE now_dt_tm = q8 WITH protect, noconstant(cnvtdatetime(sysdate))
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr
  WHERE (epr.encntr_id=request->encntr_id)
   AND epr.encntr_prsnl_r_cd=value(uar_get_code_by("MEANING",333,"REFERDOC"))
   AND epr.active_ind=1
   AND epr.beg_effective_dt_tm <= cnvtdatetime(now_dt_tm)
   AND epr.end_effective_dt_tm > cnvtdatetime(now_dt_tm)
  DETAIL
   refer_cnt += 1, stat = alterlist(reply->ref_phys,refer_cnt), reply->ref_phys[refer_cnt].
   ref_phys_id = epr.prsnl_person_id
  WITH nocounter
 ;end select
 IF (g_task_assay_cd <= 0.0)
  IF (req_catalog_cd > 0.0)
   SELECT INTO "nl:"
    FROM profile_task_r ptr,
     cv_step_ref sr
    PLAN (ptr
     WHERE (ptr.catalog_cd=request->catalog_cd)
      AND ptr.active_ind=1)
     JOIN (sr
     WHERE sr.task_assay_cd=ptr.task_assay_cd
      AND sr.step_type_cd=c_step_type_refletter)
    ORDER BY ptr.sequence
    DETAIL
     g_task_assay_cd = sr.task_assay_cd
    WITH maxqual(sr,1)
   ;end select
  ELSE
   CALL cv_log_stat(cv_warning,"REQUEST","F","CATALOG_CD",build(req_catalog_cd))
  ENDIF
  IF (g_task_assay_cd <= 0.0)
   CALL cv_log_stat(cv_warning,"SELECT","Z","PROFILE_TASK_R",build("CATALOG_CD=",req_catalog_cd))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (validate(reply->task_assay_cd)=1)
  SET reply->task_assay_cd = g_task_assay_cd
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr
  WHERE (pr.person_id=request->prim_physician_id)
  DETAIL
   prsnl_id_str = trim(cnvtstring(pr.person_id,15,2)), position_cd_str = trim(cnvtstring(pr
     .position_cd,15,2))
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_stat(cv_error,"SELECT","Z","PRSNL",build("PERSON_ID=",proc->prim_physician_id))
  RETURN(1)
 ENDIF
 DECLARE task_assay_cd_str = vc WITH noconstant(trim(cnvtstring(g_task_assay_cd)))
 CALL cv_log_msg(cv_info,build("position_cd_str=",position_cd_str))
 CALL cv_log_msg(cv_info,build("prsnl_id_str=",prsnl_id_str))
 CALL cv_log_msg(cv_info,build("task_assay_cd_str=",task_assay_cd_str))
 CALL loadpreferences("system","",position_cd_str,prsnl_id_str,"module",
  "cvnet","refletters",task_assay_cd_str)
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(preferences)
 ENDIF
 SET reply->chart_format_id = cnvtreal(getpreferencevalue(findpreference("chart format")))
 SET reply->template_id = cnvtreal(getpreferencevalue(findpreference("template")))
 SET reply->on_off_ind = cnvtint(getpreferencevalue(findpreference("on_off")))
 SET reply->include_report_ind = cnvtint(getpreferencevalue(findpreference("include_report")))
 SET reply->default_output_dest_cd = cnvtreal(getpreferencevalue(findpreference("output_dest")))
 SET reply->status_data.status = "S"
#exit_script
 CALL unloadpreferences(null)
 CALL cv_log_msg_post("MOD 001 07/24/2006 MH9140")
END GO
