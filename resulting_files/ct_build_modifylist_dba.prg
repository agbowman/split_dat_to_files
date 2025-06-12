CREATE PROGRAM ct_build_modifylist:dba
 PAINT
 IF ("Z"=validate(ct_build_modifylist_vrsn,"Z"))
  DECLARE ct_build_modifylist_vrsn = vc WITH noconstant("65970.005")
 ENDIF
 RECORD ct_detail(
   1 detail_list[*]
     2 detailtype_cd = f8
     2 ct_operator_cd = f8
     2 ruleentity_id = f8
     2 detail_name = vc
     2 operator_name = vc
     2 ruleentity_name = vc
     2 cpt4_cd = vc
     2 beg_date = dq8
     2 end_date = dq8
     2 pre_detail_id = f8
     2 result_detail_id = f8
     2 ct_result_factor = f8
 )
 RECORD request(
   1 ct_rule_detail_qual = i2
   1 ct_rule_detail[10]
     2 action_type = c3
     2 ct_rule_detail_id = f8
     2 ct_rule_id = f8
     2 detail_type_cd = f8
     2 operator_cd = f8
     2 rule_entity_id = f8
     2 rule_entity_name = c32
     2 precedence = i4
     2 sequence = i4
     2 result_factor_ind = i2
     2 result_factor = f8
     2 count_beg = i4
     2 count_end = i4
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
 )
 RECORD cv(
   1 15729_precursor = f8
   1 15729_result = f8
   1 18851_remove = f8
   1 18851_nochange = f8
 )
 RECORD response(
   1 yes_ind = i2
   1 no_ind = i2
 )
 RECORD code(
   1 cpt4_cd = f8
 )
 DECLARE lookup_option = i2
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=15729
  DETAIL
   IF (cv.cdf_meaning="PRECURSOR")
    cv->15729_precursor = cv.code_value
   ELSEIF (cv.cdf_meaning="RESULT")
    cv->15729_result = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.cdf_meaning="CPT4"
  DETAIL
   code->cpt4_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=18851
   AND cv.cdf_meaning IN ("REMOVE", "NOCHANGE")
  DETAIL
   IF (cv.cdf_meaning="REMOVE")
    cv->18851_remove = cv.code_value
   ELSE
    cv->18851_nochange = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL clear(1,1)
 SET min_row = 5
 SET row_cnt = 5
 SET max_row = (min_row+ (row_cnt - 1))
 SET ct_rule_id = cnvtreal( $1)
 SET ct_rule_name =  $2
 SET ct_action_name =  $3
 SET cur_rec = 0
 SET top_rec = 0
 SET max_rec = 0
 SET bot_rec = row_cnt
#top_modifylist
 SET v_result_factor = 0.00
 SET v_nomen_id = 0.0
 SET v_beg_date = cnvtdatetime(curdate,curtime)
 SET v_end_date = cnvtdatetime("31-Dec-2100 23:59")
 SET seq = 0
 CALL clear(1,1)
 SET count1 = 0
 SELECT INTO "nl:"
  FROM ct_rule_detail d,
   code_value cv
  WHERE ct_rule_id=d.ct_rule_id
   AND d.active_ind=1
   AND cv.code_value=d.detail_type_cd
  ORDER BY d.sequence
  HEAD d.sequence
   count1 = (count1+ 1), stat = alterlist(ct_detail->detail_list,count1), ct_detail->detail_list[
   count1].ruleentity_id = d.rule_entity_id,
   ct_detail->detail_list[count1].ruleentity_name = d.rule_entity_name
  DETAIL
   ct_detail->detail_list[count1].detail_name = cv.cdf_meaning
   IF (cv.cdf_meaning="PRECURSOR")
    ct_detail->detail_list[count1].pre_detail_id = d.ct_rule_detail_id
   ELSEIF (cv.cdf_meaning="RESULT")
    ct_detail->detail_list[count1].result_detail_id = d.ct_rule_detail_id, ct_detail->detail_list[
    count1].ct_operator_cd = d.operator_cd, ct_detail->detail_list[count1].ct_result_factor = d
    .result_factor,
    ct_detail->detail_list[count1].beg_date = d.beg_effective_dt_tm, ct_detail->detail_list[count1].
    end_date = d.end_effective_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 SET max_rec = count1
 IF (max_rec=0)
  CALL display_rows2(curscroll)
  GO TO the_second_prompt
 ENDIF
 SELECT INTO "nl:"
  c.cdf_meaning
  FROM code_value c,
   (dummyt d1  WITH seq = value(size(ct_detail->detail_list,5)))
  PLAN (d1)
   JOIN (c
   WHERE (ct_detail->detail_list[d1.seq].ct_operator_cd=c.code_value))
  DETAIL
   ct_detail->detail_list[d1.seq].operator_name = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  n.source_identifier
  FROM nomenclature n,
   (dummyt d1  WITH seq = value(size(ct_detail->detail_list,5)))
  PLAN (d1
   WHERE (ct_detail->detail_list[d1.seq].ruleentity_name="NOMENCLATURE"))
   JOIN (n
   WHERE (n.nomenclature_id=ct_detail->detail_list[d1.seq].ruleentity_id))
  DETAIL
   ct_detail->detail_list[d1.seq].cpt4_cd = n.source_identifier
  WITH nocounter
 ;end select
 CALL display_rows2(0)
