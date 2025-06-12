CREATE PROGRAM cv_acknowledge_ed_review_rr
 IF (validate(request)=0)
  RECORD request(
    1 orderlist[*]
      2 order_id = f8
  ) WITH persistscript
 ENDIF
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH persistscript
 ENDIF
END GO
