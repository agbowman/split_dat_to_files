CREATE PROGRAM cps_nomen_get_byaxis:dba
 RECORD reply(
   1 item_cnt = i2
   1 items[*]
     2 source_string = vc
     2 active_ind = i2
     2 string_identifier = c18
     2 source_identifier = vc
     2 concept_identifier = c18
     2 concept_source_cd = f8
     2 source_vocabulary_cd = f8
     2 string_source_cd = f8
     2 principle_type_cd = f8
     2 nomenclature_id = f8
     2 vocab_axis_cd = f8
   1 errormsg = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 RECORD context(
   1 namestring = vc
   1 codestring = vc
   1 context_ind = i2
   1 all_ind = i2
   1 normalized_string = vc
   1 source_identifier = vc
   1 source_string = vc
   1 nomenclature_id = f8
   1 vocabularies[*]
     2 source_vocabulary_cd = f8
   1 vocab_axis[*]
     2 vocab_axis_cd = f8
   1 vocabularycnt = i2
   1 vocab_axis_cnt = i2
 )
 SET vcnt = 0
 SELECT INTO "nl:"
  context->vocabularies[ddv1.seq].source_vocabulary_cd, request->vocabularies[ddv2.seq].
  source_vocabulary_cd
  FROM (dummyt ddv1  WITH seq = value(context->vocabularycnt)),
   (dummyt ddv2  WITH seq = value(request->vocabularycnt))
  PLAN (ddv1)
   JOIN (ddv2
   WHERE (context->vocabularies[ddv1.seq].source_vocabulary_cd > 0)
    AND (context->vocabularies[ddv1.seq].source_vocabulary_cd=request->vocabularies[ddv2.seq].
   source_vocabulary_cd))
  DETAIL
   vcnt = (vcnt+ 1)
  WITH nocounter
 ;end select
 IF ((vcnt != context->vocabularycnt))
  SET context->context_ind = 0
 ENDIF
 SET pcnt = 0
 SELECT INTO "nl:"
  context->vocab_axis[ddp1.seq].vocab_axis_cd, request->vocab_axis[ddp2.seq].vocab_axis_cd
  FROM (dummyt ddp1  WITH seq = value(context->vocab_axis_cnt)),
   (dummyt ddp2  WITH seq = value(request->vocab_axis_cnt))
  PLAN (ddp1)
   JOIN (ddp2
   WHERE (context->vocab_axis[ddp1.seq].vocab_axis_cd > 0)
    AND (context->vocab_axis[ddp1.seq].vocab_axis_cd=request->vocab_axis[ddp2.seq].vocab_axis_cd))
  DETAIL
   pcnt = (pcnt+ 1)
  WITH nocounter
 ;end select
 IF ((pcnt != context->vocab_axis_cnt))
  SET context->context_ind = 0
 ENDIF
 IF (trim(context->namestring) != trim(request->namestring))
  SET context->context_ind = 0
 ENDIF
 IF (trim(context->codestring) != trim(request->codestring))
  SET context->context_ind = 0
 ENDIF
 IF (validate(context->context_ind,0) != 0)
  SET continue = 1
 ELSE
  SET continue = 0
  SET context->all_ind = request->all_ind
  SET context->normalized_string = fillstring(1000," ")
  SET context->normalized_string = " "
  SET context->source_identifier = fillstring(100," ")
  SET context->source_identifier = " "
  SET context->source_string = fillstring(1000," ")
  SET context->source_string = " "
  SET context->nomenclature_id = 0
  SET context->namestring = request->namestring
  SET context->codestring = request->codestring
  SET context->vocabularycnt = request->vocabularycnt
  SET context->vocab_axis_cnt = request->vocab_axis_cnt
  SET vcount = 0
  SET stat = alterlist(context->vocabularies,(request->vocabularycnt+ 1))
  SELECT INTO "nl:"
   request->vocabularies[dv.seq].source_vocabulary_cd
   FROM (dummyt dv  WITH seq = value(request->vocabularycnt))
   WHERE (request->vocabularies[dv.seq].source_vocabulary_cd > 0)
   DETAIL
    vcount = (vcount+ 1), context->vocabularies[vcount].source_vocabulary_cd = request->vocabularies[
    dv.seq].source_vocabulary_cd
   WITH nocounter
  ;end select
  SET pcount = 0
  SET stat = alterlist(context->vocab_axis,(request->vocab_axis_cnt+ 1))
  SELECT INTO "nl:"
   request->vocab_axis[dp.seq].vocab_axis_cd
   FROM (dummyt dp  WITH seq = value(request->vocab_axis_cnt))
   WHERE (request->vocab_axis[dp.seq].vocab_axis_cd > 0)
   DETAIL
    pcount = (pcount+ 1), context->vocab_axis[pcount].vocab_axis_cd = request->vocab_axis[dp.seq].
    vocab_axis_cd
   WITH nocounter
  ;end select
 ENDIF
 RECORD err(
   1 msg = c255
 )
 SET errcode = 1
 SET errcode = error(err->msg,0)
 SET true = 1
 SET false = 0
 SET count1 = 0
 SET wcard = "*"
 SET wcount = 0
 SET outstr = fillstring(1000," ")
 SET buflen = 1000
 SET end_dt_tm = cnvtdatetime(curdate,curtime)
 SET active_ind_val1 = 1
 SET active_ind_val2 = 1
 IF ((context->all_ind=true))
  SET active_ind_val1 = 0
  SET end_dt_tm = cnvtdatetime("01-JAN-1800")
 ENDIF
 IF ((request->max_items > 0))
  SET max = request->max_items
 ELSE
  SET max = 100
 ENDIF
 SET stat = alterlist(reply->items,(max+ 1))
 SET maxread = (max+ 20)
 CALL echo(build("maxread",maxread))
 SET maxtoread = 0
 SET maxtoread = 7000
 IF (((trim(request->codestring) != " ") OR (trim(request->namestring) != " ")) )
  SET op = "USE_CODE_OR_NAME"
 ELSE
  SET op = "NO_CODE_OR_NAME"
 ENDIF
 IF ((request->vocabularycnt=0)
  AND (request->vocab_axis_cnt=0))
  SET type = "ALL_TYPE"
 ELSEIF ((request->vocabularycnt > 0)
  AND (request->vocab_axis_cnt=0))
  SET type = "VOCABULARY_TYPE"
 ELSEIF ((request->vocabularycnt=0)
  AND (request->vocab_axis_cnt > 0))
  SET type = "VOCAB_AXIS"
 ELSEIF ((request->vocabularycnt > 0)
  AND (request->vocab_axis_cnt > 0))
  SET type = "VOCAB_AND_AXIS"
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
 IF (code_or_name="NONE")
  SET reply->status_data.status = "Z"
  SET reply->item_cnt = 0
  GO TO end_for_thistime
 ENDIF
 IF (code_or_name="NAME")
  SET done = false
  SET tempstr = fillstring(1000," ")
  SET tempstr = nullterm(request->namestring)
  CALL uar_normalize_string(nullterm(tempstr),outstr,nullterm(wcard),buflen,wcount)
  SET inpstr = outstr
  SET count2 = 0
  CALL echo(build("context->normalized_string:",context->normalized_string))
  CALL echo(build("context->nomenclature_id:",cnvtstring(context->nomenclature_id)))
  CALL echo(build("active_ind_val1:",cnvtstring(active_ind_val1)))
  CALL echo(code_or_name)
  CALL echo(type)
  SELECT
   IF (type="ALL_TYPE")
    FROM nomenclature n,
     normalized_string_index s
    PLAN (s
     WHERE s.normalized_string=patstring(inpstr)
      AND (s.normalized_string >= context->normalized_string)
      AND (s.nomenclature_id != context->nomenclature_id))
     JOIN (n
     WHERE s.nomenclature_id=n.nomenclature_id
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.end_effective_dt_tm > cnvtdatetime(end_dt_tm))
   ELSEIF (type="VOCABULARY_TYPE")
    FROM nomenclature n,
     normalized_string_index s,
     (dummyt d1  WITH seq = value(request->vocabularycnt))
    PLAN (s
     WHERE s.normalized_string=patstring(inpstr)
      AND (s.normalized_string >= context->normalized_string)
      AND (s.nomenclature_id != context->nomenclature_id))
     JOIN (d1
     WHERE (d1.seq <= context->vocabularycnt))
     JOIN (n
     WHERE s.nomenclature_id=n.nomenclature_id
      AND (n.source_vocabulary_cd=context->vocabularies[d1.seq].source_vocabulary_cd)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.end_effective_dt_tm > cnvtdatetime(end_dt_tm))
   ELSEIF (type="VOCAB_AXIS")
    FROM nomenclature n,
     normalized_string_index s,
     (dummyt d2  WITH seq = value(request->vocab_axis_cnt))
    PLAN (s
     WHERE s.normalized_string=patstring(inpstr)
      AND (s.normalized_string >= context->normalized_string)
      AND (s.nomenclature_id != context->nomenclature_id))
     JOIN (d2
     WHERE (d2.seq <= context->vocab_axis_cnt))
     JOIN (n
     WHERE s.nomenclature_id=n.nomenclature_id
      AND (n.vocab_axis_cd=context->vocab_axis[d2.seq].vocab_axis_cd)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.end_effective_dt_tm > cnvtdatetime(end_dt_tm))
   ELSEIF (type="VOCAB_AND_AXIS")
    FROM nomenclature n,
     normalized_string_index s,
     (dummyt d1  WITH seq = value(context->vocabularycnt)),
     (dummyt d2  WITH seq = value(context->vocab_axis_cnt))
    PLAN (s
     WHERE s.normalized_string=patstring(inpstr)
      AND (s.normalized_string >= context->normalized_string)
      AND (s.nomenclature_id != context->nomenclature_id))
     JOIN (d1
     WHERE (d1.seq <= context->vocabularycnt))
     JOIN (d2
     WHERE (d2.seq <= context->vocab_axis_cnt))
     JOIN (n
     WHERE s.nomenclature_id=n.nomenclature_id
      AND (n.source_vocabulary_cd=context->vocabularies[d1.seq].source_vocabulary_cd)
      AND (n.vocab_axis_cd=context->vocab_axis[d2.seq].vocab_axis_cd)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.end_effective_dt_tm > cnvtdatetime(end_dt_tm))
   ELSE
   ENDIF
   INTO "NL:"
   DETAIL
    IF (count1 < max)
     count1 = (count1+ 1), count2 = (count2+ 1), reply->items[count1].source_string = n.source_string,
     reply->items[count1].string_identifier = n.string_identifier, reply->items[count1].
     source_identifier = n.source_identifier, reply->items[count1].concept_identifier = n
     .concept_identifier,
     reply->items[count1].concept_source_cd = n.concept_source_cd, reply->items[count1].
     source_vocabulary_cd = n.source_vocabulary_cd, reply->items[count1].string_source_cd = n
     .string_source_cd,
     reply->items[count1].principle_type_cd = n.principle_type_cd, reply->items[count1].
     nomenclature_id = n.nomenclature_id, reply->items[count1].vocab_axis_cd = n.vocab_axis_cd,
     reply->items[count1].active_ind = n.active_ind, context->normalized_string = s.normalized_string,
     context->nomenclature_id = n.nomenclature_id
     IF (count1=max)
      context->context_ind = (context->context_ind+ 1), context->normalized_string = s
      .normalized_string, context->nomenclature_id = n.nomenclature_id
     ENDIF
    ENDIF
   WITH nocounter, maxqual(n,value(120)), maxread(s,7000)
  ;end select
  SET reply->item_cnt = count1
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
   SET request->codestring = " "
  ENDIF
  IF (count2=0)
   SET done = true
  ENDIF
 ELSEIF (code_or_name="CODE")
  SET done = false
  SET tempstr = fillstring(1000," ")
  SET tempstr = nullterm(request->codestring)
  SET inpstr = build(cnvtupper(tempstr),"*")
  SET count2 = 0
  CALL echo(code_or_name)
  CALL echo(type)
  SELECT
   IF (type="ALL_TYPE")
    FROM nomenclature n
    PLAN (n
     WHERE n.source_identifier=patstring(inpstr)
      AND (n.nomenclature_id != context->nomenclature_id)
      AND (n.source_identifier >= context->source_identifier)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.end_effective_dt_tm > cnvtdatetime(end_dt_tm))
   ELSEIF (type="VOCABULARY_TYPE")
    FROM nomenclature n,
     (dummyt d1  WITH seq = value(request->vocabularycnt))
    PLAN (d1
     WHERE (d1.seq <= request->vocabularycnt))
     JOIN (n
     WHERE n.source_identifier=patstring(inpstr)
      AND (n.source_vocabulary_cd=context->vocabularies[d1.seq].source_vocabulary_cd)
      AND (n.nomenclature_id != context->nomenclature_id)
      AND (n.source_identifier >= context->source_identifier)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.end_effective_dt_tm > cnvtdatetime(end_dt_tm))
   ELSEIF (type="VOCAB_AXIS")
    FROM nomenclature n,
     (dummyt d2  WITH seq = value(request->vocab_axis_cnt))
    PLAN (d2
     WHERE (d2.seq <= context->vocab_axis_cnt))
     JOIN (n
     WHERE n.source_identifier=patstring(inpstr)
      AND (n.vocab_axis_cd=context->vocab_axis[d2.seq].vocab_axis_cd)
      AND (n.nomenclature_id != context->nomenclature_id)
      AND (n.source_identifier >= context->source_identifier)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.end_effective_dt_tm > cnvtdatetime(end_dt_tm))
   ELSEIF (type="VOCAB_AND_AXIS")
    FROM nomenclature n,
     (dummyt d1  WITH seq = value(request->vocabularycnt)),
     (dummyt d2  WITH seq = value(request->vocab_axis_cnt))
    PLAN (d1
     WHERE (d1.seq <= context->vocabularycnt))
     JOIN (d2
     WHERE (d2.seq <= context->vocab_axis_cnt))
     JOIN (n
     WHERE n.source_identifier=patstring(inpstr)
      AND (n.source_identifier >= context->source_identifier)
      AND (n.nomenclature_id != context->nomenclature_id)
      AND (n.source_vocabulary_cd=context->vocabularies[d1.seq].source_vocabulary_cd)
      AND (n.vocab_axis_cd=context->vocab_axis[d2.seq].vocab_axis_cd)
      AND n.active_ind IN (active_ind_val1, active_ind_val2)
      AND n.end_effective_dt_tm > cnvtdatetime(end_dt_tm))
   ELSE
   ENDIF
   INTO "NL:"
   DETAIL
    IF (count1 < max)
     count1 = (count1+ 1), count2 = (count2+ 1), reply->items[count1].source_string = n.source_string,
     reply->items[count1].string_identifier = n.string_identifier, reply->items[count1].
     source_identifier = n.source_identifier, reply->items[count1].concept_identifier = n
     .concept_identifier,
     reply->items[count1].concept_source_cd = n.concept_source_cd, reply->items[count1].
     source_vocabulary_cd = n.source_vocabulary_cd, reply->items[count1].string_source_cd = n
     .string_source_cd,
     reply->items[count1].principle_type_cd = n.principle_type_cd, reply->items[count1].
     nomenclature_id = n.nomenclature_id, reply->items[count1].vocab_axis_cd = n.vocab_axis_cd,
     reply->items[count1].active_ind = n.active_ind, context->source_identifier = n.source_identifier,
     context->nomenclature_id = n.nomenclature_id
     IF (count1=max)
      context->context_ind = (context->context_ind+ 1), context->source_identifier = n
      .source_identifier, context->nomenclature_id = n.nomenclature_id
     ENDIF
    ENDIF
   WITH nocounter, maxqual(n,value(maxread)), orahint("index (n XAK2NOMENCLATURE)")
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
 SET errcode = error(err->msg,0)
 IF (errcode > 0)
  SET reply->errormsg = err->msg
  SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_get_byaxis"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "failure"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  CALL echo(err->msg)
 ELSE
  SET reply->errormsg = "no error"
  SET reply->status_data.subeventstatus[1].targetobjectname = "nomen_get_byaxis"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "success"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
 ENDIF
END GO