#the_second_prompt
 CALL text(23,3,"Add/Modify/Delete/Quit (A/M/D/Q):  ")
 CALL accept(23,36,"x;cus","Q")
 CALL clear(24,1)
 CASE (curscroll)
  OF 0:
   CASE (curaccept)
    OF "A":
     GO TO add_modifylist
    OF "M":
     GO TO modify_modifylist
    OF "D":
     GO TO delete_modifylist
    OF "Q":
     GO TO end_prog
   ENDCASE
  ELSE
   CALL display_rows2(curscroll)
 ENDCASE
 GO TO the_second_prompt
 SUBROUTINE display_rows2(scrolltype)
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
   CALL clear(1,1)
   CALL text(1,15,ct_rule_name)
   CALL text(1,1,"Rule Name:")
   CALL text(2,1,"Rule Detail")
   CALL text(4,10,"Rule_Entity_Id")
   CALL text(4,29,"Operator")
   CALL text(4,50,"Result_Factor")
   SET x_qual = top_rec
   FOR (x = min_row TO max_row)
     CALL clear(x,1,80)
     IF (x_qual=cur_rec)
      CALL video(r)
     ELSE
      CALL video(n)
     ENDIF
     IF (x_qual <= max_rec)
      IF (trim(ct_detail->detail_list[x_qual].cpt4_cd)="")
       SET lookup_option = 1
       SET desc = fillstring(25," ")
       SELECT INTO "nl:"
        FROM bill_item b
        WHERE (b.bill_item_id=ct_detail->detail_list[x_qual].ruleentity_id)
        DETAIL
         desc = trim(b.ext_description)
        WITH nocounter
       ;end select
       SET desc = build(desc," (",cnvtstring(ct_detail->detail_list[x_qual].ruleentity_id),")")
       CALL text(x,04,desc)
       CALL text(x,50,format(ct_detail->detail_list[x_qual].ct_result_factor,"###.##"))
       CALL text(x,30,ct_detail->detail_list[x_qual].operator_name)
      ELSE
       CALL text(x,50,format(ct_detail->detail_list[x_qual].ct_result_factor,"###.##"))
       CALL text(x,4,ct_detail->detail_list[x_qual].cpt4_cd)
       CALL text(x,30,ct_detail->detail_list[x_qual].operator_name)
      ENDIF
     ELSE
      CALL clear(x,1,80)
     ENDIF
     CALL video(n)
     SET x_qual = (x_qual+ 1)
   ENDFOR
 END ;Subroutine
