CREATE PROGRAM cv_order_to_proc:dba
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
 IF (validate(proc_stat_ordered)=0)
  DECLARE cs_proc_stat = i4 WITH constant(4000341), public
  DECLARE proc_stat_ordered = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"ORDERED")),
  public
  DECLARE proc_stat_scheduled = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"SCHEDULED")),
  public
  DECLARE proc_stat_arrived = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"ARRIVED")),
  public
  DECLARE proc_stat_inprocess = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"INPROCESS")),
  public
  DECLARE proc_stat_completed = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"COMPLETED")),
  public
  DECLARE proc_stat_discontinued = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,
    "DISCONTINUED")), public
  DECLARE proc_stat_cancelled = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"CANCELLED")),
  public
  DECLARE proc_stat_verified = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"VERIFIED")),
  public
  DECLARE proc_stat_unsigned = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"UNSIGNED")),
  public
  DECLARE proc_stat_signed = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"SIGNED")),
  public
  DECLARE proc_stat_edreview = f8 WITH constant(uar_get_code_by("MEANING",cs_proc_stat,"EDREVIEW")),
  public
  DECLARE cs_step_stat = i4 WITH constant(4000440), public
  DECLARE step_stat_notstarted = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"NOTSTARTED"
    )), public
  DECLARE step_stat_inprocess = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"INPROCESS")),
  public
  DECLARE step_stat_saved = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"SAVED")), public
  DECLARE step_stat_unsigned = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"UNSIGNED")),
  public
  DECLARE step_stat_completed = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"COMPLETED")),
  public
  DECLARE step_stat_discontinued = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,
    "DISCONTINUED")), public
  DECLARE step_stat_cancelled = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"CANCELLED")),
  public
  DECLARE step_stat_edreview = f8 WITH constant(uar_get_code_by("MEANING",cs_step_stat,"EDREVIEW")),
  public
  DECLARE cs_edreview_stat = i4 WITH constant(4002463), public
  DECLARE edreview_stat_available = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "AVAILABLE")), public
  DECLARE edreview_stat_agreed = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,"AGREED"
    )), public
  DECLARE edreview_stat_disagreed = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "DISAGREED")), public
  DECLARE edreview_stat_acknowledged = f8 WITH constant(uar_get_code_by("MEANING",cs_edreview_stat,
    "ACKNOWLEDGED")), public
  DECLARE edreview_stat_removed = f8 WITH constant(null), public
 ENDIF
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
 DECLARE c_contrib_source_powerchart = f8 WITH protect, constant(uar_get_code_by("MEANING",73,
   "POWERCHART"))
 DECLARE c_step_status_notstarted = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "NOTSTARTED"))
 DECLARE c_proc_status_ordered = f8 WITH protect, constant(uar_get_code_by("MEANING",4000341,
   "ORDERED"))
 DECLARE time_now = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE step_reltn_cs = i4 WITH protect, constant(4000400)
 DECLARE g_catalog_cd = f8 WITH protect
 DECLARE g_order_id = f8 WITH protect
 DECLARE g_encntr_id = f8 WITH protect
 DECLARE g_person_id = f8 WITH protect
 DECLARE g_accession = vc WITH protect, noconstant("")
 DECLARE g_accession_id = f8 WITH protect, noconstant(0.0)
 DECLARE g_group_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE step_cnt = i4 WITH protect
 DECLARE step_idx = i4 WITH protect
 DECLARE step_stat = f8 WITH protect
 DECLARE req_date_ind = i2 WITH protect
 DECLARE detailcnt = i4 WITH protect
 DECLARE substatus = i4 WITH protect
 DECLARE step_prsnl_size = i4 WITH protect
 DECLARE encntr_added_ind = i2 WITH protect
 DECLARE action_type_mean = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE g_sch_event_id = f8 WITH protect
 DECLARE g_phys_group_id = i4 WITH protect
 DECLARE g_trigger_notify_ind = i2 WITH protect
 DECLARE g_prov_from_sched_ind = i2 WITH protect
 DECLARE g_loc_from_sched_ind = i2 WITH protect
 DECLARE notify_cnt = i4 WITH protect
 DECLARE notify_idx = i4 WITH protect
 DECLARE e_od_flag_no = i2 WITH protect, constant(0)
 DECLARE e_od_flag_yes = i2 WITH protect, constant(1)
 DECLARE e_od_flag_clear = i2 WITH protect, constant(2)
 DECLARE g_prim_od_flag = i2 WITH protect
 DECLARE g_group_od_flag = i2 WITH protect
 DECLARE c_oef_meaning_reqedphys = f8 WITH protect, constant(5.0)
 DECLARE c_oef_meaning_physiciangroup = f8 WITH protect, constant(2397.00)
 DECLARE checksched(null) = i4
 DECLARE populateserviceresourcecodeinproclist(null) = null
 SET curalias sched proc_list->cv_proc[1].cv_step[step_idx].cv_step_sched[1]
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(request,"cer_temp:cv_order_to_proc_debug_req.txt")
 ENDIF
 FREE RECORD proc_list
 RECORD proc_list(
   1 cv_proc[*]
     2 accession = vc
     2 accession_id = f8
     2 action_dt_tm = dq8
     2 catalog_cd = f8
     2 cv_proc_id = f8
     2 encntr_id = f8
     2 group_event_id = f8
     2 order_id = f8
     2 order_physician_id = f8
     2 person_id = f8
     2 phys_group_id = f8
     2 prim_physician_id = f8
     2 priority_cd = f8
     2 proc_status_cd = f8
     2 reason_for_proc = vc
     2 refer_physician_id = f8
     2 sequence = i4
     2 request_dt_tm = dq8
     2 updt_cnt = i4
     2 modified_ind = i2
     2 cv_step[*]
       3 cv_step_id = f8
       3 event_id = f8
       3 sequence = i4
       3 step_status_cd = f8
       3 task_assay_cd = f8
       3 updt_cnt = i4
       3 modified_ind = i2
       3 match_ind = i2
       3 unmatch_ind = i2
       3 activity_subtype_cd = f8
       3 doc_id_str = vc
       3 doc_type_cd = f8
       3 proc_status_cd = f8
       3 schedule_ind = i2
       3 step_level_flag = i2
       3 perf_loc_cd = f8
       3 perf_provider_id = f8
       3 perf_start_dt_tm = dq8
       3 perf_stop_dt_tm = dq8
       3 lock_prsnl_id = f8
       3 doc_template_id = f8
       3 cv_step_sched[*]
         4 arrive_dt_tm = dq8
         4 arrive_ind = i2
         4 cv_step_sched_id = f8
         4 sched_loc_cd = f8
         4 sched_phys_id = f8
         4 sched_start_dt_tm = dq8
         4 sched_stop_dt_tm = dq8
         4 updt_cnt = i4
         4 modified_ind = i2
       3 step_type_cd = f8
       3 lock_updt_dt_tm = dq8
       3 step_resident_id = f8
       3 cv_step_ind = i2
       3 action_tz = i4
       3 modality_cd = f8
       3 vendor_cd = f8
       3 study_identifier = vc
       3 study_dt_tm = dq8
       3 pdf_doc_identifier = vc
       3 normalcy_cd = f8
     2 activity_subtype_cd = f8
     2 ed_review_ind = i2
     2 ed_review_status_cd = f8
     2 ed_requestor_prsnl_id = f8
     2 ed_request_dt_tm = dq8
     2 orig_order_dt_tm = dq8
     2 proc_normalcy_cd = f8
     2 proc_indicator = vc
     2 stress_ecg_status_cd = f8
     2 future_order_ind = i2
     2 study_state_cd = f8
     2 study_state_disp = vc
     2 study_state_mean = c12
   1 calling_process_name = vc
   1 order_action_tz = i4
   1 edit_doc_flag = i2
   1 cv_step_prsnl[*]
     2 action_dt_tm = dq8
     2 action_type_cd = f8
     2 cv_step_id = f8
     2 cv_step_prsnl_id = f8
     2 step_prsnl_id = f8
     2 step_relation_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF (validate(reply) != 1)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(reply->status_data.status) != 1)
  CALL cv_log_msg(cv_error,"Invalid reply record for CV_ORDER_TO_PROC")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 IF (validate(request) != 1)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","")
  GO TO exit_script
 ENDIF
 IF (validate(request->order_id,0.0)=0.0)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","ORDER_ID=0.0")
  GO TO exit_script
 ENDIF
 IF (validate(request->person_id,0.0)=0.0)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","PERSON_ID=0.0")
  GO TO exit_script
 ENDIF
 IF (validate(request->action_type_cd,0.0)=0.0)
  CALL cv_log_stat(cv_error,"VALIDATE","F","REQUEST","ACTION_TYPE_CD=0.0")
  GO TO exit_script
 ENDIF
 IF (validate(request->catalog_cd,0.0) != 0.0)
  SET g_catalog_cd = request->catalog_cd
 ELSE
  SET g_catalog_cd = 0.0
 ENDIF
 IF (validate(request->encntr_id,0.0) != 0.0)
  SET g_encntr_id = request->encntr_id
 ELSE
  SET g_encntr_id = 0.0
 ENDIF
 IF (validate(request->accession,"") != null)
  SET g_accession = request->accession
 ENDIF
 IF (validate(request->accession_id,0.0) != 0.0)
  SET g_accession_id = request->accession_id
 ELSE
  SET g_accession_id = 0.0
 ENDIF
 SET action_type_mean = uar_get_code_meaning(request->action_type_cd)
 CALL cv_log_msg(cv_debug,build("action_type_mean=",action_type_mean))
 CASE (action_type_mean)
  OF "ORDER":
   CALL execnewsteps(0)
   SET substatus = checksched(null)
   CALL execsaveprocs(0)
   IF (g_encntr_id > 0.0)
    CALL execaddim(0)
   ENDIF
  OF "MODIFY":
  OF "ACTIVATE":
   SET g_group_event_id = 0.0
   SET substatus = execfetchprocs(0)
   IF (substatus != 0)
    CALL cv_log_stat(cv_warning,"SUBROUTINE","F","ExecFetchProcs",build("RETURN=",substatus))
    GO TO exit_script
   ENDIF
   IF (g_group_event_id=0
    AND action_type_mean="MODIFY")
    SET request->future_order_ind = 1
    SET proc_list->cv_proc[1].future_order_ind = 1
   ENDIF
   IF (g_encntr_id > 0.0
    AND (proc_list->cv_proc[1].encntr_id=0.0))
    SET proc_list->cv_proc[1].encntr_id = g_encntr_id
    SET proc_list->cv_proc[1].modified_ind = 1
    SET encntr_added_ind = 1
   ENDIF
   IF (g_accession != null
    AND g_accession_id != 0.0)
    SET proc_list->cv_proc[1].accession = g_accession
    SET proc_list->cv_proc[1].accession_id = g_accession_id
    SET proc_list->cv_proc[1].modified_ind = 1
   ENDIF
   SET substatus = checksched(null)
   IF ((proc_list->cv_proc[1].order_physician_id != request->order_provider_id))
    SET proc_list->cv_proc[1].order_physician_id = request->order_provider_id
    SET proc_list->cv_proc[1].modified_ind = 1
   ENDIF
   SET substatus = updprocrec(0)
   IF (substatus != 0)
    CALL cv_log_stat(cv_warning,"SUBROUTINE","F","UpdProcRec",build("RETURN=",substatus))
    GO TO exit_script
   ENDIF
   IF (encntr_added_ind=1)
    CALL execaddim(0)
   ENDIF
  OF "CANCEL":
  OF "DISCONTINUE":
  OF "CANCEL DC":
  OF "TRANSFER/CAN":
   SET g_group_event_id = 0.0
   SET substatus = execfetchprocs(0)
   IF (substatus != 0)
    CALL cv_log_stat(cv_warning,"SUBROUTINE","F","ExecFetchProcs",build("RETURN=",substatus))
    GO TO exit_script
   ENDIF
   IF (g_group_event_id=0
    AND ((action_type_mean="CANCEL") OR (action_type_mean="CANCEL DC")) )
    SET request->future_order_ind = 1
    SET proc_list->cv_proc[1].future_order_ind = 1
   ENDIF
   SET substatus = updstepstatus(0)
   IF (substatus != 0)
    CALL cv_log_stat(cv_warning,"SUBROUTINE","F","UpdStepStatus",build("RETURN=",substatus))
    GO TO exit_script
   ENDIF
  ELSE
   CALL cv_log_stat(cv_debug,"VALIDATE","Z","REQUEST",build("ACTION_TYPE_MEAN=",action_type_mean))
 ENDCASE
 SUBROUTINE checksched(null)
   DECLARE notify_flag = i2 WITH public, noconstant(- (1))
   DECLARE sched_flag = i2 WITH public, noconstant(- (1))
   DECLARE sched_modified_flag = i2 WITH protect, noconstant(0)
   DECLARE sched_ind = i2 WITH protect, noconstant(0)
   FREE RECORD notify_list
   RECORD notify_list(
     1 prsnl[*]
       2 person_id = f8
       2 username = vc
   )
   SET stat = checkschedprefs(sched_flag,notify_flag)
   IF (sched_flag <= 0)
    CALL cv_log_msg(cv_debug,"Scheduling preference not set")
    RETURN(sched_flag)
   ENDIF
   CALL cv_log_msg(cv_debug,"Checking scheduling tables")
   SET step_idx = locateval(step_idx,1,step_cnt,1,proc_list->cv_proc[1].cv_step[step_idx].
    schedule_ind)
   IF (step_idx=0)
    CALL cv_log_stat(cv_debug,"VALIDATE","Z","PROC_LIST","All SCHEDULE_IND=0")
    RETURN(0)
   ENDIF
   SET step_cnt = size(proc_list->cv_proc[1].cv_step,5)
   FOR (step_idx = 1 TO step_cnt)
    SET sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind
    IF (sched_ind > 0)
     IF (size(proc_list->cv_proc[1].cv_step[step_idx].cv_step_sched,5)=0)
      CALL cv_log_stat(cv_error,"VALIDATE","Z","PROC_LIST","CV_STEP_SCHED is empty")
      RETURN(1)
     ENDIF
    ENDIF
   ENDFOR
   SELECT INTO "nl:"
    FROM sch_event_attach sea,
     sch_appt sa
    PLAN (sea
     WHERE (sea.order_id=request->order_id))
     JOIN (sa
     WHERE sa.sch_event_id=sea.sch_event_id)
    HEAD REPORT
     g_sch_event_id = sea.sch_event_id
    DETAIL
     IF (sa.primary_role_ind=1)
      FOR (step_idx = 1 TO step_cnt)
       sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind,
       IF (sched_ind > 0)
        IF (cnvtdatetime(sched->sched_start_dt_tm) != sa.beg_dt_tm)
         sched->sched_start_dt_tm = sa.beg_dt_tm, sched->modified_ind = 1
        ENDIF
        IF (cnvtdatetime(sched->sched_stop_dt_tm) != sa.end_dt_tm)
         sched->sched_stop_dt_tm = sa.end_dt_tm, sched->modified_ind = 1
        ENDIF
       ENDIF
      ENDFOR
      g_appt_location_cd = sa.appt_location_cd, g_sch_event_id = sa.sch_event_id
     ENDIF
     CASE (sa.role_meaning)
      OF "PATIENT":
       FOR (step_idx = 1 TO step_cnt)
        sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind,
        IF (sched_ind > 0)
         IF (sa.state_meaning="CHECKED IN"
          AND (sched->arrive_ind=0))
          sched->arrive_ind = 1, sched->arrive_dt_tm = cnvtdatetime(sysdate), sched->modified_ind = 1,
          g_trigger_notify_ind = 1
         ENDIF
        ENDIF
       ENDFOR
      OF "CVPERFPROV":
       g_prov_from_sched_ind = 1,
       FOR (step_idx = 1 TO step_cnt)
        sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind,
        IF (sched_ind > 0)
         IF ((sched->sched_phys_id != sa.person_id))
          sched->sched_phys_id = sa.person_id, sched->modified_ind = 1
          IF ((sched->sched_phys_id > 0.0)
           AND (sched->arrive_ind=1)
           AND (proc_list->cv_proc[1].cv_step[step_idx].step_status_cd=c_step_status_notstarted))
           g_trigger_notify_ind = 1
          ENDIF
         ENDIF
        ENDIF
       ENDFOR
      OF "RESOURCE":
       IF (sa.service_resource_cd > 0.0)
        g_loc_from_sched_ind = 1
        FOR (step_idx = 1 TO step_cnt)
         sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind,
         IF (sched_ind > 0)
          sched->sched_loc_cd = sa.service_resource_cd
         ENDIF
        ENDFOR
       ENDIF
     ENDCASE
    WITH nocounter
   ;end select
   FOR (step_idx = 1 TO step_cnt)
    SET sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind
    IF (sched_ind > 0)
     IF ((sched->modified_ind=1))
      SET sched_modified_flag = 1
     ENDIF
    ENDIF
   ENDFOR
   IF (sched_modified_flag > 0)
    CALL cv_log_msg(cv_debug,"Scheduling information updated")
    SET proc_list->cv_proc[1].modified_ind = 1
   ELSE
    CALL cv_log_msg(cv_debug,"No changes found for scheduling information")
   ENDIF
   SET step_idx = locateval(step_idx,1,step_cnt,1,proc_list->cv_proc[1].cv_step[step_idx].
    schedule_ind)
   IF (g_trigger_notify_ind=1
    AND notify_flag > 0)
    IF ((sched->sched_phys_id=0.0))
     SELECT DISTINCT INTO "nl:"
      nd.person_id
      FROM sch_schedule ss,
       sch_list_role slr,
       sch_list_res slres,
       sch_resource sr,
       eks_notify_dest nd
      PLAN (ss
       WHERE ss.sch_event_id=g_sch_event_id)
       JOIN (slr
       WHERE slr.res_list_id=ss.res_list_id
        AND slr.role_meaning="CVPERFPROV")
       JOIN (slres
       WHERE slres.list_role_id=slr.list_role_id)
       JOIN (sr
       WHERE sr.resource_cd=slres.resource_cd)
       JOIN (nd
       WHERE nd.person_id=sr.person_id)
      DETAIL
       notify_cnt += 1, stat = alterlist(notify_list->prsnl,notify_cnt), notify_list->prsnl[
       notify_cnt].person_id = nd.person_id
      WITH nocounter
     ;end select
    ELSE
     SET notify_cnt = 1
     SET stat = alterlist(notify_list->prsnl,1)
     SET notify_list->prsnl[1].person_id = sched->sched_phys_id
    ENDIF
   ENDIF
   IF (notify_cnt > 0)
    SELECT INTO "nl:"
     FROM prsnl p
     WHERE expand(notify_idx,1,notify_cnt,p.person_id,notify_list->prsnl[notify_idx].person_id)
     DETAIL
      notify_idx = locateval(notify_idx,1,notify_cnt,p.person_id,notify_list->prsnl[notify_idx].
       person_id), notify_list->prsnl[notify_idx].username = p.username
     WITH nocounter
    ;end select
    FREE RECORD notify_request
    RECORD notify_request(
      1 msgtext = vc
      1 priority = i4
      1 typeflag = i4
      1 subject = vc
      1 msgclass = vc
      1 msgsubclass = vc
      1 location = vc
      1 username = vc
    )
    SET notify_request->priority = 50
    SET notify_request->typeflag = 0
    SET notify_request->msgclass = "APPLICATION"
    SET notify_request->msgsubclass = "CVNet"
    SET notify_request->location = "REPLY"
    SET notify_request->subject = fillstring(50," ")
    SET notify_request->msgtext = fillstring(255," ")
    DECLARE patient_name = vc WITH protect
    DECLARE procedure_name = vc WITH protect
    SELECT INTO "nl:"
     FROM person p
     WHERE (p.person_id=proc_list->cv_proc[1].person_id)
     DETAIL
      patient_name = substring(1,40,p.name_full_formatted)
     WITH nocounter
    ;end select
    SET notify_request->subject = concat(trim(patient_name)," arrived")
    SET procedure_name = uar_get_code_display(proc_list->cv_proc[1].cv_step[step_idx].task_assay_cd)
    SET notify_request->msgtext = concat(patient_name," arrived for ",procedure_name,
     " which is scheduled for ",format(sched->sched_start_dt_tm,"@SHORTDATETIME"))
    IF ((sched->sched_loc_cd > 0.0))
     SET notify_request->msgtext = concat(notify_request->msgtext," at ",trim(uar_get_code_display(
        sched->sched_loc_cd)))
    ENDIF
    IF ((sched->sched_phys_id > 0.0))
     SET notify_request->msgtext = concat(notify_request->msgtext,char(10),
      "You are scheduled to perform this procedure.")
     SET notify_request->priority = 75
    ENDIF
    FOR (notify_idx = 1 TO notify_cnt)
      SET notify_request->username = fillstring(50," ")
      SET notify_request->username = notify_list->prsnl[notify_idx].username
      EXECUTE eks_notify_message  WITH replace("REQUEST",notify_request), replace("REPLY",
       notify_reply)
    ENDFOR
   ENDIF
   FREE RECORD notify_list
   FREE RECORD notify_request
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (checkschedprefs(p_sched_flag=i2(ref),p_notify_flag=i2(ref)) =i4)
   DECLARE nprefidx = i2 WITH private, noconstant(0)
   CALL cv_log_msg(cv_debug,"CheckSchedPref called")
   CALL loadpreferences("system","","","","module",
    "cvnet","","")
   IF (textlen(trim(preferences->spreferrmsg)) > 0)
    CALL cv_log_stat(cv_audit,"CALL","F","LoadPreferences",preferences->spreferrmsg)
    CALL unloadpreferences(null)
    RETURN(1)
   ENDIF
   SET nprefidx = findpreference("scheduling")
   IF (nprefidx > 0)
    SET p_sched_flag = cnvtint(preferences->entry_qual[nprefidx].values[1].value)
    CALL cv_log_msg(cv_debug,build("p_sched_flag=",p_sched_flag))
   ELSE
    SET p_sched_flag = - (1)
    CALL cv_log_stat(cv_audit,"CALL","Z","FindPreference","scheduling")
   ENDIF
   SET nprefidx = findpreference("checkin_notify")
   IF (nprefidx > 0)
    SET p_notify_flag = cnvtint(preferences->entry_qual[nprefidx].values[1].value)
    CALL cv_log_msg(cv_debug,build("p_notify_flag=",p_notify_flag))
   ELSE
    SET p_notify_flag = - (1)
    CALL cv_log_stat(cv_audit,"CALL","Z","FindPreference","checkin_notify")
   ENDIF
   CALL unloadpreferences(null)
   CALL cv_log_msg(cv_debug,"CheckNotifyPref complete")
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (execnewsteps(dummy=i2) =null)
   IF ((reqdata->loglevel >= cv_debug))
    CALL echorecord(request,"cer_temp:cv_ord2proc_req.txt")
   ENDIF
   SET stat = alterlist(proc_list->cv_proc,1)
   SET proc_list->cv_proc[1].catalog_cd = g_catalog_cd
   SET proc_list->cv_proc[1].encntr_id = g_encntr_id
   SET proc_list->cv_proc[1].modified_ind = 1
   SET proc_list->cv_proc[1].order_id = request->order_id
   SET proc_list->cv_proc[1].order_physician_id = request->order_provider_id
   SET proc_list->cv_proc[1].person_id = request->person_id
   SET proc_list->cv_proc[1].phys_group_id = 0.0
   SET proc_list->cv_proc[1].sequence = 1
   SET proc_list->cv_proc[1].activity_subtype_cd = request->activity_subtype_cd
   SET proc_list->cv_proc[1].accession_id = request->accession_id
   SET proc_list->cv_proc[1].accession = request->accession
   SET proc_list->cv_proc[1].orig_order_dt_tm = request->orig_order_dt_tm
   FREE SET cv_new_steps_req
   RECORD cv_new_steps_req(
     1 new_steps_mode_flag = i2
   )
   EXECUTE cv_new_steps  WITH replace("REQUEST",cv_new_steps_req)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_msg(cv_error,"CV_NEW_STEPS failed")
    GO TO exit_script
   ENDIF
   SET step_cnt = size(proc_list->cv_proc[1].cv_step,5)
 END ;Subroutine
 SUBROUTINE (execsaveprocs(dummy=i2) =null)
   SET detailcnt = size(request->detaillist,5)
   IF (detailcnt=0)
    CALL cv_log_msg(cv_info,"No details in request")
   ELSE
    FOR (det_list_idx = 1 TO detailcnt)
      CASE (request->detaillist[det_list_idx].oefieldmeaning)
       OF "REASONFOREXAM":
        SET proc_list->cv_proc[1].reason_for_proc = request->detaillist[det_list_idx].
        oefielddisplayvalue
       OF "ACCESSION":
        SET proc_list->cv_proc[1].accession = request->detaillist[det_list_idx].oefielddisplayvalue
       OF "ACCESSION_ID":
        SET proc_list->cv_proc[1].accession_id = request->detaillist[det_list_idx].oefieldvalue
       OF "PRIORITY":
        SET proc_list->cv_proc[1].priority_cd = request->detaillist[det_list_idx].oefieldvalue
       OF "REQSTARTDTTM":
        SET proc_list->cv_proc[1].request_dt_tm = request->detaillist[det_list_idx].oefielddttmvalue
       OF "REFERPHYS":
        SET proc_list->cv_proc[1].refer_physician_id = request->detaillist[det_list_idx].oefieldvalue
       OF "SCHORDPHYS":
        IF ((request->detaillist[det_list_idx].oefieldvalue > 0.0))
         SET proc_list->cv_proc[1].order_physician_id = request->detaillist[det_list_idx].
         oefieldvalue
        ENDIF
       OF "PHYSICIANGROUP":
        SET proc_list->cv_proc[1].phys_group_id = translatephysgroup(request->detaillist[det_list_idx
         ].oefieldvalue)
       OF "REQEDPHYS":
        SET proc_list->cv_proc[1].prim_physician_id = request->detaillist[det_list_idx].oefieldvalue
       ELSE
        CALL cv_log_msg(cv_debug,concat("Unknown detail list field type :",request->detaillist[
          det_list_idx].oefieldmeaning))
      ENDCASE
    ENDFOR
    SET proc_list->cv_proc[1].modified_ind = 1
   ENDIF
   CALL populateserviceresourcecodeinproclist(0)
   SET step_cnt = size(proc_list->cv_proc[1].cv_step,5)
   FOR (step_idx = 1 TO step_cnt)
    SET sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind
    IF (sched_ind > 0)
     IF ((sched->sched_start_dt_tm=0.0)
      AND (proc_list->cv_proc[1].request_dt_tm > 0.0))
      SET sched->sched_start_dt_tm = proc_list->cv_proc[1].request_dt_tm
      SET sched->modified_ind = 1
      SET proc_list->cv_proc[1].cv_step[step_idx].modified_ind = 1
     ENDIF
    ENDIF
   ENDFOR
   SET step_idx = locateval(step_idx,1,step_cnt,1,proc_list->cv_proc[1].cv_step[step_idx].
    schedule_ind)
   IF (step_idx > 0)
    SET proc_list->cv_proc[1].action_dt_tm = sched->sched_start_dt_tm
   ELSE
    SET proc_list->cv_proc[1].action_dt_tm = proc_list->cv_proc[1].request_dt_tm
   ENDIF
   IF ((proc_list->cv_proc[1].action_dt_tm=0.0))
    SET proc_list->cv_proc[1].action_dt_tm = time_now
   ENDIF
   SET proc_list->cv_proc[1].proc_status_cd = c_proc_status_ordered
   IF ((reqdata->loglevel >= cv_debug))
    CALL echorecord(proc_list,"cer_temp:cv_ord2proc_proc_bs.txt")
   ENDIF
   SET proc_list->calling_process_name = request->calling_process_name
   SET proc_list->cv_proc[1].future_order_ind = request->future_order_ind
   EXECUTE cv_save_procs  WITH replace("REQUEST",proc_list)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_msg(cv_error,"CV_SAVE_PROCS failed")
    GO TO exit_script
   ENDIF
   IF ((reqdata->loglevel >= cv_debug))
    CALL echorecord(proc_list,"cer_temp:cv_ord2proc_proc_as.txt")
   ENDIF
 END ;Subroutine
 SUBROUTINE populateserviceresourcecodeinproclist(null)
   DECLARE service_resource_list_cnt = i2 WITH protect, noconstant(0)
   DECLARE sched_ind = i2 WITH protect, noconstant(0)
   SET step_cnt = size(proc_list->cv_proc[1].cv_step,5)
   SET service_resource_list_cnt = size(request->service_resource_list,5)
   FOR (step_idx = 1 TO step_cnt)
    SET sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind
    IF (sched_ind > 0)
     IF (g_loc_from_sched_ind=0)
      FOR (req_list_idx = 1 TO service_resource_list_cnt)
        IF ((proc_list->cv_proc[1].cv_step[step_idx].task_assay_cd=request->service_resource_list[
        req_list_idx].task_assay_cd))
         SET proc_list->cv_proc[1].cv_step[step_idx].cv_step_sched[1].sched_loc_cd = request->
         service_resource_list[req_list_idx].service_resource_cd
         SET proc_list->cv_proc[1].cv_step[step_idx].cv_step_sched[1].modified_ind = 1
         SET proc_list->cv_proc[1].modified_ind = 1
         CALL cv_log_msg(cv_debug,"Setting sched_loc_cd with service resource")
        ENDIF
      ENDFOR
     ELSE
      CALL cv_log_msg(cv_debug,
       "Not setting service resource because resource already set from scheduling")
     ENDIF
    ELSE
     CALL cv_log_msg(cv_debug,"Not setting sched_loc_cd because this is not a schedulable step")
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE (execaddim(dummy=i2) =null)
   RECORD cv_siuid_req(
     1 qual[1]
       2 order_id = f8
       2 exam_room_cd = f8
       2 entity_name = c32
       2 entity_id = f8
     1 no_room_chk_ind = i2
   )
   SET cv_siuid_req->order_id = proc_list->cv_proc[1].order_id
   SET cv_siuid_req->qual[1].entity_name = "CV_PROC"
   SET cv_siuid_req->qual[1].entity_id = proc_list->cv_proc[1].cv_proc_id
   SET cv_siuid_req->no_room_chk_ind = 1
   EXECUTE rad_add_im_studys  WITH replace("REQUEST",cv_siuid_req), replace("REPLY",cv_siuid_rep)
 END ;Subroutine
 SUBROUTINE (execfetchprocs(dummy=i2) =i4)
   FREE RECORD fetchproc
   RECORD fetchproc(
     1 orders[*]
       2 order_id = f8
   )
   SET stat = alterlist(fetchproc->orders,1)
   SET fetchproc->orders[1].order_id = request->order_id
   EXECUTE cv_fetch_procs  WITH replace("REQUEST",fetchproc), replace("REPLY",proc_list)
   IF ((proc_list->status_data.status != "S"))
    CALL cv_log_msg(cv_error,"CV_FETCH_PROCS failed")
    RETURN(1)
   ENDIF
   SET step_cnt = size(proc_list->cv_proc[1].cv_step,5)
   SET g_group_event_id = proc_list->cv_proc[1].group_event_id
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (updprocrec(dummy=i2) =i4)
   SET detailcnt = size(request->detaillist,5)
   IF (detailcnt > 0)
    FOR (det_list_idx = 1 TO detailcnt)
      IF ((request->detaillist[det_list_idx].modifiedind=1))
       CASE (request->detaillist[det_list_idx].oefieldmeaning)
        OF "REASONFOREXAM":
         SET proc_list->cv_proc[1].reason_for_proc = request->detaillist[det_list_idx].
         oefielddisplayvalue
        OF "ACCESSION":
         SET proc_list->cv_proc[1].accession = request->detaillist[det_list_idx].oefielddisplayvalue
        OF "ACCESSION_ID":
         SET proc_list->cv_proc[1].accession_id = request->detaillist[det_list_idx].oefieldvalue
        OF "PRIORITY":
         SET proc_list->cv_proc[1].priority_cd = request->detaillist[det_list_idx].oefieldvalue
        OF "REQSTARTDTTM":
         SET proc_list->cv_proc[1].request_dt_tm = request->detaillist[det_list_idx].oefielddttmvalue
         SET step_cnt = size(proc_list->cv_proc[1].cv_step,5)
         FOR (step_idx = 1 TO step_cnt)
          SET sched_ind = proc_list->cv_proc[1].cv_step[step_idx].schedule_ind
          IF (sched_ind > 0)
           SET proc_list->cv_proc[1].cv_step[step_idx].cv_step_sched[1].sched_start_dt_tm = request->
           detaillist[det_list_idx].oefielddttmvalue
           SET proc_list->cv_proc[1].cv_step[step_idx].cv_step_sched[1].modified_ind = 1
           CALL cv_log_msg(cv_debug,concat("Setting sched_start_dt_tm from REQSTARTDTTM for step:",
             step_idx))
          ELSE
           CALL cv_log_msg(cv_audit,concat(
             "Not setting sched_start_dt_tm because step is not schedulable",step_idx))
          ENDIF
         ENDFOR
         IF ((proc_list->cv_proc[1].cv_step[1].perf_start_dt_tm <= 0.0))
          SET proc_list->cv_proc[1].action_dt_tm = request->detaillist[det_list_idx].oefielddttmvalue
         ENDIF
        OF "REFERPHYS":
         SET proc_list->cv_proc[1].refer_physician_id = request->detaillist[det_list_idx].
         oefieldvalue
        OF "SCHORDPHYS":
         IF ((request->detaillist[det_list_idx].oefieldvalue > 0.0))
          SET proc_list->cv_proc[1].order_physician_id = request->detaillist[det_list_idx].
          oefieldvalue
         ENDIF
        OF "PHYSICIANGROUP":
         SET proc_list->cv_proc[1].phys_group_id = translatephysgroup(request->detaillist[
          det_list_idx].oefieldvalue)
         SET g_group_od_flag = e_od_flag_yes
        OF "REQEDPHYS":
         SET proc_list->cv_proc[1].prim_physician_id = request->detaillist[det_list_idx].oefieldvalue
         SET g_prim_od_flag = e_od_flag_yes
        ELSE
         CALL cv_log_msg(cv_debug,concat("Unknown detail list field type :",request->detaillist[
           det_list_idx].oefieldmeaning))
       ENDCASE
       SET proc_list->cv_proc[1].modified_ind = 1
      ENDIF
    ENDFOR
    IF (((g_prim_od_flag=1) OR (g_group_od_flag=1)) )
     CALL cv_log_msg(cv_debug,"Checking assignments")
     CALL checkassign(proc_list->cv_proc[1].order_id,g_prim_od_flag,g_group_od_flag,proc_list->
      cv_proc[1].prim_physician_id,proc_list->cv_proc[1].phys_group_id)
     IF (g_prim_od_flag=e_od_flag_clear)
      CALL cv_log_msg(cv_info,"Clearing prim_physician_id")
      SET proc_list->cv_proc[1].prim_physician_id = 0.0
     ENDIF
     IF (g_group_od_flag=e_od_flag_clear)
      CALL cv_log_msg(cv_info,"Clearing phys_groupn_id")
      SET proc_list->cv_proc[1].phys_group_id = 0.0
     ENDIF
    ENDIF
   ELSE
    CALL cv_log_msg(cv_debug,"No order details modified")
   ENDIF
   CALL populateserviceresourcecodeinproclist(0)
   IF ((proc_list->cv_proc[1].modified_ind=1))
    SET proc_list->calling_process_name = request->calling_process_name
    EXECUTE cv_save_procs  WITH replace("REQUEST",proc_list)
    IF ((reply->status_data.status != "S"))
     CALL cv_log_stat(cv_warning,"SCRIPT",reply->status_data.status,"CV_SAVE_PROCS","")
     RETURN(2)
    ENDIF
   ELSE
    CALL cv_log_msg(cv_debug,"No cv_proc related details modified")
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (updstepstatus(dummy=i2) =i4)
   SET step_cnt = size(proc_list->cv_proc[1].cv_step,5)
   IF (step_cnt > 0)
    FOR (step_idx = 1 TO step_cnt)
     SET step_stat = proc_list->cv_proc[1].cv_step[step_idx].step_status_cd
     CASE (step_stat)
      OF step_stat_discontinued:
      OF step_stat_cancelled:
       CALL cv_log_msg(cv_info,"Keep current step status")
      OF step_stat_completed:
       IF (((action_type_mean="DISCONTINUE") OR (action_type_mean="CANCEL")) )
        SET proc_list->cv_proc[1].cv_step[step_idx].step_status_cd = step_stat_discontinued
        IF ((proc_list->cv_proc[1].cv_step[step_idx].cv_step_id > 1.0))
         SET proc_list->cv_proc[1].cv_step[step_idx].modified_ind = 1
        ENDIF
        CALL cv_log_msg(cv_info,"Discontinue the Completed steps")
       ELSE
        CALL cv_log_msg(cv_info,"Keep current step status")
       ENDIF
      OF step_stat_inprocess:
      OF step_stat_unsigned:
      OF step_stat_saved:
       SET proc_list->cv_proc[1].cv_step[step_idx].step_status_cd = step_stat_discontinued
       IF ((proc_list->cv_proc[1].cv_step[step_idx].cv_step_id > 1.0))
        SET proc_list->cv_proc[1].cv_step[step_idx].modified_ind = 1
       ENDIF
       CALL addtostepprsnl(uar_get_code_by("MEANING",step_reltn_cs,"ACTPRSNL"),reqinfo->updt_id)
      ELSE
       SET proc_list->cv_proc[1].cv_step[step_idx].step_status_cd = step_stat_cancelled
       IF ((proc_list->cv_proc[1].cv_step[step_idx].cv_step_id > 1.0))
        SET proc_list->cv_proc[1].cv_step[step_idx].modified_ind = 1
       ENDIF
       CALL addtostepprsnl(uar_get_code_by("MEANING",step_reltn_cs,"ACTPRSNL"),reqinfo->updt_id)
     ENDCASE
    ENDFOR
   ENDIF
   SET proc_list->calling_process_name = request->calling_process_name
   EXECUTE cv_save_procs  WITH replace("REQUEST",proc_list)
   IF ((reply->status_data.status != "S"))
    CALL cv_log_msg(cv_error,"CV_SAVE_PROCS failed")
    RETURN(2)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (addtostepprsnl(step_reltn_cd=f8,prsnl_id=f8) =null)
   SET step_prsnl_size += 1
   SET stat = alterlist(proc_list->cv_step_prsnl,step_prsnl_size)
   SET proc_list->cv_step_prsnl[step_prsnl_size].action_type_cd = proc_list->cv_proc[1].cv_step[
   step_idx].step_status_cd
   SET proc_list->cv_step_prsnl[step_prsnl_size].action_dt_tm = time_now
   SET proc_list->cv_step_prsnl[step_prsnl_size].cv_step_id = proc_list->cv_proc[1].cv_step[step_idx]
   .cv_step_id
   SET proc_list->cv_step_prsnl[step_prsnl_size].step_prsnl_id = prsnl_id
   SET proc_list->cv_step_prsnl[step_prsnl_size].step_relation_cd = step_reltn_cd
 END ;Subroutine
 SUBROUTINE (checkassign(p_order_id=f8,r_prim_od_flag=i2(ref),r_group_od_flag=i2(ref),
  p_prim_physician_id=f8,p_phys_group_id=f8) =null)
   CALL cv_log_msg(cv_debug,build("CheckAssign(",p_order_id,",",r_prim_od_flag,",",
     r_group_od_flag,",",p_prim_physician_id,",",p_phys_group_id,
     ")"))
   IF (((r_prim_od_flag=e_od_flag_yes
    AND r_group_od_flag=e_od_flag_yes) OR (((p_prim_physician_id=0.0) OR (p_phys_group_id=0.0)) )) )
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM order_detail od
    WHERE od.order_id=p_order_id
     AND ((r_prim_od_flag=e_od_flag_no
     AND od.oe_field_meaning_id=c_oef_meaning_reqedphys) OR (r_group_od_flag=e_od_flag_no
     AND od.oe_field_meaning_id=c_oef_meaning_physiciangroup))
    ORDER BY od.oe_field_meaning_id, od.action_sequence DESC
    HEAD od.oe_field_meaning_id
     IF (od.oe_field_meaning_id=c_oef_meaning_reqedphys
      AND od.oe_field_value > 0.0)
      r_prim_od_flag = e_od_flag_yes
     ELSEIF (od.oe_field_meaning_id=c_oef_meaning_physiciangroup
      AND od.oe_field_value > 0.0)
      r_group_od_flag = e_od_flag_yes
     ENDIF
    DETAIL
     col 0
    WITH nocounter
   ;end select
   IF (r_prim_od_flag=r_group_od_flag)
    RETURN
   ENDIF
   SELECT INTO "nl:"
    FROM prsnl_group_reltn pgr
    WHERE pgr.person_id=p_prim_physician_id
     AND ((pgr.prsnl_group_id+ 0.0)=p_phys_group_id)
     AND pgr.active_ind=1
     AND pgr.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF (r_prim_od_flag=e_od_flag_no)
     SET r_prim_od_flag = e_od_flag_clear
    ELSE
     SET r_group_od_flag = e_od_flag_clear
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE (translatephysgroup(p_code_value=f8) =f8)
   IF (p_code_value <= 0.0)
    RETURN(0.0)
   ENDIF
   DECLARE l_prsnl_group_id = f8 WITH protect
   SELECT INTO "nl:"
    FROM code_value_alias cva
    WHERE cva.code_value=p_code_value
     AND cva.contributor_source_cd=c_contrib_source_powerchart
    DETAIL
     l_prsnl_group_id = cnvtreal(cva.alias)
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_stat(cv_audit,"SELECT","Z","CODE_VALUE_ALIAS",build("CODE_VALUE=",request->
      detaillist[det_list_idx].oefieldvalue))
   ENDIF
   IF (l_prsnl_group_id < 0.0)
    CALL cv_log_msg(cv_audit,build("cnvtreal of phys_group alias:",l_prsnl_group_id))
    SET l_prsnl_group_id = 0.0
   ENDIF
   RETURN(l_prsnl_group_id)
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  CALL cv_log_msg(cv_error,"CV_ORDER_TO_PROC failed")
  CALL echorecord(reply)
  SET reqinfo->commit_ind = 0
 ELSE
  CALL cv_log_msg(cv_info,"CV_ORDER_TO_PROC successful")
  SET reqinfo->commit_ind = 1
 ENDIF
 IF ((reqdata->loglevel >= cv_debug))
  CALL echorecord(reply,"cer_temp:cv_ord2proc_rep.txt")
 ENDIF
 CALL cv_log_msg_post("035 05/24/22  TK095466")
END GO
