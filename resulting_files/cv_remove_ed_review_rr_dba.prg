CREATE PROGRAM cv_remove_ed_review_rr:dba
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
 CALL cv_log_msg_post("000 11/06/09 RV018483")
END GO
