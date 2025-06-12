CREATE PROGRAM dm_schema_cnvt_num_to_float:dba
 SET rdm_table_name = fillstring(30," ")
 SET rdm_table_column = fillstring(60," ")
 SET rdm_null_field = "Y"
 SET rdm_float_now = "N"
 SET rdm_cnt = 0
 SET rdm_key_column = "N"
 SET rdm_temp_table = fillstring(255," ")
 SET rdm_info_name = fillstring(255," ")
 SET rdm_found = "N"
 SET rdm_null_com = fillstring(255," ")
 SET rdm_errmsg = fillstring(131," ")
 SET rdm_cnvt_stat = "S"
 SET rdm_drop_table = fillstring(255," ")
 SET rdm_file_name = fillstring(255," ")
 SET rdm_attempts = 0
 SET rdm_table_already = "N"
 FREE RECORD rdm_select
 RECORD rdm_select(
   1 data[*]
     2 s_fields = vc
     2 w_fields = vc
 )
 SET rdm_table_name = cnvtupper( $1)
 SET rdm_table_column = cnvtupper( $2)
#file_name
 SELECT INTO "NL:"
  di.info_name, di.info_domain, di.info_char
  FROM dm_info di
  WHERE di.info_domain="NUMBER_TO_FLOAT"
  HEAD REPORT
   rdm_found = "N", rdm_number = 1, rdm_info_name = build(rdm_table_name,"-",rdm_table_column)
  DETAIL
   IF (di.info_name=rdm_info_name)
    rdm_found = "Y", rdm_temp_table = cnvtlower(di.info_char)
   ENDIF
   IF (cnvtreal(substring(5,4,di.info_char)) >= rdm_number
    AND rdm_found="N")
    rdm_number = ((cnvtreal(substring(5,4,di.info_char))+ 1)+ rdm_attempts)
   ENDIF
  FOOT REPORT
   IF (rdm_found="N")
    rdm_temp_table = build("tzxy",(rdm_number+ rdm_attempts))
   ENDIF
  WITH nullreport, nocounter
 ;end select
 CALL echo("Temp table name")
 CALL echo(rdm_temp_table)
 CALL echo("Ran before?")
 CALL echo(rdm_found)
 IF (rdm_found="N")
  INSERT  FROM dm_info di
   SET di.info_domain = "NUMBER_TO_FLOAT", di.info_name = rdm_info_name, di.info_char =
    rdm_temp_table
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 IF (checkdic(cnvtupper(rdm_temp_table),"T",0)=2)
  SET rdm_table_already = "Y"
 ENDIF
 SET rdm_file_name = build("ccluserdir:",rdm_temp_table,".dat")
 SET rdm_stat = findfile(rdm_file_name)
 CALL echo("temp table already here?")
 CALL echo(rdm_table_already)
 CALL echo("temp dat file already here? 1 = yes, 0 = no")
 CALL echo(rdm_stat)
 IF (rdm_found="N"
  AND ((rdm_table_already="Y") OR (rdm_stat=1)) )
  SET rdm_attempts = (rdm_attempts+ 1)
  SET rdm_table_already = "N"
  DELETE  FROM dm_info di
   WHERE di.info_domain="NUMBER_TO_FLOAT"
    AND di.info_name=rdm_info_name
    AND di.info_char=rdm_temp_table
   WITH nocounter
  ;end delete
  COMMIT
  CALL echo("Temp table name used by program other then this one. Getting another.")
  GO TO file_name
 ENDIF
 CALL parser("select into 'NL:'")
 CALL parser("utc.data_type,utc.nullable")
 CALL parser("from user_tab_columns utc")
 CALL parser("where utc.table_name = ")
 CALL parser("rdm_table_name")
 CALL parser("and utc.column_name = ")
 CALL parser("rdm_table_column")
 CALL parser("detail")
 CALL parser("if (utc.data_type = 'FLOAT')")
 CALL parser("rdm_float_now = 'Y'")
 CALL parser("endif")
 CALL parser("with nocounter")
 CALL parser("go")
 IF (curqual=0)
  CALL video(br)
  CALL echo("*************************************")
  CALL echo("table or column not in user_tab_columns. Program aborted.")
  CALL echo("*************************************")
  CALL video(n)
  GO TO clean_up
 ENDIF
 CALL echo("Is the column already a float?")
 CALL echo(rdm_float_now)
 IF (rdm_float_now="Y"
  AND rdm_found="N")
  CALL video(br)
  CALL echo("*************************************")
  CALL echo("Table and column are already a float")
  CALL echo("*************************************")
  CALL video(n)
  GO TO clean_up
 ENDIF
 CALL parser("select into 'nl:'")
 CALL parser("from user_constraints uc,")
 CALL parser("     user_cons_columns ucc ")
 CALL parser("where uc.constraint_type = 'C' ")
 CALL parser("    and uc.table_name = ")
 CALL parser("                rdm_table_name")
 CALL parser("    and uc.constraint_name = ucc.constraint_name ")
 CALL parser("    and uc.table_name = ucc.table_name ")
 CALL parser("    and ucc.column_name = ")
 CALL parser("               rdm_table_column")
 CALL parser("detail")
 CALL parser(
  "   if ( findstring( 'ISNOTNULL', cnvtupper( trim( trim( uc.search_condition,3 ),4 ) ) ) > 0 ) ")
 CALL parser("     rdm_null_field = 'N'")
 CALL parser("  endif")
 CALL parser("with nocounter")
 CALL parser("go")
 CALL echo("Can the column be set to null?")
 CALL echo(rdm_null_field)
 CALL parser("select into 'NL:' uc.table_name, ucc.column_name, ucc.position")
 CALL parser("from user_cons_columns ucc, user_constraints uc")
 CALL parser("plan uc where uc.table_name = ")
 CALL parser("rdm_table_name")
 CALL parser("and uc.constraint_type = 'P'")
 CALL parser("join ucc where ucc.table_name= uc.table_name")
 CALL parser("and ucc.constraint_name = uc.constraint_name")
 CALL parser("order ucc.position ")
 CALL parser("head report")
 CALL parser("rdm_cnt = 0")
 CALL parser("rdm_unique_stat = alterlist(rdm_select->data, 10)")
 CALL parser("detail")
 CALL parser("rdm_cnt = rdm_cnt + 1 ")
 CALL parser("if(mod(rdm_cnt,10)=1 and rdm_cnt!=1)")
 CALL parser("rdm_stat = alterlist(rdm_select->data,rdm_cnt+9)")
 CALL parser("endif")
 CALL parser("if(rdm_cnt = 1)")
 CALL parser("rdm_select->data[1].s_fields = concat('t.',ucc.column_name)")
 CALL parser("rdm_select->data[1].w_fields = build('tn.',ucc.column_name,'=ttn.',ucc.column_name)")
 CALL parser("else")
 CALL parser("rdm_select->data[rdm_cnt].s_fields = concat(',t.',ucc.column_name)")
 CALL parser(
  "rdm_select->data[rdm_cnt].w_fields = build('and tn.',ucc.column_name,'=ttn.',ucc.column_name)")
 CALL parser("endif")
 CALL parser("if(rdm_table_column = ucc.column_name)")
 CALL parser("rdm_key_column = 'Y'")
 CALL parser("endif")
 CALL parser("with nocounter")
 CALL parser("go")
 SET rdm_unique_stat = alterlist(rdm_select->data,rdm_cnt)
 IF (rdm_found="Y"
  AND rdm_table_already="Y"
  AND rdm_stat=1)
  CALL echo("attempting to load data.")
  GO TO load_data
 ENDIF
 CALL echo("Is the column to be modified part of the primary key?")
 CALL echo(rdm_key_column)
 IF (rdm_key_column="Y")
  CALL video(br)
  CALL echo("*************************************")
  CALL echo("The column is part of the primary key.")
  CALL echo("This field can not be set to float with this program")
  CALL echo("*************************************")
  CALL video(n)
  GO TO clean_up
 ENDIF
 IF (rdm_null_field="N")
  CALL echo("Make the column nullable")
  SET rdm_null_com = concat("rdb alter table ",rdm_table_name," modify ",rdm_table_column," null go")
  CALL parser(rdm_null_com)
  SET rdm_errcode = error(rdm_errmsg,0)
  IF (rdm_errcode != 0)
   CALL video(br)
   CALL echo("*************************************")
   CALL echo("Error in making the column nullable")
   CALL echo("*************************************")
   CALL video(n)
   CALL echo(rdm_errmsg)
   GO TO clean_up
  ENDIF
 ENDIF
 CALL parser("select into table ")
 CALL parser(rdm_temp_table)
 FOR (rdm_cnt_2 = 1 TO rdm_cnt)
   CALL parser(rdm_select->data[rdm_cnt_2].s_fields)
 ENDFOR
 CALL parser(build(",t.",rdm_table_column))
 CALL parser("from ")
 CALL parser(rdm_table_name)
 CALL parser(" t")
 CALL parser(build("where t.",rdm_table_column))
 CALL parser("is not NULL")
 CALL parser("order ")
 FOR (rdm_cnt_2 = 1 TO rdm_cnt)
   CALL parser(rdm_select->data[rdm_cnt_2].s_fields)
 ENDFOR
 CALL parser(" with organization = i")
 CALL parser(" go")
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  CALL video(br)
  CALL echo("*************************************")
  CALL echo("Error in creating the temp table")
  CALL echo("*************************************")
  CALL video(n)
  CALL echo(rdm_errmsg)
  GO TO remove_dat
 ENDIF
 CALL parser("update into ")
 CALL parser(rdm_table_name)
 CALL parser("tn")
 CALL parser(build("set tn.",rdm_table_column,"= NULL"))
 CALL parser("where 1=1")
 CALL parser("with nocounter")
 CALL parser("go")
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  CALL video(br)
  CALL echo("*************************************")
  CALL echo("Error in changing all values to null in column.")
  CALL echo("*************************************")
  CALL video(n)
  CALL echo(rdm_errmsg)
  ROLLBACK
  GO TO remove_dat
 ENDIF
 CALL parser("RDB Alter table ")
 CALL parser(rdm_table_name)
 CALL parser("modify ")
 CALL parser(rdm_table_column)
 CALL parser(" float go")
 SET rdm_errcode = error(rdm_errmsg,0)
 IF (rdm_errcode != 0)
  CALL video(br)
  CALL echo("*************************************")
  CALL echo("Error in making the column float.")
  CALL echo("*************************************")
  CALL video(n)
  CALL echo(rdm_errmsg)
  ROLLBACK
  GO TO clean_up
 ENDIF
 EXECUTE oragen3 value(rdm_table_name)
