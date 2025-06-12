CREATE PROGRAM dm_refresh_cse:dba
 SELECT INTO dm_refresh_cse
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
  SELECT INTO dm_refresh_cse
   dcv.code_set, dcv.field_name, dcv.field_seq,
   dcv.field_type, dcv.field_len, dcv.field_prompt,
   dcv.field_default, dcv.field_help
   FROM dm_code_set_extension dcv
   WHERE (dcv.code_set=list->qual[cnt].code_set)
    AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
   DETAIL
    "free set dmrequest go", row + 1, "set trace symbol go",
    row + 1, "record dmrequest", row + 1,
    "(", row + 1, "1 field_name = c32",
    row + 1, "1 code_set = f8", row + 1,
    "1 field_seq = i4", row + 1, "1 field_type = i2",
    row + 1, "1 field_len = i4", row + 1,
    "1 field_prompt = c50", row + 1, "1 field_default = c50",
    row + 1, "1 field_help = c100", row + 1,
    ")", row + 1, "go",
    row + 1, "set dmrequest->code_set = ", dcv.code_set,
    " go", row + 1, "set dmrequest->field_name =  ",
    tempstr = build('"',replace(dcv.field_name,'"',"'",0),'" go'), tempstr, row + 1,
    tempstr = "set dmrequest->field_default = ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.field_default,'"',"'",0),'" go'), tempstr, row + 1,
    tempstr = "set dmrequest->field_prompt = ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.field_prompt,'"',"'",0),'" go'), tempstr, row + 1,
    tempstr = "set dmrequest->field_help =  ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.field_help,'"',"'",0),'" go'), tempstr, row + 1,
    "set dmrequest->field_seq =  ", dcv.field_seq, " go",
    row + 1, "set dmrequest->field_type =  ", dcv.field_type,
    " go", row + 1, "set dmrequest->field_len =  ",
    dcv.field_len, " go", row + 1,
    "set reqinfo->updt_id = 111 go", row + 1, "set reqinfo->updt_task = 111 go",
    row + 1, "set reqinfo->updt_applctx = 111 go", row + 1,
    "execute dm_code_set_extension go", row + 1, row + 1
   WITH nocounter, maxrow = 1, maxcol = 512,
    format = variable, formfeed = none, append
  ;end select
 ENDFOR
 COMMIT
END GO
