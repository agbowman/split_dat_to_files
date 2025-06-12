CREATE PROGRAM ct_build_detail:dba
 PAINT
 RECORD rule(
   1 rule_list[*]
     2 ct_rule_id = f8
     2 ct_rule_name = vc
     2 ct_action_name = vc
     2 ct_action = vc
     2 ct_action_cd = f8
     2 ct_beg_date = di8
     2 ct_end_date = di8
 )
 RECORD code_val(
   1 119947_replacelist = f8
   1 119948_replaceprice = f8
   1 119949_replaceadjst = f8
   1 208314_replacecusm = f8
   1 119950_count = f8
 )
 RECORD duration(
   1 meaning = c12
 )
 SET v_rule_type_disp = fillstring(40," ")
 RECORD response(
   1 yes_ind = i2
   1 no_ind = i2
 )
 RECORD code(
   1 cpt4_cd = f8
 )
 SET v_name = fillstring(50," ")
 SET v_duration = 0.0
 SET v_rule_type = 0.0
 SET v_beg_date = cnvtdatetime(curdate,curtime)
 SET v_end_date = cnvtdatetime("31-dec-2100 23:59")
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=400
  DETAIL
   IF (cv.cdf_meaning="CPT4")
    code->cpt4_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
#top
 SET min_row = 2
 SET row_cnt = 20
 SET max_row = (min_row+ (row_cnt - 1))
 SET cur_rec = 0
 SET top_rec = 0
 SET max_rec = 0
 SET bot_rec = row_cnt
 SET count1 = 0
 CALL clear(1,1)
 SELECT INTO "nl:"
  FROM ct_rule r,
   code_value cv
  WHERE r.active_ind=1
   AND cv.code_value=r.action_cd
  DETAIL
   count1 = (count1+ 1), stat = alterlist(rule->rule_list,count1), rule->rule_list[count1].ct_rule_id
    = r.ct_rule_id,
   rule->rule_list[count1].ct_rule_name = r.description, rule->rule_list[count1].ct_action_cd = r
   .action_cd, rule->rule_list[count1].ct_action = cv.cdf_meaning,
   rule->rule_list[count1].ct_beg_date = r.beg_effective_dt_tm, rule->rule_list[count1].ct_end_date
    = r.end_effective_dt_tm
  WITH nocounter
 ;end select
 SET max_rec = count1
 SET m = 0
 FOR (x = 1 TO count1)
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=18849
     AND (c.code_value=rule->rule_list[x].ct_action_cd)
    DETAIL
     m = (m+ 1), rule->rule_list[m].ct_action_name = c.display
    WITH nocounter
   ;end select
 ENDFOR
 SUBROUTINE display_rows(scrolltype)
   CASE (scrolltype)
    OF 0:
     SET cur_rec = 1
     SET top_rec = 1
     SET bot_rec = row_cnt
    OF 1:
     IF (cur_rec < max_rec)
      SET cur_rec = (cur_rec+ 1)
     ENDIF
     IF (cur_rec > bot_rec)
      SET top_rec = (top_rec+ 1)
      SET bot_rec = (top_rec+ (row_cnt - 1))
     ENDIF
    OF 2:
     IF (cur_rec > 1)
      SET cur_rec = (cur_rec - 1)
     ENDIF
     IF (cur_rec < top_rec)
      SET top_rec = cur_rec
      SET bot_rec = (cur_rec+ (row_cnt - 1))
     ENDIF
    OF 5:
     IF (cur_rec <= row_cnt)
      SET cur_rec = 1
     ELSE
      SET cur_rec = (cur_rec - row_cnt)
     ENDIF
     SET top_rec = cur_rec
     SET bot_rec = (cur_rec+ (row_cnt - 1))
    OF 6:
     IF (((cur_rec+ row_cnt) <= max_rec))
      SET cur_rec = (cur_rec+ row_cnt)
     ENDIF
     SET top_rec = cur_rec
     SET bot_rec = (top_rec+ (row_cnt - 1))
   ENDCASE
   CALL text(1,8,"Description")
   CALL text(1,40,"Rule Type")
   CALL text(1,55,"Beg Date")
   CALL text(1,68,"End Date")
   SET x_qual = top_rec
   FOR (x = min_row TO max_row)
     CALL clear(x,1,80)
     IF (x_qual=cur_rec)
      CALL video(r)
     ELSE
      CALL video(n)
     ENDIF
     IF (x_qual <= max_rec)
      CALL text(x,1,cnvtstring(x_qual))
      CALL text(x,8,rule->rule_list[x_qual].ct_rule_name)
      CALL text(x,40,rule->rule_list[x_qual].ct_action_name)
      CALL text(x,55,format(rule->rule_list[x_qual].ct_beg_date,"dd-mmm-yyyy;;d"))
      CALL text(x,68,format(rule->rule_list[x_qual].ct_end_date,"dd-mmm-yyyy;;d"))
     ELSE
      CALL clear(x,1,80)
     ENDIF
     CALL video(n)
     SET x_qual = (x_qual+ 1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE check_detail(rec_idx)
   CALL text(14,10,cnvtstring(rule->rule_list[rec_idx].ct_rule_id))
 END ;Subroutine
 CALL display_rows(0)
#top_end
#the_prompt
 CALL text(24,3,"Add/Modify/Delete/View Details/Quit (A/M/D/V/Q)")
 CALL accept(24,51,"x;cus","Q")
 CALL clear(24,1)
 CASE (curscroll)
  OF 0:
   CASE (curaccept)
    OF "A":
     GO TO add_rule
     EXECUTE FROM top TO top_end
    OF "M":
     GO TO modify_rule
     EXECUTE FROM top TO top_end
    OF "D":
     GO TO delete_rule
    OF "V":
     FREE SET request
     IF ((rule->rule_list[cur_rec].ct_action="REPLACELIST"))
      EXECUTE ct_build_replacelist cnvtstring(rule->rule_list[cur_rec].ct_rule_id), rule->rule_list[
      cur_rec].ct_rule_name, rule->rule_list[cur_rec].ct_action_name
      EXECUTE FROM top TO top_end
     ELSEIF ((rule->rule_list[cur_rec].ct_action="REPLACEADJST"))
      EXECUTE ct_build_replaceadjust cnvtstring(rule->rule_list[cur_rec].ct_rule_id), rule->
      rule_list[cur_rec].ct_rule_name, rule->rule_list[cur_rec].ct_action_name
      EXECUTE FROM top TO top_end
     ELSEIF ((rule->rule_list[cur_rec].ct_action="REPLACEPRICE"))
      EXECUTE ct_build_replaceprice cnvtstring(rule->rule_list[cur_rec].ct_rule_id), rule->rule_list[
      cur_rec].ct_rule_name, rule->rule_list[cur_rec].ct_action_name
      EXECUTE FROM top TO top_end
     ELSEIF ((rule->rule_list[cur_rec].ct_action="MODIFYLIST"))
      EXECUTE ct_build_modifylist cnvtstring(rule->rule_list[cur_rec].ct_rule_id), rule->rule_list[
      cur_rec].ct_rule_name, rule->rule_list[cur_rec].ct_action_name
      EXECUTE FROM top TO top_end
     ELSEIF ((rule->rule_list[cur_rec].ct_action="COUNT"))
      EXECUTE ct_build_count cnvtstring(rule->rule_list[cur_rec].ct_rule_id), rule->rule_list[cur_rec
      ].ct_rule_name, rule->rule_list[cur_rec].ct_action_name
      EXECUTE FROM top TO top_end
     ENDIF
     FREE SET request
    OF "Q":
     GO TO end_prog
   ENDCASE
  ELSE
   CALL display_rows(curscroll)
 ENDCASE
 GO TO the_prompt
#add_rule
 RECORD request(
   1 ct_rule_qual = i2
   1 ct_rule[10]
     2 action_type = c3
     2 ct_rule_id = f8
     2 description = c100
     2 action_cd = f8
     2 duration_cd = f8
     2 vocab_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = i4
     2 active_status_prsnl_id = f8
 )
 CALL clear(1,1)
 CALL box(4,1,22,80)
 CALL text(22,50,"Help Available < Shift F5 >")
 CALL text(6,2,"RULE")
 CALL line(7,1,80,xhor)
 CALL text(9,4,"Name:  ")
 CALL text(11,4,"Duration:  ")
 CALL text(13,4,"Beginning Date:  ")
 CALL text(15,4,"Ending Date:  ")
 CALL text(17,4,"Rule Type:  ")
 CALL accept(9,10,"p(50);cu")
 SET v_name = curaccept
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=18850
   AND cv.active_ind=1
   AND cv.cdf_meaning="DTOFSERVICE"
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(11,18,"9(40);cf")
 SET v_duration = cnvtreal(curaccept)
 SET help = off
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=18850
   AND v_duration=cv.code_value
  DETAIL
   duration->meaning = cv.description
  WITH nocounter
 ;end select
 CALL text(11,30,duration->meaning)
 CALL text(13,20,format(curdate,"DD-MMM-YYYY;;D"))
 CALL accept(13,20,"xx-xxx-xxxx;ucs",format(curdate,"DD-MMM-YYYY;;D"))
 SET v_beg_date = cnvtdatetime(curaccept)
 CALL text(15,20,format(v_end_date,"DD-MMM-YYYY;;D"))
 CALL accept(15,20,"xx-xxx-xxxx;ucs",format(v_end_date,"DD-MMM-YYYY;;D"))
 SET v_end_date = cnvtdatetime(curaccept)
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=18849
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(17,18,"9(40);cf")
 SET v_rule_type = cnvtreal(curaccept)
 SET help = off
 CALL clear(40,1)
 SET request->ct_rule_qual = 1
 SET request->ct_rule[1].action_type = "ADD"
 SET request->ct_rule[1].description = v_name
 SET request->ct_rule[1].duration_cd = v_duration
 SET request->ct_rule[1].vocab_type_cd = code->cpt4_cd
 SET request->ct_rule[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule[1].end_effective_dt_tm = v_end_date
 SET request->ct_rule[1].action_cd = v_rule_type
 EXECUTE ct_ens_rule
 COMMIT
 EXECUTE FROM top TO top_end
 GO TO the_prompt
#modify_rule
 RECORD request(
   1 ct_rule_qual = i2
   1 ct_rule[10]
     2 action_type = c3
     2 ct_rule_id = f8
     2 description = c100
     2 action_cd = f8
     2 duration_cd = f8
     2 vocab_type_cd = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = i4
     2 active_status_prsnl_id = f8
 )
 SELECT INTO "nl:"
  FROM ct_rule r,
   code_value cv
  WHERE (r.ct_rule_id=rule->rule_list[cur_rec].ct_rule_id)
   AND r.action_cd=cv.code_value
  DETAIL
   v_name = r.description, v_duration = r.duration_cd, v_beg_date = cnvtdatetime(r
    .beg_effective_dt_tm),
   v_end_date = cnvtdatetime(r.end_effective_dt_tm), v_rule_type = r.action_cd, v_rule_type_disp = cv
   .display
  WITH nocounter
 ;end select
 CALL clear(1,1)
 CALL box(1,1,14,75)
 CALL text(14,40,"Help Available <Shift F5>")
 CALL text(3,4,"1) Description:  ")
 CALL text(5,4,"2) Duration:  ")
 CALL text(7,4,"3) Beginning Date: ")
 CALL text(9,4,"4) Ending Date: ")
 CALL text(11,4,"5) Rule Type: ")
 CALL text(3,21,v_name)
 CALL text(5,18,cnvtstring(v_duration))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=18850
   AND v_duration=cv.code_value
  DETAIL
   duration->meaning = cv.description
  WITH nocounter
 ;end select
 CALL text(5,30,duration->meaning)
 CALL text(7,24,format(v_beg_date,"dd-mmm-yyyy;;d"))
 CALL text(9,21,format(v_end_date,"dd-mmm-yyyy;;d"))
 CALL text(11,18,cnvtstring(v_rule_type))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=18849
   AND v_rule_type=cv.code_value
  DETAIL
   v_rule_type_disp = cv.display
  WITH nocounter
 ;end select
 CALL text(11,30,v_rule_type_disp)
#modify_field
 CALL clear(21,1)
 CALL text(24,3,"Field Number:  ")
 CALL accept(24,17,"9",0
  WHERE curaccept IN (1, 2, 3, 4, 5))
 CASE (curaccept)
  OF 1:
   GO TO screen_1
  OF 2:
   GO TO screen_2
  OF 3:
   GO TO screen_3
  OF 4:
   GO TO screen_4
  OF 5:
   GO TO screen_5
 ENDCASE
#modify_field_end
 CALL clear(20,1)
 CALL video(n)
#screen_1
 CALL text(3,21,v_name)
 CALL accept(3,21,"p(50);cu",v_name)
 SET v_name = curaccept
#screen_2
 CALL text(5,18,cnvtstring(v_duration))
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=18850
   AND cv.active_ind=1
   AND cv.cdf_meaning="DTOFSERVICE"
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(5,18,"9(40);c",v_duration)
 SET v_duration = cnvtreal(curaccept)
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=18850
   AND v_duration=cv.code_value
  DETAIL
   duration->meaning = cv.description
  WITH nocounter
 ;end select
 CALL text(5,30,duration->meaning)
 SET help = off
#screen_3
 CALL text(7,24,cnvtstring(v_beg_date))
 CALL accept(7,24,"xx-xxx-xxxx;cu",format(v_beg_date,"dd-mmm-yyyy;;d"))
 SET v_beg_date = cnvtdatetime(curaccept)
#screen_4
 CALL text(9,21,cnvtstring(v_end_date))
 CALL accept(9,21,"xx-xxx-xxxx;cu",format(v_end_date,"dd-mmm-yyyy;;d"))
 SET v_end_date = cnvtdatetime(curaccept)
#screen_5
 CALL text(5,18,cnvtstring(v_rule_type))
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.display
  FROM code_value cv
  WHERE cv.code_set=18849
   AND cv.active_ind=1
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(11,18,"9(40);c",v_rule_type)
 SET v_rule_type = cnvtreal(curaccept)
 SELECT INTO "nl:"
  cv.display
  FROM code_value cv
  WHERE cv.code_value=v_rule_type
  DETAIL
   v_rule_type_disp = cv.display
  WITH nocounter
 ;end select
 CALL text(11,30,v_rule_type_disp)
 SET help = off
 GO TO modify_question
#modify_question
 EXECUTE afc_ccl_msgbox "Are you sure you want to Modify?", "Rule", "YN"
 IF ((response->yes_ind=1))
  GO TO modifing_rule
 ELSE
  EXECUTE FROM top TO end_top
  GO TO the_prompt
 ENDIF
#modifing_rule
 SET request->ct_rule_qual = 1
 SET request->ct_rule.action_type = "UPT"
 SET request->ct_rule.ct_rule_id = rule->rule_list[cur_rec].ct_rule_id
 SET request->ct_rule.description = v_name
 SET request->ct_rule.duration_cd = v_duration
 SET request->ct_rule.beg_effective_dt_tm = v_beg_date
 SET request->ct_rule.end_effective_dt_tm = v_end_date
 SET request->ct_rule.vocab_type_cd[1] = code->cpt4_cd
 SET request->ct_rule.action_cd = v_rule_type
 EXECUTE ct_ens_rule
 COMMIT
 EXECUTE FROM top TO top_end
 GO TO the_prompt
#delete_rule
 EXECUTE afc_ccl_msgbox "Are you sure you want to Delete?", "Rule", "YN"
 IF ((response->yes_ind=1))
  DELETE  FROM ct_rule r
   WHERE (r.ct_rule_id=rule->rule_list[cur_rec].ct_rule_id)
   WITH nocounter
  ;end delete
  EXECUTE FROM top TO end_top
  GO TO the_prompt
  COMMIT
 ELSE
  EXECUTE FROM top TO end_top
  GO TO the_prompt
 ENDIF
#end_prog
END GO
