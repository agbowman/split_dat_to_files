CREATE PROGRAM aps_get_inventory_barcode:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 item_id = f8
      2 barcode_string = vc
      2 truncated_barcode_accn = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE lreq_qual_cnt = i4 WITH protect, constant(size(request->qual,5))
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE lblankbarcodestringcount = i4 WITH protect, noconstant(0)
 EXECUTE pcs_label_integration_util
 SET reply->status_data.status = "F"
 SET lstat = alterlist(reply->qual,lreq_qual_cnt)
 FOR (lindex = 1 TO lreq_qual_cnt)
   SET reply->qual[lindex].item_id = request->qual[lindex].item_id
   SET reply->qual[lindex].barcode_string = getinventorybarcode(request->qual[lindex].
    unformatted_accn,request->qual[lindex].specimen_tag_seq,request->qual[lindex].cassette_tag_seq,
    request->qual[lindex].slide_tag_seq,request->qual[lindex].container_nbr)
   SET reply->qual[lindex].truncated_barcode_accn = gettruncatedaccession(request->qual[lindex].
    unformatted_accn)
   IF (size(reply->qual[lindex].barcode_string,1) <= 1)
    SET reply->status_data.status = "P"
    SET lblankbarcodestringcount += 1
   ENDIF
 ENDFOR
 IF (lblankbarcodestringcount=lreq_qual_cnt)
  SET reply->status_data.status = "F"
 ELSEIF ((reply->status_data.status != "P"))
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
