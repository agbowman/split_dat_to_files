CREATE PROGRAM dcp_prompt_oef:dba
 RECORD reply(
   1 qual_cnt = f8
   1 qual[*]
     2 field_type_flag = f8
     2 mnemonic = vc
     2 code_set = f8
     2 task_assay_cd = f8
     2 parent_entity_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE numeric_field = f8 WITH constant(uar_get_code_by("MEANING",289,"3"))
 DECLARE date_field = f8 WITH constant(uar_get_code_by("MEANING",289,"6"))
 DECLARE time_field = f8 WITH constant(uar_get_code_by("MEANING",289,"11"))
 DECLARE freetext_field = f8 WITH constant(uar_get_code_by("MEANING",289,"7"))
 DECLARE text_field = f8 WITH constant(uar_get_code_by("MEANING",289,"1"))
 DECLARE codeset_field = f8 WITH constant(uar_get_code_by("MEANING",289,"9"))
 DECLARE alpha_field = f8 WITH constant(uar_get_code_by("MEANING",289,"2"))
 SELECT DISTINCT INTO "nl:"
  ptr.item_type_flag, dta.task_assay_cd
  FROM profile_task_r ptr,
   discrete_task_assay dta
  PLAN (ptr
   WHERE ptr.item_type_flag=1
    AND ptr.active_ind=1)
   JOIN (dta
   WHERE dta.task_assay_cd=ptr.task_assay_cd
    AND ((dta.default_result_type_cd=numeric_field) OR (((dta.default_result_type_cd=date_field) OR (
   ((dta.default_result_type_cd=freetext_field) OR (((dta.default_result_type_cd=text_field) OR (((
   dta.default_result_type_cd=codeset_field) OR (((dta.default_result_type_cd=alpha_field) OR (dta
   .default_result_type_cd=time_field)) )) )) )) )) ))
    AND dta.active_ind=1)
  ORDER BY dta.mnemonic
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   IF (dta.default_result_type_cd=numeric_field)
    reply->qual[count1].field_type_flag = 2
   ELSEIF (dta.default_result_type_cd=date_field)
    reply->qual[count1].field_type_flag = 3
   ELSEIF (((dta.default_result_type_cd=freetext_field) OR (dta.default_result_type_cd=text_field)) )
    reply->qual[count1].field_type_flag = 0
   ELSEIF (dta.default_result_type_cd=codeset_field)
    reply->qual[count1].field_type_flag = 6
   ELSEIF (dta.default_result_type_cd=alpha_field)
    reply->qual[count1].field_type_flag = 12
   ELSEIF (dta.default_result_type_cd=time_field)
    reply->qual[count1].field_type_flag = 5
   ENDIF
   reply->qual[count1].task_assay_cd = dta.task_assay_cd, reply->qual[count1].mnemonic = dta.mnemonic,
   reply->qual[count1].code_set = dta.code_set,
   reply->qual[count1].parent_entity_name = "DISCRETE_TASK_ASSAY"
  FOOT REPORT
   reply->qual_cnt = count1, stat = alterlist(reply->qual,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
