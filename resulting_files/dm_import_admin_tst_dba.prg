CREATE PROGRAM dm_import_admin_tst:dba
 FREE SET current_ocds
 RECORD current_ocds(
   1 init_log = i2
   1 log_file_name = vc
   1 operating_system = i2
   1 oracle_version = i4
   1 ocd_cnt = i4
   1 qual[*]
     2 ocd = i4
 )
 SELECT INTO "NL:"
  p.*
  FROM product_component_version p
  WHERE cnvtupper(p.product)="ORACLE*"
  DETAIL
   current_ocds->oracle_version = cnvtint(substring(1,(findstring(".",p.version) - 1),p.version))
  WITH nocounter
 ;end select
 IF (cursys="AIX")
  SET current_ocds->operating_system = 2
 ELSE
  SET current_ocds->operating_system = 1
 ENDIF
 IF ((validate(sf_hold->exist_flag,- (1))=- (1)))
  FREE DEFINE rtl
  FREE SET file_loc
  SET logical file_loc value("cer_install:current_ocd_list.txt")
  DEFINE rtl "file_loc"
  SELECT INTO "nl:"
   FROM rtlt r
   DETAIL
    current_ocds->ocd_cnt = (current_ocds->ocd_cnt+ 1), stat = alterlist(current_ocds->qual,
     current_ocds->ocd_cnt), current_ocds->qual[current_ocds->ocd_cnt].ocd = cnvtint(r.line)
   WITH nocounter
  ;end select
  DELETE  FROM dm_ocds_per_schema_version r
   WHERE (r.schema_version= $3)
   WITH nocounter
  ;end delete
  COMMIT
  INSERT  FROM dm_ocds_per_schema_version m,
    (dummyt d  WITH seq = value(current_ocds->ocd_cnt))
   SET m.seq = 1, m.schema_version =  $3, m.schema_date = cnvtdatetimeutc( $2),
    m.ocd = current_ocds->qual[d.seq].ocd, m.updt_applctx = 4751, m.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    m.updt_cnt = 1, m.updt_id = 4751, m.updt_task = 4751
   PLAN (d
    WHERE d.seq > 0
     AND (current_ocds->qual[d.seq].ocd != 0))
    JOIN (m)
   WITH nocounter
  ;end insert
  COMMIT
 ELSE
  SELECT INTO "nl:"
   FROM dm_alpha_features_env de
   WHERE (de.environment_id=sf_hold->env_id)
   HEAD REPORT
    current_ocds->ocd_cnt = 0
   DETAIL
    current_ocds->ocd_cnt = (current_ocds->ocd_cnt+ 1), stat = alterlist(current_ocds->qual,
     current_ocds->ocd_cnt), current_ocds->qual[current_ocds->ocd_cnt].ocd = de.alpha_feature_nbr
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(current_ocds)
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 1500_inputs TO 1999_inputs_exit
 EXECUTE FROM 2000_test TO 2999_test_exit
 GO TO 9999_exit_program
 SUBROUTINE log(l_text)
   CALL echo(concat(l_text," (",format(cnvtdatetime(curdate,curtime3),";;q"),")"))
 END ;Subroutine
 SUBROUTINE parse(p_text)
   CALL parser(p_text,1)
 END ;Subroutine
 SUBROUTINE com(c_text)
   SET command_count = (command_count+ 1)
   SET stat = alterlist(commands->command,command_count)
   SET commands->command[command_count].text = trim(c_text,3)
 END ;Subroutine
 SUBROUTINE run(r_dummy)
   SET r_file = commands->command_file
   SET r_command = commands->command_file_name
   SET r_len = size(r_command)
   SET r_i = 0
   SELECT INTO value(r_file)
    FROM dummyt d
    DETAIL
     FOR (r_i = 1 TO command_count)
      commands->command[r_i].text,
      IF (r_i < command_count)
       row + 1
      ENDIF
     ENDFOR
    WITH nocounter, format = variable, noformfeed,
     maxrow = 1, maxcol = 500
   ;end select
   IF (cursys="AIX")
    SET r2_len = 0
    SET r2_command = concat("chmod 777 ",r_command)
    SET r2_len = size(r2_command)
    CALL dcl(r2_command,r2_len,0)
   ENDIF
   SET command_count = 0
   SET stat = alterlist(commands->command,0)
   SET r_i = 0
   CALL dcl(r_command,r_len,r_i)
 END ;Subroutine
 SUBROUTINE blast(b_table)
  CALL log(concat("Truncate table: ",b_table))
  CALL parse(concat("rdb truncate table ",b_table," go"))
 END ;Subroutine
 SUBROUTINE chk_ccldef(ccd_table)
  SELECT INTO "nl:"
   d.table_name, l.attr_name
   FROM dtableattr d,
    dtableattrl l
   WHERE l.structtype="F"
    AND btest(l.stat,11)=0
    AND d.table_name=ccd_table
    AND l.attr_name="*"
   WITH nocounter
  ;end select
  IF (curqual)
   RETURN(0)
  ELSE
   RETURN(1)
  ENDIF
 END ;Subroutine
 SUBROUTINE di_drop_table(ddd_table)
   SELECT INTO "nl:"
    FROM dba_synonyms da
    WHERE da.synonym_name=ddd_table
     AND da.owner="PUBLIC"
    WITH nocounter
   ;end select
   IF (curqual)
    CALL log(concat("Drop synonym: ",ddd_table))
    CALL parse(concat("rdb drop public synonym ",ddd_table," go"))
   ENDIF
   SELECT INTO "nl:"
    FROM dba_objects db
    WHERE db.object_name=ddd_table
     AND db.object_type="TABLE"
     AND db.owner=currdbuser
    WITH nocounter
   ;end select
   IF (curqual)
    CALL log(concat("Drop table: ",ddd_table))
    CALL parse(concat("rdb drop table ",ddd_table," cascade constraints go"))
   ENDIF
 END ;Subroutine
 SUBROUTINE di_build_ccl_def(bcd_dummy)
  SELECT INTO "nl:"
   FROM user_tables ut
   DETAIL
    admin_cons->tbl_cnt = (admin_cons->tbl_cnt+ 1), stat = alterlist(admin_cons->tqual,admin_cons->
     tbl_cnt), admin_cons->tqual[admin_cons->tbl_cnt].tbl_name = trim(ut.table_name)
   WITH nocounter
  ;end select
  FOR (dbcd = 1 TO value(admin_cons->tbl_cnt))
   CALL log(concat("Create CCL definition for table: ",admin_cons->tqual[dbcd].tbl_name))
   CALL parse(concat("execute oragen3 '",admin_cons->tqual[dbcd].tbl_name,"' go"))
  ENDFOR
 END ;Subroutine
 SUBROUTINE wipe(w_table,w_afd)
   IF (chk_ccldef(w_table))
    CALL log(concat("Create ccl def for table: ",w_table))
    CALL parse(concat("execute oragen3 '",w_table,"' go"))
   ENDIF
   CALL log(concat("Wipe table: ",w_table))
   SET w_flag = 1
   WHILE (w_flag)
     IF (w_afd)
      CALL parse(concat("delete from ",w_table," x where x.alpha_feature_nbr in"))
     ELSE
      CALL parse(concat("delete from ",w_table," x where x.ocd in"))
     ENDIF
     CALL parse("(select o.ocd from dm_current_ocd o where o.ocd > 0) with maxqual(x, 1000) go")
     SET w_flag = curqual
     COMMIT
   ENDWHILE
 END ;Subroutine
 SUBROUTINE blast_schema_date(b_table)
   IF (chk_ccldef(b_table))
    CALL log(concat("Create ccl def for table: ",b_table))
    CALL parse(concat("execute oragen3 '",b_table,"' go"))
   ENDIF
   CALL log(concat("Blast_schema_date table: ",b_table))
   SET w_flag = 1
   WHILE (w_flag)
     CALL parse(concat("delete from ",b_table," x where x.schema_date ="))
     CALL parse(concat("cnvtdatetime('",dump_date,"') with maxqual(x, 1000) go"))
     SET w_flag = curqual
     COMMIT
   ENDWHILE
 END ;Subroutine
