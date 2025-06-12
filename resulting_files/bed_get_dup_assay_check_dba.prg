CREATE PROGRAM bed_get_dup_assay_check:dba
 RECORD reply(
   1 code_list[*]
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 active_ind = i2
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
     2 result_type
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
     2 result_process
       3 code_value = f8
       3 display = vc
       3 cdf_meaning = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc
 SET error_flag = " "
 SET reply->status_data.status = "F"
 SET code = 0
 SET i = 0
 SET jj = 0
 SET y = 0
 SET total_start = 0
 SET auto_client_id = 0.0
 SELECT INTO "NL:"
  FROM br_client b
  DETAIL
   auto_client_id = b.autobuild_client_id
  WITH nocounter
 ;end select
 SET sze = size(request->search_list,5)
 DECLARE dta_parse = vc
 DECLARE auto_dta_parse = vc
 IF (sze=0)
  SET error_flag = "F"
  SET error_msg = "Request for DTA search is empty."
  GO TO exit_program
 ENDIF
 DECLARE sstring = vc
 FOR (y = 1 TO sze)
  SET sstring = replace(request->search_list[y].display,"*","\*",0)
  IF (y=1)
   IF ((request->search_list[y].display > "  *"))
    SET dta_parse = concat('((dta.mnemonic_key_cap = "',trim(cnvtupper(sstring)),'"')
    SET auto_dta_parse = concat('((trim(cnvtupper(dta.mnemonic)) = "',trim(cnvtupper(sstring)),'"')
   ENDIF
   SET dta_parse = concat(dta_parse,")")
   SET auto_dta_parse = concat(auto_dta_parse,")")
  ELSE
   SET dta_parse = concat(dta_parse," or (")
   SET auto_dta_parse = concat(auto_dta_parse," or (")
   IF ((request->search_list[y].display > "  *"))
    SET dta_parse = concat(dta_parse,'dta.mnemonic_key_cap = "',trim(cnvtupper(sstring)),'"')
    SET auto_dta_parse = concat(auto_dta_parse,'trim(cnvtupper(dta.mnemonic)) = "',trim(cnvtupper(
       sstring)),'"')
   ENDIF
   IF (y > 1)
    SET dta_parse = concat(dta_parse,")")
    SET auto_dta_parse = concat(auto_dta_parse,")")
   ELSE
    SET dta_parse = concat(dta_parse,"))")
    SET auto_dta_parse = concat(auto_dta_parse,"))")
   ENDIF
  ENDIF
 ENDFOR
 SET auto_dta_parse = concat(auto_dta_parse,") and dta.br_client_id = auto_client_id")
 SET dta_parse = concat(dta_parse,")  and (dta.active_ind = 1 or request->load->inactive_ind = 1)")
 CALL echo(dta_parse)
 SELECT INTO "nl:"
  FROM discrete_task_assay dta,
   code_value cv,
   code_value cv2
  PLAN (dta
   WHERE parser(dta_parse))
   JOIN (cv
   WHERE cv.code_value=outerjoin(dta.activity_type_cd)
    AND cv.active_ind=outerjoin(1))
   JOIN (cv2
   WHERE cv2.code_value=outerjoin(dta.default_result_type_cd)
    AND cv2.active_ind=outerjoin(1))
  ORDER BY dta.task_assay_cd
  DETAIL
   jj = (jj+ 1), stat = alterlist(reply->code_list,jj), code = dta.task_assay_cd,
   reply->code_list[jj].code_value = dta.task_assay_cd, reply->code_list[jj].display = trim(dta
    .mnemonic,3), reply->code_list[jj].active_ind = dta.active_ind,
   reply->code_list[jj].description = trim(dta.description,3), reply->code_list[jj].activity_type.
   code_value = dta.activity_type_cd, reply->code_list[jj].activity_type.display = cv.display,
   reply->code_list[jj].activity_type.cdf_meaning = cv.cdf_meaning, reply->code_list[jj].result_type.
   code_value = dta.default_result_type_cd, reply->code_list[jj].result_type.display = cv2.display,
   reply->code_list[jj].result_type.cdf_meaning = cv2.cdf_meaning, reply->code_list[jj].
   result_process.code_value = dta.bb_result_processing_cd
  WITH nocounter
 ;end select
 IF (jj > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = jj),
    code_value c
   PLAN (d
    WHERE (reply->code_list[d.seq].result_process.code_value > 0))
    JOIN (c
    WHERE (c.code_value=reply->code_list[d.seq].result_process.code_value))
   DETAIL
    reply->code_list[d.seq].result_process.display = c.display, reply->code_list[d.seq].
    result_process.cdf_meaning = c.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF (jj=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_program
 IF (error_flag="F")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(" >> PROGRAM NAME:  bed_get_dup_assay_check  >> ERROR MESSAGE: ",
   error_msg)
 ENDIF
 CALL echorecord(reply)
END GO
