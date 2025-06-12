CREATE PROGRAM dm_schema_log_info:dba
 FREE RECORD plog
 RECORD plog(
   1 op_id = f8
   1 op_type = vc
   1 table_name = vc
   1 column_name = vc
   1 status = vc
 )
 SET plog->op_id =  $1
 SELECT INTO "nl:"
  FROM dm_schema_op_log d
  WHERE (d.op_id=plog->op_id)
  DETAIL
   plog->op_type = d.op_type, plog->table_name = d.table_name, plog->column_name =  $3,
   plog->status = d.status
  WITH nocounter
 ;end select
 IF ((plog->status="ERROR"))
  GO TO end_program
 ENDIF
 IF ((plog->op_type="POPULATE DEFAULT VALUE"))
  CALL plog_ins_item(plog->op_type,plog->table_name,plog->column_name)
 ENDIF
 SUBROUTINE plog_ins_item(pi_op_type,pi_tbl_name,pi_col_name)
   UPDATE  FROM dm_info d
    SET d.info_char = pi_col_name
    WHERE d.info_domain=concat("SCHEMA LOG-",trim(pi_tbl_name,3),"-",trim(pi_op_type,3))
     AND d.info_name=pi_col_name
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info d
     SET d.info_domain = concat("SCHEMA LOG-",trim(pi_tbl_name,3),"-",trim(pi_op_type,3)), d
      .info_name = pi_col_name
     WITH nocounter
    ;end insert
   ENDIF
   IF (curqual)
    COMMIT
   ELSE
    CALL echo("***")
    CALL echo("*** Cannot insert SCHEMA LOG into DM_INFO")
    CALL echo("***")
   ENDIF
 END ;Subroutine
#end_program
END GO
