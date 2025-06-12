CREATE PROGRAM core_add_code_set
 IF ((validate(reply->next_code_set,- (123))=- (123)))
  FREE RECORD reply
  RECORD reply(
    1 next_code_set = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
      2 message = vc
  )
 ENDIF
 FREE RECORD cecs_request
 RECORD cecs_request(
   1 cd_set_list[*]
     2 action_type_flag = i2
     2 active_ind_dup_ind = i2
     2 add_access_ind = i2
     2 alias_dup_ind = i2
     2 cache_ind = i2
     2 cdf_meaning_dup_ind = i2
     2 chg_access_ind = i2
     2 code_set = i4
     2 definition = vc
     2 del_access_ind = i2
     2 description = vc
     2 display = vc
     2 display_dup_ind = i2
     2 display_key_dup_ind = i2
     2 inq_access_ind = i2
     2 definition_dup_ind = i2
 )
 FREE RECORD cecs_reply
 RECORD cecs_reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD csaccess_reply
 RECORD csaccess_reply(
   1 access_ind = i2
   1 dev_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE next_code_set = f8 WITH protect, noconstant(0.0)
 DECLARE script_found = c1 WITH protect, noconstant("F")
 DECLARE cs_access_ind = i2 WITH protect, noconstant(0)
 DECLARE cs_dev_ind = i2 WITH protect, noconstant(0)
 DECLARE custom_upper_bound = i4 WITH protect, constant(104999)
 DECLARE custom_lower_bound = i4 WITH protect, constant(100000)
 DECLARE code_set_min = i4 WITH protect, noconstant(0)
 DECLARE code_set_max = i4 WITH protect, noconstant(0)
 DECLARE cust_new_code_set = i4 WITH protect, noconstant(0)
 DECLARE cecs_reply_cnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant("")
 DECLARE ecode = i4 WITH protect, noconstant(1)
 SET reply->status_data.status = "S"
 SET ecode = error(errmsg,1)
 IF (validate(request->dev_ind,0)=0
  AND validate(request->access_ind,0)=0)
  EXECUTE core_get_cd_set_access_ind  WITH replace("REPLY","CSACCESS_REPLY")
  IF ((csaccess_reply->status_data.status="S"))
   SET cs_dev_ind = csaccess_reply->dev_ind
   SET cs_access_ind = csaccess_reply->access_ind
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.message = "Could not find dev_ind and access_ind values."
   SET reply->next_code_set = 0
  ENDIF
 ELSE
  SET cs_dev_ind = request->dev_ind
  SET cs_access_ind = request->access_ind
 ENDIF
 IF ((reply->status_data.status != "F"))
  IF (cs_dev_ind=1
   AND cs_access_ind=1)
   IF (checkprg("CODE_SET_GEN")=0)
    SET reply->status_data.status = "Z"
    SET reply->status_data.message = "Script to obtain next code_set value does not exist."
    SET reply->next_code_set = 0
   ELSE
    EXECUTE code_set_gen
    SET ecode = error(errmsg,1)
    IF (ecode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.message = concat("Error retrieving next code_set value ",errmsg)
     SET reply->next_code_set = 0
    ELSEIF (next_code_set <= 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.message = "Next code_set value not found."
     SET reply->next_code_set = 0
    ELSE
     SET reply->next_code_set = next_code_set
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
  ELSE
   IF ((validate(request->code_set_min,- (123))=- (123)))
    SET code_set_min = custom_lower_bound
   ELSE
    SET code_set_min = request->code_set_min
   ENDIF
   IF ((validate(request->code_set_max,- (123))=- (123)))
    SET code_set_max = custom_upper_bound
   ELSE
    SET code_set_max = request->code_set_max
   ENDIF
   IF (((code_set_min < custom_lower_bound) OR (code_set_min > custom_upper_bound)) )
    SET code_set_min = custom_lower_bound
   ENDIF
   IF (((code_set_max < custom_lower_bound) OR (code_set_max > custom_upper_bound)) )
    SET code_set_max = custom_upper_bound
   ENDIF
   IF (code_set_min > code_set_max)
    SET code_set_min = custom_lower_bound
   ENDIF
   IF ((reply->status_data.status="S"))
    SET cust_new_code_set = code_set_min
    SELECT INTO "NL:"
     a.code_set
     FROM code_value_set a
     WHERE a.code_set >= code_set_min
      AND a.code_set <= code_set_max
     ORDER BY a.code_set
     DETAIL
      IF (a.code_set=cust_new_code_set)
       cust_new_code_set = (cust_new_code_set+ 1)
      ENDIF
     WITH nocounter
    ;end select
    SET ecode = error(errmsg,1)
    IF (ecode > 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.message = concat("Error retrieving next custom code_set value ",errmsg)
     SET reply->next_code_set = 0
    ELSEIF (cust_new_code_set > code_set_max)
     SET reply->status_data.status = "F"
     SET reply->status_data.message = "Next custom code_set value not found."
     SET reply->next_code_set = 0
    ELSE
     SET reply->status_data.status = "S"
     SET reply->next_code_set = cust_new_code_set
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((reply->status_data.status="S")
  AND (reply->next_code_set > 0)
  AND validate(request->cd_set_list[1].display,"") != "")
  SET stat = alterlist(cecs_request->cd_set_list,1)
  SET cecs_request->cd_set_list[1].action_type_flag = 1
  SET cecs_request->cd_set_list[1].active_ind_dup_ind = request->cd_set_list[1].active_ind_dup_ind
  SET cecs_request->cd_set_list[1].add_access_ind = request->cd_set_list[1].add_access_ind
  SET cecs_request->cd_set_list[1].alias_dup_ind = request->cd_set_list[1].alias_dup_ind
  SET cecs_request->cd_set_list[1].cache_ind = request->cd_set_list[1].cache_ind
  SET cecs_request->cd_set_list[1].cdf_meaning_dup_ind = request->cd_set_list[1].cdf_meaning_dup_ind
  SET cecs_request->cd_set_list[1].chg_access_ind = request->cd_set_list[1].chg_access_ind
  SET cecs_request->cd_set_list[1].code_set = reply->next_code_set
  SET cecs_request->cd_set_list[1].definition = request->cd_set_list[1].definition
  SET cecs_request->cd_set_list[1].del_access_ind = request->cd_set_list[1].del_access_ind
  SET cecs_request->cd_set_list[1].description = request->cd_set_list[1].description
  SET cecs_request->cd_set_list[1].display = request->cd_set_list[1].display
  SET cecs_request->cd_set_list[1].display_dup_ind = request->cd_set_list[1].display_dup_ind
  SET cecs_request->cd_set_list[1].display_key_dup_ind = request->cd_set_list[1].display_key_dup_ind
  SET cecs_request->cd_set_list[1].inq_access_ind = request->cd_set_list[1].inq_access_ind
  SET cecs_request->cd_set_list[1].definition_dup_ind = request->cd_set_list[1].definition_dup_ind
  EXECUTE core_ens_cd_set  WITH replace("REQUEST","CECS_REQUEST"), replace("REPLY","CECS_REPLY")
  SET reply->status_data.status = cecs_reply->status_data.status
  SET reply->status_data.message = cecs_reply->qual[1].error_msg
 ENDIF
END GO
