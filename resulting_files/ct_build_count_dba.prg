CREATE PROGRAM ct_build_count:dba
 PAINT
 IF ("Z"=validate(ct_build_count_vrsn,"Z"))
  DECLARE ct_build_count_vrsn = vc WITH noconstant("65970.007")
 ENDIF
 RECORD ct_detail(
   1 detail_list[*]
     2 detailtype_cd = f8
     2 ct_operator_cd = f8
     2 ruleentity_id = f8
     2 detail_name = vc
     2 operator_name = vc
     2 ruleentity_name = vc
     2 bill_item_name = vc
     2 cpt4_cd = vc
     2 beg_date = dq8
     2 end_date = dq8
     2 ct_detail_id = f8
     2 detail_disp = vc
     2 result_factor = f8
     2 count_beg = i4
     2 count_end = i4
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
   1 and_operator = f8
   1 equal_operator = f8
   1 nochange_operator = f8
   1 precursor = f8
   1 result = f8
 )
 RECORD code(
   1 cpt4_cd = f8
 )
 RECORD response(
   1 yes_ind = i2
   1 no_ind = i2
 )
 DECLARE lookup_option = i2
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=15729
  DETAIL
   IF (cv.cdf_meaning="PRECURSOR")
    cv->precursor = cv.code_value
   ELSEIF (cv.cdf_meaning="RESULT")
    cv->result = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=18851
  DETAIL
   IF (cv.cdf_meaning="AND")
    cv->and_operator = cv.code_value
   ELSEIF (cv.cdf_meaning="NOCHANGE")
    cv->nochange_operator = cv.code_value
   ELSEIF (cv.cdf_meaning="EQUAL")
    cv->equal_operator = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
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
 CALL clear(1,1)
 SET min_row = 5
 SET row_cnt = 15
 SET max_row = (min_row+ (row_cnt - 1))
 SET ct_rule_id = cnvtreal( $1)
 SET ct_rule_name =  $2
 SET ct_action_name =  $3
 SET cur_rec = 0
 SET top_rec = 0
 SET max_rec = 0
 SET bot_rec = row_cnt
