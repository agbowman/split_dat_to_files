CREATE PROGRAM dm_starter_cdf_mpd:dba
 SELECT INTO dm_starter_cdf_mpd
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
    SELECT INTO dm_starter_cdf_mpd
     dcv.code_set, dcv.cdf_meaning, dcv.display,
     dcv.definition, dcv.updt_applctx, dcv.updt_dt_tm,
     dcv.updt_id, dcv.updt_cnt, dcv.updt_task
     FROM dm_adm_common_data_foundation dcv
     WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
      AND (dcv.code_set=list->qual[cnt].code_set)
      AND dcv.delete_ind=0
     DETAIL
      "free set dmrequest go", row + 1, "free set reqinfo go",
      row + 1, "set trace symbol go", row + 1,
      "record dmrequest", row + 1, "(",
      row + 1, "1 code_set = i4", row + 1,
      "1 cdf_meaning = c12", row + 1, "1 display = c40",
      row + 1, "1 definition = vc", row + 1,
      "1 updt_applctx = i4", row + 1, "1 updt_dt_tm = dq8",
      row + 1, "1 updt_id = f8", row + 1,
      "1 updt_cnt = i4", row + 1, "1 updt_task = i4",
      row + 1, ")", row + 1,
      "go", row + 1, "record reqinfo",
      row + 1, "( 1 commit_ind  = i2", row + 1,
      "1 updt_id     = f8", row + 1, "1 position_cd = f8",
      row + 1, "1 updt_app    = i4", row + 1,
      "1 updt_task   = i4", row + 1, "1 updt_req    = i4",
      row + 1, "1 updt_applctx= i4", row + 1,
      ") go", row + 1, "set dmrequest->code_set = ",
      dcv.code_set, " go", row + 1,
      tempstr = "set dmrequest->display = ", tempstr, row + 1,
      tempstr = build('"',replace(dcv.display,'"',"'",0),'" go'), tempstr, row + 1,
      tempstr = "set dmrequest->cdf_meaning = ", tempstr, row + 1,
      tempstr = build('"',replace(dcv.cdf_meaning,'"',"'",0),'" go'), tempstr, row + 1,
      tempstr = "set dmrequest->definition = ", tempstr, row + 1,
      tempstr = build('"',replace(dcv.definition,'"',"'",0),'" go'), tempstr, row + 1,
      "set dmrequest->updt_applctx = ", dcv.updt_applctx, " go",
      row + 1, "set dmrequest->updt_dt_tm = ", dcv.updt_dt_tm,
      " go", row + 1, "set dmrequest->updt_id = ",
      dcv.updt_id, " go", row + 1,
      "set dmrequest->updt_cnt = ", dcv.updt_cnt, " go",
      row + 1, "set dmrequest->updt_task = ", dcv.updt_task,
      " go", row + 1, "set reqinfo->updt_id = 13224 go",
      row + 1, "set reqinfo->updt_task = 13224 go", row + 1,
      "set reqinfo->updt_applctx = 13224 go", row + 1, "execute dm_common_data_foundation go",
      row + 1, row + 1
     FOOT REPORT
      tempstr = fillstring(132," "), tempstr =
      " delete from common_data_foundation cdf where cdf.code_set = ", tempstr,
      row + 1, tempstr = build(list->qual[cnt].code_set," and"), tempstr,
      row + 1, tempstr = " cdf.cdf_meaning = (select c.cdf_meaning ", tempstr,
      row + 1, tempstr = " from dm_adm_common_data_foundation c where c.code_set = ", tempstr,
      row + 1, tempstr = build(list->qual[cnt].code_set," and "), tempstr,
      row + 1, tempstr = build(" c.schema_date = cnvtdatetime(",r1->rdate,")"), tempstr,
      row + 1, tempstr = " and  c.delete_ind = 1)", tempstr,
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
   FROM dm_common_data_foundation dcf
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
   FROM dm_common_data_foundation dm
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
   SELECT INTO dm_starter_cdf_mpd
    dcv.code_set, dcv.cdf_meaning, dcv.display,
    dcv.definition
    FROM dm_common_data_foundation dcv
    WHERE (dcv.code_set=list->qual[cnt].code_set)
     AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
    DETAIL
     "free set dmrequest go", row + 1, "free set reqinfo go",
     row + 1, "set trace symbol go", row + 1,
     "record dmrequest", row + 1, "(",
     row + 1, "1 code_set = i4", row + 1,
     "1 display = c40", row + 1, "1 cdf_meaning = c12",
     row + 1, "1 definition = vc", row + 1,
     ")", row + 1, "go",
     row + 1, "record reqinfo", row + 1,
     "( 1 commit_ind  = i2", row + 1, "1 updt_id     = f8",
     row + 1, "1 position_cd = f8", row + 1,
     "1 updt_app    = i4", row + 1, "1 updt_task   = i4",
     row + 1, "1 updt_req    = i4", row + 1,
     "1 updt_applctx= i4", row + 1, ") go",
     row + 1, "set dmrequest->code_set = ", dcv.code_set,
     " go", row + 1, tempstr = "set dmrequest->display = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.display,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->cdf_meaning = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.cdf_meaning,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->definition = ",
     tempstr, row + 1, tempstr = build('"',replace(dcv.definition,'"',"'",0),'" go'),
     tempstr, row + 1, "set reqinfo->updt_id = 13224 go",
     row + 1, "set reqinfo->updt_task = 13224 go", row + 1,
     "set reqinfo->updt_applctx = 13224 go", row + 1, "execute dm_common_data_foundation go",
     row + 1, row + 1
    WITH nocounter, maxrow = 1, maxcol = 512,
     format = variable, formfeed = none, append
   ;end select
  ENDFOR
 ENDIF
 COMMIT
END GO
