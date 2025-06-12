CREATE PROGRAM dm_check_static_rows
 SET new_sample_id = 0.0
 SET env = logical("ENVIRONMENT")
 SET env_id = 0.0
 SELECT INTO "nl:"
  de.environment_id
  FROM dm_environment de
  WHERE de.environment_name=env
  DETAIL
   env_id = de.environment_id
  WITH nocounter
 ;end select
 SET client_name = cnvtupper( $1)
 SELECT INTO "nl:"
  dm_x = seq(dm_size_rows_seq,nextval)
  FROM dual
  DETAIL
   new_sample_id = cnvtreal(dm_x)
  WITH nocounter
 ;end select
 FREE SET table_list
 RECORD table_list(
   1 table_count = i4
   1 list[*]
     2 table_name = c32
     2 actual_row_count = i4
 )
 SET count = 0
 SELECT DISTINCT INTO "nl:"
  ut.table_name
  FROM user_tables ut
  ORDER BY ut.table_name
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(table_list->list,(count+ 9))
   ENDIF
   table_list->list[count].table_name = ut.table_name
  WITH nocounter
 ;end select
 SET table_list->table_count = count
 SET tempcmd = fillstring(255," ")
 SET trace symbol mark
 FOR (i = 1 TO table_list->table_count)
   SET tempcmd = concat('select into "nl:" y = count(*) from ',table_list->list[i].table_name,
    "detail table_list->list[",cnvtstring(i),"]->actual_row_count = y ",
    "with nocounter go")
   CALL parser(tempcmd,1)
   SET trace = symbol
 ENDFOR
 SET trace symbol mark
 FOR (i = 1 TO table_list->table_count)
   SET table_name = table_list->list[i].table_name
   SET actual_rows = table_list->list[i].actual_row_count
   INSERT  FROM dm_size_rows sr
    SET sr.sample_id = new_sample_id, sr.client_name = client_name, sr.environment_id = env_id,
     sr.sample_date = cnvtdatetime(curdate,curtime3), sr.table_name = table_name, sr.actual_rows =
     actual_rows
    WITH clear = "0"
   ;end insert
 ENDFOR
 COMMIT
 SET dclcom = "@CER_CODE:[SCRIPT]DM_SIZE.COM"
 SET lenc = size(trim(dclcom))
 SET status = 0
 CALL dcl(dclcom,lenc,status)
 COMMIT
END GO
