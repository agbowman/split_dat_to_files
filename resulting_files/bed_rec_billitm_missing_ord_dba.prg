CREATE PROGRAM bed_rec_billitm_missing_ord:dba
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
 SET ord_cd = get_code_value(13016,"ORD CAT")
 SELECT INTO "nl:"
  FROM bill_item b,
   (dummyt d  WITH seq = 1),
   order_catalog o
  PLAN (b
   WHERE b.active_ind=1
    AND b.ext_parent_contributor_cd=ord_cd
    AND b.ext_child_reference_id=0
    AND  NOT (b.ext_parent_reference_id IN (313082, 313394, 313398, 313400, 313404,
   313406, 313410, 313412, 313416, 313418,
   313422, 313428, 644535, 670254, 670257,
   670259, 670261, 670263, 670265)))
   JOIN (d)
   JOIN (o
   WHERE o.catalog_cd=b.ext_parent_reference_id
    AND o.active_ind=1)
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
