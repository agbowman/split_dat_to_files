CREATE PROGRAM dm_refresh_afd_cse:dba
 SELECT INTO dm_refresh_afd_cse
  d.*
  FROM dual d
  DETAIL
   "set trace noreflog go", row + 1, "set trace symbol mark go",
   row + 1
  WITH nocounter, maxrow = 1, maxcol = 512,
   format = variable, formfeed = none
 ;end select
 SET envid = 0
 SELECT INTO "nl:"
  d.environment_id
  FROM dm_environment d
  WHERE d.environment_name=env_name
  DETAIL
   envid = d.environment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Invalid Environment Name")
  GO TO end_program
 ENDIF
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
  FROM dm_afd_code_set_extension dm,
   dm_alpha_features_env da
  WHERE (dm.alpha_feature_nbr=request->afdnumber)
   AND dm.alpha_feature_nbr=da.alpha_feature_nbr
   AND da.status != "SUCCESS"
   AND da.environment_id=envid
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
  SELECT INTO dm_refresh_afd_cse
   dcv.code_set, dcv.field_name, dcv.field_seq,
   dcv.field_type, dcv.field_len, dcv.field_prompt,
   dcv.field_default, dcv.field_help
   FROM dm_afd_code_set_extension dcv
   WHERE (dcv.code_set=list->qual[cnt].code_set)
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
    " go", row + 1, "set reqinfo->updt_id = 111 go",
    row + 1, "set reqinfo->updt_task = 111 go", row + 1,
    "set reqinfo->updt_applctx = 111 go", row + 1, "execute dm_code_set_extension go",
    row + 1, row + 1
   WITH nocounter, maxrow = 1, maxcol = 512,
    format = variable, formfeed = none, append
  ;end select
 ENDFOR
 COMMIT
#end_program
END GO
