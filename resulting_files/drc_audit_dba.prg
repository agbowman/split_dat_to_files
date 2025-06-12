CREATE PROGRAM drc_audit:dba
 RECORD drc(
   1 ord_cnt = i4
   1 ord[*]
     2 mnemonic = vc
     2 synonym_id = f8
     2 formulation_code = f8
     2 item_id = f8
     2 dose_range_check_id = f8
     2 dose_range_name = vc
     2 long_text_id = f8
     2 group_cnt = i4
     2 group[*]
       3 premise_group_id = f8
       3 premise_group_qual_flag = i2
       3 premise_cnt = i4
       3 premise[*]
         4 premise_pass_flag = i2
         4 premise_type_flag = i4
         4 premise_type_disp = vc
         4 relational_operator_flag = i4
         4 relational_operator_disp = vc
         4 value_type_flag = i4
         4 value_type_disp = vc
         4 value_unit_cd = f8
         4 value_unit_disp = vc
         4 value1 = f8
         4 value1_string = vc
         4 value2 = f8
         4 value2_string = vc
         4 list_cnt = i4
         4 list[*]
           5 parent_entity_id = f8
           5 disp = vc
         4 response_text = vc
       3 dr_cnt = i4
       3 dr[*]
         4 min_value = f8
         4 max_value = f8
         4 value_unit_cd = f8
         4 value_unit_disp = vc
         4 dose_days = i4
         4 type_flag = i4
         4 type_disp = vc
       3 alert_message = vc
 )
 SET ocnt = 0
 SET gcnt = 0
 SET max_gcnt = 0
 SET pcnt = 0
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM drc_form_reltn dfr,
   medication_definition md,
   order_catalog_item_r ocir,
   order_catalog_synonym ocs,
   drc_premise dp,
   drc_premise dp2,
   (dummyt d  WITH seq = 1),
   drc_premise_list dpl
  PLAN (dfr)
   JOIN (md
   WHERE md.cki=concat("MUL.FRMLTN!",cnvtstring(dfr.formulation_code)))
   JOIN (ocir
   WHERE ocir.item_id=md.item_id)
   JOIN (ocs
   WHERE ocs.synonym_id=ocir.synonym_id)
   JOIN (dp
   WHERE dp.dose_range_check_id=dfr.dose_range_check_id
    AND dp.parent_premise_id=0)
   JOIN (dp2
   WHERE dp2.parent_premise_id=dp.drc_premise_id)
   JOIN (d)
   JOIN (dpl
   WHERE dpl.drc_premise_id=dp2.drc_premise_id)
  ORDER BY ocs.mnemonic, dp.drc_premise_id, dp2.drc_premise_id
  HEAD REPORT
   ocnt = 0, gcnt = 0, pcnt = 0,
   dcnt = 0
  HEAD ocs.mnemonic
   ocnt = (ocnt+ 1), stat = alterlist(drc->ord,ocnt), drc->ord[ocnt].mnemonic = ocs.mnemonic,
   drc->ord[ocnt].synonym_id = ocs.synonym_id, drc->ord[ocnt].formulation_code = dfr.formulation_code,
   drc->ord[ocnt].item_id = ocir.item_id,
   drc->ord[ocnt].dose_range_check_id = dfr.dose_range_check_id, gcnt = 0
  HEAD dp.drc_premise_id
   gcnt = (gcnt+ 1), stat = alterlist(drc->ord[ocnt].group,gcnt), drc->ord[ocnt].group[gcnt].
   premise_group_id = dp.drc_premise_id,
   pcnt = 0
  HEAD dp2.drc_premise_id
   pcnt = (pcnt+ 1), stat = alterlist(drc->ord[ocnt].group[gcnt].premise,pcnt), drc->ord[ocnt].group[
   gcnt].premise[pcnt].premise_type_flag = dp2.premise_type_flag
   IF (dp2.premise_type_flag=1)
    drc->ord[ocnt].group[gcnt].premise[pcnt].premise_type_disp = "Age"
   ELSEIF (dp2.premise_type_flag=2)
    drc->ord[ocnt].group[gcnt].premise[pcnt].premise_type_disp = "Route"
   ENDIF
   drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_flag = dp2.relational_operator_flag
   IF ((dp2.relational_operator_flag=- (1)))
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "N/A"
   ELSEIF (dp2.relational_operator_flag=0)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "="
   ELSEIF (dp2.relational_operator_flag=1)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "<"
   ELSEIF (dp2.relational_operator_flag=2)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = ">"
   ELSEIF (dp2.relational_operator_flag=3)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "<="
   ELSEIF (dp2.relational_operator_flag=4)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = ">="
   ELSEIF (dp2.relational_operator_flag=5)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "!="
   ELSEIF (dp2.relational_operator_flag=6)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "Between"
   ELSEIF (dp2.relational_operator_flag=7)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "Outside"
   ELSEIF (dp2.relational_operator_flag=8)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "In"
   ELSEIF (dp2.relational_operator_flag=9)
    drc->ord[ocnt].group[gcnt].premise[pcnt].relational_operator_disp = "Not In"
   ENDIF
   drc->ord[ocnt].group[gcnt].premise[pcnt].value_type_flag = dp2.value_type_flag
   IF (dp2.value_type_flag=1)
    drc->ord[ocnt].group[gcnt].premise[pcnt].value_type_disp = "Number"
   ELSEIF (dp2.value_type_flag=2)
    drc->ord[ocnt].group[gcnt].premise[pcnt].value_type_disp = "String"
   ELSEIF (dp2.value_type_flag=3)
    drc->ord[ocnt].group[gcnt].premise[pcnt].value_type_disp = "Codeset"
   ELSEIF (dp2.value_type_flag=4)
    drc->ord[ocnt].group[gcnt].premise[pcnt].value_type_disp = "List"
   ELSEIF (dp2.value_type_flag=5)
    drc->ord[ocnt].group[gcnt].premise[pcnt].value_type_disp = "Nomenclature"
   ENDIF
   drc->ord[ocnt].group[gcnt].premise[pcnt].value_unit_cd = dp2.value_unit_cd
   IF (dp2.value_unit_cd > 0)
    drc->ord[ocnt].group[gcnt].premise[pcnt].value_unit_disp = uar_get_code_display(dp2.value_unit_cd
     )
   ENDIF
   drc->ord[ocnt].group[gcnt].premise[pcnt].value1 = dp2.value1, drc->ord[ocnt].group[gcnt].premise[
   pcnt].value1_string = dp2.value1_string, drc->ord[ocnt].group[gcnt].premise[pcnt].value2 = dp2
   .value2,
   drc->ord[ocnt].group[gcnt].premise[pcnt].value2_string = dp2.value2_string, drc->ord[ocnt].group[
   gcnt].premise[pcnt].list_cnt = 0, lcnt = 0
  DETAIL
   IF (dpl.drc_premise_list_id > 0
    AND dpl.active_ind=1
    AND dpl.parent_entity_name="CODE_VALUE"
    AND dpl.parent_entity_id > 0)
    lcnt = (lcnt+ 1), stat = alterlist(drc->ord[ocnt].group[gcnt].premise[pcnt].list,lcnt), drc->ord[
    ocnt].group[gcnt].premise[pcnt].list[lcnt].parent_entity_id = dpl.parent_entity_id,
    drc->ord[ocnt].group[gcnt].premise[pcnt].list[lcnt].disp = trim(uar_get_code_display(dpl
      .parent_entity_id))
   ENDIF
  FOOT  dp.drc_premise_id
   drc->ord[ocnt].group[gcnt].premise[pcnt].list_cnt = lcnt, drc->ord[ocnt].group[gcnt].premise_cnt
    = pcnt
  FOOT  ocs.mnemonic
   drc->ord[ocnt].group_cnt = gcnt
   IF (gcnt > max_gcnt)
    max_gcnt = gcnt
   ENDIF
  FOOT REPORT
   drc->ord_cnt = ocnt
  WITH nocounter, outerjoin = d
 ;end select
 FOR (x = 1 TO ocnt)
   SELECT INTO "nl:"
    FROM (dummyt d2  WITH seq = value(drc->ord[x].group_cnt)),
     drc_dose_range ddr
    PLAN (d2
     WHERE (drc->ord[x].group[d2.seq].premise_group_id > 0))
     JOIN (ddr
     WHERE (ddr.drc_premise_id=drc->ord[x].group[d2.seq].premise_group_id))
    HEAD REPORT
     dcnt = 0
    HEAD d2.seq
     dcnt = 0
    DETAIL
     dcnt = (dcnt+ 1), stat = alterlist(drc->ord[x].group[d2.seq].dr,dcnt), drc->ord[x].group[d2.seq]
     .dr[dcnt].min_value = ddr.min_value,
     drc->ord[x].group[d2.seq].dr[dcnt].max_value = ddr.max_value, drc->ord[x].group[d2.seq].dr[dcnt]
     .value_unit_cd = ddr.value_unit_cd
     IF (ddr.value_unit_cd > 0)
      drc->ord[x].group[d2.seq].dr[dcnt].value_unit_disp = uar_get_code_display(ddr.value_unit_cd)
     ENDIF
     drc->ord[x].group[d2.seq].dr[dcnt].dose_days = ddr.dose_days, drc->ord[x].group[d2.seq].dr[dcnt]
     .type_flag = ddr.type_flag
     IF (ddr.type_flag=1)
      drc->ord[x].group[d2.seq].dr[dcnt].type_disp = "per dose."
     ELSEIF (ddr.type_flag=2)
      drc->ord[x].group[d2.seq].dr[dcnt].type_disp = "per day."
     ELSEIF (ddr.type_flag=3)
      drc->ord[x].group[d2.seq].dr[dcnt].type_disp = concat("every ",cnvtstring(ddr.dose_days,1,0,r),
       " days.")
     ELSEIF (ddr.type_flag=4)
      drc->ord[x].group[d2.seq].dr[dcnt].type_disp = "per therapy."
     ENDIF
    FOOT  d2.seq
     drc->ord[x].group[d2.seq].dr_cnt = dcnt
    WITH nocounter
   ;end select
 ENDFOR
 SELECT
  FROM (dummyt d  WITH seq = 1)
  HEAD REPORT
   hline = fillstring(120,"-"), save_row = 0, last_row = 0,
   item_id = fillstring(10," ")
  HEAD PAGE
   col 52, "DRC AUDIT REPORT", row + 1,
   hline, row + 1, col 0,
   "   ITEM ID/MNEMONIC", col 30, "PREMISE GROUPS",
   col 90, "DOSE RANGES", row + 1,
   hline, row + 1
  DETAIL
   FOR (x = 1 TO drc->ord_cnt)
     IF (((row+ 15) > 60))
      BREAK
     ENDIF
     col 0, item_id = trim(format(drc->ord[x].item_id,"##########")), item_id,
     "/", drc->ord[x].mnemonic
     FOR (y = 1 TO drc->ord[x].group_cnt)
       IF (((row+ 10) > 60))
        BREAK, col 0, item_id = trim(format(drc->ord[x].item_id,"##########")),
        item_id, "/", drc->ord[x].mnemonic
       ENDIF
       save_row = row
       FOR (z = 1 TO drc->ord[x].group[y].premise_cnt)
         IF (z > 1)
          col 25, "and"
         ELSEIF (y=1)
          col 29, "("
         ELSE
          col 26, "OR ("
         ENDIF
         col 30, drc->ord[x].group[y].premise[z].premise_type_disp, " ",
         drc->ord[x].group[y].premise[z].relational_operator_disp, " "
         IF ((drc->ord[x].group[y].premise[z].value_type_flag=4))
          FOR (zz = 1 TO drc->ord[x].group[y].premise[z].list_cnt)
           drc->ord[x].group[y].premise[z].list[zz].disp,
           IF ((zz != drc->ord[x].group[y].premise[z].list_cnt))
            ","
           ENDIF
          ENDFOR
         ELSE
          drc->ord[x].group[y].premise[z].value1_string, " ", drc->ord[x].group[y].premise[z].
          value_unit_disp
          IF ((drc->ord[x].group[y].premise[z].value2_string > " ")
           AND (((drc->ord[x].group[y].premise[z].value_type_flag=6)) OR ((drc->ord[x].group[y].
          premise[z].value_type_flag=7))) )
           " ", drc->ord[x].group[y].premise[z].value2_string, " ",
           drc->ord[x].group[y].premise[z].value_unit_disp
          ENDIF
         ENDIF
         IF ((z=drc->ord[x].group[y].premise_cnt))
          ")"
         ENDIF
         row + 1
       ENDFOR
       last_row = row, row save_row
       FOR (z = 1 TO drc->ord[x].group[y].dr_cnt)
         col 70, drc->ord[x].group[y].dr[z].min_value, "-",
         drc->ord[x].group[y].dr[z].max_value, " ", drc->ord[x].group[y].dr[z].value_unit_disp,
         " ", drc->ord[x].group[y].dr[z].type_disp, row + 1
       ENDFOR
       IF (last_row > row)
        row last_row
       ENDIF
       col 55, "----------", row + 1
     ENDFOR
   ENDFOR
  FOOT REPORT
   row + 1, col 50, "*** end of report ***"
  WITH nocounter
 ;end select
END GO
