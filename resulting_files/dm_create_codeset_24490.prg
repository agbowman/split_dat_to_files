CREATE PROGRAM dm_create_codeset_24490
 RECORD pers(
   1 pers_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 code_value = f8
     2 pk_column_name = vc
     2 column_cnt = i4
     2 qual[*]
       3 column_name = vc
       3 constraint_name = vc
 )
 SET pers->pers_cnt = 0
 RECORD request(
   1 code_set = i4
   1 qual_cnt = i4
   1 qual[*]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_ind = i2
     2 authentic_ind = i2
     2 updt_cnt = i4
     2 cki = vc
 )
 SET request->code_set = 24490
 SET request->qual_cnt = 0
 SELECT INTO "nl:"
  FROM user_cons_columns ucc2,
   user_constraints uc2,
   user_cons_columns ucc,
   user_constraints uc
  WHERE uc.constraint_name=ucc.constraint_name
   AND uc.constraint_type="R"
   AND uc.r_constraint_name="XPKENCOUNTER"
   AND uc.table_name=uc2.table_name
   AND uc2.constraint_name=ucc2.constraint_name
   AND uc2.constraint_type="P"
   AND ucc2.position=1
  ORDER BY uc.table_name
  HEAD uc.table_name
   pers->pers_cnt = (pers->pers_cnt+ 1), stat = alterlist(pers->qual,pers->pers_cnt), pers->qual[pers
   ->pers_cnt].table_name = uc.table_name,
   pers->qual[pers->pers_cnt].column_cnt = 0, pers->qual[pers->pers_cnt].pk_column_name = ucc2
   .column_name, request->qual_cnt = (request->qual_cnt+ 1),
   stat = alterlist(request->qual,request->qual_cnt), request->qual[request->qual_cnt].display = uc
   .table_name, request->qual[request->qual_cnt].display_key = uc.table_name,
   request->qual[request->qual_cnt].description = concat(uc.table_name," is a child of encounter."),
   request->qual[request->qual_cnt].definition = concat(uc.table_name," is a child of encounter."),
   request->qual[request->qual_cnt].collation_seq = 1,
   request->qual[request->qual_cnt].active_ind = 1, request->qual[request->qual_cnt].authentic_ind =
   1, request->qual[request->qual_cnt].updt_cnt = 0
  DETAIL
   pers->qual[pers->pers_cnt].column_cnt = (pers->qual[pers->pers_cnt].column_cnt+ 1), ccnt = pers->
   qual[pers->pers_cnt].column_cnt, stat = alterlist(pers->qual[pers->pers_cnt].qual,ccnt),
   pers->qual[pers->pers_cnt].qual[ccnt].constraint_name = uc.constraint_name, pers->qual[pers->
   pers_cnt].qual[ccnt].column_name = ucc.column_name
  WITH nocounter
 ;end select
 EXECUTE dm_ins_upd_code_value
 SELECT INTO "nl:"
  FROM code_value cv,
   (dummyt d  WITH seq = value(pers->pers_cnt))
  PLAN (d)
   JOIN (cv
   WHERE (pers->qual[d.seq].table_name=cv.display)
    AND cnvtalphanum(pers->qual[d.seq].table_name)=cv.display_key
    AND cv.code_set=24490)
  DETAIL
   pers->qual[d.seq].code_value = cv.code_value
  WITH nocounter
 ;end select
 FOR (i = 1 TO pers->pers_cnt)
   FOR (j = 1 TO pers->qual[i].column_cnt)
    INSERT  FROM code_value_extension cve
     SET cve.code_value = pers->qual[i].code_value, cve.code_set = 24490, cve.field_name = pers->
      qual[i].qual[j].column_name,
      cve.field_type = 0, cve.field_value = " ", cve.updt_applctx = 0,
      cve.updt_cnt = 0, cve.updt_id = 0, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      cve.updt_task = 0
     WITH nocounter
    ;end insert
    COMMIT
   ENDFOR
 ENDFOR
 FOR (i = 1 TO pers->pers_cnt)
  INSERT  FROM code_value_extension cve
   SET cve.code_value = pers->qual[i].code_value, cve.code_set = 24490, cve.field_name = pers->qual[i
    ].pk_column_name,
    cve.field_type = 1, cve.field_value = " ", cve.updt_applctx = 0,
    cve.updt_cnt = 0, cve.updt_id = 0, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cve.updt_task = 0
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
END GO
