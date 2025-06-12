CREATE PROGRAM afc_rpt_helds:dba
 PAINT
 SET modify = system
#1000_start
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 CALL video(r)
 CALL box(1,1,12,80)
 CALL box(1,1,4,80)
 CALL clear(2,2,78)
 CALL text(02,05,"Report Combines")
 CALL clear(3,2,78)
 CALL text(03,05,"To be Combined by Client")
 CALL video(n)
 CALL text(06,05,"Client")
 CALL text(09,05,"Continue? (Y/N)")
 CALL text(10,40,"[HELP Available; PF3 to exit help]")
 SET help =
 SELECT INTO "NL:"
  c.organization_id";l", c.org_name
  FROM organization c,
   org_type_reltn otr
  WHERE otr.organization_id=c.organization_id
   AND otr.org_type_cd=client_cd
  ORDER BY c.org_name
  WITH nocounter
 ;end select
 CALL accept(06,27,"9(11);DS")
 SET facility_cd = curaccept
 SET help = off
 CALL accept(09,27,"A;CU","Y"
  WHERE curaccept IN ("N", "Y"))
 IF (curaccept="N")
  CALL text(11,05,"Skipping Report")
  CALL clear(1,1)
  GO TO the_end
 ENDIF
 CALL clear(1,1)
 EXECUTE FROM main TO main_exit
 GO TO the_end
