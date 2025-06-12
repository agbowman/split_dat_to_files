CREATE PROGRAM bed_get_oc_nu_list:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 catalog_code_value = f8
     2 description = vc
     2 primary_mnemonic = vc
     2 name_review_ind = i2
     2 concept_cki = vc
     2 proposed_name_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE oc_parse = vc
 SET cnt = 0
 SET list_cnt = 0
 SET oc_parse = concat(oc_parse," oc.active_ind = 1 ")
 SET oc_parse = concat(oc_parse," and oc.orderable_type_flag != 6 and oc.orderable_type_flag != 2 ")
 IF ((request->catalog_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.catalog_type_cd = ",request->catalog_type_code_value)
 ENDIF
 IF ((request->activity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_type_cd = ",request->activity_type_code_value)
 ENDIF
 IF ((request->subactivity_type_code_value > 0))
  SET oc_parse = build(oc_parse," and oc.activity_subtype_cd = ",request->subactivity_type_code_value
   )
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog oc,
   br_name_value bnv
  PLAN (oc
   WHERE parser(oc_parse))
   JOIN (bnv
   WHERE cnvtint(trim(bnv.br_name))=outerjoin(oc.catalog_cd)
    AND bnv.br_nv_key1=outerjoin("ORCNAMEREVIEWED"))
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->oc_list,100)
  DETAIL
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->oc_list,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->oc_list[cnt].catalog_code_value = oc.catalog_cd, reply->oc_list[cnt].description = oc
   .description, reply->oc_list[cnt].primary_mnemonic = oc.primary_mnemonic,
   reply->oc_list[cnt].concept_cki = oc.concept_cki
   IF (cnvtint(bnv.br_name) > 0)
    CALL echo("REVIEWED"), reply->oc_list[cnt].name_review_ind = 1
   ELSE
    reply->oc_list[cnt].name_review_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->oc_list,cnt)
  WITH nocounter
 ;end select
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt),
    br_auto_order_catalog b,
    br_auto_oc_synonym ba
   PLAN (d
    WHERE (reply->oc_list[d.seq].concept_cki > " "))
    JOIN (b
    WHERE (b.concept_cki=reply->oc_list[d.seq].concept_cki))
    JOIN (ba
    WHERE ba.catalog_cd=b.catalog_cd)
   ORDER BY d.seq
   HEAD d.seq
    reply->oc_list[d.seq].proposed_name_ind = 1
   WITH nocounter, skipbedrock = 1
  ;end select
 ENDIF
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ENDIF
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
