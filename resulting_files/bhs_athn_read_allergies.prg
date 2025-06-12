CREATE PROGRAM bhs_athn_read_allergies
 RECORD orequest(
   1 person_id = f8
   1 person[*]
     2 person_id = f8
   1 allergy[*]
     2 allergy_id = f8
   1 cancel_ind = i2
 )
 RECORD out_rec(
   1 status = vc
   1 person[*]
     2 person_id = vc
     2 allergies[*]
       3 allergy_id = vc
       3 encntr_id = vc
       3 substance_nom_id = vc
       3 substance_desc = vc
       3 substance_type_disp = vc
       3 substance_type_mean = vc
       3 substance_type_cd = vc
       3 reaction_class_disp = vc
       3 reaction_class_mean = vc
       3 reaction_class_cd = vc
       3 severity_disp = vc
       3 severity_mean = vc
       3 severity_cd = vc
       3 source_of_info_disp = vc
       3 source_of_info_mean = vc
       3 source_of_info_cd = vc
       3 reaction_status_disp = vc
       3 reaction_status_mean = vc
       3 reaction_status_cd = vc
       3 created_dt_tm = vc
       3 created_prsnl_name = vc
       3 created_prsnl_id = vc
       3 cancel_reason_disp = vc
       3 cancel_reason_cd = vc
       3 verified_status = vc
       3 concept_identifier = vc
       3 concept_source_disp = vc
       3 concept_source_mean = vc
       3 concept_source_cd = vc
       3 onset_dt_tm = vc
       3 onset_precision_disp = vc
       3 onset_precision_cd = vc
       3 onset_precision_flag = vc
       3 reviewed_dt_tm = vc
       3 reviewed_prsnl_name = vc
       3 reviewed_prsnl_id = vc
       3 orig_prsnl_name = vc
       3 orig_prsnl_id = vc
       3 reaction_status_dt_tm = vc
       3 beg_effective_dt_tm = vc
       3 end_effective_dt_tm = vc
       3 updt_name = vc
       3 updt_id = vc
       3 updt_dt_tm = vc
       3 updt_cnt = vc
       3 reaction[*]
         4 allergy_instance_id = vc
         4 reaction_id = vc
         4 reaction_nom_id = vc
         4 source_string = vc
         4 reaction_ftdesc = vc
         4 beg_effective_dt_tm = vc
         4 active_ind = vc
         4 end_effective_dt_tm = vc
         4 updt_id = vc
         4 updt_dt_tm = vc
         4 updt_cnt = vc
       3 comment[*]
         4 allergy_comment_id = vc
         4 comment_dt_tm = vc
         4 comment_prsnl_name = vc
         4 comment_prsnl_id = vc
         4 comment = vc
         4 beg_effective_dt_tm = vc
 )
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET cnt = 0
 SET t_line =  $2
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET cnt += 1
    SET stat = alterlist(orequest->person,cnt)
    SET orequest->person[cnt].person_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(orequest->person,cnt)
    SET orequest->person[cnt].person_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SET t_line2 = ""
 SET cnt = 0
 SET done = 0
 SET t_line =  $3
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET cnt += 1
    SET stat = alterlist(orequest->allergy,cnt)
    SET orequest->allergy[cnt].allergy_id = cnvtreal(t_line)
    SET done = 1
   ELSE
    SET cnt += 1
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(orequest->allergy,cnt)
    SET orequest->allergy[cnt].allergy_id = cnvtreal(t_line2)
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 IF (size(orequest->person,5) > 0
  AND (orequest->person[1].person_id=0))
  SET stat = alterlist(orequest->person,0)
 ENDIF
 IF (size(orequest->allergy,5) > 0
  AND (orequest->allergy[1].allergy_id=0))
  SET stat = alterlist(orequest->allergy,0)
 ENDIF
 IF (size(orequest->person,5) > 0
  AND (orequest->person[1].person_id > 0)
  AND size(orequest->allergy,5) > 0
  AND (orequest->allergy[1].allergy_id > 0))
  SET out_rec->status = "Failed"
  GO TO end_script
 ENDIF
 SET orequest->cancel_ind =  $4
 SET stat = tdbexecute(3200000,3200065,3200123,"REC",orequest,
  "REC",oreply,4)
 IF ((oreply->status_data.status="S"))
  SET out_rec->status = "Success"
 ELSE
  SET out_rec->status = "Failed"
 ENDIF
 SET stat = alterlist(out_rec->person,size(oreply->person,5))
 FOR (i = 1 TO size(oreply->person,5))
   SET out_rec->person[i].person_id = cnvtstring(oreply->person[i].person_id)
   SET stat = alterlist(out_rec->person[i].allergies,size(oreply->person[i].allergy,5))
   FOR (j = 1 TO size(oreply->person[i].allergy,5))
     SET out_rec->person[i].allergies[j].allergy_id = cnvtstring(oreply->person[i].allergy[j].
      allergy_id)
     SET out_rec->person[i].allergies[j].encntr_id = cnvtstring(oreply->person[i].allergy[j].
      encntr_id)
     SET out_rec->person[i].allergies[j].substance_nom_id = cnvtstring(oreply->person[i].allergy[j].
      substance_nom_id)
     IF ((oreply->person[i].allergy[j].source_string > " "))
      SET out_rec->person[i].allergies[j].substance_desc = oreply->person[i].allergy[j].source_string
     ELSE
      SET out_rec->person[i].allergies[j].substance_desc = oreply->person[i].allergy[j].
      substance_ftdesc
     ENDIF
     SET out_rec->person[i].allergies[j].substance_type_disp = oreply->person[i].allergy[j].
     substance_type_disp
     SET out_rec->person[i].allergies[j].substance_type_mean = oreply->person[i].allergy[j].
     substance_type_mean
     SET out_rec->person[i].allergies[j].substance_type_cd = cnvtstring(oreply->person[i].allergy[j].
      substance_type_cd)
     SET out_rec->person[i].allergies[j].reaction_class_disp = oreply->person[i].allergy[j].
     reaction_class_disp
     SET out_rec->person[i].allergies[j].reaction_class_mean = oreply->person[i].allergy[j].
     reaction_class_mean
     SET out_rec->person[i].allergies[j].reaction_class_cd = cnvtstring(oreply->person[i].allergy[j].
      reaction_class_cd)
     SET out_rec->person[i].allergies[j].severity_disp = oreply->person[i].allergy[j].severity_disp
     SET out_rec->person[i].allergies[j].severity_mean = oreply->person[i].allergy[j].severity_mean
     SET out_rec->person[i].allergies[j].severity_cd = cnvtstring(oreply->person[i].allergy[j].
      severity_cd)
     SET out_rec->person[i].allergies[j].source_of_info_disp = oreply->person[i].allergy[j].
     source_of_info_disp
     SET out_rec->person[i].allergies[j].source_of_info_mean = oreply->person[i].allergy[j].
     source_of_info_mean
     SET out_rec->person[i].allergies[j].source_of_info_cd = cnvtstring(oreply->person[i].allergy[j].
      source_of_info_cd)
     SET out_rec->person[i].allergies[j].reaction_status_disp = oreply->person[i].allergy[j].
     reaction_status_disp
     SET out_rec->person[i].allergies[j].reaction_status_mean = oreply->person[i].allergy[j].
     reaction_status_mean
     SET out_rec->person[i].allergies[j].reaction_status_cd = cnvtstring(oreply->person[i].allergy[j]
      .reaction_status_cd)
     SET out_rec->person[i].allergies[j].created_dt_tm = datetimezoneformat(oreply->person[i].
      allergy[j].created_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
     SET out_rec->person[i].allergies[j].created_prsnl_name = oreply->person[i].allergy[j].
     created_prsnl_name
     SET out_rec->person[i].allergies[j].created_prsnl_id = cnvtstring(oreply->person[i].allergy[j].
      created_prsnl_id)
     SET out_rec->person[i].allergies[j].cancel_reason_disp = oreply->person[i].allergy[j].
     cancel_reason_disp
     SET out_rec->person[i].allergies[j].cancel_reason_cd = cnvtstring(oreply->person[i].allergy[j].
      cancel_reason_cd)
     IF ((oreply->person[i].allergy[j].verified_status_flag=1))
      SET out_rec->person[i].allergies[j].verified_status = "true"
     ELSE
      SET out_rec->person[i].allergies[j].verified_status = "false"
     ENDIF
     SET out_rec->person[i].allergies[j].concept_identifier = oreply->person[i].allergy[j].
     concept_identifier
     SET out_rec->person[i].allergies[j].concept_source_disp = oreply->person[i].allergy[j].
     concept_source_disp
     SET out_rec->person[i].allergies[j].concept_source_mean = oreply->person[i].allergy[j].
     concept_source_mean
     SET out_rec->person[i].allergies[j].concept_source_cd = cnvtstring(oreply->person[i].allergy[j].
      concept_source_cd)
     SET out_rec->person[i].allergies[j].onset_dt_tm = datetimezoneformat(oreply->person[i].allergy[j
      ].onset_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
     SET out_rec->person[i].allergies[j].onset_precision_disp = oreply->person[i].allergy[j].
     onset_precision_disp
     SET out_rec->person[i].allergies[j].onset_precision_cd = cnvtstring(oreply->person[i].allergy[j]
      .onset_precision_cd)
     IF ((oreply->person[i].allergy[j].onset_precision_flag=10))
      SET out_rec->person[i].allergies[j].onset_precision_flag = "NotEntered"
     ELSEIF ((oreply->person[i].allergy[j].onset_precision_flag=20))
      SET out_rec->person[i].allergies[j].onset_precision_flag = "ThisDay"
     ELSEIF ((oreply->person[i].allergy[j].onset_precision_flag=30))
      SET out_rec->person[i].allergies[j].onset_precision_flag = "ThisWeek"
     ELSEIF ((oreply->person[i].allergy[j].onset_precision_flag=40))
      SET out_rec->person[i].allergies[j].onset_precision_flag = "ThisMonth"
     ELSEIF ((oreply->person[i].allergy[j].onset_precision_flag=50))
      SET out_rec->person[i].allergies[j].onset_precision_flag = "ThisYear"
     ELSEIF ((oreply->person[i].allergy[j].onset_precision_flag=60))
      SET out_rec->person[i].allergies[j].onset_precision_flag = "DateAndTime"
     ENDIF
     SET out_rec->person[i].allergies[j].reviewed_dt_tm = datetimezoneformat(oreply->person[i].
      allergy[j].reviewed_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
     SET out_rec->person[i].allergies[j].reviewed_prsnl_name = oreply->person[i].allergy[j].
     reviewed_prsnl_name
     SET out_rec->person[i].allergies[j].reviewed_prsnl_id = cnvtstring(oreply->person[i].allergy[j].
      reviewed_prsnl_id)
     SET out_rec->person[i].allergies[j].orig_prsnl_name = oreply->person[i].allergy[j].
     orig_prsnl_name
     SET out_rec->person[i].allergies[j].orig_prsnl_id = cnvtstring(oreply->person[i].allergy[j].
      orig_prsnl_id)
     SET out_rec->person[i].allergies[j].reaction_status_dt_tm = datetimezoneformat(oreply->person[i]
      .allergy[j].reaction_status_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
     SET out_rec->person[i].allergies[j].beg_effective_dt_tm = datetimezoneformat(oreply->person[i].
      allergy[j].beg_effective_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
     SET out_rec->person[i].allergies[j].end_effective_dt_tm = datetimezoneformat(oreply->person[i].
      allergy[j].end_effective_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
     SET out_rec->person[i].allergies[j].updt_name = oreply->person[i].allergy[j].updt_name
     SET out_rec->person[i].allergies[j].updt_id = cnvtstring(oreply->person[i].allergy[j].updt_id)
     SET out_rec->person[i].allergies[j].updt_dt_tm = datetimezoneformat(oreply->person[i].allergy[j]
      .updt_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",curtimezonedef)
     SET out_rec->person[i].allergies[j].updt_cnt = cnvtstring(oreply->person[i].allergy[j].updt_cnt)
     SET stat = alterlist(out_rec->person[i].allergies[j].reaction,size(oreply->person[i].allergy[j].
       reaction,5))
     FOR (k = 1 TO size(oreply->person[i].allergy[j].reaction,5))
       SET out_rec->person[i].allergies[j].reaction[k].reaction_id = cnvtstring(oreply->person[i].
        allergy[j].reaction[k].reaction_id)
       SET out_rec->person[i].allergies[j].reaction[k].allergy_instance_id = cnvtstring(oreply->
        person[i].allergy[j].reaction[k].allergy_instance_id)
       SET out_rec->person[i].allergies[j].reaction[k].reaction_nom_id = cnvtstring(oreply->person[i]
        .allergy[j].reaction[k].reaction_nom_id)
       SET out_rec->person[i].allergies[j].reaction[k].source_string = oreply->person[i].allergy[j].
       reaction[k].source_string
       SET out_rec->person[i].allergies[j].reaction[k].reaction_ftdesc = oreply->person[i].allergy[j]
       .reaction[k].reaction_ftdesc
       SET out_rec->person[i].allergies[j].reaction[k].beg_effective_dt_tm = datetimezoneformat(
        oreply->person[i].allergy[j].reaction[k].beg_effective_dt_tm,curtimezonesys,
        "yyyy-MM-dd HH:mm:ss",curtimezonedef)
       IF ((oreply->person[i].allergy[j].reaction[k].active_ind=1))
        SET out_rec->person[i].allergies[j].reaction[k].active_ind = "True"
       ELSE
        SET out_rec->person[i].allergies[j].reaction[k].active_ind = "False"
       ENDIF
       SET out_rec->person[i].allergies[j].reaction[k].end_effective_dt_tm = datetimezoneformat(
        oreply->person[i].allergy[j].reaction[k].end_effective_dt_tm,curtimezonesys,
        "yyyy-MM-dd HH:mm:ss",curtimezonedef)
       SET out_rec->person[i].allergies[j].reaction[k].updt_id = cnvtstring(oreply->person[i].
        allergy[j].reaction[k].updt_id)
       SET out_rec->person[i].allergies[j].reaction[k].updt_dt_tm = datetimezoneformat(oreply->
        person[i].allergy[j].reaction[k].updt_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
        curtimezonedef)
       SET out_rec->person[i].allergies[j].reaction[k].updt_cnt = cnvtstring(oreply->person[i].
        allergy[j].reaction[k].updt_cnt)
     ENDFOR
     SET stat = alterlist(out_rec->person[i].allergies[j].comment,size(oreply->person[i].allergy[j].
       comment,5))
     FOR (l = 1 TO size(oreply->person[i].allergy[j].comment,5))
       SET out_rec->person[i].allergies[j].comment[l].allergy_comment_id = cnvtstring(oreply->person[
        i].allergy[j].comment[l].allergy_comment_id)
       SET out_rec->person[i].allergies[j].comment[l].comment_dt_tm = datetimezoneformat(oreply->
        person[i].allergy[j].comment[l].comment_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
        curtimezonedef)
       SET out_rec->person[i].allergies[j].comment[l].comment_prsnl_name = oreply->person[i].allergy[
       j].comment[l].comment_prsnl_name
       SET out_rec->person[i].allergies[j].comment[l].comment_prsnl_id = cnvtstring(oreply->person[i]
        .allergy[j].comment[l].comment_prsnl_id)
       SET out_rec->person[i].allergies[j].comment[l].comment = oreply->person[i].allergy[j].comment[
       l].allergy_comment
       SET out_rec->person[i].allergies[j].comment[l].beg_effective_dt_tm = datetimezoneformat(oreply
        ->person[i].allergy[j].comment[l].beg_effective_dt_tm,curtimezonesys,"yyyy-MM-dd HH:mm:ss",
        curtimezonedef)
     ENDFOR
   ENDFOR
 ENDFOR
#end_script
 IF (validate(_memory_reply_string))
  SET _memory_reply_string = cnvtrectojson(out_rec)
 ELSE
  CALL echojson(out_rec, $1)
 ENDIF
 FREE RECORD out_rec
END GO
