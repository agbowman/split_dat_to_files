CREATE PROGRAM ct_build_ruleset_rule
 PAINT
 RECORD request(
   1 ct_ruleset_rule_reltn_qual = i2
   1 ct_ruleset_rule_reltn[10]
     2 action_type = c3
     2 ct_ruleset_rule_id = f8
     2 ct_rule_id = f8
     2 ct_ruleset_cd = f8
     2 priority = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 updt_task = i4
 )
 RECORD ruleset(
   1 ruleset_list[*]
     2 ct_rule_id = f8
     2 ct_rule_name = vc
     2 ct_action_cd = f8
     2 ct_action_name = vc
     2 ct_beg_date = di8
     2 ct_end_date = di8
     2 ct_priority = i4
     2 ct_ruleset_id = f8
 )
 RECORD response(
   1 yes_ind = i2
   1 no_ind = i2
 )
#top
 SET count1 = 0
 SET v_rule_id = 0.0
 CALL clear(1,1)
 CALL video(n)
 CALL box(1,1,4,80)
 CALL text(3,3,"Ruleset:  ")
#top_end
 SET v_ruleset_cd = 0
 SET help =
 SELECT
  code_value = c.code_value"########################################;l", c.display
  FROM code_value c
  WHERE c.code_set=18829
   AND c.active_ind=1
  WITH nocounter
 ;end select
 CALL accept(3,12,"9(40);cf")
 SET v_ruleset_cd = cnvtreal(curaccept)
#second
 CALL text(3,12,cnvtstring(v_ruleset_cd))
 RECORD reltn(
   1 reltn_qual[*]
     2 reltn_cd = f8
     2 reltn_name = vc
     2 v_ruleset_id = f8
 )
 SELECT INTO "nl:"
  FROM ct_ruleset_rule_reltn r
  WHERE r.ct_ruleset_cd=v_ruleset_cd
  ORDER BY r.priority
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reltn->reltn_qual,count1), reltn->reltn_qual[count1].
   reltn_cd = r.ct_ruleset_cd,
   reltn->reltn_qual[count1].v_ruleset_id = r.ct_ruleset_rule_id
  WITH nocounter
 ;end select
 SET n = 0
 FOR (x = 1 TO count1)
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=18829
     AND (code_value=reltn->reltn_qual[x].reltn_cd)
    DETAIL
     n = (n+ 1), reltn->reltn_qual[n].reltn_name = c.display
    WITH nocounter
   ;end select
 ENDFOR
 CALL text(3,20,reltn->reltn_qual.reltn_name)
#display_rule
 SET min_row = 7
 SET row_cnt = 15
 SET max_row = (min_row+ (row_cnt - 1))
 SET cur_rec = 0
 SET top_rec = 0
 SET max_rec = 0
 SET bot_rec = row_cnt
 SET count1 = 0
 SELECT INTO "nl:"
  FROM ct_ruleset_rule_reltn c
  WHERE c.ct_ruleset_cd=v_ruleset_cd
   AND c.active_ind=1
  ORDER BY c.priority
  DETAIL
   count1 = (count1+ 1), stat = alterlist(ruleset->ruleset_list,count1), ruleset->ruleset_list[count1
   ].ct_rule_id = c.ct_rule_id,
   ruleset->ruleset_list[count1].ct_priority = c.priority, ruleset->ruleset_list[count1].
   ct_ruleset_id = c.ct_ruleset_rule_id
  WITH nocounter
 ;end select
 SET max_rec = count1
 SET z = 0
 FOR (x = 1 TO count1)
   SELECT INTO "nl:"
    FROM ct_rule r
    WHERE (r.ct_rule_id=ruleset->ruleset_list[x].ct_rule_id)
     AND r.active_ind=1
    DETAIL
     z = (z+ 1), ruleset->ruleset_list[z].ct_rule_name = r.description, ruleset->ruleset_list[z].
     ct_action_cd = r.action_cd,
     ruleset->ruleset_list[z].ct_beg_date = r.beg_effective_dt_tm, ruleset->ruleset_list[z].
     ct_end_date = r.end_effective_dt_tm
    WITH nocounter
   ;end select
 ENDFOR
 SET m = 0
 FOR (xyz = 1 TO z)
   SELECT INTO "nl:"
    FROM code_value c
    WHERE code_set=18849
     AND (c.code_value=ruleset->ruleset_list[xyz].ct_action_cd)
    DETAIL
     m = (m+ 1), ruleset->ruleset_list[m].ct_action_name = c.display
    WITH nocounter
   ;end select
 ENDFOR
 CALL display_rows(0)
