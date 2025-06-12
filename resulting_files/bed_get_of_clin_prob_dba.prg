CREATE PROGRAM bed_get_of_clin_prob:dba
 FREE SET reply
 RECORD reply(
   1 clist[*]
     2 clin_prob_id = f8
     2 clin_prob_name = c255
     2 folders[*]
       3 folder_name = c500
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->clist,20)
 SET tot_ccnt = 0
 SET ccnt = 0
 SELECT INTO "NL:"
  FROM br_of_parent_reltn b,
   nomenclature n,
   alt_sel_cat a
  PLAN (b
   WHERE b.source_name="NOMENCLATURE")
   JOIN (n
   WHERE n.nomenclature_id=b.source_id)
   JOIN (a
   WHERE a.alt_sel_category_id=outerjoin(b.alt_sel_category_id))
  ORDER BY n.nomenclature_id, a.alt_sel_category_id
  HEAD n.nomenclature_id
   tot_ccnt = (tot_ccnt+ 1), ccnt = (ccnt+ 1)
   IF (ccnt > 20)
    stat = alterlist(reply->clist,(tot_ccnt+ 20)), ccnt = 0
   ENDIF
   reply->clist[tot_ccnt].clin_prob_id = b.source_id, reply->clist[tot_ccnt].clin_prob_name = n
   .source_string, stat = alterlist(reply->clist[tot_ccnt].folders,20),
   tot_fcnt = 0, fcnt = 0
  HEAD a.alt_sel_category_id
   IF (a.alt_sel_category_id > 0)
    tot_fcnt = (tot_fcnt+ 1), fcnt = (fcnt+ 1)
    IF (fcnt > 20)
     stat = alterlist(reply->clist[tot_ccnt].folders,(tot_fcnt+ 20)), fcnt = 0
    ENDIF
    reply->clist[tot_ccnt].folders[tot_fcnt].folder_name = a.short_description
   ENDIF
  FOOT  n.nomenclature_id
   stat = alterlist(reply->clist[tot_ccnt].folders,tot_fcnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->clist,tot_ccnt)
 IF (tot_ccnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
