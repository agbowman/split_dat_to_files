CREATE PROGRAM dash_cqd_comp_proc:dba
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
 RECORD json_data(
   1 num_comp = i4
   1 num_incomp = i4
   1 num_unspec = i4
   1 pct_comp = f8
   1 pct_incomp = f8
   1 pct_unspec = f8
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
    procedures->qual[pos].status = "Complete", json_data->num_comp = (json_data->num_comp+ 1)
   ELSEIF (((cecum_found=1) OR (terminalileum_found=1))
    AND procedureincomplete_found=1)
    procedures->qual[pos].status = "Unspecified", json_data->num_unspec = (json_data->num_unspec+ 1)
   ELSEIF (procedureincomplete_found=1)
    procedures->qual[pos].status = "Incomplete", json_data->num_incomp = (json_data->num_incomp+ 1)
   ELSE
    procedures->qual[pos].status = "Unspecified", json_data->num_unspec = (json_data->num_unspec+ 1)
   ENDIF
  FOOT REPORT
   null
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = procedures->qual_cnt)
  PLAN (d1
   WHERE (procedures->qual[d1.seq].term_found=0))
  DETAIL
   procedures->qual[d1.seq].status = "Unspecified", json_data->num_unspec = (json_data->num_unspec+ 1
   )
  WITH nocounter
 ;end select
 SET json_data->pct_comp = cnvtreal(((json_data->num_comp/ cnvtreal(procedures->qual_cnt)) * 100))
 SET json_data->pct_incomp = cnvtreal(((json_data->num_incomp/ cnvtreal(procedures->qual_cnt)) * 100)
  )
 SET json_data->pct_unspec = cnvtreal(((json_data->num_unspec/ cnvtreal(procedures->qual_cnt)) * 100)
  )
#exit_script
 IF ((((json_data->pct_comp+ json_data->pct_incomp)+ json_data->pct_unspec) > 0))
  SET chart_data->results = build2("[[",'["',trim(cnvtstring(json_data->pct_comp,5,0)),'%",',trim(
    cnvtstring(json_data->pct_comp,5,1)),
   "],",'["',trim(cnvtstring(json_data->pct_incomp,5,0)),'%",',trim(cnvtstring(json_data->pct_incomp,
     5,1)),
   "],",'[" ",',trim(cnvtstring(json_data->pct_unspec,5,1)),"]","]]")
 ELSE
  SET chart_data->results = ""
 ENDIF
 SET chart_data->status_data.status = "S"
 CALL putjsontofile(chart_data)
END GO
