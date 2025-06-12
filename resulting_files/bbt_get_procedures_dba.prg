CREATE PROGRAM bbt_get_procedures:dba
 RECORD reply(
   1 qual[*]
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 oe_format_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD activitytypes(
   1 qual[*]
     2 activity_type_cd = f8
 )
 SET err_cnt = 0
 SET qual_cnt = 0
 SET qual_cnt2 = 0
 SET reply->status_data.status = "F"
 SET stat = alterlist(activitytypes->qual,0)
 SET xm_cd = 0.0
 SET pat_abo_cd = 0.0
 SET product_order_cd = 0.0
 SET dispense_order_cd = 0.0
 SET trans_react_cd = 0.0
 SET bb_owner_cd = 0.0
 SET uar_failed = 0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "BB"
 SET stat = uar_get_meaning_by_codeset(106,cdf_meaning,1,bb_owner_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "XM"
 SET stat = uar_get_meaning_by_codeset(1635,cdf_meaning,1,xm_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "PATIENT ABO"
 SET stat = uar_get_meaning_by_codeset(1635,cdf_meaning,1,pat_abo_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "PRODUCT ORDR"
 SET stat = uar_get_meaning_by_codeset(1635,cdf_meaning,1,product_order_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "DISPENSE ORD"
 SET stat = uar_get_meaning_by_codeset(1635,cdf_meaning,1,dispense_order_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
 SET cdf_meaning = "TRANSF REACT"
 SET stat = uar_get_meaning_by_codeset(1635,cdf_meaning,1,trans_react_cd)
 IF (stat=1)
  SET uar_failed = 1
  GO TO skip_rest
 ENDIF
#skip_rest
 IF (uar_failed=1)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "106/1635"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Uar get meaning by codeset failed for ",cdf_meaning)
  GO TO end_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  ocs.synonym_id, ocs.catalog_cd, ocs.catalog_type_cd,
  ocs.mnemonic, sd.catalog_cd, ocs.oe_format_id,
  sd.bb_processing_cd
  FROM order_catalog oc,
   service_directory sd,
   order_catalog_synonym ocs
  PLAN (sd
   WHERE sd.bb_processing_cd > 0)
   JOIN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_cd=sd.catalog_cd
    AND oc.activity_type_cd=bb_owner_cd)
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.active_ind=1)
  ORDER BY ocs.synonym_id, ocs.catalog_cd, ocs.catalog_type_cd,
   ocs.mnemonic, ocs.oe_format_id
  DETAIL
   IF (sd.bb_processing_cd != xm_cd
    AND sd.bb_processing_cd != pat_abo_cd
    AND sd.bb_processing_cd != product_order_cd
    AND sd.bb_processing_cd != dispense_order_cd
    AND sd.bb_processing_cd != dispense_order_cd
    AND sd.bb_processing_cd != trans_react_cd)
    qual_cnt2 = (qual_cnt2+ 1), stat = alterlist(reply->qual,qual_cnt2), reply->qual[qual_cnt2].
    catalog_cd = ocs.catalog_cd,
    reply->qual[qual_cnt2].catalog_type_cd = ocs.catalog_type_cd, reply->qual[qual_cnt2].synonym_id
     = ocs.synonym_id, reply->qual[qual_cnt2].mnemonic = ocs.mnemonic,
    reply->qual[qual_cnt2].oe_format_id = ocs.oe_format_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "order_catalog_synonym"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "unable to return catalog codes"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_script
END GO
