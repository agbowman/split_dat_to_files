CREATE PROGRAM bed_get_oc_dup_concept_cki:dba
 FREE SET reply
 RECORD reply(
   1 concept_ckis[*]
     2 concept_cki = vc
     2 orders[*]
       3 catalog_code_value = f8
       3 description = vc
       3 primary_mnemonic = vc
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
 SET con_cnt = size(request->concept_ckis,5)
 SET stat = alterlist(reply->concept_ckis,con_cnt)
 FOR (x = 1 TO con_cnt)
  SET reply->concept_ckis[x].concept_cki = request->concept_ckis[x].concept_cki
  SELECT INTO "nl:"
   FROM order_catalog oc
   PLAN (oc
    WHERE (oc.concept_cki=request->concept_ckis[x].concept_cki)
     AND oc.active_ind=1)
   HEAD REPORT
    cnt = 0, list_cnt = 0, stat = alterlist(reply->concept_ckis[x].orders,100)
   DETAIL
    cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
    IF (list_cnt > 100)
     stat = alterlist(reply->concept_ckis[x].orders,(cnt+ 100)), list_cnt = 1
    ENDIF
    reply->concept_ckis[x].orders[cnt].catalog_code_value = oc.catalog_cd, reply->concept_ckis[x].
    orders[cnt].description = oc.description, reply->concept_ckis[x].orders[cnt].primary_mnemonic =
    oc.primary_mnemonic
   FOOT REPORT
    stat = alterlist(reply->concept_ckis[x].orders,cnt)
   WITH nocounter
  ;end select
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
