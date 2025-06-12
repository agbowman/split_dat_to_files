CREATE PROGRAM cv_get_fld_xref:dba
 RECORD reply(
   1 xref_rec[*]
     2 display_name = vc
     2 xref_internal_name = vc
     2 registry_field_name = vc
     2 cern_source_table_name = c30
     2 cern_source_field_name = c30
     2 event_cd = f8
     2 xref_id = f8
     2 dataset_id = f8
     2 updt_cnt = i4
     2 task_assay_cd = f8
     2 cdf_meaning = c12
     2 event_type_cd = f8
     2 group_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET xref_size = size(reply->xref_rec,5)
 SET active_cd = 0
 SET event_cd = 0
 SET xref_id = 0
 SET count = 0
 SET xref_rec_cnt = 0
 SET dataset_id = 0
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET arr_size = 0
 SELECT INTO "nl:"
  ref.dataset_id, ref.task_assay_cd, ref.group_type_cd,
  ref.event_type_cd
  FROM cv_xref ref,
   (dummyt d1  WITH seq = value(size(request->get_rec,5)))
  PLAN (d1)
   JOIN (ref
   WHERE (ref.dataset_id=request->get_rec[d1.seq].dataset_id)
    AND ref.active_ind=1)
  HEAD REPORT
   xref_rec_cnt = 0, arr_size = alterlist(reply->xref_rec,10)
  DETAIL
   xref_rec_cnt = (xref_rec_cnt+ 1)
   IF (mod(xref_rec_cnt,10)=1
    AND xref_rec_cnt != 1)
    arr_size = alterlist(reply->xref_rec,(xref_rec_cnt+ 10))
   ENDIF
   reply->xref_rec[xref_rec_cnt].registry_field_name = ref.registry_field_name, reply->xref_rec[
   xref_rec_cnt].cern_source_table_name = ref.cern_source_table_name, reply->xref_rec[xref_rec_cnt].
   cern_source_field_name = ref.cern_source_field_name,
   reply->xref_rec[xref_rec_cnt].event_cd = ref.event_cd, reply->xref_rec[xref_rec_cnt].xref_id = ref
   .xref_id, reply->xref_rec[xref_rec_cnt].dataset_id = ref.dataset_id,
   reply->xref_rec[xref_rec_cnt].xref_internal_name = ref.xref_internal_name, reply->xref_rec[
   xref_rec_cnt].updt_cnt = ref.updt_cnt, reply->xref_rec[xref_rec_cnt].event_type_cd = ref
   .event_type_cd,
   reply->xref_rec[xref_rec_cnt].group_type_cd = ref.group_type_cd, reply->xref_rec[xref_rec_cnt].
   task_assay_cd = ref.task_assay_cd
  WITH nocounter
 ;end select
 SET arr_size = alterlist(reply->xref_rec,xref_rec_cnt)
 SET meaningval = fillstring(12," ")
 FOR (initialcnt = 1 TO xref_rec_cnt)
   SET itask_assay_cd = reply->xref_rec[initialcnt].task_assay_cd
 ENDFOR
 IF (curqual=0)
  CALL echo("There are no records in the table")
  SET reply->status_data.subeventstatus[1].operationname = "GET_fld_XREf"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CV_get_fld_xref"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CV_GET_fld_xref"
  SET reply->status_data.status = "Z"
 ELSE
  CALL echo("There are records in the table")
  SET reply->status_data.status = "S"
 ENDIF
END GO
