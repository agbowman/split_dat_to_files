CREATE PROGRAM bed_rec_ord_itm_no_bill_itm
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
 SET bcnt = 0
 SELECT INTO "nl:"
  desc = cnvtupper(o.description)
  FROM order_catalog o,
   (dummyt d  WITH seq = 1),
   bill_item b
  PLAN (o
   WHERE o.active_ind=1
    AND  NOT (o.orderable_type_flag IN (3, 7, 9)))
   JOIN (d)
   JOIN (b
   WHERE b.ext_parent_reference_id=o.catalog_cd
    AND b.active_ind=1)
  ORDER BY desc
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter, outerjoin = d, dontexist
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
