CREATE PROGRAM cps_nomen_get_pickitems:dba
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
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 item_cnt = i2
   1 items[*]
     2 active_ind = i2
     2 data_status_cd = f8
     2 source_string = vc
     2 string_identifier = vc
     2 source_identifier = vc
     2 concept_identifier = vc
     2 concept_source_cd = f8
     2 source_vocabulary_cd = f8
     2 source_vocabulary_disp = c40
     2 string_source_cd = f8
     2 string_source_disp = c40
     2 principle_type_cd = f8
     2 principle_type_disp = c40
     2 nomenclature_id = f8
     2 vocab_axis_cd = f8
     2 vocab_axis_disp = c40
     2 contributor_system_cd = f8
     2 contributor_system_disp = c40
     2 primary_vterm_ind = i2
     2 short_string = vc
     2 mnemonic = vc
     2 concept_cki = vc
   1 errormsg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF (validate(context,"0")="0")
  RECORD context(
    1 namestring = vc
    1 codestring = vc
    1 context_ind = i2
    1 all_ind = i2
    1 data_status_ind = i2
    1 normalized_string = vc
    1 normalized_string_id = i4
    1 source_identifier = vc
    1 source_string = vc
    1 nomenclature_id = f8
    1 vocabularies[*]
      2 source_vocabulary_cd = f8
    1 principletypes[*]
      2 principle_type_cd = f8
    1 vocabularycnt = i2
    1 principletypecnt = i2
    1 vocab_axis_cnt = i2
    1 compare_dt_tm = dq8
    1 beg_dt_tm = dq8
    1 end_dt_tm = dq8
    1 force_disallowed_ind = i2
    1 vocab_axis[*]
      2 vocab_axis_cd = f8
    1 primary_vterm_ind = i2
  )
 ELSEIF (((trim(context->namestring) != trim(request->namestring)) OR (trim(context->codestring) !=
 trim(request->codestring))) )
  FREE RECORD context
  RECORD context(
    1 namestring = vc
    1 codestring = vc
    1 context_ind = i2
    1 all_ind = i2
    1 data_status_ind = i2
    1 normalized_string = vc
    1 normalized_string_id = i4
    1 source_identifier = vc
    1 source_string = vc
    1 nomenclature_id = f8
    1 vocabularies[*]
      2 source_vocabulary_cd = f8
    1 principletypes[*]
      2 principle_type_cd = f8
    1 vocabularycnt = i2
    1 principletypecnt = i2
    1 vocab_axis_cnt = i2
    1 compare_dt_tm = dq8
    1 beg_dt_tm = dq8
    1 end_dt_tm = dq8
    1 force_disallowed_ind = i2
    1 vocab_axis[*]
      2 vocab_axis_cd = f8
    1 primary_vterm_ind = i2
  )
 ENDIF
 IF ((context->nomenclature_id < 1))
  IF ((request->vocabularycnt > 0))
   SET context->vocabularycnt = request->vocabularycnt
   SET stat = alterlist(context->vocabularies,context->vocabularycnt)
   FOR (idx = 1 TO request->vocabularycnt)
     SET context->vocabularies[idx].source_vocabulary_cd = request->vocabularies[idx].
     source_vocabulary_cd
   ENDFOR
  ENDIF
  IF ((request->principletypecnt > 0))
   SET context->principletypecnt = request->principletypecnt
   SET stat = alterlist(context->principletypes,context->principletypecnt)
   FOR (idx = 1 TO request->principletypecnt)
     SET context->principletypes[idx].principle_type_cd = request->principletypes[idx].
     principle_type_cd
   ENDFOR
  ENDIF
  IF ((request->vocab_axis_cnt > 0))
   SET context->vocab_axis_cnt = request->vocab_axis_cnt
   SET stat = alterlist(context->vocab_axis,context->vocab_axis_cnt)
   FOR (idx = 1 TO request->vocab_axis_cnt)
     SET context->vocab_axis[idx].vocab_axis_cd = request->vocab_axis[idx].vocab_axis_cd
   ENDFOR
  ENDIF
  SET context->all_ind = request->all_ind
  SET context->normalized_string = fillstring(1000," ")
  SET context->normalized_string = " "
  SET context->normalized_string_id = 0
  SET context->source_identifier = fillstring(100," ")
  SET context->source_identifier = " "
  SET context->source_string = fillstring(1000," ")
  SET context->source_string = " "
  SET context->nomenclature_id = 0
  SET context->force_disallowed_ind = request->force_disallowed_ind
  SET context->namestring = request->namestring
  SET context->codestring = request->codestring
  SET context->vocabularycnt = request->vocabularycnt
  SET context->principletypecnt = request->principletypecnt
  SET context->vocab_axis_cnt = request->vocab_axis_cnt
  SET context->compare_dt_tm = request->compare_dt_tm
  SET context->primary_vterm_ind = request->primary_vterm_ind
  IF ((request->compare_dt_tm=0))
   SET context->beg_dt_tm = cnvtdatetime("31-DEC-2100")
   SET context->end_dt_tm = cnvtdatetime("01-JAN-1800")
  ELSE
   SET context->end_dt_tm = request->compare_dt_tm
   SET context->beg_dt_tm = request->compare_dt_tm
  ENDIF
 ENDIF
 DECLARE count1 = i4 WITH public, noconstant(0)
 DECLARE count2 = i4 WITH public, noconstant(0)
 DECLARE wcount = i4 WITH public, noconstant(0)
 SET outstr = fillstring(1000," ")
 DECLARE buflen = i4 WITH public, noconstant(1000)
 DECLARE active_ind_val1 = i2 WITH public, noconstant(1)
 DECLARE active_ind_val2 = i2 WITH public, noconstant(1)
 DECLARE primary_vterm_ind_val1 = i2 WITH public, noconstant(0)
 DECLARE primary_vterm_ind_val2 = i2 WITH public, noconstant(1)
 DECLARE max = i4 WITH public, noconstant(100)
 DECLARE maxread = i4 WITH public, noconstant(0)
 DECLARE op = vc WITH public, noconstant(" ")
 DECLARE type = vc WITH public, noconstant(" ")
 DECLARE edx = i4 WITH public, noconstant(0)
 DECLARE fdx = i4 WITH public, noconstant(0)
 DECLARE wcard = c1 WITH public, constant("*")
 IF ((context->all_ind=true))
  SET active_ind_val1 = 0
 ENDIF
 IF ((context->primary_vterm_ind=true))
  SET primary_vterm_ind_val1 = 1
 ENDIF
 IF ((request->max_items > 0))
  SET max = request->max_items
 ENDIF
 SET maxread = max
 IF ((request->principletypecnt > 0)
  AND (request->vocab_axis_cnt > 0))
  SET reply->status_data.status = "Z"
  SET reply->item_cnt = 0
  SET failed = true
  SET serrmsg_error = "Cannot search on both PrincipleType and VocabAxis"
  GO TO end_for_thistime
 ENDIF
 IF (((trim(request->codestring) != " ") OR (trim(request->namestring) != " ")) )
  SET op = "USE_CODE_OR_NAME"
 ELSE
  SET op = "NO_CODE_OR_NAME"
 ENDIF
 IF ((request->vocabularycnt=0))
  IF ((request->principletypecnt > 0))
   SET type = "PRINCIPLE_TYPE"
  ELSE
   IF ((request->vocab_axis_cnt > 0))
    SET type = "VOCAB_AXIS"
   ELSE
    SET type = "ALL_TYPE"
   ENDIF
  ENDIF
 ELSE
  IF ((request->principletypecnt > 0))
   SET type = "VOCAB_AND_PRIN_TYPE"
  ELSE
   IF ((request->vocab_axis_cnt > 0))
    SET type = "VOCAB_AND_VOCAB_AXIS"
   ELSE
    SET type = "VOCABULARY_TYPE"
   ENDIF
  ENDIF
 ENDIF
 IF (((trim(request->codestring)="\*") OR (trim(request->namestring)="\*")) )
  SET code_or_name = "NONE"
 ELSEIF (trim(request->codestring)=" "
  AND trim(request->namestring)=" ")
  SET code_or_name = "NONE"
 ELSEIF (trim(request->codestring)=" "
  AND trim(request->namestring) != " ")
  SET code_or_name = "NAME"
 ELSEIF (trim(request->codestring) != " "
  AND trim(request->namestring)=" ")
  SET code_or_name = "CODE"
 ELSE
  SET code_or_name = "NONE"
 ENDIF
 IF (((code_or_name="NONE") OR (op="NO_CODE_OR_NAME")) )
  SET reply->status_data.status = "Z"
  SET reply->item_cnt = 0
  SET failed = true
  SET serrmsg_error = "No code or string provided"
  GO TO end_for_thistime
 ENDIF
 IF (code_or_name="NAME")
  SET done = false
  SET tempstr = fillstring(1000," ")
  SET tempstr = nullterm(request->namestring)
  CALL uar_normalize_string(nullterm(tempstr),outstr,nullterm(wcard),buflen,wcount)
  SET inpstr = outstr
  SELECT
   IF (type="ALL_TYPE")
    FROM nomenclature n,
     normalized_string_index s
    PLAN (s
     WHERE operator(s.normalized_string,"LIKE",patstring(inpstr))
      AND (s.normalized_string_id > context->normalized_string_id))
     JOIN (n
     WHERE n.nomenclature_id=s.nomenclature_id
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="VOCABULARY_TYPE")
    FROM nomenclature n,
     normalized_string_index s
    PLAN (s
     WHERE operator(s.normalized_string,"LIKE",patstring(inpstr))
      AND (s.normalized_string_id > context->normalized_string_id))
     JOIN (n
     WHERE n.nomenclature_id=s.nomenclature_id
      AND expand(edx,1,request->vocabularycnt,n.source_vocabulary_cd,request->vocabularies[edx].
      source_vocabulary_cd)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="VOCAB_AXIS")
    FROM nomenclature n,
     normalized_string_index s
    PLAN (s
     WHERE operator(s.normalized_string,"LIKE",patstring(inpstr))
      AND (s.normalized_string_id > context->normalized_string_id))
     JOIN (n
     WHERE n.nomenclature_id=s.nomenclature_id
      AND expand(edx,1,request->vocab_axis_cnt,n.vocab_axis_cd,request->vocab_axis[edx].vocab_axis_cd
      )
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="PRINCIPLE_TYPE")
    FROM nomenclature n,
     normalized_string_index s
    PLAN (s
     WHERE operator(s.normalized_string,"LIKE",patstring(inpstr))
      AND (s.normalized_string_id > context->normalized_string_id))
     JOIN (n
     WHERE n.nomenclature_id=s.nomenclature_id
      AND expand(edx,1,request->principletypecnt,n.principle_type_cd,request->principletypes[edx].
      principle_type_cd)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="VOCAB_AND_VOCAB_AXIS")
    FROM nomenclature n,
     normalized_string_index s
    PLAN (s
     WHERE operator(s.normalized_string,"LIKE",patstring(inpstr))
      AND (s.normalized_string_id > context->normalized_string_id))
     JOIN (n
     WHERE n.nomenclature_id=s.nomenclature_id
      AND expand(edx,1,request->vocabularycnt,n.source_vocabulary_cd,request->vocabularies[edx].
      source_vocabulary_cd)
      AND expand(fdx,1,request->vocab_axis_cnt,n.vocab_axis_cd,request->vocab_axis[fdx].vocab_axis_cd
      )
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="VOCAB_AND_PRIN_TYPE")
    FROM nomenclature n,
     normalized_string_index s
    PLAN (s
     WHERE operator(s.normalized_string,"LIKE",patstring(inpstr))
      AND (s.normalized_string_id > context->normalized_string_id))
     JOIN (n
     WHERE n.nomenclature_id=s.nomenclature_id
      AND expand(edx,1,request->vocabularycnt,n.source_vocabulary_cd,request->vocabularies[edx].
      source_vocabulary_cd)
      AND expand(fdx,1,request->principletypecnt,n.principle_type_cd,request->principletypes[fdx].
      principle_type_cd)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSE
   ENDIF
   INTO "NL:"
   ORDER BY s.normalized_string_id
   HEAD n.nomenclature_id
    IF (count1 < max)
     count1 = (count1+ 1), count2 = (count2+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(reply->items,(count1+ 9))
     ENDIF
     reply->items[count1].source_string = n.source_string, reply->items[count1].string_identifier = n
     .string_identifier, reply->items[count1].source_identifier = n.source_identifier,
     reply->items[count1].concept_identifier = n.concept_identifier, reply->items[count1].
     concept_source_cd = n.concept_source_cd, reply->items[count1].source_vocabulary_cd = n
     .source_vocabulary_cd,
     reply->items[count1].string_source_cd = n.string_source_cd, reply->items[count1].
     principle_type_cd = n.principle_type_cd, reply->items[count1].nomenclature_id = n
     .nomenclature_id,
     reply->items[count1].vocab_axis_cd = n.vocab_axis_cd, reply->items[count1].contributor_system_cd
      = n.contributor_system_cd, reply->items[count1].active_ind = n.active_ind,
     reply->items[count1].data_status_cd = n.data_status_cd, reply->items[count1].primary_vterm_ind
      = n.primary_vterm_ind, reply->items[count1].short_string = n.short_string,
     reply->items[count1].mnemonic = n.mnemonic, reply->items[count1].concept_cki = n.concept_cki,
     context->normalized_string = s.normalized_string,
     context->normalized_string_id = s.normalized_string_id, context->nomenclature_id = n
     .nomenclature_id
     IF (count1=max)
      context->context_ind = (context->context_ind+ 1), context->normalized_string = s
      .normalized_string, context->normalized_string_id = s.normalized_string_id,
      context->nomenclature_id = n.nomenclature_id
     ENDIF
    ENDIF
   WITH nocounter, maxqual(n,value(maxread)), maxread(s,7000)
  ;end select
  SET reply->item_cnt = count1
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
   SET request->codestring = " "
  ENDIF
 ELSEIF (code_or_name="CODE")
  SET done = false
  SET tempstr = fillstring(1000," ")
  SET tempstr = nullterm(cnvtupper(request->codestring))
  SET inpstr = cnvtupper(build(tempstr,"*"))
  SELECT
   IF (type="ALL_TYPE")
    FROM nomenclature n
    PLAN (n
     WHERE operator(n.source_identifier_keycap,"LIKE",patstring(inpstr))
      AND (n.nomenclature_id != context->nomenclature_id)
      AND (n.source_identifier >= context->source_identifier)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="VOCABULARY_TYPE")
    FROM nomenclature n
    PLAN (n
     WHERE operator(n.source_identifier_keycap,"LIKE",patstring(inpstr))
      AND expand(edx,1,request->vocabularycnt,n.source_vocabulary_cd,request->vocabularies[edx].
      source_vocabulary_cd)
      AND (n.nomenclature_id != context->nomenclature_id)
      AND (n.source_identifier >= context->source_identifier)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="VOCAB_AXIS")
    FROM nomenclature n
    PLAN (n
     WHERE operator(n.source_identifier_keycap,"LIKE",patstring(inpstr))
      AND expand(edx,1,request->vocab_axis_cnt,n.vocab_axis_cd,request->vocab_axis[edx].vocab_axis_cd
      )
      AND (n.nomenclature_id != context->nomenclature_id)
      AND (n.source_identifier >= context->source_identifier)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="PRINCIPLE_TYPE")
    FROM nomenclature n
    PLAN (n
     WHERE operator(n.source_identifier_keycap,"LIKE",patstring(inpstr))
      AND expand(edx,1,request->principletypecnt,n.principle_type_cd,request->principletypes[edx].
      principle_type_cd)
      AND (n.nomenclature_id != context->nomenclature_id)
      AND (n.source_identifier >= context->source_identifier)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdate(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdate(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="VOCAB_AND_VOCAB_AXIS")
    FROM nomenclature n
    PLAN (n
     WHERE operator(n.source_identifier_keycap,"LIKE",patstring(inpstr))
      AND (n.source_identifier >= context->source_identifier)
      AND (n.nomenclature_id != context->nomenclature_id)
      AND expand(edx,1,request->vocabularycnt,n.source_vocabulary_cd,request->vocabularies[edx].
      source_vocabulary_cd)
      AND expand(fdx,1,request->vocab_axis_cnt,n.vocab_axis_cd,request->vocab_axis[fdx].vocab_axis_cd
      )
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdate(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdate(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSEIF (type="VOCAB_AND_PRIN_TYPE")
    FROM nomenclature n
    PLAN (n
     WHERE operator(n.source_identifier_keycap,"LIKE",patstring(inpstr))
      AND (n.source_identifier >= context->source_identifier)
      AND (n.nomenclature_id != context->nomenclature_id)
      AND expand(edx,1,request->vocabularycnt,n.source_vocabulary_cd,request->vocabularies[edx].
      source_vocabulary_cd)
      AND expand(fdx,1,request->principletypecnt,n.principle_type_cd,request->principletypes[fdx].
      principle_type_cd)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.beg_effective_dt_tm <= cnvtdatetime(context->beg_dt_tm)
      AND n.end_effective_dt_tm >= cnvtdatetime(context->end_dt_tm)
      AND ((((n.disallowed_ind = null) OR (n.disallowed_ind=0))
      AND (context->force_disallowed_ind=1)) OR ((context->force_disallowed_ind=0)))
      AND n.primary_vterm_ind IN (primary_vterm_ind_val1, primary_vterm_ind_val2, null))
   ELSE
   ENDIF
   INTO "NL:"
   HEAD n.nomenclature_id
    IF (count1 < max)
     count1 = (count1+ 1), count2 = (count2+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(reply->items,(count1+ 9))
     ENDIF
     reply->items[count1].source_string = n.source_string, reply->items[count1].string_identifier = n
     .string_identifier, reply->items[count1].source_identifier = n.source_identifier,
     reply->items[count1].concept_identifier = n.concept_identifier, reply->items[count1].
     concept_source_cd = n.concept_source_cd, reply->items[count1].source_vocabulary_cd = n
     .source_vocabulary_cd,
     reply->items[count1].string_source_cd = n.string_source_cd, reply->items[count1].
     principle_type_cd = n.principle_type_cd, reply->items[count1].nomenclature_id = n
     .nomenclature_id,
     reply->items[count1].vocab_axis_cd = n.vocab_axis_cd, reply->items[count1].contributor_system_cd
      = n.contributor_system_cd, reply->items[count1].active_ind = n.active_ind,
     reply->items[count1].data_status_cd = n.data_status_cd, reply->items[count1].primary_vterm_ind
      = n.primary_vterm_ind, reply->items[count1].short_string = n.short_string,
     reply->items[count1].mnemonic = n.mnemonic, reply->items[count1].concept_cki = n.concept_cki,
     context->nomenclature_id = n.nomenclature_id,
     context->source_identifier = n.source_identifier, context->source_string = n.source_string
     IF (count1=max)
      context->context_ind = (context->context_ind+ 1), context->nomenclature_id = n.nomenclature_id,
      context->source_identifier = n.source_identifier
     ENDIF
    ENDIF
   WITH nocounter, maxqual(n,value(maxread))
  ;end select
  SET reply->item_cnt = count1
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
   SET request->namestring = " "
  ENDIF
 ENDIF
 SET stat = alterlist(reply->items,count1)
#end_for_thistime
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->errormsg = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_get_pickitems"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failure"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ELSEIF (failed=true)
  SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_get_pickitems"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failure"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
 ELSE
  SET reply->errormsg = "no error"
  SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_get_pickitems"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "success"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
 ENDIF
 SET cps_script_ver = "023 01/04/06 AW9942"
END GO