#add_modifylist
 CALL clear(1,1)
 CALL box(1,1,19,75)
 CALL text(19,25,"Help Available < Shift F5 >")
 CALL text(2,2,"Rule Name:")
 CALL text(2,13,ct_rule_name)
 CALL text(3,2,"Rule Type:")
 CALL text(3,13,ct_action_name)
 CALL text(5,3,"Qualify on (0 = CPT-4, 1 = BILL ITEM):")
 CALL text(7,3,"Rule_Entity_Id:")
 CALL text(9,3,"Operator_Cd:")
 CALL text(11,3,"Result Factor:")
 CALL text(13,3,"Beg Date:")
 CALL text(15,3,"End Date:")
 CALL accept(5,41,"x(1);c",0)
 SET lookup_option = cnvtint(curaccept)
 IF (lookup_option=1)
  CALL clear(15,15)
  CALL box(1,1,19,75)
  CALL text(19,25,"No Help Available")
  FOR (x = 1 TO size(ct_detail->detail_list,5))
    SET ct_detail->detail_list[x].cpt4_cd = ""
  ENDFOR
 ELSE
  SET help =
  SELECT
   nomenclature = n.nomenclature_id"########################################;l", n.source_identifier
   "###############;l", n.source_string
   FROM nomenclature n
   WHERE n.nomenclature_id != 0
    AND n.source_identifier != " "
    AND active_ind=1
    AND (n.source_vocabulary_cd=code->cpt4_cd)
    AND n.source_identifier >= curaccept
    AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end select
 ENDIF
 CALL accept(7,19,"9(40);cpf")
 SET v_nomen_id = cnvtreal(curaccept)
 SET help = off
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=18851
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("REMOVE", "ADD", "MULTIPLY", "SUBTRACTION", "NOCHANGE")
  ORDER BY cv.display_key
  WITH nocounter
 ;end select
 CALL accept(9,17,"9(40);cf")
 SET v_operator_cd = cnvtreal(curaccept)
 SET help = off
 IF ( NOT (v_operator_cd IN (cv->18851_remove, cv->18851_nochange)))
  CALL accept(11,18,"######.##;c",000000.00)
  SET v_result_factor = cnvtreal(curaccept)
 ENDIF
 CALL text(13,14,format(curdate,"DD-MMM-YYYY;;D"))
 CALL accept(13,14,"xx-xxx-xxxx;ucs",format(curdate,"DD-MMM-YYYY;;D"))
 SET v_beg_date = cnvtdatetime(curaccept)
 CALL text(15,14,format(v_end_date,"DD-MMM-YYYY;;D"))
 CALL accept(15,14,"xx-xxx-xxxx;ucs",format(v_end_date,"DD-MMM-YYYY;;D"))
 SET v_end_date = cnvtdatetime(curaccept)
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "ADD"
 SET request->ct_rule_detail[1].ct_rule_id = ct_rule_id
 SET request->ct_rule_detail[1].rule_entity_id = v_nomen_id
 SET request->ct_rule_detail[1].operator_cd = v_operator_cd
 IF (lookup_option=0)
  SET request->ct_rule_detail[1].rule_entity_name = "NOMENCLATURE"
 ELSE
  SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
 ENDIF
 SET request->ct_rule_detail[1].detail_type_cd = cv->15729_result
 SET request->ct_rule_detail[1].precedence = 1
 SET request->ct_rule_detail[1].result_factor = v_result_factor
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
 SELECT INTO "nl:"
  seq = (max(ct.sequence)+ 1)
  FROM ct_rule_detail ct
  WHERE ct.ct_rule_id=ct_rule_id
   AND (ct.detail_type_cd=cv->15729_result)
  DETAIL
   seq = (seq+ 1)
 ;end select
 SET request->ct_rule_detail[1].sequence = seq WITH nocounter
 EXECUTE ct_ens_rule_detail
 COMMIT
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "ADD"
 SET request->ct_rule_detail[1].ct_rule_id = ct_rule_id
 SET request->ct_rule_detail[1].rule_entity_id = v_nomen_id
 SET request->ct_rule_detail[1].operator_cd = 0
 IF (lookup_option=0)
  SET request->ct_rule_detail[1].rule_entity_name = "NOMENCLATURE"
 ELSE
  SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
 ENDIF
 SET request->ct_rule_detail[1].result_factor = 0.0
 SET request->ct_rule_detail[1].detail_type_cd = cv->15729_precursor
 SET request->ct_rule_detail[1].precedence = 1
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
 SET seq = 0
 SELECT INTO "nl:"
  seq = (max(ct.sequence)+ 1)
  FROM ct_rule_detail ct
  WHERE ct.ct_rule_id=ct_rule_id
   AND (ct.detail_type_cd=cv->15729_precursor)
  DETAIL
   seq = (seq+ 1)
 ;end select
 SET request->ct_rule_detail[1].sequence = seq WITH nocounter
 EXECUTE ct_ens_rule_detail
 COMMIT
 GO TO top_modifylist
