CREATE PROGRAM afc_get_bill_item_by_ref_crit:dba
 SET afc_get_bill_item_by_ref_crit_vrsn = "000"
 RECORD reply(
   1 qual[*]
     2 bill_item_id = f8
     2 ext_parent_reference_id = f8
     2 ext_parent_contributor_cd = f8
     2 ext_child_reference_id = f8
     2 ext_child_contributor_cd = f8
     2 child_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE lcnt = i4 WITH noconstant(0), protect
 DECLARE lidx = i4 WITH noconstant(0), protect
 SET lcnt = size(request->qual,5)
 IF (lcnt > 0)
  SELECT INTO "nl:"
   b.bill_item_id
   FROM (dummyt d  WITH seq = value(lcnt)),
    bill_item b
   PLAN (d)
    JOIN (b
    WHERE (b.ext_parent_reference_id=request->qual[d.seq].ext_parent_reference_id)
     AND (b.ext_parent_contributor_cd=request->qual[d.seq].ext_parent_contributor_cd)
     AND (b.ext_child_reference_id=request->qual[d.seq].ext_child_reference_id)
     AND (b.ext_child_contributor_cd=request->qual[d.seq].ext_child_contributor_cd)
     AND (b.child_seq=request->qual[d.seq].child_seq)
     AND b.active_ind=1)
   DETAIL
    lidx = (lidx+ 1), stat = alterlist(reply->qual,lidx), reply->qual[lidx].bill_item_id = b
    .bill_item_id,
    reply->qual[lidx].ext_parent_reference_id = b.ext_parent_reference_id, reply->qual[lidx].
    ext_parent_contributor_cd = b.ext_parent_contributor_cd, reply->qual[lidx].ext_child_reference_id
     = b.ext_child_reference_id,
    reply->qual[lidx].ext_child_contributor_cd = b.ext_child_contributor_cd, reply->qual[lidx].
    child_seq = b.child_seq
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "Select"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "BILL_ITEM"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
