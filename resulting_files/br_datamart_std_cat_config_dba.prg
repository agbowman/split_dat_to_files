CREATE PROGRAM br_datamart_std_cat_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_datamart_std_cat_config.prg> script"
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE cnt = i4 WITH protect, noconstant(0)
 FREE RECORD br_existsinfo
 RECORD br_existsinfo(
   1 list_0[*]
     2 existsind = i2
     2 category_type = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 category_topic_mean = vc
     2 script_name = vc
     2 flex_flag = i2
     2 reliability_score_disp = i2
     2 baseline_target_disp = i2
     2 viewpoint_capable_ind = i2
 )
 UPDATE  FROM br_datamart_value b
  SET b.parent_entity_name = "CODE_VALUE", b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(
    sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  WHERE b.br_datamart_filter_id IN (
  (SELECT
   f.br_datamart_filter_id
   FROM br_datamart_filter f
   WHERE f.filter_category_mean="CAT_TYPE_ASSIGN"))
   AND b.parent_entity_id > 0
   AND  NOT (b.parent_entity_name > " ")
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating AMB_CAT_TYPE_OE >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM br_datamart_value b
  SET b.parent_entity_name = "DCP_FORMS_REF", b.updt_cnt = (b.updt_cnt+ 1), b.updt_dt_tm =
   cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  WHERE b.br_datamart_filter_id IN (
  (SELECT
   f.br_datamart_filter_id
   FROM br_datamart_filter f
   WHERE f.filter_category_mean="PF_MULTI_SELECT"))
   AND b.parent_entity_id > 0
   AND  NOT (b.parent_entity_name > " ")
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure updating PF_MULTI_SELECT >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET cnt = size(requestin->list_0,5)
 SET stat = alterlist(br_existsinfo->list_0,cnt)
 FOR (y = 1 TO cnt)
   IF (validate(requestin->list_0[y].script_name,"") > " ")
    SET br_existsinfo->list_0[y].script_name = cnvtupper(requestin->list_0[y].script_name)
   ELSE
    SET br_existsinfo->list_0[y].script_name = ""
   ENDIF
   IF (validate(requestin->list_0[y].category_type,"") > " ")
    SET br_existsinfo->list_0[y].category_type = cnvtint(requestin->list_0[y].category_type)
   ELSE
    SET br_existsinfo->list_0[y].category_type = 0
   ENDIF
   IF (validate(requestin->list_0[y].flex_flag,"") > " ")
    SET br_existsinfo->list_0[y].flex_flag = cnvtint(requestin->list_0[y].flex_flag)
   ELSE
    SET br_existsinfo->list_0[y].flex_flag = 0
   ENDIF
   IF (validate(requestin->list_0[y].reliability_score_disp,"") > " ")
    IF (cnvtupper(requestin->list_0[y].reliability_score_disp)="OFF")
     SET br_existsinfo->list_0[y].reliability_score_disp = 1
    ELSE
     SET br_existsinfo->list_0[y].reliability_score_disp = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].reliability_score_disp = 0
   ENDIF
   IF (validate(requestin->list_0[y].baseline_target_disp,"") > " ")
    IF (cnvtupper(requestin->list_0[y].baseline_target_disp)="OFF")
     SET br_existsinfo->list_0[y].baseline_target_disp = 1
    ELSE
     SET br_existsinfo->list_0[y].baseline_target_disp = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].baseline_target_disp = 0
   ENDIF
   IF (validate(requestin->list_0[y].viewpoint_capable_ind,"") > " ")
    IF (cnvtupper(requestin->list_0[y].viewpoint_capable_ind)="1")
     SET br_existsinfo->list_0[y].viewpoint_capable_ind = 1
    ELSE
     SET br_existsinfo->list_0[y].viewpoint_capable_ind = 0
    ENDIF
   ELSE
    SET br_existsinfo->list_0[y].viewpoint_capable_ind = 0
   ENDIF
   IF (validate(requestin->list_0[y].topic_category,"") > " ")
    SET br_existsinfo->list_0[y].category_topic_mean = requestin->list_0[y].topic_category
   ELSE
    SET br_existsinfo->list_0[y].category_topic_mean = ""
   ENDIF
   IF (validate(requestin->list_0[y].beg_effective_dt_tm,"") > " ")
    IF (textlen(requestin->list_0[y].beg_effective_dt_tm)=7)
     SET requestin->list_0[y].beg_effective_dt_tm = concat("0",requestin->list_0[y].
      beg_effective_dt_tm)
    ENDIF
    SET beg_dt_tm = cnvtdatetime(curdate,curtime)
    SET x2 = "  "
    SET x3 = "   "
    SET abc = fillstring(25," ")
    SET xyz = "  -   -     00:00:00"
    SET abc = trim(requestin->list_0[y].beg_effective_dt_tm)
    SET stat = movestring(abc,3,xyz,1,2)
    SET x2 = substring(1,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,5,xyz,8,4)
    SET beg_dt_tm = cnvtdatetime(xyz)
    SET br_existsinfo->list_0[y].beg_effective_dt_tm = cnvtdatetime(beg_dt_tm)
   ENDIF
   IF (validate(requestin->list_0[y].end_effective_dt_tm,"") > " ")
    IF (textlen(requestin->list_0[y].end_effective_dt_tm)=7)
     SET requestin->list_0[y].end_effective_dt_tm = concat("0",requestin->list_0[y].
      end_effective_dt_tm)
    ENDIF
    SET end_dt_tm = cnvtdatetime(curdate,curtime)
    SET x2 = "  "
    SET x3 = "   "
    SET abc = fillstring(25," ")
    SET xyz = "  -   -     23:59:59"
    SET abc = trim(requestin->list_0[y].end_effective_dt_tm)
    SET stat = movestring(abc,3,xyz,1,2)
    SET x2 = substring(1,2,abc)
    IF (x2="01")
     SET x3 = "JAN"
    ELSEIF (x2="02")
     SET x3 = "FEB"
    ELSEIF (x2="03")
     SET x3 = "MAR"
    ELSEIF (x2="04")
     SET x3 = "APR"
    ELSEIF (x2="05")
     SET x3 = "MAY"
    ELSEIF (x2="06")
     SET x3 = "JUN"
    ELSEIF (x2="07")
     SET x3 = "JUL"
    ELSEIF (x2="08")
     SET x3 = "AUG"
    ELSEIF (x2="09")
     SET x3 = "SEP"
    ELSEIF (x2="10")
     SET x3 = "OCT"
    ELSEIF (x2="11")
     SET x3 = "NOV"
    ELSEIF (x2="12")
     SET x3 = "DEC"
    ENDIF
    SET stat = movestring(x3,1,xyz,4,3)
    SET stat = movestring(abc,5,xyz,8,4)
    SET end_dt_tm = cnvtdatetime(xyz)
    SET br_existsinfo->list_0[y].end_effective_dt_tm = cnvtdatetime(end_dt_tm)
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM br_datamart_category b,
   (dummyt d  WITH seq = value(cnt))
  PLAN (d)
   JOIN (b
   WHERE b.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
  DETAIL
   br_existsinfo->list_0[d.seq].existsind = 1
  WITH nocounter
 ;end select
 INSERT  FROM br_datamart_category b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_datamart_category_id = seq(bedrock_seq,nextval), b.category_name = requestin->list_0[d.seq
   ].topic_display, b.category_mean = cnvtupper(requestin->list_0[d.seq].topic_mean),
   b.category_type_flag = br_existsinfo->list_0[d.seq].category_type, b.beg_effective_dt_tm =
   IF ((br_existsinfo->list_0[d.seq].beg_effective_dt_tm > 0)) cnvtdatetime(br_existsinfo->list_0[d
     .seq].beg_effective_dt_tm)
   ELSE null
   ENDIF
   , b.end_effective_dt_tm =
   IF ((br_existsinfo->list_0[d.seq].end_effective_dt_tm > 0)) cnvtdatetime(br_existsinfo->list_0[d
     .seq].end_effective_dt_tm)
   ELSE null
   ENDIF
   ,
   b.category_topic_mean = cnvtupper(br_existsinfo->list_0[d.seq].category_topic_mean), b.script_name
    = br_existsinfo->list_0[d.seq].script_name, b.flex_flag = br_existsinfo->list_0[d.seq].flex_flag,
   b.reliability_score_ind = br_existsinfo->list_0[d.seq].reliability_score_disp, b
   .baseline_target_ind = br_existsinfo->list_0[d.seq].baseline_target_disp, b.viewpoint_capable_ind
    = br_existsinfo->list_0[d.seq].viewpoint_capable_ind,
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(sysdate), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=0))
   JOIN (b)
  WITH nocounter
 ;end insert
 UPDATE  FROM br_datamart_category b,
   (dummyt d  WITH seq = value(cnt))
  SET b.category_name = requestin->list_0[d.seq].topic_display, b.category_type_flag = br_existsinfo
   ->list_0[d.seq].category_type, b.beg_effective_dt_tm =
   IF ((br_existsinfo->list_0[d.seq].beg_effective_dt_tm > 0)) cnvtdatetime(br_existsinfo->list_0[d
     .seq].beg_effective_dt_tm)
   ELSE null
   ENDIF
   ,
   b.end_effective_dt_tm =
   IF ((br_existsinfo->list_0[d.seq].end_effective_dt_tm > 0)) cnvtdatetime(br_existsinfo->list_0[d
     .seq].end_effective_dt_tm)
   ELSE null
   ENDIF
   , b.category_topic_mean = cnvtupper(br_existsinfo->list_0[d.seq].category_topic_mean), b
   .script_name = br_existsinfo->list_0[d.seq].script_name,
   b.flex_flag = br_existsinfo->list_0[d.seq].flex_flag, b.reliability_score_ind = br_existsinfo->
   list_0[d.seq].reliability_score_disp, b.baseline_target_ind = br_existsinfo->list_0[d.seq].
   baseline_target_disp,
   b.viewpoint_capable_ind = br_existsinfo->list_0[d.seq].viewpoint_capable_ind, b.updt_cnt = (b
   .updt_cnt+ 1), b.updt_dt_tm = cnvtdatetime(sysdate),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (br_existsinfo->list_0[d.seq].existsind=1))
   JOIN (b
   WHERE b.category_mean=cnvtupper(requestin->list_0[d.seq].topic_mean))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failure inserting datamart categories >> ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Readme Succeeded: <br_datamart_std_cat_config.prg> script"
#exit_script
 CALL echorecord(readme_data)
 FREE RECORD br_existsinfo
END GO
