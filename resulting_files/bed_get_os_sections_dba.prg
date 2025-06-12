CREATE PROGRAM bed_get_os_sections:dba
 FREE SET reply
 RECORD reply(
   1 sections[*]
     2 name = vc
     2 order_sets[*]
       3 code_value = f8
       3 description = vc
       3 primary_synonym_mnemonic = vc
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
 SET list_cnt = 0
 SET cnt2 = 0
 SET list_cnt2 = 0
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM cs_component cs,
   order_catalog oc,
   code_value cv
  PLAN (cs)
   JOIN (oc
   WHERE oc.catalog_cd=cs.catalog_cd)
   JOIN (cv
   WHERE cv.code_set=6030
    AND cv.cdf_meaning="LABEL"
    AND cv.active_ind=1
    AND cv.code_value=cs.comp_type_cd)
  ORDER BY cs.comp_label, oc.catalog_cd
  HEAD REPORT
   cnt = 0, list_cnt = 0, stat = alterlist(reply->sections,100)
  HEAD cs.comp_label
   cnt = (cnt+ 1), list_cnt = (list_cnt+ 1)
   IF (list_cnt > 100)
    stat = alterlist(reply->sections,(cnt+ 100)), list_cnt = 1
   ENDIF
   reply->sections[cnt].name = cs.comp_label, cnt2 = 0, list_cnt2 = 0,
   stat = alterlist(reply->sections[cnt].order_sets,100)
  HEAD oc.catalog_cd
   cnt2 = (cnt2+ 1), list_cnt2 = (list_cnt2+ 1)
   IF (list_cnt2 > 100)
    stat = alterlist(reply->sections[cnt].order_sets,(cnt2+ 100)), list_cnt2 = 1
   ENDIF
   reply->sections[cnt].order_sets[cnt2].code_value = cs.catalog_cd, reply->sections[cnt].order_sets[
   cnt2].description = oc.description, reply->sections[cnt].order_sets[cnt2].primary_synonym_mnemonic
    = oc.primary_mnemonic
  FOOT  cs.comp_label
   stat = alterlist(reply->sections[cnt].order_sets,cnt2)
  FOOT REPORT
   stat = alterlist(reply->sections,cnt)
  WITH nocounter
 ;end select
#exit_script
 IF (cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
