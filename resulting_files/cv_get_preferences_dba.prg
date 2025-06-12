CREATE PROGRAM cv_get_preferences:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 entries[*]
      2 name = vc
      2 values[*]
        3 value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE sdebug = vc WITH constant(request->debug)
 DECLARE lpreftrans_customsearch = i4 WITH constant(18)
 DECLARE sbasedn = vc WITH noconstant("")
 DECLARE lprefstat = i4 WITH noconstant(0)
 DECLARE hprefdir = i4 WITH noconstant(0)
 DECLARE lentrycnt = i4 WITH noconstant(0)
 DECLARE lentry = i4 WITH noconstant(0)
 DECLARE hentry = i4 WITH noconstant(0)
 DECLARE lattrcnt = i4 WITH noconstant(0)
 DECLARE lattr = i4 WITH noconstant(0)
 DECLARE hattr = i4 WITH noconstant(0)
 DECLARE sattr = c255 WITH noconstant("")
 DECLARE vcattr = vc WITH noconstant("")
 DECLARE lvaluecnt = i4 WITH noconstant(0)
 DECLARE lvalue = i4 WITH noconstant(0)
 DECLARE hvalue = i4 WITH noconstant(0)
 DECLARE svalue = c255 WITH noconstant("")
 DECLARE vcvalue = vc WITH noconstant("")
 DECLARE npreferr = i2 WITH noconstant(0)
 DECLARE spreferrmsg = c255 WITH noconstant("")
 DECLARE lrepcnt = i4 WITH noconstant(0)
 DECLARE lnumvalue = i4 WITH noconstant(0)
 DECLARE llen = i4 WITH noconstant(255)
 EXECUTE prefrtl
 SET hprefdir = uar_prefcreateinstance(lpreftrans_customsearch)
 CALL echo(hprefdir)
 IF (sdebug="1")
  CALL echo(build("PrefCreateInstance Handle =",hprefdir))
 ENDIF
 IF (hprefdir=0)
  GO TO error
 ENDIF
 SET groupsize = size(request->groups,5)
 FOR (groupcnt = 1 TO groupsize)
  IF (groupcnt > 1)
   SET sbasedn = concat(",",trim(sbasedn))
  ENDIF
  SET sbasedn = concat(build("prefgroup=",request->groups[groupcnt].name),trim(sbasedn))
 ENDFOR
 IF (size(trim(sbasedn)) > 0)
  SET sbasedn = concat(trim(sbasedn),",")
 ENDIF
 SET sbasedn = concat(trim(sbasedn),build("prefgroup=",request->section_id,",prefgroup=",request->
   section,",prefgroup=",
   request->context_id,",prefcontext=",request->context,",prefroot=prefroot"))
 IF (sdebug="1")
  CALL echo(concat("sBaseDN = ",sbasedn))
 ENDIF
 IF (uar_prefsetbasedn(hprefdir,nullterm(sbasedn))=false)
  GO TO error
 ENDIF
 IF (uar_prefperform(hprefdir)=false)
  GO TO error
 ENDIF
 IF (uar_prefgetentrycount(hprefdir,lentrycnt)=false)
  GO TO error
 ENDIF
 FOR (lentry = 0 TO (lentrycnt - 1))
   SET hentry = uar_prefgetentry(hprefdir,lentry)
   IF (hentry=0)
    GO TO error
   ENDIF
   IF (uar_prefgetentryattrcount(hentry,lattrcnt)=false)
    GO TO error
   ENDIF
   FOR (lattr = 0 TO (lattrcnt - 1))
     SET hattr = uar_prefgetentryattr(hentry,lattr)
     IF (hattr=0)
      GO TO error
     ENDIF
     SET llen = 255
     IF (uar_prefgetattrname(hattr,sattr,llen)=false)
      GO TO error
     ENDIF
     IF (size(trim(sattr,3)) > 0
      AND llen > 0)
      SET vcattr = substring(1,(llen - 1),sattr)
     ELSE
      SET vcattr = ""
     ENDIF
     IF (sdebug="1")
      CALL echo(concat("Attribute Name is ",vcattr))
     ENDIF
     IF (uar_prefgetattrvalcount(hattr,lvaluecnt)=false)
      GO TO error
     ENDIF
     FOR (lvalue = 0 TO (lvaluecnt - 1))
       SET llen = 255
       IF (uar_prefgetattrval(hattr,svalue,llen,lvalue)=false)
        GO TO error
       ENDIF
       IF (size(trim(svalue,3)) > 0
        AND llen > 0)
        SET vcvalue = substring(1,(llen - 1),svalue)
       ELSE
        SET vcvalue = ""
       ENDIF
       IF (sdebug="1")
        CALL echo(concat("AttrVal is ",vcvalue))
        CALL cv_log_msg(cv_debug,build2("AttrVal is ",vcvalue))
       ENDIF
       IF (vcattr="prefentry")
        SET lrepcnt += 1
        SET lnumvalue = 0
        SET stat = alterlist(reply->entries,lrepcnt)
        SET reply->entries[lrepcnt].name = vcvalue
       ENDIF
       IF (vcattr="prefvalue")
        SET lnumvalue += 1
        SET stat = alterlist(reply->entries[lrepcnt].values,lnumvalue)
        SET reply->entries[lrepcnt].values[lnumvalue].value = vcvalue
       ENDIF
     ENDFOR
     SET stat = uar_prefdestroyattr(hattr)
   ENDFOR
   SET stat = uar_prefdestroyentry(hentry)
 ENDFOR
 SET stat = uar_prefdestroyinstance(hprefdir)
 SET reply->status_data.status = "S"
 GO TO endscript
#error
 SET npreferr = uar_prefgetlasterror()
 SET lprefstat = uar_prefformatmessage(spreferrmsg,101)
 CALL echo(build("PrefCreateInstance FAILED, Error =",npreferr))
 CALL echo(build("PrefFormatMessage Status =",lprefstat,", Message =",spreferrmsg))
 CALL cv_log_msg(cv_error,build2("PrefCreateInstance FAILED, Error =",npreferr))
 SET reply->status_data.status = "F"
#endscript
 IF (sdebug="1")
  CALL echorecord(reply)
 ENDIF
END GO
