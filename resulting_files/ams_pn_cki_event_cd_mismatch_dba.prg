CREATE PROGRAM ams_pn_cki_event_cd_mismatch:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Email Address" = "",
  "Job Type" = 1
  WITH outdev, p_email, p_job_type
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 EXECUTE ams_define_toolkit_common
 FREE RECORD rdata
 RECORD rdata(
   1 qual_knt = i4
   1 qual[*]
     2 scr_term_id = f8
     2 term_display = vc
     2 term_cki = vc
     2 missing_mismatch = i2
     2 inactive_ind = i2
 )
 DECLARE dcvscrtermdeftypeeventcode = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!25002"))
 DECLARE ilocidx = i4 WITH protect, noconstant(0)
 DECLARE ipos = i4 WITH protect, noconstant(0)
 DECLARE sfullfilename = vc WITH protect, noconstant("")
 DECLARE slocalpath = vc WITH protect, noconstant(logical("cer_temp"))
 DECLARE sfilename = vc WITH protect, constant(concat("ams_pn_cki_chk_",format(cnvtdatetime(curdate,
     curtime3),"YYYYMMDD;;Q"),".csv"))
 SET sfullfilename = build(slocalpath,"/",sfilename)
 DECLARE zipfile_full = vc WITH protect, constant("")
 DECLARE removing_file = i2 WITH protect, constant(0)
 DECLARE email_file(mail_addr=vc,from_addr=vc,mail_sub=vc,attach_file_full=vc,attach_zipfile_full=vc(
   value,zipfile_full),
  remove_files=i2(value,removing_file)) = i2
 DECLARE linuxversion(null) = i4
 SUBROUTINE email_file(mail_addr,from_addr,mail_sub,attach_file_full,attach_zipfile_full,remove_files
  )
   DECLARE ccl_ver = i4 WITH private, noconstant(cnvtint(build(currev,currevminor,currevminor2)))
   DECLARE start_pos = i4 WITH private, noconstant(0)
   DECLARE cur_pos = i4 WITH private, noconstant(0)
   DECLARE end_flag = i2 WITH private, noconstant(0)
   DECLARE stemp = vc WITH private, noconstant("")
   DECLARE mail_to = vc WITH private, noconstant("")
   DECLARE attach_file = vc WITH private, noconstant("")
   DECLARE attach_zipfile = vc WITH private, noconstant("")
   DECLARE email_full = vc WITH private, noconstant("")
   DECLARE email_file = vc WITH private, noconstant("")
   DECLARE dclcom = vc WITH private, noconstant("")
   DECLARE dclcom1 = vc WITH private, noconstant("")
   DECLARE dclstatus = i2 WITH private, noconstant(9)
   DECLARE dclstatus1 = i2 WITH private, noconstant(9)
   DECLARE returnval = i2 WITH private, noconstant(9)
   DECLARE removeval = i2 WITH private, noconstant(0)
   DECLARE zipping_file = i2 WITH private, noconstant(0)
   DECLARE linver = i4 WITH private, noconstant(0.0)
   IF ( NOT (cursys2 IN ("AIX", "HPX", "LNX"))
    AND ccl_ver < 844)
    RETURN(0)
   ENDIF
   SET start_pos = 1
   SET cur_pos = 1
   SET end_flag = 0
   WHILE (end_flag=0
    AND cur_pos < 500)
     SET stemp = piece(mail_addr,";",cur_pos,"Not Found")
     IF (stemp != "Not Found")
      IF (size(trim(mail_to))=0)
       SET mail_to = stemp
      ELSE
       SET mail_to = concat(mail_to," ",stemp)
      ENDIF
     ELSE
      SET end_flag = 1
     ENDIF
     SET cur_pos = (cur_pos+ 1)
   ENDWHILE
   SET cur_pos = findstring("/",attach_file_full,start_pos,1)
   IF (cur_pos < 1)
    SET attach_file = trim(attach_file_full,3)
   ELSE
    SET attach_file = trim(substring((cur_pos+ 1),((size(attach_file_full) - cur_pos)+ 1),
      attach_file_full),3)
   ENDIF
   SET email_file = attach_file
   SET email_full = attach_file_full
   IF (textlen(trim(attach_zipfile_full,3)) > 0)
    SET zipping_file = 1
    SET start_pos = 1
    SET cur_pos = 1
    SET cur_pos = findstring("/",attach_zipfile_full,start_pos,1)
    IF (cur_pos < 1)
     SET attach_zipfile = trim(attach_zipfile_full,3)
    ELSE
     SET attach_zipfile = trim(substring((cur_pos+ 1),((size(attach_zipfile_full) - cur_pos)+ 1),
       attach_zipfile_full),3)
    ENDIF
    SET dclcom = concat("zip -j ",attach_zipfile," ",attach_file)
    CALL dcl(dclcom,size(trim(dclcom)),dclstatus)
    SET email_file = attach_zipfile
    SET email_full = attach_zipfile_full
   ENDIF
   IF (cursys2="AIX")
    IF (((dclstatus=0) OR (zipping_file=0)) )
     SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
      " ",'|mailx -s "',mail_sub,'" ',"-r ",
      from_addr," ",mail_to)
     SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
    ENDIF
   ELSEIF (cursys2="HPX")
    IF (((dclstatus=0) OR (zipping_file=0)) )
     SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
      " ",'|mailx -m -s "',mail_sub,'" ',"-r ",
      from_addr," ",mail_to)
     SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
    ENDIF
   ELSEIF (cursys2="LNX")
    SET linver = linuxversion(null)
    IF (((dclstatus=1) OR (zipping_file=0)) )
     IF (linver >= 6.0)
      SET dclcom1 = concat("echo | mailx -r '",from_addr,"' -s '",mail_sub,"' -a '",
       email_file,"' ",mail_addr)
      SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
     ELSE
      SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
       " ",'|mailx -s "',mail_sub,'" ',mail_to)
      SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
     ENDIF
    ENDIF
   ENDIF
   IF (returnval != 9
    AND remove_files != 0)
    IF (textlen(trim(attach_zipfile_full,3))=0)
     SET removeval = remove(attach_file_full)
    ELSEIF (textlen(trim(attach_zipfile_full,3)) > 0)
     SET removeval = remove(attach_file_full)
     SET removeval = remove(attach_zipfile_full)
    ENDIF
   ENDIF
   IF (returnval != 9
    AND removeval IN (0, 1))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
   SET last_mod = "12/28/2015 RJ4716"
 END ;Subroutine
 SUBROUTINE linuxversion(null)
   DECLARE filelinuxversiontemp = vc WITH constant(build2("ccps_rpt_os_ver.dat")), protect
   DECLARE strversion = vc WITH noconstant(""), protect
   DECLARE linversion = i4 WITH noconstant(0.0), protect
   DECLARE status = i4 WITH noconstant(0), protect
   DECLARE dcloutput = vc WITH noconstant(""), protect
   SET dclrem = build2("rm ",trim(filelinuxversiontemp,3))
   SET len = size(trim(dclrem))
   CALL dcl(dclrem,len,status)
   SET dclcom = build2("cat /etc/redhat-release >> ",trim(filelinuxversiontemp,3))
   SET len = size(trim(dclcom))
   SET status = - (1)
   CALL dcl(dclcom,len,status)
   FREE DEFINE rtl
   DEFINE rtl filelinuxversiontemp
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     dcloutput = cnvtupper(trim(r.line,3))
    WITH nocounter
   ;end select
   SET strversion = substring((findstring("RELEASE",dcloutput)+ 8),3,dcloutput)
   IF (isnumeric(strversion) > 0)
    SET linversion = cnvtint(strversion)
   ENDIF
   RETURN(linversion)
 END ;Subroutine
 DECLARE srecipient = vc WITH protect, noconstant(trim( $P_EMAIL,3))
 DECLARE ssubject = vc WITH protect, noconstant(concat(trim(curdomain,3),
   ": PowerNote CKI/EVENT_CD Issues ",format(cnvtdatetime(curdate,curtime3),"DD-MMM-YYYY;;D")))
 DECLARE sfrom = vc WITH protect, noconstant("Cerner")
 IF (validate(request->batch_selection,"F")="F")
  SET bisanopsjob = false
  SET bamsassociate = isamsuser(reqinfo->updt_id)
  IF ( NOT (bamsassociate))
   SET failed = exe_error
   SET serrmsg = "User is Not Cerner AMS"
   GO TO exit_script
  ENDIF
 ELSE
  SET bisanopsjob = true
 ENDIF
 SELECT INTO "nl:"
  FROM scr_term_definition std,
   scr_term st,
   scr_term_text stt
  PLAN (std
   WHERE std.scr_term_def_type_cd=dcvscrtermdeftypeeventcode
    AND  NOT ( EXISTS (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=72
     AND cv.cki=std.def_text))))
   JOIN (st
   WHERE st.scr_term_def_id=std.scr_term_def_id)
   JOIN (stt
   WHERE stt.scr_term_id=st.scr_term_id)
  HEAD REPORT
   knt = 0
  DETAIL
   knt = (knt+ 1)
   IF (knt > size(rdata->qual,5))
    stat = alterlist(rdata->qual,(knt+ 5))
   ENDIF
   rdata->qual[knt].scr_term_id = st.scr_term_id, rdata->qual[knt].term_display = stt.display, rdata
   ->qual[knt].term_cki = std.def_text,
   rdata->qual[knt].missing_mismatch = true
  FOOT REPORT
   rdata->qual_knt = knt, stat = alterlist(rdata->qual,knt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM scr_term_definition std,
   scr_term st,
   scr_term_text stt
  PLAN (std
   WHERE std.scr_term_def_type_cd=dcvscrtermdeftypeeventcode
    AND  NOT ( EXISTS (
   (SELECT
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=72
     AND cv.cki=std.def_text
     AND cv.active_ind=1))))
   JOIN (st
   WHERE st.scr_term_def_id=std.scr_term_def_id)
   JOIN (stt
   WHERE stt.scr_term_id=st.scr_term_id)
  HEAD REPORT
   knt = size(rdata->qual,5)
  DETAIL
   ilocidx = 0, ipos = locateval(ilocidx,1,knt,st.scr_term_id,rdata->qual[ilocidx].scr_term_id)
   IF (ipos > 0)
    rdata->qual[ipos].inactive_ind = true
   ELSE
    knt = (knt+ 1)
    IF (knt > size(rdata->qual,5))
     stat = alterlist(rdata->qual,(knt+ 5))
    ENDIF
    rdata->qual[knt].scr_term_id = st.scr_term_id, rdata->qual[knt].term_display = stt.display, rdata
    ->qual[knt].term_cki = std.def_text,
    rdata->qual[knt].missing_mismatch = true
   ENDIF
  FOOT REPORT
   rdata->qual_knt = knt, stat = alterlist(rdata->qual,knt)
  WITH nocounter
 ;end select
 IF (( $P_JOB_TYPE=2)
  AND bisanopsjob=false)
  CALL echo("***")
  CALL echo("***   DELETE SCR_TERM_DEFINITION")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM scr_term_definition td
   PLAN (td
    WHERE td.scr_term_def_type_cd=dcvscrtermdeftypeeventcode
     AND  NOT ( EXISTS (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=72
      AND cv.cki=td.def_text))))
   WITH nocounter
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL echo("***")
   CALL echo("***   ERROR >> DELETE SCR_TERM_DEFINITION")
   CALL echo("***")
   ROLLBACK
   SELECT INTO value( $OUTDEV)
    FROM dummyt d
    HEAD REPORT
     smsg = concat(trim(curdomain),": ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;q"),
      " : DELETE SCR_TERM_DEFINITION FAILED >> ",trim(serrmsg,3)), sjobtype = trim(cnvtstring(
        $P_JOB_TYPE),3)
    DETAIL
     col 0, smsg, row + 3,
     col 10, "Prompts Selected:", row + 1,
     col 20, "OUTPUT:",  $OUTDEV,
     row + 1, col 20, "EMAIL:",
      $P_EMAIL, row + 1, col 20,
     "JOB TYPE:", sjobtype
    WITH nocounter, maxcol = 1000
   ;end select
   GO TO exit_script
  ENDIF
  CALL echo("***")
  CALL echo("***   UPDATE SCR_TERM")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  UPDATE  FROM scr_term t
   SET t.scr_term_def_id = 0.00, t.updt_cnt = (t.updt_cnt+ 1), t.updt_id = 2.00,
    t.updt_task = 0, t.updt_applctx = 0.00, t.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   PLAN (t
    WHERE t.scr_term_def_id != 0.00
     AND  NOT ( EXISTS (
    (SELECT
     def.scr_term_def_id
     FROM scr_term_definition def
     WHERE def.scr_term_def_id=t.scr_term_def_id))))
   WITH nocounter
  ;end update
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   CALL echo("***")
   CALL echo("***   ERROR >> UPDATE SCR_TERM")
   CALL echo("***")
   ROLLBACK
   SELECT INTO value( $OUTDEV)
    FROM dummyt d
    HEAD REPORT
     smsg = concat(trim(curdomain),": ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;q"),
      " : UPDATE SCR_TERM FAILED >> ",trim(serrmsg,3)), sjobtype = trim(cnvtstring( $P_JOB_TYPE),3)
    DETAIL
     col 0, smsg, row + 3,
     col 10, "Prompts Selected:", row + 1,
     col 20, "OUTPUT:",  $OUTDEV,
     row + 1, col 20, "EMAIL:",
      $P_EMAIL, row + 1, col 20,
     "JOB TYPE:", sjobtype
    WITH nocounter, maxcol = 1000
   ;end select
   GO TO exit_script
  ENDIF
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    smsg = concat(trim(curdomain),": ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;q"),
     " : SUCCESS Cleaning up SCR_TERM_DEFINITION and SCR_TERM"), sjobtype = trim(cnvtstring(
       $P_JOB_TYPE),3)
   DETAIL
    col 0, smsg, row + 3,
    col 10, "Prompts Selected:", row + 1,
    col 20, "OUTPUT:",  $OUTDEV,
    row + 1, col 20, "EMAIL:",
     $P_EMAIL, row + 1, col 20,
    "JOB TYPE:", sjobtype
   WITH nocounter, maxcol = 1000
  ;end select
  COMMIT
  GO TO exit_script
 ENDIF
 IF (textlen(trim( $P_EMAIL,3)) < 1)
  GO TO skip_gen_output
 ENDIF
 SET stat = remove(sfullfilename)
 IF ((rdata->qual_knt < 1))
  SELECT INTO value(sfullfilename)
   msg = concat(trim(curdomain),": ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;q"),
    ": No mis-matched or inactive items found")
   FROM (dummty d  WITH seq = 1)
   WITH nocounter, maxcol = 1000
  ;end select
 ELSE
  SELECT INTO value(sfullfilename)
   scr_term_id = rdata->qual[d.seq].scr_term_id, term_disp = trim(substring(1,100,rdata->qual[d.seq].
     term_display),3), term_cki = trim(substring(1,100,rdata->qual[d.seq].term_cki),3),
   missing_mismatch =
   IF ((rdata->qual[d.seq].missing_mismatch=true)) "TRUE"
   ELSE "FALSE"
   ENDIF
   , inactive =
   IF ((rdata->qual[d.seq].inactive_ind=true)) "TRUE"
   ELSE "FALSE"
   ENDIF
   FROM (dummyt d  WITH seq = value(rdata->qual_knt))
   PLAN (d
    WHERE d.seq > 0)
   WITH nocounter, format = stream, pcformat('"',",",1),
    maxcol = 1000
  ;end select
 ENDIF
 IF (findfile(sfullfilename))
  SET email_stat = email_file(srecipient,sfrom,ssubject,sfullfilename)
 ENDIF
 GO TO exit_script
