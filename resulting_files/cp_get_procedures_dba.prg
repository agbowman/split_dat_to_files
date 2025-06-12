CREATE PROGRAM cp_get_procedures:dba
 RECORD reply(
   1 qual[1]
     2 catalog_cd = f8
     2 synonym_id = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET context_ind = 0
 SET count1 = 0
 IF (validate(context->context_ind,0) != 0)
  SET context->context_ind = 0
  SET context_ind = 1
  SET stat = alter(reply->qual,context->maxqual)
  SET catalog_type_cd = context->catalog_type_cd
 ELSE
  RECORD context(
    1 context_ind = i2
    1 synonym_id = f8
    1 mnemonic_key_cap = vc
    1 description = vc
    1 catalog_type_cd = f8
    1 maxqual = i4
  )
  SET stat = alter(reply->qual,request->maxqual)
  SET description_temp = cnvtupper(cnvtalphanum(request->description))
  SET description = concat(trim(description_temp),"*")
 ENDIF
 IF (context_ind=0)
  SELECT
   IF ((request->catalog_type_cd > 0))
    WHERE o.active_ind=1
     AND o.mnemonic_key_cap=patstring(description)
     AND (o.catalog_type_cd=request->catalog_type_cd)
   ELSE
    WHERE o.active_ind=1
     AND o.mnemonic_key_cap=patstring(description)
   ENDIF
   INTO "nl:"
   o.mnemonic_key_cap
   FROM order_catalog_synonym o
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), reply->qual[count1].catalog_cd = o.catalog_cd, reply->qual[count1].
    synonym_id = o.synonym_id,
    reply->qual[count1].mnemonic = o.mnemonic
    IF ((count1=request->maxqual))
     context->context_ind = 1, context->maxqual = request->maxqual, context->description =
     description,
     context->mnemonic_key_cap = o.mnemonic_key_cap, context->synonym_id = o.synonym_id, context->
     catalog_type_cd = request->catalog_type_cd
    ENDIF
   WITH nocounter, maxqual(o,value(request->maxqual))
  ;end select
  IF ((count1 < request->maxqual))
   SET stat = alter(reply->qual,count1)
  ENDIF
 ELSEIF (context_ind=1)
  SELECT
   IF ((context->catalog_type_cd > 0))
    WHERE o.active_ind=1
     AND o.mnemonic_key_cap=patstring(context->description)
     AND (((o.mnemonic_key_cap > context->mnemonic_key_cap)) OR ((o.mnemonic_key_cap=context->
    mnemonic_key_cap)
     AND (o.synonym_id > context->synonym_id)))
     AND (o.catalog_type_cd=context->catalog_type_cd)
   ELSE
    WHERE o.active_ind=1
     AND o.mnemonic_key_cap=patstring(context->description)
     AND (((o.mnemonic_key_cap > context->mnemonic_key_cap)) OR ((o.mnemonic_key_cap=context->
    mnemonic_key_cap)
     AND (o.synonym_id > context->synonym_id)))
   ENDIF
   INTO "nl:"
   o.mnemonic_key_cap
   FROM order_catalog_synonym o
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), reply->qual[count1].catalog_cd = o.catalog_cd, reply->qual[count1].
    synonym_id = o.synonym_id,
    reply->qual[count1].mnemonic = o.mnemonic
    IF ((count1=context->maxqual))
     context->context_ind = 1, context->mnemonic_key_cap = o.mnemonic_key_cap, context->synonym_id =
     o.synonym_id
    ENDIF
   WITH nocounter, maxqual(o,value(context->maxqual))
  ;end select
  IF ((count1 < context->maxqual))
   SET stat = alter(reply->qual,count1)
  ENDIF
 ENDIF
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
