CREATE PROGRAM bed_ens_hs_ign_source_items:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE itemcount = i4
 SET itemcount = size(request->items,5)
 RECORD tempitem(
   1 items[*]
     2 br_hlth_sntry_item_id = f8
 )
 SET stat = alterlist(tempitem->items,itemcount)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = itemcount),
   br_hlth_sntry_item b
  PLAN (d)
   JOIN (b
   WHERE (b.code_set=request->items[d.seq].code_set)
    AND (b.dim_item_ident=request->items[d.seq].dim_item_ident))
  DETAIL
   tempitem->items[d.seq].br_hlth_sntry_item_id = b.br_hlth_sntry_item_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error getting br_hlth_sntry_item_ids")
 DELETE  FROM (dummyt d  WITH seq = itemcount),
   br_name_value v
  SET v.seq = 1
  PLAN (d)
   JOIN (v
   WHERE v.br_nv_key1="HEALTHSENTIGN"
    AND (cnvtreal(v.br_name)=tempitem->items[d.seq].br_hlth_sntry_item_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Error deleting local ignore.")
 DELETE  FROM (dummyt d  WITH seq = itemcount),
   br_hlth_sntry_mill_item b
  SET b.seq = 1
  PLAN (d)
   JOIN (b
   WHERE (b.br_hlth_sntry_item_id=tempitem->items[d.seq].br_hlth_sntry_item_id))
  WITH nocounter
 ;end delete
 CALL bederrorcheck("Error deleting mapping")
 UPDATE  FROM (dummyt d  WITH seq = itemcount),
   br_hlth_sntry_item bhsi
  SET bhsi.ignore_ind = request->items[d.seq].ignore_ind
  PLAN (d)
   JOIN (bhsi
   WHERE (bhsi.br_hlth_sntry_item_id=tempitem->items[d.seq].br_hlth_sntry_item_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Error updating ignore_ind")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
