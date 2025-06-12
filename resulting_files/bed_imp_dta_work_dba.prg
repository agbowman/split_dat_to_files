CREATE PROGRAM bed_imp_dta_work:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET ar_srvs
 RECORD ar_srvs(
   1 srvs_list[*]
     2 alias = vc
 )
 FREE SET ar_resp
 RECORD ar_resp(
   1 resp_list[*]
     2 sex = vc
     2 age_from = i4
     2 age_from_units = vc
     2 age_to = i4
     2 age_to_units = vc
     2 response = vc
     2 default_ind = i2
     2 use_units_ind = i2
     2 result_process = vc
     2 reference_ind = i2
 )
 FREE SET num_rrf
 RECORD num_rrf(
   1 mrrf[*]
     2 rrf_id = f8
   1 frrf[*]
     2 rrf_id = f8
   1 urrf[*]
     2 rrf_id = f8
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 DECLARE facility = vc
 SET dta_cnt = size(requestin->list_0,5)
 SET last_dta_mnemonic = fillstring(40," ")
 SET alias = fillstring(40," ")
 SET unknown_age_ind = " "
 SET dilute_ind = " "
 SET new_dta_id = 0.0
 SET new_rrf_id = 0.0
 SET dta_count = 0
 SET tot_dta_count = 0
 SET mrrf_cnt = 0
 SET tot_mrrf_cnt = 0
 SET frrf_cnt = 0
 SET tot_frrf_cnt = 0
 SET urrf_cnt = 0
 SET tot_urrf_cnt = 0
 SET ar_seq = 0
 SET alpha_count = 0
 SET tot_alpha_count = 0
 SET ar_count = 0
 SET tot_ar_count = 0
 SET last_age_to = 0
 SET last_age_from = 0
 SET last_sex = fillstring(12," ")
 SET last_age_from_units = fillstring(25," ")
 SET last_age_to_units = fillstring(25," ")
 SET last_service_resource = fillstring(40," ")
 SET critical_ind = 0
 SET normal_ind = 0
 SET review_ind = 0
 SET linear_ind = 0
 SET feasible_ind = 0
 FOR (x = 1 TO dta_cnt)
   IF (validate(requestin->list_0[x].facility) > 0)
    SET facility = trim(requestin->list_0[x].facility)
   ELSE
    SET facility = " "
   ENDIF
   IF ((((last_dta_mnemonic != requestin->list_0[x].dta_mnemonic)) OR ((last_dta_mnemonic=requestin->
   list_0[x].dta_mnemonic)
    AND (last_service_resource != requestin->list_0[x].unique_alias)
    AND (requestin->list_0[x].unique_alias > "   "))) )
    SET last_service_resource = fillstring(40," ")
    SET last_age_to = 0
    SET last_age_from = 0
    SET last_sex = fillstring(12," ")
    SET last_age_from_units = fillstring(25," ")
    SET last_age_to_units = fillstring(25," ")
    SET mrrf_cnt = 0
    SET tot_mrrf_cnt = 0
    SET frrf_cnt = 0
    SET tot_frrf_cnt = 0
    SET urrf_cnt = 0
    SET tot_urrf_cnt = 0
    IF (tot_ar_count > 0)
     CALL add_ar(x)
    ENDIF
    SET alpha_count = 0
    SET tot_alpha_count = 0
    SET ar_count = 0
    SET tot_ar_count = 0
    SET new_dta_id = 0.0
    SELECT INTO "NL:"
     FROM br_dta_work b
     WHERE cnvtupper(b.short_desc)=cnvtupper(requestin->list_0[x].dta_mnemonic)
      AND cnvtupper(b.facility)=cnvtupper(facility)
     DETAIL
      new_dta_id = b.dta_id
     WITH nocounter
    ;end select
    IF (validate(requestin->list_0[x].pdm_numbr))
     SET alias = requestin->list_0[x].pdm_numbr
    ELSE
     SET alias = " "
    ENDIF
    IF (new_dta_id > 0)
     UPDATE  FROM br_dta_work b
      SET b.long_desc = requestin->list_0[x].dta_description, b.activity_type = requestin->list_0[x].
       activity_type_disp, b.result_type = requestin->list_0[x].default_result_type_disp_key,
       b.status_ind = 0, b.match_dta_cd = 0.0, b.alias = alias,
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->updt_applctx
      WHERE b.dta_id=new_dta_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to update ",trim(requestin->list_0[x].dta_mnemonic),
       " on the br_dta_work table.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (new_dta_id > 0)
    IF ((requestin->list_0[x].default_result_type_disp_key != "ALPHA*")
     AND (requestin->list_0[x].default_result_type_disp_key != "INTERP")
     AND (requestin->list_0[x].default_result_type_disp_key != "TEXT"))
     CALL add_rrf(x)
     IF ((((requestin->list_0[x].delta_minutes > "  *")) OR ((((requestin->list_0[x].delta_low >
     "  *")) OR ((((requestin->list_0[x].delta_high > "  *")) OR ((requestin->list_0[x].delta_value
      > "  *"))) )) )) )
      CALL add_delta(x)
     ENDIF
    ENDIF
    IF ((((requestin->list_0[x].default_result_type_disp_key="ALPHA")) OR ((((requestin->list_0[x].
    default_result_type_disp_key="INTERP")) OR ((requestin->list_0[x].default_result_type_disp_key=
    "TEXT"))) )) )
     IF (tot_alpha_count=0)
      SET stat = alterlist(ar_srvs->srvs_list,5)
     ENDIF
     SET tot_alpha_count = (tot_alpha_count+ 1)
     SET alpha_count = (alpha_count+ 1)
     IF (alpha_count > 5)
      SET stat = alterlist(ar_srvs->srvs_list,(tot_alpha_count+ 5))
      SET dta_count = 0
     ENDIF
     SET ar_srvs->srvs_list[tot_alpha_count].alias = requestin->list_0[x].unique_alias
    ENDIF
    IF ((requestin->list_0[x].default_result_type_disp_key="ALPHA RESPONSE"))
     IF (tot_alpha_count > 0)
      IF (tot_ar_count=0)
       SET stat = alterlist(ar_resp->resp_list,5)
      ENDIF
      SET tot_ar_count = (tot_ar_count+ 1)
      SET ar_count = (ar_count+ 1)
      IF (ar_count > 5)
       SET stat = alterlist(ar_resp->resp_list,(tot_ar_count+ 5))
       SET ar_count = 0
      ENDIF
      SET ar_resp->resp_list[tot_ar_count].age_from = cnvtint(requestin->list_0[x].age_from)
      SET ar_resp->resp_list[tot_ar_count].age_from_units = requestin->list_0[x].
      age_from_units_disp_key
      SET ar_resp->resp_list[tot_ar_count].age_to = cnvtint(requestin->list_0[x].age_to)
      SET ar_resp->resp_list[tot_ar_count].age_to_units = requestin->list_0[x].age_to_units_disp_key
      SET ar_resp->resp_list[tot_ar_count].response = requestin->list_0[x].mnemonic
      SET ar_resp->resp_list[tot_ar_count].result_process = requestin->list_0[x].result_process_disp
      SET ar_resp->resp_list[tot_ar_count].sex = requestin->list_0[x].sex_disp_key
      IF ((((requestin->list_0[x].default_ind="Y")) OR ((requestin->list_0[x].default_ind="1"))) )
       SET ar_resp->resp_list[tot_ar_count].default_ind = 1
      ELSE
       SET ar_resp->resp_list[tot_ar_count].default_ind = 0
      ENDIF
      IF ((((requestin->list_0[x].reference_ind="Y")) OR ((requestin->list_0[x].reference_ind="1")))
      )
       SET ar_resp->resp_list[tot_ar_count].reference_ind = 1
      ELSE
       SET ar_resp->resp_list[tot_ar_count].reference_ind = 0
      ENDIF
      IF ((((requestin->list_0[x].use_units_ind="1")) OR ((requestin->list_0[x].use_units_ind="Y")))
      )
       SET ar_resp->resp_list[tot_ar_count].use_units_ind = 1
      ELSE
       SET ar_resp->resp_list[tot_ar_count].use_units_ind = 0
      ENDIF
     ELSE
      IF ((((requestin->list_0[x].sex_disp_key="M*")) OR ((requestin->list_0[x].sex_disp_key="m*")))
      )
       SET ar_seq = 0
       FOR (mrrf_cnt = 1 TO tot_mrrf_cnt)
         SET ar_seq = (ar_seq+ 1)
         INSERT  FROM br_dta_alpha_responses b
          SET b.rrf_id = num_rrf->mrrf[mrrf_cnt].rrf_id, b.ar = requestin->list_0[x].mnemonic, b
           .sequence = ar_seq,
           b.default_ind =
           IF ((((requestin->list_0[x].default_ind="Y")) OR ((requestin->list_0[x].default_ind="1")
           )) ) 1
           ELSE 0
           ENDIF
           , b.use_units_ind =
           IF ((((requestin->list_0[x].use_units_ind="Y")) OR ((requestin->list_0[x].use_units_ind=
           "1"))) ) 1
           ELSE 0
           ENDIF
           , b.reference_ind =
           IF ((((requestin->list_0[x].reference_ind="Y")) OR ((requestin->list_0[x].reference_ind=
           "1"))) ) 1
           ELSE 0
           ENDIF
           ,
           b.result_processing_type = requestin->list_0[x].result_process_disp, b.updt_dt_tm =
           cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
           b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].dta_mnemonic),
           " into br_dta_alpha_responses for alpha response = ",requestin->list_0[x].mnemonic,".")
          GO TO exit_script
         ENDIF
       ENDFOR
      ELSEIF ((((requestin->list_0[x].sex_disp_key="F*")) OR ((requestin->list_0[x].sex_disp_key="f*"
      ))) )
       SET ar_seq = 0
       FOR (frrf_cnt = 1 TO tot_frrf_cnt)
         SET ar_seq = (ar_seq+ 1)
         INSERT  FROM br_dta_alpha_responses b
          SET b.rrf_id = num_rrf->frrf[frrf_cnt].rrf_id, b.ar = requestin->list_0[x].mnemonic, b
           .sequence = ar_seq,
           b.default_ind =
           IF ((((requestin->list_0[x].default_ind="Y")) OR ((requestin->list_0[x].default_ind="1")
           )) ) 1
           ELSE 0
           ENDIF
           , b.use_units_ind =
           IF ((((requestin->list_0[x].use_units_ind="Y")) OR ((requestin->list_0[x].use_units_ind=
           "1"))) ) 1
           ELSE 0
           ENDIF
           , b.reference_ind =
           IF ((((requestin->list_0[x].reference_ind="Y")) OR ((requestin->list_0[x].reference_ind=
           "1"))) ) 1
           ELSE 0
           ENDIF
           ,
           b.result_processing_type = requestin->list_0[x].result_process_disp, b.updt_dt_tm =
           cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
           b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].dta_mnemonic),
           " into br_dta_alpha_responses for alpha response = ",requestin->list_0[x].mnemonic,".")
          GO TO exit_script
         ENDIF
       ENDFOR
      ELSE
       SET ar_seq = 0
       FOR (urrf_cnt = 1 TO tot_urrf_cnt)
         SET ar_seq = (ar_seq+ 1)
         INSERT  FROM br_dta_alpha_responses b
          SET b.rrf_id = num_rrf->urrf[urrf_cnt].rrf_id, b.ar = requestin->list_0[x].mnemonic, b
           .sequence = ar_seq,
           b.default_ind =
           IF ((((requestin->list_0[x].default_ind="Y")) OR ((requestin->list_0[x].default_ind="1")
           )) ) 1
           ELSE 0
           ENDIF
           , b.use_units_ind =
           IF ((((requestin->list_0[x].use_units_ind="Y")) OR ((requestin->list_0[x].use_units_ind=
           "1"))) ) 1
           ELSE 0
           ENDIF
           , b.reference_ind =
           IF ((((requestin->list_0[x].reference_ind="Y")) OR ((requestin->list_0[x].reference_ind=
           "1"))) ) 1
           ELSE 0
           ENDIF
           ,
           b.result_processing_type = requestin->list_0[x].result_process_disp, b.updt_dt_tm =
           cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
           b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
          WITH nocounter
         ;end insert
         IF (curqual=0)
          SET error_flag = "Y"
          SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].dta_mnemonic),
           " into br_dta_alpha_responses for alpha response = ",requestin->list_0[x].mnemonic,".")
          GO TO exit_script
         ENDIF
       ENDFOR
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET last_dta_mnemonic = requestin->list_0[x].dta_mnemonic
   SET last_service_resource = requestin->list_0[x].unique_alias
 ENDFOR
 IF (tot_dta_count > 0
  AND tot_alpha_count > 0
  AND tot_ar_count > 0)
  CALL add_ar(x)
 ENDIF
 GO TO exit_script
 SUBROUTINE add_rrf(x)
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_rrf_id = cnvtreal(j)
    WITH format, counter
   ;end select
   IF ((((requestin->list_0[x].sex_disp_key="M*")) OR ((requestin->list_0[x].sex_disp_key="m*"))) )
    IF (tot_mrrf_cnt=0)
     SET stat = alterlist(num_rrf->mrrf,5)
    ENDIF
    SET tot_mrrf_cnt = (tot_mrrf_cnt+ 1)
    SET mrrf_cnt = (mrrf_cnt+ 1)
    IF (mrrf_cnt > 5)
     SET stat = alterlist(num_rrf->mrrf,(tot_mrrf_cnt+ 5))
     SET mrrf_cnt = 0
    ENDIF
    SET num_rrf->mrrf[tot_mrrf_cnt].rrf_id = new_rrf_id
   ELSEIF ((((requestin->list_0[x].sex_disp_key="F*")) OR ((requestin->list_0[x].sex_disp_key="f*")
   )) )
    IF (tot_frrf_cnt=0)
     SET stat = alterlist(num_rrf->frrf,5)
    ENDIF
    SET tot_frrf_cnt = (tot_frrf_cnt+ 1)
    SET frrf_cnt = (frrf_cnt+ 1)
    IF (frrf_cnt > 5)
     SET stat = alterlist(num_rrf->frrf,(tot_frrf_cnt+ 5))
     SET frrf_cnt = 0
    ENDIF
    SET num_rrf->frrf[tot_frrf_cnt].rrf_id = new_rrf_id
   ELSE
    IF (tot_urrf_cnt=0)
     SET stat = alterlist(num_rrf->urrf,5)
    ENDIF
    SET tot_urrf_cnt = (tot_urrf_cnt+ 1)
    SET urrf_cnt = (urrf_cnt+ 1)
    IF (urrf_cnt > 5)
     SET stat = alterlist(num_rrf->urrf,(tot_urrf_cnt+ 5))
     SET urrf_cnt = 0
    ENDIF
    SET num_rrf->urrf[tot_urrf_cnt].rrf_id = new_rrf_id
   ENDIF
   IF (validate(requestin->list_0[x].unknown_age_ind))
    SET unknown_age_ind = requestin->list_0[x].unknown_age_ind
   ELSE
    SET unknown_age_ind = 0
   ENDIF
   IF (validate(requestin->list_0[x].dilute_ind))
    SET dilute_ind = requestin->list_0[x].dilute_ind
   ELSE
    SET dilute_ind = 0
   ENDIF
   SELECT INTO "NL:"
    FROM br_legacy_sr b
    WHERE (b.service_resource=requestin->list_0[x].unique_alias)
    WITH nocounter, maxqual(b,1)
   ;end select
   IF (curqual=0)
    SET new_id = 0.0
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_legacy_sr b
     SET b.sr_id = new_id, b.service_resource = requestin->list_0[x].unique_alias, b.active_ind = 1,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
   IF ((requestin->list_0[x].normal_low > " ")
    AND (requestin->list_0[x].normal_high > " "))
    SET normal_ind = 3
   ELSEIF ((requestin->list_0[x].normal_high > " "))
    SET normal_ind = 2
   ELSEIF ((requestin->list_0[x].normal_low > " "))
    SET normal_ind = 1
   ELSE
    SET normal_ind = 0
   ENDIF
   IF ((requestin->list_0[x].critical_low > " ")
    AND (requestin->list_0[x].critical_high > " "))
    SET critical_ind = 3
   ELSEIF ((requestin->list_0[x].critical_high > " "))
    SET critical_ind = 2
   ELSEIF ((requestin->list_0[x].critical_low > " "))
    SET critical_ind = 1
   ELSE
    SET critical_ind = 0
   ENDIF
   IF ((requestin->list_0[x].linear_low > " ")
    AND (requestin->list_0[x].linear_high > " "))
    SET linear_ind = 3
   ELSEIF ((requestin->list_0[x].linear_high > " "))
    SET linear_ind = 2
   ELSEIF ((requestin->list_0[x].linear_low > " "))
    SET linear_ind = 1
   ELSE
    SET linear_ind = 0
   ENDIF
   IF ((requestin->list_0[x].review_low > " ")
    AND (requestin->list_0[x].review_high > " "))
    SET review_ind = 3
   ELSEIF ((requestin->list_0[x].review_high > " "))
    SET review_ind = 2
   ELSEIF ((requestin->list_0[x].review_low > " "))
    SET review_ind = 1
   ELSE
    SET review_ind = 0
   ENDIF
   IF ((requestin->list_0[x].feasible_low > " ")
    AND (requestin->list_0[x].feasible_high > " "))
    SET feasible_ind = 3
   ELSEIF ((requestin->list_0[x].feasible_high > " "))
    SET feasible_ind = 2
   ELSEIF ((requestin->list_0[x].feasible_low > " "))
    SET feasible_ind = 1
   ELSE
    SET feasible_ind = 0
   ENDIF
   INSERT  FROM br_dta_rrf b
    SET b.rrf_id = new_rrf_id, b.dta_id = new_dta_id, b.sex = cnvtupper(requestin->list_0[x].
      sex_disp_key),
     b.unknown_age_ind =
     IF (((unknown_age_ind="Y") OR (unknown_age_ind="1")) ) 1
     ELSE 0
     ENDIF
     , b.age_from = cnvtint(requestin->list_0[x].age_from), b.age_from_units = requestin->list_0[x].
     age_from_units_disp_key,
     b.age_to = cnvtint(requestin->list_0[x].age_to), b.age_to_units = requestin->list_0[x].
     age_to_units_disp_key, b.service_resource = requestin->list_0[x].unique_alias,
     b.normal_low =
     IF ((requestin->list_0[x].normal_low > "   *")) cnvtreal(requestin->list_0[x].normal_low)
     ELSE 0.0
     ENDIF
     , b.normal_high =
     IF ((requestin->list_0[x].normal_high > "   *")) cnvtreal(requestin->list_0[x].normal_high)
     ELSE 0.0
     ENDIF
     , b.normal_ind = normal_ind,
     b.uom = requestin->list_0[x].units_disp, b.critical_low =
     IF ((requestin->list_0[x].critical_low > "   *")) cnvtreal(requestin->list_0[x].critical_low)
     ELSE 0.0
     ENDIF
     , b.critical_high =
     IF ((requestin->list_0[x].critical_high > "   *")) cnvtreal(requestin->list_0[x].critical_high)
     ELSE 0.0
     ENDIF
     ,
     b.critical_ind = critical_ind, b.review_low =
     IF ((requestin->list_0[x].review_low > "   *")) cnvtreal(requestin->list_0[x].review_low)
     ELSE 0.0
     ENDIF
     , b.review_high =
     IF ((requestin->list_0[x].review_high > "   *")) cnvtreal(requestin->list_0[x].review_high)
     ELSE 0.0
     ENDIF
     ,
     b.review_ind = review_ind, b.linear_low =
     IF ((requestin->list_0[x].linear_low > "   *")) cnvtreal(requestin->list_0[x].linear_low)
     ELSE 0.0
     ENDIF
     , b.linear_high =
     IF ((requestin->list_0[x].linear_high > "   *")) cnvtreal(requestin->list_0[x].linear_high)
     ELSE 0.0
     ENDIF
     ,
     b.linear_ind = linear_ind, b.dilute_ind =
     IF (((dilute_ind="Y") OR (dilute_ind="1")) ) 1
     ELSE 0
     ENDIF
     , b.feasible_low =
     IF ((requestin->list_0[x].feasible_low > "   *")) cnvtreal(requestin->list_0[x].feasible_low)
     ELSE 0.0
     ENDIF
     ,
     b.feasible_high =
     IF ((requestin->list_0[x].feasible_high > "   *")) cnvtreal(requestin->list_0[x].feasible_high)
     ELSE 0.0
     ENDIF
     , b.feasible_ind = feasible_ind, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
     b.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].dta_mnemonic),
     " into br_dta_rrf.")
    GO TO exit_script
   ENDIF
   IF ((((((last_service_resource != requestin->list_0[x].unique_alias)) OR ((last_dta_mnemonic !=
   requestin->list_0[x].dta_mnemonic))) ) OR (last_service_resource="  *"
    AND last_dta_mnemonic="   *")) )
    SELECT INTO "NL:"
     FROM br_dta_data_map b
     WHERE b.dta_id=new_dta_id
      AND (b.service_resource=requestin->list_0[x].unique_alias)
     WITH nocounter
    ;end select
    IF (curqual=0
     AND (((requestin->list_0[x].min_digits > "   *")) OR ((((requestin->list_0[x].max_digits >
    "   *")) OR ((requestin->list_0[x].min_decimal_places > "   *"))) )) )
     INSERT  FROM br_dta_data_map b
      SET b.service_resource = requestin->list_0[x].unique_alias, b.dta_id = new_dta_id, b.min_digits
        =
       IF ((requestin->list_0[x].min_digits > "   *")) cnvtint(requestin->list_0[x].min_digits)
       ELSE 0
       ENDIF
       ,
       b.max_digits =
       IF ((requestin->list_0[x].max_digits > "   *")) cnvtint(requestin->list_0[x].max_digits)
       ELSE 0
       ENDIF
       , b.min_decimal_places =
       IF ((requestin->list_0[x].min_decimal_places > "   *")) cnvtint(requestin->list_0[x].
         min_decimal_places)
       ELSE 0
       ENDIF
       , b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
       b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].dta_mnemonic),
       " into br_dta_data_map.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_ar(x)
   FOR (ar_count = 1 TO tot_ar_count)
     IF ((((last_age_from != ar_resp->resp_list[ar_count].age_from)) OR ((((last_age_from_units !=
     ar_resp->resp_list[ar_count].age_from_units)) OR ((((last_age_to != ar_resp->resp_list[ar_count]
     .age_to)) OR ((((last_age_to_units != ar_resp->resp_list[ar_count].age_to_units)) OR ((last_sex
      != ar_resp->resp_list[ar_count].sex))) )) )) )) )
      SET ar_seq = 0
      SET last_age_from = ar_resp->resp_list[ar_count].age_from
      SET last_age_from_units = ar_resp->resp_list[ar_count].age_from_units
      SET last_age_to = ar_resp->resp_list[ar_count].age_to
      SET last_age_to_units = ar_resp->resp_list[ar_count].age_to_units
      SET last_sex = ar_resp->resp_list[ar_count].sex
      SELECT INTO "NL:"
       j = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_rrf_id = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM br_dta_rrf b
       SET b.rrf_id = new_rrf_id, b.dta_id = new_dta_id, b.sex = ar_resp->resp_list[ar_count].sex,
        b.age_from = ar_resp->resp_list[ar_count].age_from, b.age_from_units = ar_resp->resp_list[
        ar_count].age_from_units, b.age_to = ar_resp->resp_list[ar_count].age_to,
        b.age_to_units = ar_resp->resp_list[ar_count].age_to_units, b.service_resource = ar_srvs->
        srvs_list[alpha_count].alias, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = 0,
        b.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].dta_mnemonic),
        " into br_dta_rrf for service resource = ",ar_srvs->srvs_list[alpha_count].alias,".")
       GO TO exit_script
      ENDIF
     ENDIF
     SET ar_seq = (ar_seq+ 1)
     INSERT  FROM br_dta_alpha_responses b
      SET b.rrf_id = new_rrf_id, b.ar = ar_resp->resp_list[ar_count].response, b.sequence = ar_seq,
       b.default_ind = ar_resp->resp_list[ar_count].default_ind, b.use_units_ind = ar_resp->
       resp_list[ar_count].use_units_ind, b.reference_ind = ar_resp->resp_list[ar_count].
       reference_ind,
       b.result_processing_type = ar_resp->resp_list[ar_count].result_process, b.updt_dt_tm =
       cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].dta_mnemonic),
       " into br_dta_alpha_responses for alpha response = ",ar_resp->resp_list[ar_count].response,"."
       )
      GO TO exit_script
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE add_delta(x)
  INSERT  FROM br_dta_delta b
   SET b.rrf_id = new_rrf_id, b.check_type = requestin->list_0[x].delta_check_type_disp, b.minutes =
    IF ((requestin->list_0[x].delta_minutes > "  *")) cnvtint(requestin->list_0[x].delta_minutes)
    ELSE 0
    ENDIF
    ,
    b.value = requestin->list_0[x].delta_value, b.low =
    IF ((requestin->list_0[x].delta_low > "  *")) cnvtint(requestin->list_0[x].delta_low)
    ELSE 0
    ENDIF
    , b.high =
    IF ((requestin->list_0[x].delta_high > "  *")) cnvtint(requestin->list_0[x].delta_high)
    ELSE 0
    ENDIF
    ,
    b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
    reqinfo->updt_task,
    b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET error_flag = "Y"
   SET error_msg = concat("Unable to insert ",trim(requestin->list_0[x].dta_mnemonic),
    " into br_dta_delta.")
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*            LEGACY DTA FILE IMPORTED SUCCESSFULLY           *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ELSE
  CALL echo(error_msg)
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_DTA_WORK","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
  CALL echo("*                                                            *")
  CALL echo("*            LEGACY DTA FILE IMPORT HAS FAILED               *")
  CALL echo("*  Do not run additional imports, contact the BEDROCK team   *")
  CALL echo("*                                                            *")
  CALL echo("**************************************************************")
  CALL echo("**************************************************************")
 ENDIF
END GO
