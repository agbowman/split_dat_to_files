CREATE PROGRAM bed_get_all_sex_dupe_rr:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 assay_list[*]
      2 code_value = f8
      2 is_dupe = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 FREE SET all_sex_rows_reference_ranges
 RECORD all_sex_rows_reference_ranges(
   1 rows_list[*]
     2 assay_code_value = f8
     2 service_resource_code_value = f8
     2 rrf_id = f8
     2 from_age = i4
     2 to_age = i4
 )
 DECLARE size_of_request = i2 WITH protect, constant(size(request->assay_list,5))
 DECLARE cs57unkown = f8 WITH protect, constant(uar_get_code_by("MEANING",57,"UNKNOWN"))
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE all_sex_count = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->assay_list,size_of_request)
 SET stat = alterlist(all_sex_rows_reference_ranges->rows_list,10)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = size_of_request),
   reference_range_factor rrf
  PLAN (d)
   JOIN (rrf
   WHERE (rrf.task_assay_cd=request->assay_list[d.seq].code_value)
    AND (rrf.service_resource_cd != request->assay_list[d.seq].service_resource_code_value)
    AND rrf.sex_cd=0.0
    AND rrf.active_ind=1)
  DETAIL
   all_sex_count = (all_sex_count+ 1)
   IF (mod(all_sex_count,10)=0)
    stat = alterlist(all_sex_rows_reference_ranges->rows_list,(all_sex_count+ 10))
   ENDIF
   all_sex_rows_reference_ranges->rows_list[all_sex_count].assay_code_value = rrf.task_assay_cd,
   all_sex_rows_reference_ranges->rows_list[all_sex_count].service_resource_code_value = rrf
   .service_resource_cd, all_sex_rows_reference_ranges->rows_list[all_sex_count].rrf_id = rrf
   .reference_range_factor_id,
   all_sex_rows_reference_ranges->rows_list[all_sex_count].from_age = rrf.age_from_minutes,
   all_sex_rows_reference_ranges->rows_list[all_sex_count].to_age = rrf.age_to_minutes
  WITH nocounter
 ;end select
 CALL bederrorcheck("ALLSEXDUPERRERROR1: Error while getting all sex rows.")
 FOR (i = 1 TO size_of_request)
   SET reply->assay_list[i].code_value = request->assay_list[i].code_value
 ENDFOR
 SET stat = alterlist(all_sex_rows_reference_ranges->rows_list,all_sex_count)
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(all_sex_rows_reference_ranges->rows_list,5))),
   reference_range_factor rrf
  PLAN (d)
   JOIN (rrf
   WHERE (rrf.task_assay_cd=all_sex_rows_reference_ranges->rows_list[d.seq].assay_code_value)
    AND (rrf.service_resource_cd=all_sex_rows_reference_ranges->rows_list[d.seq].
   service_resource_code_value)
    AND rrf.sex_cd != 0.0
    AND (((request->unknown_sex_ind=1)) OR (rrf.sex_cd != cs57unkown))
    AND rrf.active_ind=1)
  ORDER BY d.seq, rrf.task_assay_cd
  DETAIL
   IF ((((all_sex_rows_reference_ranges->rows_list[d.seq].from_age <= rrf.age_from_minutes)
    AND (rrf.age_from_minutes <= all_sex_rows_reference_ranges->rows_list[d.seq].to_age)) OR ((((
   all_sex_rows_reference_ranges->rows_list[d.seq].from_age <= rrf.age_to_minutes)
    AND (rrf.age_to_minutes <= all_sex_rows_reference_ranges->rows_list[d.seq].to_age)) OR ((((rrf
   .age_from_minutes <= all_sex_rows_reference_ranges->rows_list[d.seq].from_age)
    AND (all_sex_rows_reference_ranges->rows_list[d.seq].from_age <= rrf.age_to_minutes)) OR ((rrf
   .age_from_minutes <= all_sex_rows_reference_ranges->rows_list[d.seq].to_age)
    AND (all_sex_rows_reference_ranges->rows_list[d.seq].to_age <= rrf.age_to_minutes))) )) )) )
    index = locateval(index,1,size_of_request,rrf.task_assay_cd,reply->assay_list[index].code_value),
    reply->assay_list[index].is_dupe = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("ALLSEXDUPERRERROR2: Error while checking for overlapping reference ranges.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
