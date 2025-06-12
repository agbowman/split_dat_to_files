CREATE PROGRAM ct_get_research_acc_details:dba
 DECLARE lock_error = i2 WITH private, constant(1)
 DECLARE update_error = i2 WITH private, constant(2)
 DECLARE delete_error = i2 WITH private, constant(7)
 DECLARE insert_error = i2 WITH private, constant(20)
 RECORD code_set_record(
   1 list[*]
     2 code_value = f8
     2 code_research_id = f8
     2 research_id = f8
     2 status = i2
     2 name = vc
     2 description = vc
     2 definition = vc
     2 end_date = dq8
     2 begin_date = dq8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply(
   1 cd_value_list[*]
     2 action_type_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply_child(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(domain_reply)))
  RECORD domain_reply(
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE ct_get_logical_domain_id  WITH replace("REPLY",domain_reply)
 DECLARE fail_flag = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE j = i4 WITH protect, noconstant(0)
 SELECT
  *
  FROM code_value cv
  WHERE cv.code_set=4504006
  HEAD REPORT
   j = 0
  DETAIL
   j += 1
   IF (mod(j,10)=1)
    stat = alterlist(code_set_record->list,(j+ 9))
   ENDIF
   code_set_record->list[j].code_value = cv.code_value, code_set_record->list[j].code_research_id =
   cnvtreal(cv.definition), code_set_record->list[j].name = cv.display,
   code_set_record->list[j].description = cv.description, code_set_record->list[j].definition = cv
   .definition, code_set_record->list[j].end_date = cv.end_effective_dt_tm,
   code_set_record->list[j].begin_date = cv.begin_effective_dt_tm, code_set_record->list[j].
   active_ind = cv.active_ind
  FOOT REPORT
   stat = alterlist(code_set_record->list,j)
 ;end select
 SET i = 0
 CALL echorecord(code_set_record)
 SELECT
  *
  FROM research_account ra,
   organization o
  PLAN (ra
   WHERE ra.research_account_id > 0)
   JOIN (o
   WHERE o.organization_id=ra.organization_id
    AND (o.logical_domain_id=domain_reply->logical_domain_id))
  ORDER BY ra.description
  HEAD REPORT
   pos = 0, rec_size = 0, rec_size_code_set = size(code_set_record->list,5)
  DETAIL
   size = 0, pos = 0, pos = locateval(i,1,rec_size_code_set,ra.research_account_id,code_set_record->
    list[i].code_research_id),
   rec_size += 1, stat = alterlist(reply->cd_value_list,rec_size)
   IF (pos > 0)
    reply->cd_value_list[rec_size].action_type_flag = 2, reply->cd_value_list[rec_size].code_value =
    code_set_record->list[i].code_value
   ELSEIF (pos=0)
    reply->cd_value_list[rec_size].action_type_flag = 1
   ENDIF
   reply->cd_value_list[rec_size].code_set = 4504006, reply->cd_value_list[rec_size].display = concat
   (trim(ra.description,7),concat("; ",trim(ra.account_nbr,7))), reply->cd_value_list[rec_size].
   description = ra.name,
   reply->cd_value_list[rec_size].definition = cnvtstring(ra.research_account_id), reply->
   cd_value_list[rec_size].end_effective_dt_tm = ra.end_effective_dt_tm, reply->cd_value_list[
   rec_size].begin_effective_dt_tm = ra.beg_effective_dt_tm,
   reply->cd_value_list[rec_size].active_ind = ra.active_ind
  WITH nocounter
 ;end select
 CALL echo("reply is here")
 CALL echo(reply)
 CALL echo(code_set_record)
 EXECUTE ct_core_ens_cd_value  WITH replace(reply,reply_child), replace(request,reply)
#check_error
 IF (fail_flag=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = ""
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].targetobjectname = ""
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
 ELSE
  CASE (fail_flag)
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.subeventstatus[1].operationstatus = "L"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Unknown error."
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
  ENDCASE
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 SET last_mod = "002"
 SET mod_date = "Oct 22, 2019"
 SET reqinfo->commit_ind = 1
END GO