#display_rule_end
#the_prompt
 SET cur_pri = 0
 SET insert_rec = 0
 CALL text(24,3,"Add/Insert/Delete/Quit (A/I/D/Q):  ")
 CALL accept(24,37,"x;cus","Q")
 CALL clear(24,1)
 CASE (curscroll)
  OF 0:
   CASE (curaccept)
    OF "A":
     GO TO add_ruleset
    OF "I":
     GO TO insert_rule
    OF "D":
     GO TO delete_ruleset
    OF "Q":
     GO TO end_prog
   ENDCASE
  ELSE
   CALL display_rows(curscroll)
 ENDCASE
 GO TO the_prompt
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
   CALL clear(6,1)
   CALL text(6,1,"Priority")
   CALL text(6,10,"Description")
   CALL text(6,40,"Rule Type")
   CALL text(6,58,"Beg Date")
   CALL text(6,70,"End Date")
   SET x_qual = top_rec
   FOR (x = min_row TO max_row)
     CALL clear(x,1,80)
     IF (x_qual=cur_rec)
      CALL video(r)
     ELSE
      CALL video(n)
     ENDIF
     IF (x_qual <= max_rec)
      CALL text(x,1,cnvtstring(ruleset->ruleset_list[x_qual].ct_priority))
      CALL text(x,10,ruleset->ruleset_list[x_qual].ct_rule_name)
      CALL text(x,40,ruleset->ruleset_list[x_qual].ct_action_name)
      CALL text(x,57,format(ruleset->ruleset_list[x_qual].ct_beg_date,"dd-mmm-yyyy;;d"))
      CALL text(x,70,format(ruleset->ruleset_list[x_qual].ct_end_date,"dd-mmm-yyyy;;d"))
     ELSE
      CALL clear(x,1,80)
     ENDIF
     CALL video(n)
     SET x_qual = (x_qual+ 1)
   ENDFOR
 END ;Subroutine
 SUBROUTINE draw_box(rec_idx)
  CALL text(23,55,cnvtstring(ruleset->ruleset_list[rec_idx].ct_rule_id))
  CALL text(24,55,cnvtstring(ruleset->ruleset_list[rec_idx].ct_ruleset_id))
 END ;Subroutine
#insert_rule
 SET cur_pri = ruleset->ruleset_list[cur_rec].ct_priority
 SET insert_rec = 1
#add_ruleset
 IF (cur_pri=0)
  SET cur_pri = (ruleset->ruleset_list[max_rec].ct_priority+ 1)
 ENDIF
 SET help =
 SELECT
  ct_rule = c.ct_rule_id"########################################;l", c.description
  FROM ct_rule c
  WHERE active_ind=1
  ORDER BY c.description
  WITH nocounter
 ;end select
 CALL accept(12,23,"9(40);cf")
 SET v_rule_id = cnvtreal(curaccept)
 SET help = off
 EXECUTE afc_ccl_msgbox "Are you sure you want to add a rule?", "Ruleset", "YN"
 CALL clear(1,1)
 IF ((response->yes_ind=1))
  GO TO adding_rule
 ELSEIF ((response->no_ind=1))
  EXECUTE FROM top TO top_end
  GO TO second
 ENDIF
#adding_rule
 SET request->ct_ruleset_rule_reltn_qual = 1
 SET request->ct_ruleset_rule_reltn[1].action_type = "ADD"
 SET request->ct_ruleset_rule_reltn[1].ct_ruleset_cd = v_ruleset_cd
 SET request->ct_ruleset_rule_reltn[1].ct_rule_id = v_rule_id
 SET v_priority = cur_pri
 SET request->ct_ruleset_rule_reltn[1].priority = v_priority
 EXECUTE ct_ens_ruleset_rule_reltn
 COMMIT
 IF (insert_rec=1)
  SET new_pri = v_priority
  FOR (xrec = cur_rec TO max_rec)
    SET new_pri = (new_pri+ 1)
    SET request->ct_ruleset_rule_reltn_qual = 1
    SET request->ct_ruleset_rule_reltn.action_type = "UPT"
    SET request->ct_ruleset_rule_reltn.ct_ruleset_cd = v_ruleset_cd
    SET request->ct_ruleset_rule_reltn.ct_rule_id = ruleset->ruleset_list[xrec].ct_rule_id
    SET request->ct_ruleset_rule_reltn.priority = new_pri
    SET request->ct_ruleset_rule_reltn.ct_ruleset_rule_id = ruleset->ruleset_list[xrec].ct_ruleset_id
    EXECUTE ct_ens_ruleset_rule_reltn
    COMMIT
  ENDFOR
 ENDIF
 EXECUTE FROM top TO top_end
 GO TO second
#delete_ruleset
 EXECUTE afc_ccl_msgbox "Are you sure you want to delete a rule?", "Ruleset", "YN"
 CALL clear(1,1)
 IF ((response->yes_ind=1))
  CALL del_row(cur_rec)
 ELSEIF ((response->no_ind=1))
  EXECUTE FROM top TO top_end
  GO TO second
 ENDIF
 EXECUTE FROM top TO top_end
 GO TO second
 SUBROUTINE del_row(rec_idx)
  DELETE  FROM ct_ruleset_rule_reltn r
   WHERE (ruleset->ruleset_list[rec_idx].ct_ruleset_id=r.ct_ruleset_rule_id)
   WITH nocounter
  ;end delete
  COMMIT
 END ;Subroutine
 GO TO top
#end_prog
END GO
