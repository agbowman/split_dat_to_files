CREATE PROGRAM assist_ens_table_data:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 row_qual = i4
    1 row[100]
      2 status = c1
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET hassist_ens_table_data = 0
 SET istatus = 0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET reply->row_qual = request->row_qual
 SET stat = alter(reply->row,reply->row_qual)
 SET table_name = request->table_name
 SET parser_buf[900] = fillstring(128," ")
 IF ((request->row_qual != 0))
  FOR (row_inx = 1 TO request->row_qual)
    SET kount = 0
    SET buf_inx = 0
    SET buf_inx = (buf_inx+ 1)
    SET parser_buf[buf_inx] = concat('select into "nl:"')
    SET buf_inx = (buf_inx+ 1)
    SET parser_buf[buf_inx] = concat(" x.* ")
    SET buf_inx = (buf_inx+ 1)
    SET parser_buf[buf_inx] = concat(" from ",trim(request->table_name,3)," x ")
    IF ((request->attrib_qual > 0))
     SET ifirst = true
     FOR (inx1 = 1 TO request->attrib_qual)
       IF ((request->attrib[inx1].primary_key_ind=true))
        IF (ifirst=true)
         SET buf_inx = (buf_inx+ 1)
         SET parser_buf[buf_inx] = concat(" where x.",trim(request->attrib[inx1].column_name,3)," = ",
          trim(request->row[row_inx].col[inx1].value,3)," ")
         SET ifirst = false
        ELSE
         SET buf_inx = (buf_inx+ 1)
         SET parser_buf[buf_inx] = concat(" and  x.",trim(request->attrib[inx1].column_name,3)," = ",
          trim(request->row[inx1].value,3)," ")
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    FOR (x = 1 TO buf_inx)
      CALL echo(x,0)
      CALL echo(" :",0)
      CALL echo(parser_buf[x],1)
      CALL parser(parser_buf[x])
    ENDFOR
    IF (curqual=0)
     CALL echo(table_name,0)
     CALL echo(row_inx,0)
     CALL echo(" Found",1)
     SET reply->row[row_inx].status = "Z"
    ELSE
     CALL echo(table_name,0)
     CALL echo(row_inx,0)
     CALL echo(" NOT Found",1)
     SET reply->row[row_inx].status = "S"
    ENDIF
  ENDFOR
 ENDIF
 SET stat = alter(reply->row,reply->row_qual)
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
  CALL echo("FAILED: Table = [",0)
  CALL echo(table_name,0)
  CALL echo("]  failed to [",0)
  SET op_name = reply->status_data.subeventstatus[1].operationname
  CALL echo(op_name,0)
  CALL echo("]  ",1)
  CALL echo("        CCL error = [",0)
  CALL echo(serrmsg,0)
  CALL echo("]",1)
 ENDIF
 GO TO end_program
#end_program
END GO