#top
 CALL clear(1,1)
 SET v_operator_cd = 0.0
 SET v_nomen_id = 0.0
 SET seq = 0
 SET v_beg_date = cnvtdatetime(curdate,curtime)
 SET v_end_date = cnvtdatetime("31-Dec-2100 23:59")
 SET v_bill_item_id = 0.0
 SET v_result = 0
 SET v_beg = 0
 SET v_end = 0
 SET count1 = 0
 SELECT INTO "nl:"
  FROM ct_rule_detail d,
   code_value cv
  WHERE ct_rule_id=d.ct_rule_id
   AND d.active_ind=1
   AND cv.code_value=d.detail_type_cd
  ORDER BY d.count_beg, d.count_end
  DETAIL
   count1 = (count1+ 1), stat = alterlist(ct_detail->detail_list,count1), ct_detail->detail_list[
   count1].detailtype_cd = d.detail_type_cd,
   ct_detail->detail_list[count1].detail_name = cv.cdf_meaning, ct_detail->detail_list[count1].
   ct_operator_cd = d.operator_cd, ct_detail->detail_list[count1].ruleentity_id = d.rule_entity_id,
   ct_detail->detail_list[count1].beg_date = d.beg_effective_dt_tm, ct_detail->detail_list[count1].
   end_date = d.end_effective_dt_tm, ct_detail->detail_list[count1].ct_detail_id = d
   .ct_rule_detail_id,
   ct_detail->detail_list[count1].result_factor = d.result_factor, ct_detail->detail_list[count1].
   count_beg = d.count_beg, ct_detail->detail_list[count1].count_end = d.count_end,
   ct_detail->detail_list[count1].ruleentity_name = d.rule_entity_name
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
   WHERE (ct_detail->detail_list[d1.seq].detailtype_cd=c.code_value))
  DETAIL
   ct_detail->detail_list[d1.seq].detail_disp = c.display
  WITH nocounter
 ;end select
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
 SELECT INTO "nl:"
  b.ext_short_desc
  FROM bill_item b,
   (dummyt d1  WITH seq = value(size(ct_detail->detail_list,5)))
  PLAN (d1
   WHERE (ct_detail->detail_list[d1.seq].ruleentity_name="BILL_ITEM"))
   JOIN (b
   WHERE (b.bill_item_id=ct_detail->detail_list[d1.seq].ruleentity_id))
  DETAIL
   ct_detail->detail_list[d1.seq].bill_item_name = b.ext_short_desc
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
     CALL clear(23,1)
     CALL text(23,3,"Precursor/Result  (P/R): ")
     CALL accept(23,32,"x;cu","P")
     CASE (curaccept)
      OF "P":
       GO TO add_precursor
      OF "R":
       GO TO add_result
     ENDCASE
    OF "M":
     GO TO modify_detail
    OF "D":
     GO TO delete_detail
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
   CALL text(4,05,"Precursor")
   CALL text(4,20,"Begin")
   CALL text(4,30,"End")
   CALL text(4,40,"Operator")
   CALL text(4,50,"Quantity")
   CALL text(4,60,"Result Item")
   SET x_qual = top_rec
   FOR (x = min_row TO max_row)
     CALL clear(x,1,80)
     IF (x_qual=cur_rec)
      CALL video(r)
     ELSE
      CALL video(n)
     ENDIF
     IF (x_qual <= max_rec)
      IF ((ct_detail->detail_list[x_qual].detail_name="PRECURSOR"))
       IF (trim(ct_detail->detail_list[x_qual].cpt4_cd)="")
        SET lookup_option = 1
        SET desc = fillstring(20," ")
        SELECT INTO "nl:"
         FROM bill_item b
         WHERE (b.bill_item_id=ct_detail->detail_list[x_qual].ruleentity_id)
         DETAIL
          desc = trim(b.ext_description)
         WITH nocounter
        ;end select
        SET desc = build(desc," (",cnvtstring(ct_detail->detail_list[x_qual].ruleentity_id),")")
        CALL text(x,05,desc)
       ELSE
        CALL text(x,05,ct_detail->detail_list[x_qual].cpt4_cd)
       ENDIF
      ELSE
       CALL text(x,20,cnvtstring(ct_detail->detail_list[x_qual].count_beg))
       IF ((ct_detail->detail_list[x_qual].count_end > 0))
        CALL text(x,30,cnvtstring(ct_detail->detail_list[x_qual].count_end))
       ELSE
        CALL text(x,30,"<none>")
       ENDIF
       CALL text(x,40,ct_detail->detail_list[x_qual].operator_name)
       CALL text(x,50,cnvtstring(ct_detail->detail_list[x_qual].result_factor))
       IF ((ct_detail->detail_list[x_qual].ruleentity_name="BILL_ITEM"))
        CALL text(x,60,ct_detail->detail_list[x_qual].bill_item_name)
       ELSE
        CALL text(x,60,ct_detail->detail_list[x_qual].cpt4_cd)
       ENDIF
      ENDIF
     ELSE
      CALL clear(x,1,80)
     ENDIF
     CALL video(n)
     SET x_qual = (x_qual+ 1)
   ENDFOR
 END ;Subroutine
