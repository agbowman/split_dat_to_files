CREATE PROGRAM bed_get_careset_comps:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 synonym_id = f8
     2 synonym_name = c100
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->slist,10)
 SET scnt = 0
 SET alterlist_scnt = 0
 SELECT INTO "NL:"
  FROM cs_component cs,
   order_catalog_synonym ocs
  PLAN (cs
   WHERE (cs.catalog_cd=request->catalog_code_value)
    AND cs.comp_id > 0)
   JOIN (ocs
   WHERE ocs.synonym_id=cs.comp_id)
  ORDER BY cs.comp_seq
  DETAIL
   alterlist_scnt = (alterlist_scnt+ 1)
   IF (alterlist_scnt > 10)
    stat = alterlist(reply->slist,(scnt+ 10)), alterlist_scnt = 1
   ENDIF
   scnt = (scnt+ 1), reply->slist[scnt].synonym_id = ocs.synonym_id, reply->slist[scnt].synonym_name
    = ocs.mnemonic
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->slist,scnt)
 IF (scnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
