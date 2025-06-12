CREATE PROGRAM ct_create_script
 PAINT
 RECORD rule(
   1 rule_list[*]
     2 ct_rule_id = f8
     2 ct_rule_name = vc
     2 ct_action_name = vc
     2 ct_action_cd = f8
     2 ct_beg_date = di8
     2 ct_end_date = di8
 )
 RECORD request(
   1 ct_rule_id = f8
 )
 SET min_row = 2
 SET row_cnt = 20
 SET max_row = (min_row+ (row_cnt - 1))
 SET cur_rec = 0
 SET top_rec = 0
 SET max_rec = 0
 SET bot_rec = row_cnt
#top
 SET count1 = 0
 CALL clear(1,1)
 SELECT INTO "nl:"
  FROM ct_rule r
  WHERE active_ind=1
   AND  NOT ((action_cd=
  (SELECT
   code_value
   FROM code_value
   WHERE code_set=18849
    AND cdf_meaning IN ("COUNT", "REPLACECUSM"))))
  DETAIL
   count1 = (count1+ 1), stat = alterlist(rule->rule_list,count1), rule->rule_list[count1].ct_rule_id
    = r.ct_rule_id,
   rule->rule_list[count1].ct_rule_name = r.description, rule->rule_list[count1].ct_action_cd = r
   .action_cd, rule->rule_list[count1].ct_beg_date = r.beg_effective_dt_tm,
   rule->rule_list[count1].ct_end_date = r.end_effective_dt_tm
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
 IF (cur_rec=0)
  CALL display_rows(0)
 ELSE
  CALL display_rows(1)
 ENDIF
#the_prompt
 CALL text(24,3,"Create Script/Range/Quit (C/R/Q)")
 CALL accept(24,40,"x;cus","Q")
 CALL clear(24,1)
 CASE (curscroll)
  OF 0:
   CASE (curaccept)
    OF "C":
     GO TO create_script
    OF "Q":
     GO TO end_prog
    OF "R":
     GO TO create_range
   ENDCASE
  ELSE
   CALL display_rows(curscroll)
 ENDCASE
 GO TO the_prompt
#create_range
 CALL text(24,45,"Start")
 CALL text(24,56,"End")
 CALL accept(24,51,"9999",1
  WHERE curaccept BETWEEN 1 AND max_rec)
 SET start_rec = curaccept
 CALL accept(24,62,"9999",max_rec
  WHERE curaccept BETWEEN start_rec AND max_rec)
 SET end_rec = curaccept
 FOR (x = start_rec TO end_rec)
   SET cur_rec = x
   CALL text(24,1,concat("Generating: ",rule->rule_list[x].ct_rule_name,"..."))
   EXECUTE FROM create_script TO create_script_end
 ENDFOR
 GO TO top
#create_script
 SELECT INTO "nl:"
  FROM ct_rule_detail d
  WHERE (d.ct_rule_id=rule->rule_list[cur_rec].ct_rule_id)
 ;end select
 IF (curqual=0)
  EXECUTE afc_ccl_msgbox "Can't create script. No detail found.", "", "OK"
 ELSE
  SET request->ct_rule_id = rule->rule_list[cur_rec].ct_rule_id
  EXECUTE ct_generate_rule_script
 ENDIF
#create_script_end
 CALL clear(20,1)
 GO TO top
#end_prog
END GO
