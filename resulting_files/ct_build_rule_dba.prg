CREATE PROGRAM ct_build_rule:dba
 PAINT
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
 CALL clear(1,1)
 CALL video(n)
 CALL box(2,1,15,65)
 CALL text(4,2,"RULE")
 CALL line(5,1,65,xhor)
 CALL text(6,4,"1)  ADD")
 CALL text(8,4,"2)  MODIFY / DELETE")
 CALL text(10,4,"3)  QUIT")
 CALL text(14,4,"Enter Choice: ")
 CALL accept(14,18,"9;",3
  WHERE curaccept IN (1, 2, 3))
 CALL clear(40,1)
 CASE (curaccept)
  OF 1:
   GO TO ct_rule
  OF 2:
   GO TO modify_delete_rule
  OF 3:
   GO TO the_end
 ENDCASE
#top_end
#ct_rule
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
 SET request->ct_rule[1].description = v_name
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
 SET request->ct_rule[1].duration_cd = v_duration
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
 SET request->ct_rule[1].beg_effective_dt_tm = v_beg_date
 CALL text(15,20,format(v_end_date,"DD-MMM-YYYY;;D"))
 CALL accept(15,20,"xx-xxx-xxxx;ucs",format(v_end_date,"DD-MMM-YYYY;;D"))
 SET v_end_date = cnvtdatetime(curaccept)
 SET request->ct_rule[1].end_effective_dt_tm = v_end_date
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
 SET request->ct_rule[1].action_cd = v_rule_type
 SET help = off
 CALL clear(40,1)
 SET request->ct_rule_qual = 1
 SET request->ct_rule[1].action_type = "ADD"
 SET request->ct_rule[1].vocab_type_cd = code->cpt4_cd
 EXECUTE ct_ens_rule
 COMMIT
 EXECUTE FROM top TO top_end
#modify_delete_rule
 CALL clear(1,1)
 CALL box(1,1,14,75)
 CALL text(3,4,"Description:  ")
 CALL text(5,4,"Duration:  ")
 CALL text(7,4,"Beginning Date: ")
 CALL text(9,4,"Ending Date: ")
 CALL text(11,4,"Rule Type: ")
 SET help =
 SELECT
  ct_rule = r.ct_rule_id"########################################;l", r.description
  FROM ct_rule r
  WITH nocounter
 ;end select
 CALL accept(3,19,"9(40);cf")
 SET v_rule_id = cnvtreal(curaccept)
 SET help = off
 SELECT INTO "nl:"
  FROM ct_rule r,
   code_value cv
  WHERE r.ct_rule_id=v_rule_id
   AND cv.code_value=r.action_cd
  DETAIL
   v_name = r.description, v_duration = r.duration_cd, v_beg_date = cnvtdatetime(r
    .beg_effective_dt_tm),
   v_end_date = cnvtdatetime(r.end_effective_dt_tm), v_rule_type = r.action_cd, v_rule_type_disp = cv
   .display
  WITH nocounter
 ;end select
 CALL text(3,18,v_name)
 CALL text(5,15,cnvtstring(v_duration))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=18850
   AND v_duration=cv.code_value
  DETAIL
   duration->meaning = cv.description
  WITH nocounter
 ;end select
 CALL text(5,30,duration->meaning)
 CALL text(7,21,format(v_beg_date,"dd-mmm-yyyy;;d"))
 CALL text(9,18,format(v_end_date,"dd-mmm-yyyy;;d"))
 CALL text(11,18,cnvtstring(v_rule_type))
 CALL text(11,30,v_rule_type_disp)
#screen_2
 CALL text(13,3,"Modify/Delete/Quit (M/D/Q):  ")
 CALL accept(13,35,"p;cu","Q")
 CASE (curaccept)
  OF "M":
   GO TO screen_3
  OF "D":
   GO TO screen_5
  OF "Q":
   CALL clear(24,0)
   GO TO the_end
 ENDCASE
#screen_3
 CALL clear(20,1)
 CALL video(n)
 CALL text(3,18,v_name)
 CALL accept(3,18,"x(50);cu",v_name)
 SET v_name = curaccept
 CALL text(5,15,cnvtstring(v_duration))
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
 CALL accept(5,15,"9(40);cf",v_duration)
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
 CALL text(7,21,cnvtstring(v_beg_date))
 CALL accept(7,21,"xx-xxx-xxxx;cu",format(v_beg_date,"dd-mmm-yyyy;;d"))
 SET v_beg_date = cnvtdatetime(curaccept)
 CALL text(9,18,cnvtstring(v_end_date))
 CALL accept(9,18,"xx-xxx-xxxx;cu",format(v_end_date,"dd-mmm-yyyy;;d"))
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
 CALL accept(11,18,"9(40);cf")
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
 GO TO modify_question
#modify_question
 EXECUTE afc_ccl_msgbox "Are you sure you want to Modify?", "Rule", "YN"
 IF ((response->yes_ind=1))
  GO TO modifing_rule
 ELSE
  EXECUTE FROM top TO end_top
 ENDIF
#modifing_rule
 SET request->ct_rule_qual = 1
 SET request->ct_rule.action_type = "UPT"
 SET request->ct_rule.ct_rule_id = v_rule_id
 SET request->ct_rule.description = v_name
 SET request->ct_rule.duration_cd = v_duration
 SET request->ct_rule.beg_effective_dt_tm = v_beg_date
 SET request->ct_rule.end_effective_dt_tm = v_end_date
 SET request->ct_rule.vocab_type_cd[1] = code->cpt4_cd
 SET request->ct_rule.action_cd = v_rule_type
 EXECUTE ct_ens_rule
 COMMIT
 EXECUTE FROM top TO top_end
#screen_5
 EXECUTE afc_ccl_msgbox "Are you sure you want to Delete?", "Rule", "YN"
 IF ((response->yes_ind=1))
  DELETE  FROM ct_rule r
   WHERE r.ct_rule_id=v_rule_id
   WITH nocounter
  ;end delete
  EXECUTE FROM top TO end_top
  COMMIT
 ELSE
  EXECUTE FROM top TO end_top
 ENDIF
#the_end
 FREE SET request
END GO
