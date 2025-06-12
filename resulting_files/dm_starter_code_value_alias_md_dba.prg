CREATE PROGRAM dm_starter_code_value_alias_md:dba
 SELECT INTO dm_starter_code_value_alias_md
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
    SELECT INTO dm_starter_code_value_alias_md
     dcv.code_set, dcv.schema_date, dcv.code_value,
     dcv.alias, dcv.contributor_source_cd, dcv.alias_type_meaning,
     dcv.primary_ind, dcv.updt_dt_tm, dcv.updt_id,
     dcv.updt_task, dcv.updt_cnt, dcv.updt_applctx,
     dc.cdf_meaning, dc.display, dc.active_ind,
     dca.display
     FROM dm_adm_code_value_alias dcv,
      dm_adm_code_value dc,
      dm_adm_code_value dca
     WHERE (dcv.code_set=list->qual[cnt].code_set)
      AND dc.code_value=dcv.code_value
      AND dca.code_value=dcv.contributor_source_cd
      AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
      AND dcv.delete_ind=0
      AND dcv.schema_date=dc.schema_date
      AND dcv.schema_date=dca.schema_date
     DETAIL
      "free set dmrequest go", row + 1, "free set reqinfo go",
      row + 1, "set trace symbol go", row + 1,
      "record dmrequest", row + 1, "(",
      row + 1, "1 alias = vc", row + 1,
      "1 schema_date = dq8", row + 1, "1 code_set = i4",
      row + 1, "1 display = vc", row + 1,
      "1 cdf_meaning = c12", row + 1, "1 active_ind = i2",
      row + 1, "1 alias_type_meaning = vc", row + 1,
      "1 contributor_source_disp = vc", row + 1, "1 contributor_source_cd = i2",
      row + 1, "1 PRIMARY_IND = I2", row + 1,
      "1 UPDT_DT_TM  =  DQ8", row + 1, "1 UPDT_ID =  F8",
      row + 1, "1 UPDT_TASK = I4", row + 1,
      "1 UPDT_CNT = I4", row + 1, "1 UPDT_APPLCTX = i4",
      row + 1, ")", row + 1,
      "go", row + 1, "record reqinfo",
      row + 1, "( 1 commit_ind  = i2", row + 1,
      "1 updt_id     = f8", row + 1, "1 position_cd = f8",
      row + 1, "1 updt_app    = i4", row + 1,
      "1 updt_task   = i4", row + 1, "1 updt_req    = i4",
      row + 1, "1 updt_applctx= i4", row + 1,
      ") go", row + 1, "set dmrequest->code_set = ",
      dcv.code_set, " go", row + 1,
      tempstr = build('set dmrequest->schema_date = cnvtdatetime("',dcv.schema_date,'") go'), tempstr,
      row + 1,
      tempstr = "set dmrequest->alias =  ", tempstr, row + 1,
      tempstr = build('"',replace(dcv.alias,'"',"'",0),'" go'), tempstr, row + 1,
      tempstr = "set dmrequest->alias_type_meaning = ", tempstr, row + 1,
      tempstr = build('"',replace(dcv.alias_type_meaning,'"',"'",0),'" go'), tempstr, row + 1,
      tempstr = "set dmrequest->contributor_source_disp = ", tempstr, row + 1,
      tempstr = build('"',replace(dca.display,'"',"'",0),'" go'), tempstr, row + 1,
      tempstr = "set dmrequest->display =  ", tempstr, row + 1,
      tempstr = build('"',replace(dc.display,'"',"'",0),'" go'), tempstr, row + 1,
      tempstr = "set dmrequest->cdf_meaning =  ", tempstr, row + 1,
      tempstr = build('"',replace(dc.cdf_meaning,'"',"'",0),'" go'), tempstr, row + 1,
      "set dmrequest->active_ind =  ", dc.active_ind, " go",
      row + 1, "set dmrequest->primary_ind =  ", dcv.primary_ind,
      " go", row + 1, "set reqinfo->updt_id = 13224 go",
      row + 1, "set reqinfo->updt_task = 13224 go", row + 1,
      "set reqinfo->updt_applctx = 13224 go", row + 1, "execute dm_code_value_alias go",
      row + 1, row + 1
     FOOT REPORT
      "execute dm_delete_cva go", row + 1, row + 1
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
   FROM dm_code_value_alias dcf
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
   FROM dm_code_value_alias dm
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
   SELECT INTO dm_starter_code_value_alias_md
    dcv.code_set, dcv.code_value, dcv.alias,
    dcv.contributor_source_cd, dcv.alias_type_meaning, dc.cdf_meaning,
    dc.display, dc.active_ind, dca.display
    FROM dm_code_value_alias dcv,
     dm_code_value dc,
     dm_code_value dca
    WHERE (dcv.code_set=list->qual[cnt].code_set)
     AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
     AND dc.code_value=dcv.code_value
     AND dca.code_value=dcv.contributor_source_cd
    DETAIL
     "free set dmrequest go", row + 1, "free set reqinfo go",
     row + 1, "set trace symbol go", row + 1,
     "record dmrequest", row + 1, "(",
     row + 1, "1 alias = vc", row + 1,
     "1 code_set = i4", row + 1, "1 display = vc",
     row + 1, "1 cdf_meaning = c12", row + 1,
     "1 active_ind = i2", row + 1, "1 alias_type_meaning = vc",
     row + 1, "1 contributor_source_disp = vc", row + 1,
     ")", row + 1, "go",
     row + 1, "record reqinfo", row + 1,
     "( 1 commit_ind  = i2", row + 1, "1 updt_id     = f8",
     row + 1, "1 position_cd = f8", row + 1,
     "1 updt_app    = i4", row + 1, "1 updt_task   = i4",
     row + 1, "1 updt_req    = i4", row + 1,
     "1 updt_applctx= i4", row + 1, ") go",
     row + 1, "set dmrequest->code_set = ", dcv.code_set,
     " go", row + 1, tempstr = "set dmrequest->alias ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.alias,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->alias_type_meaning = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.alias_type_meaning,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->contributor_source_disp = ",
     tempstr, row + 1, tempstr = build('"',replace(dca.display,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->display =  ",
     tempstr, row + 1, tempstr = build('"',replace(dc.display,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->cdf_meaning =  ",
     tempstr, row + 1, tempstr = build('"',replace(dc.cdf_meaning,'"',"'",0),'" go'),
     tempstr, row + 1, "set dmrequest->active_ind =  ",
     dc.active_ind, " go", row + 1,
     "set reqinfo->updt_id = 13224 go", row + 1, "set reqinfo->updt_task = 13224 go",
     row + 1, "set reqinfo->updt_applctx = 13224 go", row + 1,
     "execute dm_code_value_alias go", row + 1, row + 1
    WITH nocounter, maxrow = 1, maxcol = 512,
     format = variable, formfeed = none, append
   ;end select
  ENDFOR
 ENDIF
 COMMIT
END GO
