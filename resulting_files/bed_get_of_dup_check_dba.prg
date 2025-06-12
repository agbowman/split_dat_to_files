CREATE PROGRAM bed_get_of_dup_check:dba
 FREE SET reply
 RECORD reply(
   1 duplicate_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET reply->duplicate_ind = 0
 SET inpt_short_desc = fillstring(500," ")
 SELECT INTO "NL:"
  FROM alt_sel_cat a
  WHERE a.long_description="INPTCATEGORY"
  DETAIL
   inpt_short_desc = a.short_description
  WITH nocounter
 ;end select
 IF (cnvtalphanum(cnvtupper(request->folder_name))=cnvtalphanum(cnvtupper(inpt_short_desc)))
  SET reply->duplicate_ind = 1
 ELSE
  SELECT INTO "NL:"
   FROM alt_sel_cat a
   WHERE a.ahfs_ind IN (0, null)
    AND a.adhoc_ind IN (0, null)
    AND a.folder_flag IN (0, 1, null)
    AND a.owner_id=0
   DETAIL
    IF (cnvtalphanum(cnvtupper(a.short_description))=cnvtalphanum(cnvtupper(request->folder_name)))
     reply->duplicate_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
