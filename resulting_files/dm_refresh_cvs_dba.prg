CREATE PROGRAM dm_refresh_cvs:dba
 SELECT INTO dm_refresh_cvs
  d.*
  FROM dual d
  DETAIL
   "set trace noreflog go", row + 1, "set trace symbol mark go",
   row + 1
  WITH nocounter, maxrow = 1, maxcol = 1024,
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
  FROM dm_code_value_set dm
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
  SELECT INTO dm_refresh_cvs
   dcv.code_set, dcv.display, dcv.description,
   dcv.definition, dcv.table_name, dcv.cache_ind,
   dcv.add_access_ind, dcv.chg_access_ind, dcv.del_access_ind,
   dcv.inq_access_ind, dcv.domain_qualifier_ind, dcv.domain_code_set,
   dcv.def_dup_rule_flag, dcv.cdf_meaning_dup_ind, dcv.display_key_dup_ind,
   dcv.active_ind_dup_ind, dcv.display_dup_ind, dcv.alias_dup_ind
   FROM dm_code_value_set dcv
   WHERE (dcv.code_set=list->qual[cnt].code_set)
    AND datetimediff(dcv.schema_date,cnvtdatetime(r1->rdate))=0
   DETAIL
    "free set dmrequest go", row + 1, "set trace symbol go",
    row + 1, "record dmrequest", row + 1,
    "(", row + 1, "1 code_set = i4",
    row + 1, "1 display = c40", row + 1,
    "1 description = vc", row + 1, "1 definition = vc",
    row + 1, "1 table_name = c32", row + 1,
    "1 cache_ind = i2", row + 1, "1 add_access_ind = i2",
    row + 1, "1 chg_access_ind = i2", row + 1,
    "1 del_access_ind = i2", row + 1, "1 inq_access_ind = i2",
    row + 1, "1 domain_qualifier_ind = i2", row + 1,
    "1 domain_code_set = i4", row + 1, "1 add_code_value_ind = i2",
    row + 1, "1 add_code_value_default = i4", row + 1,
    "1 def_dup_rule_flag = i2", row + 1, "1 cdf_meaning_dup_ind = i2",
    row + 1, "1 display_key_dup_ind = i2", row + 1,
    "1 active_ind_dup_ind = i2", row + 1, "1 display_dup_ind = i2",
    row + 1, "1 alias_dup_ind = i2", row + 1,
    ")", row + 1, "go",
    row + 1, 'set def1 = fillstring(85, " ") go', row + 1,
    'set def2 = fillstring(85, " ") go', row + 1, 'set def3 = fillstring(85, " ") go',
    row + 1, "set dmrequest->code_set = ", dcv.code_set,
    " go", row + 1, tempstr = "set dmrequest->display =  ",
    tempstr, row + 1, tempstr = build('"',replace(dcv.display,'"',"'",0),'" go'),
    tempstr, row + 1, tempstr = "set dmrequest->description = ",
    tempstr, row + 1, tempstr = build('"',replace(dcv.description,'"',"'",0),'" go'),
    tempstr, row + 1, tempstr = build("set def1 =",'"'),
    tempstr = build(tempstr,substring(1,85,dcv.definition)), tempstr = build(tempstr,'" go'), tempstr,
    row + 1, tempstr = build("set def2 = ",'"'), tempstr = build(tempstr,substring(86,85,dcv
      .definition)),
    tempstr = build(tempstr,'" go'), tempstr, row + 1,
    tempstr = build("set def3 = ",'"'), tempstr = build(tempstr,substring(171,85,dcv.definition)),
    tempstr = build(tempstr,'" go'),
    tempstr, row + 1, tempstr = "set dmrequest->definition = ",
    tempstr, row + 1, tempstr = "trim(concat(def1,def2,def3))",
    tempstr = build(tempstr," go"), tempstr, row + 1,
    tempstr = "set dmrequest->table_name =  ", tempstr, row + 1,
    tempstr = build('"',replace(dcv.table_name,'"',"'",0),'" go'), tempstr, row + 1,
    "set dmrequest->cache_ind =  ", dcv.cache_ind, " go",
    row + 1, "set dmrequest->add_access_ind =  ", dcv.add_access_ind,
    " go", row + 1, "set dmrequest->chg_access_ind =  ",
    dcv.chg_access_ind, " go", row + 1,
    "set dmrequest->del_access_ind =  ", dcv.del_access_ind, " go",
    row + 1, "set dmrequest->inq_access_ind =  ", dcv.inq_access_ind,
    " go", row + 1, "set dmrequest->domain_qualifier_ind =  ",
    dcv.domain_qualifier_ind, " go", row + 1,
    "set dmrequest->domain_code_set =  ", dcv.domain_code_set, " go",
    row + 1, "set dmrequest->def_dup_rule_flag =  ", dcv.def_dup_rule_flag,
    " go", row + 1, "set dmrequest->cdf_meaning_dup_ind =  ",
    dcv.cdf_meaning_dup_ind, " go", row + 1,
    "set dmrequest->display_key_dup_ind =  ", dcv.display_key_dup_ind, " go",
    row + 1, "set dmrequest->active_ind_dup_ind =  ", dcv.active_ind_dup_ind,
    " go", row + 1, "set dmrequest->display_dup_ind =  ",
    dcv.display_dup_ind, " go", row + 1,
    "set dmrequest->alias_dup_ind =  ", dcv.alias_dup_ind, " go",
    row + 1, "set reqinfo->updt_id = 111 go", row + 1,
    "set reqinfo->updt_task = 111 go", row + 1, "set reqinfo->updt_applctx = 111 go",
    row + 1, "execute dm_code_value_set go", row + 1,
    row + 1
   WITH nocounter, maxrow = 1, maxcol = 1024,
    formfeed = none, append
  ;end select
 ENDFOR
 COMMIT
END GO
