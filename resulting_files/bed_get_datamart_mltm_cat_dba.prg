CREATE PROGRAM bed_get_datamart_mltm_cat:dba
 FREE SET reply
 RECORD reply(
   1 category[*]
     2 id = f8
     2 name = vc
     2 sub_category[*]
       3 id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET scnt = 0
 SELECT INTO "nl:"
  FROM mltm_drug_categories m,
   mltm_category_sub_xref s
  PLAN (m)
   JOIN (s
   WHERE s.multum_category_id=outerjoin(m.multum_category_id))
  ORDER BY m.category_name
  HEAD m.multum_category_id
   scnt = 0, ccnt = (ccnt+ 1), stat = alterlist(reply->category,ccnt),
   reply->category[ccnt].id = m.multum_category_id, reply->category[ccnt].name = m.category_name
  DETAIL
   IF (s.sub_category_id > 0)
    scnt = (scnt+ 1), stat = alterlist(reply->category[ccnt].sub_category,scnt), reply->category[ccnt
    ].sub_category[scnt].id = s.sub_category_id
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
