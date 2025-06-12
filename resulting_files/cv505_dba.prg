CREATE PROGRAM cv505:dba
 SELECT INTO dm_starter_cv_extension
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
  SET ref_status = "2b"
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
    AND dm.code_set=505
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
  SET tempstr = fillstring(255," ")
  FREE SET r1
  RECORD r1(
    1 rdate = dq8
  )
  SET r1->rdate = 0
  SELECT INTO "NL:"
   dcf.schema_dt_tm
   FROM dm_feature_code_sets_env dcf
   WHERE dcf.code_set=505
    AND dcf.environment=env
    AND (dcf.feature_number=
   (SELECT
    dm.feature_number
    FROM dm_features dm
    WHERE dm.feature_status >= ref_status
     AND ((dm.feature_status != "2f") OR (dm.feature_status != "3f")) ))
   DETAIL
    IF ((dcf.schema_dt_tm > r1->rdate))
     r1->rdate = dcf.schema_dt_tm
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO dm_starter_cv_extension
   dcv.code_set, dcv.schema_date, dcv.code_value,
   dcv.field_name, dcv.field_type, dcv.field_value,
   dcv.updt_id, dcv.updt_cnt, dcv.updt_task,
   dcv.updt_dt_tm, dcv.updt_applctx, dc.display,
   dc.cdf_meaning, dc.cki, dc.active_ind
   FROM dm_adm_code_value_extension dcv,
    dm_adm_code_value dc
   WHERE datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
    AND dcv.code_set=505
    AND dcv.delete_ind=0
    AND dc.code_value=dcv.code_value
    AND dcv.schema_date=dc.schema_date
   DETAIL
    "free set dmrequest go", row + 1, "free set reqinfo go",
    row + 1, "set trace symbol go", row + 1,
    "record dmrequest", row + 1, "(",
    row + 1, "1 field_name = c32", row + 1,
    "1 code_set = i4", row + 1, "1 schema_date = dq8",
    row + 1, "1 code_value = f8", row + 1,
    "1 display=vc", row + 1, "1 cdf_meaning = c12",
    row + 1, "1 active_ind = i2", row + 1,
    "1 field_type = i4", row + 1, "1 field_value = c100",
    row + 1, "1 cki = vc", row + 1,
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
    tempstr = build('set dmrequest->schema_date = cnvtdatetime("',dcv.schema_date,'") go'), tempstr,
    row + 1,
    tempstr = build('set dmrequest->cki = "',dc.cki,'" go'), tempstr, row + 1,
    tempstr = "set dmrequest->field_name =  ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.field_name,'"',"'",0),'" go'), tempstr, row + 1,
    tempstr = "set dmrequest->field_value = ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.field_value,'"',"'",0),'" go'), tempstr, row + 1,
    "set dmrequest->field_type =  ", dcv.field_type, " go",
    row + 1, tempstr = "set dmrequest->display =  ", tempstr,
    row + 1, tempstr = build('"',replace(dc.display,'"',"'",0),'" go'), tempstr,
    row + 1, tempstr = "set dmrequest->cdf_meaning =  ", tempstr,
    row + 1, tempstr = build('"',replace(dc.cdf_meaning,'"',"'",0),'" go'), tempstr,
    row + 1, "set dmrequest->active_ind =  ", dc.active_ind,
    " go", row + 1, "set reqinfo->updt_id = 13224 go",
    row + 1, "set reqinfo->updt_task = 13224 go", row + 1,
    "set reqinfo->updt_applctx = 13224 go", row + 1, "execute dm_code_value_extension go",
    row + 1, row + 1
   FOOT REPORT
    "execute dm_delete_cve go", row + 1, row + 1
   WITH nocounter, maxrow = 1, maxcol = 512,
    format = variable, formfeed = none, append
  ;end select
  SET cnt = 0
 ELSE
  FREE SET r1
  RECORD r1(
    1 rdate = dq8
  )
  SET r1->rdate = 0
  SELECT DISTINCT INTO "NL:"
   dcf.schema_date
   FROM dm_adm_code_value_extension dcf
   WHERE dcf.code_set=505
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
   FROM dm_adm_code_value_extension dm
   WHERE datetimediff(dm.schema_date,cnvtdatetime(r1->rdate))=0
    AND dm.code_set=505
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
   SELECT INTO dm_starter_cv_extension
    dcv.code_set, dcv.code_value, dcv.field_name,
    dcv.field_type, dcv.field_value, dc.display,
    dc.cdf_meaning, dc.cki, dc.active_ind
    FROM dm_adm_code_value_extension dcv,
     dm_adm_code_value dc
    WHERE (dcv.code_set=list->qual[cnt].code_set)
     AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
     AND dc.code_value=dcv.code_value
    DETAIL
     "free set dmrequest go", row + 1, "free set reqinfo go",
     row + 1, "set trace symbol go", row + 1,
     "record dmrequest", row + 1, "(",
     row + 1, "1 field_name = c32", row + 1,
     "1 code_set = i4", row + 1, "1 display=vc",
     row + 1, "1 cdf_meaning = c12", row + 1,
     "1 active_ind = i2", row + 1, "1 cki = vc",
     row + 1, "1 field_type = i4", row + 1,
     "1 field_value = c100", row + 1, ")",
     row + 1, "go", row + 1,
     "record reqinfo", row + 1, "( 1 commit_ind  = i2",
     row + 1, "1 updt_id     = f8", row + 1,
     "1 position_cd = f8", row + 1, "1 updt_app    = i4",
     row + 1, "1 updt_task   = i4", row + 1,
     "1 updt_req    = i4", row + 1, "1 updt_applctx= i4",
     row + 1, ") go", row + 1,
     "set dmrequest->code_set = ", dcv.code_set, " go",
     row + 1, tempstr = build('set dmrequest->cki = "',dc.cki,'" go'), tempstr,
     row + 1, tempstr = "set dmrequest->field_name =  ", tempstr,
     row + 1, tempstr = build('"',replace(dcv.field_name,'"',"'",0),'" go'), tempstr,
     row + 1, tempstr = "set dmrequest->field_value = ", tempstr,
     row + 1, tempstr = build('"',replace(dcv.field_value,'"',"'",0),'" go'), tempstr,
     row + 1, "set dmrequest->field_type =  ", dcv.field_type,
     " go", row + 1, tempstr = "set dmrequest->display =  ",
     tempstr, row + 1, tempstr = build('"',replace(dc.display,'"',"'",0),'" go'),
     tempstr, row + 1, tempstr = "set dmrequest->cdf_meaning ",
     tempstr, row + 1, tempstr = build('"',replace(dc.cdf_meaning,'"',"'",0),'" go'),
     tempstr, row + 1, "set dmrequest->active_ind =  ",
     dc.active_ind, " go", row + 1,
     "set reqinfo->updt_id = 111 go", row + 1, "set reqinfo->updt_task = 111 go",
     row + 1, "set reqinfo->updt_applctx = 111 go", row + 1,
     "execute dm_code_value_extension go", row + 1, row + 1
    WITH nocounter, maxrow = 1, maxcol = 512,
     format = variable, formfeed = none, append
   ;end select
  ENDFOR
 ENDIF
 COMMIT
END GO
