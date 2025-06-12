CREATE PROGRAM cps_get_last_ord_cmt:dba
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
 FREE SET reply
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 order_id = f8
     2 action_sequence = i4
     2 long_text_id = f8
     2 order_comment = vc
     2 order_comment_full = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET dvar = 0
 DECLARE dordcmttypecd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(14,"ORD COMMENT",1,dordcmttypecd)
 SELECT INTO "nl:"
  oc.order_id, oc.updt_dt_tm
  FROM order_comment oc,
   long_text lt,
   (dummyt d  WITH seq = value(request->qual_knt))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (oc
   WHERE (oc.order_id=request->qual[d.seq].order_id)
    AND (((request->qual[d.seq].get_ord_cmt_ind=0)) OR ((request->qual[d.seq].get_ord_cmt_ind=1)
    AND oc.comment_type_cd=dordcmttypecd)) )
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id
    AND lt.active_ind > 0)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  HEAD oc.order_id
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->qual,(knt+ 9))
   ENDIF
   reply->qual[knt].order_id = oc.order_id
  DETAIL
   dvar = 0
  FOOT  oc.order_id
   reply->qual[knt].long_text_id = oc.long_text_id, reply->qual[knt].action_sequence = oc
   .action_sequence, reply->qual[knt].order_comment = trim(substring(1,255,lt.long_text)),
   reply->qual[knt].order_comment_full = lt.long_text
  FOOT REPORT
   reply->qual_knt = knt, stat = alterlist(reply->qual,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT_ERROR"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_COMMENT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
#exit_script
 IF (failed=false)
  IF ((reply->qual_knt=0))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 SET script_version = "002 10/11/04 PC3603"
END GO
