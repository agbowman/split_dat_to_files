CREATE PROGRAM dm_refresh_cdf:dba
 SELECT INTO dm_refresh_cdf
  d.*
  FROM dual d
  DETAIL
   "set trace noreflog go", row + 1, "set trace symbol mark go",
   row + 1
  WITH nocounter, maxrow = 1, maxcol = 512,
   format = variable, formfeed = none
 ;end select
 FREE SET r1
 RECORD r1(
   1 rdate = dq8
 )
 SET r1->rdate = 0
 SELECT INTO "nl:"
  c.schema_date
  FROM dm_environment b,
   dm_schema_version c
  WHERE (b.environment_id=request->setup_proc[1].env_id)
   AND b.schema_version=c.schema_version
  DETAIL
   r1->rdate = c.schema_date
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
  SELECT INTO dm_refresh_cdf
   dcv.code_set, dcv.cdf_meaning, dcv.display,
   dcv.definition
   FROM dm_common_data_foundation dcv
   WHERE (dcv.code_set=list->qual[cnt].code_set)
    AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
   DETAIL
    "free set dmrequest go", row + 1, "set trace symbol go",
    row + 1, "record dmrequest", row + 1,
    "(", row + 1, "1 code_set = i4",
    row + 1, "1 display = c40", row + 1,
    "1 cdf_meaning = c12", row + 1, "1 definition = vc",
    row + 1, ")", row + 1,
    "go", row + 1, "set dmrequest->code_set = ",
    dcv.code_set, " go", row + 1,
    tempstr = "set dmrequest->display = ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.display,'"',"'",0),'" go'), tempstr, row + 1,
    tempstr = "set dmrequest->cdf_meaning = ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.cdf_meaning,'"',"'",0),'" go'), tempstr, row + 1,
    tempstr = "set dmrequest->definition = ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.definition,'"',"'",0),'" go'), tempstr, row + 1,
    "set reqinfo->updt_id = 111 go", row + 1, "set reqinfo->updt_task = 111 go",
    row + 1, "set reqinfo->updt_applctx = 111 go", row + 1,
    "execute dm_common_data_foundation go", row + 1, row + 1
   WITH nocounter, maxrow = 1, maxcol = 512,
    format = variable, formfeed = none, append
  ;end select
 ENDFOR
 COMMIT
END GO
