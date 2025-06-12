CREATE PROGRAM bed_get_iview_ord_titrate:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 catalog_code_value = f8
     2 mnemonic = vc
     2 synonyms[*]
       3 id = f8
       3 mnemonic = vc
       3 mnemonic_type
         4 code_value = f8
         4 display = vc
       3 ingredient_rate_conversion_ind = i2
       3 ignore_ind = i2
       3 facilities[*]
         4 code_value = f8
         4 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET ocnt = 0
 SET scnt = 0
 DECLARE pharm_cd = f8 WITH public, noconstant(0.0)
 SET pharm_cd = uar_get_code_by("MEANING",6000,"PHARMACY")
 RECORD temp(
   1 qual[*]
     2 cd = f8
 )
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_type_cd=pharm_cd
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.ingredient_rate_conversion_ind=1
    AND ocs.active_ind=1)
  ORDER BY oc.primary_mnemonic
  HEAD oc.primary_mnemonic
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cd = oc.catalog_cd
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog oc,
   order_catalog_synonym ocs,
   br_name_value b
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=temp->qual[d.seq].cd))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1)
   JOIN (b
   WHERE b.br_nv_key1=outerjoin("IVDRIPS_IGN_SYN")
    AND b.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
    AND b.br_value=outerjoin(cnvtstring(ocs.synonym_id)))
  ORDER BY d.seq, ocs.mnemonic
  HEAD d.seq
   scnt = 0, ocnt = (ocnt+ 1), stat = alterlist(reply->orderables,ocnt),
   reply->orderables[ocnt].catalog_code_value = oc.catalog_cd, reply->orderables[ocnt].mnemonic = oc
   .primary_mnemonic
  DETAIL
   scnt = (scnt+ 1), stat = alterlist(reply->orderables[ocnt].synonyms,scnt), reply->orderables[ocnt]
   .synonyms[scnt].id = ocs.synonym_id,
   reply->orderables[ocnt].synonyms[scnt].mnemonic = ocs.mnemonic, reply->orderables[ocnt].synonyms[
   scnt].mnemonic_type.code_value = ocs.mnemonic_type_cd, reply->orderables[ocnt].synonyms[scnt].
   mnemonic_type.display = uar_get_code_display(ocs.mnemonic_type_cd),
   reply->orderables[ocnt].synonyms[scnt].ingredient_rate_conversion_ind = ocs
   .ingredient_rate_conversion_ind
   IF (b.br_name_value_id > 0)
    reply->orderables[ocnt].synonyms[scnt].ignore_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   (dummyt d2  WITH seq = 1),
   ocs_facility_r o,
   code_value cv
  PLAN (d
   WHERE maxrec(d2,size(reply->orderables[d.seq].synonyms,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.synonym_id=reply->orderables[d.seq].synonyms[d2.seq].id))
   JOIN (cv
   WHERE cv.code_value=outerjoin(o.facility_cd)
    AND cv.active_ind=outerjoin(1))
  ORDER BY d.seq, d2.seq, cv.code_value
  HEAD d.seq
   fcnt = 0
  HEAD d2.seq
   fcnt = 0, ftcnt = 0, stat = alterlist(reply->orderables[d.seq].synonyms[d2.seq].facilities,100)
  HEAD cv.code_value
   IF (((o.facility_cd=0) OR (cv.code_value > 0)) )
    fcnt = (fcnt+ 1), ftcnt = (ftcnt+ 1)
    IF (fcnt > 100)
     stat = alterlist(reply->orderables[d.seq].synonyms[d2.seq].facilities,(ftcnt+ 100)), fcnt = 1
    ENDIF
    reply->orderables[d.seq].synonyms[d2.seq].facilities[ftcnt].code_value = cv.code_value, reply->
    orderables[d.seq].synonyms[d2.seq].facilities[ftcnt].display = trim(cv.display)
   ENDIF
  FOOT  d2.seq
   stat = alterlist(reply->orderables[d.seq].synonyms[d2.seq].facilities,ftcnt)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Failed to populate the facilities information.")
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