#1000_initialize
 ROLLBACK
 FREE SET commands
 RECORD commands(
   1 imp_command_str = vc
   1 sqlplus_command_str = vc
   1 command_file_name = vc
   1 command_file = vc
   1 command[*]
     2 text = vc
 )
 SET command_count = 0
 FREE SET arch_dt
 RECORD arch_dt(
   1 arch_dt_cnt = i4
   1 qual[*]
     2 ocd = i4
     2 archive_dt_tm = dq8
 )
 SET arch_dt->arch_dt_cnt = 0
 SET stat = alterlist(arch_dt->qual,arch_dt->arch_dt_cnt)
 FREE SET admin_cons
 RECORD admin_cons(
   1 fk_cnt = i4
   1 qual[*]
     2 table_name = vc
     2 constraint_name = vc
   1 tbl_cnt = i4
   1 tqual[*]
     2 tbl_name = vc
 )
 SET admin_cons->fk_cnt = 0
 SET stat = alterlist(admin_cons->qual,admin_cons->fk_cnt)
 SET admin_cons->tbl_cnt = 0
 SET stat = alterlist(admin_cons->tqual,admin_cons->tbl_cnt)
 SET i = 0
 SET j = 0
 SET k = 0
 IF (cursys="AIX")
  SET commands->imp_command_str = "$ORACLE_HOME/bin/imp"
  SET commands->sqlplus_command_str = "$ORACLE_HOME/bin/sqlplus"
  SET commands->command_file_name = "$CCLUSERDIR/ocd_import_admin.ksh"
  SET commands->command_file = "ocd_import_admin.ksh"
 ELSE
  SET commands->imp_command_str = "$imp"
  SET commands->sqlplus_command_str = "$sqlplus"
  SET commands->command_file_name = "@CCLUSERDIR:ocd_import_admin.com"
  SET commands->command_file = "ocd_import_admin.com"
  IF ((current_ocds->oracle_version >= 9))
   CALL com("$@oracle_home:orauser")
  ELSE
   CALL com("$@ora_util:orauser")
  ENDIF
 ENDIF
