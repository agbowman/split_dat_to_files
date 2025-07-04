CREATE PROGRAM bed_rec_billitm_missing_master:dba
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
 SET reply->run_status_flag = 1
 SET im_cd = get_code_value(13016,"ITEM MASTER")
 SELECT INTO "nl:"
  FROM bill_item b,
   (dummyt d  WITH seq = 1),
   item_master i
  PLAN (b
   WHERE b.active_ind=1
    AND b.ext_parent_contributor_cd=im_cd)
   JOIN (d)
   JOIN (i
   WHERE i.item_id=b.ext_parent_reference_id)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter, outerjoin = d, dontexist
 ;end select
 IF ((reply->run_status_flag=1))
  SELECT INTO "nl:"
   FROM bill_item b,
    item_master i,
    item_definition id
   PLAN (b
    WHERE b.active_ind=1
     AND b.ext_parent_contributor_cd=im_cd)
    JOIN (i
    WHERE i.item_id=b.ext_parent_reference_id)
    JOIN (id
    WHERE id.item_id=i.item_id)
   DETAIL
    IF (id.active_ind != 1)
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
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
