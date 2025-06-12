CREATE PROGRAM dash_cqd_qual_timeline:dba
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
 SET bdate = datetimefind(cnvtdatetime(bdate),"M","B","B")
 SET edate = datetimefind(cnvtdatetime(edate),"M","E","E")
 DECLARE tbdate = dq8 WITH protect, constant(cnvtlookbehind("1,D",cnvtdatetime(bdate)))
 DECLARE tedate = dq8 WITH protect, constant(cnvtlookahead("1,D",cnvtdatetime(edate)))
 RECORD json_data(
   1 month_cnt = i4
   1 month_qual[*]
     2 yearmonth = i4
     2 datalabel = vc
     2 procedures_denom = i4
     2 male_denom = i4
     2 female_denom = i4
     2 bowel_prep_denom = i4
     2 num_cecum = i4
     2 num_polypmale = i4
     2 num_polypfemale = i4
     2 num_bowel_prep = f8
     2 pct_cecum = f8
     2 pct_polypmale = f8
     2 pct_polypfemale = f8
     2 pct_bowel_prep = f8
 )
 SET terms->qual_cnt = 8
 SET stat = alterlist(terms->qual,terms->qual_cnt)
 SET terms->qual[1].term_disp = "Cecum+"
 SET terms->qual[1].term_id = tidcecum
 SET terms->qual[2].term_disp = "Terminal ileum+"
 SET terms->qual[2].term_id = tidterminalileum
 SET terms->qual[3].term_disp = "Polyp"
 SET terms->qual[3].term_id = tidpolyp
 SET terms->qual[4].term_disp = "very good"
 SET terms->qual[4].term_id = tidverygood
 SET terms->qual[5].term_disp = "good"
 SET terms->qual[5].term_id = tidgood
 SET terms->qual[6].term_disp = "sufficient"
 SET terms->qual[6].term_id = tidsufficient
 SET terms->qual[7].term_disp = "poor"
 SET terms->qual[7].term_id = tidpoor
 SET terms->qual[8].term_disp = "inadequate"
 SET terms->qual[8].term_id = tidinadequate
 CALL validateterms(null)
 CALL getprocedures(null)
