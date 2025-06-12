CREATE PROGRAM bsc_get_dyn_lbl_by_event_id
 SET modify = predeclare
 RECORD reply(
   1 qual[*]
     2 event_id = f8
     2 dyanmic_label = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE size_array = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET size_array = size(request->qual,5)
 SELECT INTO "nl:"
  FROM clinical_event c,
   ce_dynamic_label ced,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (c
   WHERE (c.event_id=request->qual[d.seq].event_id))
   JOIN (ced
   WHERE ced.ce_dynamic_label_id=c.ce_dynamic_label_id
    AND ced.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  HEAD REPORT
   stat = alterlist(reply->qual,size_array)
  DETAIL
   reply->qual[d.seq].event_id = c.event_id, reply->qual[d.seq].dyanmic_label = ced.label_name
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->qual,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "000"
 SET mod_date = "06/06/2008"
 SET modify = nopredeclare
END GO
