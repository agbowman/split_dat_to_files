CREATE PROGRAM bed_get_powernote_catalog:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 dlist[*]
     2 catalog_id = f8
     2 catalog_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cat_ep_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14409
    AND c.cdf_meaning="CAT EP")
  DETAIL
   cat_ep_cd = c.code_value
  WITH nocounter
 ;end select
 SET ccnt = size(request->clist,5)
 IF (ccnt=0)
  SELECT INTO "nl:"
   FROM scr_pattern sp
   PLAN (sp
    WHERE sp.pattern_type_cd=cat_ep_cd)
   ORDER BY sp.display_key
   HEAD REPORT
    dcnt = 0
   DETAIL
    dcnt = (dcnt+ 1), stat = alterlist(reply->dlist,dcnt), reply->dlist[dcnt].catalog_id = sp
    .scr_pattern_id,
    reply->dlist[dcnt].catalog_desc = sp.display
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->dlist,ccnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = ccnt),
   scr_pattern sp
  PLAN (d)
   JOIN (sp
   WHERE sp.scr_pattern_id=outerjoin(request->clist[d.seq].catalog_id))
  DETAIL
   reply->dlist[d.seq].catalog_id = request->clist[d.seq].catalog_id
   IF (sp.scr_pattern_id > 0)
    reply->dlist[d.seq].catalog_desc = sp.display
   ENDIF
  WITH nocounter, outerjoin = d
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