#1499_initialize_exit
#1500_inputs
 SET dump_path = "ccluserdir:"
 SET dump_date = "01-SEP-2001"
 SET admin_connect = "cdba/cdba@adm781"
 IF ((( NOT (size(trim(dump_path,3)))) OR ((( NOT (cnvtdatetime(dump_date))) OR ( NOT (size(trim(
   admin_connect,3))))) )) )
  CALL kick("One or more parameters seems to be invalid.")
 ENDIF
#1999_inputs_exit
#2000_test
 CALL di_drop_table("DM_CURRENT_OCD")
 CALL com(concat(commands->imp_command_str," ",admin_connect,
   " touser=cdba fromuser=admin_tmp commit=Y ignore=y ","tables=DM_CURRENT_OCD file=",
   dump_path,"admin.dmp log=",dump_path,"admin_table_imp.log"))
 CALL run(0)
 CALL wipe("DM_AFE_SHIP",1)
 CALL com(concat(commands->imp_command_str," ",admin_connect,
   " touser=cdba fromuser=admin_tmp commit=Y ignore=y ","tables=DM_AFE_SHIP file=",
   dump_path,"admin.dmp log=",dump_path,"admin_table_imp.log"))
 CALL run(0)
 CALL blast_schema_date("DM_SCHEMA_VERSION")
 SELECT INTO "nl:"
  FROM dm_schema_version dv
  WHERE dv.schema_version=0.0
  WITH nocounter
 ;end select
 IF (curqual)
  CALL log("Delete zero row from DM_SCHEMA_VERSION table.")
  DELETE  FROM dm_schema_version dv
   WHERE dv.schema_version=0.0
   WITH nocounter
  ;end delete
  COMMIT
 ENDIF
 CALL com(concat(commands->imp_command_str," ",admin_connect,
   " touser=cdba fromuser=admin_tmp commit=Y ignore=y ","tables=DM_SCHEMA_VERSION file=",
   dump_path,"admin.dmp log=",dump_path,"admin_table_imp.log"))
 CALL run(0)
 CALL blast("DM_TABLESPACE")
 CALL com(concat(commands->imp_command_str," ",admin_connect,
   " touser=cdba fromuser=admin_tmp commit=Y ignore=y ","tables=DM_TABLESPACE file=",
   dump_path,"admin.dmp log=",dump_path,"admin_table_imp.log"))
 CALL run(0)
#2999_test_exit
#9999_exit_program
END GO
