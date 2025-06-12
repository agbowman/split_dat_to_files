CREATE PROGRAM dm_starter_cv_16049:dba
 SELECT INTO dm_starter_code_value
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
  SET ref_status = "2d"
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
   FROM dm_feature_code_sets_env dm,
    dm_features df
   WHERE dm.feature_number=df.feature_number
    AND dm.environment=env
    AND dm.code_set=16049
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
    SELECT INTO dm_starter_code_value
     dcv.code_value, dcv.schema_date, dcv.code_set,
     dcv.cdf_meaning, dcv.display, dcv.display_key,
     dcv.definition, dcv.collation_seq, dcv.active_type_cd,
     dcv.active_ind, dcv.data_status_cd, dcv.data_status_prsnl_id,
     dcv.end_effective_dt_tm, dcv.begin_effective_dt_tm, dcv.active_status_prsnl_id
     FROM dm_adm_code_value dcv
     WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
      AND (dcv.code_set=list->qual[cnt].code_set)
      AND dcv.delete_ind=0
     DETAIL
      "free set dmrequest go", row + 1, "free set reqinfo go",
      row + 1, "set trace symbol go", row + 1,
      "record dmrequest", row + 1, "(",
      row + 1, "1 dup_rule_flag = i2", row + 1,
      "1 code_set = f8", row + 1, "1 code_value = f8",
      row + 1, "1 schema_date = dq8", row + 1,
      "1 cdf_meaning = C12", row + 1, "1 display = C40",
      row + 1, "1 display_key = C40", row + 1,
      "1 description = C60", row + 1, "1 definition = C100",
      row + 1, "1 collation_seq = i2", row + 1,
      "1 ACTIVE_TYPE_CD = f8", row + 1, "1 ACTIVE_IND = i2",
      row + 1, "1 DATA_STATUS_CD = f8", row + 1,
      "1 DATA_STATUS_DT_TM = dq8", row + 1, "1 DATA_STATUS_PRSNL_ID = f8",
      row + 1, "1 ACTIVE_STATUS_PRSNL_ID = f8", row + 1,
      ")", row + 1, "go",
      row + 1, "record reqinfo", row + 1,
      "( 1 commit_ind  = i2", row + 1, "1 updt_id     = f8",
      row + 1, "1 position_cd = f8", row + 1,
      "1 updt_app    = i4", row + 1, "1 updt_task   = i4",
      row + 1, "1 updt_req    = i4", row + 1,
      "1 updt_applctx= i4", row + 1, ") go",
      row + 1, "set dmrequest->dup_rule_flag = 0 go", row + 1,
      "set dmrequest->code_value = ", dcv.code_value, " go",
      row + 1, "set dmrequest->code_set = ", dcv.code_set,
      " go", row + 1, tempstr = build('set dmrequest->schema_date = cnvtdatetime("',dcv.schema_date,
       '") go'),
      tempstr, row + 1, tempstr = "set dmrequest->cdf_meaning = ",
      tempstr, row + 1, tempstr = build('"',replace(dcv.cdf_meaning,'"',"'",0),'" go'),
      tempstr, row + 1, tempstr = "set dmrequest->display = ",
      tempstr, row + 1, tempstr = build('"',replace(dcv.display,'"',"'",0),'" go'),
      tempstr, row + 1, tempstr = build('set dmrequest->display_key =  "',dcv.display_key,'" go'),
      tempstr, row + 1, tempstr = "set dmrequest->description = ",
      tempstr, row + 1, tempstr = build('"',replace(dcv.description,'"',"'",0),'" go'),
      tempstr, row + 1, tempstr = "set dmrequest->definition = ",
      tempstr, row + 1, tempstr = build('"',replace(dcv.definition,'"',"'",0),'" go'),
      tempstr, row + 1, "set dmrequest->collation_seq =  ",
      dcv.collation_seq, " go", row + 1,
      "set dmrequest->active_ind =  ", dcv.active_ind, " go",
      row + 1, "set dmrequest->active_type_cd =  ", dcv.active_type_cd,
      " go", row + 1, "set dmrequest->data_status_cd =  ",
      dcv.data_status_cd, " go", row + 1,
      "set dmrequest->data_status_prsnl_id =  ", dcv.data_status_prsnl_id, " go",
      row + 1, "set dmrequest->active_status_prsnl_id =  ", dcv.active_status_prsnl_id,
      " go", row + 1, "set reqinfo->updt_id = 13224 go",
      row + 1, "set reqinfo->updt_task = 13224 go", row + 1,
      "set reqinfo->updt_applctx = 13224 go", row + 1, "execute dm_insert_code_value go",
      row + 1, row + 1
     FOOT REPORT
      "execute dm_delete_code_value go", row + 1, row + 1
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
   FROM dm_code_value dcf
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
   FROM dm_code_value dm
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
   SELECT INTO dm_starter_code_value
    dcv.code_set, dcv.cdf_meaning, dcv.display,
    dcv.description, dcv.definition, dcv.collation_seq,
    dcv.active_ind
    FROM dm_code_value dcv
    WHERE (dcv.code_set=list->qual[cnt].code_set)
     AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
    DETAIL
     "free set dmrequest go", row + 1, "free set reqinfo go",
     row + 1, "set trace symbol go", row + 1,
     "record dmrequest", row + 1, "(",
     row + 1, "1 dup_rule_flag = i2   ; 1 = source is the master, 2 = target is the master, add only",
     row + 1,
     "1 code_set = f8", row + 1, "1 code_value = f8",
     row + 1, "1 cdf_meaning = C12", row + 1,
     "1 display = C40", row + 1, "1 description = C60",
     row + 1, "1 definition = C100", row + 1,
     "1 collation_seq = i2", row + 1, "1 active_ind    = i2",
     row + 1, ")", row + 1,
     "go", row + 1, "record reqinfo",
     row + 1, "( 1 commit_ind  = i2", row + 1,
     "1 updt_id     = f8", row + 1, "1 position_cd = f8",
     row + 1, "1 updt_app    = i4", row + 1,
     "1 updt_task   = i4", row + 1, "1 updt_req    = i4",
     row + 1, "1 updt_applctx= i4", row + 1,
     ") go", row + 1, "set dmrequest->dup_rule_flag = 1 go",
     row + 1, "set dmrequest->code_set = ", dcv.code_set,
     " go", row + 1, tempstr = "set dmrequest->cdf_meaning = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.cdf_meaning,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->display = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.display,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->description = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.description,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->definition = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.definition,'"',"'",0),'" go'),
     tempstr, row + 1, "set dmrequest->collation_seq =  ",
     dcv.collation_seq, " go", row + 1,
     "set dmrequest->active_ind =  ", dcv.active_ind, " go",
     row + 1, "set reqinfo->updt_id = 13224 go", row + 1,
     "set reqinfo->updt_task = 13224 go", row + 1, "set reqinfo->updt_applctx = 13224 go",
     row + 1, "execute dm_insert_code_value go", row + 1,
     row + 1
    WITH nocounter, maxrow = 1, maxcol = 512,
     format = variable, formfeed = none, append
   ;end select
  ENDFOR
 ENDIF
 COMMIT
END GO
