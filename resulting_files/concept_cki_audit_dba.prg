CREATE PROGRAM concept_cki_audit:dba
 PROMPT
  "Enter character portion of concept_cki (defaults to SNOMED!): " = "SNOMED!",
  "Enter numeric portion of concept_cki: " = 0
 CALL echo( $1)
 CALL echo( $2)
 IF (( $1=" "))
  GO TO exit_script
 ENDIF
 IF (( $2=0))
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 concept_cki = vc
   1 concept_name = vc
   1 disallowed_ind = i2
   1 beg_effective_dt_tm = f8
   1 end_effective_dt_tm = f8
   1 tcnt = i2
   1 tlist[*]
     2 source_string = vc
     2 pv_ind = i2
     2 pc_ind = i2
     2 cmti = vc
     2 beg_effective_dt_tm = f8
     2 end_effective_dt_tm = f8
     2 source_vocab = vc
     2 vocab_axis = vc
     2 short_string = vc
     2 mnemonic = vc
   1 ccnt = i2
   1 clist[*]
     2 concept_cki = vc
     2 concept_name = vc
   1 pcnt = i2
   1 plist[*]
     2 concept_cki = vc
     2 concept_name = vc
   1 hcnt = i2
   1 hlist[10]
     2 concept_cki = vc
     2 concept_name = vc
   1 chcnt = i2
   1 chlist[*]
     2 concept_cki = vc
     2 concept_name = vc
     2 gchcnt = i2
     2 gchlist[*]
       3 concept_cki = vc
       3 concept_name = vc
 )
 DECLARE cki_string = vc
 DECLARE cki_nbr = i4
 DECLARE tcnt = i4
 DECLARE pcnt = i4
 DECLARE ccnt = i4
 DECLARE parent_cki1 = vc
 DECLARE parent_cki2 = vc
 DECLARE parent_cki3 = vc
 DECLARE parent_cki4 = vc
 DECLARE parent_cki5 = vc
 DECLARE parent_cki6 = vc
 DECLARE parent_cki7 = vc
 DECLARE parent_cki8 = vc
 DECLARE parent_cki9 = vc
 DECLARE parent_cki10 = vc
 SET cki_string =  $1
 SET cki_nbr =  $2
 SET concept_cki = concat(trim(cki_string),cnvtstring(cki_nbr))
 SELECT INTO "nl:"
  FROM cmt_concept cc,
   nomenclature n
  PLAN (cc
   WHERE cc.concept_cki=concept_cki)
   JOIN (n
   WHERE n.concept_cki=outerjoin(cc.concept_cki))
  ORDER BY n.source_string_keycap
  HEAD REPORT
   temp->concept_cki = cc.concept_cki, temp->concept_name = cc.concept_name, temp->disallowed_ind =
   cc.disallowed_ind,
   temp->beg_effective_dt_tm = cnvtdatetime(cc.beg_effective_dt_tm), temp->end_effective_dt_tm =
   cnvtdatetime(cc.end_effective_dt_tm), tcnt = 0
  DETAIL
   IF (n.nomenclature_id > 0)
    tcnt = (tcnt+ 1), stat = alterlist(temp->tlist,tcnt), temp->tlist[tcnt].source_string = n
    .source_string,
    temp->tlist[tcnt].pv_ind = n.primary_vterm_ind, temp->tlist[tcnt].pc_ind = n.primary_cterm_ind,
    temp->tlist[tcnt].cmti = n.cmti,
    temp->tlist[tcnt].beg_effective_dt_tm = cnvtdatetime(n.beg_effective_dt_tm), temp->tlist[tcnt].
    end_effective_dt_tm = cnvtdatetime(n.end_effective_dt_tm), temp->tlist[tcnt].source_vocab =
    uar_get_code_display(n.source_vocabulary_cd),
    temp->tlist[tcnt].vocab_axis = uar_get_code_display(n.vocab_axis_cd), temp->tlist[tcnt].
    short_string = n.short_string, temp->tlist[tcnt].mnemonic = n.mnemonic
   ENDIF
  FOOT REPORT
   temp->tcnt = tcnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cmt_concept_explode cce,
   cmt_concept cc,
   nomenclature n
  PLAN (cce
   WHERE cce.child_concept_cki=concept_cki)
   JOIN (cc
   WHERE cc.concept_cki=cce.parent_concept_cki)
   JOIN (n
   WHERE n.concept_cki=cc.concept_cki
    AND n.primary_vterm_ind=1)
  HEAD REPORT
   pcnt = 0
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(temp->plist,pcnt), temp->plist[pcnt].concept_cki = cc
   .concept_cki,
   temp->plist[pcnt].concept_name = n.source_string
  FOOT REPORT
   temp->pcnt = pcnt
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cmt_concept_explode cce
  PLAN (cce
   WHERE cce.parent_concept_cki=concept_cki)
  HEAD REPORT
   ccnt = 0
  DETAIL
   ccnt = (ccnt+ 1)
  WITH nocounter
 ;end select
 IF (ccnt > 100)
  SET temp->ccnt = ccnt
 ELSE
  SELECT INTO "nl:"
   FROM cmt_concept_explode cce,
    cmt_concept cc,
    nomenclature n
   PLAN (cce
    WHERE cce.parent_concept_cki=concept_cki)
    JOIN (cc
    WHERE cc.concept_cki=cce.child_concept_cki)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    ccnt = 0
   DETAIL
    ccnt = (ccnt+ 1), stat = alterlist(temp->clist,ccnt), temp->clist[ccnt].concept_cki = cc
    .concept_cki,
    temp->clist[ccnt].concept_name = n.source_string
   FOOT REPORT
    temp->ccnt = ccnt
   WITH nocounter
  ;end select
 ENDIF
 SET parent_cki1 = " "
 SELECT INTO "nl:"
  FROM cmt_concept_reltn ccr,
   cmt_concept cc,
   nomenclature n
  PLAN (ccr
   WHERE ccr.concept_cki1=concept_cki
    AND ccr.relation_cki="SNOMED!116680003")
   JOIN (cc
   WHERE cc.concept_cki=ccr.concept_cki2)
   JOIN (n
   WHERE n.concept_cki=cc.concept_cki
    AND n.primary_vterm_ind=1)
  HEAD REPORT
   count = 0
  HEAD cc.concept_cki
   parent_cki1 = ccr.concept_cki2, temp->hlist[1].concept_cki = cc.concept_cki, temp->hlist[1].
   concept_name = n.source_string,
   count = (count+ 1)
  FOOT REPORT
   IF (count > 1)
    temp->hlist[1].concept_name = concat(temp->hlist[1].concept_name," (one of ",cnvtstring(count,1,0,
      r),")")
   ENDIF
  WITH nocounter
 ;end select
 IF (parent_cki1 > " ")
  SET temp->hcnt = 1
  SET parent_cki2 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki1
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki2 = ccr.concept_cki2, temp->hlist[2].concept_cki = cc.concept_cki, temp->hlist[2].
    concept_name = n.source_string,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[2].concept_name = concat(temp->hlist[2].concept_name," (one of ",cnvtstring(count,1,
       0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki2 > " ")
  SET temp->hcnt = 2
  SET parent_cki3 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki2
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki3 = ccr.concept_cki2, temp->hlist[3].concept_cki = cc.concept_cki, temp->hlist[3].
    concept_name = n.source_string,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[3].concept_name = concat(temp->hlist[3].concept_name," (one of ",cnvtstring(count,1,
       0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki3 > " ")
  SET temp->hcnt = 3
  SET parent_cki4 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki3
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki4 = ccr.concept_cki2, temp->hlist[4].concept_cki = cc.concept_cki, temp->hlist[4].
    concept_name = n.source_string,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[4].concept_name = concat(temp->hlist[4].concept_name," (one of ",cnvtstring(count,1,
       0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki4 > " ")
  SET temp->hcnt = 4
  SET parent_cki5 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki4
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki5 = ccr.concept_cki2, temp->hlist[5].concept_cki = cc.concept_cki, temp->hlist[5].
    concept_name = n.source_string,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[5].concept_name = concat(temp->hlist[5].concept_name," (one of ",cnvtstring(count,1,
       0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki5 > " ")
  SET temp->hcnt = 5
  SET parent_cki6 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki5
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki6 = ccr.concept_cki2, temp->hlist[6].concept_cki = n.source_string, temp->hlist[6].
    concept_name = cc.concept_name,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[6].concept_name = concat(temp->hlist[6].concept_name," (one of ",cnvtstring(count,1,
       0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki6 > " ")
  SET temp->hcnt = 6
  SET parent_cki7 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki6
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki7 = ccr.concept_cki2, temp->hlist[7].concept_cki = cc.concept_cki, temp->hlist[7].
    concept_name = n.source_string,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[7].concept_name = concat(temp->hlist[7].concept_name," (one of ",cnvtstring(count,1,
       0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki7 > " ")
  SET temp->hcnt = 7
  SET parent_cki8 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki7
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki8 = ccr.concept_cki2, temp->hlist[8].concept_cki = cc.concept_cki, temp->hlist[8].
    concept_name = n.source_string,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[8].concept_name = concat(temp->hlist[8].concept_name," (one of ",cnvtstring(count,1,
       0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki8 > " ")
  SET temp->hcnt = 8
  SET parent_cki9 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki8
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki9 = ccr.concept_cki2, temp->hlist[9].concept_cki = cc.concept_cki, temp->hlist[9].
    concept_name = n.source_string,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[9].concept_name = concat(temp->hlist[9].concept_name," (one of ",cnvtstring(count,1,
       0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki9 > " ")
  SET temp->hcnt = 9
  SET parent_cki10 = " "
  SELECT INTO "nl:"
   FROM cmt_concept_reltn ccr,
    cmt_concept cc,
    nomenclature n
   PLAN (ccr
    WHERE ccr.concept_cki1=parent_cki9
     AND ccr.relation_cki="SNOMED!116680003")
    JOIN (cc
    WHERE cc.concept_cki=ccr.concept_cki2)
    JOIN (n
    WHERE n.concept_cki=cc.concept_cki
     AND n.primary_vterm_ind=1)
   HEAD REPORT
    count = 0
   HEAD cc.concept_cki
    parent_cki10 = ccr.concept_cki2, temp->hlist[10].concept_cki = cc.concept_cki, temp->hlist[10].
    concept_name = n.source_string,
    count = (count+ 1)
   FOOT REPORT
    IF (count > 1)
     temp->hlist[10].concept_name = concat(temp->hlist[10].concept_name," (one of ",cnvtstring(count,
       1,0,r),")")
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (parent_cki10 > " ")
  SET temp->hcnt = 10
 ENDIF
 SELECT INTO "nl:"
  FROM cmt_concept_reltn ccr,
   cmt_concept cc,
   nomenclature n
  PLAN (ccr
   WHERE ccr.concept_cki2=concept_cki
    AND ccr.relation_cki="SNOMED!116680003")
   JOIN (cc
   WHERE cc.concept_cki=ccr.concept_cki1)
   JOIN (n
   WHERE n.concept_cki=cc.concept_cki
    AND n.primary_vterm_ind=1)
  HEAD REPORT
   chcnt = 0
  DETAIL
   chcnt = (chcnt+ 1), stat = alterlist(temp->chlist,chcnt), temp->chlist[chcnt].concept_cki = cc
   .concept_cki,
   temp->chlist[chcnt].concept_name = n.source_string
  FOOT REPORT
   temp->chcnt = chcnt
  WITH nocounter
 ;end select
 FOR (x = 1 TO temp->chcnt)
   SELECT INTO "nl:"
    FROM cmt_concept_reltn ccr,
     cmt_concept cc,
     nomenclature n
    PLAN (ccr
     WHERE (ccr.concept_cki2=temp->chlist[x].concept_cki)
      AND ccr.relation_cki="SNOMED!116680003")
     JOIN (cc
     WHERE cc.concept_cki=ccr.concept_cki1)
     JOIN (n
     WHERE n.concept_cki=cc.concept_cki
      AND n.primary_vterm_ind=1)
    HEAD REPORT
     gchcnt = 0
    DETAIL
     gchcnt = (gchcnt+ 1), stat = alterlist(temp->chlist[x].gchlist,gchcnt), temp->chlist[x].gchlist[
     gchcnt].concept_cki = cc.concept_cki,
     temp->chlist[x].gchlist[gchcnt].concept_name = n.source_string
    FOOT REPORT
     temp->chlist[x].gchcnt = gchcnt
    WITH nocounter
   ;end select
 ENDFOR
 SELECT
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   col 50, "CONCEPT CKI AUDIT REPORT", row + 2,
   beg_date = "                ", end_date = "                   ", col_inc = 4
  HEAD PAGE
   "Concept CKI: ", temp->concept_cki, row + 1,
   "Concept Name: ", temp->concept_name, row + 1,
   "Effective: ", beg_date = format(temp->beg_effective_dt_tm,"mm/dd/yyyy hh:mm;;d"), beg_date,
   " thru ", end_date = format(temp->end_effective_dt_tm,"mm/dd/yyyy hh:mm;;d"), end_date,
   row + 2
  DETAIL
   "TERM INFO   (Rows on the nomenclature table for this concept)", row + 2
   IF ((temp->tcnt > 0))
    col 4, "Source String", col 60,
    "CMTI", row + 1, col 4,
    "--------------------------------", col 60, "---------------",
    row + 1
    FOR (x = 1 TO temp->tcnt)
      col 4, temp->tlist[x].source_string, col 60,
      temp->tlist[x].cmti, row + 1
    ENDFOR
   ELSE
    col 4, "There were no terms on the nomenclature table with this concept_cki.", row + 1
   ENDIF
   row + 1,
   "HEIRARCHY INFO (Max 10 layers up, 2 down from entered concept. Entered concept preceded by >>>'s.)",
   row + 2,
   y = temp->hcnt
   WHILE (y > 0)
     col col_inc, col_inc = (col_inc+ 4), temp->hlist[y].concept_name,
     row + 1, y = (y - 1)
   ENDWHILE
   FOR (a = 1 TO (col_inc - 3))
     ">"
   ENDFOR
   col col_inc, temp->concept_name, col_inc = (col_inc+ 4),
   row + 1
   FOR (x = 1 TO temp->chcnt)
     col col_inc, temp->chlist[x].concept_name, col_inc = (col_inc+ 4)
     FOR (y = 1 TO temp->chlist[x].gchcnt)
       col col_inc, temp->chlist[x].gchlist[y].concept_name, row + 1
     ENDFOR
     col_inc = (col_inc - 4)
   ENDFOR
   row + 2, "EXPLODE INFO (Info about this concept on the cmt_concept_explode table)", row + 2,
   col 4, "This concept is a descendent of ", temp->pcnt,
   " other concepts.", row + 2
   IF ((temp->pcnt < 100)
    AND (temp->pcnt > 0))
    col 4, "Concept CKI", col 30,
    "Concept Name", row + 1
    FOR (x = 1 TO temp->pcnt)
      col 4, temp->plist[x].concept_cki, col 30,
      temp->plist[x].concept_name, row + 1
    ENDFOR
   ELSEIF ((temp->pcnt >= 100))
    col 4, "Since there are more than 100, they won't be listed on this report.", row + 1
   ENDIF
   row + 1, col 4, "There are ",
   temp->ccnt, " concepts that are descendents of this concept.", row + 2
   IF ((temp->ccnt < 100)
    AND (temp->ccnt > 0))
    col 4, "Concept CKI", col 30,
    "Concept Name", row + 1
    FOR (x = 1 TO temp->ccnt)
      col 4, temp->clist[x].concept_cki, col 30,
      temp->clist[x].concept_name, row + 1
    ENDFOR
   ELSEIF ((temp->ccnt > 100))
    "  Since there are more than 100, they won't be listed on this report.", row + 1
   ENDIF
   row + 1
  WITH nocounter, maxrow = 2000, maxcol = 300
 ;end select
#exit_script
END GO
