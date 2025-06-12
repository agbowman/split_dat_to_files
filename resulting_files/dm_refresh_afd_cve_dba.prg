CREATE PROGRAM dm_refresh_afd_cve:dba
 SELECT INTO dm_refresh_afd_cve
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
  FROM dm_afd_code_value_extension dm,
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
  SELECT INTO dm_refresh_afd_cve
   dcv.code_set, dcv.code_value, dcv.field_name,
   dcv.field_type, dcv.field_value, dc.display,
   dc.cdf_meaning, dc.cki, dc.active_ind
   FROM dm_afd_code_value_extension dcv,
    dm_afd_code_value dc
   WHERE (dcv.code_set=list->qual[cnt].code_set)
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
 COMMIT
#end_program
END GO
