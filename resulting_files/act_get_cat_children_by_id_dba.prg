CREATE PROGRAM act_get_cat_children_by_id:dba
 RECORD reply(
   1 cat_qual[*]
     2 child_alt_sel_cat_id = f8
     2 long_description = vc
     2 short_description = vc
     2 ahfs_ind = i2
   1 syn_qual[*]
     2 synonym_id = f8
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE c_cnt = i4 WITH public, noconstant(0)
 DECLARE s_cnt = i4 WITH public, noconstant(0)
 SELECT INTO "nl:"
  FROM alt_sel_list asl,
   alt_sel_cat a
  PLAN (asl
   WHERE (asl.alt_sel_category_id=request->alt_sel_category_id))
   JOIN (a
   WHERE a.alt_sel_category_id=asl.child_alt_sel_cat_id)
  DETAIL
   IF (asl.list_type=1)
    c_cnt = (c_cnt+ 1), stat = alterlist(reply->cat_qual,c_cnt), reply->cat_qual[c_cnt].
    child_alt_sel_cat_id = asl.child_alt_sel_cat_id,
    reply->cat_qual[c_cnt].long_description = a.long_description, reply->cat_qual[c_cnt].
    short_description = a.short_description, reply->cat_qual[c_cnt].ahfs_ind = a.ahfs_ind
   ENDIF
   IF (asl.list_type=2)
    s_cnt = (s_cnt+ 1), stat = alterlist(reply->syn_qual,s_cnt), reply->syn_qual[s_cnt].synonym_id =
    asl.synonym_id,
    reply->syn_qual[s_cnt].sequence = asl.sequence
   ENDIF
  WITH nocounter
 ;end select
 IF (c_cnt=0
  AND s_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
