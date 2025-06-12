CREATE PROGRAM bbt_chk_interp_result:dba
 RECORD errors(
   1 err_cnt = i4
   1 err[5]
     2 err_code = i4
     2 err_msg = vc
 )
 RECORD internal(
   1 checking_text[*]
     2 long_text_id = f8
 )
 SET text_cnt = 0
 SET idx = 0
 SET stat = alterlist(internal->checking_text,100)
 SELECT INTO "NL:"
  *
  FROM interp_result ir
  WHERE ir.long_text_id > 0
  DETAIL
   text_cnt = (text_cnt+ 1)
   IF (text_cnt > 100)
    stat = alterlist(internal->checking_text,1)
   ENDIF
   internal->checking_text[text_cnt].long_text_id = ir.long_text_id
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (text_cnt=0)) )
  SET request->setup_proc[1].success_ind = 1
  GO TO exit_script
 ENDIF
 FOR (idx = 1 TO text_cnt)
  SELECT INTO "NL:"
   *
   FROM long_text
   WHERE (long_text_id=internal->checking_text[idx].long_text_id)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET request->setup_proc[1].success_ind = 0
   SET request->setup_proc[1].error_msg = "No text found on long_text table"
   GO TO exit_script
  ENDIF
 ENDFOR
 SET request->setup_proc[1].success_ind = 1
#exit_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