#skip_gen_output
 IF ((rdata->qual_knt < 1))
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    smsg = concat(trim(curdomain),": ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;q"),
     ": No mis-matched or inactive items found"), sjobtype = trim(cnvtstring( $P_JOB_TYPE),3)
   DETAIL
    col 0, smsg, row + 3,
    col 10, "Prompts Selected:", row + 1,
    col 20, "OUTPUT:",  $OUTDEV,
    row + 1, col 20, "EMAIL:",
     $P_EMAIL, row + 1, col 20,
    "JOB TYPE:", sjobtype
   WITH nocounter, maxcol = 1000
  ;end select
 ELSE
  SELECT INTO value( $OUTDEV)
   scr_term_id = rdata->qual[d.seq].scr_term_id, term_disp = trim(substring(1,100,rdata->qual[d.seq].
     term_display),3), term_cki = trim(substring(1,100,rdata->qual[d.seq].term_cki),3),
   missing_mismatch =
   IF ((rdata->qual[d.seq].missing_mismatch=true)) "TRUE"
   ELSE "FALSE"
   ENDIF
   , inactive =
   IF ((rdata->qual[d.seq].inactive_ind=true)) "TRUE"
   ELSE "FALSE"
   ENDIF
   FROM (dummyt d  WITH seq = value(rdata->qual_knt))
   PLAN (d
    WHERE d.seq > 0)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
#exit_script
 IF (bisanopsjob=false)
  IF (( $P_JOB_TYPE != 2))
   IF ((rdata->qual_knt < 1))
    IF (failed=exe_error)
     SET smessage = "User must be a Cerner AMS associated to run this program from Explorer Menu"
    ELSE
     SET smessage = concat(trim(curdomain),": ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;q"
       ),": No mis-matched or inactive items found")
    ENDIF
   ELSE
    SET smessage = concat(trim(curdomain),": ",format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;q"),
     ": ",trim(cnvtstring(rdata->qual_knt),3),
     " Mis-matched or Inactive items found")
   ENDIF
  ENDIF
  IF (failed != exe_error)
   CALL updtdminfo("AMS_PN_CKI_EVENT_CD_MISMATCH")
  ENDIF
  IF (( $P_JOB_TYPE != 2))
   IF (textlen(trim( $P_EMAIL,3)) > 0)
    SELECT INTO value( $OUTDEV)
     message = trim(substring(1,200,smessage),3), soutdev =  $OUTDEV, semail =  $P_EMAIL
     FROM (dummyt d  WITH seq = 1)
     WITH nocounter, format, separator = " "
    ;end select
   ENDIF
  ENDIF
 ENDIF
END GO
