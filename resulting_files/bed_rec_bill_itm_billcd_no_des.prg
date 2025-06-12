CREATE PROGRAM bed_rec_bill_itm_billcd_no_des
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
 SET bill_code_cd = get_code_value(13019,"BILL CODE")
 SELECT INTO "nl:"
  FROM bill_item_modifier bim,
   bill_item bi
  PLAN (bim
   WHERE bim.bill_item_type_cd=bill_code_cd
    AND bim.active_ind=1
    AND bim.key7 IN ("", " ", null)
    AND  NOT (bim.key6 IN ("", " ", null)))
   JOIN (bi
   WHERE bi.bill_item_id=bim.bill_item_id)
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
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
