CREATE PROGRAM dash_cqd_comp_proc_det:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Provider ID" = 0,
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, provider_id, beg_date,
  end_date
 DECLARE prompt_bdate = vc WITH protect, noconstant( $BEG_DATE)
 DECLARE prompt_edate = vc WITH protect, noconstant( $END_DATE)
 IF (size(trim( $BEG_DATE))=19)
  SET prompt_bdate = build2("0",trim(prompt_bdate,3))
 ENDIF
 IF (size(trim( $END_DATE))=19)
  SET prompt_edate = build2("0",trim(prompt_edate,3))
 ENDIF
 DECLARE bdate = dq8 WITH protect, noconstant(cnvtdatetime(prompt_bdate))
 DECLARE edate = dq8 WITH protect, noconstant(cnvtdatetime(prompt_edate))
 IF (((( $PROVIDER_ID=0)) OR (null)) )
  DECLARE provider_parser = vc WITH protect, constant("1=1")
 ELSE
  DECLARE provider_parser = vc WITH protect, constant(build("ss.author_id IN (", $PROVIDER_ID,")"))
 ENDIF
 DECLARE cs8auth = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2628"))
 DECLARE cs8altered = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!16901"))
 DECLARE cs8modified = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2636"))
 DECLARE cs57male = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2773"))
 DECLARE cs57female = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2774"))
 DECLARE cs319finnbr = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2930"))
 DECLARE cs14409encounterpathway = f8 WITH protect, constant(uar_get_code_by_cki(
   "CKI.CODEVALUE!11707"))
 DECLARE cs15751true = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!13769"))
 DECLARE tidanatomicabnormality = f8 WITH protect, constant(gettermidfromcki(
   "CKI.CODEVALUE!4114081763"))
 DECLARE tidcecum = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081766"))
 DECLARE tidgood = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081760"))
 DECLARE tidinadequate = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081762"))
 DECLARE tidother = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081751"))
 DECLARE tidpolyp = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081768"))
 DECLARE tidpoor = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081748"))
 DECLARE tidpoorprep = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081749"))
 DECLARE tidprocedureincomplete = f8 WITH protect, constant(gettermidfromcki(
   "CKI.CODEVALUE!4114081765"))
 DECLARE tidrecurrentsigmoidlooping = f8 WITH protect, constant(gettermidfromcki(
   "CKI.CODEVALUE!4114081750"))
 DECLARE tidstricture = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081764"))
 DECLARE tidsufficient = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081761"))
 DECLARE tidterminalileum = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081767"))
 DECLARE tidverygood = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081747"))
 DECLARE tidproceduredate = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114081680"))
 DECLARE tidprocedure = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114141248"))
 DECLARE tidpreproceduredx = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114141780"))
 DECLARE tidpostproceduredx = f8 WITH protect, constant(gettermidfromcki("CKI.CODEVALUE!4114141781"))
 DECLARE ckisource = vc WITH protect, constant("CKIGI")
 DECLARE ckisourceidentifier = vc WITH protect, constant("EPR PROC GI COLONOSCOPY")
 DECLARE ep_parser = vc WITH protect, noconstant(build2("sp.cki_identifier in ('",ckisourceidentifier,
   "')"))
 DECLARE idx = i2 WITH protect, noconstant(0)
 DECLARE svalue = vc WITH protect, noconstant(" ")
 RECORD chart_data(
   1 results = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD terms(
   1 qual_cnt = i4
   1 qual[*]
     2 term_disp = vc
     2 term_id = f8
     2 term_validated = i2
 )
 RECORD procedures(
   1 male_qual_cnt = i4
   1 female_qual_cnt = i4
   1 qual_cnt = i4
   1 qual[*]
     2 note_cki_identifier = vc
     2 scd_story_id = f8
     2 fin = vc
     2 patient_name = vc
     2 service_dt_tm = dq8
     2 subject = vc
     2 author = vc
     2 status = vc
     2 term_found = i2
     2 sex_cd = f8
     2 procedure_date = vc
     2 procedure = vc
     2 preprocedure_dx = vc
     2 postprocedure_dx = vc
 )
 DECLARE validateterms(null) = null
 SUBROUTINE validateterms(null)
   SELECT INTO "nl:"
    FROM scr_term st
    PLAN (st
     WHERE expand(idx,1,terms->qual_cnt,st.scr_term_id,terms->qual[idx].term_id)
      AND st.active_ind=1)
    DETAIL
     pos = locateval(idx,1,terms->qual_cnt,st.scr_term_id,terms->qual[idx].term_id), terms->qual[pos]
     .term_validated = 1,
     CALL echo(build("recording-",st.scr_term_id))
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 DECLARE getprocedures(null) = null
 SUBROUTINE getprocedures(null)
  SELECT INTO "nl:"
   FROM scr_pattern sp,
    scd_story_pattern ssp,
    scd_story ss,
    clinical_event ce,
    encntr_alias fin,
    person p,
    prsnl pr
   PLAN (sp
    WHERE parser(ep_parser)
     AND sp.pattern_type_cd=cs14409encounterpathway)
    JOIN (ssp
    WHERE ssp.scr_pattern_id=sp.scr_pattern_id
     AND ssp.pattern_type_cd=cs14409encounterpathway)
    JOIN (ss
    WHERE ss.scd_story_id=ssp.scd_story_id
     AND parser(provider_parser))
    JOIN (ce
    WHERE ce.event_id=ss.event_id
     AND ce.event_end_dt_tm BETWEEN cnvtdatetime(bdate) AND cnvtdatetime(edate)
     AND ce.result_status_cd IN (cs8auth, cs8altered, cs8modified)
     AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
    JOIN (fin
    WHERE fin.encntr_id=ss.encounter_id
     AND fin.encntr_alias_type_cd=cs319finnbr
     AND fin.active_ind=1
     AND fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fin.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (p
    WHERE p.person_id=ss.person_id)
    JOIN (pr
    WHERE pr.person_id=ss.author_id)
   ORDER BY ss.scd_story_id
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,100)=1)
     stat = alterlist(procedures->qual,(cnt+ 99))
    ENDIF
    procedures->qual[cnt].note_cki_identifier = sp.cki_identifier, procedures->qual[cnt].scd_story_id
     = ss.scd_story_id, procedures->qual[cnt].fin = cnvtalias(fin.alias,fin.alias_pool_cd),
    procedures->qual[cnt].patient_name = p.name_full_formatted, procedures->qual[cnt].service_dt_tm
     = ce.event_end_dt_tm, procedures->qual[cnt].subject = ss.title,
    procedures->qual[cnt].author = pr.name_full_formatted, procedures->qual[cnt].sex_cd = p.sex_cd
    IF (p.sex_cd=cs57male)
     procedures->male_qual_cnt = (procedures->male_qual_cnt+ 1)
    ELSEIF (p.sex_cd=cs57female)
     procedures->female_qual_cnt = (procedures->female_qual_cnt+ 1)
    ENDIF
   FOOT REPORT
    procedures->qual_cnt = cnt, stat = alterlist(procedures->qual,cnt)
   WITH nocounter
  ;end select
  IF ((procedures->qual_cnt=0))
   GO TO exit_script
  ENDIF
 END ;Subroutine
 DECLARE gettermidfromcki(cki_value=vc(val)) = f8
 SUBROUTINE gettermidfromcki(cki_value)
   DECLARE termid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM scr_term st,
     scr_term_definition std
    PLAN (st
     WHERE st.active_ind=1)
     JOIN (std
     WHERE std.scr_term_def_id=st.scr_term_def_id
      AND std.def_text=cki_value)
    DETAIL
     termid = std.scr_term_def_id
    WITH nocounter
   ;end select
   RETURN(termid)
 END ;Subroutine
 DECLARE putjsontofile(record_data=vc(ref)) = null
 SUBROUTINE putjsontofile(record_data)
  SET svalue = cnvtrectojson(record_data)
  IF (validate(_memory_reply_string)=1)
   SET _memory_reply_string = svalue
  ELSE
   FREE RECORD putrequest
   RECORD putrequest(
     1 source_dir = vc
     1 source_filename = vc
     1 nbrlines = i4
     1 line[*]
       2 linedata = vc
     1 overflowpage[*]
       2 ofr_qual[*]
         3 ofr_line = vc
     1 isblob = c1
     1 document_size = i4
     1 document = gvc
   )
   SET putrequest->source_dir =  $OUTDEV
   SET putrequest->isblob = "1"
   SET putrequest->document = svalue
   SET putrequest->document_size = size(putrequest->document)
   EXECUTE eks_put_source  WITH replace("REQUEST",putrequest), replace("REPLY",putreply)
  ENDIF
 END ;Subroutine
 DECLARE addtermid(scd_term_id=f8,scr_term_id=f8,position=i4) = null
 DECLARE term_display_text = vc WITH noconstant(""), protect
 DECLARE cs15752data = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!10212"))
 DECLARE cs15752infonote = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!519151"))
 DECLARE inbuffer = vc WITH noconstant(""), protect
 DECLARE inbuflen = i4 WITH noconstant(0), protect
 DECLARE outbuffer = c1000 WITH noconstant(""), protect
 DECLARE outbuflen = i4 WITH noconstant(1000), protect
 DECLARE retbuflen = i4 WITH noconstant(0), protect
 DECLARE bflag = i4 WITH noconstant(0), protect
 SET ep_parser = build2("sp.cki_identifier in ('",ckisourceidentifier,"'",",'EP ERCP PROCEDURE FH'",
  ",'EP EGD PROCEDURE FH'",
  ",'EP ENTEROSCOPY PROCEDURE FH'",",'EP EUS PROCEDURE FH')")
 RECORD detail_data(
   1 results[*]
     2 values[7]
       3 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD term_display(
   1 qual_cnt = i4
   1 qual[*]
     2 scd_term_id = f8
     2 term_display = vc
 )
 RECORD json_data(
   1 qual_cnt = i4
   1 qual[*]
     2 scd_story_id = f8
     2 procedure_date = vc
     2 tprocedure_date_qual_cnt = i4
     2 tprocedure_date_qual[*]
       3 scd_term_id = f8
     2 name = vc
     2 fin = vc
     2 procedure = vc
     2 tprocedure_qual_cnt = i4
     2 tprocedure_qual[*]
       3 scd_term_id = f8
     2 preprocedure_dx = vc
     2 tpreprocedure_dx_qual_cnt = i4
     2 tpreprocedure_dx_qual[*]
       3 scd_term_id = f8
     2 postprocedure_dx = vc
     2 tpostprocedure_dx_qual_cnt = i4
     2 tpostprocedure_dx_qual[*]
       3 scd_term_id = f8
     2 status = vc
 )
 SET terms->qual_cnt = 3
 SET stat = alterlist(terms->qual,terms->qual_cnt)
 SET terms->qual[1].term_disp = "Cecum+"
 SET terms->qual[1].term_id = tidcecum
 SET terms->qual[2].term_disp = "Terminal ileum+"
 SET terms->qual[2].term_id = tidterminalileum
 SET terms->qual[3].term_disp = "Procedure incomplete+"
 SET terms->qual[3].term_id = tidprocedureincomplete
 CALL validateterms(null)
 CALL getprocedures(null)
 SELECT INTO "nl:"
  FROM scd_term st
  PLAN (st
   WHERE expand(idx,1,procedures->qual_cnt,st.scd_story_id,procedures->qual[idx].scd_story_id)
    AND expand(idx,1,terms->qual_cnt,st.scr_term_id,terms->qual[idx].term_id)
    AND st.truth_state_cd=cs15751true
    AND st.active_ind=1
    AND st.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND st.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY st.scd_story_id, st.scr_term_id
  HEAD REPORT
   null
  HEAD st.scd_story_id
   cecum_found = 0, terminalileum_found = 0, procedureincomplete_found = 0
  DETAIL
   CASE (st.scr_term_id)
    OF tidcecum:
     cecum_found = 1
    OF tidterminalileum:
     terminalileum_found = 1
    OF tidprocedureincomplete:
     procedureincomplete_found = 1
   ENDCASE
  FOOT  st.scd_story_id
   pos = locatevalsort(idx,1,procedures->qual_cnt,st.scd_story_id,procedures->qual[idx].scd_story_id),
   procedures->qual[pos].term_found = 1
   IF (((cecum_found=1) OR (terminalileum_found=1))
    AND procedureincomplete_found=0)
    procedures->qual[pos].status = "Complete"
   ELSEIF (((cecum_found=1) OR (terminalileum_found=1))
    AND procedureincomplete_found=1)
    procedures->qual[pos].status = "Unspecified"
   ELSEIF (procedureincomplete_found=1)
    procedures->qual[pos].status = "Incomplete"
   ELSE
    procedures->qual[pos].status = "Unspecified"
   ENDIF
  FOOT REPORT
   null
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = procedures->qual_cnt)
  PLAN (d1
   WHERE (((procedures->qual[d1.seq].term_found=0)) OR ((procedures->qual[d1.seq].note_cki_identifier
    != ckisourceidentifier))) )
  DETAIL
   IF ((procedures->qual[d1.seq].note_cki_identifier != ckisourceidentifier))
    procedures->qual[d1.seq].status = "n/a"
   ELSE
    procedures->qual[d1.seq].status = "Unspecified"
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  FROM (dummyt d1  WITH seq = procedures->qual_cnt)
  HEAD REPORT
   cnt = 0, stat = alterlist(json_data->qual,procedures->qual_cnt)
  DETAIL
   cnt = (cnt+ 1), json_data->qual[cnt].scd_story_id = procedures->qual[d1.seq].scd_story_id,
   json_data->qual[cnt].fin = procedures->qual[d1.seq].fin,
   json_data->qual[cnt].name = procedures->qual[d1.seq].patient_name, json_data->qual[cnt].status =
   procedures->qual[d1.seq].status
  FOOT REPORT
   json_data->qual_cnt = cnt
  WITH nocounter
 ;end select
 SET stat = initrec(terms)
 SET terms->qual_cnt = 4
 SET stat = alterlist(terms->qual,terms->qual_cnt)
 SET terms->qual[1].term_disp = "Procedure Date"
 SET terms->qual[1].term_id = tidproceduredate
 SET terms->qual[2].term_disp = "Procedure"
 SET terms->qual[2].term_id = tidprocedure
 SET terms->qual[3].term_disp = "Preprocedure Dx"
 SET terms->qual[3].term_id = tidpreproceduredx
 SET terms->qual[4].term_disp = "Postprocedure Dx"
 SET terms->qual[4].term_id = tidpostproceduredx
 CALL validateterms(null)
 SELECT INTO "nl:"
  FROM scd_term st,
   scd_term st1
  PLAN (st
   WHERE expand(idx,1,json_data->qual_cnt,st.scd_story_id,json_data->qual[idx].scd_story_id)
    AND expand(idx,1,terms->qual_cnt,st.scr_term_id,terms->qual[idx].term_id))
   JOIN (st1
   WHERE st1.scd_sentence_id=st.scd_sentence_id
    AND st1.scd_story_id=st.scd_story_id
    AND st1.scr_term_id != st.scr_term_id)
  ORDER BY st.scd_story_id, st.scr_term_id, st1.scr_term_hier_id
  HEAD st.scd_story_id
   pos = locatevalsort(idx,1,procedures->qual_cnt,st.scd_story_id,procedures->qual[idx].scd_story_id)
  HEAD st.scr_term_id
   null
  DETAIL
   CASE (st.scr_term_id)
    OF tidproceduredate:
     CALL addtermid(st1.scd_term_id,st.scr_term_id,pos)
    OF tidprocedure:
     CALL addtermid(st1.scd_term_id,st.scr_term_id,pos)
    OF tidpreproceduredx:
     CALL addtermid(st1.scd_term_id,st.scr_term_id,pos)
    OF tidpostproceduredx:
     CALL addtermid(st1.scd_term_id,st.scr_term_id,pos)
   ENDCASE
  FOOT  st.scr_term_id
   CASE (st.scr_term_id)
    OF tidproceduredate:
     stat = alterlist(json_data->qual[pos].tprocedure_date_qual,json_data->qual[pos].
      tprocedure_date_qual_cnt)
    OF tidprocedure:
     stat = alterlist(json_data->qual[pos].tprocedure_qual,json_data->qual[pos].tprocedure_qual_cnt)
    OF tidpreproceduredx:
     stat = alterlist(json_data->qual[pos].tpreprocedure_dx_qual,json_data->qual[pos].
      tpreprocedure_dx_qual_cnt)
    OF tidpostproceduredx:
     stat = alterlist(json_data->qual[pos].tpostprocedure_dx_qual,json_data->qual[pos].
      tpostprocedure_dx_qual_cnt)
   ENDCASE
  FOOT  st.scd_story_id
   null
  FOOT REPORT
   stat = alterlist(term_display->qual,term_display->qual_cnt)
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM scd_term st,
   scr_term_text stt,
   scd_term_data std,
   (left JOIN diagnosis d ON d.diagnosis_id=std.fkey_id
    AND "DIAGNOSIS"=std.fkey_entity_name),
   (left JOIN nomenclature n ON n.nomenclature_id=d.nomenclature_id)
  PLAN (st
   WHERE expand(idx,1,term_display->qual_cnt,st.scd_term_id,term_display->qual[idx].scd_term_id))
   JOIN (stt
   WHERE stt.scr_term_id=st.scr_term_id)
   JOIN (std
   WHERE std.scd_term_data_id=st.scd_term_data_id)
   JOIN (d)
   JOIN (n)
  ORDER BY st.scd_term_id, std.scd_term_data_type_cd
  HEAD st.scd_term_id
   term_display_text = "", outbuffer = "", dxind = 0,
   pos = locateval(idx,1,term_display->qual_cnt,st.scd_term_id,term_display->qual[idx].scd_term_id)
   IF (stt.text_representation="Dx Code Search")
    dxind = 1
   ENDIF
  DETAIL
   IF (st.scd_term_data_id=0)
    term_display_text = stt.text_representation
   ELSEIF (std.scd_term_data_type_cd=value(uar_get_code_by_cki("CKI.CODEVALUE!10212")))
    term_display_text = trim(replace(stt.text_representation," ===",build2(" ",trim(std.value_text),
       " ")),3), term_display_text = trim(replace(term_display_text,"=== ",build2(" ",trim(std
        .value_text)," ")),3), term_display_text = trim(replace(term_display_text," === ",build2(" ",
       trim(std.value_text)," ")),3),
    term_display_text = trim(replace(term_display_text,"===",build2(" ",trim(std.value_text)," ")),3),
    term_display_text = trim(replace(term_display_text,"[name of physician]",build2(" ",trim(std
        .value_text)," ")),3)
   ELSEIF (dxind)
    IF (d.diagnosis_id != 0)
     IF (n.nomenclature_id != 0)
      term_display_text = build2(trim(n.source_string)," (",trim(n.source_identifier),")")
     ELSE
      term_display_text = d.diagnosis_display
     ENDIF
    ENDIF
   ELSEIF (std.scd_term_data_type_cd=value(uar_get_code_by_cki("CKI.CODEVALUE!519151")))
    IF (std.fkey_id=0)
     inbuffer = trim(replace(std.value_text,"__{ScdBlockedTextDataTag}__"," "),3), inbuflen = size(
      inbuffer), stat = uar_rtf(inbuffer,inbuflen,outbuffer,outbuflen,retbuflen,
      bflag),
     term_display_text = outbuffer
    ENDIF
   ENDIF
  FOOT  st.scd_term_id
   term_display->qual[pos].term_display = term_display_text
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = json_data->qual_cnt)
  DETAIL
   FOR (pdatecnt = 1 TO json_data->qual[d1.seq].tprocedure_date_qual_cnt)
    pos = locateval(idx,1,term_display->qual_cnt,json_data->qual[d1.seq].tprocedure_date_qual[
     pdatecnt].scd_term_id,term_display->qual[idx].scd_term_id),
    IF (pdatecnt=1)
     json_data->qual[d1.seq].procedure_date = term_display->qual[pos].term_display
    ELSE
     json_data->qual[d1.seq].procedure_date = build2(json_data->qual[d1.seq].procedure_date," ",
      term_display->qual[pos].term_display)
    ENDIF
   ENDFOR
   FOR (pnamecnt = 1 TO json_data->qual[d1.seq].tprocedure_qual_cnt)
    pos = locateval(idx,1,term_display->qual_cnt,json_data->qual[d1.seq].tprocedure_qual[pnamecnt].
     scd_term_id,term_display->qual[idx].scd_term_id),
    IF (pnamecnt=1)
     json_data->qual[d1.seq].procedure = term_display->qual[pos].term_display
    ELSE
     json_data->qual[d1.seq].procedure = build2(json_data->qual[d1.seq].procedure," ",term_display->
      qual[pos].term_display)
    ENDIF
   ENDFOR
   FOR (predxcnt = 1 TO json_data->qual[d1.seq].tpreprocedure_dx_qual_cnt)
    pos = locateval(idx,1,term_display->qual_cnt,json_data->qual[d1.seq].tpreprocedure_dx_qual[
     predxcnt].scd_term_id,term_display->qual[idx].scd_term_id),
    IF (predxcnt=1)
     json_data->qual[d1.seq].preprocedure_dx = term_display->qual[pos].term_display
    ELSE
     json_data->qual[d1.seq].preprocedure_dx = build2(json_data->qual[d1.seq].preprocedure_dx," ",
      term_display->qual[pos].term_display)
    ENDIF
   ENDFOR
   FOR (postdxcnt = 1 TO json_data->qual[d1.seq].tpostprocedure_dx_qual_cnt)
    pos = locateval(idx,1,term_display->qual_cnt,json_data->qual[d1.seq].tpostprocedure_dx_qual[
     postdxcnt].scd_term_id,term_display->qual[idx].scd_term_id),
    IF (postdxcnt=1)
     json_data->qual[d1.seq].postprocedure_dx = term_display->qual[pos].term_display
    ELSE
     json_data->qual[d1.seq].postprocedure_dx = build2(json_data->qual[d1.seq].postprocedure_dx," ",
      term_display->qual[pos].term_display)
    ENDIF
   ENDFOR
  WITH nocounter
 ;end select
#exit_script
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = json_data->qual_cnt)
  HEAD REPORT
   cnt = 1, stat = alterlist(detail_data->results,(cnt+ 50)), detail_data->results[cnt].values[1].
   value = "procedure_date",
   detail_data->results[cnt].values[2].value = "name", detail_data->results[cnt].values[3].value =
   "fin", detail_data->results[cnt].values[4].value = "procedure",
   detail_data->results[cnt].values[5].value = "preprocedure_dx", detail_data->results[cnt].values[6]
   .value = "postprocedure_dx", detail_data->results[cnt].values[7].value = "status"
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(detail_data->results,5))
    stat = alterlist(detail_data->results,(cnt+ 50))
   ENDIF
   detail_data->results[cnt].values[1].value = replace(json_data->qual[d1.seq].procedure_date,'"',"'"
    ), detail_data->results[cnt].values[2].value = replace(json_data->qual[d1.seq].name,'"',"'"),
   detail_data->results[cnt].values[3].value = replace(json_data->qual[d1.seq].fin,'"',"'"),
   detail_data->results[cnt].values[4].value = replace(json_data->qual[d1.seq].procedure,'"',"'"),
   detail_data->results[cnt].values[5].value = replace(json_data->qual[d1.seq].preprocedure_dx,'"',
    "'"), detail_data->results[cnt].values[6].value = replace(json_data->qual[d1.seq].
    postprocedure_dx,'"',"'"),
   detail_data->results[cnt].values[7].value = replace(json_data->qual[d1.seq].status,'"',"'")
  FOOT REPORT
   stat = alterlist(detail_data->results,cnt)
  WITH nocounter
 ;end select
 SET detail_data->status_data.status = "S"
 CALL putjsontofile(detail_data)
 SUBROUTINE addtermid(scd_term_id,scr_term_id,position)
   SET term_display->qual_cnt = (term_display->qual_cnt+ 1)
   IF ((term_display->qual_cnt > size(term_display->qual,5)))
    SET stat = alterlist(term_display->qual,(term_display->qual_cnt+ 50))
   ENDIF
   SET term_display->qual[term_display->qual_cnt].scd_term_id = scd_term_id
   CASE (scr_term_id)
    OF tidproceduredate:
     SET json_data->qual[position].tprocedure_date_qual_cnt = (json_data->qual[position].
     tprocedure_date_qual_cnt+ 1)
     SET aticnt = json_data->qual[position].tprocedure_date_qual_cnt
     IF (aticnt > size(json_data->qual[position].tprocedure_date_qual,5))
      SET stat = alterlist(json_data->qual[position].tprocedure_date_qual,(aticnt+ 10))
     ENDIF
     SET json_data->qual[position].tprocedure_date_qual[aticnt].scd_term_id = scd_term_id
    OF tidprocedure:
     SET json_data->qual[position].tprocedure_qual_cnt = (json_data->qual[position].
     tprocedure_qual_cnt+ 1)
     SET aticnt = json_data->qual[position].tprocedure_qual_cnt
     IF (aticnt > size(json_data->qual[position].tprocedure_qual,5))
      SET stat = alterlist(json_data->qual[position].tprocedure_qual,(aticnt+ 10))
     ENDIF
     SET json_data->qual[position].tprocedure_qual[aticnt].scd_term_id = scd_term_id
    OF tidpreproceduredx:
     SET json_data->qual[position].tpreprocedure_dx_qual_cnt = (json_data->qual[position].
     tpreprocedure_dx_qual_cnt+ 1)
     SET aticnt = json_data->qual[position].tpreprocedure_dx_qual_cnt
     IF (aticnt > size(json_data->qual[position].tpreprocedure_dx_qual,5))
      SET stat = alterlist(json_data->qual[position].tpreprocedure_dx_qual,(aticnt+ 10))
     ENDIF
     SET json_data->qual[position].tpreprocedure_dx_qual[aticnt].scd_term_id = scd_term_id
    OF tidpostproceduredx:
     SET json_data->qual[position].tpostprocedure_dx_qual_cnt = (json_data->qual[position].
     tpostprocedure_dx_qual_cnt+ 1)
     SET aticnt = json_data->qual[position].tpostprocedure_dx_qual_cnt
     IF (aticnt > size(json_data->qual[position].tpostprocedure_dx_qual,5))
      SET stat = alterlist(json_data->qual[position].tpostprocedure_dx_qual,(aticnt+ 10))
     ENDIF
     SET json_data->qual[position].tpostprocedure_dx_qual[aticnt].scd_term_id = scd_term_id
   ENDCASE
 END ;Subroutine
END GO
