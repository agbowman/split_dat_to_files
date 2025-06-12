CREATE PROGRAM bhs_athn_drug_interactions
 RECORD orequest(
   1 person_id = f8
   1 dc_intr_days_flag = i2
 )
 RECORD t_record(
   1 drug_cnt = i4
   1 drug_qual[*]
     2 cki = vc
   1 o_drug_cnt = i4
   1 o_drug_qual[*]
     2 cki = vc
   1 int_cnt = i4
   1 int_qual[*]
     2 int_id = f8
     2 drug1 = vc
     2 drug2 = vc
 )
 RECORD out_rec(
   1 severity_pref = vc
   1 severity_pref_desc = vc
   1 interactions[*]
     2 drug1 = vc
     2 drug1_cki = vc
     2 drug2 = vc
     2 drug2_cki = vc
     2 severity = vc
     2 severity_value = vc
     2 interaction_text = vc
 )
 DECLARE dup_ind = i2
 SELECT INTO "nl:"
  FROM name_value_prefs nvp,
   app_prefs ap,
   mltm_severity ms
  PLAN (nvp
   WHERE nvp.parent_entity_name="APP_PREFS"
    AND cnvtupper(nvp.pvc_name)="MUL*"
    AND nvp.pvc_name="MULFSEVERITY"
    AND nvp.active_ind=1)
   JOIN (ap
   WHERE ap.app_prefs_id=nvp.parent_entity_id
    AND ap.application_number=600005
    AND ap.active_ind=1
    AND ap.position_cd=0)
   JOIN (ms
   WHERE ms.severity_id=cnvtreal(nvp.pvc_value))
  HEAD REPORT
   out_rec->severity_pref = nvp.pvc_value, out_rec->severity_pref_desc = ms.severity_description
  WITH time = 30
 ;end select
 SET orequest->person_id =  $2
 SET stat = tdbexecute(3200000,3200081,965238,"REC",orequest,
  "REC",oreply)
 CALL echorecord(oreply)
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
 CALL echorecord(t_record)
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
 FOR (i = 1 TO t_record->o_drug_cnt)
   FOR (j = 1 TO t_record->drug_cnt)
     SELECT INTO "nl:"
      FROM mltm_int_drug_interactions midi
      PLAN (midi
       WHERE (midi.drug_identifier_1=t_record->o_drug_qual[i].cki)
        AND (midi.drug_identifier_2=t_record->drug_qual[j].cki))
      DETAIL
       t_record->int_cnt = (t_record->int_cnt+ 1), stat = alterlist(t_record->int_qual,t_record->
        int_cnt), t_record->int_qual[t_record->int_cnt].int_id = midi.int_id,
       t_record->int_qual[t_record->int_cnt].drug1 = midi.drug_identifier_1, t_record->int_qual[
       t_record->int_cnt].drug2 = midi.drug_identifier_2
      WITH nocounter, time = 30
     ;end select
   ENDFOR
 ENDFOR
 FOR (i = 1 TO t_record->drug_cnt)
   FOR (j = 1 TO t_record->o_drug_cnt)
     SELECT INTO "nl:"
      FROM mltm_int_drug_interactions midi
      PLAN (midi
       WHERE (midi.drug_identifier_1=t_record->drug_qual[i].cki)
        AND (midi.drug_identifier_2=t_record->o_drug_qual[j].cki))
      DETAIL
       t_record->int_cnt = (t_record->int_cnt+ 1), stat = alterlist(t_record->int_qual,t_record->
        int_cnt), t_record->int_qual[t_record->int_cnt].int_id = midi.int_id,
       t_record->int_qual[t_record->int_cnt].drug1 = midi.drug_identifier_1, t_record->int_qual[
       t_record->int_cnt].drug2 = midi.drug_identifier_2
      WITH nocounter, time = 30
     ;end select
   ENDFOR
 ENDFOR
 FOR (i = 1 TO t_record->o_drug_cnt)
   FOR (j = 1 TO t_record->o_drug_cnt)
     SELECT INTO "nl:"
      FROM mltm_int_drug_interactions midi
      PLAN (midi
       WHERE (midi.drug_identifier_1=t_record->o_drug_qual[i].cki)
        AND (midi.drug_identifier_2=t_record->o_drug_qual[j].cki))
      DETAIL
       t_record->int_cnt = (t_record->int_cnt+ 1), stat = alterlist(t_record->int_qual,t_record->
        int_cnt), t_record->int_qual[t_record->int_cnt].int_id = midi.int_id,
       t_record->int_qual[t_record->int_cnt].drug1 = midi.drug_identifier_1, t_record->int_qual[
       t_record->int_cnt].drug2 = midi.drug_identifier_2
      WITH nocounter, time = 30
     ;end select
   ENDFOR
 ENDFOR
 SET stat = alterlist(out_rec->interactions,t_record->int_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->int_cnt),
   mltm_int_drug_interactions midi,
   mltm_int_interact_severity_map miisp,
   mltm_severity ms,
   mltm_interaction_description mid,
   mltm_drug_name_map mdnm1,
   mltm_drug_name_map mdnm2,
   mltm_drug_name mdn1,
   mltm_drug_name mdn2
  PLAN (d)
   JOIN (midi
   WHERE (midi.int_id=t_record->int_qual[d.seq].int_id)
    AND (midi.drug_identifier_1=t_record->int_qual[d.seq].drug1)
    AND (midi.drug_identifier_2=t_record->int_qual[d.seq].drug2))
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
   JOIN (mdnm2
   WHERE mdnm2.drug_identifier=midi.drug_identifier_2
    AND mdnm2.function_id=16)
   JOIN (mdn2
   WHERE mdn2.drug_synonym_id=mdnm2.drug_synonym_id)
  DETAIL
   out_rec->interactions[d.seq].drug1 = mdn1.drug_name, out_rec->interactions[d.seq].drug1_cki =
   concat("MUL.ORD!",midi.drug_identifier_1), out_rec->interactions[d.seq].drug2 = mdn2.drug_name,
   out_rec->interactions[d.seq].drug2_cki = concat("MUL.ORD!",midi.drug_identifier_2), out_rec->
   interactions[d.seq].severity = ms.severity_description, out_rec->interactions[d.seq].
   severity_value = trim(cnvtstring(ms.severity_id)),
   out_rec->interactions[d.seq].interaction_text = mid.int_desc_text
  WITH nocounter, time = 30
 ;end select
 FOR (i = 1 TO size(out_rec->interactions,5))
   SELECT
    severity = evaluate(der.rank_sequence,0,"**SUPPRESSED**",1,"MINOR",
     2,"MODERATE",3,"MAJOR"), severity_heading = evaluate(der.entity1_name,"1","CONTRAINDICATED","2",
     "GENERALLY AVOID",
     "4","MONITOR CLOSELY","8","ADJUST DOSING INTERVAL","16",
     "ADJUST DOSE","32","ADDITIONAL CONTRACEPTION RECOMMENDED","64","MONITOR",
     der.entity1_name,der.entity1_name)
    FROM dcp_entity_reltn der
    PLAN (der
     WHERE der.entity_reltn_mean IN ("DRUG/DRUG")
      AND cnvtlower(der.entity1_display)=cnvtlower(out_rec->interactions[i].drug1)
      AND cnvtlower(der.entity2_display)=cnvtlower(out_rec->interactions[i].drug2)
      AND der.active_ind=1)
    DETAIL
     out_rec->interactions[i].severity = concat(trim(severity),"-",trim(severity_heading)), out_rec->
     interactions[i].severity_value = trim(cnvtstring(der.rank_sequence))
    WITH time = 30
   ;end select
 ENDFOR
 CALL echojson(out_rec, $1)
END GO
