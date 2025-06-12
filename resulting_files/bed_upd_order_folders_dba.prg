CREATE PROGRAM bed_upd_order_folders:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 folder_id = f8
     2 sec_ind = i2
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SELECT INTO "nl:"
  FROM alt_sel_cat c
  PLAN (c
   WHERE c.alt_sel_category_id > 0
    AND c.long_description != "DRUGCLASSES"
    AND c.security_flag IN (0, null))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].folder_id = c
   .alt_sel_category_id
   IF (c.owner_id=0)
    temp->qual[cnt].sec_ind = 2
   ELSE
    temp->qual[cnt].sec_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = 0
 UPDATE  FROM alt_sel_cat c,
   (dummyt d  WITH seq = value(size(temp->qual,5)))
  SET c.seq = 1, c.security_flag =
   IF ((temp->qual[d.seq].sec_ind=2)) 2
   ELSEIF ((temp->qual[d.seq].sec_ind=1)) 1
   ENDIF
  PLAN (d)
   JOIN (c
   WHERE (c.alt_sel_category_id=temp->qual[d.seq].folder_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