#modify_modifylist
 CALL clear(1,1)
 CALL box(1,1,17,70)
 CALL text(2,2,"Rule Name:")
 CALL text(2,13,ct_rule_name)
 CALL text(17,25,"Help Available <Shift F5>")
 CALL text(4,5,"Qualify on (0 = CPT-4, 1 = BILL ITEM):")
 CALL text(6,5,"Rule_Entity_Id:")
 CALL text(8,5,"Operator:")
 CALL text(10,5,"Result_Factor:")
 CALL text(12,5,"Beg Date:")
 CALL text(14,5,"End Date:")
 CALL text(4,43,cnvtstring(lookup_option))
 IF (lookup_option=0)
  CALL text(6,21,ct_detail->detail_list[cur_rec].cpt4_cd)
 ELSE
  CALL text(6,21,cnvtstring(ct_detail->detail_list[cur_rec].ruleentity_id))
 ENDIF
 CALL text(8,15,ct_detail->detail_list[cur_rec].operator_name)
 CALL text(10,20,format(ct_detail->detail_list[cur_rec].ct_result_factor,"###.##"))
 CALL text(12,15,format(ct_detail->detail_list[cur_rec].beg_date,"dd-mmm-yyyy;;d"))
 CALL text(14,15,format(ct_detail->detail_list[cur_rec].end_date,"dd-mmm-yyyy;;d"))
 CALL accept(4,43,"x(1);cp",lookup_option)
 SET lookup_option = cnvtint(curaccept)
 IF (lookup_option=0)
  SET help =
  SELECT
   nomenclature = n.nomenclature_id"########################################;l", n.source_identifier
   "##########;l", n.source_string
   FROM nomenclature n
   WHERE n.nomenclature_id != 0
    AND n.source_identifier != " "
    AND active_ind=1
    AND (n.source_vocabulary_cd=code->cpt4_cd)
    AND n.source_identifier >= curaccept
   WITH nocounter
  ;end select
  CALL accept(6,21,"9(40);cp",ct_detail->detail_list[cur_rec].ruleentity_id)
  SET v_nomen_id = cnvtreal(curaccept)
  SET help = off
 ELSE
  CALL clear(15,15)
  CALL box(1,1,17,70)
  CALL text(17,25,"No Help Available")
  CALL accept(6,21,"x(10);cp",ct_detail->detail_list[cur_rec].ruleentity_id)
  SET v_nomen_id = cnvtint(curaccept)
 ENDIF
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=18851
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("REMOVE", "ADD", "MULTIPLY", "SUBTRACTION", "NOCHANGE")
  WITH nocounter
 ;end select
 CALL accept(8,15,"9(40);c",ct_detail->detail_list[cur_rec].ct_operator_cd)
 SET v_operator_cd = cnvtreal(curaccept)
 SET help = off
 IF ( NOT (v_operator_cd IN (cv->18851_remove, cv->18851_nochange)))
  CALL accept(10,20,"######.##;c",ct_detail->detail_list[cur_rec].ct_result_factor)
  SET v_result_factor = cnvtreal(curaccept)
 ENDIF
 CALL text(12,15,format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"))
 CALL accept(12,15,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"
   ))
 SET v_beg_date = cnvtdatetime(curaccept)
 CALL text(14,15,format(ct_detail->detail_list[cur_rec].end_date,"DD-MMM-YYYY;;D"))
 CALL accept(14,15,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].end_date,"DD-MMM-YYYY;;D"
   ))
 SET v_end_date = cnvtdatetime(curaccept)
 EXECUTE afc_ccl_msgbox "Are you sure you want to Modify?", "Modifylist", "YN"
 CALL clear(1,1)
 IF ((response->yes_ind=1))
  GO TO modifing_modifylist
 ELSEIF ((response->no_ind=1))
  GO TO top_modifylist
 ENDIF
#modifing_modifylist
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "UPT"
 SET request->ct_rule_detail[1].ct_rule_detail_id = ct_detail->detail_list[cur_rec].pre_detail_id
 SET request->ct_rule_detail[1].rule_entity_id = v_nomen_id
 IF (lookup_option=0)
  SET request->ct_rule_detail[1].rule_entity_name = "NOMENCLATURE"
 ELSE
  SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
 ENDIF
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
 SET request->ct_rule_detail[1].operator_cd = 0
 SET request->ct_rule_detail[1].result_factor = 0.00
 SET request->ct_rule_detail[1].detail_type_cd = cv->15729_precursor
 SET request->ct_rule_detail[1].sequence = 0
 EXECUTE ct_ens_rule_detail
 COMMIT
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "UPT"
 SET request->ct_rule_detail[1].ct_rule_detail_id = ct_detail->detail_list[cur_rec].result_detail_id
 SET request->ct_rule_detail[1].rule_entity_id = v_nomen_id
 IF (lookup_option=0)
  SET request->ct_rule_detail[1].rule_entity_name = "NOMENCLATURE"
 ELSE
  SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
 ENDIF
 SET request->ct_rule_detail[1].result_factor = v_result_factor
 SET request->ct_rule_detail[1].operator_cd = v_operator_cd
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
 SET request->ct_rule_detail[1].detail_type_cd = cv->15729_result
 SET request->ct_rule_detail[1].sequence = 0
 EXECUTE ct_ens_rule_detail
 COMMIT
 GO TO top_modifylist
#delete_modifylist
 EXECUTE afc_ccl_msgbox "Are you sure you want to Delete?", "Modifylist", "YN"
 CALL clear(1,1)
 IF ((response->yes_ind=1))
  DELETE  FROM ct_rule_detail d
   WHERE (d.ct_rule_detail_id=ct_detail->detail_list[cur_rec].pre_detail_id)
  ;end delete
  COMMIT
  DELETE  FROM ct_rule_detail d
   WHERE (d.ct_rule_detail_id=ct_detail->detail_list[cur_rec].result_detail_id)
  ;end delete
  COMMIT
  GO TO top_modifylist
 ELSEIF ((response->no_ind=1))
  GO TO top_modifylist
 ENDIF
 GO TO top_modifylist
#end_prog
END GO
