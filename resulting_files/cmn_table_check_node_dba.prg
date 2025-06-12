CREATE PROGRAM cmn_table_check_node:dba
 PROMPT
  "outdev    : " = "MINE",
  "table name: " = ""
  WITH outdev, tablename
 RECORD record_data(
   1 table_exists = i2
   1 table_accessible = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE PUBLIC::main_cmn_table_check_node(null) = null WITH protect
 DECLARE PUBLIC::checkexists(tablename=vc) = i2 WITH protect
 DECLARE PUBLIC::checkaccessible(null) = i2 WITH protect
 SUBROUTINE PUBLIC::checkexists(tablename)
  SELECT INTO "nl:"
   dt.table_name
   FROM dtable dt
   WHERE dt.platform="H0000"
    AND dt.rcode="3"
    AND dt.table_name=tablename
   WITH nocounter
  ;end select
  RETURN(evaluate(curqual,0,false,true))
 END ;Subroutine
 SUBROUTINE PUBLIC::checkaccessible(null)
   DECLARE msg = vc WITH protect
   DECLARE err = i4 WITH protect, noconstant(0)
   SET err = error(msg,1)
   SELECT INTO "nl:"
    count(*)
    FROM ( $TABLENAME)
    WITH nocounter
   ;end select
   SET err = error(msg,0)
   RETURN(evaluate(err,0,true,false))
 END ;Subroutine
 SUBROUTINE PUBLIC::main_cmn_table_check_node(null)
  SET record_data->table_exists = checkexists(cnvtupper( $TABLENAME))
  IF ((record_data->table_exists=true))
   SET record_data->table_accessible = checkaccessible(null)
  ENDIF
 END ;Subroutine
 IF (validate(_memory_reply_string)=false)
  DECLARE _memory_reply_string = vc WITH protect, noconstant("")
 ENDIF
 CALL main_cmn_table_check_node(null)
#exit_script
 SET _memory_reply_string = cnvtrectojson(record_data)
END GO
