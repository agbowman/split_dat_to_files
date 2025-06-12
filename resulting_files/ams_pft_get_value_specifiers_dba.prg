CREATE PROGRAM ams_pft_get_value_specifiers:dba
 PROMPT
  "entity_type_code" = "",
  "pft_entity_status" = ""
  WITH inputentitytypecd, inputentitystatuscd
 DECLARE addvaluetodataset(display=vc,queue_id=f8,assignedprsnl=vc) = null WITH protect
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE last_mod = vc WITH protect
 DECLARE disppos = i4 WITH protect
 DECLARE valuepos = i4 WITH protect
 DECLARE namepos = i4 WITH protect
 DECLARE groupingstr = vc WITH protect
 DECLARE i = i4 WITH protect
 DECLARE cnt = i4 WITH protect
 DECLARE currchildpos = i2 WITH protect
 DECLARE currparentpos = i4 WITH protect
 DECLARE speccnt = i4 WITH protect
 DECLARE treecnt = i4 WITH protect
 DECLARE arrowstr = vc WITH protect
 RECORD specifiers(
   1 list[*]
     2 pft_queue_assignment_id = f8
     2 display = vc
     2 value_specifier_cd = f8
     2 sequence = i4
     2 parent_seq = i4
     2 parent_ind = i2
     2 child_ind = i2
     2 assigned_prsnl = vc
 ) WITH protect
 RECORD tree(
   1 list[*]
     2 parentpos = i4
     2 mypos = i4
     2 maxchildpos = i4
     2 disp = vc
 ) WITH protect
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SET stat = makedataset(10)
 SET disppos = addstringfield("SPECIFIER","Specifier",visibile_ind,125)
 SET valuepos = addrealfield("VALUE","Value",invisibile_ind)
 SET namepos = addstringfield("NAME","Assigned To",visibile_ind,100)
 SET stat = setkeyfield(valuepos,1)
 SELECT INTO "nl:"
  value_disp = uar_get_code_display(pqa.value_specifier_cd), grouping = cnvtreal(concat(cnvtstring(
     pqa.level_nbr),cnvtstring(pqa.sequence_nbr))), pqa.pft_queue_assignment_id
  FROM prsnl p,
   pft_queue_assignment pqa,
   prsnl p2
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
   JOIN (pqa
   WHERE pqa.active_ind=1
    AND pqa.logical_domain_id=p.logical_domain_id
    AND (pqa.pft_entity_status_cd= $INPUTENTITYSTATUSCD)
    AND (pqa.pft_entity_type_cd= $INPUTENTITYTYPECD)
    AND pqa.level_nbr != 0)
   JOIN (p2
   WHERE p2.person_id=pqa.assigned_prsnl_id)
  ORDER BY pqa.level_nbr, value_disp, pqa.value_specifier_cd,
   pqa.sequence_nbr, grouping, pqa.value_display_txt
  HEAD grouping
   i = (i+ 1)
   IF (mod(i,10)=1)
    stat = alterlist(specifiers->list,(i+ 9))
   ENDIF
   specifiers->list[i].pft_queue_assignment_id = pqa.pft_queue_assignment_id, specifiers->list[i].
   value_specifier_cd = pqa.value_specifier_cd
   IF (pqa.contributor_system_cd > 0.0)
    specifiers->list[i].assigned_prsnl = trim(uar_get_code_display(pqa.contributor_system_cd))
   ELSE
    specifiers->list[i].assigned_prsnl = p2.name_full_formatted
   ENDIF
   specifiers->list[i].sequence = pqa.sequence_nbr, specifiers->list[i].parent_seq = pqa.level_nbr
   IF (pqa.level_nbr > 1)
    specifiers->list[i].child_ind = 1, currparentpos = locateval(cnt,1,size(specifiers->list,5),pqa
     .level_nbr,specifiers->list[cnt].sequence)
    IF (currparentpos > 0)
     specifiers->list[cnt].parent_ind = 1
    ENDIF
   ENDIF
   groupingstr = ""
  DETAIL
   IF (textlen(trim(groupingstr)) > 0)
    groupingstr = build2(groupingstr,", ",pqa.value_display_txt)
   ELSE
    groupingstr = pqa.value_display_txt
   ENDIF
  FOOT  grouping
   specifiers->list[i].display = build2(trim(value_disp),": ",groupingstr)
  FOOT REPORT
   IF (mod(i,10) != 0)
    stat = alterlist(specifiers->list,i)
   ENDIF
  WITH nocounter
 ;end select
 FOR (speccnt = 1 TO size(specifiers->list,5))
   IF ((specifiers->list[speccnt].child_ind=0))
    CALL addvaluetodataset(specifiers->list[speccnt].display,specifiers->list[speccnt].
     pft_queue_assignment_id,specifiers->list[speccnt].assigned_prsnl)
    SET treecnt = 1
    SET currparentpos = speccnt
    SET stat = alterlist(tree->list,treecnt)
    SET tree->list[treecnt].parentpos = currparentpos
    SET tree->list[treecnt].mypos = currparentpos
    SET tree->list[treecnt].disp = specifiers->list[currparentpos].display
    SET currchildpos = locateval(cnt,1,size(specifiers->list,5),specifiers->list[currparentpos].
     sequence,specifiers->list[cnt].parent_seq)
    IF (currchildpos > 0)
     SET tree->list[treecnt].maxchildpos = currchildpos
    ENDIF
    WHILE (((currchildpos != 0) OR (treecnt >= 1)) )
     IF (currchildpos > 0)
      SET arrowstr = notrim(fillstring(value((treecnt * 5))," "))
      SET specifiers->list[currchildpos].display = build2(arrowstr,specifiers->list[currchildpos].
       display)
      CALL addvaluetodataset(specifiers->list[currchildpos].display,specifiers->list[currchildpos].
       pft_queue_assignment_id,specifiers->list[currchildpos].assigned_prsnl)
     ENDIF
     IF ((specifiers->list[currchildpos].parent_ind=1)
      AND currchildpos > 0)
      SET treecnt = (treecnt+ 1)
      SET stat = alterlist(tree->list,treecnt)
      SET tree->list[treecnt].parentpos = currparentpos
      SET tree->list[treecnt].mypos = currchildpos
      SET tree->list[treecnt].disp = specifiers->list[currchildpos].display
      SET currparentpos = currchildpos
      SET currchildpos = locateval(cnt,(currchildpos+ 1),size(specifiers->list,5),specifiers->list[
       currparentpos].sequence,specifiers->list[cnt].parent_seq)
      IF (currchildpos > 0)
       SET tree->list[treecnt].maxchildpos = currchildpos
      ENDIF
     ELSE
      SET currchildpos = locateval(cnt,(tree->list[treecnt].maxchildpos+ 1),size(specifiers->list,5),
       specifiers->list[currparentpos].sequence,specifiers->list[cnt].parent_seq)
      IF (currchildpos > 0)
       SET tree->list[treecnt].maxchildpos = currchildpos
      ENDIF
      WHILE (currchildpos=0
       AND treecnt > 0)
        SET treecnt = (treecnt - 1)
        SET stat = alterlist(tree->list,treecnt)
        IF (treecnt > 0)
         SET currparentpos = tree->list[treecnt].mypos
         SET currchildpos = locateval(cnt,(tree->list[treecnt].maxchildpos+ 1),size(specifiers->list,
           5),specifiers->list[currparentpos].sequence,specifiers->list[cnt].parent_seq)
         IF (currchildpos > 0)
          SET tree->list[treecnt].maxchildpos = currchildpos
         ENDIF
        ENDIF
      ENDWHILE
     ENDIF
    ENDWHILE
   ENDIF
 ENDFOR
 SET stat = closedataset(0)
 SUBROUTINE addvaluetodataset(display,queue_id,assignedprsnl)
   SET recordpos = getnextrecord(0)
   SET stat = setstringfield(recordpos,disppos,display)
   SET stat = setrealfield(recordpos,valuepos,queue_id)
   SET stat = setstringfield(recordpos,namepos,assignedprsnl)
 END ;Subroutine
 SET last_mod = "000"
END GO