#1000_start_exit
#1000_initialize
 FREE SET l
 RECORD l(
   1 loc_qual = i2
   1 loc[*]
     2 nurs_desc = c80
     2 nurs_cd = f8
     2 room_desc = c80
     2 room_cd = f8
     2 bed_desc = c80
     2 bed_cd = f8
     2 seq = f8
     2 encntr_id = f8
     2 person_id = f8
     2 org_id = f8
     2 name = c80
     2 med_nbr = c40
     2 fin_nbr = c40
     2 age = c5
     2 sex = c10
     2 admit_date = c20
     2 physician = c80
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SET encntr_type_cd = 0
 SET facility_cd = 0.0
 SET nurseunit_cd = 0
 SET status_codeset = 48
 SET status_mean_active = "ACTIVE"
 SET person_alias_codeset = 4
 SET person_alias_mean_med_rec_num = "MRN"
 SET encounter_alias_codeset = 319
 SET encounter_alias_mean_fin_num = "FIN NBR"
 SET rm_type_cd = 0.0
 SET adm_doc_cd = 0.0
 SET g_code_value = 0.0
 SET count1 = 0
 SET g_status_code_active = 0.0
 SET g_person_alias_med_rec_num = 0.0
 SET g_encounter_alias_fin_num = 0.0
 SET i = 0
 CALL get_code_value(278,"CLIENT")
 SET client_cd = g_code_value
 CALL get_code_value(48,"COMBINED")
 SET combined_cd = g_code_value
#1099_initialize_exit
#main
 CALL get_code_value(status_codeset,status_mean_active)
 SET g_status_code_active = g_code_value
 IF (failed=false)
  CALL get_code_value(person_alias_codeset,person_alias_mean_med_rec_num)
  SET g_person_alias_med_rec_num = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_code_value(333,"ADMITDOC")
  SET adm_doc_cd = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_code_value(encounter_alias_codeset,encounter_alias_mean_fin_num)
  SET g_encounter_alias_fin_num = g_code_value
 ENDIF
 IF (failed=false)
  CALL get_code_value(222,"ROOM")
  SET rm_type_cd = g_code_value
 ENDIF
 CALL rpt_census("BOGUS")
#main_exit
 GO TO end_program
 SUBROUTINE get_code_value(l_code_set,l_cdf_meaning)
   SET g_code_value = 0.0
   SET table_name = "code_value"
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=l_code_set
     AND c.cdf_meaning=l_cdf_meaning
     AND c.active_ind=true
    DETAIL
     g_code_value = c.code_value
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = select_error
   ENDIF
 END ;Subroutine
 SUBROUTINE rpt_census(l_dummy)
   SET pagecount = 0
   SET count1 = 0
   SET facility_line = fillstring(50," ")
   SELECT INTO "nl:"
    c.org_name
    FROM organization c
    WHERE c.organization_id=facility_cd
     AND c.active_ind=true
    DETAIL
     facility_line = c.org_name
    WITH nocounter
   ;end select
   SET encounter_line = fillstring(50," ")
   SELECT INTO "nl:"
    cv.description, p.name_full_formatted, p.birth_dt_tm,
    e.organization_id, e.arrive_dt_tm, e.encntr_id,
    e.person_id, age = cnvtage(cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(
      format(p.birth_dt_tm,"hhmm;;m")))
    FROM person p,
     encounter e,
     code_value cv
    PLAN (e
     WHERE e.organization_id=facility_cd
      AND e.active_status_cd != combined_cd
      AND e.active_ind=true)
     JOIN (p
     WHERE p.person_id=e.person_id
      AND p.active_ind=true)
     JOIN (cv
     WHERE cv.code_value=p.sex_cd)
    DETAIL
     count1 += 1, stat = alterlist(l->loc,count1), l->loc[count1].org_id = e.organization_id
     IF (e.reg_dt_tm != null)
      l->loc[count1].admit_date = format(e.reg_dt_tm,"MM/DD/YY HH:MM;;d")
     ELSE
      l->loc[count1].admit_date = format(e.arrive_dt_tm,"MM/DD/YY HH:MM;;d")
     ENDIF
     l->loc[count1].encntr_id = e.encntr_id, l->loc[count1].person_id = e.person_id, l->loc[count1].
     name = p.name_full_formatted,
     l->loc[count1].sex = cv.display, l->loc[count1].age = age
    WITH nocounter
   ;end select
   SET l->loc_qual = count1
   SELECT INTO "nl:"
    pa.alias, ea.alias
    FROM (dummyt d1  WITH seq = value(l->loc_qual)),
     person_alias pa,
     encntr_alias ea,
     org_alias_pool_reltn oapr,
     org_alias_pool_reltn oap2
    PLAN (d1
     WHERE (l->loc[d1.seq].org_id > 0)
      AND (l->loc[d1.seq].org_id != null)
      AND (l->loc[d1.seq].encntr_id > 0)
      AND (l->loc[d1.seq].encntr_id != null)
      AND (l->loc[d1.seq].person_id > 0)
      AND (l->loc[d1.seq].person_id != null)
      AND (l->loc[d1.seq].name > ""))
     JOIN (oap2
     WHERE (oap2.organization_id=l->loc[d1.seq].org_id)
      AND oap2.alias_entity_alias_type_cd=g_encounter_alias_fin_num
      AND oap2.alias_entity_name="ENCNTR_ALIAS"
      AND oap2.active_ind=true)
     JOIN (ea
     WHERE (ea.encntr_id=l->loc[d1.seq].encntr_id)
      AND ea.alias_pool_cd=oap2.alias_pool_cd
      AND ea.encntr_alias_type_cd=g_encounter_alias_fin_num
      AND ea.active_ind=true)
     JOIN (oapr
     WHERE (oapr.organization_id=l->loc[d1.seq].org_id)
      AND oapr.alias_entity_alias_type_cd=g_person_alias_med_rec_num
      AND oapr.alias_entity_name="PERSON_ALIAS"
      AND oapr.active_ind=true)
     JOIN (pa
     WHERE (pa.person_id=l->loc[d1.seq].person_id)
      AND pa.alias_pool_cd=oapr.alias_pool_cd
      AND pa.person_alias_type_cd=g_person_alias_med_rec_num
      AND pa.active_ind=true)
    DETAIL
     l->loc[d1.seq].med_nbr = pa.alias, l->loc[d1.seq].fin_nbr = ea.alias
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    pc.to_person_id
    FROM (dummyt d1  WITH seq = value(l->loc_qual)),
     person_combine pc
    PLAN (d1
     WHERE (l->loc[d1.seq].org_id > 0))
     JOIN (pc
     WHERE (l->loc[d1.seq].person_id=pc.to_person_id))
    DETAIL
     l->loc[d1.seq].nurs_desc = "@"
    WITH nocounter
   ;end select
   SELECT INTO "MINE"
    pers_id = l->loc[d1.seq].person_id, name = substring(1,25,l->loc[d1.seq].name), pcmb = substring(
     1,1,l->loc[d1.seq].nurs_desc),
    mnbr = l->loc[d1.seq].med_nbr, fnbr = l->loc[d1.seq].fin_nbr, age = l->loc[d1.seq].age,
    sex = substring(1,4,l->loc[d1.seq].sex), adt = l->loc[d1.seq].admit_date
    FROM (dummyt d1  WITH seq = value(l->loc_qual))
    ORDER BY name
    HEAD REPORT
     team_name = "Person Management", report_name = "Combine Statuses by Client", line130 =
     fillstring(130,"-"),
     firsttime = true
    HEAD PAGE
     col 01, team_name, col 95,
     report_name, row + 1, col 01,
     facility_line, row + 1, col 01,
     encounter_line, row + 1, col 01,
     line130, row + 2, col 01,
     "PATIENT NAME", col 27, "PERSON ID",
     col 42, "FINANCIAL NBR", col 56,
     "MED REC NBR", col 71, "AGE",
     col 79, "SEX", col 90,
     "ADMIT DT/TM", row + 1, col 01,
     line130, row + 1
    DETAIL
     IF (((row+ 4) > 58))
      BREAK
     ELSE
      row + 1
     ENDIF
     IF (name > " ")
      col 00, pcmb, col 02,
      name, col 27, pers_id"#############",
      col 42, fnbr"#############", col 56,
      mnbr"#############", col 71, age,
      col 79, sex, col 90,
      adt
     ENDIF
    FOOT PAGE
     row 58, col 01, line130,
     row + 1, col 01, "Printed: ",
     col 10, curdate"DDMMMYY;;D", col 18,
     curtime"HH:MM;;M", col 25, "By: ",
     col 29, curuser"######", col 114,
     "Page: ", col 120, curpage"###",
     pagecount = curpage
    WITH nocounter
   ;end select
 END ;Subroutine
#end_program
#the_end
 FREE SET l
END GO
