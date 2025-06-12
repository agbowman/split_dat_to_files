CREATE PROGRAM bbd_get_all_codes:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
     2 mnemonic = c12
     2 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SET qual_idx = 0
 IF ((request->cdf_meaning=""))
  SELECT INTO "nl:"
   c.code_value, c.code_set, c.display
   FROM code_value c
   WHERE (c.code_set=request->code_set)
   DETAIL
    qual_idx = (qual_idx+ 1), stat = alterlist(reply->qual,qual_idx), reply->qual[qual_idx].
    code_value = c.code_value,
    reply->qual[qual_idx].display = c.display
   WITH nocounter
  ;end select
 ELSE
  SET code_cnt = 1
  SET activity_cd = 0.0
  SET cdf = request->cdf_meaning
  SET code_set = request->code_set
  SET stat = uar_get_meaning_by_codeset(code_set,cdf,code_cnt,activity_cd)
  IF (activity_cd=0.0)
   SET failed = "T"
   SET reply->status = "F"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_all_codes.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Retrieve"
   SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
    "Unable to retrieve code value for code set ",code_set," and cdf meaning ",cdf)
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  SET result_type_cd = 0.0
  SET code_cnt = 1
  SET cdf = "4"
  SET code_set = 289
  SET stat = uar_get_meaning_by_codeset(code_set,cdf,code_cnt,result_type_cd)
  IF (result_type_cd=0.0)
   SET failed = "T"
   SET reply->status = "F"
   SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_get_all_codes.prg"
   SET reply->status_data.subeventstatus[1].operationname = "Retrieve"
   SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
    "Unable to retrieve code value for code set ",code_set," and cdf meaning ",cdf)
   SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   dta.activity_type_cd, dta.mnemonic, dta.default_result_type_cd
   FROM discrete_task_assay dta
   WHERE dta.activity_type_cd=activity_cd
    AND dta.default_result_type_cd=result_type_cd
   DETAIL
    qual_idx = (qual_idx+ 1), stat = alterlist(reply->qual,qual_idx), reply->qual[qual_idx].
    code_value = dta.activity_type_cd,
    reply->qual[qual_idx].mnemonic = dta.mnemonic, reply->qual[qual_idx].task_assay_cd = dta
    .task_assay_cd
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (qual_idx=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
