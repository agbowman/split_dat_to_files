CREATE PROGRAM bed_get_of_units:dba
 FREE SET reply
 RECORD reply(
   1 ulist[*]
     2 unit_id = f8
     2 unit_name = c40
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
 SET stat = alterlist(reply->ulist,20)
 SET tot_ucnt = 0
 SET ucnt = 0
 SELECT INTO "NL:"
  FROM br_of_parent_reltn b,
   code_value c,
   alt_sel_cat a
  PLAN (b
   WHERE b.source_name="CODE_VALUE")
   JOIN (c
   WHERE c.code_value=b.source_id
    AND c.code_set=220)
   JOIN (a
   WHERE a.alt_sel_category_id=outerjoin(b.alt_sel_category_id))
  ORDER BY c.code_value, a.alt_sel_category_id
  HEAD c.code_value
   tot_ucnt = (tot_ucnt+ 1), ucnt = (ucnt+ 1)
   IF (ucnt > 20)
    stat = alterlist(reply->ulist,(tot_ucnt+ 20)), ucnt = 0
   ENDIF
   reply->ulist[tot_ucnt].unit_id = b.source_id, reply->ulist[tot_ucnt].unit_name = c.display, stat
    = alterlist(reply->ulist[tot_ucnt].folders,20),
   tot_fcnt = 0, fcnt = 0
  HEAD a.alt_sel_category_id
   IF (a.alt_sel_category_id > 0)
    tot_fcnt = (tot_fcnt+ 1), fcnt = (fcnt+ 1)
    IF (fcnt > 20)
     stat = alterlist(reply->ulist[tot_ucnt].folders,(tot_fcnt+ 20)), fcnt = 0
    ENDIF
    reply->ulist[tot_ucnt].folders[tot_fcnt].folder_name = a.short_description
   ENDIF
  FOOT  c.code_value
   stat = alterlist(reply->ulist[tot_ucnt].folders,tot_fcnt)
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->ulist,tot_ucnt)
 IF (tot_ucnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
