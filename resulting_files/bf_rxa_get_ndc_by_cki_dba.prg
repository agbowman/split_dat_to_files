CREATE PROGRAM bf_rxa_get_ndc_by_cki:dba
 SET sprogram = "rxa_get_ndc_by_cki"
 SET slastmod = "003"
 CALL echo("==============================================")
 CALL echo("==============================================")
 CALL echo(build("Start of <",sprogram,"> MOD ",slastmod))
 CALL echorecord(request)
 RECORD reply(
   1 item_list[*]
     2 ndc_formatted = vc
     2 med_product_id = f8
     2 item_id = f8
     2 sort_level_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD rxa_temp_reply(
   1 item_list[*]
     2 ndc_formatted = vc
     2 med_product_id = f8
     2 item_id = f8
     2 sort_level_ind = i2
 )
 DECLARE errcode = i4 WITH protect, noconstant(1)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 IF ( NOT (validate(errors,0)))
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  )
 ENDIF
 DECLARE ncki_size = i4 WITH private, noconstant(0)
 DECLARE nexclamation_pos = i4 WITH private, noconstant(0)
 DECLARE scki_number = vc WITH private, noconstant("")
 DECLARE dcki_number = f8 WITH protect, noconstant(0.0)
 DECLARE nlength = i4 WITH private, noconstant(0)
 DECLARE dfunctionid = f8 WITH protect, noconstant(0.0)
 DECLARE nmltmtblind = i2 WITH protect, noconstant(0)
 DECLARE nprodcnt = i2 WITH protect, noconstant(0)
 DECLARE cprimary = f8 WITH private, noconstant(0.0)
 DECLARE cbrandname = f8 WITH private, noconstant(0.0)
 DECLARE cdispdrug = f8 WITH private, noconstant(0.0)
 DECLARE ctradetop = f8 WITH private, noconstant(0.0)
 DECLARE cgenerictop = f8 WITH private, noconstant(0.0)
 DECLARE ctradeprod = f8 WITH private, noconstant(0.0)
 DECLARE cgenericprod = f8 WITH private, noconstant(0.0)
 DECLARE cretail = f8 WITH protect, noconstant(0.0)
 DECLARE coracle = c6 WITH private, constant("ORACLE")
 DECLARE c_mul_brand_primary = i2 WITH protect, constant(6)
 DECLARE c_mul_primary = i2 WITH protect, constant(5)
 DECLARE c_mul_nonref_primary = i2 WITH protect, constant(4)
 DECLARE c_mul_brand_secondary = i2 WITH protect, constant(3)
 DECLARE c_mul_secondary = i2 WITH protect, constant(2)
 DECLARE c_mul_nonref_secondary = i2 WITH protect, constant(1)
 DECLARE cdfmulmmdc = f8 WITH protect, noconstant(0.0)
 DECLARE cdfgenform = f8 WITH protect, noconstant(0.0)
 DECLARE cndc = f8 WITH protect, noconstant(0.0)
 SET cdfmulmmdc = uar_get_code_by("MEANING",400,"MUL.MMDC")
 SET cdfgenform = uar_get_code_by("MEANING",401,"GENFORM")
 SET stat = uar_get_meaning_by_codeset(11000,"NDC",1,cndc)
 SET stat = uar_get_meaning_by_codeset(6011,"PRIMARY",1,cprimary)
 SET stat = uar_get_meaning_by_codeset(6011,"BRANDNAME",1,cbrandname)
 SET stat = uar_get_meaning_by_codeset(6011,"DISPDRUG",1,cdispdrug)
 SET stat = uar_get_meaning_by_codeset(6011,"TRADETOP",1,ctradetop)
 SET stat = uar_get_meaning_by_codeset(6011,"GENERICTOP",1,cgenerictop)
 SET stat = uar_get_meaning_by_codeset(6011,"TRADEPROD",1,ctradeprod)
 SET stat = uar_get_meaning_by_codeset(6011,"GENERICPROD",1,cgenericprod)
 SET stat = uar_get_meaning_by_codeset(4500,"RETAIL",1,cretail)
 SET reply->status_data.status = "F"
 IF ((request->synonym_id > 0))
  SELECT INTO "nl:"
   FROM order_catalog_synonym ocs
   PLAN (ocs
    WHERE (ocs.synonym_id=request->synonym_id))
   DETAIL
    request->synonym_cki = trim(ocs.cki), request->mnemonic_type_cd = ocs.mnemonic_type_cd
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "order_catalog_synonym"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "request->synonym_id not in order_catalog_synonym"
  ENDIF
 ENDIF
 IF (size(trim(request->synonym_cki)) > 0)
  CALL echo(build("synonym_cki::",request->synonym_cki))
  SET ncki_size = size(request->synonym_cki)
  SET nexclamation_pos = findstring("!",request->synonym_cki,1,0)
  SET nlength = (ncki_size - nexclamation_pos)
  SET scki_number = substring((nexclamation_pos+ 1),nlength,request->synonym_cki)
  IF (size(trim(scki_number)) > 0)
   SET dcki_number = cnvtreal(scki_number)
  ELSE
   CALL echo("No CKI number found")
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "CHECK"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "request->synonym_cki"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "invalid request->synonym_cki "
   GO TO exit_script
  ENDIF
  CALL echo(build("CKI NUMBER::",dcki_number))
 ELSE
  CALL echo("NO CKI")
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "CHECK"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request->synonym_cki"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "no request->synonym_cki found"
  GO TO exit_script
 ENDIF
 CASE (request->mnemonic_type_cd)
  OF cprimary:
   SET dfunctionid = 16
  OF cbrandname:
   SET dfunctionid = 17
  OF cdispdrug:
   SET dfunctionid = 26
  OF ctradetop:
   SET dfunctionid = 60
  OF cgenerictop:
   SET dfunctionid = 59
  OF ctradeprod:
   SET dfunctionid = 60
  OF cgenericprod:
   SET dfunctionid = 59
  ELSE
   SET dfunctionid = 0
 ENDCASE
 CALL echo(build("FunctionID::",dfunctionid))
 IF (dfunctionid=0)
  CALL echo("unrecognized mnemonic Type cd")
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "CHECK"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "request->mnemonic_type_cd"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "unrecognized request->mnemonic_type_cd"
  GO TO exit_script
 ENDIF
 CALL echo(currdb)
 IF (trim(currdb)=trim(coracle))
  SELECT INTO "NL:"
   d.owner
   FROM dba_tables d
   PLAN (d
    WHERE d.table_name="NDC_CORE_DESCRIPTION"
     AND d.owner="V500")
   DETAIL
    nmltmtblind = 1
   WITH nocounter
  ;end select
  SELECT INTO "NL:"
   d.owner
   FROM dba_tables d
   PLAN (d
    WHERE d.table_name="MLTM_NDC_CORE_DESCRIPTION"
     AND d.owner="V500")
   DETAIL
    nmltmtblind = 2,
    CALL echo("2")
   WITH nocounter
  ;end select
 ELSE
  SET nmltmtblind = 2
 ENDIF
 CALL echo(build("Multum Table Ind::",nmltmtblind))
 SELECT
  IF (nmltmtblind=0)
   FROM (v500_ref.ndc_core_description ndc),
    (v500_ref.ndc_main_multum_drug_code mmdc),
    (v500_ref.multum_mmdc_name_map mmm),
    med_identifier mi
  ELSEIF (nmltmtblind=1)
   FROM (v500.ndc_core_description ndc),
    (v500.ndc_main_multum_drug_code mmdc),
    (v500.multum_mmdc_name_map mmm),
    med_identifier mi
  ELSEIF (nmltmtblind=2)
   FROM (v500.mltm_ndc_core_description ndc),
    (v500.mltm_ndc_main_drug_code mmdc),
    (v500.mltm_mmdc_name_map mmm),
    med_identifier mi
  ELSE
  ENDIF
  INTO "NL:"
  PLAN (mmm
   WHERE mmm.drug_synonym_id=dcki_number
    AND mmm.function_id=dfunctionid)
   JOIN (mmdc
   WHERE mmdc.main_multum_drug_code=mmm.main_multum_drug_code)
   JOIN (ndc
   WHERE ndc.main_multum_drug_code=mmdc.main_multum_drug_code
    AND ndc.brand_code=dcki_number)
   JOIN (mi
   WHERE trim(mi.value_key)=ndc.ndc_code
    AND mi.pharmacy_type_cd=cretail
    AND mi.active_ind=1
    AND mi.med_product_id > 0)
  ORDER BY mi.item_id, mi.med_product_id
  HEAD mi.item_id
   x = 0
  HEAD mi.med_product_id
   nprodcnt = (nprodcnt+ 1)
   IF (nprodcnt > size(reply->item_list,5))
    stat = alterlist(reply->item_list,(nprodcnt+ 5))
   ENDIF
   reply->item_list[nprodcnt].item_id = mi.item_id, reply->item_list[nprodcnt].med_product_id = mi
   .med_product_id, reply->item_list[nprodcnt].ndc_formatted = trim(mi.value)
   IF (mi.sequence=1)
    reply->item_list[nprodcnt].sort_level_ind = c_mul_brand_primary
   ELSE
    reply->item_list[nprodcnt].sort_level_ind = c_mul_brand_secondary
   ENDIF
  WITH nocounter
 ;end select
 WHILE (errcode != 0)
   SET errcode = error(errmsg,0)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,errcnt)
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
 ENDWHILE
 IF (size(reply->item_list,5)=0)
  CALL echo("No unique NDC match found. Falling back to MMDC level...")
  IF ((errors->err_cnt > 1))
   CALL echorecord(errors)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = "mltm_mmdc_name_map"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "no matching records found"
   GO TO exit_script
  ENDIF
 ELSE
  SET stat = alterlist(reply->item_list,nprodcnt)
  SET reply->status_data.status = "S"
 ENDIF
 SELECT
  IF (nmltmtblind=0)
   FROM (v500_ref.ndc_core_description ndc),
    (v500_ref.ndc_main_multum_drug_code mmdc),
    (v500_ref.multum_mmdc_name_map mmm),
    med_identifier mi
  ELSEIF (nmltmtblind=1)
   FROM (v500.ndc_core_description ndc),
    (v500.ndc_main_multum_drug_code mmdc),
    (v500.multum_mmdc_name_map mmm),
    med_identifier mi
  ELSEIF (nmltmtblind=2)
   FROM (v500.mltm_ndc_core_description ndc),
    (v500.mltm_ndc_main_drug_code mmdc),
    (v500.mltm_mmdc_name_map mmm),
    med_identifier mi
  ELSE
  ENDIF
  INTO "NL:"
  PLAN (mmm
   WHERE mmm.drug_synonym_id=dcki_number
    AND mmm.function_id=dfunctionid)
   JOIN (mmdc
   WHERE mmdc.main_multum_drug_code=mmm.main_multum_drug_code)
   JOIN (ndc
   WHERE ndc.main_multum_drug_code=mmdc.main_multum_drug_code)
   JOIN (mi
   WHERE trim(mi.value_key)=ndc.ndc_code
    AND mi.pharmacy_type_cd=cretail
    AND mi.active_ind=1
    AND mi.med_product_id > 0)
  ORDER BY mi.item_id, mi.med_product_id
  HEAD mi.item_id
   x = 0
  HEAD mi.med_product_id
   nprodcnt = (nprodcnt+ 1)
   IF (nprodcnt > size(reply->item_list,5))
    stat = alterlist(reply->item_list,(nprodcnt+ 5))
   ENDIF
   reply->item_list[nprodcnt].item_id = mi.item_id, reply->item_list[nprodcnt].med_product_id = mi
   .med_product_id, reply->item_list[nprodcnt].ndc_formatted = trim(mi.value)
   IF (mi.sequence=1)
    reply->item_list[nprodcnt].sort_level_ind = c_mul_primary
   ELSE
    reply->item_list[nprodcnt].sort_level_ind = c_mul_secondary
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->item_list,nprodcnt)
 WHILE (errcode != 0)
   SET errcode = error(errmsg,0)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,errcnt)
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
 ENDWHILE
 IF (curqual=0
  AND (errors->err_cnt > 1))
  CALL echo("No Products Found")
  IF ((errors->err_cnt > 1))
   CALL echorecord(errors)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "mltm_mmdc_name_map"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "no matching records found"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo(build("Multum Table Ind (rev 003)::",nmltmtblind))
 SELECT
  IF (nmltmtblind=0)
   FROM (v500_ref.ndc_main_multum_drug_code mmdc),
    (v500_ref.multum_mmdc_name_map mmm),
    medication_definition md,
    med_identifier mi
  ELSEIF (nmltmtblind=1)
   FROM (v500.ndc_main_multum_drug_code mmdc),
    (v500.multum_mmdc_name_map mmm),
    medication_definition md,
    med_identifier mi
  ELSEIF (nmltmtblind=2)
   FROM (v500.mltm_ndc_main_drug_code mmdc),
    (v500.mltm_mmdc_name_map mmm),
    medication_definition md,
    med_identifier mi
  ELSE
  ENDIF
  INTO "NL:"
  PLAN (mmm
   WHERE mmm.drug_synonym_id=dcki_number
    AND mmm.function_id=dfunctionid)
   JOIN (mmdc
   WHERE mmdc.main_multum_drug_code=mmm.main_multum_drug_code)
   JOIN (md
   WHERE md.cki=concat("MUL.FRMLTN!",cnvtstring(mmdc.main_multum_drug_code)))
   JOIN (mi
   WHERE mi.med_identifier_type_cd=cndc
    AND mi.pharmacy_type_cd=cretail
    AND mi.active_ind=1
    AND mi.med_product_id > 0)
  ORDER BY mi.item_id, mi.med_product_id
  HEAD mi.item_id
   x = 0
  HEAD mi.med_product_id
   nprodcnt = (nprodcnt+ 1)
   IF (nprodcnt > size(reply->item_list,5))
    stat = alterlist(reply->item_list,(nprodcnt+ 5))
   ENDIF
   reply->item_list[nprodcnt].item_id = mi.item_id, reply->item_list[nprodcnt].med_product_id = mi
   .med_product_id, reply->item_list[nprodcnt].ndc_formatted = trim(mi.value)
   IF (mi.sequence=1)
    reply->item_list[nprodcnt].sort_level_ind = c_mul_nonref_primary
   ELSE
    reply->item_list[nprodcnt].sort_level_ind = c_mul_nonref_secondary
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->item_list,nprodcnt)
 WHILE (errcode != 0)
   SET errcode = error(errmsg,0)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,errcnt)
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
 ENDWHILE
 IF (curqual=0
  AND (errors->err_cnt > 1))
  CALL echo("No Non Ref Products Found")
  CALL echorecord(errors)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = " medication_definition "
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "errors  found"
  GO TO exit_script
 ELSE
  IF (nprodcnt > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = "medication_definition"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "no matching records found"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (nprodcnt > 0)
  SET nlength = 0
  SET stat = alterlist(rxa_temp_reply->item_list,nprodcnt)
  FOR (nlength = 1 TO nprodcnt)
    SET rxa_temp_reply->item_list[nlength].item_id = reply->item_list[nlength].item_id
    SET rxa_temp_reply->item_list[nlength].med_product_id = reply->item_list[nlength].med_product_id
    SET rxa_temp_reply->item_list[nlength].ndc_formatted = reply->item_list[nlength].ndc_formatted
    SET rxa_temp_reply->item_list[nlength].sort_level_ind = reply->item_list[nlength].sort_level_ind
  ENDFOR
  SET stat = alterlist(reply->item_list,0)
  SET stat = alterlist(reply->item_list,nprodcnt)
  SELECT INTO "nl:"
   isortvalue = rxa_temp_reply->item_list[d1.seq].sort_level_ind
   FROM (dummyt d1  WITH seq = value(nprodcnt))
   PLAN (d1)
   ORDER BY isortvalue DESC
   DETAIL
    reply->item_list[d1.seq].item_id = rxa_temp_reply->item_list[d1.seq].item_id, reply->item_list[d1
    .seq].med_product_id = rxa_temp_reply->item_list[d1.seq].med_product_id, reply->item_list[d1.seq]
    .ndc_formatted = rxa_temp_reply->item_list[d1.seq].ndc_formatted,
    reply->item_list[d1.seq].sort_level_ind = rxa_temp_reply->item_list[d1.seq].sort_level_ind
   WITH nocounter
  ;end select
  FREE RECORD rxa_temp_reply
  WHILE (errcode != 0)
    SET errcode = error(errmsg,0)
    SET errcnt = (errcnt+ 1)
    IF (errcnt > size(errors->err,5))
     SET stat = alterlist(errors->err,errcnt)
    ENDIF
    SET errors->err[errcnt].err_code = errcode
    SET errors->err[errcnt].err_msg = errmsg
    SET errors->err_cnt = errcnt
  ENDWHILE
  IF (curqual=0
   AND (errors->err_cnt > 1))
   CALL echo("Error copying records from rxa_temp_reply into reply")
   CALL echorecord(errors)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Reply"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Rxa_Temp_Reply"
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET last_rxagetndcbycki_mod = slastmod
 CALL echorecord(reply)
END GO
