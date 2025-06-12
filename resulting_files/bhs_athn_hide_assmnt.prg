CREATE PROGRAM bhs_athn_hide_assmnt
 RECORD t_rec(
   1 hidden_cnt = i4
   1 hidden_qual[*]
     2 key_name = vc
     2 hidden_value = vc
   1 a_line = vc
   1 dx_line = vc
   1 d_line = vc
   1 c_line = vc
   1 diag_cnt = i4
   1 diag_qual[*]
     2 key_name = vc
     2 diag = vc
     2 diag_id = vc
     2 specificity = vc
     2 plan_str = vc
     2 last_updated = vc
     2 last_updated_by = vc
     2 target_vocab_cd = vc
     2 prob_class_cd = vc
     2 prob_confirm_cd = vc
     2 nomen_id = vc
     2 checked = vc
     2 disabled = vc
     2 dx_group = vc
     2 dx_group_nomen_id = vc
     2 orig_nomen_id = vc
     2 diag_display = vc
     2 measure_set = vc
     2 hidden_ind = vc
     2 removable_ind = vc
     2 viewable = vc
     2 concept = vc
   1 t_element_cnt = i4
   1 t_elements[*]
     2 key_name = vc
     2 comment = vc
     2 last_updated = vc
     2 last_updated_by = vc
     2 measure_set = vc
     2 hidden_ind = vc
     2 removable_ind = vc
     2 target_vocab_cd = vc
     2 prob_class_cd = vc
     2 prob_confirm_cd = vc
     2 nomen_id = vc
     2 checked = vc
     2 disabled = vc
     2 dx_group = vc
     2 dx_group_nomen_id = vc
     2 orig_nomen_id = vc
     2 diag_display = vc
   1 concept_cnt = i4
   1 concept_qual[*]
     2 key_name = vc
     2 label = vc
     2 concept = vc
     2 column_name = vc
     2 measure_set = vc
     2 no_rule_ind = i2
 )
 RECORD d_rec(
   1 row[*]
     2 key_name = vc
     2 label = vc
     2 content[*]
       3 columnname = vc
       3 properties[*]
         4 name = vc
         4 value = vc
 )
 RECORD out_rec(
   1 assessment = vc
   1 last_updated = vc
   1 last_updated_by = vc
   1 diagnoses[*]
     2 key_name = vc
     2 diag = vc
     2 diag_id = vc
     2 specificity = vc
     2 plan_str = vc
     2 last_updated = vc
     2 last_updated_by = vc
     2 measure_set = vc
     2 removable_ind = vc
     2 hidden_ind = vc
     2 viewable_ind = vc
   1 a_line = vc
   1 dx_line = vc
 )
 DECLARE username = vc
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $3)
    AND p.active_ind=1)
  HEAD p.person_id
   username = p.username
  WITH nocounter, time = 30
 ;end select
 SET namelen = (textlen(username)+ 1)
 SET domainnamelen = (textlen(curdomain)+ 2)
 SET statval = memalloc(name,1,build("C",namelen))
 SET statval = memalloc(domainname,1,build("C",domainnamelen))
 SET name = username
 SET domainname = curdomain
 SET setcntxt = uar_secimpersonate(nullterm(username),nullterm(domainname))
 DECLARE d_cnt = i4
 DECLARE c_cnt = i4
 DECLARE t_line = vc
 DECLARE t_line1 = vc
 DECLARE str = vc
 DECLARE not_found = vc
 SET not_found = "<not_found>"
 DECLARE num = i4
 DECLARE data = vc
 DECLARE pos = i4
 DECLARE pos1 = i4
 FOR (i = 1 TO 50)
  SET t_line = piece( $4,"|",i,"not found")
  IF (t_line="not found")
   SET i = 51
  ELSE
   SET t_rec->hidden_cnt += 1
   SET stat = alterlist(t_rec->hidden_qual,t_rec->hidden_cnt)
   SET t_rec->hidden_qual[t_rec->hidden_cnt].key_name = piece(t_line,";",1,"not found")
   SET t_rec->hidden_qual[t_rec->hidden_cnt].hidden_value = piece(t_line,";",2,"not found")
  ENDIF
 ENDFOR
 SET t_rec->a_line = concat(
  '[{"KEY_NAME":"ASSESSMENT","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":""}},"ASSESSMENT":',
  '{"PROPIDX":{"TEXT":""}}},"HIDDEN_IND":0,"REMOVABLE_IND":""}]')
 SELECT INTO "nl:"
  FROM cust_mpg_config cmc
  PLAN (cmc
   WHERE cmc.config_key="ASSESSPLAN"
    AND cmc.end_effective_dt_tm > sysdate)
  HEAD REPORT
   t_rec->c_line = replace(cmc.json,"{FNORD}","")
  WITH nocounter, time = 30
 ;end select
 SET jrec = cnvtjsontorec(t_rec->c_line)
 FOR (i = 1 TO size(rconfig->card[2].object.row,5))
   SET t_rec->concept_cnt += 1
   SET stat = alterlist(t_rec->concept_qual,t_rec->concept_cnt)
   SET c_cnt = t_rec->concept_cnt
   SET t_rec->concept_qual[c_cnt].key_name = rconfig->card[2].object.row[i].key_name
   SET t_rec->concept_qual[c_cnt].label = rconfig->card[2].object.row[i].label
   IF (size(rconfig->card[2].object.row[i].display_rule,5) > 0)
    SET t_rec->concept_qual[c_cnt].concept = rconfig->card[2].object.row[i].display_rule[1].concept
   ENDIF
   IF (size(rconfig->card[2].object.row[i].content,5) > 0)
    SET t_rec->concept_qual[c_cnt].column_name = rconfig->card[2].object.row[i].content[1].columnname
    IF ((rconfig->card[2].object.row[i].content[1].columnname="MEASURESET"))
     IF ((rconfig->card[2].object.row[i].content[1].properties[1].name="CONFIGKEY"))
      SET t_rec->concept_qual[c_cnt].measure_set = rconfig->card[2].object.row[i].content[1].
      properties[1].value
     ELSEIF ((rconfig->card[2].object.row[i].content[1].properties[2].name="CONFIGKEY"))
      SET t_rec->concept_qual[c_cnt].measure_set = rconfig->card[2].object.row[i].content[1].
      properties[2].value
     ENDIF
    ENDIF
   ENDIF
   IF (size(rconfig->card[2].object.row[i].display_rule,5)=0)
    SET t_rec->concept_qual[c_cnt].no_rule_ind = 1
   ENDIF
 ENDFOR
 DECLARE person_id = f8
 SELECT INTO "nl:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id= $2))
  HEAD REPORT
   person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 EXECUTE bhs_athn_mpg_idr_diagnoses person_id,  $2,  $3 WITH replace("RREC",d_rec)
 FOR (i = 1 TO size(d_rec->row,5))
   SET t_rec->diag_cnt += 1
   SET stat = alterlist(t_rec->diag_qual,t_rec->diag_cnt)
   SET d_cnt = t_rec->diag_cnt
   SET t_rec->diag_qual[d_cnt].key_name = d_rec->row[i].key_name
   SET t_rec->diag_qual[d_cnt].diag = d_rec->row[i].label
   SET t_rec->diag_qual[d_cnt].diag_id = d_rec->row[i].content[6].properties[1].value
   IF (size(d_rec->row[i].content[5].properties,5) >= 4)
    SET t_rec->diag_qual[d_cnt].specificity = d_rec->row[i].content[5].properties[4].value
   ENDIF
   SET t_rec->diag_qual[d_cnt].viewable = "1"
 ENDFOR
 FOR (i = 2 TO t_rec->concept_cnt)
   SET t_rec->diag_cnt += 1
   SET stat = alterlist(t_rec->diag_qual,t_rec->diag_cnt)
   SET d_cnt = t_rec->diag_cnt
   SET t_rec->diag_qual[d_cnt].key_name = t_rec->concept_qual[i].key_name
   SET t_rec->diag_qual[d_cnt].diag = t_rec->concept_qual[i].label
   IF ((t_rec->concept_qual[i].column_name="PLAN"))
    SET t_rec->diag_qual[d_cnt].viewable = "1"
    SET t_rec->diag_qual[d_cnt].removable_ind = "1"
   ENDIF
   SET t_rec->diag_qual[d_cnt].concept = t_rec->concept_qual[i].concept
   SET t_rec->diag_qual[d_cnt].measure_set = t_rec->concept_qual[i].measure_set
   IF ((t_rec->concept_qual[i].no_rule_ind=1))
    SET t_rec->diag_qual[d_cnt].viewable = "1"
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_rec->diag_cnt),
   cust_concept cc,
   cust_concept_person_r ccpr
  PLAN (d)
   JOIN (cc
   WHERE (cc.concept_name_key=t_rec->diag_qual[d.seq].concept))
   JOIN (ccpr
   WHERE (ccpr.encntr_id= $2)
    AND ccpr.cust_concept_id=cc.cust_concept_id)
  DETAIL
   t_rec->diag_qual[d.seq].viewable = "1"
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM cust_mpg_rounding_sum cmrs
  PLAN (cmrs
   WHERE (cmrs.encntr_id= $2)
    AND (cmrs.updt_id= $3)
    AND cmrs.group_name="ASSESSMENT")
  DETAIL
   t_rec->a_line = cmrs.long_text
  WITH nocounter, time = 30
 ;end select
 SET pos = findstring('"ASSESSMENT":{"PROPIDX":{"TEXT":',t_rec->a_line,0)
 SET pos1 = findstring('"LAST_UPDATED"',t_rec->a_line,pos)
 SET out_rec->assessment = substring((pos+ 33),((pos1 - 3) - (pos+ 32)),t_rec->a_line)
 SET pos = pos1
 IF (pos > 0)
  SET pos1 = findstring("USER_DEFINED",t_rec->a_line,(pos+ 14))
  SET t_line1 = substring((pos+ 15),((pos1 - 2) - (pos+ 15)),t_rec->a_line)
  SET out_rec->last_updated = t_line1
 ENDIF
 SET pos = findstring("LAST_UPDATED_BY",t_rec->a_line,pos1)
 IF (pos > 0)
  SET pos1 = findstring("}}",t_rec->a_line,(pos+ 18))
  SET t_line1 = substring((pos+ 18),((pos1 - 1) - (pos+ 18)),t_rec->a_line)
  SET out_rec->last_updated_by = t_line1
 ENDIF
 SELECT INTO "nl:"
  FROM cust_mpg_rounding_sum cmrs
  PLAN (cmrs
   WHERE (cmrs.encntr_id= $2)
    AND (cmrs.updt_id= $3)
    AND cmrs.group_name="DIAGNOSES")
  ORDER BY cmrs.key_seq
  DETAIL
   t_rec->d_line = concat(t_rec->d_line,cmrs.long_text)
  FOOT REPORT
   t_rec->d_line = replace(t_rec->d_line,'{"KEY_NAME":',char(3))
  WITH nocounter, time = 30
 ;end select
 SET num = 1
 SET str = "zzz"
 SET data = t_rec->d_line
 WHILE (str != not_found)
   SET str = piece(data,char(3),num,not_found)
   IF (num > 1
    AND str != "<not_found>")
    SET t_line = str
    SET t_rec->t_element_cnt += 1
    SET stat = alterlist(t_rec->t_elements,t_rec->t_element_cnt)
    SET pos = findstring("DIAG_",t_line)
    IF (pos > 0)
     SET pos1 = findstring("CONTENTIDX",t_line,(pos+ 15))
     SET t_line1 = substring(pos,((pos1 - 3) - pos),t_line)
     SET t_rec->t_elements[t_rec->t_element_cnt].key_name = t_line1
     SET pos = findstring('"PLAN":{"PROPIDX":{"TEXT"',t_line,(pos1+ 1))
     SET pos1 = findstring("LAST_UPDATED",t_line,(pos+ 1))
     SET t_line1 = substring((pos+ 27),((pos1 - 2) - (pos+ 28)),t_line)
     SET t_rec->t_elements[t_rec->t_element_cnt].comment = t_line1
     SET pos = pos1
     IF (pos > 0)
      SET pos1 = findstring("USER_DEFINED",t_line,(pos+ 14))
      SET t_line1 = substring((pos+ 14),((pos1 - 2) - (pos+ 14)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].last_updated = t_line1
     ENDIF
     SET pos = findstring("LAST_UPDATED_BY",t_line,pos1)
     IF (pos > 0)
      SET pos1 = findstring("}}",t_line,(pos+ 18))
      SET t_line1 = substring((pos+ 18),((pos1 - 1) - (pos+ 18)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].last_updated_by = t_line1
     ENDIF
     SET pos = findstring("TARGET_VOCAB_CD",t_line,1)
     IF (pos > 0)
      SET pos1 = findstring("PROB_CLASS_CD",t_line,1)
      SET t_line1 = substring((pos+ 18),((pos1 - 4) - (pos+ 17)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].target_vocab_cd = t_line1
     ENDIF
     SET pos = findstring("PROB_CLASS_CD",t_line,1)
     IF (pos > 0)
      SET pos1 = findstring("PROB_CONFIRM_CD",t_line,1)
      SET t_line1 = substring((pos+ 16),((pos1 - 4) - (pos+ 15)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].prob_class_cd = t_line1
     ENDIF
     SET pos = findstring("PROB_CONFIRM_CD",t_line,1)
     IF (pos > 0)
      SET pos1 = findstring("NOMENCLATURE_ID",t_line,0)
      SET t_line1 = substring((pos+ 18),((pos1 - 4) - (pos+ 17)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].prob_confirm_cd = t_line1
     ENDIF
     SET pos = findstring("NOMENCLATURE_ID",t_line,1,0)
     IF (pos > 0)
      SET pos1 = findstring("CHECKED",t_line,pos,0)
      SET t_line1 = substring((pos+ 18),((pos1 - 4) - (pos+ 17)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].nomen_id = t_line1
     ENDIF
     SET pos = pos1
     IF (pos > 0)
      SET pos1 = findstring("DISABLED",t_line,pos,0)
      SET t_line1 = substring((pos+ 10),((pos1 - 4) - (pos+ 9)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].checked = t_line1
     ENDIF
     SET pos = pos1
     IF (pos > 0)
      SET pos1 = findstring("SPECIFICITY",t_line,pos,0)
      SET t_line1 = substring((pos+ 11),((pos1 - 7) - (pos+ 9)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].disabled = t_line1
     ENDIF
     SET pos = findstring("DIAGNOSIS_GROUP",t_line,1,0)
     IF (pos > 0)
      SET pos1 = findstring("NOMENCLATURE_ID",t_line,pos,0)
      SET t_line1 = substring((pos+ 37),((pos1 - 6) - (pos+ 36)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].dx_group = t_line1
     ENDIF
     SET pos = pos1
     IF (pos > 0)
      SET pos1 = findstring("ORIGINATING_NOMENCLATURE_ID",t_line,pos,0)
      SET t_line1 = substring((pos+ 37),((pos1 - 6) - (pos+ 36)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].dx_group_nomen_id = t_line1
     ENDIF
     SET pos = pos1
     IF (pos > 0)
      SET pos1 = findstring("DIAGNOSIS_DISPLAY",t_line,pos,0)
      SET t_line1 = substring((pos+ 49),((pos1 - 6) - (pos+ 48)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].orig_nomen_id = t_line1
     ENDIF
     SET pos = pos1
     IF (pos > 0)
      SET pos1 = findstring("QUALITY",t_line,pos,0)
      SET t_line1 = substring((pos+ 39),((pos1 - 6) - (pos+ 38)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].diag_display = t_line1
     ENDIF
     SET t_rec->t_elements[t_rec->t_element_cnt].removable_ind = "0"
     SET t_rec->t_elements[t_rec->t_element_cnt].hidden_ind = "0"
    ELSE
     SET pos = 0
     FOR (x = 1 TO t_rec->diag_cnt)
      SET pos = (findstring(concat('"',t_rec->diag_qual[x].key_name,'"'),t_line,0)+ 2)
      IF (pos > 0)
       SET x = (t_rec->diag_cnt+ 1)
      ENDIF
     ENDFOR
     IF (pos > 0)
      SET pos1 = findstring("CONTENTIDX",t_line,pos)
      SET t_line1 = substring(pos,((pos1 - 3) - pos),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].key_name = t_line1
      SET pos = findstring('"PLAN":{"PROPIDX":{"TEXT"',t_line,(pos1+ 1))
      SET pos1 = findstring("LAST_UPDATED",t_line,(pos+ 1))
      SET t_line1 = substring((pos+ 27),((pos1 - 2) - (pos+ 28)),t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].comment = t_line1
      SET pos = pos1
      IF (pos > 0)
       SET pos1 = findstring("USER_DEFINED",t_line,(pos+ 14))
       SET t_line1 = substring((pos+ 14),((pos1 - 2) - (pos+ 14)),t_line)
       SET t_rec->t_elements[t_rec->t_element_cnt].last_updated = t_line1
      ENDIF
      SET pos = findstring("LAST_UPDATED_BY",t_line,pos1)
      IF (pos > 0)
       SET pos1 = findstring("}}",t_line,(pos+ 18))
       SET t_line1 = substring((pos+ 18),((pos1 - 1) - (pos+ 18)),t_line)
       SET t_rec->t_elements[t_rec->t_element_cnt].last_updated_by = t_line1
      ENDIF
     ENDIF
     SET pos = findstring("REMOVABLE_IND",t_line,0)
     IF (pos > 0)
      SET t_line1 = substring((pos+ 16),1,t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].removable_ind = t_line1
      IF ((t_rec->t_elements[t_rec->t_element_cnt].removable_ind != "1"))
       SET t_rec->t_elements[t_rec->t_element_cnt].removable_ind = "0"
      ENDIF
     ENDIF
     SET pos = findstring("HIDDEN_IND",t_line,0)
     IF (pos > 0)
      SET t_line1 = substring((pos+ 12),1,t_line)
      SET t_rec->t_elements[t_rec->t_element_cnt].hidden_ind = t_line1
      IF ( NOT ((t_rec->t_elements[t_rec->t_element_cnt].hidden_ind IN ("0", "1"))))
       SET t_rec->t_elements[t_rec->t_element_cnt].hidden_ind = ""
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   SET num += 1
 ENDWHILE
 FOR (i = 1 TO t_rec->diag_cnt)
   FOR (j = 1 TO t_rec->t_element_cnt)
     IF ((t_rec->diag_qual[i].key_name=t_rec->t_elements[j].key_name))
      SET t_rec->diag_qual[i].plan_str = t_rec->t_elements[j].comment
      SET t_rec->diag_qual[i].last_updated = t_rec->t_elements[j].last_updated
      SET t_rec->diag_qual[i].last_updated_by = t_rec->t_elements[j].last_updated_by
      SET t_rec->diag_qual[i].hidden_ind = t_rec->t_elements[j].hidden_ind
      SET t_rec->diag_qual[i].removable_ind = t_rec->t_elements[j].removable_ind
      SET t_rec->diag_qual[i].target_vocab_cd = t_rec->t_elements[j].target_vocab_cd
      SET t_rec->diag_qual[i].prob_class_cd = t_rec->t_elements[j].prob_class_cd
      SET t_rec->diag_qual[i].prob_confirm_cd = t_rec->t_elements[j].prob_confirm_cd
      SET t_rec->diag_qual[i].nomen_id = t_rec->t_elements[j].nomen_id
      SET t_rec->diag_qual[i].checked = t_rec->t_elements[j].checked
      SET t_rec->diag_qual[i].disabled = t_rec->t_elements[j].disabled
      SET t_rec->diag_qual[i].dx_group = t_rec->t_elements[j].dx_group
      SET t_rec->diag_qual[i].dx_group_nomen_id = t_rec->t_elements[j].dx_group_nomen_id
      SET t_rec->diag_qual[i].orig_nomen_id = t_rec->t_elements[j].orig_nomen_id
      SET t_rec->diag_qual[i].diag_display = t_rec->t_elements[j].diag_display
     ENDIF
   ENDFOR
 ENDFOR
 SET d_cnt = 0
 FOR (i = 1 TO t_rec->diag_cnt)
   SET d_cnt += 1
   SET stat = alterlist(out_rec->diagnoses,d_cnt)
   SET out_rec->diagnoses[d_cnt].key_name = t_rec->diag_qual[i].key_name
   SET out_rec->diagnoses[d_cnt].diag = t_rec->diag_qual[i].diag
   SET out_rec->diagnoses[d_cnt].diag_id = t_rec->diag_qual[i].diag_id
   SET out_rec->diagnoses[d_cnt].specificity = t_rec->diag_qual[i].specificity
   SET out_rec->diagnoses[d_cnt].plan_str = t_rec->diag_qual[i].plan_str
   SET out_rec->diagnoses[d_cnt].last_updated = t_rec->diag_qual[i].last_updated
   SET out_rec->diagnoses[d_cnt].last_updated_by = t_rec->diag_qual[i].last_updated_by
   SET out_rec->diagnoses[d_cnt].measure_set = t_rec->diag_qual[i].measure_set
   SET out_rec->diagnoses[d_cnt].hidden_ind = t_rec->diag_qual[i].hidden_ind
   SET out_rec->diagnoses[d_cnt].removable_ind = t_rec->diag_qual[i].removable_ind
   SET out_rec->diagnoses[d_cnt].viewable_ind = t_rec->diag_qual[i].viewable
   IF ( NOT ((out_rec->diagnoses[d_cnt].viewable_ind IN ("0", "1")))
    AND (out_rec->diagnoses[d_cnt].key_name != "CODESTATUS"))
    SET out_rec->diagnoses[d_cnt].viewable_ind = "0"
   ENDIF
   IF ((out_rec->diagnoses[d_cnt].key_name="CODESTATUS")
    AND (out_rec->diagnoses[d_cnt].viewable_ind=""))
    SET out_rec->diagnoses[d_cnt].viewable_ind = "1"
   ENDIF
 ENDFOR
 SET out_rec->a_line = t_rec->a_line
 FOR (i = 1 TO t_rec->hidden_cnt)
   FOR (j = 1 TO t_rec->diag_cnt)
     IF ((t_rec->hidden_qual[i].key_name=t_rec->diag_qual[j].key_name))
      SET t_rec->diag_qual[j].hidden_ind = t_rec->hidden_qual[i].hidden_value
     ENDIF
   ENDFOR
 ENDFOR
 FOR (i = 1 TO t_rec->hidden_cnt)
   FOR (j = 1 TO size(out_rec->diagnoses,5))
     IF ((t_rec->hidden_qual[i].key_name=out_rec->diagnoses[j].key_name))
      SET out_rec->diagnoses[j].hidden_ind = t_rec->hidden_qual[i].hidden_value
     ENDIF
   ENDFOR
 ENDFOR
 SET out_rec->dx_line = "["
 FOR (i = 1 TO t_rec->diag_cnt)
   IF ((t_rec->diag_qual[i].key_name="DIAG_*"))
    SET out_rec->dx_line = concat(out_rec->dx_line,'{"KEY_NAME":"',t_rec->diag_qual[i].key_name,'","',
     'CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"',
     t_rec->diag_qual[i].diag,'","CLICKFN":"modifyDx"}},')
    IF ((t_rec->diag_qual[i].plan_str > " "))
     SET out_rec->dx_line = concat(out_rec->dx_line,'"PLAN":{"PROPIDX":{"TEXT":"',t_rec->diag_qual[i]
      .plan_str,'","LAST_UPDATED":',t_rec->diag_qual[i].last_updated,
      ',"USER_DEFINED":1,"','LAST_UPDATED_BY":"',t_rec->diag_qual[i].last_updated_by,'"}},')
    ELSE
     SET out_rec->dx_line = concat(out_rec->dx_line,'"PLAN":{"PROPIDX":{"TEXT":""}},')
    ENDIF
    SET out_rec->dx_line = concat(out_rec->dx_line,
     '"INNOTE":{"PROPIDX":{"FUNCTIONNAME":"renderIncludeInNote","USER_SPECIFIC":"false",',
     '"DEFAULT_CHECKED":"true"}},"CHRONIC":{"PROPIDX":{"CLICKFN":"cnvtDxtoProblem","TARGET_VOCAB_CD":"'
     )
    SET out_rec->dx_line = concat(out_rec->dx_line,t_rec->diag_qual[i].target_vocab_cd,
     '","PROB_CLASS_CD":"',t_rec->diag_qual[i].prob_class_cd,'","PROB_CONFIRM_CD":"',
     t_rec->diag_qual[i].prob_confirm_cd,'","NOMENCLATURE_ID":"',t_rec->diag_qual[i].nomen_id,
     '","CHECKED":"',t_rec->diag_qual[i].checked,
     '","DISABLED":"',t_rec->diag_qual[i].disabled,'"}},')
    IF ((t_rec->diag_qual[i].specificity="Specified"))
     SET out_rec->dx_line = concat(out_rec->dx_line,
      '"SPECIFICITY":{"PROPIDX":{"TEXT":"Y","ICON":"uhspa-specified-condition",',
      '"CLICKFN":"openDxAssist","TITLETEXT":"Specified"}},')
    ENDIF
    IF ((t_rec->diag_qual[i].specificity="Unspecified"))
     SET out_rec->dx_line = concat(out_rec->dx_line,
      '"SPECIFICITY":{"PROPIDX":{"TEXT":"N","ICON":"uhspa-unspecified-condition",',
      '"CLICKFN":"openDxAssist","TITLETEXT":"Unspecified"}},')
    ENDIF
    SET out_rec->dx_line = concat(out_rec->dx_line,'"DIAGNOSIS_ID":{"PROPIDX":{"TEXT":"',t_rec->
     diag_qual[i].diag_id,'"}},"DIAGNOSIS_GROUP":{"PROPIDX":{"TEXT":"',t_rec->diag_qual[i].dx_group,
     '"}},"NOMENCLATURE_ID":{"PROPIDX":{"TEXT":"',t_rec->diag_qual[i].dx_group_nomen_id,
     '"}},"ORIGINATING_NOMENCLATURE_ID":{"PROPIDX":{"TEXT":"',t_rec->diag_qual[i].orig_nomen_id,
     '"}},"DIAGNOSIS_DISPLAY":{"PROPIDX":{"TEXT":"',
     t_rec->diag_qual[i].diag_display,
     '"}},"QUALITY":{"PROPIDX":{"TEXT":""}},"MEASURESET":{"PROPIDX":{"TEXT":""}}},"REMOVABLE_IND":0},'
     )
   ELSE
    IF ((t_rec->diag_qual[i].measure_set > " "))
     IF ((t_rec->diag_qual[i].key_name="VTE"))
      SET out_rec->dx_line = concat(out_rec->dx_line,'{"KEY_NAME":"',t_rec->diag_qual[i].key_name,
       '","CONTENTIDX":{"LABEL":{"PROPIDX":','{"TEXT":"',
       t_rec->diag_qual[i].diag,'"}},"MEASURESET":{"PROPIDX":{"CONFIGKEY":"',t_rec->diag_qual[i].
       measure_set,'","FUNCTIONNAME":"openMeasureSet","TEXT":""}},',
       '"SPECIFICITY":{"PROPIDX":{"TEXT":""}},"QUALITY":{"PROPIDX":{"TEXT":""}},')
     ELSE
      SET out_rec->dx_line = concat(out_rec->dx_line,'{"KEY_NAME":"',t_rec->diag_qual[i].key_name,
       '","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"',t_rec->diag_qual[i].diag,
       '"}},"MEASURESET":{"PROPIDX":{"FUNCTIONNAME":"openMeasureSet","CONFIGKEY":"',t_rec->diag_qual[
       i].measure_set,'","TEXT":""}},"SPECIFICITY":{"PROPIDX":{"TEXT":""}},',
       '"QUALITY":{"PROPIDX":{"TEXT":""}},')
     ENDIF
     IF ((t_rec->diag_qual[i].plan_str > " "))
      SET out_rec->dx_line = concat(out_rec->dx_line,'"PLAN":{"PROPIDX":{"TEXT":"',t_rec->diag_qual[i
       ].plan_str,'","LAST_UPDATED":',t_rec->diag_qual[i].last_updated,
       ',"USER_DEFINED":1,"','LAST_UPDATED_BY":"',t_rec->diag_qual[i].last_updated_by,'"}}},')
     ELSE
      SET out_rec->dx_line = concat(out_rec->dx_line,'"PLAN":{"PROPIDX":{"TEXT":""}}},')
     ENDIF
     SET out_rec->dx_line = concat(out_rec->dx_line,'"HIDDEN_IND":0,"REMOVABLE_IND":""},')
    ELSE
     SET out_rec->dx_line = concat(out_rec->dx_line,'{"KEY_NAME":"',t_rec->diag_qual[i].key_name,
      '","CONTENTIDX":{"LABEL":{"PROPIDX":{"TEXT":"',t_rec->diag_qual[i].diag,
      '"}},')
     IF ((t_rec->diag_qual[i].plan_str > " "))
      SET out_rec->dx_line = concat(out_rec->dx_line,'"PLAN":{"PROPIDX":{"TEXT":"',t_rec->diag_qual[i
       ].plan_str,'","LAST_UPDATED":',t_rec->diag_qual[i].last_updated,
       ',"USER_DEFINED":1,"','LAST_UPDATED_BY":"',t_rec->diag_qual[i].last_updated_by,'"}},')
     ELSE
      SET out_rec->dx_line = concat(out_rec->dx_line,'"PLAN":{"PROPIDX":{"TEXT":""}},')
     ENDIF
     SET out_rec->dx_line = concat(out_rec->dx_line,
      '"SPECIFICITY":{"PROPIDX":{"TEXT":""}},"QUALITY":{"PROPIDX":{"TEXT":""}},',
      '"MEASURESET":{"PROPIDX":{"TEXT":""}}},"HIDDEN_IND":',t_rec->diag_qual[i].hidden_ind,
      ',"REMOVABLE_IND":"',
      t_rec->diag_qual[i].removable_ind,'"},')
    ENDIF
   ENDIF
 ENDFOR
 SET out_rec->dx_line = concat(out_rec->dx_line,"]")
 SET out_rec->dx_line = replace(out_rec->dx_line,",]","]")
 EXECUTE uhs_mpg_upd_rounding_sum "mine",  $2, "DIAGNOSES",
 "", "", out_rec->dx_line,
 "1"
END GO