#add_precursor
 CALL clear(1,1)
 CALL box(1,1,15,75)
 CALL text(15,15,"Help Available < Shift F5 >")
 CALL text(2,2,"Rule Name:")
 CALL text(2,13,ct_rule_name)
 CALL text(3,2,"Rule Type:")
 CALL text(3,12,ct_action_name)
 CALL text(5,3,"Qualify on (0 = CPT-4, 1 = BILL ITEM):")
 CALL text(7,3,"Rule_Entity_Id: ")
 CALL text(9,3,"Beg Date:")
 CALL text(11,3,"End Date:")
 SET help =
 SELECT
  nomenclature = n.nomenclature_id"########################################;l", n.source_identifier
  "###############;l", n.source_string
  FROM nomenclature n
  WHERE n.nomenclature_id != 0
   AND active_ind=1
   AND (n.source_vocabulary_cd=code->cpt4_cd)
   AND n.source_identifier != " "
   AND n.source_identifier >= curaccept
   AND n.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  WITH nocounter
 ;end select
 CALL accept(5,41,"x(1);c",0)
 SET lookup_option = cnvtint(curaccept)
 IF (lookup_option=1)
  CALL clear(15,15)
  CALL box(1,1,15,75)
  CALL text(15,25,"No Help Available")
 ENDIF
 CALL accept(7,19,"x(7);cp")
 SET v_nomen_id = cnvtint(curaccept)
 SET help = off
 CALL text(9,14,format(curdate,"DD-MMM-YYYY;;D"))
 CALL accept(9,14,"xx-xxx-xxxx;ucs",format(curdate,"DD-MMM-YYYY;;D"))
 SET v_beg_date = cnvtdatetime(curaccept)
 CALL text(11,14,format(v_end_date,"DD-MMM-YYYY;;D"))
 CALL accept(11,14,"xx-xxx-xxxx;ucs",format(v_end_date,"DD-MMM-YYYY;;D"))
 SET v_end_date = cnvtdatetime(curaccept)
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "ADD"
 SET request->ct_rule_detail[1].ct_rule_id = ct_rule_id
 SET request->ct_rule_detail[1].operator_cd = cv->and_operator
 SET request->ct_rule_detail[1].rule_entity_id = v_nomen_id
 IF (lookup_option=1)
  SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
 ELSE
  SET request->ct_rule_detail[1].rule_entity_name = "NOMENCLATURE"
 ENDIF
 SET request->ct_rule_detail[1].detail_type_cd = cv->precursor
 SET request->ct_rule_detail[1].precedence = 1
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
 SELECT INTO "nl:"
  seq = (max(ct.sequence)+ 1)
  FROM ct_rule_detail ct
  WHERE ct.ct_rule_id=ct_rule_id
   AND (ct.detail_type_cd=cv->precursor)
  DETAIL
   seq = (seq+ 1)
 ;end select
 SET request->ct_rule_detail[1].sequence = seq WITH nocounter
 EXECUTE ct_ens_rule_detail
 COMMIT
 GO TO top
