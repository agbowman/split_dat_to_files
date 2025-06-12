CREATE PROGRAM dcp_get_outcome_tasks:dba
 RECORD reply(
   1 qual[1]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 result_type_cd = f8
     2 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET ncnt = 0
 SET reply->status_data.status = "F"
 SET code_value = 0.0
 SET alpha_type_cd = 0.0
 SET numeric_type_cd = 0.0
 SET multi_type_cd = 0.0
 SET code_set = 289
 SET cdf_meaning = "2"
 EXECUTE cpm_get_cd_for_cdf
 SET alpha_type_cd = code_value
 SET code_set = 289
 SET cdf_meaning = "3"
 EXECUTE cpm_get_cd_for_cdf
 SET numeric_type_cd = code_value
 SET code_set = 289
 SET cdf_meaning = "5"
 EXECUTE cpm_get_cd_for_cdf
 SET multi_type_cd = code_value
 IF ((request->filter_all_flag=1))
  SELECT INTO "nl:"
   dta.task_assay_cd, dta.mnemonic
   FROM discrete_task_assay dta,
    v500_event_code e
   PLAN (dta
    WHERE ((dta.mnemonic_key_cap >= trim(cnvtupper(request->task_description))) OR ((request->
    task_description=" ")))
     AND dta.active_ind=1
     AND ((dta.default_result_type_cd=alpha_type_cd) OR (((dta.default_result_type_cd=numeric_type_cd
    ) OR (dta.default_result_type_cd=multi_type_cd)) )) )
    JOIN (e
    WHERE e.event_cd=dta.event_cd)
   ORDER BY dta.mnemonic_key_cap
   HEAD REPORT
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1)
    IF (mod(ncnt,10)=2)
     stat = alter(reply->qual,(ncnt+ 10))
    ENDIF
    reply->qual[ncnt].task_assay_cd = dta.task_assay_cd, reply->qual[ncnt].mnemonic = trim(dta
     .mnemonic), reply->qual[ncnt].description = trim(dta.description),
    reply->qual[ncnt].result_type_cd = dta.default_result_type_cd, reply->qual[ncnt].event_cd = e
    .event_cd
   WITH nocounter, maxqual(dta,51)
  ;end select
 ELSE
  SELECT INTO "nl:"
   dta.task_assay_cd, dta.mnemonic
   FROM discrete_task_assay dta,
    v500_event_code e
   PLAN (dta
    WHERE ((dta.mnemonic_key_cap >= trim(cnvtupper(request->task_description))) OR ((request->
    task_description=" ")))
     AND dta.active_ind=1
     AND (dta.activity_type_cd=request->activity_type_cd)
     AND ((dta.default_result_type_cd=alpha_type_cd) OR (((dta.default_result_type_cd=numeric_type_cd
    ) OR (dta.default_result_type_cd=multi_type_cd)) )) )
    JOIN (e
    WHERE e.event_cd=dta.event_cd)
   ORDER BY dta.mnemonic_key_cap
   HEAD REPORT
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1)
    IF (mod(ncnt,10)=2)
     stat = alter(reply->qual,(ncnt+ 10))
    ENDIF
    reply->qual[ncnt].task_assay_cd = dta.task_assay_cd, reply->qual[ncnt].mnemonic = trim(dta
     .mnemonic), reply->qual[ncnt].description = trim(dta.description),
    reply->qual[ncnt].result_type_cd = dta.default_result_type_cd, reply->qual[ncnt].event_cd = e
    .event_cd
   WITH nocounter, maxqual(dta,51)
  ;end select
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET stat = alter(reply->qual,ncnt)
END GO
