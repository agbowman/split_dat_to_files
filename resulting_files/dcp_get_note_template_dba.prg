CREATE PROGRAM dcp_get_note_template:dba
 RECORD reply(
   1 template_id = f8
   1 template_name = vc
   1 note_template = vc
   1 large_text_qual[*]
     2 text_segment = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp_blobs(
   1 blobs[*]
     2 long_blob = vc
     2 blob_len = i4
 )
 DECLARE segmentcount = i4 WITH noconstant(0)
 DECLARE itr = i4 WITH noconstant(0)
 DECLARE listsize = i4 WITH noconstant(0)
 DECLARE blobtext = vc
 DECLARE iblockpos = i4 WITH noconstant(0)
 DECLARE sdelimiter = c9 WITH constant("<BLOCKID>")
 DECLARE isegmentnum = i4
 DECLARE itextsize = i4
 DECLARE ibloblen = i4 WITH noconstant(0)
 SET reply->status_data.status = "S"
 IF ((request->template_id > 0))
  SELECT INTO "nl:"
   FROM clinical_note_template nt,
    long_blob lb
   PLAN (nt
    WHERE (nt.template_id=request->template_id))
    JOIN (lb
    WHERE lb.parent_entity_id=nt.template_id
     AND lb.parent_entity_name="CLINICAL_NOTE_TEMPLATE")
   HEAD REPORT
    stat = alterlist(temp_blobs->blobs,10), listsize = 10, itr = 0
   HEAD nt.template_id
    reply->template_id = nt.template_id, reply->template_name = nt.template_name
   DETAIL
    itr = (itr+ 1)
    IF (itr > listsize)
     listsize = (listsize+ 10), stat = alterlist(temp_blobs->blobs,listsize)
    ENDIF
    temp_blobs->blobs[itr].long_blob = notrim(lb.long_blob), temp_blobs->blobs[itr].blob_len = lb
    .blob_length
   FOOT REPORT
    stat = alterlist(temp_blobs->blobs,itr), listsize = itr
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM clinical_note_template nt,
    long_blob lb
   PLAN (nt
    WHERE (nt.cki=request->cki))
    JOIN (lb
    WHERE lb.parent_entity_id=nt.template_id
     AND lb.parent_entity_name="CLINICAL_NOTE_TEMPLATE")
   HEAD REPORT
    stat = alterlist(temp_blobs->blobs,10), listsize = 10, itr = 0
   HEAD nt.template_id
    reply->template_id = nt.template_id, reply->template_name = nt.template_name
   DETAIL
    itr = (itr+ 1)
    IF (itr > listsize)
     listsize = (listsize+ 10), stat = alterlist(temp_blobs->blobs,listsize)
    ENDIF
    temp_blobs->blobs[itr].long_blob = notrim(lb.long_blob), temp_blobs->blobs[itr].blob_len = lb
    .blob_length
   FOOT REPORT
    stat = alterlist(temp_blobs->blobs,itr), listsize = itr
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(reply->large_text_qual,listsize)
 FOR (itr = 1 TO listsize)
   SET blobtext = notrim(temp_blobs->blobs[itr].long_blob)
   SET ibloblen = temp_blobs->blobs[itr].blob_len
   SET iblockpos = findstring(sdelimiter,blobtext,1,0)
   IF (iblockpos > 0)
    IF (size(blobtext,1) > ibloblen)
     SET blobtext = substring(1,ibloblen,blobtext)
    ENDIF
    SET isegmentnum = cnvtint(substring(1,(iblockpos - 1),blobtext))
    IF (itr=listsize)
     SET blobtext = trim(blobtext)
     SET ibloblen = size(blobtext,1)
     SET itextsize = (ibloblen - (iblockpos+ 8))
     SET blobtext = substring((iblockpos+ 9),itextsize,blobtext)
    ELSE
     SET itextsize = (ibloblen - (iblockpos+ 8))
     SET blobtext = notrim(substring((iblockpos+ 9),itextsize,blobtext))
    ENDIF
    SET reply->large_text_qual[isegmentnum].text_segment = notrim(blobtext)
   ELSE
    SET reply->large_text_qual[itr].text_segment = trim(blobtext)
   ENDIF
 ENDFOR
 SET reply->note_template = notrim(reply->large_text_qual[1].text_segment)
 IF (curqual=0)
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CLINICAL_NOTE_TEMPLATE"
 ENDIF
END GO
