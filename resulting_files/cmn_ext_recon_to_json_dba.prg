CREATE PROGRAM cmn_ext_recon_to_json:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Reconciliation File" = "",
  "Debug Ind" = 0
  WITH outdev, recfile, bdebug
 DECLARE PUBLIC::errorcheck(replystructure=vc(ref),operation=vc) = null
 SUBROUTINE PUBLIC::errorcheck(replystructure,operation)
   DECLARE errormsg = c255 WITH protect, noconstant("")
   DECLARE errorcode = i4 WITH protect, noconstant(0)
   SET errorcode = error(errormsg,0)
   IF (errorcode != 0)
    WHILE (errorcode != 0)
      SET replystructure->status_data.subeventstatus[1].operationname = operation
      SET replystructure->status_data.subeventstatus[1].targetobjectname = cnvtstring(errorcode,10)
      SET replystructure->status_data.subeventstatus[1].targetobjectvalue = errormsg
      SET replystructure->status_data.status = "F"
      IF ((reqdata->loglevel >= 4))
       CALL echo(errormsg)
      ENDIF
      SET errorcode = error(errormsg,0)
    ENDWHILE
    GO TO exit_script
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cmn_string_utils_imported)))
  EXECUTE cmn_string_utils
 ENDIF
 DECLARE action_field = i4 WITH constant(12)
 DECLARE matchtype_field = i4 WITH constant(13)
 DECLARE t_suggestions_field = i4 WITH constant(19)
 DECLARE code_set_event_set_93 = i4 WITH protect, constant(93)
 DECLARE PUBLIC::main(null) = null
 DECLARE PUBLIC::extractdatafromcsv(filepath=vc) = null
 DECLARE PUBLIC::populatetargetsuggestioncv(qualcountcv=i4,targetsuggestionslist=vc) = null
 DECLARE PUBLIC::populatecodeset93cvlist(codevalue=f8,qualcvidx=i4,suggestionsidx=i4) = null
 DECLARE PUBLIC::populateothercodesetcvlist(codevalue=f8,qualcvidx=i4,suggestionsidx=i4) = null
 DECLARE PUBLIC::populatecodeset93suggestiondata(null) = null
 DECLARE PUBLIC::populateothercodesetsuggestiondata(null) = null
 FREE RECORD reconciledata
 RECORD reconciledata(
   1 qualcountcv = i4
   1 qualcv[*]
     2 csvrownum = i4
     2 codevaluenum = i4
     2 codeset = vc
     2 sourcecdfmeaning = vc
     2 sourcedisplaykey = vc
     2 sourcedescription = vc
     2 sourceeventsetname = vc
     2 targetcodevalue = vc
     2 targetcdfmeaning = vc
     2 targetdisplaykey = vc
     2 targetdescription = vc
     2 targeteventsetname = vc
     2 suggestions[*]
       3 targetcodevalue = vc
       3 targetcdfmeaning = vc
       3 targetdisplaykey = vc
       3 targetdescription = vc
       3 targeteventsetname = vc
       3 context[*]
         4 parentfolder = vc
         4 contextpath = vc
     2 action = c1
     2 casesensitive = c1
   1 qualcounttable = i4
   1 qualtable[*]
     2 csvrownum = i4
     2 tablenumber = i4
     2 sourcetablename = vc
     2 sourcetabledefinition = vc
     2 sourcecategoryname = vc
     2 targetprimaryid = vc
     2 targetdefinition = vc
     2 targetcategoryname = vc
     2 action = c1
     2 casesensitive = c1
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 RECORD eventset93codevalues(
   1 qual[*]
     2 codevalue = f8
     2 masteridxlist[*]
       3 qualcvindex = i4
       3 suggestionsidx = i4
 ) WITH protect
 RECORD othercodevalues(
   1 qual[*]
     2 codevalue = f8
     2 masteridxlist[*]
       3 qualcvindex = i4
       3 suggestionsidx = i4
 ) WITH protect
 SUBROUTINE PUBLIC::main(null)
   DECLARE recfilepath = vc WITH protect, constant(trim( $RECFILE))
   CALL extractdatafromcsv(recfilepath)
   CALL errorcheck(reconciledata,"Convert to JSON")
 END ;Subroutine
 SUBROUTINE PUBLIC::extractdatafromcsv(filepath)
   DECLARE rowcount = i4 WITH noconstant(0), protect
   DECLARE remainder = vc WITH noconstant(""), protect
   DECLARE delimiter = vc WITH constant('","'), protect
   DECLARE startchars = vc WITH noconstant(trim("")), protect
   DECLARE rowtype = vc WITH noconstant(trim("")), protect
   DECLARE rowaction = vc WITH noconstant(trim("")), protect
   SET reconciledata->qualcountcv = 0
   SET reconciledata->qualcounttable = 0
   SET stat = alterlist(reconciledata->qualcv,100)
   SET stat = alterlist(reconciledata->qualtable,100)
   IF (cmnisblank(filepath))
    SET reconciledata->status_data.status = "F"
    SET reconciledata->status_data.subeventstatus.targetobjectvalue = "Filepath cannot be empty"
    GO TO exit_script
   ENDIF
   IF (findfile(filepath,4)=0)
    SET reconciledata->status_data.status = "F"
    SET reconciledata->status_data.subeventstatus.targetobjectvalue = "File not available"
   ENDIF
   FREE DEFINE rtl3
   DEFINE rtl3 filepath
   CALL errorcheck(reconciledata,"Get file for retrieval")
   SET rowtype = "CV"
   SELECT INTO "nl:"
    r.line
    FROM rtl3t r
    DETAIL
     rowcount = (rowcount+ 1), startchars = substring(2,2,r.line)
     IF (cmnisblank(r.line))
      rowtype = "TB"
     ENDIF
     IF (rowtype="CV"
      AND mod(reconciledata->qualcountcv,100)=1)
      stat = alterlist(reconciledata->qualcv,(reconciledata->qualcountcv+ 100))
     ENDIF
     IF (rowtype="TB"
      AND mod(reconciledata->qualcounttable,100)=1)
      stat = alterlist(reconciledata->qualtable,(reconciledata->qualcounttable+ 100))
     ENDIF
     rowaction = parsedelimitedstring(r.line,delimiter,action_field,remainder)
     IF (rowaction != "T")
      IF (operator(startchars,"REGEXPLIKE","[0-9]")
       AND rowtype="CV")
       reconciledata->qualcountcv = (reconciledata->qualcountcv+ 1), reconciledata->qualcv[
       reconciledata->qualcountcv].csvrownum = rowcount, reconciledata->qualcv[reconciledata->
       qualcountcv].codevaluenum = cnvtint(replace(parsedelimitedstring(r.line,delimiter,1,remainder),
         '"',"",1)),
       reconciledata->qualcv[reconciledata->qualcountcv].codeset = parsedelimitedstring(remainder,
        delimiter,1,remainder), reconciledata->qualcv[reconciledata->qualcountcv].sourcecdfmeaning =
       parsedelimitedstring(remainder,delimiter,1,remainder), reconciledata->qualcv[reconciledata->
       qualcountcv].sourcedisplaykey = parsedelimitedstring(remainder,delimiter,1,remainder),
       reconciledata->qualcv[reconciledata->qualcountcv].sourcedescription = parsedelimitedstring(
        remainder,delimiter,1,remainder), reconciledata->qualcv[reconciledata->qualcountcv].
       sourceeventsetname = parsedelimitedstring(remainder,delimiter,1,remainder), reconciledata->
       qualcv[reconciledata->qualcountcv].targetcodevalue = parsedelimitedstring(remainder,delimiter,
        1,remainder),
       reconciledata->qualcv[reconciledata->qualcountcv].targetcdfmeaning = parsedelimitedstring(
        remainder,delimiter,1,remainder), reconciledata->qualcv[reconciledata->qualcountcv].
       targetdisplaykey = parsedelimitedstring(remainder,delimiter,1,remainder), reconciledata->
       qualcv[reconciledata->qualcountcv].targetdescription = parsedelimitedstring(remainder,
        delimiter,1,remainder),
       reconciledata->qualcv[reconciledata->qualcountcv].targeteventsetname = parsedelimitedstring(
        remainder,delimiter,1,remainder), reconciledata->qualcv[reconciledata->qualcountcv].action =
       parsedelimitedstring(remainder,delimiter,1,remainder), reconciledata->qualcv[reconciledata->
       qualcountcv].casesensitive = parsedelimitedstring(remainder,delimiter,1,remainder),
       CALL populatetargetsuggestioncv(reconciledata->qualcountcv,replace(parsedelimitedstring(
         remainder,delimiter,(t_suggestions_field - matchtype_field),remainder),'"',"",1))
      ELSEIF (operator(startchars,"REGEXPLIKE","[0-9]")
       AND rowtype="TB")
       reconciledata->qualcounttable = (reconciledata->qualcounttable+ 1), reconciledata->qualtable[
       reconciledata->qualcounttable].csvrownum = rowcount, reconciledata->qualtable[reconciledata->
       qualcounttable].tablenumber = cnvtint(replace(parsedelimitedstring(r.line,delimiter,1,
          remainder),'"',"",1)),
       reconciledata->qualtable[reconciledata->qualcounttable].sourcetablename = parsedelimitedstring
       (remainder,delimiter,1,remainder), reconciledata->qualtable[reconciledata->qualcounttable].
       sourcetabledefinition = parsedelimitedstring(remainder,delimiter,1,remainder), reconciledata->
       qualtable[reconciledata->qualcounttable].sourcecategoryname = parsedelimitedstring(remainder,
        delimiter,1,remainder),
       reconciledata->qualtable[reconciledata->qualcounttable].targetprimaryid = parsedelimitedstring
       (remainder,delimiter,3,remainder), reconciledata->qualtable[reconciledata->qualcounttable].
       targetdefinition = parsedelimitedstring(remainder,delimiter,1,remainder), reconciledata->
       qualtable[reconciledata->qualcounttable].targetcategoryname = parsedelimitedstring(remainder,
        delimiter,1,remainder),
       reconciledata->qualtable[reconciledata->qualcounttable].action = parsedelimitedstring(
        remainder,delimiter,3,remainder), reconciledata->qualtable[reconciledata->qualcounttable].
       casesensitive = parsedelimitedstring(remainder,delimiter,1,remainder)
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reconciledata->qualcv,reconciledata->qualcountcv), stat = alterlist(
      reconciledata->qualtable,reconciledata->qualcounttable)
    WITH nocounter
   ;end select
   CALL errorcheck(reconciledata,"Extract to record struct")
   FREE DEFINE rtl3
   IF ((reconciledata->qualcountcv=0)
    AND (reconciledata->qualcounttable=0))
    SET reconciledata->status_data.status = "Z"
    SET reconciledata->status_data.subeventstatus.targetobjectvalue = "No Data Found"
   ENDIF
   IF (size(othercodevalues->qual,5) > 0)
    CALL populateothercodesetsuggestiondata(null)
   ENDIF
   IF (size(eventset93codevalues->qual,5) > 0)
    CALL populatecodeset93suggestiondata(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::populatetargetsuggestioncv(qualcountcv,targetsuggestionslist)
   DECLARE cvdelimiter = vc WITH protect, constant("_")
   DECLARE codevaluecount = i4 WITH protect, noconstant(0)
   DECLARE parsedcodevalue = vc WITH protect, noconstant("")
   WHILE (cmnisnotblank(targetsuggestionslist))
     SET parsedcodevalue = replace(parsedelimitedstring(targetsuggestionslist,cvdelimiter,1,
       targetsuggestionslist),'"',"",1)
     SET codevaluecount = (codevaluecount+ 1)
     SET stat = alterlist(reconciledata->qualcv[qualcountcv].suggestions,codevaluecount)
     SET reconciledata->qualcv[qualcountcv].suggestions[codevaluecount].targetcodevalue =
     parsedcodevalue
     IF (cnvtint(reconciledata->qualcv[qualcountcv].codeset)=code_set_event_set_93)
      CALL populatecodeset93cvlist(cnvtreal(parsedcodevalue),qualcountcv,codevaluecount)
     ELSE
      CALL populateothercodesetcvlist(cnvtreal(parsedcodevalue),qualcountcv,codevaluecount)
     ENDIF
   ENDWHILE
 END ;Subroutine
 SUBROUTINE PUBLIC::populatecodeset93cvlist(codevalue,qualcvidx,suggestionsidx)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE masteridxlistsize = i4 WITH protect, noconstant(0)
   DECLARE recsize = i4 WITH protect, noconstant(size(eventset93codevalues->qual,5))
   SET pos = locatevalsort(num,1,recsize,codevalue,eventset93codevalues->qual[num].codevalue)
   IF (pos <= 0)
    SET recsize = (recsize+ 1)
    SET stat = alterlist(eventset93codevalues->qual,recsize,- (pos))
    SET pos = (1 - pos)
    SET eventset93codevalues->qual[pos].codevalue = codevalue
   ENDIF
   SET masteridxlistsize = size(eventset93codevalues->qual[pos].masteridxlist,5)
   SET stat = alterlist(eventset93codevalues->qual[pos].masteridxlist,(masteridxlistsize+ 1))
   SET eventset93codevalues->qual[pos].masteridxlist[(masteridxlistsize+ 1)].qualcvindex = qualcvidx
   SET eventset93codevalues->qual[pos].masteridxlist[(masteridxlistsize+ 1)].suggestionsidx =
   suggestionsidx
   IF (validate(debug_ind)=1)
    CALL echorecord(eventset93codevalues)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::populateothercodesetcvlist(codevalue,qualcvidx,suggestionsidx)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE masteridxlistsize = i4 WITH protect, noconstant(0)
   DECLARE recsize = i4 WITH protect, noconstant(size(othercodevalues->qual,5))
   SET pos = locatevalsort(num,1,recsize,codevalue,othercodevalues->qual[num].codevalue)
   IF (pos <= 0)
    SET recsize = (recsize+ 1)
    SET stat = alterlist(othercodevalues->qual,recsize,- (pos))
    SET pos = (1 - pos)
    SET othercodevalues->qual[pos].codevalue = codevalue
   ENDIF
   SET masteridxlistsize = size(othercodevalues->qual[pos].masteridxlist,5)
   SET stat = alterlist(othercodevalues->qual[pos].masteridxlist,(masteridxlistsize+ 1))
   SET othercodevalues->qual[pos].masteridxlist[(masteridxlistsize+ 1)].qualcvindex = qualcvidx
   SET othercodevalues->qual[pos].masteridxlist[(masteridxlistsize+ 1)].suggestionsidx =
   suggestionsidx
   IF (validate(debug_ind)=1)
    CALL echorecord(othercodevalues)
   ENDIF
 END ;Subroutine
 SUBROUTINE PUBLIC::populateothercodesetsuggestiondata(null)
   DECLARE num = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx1 = i4 WITH protect, noconstant(0)
   DECLARE qualcvindex = i4 WITH protect, noconstant(0)
   DECLARE suggestionsidx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE expand(num,1,size(othercodevalues->qual,5),cv.code_value,othercodevalues->qual[num].
     codevalue)
    DETAIL
     idx = (idx+ 1)
     FOR (idx1 = 1 TO size(othercodevalues->qual[idx].masteridxlist,5))
       qualcvindex = othercodevalues->qual[idx].masteridxlist.qualcvindex, suggestionsidx =
       othercodevalues->qual[idx].masteridxlist.suggestionsidx, reconciledata->qualcv[qualcvindex].
       suggestions[suggestionsidx].targetcdfmeaning = cv.cdf_meaning,
       reconciledata->qualcv[qualcvindex].suggestions[suggestionsidx].targetdisplaykey = cv
       .display_key, reconciledata->qualcv[qualcvindex].suggestions[suggestionsidx].targetdescription
        = cv.description
     ENDFOR
    WITH nocounter
   ;end select
   CALL errorcheck(reconciledata,"populateOtherCodeSetSugge")
 END ;Subroutine
 SUBROUTINE PUBLIC::populatecodeset93suggestiondata(null)
   RECORD event_request(
     1 query_mode = i4
     1 decode_flag = i2
     1 event_set_cd = f8
   ) WITH protect
   RECORD event_reply(
     1 sb
       2 severitycd = i4
     1 rb_list[*]
       2 self_cd = f8
       2 self_disp = vc
       2 self_name = vc
   ) WITH protect
   RECORD eventsetcontext(
     1 qual[*]
       2 eventsetparentfolder = vc
       2 contextpath = vc
   ) WITH protect
   DECLARE rsize = i4 WITH protect, noconstant(0)
   DECLARE contextsize = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE idx1 = i4 WITH protect, noconstant(0)
   DECLARE qualcvindex = i4 WITH protect, noconstant(0)
   DECLARE suggestionsidx = i4 WITH protect, noconstant(0)
   DECLARE targeteventsetname = vc WITH protect, noconstant("")
   DECLARE targeteventsetdisplay = vc WITH protect, noconstant("")
   DECLARE previousvalue = vc WITH protect, noconstant("")
   DECLARE contextpath = vc WITH protect, noconstant("")
   DECLARE targeteventsetparentfolder = vc WITH protect, noconstant("")
   DECLARE eventsetfoldername = vc WITH protect, noconstant("")
   DECLARE eventsetfolderdisplay = vc WITH protect, noconstant("")
   DECLARE recsize = i4 WITH protect, constant(size(eventset93codevalues->qual,5))
   SET event_request->query_mode = 256
   SET event_request->decode_flag = 1
   FOR (rsize = 1 TO recsize)
     SET stat = initrec(event_reply)
     SET contextsize = 0
     SET event_request->event_set_cd = eventset93codevalues->qual[rsize].codevalue
     SET stat = tdbexecute(3202004,3202004,1000013,"REC",event_request,
      "REC",event_reply,1)
     IF (stat != 0)
      SET reconciledata->status_data.status = "F"
      SET reconciledata->status_data.subeventstatus.targetobjectvalue = build2(
       "ERR:tdbexecute:1000013:","The call to the clinical event service failed")
      GO TO exit_script
     ELSEIF ((event_reply->sb.severitycd > 2))
      SET reconciledata->status_data.status = "F"
      SET reconciledata->status_data.subeventstatus.targetobjectvalue = build2(
       "ERR:tdbexecute:1000013:",
       "The service was contacted and it was able to process the request but the service identified a problem"
       )
      GO TO exit_script
     ENDIF
     IF (validate(debug_ind)=1)
      CALL echorecord(event_request)
      CALL echorecord(event_reply)
     ENDIF
     FOR (idx = 1 TO size(event_reply->rb_list,5))
       SET eventsetfoldername = event_reply->rb_list[idx].self_name
       SET eventsetfolderdisplay = event_reply->rb_list[idx].self_disp
       IF (idx=1)
        SET targeteventsetname = eventsetfoldername
        SET targeteventsetdisplay = eventsetfolderdisplay
        SET previousvalue = targeteventsetname
       ELSEIF (((trim(previousvalue,3)=trim(targeteventsetname,3)) OR (trim(previousvalue,3)=
       "ALL OCF EVENT SETS")) )
        SET targeteventsetparentfolder = eventsetfolderdisplay
       ELSE
        IF (trim(eventsetfoldername,3)="ALL OCF EVENT SETS")
         SET contextsize = (contextsize+ 1)
         SET stat = alterlist(eventsetcontext->qual,contextsize)
         SET eventsetcontext->qual[contextsize].eventsetparentfolder = targeteventsetparentfolder
         SET eventsetcontext->qual[contextsize].contextpath = build2(eventsetfolderdisplay,"->",
          contextpath,targeteventsetparentfolder,"->",
          targeteventsetdisplay)
         SET contextpath = ""
        ELSE
         SET contextpath = build2(eventsetfolderdisplay,"->",trim(contextpath,3))
        ENDIF
       ENDIF
       SET previousvalue = eventsetfoldername
     ENDFOR
     FOR (idx = 1 TO size(eventset93codevalues->qual[rsize].masteridxlist,5))
       SET qualcvindex = eventset93codevalues->qual[rsize].masteridxlist[idx].qualcvindex
       SET suggestionsidx = eventset93codevalues->qual[rsize].masteridxlist[idx].suggestionsidx
       SET reconciledata->qualcv[qualcvindex].suggestions[suggestionsidx].targeteventsetname =
       targeteventsetdisplay
       FOR (idx1 = 1 TO size(eventsetcontext->qual,5))
         SET stat = alterlist(reconciledata->qualcv[qualcvindex].suggestions[suggestionsidx].context,
          idx1)
         SET reconciledata->qualcv[qualcvindex].suggestions[suggestionsidx].context[idx1].
         parentfolder = eventsetcontext->qual[idx1].eventsetparentfolder
         SET reconciledata->qualcv[qualcvindex].suggestions[suggestionsidx].context[idx1].contextpath
          = eventsetcontext->qual[idx1].contextpath
       ENDFOR
     ENDFOR
   ENDFOR
 END ;Subroutine
 SET reconciledata->status_data.status = "S"
 IF (validate(_memory_reply_string)=false)
  DECLARE _memory_reply_string = vc WITH protect, noconstant("")
 ENDIF
 CALL main(null)
#exit_script
 SET _memory_reply_string = cnvtrectojson(reconciledata)
 IF ( $BDEBUG)
  CALL echorecord(reconciledata)
  CALL echo(_memory_reply_string)
 ENDIF
END GO
