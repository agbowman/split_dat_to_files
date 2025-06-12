CREATE PROGRAM cp_get_catalog_codes:dba
 RECORD reply(
   1 qual[*]
     2 catalog_cd = f8
     2 mnemonic = vc
     2 synonym_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE context_ind = i2
 DECLARE count = i4
 DECLARE primary_cd = f8
 DECLARE description = vc
 SET reply->status_data.status = "F"
 IF (validate(context->context_ind,0) != 0)
  CALL echo("In context record of ChartFormatBuilder")
  SET context->context_ind = 0
  SET context_ind = 1
  SET primary_cd = context->primary_cd
  SET stat = alterlist(reply->qual,context->maxqual)
 ELSE
  RECORD context(
    1 context_ind = i2
    1 synonym_id = f8
    1 mnemonic_key_cap = vc
    1 description = vc
    1 maxqual = i4
    1 primary_cd = f8
  )
  SET stat = uar_get_meaning_by_codeset(6011,"PRIMARY",1,primary_cd)
  SET description = concat(cnvtupper(request->description),"*")
  SET stat = alterlist(reply->qual,request->maxqual)
 ENDIF
 IF (context_ind=0)
  SELECT INTO "nl:"
   o.mnemonic_key_cap
   FROM order_catalog_synonym o
   PLAN (o
    WHERE o.mnemonic_key_cap=patstring(description)
     AND o.mnemonic_type_cd=primary_cd
     AND o.orderable_type_flag IN (0, 1)
     AND o.active_ind=1
     AND  EXISTS (
    (SELECT
     ptr.catalog_cd
     FROM profile_task_r ptr,
      code_value_event_r cver
     WHERE ptr.catalog_cd=o.catalog_cd
      AND ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd)) )))
   ORDER BY o.mnemonic_key_cap
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), reply->qual[count].catalog_cd = o.catalog_cd, reply->qual[count].mnemonic = o
    .mnemonic,
    reply->qual[count].synonym_id = o.synonym_id
    IF ((count=request->maxqual))
     context->context_ind = 1, context->maxqual = request->maxqual, context->description =
     description,
     context->mnemonic_key_cap = o.mnemonic_key_cap, context->synonym_id = o.synonym_id, context->
     primary_cd = primary_cd
    ENDIF
   WITH nocounter, maxqual(o,value(request->maxqual))
  ;end select
 ELSEIF (context_ind=1)
  SELECT INTO "nl:"
   o.mnemonic_key_cap
   FROM order_catalog_synonym o
   PLAN (o
    WHERE o.mnemonic_key_cap=patstring(context->description)
     AND (((o.mnemonic_key_cap > context->mnemonic_key_cap)) OR ((o.mnemonic_key_cap=context->
    mnemonic_key_cap)
     AND (o.synonym_id > context->synonym_id)))
     AND o.mnemonic_type_cd=primary_cd
     AND o.active_ind=1
     AND  EXISTS (
    (SELECT
     ptr.catalog_cd
     FROM profile_task_r ptr,
      code_value_event_r cver
     WHERE ptr.catalog_cd=o.catalog_cd
      AND ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd)) )))
   ORDER BY o.mnemonic_key_cap
   HEAD REPORT
    count = 0
   DETAIL
    count = (count+ 1), reply->qual[count].catalog_cd = o.catalog_cd, reply->qual[count].mnemonic = o
    .mnemonic,
    reply->qual[count].synonym_id = o.synonym_id
    IF ((count=context->maxqual))
     context->context_ind = 1, context->mnemonic_key_cap = o.mnemonic_key_cap, context->synonym_id =
     o.synonym_id
    ENDIF
   WITH nocounter, maxqual(o,value(context->maxqual))
  ;end select
 ENDIF
 IF ((count < request->maxqual))
  SET stat = alterlist(reply->qual,count)
 ENDIF
 IF ((context->context_ind=0))
  FREE RECORD context
  CALL echo("context record freed")
 ELSE
  CALL echorecord(context)
 ENDIF
 IF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
