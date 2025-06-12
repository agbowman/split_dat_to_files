CREATE PROGRAM afc_get_fav_folder_list:dba
 DECLARE afc_get_fav_folder_list_ver = vc
 SET afc_get_fav_folder_list_ver = "001"
 RECORD reply(
   1 fav_folder_cat_qual = i2
   1 fav_folder_cat[*]
     2 fav_folder_cat_id = f8
     2 description = vc
     2 child_cat_ind = i2
     2 active_status_dt_tm = dq8
   1 fav_folder_list_qual = i2
   1 fav_folder_list[*]
     2 fav_folder_list_id = f8
     2 fav_folder_cat_id = f8
     2 list_type = i4
     2 child_fav_folder_cat_id = f8
     2 active_status_dt_tm = dq8
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_description = vc
     2 ext_owner_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET stat = alterlist(reply->fav_folder_cat,count1)
 SET stat = alterlist(reply->fav_folder_list,count1)
 SELECT INTO "nl:"
  l.*
  FROM fav_folder_list l,
   fav_folder_cat c
  PLAN (l
   WHERE (l.fav_folder_cat_id=request->fav_folder_cat_id)
    AND l.list_type=1
    AND l.bill_item_id=0
    AND l.child_fav_folder_cat_id > 0
    AND l.active_ind=1)
   JOIN (c
   WHERE c.fav_folder_cat_id=l.child_fav_folder_cat_id
    AND c.active_ind=1)
  ORDER BY c.fav_folder_cat_id
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->fav_folder_cat,count1), reply->fav_folder_cat[count1
   ].fav_folder_cat_id = c.fav_folder_cat_id,
   reply->fav_folder_cat[count1].description = c.description, reply->fav_folder_cat[count1].
   child_cat_ind = c.child_cat_ind, reply->fav_folder_cat[count1].active_status_dt_tm = cnvtdatetime(
    c.active_status_dt_tm)
  WITH nocounter
 ;end select
 SET reply->fav_folder_cat_qual = count1
 SET count1 = 0
 SELECT INTO "nl:"
  l.*
  FROM fav_folder_list l
  WHERE (l.fav_folder_cat_id=request->fav_folder_cat_id)
   AND l.list_type=2
   AND l.bill_item_id > 0
   AND l.child_fav_folder_cat_id IN (null, 0)
   AND l.active_ind=1
  ORDER BY l.fav_folder_list_id
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->fav_folder_list,count1), reply->fav_folder_list[
   count1].fav_folder_list_id = l.fav_folder_list_id,
   reply->fav_folder_list[count1].fav_folder_cat_id = l.fav_folder_cat_id, reply->fav_folder_list[
   count1].list_type = l.list_type, reply->fav_folder_list[count1].child_fav_folder_cat_id = l
   .child_fav_folder_cat_id,
   reply->fav_folder_list[count1].active_status_dt_tm = cnvtdatetime(l.active_status_dt_tm), reply->
   fav_folder_list[count1].bill_item_id = l.bill_item_id
  WITH nocounter
 ;end select
 SET reply->fav_folder_list_qual = count1
 IF (count1 > 0)
  SELECT INTO "nl:"
   b.bill_item_id
   FROM bill_item b,
    (dummyt d1  WITH seq = value(count1))
   PLAN (d1)
    JOIN (b
    WHERE (b.bill_item_id=reply->fav_folder_list[d1.seq].bill_item_id)
     AND b.active_ind=1)
   DETAIL
    reply->fav_folder_list[d1.seq].ext_parent_reference_id = b.ext_parent_reference_id, reply->
    fav_folder_list[d1.seq].ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->
    fav_folder_list[d1.seq].ext_description = b.ext_description,
    reply->fav_folder_list[d1.seq].ext_owner_cd = b.ext_owner_cd
   WITH nocounter
  ;end select
 ENDIF
END GO
