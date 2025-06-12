CREATE PROGRAM core_get_ordcat_by_mnemonic:dba
 RECORD reply(
   1 qual[*]
     2 mnemonic = vc
     2 synonym_id = f8
     2 catalog_cd = f8
     2 activity_type_cd = f8
     2 cki_ordcat_synonym = vc
     2 cki_ordcat = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE meaning_code(mc_codeset,mc_meaning)
   SET mc_code = 0.0
   SET mc_text = fillstring(12," ")
   SET mc_text = mc_meaning
   SET mc_stat = uar_get_meaning_by_codeset(mc_codeset,mc_text,1,mc_code)
   IF (mc_code > 0.0)
    RETURN(mc_code)
   ELSE
    RETURN(- (1.0))
   ENDIF
 END ;Subroutine
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET cdf_meaning = fillstring(12," ")
 SET catalog_type_cd = 0.0
 IF ((request->catalog_type_cd=0))
  SET cdf_meaning = cnvtupper(trim(request->catalog_type_meaning))
  IF (cdf_meaning > " ")
   SET catalog_type_cd = meaning_code(6000,cdf_meaning)
  ENDIF
 ELSE
  SET catalog_type_cd = request->catalog_type_cd
 ENDIF
 SET mnemonic_type_cd = 0.0
 IF ((request->catalog_type_cd=0))
  SET cdf_meaning = cnvtupper(trim(request->mnemonic_type_meaning))
  IF (cdf_meaning > " ")
   SET mnemonic_type_cd = meaning_code(6011,cdf_meaning)
  ENDIF
 ELSE
  SET mnemonic_type_cd = request->mnemonic_type_cd
 ENDIF
 SET search_mnemonic = trim(request->mnemonic)
 IF (search_mnemonic > " ")
  SET search_key = concat(cnvtupper(search_mnemonic),"*")
 ELSE
  SET search_key = "A*"
 ENDIF
 SELECT INTO "nl:"
  oc.catalog_cd
  FROM order_catalog_synonym ocs,
   order_catalog oc
  PLAN (ocs
   WHERE ocs.mnemonic_key_cap=patstring(search_key)
    AND ((ocs.catalog_type_cd=catalog_type_cd) OR (catalog_type_cd=0))
    AND ((ocs.mnemonic_type_cd=mnemonic_type_cd) OR (mnemonic_type_cd=0))
    AND ocs.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,20)=1)
    stat = alterlist(reply->qual,(count1+ 19))
   ENDIF
   reply->qual[count1].mnemonic = ocs.mnemonic, reply->qual[count1].synonym_id = ocs.synonym_id,
   reply->qual[count1].catalog_cd = ocs.catalog_cd,
   reply->qual[count1].activity_type_cd = ocs.activity_type_cd, reply->qual[count1].
   cki_ordcat_synonym = ocs.cki, reply->qual[count1].cki_ordcat = oc.cki
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
