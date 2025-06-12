CREATE PROGRAM bhs_upd_synonym_item_r:dba
 EXECUTE gm_synonym_item7888_def "I"
 DECLARE gm_i_synonym_item7888_f8(icol_name=vc,ival=f8,iqual=i4,null_ind=i2) = i2
 SUBROUTINE gm_i_synonym_item7888_f8(icol_name,ival,iqual,null_ind)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_i_synonym_item7888_req->qual,5) < iqual)
    SET stat = alterlist(gm_i_synonym_item7888_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "synonym_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_synonym_item7888_req->qual[iqual].synonym_id = ival
     SET gm_i_synonym_item7888_req->synonym_idi = 1
    OF "item_id":
     IF (null_ind=1)
      CALL echo("error can not set this column to null")
      RETURN(0)
     ENDIF
     SET gm_i_synonym_item7888_req->qual[iqual].item_id = ival
     SET gm_i_synonym_item7888_req->item_idi = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 EXECUTE gm_synonym_item7888_def "D"
 DECLARE gm_d_synonym_item7888_f8(icol_name=vc,ival=f8,iqual=i4) = i2
 SUBROUTINE gm_d_synonym_item7888_f8(icol_name,ival,iqual)
   DECLARE stat = i2 WITH protect, noconstant(0)
   IF (size(gm_d_synonym_item7888_req->qual,5) < iqual)
    SET stat = alterlist(gm_d_synonym_item7888_req->qual,iqual)
    IF (stat=0)
     CALL echo("can not expand request structure")
     RETURN(0)
    ENDIF
   ENDIF
   CASE (cnvtlower(icol_name))
    OF "synonym_id":
     SET gm_d_synonym_item7888_req->qual[iqual].synonym_id = ival
     SET gm_d_synonym_item7888_req->synonym_idw = 1
    OF "item_id":
     SET gm_d_synonym_item7888_req->qual[iqual].item_id = ival
     SET gm_d_synonym_item7888_req->item_idw = 1
    ELSE
     CALL echo("invalid column name passed")
     RETURN(0)
   ENDCASE
   RETURN(1)
 END ;Subroutine
 RECORD errors(
   1 err_cnt = i4
   1 err[*]
     2 err_code = i4
     2 err_msg = vc
 ) WITH protect
 DECLARE errcode = i4 WITH protected, noconstant(1)
 DECLARE errcnt = i4 WITH protected, noconstant(0)
 DECLARE errmsg = c132 WITH protected, noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE req_cnt = i4 WITH protect, noconstant(0)
 DECLARE upd_cnt = i4 WITH protect, noconstant(0)
 DECLARE del_cnt = i4 WITH protect, noconstant(0)
 DECLARE i_cnt = i4 WITH protect, noconstant(0)
 DECLARE d_cnt = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 CALL echorecord(request)
 FOR (req_cnt = 1 TO size(request->qual,5))
   CALL echo(build("###Number of items to insert:",size(request->qual[req_cnt].upd_qual,5)))
   CALL echo(build("###Number of items to delete:",size(request->qual[req_cnt].del_qual,5)))
   CALL echo(build("###For synonym_id: ",request->qual[req_cnt].synonym_id))
   IF (size(request->qual[req_cnt].upd_qual,5) > 0)
    FOR (upd_cnt = 1 TO size(request->qual[req_cnt].upd_qual,5))
      IF ((request->qual[req_cnt].upd_qual[upd_cnt].item_id > 0))
       SELECT INTO "nl:"
        FROM synonym_item_r sir
        WHERE (sir.item_id=request->qual[req_cnt].upd_qual[upd_cnt].item_id)
         AND (sir.synonym_id=request->qual[req_cnt].synonym_id)
        WITH nocounter
       ;end select
       IF (curqual=0)
        SET i_cnt = (i_cnt+ 1)
        IF (i_cnt > size(gm_i_synonym_item7888_req->qual,5))
         SET stat = alterlist(gm_i_synonym_item7888_req->qual,(i_cnt+ 9))
        ENDIF
        SET stat = gm_i_synonym_item7888_f8("SYNONYM_ID",request->qual[req_cnt].synonym_id,i_cnt,0)
        IF (stat=1)
         SET stat = gm_i_synonym_item7888_f8("ITEM_ID",request->qual[req_cnt].upd_qual[upd_cnt].
          item_id,i_cnt,0)
         CALL echo("***Inserting rows into synonym_item_r***")
         CALL echo(build("Synonym_id: ",request->qual[req_cnt].synonym_id))
         CALL echo(build("Item_id: ",request->qual[req_cnt].upd_qual[upd_cnt].item_id))
        ELSE
         SET reply->status_data.subeventstatus[1].targetobjectvalue =
         "Failure in adding Insert item to Master Script"
         CALL echo("!!!!Failure in adding Insert item to Master Script!!!")
         CALL echo(build("synonym_id: ",request->qual[req_cnt].synonym_id))
         CALL echo(build("item_id: ",request->qual[req_cnt].upd_qual[upd_cnt].item_id))
         GO TO exit_script
        ENDIF
       ELSE
        SET reply->status_data.subeventstatus[1].targetobjectvalue =
        "!!!!Row already exists on the table!!!!"
        CALL echo("!!!!Row already exists on the table!!!!")
        CALL echo(build("synonym_id: ",request->qual[req_cnt].synonym_id))
        CALL echo(build("item_id: ",request->qual[req_cnt].upd_qual[upd_cnt].item_id))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (size(request->qual[req_cnt].del_qual,5) > 0)
    FOR (del_cnt = 1 TO size(request->qual[req_cnt].del_qual,5))
      IF ((request->qual[req_cnt].del_qual[del_cnt].item_id > 0))
       SELECT INTO "nl:"
        FROM synonym_item_r sir
        WHERE (sir.item_id=request->qual[req_cnt].del_qual[del_cnt].item_id)
         AND (sir.synonym_id=request->qual[req_cnt].synonym_id)
        WITH nocounter
       ;end select
       IF (curqual > 0)
        SET d_cnt = (d_cnt+ 1)
        IF (d_cnt > size(gm_d_synonym_item7888_req->qual,5))
         SET stat = alterlist(gm_d_synonym_item7888_req->qual,(d_cnt+ 9))
        ENDIF
        SET stat = gm_d_synonym_item7888_f8("SYNONYM_ID",request->qual[req_cnt].synonym_id,d_cnt)
        IF (stat=1)
         SET stat = gm_d_synonym_item7888_f8("ITEM_ID",request->qual[req_cnt].del_qual[del_cnt].
          item_id,d_cnt)
         CALL echo("***Deleting rows from synonym_item_r***")
         CALL echo(build("Synonym_id: ",request->qual[req_cnt].synonym_id))
         CALL echo(build("Item_id: ",request->qual[req_cnt].del_qual[del_cnt].item_id))
        ELSE
         CALL echo("!!!!Failure in adding Delete item to Master Script!!!")
         CALL echo(build("synonym_id: ",request->qual[req_cnt].synonym_id))
         CALL echo(build("item_id: ",request->qual[req_cnt].del_qual[del_cnt].item_id))
         GO TO exit_script
        ENDIF
       ELSE
        CALL echo("!!!!Row does not exist on the table!!!!")
        CALL echo(build("synonym_id: ",request->qual[req_cnt].synonym_id))
        CALL echo(build("item_id: ",request->qual[req_cnt].del_qual[del_cnt].item_id))
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 SET stat = alterlist(gm_i_synonym_item7888_req->qual,i_cnt)
 SET stat = alterlist(gm_d_synonym_item7888_req->qual,d_cnt)
#exit_script
 CALL echo("******************************")
 CALL echo("Checking for errors...")
 CALL echo("******************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET stat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  CALL echorecord(errors)
 ENDIF
 IF (i_cnt > 0)
  EXECUTE gm_i_synonym_item7888  WITH replace(request,gm_i_synonym_item7888_req), replace(reply,
   gm_i_synonym_item7888_rep)
  FOR (i = 1 TO i_cnt)
    IF ((gm_i_synonym_item7888_rep->qual[i].status=0))
     SET err_msg = gm_i_synonym_item7888_rep->qual[i].error_msg
     CALL echo(build("Error during Insert: ",err_msg))
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "SYNONYM_ITEM_R"
     ROLLBACK
     GO TO exit_program
    ENDIF
  ENDFOR
 ENDIF
 IF (d_cnt > 0)
  EXECUTE gm_d_synonym_item7888  WITH replace(request,gm_d_synonym_item7888_req), replace(reply,
   gm_d_synonym_item7888_rep)
  FOR (i = 1 TO d_cnt)
    IF ((gm_d_synonym_item7888_rep->qual[i].status=0))
     SET err_msg = gm_d_synonym_item7888_rep->qual[i].error_msg
     CALL echo(build("Error during Delete: ",err_msg))
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "SYNONYM_ITEM_R"
     ROLLBACK
     GO TO exit_program
    ENDIF
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
#exit_program
 FREE RECORD gm_i_synonym_item7888_req
 FREE RECORD gm_i_synonym_item7888_rep
 FREE RECORD gm_d_synonym_item7888_req
 FREE RECORD gm_d_synonym_item7888_rep
 SET mod_date = "April 3, 2003"
 SET last_mod = "000"
END GO