#add_result
 CALL clear(1,1)
 CALL box(1,1,20,75)
 CALL text(20,15,"Help Available < Shift F5 >")
 CALL text(2,1,"Rule Name:")
 CALL text(2,12,ct_rule_name)
 CALL text(3,1,"Rule Type:")
 CALL text(3,12,ct_action_name)
 CALL text(5,3,"Count Beg: ")
 CALL text(7,3,"Count End: ")
 CALL text(9,3,"Operator: ")
 CALL text(11,3,"Quantity: ")
 CALL text(13,3,"Result Item: ")
 CALL text(15,3,"Beg Date: ")
 CALL text(17,3,"End Date: ")
 SET next_val = 0
 SELECT INTO "nl:"
  val = max(ct.count_end)
  FROM ct_rule_detail ct
  WHERE ct.ct_rule_id=ct_rule_id
  DETAIL
   IF (val > 0)
    next_val = (val+ 1)
   ENDIF
  WITH nocounter
 ;end select
 CALL accept(5,14,"x(2);c",next_val)
 SET v_beg = cnvtint(curaccept)
 CALL accept(7,14,"x(2);c")
 SET v_end = cnvtint(curaccept)
 SET help =
 SELECT
  code_value = cv.code_value"########################################;l", cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=18851
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("AND", "NOCHANGE", "EQUAL")
  ORDER BY cv.display
  WITH nocounter
 ;end select
 CALL accept(9,14,"9(40);cf")
 SET v_operator_cd = cnvtreal(curaccept)
 SET help = off
 SET v_entity_name = fillstring(32," ")
 IF (v_operator_cd IN (cv->equal_operator, cv->and_operator))
  CALL accept(11,14,"p(6);c")
  SET v_result = cnvtint(curaccept)
 ELSE
  SET v_result = 0
 ENDIF
 IF ((v_operator_cd=cv->and_operator))
  SET v_entity_name = "BILL_ITEM"
  CALL text(13,3,"Bill Item: ")
  SET help =
  SELECT
   bill_item = b.bill_item_id"########################################;l", b.ext_short_desc
   FROM bill_item b
   WHERE b.ext_short_desc >= curaccept
    AND b.active_ind=1
    AND ext_parent_reference_id > 0
    AND ext_child_reference_id=0
   ORDER BY b.ext_short_desc
   WITH nocounter
  ;end select
 ELSE
  IF (lookup_option=1)
   SET v_entity_name = "BILL_ITEM"
   CALL text(13,3,"Bill Item: ")
   SET help =
   SELECT
    bill_item = b.bill_item_id"########;l", b.ext_short_desc
    FROM bill_item b
    WHERE b.ext_short_desc >= curaccept
     AND b.active_ind=1
     AND ext_parent_reference_id > 0
     AND ext_child_reference_id=0
    ORDER BY b.ext_short_desc
    WITH nocounter
   ;end select
  ELSE
   CALL text(13,3,"Nomenclature: ")
   SET v_entity_name = "NOMENCLATURE"
   SET help =
   SELECT
    nomenclature = n.nomenclature_id"########################################;l", n.source_identifier
    "###############;l", n.source_string
    FROM nomenclature n
    WHERE n.nomenclature_id != 0
     AND active_ind=1
     AND (n.source_vocabulary_cd=code->cpt4_cd)
     AND n.source_identifier != " "
     AND n.source_identifier >= curaccept
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 CALL accept(13,19,"9(40);cp")
 SET v_billitem_id = cnvtreal(curaccept)
 SET help = off
 CALL text(15,14,format(curdate,"DD-MMM-YYYY;;D"))
 CALL accept(15,14,"xx-xxx-xxxx;ucs",format(curdate,"DD-MMM-YYYY;;D"))
 SET v_beg_date = cnvtdatetime(curaccept)
 CALL text(17,14,format(v_end_date,"DD-MMM-YYYY;;D"))
 CALL accept(17,14,"xx-xxx-xxxx;ucs",format(v_end_date,"DD-MMM-YYYY;;D"))
 SET v_end_date = cnvtdatetime(curaccept)
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "ADD"
 SET request->ct_rule_detail[1].ct_rule_id = ct_rule_id
 SET request->ct_rule_detail[1].operator_cd = v_operator_cd
 SET request->ct_rule_detail[1].rule_entity_id = v_billitem_id
 SET request->ct_rule_detail[1].rule_entity_name = v_entity_name
 SET request->ct_rule_detail[1].detail_type_cd = cv->result
 SET request->ct_rule_detail[1].precedence = 1
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
 SET request->ct_rule_detail[1].result_factor = v_result
 SET request->ct_rule_detail[1].count_beg = v_beg
 SET request->ct_rule_detail[1].count_end = v_end
 SELECT INTO "nl:"
  seq = (max(ct.sequence)+ 1)
  FROM ct_rule_detail ct
  WHERE ct.ct_rule_id=ct_rule_id
   AND (ct.detail_type_cd=cv->result)
  DETAIL
   seq = (seq+ 1)
 ;end select
 SET request->ct_rule_detail[1].sequence = seq WITH nocounter
 EXECUTE ct_ens_rule_detail
 COMMIT
 GO TO top
