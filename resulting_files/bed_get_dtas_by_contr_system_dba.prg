CREATE PROGRAM bed_get_dtas_by_contr_system:dba
 FREE SET reply
 RECORD reply(
   1 dtas[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 description = vc
     2 active_ind = i2
     2 inbound_aliases[*]
       3 alias = vc
     2 outbound_alias = vc
     2 ignore_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE dta_parse = vc
 SET dta_parse = "dta.task_assay_cd = cv.code_value"
 IF ((request->activity_type_code_value > 0))
  SET dta_parse = concat(dta_parse," and dta.activity_type_cd = request->activity_type_code_value")
 ENDIF
 SET ccnt = 0
 IF ((request->alias_config_params_ind=1))
  SELECT INTO "NL:"
   FROM code_value cv,
    discrete_task_assay dta,
    br_name_value bnv,
    code_value_outbound cvo,
    code_value_alias cva
   PLAN (cv
    WHERE cv.code_set=14003)
    JOIN (dta
    WHERE parser(dta_parse))
    JOIN (bnv
    WHERE bnv.br_nv_key1=outerjoin("ALIAS_IGNORE_CV")
     AND bnv.br_name=outerjoin(cnvtstring(request->contributor_system_code_value))
     AND bnv.br_value=outerjoin(cnvtstring(cv.code_value)))
    JOIN (cvo
    WHERE cvo.code_value=outerjoin(cv.code_value)
     AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    JOIN (cva
    WHERE cva.code_value=outerjoin(cv.code_value)
     AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
   ORDER BY cv.code_value
   HEAD cv.code_value
    ccnt = (ccnt+ 1), stat = alterlist(reply->dtas,ccnt), reply->dtas[ccnt].code_value = cv
    .code_value,
    reply->dtas[ccnt].display = cv.display, reply->dtas[ccnt].mean = cv.cdf_meaning, reply->dtas[ccnt
    ].description = cv.description,
    reply->dtas[ccnt].active_ind = cv.active_ind
    IF (bnv.br_name_value_id > 0)
     reply->dtas[ccnt].ignore_ind = 1
    ENDIF
    IF (cvo.code_value > 0)
     IF (cvo.alias > " ")
      reply->dtas[ccnt].outbound_alias = cvo.alias
     ELSE
      reply->dtas[ccnt].outbound_alias = "<space>"
     ENDIF
    ENDIF
    reply->dtas[ccnt].beg_effective_dt_tm = cv.begin_effective_dt_tm, reply->dtas[ccnt].
    end_effective_dt_tm = cv.end_effective_dt_tm, icnt = 0
   DETAIL
    IF (cva.alias > " ")
     icnt = (icnt+ 1), stat = alterlist(reply->dtas[ccnt].inbound_aliases,icnt), reply->dtas[ccnt].
     inbound_aliases[icnt].alias = cva.alias
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM code_value cv,
    discrete_task_assay dta,
    code_value_outbound cvo,
    code_value_alias cva
   PLAN (cv
    WHERE cv.code_set=14003)
    JOIN (dta
    WHERE parser(dta_parse))
    JOIN (cvo
    WHERE cvo.code_value=outerjoin(cv.code_value)
     AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    JOIN (cva
    WHERE cva.code_value=outerjoin(cv.code_value)
     AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
   ORDER BY cv.code_value
   HEAD cv.code_value
    ccnt = (ccnt+ 1), stat = alterlist(reply->dtas,ccnt), reply->dtas[ccnt].code_value = cv
    .code_value,
    reply->dtas[ccnt].display = cv.display, reply->dtas[ccnt].mean = cv.cdf_meaning, reply->dtas[ccnt
    ].description = cv.description,
    reply->dtas[ccnt].active_ind = cv.active_ind
    IF (cvo.code_value > 0)
     IF (cvo.alias > " ")
      reply->dtas[ccnt].outbound_alias = cvo.alias
     ELSE
      reply->dtas[ccnt].outbound_alias = "<space>"
     ENDIF
    ENDIF
    reply->dtas[ccnt].beg_effective_dt_tm = cv.begin_effective_dt_tm, reply->dtas[ccnt].
    end_effective_dt_tm = cv.end_effective_dt_tm, icnt = 0
   DETAIL
    IF (cva.alias > " ")
     icnt = (icnt+ 1), stat = alterlist(reply->dtas[ccnt].inbound_aliases,icnt), reply->dtas[ccnt].
     inbound_aliases[icnt].alias = cva.alias
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
