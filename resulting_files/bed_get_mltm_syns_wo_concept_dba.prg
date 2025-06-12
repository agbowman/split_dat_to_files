CREATE PROGRAM bed_get_mltm_syns_wo_concept:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 catalog_code_value = f8
     2 description = vc
     2 primary_mnemonic = vc
     2 synonyms[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 cki = vc
       3 mltm_synonyms[*]
         4 cki = vc
         4 concept_cki = vc
         4 mnemonic = vc
       3 ignored_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET concept_exist_ind = 0
 SELECT INTO "nl:"
  FROM mltm_order_catalog_load m
  WHERE m.catalog_concept_cki > " "
   AND m.synonym_concept_cki > " "
  HEAD REPORT
   concept_exist_ind = 1
  WITH nocounter
 ;end select
 IF (concept_exist_ind=0)
  GO TO exit_script
 ENDIF
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET tcnt = 0
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   order_catalog oc,
   mltm_order_catalog_load m,
   br_name_value b
  PLAN (ocs
   WHERE ocs.cki="MUL.*"
    AND ocs.concept_cki IN ("", " ", null)
    AND ((ocs.catalog_type_cd+ 0)=pharm_ct)
    AND ((ocs.activity_type_cd+ 0)=pharm_at)
    AND ocs.active_ind=1)
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND oc.active_ind=1)
   JOIN (m
   WHERE m.synonym_cki=ocs.cki
    AND m.synonym_concept_cki > " ")
   JOIN (b
   WHERE b.br_nv_key1=outerjoin("MLTM_IGN_CONCEPT")
    AND b.br_name=outerjoin("ORDER_CATALOG_SYNONYM")
    AND b.br_value=outerjoin(cnvtstring(ocs.synonym_id)))
  ORDER BY ocs.catalog_cd, ocs.synonym_id, m.synonym_cki,
   m.synonym_concept_cki
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(reply->orders,100)
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->orders,(tcnt+ 100)), cnt = 1
   ENDIF
   reply->orders[tcnt].catalog_code_value = oc.catalog_cd, reply->orders[tcnt].description = oc
   .description, reply->orders[tcnt].primary_mnemonic = oc.primary_mnemonic,
   scnt = 0, stcnt = 0, stat = alterlist(reply->orders[tcnt].synonyms,100)
  HEAD ocs.synonym_id
   scnt = (scnt+ 1), stcnt = (stcnt+ 1)
   IF (scnt > 100)
    stat = alterlist(reply->orders[tcnt].synonyms,(stcnt+ 100)), scnt = 1
   ENDIF
   reply->orders[tcnt].synonyms[stcnt].synonym_id = ocs.synonym_id, reply->orders[tcnt].synonyms[
   stcnt].mnemonic = ocs.mnemonic, reply->orders[tcnt].synonyms[stcnt].cki = ocs.cki
   IF (b.br_name_value_id > 0)
    reply->orders[tcnt].synonyms[stcnt].ignored_ind = 1
   ENDIF
   mcnt = 0, mtcnt = 0, stat = alterlist(reply->orders[tcnt].synonyms[stcnt].mltm_synonyms,10)
  HEAD m.synonym_cki
   mcnt = mcnt
  HEAD m.synonym_concept_cki
   mcnt = (mcnt+ 1), mtcnt = (mtcnt+ 1)
   IF (mcnt > 10)
    stat = alterlist(reply->orders[tcnt].synonyms[stcnt].mltm_synonyms,(mtcnt+ 10)), mcnt = 1
   ENDIF
   reply->orders[tcnt].synonyms[stcnt].mltm_synonyms[mtcnt].cki = m.synonym_cki, reply->orders[tcnt].
   synonyms[stcnt].mltm_synonyms[mtcnt].concept_cki = m.synonym_concept_cki, reply->orders[tcnt].
   synonyms[stcnt].mltm_synonyms[mtcnt].mnemonic = m.mnemonic
  FOOT  ocs.synonym_id
   stat = alterlist(reply->orders[tcnt].synonyms[stcnt].mltm_synonyms,mtcnt)
  FOOT  oc.catalog_cd
   stat = alterlist(reply->orders[tcnt].synonyms,stcnt)
  FOOT REPORT
   stat = alterlist(reply->orders,tcnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
