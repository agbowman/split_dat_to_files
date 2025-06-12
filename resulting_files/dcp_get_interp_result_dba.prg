CREATE PROGRAM dcp_get_interp_result:dba
 RECORD reply(
   1 result_nomenclature_id = f8
   1 result_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (getdecmap(input_assay_cd=f8) =i4)
   DECLARE decimal_digit = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    FROM data_map dm
    WHERE dm.task_assay_cd=input_assay_cd
     AND dm.min_decimal_places != 0
     AND (dm.min_decimal_places=
    (SELECT
     max(dm1.min_decimal_places)
     FROM data_map dm1
     WHERE dm1.task_assay_cd=dm.task_assay_cd))
    DETAIL
     decimal_digit = dm.min_decimal_places
    WITH nocounter
   ;end select
   RETURN(decimal_digit)
 END ;Subroutine
 SET state = 0
 SET res_nomen = 0
 SET idx = 1
 SET cnt = size(request->qual,5)
 SET continue = 1
 SET cnt2 = 0
 SET numeric_interp = 1
 SET alpha_interp = 0
 WHILE (continue > 0)
   SET continue = 0
   CALL echo(build("Task Assay Cd - ",request->qual[idx].input_assay_cd))
   CALL echo(build("Nomenclature Id - ",request->qual[idx].input_nomenclature_id))
   CALL echo(build("input_value -",request->qual[idx].input_value))
   IF ((request->qual[idx].flags=alpha_interp))
    SELECT INTO "nl:"
     FROM dcp_interp_state dis
     WHERE (dis.dcp_interp_id=request->dcp_interp_id)
      AND dis.state=state
      AND (dis.input_assay_cd=request->qual[idx].input_assay_cd)
      AND (dis.nomenclature_id=request->qual[idx].input_nomenclature_id)
     DETAIL
      IF (dis.result_nomenclature_id > 0)
       res_nomen = dis.result_nomenclature_id
      ELSE
       state = dis.resulting_state,
       CALL echo(build("next state -",state)), continue = 1
      ENDIF
     WITH nocounter
    ;end select
   ELSEIF ((request->qual[idx].flags=numeric_interp))
    SET dec_digit = getdecmap(request->qual[idx].input_assay_cd)
    SET input_value = round(request->qual[idx].input_value,dec_digit)
    SELECT INTO "nl:"
     FROM dcp_interp_state dis
     WHERE (dis.dcp_interp_id=request->dcp_interp_id)
      AND dis.state=state
      AND (dis.input_assay_cd=request->qual[idx].input_assay_cd)
      AND dis.flags=numeric_interp
     DETAIL
      IF (round(dis.numeric_low,dec_digit) <= input_value
       AND round(dis.numeric_high,dec_digit) >= input_value)
       IF (dis.result_nomenclature_id > 0)
        res_nomen = dis.result_nomenclature_id
       ELSE
        state = dis.resulting_state,
        CALL echo(build("next state -",state)), continue = 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   SET idx += 1
 ENDWHILE
 CALL echo(build("res_nomen:",res_nomen))
 SET reply->result_nomenclature_id = res_nomen
 IF (res_nomen > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
