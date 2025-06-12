CREATE PROGRAM dm_starter_cs_extension_mpd:dba
 SELECT INTO dm_starter_cs_extension_mpd
  d.*
  FROM dual d
  DETAIL
   "set trace noreflog go", row + 1, "set trace symbol mark go",
   row + 1
  WITH nocounter, maxrow = 1, maxcol = 512,
   format = variable, formfeed = none
 ;end select
 IF (trim(ref)="C")
  SET ref_status = fillstring(20," ")
  SET ref_status = "2D"
  FREE SET list
  RECORD list(
    1 qual[*]
      2 code_set = i4
    1 count = i4
  )
  SET list->count = 0
  SET stat = alterlist(list->qual,10)
  SELECT DISTINCT INTO "nl:"
   dm.code_set
   FROM dm_feature_code_sets_env dm,
    dm_features df
   WHERE dm.feature_number=df.feature_number
    AND dm.environment=env
    AND df.feature_status=ref_status
   ORDER BY dm.code_set
   DETAIL
    list->count = (list->count+ 1)
    IF (mod(list->count,10)=1)
     stat = alterlist(list->qual,(list->count+ 9))
    ENDIF
    list->qual[list->count].code_set = dm.code_set
   WITH nocounter
  ;end select
  SET cnt = 0
  FOR (cnt = 1 TO list->count)
    SET tempstr = fillstring(255," ")
    FREE SET r1
    RECORD r1(
      1 rdate = dq8
    )
    SET r1->rdate = 0
    SELECT INTO "NL:"
     dcf.schema_dt_tm
     FROM dm_feature_code_sets_env dcf
     WHERE (dcf.code_set=list->qual[cnt].code_set)
      AND dcf.environment=env
      AND (dcf.feature_number=
     (SELECT
      dm.feature_number
      FROM dm_features dm
      WHERE dm.feature_status >= ref_status
       AND ((dm.feature_status != "2F") OR (dm.feature_status != "3F")) ))
     DETAIL
      IF ((dcf.schema_dt_tm > r1->rdate))
       r1->rdate = dcf.schema_dt_tm
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO dm_starter_cs_extension_mpd
     dcv.code_set, dcv.field_name, dcv.field_seq,
     dcv.field_type, dcv.field_len, dcv.field_prompt,
     dcv.field_default, dcv.field_help, dcv.field_in_mask,
     dcv.field_out_mask, dcv.validation_condition, dcv.validation_code_set,
     dcv.action_field, dcv.updt_id, dcv.updt_cnt,
     dcv.updt_task, dcv.updt_dt_tm, dcv.updt_applctx
     FROM dm_adm_code_set_extension dcv
     WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
      AND (dcv.code_set=list->qual[cnt].code_set)
      AND dcv.delete_ind=0
     DETAIL
      "free set dmrequest go", row + 1, "free set reqinfo go",
      row + 1, "set trace symbol go", row + 1,
      "record dmrequest", row + 1, "(",
      row + 1, "1 field_name = c32", row + 1,
      "1 code_set = f8", row + 1, "1 field_seq = i4",
      row + 1, "1 field_type = i2", row + 1,
      "1 field_len = i4", row + 1, "1 field_prompt = c50",
      row + 1, "1 field_default = c50", row + 1,
      "1 field_help = c100", row + 1, "1 field_in_mask = c50",
      row + 1, "1 field_out_mask = c50", row + 1,
      "1 validation_condition = c100", row + 1, "1 validation_code_set = i4",
      row + 1, "1 action_field = c50", row + 1,
      "1 UPDT_DT_TM = dq8", row + 1, "1 UPDT_ID = f8",
      row + 1, "1 UPDT_CNT = i4", row + 1,
      "1 UPDT_APPLCTX = i4", row + 1, "1 UPDT_TASK = f8",
      row + 1, ")", row + 1,
      "go", row + 1, "record reqinfo",
      row + 1, "( 1 commit_ind  = i2", row + 1,
      "1 updt_id     = f8", row + 1, "1 position_cd = f8",
      row + 1, "1 updt_app    = i4", row + 1,
      "1 updt_task   = i4", row + 1, "1 updt_req    = i4",
      row + 1, "1 updt_applctx= i4", row + 1,
      ") go", row + 1, "set dmrequest->code_set = ",
      dcv.code_set, " go", row + 1,
      "set dmrequest->field_name =  ", tempstr = build('"',replace(dcv.field_name,'"',"'",0),'" go'),
      tempstr,
      row + 1, tempstr = "set dmrequest->field_default = ", tempstr,
      row + 1, tempstr = build('"',replace(dcv.field_default,'"',"'",0),'" go'), tempstr,
      row + 1, tempstr = "set dmrequest->field_prompt = ", tempstr,
      row + 1, tempstr = build('"',replace(dcv.field_prompt,'"',"'",0),'" go'), tempstr,
      row + 1, tempstr = "set dmrequest->field_help =  ", tempstr,
      row + 1, tempstr = build('"',replace(dcv.field_help,'"',"'",0),'" go'), tempstr,
      row + 1, "set dmrequest->field_seq =  ", dcv.field_seq,
      " go", row + 1, "set dmrequest->field_type =  ",
      dcv.field_type, " go", row + 1,
      "set dmrequest->field_len =  ", dcv.field_len, " go",
      row + 1, tempstr = "set dmrequest->field_in_mask =  ", tempstr,
      row + 1, tempstr = build('"',replace(dcv.field_in_mask,'"',"'",0),'" go'), tempstr,
      row + 1, tempstr = "set dmrequest->field_out_mask =  ", tempstr,
      row + 1, tempstr = build('"',replace(dcv.field_out_mask,'"',"'",0),'" go'), tempstr,
      row + 1, tempstr = "set dmrequest->validation_condition =  ", tempstr,
      row + 1, tempstr = build('"',replace(dcv.validation_condition,'"',"'",0),'" go'), tempstr,
      row + 1, "set dmrequest->validation_code_set =", dcv.validation_code_set,
      " go", row + 1, "set dmrequest->updt_dt_tm =  ",
      dcv.updt_dt_tm, " go", row + 1,
      "set dmrequest->updt_id =  ", dcv.updt_id, " go",
      row + 1, "set dmrequest->updt_cnt =  ", dcv.updt_cnt,
      " go", row + 1, "set dmrequest->updt_task =  ",
      dcv.updt_task, " go", row + 1,
      "set dmrequest->updt_applctx =  ", dcv.updt_applctx, " go",
      row + 1, "set reqinfo->updt_id = 13224 go", row + 1,
      "set reqinfo->updt_task = 13224 go", row + 1, "set reqinfo->updt_applctx = 13224 go",
      row + 1, "execute dm_code_set_extension go", row + 1,
      row + 1
     FOOT REPORT
      tempstr = fillstring(132," "), tempstr =
      "delete from code_set_extension cse where cse.code_set = ", tempstr,
      row + 1, tempstr = build(list->qual[cnt].code_set," and"), tempstr,
      row + 1, tempstr = "cse.field_name = (select c.field_name ", tempstr,
      row + 1, tempstr = " from dm_adm_code_set_extension c where c.code_set = ", tempstr,
      row + 1, tempstr = build(list->qual[cnt].code_set," and "), tempstr,
      row + 1, tempstr = build("c.schema_date = cnvtdatetime(",r1->rdate,")"), tempstr,
      row + 1, tempstr = " and c.delete_ind = 1)", tempstr,
      row + 1, tempstr = " with nocounter go", tempstr,
      row + 1
     WITH nocounter, maxrow = 1, maxcol = 512,
      format = variable, formfeed = none, append
    ;end select
  ENDFOR
 ELSE
  FREE SET r1
  RECORD r1(
    1 rdate = dq8
  )
  SET r1->rdate = 0
  SELECT INTO "NL:"
   dcf.schema_date
   FROM dm_code_set_extension dcf
   WHERE dcf.code_set > 0
   DETAIL
    IF ((dcf.schema_date > r1->rdate))
     r1->rdate = dcf.schema_date
    ENDIF
   WITH nocounter
  ;end select
  FREE SET list
  RECORD list(
    1 qual[*]
      2 code_set = f8
    1 count = i4
  )
  SET list->count = 0
  SET stat = alterlist(list->qual,10)
  SELECT DISTINCT INTO "nl:"
   dm.code_set
   FROM dm_code_set_extension dm
   WHERE datetimediff(dm.schema_date,cnvtdatetime(r1->rdate))=0
   ORDER BY dm.code_set
   DETAIL
    list->count = (list->count+ 1)
    IF (mod(list->count,10)=1)
     stat = alterlist(list->qual,(list->count+ 9))
    ENDIF
    list->qual[list->count].code_set = dm.code_set
   WITH nocounter
  ;end select
  SET cnt = 0
  FOR (cnt = 1 TO list->count)
   SET tempstr = fillstring(255," ")
   SELECT INTO dm_starter_cs_extension_mpd
    dcv.code_set, dcv.field_name, dcv.field_seq,
    dcv.field_type, dcv.field_len, dcv.field_prompt,
    dcv.field_default, dcv.field_help
    FROM dm_code_set_extension dcv
    WHERE (dcv.code_set=list->qual[cnt].code_set)
     AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
    DETAIL
     "free set dmrequest go", row + 1, "free set reqinfo go",
     row + 1, "set trace symbol go", row + 1,
     "record dmrequest", row + 1, "(",
     row + 1, "1 field_name = c32", row + 1,
     "1 code_set = f8", row + 1, "1 field_seq = i4",
     row + 1, "1 field_type = i2", row + 1,
     "1 field_len = i4", row + 1, "1 field_prompt = c50",
     row + 1, "1 field_default = c50", row + 1,
     "1 field_help = c100", row + 1, ")",
     row + 1, "go", row + 1,
     "record reqinfo", row + 1, "( 1 commit_ind  = i2",
     row + 1, "1 updt_id     = f8", row + 1,
     "1 position_cd = f8", row + 1, "1 updt_app    = i4",
     row + 1, "1 updt_task   = i4", row + 1,
     "1 updt_req    = i4", row + 1, "1 updt_applctx= i4",
     row + 1, ") go", row + 1,
     "set dmrequest->code_set = ", dcv.code_set, " go",
     row + 1, "set dmrequest->field_name =  ", tempstr = build('"',replace(dcv.field_name,'"',"'",0),
      '" go'),
     tempstr, row + 1, tempstr = "set dmrequest->field_default = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.field_default,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->field_prompt = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.field_prompt,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->field_help =  ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.field_help,'"',"'",0),'" go'),
     tempstr, row + 1, "set dmrequest->field_seq =  ",
     dcv.field_seq, " go", row + 1,
     "set dmrequest->field_type =  ", dcv.field_type, " go",
     row + 1, "set dmrequest->field_len =  ", dcv.field_len,
     " go", row + 1, "set reqinfo->updt_id = 13224 go",
     row + 1, "set reqinfo->updt_task = 13224 go", row + 1,
     "set reqinfo->updt_applctx = 13224 go", row + 1, "execute dm_code_set_extension go",
     row + 1, row + 1
    WITH nocounter, maxrow = 1, maxcol = 512,
     format = variable, formfeed = none, append
   ;end select
  ENDFOR
 ENDIF
 COMMIT
END GO
