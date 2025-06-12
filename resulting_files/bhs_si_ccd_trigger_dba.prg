CREATE PROGRAM bhs_si_ccd_trigger:dba
 PROMPT
  "Encounter" = 0,
  "Template:" = "",
  "person_id" = 0,
  "encntr_id" = 0,
  "Output to File/Printer/MINE" = "MINE"
  WITH lstencounter, prompt1, person_id,
  encntr_id, outdev
 IF (validate(reply))
  SET stat = initrec(reply)
 ELSE
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 DECLARE submitrequests(null) = null
 DECLARE exitsubmit(hmsg=i4,hreq=i4,hrep=i4) = null
 DECLARE getparameter(textstring=vc,keyword=vc,delimit=c1) = f8
 DECLARE getvalue(startpos=i4(ref),textstring=vc,delimit=c1) = null
 DECLARE write_log(logfile=vc,loglevel=vc,lohmessage=vc) = null
 DECLARE logerror(person_id=f8,encntr_id=f8,contributor_system_cd=f8,sstatus=vc,serrortext=vc) = null
 FREE RECORD encounters
 RECORD encounters(
   1 qual[*]
     2 encntr_id = f8
 )
 FREE RECORD qualified_encntrs
 RECORD qualified_encntrs(
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 contributor_system_cd = f8
 )
 DECLARE submit_failed = i2 WITH protect, noconstant(0)
 DECLARE beg_date_time = dq8 WITH constant(cnvtdatetime(curdate,0000))
 DECLARE end_date_time = dq8 WITH constant(cnvtdatetime(curdate,235959))
 DECLARE cur_date_fomatted = vc WITH constant(datetimezoneformat(cnvtdatetime(curdate,curtime3),
   curtimezoneapp,"DD-MM-YYYY-HH-mm-ss"))
 DECLARE organization_id = f8 WITH protect, noconstant(0.0)
 DECLARE contributor_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE template_id = f8 WITH protect, noconstant(0.0)
 DECLARE discharge_days = i4 WITH protect, noconstant(0)
 DECLARE lookback_days = i4 WITH protect, noconstant(0)
 DECLARE archive_ind = i2 WITH protect, noconstant(0)
 DECLARE phr_info_flag = i2 WITH protect, noconstant(0)
 DECLARE text = c100 WITH protect, noconstant(" ")
 DECLARE endstring = i2 WITH protect, noconstant(0)
 DECLARE dccdconsentcd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002565,"YES"))
 DECLARE user_defined_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",355,"USERDEFINED"))
 DECLARE hie_consent_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",356,"HIECONSENT"))
 DECLARE lab_institute_encntr_type_cd = f8 WITH protect, constant(uar_get_code_by("LABORINSTPT",71,
   "DISPLAYKEY"))
 DECLARE history_encntr_type_cd = f8 WITH protect, constant(uar_get_code_by("HISTORY",71,"DISPLAYKEY"
   ))
 DECLARE outreach_lab_encntr_type_cd = f8 WITH protect, constant(uar_get_code_by("OUTREACHLAB",71,
   "DISPLAYKEY"))
 DECLARE yes_value_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",20322,"YES"))
 DECLARE slogfile = vc WITH protect, constant(build("cer_temp:ccd_ops_job_",cur_date_fomatted,".out")
  )
 SET template_id = getparameter( $PROMPT1,"T:",";")
 CALL write_log(slogfile,"DEBUG",build("fsi_ccd_trigger::template_id= ",template_id))
 SELECT INTO "nl"
  t.template_id
  FROM cr_report_template t
  WHERE t.template_id=template_id
 ;end select
 IF (curqual > 0
  AND template_id != 0)
  CALL write_log(slogfile,"DEBUG",build("Template id: ",template_id))
 ELSE
  CALL write_log(slogfile,"ERROR",build("Invalid template id: ",template_id,
    " No further qualification."))
  SET reply->status_data.status = "A"
  GO TO exit_script
 ENDIF
 SET lookback_days = getparameter( $PROMPT1,"L:",";")
 CALL write_log(slogfile,"DEBUG",build("fsi_ccd_trigger::lookback_days= ",lookback_days))
 SET discharge_days = getparameter( $PROMPT1,"D:",";")
 CALL write_log(slogfile,"DEBUG",build("fsi_ccd_trigger::discharge_days= ",discharge_days))
 IF (lookback_days < discharge_days)
  CALL write_log(slogfile,"ERROR","DISCHG_DAYS has to be smaller then LOOKBACK_DAYS.")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 DECLARE beg_qualify_date = dq8 WITH constant(datetimeadd(beg_date_time,(lookback_days * - (1))))
 CALL write_log(slogfile,"DEBUG",build("fsi_ccd_trigger::beg_qualify_date= ",format(beg_qualify_date,
    "mm/dd/yy;;d")))
 DECLARE end_qualify_date = dq8 WITH constant(datetimeadd(end_date_time,(discharge_days * - (1))))
 CALL write_log(slogfile,"DEBUG",build("fsi_ccd_trigger::end_qualify_date= ",format(end_qualify_date,
    "mm/dd/yy;;d")))
 SET phr_info_flag = getparameter( $PROMPT1,"PI:",";")
 CALL write_log(slogfile,"DEBUG",build("fsi_ccd_trigger::phr_info_flag= ",phr_info_flag))
 IF (phr_info_flag=1)
  SET contributor_system_cd = getparameter( $PROMPT1,"C:",";")
  CALL write_log(slogfile,"DEBUG",build("fsi_ccd_trigger::contributor_system_cd= ",
    contributor_system_cd))
  SELECT INTO "nl:"
   cs.contributor_system_cd
   FROM contributor_system cs
   WHERE cs.contributor_system_cd=contributor_system_cd
  ;end select
  IF (curqual > 0)
   CALL write_log(slogfile,"DEBUG",build("contributor_system_cd: ",contributor_system_cd))
  ELSE
   CALL write_log(slogfile,"ERROR",build("Invalid contributor_system_cd: ",contributor_system_cd))
   SET reply->status_data.status = "C"
   GO TO exit_script
  ENDIF
  CALL write_log(slogfile,"DEBUG","Checking for Encounter Tables.")
  SET stat = alterlist(qualified_encntrs->qual,1)
  SET qualified_encntrs->qual[1].person_id =  $PERSON_ID
  IF (( $ENCNTR_ID > 0))
   SET qualified_encntrs->qual[1].encntr_id =  $ENCNTR_ID
  ENDIF
  SET qualified_encntrs->qual[1].contributor_system_cd = contributor_system_cd
  SET cnt = 1
  DECLARE count = i4
 ENDIF
 CALL write_log(slogfile,"DEBUG",build("Encounters from encounter table: ",size(qualified_encntrs->
    qual,5)))
 SET qualifiedencntrs = size(qualified_encntrs->qual,5)
 CALL echorecord(qualified_encntrs)
 IF (qualifiedencntrs > 0)
  CALL echo("MADE IT HERE")
  SET archive_ind = getparameter( $PROMPT1,"A:",";")
  CALL write_log(slogfile,"DEBUG",build("Archive_ind: ",archive_ind))
  CALL write_log(slogfile,"DEBUG",build("Encounters qualified for processing reports: ",
    qualifiedencntrs))
  CALL submitrequests(null)
 ELSE
  CALL write_log(slogfile,"ERROR","No encounters qualified for processing reports")
  SET reply->status_data.status = "G "
  GO TO exit_script
 ENDIF
 SUBROUTINE getparameter(textstring,keyword,delimit)
   DECLARE value = f8 WITH protect, noconstant(0)
   DECLARE startpos = i4 WITH public, noconstant(1)
   SET stringsize = size(textstring,1)
   SET keysize = size(trim(keyword),1)
   SET text = ""
   SET endstring = 0
   SET pos = startpos
   SET foundkey = 0
   WHILE (pos <= stringsize)
    IF (substring(pos,keysize,textstring)=keyword)
     SET foundkey = 1
     SET startpos = (pos+ keysize)
     SET pos = stringsize
    ENDIF
    SET pos = (pos+ 1)
   ENDWHILE
   IF (foundkey=1)
    SET pos = startpos
    WHILE (pos <= stringsize)
      IF (pos=stringsize)
       SET endstring = 1
      ENDIF
      IF (substring(pos,1,textstring)=delimit)
       SET text = substring(startpos,(pos - startpos),textstring)
       SET value = cnvtreal(trim(text))
       SET pos = stringsize
      ELSEIF (endstring=1)
       SET text = substring(startpos,((pos - startpos)+ 1),textstring)
       SET value = cnvtreal(trim(text))
      ENDIF
      SET pos = (pos+ 1)
    ENDWHILE
   ENDIF
   RETURN(value)
 END ;Subroutine
 SUBROUTINE submitrequests(null)
   CALL echo("sbr SubmitRequest")
   DECLARE hmsg = i4 WITH protect, noconstant(0)
   DECLARE hreq = i4 WITH private, noconstant(0)
   DECLARE hrep = i4 WITH private, noconstant(0)
   DECLARE hstatusdata = i4 WITH protect, noconstant(0)
   DECLARE nsrvstat = i2 WITH protect, noconstant(0)
   DECLARE hitem = i4 WITH protect, noconstant(0)
   DECLARE sstatus = c1 WITH protect, noconstant(" ")
   DECLARE soperationname = c25 WITH protect, noconstant(fillstring(25," "))
   DECLARE soperationstatus = c1 WITH protect, noconstant(" ")
   DECLARE stargetobjectname = c25 WITH protect, noconstant(fillstring(25," "))
   DECLARE stargetobjectvalue = vc WITH protect, noconstant(" ")
   DECLARE serrortext = vc WITH protect, noconstant("")
   IF (validate(recdate))
    SET stat = initrec(recdate)
   ELSE
    RECORD recdate(
      1 datetime = dq8
    )
   ENDIF
   SET hmsg = uar_srvselectmessage(1370051)
   IF (hmsg=0)
    CALL echo("STATUS = D")
    CALL write_log(slogfile,"ERROR","Unable to obtain message for TDB 1370051.")
    SET reply->status_data.status = "D "
    GO TO exit_script
   ENDIF
   SET hreq = uar_srvcreaterequest(hmsg)
   IF (hreq=0)
    CALL write_log(slogfile,"ERROR","Unable to obtain request for TDB 1370051.")
    SET reply->status_data.status = "E "
    GO TO exit_script
   ENDIF
   SET hrep = uar_srvcreatereply(hmsg)
   IF (hrep=0)
    CALL write_log(slogfile,"ERROR","Unable to obtain reply for TDB 1370051.")
    SET reply->status_data.status = "Y "
    GO TO exit_script
   ENDIF
   SET recdate->datetime = cnvtdatetime(0,0)
   SET encntrnbr = size(qualified_encntrs->qual,5)
   FOR (i = 1 TO encntrnbr)
     SET nsrvstat = uar_srvsetdouble(hreq,"person_id",qualified_encntrs->qual[i].person_id)
     SET nsrvstat = uar_srvsetdouble(hreq,"encntr_id",qualified_encntrs->qual[i].encntr_id)
     SET nsrvstat = uar_srvsetdouble(hreq,"report_template_id",template_id)
     SET nsrvstat = uar_srvsetshort(hreq,"device_id",0)
     SET nsrvstat = uar_srvsetdate2(hreq,"begin_qual_date",recdate)
     SET nsrvstat = uar_srvsetdate2(hreq,"end_qual_date",recdate)
     SET nsrvstat = uar_srvsetshort(hreq,"archive_ind",archive_ind)
     SET nsrvstat = uar_srvsetdouble(hreq,"contributor_system_id",qualified_encntrs->qual[i].
      contributor_system_cd)
     SET nsrvstat = uar_srvsetshort(hreq,"authorization_mode",0)
     SET nsrvstat = uar_srvsetshort(hreq,"provider_patient_reltn_cd",0)
     CALL write_log(slogfile,"DEBUG",build("Calling for person_id:",qualified_encntrs->qual[i].
       person_id," encntr_id: ",qualified_encntrs->qual[i].encntr_id))
     CALL write_log(slogfile,"DEBUG",build("contributor_system_cd:",qualified_encntrs->qual[i].
       contributor_system_cd))
     SET nsrvstat = uar_srvexecute(hmsg,hreq,hrep)
     CALL echo("nSrvStat")
     CALL echo(nsrvstat)
     CALL write_log(slogfile,"DEBUG",build("nSrvStat: ",nsrvstat))
     IF (nsrvstat=0)
      SET hstatusdata = uar_srvgetstruct(hrep,"status_data")
      SET sstatus = uar_srvgetstringptr(hstatusdata,"status")
      CALL write_log(slogfile,"DEBUG",build("sStatus: ",sstatus))
      CALL echo(build2("nSrvStat = 0"))
      CALL echo(build2("STATUS = ",sstatus))
      IF (sstatus="S")
       DELETE  FROM si_custom_cdg_log cdglog
        WHERE (cdglog.encntr_id=qualified_encntrs->qual[i].encntr_id)
         AND (cdglog.person_id=qualified_encntrs->qual[i].person_id)
       ;end delete
      ELSEIF (sstatus="Z")
       SET serrortext = "No Clinical Information Qualified."
       IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
        SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
        SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
        SET serrortext = concat(serrortext," TargetObjectValue:",substring(1,400,stargetobjectvalue),
         ".")
       ENDIF
      ELSE
       SET serrortext = "Transaction Failed."
       CALL echo(serrortext)
       IF (uar_srvgetitemcount(hstatusdata,"subeventstatus") > 0)
        SET hitem = uar_srvgetitem(hstatusdata,"subeventstatus",0)
        SET stargetobjectvalue = uar_srvgetstringptr(hitem,"TargetObjectValue")
        SET serrortext = concat(serrortext," TargetObjectValue:",substring(1,400,stargetobjectvalue),
         ".")
       ENDIF
       CALL echo("set submit_failed to 1")
       SET submit_failed = 1
       CALL logerror(qualified_encntrs->qual[i].person_id,qualified_encntrs->qual[i].encntr_id,
        qualified_encntrs->qual[i].contributor_system_cd,sstatus,serrortext)
      ENDIF
     ELSE
      SET serrortext = "SrvExecute Failed.Either Server 388 is not running or invalid request."
      CALL write_log(slogfile,"DEBUG","SrvExecute Failed.")
      CALL echo("set submit_failed to 1")
      SET submit_failed = 1
      CALL logerror(qualified_encntrs->qual[i].person_id,qualified_encntrs->qual[i].encntr_id,
       qualified_encntrs->qual[i].contributor_system_cd,"F",serrortext)
     ENDIF
   ENDFOR
   CALL echo(build2("submitfailed: ",submit_failed))
   CALL echo(build2("call exitsubmit: ",hmsg,hreq,hrep))
   CALL exitsubmit(hmsg,hreq,hrep)
 END ;Subroutine
 SUBROUTINE logerror(person_id,encntr_id,contributor_system_cd,sstatus,serrortext)
   SET si_custom_cdg_log_id = 0.0
   CALL write_log(slogfile,"ERROR",sstatus)
   CALL write_log(slogfile,"ERROR","Transaction Failed. Check si_custom_cdg_log table.")
   CALL write_log(slogfile,"ERROR",substring(1,100,serrortext))
   UPDATE  FROM si_custom_cdg_log si
    SET si.updt_cnt = (si.updt_cnt+ 1), si.updt_dt_tm = cnvtdatetime(curdate,curtime3), si.updt_id =
     reqinfo->updt_id,
     si.updt_task = reqinfo->updt_task, si.error_flag_txt = sstatus, si.error_text = serrortext
    WHERE si.encntr_id=encntr_id
     AND si.person_id=person_id
    WITH nocounter
   ;end update
   IF (curqual=0)
    SELECT INTO "nl:"
     y = seq(si_template_seq,nextval)
     FROM dual
     DETAIL
      si_custom_cdg_log_id = cnvtreal(y)
     WITH format, counter
    ;end select
    INSERT  FROM si_custom_cdg_log si
     SET si.si_custom_cdg_log_id = si_custom_cdg_log_id, si.person_id = person_id, si.encntr_id =
      encntr_id,
      si.contributor_system_cd = contributor_system_cd, si.error_flag_txt = sstatus, si.error_text =
      serrortext,
      si.trigger_dt_tm = cnvtdatetime(curdate,curtime3), si.updt_cnt = 0, si.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      si.updt_id = reqinfo->updt_id, si.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
   ENDIF
 END ;Subroutine
 SUBROUTINE exitsubmit(hmsg,hreq,hrep)
   CALL echo("subroutine exit submit")
   IF (hmsg > 0)
    SET stat = uar_srvdestroyinstance(hmsg)
   ENDIF
   IF (hreq > 0)
    SET stat = uar_srvdestroyinstance(hreq)
   ENDIF
   IF (hrep > 0)
    SET stat = uar_srvdestroyinstance(hrep)
   ENDIF
   IF (submit_failed=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 END ;Subroutine
 SUBROUTINE write_log(logfile,loglevel,logmessage)
   SET time = concat(format(curdate,"mm/dd/yy;;d")," ",format(curtime3,"hh:mm:ss;3;m"))
   SET logmsg = concat(time,": ",loglevel,": ",logmessage)
   SELECT INTO value(logfile)
    HEAD REPORT
     col 0, logmsg
    WITH nocounter, append
   ;end select
 END ;Subroutine
#exit_script
 CALL echorecord(reply)
 CALL echo(build("logfile(cer_temp) = ",slogfile))
 IF ( NOT (trim(value( $OUTDEV)) IN ("", " ", null)))
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    IF ((reply->status_data.status="S"))
     col 0, "STATUS: S"
    ELSE
     col 0, "STATUS: F"
    ENDIF
    col 0, row + 1, "Log File (cer_temp): ",
    slogfile
   WITH nocounter
  ;end select
 ENDIF
 COMMIT
END GO
