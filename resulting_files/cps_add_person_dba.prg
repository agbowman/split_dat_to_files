CREATE PROGRAM cps_add_person:dba
 SET false = 0
 SET true = 1
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET replace_error = 6
 SET delete_error = 7
 SET undelete_error = 8
 SET remove_error = 9
 SET attribute_error = 10
 SET lock_error = 11
 SET none_found = 12
 SET select_error = 13
 SET failed = false
 SET table_name = fillstring(50," ")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 person_qual = i2
    1 person[10]
      2 person_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->person_qual
 ENDIF
 SET reply->person_qual = request->person_qual
 SET reply->status_data.status = "F"
 SET table_name = "PERSON"
 CALL add_person(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE add_person(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET active_code = 0.0
     IF ((request->person[x].active_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=48
        AND c.cdf_meaning="ACTIVE"
       DETAIL
        active_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET data_status_code = 0
     IF ((request->person[x].data_status_cd=0))
      SELECT INTO "nl:"
       FROM code_value c
       WHERE c.code_set=8
        AND c.cdf_meaning="UNAUTH"
       DETAIL
        data_status_code = c.code_value
       WITH nocounter
      ;end select
     ENDIF
     SET new_nbr = 0
     SELECT INTO "nl:"
      y = seq(person_only_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       new_nbr = cnvtreal(y)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET failed = gen_nbr_error
      RETURN
     ELSE
      SET request->person[x].person_id = new_nbr
     ENDIF
     INSERT  FROM person p
      SET p.person_id = new_nbr, p.create_dt_tm = cnvtdatetime(curdate,curtime3), p.create_prsnl_id
        = reqinfo->updt_id,
       p.person_type_cd =
       IF ((request->person[x].person_type_cd <= 0)) 0
       ELSE request->person[x].person_type_cd
       ENDIF
       , p.name_last_key = cnvtupper(cnvtalphanum(request->person[x].name_last_key)), p
       .name_first_key = cnvtupper(cnvtalphanum(request->person[x].name_first_key)),
       p.name_full_formatted =
       IF ((request->person[x].name_full_formatted='""')) null
       ELSE request->person[x].name_full_formatted
       ENDIF
       , p.autopsy_cd = 0, p.birth_dt_cd =
       IF ((request->person[x].birth_dt_cd <= 0)) 0
       ELSE request->person[x].birth_dt_cd
       ENDIF
       ,
       p.birth_dt_tm =
       IF ((((request->person[x].birth_dt_tm <= 0)) OR ((request->person[x].birth_dt_tm=blank_date)
       )) ) null
       ELSE cnvtdatetime(request->person[x].birth_dt_tm)
       ENDIF
       , p.conception_dt_tm =
       IF ((((request->person[x].conception_dt_tm <= 0)) OR ((request->person[x].conception_dt_tm=
       blank_date))) ) null
       ELSE cnvtdatetime(request->person[x].conception_dt_tm)
       ENDIF
       , p.cause_of_death =
       IF ((request->person[x].cause_of_death='""')) null
       ELSE request->person[x].cause_of_death
       ENDIF
       ,
       p.deceased_cd =
       IF ((request->person[x].deceased_cd <= 0)) 0
       ELSE request->person[x].deceased_cd
       ENDIF
       , p.deceased_dt_tm =
       IF ((((request->person[x].deceased_dt_tm <= 0)) OR ((request->person[x].deceased_dt_tm=
       blank_date))) ) null
       ELSE cnvtdatetime(request->person[x].deceased_dt_tm)
       ENDIF
       , p.ethnic_grp_cd =
       IF ((request->person[x].ethnic_grp_cd <= 0)) 0
       ELSE request->person[x].ethnic_grp_cd
       ENDIF
       ,
       p.language_cd =
       IF ((request->person[x].language_cd <= 0)) 0
       ELSE request->person[x].language_cd
       ENDIF
       , p.marital_type_cd =
       IF ((request->person[x].marital_type_cd <= 0)) 0
       ELSE request->person[x].marital_type_cd
       ENDIF
       , p.purge_option_cd =
       IF ((request->person[x].purge_option_cd <= 0)) 0
       ELSE request->person[x].purge_option_cd
       ENDIF
       ,
       p.race_cd =
       IF ((request->person[x].race_cd <= 0)) 0
       ELSE request->person[x].race_cd
       ENDIF
       , p.religion_cd =
       IF ((request->person[x].religion_cd <= 0)) 0
       ELSE request->person[x].religion_cd
       ENDIF
       , p.sex_cd =
       IF ((request->person[x].sex_cd <= 0)) 0
       ELSE request->person[x].sex_cd
       ENDIF
       ,
       p.sex_age_change_ind =
       IF ((request->person[x].sex_age_change_ind_ind=false)) null
       ELSE request->person[x].sex_age_change_ind
       ENDIF
       , p.contributor_system_cd =
       IF ((request->person[x].contributor_system_cd <= 0)) 0
       ELSE request->person[x].contributor_system_cd
       ENDIF
       , p.language_dialect_cd =
       IF ((request->person[x].language_dialect_cd <= 0)) 0
       ELSE request->person[x].language_dialect_cd
       ENDIF
       ,
       p.name_last =
       IF ((request->person[x].name_last='""')) null
       ELSE request->person[x].name_last
       ENDIF
       , p.name_first =
       IF ((request->person[x].name_first='""')) null
       ELSE request->person[x].name_first
       ENDIF
       , p.name_phonetic =
       IF ((request->person[x].name_phonetic='""')) null
       ELSE request->person[x].name_phonetic
       ENDIF
       ,
       p.last_encntr_dt_tm =
       IF ((((request->person[x].last_encntr_dt_tm <= 0)) OR ((request->person[x].last_encntr_dt_tm=
       blank_date))) ) null
       ELSE cnvtdatetime(request->person[x].last_encntr_dt_tm)
       ENDIF
       , p.species_cd =
       IF ((request->person[x].species_cd <= 0)) 0
       ELSE request->person[x].species_cd
       ENDIF
       , p.confid_level_cd =
       IF ((request->person[x].confid_level_cd <= 0)) 0
       ELSE request->person[x].confid_level_cd
       ENDIF
       ,
       p.vip_cd =
       IF ((request->person[x].vip_cd <= 0)) 0
       ELSE request->person[x].vip_cd
       ENDIF
       , p.name_first_synonym_id = 0, p.citizenship_cd = 0,
       p.name_middle_key = cnvtupper(cnvtalphanum(request->person[x].name_middle_key)), p.name_middle
        =
       IF ((request->person[x].name_middle='""')) null
       ELSE request->person[x].name_middle
       ENDIF
       , p.data_status_dt_tm = cnvtdatetime(curdate,curtime3),
       p.data_status_prsnl_id = reqinfo->updt_id, p.beg_effective_dt_tm =
       IF ((request->person[x].beg_effective_dt_tm <= 0)) cnvtdatetime(curdate,curtime3)
       ELSE cnvtdatetime(request->person[x].beg_effective_dt_tm)
       ENDIF
       , p.end_effective_dt_tm =
       IF ((request->person[x].end_effective_dt_tm <= 0)) cnvtdatetime("31-DEC-2100 00:00:00.00")
       ELSE cnvtdatetime(request->person[x].end_effective_dt_tm)
       ENDIF
       ,
       p.active_ind =
       IF ((request->person[x].active_ind_ind=false)) true
       ELSE request->person[x].active_ind
       ENDIF
       , p.active_status_cd =
       IF ((request->person[x].active_status_cd=0)) active_code
       ELSE request->person[x].active_status_cd
       ENDIF
       , p.active_status_prsnl_id = reqinfo->updt_id,
       p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_cnt = 0, p.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       p.updt_id = reqinfo->updt_id, p.updt_applctx = reqinfo->updt_applctx, p.updt_task = reqinfo->
       updt_task
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET failed = insert_error
      RETURN
     ELSE
      SET reply->person[x].person_id = request->person[x].person_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
