CREATE PROGRAM aps_get_cases_with_images:dba
 RECORD reply(
   1 qual[*]
     2 accession_nbr = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET canceled_status_cd = 0.0
 SET verified_status_cd = 0.0
 SET corrected_status_cd = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(10," ")
 SET cnt = size(request->accession_qual,5)
 SET acc_cnt = 0
 SET x = 0
 SET y = 0
#script
 SET code_set = 1305
 SET cdf_meaning = "CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET canceled_status_cd = code_value
 SET code_value = 0.0
 SET cdf_meaning = "CORRECTED"
 EXECUTE cpm_get_cd_for_cdf
 SET corrected_status_cd = code_value
 SET code_value = 0.0
 SET cdf_meaning = "VERIFIED"
 EXECUTE cpm_get_cd_for_cdf
 SET verified_status_cd = code_value
 FOR (x = 1 TO cnt)
   FOR (y = 1 TO size(request->accession_qual[x].event_qual,5))
     IF ((request->accession_qual[x].event_qual[y].image_ind=1))
      IF ((request->accession_qual[x].qualify_ind=0))
       SET acc_cnt = (acc_cnt+ 1)
       IF (mod(acc_cnt,10)=1)
        SET stat = alterlist(reply->qual,(acc_cnt+ 9))
       ENDIF
       SET reply->qual[acc_cnt].accession_nbr = request->accession_qual[x].accession_nbr
       SET request->accession_qual[x].qualify_ind = 1
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  rdi.report_id
  FROM (dummyt d  WITH seq = value(cnt)),
   (dummyt d1  WITH seq = value(request->max_event_cnt)),
   case_report cr,
   report_detail_image rdi,
   blob_reference br,
   report_detail_task rdt
  PLAN (d
   WHERE (request->accession_qual[d.seq].qualify_ind=0))
   JOIN (d1
   WHERE d1.seq <= size(request->accession_qual[d.seq].event_qual,5))
   JOIN (rdt
   WHERE (rdt.event_id=request->accession_qual[d.seq].event_qual[d1.seq].event_id))
   JOIN (cr
   WHERE cr.report_id=rdt.report_id
    AND  NOT (cr.status_cd IN (verified_status_cd, corrected_status_cd, canceled_status_cd)))
   JOIN (rdi
   WHERE rdi.task_assay_cd=rdt.task_assay_cd)
   JOIN (br
   WHERE br.parent_entity_name="REPORT_DETAIL_IMAGE"
    AND br.parent_entity_id=rdi.report_detail_id)
  ORDER BY d.seq
  HEAD d.seq
   acc_cnt = (acc_cnt+ 1)
   IF (mod(acc_cnt,10)=1)
    stat = alterlist(reply->qual,(acc_cnt+ 9))
   ENDIF
   reply->qual[acc_cnt].accession_nbr = request->accession_qual[d.seq].accession_nbr, request->
   accession_qual[d.seq].qualify_ind = 1
  WITH nocounter
 ;end select
 IF (acc_cnt=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "REPORT_DETAIL_TASK"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "SELECT"
 ELSE
  SET stat = alterlist(reply->qual,acc_cnt)
  SET reply->status_data.status = "S"
 ENDIF
END GO
