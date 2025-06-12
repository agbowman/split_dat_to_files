CREATE PROGRAM cv_utl_import_dataset:dba
 RECORD request_dataset(
   1 dataset_rec
     2 dataset_internal_name = vc
     2 display_name = vc
 )
 RECORD request_xref(
   1 cv_xref_rec[*]
     2 dataset_id = f8
     2 dataset_index = i2
     2 xref_internal_name = vc
     2 registry_field_name = vc
     2 cern_source_table_name = c30
     2 cern_source_field_name = c30
     2 event_type_cd = f8
     2 group_type_cd = f8
     2 event_type_mean = vc
     2 group_type_mean = vc
     2 cdf_meaning = vc
 )
 RECORD request_response(
   1 response_rec[*]
     2 field_type = c1
     2 response_internal_name = vc
     2 a1 = vc
     2 a2 = vc
     2 a3 = vc
     2 a4 = vc
     2 a5 = vc
     2 xref_id = f8
     2 xref_index = i2
 )
 SET request_dataset->dataset_rec.dataset_internal_name = requestin->list_0[0].datasetname
 SET request_dataset->dataset_rec.display_name = requestin->list_0[0].internalfieldname_xref
 EXECUTE cv_add_fld_dataset  WITH replace(request,request_dataset)
 SET data_set_id = 0.0
 SELECT INTO "NL:"
  FROM cv_dataset cd
  WHERE (cd.dataset_internal_name=requestin->list_0[0].datasetname)
  DETAIL
   data_set_id = cd.dataset_id
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  this_count = d.seq, data_set_name = requestin->list_0[d.seq].datasetname, internal_field_name_xref
   = requestin->list_0[d.seq].internalfieldname_xref,
  internal_field_name_res = requestin->list_0[d.seq].internalfieldname_res, registry_field_name =
  requestin->list_0[d.seq].registryfieldname, registry_field_short_name = requestin->list_0[d.seq].
  registryfieldshortname,
  registry_field_code_name = requestin->list_0[d.seq].registryfieldcodename, cdf_meaning = requestin
  ->list_0[d.seq].cdf_meaning, cern_source_table_name = requestin->list_0[d.seq].cernsourcetablename,
  cern_source_field_name = requestin->list_0[d.seq].cernsourcefieldname, field_type = requestin->
  list_0[d.seq].fieldtype, a1 = requestin->list_0[d.seq].a1,
  a2 = requestin->list_0[d.seq].a2, a3 = requestin->list_0[d.seq].a3, a4 = requestin->list_0[d.seq].
  a4,
  a5 = requestin->list_0[d.seq].a5, event_type = requestin->list_0[d.seq].eventtype, group_type =
  requestin->list_0[d.seq].grouptype
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d
   WHERE d.seq > 1)
  HEAD REPORT
   rec_cnt = 0, data_set_cnt = 0, fld_cnt = 0,
   response_cnt = 0, old_internalfieldname_xref = fillstring(100," "), new_internalfieldname_xref =
   fillstring(100," ")
  DETAIL
   rec_cnt = (rec_cnt+ 1), new_internalfieldname_xref = requestin->list_0[this_count].
   internalfieldname_xref
   IF (old_internalfieldname_xref != new_internalfieldname_xref)
    fld_cnt = (fld_cnt+ 1)
    IF (mod(fld_cnt,10)=1)
     stat = alterlist(request_xref->cv_xref_rec,(fld_cnt+ 9))
    ENDIF
    request_xref->cv_xref_rec[fld_cnt].dataset_index = data_set_cnt, request_xref->cv_xref_rec[
    fld_cnt].dataset_id = data_set_id, request_xref->cv_xref_rec[fld_cnt].xref_internal_name =
    requestin->list_0[this_count].internalfieldname_xref,
    request_xref->cv_xref_rec[fld_cnt].registry_field_name = requestin->list_0[d.seq].
    registryfieldname, request_xref->cv_xref_rec[fld_cnt].cern_source_table_name = requestin->list_0[
    d.seq].cernsourcetablename, request_xref->cv_xref_rec[fld_cnt].cern_source_field_name = requestin
    ->list_0[d.seq].cernsourcefieldname,
    request_xref->cv_xref_rec[fld_cnt].event_type_mean = requestin->list_0[d.seq].eventtype,
    request_xref->cv_xref_rec[fld_cnt].group_type_mean = requestin->list_0[d.seq].grouptype,
    request_xref->cv_xref_rec[fld_cnt].cdf_meaning = requestin->list_0[d.seq].cdf_meaning
   ENDIF
   old_internalfieldname_xref = new_internalfieldname_xref, response_cnt = (response_cnt+ 1)
   IF (mod(response_cnt,100)=1)
    stat = alterlist(request_response->response_rec,(response_cnt+ 99))
   ENDIF
   field_type = " "
   CASE (requestin->list_0[d.seq].fieldtype)
    OF "Alpha Response":
     field_type = "A"
    OF "Numeric":
     field_type = "N"
    OF "Date":
     field_type = "D"
    OF "String":
     field_type = "S"
   ENDCASE
   request_response->response_rec[response_cnt].field_type = field_type, request_response->
   response_rec[response_cnt].response_internal_name = requestin->list_0[d.seq].internalfieldname_res,
   request_response->response_rec[response_cnt].a1 = requestin->list_0[d.seq].a1,
   request_response->response_rec[response_cnt].a2 = requestin->list_0[d.seq].a2, request_response->
   response_rec[response_cnt].a3 = requestin->list_0[d.seq].a3, request_response->response_rec[
   response_cnt].a4 = requestin->list_0[d.seq].a4,
   request_response->response_rec[response_cnt].a5 = requestin->list_0[d.seq].a5, request_response->
   response_rec[response_cnt].xref_index = fld_cnt
  FOOT REPORT
   stat = alterlist(request_response->response_rec,response_cnt), stat = alterlist(request_xref->
    cv_xref_rec,fld_cnt)
  WITH nocounter
 ;end select
 RECORD reply_xref(
   1 return_rec[*]
     2 xref_id = f8
     2 xref_internal_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(request_xref->cv_xref_rec,5))),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=22310
    AND (cv.cdf_meaning=request_xref->cv_xref_rec[d.seq].group_type_mean))
  DETAIL
   request_xref->cv_xref_rec[d.seq].group_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(request_xref->cv_xref_rec,5))),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=22309
    AND (cv.cdf_meaning=request_xref->cv_xref_rec[d.seq].event_type_mean))
  DETAIL
   request_xref->cv_xref_rec[d.seq].event_type_cd = cv.code_value
  WITH nocounter
 ;end select
 EXECUTE cv_add_fld_xref  WITH replace(request,request_xref), replace(reply,reply_xref)
 FOR (idx = 1 TO size(request_response->response_rec,5))
   SET request_response->response_rec[idx].xref_id = reply_xref->return_rec[request_response->
   response_rec[idx].xref_index].xref_id
 ENDFOR
 EXECUTE cv_add_fld_response  WITH replace(request,request_response)
#exit_script
 CALL cv_log_message("Success!!!")
END GO
