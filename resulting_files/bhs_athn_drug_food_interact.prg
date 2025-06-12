CREATE PROGRAM bhs_athn_drug_food_interact
 RECORD t_record(
   1 drug_cnt = i4
   1 drug_qual[*]
     2 cki = vc
   1 int_cnt = i4
   1 int_qual[*]
     2 int_id = f8
     2 drug1 = vc
     2 drug2 = vc
 )
 RECORD out_rec(
   1 interactions[*]
     2 drug1 = vc
     2 drug1_cki = vc
     2 drug2 = vc
     2 severity = vc
     2 severity_value = vc
     2 interaction_text = vc
 )
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET t_line =  $2
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->drug_cnt = (t_record->drug_cnt+ 1)
    SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
    SET t_record->drug_qual[t_record->drug_cnt].cki = replace(t_line,"MUL.ORD!","")
    SET done = 1
   ELSE
    SET t_record->drug_cnt = (t_record->drug_cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
    SET t_record->drug_qual[t_record->drug_cnt].cki = replace(t_line2,"MUL.ORD!","")
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->drug_cnt),
   mltm_int_drug_interactions midi,
   mltm_int_interact_severity_map miisp,
   mltm_severity ms,
   mltm_interaction_description mid,
   mltm_drug_name_map mdnm1,
   mltm_drug_name mdn1
  PLAN (d)
   JOIN (midi
   WHERE (midi.drug_identifier_1=t_record->drug_qual[d.seq].cki)
    AND cnvtlower(midi.drug_identifier_2)="food")
   JOIN (miisp
   WHERE miisp.int_id=midi.int_id)
   JOIN (ms
   WHERE ms.severity_id=midi.severity_id)
   JOIN (mid
   WHERE mid.int_id=midi.int_id)
   JOIN (mdnm1
   WHERE mdnm1.drug_identifier=midi.drug_identifier_1
    AND mdnm1.function_id=16)
   JOIN (mdn1
   WHERE mdn1.drug_synonym_id=mdnm1.drug_synonym_id)
  HEAD REPORT
   i_cnt = 0
  DETAIL
   i_cnt = (i_cnt+ 1), stat = alterlist(out_rec->interactions,i_cnt), out_rec->interactions[i_cnt].
   drug1 = mdn1.drug_name,
   out_rec->interactions[i_cnt].drug1_cki = concat("MUL.ORD!",midi.drug_identifier_1), out_rec->
   interactions[i_cnt].drug2 = "food", out_rec->interactions[i_cnt].severity = ms
   .severity_description,
   out_rec->interactions[i_cnt].severity_value = trim(cnvtstring(ms.severity_id)), out_rec->
   interactions[i_cnt].interaction_text = mid.int_desc_text
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
