CREATE PROGRAM bhs_athn_get_drug_allergy_rev
 RECORD orequest(
   1 person_id = f8
   1 dc_intr_days_flag = i2
 )
 RECORD t_record(
   1 drug_cnt = i4
   1 drug_qual[*]
     2 cki = vc
     2 long_cki = vc
   1 drug_cnt2 = i4
   1 drug_qual2[*]
     2 cki = vc
     2 long_cki = vc
   1 allergy_cnt = i4
   1 allergy_qual[*]
     2 category_id = f8
   1 category_cnt = i4
   1 category_qual[*]
     2 category_id = f8
     2 category = vc
     2 drug_cnt = i4
     2 drug_qual[*]
       3 drug_cki = vc
       3 drug = vc
 )
 RECORD out_rec(
   1 allergy_category[*]
     2 allergy_category_cki = vc
     2 allergy_category = vc
     2 drug[*]
       3 drug_cki = vc
       3 drug = vc
 )
 SET orequest->person_id =  $2
 SET stat = tdbexecute(3200000,3200081,965238,"REC",orequest,
  "REC",oreply)
 SET t_record->drug_cnt = size(oreply->med_list,5)
 SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
 FOR (i = 1 TO size(oreply->med_list,5))
  SET t_record->drug_qual[i].cki = oreply->med_list[i].source_identifier
  SET t_record->drug_qual[i].long_cki = concat("MUL.ORD!",trim(oreply->med_list[i].source_identifier)
   )
 ENDFOR
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET t_line =  $3
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->drug_cnt = (t_record->drug_cnt+ 1)
    SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
    SET t_record->drug_qual[t_record->drug_cnt].cki = replace(t_line,"MUL.ORD!","")
    SET t_record->drug_qual[t_record->drug_cnt].long_cki = t_line
    SET done = 1
   ELSE
    SET t_record->drug_cnt = (t_record->drug_cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
    SET t_record->drug_qual[t_record->drug_cnt].cki = replace(t_line2,"MUL.ORD!","")
    SET t_record->drug_qual[t_record->drug_cnt].long_cki = t_line2
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  cki = t_record->drug_qual[d.seq].cki
  FROM (dummyt d  WITH seq = t_record->drug_cnt)
  ORDER BY cki
  HEAD cki
   t_record->drug_cnt2 = (t_record->drug_cnt2+ 1), stat = alterlist(t_record->drug_qual2,t_record->
    drug_cnt2), t_record->drug_qual2[t_record->drug_cnt2].cki = t_record->drug_qual[d.seq].cki,
   t_record->drug_qual2[t_record->drug_cnt2].long_cki = t_record->drug_qual[d.seq].long_cki
  WITH nocounter, time = 30
 ;end select
 SET t_record->drug_cnt = 0
 SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
 SET done = 0
 SET t_line =  $4
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->allergy_cnt = (t_record->allergy_cnt+ 1)
    SET stat = alterlist(t_record->allergy_qual,t_record->allergy_cnt)
    SET t_record->allergy_qual[t_record->allergy_cnt].category_id = cnvtreal(replace(t_line,
      "MUL.ALGCAT!",""))
    SET done = 1
   ELSE
    SET t_record->allergy_cnt = (t_record->allergy_cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->allergy_qual,t_record->allergy_cnt)
    SET t_record->allergy_qual[t_record->allergy_cnt].category_id = cnvtreal(replace(t_line2,
      "MUL.ALGCAT!",""))
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 FOR (i = 1 TO t_record->allergy_cnt)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = t_record->drug_cnt2),
     mltm_alr_category_drug_map macdm,
     mltm_alr_category mac,
     order_catalog oc
    PLAN (d)
     JOIN (macdm
     WHERE (macdm.alr_category_id=t_record->allergy_qual[i].category_id)
      AND (macdm.drug_identifier=t_record->drug_qual2[d.seq].cki))
     JOIN (mac
     WHERE mac.alr_category_id=macdm.alr_category_id)
     JOIN (oc
     WHERE (oc.cki=t_record->drug_qual2[d.seq].long_cki))
    ORDER BY macdm.drug_identifier
    HEAD REPORT
     t_record->category_cnt = (t_record->category_cnt+ 1), stat = alterlist(t_record->category_qual,
      t_record->category_cnt), c_cnt = t_record->category_cnt,
     t_record->category_qual[c_cnt].category_id = macdm.alr_category_id, t_record->category_qual[
     c_cnt].category = mac.category_description
    DETAIL
     t_record->category_qual[c_cnt].drug_cnt = (t_record->category_qual[c_cnt].drug_cnt+ 1), stat =
     alterlist(t_record->category_qual[c_cnt].drug_qual,t_record->category_qual[c_cnt].drug_cnt),
     d_cnt = t_record->category_qual[c_cnt].drug_cnt,
     t_record->category_qual[c_cnt].drug_qual[d_cnt].drug_cki = concat("MUL.ORD!",macdm
      .drug_identifier), t_record->category_qual[c_cnt].drug_qual[d_cnt].drug = uar_get_code_display(
      oc.catalog_cd)
    WITH nocounter, time = 30
   ;end select
 ENDFOR
 SET stat = alterlist(out_rec->allergy_category,t_record->category_cnt)
 FOR (i = 1 TO t_record->category_cnt)
   SET out_rec->allergy_category[i].allergy_category_cki = concat("MUL.ALGCAT!",trim(cnvtstring(
      t_record->category_qual[i].category_id)))
   SET out_rec->allergy_category[i].allergy_category = t_record->category_qual[i].category
   SET stat = alterlist(out_rec->allergy_category[i].drug,t_record->category_qual[i].drug_cnt)
   FOR (j = 1 TO t_record->category_qual[i].drug_cnt)
    SET out_rec->allergy_category[i].drug[j].drug_cki = t_record->category_qual[i].drug_qual[j].
    drug_cki
    SET out_rec->allergy_category[i].drug[j].drug = t_record->category_qual[i].drug_qual[j].drug
   ENDFOR
 ENDFOR
 CALL echojson(out_rec, $1)
END GO
