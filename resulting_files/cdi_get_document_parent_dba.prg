CREATE PROGRAM cdi_get_document_parent:dba
 RECORD reply(
   1 documents[*]
     2 blob_handle = vc
     2 parent_name = vc
     2 parent_id = f8
     2 clinical_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 DECLARE req_size = i4
 DECLARE rep_size = i4
 DECLARE idx = i4
 DECLARE storage_cd = f8 WITH public, noconstant(0.0)
 DECLARE dummy_ctr = i4 WITH noconstant(0)
 SET idx = 0
 SET req_size = size(request->documents,5)
 SET rep_size = 0
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(25,"OTG",1,storage_cd)
 SET stat = alterlist(reply->documents,req_size)
 SELECT INTO "nl:"
  cbr.blob_handle, ce.encntr_id, ce.person_id
  FROM ce_blob_result cbr,
   clinical_event ce
  PLAN (cbr
   WHERE cbr.storage_cd=storage_cd
    AND expand(idx,1,req_size,cbr.blob_handle,request->documents[idx].blob_handle))
   JOIN (ce
   WHERE cbr.event_id=ce.event_id)
  ORDER BY cbr.blob_handle, ce.valid_until_dt_tm DESC
  HEAD cbr.blob_handle
   rep_size = (rep_size+ 1)
   IF (size(reply->documents,5) < rep_size)
    stat = alterlist(reply->documents,rep_size)
   ENDIF
   reply->documents[rep_size].blob_handle = cbr.blob_handle, reply->documents[rep_size].clinical_ind
    = 1
   IF (ce.encntr_id != 0.0)
    reply->documents[rep_size].parent_name = "ENCOUNTER", reply->documents[rep_size].parent_id = ce
    .encntr_id
   ELSE
    reply->documents[rep_size].parent_name = "PERSON", reply->documents[rep_size].parent_id = ce
    .person_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  br.blob_handle, br.parent_entity_id, br.parent_entity_name
  FROM blob_reference br
  PLAN (br
   WHERE br.storage_cd=storage_cd
    AND expand(idx,1,req_size,br.blob_handle,request->documents[idx].blob_handle))
  ORDER BY br.blob_handle
  HEAD br.blob_handle
   rep_size = (rep_size+ 1)
   IF (size(reply->documents,5) < rep_size)
    stat = alterlist(reply->documents,rep_size)
   ENDIF
   reply->documents[rep_size].blob_handle = br.blob_handle, reply->documents[rep_size].clinical_ind
    = 0, reply->documents[rep_size].parent_name = br.parent_entity_name,
   reply->documents[rep_size].parent_id = br.parent_entity_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->documents,rep_size)
 IF (rep_size=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
