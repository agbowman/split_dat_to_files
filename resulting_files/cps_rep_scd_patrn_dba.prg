CREATE PROGRAM cps_rep_scd_patrn:dba
 RECORD reply(
   1 patterns[*]
     2 scr_pattern_id = f8
     2 sentences[*]
       3 scr_sentence_id = f8
     2 term_hier[*]
       3 scr_term_hier_id = f8
       3 scr_term_id = f8
       3 term_actions[*]
         4 scr_action_id = f8
         4 expr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 )
 SET failed = 0
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SET number_patterns = size(request->patterns,5)
 IF (number_patterns=0)
  SET failed = 1
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No patterns specified",cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 FREE RECORD request_del
 RECORD request_del(
   1 patterns[*]
     2 scr_pattern_id = f8
     2 action_type = c4
   1 deleted_status_cd = f8
 )
 FREE RECORD reply_del
 RECORD reply_del(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 cps_error
     2 cnt = i4
     2 data[*]
       3 code = i4
       3 severity_level = i4
       3 supp_err_txt = c32
       3 def_msg = vc
       3 row_data
         4 lvl_1_idx = i4
         4 lvl_2_idx = i4
         4 lvl_3_idx = i4
 )
 SET reply_del->status_data.status = "F"
 SET stat = alterlist(request_del->patterns,number_patterns)
 FOR (curind = 1 TO value(number_patterns))
   SET request_del->patterns[curind] = request->patterns[curind]
   SET request_del->patterns[curind].scr_pattern_id = request->patterns[curind].scr_pattern_id
   SET request_del->patterns[curind].action_type = request->patterns[curind].action_type
 ENDFOR
 SET delcode = uar_get_meaning_by_codeset(48,"DELETED",1,request_del->deleted_status_cd)
 EXECUTE cps_del_scd_patrn  WITH replace("REQUEST",request_del), replace("REPLY",reply_del)
 IF ((reply_del->status_data.status="S"))
  FREE RECORD request_del
  FREE RECORD reply_del
  EXECUTE cps_add_scd_patrn
  IF ((reply->status_data.status != "S"))
   SET failed = 1
   GO TO exit_script
  ENDIF
 ELSE
  SET failed = 1
  GO TO exit_script
 ENDIF
#exit_script
 FREE RECORD request_del
 FREE RECORD reply_del
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
