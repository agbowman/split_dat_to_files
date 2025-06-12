CREATE PROGRAM cps_add_reprint_hx:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 IF ( NOT (validate(reply,0)))
  FREE SET reply
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
 DECLARE reprint_to_add = i4 WITH protect, noconstant(0)
 SET reprint_to_add = size(request->qual,5)
 DECLARE idx = i4 WITH protect, noconstant(0)
 SET idx = 0
 DECLARE reprintid = f8 WITH protect, noconstant(0.0)
 SET reprintid = 0
 FOR (idx = 1 TO reprint_to_add)
   SELECT INTO "nl:"
    nextseq = seq(order_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     reprintid = cnvtint(nextseq)
    WITH format, nocounter
   ;end select
   INSERT  FROM reprint_hx rhx
    SET rhx.reprint_hx_id = reprintid, rhx.order_id = request->qual[idx].order_id, rhx.prsnl_id =
     request->qual[idx].prsnl_id,
     rhx.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   SET ierrcode = error(serrmsg,1)
   IF (((ierrcode > 0) OR (curqual=0)) )
    SET failed = select_error
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT_ERROR"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "REPRINT_HX"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
    GO TO exitscript
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
 ENDFOR
#exitscript
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SET script_ver = "000 12/03/04 BP9613"
END GO
