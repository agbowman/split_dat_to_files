CREATE PROGRAM bed_get_nomenclature:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 nomen_list[*]
      2 active_ind = i2
      2 nomenclature_id = f8
      2 principle_type_code_value = f8
      2 principle_type_display = vc
      2 principle_type_mean = vc
      2 contributor_system_code_value = f8
      2 contributor_system_display = vc
      2 contributor_system_mean = vc
      2 language_code_value = f8
      2 language_display = vc
      2 language_mean = vc
      2 source_vocabulary_code_value = f8
      2 source_vocabulary_display = vc
      2 source_vocabulary_mean = vc
      2 source_string = c255
      2 short_string = c60
      2 mnemonic = c25
      2 source_identifier = vc
      2 concept_identifier = vc
      2 concept_cki = vc
      2 vocab_axis_code_value = f8
      2 vocab_axis_display = vc
      2 vocab_axis_mean = vc
      2 concept_source_code_value = f8
      2 concept_source_display = vc
      2 concept_source_mean = vc
      2 beg_effective_dt_tm = dq8
      2 end_effective_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
    1 too_many_results_ind = i2
  )
 ENDIF
 SET reply->status_data.status = "Z"
 SET reply->too_many_results_ind = 0
 SET tot_count = 0
 SET nomen_count = 0
 SET ncount = size(request->nlist,5)
 SET parser_buffer[1000] = fillstring(120," ")
 SET xx = initarray(parser_buffer," ")
 SET parser_number = 0
 SET stat = alterlist(reply->nomen_list,100)
 IF ((request->max_reply > 0))
  SET max_reply = request->max_reply
 ELSE
  SET max_reply = 10000
 ENDIF
 IF (ncount > 0)
  SET last_source_vocab_code_value = 0.0
  SET alpha_ind = 0
  DECLARE search_string = vc
  IF ((request->search_type_flag="E"))
   SET search_string = fillstring(27," ")
  ENDIF
  SET search_string = "*"
  IF ((request->search_string > " "))
   IF ((request->search_type_flag="S"))
    SET search_string = concat('"',trim(request->search_string),'*"')
   ELSEIF ((request->search_type_flag="E"))
    SET search_string = concat('"',trim(request->search_string),'"')
   ELSE
    SET search_string = concat('"*',trim(request->search_string),'*"')
   ENDIF
  ELSE
   IF ((request->source_type_flag="S"))
    SET search_string = concat('"',trim(request->source_identifier),'*"')
   ELSE
    SET search_string = concat('"*',trim(request->source_identifier),'*"')
   ENDIF
  ENDIF
  SET search_string = cnvtupper(search_string)
  CALL echoxml(request,"asxml")
  DECLARE temp_string = vc
  DECLARE temp_string2 = vc
  SET temp_string = fillstring(120," ")
  SET temp_string2 = fillstring(120," ")
  SET alpha_cd = 0.0
  SELECT INTO "NL:"
   FROM code_value cv
   WHERE cv.cdf_meaning="ALPHA RESPON"
    AND cv.active_ind=1
    AND cv.code_set=401
   DETAIL
    alpha_cd = cv.code_value
   WITH nocounter
  ;end select
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = 'select into "nl:"'
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = concat("from nomenclature n")
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "plan n where "
  FOR (x = 1 TO ncount)
    SET temp_string = fillstring(120," ")
    SET temp_string2 = fillstring(120," ")
    SET alpha_ind = 0
    IF ((request->nlist[x].principle_type_code_value=alpha_cd))
     SET alpha_ind = 1
    ENDIF
    IF ((request->nlist[x].principle_type_code_value=0)
     AND (request->nlist[x].source_vocabulary_code_value=0))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
    SET temp_string = "("
    IF ((request->nlist[x].source_vocabulary_code_value > 0))
     SET temp_string = build(temp_string," n.source_vocabulary_cd+0 =",request->nlist[x].
      source_vocabulary_code_value)
    ENDIF
    IF ((request->nlist[x].principle_type_code_value > 0))
     IF (temp_string != "(")
      SET temp_string = concat(temp_string," and ")
     ENDIF
     IF (alpha_ind=1)
      SET temp_string = build(temp_string," n.principle_type_cd =",request->nlist[x].
       principle_type_code_value)
     ELSE
      SET temp_string = build(temp_string," n.principle_type_cd+0 =",request->nlist[x].
       principle_type_code_value)
     ENDIF
    ENDIF
    IF ((request->nlist[x].contributor_system_code_value > 0))
     SET temp_string2 = build(" and n.contributor_system_cd+0 =",request->nlist[x].
      contributor_system_code_value)
    ENDIF
    IF ((request->nlist[x].language_code_value > 0))
     SET temp_string2 = build(temp_string2," and n.language_cd+0 = ",request->nlist[x].
      language_code_value)
    ENDIF
    IF (validate(request->primary_vterm_ind))
     IF ((request->primary_vterm_ind=1))
      SET temp_string2 = build(temp_string2," and n.primary_vterm_ind+0 = 1")
     ENDIF
    ENDIF
    SET temp_string2 = concat(temp_string2,")")
    IF (x=1)
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = concat("(",trim(temp_string))
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = concat(trim(temp_string2))
    ELSE
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = concat(" or ",trim(temp_string))
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = concat(trim(temp_string2))
    ENDIF
    IF (x=ncount)
     IF (alpha_ind=1)
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = concat(") and (n.source_string_keycap = ",search_string)
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = concat(" or cnvtupper(n.short_string)= ",search_string)
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = concat(" or cnvtupper(n.mnemonic) = ",search_string,")")
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = concat(" and (n.active_ind+0 = 1 or ")
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = concat(
       " (n.active_ind+0 = 0 and request->load_inactive_ind = 1))")
     ELSE
      SET parser_number = (parser_number+ 1)
      IF ((request->search_string > " "))
       SET parser_buffer[parser_number] = concat(") and (n.source_string_keycap  = ",search_string,
        ")")
      ELSE
       SET parser_buffer[parser_number] = concat(") and (n.source_identifier_keycap  = ",
        search_string,")")
      ENDIF
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = concat(" and (n.active_ind+0 = 1 or ")
      SET parser_number = (parser_number+ 1)
      SET parser_buffer[parser_number] = concat(
       "(n.active_ind+0 = 0 and request->load_inactive_ind = 1))")
     ENDIF
     IF (validate(request->search_future_effective_ind))
      IF ((request->search_future_effective_ind=0))
       SET parser_number = (parser_number+ 1)
       SET parser_buffer[parser_number] = concat(
        " and n.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)")
      ENDIF
     ENDIF
     SET parser_number = (parser_number+ 1)
     SET parser_buffer[parser_number] = concat(" and n.source_vocabulary_cd !=0.0")
    ENDIF
    SET max_reply = (max_reply - tot_count)
  ENDFOR
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "detail"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "tot_count = tot_count + 1"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "nomen_count = nomen_count + 1"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "if (nomen_count > 100)"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "stat = alterlist(reply->nomen_list, tot_count + 100)"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "nomen_count = 0"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "endif"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "reply->nomen_list[tot_count]->active_ind = n.active_ind"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->nomenclature_id = n.nomenclature_id"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->principle_type_code_value = n.principle_type_cd"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->contributor_system_code_value = n.contributor_system_cd"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->language_code_value = n.language_cd"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->source_vocabulary_code_value = n.source_vocabulary_cd"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "reply->nomen_list[tot_count]->source_string = n.source_string"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "reply->nomen_list[tot_count]->short_string = n.short_string"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "reply->nomen_list[tot_count]->mnemonic = n.mnemonic"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->source_identifier = n.source_identifier"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->concept_identifier = n.concept_identifier"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "reply->nomen_list[tot_count]->concept_cki = n.concept_cki"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->concept_source_code_value = n.concept_source_cd"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->vocab_axis_code_value = n.vocab_axis_cd"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->beg_effective_dt_tm = n.beg_effective_dt_tm"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] =
  "reply->nomen_list[tot_count]->end_effective_dt_tm = n.end_effective_dt_tm"
  SET parser_number = (parser_number+ 1)
  SET parser_buffer[parser_number] = "with maxrec = value(max_reply), nocounter go"
  SELECT INTO "nl:"
   FROM dummyt d
   DETAIL
    FOR (x = 1 TO parser_number)
      CALL echo(parser_buffer[x])
    ENDFOR
   WITH maxcol = 150, nocounter, format = variable
  ;end select
  FOR (x = 1 TO parser_number)
    CALL parser(parser_buffer[x])
  ENDFOR
  IF (tot_count >= max_reply
   AND (request->reply_return_nbr=0))
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
  ELSEIF (tot_count >= max_reply
   AND (request->reply_return_nbr > 0))
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
  ELSEIF (tot_count > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 IF (ncount=0
  AND (request->search_string > " "))
  DECLARE search_string = vc
  DECLARE temp_string3 = vc
  IF ((request->search_type_flag="E"))
   SET search_string = fillstring(27," ")
  ENDIF
  SET search_string = "*"
  IF ((request->search_type_flag="S"))
   SET search_string = concat('"',trim(request->search_string),'*"')
  ELSEIF ((request->search_type_flag="E"))
   SET search_string = concat('"',trim(request->search_string),'"')
  ELSE
   SET search_string = concat('"*',trim(request->search_string),'*"')
  ENDIF
  SET search_string = cnvtupper(search_string)
  SET temp_string3 = concat("n.source_string_keycap = ",search_string)
  IF (validate(request->primary_vterm_ind))
   IF ((request->primary_vterm_ind=1))
    SET temp_string3 = concat(temp_string3," and n.primary_vterm_ind+0 = 1")
   ENDIF
  ENDIF
  SET temp_string3 = concat(temp_string3,
   " and (n.active_ind+0 = 1 or (n.active_ind+0 = 0 and request->load_inactive_ind = 1))")
  SET temp_string3 = concat(temp_string3," and (n.concept_cki > ' ') and n.concept_cki != null")
  SET temp_string3 = concat(temp_string3,
   " and n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)")
  SET temp_string3 = concat(temp_string3," and n.source_vocabulary_cd!=0.0")
  SELECT INTO "nl:"
   FROM nomenclature n
   PLAN (n
    WHERE parser(temp_string3))
   DETAIL
    tot_count = (tot_count+ 1), nomen_count = (nomen_count+ 1)
    IF (nomen_count > 100)
     stat = alterlist(reply->nomen_list,(tot_count+ 100)), nomen_count = 0
    ENDIF
    reply->nomen_list[tot_count].active_ind = n.active_ind, reply->nomen_list[tot_count].
    nomenclature_id = n.nomenclature_id, reply->nomen_list[tot_count].principle_type_code_value = n
    .principle_type_cd,
    reply->nomen_list[tot_count].contributor_system_code_value = n.contributor_system_cd, reply->
    nomen_list[tot_count].language_code_value = n.language_cd, reply->nomen_list[tot_count].
    source_vocabulary_code_value = n.source_vocabulary_cd,
    reply->nomen_list[tot_count].source_string = n.source_string, reply->nomen_list[tot_count].
    short_string = n.short_string, reply->nomen_list[tot_count].mnemonic = n.mnemonic,
    reply->nomen_list[tot_count].source_identifier = n.source_identifier, reply->nomen_list[tot_count
    ].concept_identifier = n.concept_identifier, reply->nomen_list[tot_count].concept_cki = n
    .concept_cki,
    reply->nomen_list[tot_count].concept_source_code_value = n.concept_source_cd, reply->nomen_list[
    tot_count].vocab_axis_code_value = n.vocab_axis_cd, reply->nomen_list[tot_count].
    beg_effective_dt_tm = n.beg_effective_dt_tm,
    reply->nomen_list[tot_count].end_effective_dt_tm = n.end_effective_dt_tm
   WITH nocounter, maxrec = value(max_reply)
  ;end select
  IF (tot_count >= max_reply
   AND (request->reply_return_nbr=0))
   SET reply->too_many_results_ind = 1
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 SET id_count = size(request->id_list,5)
 IF (id_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = value(id_count)),
    nomenclature n
   PLAN (d)
    JOIN (n
    WHERE (n.nomenclature_id=request->id_list[d.seq].nomenclature_id)
     AND n.source_vocabulary_cd != 0)
   ORDER BY d.seq
   DETAIL
    tot_count = (tot_count+ 1), nomen_count = (nomen_count+ 1)
    IF (nomen_count > 100)
     stat = alterlist(reply->nomen_list,(tot_count+ 100)), nomen_count = 0
    ENDIF
    reply->nomen_list[tot_count].active_ind = n.active_ind, reply->nomen_list[tot_count].
    nomenclature_id = n.nomenclature_id, reply->nomen_list[tot_count].principle_type_code_value = n
    .principle_type_cd,
    reply->nomen_list[tot_count].contributor_system_code_value = n.contributor_system_cd, reply->
    nomen_list[tot_count].language_code_value = n.language_cd, reply->nomen_list[tot_count].
    source_vocabulary_code_value = n.source_vocabulary_cd,
    reply->nomen_list[tot_count].source_string = n.source_string, reply->nomen_list[tot_count].
    short_string = n.short_string, reply->nomen_list[tot_count].mnemonic = n.mnemonic,
    reply->nomen_list[tot_count].source_identifier = n.source_identifier, reply->nomen_list[tot_count
    ].concept_identifier = n.concept_identifier, reply->nomen_list[tot_count].concept_cki = n
    .concept_cki,
    reply->nomen_list[tot_count].concept_source_code_value = n.concept_source_cd, reply->nomen_list[
    tot_count].vocab_axis_code_value = n.vocab_axis_cd, reply->nomen_list[tot_count].
    beg_effective_dt_tm = n.beg_effective_dt_tm,
    reply->nomen_list[tot_count].end_effective_dt_tm = n.end_effective_dt_tm
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(request->cki_list))
  SET cki_count = size(request->cki_list,5)
  IF (cki_count > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = value(cki_count)),
     nomenclature n
    PLAN (d)
     JOIN (n
     WHERE (n.concept_cki=request->cki_list[d.seq].concept_cki)
      AND n.primary_vterm_ind=1
      AND n.active_ind=1
      AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND n.source_vocabulary_cd != 0.0)
    ORDER BY d.seq
    DETAIL
     tot_count = (tot_count+ 1), nomen_count = (nomen_count+ 1)
     IF (nomen_count > 100)
      stat = alterlist(reply->nomen_list,(tot_count+ 100)), nomen_count = 0
     ENDIF
     reply->nomen_list[tot_count].active_ind = n.active_ind, reply->nomen_list[tot_count].
     nomenclature_id = n.nomenclature_id, reply->nomen_list[tot_count].principle_type_code_value = n
     .principle_type_cd,
     reply->nomen_list[tot_count].contributor_system_code_value = n.contributor_system_cd, reply->
     nomen_list[tot_count].language_code_value = n.language_cd, reply->nomen_list[tot_count].
     source_vocabulary_code_value = n.source_vocabulary_cd,
     reply->nomen_list[tot_count].source_string = n.source_string, reply->nomen_list[tot_count].
     short_string = n.short_string, reply->nomen_list[tot_count].mnemonic = n.mnemonic,
     reply->nomen_list[tot_count].source_identifier = n.source_identifier, reply->nomen_list[
     tot_count].concept_identifier = n.concept_identifier, reply->nomen_list[tot_count].concept_cki
      = n.concept_cki,
     reply->nomen_list[tot_count].concept_source_code_value = n.concept_source_cd, reply->nomen_list[
     tot_count].vocab_axis_code_value = n.vocab_axis_cd, reply->nomen_list[tot_count].
     beg_effective_dt_tm = n.beg_effective_dt_tm,
     reply->nomen_list[tot_count].end_effective_dt_tm = n.end_effective_dt_tm
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (tot_count > 0)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    code_value cv
   PLAN (d
    WHERE (reply->nomen_list[d.seq].principle_type_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->nomen_list[d.seq].principle_type_code_value))
   DETAIL
    reply->nomen_list[d.seq].principle_type_display = cv.display, reply->nomen_list[d.seq].
    principle_type_mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    code_value cv
   PLAN (d
    WHERE (reply->nomen_list[d.seq].contributor_system_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->nomen_list[d.seq].contributor_system_code_value))
   DETAIL
    reply->nomen_list[d.seq].contributor_system_display = cv.display, reply->nomen_list[d.seq].
    contributor_system_mean = cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    code_value cv
   PLAN (d
    WHERE (reply->nomen_list[d.seq].language_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->nomen_list[d.seq].language_code_value))
   DETAIL
    reply->nomen_list[d.seq].language_display = cv.display, reply->nomen_list[d.seq].language_mean =
    cv.cdf_meaning
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = tot_count),
    code_value cv
   PLAN (d
    WHERE (reply->nomen_list[d.seq].source_vocabulary_code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->nomen_list[d.seq].source_vocabulary_code_value))
   DETAIL
    reply->nomen_list[d.seq].source_vocabulary_display = cv.display, reply->nomen_list[d.seq].
    source_vocabulary_mean = cv.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF (tot_count > 0
  AND (reply->status_data.status="Z"))
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alterlist(reply->nomen_list,tot_count)
#exit_script
 IF ((reply->too_many_results_ind=1)
  AND (request->reply_return_nbr=0))
  SET stat = alterlist(reply->nomen_list,0)
  SET reply->status_data.status = "S"
 ELSEIF ((reply->too_many_results_ind=1)
  AND (request->reply_return_nbr > 0))
  SET stat = alterlist(reply->nomen_list,request->reply_return_nbr)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
