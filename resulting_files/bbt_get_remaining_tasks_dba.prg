CREATE PROGRAM bbt_get_remaining_tasks:dba
 RECORD reply(
   1 qual[*]
     2 task_cd = f8
     2 task_disp = vc
     2 sequence = i2
     2 meaning = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET hold_assay = 0.0
 SELECT INTO "nl:"
  dta.task_assay_cd, dta.mnemonic, result_type_mean = decode(apr.seq,uar_get_code_meaning(apr
    .default_result_type_cd),uar_get_code_meaning(dta.default_result_type_cd))
  FROM discrete_task_assay dta,
   assay_processing_r apr,
   (dummyt d1  WITH seq = 1),
   profile_task_r ptr
  PLAN (ptr
   WHERE (ptr.catalog_cd=request->catalog_cd))
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND dta.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (apr
   WHERE apr.task_assay_cd=dta.task_assay_cd
    AND apr.active_ind=1)
  HEAD REPORT
   count1 = 0
  DETAIL
   IF ((dta.task_assay_cd != request->task_assay_cd))
    IF (hold_assay != dta.task_assay_cd)
     hold_assay = dta.task_assay_cd
     IF (result_type_mean != null
      AND result_type_mean != "1")
      count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].task_cd = dta
      .task_assay_cd,
      reply->qual[count1].task_disp = dta.mnemonic, reply->qual[count1].sequence = ptr.sequence,
      reply->qual[count1].meaning = result_type_mean,
      reply->qual[count1].concept_cki = dta.concept_cki
     ENDIF
    ENDIF
   ENDIF
  WITH counter, outerjoin(d1)
 ;end select
 IF (((curqual != 0) OR (count1 > 0)) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
