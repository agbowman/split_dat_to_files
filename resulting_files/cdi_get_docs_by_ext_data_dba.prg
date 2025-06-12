CREATE PROGRAM cdi_get_docs_by_ext_data:dba
 RECORD reply(
   1 documents[*]
     2 pending_document_id = f8
     2 blob_handle = vc
     2 event_cd = f8
     2 event_codeset = i4
     2 subject_text = vc
     2 service_dt_tm = dq8
     2 process_location_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE index = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE aliaslistsize = i4 WITH noconstant(value(size(request->alias_list,5))), protect
 SELECT INTO "NL:"
  c.cdi_pending_document_id, c.blob_handle, c.event_cd,
  c.event_codeset, c.subject_text, c.service_dt_tm,
  c.process_location_flag
  FROM cdi_pending_document c,
   cdi_doc_dyn_metadata cd
  PLAN (cd
   WHERE expand(idx,1,aliaslistsize,cd.alias_type_cd,request->alias_list[idx].alias_type_cd,
    cd.field_value,request->alias_list[idx].field_value))
   JOIN (c
   WHERE c.cdi_pending_document_id=cd.cdi_pending_document_id
    AND c.active_ind=1
    AND c.source_flag=2
    AND (c.parent_level_flag=request->parent_level_flag)
    AND ((c.process_location_flag=1) OR (c.process_location_flag=2)) )
  HEAD c.cdi_pending_document_id
   count = 0
  DETAIL
   count = (count+ 1)
  FOOT  c.cdi_pending_document_id
   IF (count=aliaslistsize)
    index = (index+ 1)
    IF (mod(index,10)=1)
     stat = alterlist(reply->documents,10)
    ENDIF
    reply->documents[index].pending_document_id = c.cdi_pending_document_id, reply->documents[index].
    blob_handle = c.blob_handle, reply->documents[index].event_cd = c.event_cd,
    reply->documents[index].event_codeset = c.event_codeset, reply->documents[index].service_dt_tm =
    c.service_dt_tm, reply->documents[index].subject_text = c.subject_text,
    reply->documents[index].process_location_flag = c.process_location_flag
   ENDIF
 ;end select
 SET stat = alterlist(reply->documents,index)
 IF (index=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