#modify_detail
 IF ((ct_detail->detail_list[cur_rec].detail_name="PRECURSOR"))
  SET new_cpt4_cd = 0.0
  SET v_beg_date = cnvtdatetime(curdate,curtime)
  SET v_end_date = cnvtdatetime("31-Dec-2100 23:59")
  SET v_bill_item_id = 0.0
  SET new_bill_item_id = 0.0
  CALL clear(1,1)
  CALL box(1,1,15,70)
  CALL text(2,2,"Rule Name:")
  CALL text(2,13,ct_rule_name)
  CALL text(15,25,"Help Available <Shift F5>")
  CALL text(4,5,"Qualify on (0 = CPT-4, 1 = BILL ITEM):")
  CALL text(4,43,cnvtstring(lookup_option))
  CALL text(6,5,"Precursor:")
  CALL text(6,16,ct_detail->detail_list[cur_rec].cpt4_cd)
  CALL text(8,5,"Beg Date:")
  CALL text(8,16,format(ct_detail->detail_list[cur_rec].beg_date,"dd-mmm-yyyy;;d"))
  CALL text(10,5,"End Date:")
  CALL text(10,16,format(ct_detail->detail_list[cur_rec].end_date,"dd-mmm-yyyy;;d"))
  CALL accept(4,43,"x(1);c",lookup_option)
  SET lookup_option = cnvtint(curaccept)
  IF (lookup_option=0)
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
    WITH nocounter
   ;end select
   CALL accept(4,16,"9(40);cp",ct_detail->detail_list[cur_rec].ruleentity_id)
   SET new_cpt4_cd = cnvtreal(curaccept)
   SET help = off
  ELSE
   CALL clear(15,15)
   CALL box(1,1,15,70)
   CALL text(15,25,"No Help Available")
   CALL accept(6,16,"x(10);cp",ct_detail->detail_list[cur_rec].ruleentity_id)
   SET new_cpt4_cd = cnvtint(curaccept)
  ENDIF
  CALL text(6,16,format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"))
  CALL accept(6,16,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"
    ))
  SET v_beg_date = cnvtdatetime(curaccept)
  CALL text(8,16,format(ct_detail->detail_list[cur_rec].end_date,"DD-MMM-YYYY;;D"))
  CALL accept(8,16,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].end_date,"DD-MMM-YYYY;;D"
    ))
  SET v_end_date = cnvtdatetime(curaccept)
  EXECUTE afc_ccl_msgbox "Are you sure you want to Modify?", "Replacelist", "YN"
  CALL clear(1,1)
  IF ((response->yes_ind=1))
   GO TO modifing_precursor
  ELSEIF ((response->no_ind=1))
   GO TO top
  ENDIF
 ELSEIF ((ct_detail->detail_list[cur_rec].detail_name="RESULT"))
  SET new_bill_item_id = 0.0
  CALL clear(1,1)
  CALL box(1,1,17,70)
  CALL text(2,2,"Rule Name:")
  CALL text(2,13,ct_rule_name)
  CALL text(17,42,"Help Available <Shift F5>")
  CALL text(4,5,"Beg_Count:")
  CALL text(4,17,cnvtstring(ct_detail->detail_list[cur_rec].count_beg))
  CALL text(6,5,"End_Count:")
  CALL text(6,17,cnvtstring(ct_detail->detail_list[cur_rec].count_end))
  CALL text(8,5,"Operator: ")
  CALL text(8,17,ct_detail->detail_list[cur_rec].operator_name)
  CALL text(10,5,"Result_Factor:")
  CALL text(10,21,cnvtstring(ct_detail->detail_list[cur_rec].result_factor))
  IF ((ct_detail->detail_list[cur_rec].ruleentity_name="BILL_ITEM"))
   CALL text(12,5,"Bill_Item:")
   CALL text(12,16,cnvtstring(ct_detail->detail_list[cur_rec].bill_item_name))
  ELSE
   CALL text(12,5,"Nomenclature: ")
   CALL text(12,16,ct_detail->detail_list[cur_rec].cpt4_cd)
  ENDIF
  CALL text(14,5,"Beg Date:")
  CALL text(14,16,format(ct_detail->detail_list[cur_rec].beg_date,"dd-mmm-yyyy;;d"))
  CALL text(16,5,"End Date:")
  CALL text(16,16,format(ct_detail->detail_list[cur_rec].end_date,"dd-mmm-yyyy;;d"))
  CALL text(4,17,cnvtstring(ct_detail->detail_list[cur_rec].count_beg))
  CALL accept(4,17,"x(2);c",cnvtstring(ct_detail->detail_list[cur_rec].count_beg))
  SET v_beg = cnvtint(curaccept)
  CALL text(6,17,cnvtstring(ct_detail->detail_list[cur_rec].count_end))
  CALL accept(6,17,"x(2);c",cnvtstring(ct_detail->detail_list[cur_rec].count_end))
  SET v_end = cnvtint(curaccept)
  CALL clear(8,16,20)
  SET help =
  SELECT
   code_value = cv.code_value"########################################;l", cv.cdf_meaning
   FROM code_value cv
   WHERE cv.code_set=18851
    AND cv.active_ind=1
    AND cv.cdf_meaning IN ("NOCHANGE", "EQUAL", "AND")
   ORDER BY cv.display
   WITH nocounter
  ;end select
  CALL accept(8,16,"9(40);c",ct_detail->detail_list[cur_rec].ct_operator_cd)
  SET v_operator_cd = cnvtreal(curaccept)
  SET help = off
  IF (v_operator_cd IN (cv->and_operator, cv->equal_operator))
   CALL text(10,21,cnvtstring(ct_detail->detail_list[cur_rec].result_factor))
   CALL accept(10,21,"p(6);c",cnvtstring(ct_detail->detail_list[cur_rec].result_factor))
   SET v_result_factor = cnvtint(curaccept)
  ELSE
   SET v_result_factor = 0
   CALL text(10,21,"0")
  ENDIF
  IF ((v_operator_cd=cv->and_operator))
   CALL text(12,5,"Bill_Item:")
   SET v_entity_name = "BILL_ITEM"
   SET help =
   SELECT
    bill_item = b.bill_item_id"########################################;l", b.ext_short_desc
    FROM bill_item b
    WHERE b.active_ind=1
     AND b.ext_short_desc >= curaccept
     AND ext_parent_reference_id > 0
     AND ext_child_reference_id=0
    ORDER BY b.ext_short_desc
    WITH nocounter
   ;end select
  ELSE
   CALL text(12,5,"Nomenclature: ")
   SET v_entity_name = "NOMENCLATURE"
   SET help =
   SELECT
    nomenclature = n.nomenclature_id"########################################;l", n.source_identifier
    "###############;l", n.source_string
    FROM nomenclature n
    WHERE n.nomenclature_id != 0
     AND active_ind=1
     AND (n.source_vocabulary_cd=code->cpt4_cd)
     AND n.source_identifier != " "
     AND n.source_identifier >= curaccept
    WITH nocounter
   ;end select
  ENDIF
  CALL clear(12,16,20)
  CALL accept(12,16,"9(40);cp",ct_detail->detail_list[cur_rec].ruleentity_id)
  SET new_bill_item_id = cnvtreal(curaccept)
  SET help = off
  CALL text(14,16,format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"))
  CALL accept(14,16,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].beg_date,
    "DD-MMM-YYYY;;D"))
  SET v_beg_date = cnvtdatetime(curaccept)
  CALL text(16,16,format(ct_detail->detail_list[cur_rec].end_date,"DD-MMM-YYYY;;D"))
  CALL accept(16,16,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].end_date,
    "DD-MMM-YYYY;;D"))
  SET v_end_date = cnvtdatetime(curaccept)
  EXECUTE afc_ccl_msgbox "Are you sure you want to modify?", "Count", "YN"
  CALL clear(1,1)
  IF ((response->yes_ind=1))
   GO TO modifing_result
  ELSEIF ((response->no_ind=1))
   GO TO top
  ENDIF
  GO TO top
 ENDIF
