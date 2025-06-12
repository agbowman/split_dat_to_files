CREATE PROGRAM delete_qnaireid:dba
 PAINT
 DECLARE list1_cnt = i4
 DECLARE list2_cnt = i4
 DECLARE list3_cnt = i4
 DECLARE list4_cnt = i4
 DECLARE list5_cnt = i4
 DECLARE p1 = vc
 RECORD info(
   1 alias_id = vc
   1 qnaire_id = vc
   1 list1[*]
     2 elem_entity_id = vc
     2 qnaire_elem_id = vc
   1 list2[*]
     2 qset_id = vc
   1 list3[*]
     2 qea_id = vc
   1 list4[*]
     2 qset_id = vc
   1 list5[*]
     2 question_id = vc
 )
 SET valid = 0
 WHILE (valid=0)
   CALL text(1,1,"Please Enter an QUESTIONNAIRE_IDENT from CKE_QUESTIONNAIRE to be deleted: ")
   CALL text(2,1,"questionnaire_ident:")
   CALL accept(2,25,"p(100);c"," ")
   SET p1 = curaccept
   IF (p1="")
    CALL text(6,1,build("please enter a valid questionnaire_ident, (case sensitive)."))
    SET valid = 0
   ELSE
    SELECT INTO "nl:"
     questionnaire_ident
     FROM cke_questionnaire
     WHERE questionnaire_ident=p1
    ;end select
    IF (curqual=1)
     CALL clear(6,1)
     CALL text(6,1,build("QUESTIONNAIRE_IDENT: '",p1,"' found on CKE_QUESTIONNAIRE."))
     SET valid = 1
    ELSEIF (curqual > 1)
     CALL text(6,1,build("found more than one QUESTIONNAIRE_IDENT for ident: '",p1,
       "' on CKE_QUESTIONNAIRE."))
     SET valid = 0
    ELSE
     CALL text(6,1,build("did not find QUESTIONNAIRE_IDENT: '",p1,"' on CKE_QUESTIONNAIRE."))
     SET valid = 0
    ENDIF
   ENDIF
   IF (valid=0)
    CALL text(7,1,"enter 'Y' to enter another QUESTIONNAIRE_IDENT: ")
    CALL accept(7,55,"p;cu"," ")
    IF (curaccept != "Y")
     RETURN
    ELSE
     SET valid = 0
    ENDIF
   ELSEIF (valid=1)
    CALL text(7,1,"continue with delete? (Y|N): ")
    CALL accept(7,31,"p;cu"," ")
    IF (curaccept != "Y")
     RETURN
    ENDIF
   ENDIF
 ENDWHILE
 CALL clear(1,1)
 SET info->qnaire_id = p1
 SELECT INTO "nl:"
  qnel.element_entity_ident, qnel.qnaire_element_ident
  FROM cke_qnaire_element qnel
  WHERE (qnel.qnaire_ident=info->qnaire_id)
  DETAIL
   list1_cnt = (list1_cnt+ 1)
   IF (mod(list1_cnt,50)=1)
    stat = alterlist(info->list1,(list1_cnt+ 50))
   ENDIF
   info->list1[list1_cnt].elem_entity_id = qnel.element_entity_ident, info->list1[list1_cnt].
   qnaire_elem_id = qnel.qnaire_element_ident
  WITH nocounter
 ;end select
 SET stat = alterlist(info->list1,list1_cnt)
 SELECT INTO "nl:"
  ques.questionset_ident
  FROM cke_question ques,
   (dummyt d  WITH seq = size(info->list1,5))
  PLAN (d)
   JOIN (ques
   WHERE (ques.question_ident=info->list1[d.seq].elem_entity_id))
  DETAIL
   list2_cnt = (list2_cnt+ 1)
   IF (mod(list2_cnt,50)=1)
    stat = alterlist(info->list2,(list2_cnt+ 50))
   ENDIF
   info->list2[list2_cnt].qset_id = ques.questionset_ident
  WITH nocounter
 ;end select
 SET stat = alterlist(info->list2,list2_cnt)
 SELECT INTO "nl:"
  qnelit.qea_ident
  FROM cke_qnaire_element_item qnelit,
   (dummyt d  WITH seq = size(info->list1,5))
  PLAN (d)
   JOIN (qnelit
   WHERE (qnelit.qnaire_element_ident=info->list1[d.seq].qnaire_elem_id))
  DETAIL
   list3_cnt = (list3_cnt+ 1)
   IF (mod(list3_cnt,50)=1)
    stat = alterlist(info->list3,(list3_cnt+ 50))
   ENDIF
   info->list3[list3_cnt].qea_id = qnelit.qea_ident
  WITH nocounter
 ;end select
 SET stat = alterlist(info->list3,list3_cnt)
 SELECT INTO "nl:"
  ques.questionset_ident
  FROM cke_question ques,
   cke_questionset queset,
   cke_questionset_member cqm,
   (dummyt d  WITH seq = size(info->list1,5))
  PLAN (d)
   JOIN (ques
   WHERE (ques.question_ident=info->list1[d.seq].elem_entity_id))
   JOIN (cqm
   WHERE ((cqm.member_ident=ques.questionset_ident) OR (cqm.questionset_ident=ques.questionset_ident
   )) )
   JOIN (queset
   WHERE ((queset.questionset_ident=cqm.member_ident) OR (queset.questionset_ident=cqm
   .questionset_ident)) )
  DETAIL
   list4_cnt = (list4_cnt+ 1)
   IF (mod(list4_cnt,50)=1)
    stat = alterlist(info->list4,(list4_cnt+ 50))
   ENDIF
   info->list4[list4_cnt].qset_id = queset.questionset_ident
  WITH nocounter
 ;end select
 SET stat = alterlist(info->list4,list4_cnt)
 SELECT INTO "nl:"
  ques.question_ident
  FROM cke_question ques,
   (dummyt d  WITH seq = size(info->list2,5))
  PLAN (d)
   JOIN (ques
   WHERE (ques.questionset_ident=info->list2[d.seq].qset_id))
  DETAIL
   list5_cnt = (list5_cnt+ 1)
   IF (mod(list5_cnt,50)=1)
    stat = alterlist(info->list5,(list5_cnt+ 50))
   ENDIF
   info->list5[list5_cnt].question_id = ques.question_ident
  WITH nocounter
 ;end select
 SET stat = alterlist(info->list5,list5_cnt)
 DELETE  FROM cke_questionnaire qnaire
  WHERE (qnaire.questionnaire_ident=info->qnaire_id)
 ;end delete
 CALL text(2,1,"deleting from CKE_QUESTIONNAIRE:")
 CALL text(2,45,build(curqual))
 CALL text(2,55,"row(s) deleted")
 DELETE  FROM cke_qnaire_element qnelem
  WHERE (qnelem.qnaire_ident=info->qnaire_id)
 ;end delete
 CALL text(3,1,"deleting from CKE_QNAIRE_ELEMENT:")
 CALL text(3,45,build(curqual))
 CALL text(3,55,"row(s) deleted")
 DELETE  FROM cke_qnaire_element_tag qnelemtag
  WHERE (qnelemtag.qnaire_ident=info->qnaire_id)
 ;end delete
 CALL text(4,1,"deleting from CKE_QNAIRE_ELEMENT_TAG:")
 CALL text(4,45,build(curqual))
 CALL text(4,55,"row(s) deleted")
 DELETE  FROM cke_question ques,
   (dummyt d1  WITH seq = list5_cnt)
  SET ques.seq = 1
  PLAN (d1)
   JOIN (ques
   WHERE (ques.question_ident=info->list5[d1.seq].question_id))
  WITH nocounter
 ;end delete
 CALL text(5,1,"deleting from CKE_QUESTION:")
 CALL text(5,45,build(curqual))
 CALL text(5,55,"row(s) deleted")
 DELETE  FROM cke_annotation an,
   (dummyt d2  WITH seq = list1_cnt)
  SET an.seq = 1
  PLAN (d2)
   JOIN (an
   WHERE (an.annotation_ident=info->list1[d2.seq].elem_entity_id))
  WITH nocounter
 ;end delete
 CALL text(6,1,"deleting from CKE_ANNOTATION:")
 CALL text(6,45,build(curqual))
 CALL text(6,55,"row(s) deleted")
 DELETE  FROM cke_qnaire_element_item qnelemitem,
   (dummyt d3  WITH seq = list1_cnt)
  SET qnelemitem.seq = 1
  PLAN (d3)
   JOIN (qnelemitem
   WHERE (qnelemitem.qnaire_element_ident=info->list1[d3.seq].qnaire_elem_id))
  WITH nocounter
 ;end delete
 CALL text(7,1,"deleting from CKE_QNAIRE_ELEMENT_ITEM:")
 CALL text(7,45,build(curqual))
 CALL text(7,55,"row(s) deleted")
 DECLARE cur_set_total = i4
 DECLARE cur_set1 = i4
 DECLARE cur_set2 = i4
 DELETE  FROM cke_questionset queset,
   (dummyt d41  WITH seq = list2_cnt)
  SET queset.seq = 1
  PLAN (d41)
   JOIN (queset
   WHERE (queset.questionset_ident=info->list2[d41.seq].qset_id))
  WITH nocounter
 ;end delete
 SET cur_set1 = curqual
 DELETE  FROM cke_questionset queset,
   (dummyt d42  WITH seq = list4_cnt)
  SET queset.seq = 1
  PLAN (d42)
   JOIN (queset
   WHERE (queset.questionset_ident=info->list4[d42.seq].qset_id))
  WITH nocounter
 ;end delete
 SET cur_set2 = curqual
 SET cur_set_total = (cur_set1+ cur_set2)
 CALL text(8,1,"deleting from CKE_QUESTIONSET:")
 CALL text(8,45,build(cur_set_total))
 CALL text(8,55,"row(s) deleted")
 DECLARE cur1 = i4
 DECLARE cur2 = i4
 DECLARE cur3 = i4
 DECLARE cur4 = i4
 DELETE  FROM cke_attributes att,
   (dummyt d5  WITH seq = list3_cnt)
  SET att.seq = 1
  PLAN (d5)
   JOIN (att
   WHERE (att.own_entity_ident=info->list3[d5.seq].qea_id))
  WITH nocounter
 ;end delete
 SET cur1 = curqual
 CALL text(9,1,"deleting from CKE_ATTRIBUTES")
 DELETE  FROM cke_attributes att2,
   (dummyt d6  WITH seq = list1_cnt)
  SET att2.seq = 1
  PLAN (d6)
   JOIN (att2
   WHERE (att2.own_entity_ident=info->list1[d6.seq].qnaire_elem_id))
  WITH nocounter
 ;end delete
 SET cur2 = curqual
 CALL text(9,1,"deleting from CKE_ATTRIBUTES")
 DELETE  FROM cke_attributes att3
  WHERE (att3.own_entity_ident=info->qnaire_id)
 ;end delete
 SET cur3 = curqual
 SET cur4 = ((cur1+ cur2)+ cur3)
 CALL text(9,1,"deleting from CKE_ATTRIBUTES:")
 CALL text(9,45,build(cur4))
 CALL text(9,55,"row(s) deleted")
 DELETE  FROM cke_questionnaire_keyword cqk
  WHERE (cqk.qnaire_ident=info->qnaire_id)
 ;end delete
 CALL text(10,1,"deleting from CKE_QUESTIONNAIRE_KEYWORD:")
 CALL text(10,45,build(curqual))
 CALL text(10,55,"row(s) deleted")
 DECLARE cur_setkey_total = i4
 DECLARE cur_setkey1 = i4
 DECLARE cur_setkey2 = i4
 DELETE  FROM cke_questionset_keyword cqsetk,
   (dummyt d7  WITH seq = list2_cnt)
  SET cqsetk.seq = 1
  PLAN (d7)
   JOIN (cqsetk
   WHERE (cqsetk.questionset_ident=info->list2[d7.seq].qset_id))
  WITH nocounter
 ;end delete
 SET cur_setkey1 = curqual
 DELETE  FROM cke_questionset_keyword cqsetk,
   (dummyt d71  WITH seq = list4_cnt)
  SET cqsetk.seq = 1
  PLAN (d71)
   JOIN (cqsetk
   WHERE (cqsetk.questionset_ident=info->list4[d71.seq].qset_id))
  WITH nocounter
 ;end delete
 SET cur_setkey2 = curqual
 SET cur_setkey_total = (cur_setkey1+ cur_setkey2)
 CALL text(11,1,"deleting from CKE_QUESTIONSET_KEYWORD:")
 CALL text(11,45,build(cur_setkey_total))
 CALL text(11,55,"row(s) deleted")
 DECLARE cur_mem1 = i4
 DECLARE cur_mem2 = i4
 DECLARE cur_mem_total = i4
 DELETE  FROM cke_questionset_member cqsetm,
   (dummyt d8  WITH seq = list2_cnt)
  SET cqsetm.seq = 1
  PLAN (d8)
   JOIN (cqsetm
   WHERE (cqsetm.questionset_ident=info->list2[d8.seq].qset_id))
  WITH nocounter
 ;end delete
 SET cur_mem1 = curqual
 DELETE  FROM cke_questionset_member cqsetm,
   (dummyt d81  WITH seq = list4_cnt)
  SET cqsetm.seq = 1
  PLAN (d81)
   JOIN (cqsetm
   WHERE (cqsetm.questionset_ident=info->list4[d81.seq].qset_id))
  WITH nocounter
 ;end delete
 SET cur_mem2 = curqual
 SET cur_mem_total = (cur_mem1+ cur_mem2)
 CALL text(12,1,"deleting from CKE_QUESTIONSET_MEMBER:")
 CALL text(12,45,build(cur_mem_total))
 CALL text(12,55,"row(s) deleted")
 DELETE  FROM cke_question_keyword cquesk,
   (dummyt d91  WITH seq = list5_cnt)
  SET cquesk.seq = 1
  PLAN (d91)
   JOIN (cquesk
   WHERE (cquesk.question_ident=info->list5[d91.seq].question_id))
  WITH nocounter
 ;end delete
 CALL text(13,1,"deleting from CKE_QUESTION_KEYWORD:")
 CALL text(13,45,build(curqual))
 CALL text(13,55,"row(s) deleted")
 DELETE  FROM cke_expression_template ctemp,
   (dummyt d101  WITH seq = list1_cnt)
  SET ctemp.seq = 1
  PLAN (d101)
   JOIN (ctemp
   WHERE (ctemp.exp_template_id=info->list1[d101.seq].exp_temp_id))
  WITH nocounter
 ;end delete
 CALL text(14,1,"deleting from CKE_EXPRESSION_TEMPLATE:")
 CALL text(14,45,build(curqual))
 CALL text(14,55,"row(s) deleted")
 DELETE  FROM cke_expression_param cparam,
   (dummyt d111  WITH seq = list1_cnt)
  SET cparam.seq = 1
  PLAN (d111)
   JOIN (cparam
   WHERE (cparam.qnaire_element_ident=info->list1[d111.seq].qnaire_elem_id))
  WITH nocounter
 ;end delete
 CALL text(15,1,"deleting from CKE_EXPRESSION_PARAM:")
 CALL text(15,45,build(curqual))
 CALL text(15,55,"row(s) deleted")
 CALL text(21,1,"commit deletions to DB?:")
 CALL accept(21,26,"p;cu","N")
 IF (curaccept != "Y")
  ROLLBACK
  CALL text(22,1,"changes rolled back")
 ELSE
  COMMIT
  CALL text(22,1,"deletions committed to DB")
 ENDIF
END GO
