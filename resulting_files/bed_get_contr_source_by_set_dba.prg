CREATE PROGRAM bed_get_contr_source_by_set:dba
 FREE SET reply
 RECORD reply(
   1 contributor_sources[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 inbound_alias_exists_ind = i2
     2 outbound_alias_exists_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 RECORD hold_sources(
   1 sources[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
     2 inbound_ind = i2
     2 outbound_ind = i2
 )
 IF ((request->code_set=200))
  DECLARE oc_parse = vc
  SET oc_parse = "oc.catalog_cd = cva.code_value"
  IF ((request->catalog_type_code_value > 0))
   SET oc_parse = concat(oc_parse," and oc.catalog_type_cd+0 = request->catalog_type_code_value")
  ENDIF
  IF ((request->activity_type_code_value > 0))
   SET oc_parse = concat(oc_parse," and oc.activity_type_cd+0 = request->activity_type_code_value")
  ENDIF
  IF ((request->subactivity_type_code_value > 0))
   SET oc_parse = concat(oc_parse,
    " and oc.activity_subtype_cd+0 = request->subactivity_type_code_value")
  ENDIF
 ENDIF
 IF ((request->code_set=14003))
  DECLARE dta_parse = vc
  SET dta_parse = "dta.task_assay_cd = cva.code_value"
  IF ((request->activity_type_code_value > 0))
   SET dta_parse = concat(dta_parse," and dta.activity_type_cd+0 = request->activity_type_code_value"
    )
  ENDIF
 ENDIF
 IF ((request->code_set=72))
  DECLARE cva_parse = vc
  SET cva_parse = "cva.code_set = request->code_set"
  DECLARE event_code_list = vc
  SET event_code_list = " and cva.code_value in ("
  SET ecnt = size(request->event_codes,5)
  FOR (e = 1 TO ecnt)
    IF (e=ecnt)
     SET event_code_list = build(event_code_list,request->event_codes[e].code_value,")")
    ELSE
     SET event_code_list = build(event_code_list,request->event_codes[e].code_value,",")
    ENDIF
  ENDFOR
  SET cva_parse = concat(cva_parse,event_code_list)
 ENDIF
 SET ccnt = 0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.active_ind=1
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(hold_sources->sources,ccnt), hold_sources->sources[ccnt].
   code_value = cv.code_value,
   hold_sources->sources[ccnt].display = cv.display, hold_sources->sources[ccnt].mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 IF (ccnt > 0)
  IF ((request->code_set=200))
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value_alias cva,
     order_catalog oc
    PLAN (d)
     JOIN (cva
     WHERE (cva.code_set=request->code_set)
      AND (cva.contributor_source_cd=hold_sources->sources[d.seq].code_value))
     JOIN (oc
     WHERE parser(oc_parse))
    DETAIL
     hold_sources->sources[d.seq].inbound_ind = 1
    WITH nocounter
   ;end select
  ELSEIF ((request->code_set=14003))
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value_alias cva,
     discrete_task_assay dta
    PLAN (d)
     JOIN (cva
     WHERE (cva.code_set=request->code_set)
      AND (cva.contributor_source_cd=hold_sources->sources[d.seq].code_value))
     JOIN (dta
     WHERE parser(dta_parse))
    DETAIL
     hold_sources->sources[d.seq].inbound_ind = 1
    WITH nocounter
   ;end select
  ELSEIF ((request->code_set=72))
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value_alias cva
    PLAN (d)
     JOIN (cva
     WHERE parser(cva_parse)
      AND (cva.contributor_source_cd=hold_sources->sources[d.seq].code_value))
    DETAIL
     hold_sources->sources[d.seq].inbound_ind = 1
    WITH nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value_alias cva
    PLAN (d)
     JOIN (cva
     WHERE (cva.code_set=request->code_set)
      AND (cva.contributor_source_cd=hold_sources->sources[d.seq].code_value))
    DETAIL
     hold_sources->sources[d.seq].inbound_ind = 1
    WITH nocounter
   ;end select
  ENDIF
  IF ((request->code_set=200))
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value_outbound cva,
     order_catalog oc
    PLAN (d)
     JOIN (cva
     WHERE (cva.code_set=request->code_set)
      AND (cva.contributor_source_cd=hold_sources->sources[d.seq].code_value))
     JOIN (oc
     WHERE parser(oc_parse))
    DETAIL
     hold_sources->sources[d.seq].outbound_ind = 1
    WITH nocounter
   ;end select
  ELSEIF ((request->code_set=14003))
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value_outbound cva,
     discrete_task_assay dta
    PLAN (d)
     JOIN (cva
     WHERE (cva.code_set=request->code_set)
      AND (cva.contributor_source_cd=hold_sources->sources[d.seq].code_value))
     JOIN (dta
     WHERE parser(dta_parse))
    DETAIL
     hold_sources->sources[d.seq].outbound_ind = 1
    WITH nocounter
   ;end select
  ELSEIF ((request->code_set=72))
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value_outbound cva
    PLAN (d)
     JOIN (cva
     WHERE parser(cva_parse)
      AND (cva.contributor_source_cd=hold_sources->sources[d.seq].code_value))
    DETAIL
     hold_sources->sources[d.seq].outbound_ind = 1
    WITH nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO "NL:"
    FROM (dummyt d  WITH seq = ccnt),
     code_value_outbound cva
    PLAN (d)
     JOIN (cva
     WHERE (cva.code_set=request->code_set)
      AND (cva.contributor_source_cd=hold_sources->sources[d.seq].code_value))
    DETAIL
     hold_sources->sources[d.seq].outbound_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET rcnt = 0
 FOR (c = 1 TO ccnt)
   IF ((((hold_sources->sources[c].inbound_ind=1)) OR ((hold_sources->sources[c].outbound_ind=1))) )
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->contributor_sources,rcnt)
    SET reply->contributor_sources[rcnt].code_value = hold_sources->sources[c].code_value
    SET reply->contributor_sources[rcnt].display = hold_sources->sources[c].display
    SET reply->contributor_sources[rcnt].mean = hold_sources->sources[c].mean
    SET reply->contributor_sources[rcnt].inbound_alias_exists_ind = hold_sources->sources[c].
    inbound_ind
    SET reply->contributor_sources[rcnt].outbound_alias_exists_ind = hold_sources->sources[c].
    outbound_ind
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
#exit_script
 CALL echorecord(reply)
END GO
