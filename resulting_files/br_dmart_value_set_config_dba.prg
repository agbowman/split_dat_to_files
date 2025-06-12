CREATE PROGRAM br_dmart_value_set_config:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting <br_dmart_value_set_config.prg> script"
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE reqcnt = i4 WITH protect, noconstant(0)
 DECLARE mapvalcnt = i4 WITH protect, noconstant(0)
 DECLARE valcnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE totdtldel = i4 WITH protect, noconstant(0)
 DECLARE totmapdel = i4 WITH protect, noconstant(0)
 DECLARE maxfield50 = vc WITH protect, noconstant("")
 SET reqcnt = size(requestin->list_0,5)
 SET cnt = (reqcnt+ 1)
 FREE RECORD br_import
 RECORD br_import(
   1 import[*]
     2 topicmean = vc
     2 templatename = vc
     2 topicind = vc
     2 valuesetname = vc
     2 codingsystem = vc
     2 codingsystemoid = vc
     2 code = vc
     2 drugdescrip = vc
     2 qualifiermodifier = vc
     2 codedescrip = vc
     2 drugcategory = vc
     2 drugexclusion = i2
     2 enddatetime = dq8
     2 minvalue = f8
     2 maxvalue = f8
     2 unitsofmeasure = vc
     2 mappingind = i2
     2 delind = i2
     2 categoryid = f8
     2 valuesetid = f8
     2 mapvalueid = f8
     2 mapvaluedtlid = f8
     2 valuesetoid = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 SET stat = alterlist(br_import->import,cnt)
 FREE RECORD br_value_set
 RECORD br_value_set(
   1 value_set[*]
     2 valuesetid = f8
     2 categoryid = f8
     2 templatename = vc
     2 valuesetname = vc
     2 valuesetoid = vc
 )
 FREE RECORD br_map_value
 RECORD br_map_value(
   1 map_value[*]
     2 mapvalueid = f8
     2 valuesetid = f8
     2 code = vc
     2 codingsystem = vc
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
 )
 FREE RECORD br_del_dtls
 RECORD br_del_dtls(
   1 dtls[*]
     2 detailid = f8
 )
 SET maxfield50 = cnvtupper(fillstring(50,"z"))
 DECLARE validate_optional_csv_columns(dseq=i4) = null
 DECLARE drugexclusion = i2 WITH protect, noconstant(0)
 DECLARE minvalue = f8 WITH protect, noconstant(0.0)
 DECLARE maxvalue = f8 WITH protect, noconstant(0.0)
 DECLARE mappingind = i2 WITH protect, noconstant(0)
 DECLARE delind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM br_datamart_category c,
   (dummyt d  WITH seq = value(reqcnt))
  PLAN (d)
   JOIN (c
   WHERE cnvtupper(c.category_mean)=cnvtupper(requestin->list_0[d.seq].topic_mean)
    AND c.category_type_flag=0)
  ORDER BY c.br_datamart_category_id
  HEAD c.br_datamart_category_id
   br_import->import[d.seq].categoryid = c.br_datamart_category_id, br_import->import[d.seq].
   topicmean = cnvtupper(fillstring(30,"z")), br_import->import[d.seq].templatename = maxfield50,
   br_import->import[d.seq].topicind = maxfield50, br_import->import[d.seq].valuesetname = cnvtupper(
    fillstring(255,"z")), br_import->import[d.seq].codingsystem = cnvtupper(fillstring(12,"z")),
   br_import->import[d.seq].code = maxfield50, br_import->import[(d.seq+ 1)].qualifiermodifier =
   cnvtupper(fillstring(40,"z"))
  DETAIL
   IF (cnvtupper(requestin->list_0[d.seq].drug_exclusion)="Y")
    drugexclusion = 1
   ELSE
    drugexclusion = 0
   ENDIF
   IF (isnumeric(requestin->list_0[d.seq].minimum_value))
    minvalue = cnvtreal(requestin->list_0[d.seq].minimum_value)
   ELSE
    minvalue = 0
   ENDIF
   IF (isnumeric(requestin->list_0[d.seq].maximum_value))
    maxvalue = cnvtreal(requestin->list_0[d.seq].maximum_value)
   ELSE
    maxvalue = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[d.seq].mapping_indicator)="Y")
    mappingind = 1
   ELSE
    mappingind = 0
   ENDIF
   IF (cnvtupper(requestin->list_0[d.seq].delete_indicator)="Y")
    delind = 1
   ELSE
    delind = 0
   ENDIF
   br_import->import[(d.seq+ 1)].categoryid = c.br_datamart_category_id, br_import->import[(d.seq+ 1)
   ].topicmean = cnvtupper(requestin->list_0[d.seq].topic_mean), br_import->import[(d.seq+ 1)].
   templatename = cnvtupper(requestin->list_0[d.seq].template_name),
   br_import->import[(d.seq+ 1)].topicind = cnvtupper(requestin->list_0[d.seq].topic_indicator),
   br_import->import[(d.seq+ 1)].valuesetname = cnvtupper(requestin->list_0[d.seq].value_set_name),
   br_import->import[(d.seq+ 1)].codingsystem = cnvtupper(requestin->list_0[d.seq].coding_system),
   br_import->import[(d.seq+ 1)].codingsystemoid = requestin->list_0[d.seq].coding_system_oid,
   br_import->import[(d.seq+ 1)].code = cnvtupper(requestin->list_0[d.seq].code), br_import->import[(
   d.seq+ 1)].drugdescrip = requestin->list_0[d.seq].drug_description,
   br_import->import[(d.seq+ 1)].qualifiermodifier = cnvtupper(requestin->list_0[d.seq].
    qualifier_modifier), br_import->import[(d.seq+ 1)].codedescrip = requestin->list_0[d.seq].
   code_description, br_import->import[(d.seq+ 1)].drugcategory = requestin->list_0[d.seq].
   drug_category,
   br_import->import[(d.seq+ 1)].drugexclusion = drugexclusion, br_import->import[(d.seq+ 1)].
   enddatetime = cnvtdatetime(cnvtdate2(trim(requestin->list_0[d.seq].end_date),"MM/DD/YYYY"),0),
   br_import->import[(d.seq+ 1)].minvalue = minvalue,
   br_import->import[(d.seq+ 1)].maxvalue = maxvalue, br_import->import[(d.seq+ 1)].unitsofmeasure =
   requestin->list_0[d.seq].units_of_measure, br_import->import[(d.seq+ 1)].mappingind = mappingind,
   br_import->import[(d.seq+ 1)].delind = delind,
   CALL validate_optional_csv_columns(d.seq)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt))
  PLAN (d)
  ORDER BY br_import->import[d.seq].categoryid, br_import->import[d.seq].templatename, br_import->
   import[d.seq].valuesetname
  HEAD REPORT
   valcnt = 0, stat = alterlist(br_value_set->value_set,cnt)
  DETAIL
   valcnt = (valcnt+ 1), br_value_set->value_set[valcnt].categoryid = br_import->import[d.seq].
   categoryid, br_value_set->value_set[valcnt].templatename = br_import->import[d.seq].templatename,
   br_value_set->value_set[valcnt].valuesetname = br_import->import[d.seq].valuesetname, br_value_set
   ->value_set[valcnt].valuesetoid = br_import->import[d.seq].valuesetoid
  FOOT REPORT
   stat = alterlist(br_value_set->value_set,valcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datam_val_set vs,
   (dummyt d  WITH seq = value(valcnt))
  PLAN (d)
   JOIN (vs
   WHERE vs.br_datamart_category_id > 0
    AND (vs.br_datamart_category_id=br_value_set->value_set[d.seq].categoryid)
    AND (vs.template_name=br_value_set->value_set[d.seq].templatename)
    AND (vs.value_set_name=br_value_set->value_set[d.seq].valuesetname))
  DETAIL
   br_value_set->value_set[d.seq].valuesetid = vs.br_datam_val_set_id
  WITH nocounter
 ;end select
 INSERT  FROM br_datam_val_set vs,
   (dummyt d  WITH seq = value(valcnt))
  SET vs.br_datam_val_set_id = seq(bedrock_seq,nextval), vs.br_datamart_category_id = br_value_set->
   value_set[d.seq].categoryid, vs.template_name = br_value_set->value_set[d.seq].templatename,
   vs.value_set_name = br_value_set->value_set[d.seq].valuesetname, vs.updt_cnt = 0, vs.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   vs.updt_id = reqinfo->updt_id, vs.updt_task = reqinfo->updt_task, vs.updt_applctx = reqinfo->
   updt_applctx,
   vs.vocab_oid_txt = br_value_set->value_set[d.seq].valuesetoid
  PLAN (d
   WHERE (br_value_set->value_set[d.seq].valuesetid=0.0)
    AND (br_value_set->value_set[d.seq].templatename != maxfield50)
    AND (br_value_set->value_set[d.seq].categoryid != 0.0))
   JOIN (vs)
  WITH nocounter
 ;end insert
 UPDATE  FROM br_datam_val_set vs,
   (dummyt d  WITH seq = value(valcnt))
  SET vs.vocab_oid_txt = br_value_set->value_set[d.seq].valuesetoid, vs.updt_cnt = (vs.updt_cnt+ 1),
   vs.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   vs.updt_id = reqinfo->updt_id, vs.updt_task = reqinfo->updt_task, vs.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_value_set->value_set[d.seq].valuesetid > 0.0))
   JOIN (vs
   WHERE (vs.br_datam_val_set_id=br_value_set->value_set[d.seq].valuesetid))
  WITH nocounter
 ;end update
 SELECT INTO "nl:"
  FROM br_datam_val_set vs,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (br_import->import[d.seq].categoryid > 0))
   JOIN (vs
   WHERE (vs.br_datamart_category_id=br_import->import[d.seq].categoryid)
    AND (vs.template_name=br_import->import[d.seq].templatename)
    AND (vs.value_set_name=br_import->import[d.seq].valuesetname))
  DETAIL
   br_import->import[d.seq].valuesetid = vs.br_datam_val_set_id
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (br_import->import[d.seq].valuesetid > 0))
  ORDER BY br_import->import[d.seq].valuesetid, br_import->import[d.seq].codingsystem, br_import->
   import[d.seq].code
  HEAD REPORT
   stat = alterlist(br_map_value->map_value,(cnt+ 1)), mapvalcnt = 0
  DETAIL
   mapvalcnt = (mapvalcnt+ 1), br_map_value->map_value[mapvalcnt].valuesetid = br_import->import[d
   .seq].valuesetid, br_map_value->map_value[mapvalcnt].codingsystem = br_import->import[d.seq].
   codingsystem,
   br_map_value->map_value[mapvalcnt].code = br_import->import[d.seq].code, br_map_value->map_value[
   mapvalcnt].beg_effective_dt_tm = br_import->import[d.seq].beg_effective_dt_tm, br_map_value->
   map_value[mapvalcnt].end_effective_dt_tm = br_import->import[d.seq].end_effective_dt_tm
  FOOT REPORT
   stat = alterlist(br_map_value->map_value,mapvalcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datam_val_set_item mv,
   (dummyt d  WITH seq = value(mapvalcnt))
  PLAN (d
   WHERE (br_map_value->map_value[d.seq].valuesetid > 0))
   JOIN (mv
   WHERE (mv.br_datam_val_set_id=br_map_value->map_value[d.seq].valuesetid)
    AND (mv.source_vocab_item_ident=br_map_value->map_value[d.seq].code)
    AND (mv.source_vocab_mean=br_map_value->map_value[d.seq].codingsystem))
  DETAIL
   br_map_value->map_value[d.seq].mapvalueid = mv.br_datam_val_set_item_id
  WITH nocounter
 ;end select
 UPDATE  FROM br_datam_val_set_item m,
   (dummyt d  WITH seq = value(mapvalcnt))
  SET m.updt_cnt = (m.updt_cnt+ 1), m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_id =
   reqinfo->updt_id,
   m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->updt_applctx, m.beg_effective_dt_tm =
   cnvtdatetime(br_map_value->map_value[d.seq].beg_effective_dt_tm),
   m.end_effective_dt_tm = cnvtdatetime(br_map_value->map_value[d.seq].end_effective_dt_tm)
  PLAN (d
   WHERE (br_map_value->map_value[d.seq].mapvalueid != 0))
   JOIN (m
   WHERE (m.br_datam_val_set_item_id=br_map_value->map_value[d.seq].mapvalueid))
  WITH nocounter
 ;end update
 INSERT  FROM br_datam_val_set_item m,
   (dummyt d  WITH seq = value(mapvalcnt))
  SET m.br_datam_val_set_item_id = seq(bedrock_seq,nextval), m.br_datam_val_set_id = br_map_value->
   map_value[d.seq].valuesetid, m.source_vocab_item_ident = br_map_value->map_value[d.seq].code,
   m.source_vocab_mean = br_map_value->map_value[d.seq].codingsystem, m.updt_cnt = 0, m.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   m.updt_id = reqinfo->updt_id, m.updt_task = reqinfo->updt_task, m.updt_applctx = reqinfo->
   updt_applctx,
   m.beg_effective_dt_tm = cnvtdatetime(br_map_value->map_value[d.seq].beg_effective_dt_tm), m
   .end_effective_dt_tm = cnvtdatetime(br_map_value->map_value[d.seq].end_effective_dt_tm)
  PLAN (d
   WHERE (br_map_value->map_value[d.seq].mapvalueid=0)
    AND (br_map_value->map_value[d.seq].code != maxfield50))
   JOIN (m)
  WITH nocounter
 ;end insert
 SELECT INTO "nl:"
  FROM br_datam_val_set_item mv,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (br_import->import[d.seq].valuesetid > 0))
   JOIN (mv
   WHERE (mv.br_datam_val_set_id=br_import->import[d.seq].valuesetid)
    AND (mv.source_vocab_mean=br_import->import[d.seq].codingsystem)
    AND (mv.source_vocab_item_ident=br_import->import[d.seq].code))
  DETAIL
   br_import->import[d.seq].mapvalueid = mv.br_datam_val_set_item_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datam_val_set_item_meas mvd,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (br_import->import[d.seq].mapvalueid > 0))
   JOIN (mvd
   WHERE (mvd.br_datam_val_set_item_id=br_import->import[d.seq].mapvalueid)
    AND (mvd.meas_ident=br_import->import[d.seq].topicind)
    AND (mvd.vocab_item_qualifier_txt=br_import->import[d.seq].qualifiermodifier))
  DETAIL
   br_import->import[d.seq].mapvaluedtlid = mvd.br_datam_val_set_item_meas_id
  WITH nocounter
 ;end select
 INSERT  FROM br_datam_val_set_item_meas mvd,
   (dummyt d  WITH seq = value(cnt))
  SET mvd.br_datam_val_set_item_meas_id = seq(bedrock_seq,nextval), mvd.br_datam_val_set_item_id =
   br_import->import[d.seq].mapvalueid, mvd.vocab_oid_txt = br_import->import[d.seq].codingsystemoid,
   mvd.drug_desc = br_import->import[d.seq].drugdescrip, mvd.vocab_item_qualifier_txt = br_import->
   import[d.seq].qualifiermodifier, mvd.vocab_item_desc = br_import->import[d.seq].codedescrip,
   mvd.drug_category_txt = br_import->import[d.seq].drugcategory, mvd.drug_exclusion_ind = br_import
   ->import[d.seq].drugexclusion, mvd.meas_ident = br_import->import[d.seq].topicind,
   mvd.vocab_item_end_effective_dt_tm = cnvtdatetime(br_import->import[d.seq].enddatetime), mvd
   .meas_min_value = cnvtreal(br_import->import[d.seq].minvalue), mvd.meas_max_value = cnvtreal(
    br_import->import[d.seq].maxvalue),
   mvd.meas_uom_txt = br_import->import[d.seq].unitsofmeasure, mvd.mapping_required_ind = br_import->
   import[d.seq].mappingind, mvd.updt_cnt = 0,
   mvd.updt_dt_tm = cnvtdatetime(curdate,curtime3), mvd.updt_id = reqinfo->updt_id, mvd.updt_task =
   reqinfo->updt_task,
   mvd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_import->import[d.seq].mapvaluedtlid=0.0)
    AND (br_import->import[d.seq].mapvalueid > 0.0)
    AND (br_import->import[d.seq].valuesetid > 0.0)
    AND (br_import->import[d.seq].topicind != maxfield50)
    AND (br_import->import[d.seq].delind=0.0))
   JOIN (mvd)
  WITH nocounter
 ;end insert
 UPDATE  FROM br_datam_val_set_item_meas mvd,
   (dummyt d  WITH seq = value(cnt))
  SET mvd.vocab_oid_txt = br_import->import[d.seq].codingsystemoid, mvd.drug_desc = br_import->
   import[d.seq].drugdescrip, mvd.vocab_item_qualifier_txt = br_import->import[d.seq].
   qualifiermodifier,
   mvd.vocab_item_desc = br_import->import[d.seq].codedescrip, mvd.drug_category_txt = br_import->
   import[d.seq].drugcategory, mvd.drug_exclusion_ind = br_import->import[d.seq].drugexclusion,
   mvd.vocab_item_end_effective_dt_tm = cnvtdatetime(br_import->import[d.seq].enddatetime), mvd
   .meas_min_value = cnvtreal(br_import->import[d.seq].minvalue), mvd.meas_max_value = cnvtreal(
    br_import->import[d.seq].maxvalue),
   mvd.meas_uom_txt = br_import->import[d.seq].unitsofmeasure, mvd.mapping_required_ind = br_import->
   import[d.seq].mappingind, mvd.updt_cnt = (mvd.updt_cnt+ 1),
   mvd.updt_dt_tm = cnvtdatetime(curdate,curtime3), mvd.updt_id = reqinfo->updt_id, mvd.updt_task =
   reqinfo->updt_task,
   mvd.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_import->import[d.seq].mapvaluedtlid > 0.0)
    AND (br_import->import[d.seq].delind=0.0))
   JOIN (mvd
   WHERE (mvd.br_datam_val_set_item_meas_id=br_import->import[d.seq].mapvaluedtlid))
  WITH nocounter
 ;end update
 DELETE  FROM br_datam_val_set_item_meas mvd,
   (dummyt d  WITH seq = value(cnt))
  SET mvd.seq = 1
  PLAN (d
   WHERE (br_import->import[d.seq].mapvaluedtlid > 0.0)
    AND (br_import->import[d.seq].delind=1))
   JOIN (mvd
   WHERE (mvd.br_datam_val_set_item_meas_id=br_import->import[d.seq].mapvaluedtlid))
  WITH nocounter
 ;end delete
 SUBROUTINE validate_optional_csv_columns(dseq)
   IF (validate(requestin->list_0[dseq].value_set_oid))
    SET br_import->import[(dseq+ 1)].valuesetoid = requestin->list_0[dseq].value_set_oid
   ELSE
    SET br_import->import[(dseq+ 1)].valuesetoid = ""
   ENDIF
   IF (validate(requestin->list_0[dseq].beg_effective_dt_tm))
    IF (cnvtdate(requestin->list_0[dseq].beg_effective_dt_tm) != 0)
     SET br_import->import[(dseq+ 1)].beg_effective_dt_tm = cnvtdatetime(cnvtdate(requestin->list_0[
       dseq].beg_effective_dt_tm),0)
    ELSE
     SET br_import->import[(dseq+ 1)].beg_effective_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00")
    ENDIF
   ELSE
    SET br_import->import[(dseq+ 1)].beg_effective_dt_tm = cnvtdatetime("01-JAN-1800 00:00:00")
   ENDIF
   IF (validate(requestin->list_0[dseq].end_effective_dt_tm))
    IF (cnvtdate(requestin->list_0[dseq].end_effective_dt_tm) != 0)
     SET br_import->import[(dseq+ 1)].end_effective_dt_tm = cnvtdatetime(cnvtdate(requestin->list_0[
       dseq].end_effective_dt_tm),235959)
    ELSE
     SET br_import->import[(dseq+ 1)].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59")
    ENDIF
   ELSE
    SET br_import->import[(dseq+ 1)].end_effective_dt_tm = cnvtdatetime("31-DEC-2100 23:59:59")
   ENDIF
 END ;Subroutine
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart mapping type >> ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_dmart_map_types_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
END GO
