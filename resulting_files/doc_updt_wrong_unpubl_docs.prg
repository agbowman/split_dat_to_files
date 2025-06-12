CREATE PROGRAM doc_updt_wrong_unpubl_docs
 PROMPT
  "Enter file name with the location of the file (eg. cer_temp:test_file_1020.csv): " = "*"
  WITH filename
 DECLARE strfileinput = vc WITH noconstant( $FILENAME)
 IF (findfile(strfileinput)=0)
  CALL echo("*************************************************************************")
  CALL echo(concat("FAILED - COULD NOT FIND THE FILE: ",strfileinput))
  CALL echo("*************************************************************************")
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 SET logical fileinput strfileinput
 DEFINE rtl2 "fileInput"
 SET filename = build("cer_temp:updt_publ_flag_prog_status_",format(curdate,"yymmdd;;d"),format(
   curtime,"hhmm;;m"),".txt")
 SELECT INTO value(filename)
  DETAIL
   row 1, col 01, strfileinput
  WITH nocounter, format = variable, noformfeed,
   maxcol = 255, maxrow = 1, append
 ;end select
 CALL echo(build("The processing status output file name is :",filename))
 DECLARE commitpass = i4 WITH noconstant(1)
 DECLARE maxcommit = i4 WITH constant(250000)
 DECLARE startindex = i4 WITH noconstant(1)
 DECLARE endindex = i4 WITH noconstant(value(maxcommit))
 DECLARE statusmsg = vc WITH noconstant("")
 DECLARE statusresult = vc WITH noconstant("")
 DECLARE currclineventid = vc WITH noconstant("")
 DECLARE startindexnumfiletable = i4 WITH noconstant(0)
 DECLARE currindexnumfiletable = i4 WITH noconstant(0)
 DECLARE indexnumtabletemp = i4 WITH noconstant(0)
 DECLARE maxrecsize = i4 WITH noconstant(0)
 DECLARE startpos = i4 WITH noconstant(0)
 DECLARE endpos = i4 WITH noconstant(0)
 DECLARE doneloop = i4 WITH noconstant(0)
 FREE SET table_temp
 RECORD table_temp(
   1 list[maxcommit]
     2 clinical_event_id = f8
 )
 WHILE (doneloop=0)
   IF (commitpass=1)
    SET maxrecsize = ((maxcommit * commitpass)+ 1)
   ELSE
    SET maxrecsize = (maxcommit * commitpass)
   ENDIF
   SELECT INTO "nl"
    FROM rtl2t a
    WHERE a.line > " "
    HEAD REPORT
     IF (commitpass=1)
      currindexnumfiletable = - (1)
     ELSE
      currindexnumfiletable = 0
     ENDIF
     startindexnumfiletable = (maxcommit * (commitpass - 1)), indexnumtabletemp = 0
    DETAIL
     currindexnumfiletable = (currindexnumfiletable+ 1)
     IF (currindexnumfiletable != 0
      AND currindexnumfiletable > startindexnumfiletable)
      startpos = 1, endpos = findstring(",",a.line,startpos), currclineventid = trim(substring(
        startpos,(endpos - startpos),a.line)),
      indexnumtabletemp = (currindexnumfiletable - startindexnumfiletable), table_temp->list[
      indexnumtabletemp].clinical_event_id = cnvtreal(currclineventid)
     ENDIF
    FOOT REPORT
     IF (indexnumtabletemp < maxcommit)
      doneloop = 1, endindex = indexnumtabletemp
     ENDIF
    WITH maxrec = value(maxrecsize)
   ;end select
   UPDATE  FROM (dummyt d  WITH seq = value(endindex)),
     clinical_event ce
    SET ce.publish_flag = 1
    PLAN (d
     WHERE d.seq >= startindex
      AND d.seq <= endindex)
     JOIN (ce
     WHERE ce.clinical_event_id > 0
      AND (ce.clinical_event_id=table_temp->list[d.seq].clinical_event_id))
   ;end update
   SET statusmsg = concat("  Processing ",build(" ",curqual)," rows of qualifying events...")
   CALL echo(statusmsg)
   COMMIT
   IF ((curqual != ((endindex+ 1) - startindex)))
    SET statusresult = "   Result status is Failure"
   ELSE
    SET statusresult = "   Result status is Success"
   ENDIF
   CALL echo(statusresult)
   SELECT INTO value(filename)
    DETAIL
     row 1, col 01, statusmsg,
     row + 1, col 01, statusresult
    WITH nocounter, format = variable, noformfeed,
     maxcol = 255, maxrow = 1, append
   ;end select
   SET commitpass = (commitpass+ 1)
 ENDWHILE
 CALL echo(build("The processing status output file name is :",filename))
#exit_script
END GO
