CREATE PROGRAM ct_build_replacelist:dba
 PAINT
 IF ("Z"=validate(ct_build_replacelist_vrsn,"Z"))
  DECLARE ct_build_replacelist_vrsn = vc WITH noconstant("65970.003")
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
     2 detail_name = vc
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
 SET count1 = 0
 SELECT INTO "nl:"
  FROM ct_rule_detail d,
   code_value cv
  WHERE ct_rule_id=d.ct_rule_id
   AND d.active_ind=1
   AND cv.code_value=d.detail_type_cd
  ORDER BY d.sequence
  DETAIL
   count1 = (count1+ 1), stat = alterlist(ct_detail->detail_list,count1), ct_detail->detail_list[
   count1].detailtype_cd = d.detail_type_cd,
   ct_detail->detail_list[count1].detail_name = cv.cdf_meaning, ct_detail->detail_list[count1].
   ct_operator_cd = d.operator_cd, ct_detail->detail_list[count1].ruleentity_id = d.rule_entity_id,
   ct_detail->detail_list[count1].ruleentity_name = d.rule_entity_name, ct_detail->detail_list[count1
   ].beg_date = d.beg_effective_dt_tm, ct_detail->detail_list[count1].end_date = d
   .end_effective_dt_tm,
   ct_detail->detail_list[count1].ct_detail_id = d.ct_rule_detail_id
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
   ct_detail->detail_list[d1.seq].detail_name = c.display
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
   ct_detail->detail_list[d1.seq].operator_name = c.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  n.source_identifier
  FROM nomenclature n,
   (dummyt d1  WITH seq = value(size(ct_detail->detail_list,5)))
  PLAN (d1
   WHERE (ct_detail->detail_list[d1.seq].detail_name="PRECURSOR")
    AND (ct_detail->detail_list[d1.seq].ruleentity_name="NOMENCLATURE"))
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
   WHERE (ct_detail->detail_list[d1.seq].detail_name="RESULT"))
   JOIN (b
   WHERE (b.bill_item_id=ct_detail->detail_list[d1.seq].ruleentity_id))
  DETAIL
   ct_detail->detail_list[d1.seq].bill_item_name = trim(b.ext_short_desc,3)
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
   CALL text(4,4,"Precursor")
   CALL text(4,45,"Result")
   SET x_qual = top_rec
   FOR (x = min_row TO max_row)
     CALL clear(x,1,70)
     IF (x_qual=cur_rec)
      CALL video(r)
     ELSE
      CALL video(n)
     ENDIF
     IF (x_qual <= max_rec)
      IF (trim(ct_detail->detail_list[x_qual].cpt4_cd)="")
       SET lookup_option = 1
       SET desc = fillstring(30," ")
       SELECT INTO "nl:"
        FROM bill_item b
        WHERE (b.bill_item_id=ct_detail->detail_list[x_qual].ruleentity_id)
        DETAIL
         desc = trim(b.ext_description)
        WITH nocounter
       ;end select
       IF ((ct_detail->detail_list[x_qual].detailtype_cd=cv->precursor))
        SET desc = build(desc," (",cnvtstring(ct_detail->detail_list[x_qual].ruleentity_id),")")
        CALL text(x,4,desc)
       ELSE
        CALL text(x,45,ct_detail->detail_list[x_qual].bill_item_name)
       ENDIF
      ELSE
       IF ((ct_detail->detail_list[x_qual].detailtype_cd=cv->precursor))
        CALL text(x,4,ct_detail->detail_list[x_qual].cpt4_cd)
       ELSE
        CALL text(x,45,ct_detail->detail_list[x_qual].bill_item_name)
       ENDIF
      ENDIF
     ELSE
      CALL clear(x,1,70)
     ENDIF
     CALL video(n)
     SET x_qual = (x_qual+ 1)
   ENDFOR
 END ;Subroutine