#modifing_result
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "UPT"
 SET request->ct_rule_detail[1].ct_rule_detail_id = ct_detail->detail_list[cur_rec].ct_detail_id
 SET request->ct_rule_detail[1].rule_entity_id = new_bill_item_id
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
 SET request->ct_rule_detail[1].rule_entity_name = v_entity_name
 SET request->ct_rule_detail[1].operator_cd = v_operator_cd
 SET request->ct_rule_detail[1].result_factor = v_result_factor
 SET request->ct_rule_detail[1].count_beg = v_beg
 SET request->ct_rule_detail[1].count_end = v_end
 EXECUTE ct_ens_rule_detail
 COMMIT
 GO TO top
#modifing_precursor
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "UPT"
 SET request->ct_rule_detail[1].ct_rule_detail_id = ct_detail->detail_list[cur_rec].ct_detail_id
 SET request->ct_rule_detail[1].rule_entity_id = new_cpt4_cd
 SET request->ct_rule_detail[1].operator_cd = cv->and_operator
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
 IF (lookup_option=0)
  SET request->ct_rule_detail[1].rule_entity_name = "NOMENCLATURE"
 ELSE
  SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
 ENDIF
 EXECUTE ct_ens_rule_detail
 COMMIT
 GO TO top
#delete_detail
 EXECUTE afc_ccl_msgbox "Are you sure you want to Delete?", "Count", "YN"
 IF ((response->yes_ind=1))
  DELETE  FROM ct_rule_detail d
   WHERE (d.ct_rule_detail_id=ct_detail->detail_list[cur_rec].ct_detail_id)
   WITH nocounter
  ;end delete
  COMMIT
  GO TO top
 ELSEIF ((response->no_ind=1))
  GO TO top
 ENDIF
#end_prog
END GO
