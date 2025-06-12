CREATE PROGRAM dd_rdm_populate_ap:dba
 PROMPT
  "Start date in DD-MMM-YYYY format (defaults to 01-JUL-2019):    " = "01-JUL-2019",
  "End date in DD-MMM-YYYY format (defaults to current date):     " = "CURDATE",
  "Enter the number of days to process per batch (defaults to 1): " = "1"
  WITH sdttmstart, sdttmend, sbatchsize
 DECLARE querydocrows(batchdttmstart,batchdttmend) = null WITH protect
 DECLARE processpopulateap(null) = null WITH protect
 DECLARE extractapcontent(eventid) = i2 WITH protect
 DECLARE extractapcontentblob(null) = null WITH protect
 DECLARE findclosingdivpos(frompos,blob) = i4 WITH protect
 DECLARE validaterequest(null) = i2 WITH protect
 DECLARE enrichrequest(null) = i2 WITH protect
 DECLARE dttmstart = dq8 WITH protect, noconstant(cnvtdatetime(cnvtdate2( $SDTTMSTART,"DD-MMM-YYYY"),
   0))
 DECLARE dttmstartconst = dq8 WITH constant(dttmstart)
 DECLARE dttmend = dq8 WITH protect, noconstant(0)
 DECLARE bucketsize = f8 WITH constant(cnvtreal( $SBATCHSIZE))
 DECLARE successcount = i4 WITH noconstant(0)
 DECLARE failedcount = i4 WITH noconstant(0)
 IF (( $SDTTMEND="CURDATE"))
  SET dttmend = cnvtdatetime(curdate,curtime)
 ELSE
  SET dttmend = cnvtdatetime(cnvtdate2( $SDTTMEND,"DD-MMM-YYYY"),235959)
 ENDIF
 IF (datetimecmp(dttmstart,cnvtdatetime("01-JAN-2018")) < 0)
  GO TO endscript
 ENDIF
 IF (bucketsize < 1)
  GO TO endscript
 ENDIF
 FREE RECORD dd_doc_event_ids
 RECORD dd_doc_event_ids(
   1 list_ids[*]
     2 event_id = f8
 )
 FREE RECORD request
 RECORD request(
   1 service_dt_tm = dq8
   1 ap_contribution[*]
     2 person_id = f8
     2 doc_event_id = f8
     2 doc_row_reference_nbr = vc
     2 has_comment = c1
     2 diagnosis[*]
       3 diagnosis_id = f8
 )
 DECLARE totaldaterange = f8 WITH constant(datetimediff(dttmend,dttmstart))
 DECLARE numberofiteration = i4 WITH constant(ceil((cnvtreal(totaldaterange)/ cnvtreal(bucketsize))))
 DECLARE totalprocessedevents = f8 WITH noconstant(0)
 DECLARE batchdttmstart = f8 WITH noconstant(dttmstart)
 DECLARE batchdttmend = f8 WITH noconstant(datetimeadd(batchdttmstart,bucketsize))
 DECLARE iteration = i4 WITH noconstant(1)
 FOR (iteration = 1 TO numberofiteration)
   IF (iteration=numberofiteration)
    SET batchdttmend = dttmend
   ENDIF
   CALL querydocrows(batchdttmstart,batchdttmend)
   CALL processpopulateap(null)
   SET batchdttmstart = batchdttmend
   SET batchdttmend = datetimeadd(batchdttmstart,bucketsize)
   SET totalprocessedevents += size(dd_doc_event_ids->list_ids,5)
   SET stat = initrec(dd_doc_event_ids)
 ENDFOR
 CALL echo("")
 CALL echo(build("Total number of potentially affected events: ",(successcount+ failedcount)))
 CALL echo(build("Total Processed events: ",totalprocessedevents))
 CALL echo(build("Total number of successfully processed events: ",successcount))
 CALL echo(build("Total number of failed to process events: ",failedcount))
 SUBROUTINE querydocrows(batchdttmstart,batchdttmend)
   DECLARE ddoccd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
   DECLARE dddentrymodecd = f8 WITH constant(uar_get_code_by("MEANING",29520,"DYNDOC")), protect
   DECLARE icnt = i4 WITH noconstant(0), protect
   DECLARE dinauth = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
   DECLARE dinmodified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.event_end_dt_tm >= cnvtdatetime(batchdttmstart)
     AND ce.event_end_dt_tm < cnvtdatetime(batchdttmend)
     AND ce.event_class_cd=ddoccd
     AND ce.entry_mode_cd=dddentrymodecd
     AND ce.result_status_cd IN (dinauth, dinmodified)
    DETAIL
     icnt += 1
     IF (mod(icnt,500)=1)
      stat = alterlist(dd_doc_event_ids->list_ids,(icnt+ 499))
     ENDIF
     dd_doc_event_ids->list_ids[icnt].event_id = ce.event_id
    WITH nocounter
   ;end select
   IF (icnt != 0)
    SET stat = alterlist(dd_doc_event_ids->list_ids,icnt)
   ENDIF
 END ;Subroutine
 SUBROUTINE processpopulateap(null)
   DECLARE docfcompresscd = f8 WITH protect, noconstant(0.0)
   DECLARE docfnocompresscd = f8 WITH protect, noconstant(0.0)
   DECLARE apcontentexists = i2 WITH protect, noconstant(0)
   DECLARE ierror = i2 WITH protect, noconstant(0)
   DECLARE ireportidx = i4 WITH protect, noconstant(0)
   DECLARE ibloblength = i4 WITH protect, noconstant(0)
   DECLARE isearchres = i4 WITH protect, noconstant(0)
   DECLARE doc_event_cnt = i4 WITH protect, constant(size(dd_doc_event_ids->list_ids,5))
   DECLARE sblobcompressed = vc WITH protect, noconstant("")
   DECLARE icuridx = i4 WITH protect, noconstant(0)
   DECLARE sblobxhtml = vc WITH public, noconstant("")
   DECLARE apcontentblob = vc WITH public, noconstant("")
   SET stat = uar_get_meaning_by_codeset(120,"OCFCOMP",1,docfcompresscd)
   SET stat = uar_get_meaning_by_codeset(120,"NOCOMP",1,docfnocompresscd)
   FOR (icuridx = 1 TO doc_event_cnt)
     SET apcontentexists = 0
     SET ierror = 0
     SET sblobcompressed = " "
     SET sblobxhtml = ""
     SELECT INTO "nl:"
      FROM ce_blob c
      PLAN (c
       WHERE (c.event_id=dd_doc_event_ids->list_ids[icuridx].event_id))
      ORDER BY c.event_id, c.blob_seq_num
      HEAD c.event_id
       stat = memrealloc(sblobxhtml,1,build("C",c.blob_length))
      DETAIL
       isearchres = (findstring("ocf_blob",c.blob_contents,(size(trim(c.blob_contents)) - 10)) - 1)
       IF (isearchres < 1)
        isearchres = size(c.blob_contents)
       ENDIF
       sblobcompressed = notrim(concat(notrim(sblobcompressed),notrim(substring(1,isearchres,c
           .blob_contents))))
      FOOT  c.event_id
       sblobcompressed = concat(notrim(sblobcompressed),"ocf_blob")
       IF (c.compression_cd=docfcompresscd)
        stat = uar_ocf_uncompress(sblobcompressed,size(sblobcompressed),sblobxhtml,size(sblobxhtml),
         ibloblength)
       ELSEIF (c.compression_cd=docfnocompresscd)
        sblobxhtml = sblobcompressed
       ELSE
        ierror = 1
       ENDIF
      WITH nocounter
     ;end select
     IF (ierror=1)
      CALL echo("Unhandled compression code")
     ELSEIF (sblobxhtml != "")
      SET apcontentexists = extractapcontent(dd_doc_event_ids->list_ids[icuridx].event_id)
      IF (apcontentexists > 0)
       SET reqinfo->commit_ind = 0
       EXECUTE dd_ens_assessplan
       IF ((reqinfo->commit_ind=1))
        SET successcount += 1
        COMMIT
       ELSE
        SET failedcount += 1
        CALL echo(build("Error: Failed to pre-populate content for doc event ID:",dd_doc_event_ids->
          list_ids[icuridx].event_id))
        ROLLBACK
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE extractapcontent(eventid)
   DECLARE inextdivopenpos = i4 WITH noconstant(0), protect
   DECLARE idivopenend = i4 WITH noconstant(0), protect
   DECLARE idiagcontentattrpos = i4 WITH noconstant(0), protect
   DECLARE idiagidattrpos = i4 WITH noconstant(0), protect
   DECLARE iddfreetextclasspos = i4 WITH noconstant(0), protect
   DECLARE diagnosescnt = i4 WITH noconstant(0), protect
   DECLARE diagnosesid = f8 WITH noconstant(0), protect
   DECLARE requestinitialized = i2 WITH noconstant(0), protect
   CALL extractapcontentblob(null)
   IF (apcontentblob="")
    RETURN(0)
   ENDIF
   DECLARE fromposlocal = i4 WITH noconstant(0), protect
   DECLARE max_iteration = i4 WITH constant(1000), protect
   DECLARE iterationcount = i4 WITH noconstant(0), protect
   SET inextdivopenpos = findstring("<div",apcontentblob,fromposlocal)
   SET stat = alterlist(request->ap_contribution,1)
   SET stat = alterlist(request->ap_contribution[1].diagnosis,10)
   SET request->ap_contribution.has_comment = "N"
   SET diagnosescnt = 1
   WHILE (inextdivopenpos > 0
    AND iterationcount < max_iteration)
     SET iterationcount += 1
     IF (inextdivopenpos > 0)
      SET idivopenend = findstring(">",apcontentblob,inextdivopenpos)
      IF (idivopenend=0)
       CALL echo(build("Error: Couldn't find the DIV End (>). Event ID: ",eventid))
       RETURN(0)
      ENDIF
      SET idiagcontentattrpos = findstring('dd:contenttype="DIAGNOSES"',apcontentblob,inextdivopenpos
       )
      IF (idiagcontentattrpos > 0
       AND idiagcontentattrpos < idivopenend)
       SET idiagidattrpos = findstring('dd:entityid="',apcontentblob,inextdivopenpos)
       IF (idiagidattrpos > 0
        AND idiagidattrpos < idivopenend)
        SET diagnosesid = cnvtint(substring((idiagidattrpos+ 13),((findstring('"',apcontentblob,(
           idiagidattrpos+ 15)) - idiagidattrpos) - 13),apcontentblob))
        IF (diagnosesid > 0)
         SET request->ap_contribution[1].diagnosis[diagnosescnt].diagnosis_id = diagnosesid
         SET diagnosescnt += 1
        ENDIF
       ENDIF
       SET fromposlocal = findclosingdivpos((inextdivopenpos+ 3),apcontentblob)
       IF (fromposlocal=0)
        CALL echo(build("Error: Couldn't define the Closing DIV, ignore processing event ID: ",
          eventid))
        RETURN(0)
       ENDIF
      ELSE
       SET iddfreetextclasspos = findstring("ddfreetext",apcontentblob,inextdivopenpos)
       IF (iddfreetextclasspos > 0
        AND iddfreetextclasspos < idivopenend)
        IF (((findclosingdivpos((inextdivopenpos+ 3),apcontentblob) - idivopenend) > 1))
         SET request->ap_contribution.has_comment = "Y"
        ENDIF
       ENDIF
       SET fromposlocal = idivopenend
      ENDIF
     ENDIF
     SET inextdivopenpos = findstring("<div",apcontentblob,fromposlocal)
   ENDWHILE
   SET stat = alterlist(request->ap_contribution[1].diagnosis,(diagnosescnt - 1))
   SET request->ap_contribution[1].doc_event_id = eventid
   SET requestinitialized = validaterequest(null)
   IF (requestinitialized > 0)
    RETURN(enrichrequest(null))
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE extractapcontentblob(null)
   DECLARE iapcompattrtpos = i4 WITH protect, noconstant(findstring(
     "CERNER!3AAB66F1-295B-4ADA-BE1C-D2E29461E861",sblobxhtml))
   SET apcontentblob = ""
   IF (iapcompattrtpos > 0)
    DECLARE iapcompcontentpos = i4 WITH protect, noconstant(findstring("<div",sblobxhtml,
      iapcompattrtpos))
    DECLARE iapcompclosepos = i4 WITH protect, noconstant(findclosingdivpos((iapcompcontentpos+ 4),
      sblobxhtml))
    IF (iapcompclosepos=0)
     CALL echo(build(
       "Error: Couldn't extract AP EMR content - couldn't identify the closing DIV. Attr pos:",
       iapcompattrtpos))
    ELSE
     SET apcontentblob = trim(substring(iapcompcontentpos,((iapcompclosepos - iapcompcontentpos)+ 6),
       sblobxhtml),4)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE findclosingdivpos(frompos,blob)
   DECLARE divopencount = i4 WITH noconstant(1), protect
   DECLARE iterationcount = i4 WITH noconstant(0), protect
   DECLARE idivclosepos = i4 WITH noconstant(0), protect
   DECLARE fromposlocal = i4 WITH noconstant(frompos), protect
   DECLARE idivopenpos = i4 WITH noconstant(0), protect
   DECLARE max_iteration = i4 WITH constant(1000), protect
   WHILE (divopencount > 0
    AND iterationcount < max_iteration)
     SET iterationcount += 1
     SET idivopenpos = findstring("<div",blob,fromposlocal)
     SET idivclosepos = findstring("</div>",blob,fromposlocal)
     IF (idivopenpos > 0
      AND idivopenpos < idivclosepos)
      SET divopencount += 1
      SET fromposlocal = (idivopenpos+ 4)
     ELSEIF (idivclosepos > 0)
      SET divopencount -= 1
      SET fromposlocal = (idivclosepos+ 6)
     ELSE
      CALL echo("Error: Couldn't find the closing DIV!")
      RETURN(0)
     ENDIF
   ENDWHILE
   RETURN(idivclosepos)
 END ;Subroutine
 SUBROUTINE validaterequest(null)
   IF (size(request->ap_contribution,5) < 1)
    RETURN(0)
   ENDIF
   IF (size(request->ap_contribution.diagnosis,5) > 0)
    RETURN(1)
   ENDIF
   IF ((request->ap_contribution.has_comment="Y"))
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE enrichrequest(null)
   SELECT DISTINCT INTO "nl:"
    FROM clinical_event ce
    WHERE (ce.event_id=request->ap_contribution[1].doc_event_id)
    DETAIL
     request->service_dt_tm = ce.event_end_dt_tm, reqinfo->updt_applctx = ce.updt_applctx, reqinfo->
     updt_id = ce.updt_id,
     reqinfo->updt_task = ce.updt_task
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(build("Error: Couldn't find the clinical_event row for event ID: ",request->
      ap_contribution[1].doc_event_id))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#endscript
END GO
