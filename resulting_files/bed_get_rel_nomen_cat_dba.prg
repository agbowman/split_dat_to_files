CREATE PROGRAM bed_get_rel_nomen_cat:dba
 FREE SET reply
 RECORD reply(
   1 nlist[*]
     2 nomen_cat_id = f8
     2 nomenclature_id = f8
     2 source_string = vc
     2 short_string = vc
     2 mnemonic = vc
     2 sequence = i4
     2 contributor_system_code_value = f8
     2 contributor_system_display = vc
     2 contributor_system_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "Z"
 SET tot_count = 0
 SET nomen_count = 0
 SET stat = alterlist(reply->nlist,100)
 DECLARE nomen_parse = vc
 SET clistcnt = size(request->clist,5)
 SET i = 0
 IF (clistcnt > 0)
  FOR (i = 1 TO clistcnt)
    IF (i=1)
     SET nomen_parse = build(nomen_parse,"((nl.parent_category_id = ",request->clist[i].nomen_cat_id,
      ")")
    ELSE
     SET nomen_parse = build(nomen_parse," or (nl.parent_category_id  = ",request->clist[i].
      nomen_cat_id,")")
    ENDIF
  ENDFOR
  SET nomen_parse = concat(nomen_parse,")")
 ENDIF
 CALL echo(build("nomen_parse = ",nomen_parse))
 SELECT INTO "NL:"
  FROM nomen_cat_list nl,
   nomenclature n,
   code_value cv
  PLAN (nl
   WHERE parser(nomen_parse))
   JOIN (n
   WHERE n.nomenclature_id=nl.nomenclature_id
    AND n.active_ind=1)
   JOIN (cv
   WHERE n.contributor_system_cd=cv.code_value
    AND cv.code_set=89)
  ORDER BY nl.parent_category_id, nl.list_sequence
  DETAIL
   tot_count = (tot_count+ 1), nomen_count = (nomen_count+ 1)
   IF (nomen_count > 100)
    stat = alterlist(reply->nlist,(tot_count+ 100)), nomen_cnt = 0
   ENDIF
   reply->nlist[tot_count].nomen_cat_id = nl.parent_category_id, reply->nlist[tot_count].
   nomenclature_id = nl.nomenclature_id, reply->nlist[tot_count].source_string = n.source_string,
   reply->nlist[tot_count].short_string = n.short_string, reply->nlist[tot_count].mnemonic = n
   .mnemonic, reply->nlist[tot_count].sequence = nl.list_sequence,
   reply->nlist[tot_count].contributor_system_code_value = cv.code_value, reply->nlist[tot_count].
   contributor_system_display = cv.display, reply->nlist[tot_count].contributor_system_mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->nlist,tot_count)
 IF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
