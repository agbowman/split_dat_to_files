CREATE PROGRAM afc_get_bill_item_by_owner:dba
 SET afc_get_bill_item_by_owner_vrsn = 000
 FREE RECORD reply
 RECORD reply(
   1 qual[*]
     2 bill_item_id = f8
     2 ext_owner_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lreqqualsize = i4 WITH noconstant(0)
 DECLARE lcount = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET lreqqualsize = size(request->qual,lreqqualsize)
 IF (lreqqualsize > 0)
  EXECUTE pft_log "afc_get_bill_item_by_owner", build("Number Of Criterion Found = ",lreqqualsize), 4
  SELECT INTO "Nl:"
   FROM (dummyt d  WITH seq = value(size(request->qual,5))),
    bill_item bi
   PLAN (d)
    JOIN (bi
    WHERE (bi.ext_owner_cd=request->qual[d.seq].ext_owner_cd)
     AND bi.active_ind=1
     AND (bi.active_status_cd=reqdata->active_status_cd)
     AND bi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND bi.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY bi.ext_owner_cd
   DETAIL
    lcount = (lcount+ 1), stat = alterlist(reply->qual,lcount), reply->qual[lcount].bill_item_id = bi
    .bill_item_id,
    reply->qual[lcount].ext_owner_cd = bi.ext_owner_cd
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET reply->status_data.subeventstatus[1].operationname = "Select"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
   SET reply->status_data.status = "Z"
   EXECUTE pft_log "afc_get_bill_item_by_owner", "Returning Status Z::No Matching Bill Items Found",
   1
   GO TO exitscript
  ELSE
   EXECUTE pft_log "afc_get_bill_item_by_owner", build("Returning Status S::# Of Bill Items Found = ",
    lcount), 4
  ENDIF
 ELSE
  SET reply->status_data.subeventstatus[1].operationname = "Qual Size Is <= 0"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "STRUCT"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REQUEST->QUAL"
  EXECUTE pft_log "afc_get_bill_item_by_owner",
  "Returning Status F::No Search Criteria Received - No Search Will Be Performed", 0
  GO TO exitscript
 ENDIF
 SET reply->status_data.status = "S"
#exitscript
 CALL echorecord(reply)
END GO
