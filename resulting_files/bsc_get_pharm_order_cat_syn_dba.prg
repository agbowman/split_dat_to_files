CREATE PROGRAM bsc_get_pharm_order_cat_syn:dba
 DECLARE cpharmacy = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 SET v_cv_count = 0
 SET context->start_value = context->start_value
 SET request->start_value = request->start_value
 SELECT
  IF (context_ind=1)
   WHERE ocs.catalog_type_cd=cpharmacy
    AND ((ocs.orderable_type_flag IN (0, 1, 2, 3, 6,
   8, 9, 10, 11, 13)) OR (ocs.orderable_type_flag = null))
    AND ((ocs.mnemonic_key_cap > cnvtupper(context->start_value)
    AND ocs.mnemonic_key_cap=value(concat(cnvtupper(request->start_value),"*"))) OR (ocs
   .mnemonic_key_cap=cnvtupper(context->start_value)
    AND (ocs.synonym_id > context->num1)))
  ELSE
   WHERE ocs.catalog_type_cd=cpharmacy
    AND ((ocs.orderable_type_flag IN (0, 1, 2, 3, 6,
   8, 9, 10, 11, 13)) OR (ocs.orderable_type_flag = null))
    AND ocs.mnemonic_key_cap=value(concat(cnvtupper(request->start_value),"*"))
  ENDIF
  INTO "nl:"
  FROM order_catalog_synonym ocs
  ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id
  DETAIL
   v_cv_count = (v_cv_count+ 1), stat = alterlist(reply->datacoll,v_cv_count), reply->datacoll[
   v_cv_count].description = ocs.mnemonic,
   reply->datacoll[v_cv_count].currcv = trim(build2(ocs.synonym_id),3)
   IF (v_cv_count=maxqualrows)
    context->context_ind = (context->context_ind+ 1), context->start_value = ocs.mnemonic_key_cap,
    context->num1 = ocs.synonym_id,
    context->maxqual = request->maxqual
   ENDIF
  WITH nocounter, maxqual(ocs,value(maxqualrows))
 ;end select
 CALL echo("Last Mod: 003")
 CALL echo("Mod Date: 01/12/2018")
END GO
