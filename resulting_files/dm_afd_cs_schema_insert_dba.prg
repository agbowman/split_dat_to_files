CREATE PROGRAM dm_afd_cs_schema_insert:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET cs_to_add = 0
 SET number_to_add = 0
 SET feature_num = 0
 SET desc = fillstring(50," ")
 SET reply->status_data.status = "F"
 SET afd_nbr = request->alpha_feature_nbr
 SET cid = substring(1,10,request->client_id)
 SET desc = request->description
 SET rev_nbr = request->rev_number
 SET feature_num = request->feature_num
 SET oname = build("Ocd_Schema_",cnvtstring(afd_nbr))
 SET fname = build("ccluserdir:Ocd_Schema_",cnvtstring(afd_nbr),".ccl")
 SELECT INTO "nl:"
  d.*
  FROM dm_alpha_features d
  WHERE d.alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end select
 IF (curqual=0)
  INSERT  FROM dm_alpha_features
   SET alpha_feature_nbr = afd_nbr, description = desc, create_dt_tm = cnvtdatetime(request->
     create_dt_tm),
    sponsor_client_id = cid, rev_number = rev_nbr
   WITH nocounter
  ;end insert
 ELSE
  UPDATE  FROM dm_alpha_features
   SET description = desc, create_dt_tm = cnvtdatetime(request->create_dt_tm), sponsor_client_id =
    cid,
    rev_number = rev_nbr
   WHERE alpha_feature_nbr=afd_nbr
   WITH nocounter
  ;end update
 ENDIF
 SET temp = fillstring(120," ")
 SELECT INTO value(fname)
  FROM dual
  DETAIL
   temp = build("set ocd_number = ",cnvtstring(afd_nbr)," go"), temp, row + 2,
   "set env_name = fillstring(20,' ') go", row + 2, "select into 'nl:'",
   row + 1, " de.environment_name", row + 1,
   temp = build("from DM_INFO di",","," DM_ENVIRONMENT de "), temp, row + 1,
   "where di.info_name = 'DM_ENV_ID'", row + 1, " and di.info_domain = 'DATA MANAGEMENT'",
   row + 1, "  and de.environment_id = di.info_number", row + 1,
   "detail", row + 1, " env_name = de.environment_name",
   row + 1, "with nocounter go", row + 1,
   "execute dm_ocd_insert_env go", row + 3
  WITH nocounter, maxrow = 1, maxcol = 512,
   format = variable, formfeed = none
 ;end select
 DELETE  FROM dm_ocd_features
  WHERE alpha_feature_nbr=afd_nbr
  WITH nocounter
 ;end delete
 SELECT INTO value(fname)
  FROM dual
  DETAIL
   "delete from dm_ocd_features", row + 1, temp = build("where alpha_feature_nbr = ",afd_nbr),
   temp, row + 1, "with nocounter go",
   row + 1, "commit go", row + 2
  WITH nocounter, maxrow = 1, maxcol = 512,
   format = variable, formfeed = none, append
 ;end select
 EXECUTE dm_delete_afd_codesets
 EXECUTE dm_delete_afd_tables
 SET tot_cs = 0
 SET tot_tbl = 0
 FOR (i = 1 TO feature_num)
   SET number_to_add = request->feature[i].qual_num
   SET cs_to_add = request->feature[i].cs_num
   SET tot_cs = (tot_cs+ cs_to_add)
   SET tot_tbl = (tot_tbl+ number_to_add)
   INSERT  FROM dm_ocd_features
    SET alpha_feature_nbr = afd_nbr, feature_number = request->feature[i].feature_number
    WITH nocounter
   ;end insert
   SELECT INTO value(fname)
    FROM dual
    DETAIL
     "insert into dm_ocd_features", row + 1, temp = build("set alpha_feature_nbr = ",afd_nbr,","),
     temp, row + 1, temp = build("feature_number = ",request->feature[i].feature_number),
     temp, row + 1, "with nocounter go",
     row + 1, "commit go", row + 2
    WITH nocounter, maxrow = 1, maxcol = 512,
     format = variable, formfeed = none, append
   ;end select
   IF (((number_to_add > 0) OR (cs_to_add > 0)) )
    UPDATE  FROM dm_ocd_features a
     SET a.schema_ind = 1
     WHERE a.alpha_feature_nbr=afd_nbr
      AND (a.feature_number=request->feature[i].feature_number)
     WITH nocounter
    ;end update
    SELECT INTO value(fname)
     FROM dual
     DETAIL
      "update into dm_ocd_features a", row + 1, "set a.schema_ind = 1",
      row + 1, temp = build("where a.alpha_feature_nbr = ",afd_nbr), temp,
      row + 1, temp = build("and a.feature_number = ",request->feature[i].feature_number), temp,
      row + 1, "with nocounter go", row + 1,
      "commit go", row + 1
     WITH nocounter, maxrow = 1, maxcol = 512,
      format = variable, formfeed = none, append
    ;end select
   ENDIF
   SET fnumber = request->feature[i].feature_number
   SET rev_date = cnvtdatetime("31-DEC-2100")
   SELECT INTO "nl:"
    a.schema_date
    FROM dm_schema_version a
    WHERE a.schema_version=rev_nbr
    DETAIL
     rev_date = a.schema_date
    WITH nocounter
   ;end select
   FREE SET list
   RECORD list(
     1 qual[*]
       2 code_set = i4
     1 count = i4
   )
   SET list->count = 0
   SET stat = alterlist(list->qual,10)
   FOR (z = 1 TO cs_to_add)
     SET list->count = (list->count+ 1)
     IF (mod(list->count,10)=1)
      SET stat = alterlist(list->qual,(list->count+ 9))
     ENDIF
     SET list->qual[list->count].code_set = request->feature[i].cs[z].code_set
   ENDFOR
   EXECUTE dm_fill_afd_codesets
   FREE SET tab_list
   RECORD tab_list(
     1 qual[*]
       2 table_name = vc
     1 count = i4
   )
   SET tab_list->count = 0
   SET stat = alterlist(tab_list->qual,10)
   FOR (x = 1 TO number_to_add)
     SET tab_list->count = (tab_list->count+ 1)
     IF (mod(tab_list->count,10)=1)
      SET stat = alterlist(tab_list->qual,(tab_list->count+ 9))
     ENDIF
     SET tab_list->qual[tab_list->count].table_name = request->feature[i].qual[x].table_name
   ENDFOR
   EXECUTE dm_fill_afd_tables
 ENDFOR
 COMMIT
 IF (tot_cs > 0)
  EXECUTE dm_refresh_afd_codesets
 ENDIF
 SET pre_name = build("OCD_PRE_SCHEMA_",cnvtstring(afd_nbr))
 SET post_name = build("OCD_POST_SCHEMA_",cnvtstring(afd_nbr))
 SET tempstr = fillstring(140," ")
 SELECT INTO value(fname)
  *
  FROM dual
  DETAIL
   tempstr = build("execute dm_ocd_pre_program '",pre_name,"' go"), tempstr, row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 1
 ;end select
 IF (tot_tbl > 0)
  SELECT INTO value(fname)
   *
   FROM dual
   DETAIL
    "execute dm_ocd_check_tspace go", row + 2
   WITH nocounter, append, maxcol = 512,
    format = variable, formfeed = none, maxrow = 1
  ;end select
  EXECUTE dm_refresh_afd_tables
 ENDIF
 SET tempstr = fillstring(140," ")
 SELECT INTO value(fname)
  *
  FROM dual
  DETAIL
   tempstr = build("execute dm_ocd_post_program '",post_name,"' go"), tempstr, row + 2
  WITH nocounter, append, maxcol = 512,
   format = variable, formfeed = none, maxrow = 1
 ;end select
 IF (tot_tbl > 0)
  SELECT INTO value(fname)
   *
   FROM dual
   DETAIL
    "execute dm_ocd_schema_comp go", row + 2
   WITH nocounter, append, maxcol = 512,
    format = variable, formfeed = none, maxrow = 1
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
END GO
