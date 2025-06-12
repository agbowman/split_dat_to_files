CREATE PROGRAM br_reg_default_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_reg_default_config.prg> script"
 DELETE  FROM br_datamart_default_detail dd
  WHERE dd.br_datamart_default_id IN (
  (SELECT
   d.br_datamart_default_id
   FROM br_datamart_category c,
    br_datamart_filter f,
    br_datamart_default d
   WHERE c.category_mean=cnvtupper(requestin->list_0[1].topic_mean)
    AND f.br_datamart_category_id=c.br_datamart_category_id
    AND d.br_datamart_filter_id=f.br_datamart_filter_id))
  WITH nocounter
 ;end delete
 DELETE  FROM br_datamart_default d
  WHERE d.br_datamart_filter_id IN (
  (SELECT
   f.br_datamart_filter_id
   FROM br_datamart_category c,
    br_datamart_filter f
   WHERE c.category_mean=cnvtupper(requestin->list_0[1].topic_mean)
    AND f.br_datamart_category_id=c.br_datamart_category_id))
  WITH nocounter
 ;end delete
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 filterid = f8
     2 existsind = i2
     2 defaultid = f8
     2 detailind = i2
     2 group_name = vc
     2 group_ce_r = vc
     2 group_ce_concept_cki = vc
 )
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 SELECT INTO "nl:"
  FROM br_datamart_category bdc,
   br_datamart_filter bdf,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (bdc
   WHERE bdc.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
   JOIN (bdf
   WHERE bdf.br_datamart_category_id=bdc.br_datamart_category_id
    AND bdf.filter_mean=cnvtupper(requestin->list_0[d.seq].filter_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].filterid = bdf.br_datamart_filter_id
   IF (bdf.filter_category_mean="ORDER_DETAILS")
    br_existsinfo->list_0[d.seq].detailind = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (y = 1 TO cnt)
   SET new_id = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET br_existsinfo->list_0[y].defaultid = new_id
   IF (validate(requestin->list_0[y].group_name,"") > " ")
    SET br_existsinfo->list_0[y].group_name = requestin->list_0[y].group_name
   ELSE
    SET br_existsinfo->list_0[y].group_name = ""
   ENDIF
   IF (validate(requestin->list_0[y].group_ce_r,"") > " ")
    SET br_existsinfo->list_0[y].group_ce_r = requestin->list_0[y].group_ce_r
   ELSE
    SET br_existsinfo->list_0[y].group_ce_r = ""
   ENDIF
   IF (validate(requestin->list_0[y].group_ce_concept_cki,"") > " ")
    SET br_existsinfo->list_0[y].group_ce_concept_cki = requestin->list_0[y].group_ce_concept_cki
   ELSE
    SET br_existsinfo->list_0[y].group_ce_concept_cki = ""
   ENDIF
 ENDFOR
 INSERT  FROM br_datamart_default b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_default_id = br_existsinfo->list_0[d.seq].defaultid, b.br_datamart_filter_id =
   br_existsinfo->list_0[d.seq].filterid, b.unique_identifier = requestin->list_0[d.seq].
   unique_identifier,
   b.cv_display = requestin->list_0[d.seq].short_name, b.cv_description = requestin->list_0[d.seq].
   long_name, b.code_set =
   IF ((requestin->list_0[d.seq].code_set > " ")) cnvtint(requestin->list_0[d.seq].code_set)
   ELSE 0
   ENDIF
   ,
   b.result_type_flag =
   IF (cnvtupper(requestin->list_0[d.seq].result_type)="ALPHA") 1
   ELSEIF (cnvtupper(requestin->list_0[d.seq].result_type)="NUMERIC") 2
   ELSE 0
   ENDIF
   , b.qualifier_flag =
   IF (cnvtupper(requestin->list_0[d.seq].qualifier)="EQUAL TO") 1
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="NOT EQUAL TO") 2
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="GREATER THAN") 3
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="LESS THAN") 4
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="GREATER THAN OR EQUAL TO") 5
   ELSEIF (cnvtupper(requestin->list_0[d.seq].qualifier)="LESS THAN OR EQUAL TO") 6
   ELSE 0
   ENDIF
   , b.result_value = requestin->list_0[d.seq].result_value,
   b.order_detail_ind = br_existsinfo->list_0[d.seq].detailind, b.group_name = br_existsinfo->list_0[
   d.seq].group_name, b.group_ce_name = br_existsinfo->list_0[d.seq].group_ce_r,
   b.group_ce_concept_cki = br_existsinfo->list_0[d.seq].group_ce_concept_cki, b.updt_cnt = 0, b
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart defaults >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 FOR (y = 1 TO cnt)
   IF ((br_existsinfo->list_0[y].detailind=1))
    FREE SET temp
    RECORD temp(
      1 ord[*]
        2 mean = vc
        2 val = vc
        2 cki = vc
    )
    SET ocnt = 0
    IF ((requestin->list_0[y].oe_field_meaning1 > " "))
     SET ocnt = (ocnt+ 1)
     SET stat = alterlist(temp->ord,ocnt)
     SET temp->ord[ocnt].mean = requestin->list_0[y].oe_field_meaning1
     SET temp->ord[ocnt].val = requestin->list_0[y].oe_detail_value1
     SET temp->ord[ocnt].cki = requestin->list_0[y].oe_detail_cki1
    ENDIF
    IF ((requestin->list_0[y].oe_field_meaning2 > " "))
     SET ocnt = (ocnt+ 1)
     SET stat = alterlist(temp->ord,ocnt)
     SET temp->ord[ocnt].mean = requestin->list_0[y].oe_field_meaning2
     SET temp->ord[ocnt].val = requestin->list_0[y].oe_detail_value2
     SET temp->ord[ocnt].cki = requestin->list_0[y].oe_detail_cki2
    ENDIF
    IF ((requestin->list_0[y].oe_field_meaning3 > " "))
     SET ocnt = (ocnt+ 1)
     SET stat = alterlist(temp->ord,ocnt)
     SET temp->ord[ocnt].mean = requestin->list_0[y].oe_field_meaning3
     SET temp->ord[ocnt].val = requestin->list_0[y].oe_detail_value3
     SET temp->ord[ocnt].cki = requestin->list_0[y].oe_detail_cki3
    ENDIF
    IF ((requestin->list_0[y].oe_field_meaning4 > " "))
     SET ocnt = (ocnt+ 1)
     SET stat = alterlist(temp->ord,ocnt)
     SET temp->ord[ocnt].mean = requestin->list_0[y].oe_field_meaning4
     SET temp->ord[ocnt].val = requestin->list_0[y].oe_detail_value4
     SET temp->ord[ocnt].cki = requestin->list_0[y].oe_detail_cki4
    ENDIF
    IF (ocnt > 0)
     INSERT  FROM br_datamart_default_detail b,
       (dummyt d  WITH seq = value(ocnt))
      SET b.br_datamart_default_detail_id = seq(bedrock_seq,nextval), b.br_datamart_default_id =
       br_existsinfo->list_0[y].defaultid, b.oe_field_meaning = cnvtupper(temp->ord[d.seq].mean),
       b.detail_value = temp->ord[d.seq].val, b.detail_cki = temp->ord[d.seq].cki, b.updt_cnt = 0,
       b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
       reqinfo->updt_task,
       b.updt_applctx = reqinfo->updt_applctx
      PLAN (d)
       JOIN (b)
      WITH nocounter
     ;end insert
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failure inserting datamart default details >> ",errmsg)
      GO TO exit_script
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_reg_default_config.prg> script"
#exit_script
 FREE RECORD br_existsinfo
END GO
