CREATE PROGRAM ec_imp_app_prefs:dba
 PROMPT
  "Enter name of input file (Default = ec_imp_app_prefs.csv): " = "ec_imp_app_prefs.csv"
  WITH inputfilename
 SET message = (noinformation - 1)
 DECLARE csvfilepath = vc WITH noconstant( $INPUTFILENAME), protect
 DECLARE logfilename = vc WITH noconstant("ec_imp_app_prefs_log.csv"), protect
 DECLARE backupfile = vc WITH noconstant("ec_imp_app_prefs_backup.csv"), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE rowcnt = i4 WITH noconstant(0), protect
 DECLARE errmsg = vc WITH noconstant(fillstring(132," ")), protect
 DECLARE errcode = i4 WITH noconstant(1), protect
 DECLARE tokenize(dummy=i4) = null
 DECLARE checkerror(emsg=vc,eoperation=vc) = null
 FREE RECORD rpt
 RECORD rpt(
   1 csvfilepath = vc
   1 row_cnt = i4
   1 rows[*]
     2 application_number = i4
     2 position_cd = f8
     2 pvc_name = vc
     2 pvc_value = vc
     2 sequence = i2
 )
 FREE RECORD appprefs
 RECORD appprefs(
   1 qual[*]
     2 app_prefs_id = f8
     2 position_cd = f8
 )
 FREE RECORD tokens
 RECORD tokens(
   1 delimiter = c1
   1 line_cnt = i4
   1 lines[*]
     2 line = vc
     2 token_cnt = i2
     2 tokens[*]
       3 token = vc
 )
 SET tokens->delimiter = ","
 IF (findfile(csvfilepath)=0)
  CALL echo("Unable to find the CSV file.  Stopping.")
  GO TO exit_script
 ELSE
  CALL echo(build2("Reading in ",csvfilepath))
 ENDIF
 FREE DEFINE rtl3
 DEFINE rtl3 csvfilepath
 DECLARE linecnt = i4 WITH noconstant(0), protect
 SELECT INTO "nl"
  FROM rtl3t r
  WHERE r.line > " "
  DETAIL
   linecnt = (tokens->line_cnt+ 1), tokens->line_cnt = linecnt, stat = alterlist(tokens->lines,
    linecnt),
   tokens->lines[linecnt].line = r.line
  WITH nocounter
 ;end select
 CALL tokenize(0)
 CALL echorecord(tokens,logfilename,1)
 SET rpt->row_cnt = 0
 SELECT INTO value(backupfile)
  stemp = build2("EC_IMP_APP_PREFS ran on ",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"))
  FROM dummyt d
  PLAN (d)
  DETAIL
   col 0, stemp, row + 2
  WITH nocounter, pcformat('"',",",1), format = stream,
   append
 ;end select
 CALL writelog(logfilename,build2("EC_IMP_APP_PREFS ran on ",format(cnvtdatetime(curdate,curtime3),
    "@SHORTDATETIME")))
 CALL echo("Please wait until the CSV file has finished processing.")
 FOR (x = 2 TO tokens->line_cnt)
   SET rowcnt = (rpt->row_cnt+ 1)
   SET rpt->row_cnt = rowcnt
   SET stat = alterlist(rpt->rows,rowcnt)
   SET rpt->rows[rowcnt].application_number = cnvtint(tokens->lines[x].tokens[1].token)
   SET rpt->rows[rowcnt].position_cd = cnvtreal(tokens->lines[x].tokens[2].token)
   SET rpt->rows[rowcnt].pvc_name = trim(tokens->lines[x].tokens[3].token,3)
   SET rpt->rows[rowcnt].pvc_value = trim(tokens->lines[x].tokens[4].token,3)
   SET rpt->rows[rowcnt].sequence = cnvtint(tokens->lines[x].tokens[5].token)
   IF ((((rpt->rows[rowcnt].application_number=0)) OR (textlen(trim(rpt->rows[rowcnt].pvc_name))=0))
   )
    CALL echo(build2("INVALID ENTRY AT ROW# ",x," EXITING."))
    CALL writelog(logfilename,build2("INVALID ENTRY AT ROW# ",x," EXITING."))
    GO TO exit_script
   ENDIF
   IF ((rpt->rows[rowcnt].position_cd=0.0))
    CALL writelog(logfilename,build2("Position_cd: 0.0 Application_number: ",rpt->rows[rowcnt].
      application_number," Pvc_name: ",rpt->rows[rowcnt].pvc_name))
   ENDIF
   SELECT
    IF ((rpt->rows[rowcnt].position_cd=0.0))
     WHERE ap.prsnl_id >= 0
      AND (ap.position_cd >= rpt->rows[rowcnt].position_cd)
      AND (ap.application_number=rpt->rows[rowcnt].application_number)
    ELSE
     WHERE ap.prsnl_id=0
      AND (ap.position_cd=rpt->rows[rowcnt].position_cd)
      AND (ap.application_number=rpt->rows[rowcnt].application_number)
    ENDIF
    INTO "nl:"
    FROM app_prefs ap
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(appprefs->qual,cnt), appprefs->qual[cnt].app_prefs_id = ap
     .app_prefs_id,
     appprefs->qual[cnt].position_cd = ap.position_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    SELECT INTO "nl:"
     z = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      stat = alterlist(appprefs->qual,1), appprefs->qual[1].app_prefs_id = cnvtreal(z), appprefs->
      qual[1].position_cd = rpt->rows[rowcnt].position_cd
     WITH nocounter
    ;end select
    INSERT  FROM app_prefs ap
     SET ap.app_prefs_id = appprefs->qual[1].app_prefs_id, ap.application_number = rpt->rows[rowcnt].
      application_number, ap.position_cd = rpt->rows[rowcnt].position_cd,
      ap.prsnl_id = 0.0, ap.active_ind = 1, ap.updt_cnt = 0,
      ap.updt_id = 999999, ap.updt_dt_tm = cnvtdatetime(curdate,curtime3), ap.updt_task = 999999,
      ap.updt_applctx = 999999
     WITH nocounter
    ;end insert
    CALL checkerror("CRITICAL ERROR: Cannot insert into APP_PREFS","INSERT")
    CALL writelog(logfilename,build2("Created new app_prefs_id: ",appprefs->qual[1].app_prefs_id))
    COMMIT
   ENDIF
   IF ((rpt->rows[rowcnt].sequence=0))
    DELETE  FROM (dummyt d  WITH seq = size(appprefs->qual,5)),
      name_value_prefs nvp
     SET nvp.seq = 1
     PLAN (d)
      JOIN (nvp
      WHERE (nvp.parent_entity_id=appprefs->qual[d.seq].app_prefs_id)
       AND nvp.parent_entity_name="APP_PREFS"
       AND (nvp.pvc_name=rpt->rows[rowcnt].pvc_name))
     WITH nocounter
    ;end delete
    CALL checkerror("CRITICAL ERROR: Cannot delete from NAME_VALUE_PREFS","DELETE")
    CALL writelog(logfilename,build2("Deleted ",trim(cnvtstring(size(appprefs->qual,5)),3),
      " rows for ",rpt->rows[rowcnt].pvc_name,". Check backup file for details."))
    COMMIT
   ENDIF
   IF ((rpt->rows[rowcnt].position_cd=0.0))
    SET pos = locateval(num,1,size(appprefs->qual,5),0.0,appprefs->qual[num].position_cd)
    SET tempappprefsid = appprefs->qual[pos].app_prefs_id
    SET stat = alterlist(appprefs->qual,1)
    SET appprefs->qual[1].app_prefs_id = tempappprefsid
   ENDIF
   INSERT  FROM (dummyt d  WITH seq = size(appprefs->qual,5)),
     name_value_prefs nvp
    SET nvp.name_value_prefs_id = cnvtreal(seq(carenet_seq,nextval)), nvp.parent_entity_name =
     "APP_PREFS", nvp.parent_entity_id = appprefs->qual[d.seq].app_prefs_id,
     nvp.pvc_name = rpt->rows[rowcnt].pvc_name, nvp.pvc_value = rpt->rows[rowcnt].pvc_value, nvp
     .active_ind = 1,
     nvp.updt_cnt = 0, nvp.updt_id = 999999, nvp.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     nvp.updt_task = 999999, nvp.updt_applctx = 999999, nvp.merge_name = null,
     nvp.merge_id = 0.0, nvp.sequence = rpt->rows[rowcnt].sequence
    PLAN (d)
     JOIN (nvp)
    WITH nocounter
   ;end insert
   CALL checkerror("CRITICAL ERROR: Cannot insert into NAME_VALUE_PREFS","INSERT")
   COMMIT
 ENDFOR
 CALL echorecord(rpt,logfilename,1)
 CALL echo(build2("Succesfully imported ",trim(cnvtstring(rpt->row_cnt),3)," rows from CSV file."))
 SUBROUTINE tokenize(dummy)
   DECLARE linecnt = i2 WITH noconstant(0), protect
   DECLARE tokencnt = i2 WITH noconstant(0), protect
   DECLARE delimiterpos = i2 WITH noconstant(0), protect
   DECLARE startpos = i2 WITH noconstant(0), protect
   FOR (linecnt = 1 TO tokens->line_cnt)
     SET startpos = 1
     SET delimiterpos = findstring(tokens->delimiter,tokens->lines[linecnt].line,startpos,0)
     WHILE (delimiterpos > 0)
       SET tokencnt = (tokens->lines[linecnt].token_cnt+ 1)
       SET tokens->lines[linecnt].token_cnt = tokencnt
       SET stat = alterlist(tokens->lines[linecnt].tokens,tokencnt)
       SET tokens->lines[linecnt].tokens[tokencnt].token = substring(startpos,(delimiterpos -
        startpos),tokens->lines[linecnt].line)
       SET startpos = (delimiterpos+ 1)
       SET delimiterpos = findstring(tokens->delimiter,tokens->lines[linecnt].line,startpos,0)
       IF (delimiterpos <= 0)
        SET tokencnt = (tokens->lines[linecnt].token_cnt+ 1)
        SET tokens->lines[linecnt].token_cnt = tokencnt
        SET stat = alterlist(tokens->lines[linecnt].tokens,tokencnt)
        SET tokens->lines[linecnt].tokens[tokencnt].token = substring(startpos,((size(tokens->lines[
          linecnt].line)+ 1) - startpos),tokens->lines[linecnt].line)
       ENDIF
     ENDWHILE
   ENDFOR
 END ;Subroutine
 SUBROUTINE checkerror(emsg,eoperation)
  SET errcode = error(errmsg,1)
  IF (errcode != 0)
   CALL echo("*****************************************")
   CALL echo("** Load program reported a failure. *****")
   CALL echo("************ Exiting program *********** ")
   CALL echo("********* Rolling back changes ********* ")
   CALL echo("*****************************************")
   ROLLBACK
   CALL echo(build("Writing out errors to: ",logfilename))
   SET msg = build2("[",format(cnvtdatetime(curdate,curtime3),"@SHORTDATETIME"),"] Error: ",trim(emsg
     )," :: ",
    errmsg)
   CALL writelog(logfilename,msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE writelog(filename,msg)
   SELECT INTO value(filename)
    FROM dummyt d
    PLAN (d)
    DETAIL
     col 0, msg, row + 1
    WITH nocounter, append, maxcol = 1001
   ;end select
 END ;Subroutine
#exit_script
END GO