#exit_script
 SET nummonths = floor(datetimediff(cnvtdatetime(tedate),cnvtdatetime(tbdate),11))
 IF (nummonths=0)
  SET nummonths = 1
 ENDIF
 SET json_data->month_cnt = nummonths
 SET stat = alterlist(json_data->month_qual,nummonths)
 FOR (monthloop = 1 TO nummonths)
   SET unit = build('"',(monthloop - 1),',M"')
   SET yearmonth = cnvtint(format(cnvtlookahead(unit,cnvtdatetime(bdate)),"YYYYMM;;D"))
   SET json_data->month_qual[monthloop].yearmonth = yearmonth
   SET json_data->month_qual[monthloop].datalabel = build2(format(cnvtlookahead(unit,cnvtdatetime(
       bdate)),"MMM;;D")," ",format(cnvtlookahead(unit,cnvtdatetime(bdate)),"YYYY;;D"))
 ENDFOR
 SELECT INTO "nl:"
  month_sort = cnvtint(format(procedures->qual[d1.seq].service_dt_tm,"YYYYMM;;D"))
  FROM (dummyt d1  WITH seq = procedures->qual_cnt)
  ORDER BY month_sort, procedures->qual[d1.seq].scd_story_id
  HEAD month_sort
   monthcnt = 0, monthmalecnt = 0, monthfemalecnt = 0
  DETAIL
   monthcnt = (monthcnt+ 1)
   IF ((procedures->qual[d1.seq].sex_cd=cs57male))
    monthmalecnt = (monthmalecnt+ 1)
   ELSEIF ((procedures->qual[d1.seq].sex_cd=cs57female))
    monthfemalecnt = (monthfemalecnt+ 1)
   ENDIF
  FOOT  month_sort
   pos = locateval(idx,1,json_data->month_cnt,month_sort,json_data->month_qual[idx].yearmonth),
   json_data->month_qual[pos].procedures_denom = monthcnt, json_data->month_qual[pos].male_denom =
   monthmalecnt,
   json_data->month_qual[pos].female_denom = monthfemalecnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  month_sort = cnvtint(format(ce.event_end_dt_tm,"YYYYMM;;D"))
  FROM scd_term st,
   scd_story ss,
   clinical_event ce
  PLAN (st
   WHERE expand(idx,1,procedures->qual_cnt,st.scd_story_id,procedures->qual[idx].scd_story_id)
    AND expand(idx,1,terms->qual_cnt,st.scr_term_id,terms->qual[idx].term_id)
    AND st.truth_state_cd=cs15751true
    AND st.active_ind=1
    AND st.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND st.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (ss
   WHERE ss.scd_story_id=st.scd_story_id)
   JOIN (ce
   WHERE ce.event_id=ss.event_id
    AND ce.result_status_cd IN (cs8auth, cs8altered, cs8modified)
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100"))
  ORDER BY month_sort, st.scd_story_id, st.scr_term_id
  HEAD month_sort
   mpos = locateval(idx,1,json_data->month_cnt,month_sort,json_data->month_qual[idx].yearmonth)
  HEAD st.scd_story_id
   cecum_ind = 0, bowel_prep_ind = 0, bowel_prep_num = 0.0
  DETAIL
   pos = locatevalsort(idx,1,procedures->qual_cnt,st.scd_story_id,procedures->qual[idx].scd_story_id),
   pos2 = locateval(idx,1,terms->qual_cnt,st.scr_term_id,terms->qual[idx].term_id)
   IF (size(procedures->qual[pos].status) > 0)
    procedures->qual[pos].status = build2(procedures->qual[pos].status,", ",terms->qual[pos2].
     term_disp)
   ELSE
    procedures->qual[pos].status = build2(terms->qual[pos2].term_disp)
   ENDIF
   CASE (st.scr_term_id)
    OF tidcecum:
     cecum_ind = 1
    OF tidterminalileum:
     cecum_ind = 1
    OF tidpolyp:
     IF ((procedures->qual[pos].sex_cd=cs57male))
      json_data->month_qual[mpos].num_polypmale = (json_data->month_qual[mpos].num_polypmale+ 1)
     ELSEIF ((procedures->qual[pos].sex_cd=cs57female))
      json_data->month_qual[mpos].num_polypfemale = (json_data->month_qual[mpos].num_polypfemale+ 1)
     ENDIF
    OF tidverygood:
     bowel_prep_ind = 1,bowel_prep_num = 1
    OF tidgood:
     bowel_prep_ind = 1,bowel_prep_num = 0.75
    OF tidsufficient:
     bowel_prep_ind = 1,bowel_prep_num = 0.5
    OF tidpoor:
     bowel_prep_ind = 1,bowel_prep_num = 0.25
    OF tidinadequate:
     bowel_prep_ind = 1
   ENDCASE
  FOOT  st.scd_story_id
   IF (cecum_ind=1)
    json_data->month_qual[mpos].num_cecum = (json_data->month_qual[mpos].num_cecum+ 1)
   ENDIF
   IF (bowel_prep_ind=1)
    json_data->month_qual[mpos].bowel_prep_denom = (json_data->month_qual[mpos].bowel_prep_denom+ 1),
    json_data->month_qual[mpos].num_bowel_prep = (json_data->month_qual[mpos].num_bowel_prep+
    bowel_prep_num)
   ENDIF
  FOOT  month_sort
   json_data->month_qual[mpos].pct_cecum = ((cnvtreal(json_data->month_qual[mpos].num_cecum)/
   cnvtreal(json_data->month_qual[mpos].procedures_denom)) * 100), json_data->month_qual[mpos].
   pct_polypmale = ((cnvtreal(json_data->month_qual[mpos].num_polypmale)/ cnvtreal(json_data->
    month_qual[mpos].male_denom)) * 100), json_data->month_qual[mpos].pct_polypfemale = ((cnvtreal(
    json_data->month_qual[mpos].num_polypfemale)/ cnvtreal(json_data->month_qual[mpos].female_denom))
    * 100),
   json_data->month_qual[mpos].pct_bowel_prep = ((cnvtreal(json_data->month_qual[mpos].num_bowel_prep
    )/ cnvtreal(json_data->month_qual[mpos].bowel_prep_denom)) * 100)
  WITH nocounter, expand = 1
 ;end select
 IF ((procedures->qual_cnt > 0))
  SET chart_data->results = build2("[[")
  FOR (monthloop = 1 TO json_data->month_cnt)
   SET chart_data->results = build2(chart_data->results,'["',json_data->month_qual[monthloop].
    datalabel,'",')
   SET chart_data->results = build2(chart_data->results,trim(cnvtstring(json_data->month_qual[
      monthloop].pct_cecum,5,1)),"],")
  ENDFOR
  SET chart_data->results = substring(1,(size(chart_data->results) - 1),chart_data->results)
  SET chart_data->results = build2(chart_data->results,"],[")
  FOR (monthloop = 1 TO json_data->month_cnt)
   SET chart_data->results = build2(chart_data->results,'["',json_data->month_qual[monthloop].
    datalabel,'",')
   SET chart_data->results = build2(chart_data->results,trim(cnvtstring(json_data->month_qual[
      monthloop].pct_bowel_prep,5,1)),"],")
  ENDFOR
  SET chart_data->results = substring(1,(size(chart_data->results) - 1),chart_data->results)
  SET chart_data->results = build2(chart_data->results,"],[")
  FOR (monthloop = 1 TO json_data->month_cnt)
   SET chart_data->results = build2(chart_data->results,'["',json_data->month_qual[monthloop].
    datalabel,'",')
   SET chart_data->results = build2(chart_data->results,trim(cnvtstring(json_data->month_qual[
      monthloop].pct_polypmale,5,1)),"],")
  ENDFOR
  SET chart_data->results = substring(1,(size(chart_data->results) - 1),chart_data->results)
  SET chart_data->results = build2(chart_data->results,"],[")
  FOR (monthloop = 1 TO json_data->month_cnt)
   SET chart_data->results = build2(chart_data->results,'["',json_data->month_qual[monthloop].
    datalabel,'",')
   SET chart_data->results = build2(chart_data->results,trim(cnvtstring(json_data->month_qual[
      monthloop].pct_polypfemale,5,1)),"],")
  ENDFOR
  SET chart_data->results = substring(1,(size(chart_data->results) - 1),chart_data->results)
  SET chart_data->results = build2(chart_data->results,"]]")
 ENDIF
 SET chart_data->status_data.status = "S"
 CALL putjsontofile(chart_data)
END GO
