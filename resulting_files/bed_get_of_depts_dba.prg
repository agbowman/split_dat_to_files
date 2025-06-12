CREATE PROGRAM bed_get_of_depts:dba
 FREE SET reply
 RECORD reply(
   1 dlist[*]
     2 dept_id = f8
     2 dept_name = c40
     2 selected_ind = i2
     2 folder_name = c500
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_ccount = 0
 SET ccount = 0
 SELECT INTO "NL:"
  FROM br_of_depts d,
   br_of_parent_reltn p,
   alt_sel_cat a
  PLAN (d)
   JOIN (p
   WHERE p.source_id=outerjoin(d.of_dept_id)
    AND p.source_name=outerjoin("BR_OF_DEPTS"))
   JOIN (a
   WHERE a.alt_sel_category_id=outerjoin(p.alt_sel_category_id))
  ORDER BY d.of_dept_name
  HEAD REPORT
   stat = alterlist(reply->dlist,20)
  DETAIL
   tot_ccount = (tot_ccount+ 1), ccount = (ccount+ 1)
   IF (ccount > 20)
    stat = alterlist(reply->dlist,(tot_ccount+ 20)), ccount = 0
   ENDIF
   reply->dlist[tot_ccount].dept_id = d.of_dept_id, reply->dlist[tot_ccount].dept_name = d
   .of_dept_name
   IF (p.alt_sel_category_id > 0.0)
    reply->dlist[tot_ccount].selected_ind = 1, reply->dlist[tot_ccount].folder_name = a
    .short_description
   ELSE
    reply->dlist[tot_ccount].selected_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->dlist,tot_ccount)
  WITH nocounter
 ;end select
 IF (tot_ccount=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
