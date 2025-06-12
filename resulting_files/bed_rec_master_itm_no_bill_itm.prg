CREATE PROGRAM bed_rec_master_itm_no_bill_itm
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET item_master_cd = get_code_value(11001,"ITEM_MASTER")
 SET reply->run_status_flag = 1
 SELECT INTO "nl:"
  FROM item_master im,
   object_identifier_index oii,
   (dummyt d  WITH seq = 1),
   bill_item b
  PLAN (im)
   JOIN (oii
   WHERE oii.object_id=im.item_id
    AND oii.generic_object=0
    AND oii.object_type_cd=item_master_cd
    AND oii.active_ind=1)
   JOIN (d)
   JOIN (b
   WHERE b.ext_parent_reference_id=im.item_id
    AND b.active_ind=1)
  ORDER BY oii.value_key
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf
      AND c.active_ind=1)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
