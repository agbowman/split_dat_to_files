CREATE PROGRAM bhs_athn_drug_duplications
 RECORD orequest(
   1 person_id = f8
   1 dc_intr_days_flag = i2
 )
 RECORD t_record(
   1 drug_cnt = i4
   1 drug_qual[*]
     2 cki = vc
     2 category_id = f8
     2 category = vc
   1 o_drug_cnt = i4
   1 o_drug_qual[*]
     2 cki = vc
     2 category_id = f8
     2 category = vc
   1 dup_cnt = i4
   1 dup_qual[*]
     2 drug1 = vc
     2 drug1_category = vc
     2 drug2 = vc
     2 drug2_category = vc
     2 message = vc
 )
 RECORD out_rec(
   1 duplications[*]
     2 drug1 = vc
     2 drug1_cki = vc
     2 drug1_category = vc
     2 drug2 = vc
     2 drug2_cki = vc
     2 drug2_category = vc
     2 message = vc
 )
 SET orequest->person_id =  $2
 SET stat = tdbexecute(3200000,3200081,965238,"REC",orequest,
  "REC",oreply)
 IF (size(oreply->med_list,5)=0)
  GO TO end_script
 ENDIF
 FOR (i = 1 TO size(oreply->med_list,5))
  IF ((t_record->drug_cnt=0))
   SET t_record->drug_cnt = 1
   SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
   SET t_record->drug_qual[t_record->drug_cnt].cki = oreply->med_list[i].source_identifier
  ENDIF
  IF ((t_record->drug_cnt > 0))
   SET dup_ind = 0
   FOR (j = 1 TO t_record->drug_cnt)
     IF ((t_record->drug_qual[j].cki=oreply->med_list[i].source_identifier))
      SET dup_ind = 1
      SET j = (t_record->drug_cnt+ 1)
     ENDIF
   ENDFOR
   IF (dup_ind=0)
    SET t_record->drug_cnt = (t_record->drug_cnt+ 1)
    SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
    SET t_record->drug_qual[t_record->drug_cnt].cki = oreply->med_list[i].source_identifier
   ENDIF
  ENDIF
 ENDFOR
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET t_line =  $3
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->o_drug_cnt = (t_record->o_drug_cnt+ 1)
    SET stat = alterlist(t_record->o_drug_qual,t_record->o_drug_cnt)
    SET t_record->o_drug_qual[t_record->o_drug_cnt].cki = replace(t_line,"MUL.ORD!","")
    SET done = 1
   ELSE
    SET t_record->o_drug_cnt = (t_record->o_drug_cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->o_drug_qual,t_record->o_drug_cnt)
    SET t_record->o_drug_qual[t_record->o_drug_cnt].cki = replace(t_line2,"MUL.ORD!","")
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->drug_cnt),
   mltm_duplication_drug_xref mddx,
   mltm_duplication_categories mdc
  PLAN (d)
   JOIN (mddx
   WHERE (mddx.drug_identifier=t_record->drug_qual[d.seq].cki))
   JOIN (mdc
   WHERE mdc.multum_category_id=mddx.multum_category_id)
  DETAIL
   t_record->drug_qual[d.seq].category_id = mdc.multum_category_id, t_record->drug_qual[d.seq].
   category = mdc.category_name
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->o_drug_cnt),
   mltm_duplication_drug_xref mddx,
   mltm_duplication_categories mdc
  PLAN (d)
   JOIN (mddx
   WHERE (mddx.drug_identifier=t_record->o_drug_qual[d.seq].cki))
   JOIN (mdc
   WHERE mdc.multum_category_id=mddx.multum_category_id)
  DETAIL
   t_record->o_drug_qual[d.seq].category_id = mdc.multum_category_id, t_record->o_drug_qual[d.seq].
   category = mdc.category_name
  WITH nocounter, time = 30
 ;end select
 FOR (i = 1 TO t_record->drug_cnt)
   FOR (j = 1 TO t_record->o_drug_cnt)
     IF ((t_record->drug_qual[i].cki=t_record->o_drug_qual[j].cki))
      SET t_record->dup_cnt = (t_record->dup_cnt+ 1)
      SET stat = alterlist(t_record->dup_qual,t_record->dup_cnt)
      SET t_record->dup_qual[t_record->dup_cnt].drug1 = t_record->o_drug_qual[j].cki
      SET t_record->dup_qual[t_record->dup_cnt].drug1_category = t_record->o_drug_qual[j].category
      SET t_record->dup_qual[t_record->dup_cnt].drug2 = t_record->drug_qual[i].cki
      SET t_record->dup_qual[t_record->dup_cnt].drug2_category = t_record->drug_qual[i].category
      SET t_record->dup_qual[t_record->dup_cnt].message = "Message1"
     ENDIF
   ENDFOR
 ENDFOR
 FOR (i = 1 TO t_record->o_drug_cnt)
   FOR (j = 1 TO t_record->o_drug_cnt)
     IF ((t_record->o_drug_qual[i].cki=t_record->o_drug_qual[j].cki)
      AND i != j)
      SET t_record->dup_cnt = (t_record->dup_cnt+ 1)
      SET stat = alterlist(t_record->dup_qual,t_record->dup_cnt)
      SET t_record->dup_qual[t_record->dup_cnt].drug1 = t_record->o_drug_qual[i].cki
      SET t_record->dup_qual[t_record->dup_cnt].drug1_category = t_record->o_drug_qual[i].category
      SET t_record->dup_qual[t_record->dup_cnt].drug2 = t_record->o_drug_qual[j].cki
      SET t_record->dup_qual[t_record->dup_cnt].drug2_category = t_record->o_drug_qual[j].category
      SET t_record->dup_qual[t_record->dup_cnt].message = "Message2"
     ENDIF
   ENDFOR
 ENDFOR
 FOR (i = 1 TO t_record->drug_cnt)
   FOR (j = 1 TO t_record->o_drug_cnt)
     IF ((t_record->drug_qual[i].category_id=t_record->o_drug_qual[j].category_id)
      AND (t_record->drug_qual[i].category_id != 0)
      AND (t_record->o_drug_qual[j].category_id != 0)
      AND (t_record->drug_qual[i].cki != t_record->o_drug_qual[j].cki))
      SET t_record->dup_cnt = (t_record->dup_cnt+ 1)
      SET stat = alterlist(t_record->dup_qual,t_record->dup_cnt)
      SET t_record->dup_qual[t_record->dup_cnt].drug1 = t_record->o_drug_qual[j].cki
      SET t_record->dup_qual[t_record->dup_cnt].drug1_category = t_record->o_drug_qual[j].category
      SET t_record->dup_qual[t_record->dup_cnt].drug2 = t_record->drug_qual[i].cki
      SET t_record->dup_qual[t_record->dup_cnt].drug2_category = t_record->drug_qual[i].category
      SET t_record->dup_qual[t_record->dup_cnt].message = "Message3"
     ENDIF
   ENDFOR
 ENDFOR
 FOR (i = 1 TO t_record->o_drug_cnt)
   FOR (j = 1 TO t_record->o_drug_cnt)
     IF ((t_record->o_drug_qual[i].category_id=t_record->o_drug_qual[j].category_id)
      AND (t_record->o_drug_qual[i].category_id != 0)
      AND (t_record->o_drug_qual[j].category_id != 0)
      AND (t_record->o_drug_qual[i].cki != t_record->o_drug_qual[j].cki))
      SET t_record->dup_cnt = (t_record->dup_cnt+ 1)
      SET stat = alterlist(t_record->dup_qual,t_record->dup_cnt)
      SET t_record->dup_qual[t_record->dup_cnt].drug1 = t_record->o_drug_qual[j].cki
      SET t_record->dup_qual[t_record->dup_cnt].drug1_category = t_record->o_drug_qual[j].category
      SET t_record->dup_qual[t_record->dup_cnt].drug2 = t_record->o_drug_qual[i].cki
      SET t_record->dup_qual[t_record->dup_cnt].drug2_category = t_record->o_drug_qual[i].category
      SET t_record->dup_qual[t_record->dup_cnt].message = "Message4"
     ENDIF
   ENDFOR
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  drug1 = t_record->dup_qual[d.seq].drug1, drug2 = t_record->dup_qual[d.seq].drug2, message =
  t_record->dup_qual[d.seq].message
  FROM (dummyt d  WITH seq = t_record->dup_cnt)
  PLAN (d)
  ORDER BY drug1, drug2, message
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(out_rec->duplications,cnt), out_rec->duplications[cnt].drug1_cki
    = concat("MUL.ORD!",drug1),
   out_rec->duplications[cnt].drug1_category = t_record->dup_qual[d.seq].drug1_category, out_rec->
   duplications[cnt].drug2_cki = concat("MUL.ORD!",drug2), out_rec->duplications[cnt].drug2_category
    = t_record->dup_qual[d.seq].drug2_category
   IF (message="Message1")
    out_rec->duplications[cnt].message = "Incoming - Ordered Drug Duplication"
   ENDIF
   IF (message="Message2")
    out_rec->duplications[cnt].message = "Incoming - Incoming Drug Duplication"
   ENDIF
   IF (message="Message3")
    out_rec->duplications[cnt].message = "Incoming - Ordered Drug Category Duplication"
   ENDIF
   IF (message="Message4")
    out_rec->duplications[cnt].message = "Incoming - Incoming Drug Category Duplication"
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->duplications,5)),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (oc.cki=out_rec->duplications[d.seq].drug1_cki))
  DETAIL
   out_rec->duplications[d.seq].drug1 = uar_get_code_display(oc.catalog_cd)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->duplications,5)),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (oc.cki=out_rec->duplications[d.seq].drug2_cki))
  DETAIL
   out_rec->duplications[d.seq].drug2 = uar_get_code_display(oc.catalog_cd)
  WITH nocounter, time = 30
 ;end select
#end_script
 CALL echojson(out_rec, $1)
END GO
