CREATE PROGRAM bed_get_alias_by_contr_system:dba
 RECORD request(
   1 contributor_system_code_value = f8
   1 contributor_source_code_value = f8
   1 alias_config_params_ind = i2
   1 code_set = i4
   1 event_codes[*]
     2 code_value = f8
   1 catalog_type_code_value = f8
   1 activity_type_code_value = f8
   1 subactivity_type_code_value = f8
 )
 FREE SET reply
 RECORD reply(
   1 code_values[*]
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
 DECLARE cv_parse = vc
 SET cv_parse = "cv.code_set = request->code_set"
 IF ((request->code_set=72))
  SET ecnt = size(request->event_codes,5)
  IF (ecnt > 0)
   DECLARE event_code_list = vc
   SET event_code_list = " and cv.code_value in ("
   FOR (e = 1 TO ecnt)
     IF (e=ecnt)
      SET event_code_list = build(event_code_list,request->event_codes[e].code_value,")")
     ELSE
      SET event_code_list = build(event_code_list,request->event_codes[e].code_value,",")
     ENDIF
   ENDFOR
   SET cv_parse = concat(cv_parse,event_code_list)
  ENDIF
 ENDIF
 DECLARE oc_parse = vc
 SET oc_parse = "oc.catalog_cd = cv.code_value"
 IF (validate(request->catalog_type_code_value))
  IF ((request->catalog_type_code_value > 0))
   SET oc_parse = concat(oc_parse," and oc.catalog_type_cd = request->catalog_type_code_value")
  ENDIF
 ENDIF
 IF (validate(request->activity_type_code_value))
  IF ((request->activity_type_code_value > 0))
   SET oc_parse = concat(oc_parse," and oc.activity_type_cd = request->activity_type_code_value")
  ENDIF
 ENDIF
 IF (validate(request->subactivity_type_code_value))
  IF ((request->subactivity_type_code_value > 0))
   SET oc_parse = concat(oc_parse,
    " and oc.activity_subtype_cd = request->subactivity_type_code_value")
  ENDIF
 ENDIF
 SET ccnt = 0
 IF ((request->alias_config_params_ind=1))
  SELECT
   IF ((request->code_set=200))
    FROM code_value cv,
     order_catalog oc,
     br_name_value bnv,
     code_value_outbound cvo,
     code_value_alias cva
    PLAN (cv
     WHERE parser(cv_parse))
     JOIN (oc
     WHERE parser(oc_parse))
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
   ELSE
   ENDIF
   INTO "NL:"
   FROM code_value cv,
    br_name_value bnv,
    code_value_outbound cvo,
    code_value_alias cva
   PLAN (cv
    WHERE parser(cv_parse))
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
    ccnt = (ccnt+ 1), stat = alterlist(reply->code_values,ccnt), reply->code_values[ccnt].code_value
     = cv.code_value,
    reply->code_values[ccnt].display = cv.display, reply->code_values[ccnt].mean = cv.cdf_meaning,
    reply->code_values[ccnt].description = cv.description,
    reply->code_values[ccnt].active_ind = cv.active_ind
    IF (bnv.br_name_value_id > 0)
     reply->code_values[ccnt].ignore_ind = 1
    ENDIF
    IF (cvo.code_value > 0)
     IF (cvo.alias > " ")
      reply->code_values[ccnt].outbound_alias = cvo.alias
     ELSE
      reply->code_values[ccnt].outbound_alias = "<space>"
     ENDIF
    ENDIF
    reply->code_values[ccnt].beg_effective_dt_tm = cv.begin_effective_dt_tm, reply->code_values[ccnt]
    .end_effective_dt_tm = cv.end_effective_dt_tm, icnt = 0
   DETAIL
    IF (cva.alias > " ")
     icnt = (icnt+ 1), stat = alterlist(reply->code_values[ccnt].inbound_aliases,icnt), reply->
     code_values[ccnt].inbound_aliases[icnt].alias = cva.alias
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT
   IF ((request->code_set=200))
    FROM code_value cv,
     order_catalog oc,
     code_value_outbound cvo,
     code_value_alias cva
    PLAN (cv
     WHERE parser(cv_parse))
     JOIN (oc
     WHERE parser(oc_parse))
     JOIN (cvo
     WHERE cvo.code_value=outerjoin(cv.code_value)
      AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
     JOIN (cva
     WHERE cva.code_value=outerjoin(cv.code_value)
      AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    ORDER BY cv.code_value
   ELSE
   ENDIF
   INTO "NL:"
   FROM code_value cv,
    code_value_outbound cvo,
    code_value_alias cva
   PLAN (cv
    WHERE parser(cv_parse))
    JOIN (cvo
    WHERE cvo.code_value=outerjoin(cv.code_value)
     AND cvo.contributor_source_cd=outerjoin(request->contributor_source_code_value))
    JOIN (cva
    WHERE cva.code_value=outerjoin(cv.code_value)
     AND cva.contributor_source_cd=outerjoin(request->contributor_source_code_value))
   ORDER BY cv.code_value
   HEAD cv.code_value
    ccnt = (ccnt+ 1), stat = alterlist(reply->code_values,ccnt), reply->code_values[ccnt].code_value
     = cv.code_value,
    reply->code_values[ccnt].display = cv.display, reply->code_values[ccnt].description = cv
    .description, reply->code_values[ccnt].active_ind = cv.active_ind
    IF (cvo.code_value > 0)
     IF (cvo.alias > " ")
      reply->code_values[ccnt].outbound_alias = cvo.alias
     ELSE
      reply->code_values[ccnt].outbound_alias = "<space>"
     ENDIF
    ENDIF
    reply->code_values[ccnt].beg_effective_dt_tm = cv.begin_effective_dt_tm, reply->code_values[ccnt]
    .end_effective_dt_tm = cv.end_effective_dt_tm, icnt = 0
   DETAIL
    IF (cva.alias > " ")
     icnt = (icnt+ 1), stat = alterlist(reply->code_values[ccnt].inbound_aliases,icnt), reply->
     code_values[ccnt].inbound_aliases[icnt].alias = cva.alias
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
