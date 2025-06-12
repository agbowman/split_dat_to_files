CREATE PROGRAM dm_batch_recombine:dba
 PAINT
 SET width = 132
 SET modify = system
 ROLLBACK
 UPDATE  FROM dm_cmb_exception
  SET single_encntr_ind = 1
  WHERE child_entity="PERSON_COMBINE"
   AND script_name="NONE"
  WITH nocounter
 ;end update
 COMMIT
 FREE SET request
 RECORD request(
   1 parent_table = c50
   1 cmb_mode = c20
   1 error_message = c132
   1 transaction_type = c8
   1 xxx_combine[*]
     2 xxx_combine_id = f8
     2 from_xxx_id = f8
     2 from_mrn = c200
     2 from_alias_pool_cd = f8
     2 from_alias_type_cd = f8
     2 to_xxx_id = f8
     2 to_mrn = c200
     2 to_alias_pool_cd = f8
     2 to_alias_type_cd = f8
     2 encntr_id = f8
     2 application_flag = i2
     2 combine_weight = f8
   1 xxx_combine_det[*]
     2 xxx_combine_det_id = f8
     2 xxx_combine_id = f8
     2 entity_name = c32
     2 entity_id = f8
     2 combine_action_cd = f8
     2 attribute_name = c32
     2 prev_active_ind = i2
     2 prev_active_status_cd = f8
     2 prev_end_eff_dt_tm = dq8
     2 combine_desc_cd = f8
     2 to_record_ind = i2
 )
 FREE SET reply
 RECORD reply(
   1 xxx_combine_id[*]
     2 combine_id = f8
     2 parent_table = c50
     2 from_xxx_id = f8
     2 to_xxx_id = f8
     2 encntr_id = f8
   1 error[*]
     2 create_dt_tm = dq8
     2 parent_table = c50
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 error_table = c32
     2 error_type = vc
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE SET recombines
 RECORD recombines(
   1 cmb[*]
     2 parent_table = c30
     2 combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
 )
 SET error_cnt = 0
 SET reply_cnt = 0
 SET rcb_from_id = 0
 SET rcb_to_id = 0
 SET person_cmb_cnt = 0
 SET encntr_move_cnt = 0
 SET encntr_cmb_cnt = 0
 SET reqinfo->updt_id = 77777
 SET reqinfo->updt_applctx = 77777
 SET reqinfo->updt_task = 77777
 SET default_start_date = cnvtdatetime("11-SEP-1999")
 SET default_end_date = cnvtdatetime(sysdate)
#0100_start
 CALL video(n)
 CALL clear(1,1)
 CALL clear(23,1)
 CALL clear(24,1)
 CALL box(3,1,22,132)
 CALL text(2,2,"PERSON/ENCOUNTER RE-COMBINE TOOL",w)
 CALL text(7,5," 1  Single Person Re-Combine")
 CALL text(9,5," 2  Single Encounter Re-Combine")
 CALL text(11,5," 3  Date Range Re-Combine")
 CALL text(13,5," 4  Exit")
 CALL text(23,1,"Select Option ? ")
 CALL accept(23,17,"9;",4
  WHERE curaccept IN (1, 2, 3, 4))
 CALL clear(23,1)
 SET choice = curaccept
 CASE (choice)
  OF 1:
   EXECUTE FROM 0200_process_single_person_cmb TO 0299_process_person_exit
  OF 2:
   EXECUTE FROM 0300_process_single_encntr_cmb TO 0399_process_encntr_exit
  OF 3:
   EXECUTE FROM 0400_accept_date TO 0499_accept_date_exit
   EXECUTE FROM 0500_process_date TO 0599_process_date_exit
  OF 4:
   GO TO 9999_end
 ENDCASE
 CALL clear(23,1)
 CALL clear(24,1)
 GO TO 0100_start
#0199_start_exit
#0200_process_single_person_cmb
 FOR (x = 4 TO 20)
   CALL clear(x,2,130)
 ENDFOR
 CALL video(n)
 CALL text(2,53,"*** INPUT ***",w)
 CALL text(5,5,"Combined Away PERSON_ID")
 CALL text(7,5,"Master PERSON_ID")
 CALL video(lu)
 SET accept = change
 CALL accept(5,35,"9(9)")
 SET rcb_from_id = curaccept
 CALL accept(7,35,"9(9)")
 SET rcb_to_id = curaccept
 CALL video(n)
 CALL clear(23,1)
 CALL clear(24,1)
 CALL text(23,1,"Working...")
 SET request->parent_table = "PERSON"
 SET request->cmb_mode = "RE-CMB"
 SET request->transaction_type = "RE-CMB"
 SET stat = alterlist(request->xxx_combine,0)
 SET stat = alterlist(request->xxx_combine_det,0)
 SET stat = alterlist(reply->xxx_combine_id,0)
 SET stat = alterlist(reply->error,0)
 SELECT INTO "nl:"
  p.person_combine_id
  FROM person_combine p
  WHERE p.from_person_id=rcb_from_id
   AND p.to_person_id=rcb_to_id
   AND p.encntr_id=0
   AND p.active_ind=1
  DETAIL
   stat = alterlist(request->xxx_combine,1), request->xxx_combine[1].xxx_combine_id = p
   .person_combine_id, request->xxx_combine[1].from_xxx_id = rcb_from_id,
   request->xxx_combine[1].to_xxx_id = rcb_to_id, request->xxx_combine[1].encntr_id = 0
  WITH nocounter
 ;end select
 IF (curqual=1)
  CALL clear(23,1)
  CALL text(23,1,"Working...")
  EXECUTE dm_call_combine
  CALL clear(23,1)
  IF (error_cnt > 0)
   CALL text(23,1,concat("Error: ",substring(1,123,reply->error[1].error_msg)))
  ENDIF
  IF (reply_cnt > 0)
   CALL text(23,1,"*** Done ! ***")
  ENDIF
  CALL text(24,1,"Enter X to exit or M to go back to main menu...")
  CALL accept(24,50,"p;cud","M"
   WHERE curaccept IN ("M", "X"))
  IF (curaccept="X")
   GO TO 9999_end
  ELSE
   GO TO 0100_start
  ENDIF
 ELSE
  CALL clear(23,1)
  CALL text(23,1,"No person combine has been performed on this person_id combination.")
  CALL text(24,1,"Please re-enter...")
  GO TO 0200_process_single_person_cmb
 ENDIF
#0299_process_person_exit
#0300_process_single_encntr_cmb
 FOR (x = 4 TO 20)
   CALL clear(x,2,130)
 ENDFOR
 CALL video(n)
 CALL text(2,53,"*** INPUT ***",w)
 CALL text(5,5,"Combined Away ENCNTR_ID")
 CALL text(7,5,"Master ENCNTR_ID")
 CALL video(lu)
 SET accept = change
 CALL accept(5,35,"9(9)")
 SET rcb_from_id = curaccept
 CALL accept(7,35,"9(9)")
 SET rcb_to_id = curaccept
 CALL video(n)
 CALL clear(23,1)
 CALL clear(24,1)
 CALL text(23,1,"Working...")
 SET request->parent_table = "ENCOUNTER"
 SET request->cmb_mode = "RE-CMB"
 SET request->transaction_type = "RE-CMB"
 SET stat = alterlist(request->xxx_combine,0)
 SET stat = alterlist(request->xxx_combine_det,0)
 SET stat = alterlist(reply->xxx_combine_id,0)
 SET stat = alterlist(reply->error,0)
 SELECT INTO "nl:"
  e.encntr_combine_id
  FROM encntr_combine e
  WHERE e.from_encntr_id=rcb_from_id
   AND e.to_encntr_id=rcb_to_id
   AND e.active_ind=1
  DETAIL
   stat = alterlist(request->xxx_combine,1), request->xxx_combine[1].xxx_combine_id = e
   .encntr_combine_id, request->xxx_combine[1].from_xxx_id = rcb_from_id,
   request->xxx_combine[1].to_xxx_id = rcb_to_id, request->xxx_combine[1].encntr_id = 0
  WITH nocounter
 ;end select
 IF (curqual=1)
  CALL clear(23,1)
  CALL text(23,1,"Working...")
  EXECUTE dm_call_combine
  CALL clear(23,1)
  IF (error_cnt > 0)
   CALL text(23,1,concat("Error: ",substring(1,123,reply->error[1].error_msg)))
  ENDIF
  IF (reply_cnt > 0)
   CALL text(23,1,"*** Done ! ***")
  ENDIF
  CALL text(24,1,"Enter X to exit or M to go back to main menu...")
  CALL accept(24,50,"p;cud","M"
   WHERE curaccept IN ("M", "X"))
  IF (curaccept="X")
   GO TO 9999_end
  ELSE
   GO TO 0100_start
  ENDIF
 ELSE
  CALL clear(23,1)
  CALL text(23,1,"No encounter combine has been performed on this encntr_id combination.")
  CALL text(24,1,"Please re-enter...")
  GO TO 0200_process_single_encntr_cmb
 ENDIF
#0399_process_encntr_exit
#0400_accept_date
 FOR (x = 4 TO 21)
   CALL clear(x,2,130)
 ENDFOR
 CALL text(2,53,"*** INPUT ***",w)
 CALL text(5,5,"Beginning Date")
 CALL text(7,5,"Ending Date   ")
 CALL video(lu)
 SET accept = change
 CALL text(5,26,format(default_start_date,"DD-MMM-YYYY;3;d"))
 CALL text(7,26,format(default_end_date,"DD-MMM-YYYY;3;d"))
#0410_accept_start_date
 CALL accept(5,26,"nndpppdnnnn;ucs",format(default_start_date,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 CASE (curscroll)
  OF 0:
   SET default_start_date = cnvtdatetime(curaccept)
   CALL text(5,26,format(default_start_date,"DD-MMM-YYYY;3;d"))
   SET start_date = concat(curaccept," 00:00:00.00")
  OF 2:
   CALL text(5,26,format(default_start_date,"DD-MMM-YYYY;3;d"))
   GO TO 0410_accept_start_date
  ELSE
   GO TO 0410_accept_start_date
 ENDCASE
#0420_accept_end_date
 CALL accept(7,26,"nndpppdnnnn;ucs",format(default_end_date,"dd-mmm-yyyy;;d")
  WHERE format(cnvtdatetime(curaccept),"dd-mmm-yyyy;;d")=curaccept)
 CASE (curscroll)
  OF 0:
   SET default_end_date = cnvtdatetime(curaccept)
   CALL text(7,26,format(default_end_date,"DD-MMM-YYYY;3;d"))
   SET end_date = concat(curaccept," 23:59:59.99")
  OF 2:
   CALL text(7,26,format(default_end_date,"DD-MMM-YYYY;3;d"))
   GO TO 0410_accept_start_date
  ELSE
   GO TO 0420_accept_end_date
 ENDCASE
#0499_accept_date_exit
#0500_process_date
 FREE SET recombine
 RECORD recombine(
   1 qual[*]
     2 parent_table = c30
     2 combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 updt_dt_tm = dq8
   1 sorted[*]
     2 parent_table = c30
     2 combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 updt_dt_tm = dq8
   1 error[*]
     2 parent_table = c50
     2 combine_id = f8
     2 from_id = f8
     2 to_id = f8
     2 encntr_id = f8
     2 error_table = c32
     2 error_type = vc
     2 error_msg = vc
 )
 SET cmb_cnt = 0
 SET cmb_cnt2 = 0
 SET err_log_cnt = 0
 SELECT INTO "nl:"
  p.person_combine_id, p.from_person_id, p.to_person_id,
  p.encntr_id, p.updt_dt_tm
  FROM person_combine p
  WHERE p.updt_dt_tm >= cnvtdatetime(start_date)
   AND p.updt_dt_tm <= cnvtdatetime(end_date)
   AND p.active_ind=1
   AND p.updt_task != 77777
  ORDER BY p.updt_dt_tm
  DETAIL
   cmb_cnt += 1, stat = alterlist(recombine->qual,cmb_cnt), recombine->qual[cmb_cnt].parent_table =
   "PERSON",
   recombine->qual[cmb_cnt].combine_id = p.person_combine_id, recombine->qual[cmb_cnt].from_id = p
   .from_person_id, recombine->qual[cmb_cnt].to_id = p.to_person_id,
   recombine->qual[cmb_cnt].encntr_id = p.encntr_id, recombine->qual[cmb_cnt].updt_dt_tm = p
   .updt_dt_tm
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  e.encntr_combine_id, e.from_encntr_id, e.to_encntr_id,
  e.updt_dt_tm
  FROM encntr_combine e
  WHERE e.updt_dt_tm >= cnvtdatetime(start_date)
   AND e.updt_dt_tm <= cnvtdatetime(end_date)
   AND e.active_ind=1
   AND e.updt_task != 77777
  DETAIL
   cmb_cnt += 1, stat = alterlist(recombine->qual,cmb_cnt), recombine->qual[cmb_cnt].parent_table =
   "ENCOUNTER",
   recombine->qual[cmb_cnt].combine_id = e.encntr_combine_id, recombine->qual[cmb_cnt].from_id = e
   .from_encntr_id, recombine->qual[cmb_cnt].to_id = e.to_encntr_id,
   recombine->qual[cmb_cnt].encntr_id = 0, recombine->qual[cmb_cnt].updt_dt_tm = e.updt_dt_tm
  WITH nocounter
 ;end select
 IF (cmb_cnt > 0)
  SELECT INTO "nl:"
   d.seq
   FROM (dummyt d  WITH seq = value(cmb_cnt))
   ORDER BY recombine->qual[d.seq].updt_dt_tm
   DETAIL
    cmb_cnt2 += 1, stat = alterlist(recombine->sorted,cmb_cnt2), recombine->sorted[cmb_cnt2].
    parent_table = recombine->qual[d.seq].parent_table,
    recombine->sorted[cmb_cnt2].combine_id = recombine->qual[d.seq].combine_id, recombine->sorted[
    cmb_cnt2].from_id = recombine->qual[d.seq].from_id, recombine->sorted[cmb_cnt2].to_id = recombine
    ->qual[d.seq].to_id,
    recombine->sorted[cmb_cnt2].encntr_id = recombine->qual[d.seq].encntr_id, recombine->sorted[
    cmb_cnt2].updt_dt_tm = recombine->qual[d.seq].updt_dt_tm
   WITH nocounter
  ;end select
  SELECT INTO mine
   z = d.seq, a = recombine->sorted[d.seq].parent_table, b = recombine->sorted[d.seq].combine_id,
   c = recombine->sorted[d.seq].from_id, d = recombine->sorted[d.seq].to_id, e = recombine->sorted[d
   .seq].encntr_id,
   f = cnvtdatetime(recombine->sorted[d.seq].updt_dt_tm)
   FROM (dummyt d  WITH seq = value(cmb_cnt2))
   HEAD PAGE
    col 0, "LIST OF COMBINES THAT WILL BE PROCESSED", row + 1,
    col 0, "=======================================", row + 2,
    col 0, "NO.", col 8,
    "PARENT_TABLE", col 23, "COMBINE_ID",
    col 35, "FROM_ID", col 47,
    "TO_ID", col 59, "ENCNTR_ID",
    col 71, "UPDT_DT_TM", row + 1,
    col 0, "------", col 8,
    "------------", col 23, "----------",
    col 35, "---------", col 47,
    "---------", col 59, "---------",
    col 71, "----------", row + 2
   DETAIL
    col 0, z"######;r", col 8,
    a, col 23, b"##########",
    col 35, c"#########", col 47,
    d"#########", col 59, e"#########",
    col 71, f";;q", row + 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO mine
   "No combine on the specified date range needs to be processed."
   FROM dual
   WITH nocounter
  ;end select
 ENDIF
 FOR (rcb_cnt = 1 TO cmb_cnt2)
   CALL video(n)
   CALL clear(23,1,6)
   CALL text(23,1,format(rcb_cnt,"######;r"))
   CALL text(23,8,"combine(s) processed!")
   CALL clear(24,1)
   SET stat = alterlist(request->xxx_combine,0)
   SET stat = alterlist(request->xxx_combine_det,0)
   SET stat = alterlist(reply->xxx_combine_id,0)
   SET stat = alterlist(reply->error,0)
   SET request->cmb_mode = "RE-CMB"
   SET request->transaction_type = "RE-CMB"
   SET request->parent_table = recombine->sorted[rcb_cnt].parent_table
   SET stat = alterlist(request->xxx_combine,1)
   SET request->xxx_combine[1].xxx_combine_id = recombine->sorted[rcb_cnt].combine_id
   SET request->xxx_combine[1].from_xxx_id = recombine->sorted[rcb_cnt].from_id
   SET request->xxx_combine[1].to_xxx_id = recombine->sorted[rcb_cnt].to_id
   SET request->xxx_combine[1].encntr_id = recombine->sorted[rcb_cnt].encntr_id
   EXECUTE dm_call_combine
   IF (error_cnt > 0)
    SET err_log_cnt += 1
    SET stat = alterlist(recombine->error,err_log_cnt)
    SET recombine->error[err_log_cnt].parent_table = reply->error[1].parent_table
    SET recombine->error[err_log_cnt].combine_id = recombine->sorted[rcb_cnt].combine_id
    SET recombine->error[err_log_cnt].from_id = reply->error[1].from_id
    SET recombine->error[err_log_cnt].to_id = reply->error[1].to_id
    SET recombine->error[err_log_cnt].encntr_id = reply->error[1].encntr_id
    SET recombine->error[err_log_cnt].error_type = reply->error[1].error_type
    SET recombine->error[err_log_cnt].error_table = reply->error[1].error_table
    SET recombine->error[err_log_cnt].error_msg = reply->error[1].error_msg
   ENDIF
   IF (err_log_cnt=10)
    GO TO 0510_error_disp
   ENDIF
 ENDFOR
#0510_error_disp
 IF (err_log_cnt > 0)
  SELECT INTO mine
   z = d.seq
   FROM (dummyt d  WITH seq = value(err_log_cnt))
   HEAD REPORT
    col 0, "RE-COMBINE ERROR LOG", row + 1,
    col 0, "====================", row + 2,
    col 0, "NO.", col 8,
    "PARENT_TABLE", col 23, "COMBINE_ID",
    col 35, "FROM_ID", col 47,
    "TO_ID", col 59, "ENCNTR_ID",
    col 71, "ERROR_TYPE", col 85,
    "ERROR_TABLE", row + 1, col 0,
    "------", col 8, "------------",
    col 23, "----------", col 35,
    "---------", col 47, "---------",
    col 59, "---------", col 71,
    "----------", col 85, "-----------",
    row + 2
   DETAIL
    col 0, z"######;r", col 8,
    recombine->error[d.seq].parent_table, col 23, recombine->error[d.seq].combine_id"##########",
    col 35, recombine->error[d.seq].from_id"#########", col 47,
    recombine->error[d.seq].to_id"#########", col 59, recombine->error[d.seq].encntr_id"#########",
    col 71, recombine->error[d.seq].error_type, col 85,
    recombine->error[d.seq].error_table, row + 1, col 0,
    "Error: ", col 8, recombine->error[d.seq].error_msg,
    row + 2
   WITH nocounter
  ;end select
 ENDIF
 CALL video(n)
 CALL clear(24,1)
 CALL text(24,1,"Enter X to exit or M to go back to main menu...")
 CALL accept(24,50,"p;cud","M"
  WHERE curaccept IN ("X", "M"))
 IF (curaccept="X")
  GO TO 9999_end
 ELSE
  GO TO 0100_start
 ENDIF
#0599_process_date_exit
#9999_end
END GO
