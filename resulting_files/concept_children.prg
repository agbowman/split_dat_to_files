CREATE PROGRAM concept_children
 PROMPT
  "Enter character portion of cki (defaults to SNOMED!): " = "SNOMED!",
  "Enter numeric portion of cki (defaults to top of heirarchy): " = 138875005
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
   1 c1cnt = i2
   1 c1[*]
     2 cki = vc
     2 name = vc
     2 c2cnt = i2
     2 c2[*]
       3 cki = vc
       3 name = vc
       3 c3cnt = i2
       3 c3[*]
         4 cki = vc
         4 name = vc
         4 c4cnt = i2
         4 c4[*]
           5 cki = vc
           5 name = vc
           5 c5cnt = i2
           5 c5[*]
             6 cki = vc
             6 name = vc
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
 SET snmct_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.cdf_meaning="SNMCT"
    AND c.code_set=400
    AND c.active_ind=1)
  DETAIL
   snmct_cd = c.code_value
  WITH nocounter
 ;end select
 SET cki_string =  $1
 SET cki_nbr =  $2
 SET levels_deep = 3
 SET concept_cki = concat(trim(cki_string),cnvtstring(cki_nbr))
 SELECT INTO "nl:"
  FROM cmt_concept cc,
   nomenclature n
  PLAN (cc
   WHERE cc.concept_cki=concept_cki)
   JOIN (n
   WHERE n.concept_cki=outerjoin(cc.concept_cki)
    AND n.primary_vterm_ind=1
    AND n.source_vocabulary_cd=snmct_cd
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD n.concept_cki
   temp->concept_cki = cc.concept_cki, temp->concept_name = n.source_string, temp->disallowed_ind =
   cc.disallowed_ind,
   temp->beg_effective_dt_tm = cnvtdatetime(cc.beg_effective_dt_tm), temp->end_effective_dt_tm =
   cnvtdatetime(cc.end_effective_dt_tm)
  WITH nocounter
 ;end select
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
    AND n.primary_vterm_ind=1
    AND n.source_vocabulary_cd=snmct_cd
    AND n.active_ind=1
    AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
  HEAD REPORT
   chcnt = 0
  DETAIL
   chcnt = (chcnt+ 1), stat = alterlist(temp->c1,chcnt), temp->c1[chcnt].cki = cc.concept_cki,
   temp->c1[chcnt].name = n.source_string
  FOOT REPORT
   temp->c1cnt = chcnt
  WITH nocounter
 ;end select
 IF (levels_deep > 1)
  FOR (x = 1 TO temp->c1cnt)
   SELECT INTO "nl:"
    FROM cmt_concept_reltn ccr,
     cmt_concept cc,
     nomenclature n
    PLAN (ccr
     WHERE (ccr.concept_cki2=temp->c1[x].cki)
      AND ccr.relation_cki="SNOMED!116680003")
     JOIN (cc
     WHERE cc.concept_cki=ccr.concept_cki1)
     JOIN (n
     WHERE n.concept_cki=cc.concept_cki
      AND n.primary_vterm_ind=1
      AND n.source_vocabulary_cd=snmct_cd
      AND n.active_ind=1
      AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    HEAD REPORT
     gchcnt = 0
    DETAIL
     gchcnt = (gchcnt+ 1), stat = alterlist(temp->c1[x].c2,gchcnt), temp->c1[x].c2[gchcnt].cki = cc
     .concept_cki,
     temp->c1[x].c2[gchcnt].name = n.source_string
    FOOT REPORT
     temp->c1[x].c2cnt = gchcnt
    WITH nocounter
   ;end select
   IF (levels_deep > 2)
    FOR (y = 1 TO temp->c1[x].c2cnt)
      SELECT INTO "nl:"
       FROM cmt_concept_reltn ccr,
        cmt_concept cc,
        nomenclature n
       PLAN (ccr
        WHERE (ccr.concept_cki2=temp->c1[x].c2[y].cki)
         AND ccr.relation_cki="SNOMED!116680003")
        JOIN (cc
        WHERE cc.concept_cki=ccr.concept_cki1)
        JOIN (n
        WHERE n.concept_cki=cc.concept_cki
         AND n.primary_vterm_ind=1
         AND n.source_vocabulary_cd=snmct_cd
         AND n.active_ind=1
         AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
       HEAD REPORT
        gchcnt = 0
       DETAIL
        gchcnt = (gchcnt+ 1), stat = alterlist(temp->c1[x].c2[y].c3,gchcnt), temp->c1[x].c2[y].c3[
        gchcnt].cki = cc.concept_cki,
        temp->c1[x].c2[y].c3[gchcnt].name = n.source_string
       FOOT REPORT
        temp->c1[x].c2[y].c3cnt = gchcnt
       WITH nocounter
      ;end select
    ENDFOR
   ENDIF
  ENDFOR
 ENDIF
 SELECT
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   col 50, "CONCEPT CHILDREN REPORT", row + 2,
   beg_date = "                ", end_date = "                   ", col_inc = 4,
   cnt_str = "    "
  DETAIL
   "Concept Name: ", temp->concept_name, " ",
   temp->concept_cki, row + 1
   IF ((temp->c1cnt > 0))
    "Nbr of children at this level: ", temp->c1cnt, row + 1
   ENDIF
   FOR (x = 1 TO temp->c1cnt)
     col 4, "(1) ", temp->c1[x].name,
     "   ", temp->c1[x].cki, row + 1
     IF ((temp->c1[x].c2cnt > 0))
      col 4, "Nbr of children at this level: ", temp->c1[x].c2cnt,
      row + 1
     ENDIF
     FOR (y = 1 TO temp->c1[x].c2cnt)
       col 8, "(2) ", temp->c1[x].c2[y].name,
       "   ", temp->c1[x].c2[y].cki, row + 1
       IF ((temp->c1[x].c2[y].c3cnt > 0))
        col 8, "Nbr of children at this level: ", temp->c1[x].c2[y].c3cnt,
        row + 1
       ENDIF
       FOR (z = 1 TO temp->c1[x].c2[y].c3cnt)
         col 12, "(3) ", temp->c1[x].c2[y].c3[z].name,
         "   ", temp->c1[x].c2[y].c3[z].cki, row + 1
       ENDFOR
     ENDFOR
   ENDFOR
  WITH nocounter, maxrow = 2000, maxcol = 300
 ;end select
#exit_script
END GO