#add_precursor
 CALL clear(1,1)
 CALL box(1,1,15,75)
 CALL text(15,25,"Help Available < Shift F5 >")
 CALL text(2,2,"Rule Name:")
 CALL text(2,13,ct_rule_name)
 CALL text(3,2,"Rule Type:")
 CALL text(3,13,ct_action_name)
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
  FOR (x = 1 TO size(ct_detail->detail_list,5))
    SET ct_detail->detail_list[x].cpt4_cd = ""
  ENDFOR
 ENDIF
 CALL accept(7,19,"9(40);cp")
 SET v_nomen_id = cnvtreal(curaccept)
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
 IF (lookup_option=0)
  SET request->ct_rule_detail[1].rule_entity_name = "NOMENCLATURE"
 ELSEIF (lookup_option=1)
  SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
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
 CALL box(1,1,15,75)
 CALL text(15,45,"Help Available < Shift F5 >")
 CALL text(2,1,"Rule Name:")
 CALL text(2,12,ct_rule_name)
 CALL text(3,1,"Rule Type:")
 CALL text(3,12,ct_action_name)
 CALL text(5,3,"Bill_Item_Id ")
 CALL text(7,3,"Beg Date:")
 CALL text(9,3,"End Date:")
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
 CALL accept(5,19,"9(40);cp")
 SET v_billitem_id = cnvtreal(curaccept)
 SET help = off
 CALL text(7,14,format(curdate,"DD-MMM-YYYY;;D"))
 CALL accept(7,14,"xx-xxx-xxxx;ucs",format(curdate,"DD-MMM-YYYY;;D"))
 SET v_beg_date = cnvtdatetime(curaccept)
 CALL text(9,14,format(v_end_date,"DD-MMM-YYYY;;D"))
 CALL accept(9,14,"xx-xxx-xxxx;ucs",format(v_end_date,"DD-MMM-YYYY;;D"))
 SET v_end_date = cnvtdatetime(curaccept)
 SET request->ct_rule_detail_qual = 1
 SET request->ct_rule_detail[1].action_type = "ADD"
 SET request->ct_rule_detail[1].ct_rule_id = ct_rule_id
 SET request->ct_rule_detail[1].operator_cd = cv->and_operator
 SET request->ct_rule_detail[1].rule_entity_id = v_billitem_id
 SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
 SET request->ct_rule_detail[1].detail_type_cd = cv->result
 SET request->ct_rule_detail[1].precedence = 1
 SET request->ct_rule_detail[1].beg_effective_dt_tm = v_beg_date
 SET request->ct_rule_detail[1].end_effective_dt_tm = v_end_date
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
  SET new_cpt4_cd = 0
  SET v_beg_date = cnvtdatetime(curdate,curtime)
  SET v_end_date = cnvtdatetime("31-Dec-2100 23:59")
  SET v_bill_item_id = 0
  SET new_bill_item_id = 0
  CALL clear(1,1)
  CALL box(1,1,15,70)
  CALL text(2,2,"Rule Name:")
  CALL text(2,13,ct_rule_name)
  CALL text(15,25,"Help Available <Shift F5>")
  CALL text(4,5,"Qualify on (0 = CPT-4, 1 = BILL ITEM):")
  CALL text(6,5,"Precursor:")
  CALL text(6,5,ct_detail->detail_list[cur_rec].cpt4_cd)
  CALL text(8,5,"Beg Date:")
  CALL text(8,16,format(ct_detail->detail_list[cur_rec].beg_date,"dd-mmm-yyyy;;d"))
  CALL text(10,5,"End Date:")
  CALL text(10,16,format(ct_detail->detail_list[cur_rec].end_date,"dd-mmm-yyyy;;d"))
  IF (lookup_option=1)
   CALL text(4,43,"1")
   CALL text(6,16,cnvtstring(ct_detail->detail_list[cur_rec].ruleentity_id))
  ELSE
   CALL text(4,43,"0")
   CALL text(6,16,ct_detail->detail_list[cur_rec].cpt4_cd)
  ENDIF
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
   CALL accept(6,16,"x(10);cp",ct_detail->detali_list[cur_rec].ruleentity_id)
   SET new_cpt4_cd = cnvtint(curaccept)
   SET help = off
  ELSE
   CALL clear(15,25)
   CALL box(1,1,15,70)
   CALL text(15,25,"No Help Available")
   CALL accept(6,16,"x(10);cp",ct_detail->detail_list[cur_rec].ruleentity_id)
   SET new_cpt4_cd = cnvtint(curaccept)
  ENDIF
  CALL text(8,16,format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"))
  CALL accept(8,16,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"
    ))
  SET v_beg_date = cnvtdatetime(curaccept)
  CALL text(10,16,format(ct_detail->detail_list[cur_rec].end_date,"DD-MMM-YYYY;;D"))
  CALL accept(10,16,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].end_date,
    "DD-MMM-YYYY;;D"))
  SET v_end_date = cnvtdatetime(curaccept)
  EXECUTE afc_ccl_msgbox "Are you sure you want to Modify?", "Replacelist", "YN"
  CALL clear(1,1)
  IF ((response->yes_ind=1))
   GO TO modifing_precursor
  ELSEIF ((response->no_ind=1))
   GO TO top
  ENDIF
 ELSEIF ((ct_detail->detail_list[cur_rec].detail_name="RESULT"))
  CALL clear(1,1)
  CALL box(1,1,15,70)
  CALL text(2,2,"Rule Name:")
  CALL text(2,13,ct_rule_name)
  CALL text(15,25,"Help Available <Shift F5>")
  CALL text(4,5,"Qualify on (0 = CPT-4, 1 = BILL ITEM):")
  CALL text(4,43,cnvtstring(lookup_option))
  CALL text(6,5,"Result:")
  CALL text(6,16,cnvtstring(ct_detail->detail_list[cur_rec].bill_item_name))
  CALL text(8,5,"Beg Date:")
  CALL text(8,16,format(ct_detail->detail_list[cur_rec].beg_date,"dd-mmm-yyyy;;d"))
  CALL text(10,5,"End Date:")
  CALL text(10,16,format(ct_detail->detail_list[cur_rec].end_date,"dd-mmm-yyyy;;d"))
  IF (lookup_option=1)
   CALL text(4,43,"1")
   CALL text(6,16,cnvtstring(ct_detail->detail_list[cur_rec].ruleentity_id))
  ELSE
   CALL text(4,43,"0")
   CALL text(6,16,ct_detail->detail_list[cur_rec].cpt4_cd)
  ENDIF
  CALL accept(4,43,"x(1);c",lookup_option)
  SET lookup_option = cnvtint(curaccept)
  IF (lookup_option=0)
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
   CALL accept(6,16,"9(40);cp",ct_detail->detail_list[cur_rec].bill_item_name)
   SET new_bill_item_id = cnvtreal(curaccept)
   SET help = off
  ELSE
   CALL clear(15,25)
   CALL box(1,1,15,70)
   CALL text(15,25,"No Help Available")
   CALL accept(6,16,"x(8);cp",ct_detail->detail_list[cur_rec].ruleentity_id)
   SET new_bill_item_id = cnvtint(curaccept)
  ENDIF
  CALL text(8,16,format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"))
  CALL accept(8,16,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].beg_date,"DD-MMM-YYYY;;D"
    ))
  SET v_beg_date = cnvtdatetime(curaccept)
  CALL text(10,16,format(ct_detail->detail_list[cur_rec].end_date,"DD-MMM-YYYY;;D"))
  CALL accept(10,16,"xx-xxx-xxxx;ucs",format(ct_detail->detail_list[cur_rec].end_date,
    "DD-MMM-YYYY;;D"))
  SET v_end_date = cnvtdatetime(curaccept)
  EXECUTE afc_ccl_msgbox "Are you sure you want to modify?", "Replacelist", "YN"
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
 SET request->ct_rule_detail[1].rule_entity_name = "BILL_ITEM"
 SET request->ct_rule_detail[1].operator_cd = cv->and_operator
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
 EXECUTE afc_ccl_msgbox "Are you sure you want to Delete?", "Replacelist", "YN"
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