#load_data
 CALL parser("update into ")
 CALL parser(rdm_table_name)
 CALL parser(build("tn, ",rdm_temp_table))
 CALL parser(" ttn ")
 CALL parser(build("set tn.",rdm_table_column,"=ttn.",rdm_table_column))
 CALL parser("plan ttn join tn where")
 FOR (rdm_cnt_2 = 1 TO rdm_cnt)
   CALL parser(rdm_select->data[rdm_cnt_2].w_fields)
 ENDFOR
 CALL parser(build("and tn.",rdm_table_column))
 CALL parser(" is NULL")
 CALL parser("with nocounter")
 CALL parser("go")
 COMMIT
 CALL parser("select into 'NL:'")
 CALL parser(build("tn.",rdm_table_column))
 CALL parser("from ")
 CALL parser(rdm_table_name)
 CALL parser(build("tn, ",rdm_temp_table))
 CALL parser(" ttn ")
 CALL parser("plan tn")
 CALL parser(build("where tn.",rdm_table_column,"=NULL"))
 CALL parser(" join ttn where")
 FOR (rdm_cnt_2 = 1 TO rdm_cnt)
   CALL parser(rdm_select->data[rdm_cnt_2].w_fields)
 ENDFOR
 CALL parser(" detail")
 CALL parser(" rdm_cnvt_stat= 'F'")
 CALL parser(" with nocounter")
 CALL parser(" go")
 IF (rdm_cnvt_stat="F")
  CALL video(br)
  CALL echo("*************************************")
  CALL echo("All data has not been converted back!")
  CALL echo("Be sure to copy the following file in ccluserdir to a safe location!")
  SET rdm_file_name = concat(rdm_temp_table,",.dat")
  CALL echo(rdm_file_name)
  CALL echo("*************************************")
  CALL video(n)
  GO TO exit_script
 ENDIF
 IF (rdm_null_field="N")
  SET rdm_null_com = concat("rdb alter table ",rdm_table_name," modify ",rdm_table_column,
   "not null go")
  CALL parser(rdm_null_com)
 ENDIF
#remove_dat
 IF (cursys="AXP")
  SET dcldel = build("del ccluserdir:",rdm_temp_table,".dat;1")
  CALL echo(dcldel)
  SET len = size(trim(dcldel))
  SET status = 0
  CALL dcl(dcldel,len,status)
 ELSE
  SET dcldel = build("rm $CCLUSERDIR/",rdm_temp_table,".dat")
  SET len = size(trim(dcldel))
  SET status = 0
  CALL dcl(dcldel,len,status)
  SET dcldel = build("rm $CCLUSERDIR/",rdm_temp_table,".idx")
  SET len = size(trim(dcldel))
  SET status = 0
  CALL dcl(dcldel,len,status)
 ENDIF
 CALL parser("drop table ")
 CALL parser(rdm_temp_table)
 CALL parser(" go")
 CALL video(br)
 CALL echo("*************************************")
 CALL echo("Field has been changed to a float.")
 CALL echo("*************************************")
 CALL video(n)
#clean_up
 DELETE  FROM dm_info di
  WHERE di.info_domain="NUMBER_TO_FLOAT"
   AND di.info_name=rdm_info_name
   AND di.info_char=rdm_temp_table
  WITH nocounter
 ;end delete
 COMMIT
#exit_script
END GO
