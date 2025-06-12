CREATE PROGRAM bed_get_docset_dup:dba
 FREE SET reply
 RECORD reply(
   1 name_dup_ind = i2
   1 description_dup_ind = i2
   1 dynamic_group_dup_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 IF ((request->description > " "))
  SELECT INTO "nl:"
   FROM doc_set_ref d
   PLAN (d
    WHERE cnvtupper(d.doc_set_description)=cnvtupper(request->description)
     AND d.doc_set_ref_id=d.prev_doc_set_ref_id)
   DETAIL
    reply->description_dup_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->name > " "))
  SELECT INTO "nl:"
   FROM doc_set_ref d
   PLAN (d
    WHERE cnvtupper(d.doc_set_name)=cnvtupper(request->name)
     AND d.doc_set_ref_id=d.prev_doc_set_ref_id)
   DETAIL
    reply->name_dup_ind = 1
    IF (d.doc_set_description IN ("", " ", null))
     reply->dynamic_group_dup_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
