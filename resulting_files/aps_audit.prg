CREATE PROGRAM aps_audit
 PAINT
 CALL clear(1,1)
 CALL text(5,12,"CERNER Corporation",wide)
 CALL text(8,33,"HNA Millennium")
 CALL text(10,36,"PathNet")
 CALL video(l)
 CALL text(12,31,"Anatomic Pathology")
 CALL video(n)
 CALL pause(1)
 CALL clear(1,1)
 CALL video(n)
 CALL video(s)
 CALL video(l)
 CALL text(2,62,curuser)
 CALL text(3,62,".")
 CALL video(n)
#start_over
 CALL refreshscreen("      M a i n   S c r e e n        ")
 CALL displaymessage(format(curdate,"mmm-dd-yy;;d"),curuser)
 CALL video(u)
 CALL video(l)
 CALL text(6,3," DATABASE                              ACTIVITY                             ")
 CALL video(n)
 CALL text(8,5,"1   Audits                            A   Non-Patient specific            ")
 CALL text(9,5,"                                      B   Patient specific                ")
 CALL text(10,5,"                                                                          ")
 CALL text(11,5,"                                                                          ")
 CALL text(12,5,"                                                                          ")
 CALL text(13,5,"                                                                          ")
 CALL text(14,5,"                                                                          ")
 CALL text(15,5,"                                                                          ")
 CALL text(16,5,"                                                                          ")
 CALL text(17,5,"                                                                          ")
 CALL text(18,5,"                                                                          ")
 CALL video(u)
 CALL video(l)
 CALL text(19,3,"                                                                            ")
 CALL video(n)
 CALL text(20,5,"                                                                          ")
 CALL text(21,5,"U   Utilities                         X   Exit program                    ")
 CALL video(n)
 CALL video(r)
 CALL box(5,2,22,79)
 CALL line(5,40,18,xvert)
 CALL video(n)
 CALL video(l)
 CALL clear(24,1,79)
 CALL text(24,5," ... type your choice and press enter!")
 SET accept = video(iu)
 CALL accept(24,3,"PP;CU","/ "
  WHERE curaccept IN ("1", "A", "B", "U", "X",
  "/"))
 CALL refreshscreen("      M a i n   S c r e e n        ")
 CASE (curaccept)
  OF "1":
   CALL text(24,5,"... Loading reference audit menu")
   EXECUTE apaudit
   GO TO start_over
  OF "A":
   CALL text(24,5,"... Loading Non-Patient activity audit menu")
   GO TO npat_activity_audit
   GO TO start_over
  OF "B":
   CALL text(24,5,"... Loading Patient activity audit menu")
   GO TO pat_activity_audit
   GO TO start_over
  OF "U":
   CALL text(24,5,"... Loading Utilities menu")
   GO TO utilities
   GO TO start_over
  OF "X":
   CALL text(24,5,"... Exiting")
   GO TO end_program
  ELSE
   GO TO start_over
 ENDCASE
#pat_activity_audit
 SET accept_accession_nbr = "                  "
 SET accept_case_id = 0.0
 SET answer = "  "
 SET code_value = 0.0
 SET code_set = 319
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_type_cd = code_value
#accessretry
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 SET accept_case_id = 0.0
 SET accept_rpt_nbr = 0
 SET help =
 SELECT INTO "NL:"
  accession = pc.accession_nbr"##################;l", name = decode(p.seq,p.name_full_formatted,
   "Not Found")"####################", case_id = pc.case_id,
  ext_acc_nbr = pc.ext_accession_nbr
  FROM pathology_case pc,
   dummyt d,
   person p
  PLAN (pc
   WHERE pc.case_id > 0
    AND pc.accession_nbr >= curaccept)
   JOIN (d)
   JOIN (p
   WHERE pc.person_id=p.person_id)
  ORDER BY accession
  WITH nocounter, outerjoin = d
 ;end select
 SET help = promptmsg("enter starting accession_nbr: ")
 SET accept_accession_nbr = "00000SO19980002362"
 SET accept = video(iu)
 CALL text(6,20,"Enter a valid accession")
 CALL video(l)
 CALL text(17,45,"Press <HELP> to search.")
 CALL text(19,45,"Enter all zeros to use a case_id.")
 CALL video(n)
 CALL accept(6,45,"PPPPPPPPPPPPPPPPPP;CUP",accept_accession_nbr)
 SET accept_accession_nbr = value(curaccept)
 SET help = off
 IF (accept_accession_nbr="000000000000000000")
  GO TO acceptcaseid
 ENDIF
 IF (textlen(trim(curaccept))=0)
  GO TO end_program
 ENDIF
 GO TO validate
#acceptcaseid
 SET accept_case_id = 0.0
 SET accept = video(iu)
 CALL clear(17,45,35)
 CALL clear(19,45,35)
 CALL clear(6,20,60)
 CALL text(6,20,"Enter a valid case_id")
 CALL accept(6,45,"9999999999999999999","0")
 SET accept_case_id = curaccept
 IF (accept_case_id=0)
  GO TO accessretry
 ENDIF
 IF (textlen(trim(cnvtstring(accept_case_id)))=0)
  GO TO accessretry
 ENDIF
 GO TO validate
#validate
 CALL text(24,5,"Validating Accession ...                                               ")
 FREE SET pc
 RECORD pc(
   1 case_id = f8
   1 accession_nbr = c21
   1 accessioned_dt_tm = dq8
   1 accession_prsnl_id = f8
   1 person_id = f8
   1 encntr_id = f8
   1 group_id = f8
   1 prefix_id = f8
   1 case_year = i4
   1 case_number = i4
   1 responsible_resident_id = f8
   1 responsible_pathologist_id = f8
   1 requesting_physician_id = f8
   1 main_report_cmplete_dt_tm = dq8
   1 case_received_dt_tm = dq8
   1 case_collect_dt_tm = dq8
   1 origin_flag = i4
   1 reserved_ind = i2
   1 chr_ind = i2
   1 case_type_cd = f8
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 updt_task = i4
   1 updt_cnt = i4
   1 updt_applctx = i4
 )
 SELECT INTO "nl:"
  pc.case_id, pc.case_id, pc.person_id,
  pc.accessioned_dt_tm, pc.case_year, pc.case_number,
  pc.case_type_cd, pc.requesting_physician_id, pc.encntr_id,
  pc.accession_prsnl_id, pc.accession_nbr, pc.prefix_id,
  pc.group_id, pc.case_collect_dt_tm, pc.origin_flag,
  pc.reserved_ind, pc.main_report_cmplete_dt_tm, pc.updt_dt_tm,
  pc.updt_id, pc.updt_task, pc.updt_applctx,
  pc.updt_cnt
  FROM pathology_case pc
  PLAN (pc
   WHERE parser(
    IF (accept_accession_nbr != "000000000000000000") "pc.accession_nbr = accept_accession_nbr"
    ELSE "0 = 0"
    ENDIF
    )
    AND parser(
    IF (accept_case_id != 0) "accept_case_id = pc.case_id"
    ELSE "0 = 0"
    ENDIF
    )
    AND pc.case_id != 0)
  DETAIL
   pc->case_id = pc.case_id, pc->person_id = pc.person_id, pc->accessioned_dt_tm = pc
   .accessioned_dt_tm,
   pc->case_year = pc.case_year, pc->case_number = pc.case_number, pc->case_type_cd = pc.case_type_cd,
   pc->requesting_physician_id = pc.requesting_physician_id, pc->encntr_id = pc.encntr_id, pc->
   accession_prsnl_id = pc.accession_prsnl_id,
   pc->accession_nbr = pc.accession_nbr, pc->prefix_id = pc.prefix_id, pc->group_id = pc.group_id,
   pc->case_collect_dt_tm = pc.case_collect_dt_tm, pc->origin_flag = pc.origin_flag, pc->reserved_ind
    = pc.reserved_ind,
   pc->main_report_cmplete_dt_tm = pc.main_report_cmplete_dt_tm, pc->updt_dt_tm = pc.updt_dt_tm, pc->
   updt_id = pc.updt_id,
   pc->updt_task = pc.updt_task, pc->updt_applctx = pc.updt_applctx, pc->updt_cnt = pc.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL text(24,5,"INVALID, try again ...                                       ")
  CALL pause(5)
  GO TO accessretry
 ENDIF
 CALL text(24,5,"  Loading            ...                                               ")
 FREE SET p
 RECORD p(
   1 name_full_formatted = vc
   1 birth_dt_tm = dq8
   1 age = c30
   1 sex_cd = f8
   1 sex_disp = c40
   1 alias = vc
 )
 SELECT INTO "NL:"
  p.name_full_formatted, psex_disp = uar_get_code_display(p.sex_cd)
  FROM person p
  PLAN (p
   WHERE (pc->person_id=p.person_id))
  DETAIL
   p->name_full_formatted = p.name_full_formatted, p->birth_dt_tm = p.birth_dt_tm, p->age = cnvtage(
    cnvtdate2(format(p.birth_dt_tm,"mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(p.birth_dt_tm,
      "hhmm;;m"))),
   p->sex_cd = p.sex_cd, p->sex_disp = psex_disp
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL refreshscreen("   P a t i e n t     A u d i t     ")
  CALL text(2,3,"Current Case:")
  CALL video(b)
  CALL text(3,3,accept_accession_nbr)
  CALL video(n)
  CALL text(24,2,"Most likely there is bad info for the PERSON_ID")
  CALL pause(5)
 ENDIF
 SELECT INTO "NL:"
  ea.alias
  FROM person p,
   encntr_alias ea
  PLAN (p
   WHERE (pc->person_id=p.person_id))
   JOIN (ea
   WHERE (ea.encntr_id=pc->encntr_id)
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   p->alias = ea.alias
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET p->alias = "Unknown"
 ENDIF
 GO TO demographics
#redraw
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
#getanswer
 CALL clear(24,1,79)
 CALL text(24,6," ... type your choice and press enter!                   (/ for menu)")
 CALL accept(24,3,"PP;CU","  "
  WHERE curaccept IN ("1", "2", "3", "4", "5",
  "6", "7", "8", "9", "A",
  "B", "C", "N", "XX", "/",
  "/2", "X", "@"))
 SET answer = curaccept
 CALL displaymessage("",answer)
 CASE (answer)
  OF "/":
   GO TO helpmenu
  OF "/2":
   GO TO 2helpmenu
  OF "1":
   GO TO pathcase
  OF "2":
   GO TO person
  OF "3":
   GO TO casereport
  OF "4":
   GO TO apdcevent
  OF "5":
   GO TO apqainfo
  OF "6":
   GO TO caseprovider
  OF "7":
   GO TO cytoscreenevent
  OF "8":
   GO TO ftevent
  OF "9":
   GO TO processingtask
  OF "A":
   GO TO demographics
  OF "B":
   GO TO reporttext
  OF "C":
   GO TO casespecimen
  OF "N":
   GO TO accessretry
  OF "@":
   GO TO cartmansays
  OF "X":
   GO TO start_over
  ELSE
   GO TO helpmenu
 ENDCASE
 GO TO redraw
#helpmenu
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL video(u)
 CALL video(l)
 CALL text(6,3," UNFORMATTED                           FORMATTED                            ")
 CALL video(n)
 CALL text(8,5,"1   Pathology_Case                    A   Demographics                    ")
 CALL text(9,5,"2   Person                            B   Report text                     ")
 CALL text(10,5,"3   Case_Report                       C   Case specimen                   ")
 CALL text(11,5,"4   ap_dc_event                                                           ")
 CALL text(12,5,"5   ap_qa_info                                                            ")
 CALL text(13,5,"6   case_provider                                                         ")
 CALL text(14,5,"7   cyto_screening_event                                                  ")
 CALL text(15,5,"8   ap_ft_event                                                           ")
 CALL text(16,5,"9   processing_task                                                       ")
 CALL text(17,5,"                                                                          ")
 CALL text(18,5,"                                                                          ")
 CALL video(u)
 CALL video(l)
 CALL text(19,3,"                                                                            ")
 CALL video(n)
 CALL text(20,5,"                                      N   enter New accession             ")
 CALL text(21,5,"/2  Help screen # 2                   X   eXit program                    ")
 CALL video(n)
 CALL video(r)
 CALL line(5,40,18,xvert)
 CALL box(5,2,22,79)
 CALL video(n)
 CALL video(l)
 SET answer = "/"
 GO TO getanswer
#2helpmenu
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL video(u)
 CALL video(l)
 CALL text(6,3," UNFORMATTED                           FORMATTED                            ")
 CALL video(n)
 CALL text(8,5,"                                                                          ")
 CALL text(9,5,"                                                                          ")
 CALL text(10,5,"                                                                          ")
 CALL text(11,5,"                                                                          ")
 CALL text(12,5,"                                                                          ")
 CALL text(13,5,"                                                                          ")
 CALL text(14,5,"                                                                          ")
 CALL text(15,5,"                                                                          ")
 CALL text(16,5,"                                                                          ")
 CALL text(17,5,"                                                                          ")
 CALL text(18,5,"                                                                          ")
 CALL video(u)
 CALL video(l)
 CALL text(19,3,"                                                                            ")
 CALL video(n)
 CALL text(20,5,"                                      N  enter New accession              ")
 CALL text(21,5,"/  Help screen 1                      X  eXit program                     ")
 CALL video(n)
 CALL video(r)
 CALL line(5,40,18,xvert)
 CALL box(5,2,22,79)
 CALL video(n)
 CALL video(l)
 SET answer = "/"
 GO TO getanswer
#demographics
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Alias")
 CALL text(6,35,p->alias)
 CALL text(7,3,"Name")
 CALL text(7,35,p->name_full_formatted)
 CALL text(8,3,"Birthday")
 CALL text(8,35,cnvtstring(p->birth_dt_tm,19,0))
 CALL text(9,35,format(cnvtdatetime(p->birth_dt_tm),"mm/dd/yy;;d"))
 CALL text(10,3,"age")
 CALL text(10,35,p->age)
 CALL text(11,3,"sex")
 CALL text(11,35,cnvtstring(p->sex_cd))
 CALL text(12,35,p->sex_disp)
 SET answer = "/"
 GO TO getanswer
#pathcase
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Selecting pathology case...")
 SELECT INTO mine
  pc.*
  FROM pathology_case pc
  PLAN (pc
   WHERE (pc->case_id=pc.case_id))
  HEAD REPORT
   line = fillstring(125,"="), col 10, "PATHOLOGY CASE TABLE for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2
  DETAIL
   col 0, line, row + 1,
   col 5, "CASE_ID", col 40,
   pc.case_id, row + 1, col 5,
   "ACCESSION_NBR", col 40, pc.accession_nbr,
   row + 1, col 5, "ACCESSIONED_DT_TM",
   col 40, pc.accessioned_dt_tm, row + 1,
   col 5, "ACCESSION_PRSNL_ID", col 40,
   pc.accession_prsnl_id, row + 1, col 5,
   "PERSON_ID", col 40, pc.person_id,
   row + 1, col 5, "ENCNTR_ID",
   col 40, pc.encntr_id, row + 1,
   col 5, "GROUP_ID", col 40,
   pc.group_id, row + 1, col 5,
   "PREFIX_ID", col 40, pc.prefix_id,
   row + 1, col 5, "CASE_YEAR",
   col 40, pc.case_year, row + 1,
   col 5, "CASE_NUMBER", col 40,
   pc.case_number, row + 1, col 5,
   "RESPONSIBLE_RESIDENT_ID", col 40, pc.responsible_resident_id,
   row + 1, col 5, "RESPONSIBLE_PATHOLOGIST_ID",
   col 40, pc.responsible_pathologist_id, row + 1,
   col 5, "REQUESTING_PHYSICIAN_ID", col 40,
   pc.requesting_physician_id, row + 1, col 5,
   "MAIN_REPORT_CMPLETE_DT_TM", col 40, pc.main_report_cmplete_dt_tm,
   row + 1, col 5, "CASE_RECEIVED_DT_TM",
   col 40, pc.case_received_dt_tm, row + 1,
   col 5, "CASE_COLLECT_DT_TM", col 40,
   pc.case_collect_dt_tm, row + 1, col 5,
   "LOC_FACILITY_CD", col 40, pc.loc_facility_cd,
   row + 1, col 5, "LOC_BUILDING_CD",
   col 40, pc.loc_building_cd, row + 1,
   col 5, "LOC_NURSE_UNIT_CD", col 40,
   pc.loc_nurse_unit_cd, row + 1, col 5,
   "COMMENTS", col 40, pc.comments
   "##########################################################################################",
   row + 1, col 5, "CANCEL_CD",
   col 40, pc.cancel_cd, row + 1,
   col 5, "CANCEL_DT_TM", col 40,
   pc.cancel_dt_tm, row + 1, col 5,
   "CANCEL_ID", col 40, pc.cancel_id,
   row + 1, col 5, "ORIGIN_FLAG",
   col 40, pc.origin_flag, row + 1,
   col 5, "RESERVED_IND", col 40,
   pc.reserved_ind, row + 1, col 5,
   "CHR_IND", col 40, pc.chr_ind,
   row + 1, col 5, "CASE_TYPE_CD",
   col 40, pc.case_type_cd, row + 1,
   col 5, "AUTOPSY_SCOPE_CD", col 40,
   pc.autopsy_scope_cd, row + 1, col 5,
   "AUTOPSY_DESCRIPTION", col 40, pc.autopsy_description
   "###########################################################################################",
   row + 1, col 5, "UPDT_DT_TM",
   col 40, pc.updt_dt_tm, row + 1,
   col 5, "UPDT_ID", col 40,
   pc.updt_id, row + 1, col 5,
   "UPDT_TASK", col 40, pc.updt_task,
   row + 1, col 5, "UPDT_CNT",
   col 40, pc.updt_cnt, row + 1,
   col 5, "UPDT_APPLCTX", col 40,
   pc.updt_applctx, row + 2
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL video(r)
  CALL text(6,3,"Selecting pathology case...FAILED")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#person
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Selecting person ...")
 SELECT INTO mine
  p.*
  FROM person p
  PLAN (p
   WHERE (pc->person_id=p.person_id))
  HEAD REPORT
   line = fillstring(125,"="), col 10, "PERSON TABLE for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2
  DETAIL
   col 0, line, row + 1,
   col 5, "PERSON_ID", col 40,
   p.person_id, row + 1, col 5,
   "UPDT_CNT", col 40, p.updt_cnt,
   row + 1, col 5, "UPDT_DT_TM",
   col 40, p.updt_dt_tm, row + 1,
   col 5, "UPDT_ID", col 40,
   p.updt_id, row + 1, col 5,
   "UPDT_TASK", col 40, p.updt_task,
   row + 1, col 5, "UPDT_APPLCTX",
   col 40, p.updt_applctx, row + 1,
   col 5, "ACTIVE_IND", col 40,
   p.active_ind, row + 1, col 5,
   "ACTIVE_STATUS_CD", col 40, p.active_status_cd,
   row + 1, col 5, "ACTIVE_STATUS_PRSNL_ID",
   col 40, p.active_status_prsnl_id, row + 1,
   col 5, "ACTIVE_STATUS_DT_TM", col 40,
   p.active_status_dt_tm, row + 1, col 5,
   "CREATE_DT_TM", col 40, p.create_dt_tm,
   row + 1, col 5, "CREATE_PRSNL_ID",
   col 40, p.create_prsnl_id, row + 1,
   col 5, "BEG_EFFECTIVE_DT_TM", col 40,
   p.beg_effective_dt_tm, row + 1, col 5,
   "END_EFFECTIVE_DT_TM", col 40, p.end_effective_dt_tm,
   row + 1, col 5, "PERSON_TYPE_CD",
   col 40, p.person_type_cd, row + 1,
   col 5, "NAME_LAST_KEY", col 40,
   p.name_last_key, row + 1, col 5,
   "NAME_FIRST_KEY", col 40, p.name_first_key,
   row + 1, col 5, "NAME_FULL_FORMATTED",
   col 40, p.name_full_formatted, row + 1,
   col 5, "AUTOPSY_CD", col 40,
   p.autopsy_cd, row + 1, col 5,
   "BIRTH_DT_CD", col 40, p.birth_dt_cd,
   row + 1, col 5, "BIRTH_DT_TM",
   col 40, p.birth_dt_tm, row + 1,
   col 5, "CONCEPTION_DT_TM", col 40,
   p.conception_dt_tm, row + 1, col 5,
   "CAUSE_OF_DEATH", col 40, p.cause_of_death,
   row + 1, col 5, "DECEASED_CD",
   col 40, p.deceased_cd, row + 1,
   col 5, "DECEASED_DT_TM", col 40,
   p.deceased_dt_tm, row + 1, col 5,
   "ETHNIC_GRP_CD", col 40, p.ethnic_grp_cd,
   row + 1, col 5, "LANGUAGE_CD",
   col 40, p.language_cd, row + 1,
   col 5, "MARITAL_TYPE_CD", col 40,
   p.marital_type_cd, row + 1, col 5,
   "PURGE_OPTION_CD", col 40, p.purge_option_cd,
   row + 1, col 5, "RACE_CD",
   col 40, p.race_cd, row + 1,
   col 5, "RELIGION_CD", col 40,
   p.religion_cd, row + 1, col 5,
   "SEX_CD", col 40, p.sex_cd,
   row + 1, col 5, "SEX_AGE_CHANGE_IND",
   col 40, p.sex_age_change_ind, row + 1,
   col 5, "DATA_STATUS_CD", col 40,
   p.data_status_cd, row + 1, col 5,
   "DATA_STATUS_DT_TM", col 40, p.data_status_dt_tm,
   row + 1, col 5, "DATA_STATUS_PRSNL_ID",
   col 40, p.data_status_prsnl_id, row + 1,
   col 5, "CONTRIBUTOR_SYSTEM_CD", col 40,
   p.contributor_system_cd, row + 1, col 5,
   "LANGUAGE_DIALECT_CD", col 40, p.language_dialect_cd,
   row + 1, col 5, "NAME_LAST",
   col 40, p.name_last, row + 1,
   col 5, "NAME_FIRST", col 40,
   p.name_first, row + 1, col 5,
   "NAME_PHONETIC", col 40, p.name_phonetic,
   row + 1, col 5, "LAST_ENCNTR_DT_TM",
   col 40, p.last_encntr_dt_tm, row + 1,
   col 5, "SPECIES_CD", col 40,
   p.species_cd, row + 1, col 5,
   "CONFID_LEVEL_CD", col 40, p.confid_level_cd,
   row + 1, col 5, "VIP_CD",
   col 40, p.vip_cd, row + 1,
   col 5, "NAME_FIRST_SYNONYM_ID", col 40,
   p.name_first_synonym_id, row + 1, col 5,
   "CITIZENSHIP_CD", col 40, p.citizenship_cd,
   row + 1, col 5, "VET_MILITARY_STATUS_CD",
   col 40, p.vet_military_status_cd, row + 1,
   col 5, "MOTHER_MAIDEN_NAME", col 40,
   p.mother_maiden_name, row + 1, col 5,
   "NATIONALITY_CD", col 40, p.nationality_cd,
   row + 1, col 5, "FT_ENTITY_NAME",
   col 40, p.ft_entity_name, row + 1,
   col 5, "FT_ENTITY_ID", col 40,
   p.ft_entity_id, row + 1, col 5,
   "NAME_MIDDLE_KEY", col 40, p.name_middle_key,
   row + 1, col 5, "NAME_MIDDLE",
   col 40, p.name_middle, row + 1,
   col 5, "NAME_LAST_PHONETIC", col 40,
   p.name_last_phonetic, row + 1, col 5,
   "NAME_FIRST_PHONETIC", col 40, p.name_first_phonetic
  WITH nocounter, maxcol = 500
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(6,3,"Selecting person ... FAILURE")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#casereport
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(24,2,"Selecting case report   ...                                             ")
 SELECT INTO mine
  cr.*
  FROM case_report cr
  PLAN (cr
   WHERE (pc->case_id=cr.case_id))
  HEAD REPORT
   line = fillstring(125,"="), col 10, "CASE REPORT TABLE for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2
  DETAIL
   col 0, line, row + 1,
   col 5, "report_id", col 40,
   cr.report_id, row + 1, col 5,
   "case_id  ", col 40, cr.case_id,
   row + 1, col 5, "event_id",
   col 40, cr.event_id, row + 1,
   col 5, "catalog_cd", col 40,
   cr.catalog_cd, row + 1, col 5,
   "report_sequence", col 40, cr.report_sequence,
   row + 1, col 5, "request_dt_tm",
   col 40, cr.request_dt_tm, row + 1,
   col 5, "request_prsnl_id", col 40,
   cr.request_prsnl_id, row + 1, col 5,
   "status_cd", col 40, cr.status_cd,
   row + 1, col 5, "status_prsnl_id",
   col 40, cr.status_prsnl_id, row + 1,
   col 5, "status_dt_tm", col 40,
   cr.status_dt_tm, row + 1, col 5,
   "cancel_cd", col 40, cr.cancel_cd,
   row + 1, col 5, "cancel_prsnl_id",
   col 40, cr.cancel_prsnl_id, row + 1,
   col 5, "cancel_dt_tm", col 40,
   cr.cancel_dt_tm, row + 1, col 5,
   "updt_applctx", col 40, cr.updt_applctx,
   row + 1, col 5, "updt_id",
   col 40, cr.updt_id, row + 1,
   col 5, "updt_cnt", col 40,
   cr.updt_cnt, row + 1, col 5,
   "updt_task", col 40, cr.updt_task,
   row + 1, col 5, "updt_dt_tm",
   col 40, cr.updt_dt_tm, row + 2
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(24,2,"Selecting case report   ... SOMETHING BAD HAS HAPPENED")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#apdcevent
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Selecting ap_dc_event ...")
 SELECT INTO mine
  ade.*
  FROM ap_dc_event ade
  PLAN (ade
   WHERE (pc->case_id=ade.case_id))
  HEAD REPORT
   line = fillstring(125,"="), col 10, "AP_DC_EVENT for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2,
   col 0, line, row + 1
  DETAIL
   col 5, "+++++++++++++++++++++++++++++++++++++++++", row + 1,
   col 10, "event_id", col 50,
   ade.event_id, row + 1, col 10,
   "study_id", col 50, ade.study_id,
   row + 1, col 10, "case_id",
   col 50, ade.case_id, row + 1,
   col 10, "correlate_case_id", col 50,
   ade.correlate_case_id, row + 1, col 10,
   "init_eval_term_id", col 50, ade.init_eval_term_id,
   row + 1, col 10, "init_discrep_term_id",
   col 50, ade.init_discrep_term_id, row + 1,
   col 10, "disagree_reason_cd", col 50,
   ade.disagree_reason_cd, row + 1, col 10,
   "investigation_cd", col 50, ade.investigation_cd,
   row + 1, col 10, "resolution_cd",
   col 50, ade.resolution_cd, row + 1,
   col 10, "final_eval_term_id", col 50,
   ade.final_eval_term_id, row + 1, col 10,
   "final_discrep_term_id", col 50, ade.final_discrep_term_id,
   row + 1, col 10, "long_text_id",
   col 50, ade.long_text_id, row + 1,
   col 10, "prsnl_group_id", col 50,
   ade.prsnl_group_id, row + 1, col 10,
   "initiated_prsnl_id", col 50, ade.initiated_prsnl_id,
   row + 1, col 10, "initiated_dt_tm",
   col 50, ade.initiated_dt_tm, row + 1,
   col 10, "cancel_prsnl_id", col 50,
   ade.cancel_prsnl_id, row + 1, col 10,
   "cancel_dt_tm", col 50, ade.cancel_dt_tm,
   row + 1, col 10, "complete_prsnl_id",
   col 50, ade.complete_prsnl_id, row + 1,
   col 10, "updt_cnt", col 50,
   ade.updt_cnt, row + 1, col 10,
   "updt_dt_tm", col 50, ade.updt_dt_tm,
   row + 1, col 10, "updt_id",
   col 50, ade.updt_id, row + 1,
   col 10, "updt_task", col 50,
   ade.updt_task, row + 1, col 10,
   "updt_applctx", col 50, ade.updt_applctx
  WITH nocounter, maxcol = 500
 ;end select
 IF (curqual=0)
  CALL video(r)
  CALL text(6,3,"Selecting ap_dc_event ... FAILURE")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#apqainfo
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Selecting ap_qa_info ... ")
 SELECT INTO mine
  aqi.*
  FROM ap_qa_info aqi
  PLAN (aqi
   WHERE (pc->case_id=aqi.case_id))
  HEAD REPORT
   line = fillstring(125,"="), col 10, "AP_QA_INFO TABLE for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2,
   col 0, line, row + 1
  DETAIL
   col 5, "+++++++++++++++++++++++++++++++++++++++++", row + 1,
   col 10, "qa_flag_id", col 50,
   aqi.qa_flag_id, row + 1, col 10,
   "case_id", col 50, aqi.case_id,
   row + 1, col 10, "flag_type_cd",
   col 50, aqi.flag_type_cd, row + 1,
   col 10, "activated_id", col 50,
   aqi.activated_id, row + 1, col 10,
   "activated_dt_tm", col 50, aqi.activated_dt_tm,
   row + 1, col 10, "person_id",
   col 50, aqi.person_id, row + 1,
   col 10, "complete_id", col 50,
   aqi.complete_id, row + 1, col 10,
   "complete_dt_tm", col 50, aqi.complete_dt_tm,
   row + 1, col 10, "suspend_id",
   col 50, aqi.suspend_id, row + 1,
   col 10, "suspend_dt_tm", col 50,
   aqi.suspend_dt_tm, row + 1, col 10,
   "cancel_cd", col 50, aqi.cancel_cd,
   row + 1, col 10, "updt_dt_tm",
   col 50, aqi.updt_dt_tm, row + 1,
   col 10, "active_ind", col 50,
   aqi.active_ind, row + 1, col 10,
   "updt_id", col 50, aqi.updt_id,
   row + 1, col 10, "updt_task",
   col 50, aqi.updt_task, row + 1,
   col 10, "updt_cnt", col 50,
   aqi.updt_cnt, row + 1, col 10,
   "updt_applctx", col 50, aqi.updt_applctx
  WITH nocounter, maxcol = 500
 ;end select
 IF (curqual=0)
  CALL video(r)
  CALL text(6,3,"Selecting ap_qa_info ... FAILED")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#caseprovider
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Selecting case_provider ... ")
 SELECT INTO mine
  cp.*
  FROM case_provider cp
  PLAN (cp
   WHERE (pc->case_id=cp.case_id))
  HEAD REPORT
   line = fillstring(125,"="), col 10, "CASE_PROVIDER TABLE for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2,
   col 0, line, row + 1
  DETAIL
   col 5, "+++++++++++++++++++++++++++++++++++++++++", row + 1,
   col 10, "case_id", col 50,
   cp.case_id, row + 1, col 10,
   "physician_id", col 50, cp.physician_id,
   row + 1, col 10, "updt_dt_tm",
   col 50, cp.updt_dt_tm, row + 1,
   col 10, "updt_id", col 50,
   cp.updt_id, row + 1, col 10,
   "updt_task", col 50, cp.updt_task,
   row + 1, col 10, "updt_cnt",
   col 50, cp.updt_cnt, row + 1,
   col 10, "updt_applctx", col 50,
   cp.updt_applctx
  WITH nocounter, maxcol = 500
 ;end select
 IF (curqual=0)
  CALL video(r)
  CALL text(6,3,"Selecting case_provider ... FAILED")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#cytoscreenevent
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Selecting cyto_screening_event ... ")
 SELECT INTO mine
  cse.*
  FROM cyto_screening_event cse
  PLAN (cse
   WHERE (pc->case_id=cse.case_id))
  HEAD REPORT
   line = fillstring(125,"="), col 10, "CYTO_SCREENONG_EVENT TABLE for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2,
   col 0, line, row + 1
  DETAIL
   col 5, "+++++++++++++++++++++++++++++++++++++++++", row + 1,
   col 10, "case_id", col 50,
   cse.case_id, row + 1, col 10,
   "sequence", col 50, cse.sequence,
   row + 1, col 10, "screener_id",
   col 50, cse.screener_id, row + 1,
   col 10, "screen_dt_tm", col 50,
   cse.screen_dt_tm, row + 1, col 10,
   "initial_screener_ind", col 50, cse.initial_screener_ind,
   row + 1, col 10, "reference_range_factor_id",
   col 50, cse.reference_range_factor_id, row + 1,
   col 10, "endocerv_ind", col 50,
   cse.endocerv_ind, row + 1, col 10,
   "adequacy_flag", col 50, cse.adequacy_flag,
   row + 1, col 10, "standard_rpt_id",
   col 50, cse.standard_rpt_id, row + 1,
   col 10, "event_id", col 50,
   cse.event_id, row + 1, col 10,
   "valid_from_dt_tm", col 50, cse.valid_from_dt_tm,
   row + 1, col 10, "nomenclature_id",
   col 50, cse.nomenclature_id, row + 1,
   col 10, "verify_ind", col 50,
   cse.verify_ind, row + 1, col 10,
   "review_reason_flag", col 50, cse.review_reason_flag,
   row + 1, col 10, "active_ind",
   col 50, cse.active_ind, row + 1,
   col 10, "diagnostic_category_cd", col 50,
   cse.diagnostic_category_cd, row + 1, col 10,
   "action_flag", col 50, cse.action_flag,
   row + 1, col 10, "split_ind",
   col 50, cse.split_ind, row + 1,
   col 10, "specimen_grouping_cd", col 50,
   cse.specimen_grouping_cd, row + 1, col 10,
   "updt_cnt", col 50, cse.updt_cnt,
   row + 1, col 10, "updt_dt_tm",
   col 50, cse.updt_dt_tm, row + 1,
   col 10, "updt_id", col 50,
   cse.updt_id, row + 1, col 10,
   "updt_task", col 50, cse.updt_task,
   row + 1, col 10, "updt_applctx",
   col 50, cse.updt_applctx
  WITH nocounter, maxcol = 500
 ;end select
 IF (curqual=0)
  CALL video(r)
  CALL text(6,3,"Selecting cyto_screening_event ... FAILED")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#ftevent
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Selecting ft_event ...")
 SELECT INTO mine
  afe.*, lt.long_text, lt.long_text_id
  FROM ap_ft_event afe,
   long_text lt,
   (dummyt d1  WITH seq = 1)
  PLAN (afe
   WHERE (pc->case_id=afe.case_id))
   JOIN (d1)
   JOIN (lt
   WHERE lt.long_text_id=afe.term_long_text_id
    AND lt.parent_entity_name="AP_FT_EVENT")
  HEAD REPORT
   line = fillstring(125,"="), col 10, "ap_ft_event TABLE for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2,
   col 0, line, row + 1
  DETAIL
   col 5, "+++++++++++++++++++++++++++++++++++++++++", row + 1,
   col 10, "followup_event_id", col 50,
   afe.followup_event_id, row + 1, col 10,
   "case_id", col 50, afe.case_id,
   row + 1, col 10, "followup_type_cd",
   col 50, afe.followup_type_cd, row + 1,
   col 10, "person_id", col 50,
   afe.person_id, row + 1, col 10,
   "origin_flag", col 50, afe.origin_flag,
   row + 1, col 10, "origin_dt_tm",
   col 50, afe.origin_dt_tm, row + 1,
   col 10, "origin_prsnl_id", col 50,
   afe.origin_prsnl_id, row + 1, col 10,
   "expected_term_dt", col 50, afe.expected_term_dt,
   row + 1, col 10, "initial_notif_dt_tm",
   col 50, afe.initial_notif_dt_tm, row + 1,
   col 10, "initial_notif_print_flag", col 50,
   afe.initial_notif_print_flag, row + 1, col 10,
   "first_overdue_dt_tm", col 50, afe.first_overdue_dt_tm,
   row + 1, col 10, "first_overdue_print_flag",
   col 50, afe.first_overdue_print_flag, row + 1,
   col 10, "final_overdue_dt_tm", col 50,
   afe.final_overdue_dt_tm, row + 1, col 10,
   "final_overdue_print_flag", col 50, afe.final_overdue_print_flag,
   row + 1, col 10, "term_id",
   col 50, afe.term_id, row + 1,
   col 10, "term_dt_tm", col 50,
   afe.term_dt_tm, row + 1, col 10,
   "term_reason_cd", col 50, afe.term_reason_cd,
   row + 1, col 10, "term_accession_nbr",
   col 50, afe.term_accession_nbr, row + 1,
   col 10, "term_comment (truncated)", col 50,
   lt.long_text"###############################################################################", row
    + 1, col 10,
   "term_long_text_id", col 50, afe.term_long_text_id,
   row + 1, col 10, "updt_dt_tm",
   col 50, afe.updt_dt_tm, row + 1,
   col 10, "updt_id", col 50,
   afe.updt_id, row + 1, col 10,
   "updt_task", col 50, afe.updt_task,
   row + 1, col 10, "updt_cnt",
   col 50, afe.updt_cnt, row + 1,
   col 10, "updt_applctx", col 50,
   afe.updt_applctx
  WITH nocounter, outerjoin = d1, maxcol = 500
 ;end select
 IF (curqual=0)
  CALL video(r)
  CALL text(6,3,"Selecting ft_event ... FAILED")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#processingtask
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Selecting processing_task ... ")
 SELECT INTO mine
  pt.*
  FROM processing_task pt,
   (dummyt d1  WITH seq = 1),
   long_text lt
  PLAN (pt
   WHERE (pc->case_id=pt.case_id))
   JOIN (d1)
   JOIN (lt
   WHERE pt.comments_long_text_id=lt.long_text_id
    AND lt.long_text_id > 0)
  HEAD REPORT
   line = fillstring(125,"="), col 10, "PROCESSING_TASK TABLE for",
   col + 1, pc->accession_nbr, col + 1,
   " as of ", col + 2, curdate,
   col + 3, curtime, row + 2,
   col 0, line, row + 1
  DETAIL
   col 5, "+++++++++++++++++++++++++++++++++++++++++", row + 1,
   col 10, "processing_task_id", col 50,
   pt.processing_task_id, row + 1, col 10,
   "order_id", col 50, pt.order_id,
   row + 1, col 10, "task_assay_cd",
   col 50, pt.task_assay_cd, row + 1,
   col 10, "case_id", col 50,
   pt.case_id, row + 1, col 10,
   "case_specimen_id", col 50, pt.case_specimen_id,
   row + 1, col 10, "case_specimen_tag_id",
   col 50, pt.case_specimen_tag_id, row + 1,
   col 10, "cassette_id", col 50,
   pt.cassette_id, row + 1, col 10,
   "cassette_tag_id", col 50, pt.cassette_tag_id,
   row + 1, col 10, "slide_id",
   col 50, pt.slide_id, row + 1,
   col 10, "slide_tag_id", col 50,
   pt.slide_tag_id, row + 1, col 10,
   "create_inventory_flag", col 50, pt.create_inventory_flag,
   row + 1, col 10, "service_resource_cd",
   col 50, pt.service_resource_cd, row + 1,
   col 10, "priority_cd", col 50,
   pt.priority_cd, row + 1, col 10,
   "comments", col 50, lt.long_text
   "#####################################################################",
   row + 1, col 10, "request_dt_tm",
   col 50, pt.request_dt_tm, row + 1,
   col 10, "request_prsnl_id", col 50,
   pt.request_prsnl_id, row + 1, col 10,
   "worklist_nbr", col 50, pt.worklist_nbr,
   row + 1, col 10, "label_printed_ind",
   col 50, pt.label_printed_ind, row + 1,
   col 10, "quantity", col 50,
   pt.quantity, row + 1, col 10,
   "hold_cd", col 50, pt.hold_cd,
   row + 1, col 10, "hold_prsnl_id",
   col 50, pt.hold_prsnl_id, row + 1,
   col 10, "hold_dt_tm", col 50,
   pt.hold_dt_tm, row + 1, col 10,
   "hold_comment", col 50, pt.hold_comment,
   row + 1, col 10, "status_cd",
   col 50, pt.status_cd, row + 1,
   col 10, "status_prsnl_id", col 50,
   pt.status_prsnl_id, row + 1, col 10,
   "status_dt_tm", col 50, pt.status_dt_tm,
   row + 1, col 10, "cancel_cd",
   col 50, pt.cancel_cd, row + 1,
   col 10, "cancel_prsnl_id", col 50,
   pt.cancel_prsnl_id, row + 1, col 10,
   "cancel_dt_tm", col 50, pt.cancel_dt_tm,
   row + 1, col 10, "queue_id",
   col 50, pt.queue_id, row + 1,
   col 10, "updt_dt_tm", col 50,
   pt.updt_dt_tm, row + 1, col 10,
   "updt_id", col 50, pt.updt_id,
   row + 1, col 10, "updt_task",
   col 50, pt.updt_task, row + 1,
   col 10, "updt_cnt", col 50,
   pt.updt_cnt, row + 1, col 10,
   "updt_applctx", col 50, pt.updt_applctx
  WITH nocounter, maxcol = 500, outerjoin = d1
 ;end select
 IF (curqual=0)
  CALL video(r)
  CALL text(6,3,"Selecting processing_task ... FAILED")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#reporttext
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 DECLARE blob_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",25,"BLOB"))
 DECLARE blobout = gvc WITH protect, noconstant("")
 CALL text(6,3,"Selecting code value 120...")
 SET compressed_cd = 0.0
 SET uncompressed_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=120
  DETAIL
   IF (cv.cdf_meaning="NOCOMP")
    uncompressed_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="OCFCOMP")
    compressed_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(6,3,"Selecting code value 120 ... FAILURE")
  CALL video(n)
  CALL pause(5)
 ENDIF
 CALL text(7,3,"Selecting code value 1305 ...")
 SET cancel_cd = 0.0
 SET verified_cd = 0.0
 SET corrected_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=1305
   AND cv.cdf_meaning IN ("CANCEL", "VERIFIED", "CORRECTED")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "CANCEL":
     cancel_cd = cv.code_value
    OF "VERIFIED":
     verified_cd = cv.code_value
    OF "CORRECTED":
     corrected_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (verified_cd=0)
  CALL video(b)
  CALL text(7,3,"Selecting code value 1305 ... FAILURE")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET placeholder_cd = uar_get_code_by("MEANING",53,"PLACEHOLDER")
 SET num_of_rpts = 0
 FREE SET temp
 RECORD temp(
   1 report_qual[*]
     2 report_id = f8
     2 report_disp = vc
 )
 CALL text(8,3,"Counting reports ...")
 SELECT INTO "nl:"
  cr.report_id
  FROM case_report cr,
   pathology_case pc,
   order_catalog oc
  PLAN (pc
   WHERE pc.accession_nbr=accept_accession_nbr)
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (oc
   WHERE cr.catalog_cd=oc.catalog_cd)
  DETAIL
   num_of_rpts += 1, stat = alterlist(temp->report_qual,num_of_rpts), temp->report_qual[num_of_rpts].
   report_disp = oc.primary_mnemonic,
   temp->report_qual[num_of_rpts].report_id = cr.report_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(8,3,"Counting reports ... FAILURE")
  CALL video(n)
  CALL pause(5)
 ENDIF
 CALL text(10,5,"             ")
 IF (num_of_rpts > 1)
  CALL text(10,5,"Choose a report number: ")
  FOR (x = 1 TO num_of_rpts)
    CALL text((10+ x),7,cnvtstring(x))
    CALL text((10+ x),8,"->")
    CALL text((10+ x),12,temp->report_qual[x].report_disp)
  ENDFOR
  CALL accept(10,30,"P;CU",accept_rpt_nbr)
  SET accept_rpt_nbr = cnvtint(curaccept)
  IF (accept_rpt_nbr=0)
   GO TO end_reporttext
  ENDIF
  CALL text(9,3,"Loading report ... ")
 ELSEIF (num_of_rpts=1)
  SET accept_rpt_nbr = 1
  CALL text(9,3,"Loading report ... ")
 ELSEIF (num_of_rpts=0)
  SET accept_rpt_nbr = 0
  CALL video(b)
  CALL text(9,3,"Loading report ... NONE FOUND")
  CALL video(n)
  CALL pause(5)
  GO TO end_reporttext
 ENDIF
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SELECT
  ce.event_id, pc_case_collect_dt_tm = pc.case_collect_dt_tm"mm/dd/yy;;d", pc.accession_nbr,
  cv.description, join_path = decode(ceb.seq,"A-TEXT",cecr.seq,"B-ALPHA",cen.seq,
   "C-SIGNLINE",cecr2.seq,"D-SNOMED"," "), nomenclature_id = decode(cecr2.seq,cecr2.nomenclature_id,
   0.0),
  n2.source_string, lb.long_blob_id, lb.parent_entity_name,
  lb.parent_entity_id, pc_case_collect_dt_tm = pc.case_collect_dt_tm"mm/dd/yy;;d", pc.accession_nbr,
  ce.event_id, cv.description"###########################################################", ceb
  .event_id,
  cen.event_id, pc.person_id, ce.task_assay_cd,
  cecr2_group_nbr = decode(cecr2.seq,cecr2.group_nbr,0), cecr2.nomenclature_id, n2.source_string,
  alpha = decode(ceb3.seq,"F","T")
  FROM case_report cr,
   pathology_case pc,
   clinical_event ce,
   code_value cv,
   (dummyt d1  WITH seq = 1),
   ce_blob_result ceb,
   ce_event_note cen,
   (dummyt d4  WITH seq = 1),
   ce_coded_result cecr,
   nomenclature n,
   (dummyt d5  WITH seq = 1),
   ce_blob_result ceb3,
   (dummyt d2  WITH seq = 1),
   long_blob lb,
   (dummyt d3  WITH seq = 1),
   ce_coded_result cecr2,
   ce_blob_result ceb2,
   nomenclature n2
  PLAN (pc
   WHERE pc.accession_nbr=accept_accession_nbr
    AND pc.cancel_cd IN (null, 0))
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND (cr.report_id=temp->report_qual[accept_rpt_nbr].report_id)
    AND cr.status_cd != cancel_cd)
   JOIN (ce
   WHERE cr.event_id=ce.parent_event_id
    AND ce.event_class_cd != placeholder_cd
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (cv
   WHERE ce.task_assay_cd=cv.code_value)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (ceb
   WHERE ce.event_id=ceb.event_id
    AND ceb.storage_cd=blob_cd
    AND ceb.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   ) ORJOIN ((((d2
   WHERE 1=d2.seq)
   JOIN (cen
   WHERE ce.event_id=cen.event_id
    AND cen.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (lb
   WHERE lb.parent_entity_name="CE_EVENT_NOTE"
    AND lb.parent_entity_id=cen.ce_event_note_id)
   ) ORJOIN ((((d3
   WHERE 1=d3.seq)
   JOIN (cecr2
   WHERE ce.event_id=cecr2.event_id
    AND cecr2.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (ceb2
   WHERE cecr2.event_id=ceb2.event_id
    AND ceb2.storage_cd=blob_cd
    AND ceb2.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (n2
   WHERE cecr2.nomenclature_id=n2.nomenclature_id)
   ) ORJOIN ((d4
   WHERE 1=d4.seq)
   JOIN (cecr
   WHERE ce.event_id=cecr.event_id
    AND cecr.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   JOIN (n
   WHERE cecr.nomenclature_id=n.nomenclature_id)
   JOIN (d5
   WHERE 1=d5.seq)
   JOIN (ceb3
   WHERE cecr.event_id=ceb3.event_id
    AND ceb3.storage_cd=blob_cd
    AND ceb3.valid_until_dt_tm > cnvtdatetime(curdate,curtime))
   )) )) ))
  ORDER BY ce.event_id, join_path, cecr2_group_nbr
  HEAD REPORT
   col 0, "Accession: ", pc.accession_nbr,
   row + 1
  DETAIL
   CASE (join_path)
    OF "A-TEXT":
     row + 1,col 0,
     "======================================================================================================================",
     row + 1,col 5,cv.description,
     recdate->datetime = cnvtdatetimeutc(ceb.valid_from_dt_tm),blobsize = uar_get_ceblobsize(ceb
      .event_id,recdate),blobout = "",
     IF (blobsize > 0)
      stat = memrealloc(blobout,1,build("C",blobsize)), status = uar_get_ceblob(ceb.event_id,recdate,
       blobout,blobsize)
     ENDIF
     ,
     CALL rtf_to_text(blobout,1,112)
     FOR (z = 1 TO size(tmptext->qual,5))
       row + 1, col 7, "*",
       col 10, tmptext->qual[z].text
     ENDFOR
    OF "B-ALPHA":
     IF (alpha="T")
      row + 1, col 0,
      "======================================================================================================================",
      row + 1, col 5, cv.description,
      row + 1, col 6, "->",
      col + 1, n.source_string
     ENDIF
    OF "C-SIGNLINE":
     tblobin = lb.long_blob,
     IF (cen.compression_cd=compressed_cd)
      CALL decompress_text(tblobin)
     ELSE
      tblobout = substring(1,(textlen(trim(tblobin)) - textlen("ocf_blob")),tblobin)
     ENDIF
     ,
     CALL rtf_to_text(tblobout,1,112)row + 1,col 15,
     "----- signature line ----------------------------------------------------------------------------------",
     FOR (z = 1 TO size(tmptext->qual,5))
       row + 1, col 20, tmptext->qual[z].text
     ENDFOR
    OF "D-SNOMED":
     row + 1,col 15,"+++++ diagnostic code group #",
     col + 1,cecr2_group_nbr"###",col + 1,
     "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",row + 1,col 20,
     "      source id -> ",col + 1,n2.source_identifier"##########",
     row + 1,col 20,"  source string -> ",
     col + 1,n2.source_string,row + 1,
     col 20,"nomenclature id -> ",col + 1,
     cecr2.nomenclature_id,row + 1,col 20,
     "       event id -> ",col + 1,cecr2.event_id,
     row + 1,col 20,"       sequence -> ",
     col + 1,cecr2.seq"###"
    ELSE
     row + 1,col 15,"????? unknown "
   ENDCASE
  WITH nocounter, maxcol = 500, outerjoin = d5,
   memsort
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(9,3,"Loading report ... NONE FOUND")
  CALL video(n)
  CALL pause(5)
 ENDIF
#end_reporttext
 SET answer = "/"
 GO TO helpmenu
#casespecimen
 CALL refreshscreen("   P a t i e n t     A u d i t     ")
 CALL displaycase(1)
 CALL text(6,3,"Loading {specimen \ cassette \ slide} ...              ")
 SELECT INTO mine
  cs.specimen_description, cs_apt.tag_disp, cs_apt.tag_sequence,
  c_apt_tag_disp = decode(c_apt.seq,c_apt.tag_disp,">?<"), c_apt_tag_sequence = decode(c_apt.seq,
   c_apt.tag_sequence,0), s_apt_tag_disp = decode(s_apt.seq,s_apt.tag_disp,">?<"),
  s_apt_tag_sequence = decode(s_apt.seq,s_apt.tag_sequence,0), one_long_text = decode(lt.seq,
   substring(1,60,lt.long_text),"")
  FROM case_specimen cs,
   ap_tag cs_apt,
   dummyt d1,
   cassette c,
   ap_tag c_apt,
   dummyt d2,
   slide s,
   ap_tag s_apt,
   dummyt d3,
   long_text lt
  PLAN (cs
   WHERE (pc->case_id=cs.case_id)
    AND cs.case_specimen_id > 0)
   JOIN (d3)
   JOIN (lt
   WHERE lt.long_text_id=cs.spec_comments_long_text_id
    AND cs.spec_comments_long_text_id > 0)
   JOIN (cs_apt
   WHERE cs.specimen_tag_id=cs_apt.tag_id)
   JOIN (d1)
   JOIN (c
   WHERE cs.case_specimen_id=c.case_specimen_id)
   JOIN (c_apt
   WHERE c.cassette_tag_id=c_apt.tag_id)
   JOIN (d2)
   JOIN (s
   WHERE c.cassette_id=s.cassette_id)
   JOIN (s_apt
   WHERE s.tag_id=s_apt.tag_id)
  ORDER BY cs_apt.tag_sequence, c_apt_tag_sequence, s_apt_tag_sequence
  HEAD REPORT
   col 0, col 0, "Accession: ",
   accept_accession_nbr, col + 1, "Specimen \ cassette \ slide ",
   row + 1
  HEAD cs_apt.tag_sequence
   row + 1, col 0,
   "==== specimen     =======================================================================================",
   col 14, cs_apt.tag_sequence"###", row + 1,
   col 10, cs.specimen_description, row + 1,
   col 10, "case_specimen_id", col 30,
   cs.case_specimen_id, row + 1, col 10,
   "case_id", col 30, cs.case_id,
   row + 1, col 10, "specimen_tag_id",
   col 30, cs.specimen_tag_id, row + 1,
   col 10, "fixative_added_cd", col 30,
   cs.fixative_added_cd, row + 1, col 10,
   "storage_locn_cd", col 30, cs.storage_locn_cd,
   row + 1, col 10, "on_loan_locn_cd",
   col 30, cs.on_loan_locn_cd, row + 1,
   col 10, "discard_dt_tm", col 30,
   cs.discard_dt_tm, row + 1, col 10,
   "frozen_report_id", col 30, cs.frozen_report_id,
   row + 1, col 10, "collect_dt_tm",
   col 30, cs.collect_dt_tm, row + 1,
   col 10, "cancel_cd", col 30,
   cs.cancel_cd, row + 1, col 10,
   "specimen_cd", col 30, cs.specimen_cd,
   row + 1, col 10, "nomenclature_id",
   col 30, cs.nomenclature_id, row + 1,
   col 10, "specimen_description", col 30,
   cs.specimen_description, row + 1, col 10,
   "special_comments", col 30, one_long_text,
   row + 1, col 10, "adequacy_ind",
   col 30, cs.adequacy_ind, row + 1,
   col 10, "inadequacy_reason_cd", col 30,
   cs.inadequacy_reason_cd, row + 1, col 10,
   "received_dt_tm", col 30, cs.received_dt_tm,
   row + 1, col 10, "received_id",
   col 30, cs.received_id, row + 1,
   col 10, "received_fixative_cd", col 30,
   cs.received_fixative_cd, row + 1, col 10,
   "updt_cnt", col 30, cs.updt_cnt,
   row + 1, col 10, "updt_dt_tm",
   col 30, cs.updt_dt_tm, row + 1,
   col 10, "updt_id", col 30,
   cs.updt_id, row + 1, col 10,
   "updt_task", col 30, cs.updt_task,
   row + 1, col 10, "updt_applctx",
   col 30, cs.updt_applctx
  HEAD c_apt_tag_sequence
   row + 1, col 5,
   "++++ cassette     ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++",
   col 19, c_apt_tag_sequence"###"
   IF (c_apt_tag_sequence > 0)
    row + 1, col 15, "cassette_id",
    col 35, c.cassette_id, row + 1,
    col 15, "case_specimen_id", col 35,
    c.case_specimen_id, row + 1, col 15,
    "owner_id", col 35, c.owner_id,
    row + 1, col 15, "cassette_tag_id",
    col 35, c.cassette_tag_id, row + 1,
    col 15, "supplemental_tag", col 35,
    c.supplemental_tag, row + 1, col 15,
    "task_assay_cd", col 35, c.task_assay_cd,
    row + 1, col 15, "on_loan_locn_cd",
    col 35, c.on_loan_locn_cd, row + 1,
    col 15, "fixative_cd", col 35,
    c.fixative_cd, row + 1, col 15,
    "origin_modifier", col 35, c.origin_modifier,
    row + 1, col 15, "pieces",
    col 35, c.pieces, row + 1,
    col 15, "sectionable_ind", col 35,
    c.sectionable_ind, row + 1, col 15,
    "discard_dt_tm", col 35, c.discard_dt_tm,
    row + 1, col 15, "storage_location_cd",
    col 35, c.storage_location_cd, row + 1,
    col 15, "frozen_ind", col 35,
    c.frozen_ind, row + 1, col 15,
    "embedding_media_cd", col 35, c.embedding_media_cd,
    row + 1, col 15, "updt_cnt",
    col 35, c.updt_cnt, row + 1,
    col 15, "updt_dt_tm", col 35,
    c.updt_dt_tm, row + 1, col 15,
    "updt_id", col 35, c.updt_id,
    row + 1, col 15, "updt_task",
    col 35, c.updt_task, row + 1,
    col 15, "updt_applctx", col 35,
    c.updt_applctx
   ELSE
    row + 1, col 15, "Item not found"
   ENDIF
  HEAD s_apt_tag_sequence
   row + 1, col 10,
   "---- slide     --------------------------------------------------------------------------------",
   col 21, s_apt_tag_sequence"###"
   IF (s_apt_tag_sequence > 0)
    col + 1, row + 1, col 20,
    "SLIDE_ID", col 40, s.slide_id,
    row + 1, col 20, "SEQUENCE_NBR",
    col 40, s.sequence_nbr, row + 1,
    col 20, "CASE_SPECIMEN_ID", col 40,
    s.case_specimen_id, row + 1, col 20,
    "CASSETTE_ID", col 40, s.cassette_id,
    row + 1, col 20, "TASK_ASSAY_CD",
    col 40, s.task_assay_cd, row + 1,
    col 20, "STAIN_TASK_ASSAY_CD", col 40,
    s.stain_task_assay_cd, row + 1, col 20,
    "TAG_ID", col 40, s.tag_id,
    row + 1, col 20, "SUPPLEMENTAL_TAG",
    col 40, s.supplemental_tag, row + 1,
    col 20, "ORIGIN_MODIFIER", col 40,
    s.origin_modifier, row + 1, col 20,
    "SPECIAL_STAIN_IND", col 40, s.special_stain_ind,
    row + 1, col 20, "OWNER_ID",
    col 40, s.owner_id, row + 1,
    col 20, "STORAGE_LOCATION_CD", col 40,
    s.storage_location_cd, row + 1, col 20,
    "DISCARD_DT_TM", col 40, s.discard_dt_tm,
    row + 1, col 20, "ON_LOAN_LOCN_CD",
    col 40, s.on_loan_locn_cd, row + 1,
    col 20, "UPDT_CNT", col 40,
    s.updt_cnt, row + 1, col 20,
    "UPDT_DT_TM", col 40, s.updt_dt_tm,
    row + 1, col 20, "UPDT_ID",
    col 40, s.updt_id, row + 1,
    col 20, "UPDT_TASK", col 40,
    s.updt_task, row + 1, col 20,
    "UPDT_APPLCTX", col 40, s.updt_applctx
   ELSE
    row + 1, col 15, "Item not found"
   ENDIF
  WITH nocounter, maxcol = 500, outerjoin = d1,
   outerjoin = d2, outerjoin = d3
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(6,3,"Loading {specimen \ cassette \ slide} ... FAILURE")
  CALL video(n)
  CALL pause(5)
 ENDIF
 CALL text(6,3,"Loading {specimen \ slide} ...                                   ")
 SELECT INTO mine
  cs.specimen_description, cs_apt.tag_disp, cs_apt.tag_sequence,
  s_apt_tag_disp = decode(s_apt.seq,s_apt.tag_disp,">?<"), s_apt_tag_sequence = decode(s_apt.seq,
   s_apt.tag_sequence,0), two_long_text = decode(lt.seq,substring(1,60,lt.long_text),"")
  FROM case_specimen cs,
   ap_tag cs_apt,
   dummyt d,
   slide s,
   ap_tag s_apt,
   dummyt d1,
   long_text lt
  PLAN (cs
   WHERE (pc->case_id=cs.case_id)
    AND cs.case_specimen_id > 0)
   JOIN (d1)
   JOIN (lt
   WHERE lt.long_text_id=cs.spec_comments_long_text_id
    AND cs.spec_comments_long_text_id > 0)
   JOIN (cs_apt
   WHERE cs.specimen_tag_id=cs_apt.tag_id)
   JOIN (d)
   JOIN (s
   WHERE cs.case_specimen_id=s.case_specimen_id)
   JOIN (s_apt
   WHERE s.tag_id=s_apt.tag_id)
  ORDER BY cs_apt.tag_sequence, s_apt.tag_sequence
  HEAD REPORT
   col 0, col 0, "Accession: ",
   accept_accession_nbr, col + 1, "Specimen \ slide ",
   row + 1
  HEAD cs_apt.tag_sequence
   row + 1, col 0,
   "==== specimen     =======================================================================================",
   col 14, cs_apt.tag_sequence"###", row + 1,
   col 10, cs.specimen_description, row + 1,
   col 10, "case_specimen_id", col 30,
   cs.case_specimen_id, row + 1, col 10,
   "case_id", col 30, cs.case_id,
   row + 1, col 10, "specimen_tag_id",
   col 30, cs.specimen_tag_id, row + 1,
   col 10, "fixative_added_cd", col 30,
   cs.fixative_added_cd, row + 1, col 10,
   "storage_locn_cd", col 30, cs.storage_locn_cd,
   row + 1, col 10, "on_loan_locn_cd",
   col 30, cs.on_loan_locn_cd, row + 1,
   col 10, "discard_dt_tm", col 30,
   cs.discard_dt_tm, row + 1, col 10,
   "frozen_report_id", col 30, cs.frozen_report_id,
   row + 1, col 10, "collect_dt_tm",
   col 30, cs.collect_dt_tm, row + 1,
   col 10, "cancel_cd", col 30,
   cs.cancel_cd, row + 1, col 10,
   "specimen_cd", col 30, cs.specimen_cd,
   row + 1, col 10, "nomenclature_id",
   col 30, cs.nomenclature_id, row + 1,
   col 10, "specimen_description", col 30,
   cs.specimen_description, row + 1, col 10,
   "special_comments", col 30, two_long_text,
   row + 1, col 10, "adequacy_ind",
   col 30, cs.adequacy_ind, row + 1,
   col 10, "inadequacy_reason_cd", col 30,
   cs.inadequacy_reason_cd, row + 1, col 10,
   "received_dt_tm", col 30, cs.received_dt_tm,
   row + 1, col 10, "received_id",
   col 30, cs.received_id, row + 1,
   col 10, "received_fixative_cd", col 30,
   cs.received_fixative_cd, row + 1, col 10,
   "updt_cnt", col 30, cs.updt_cnt,
   row + 1, col 10, "updt_dt_tm",
   col 30, cs.updt_dt_tm, row + 1,
   col 10, "updt_id", col 30,
   cs.updt_id, row + 1, col 10,
   "updt_task", col 30, cs.updt_task,
   row + 1, col 10, "updt_applctx",
   col 30, cs.updt_applctx
  HEAD s_apt_tag_sequence
   row + 1, col 10,
   "---- slide     --------------------------------------------------------------------------------",
   col 21, s_apt_tag_sequence"###", col + 1
   IF (s_apt_tag_sequence > 0)
    row + 1, col 20, "SLIDE_ID",
    col 40, s.slide_id, row + 1,
    col 20, "SEQUENCE_NBR", col 40,
    s.sequence_nbr, row + 1, col 20,
    "CASE_SPECIMEN_ID", col 40, s.case_specimen_id,
    row + 1, col 20, "CASSETTE_ID",
    col 40, s.cassette_id, row + 1,
    col 20, "TASK_ASSAY_CD", col 40,
    s.task_assay_cd, row + 1, col 20,
    "STAIN_TASK_ASSAY_CD", col 40, s.stain_task_assay_cd,
    row + 1, col 20, "TAG_ID",
    col 40, s.tag_id, row + 1,
    col 20, "SUPPLEMENTAL_TAG", col 40,
    s.supplemental_tag, row + 1, col 20,
    "ORIGIN_MODIFIER", col 40, s.origin_modifier,
    row + 1, col 20, "SPECIAL_STAIN_IND",
    col 40, s.special_stain_ind, row + 1,
    col 20, "OWNER_ID", col 40,
    s.owner_id, row + 1, col 20,
    "STORAGE_LOCATION_CD", col 40, s.storage_location_cd,
    row + 1, col 20, "DISCARD_DT_TM",
    col 40, s.discard_dt_tm, row + 1,
    col 20, "ON_LOAN_LOCN_CD", col 40,
    s.on_loan_locn_cd, row + 1, col 20,
    "UPDT_CNT", col 40, s.updt_cnt,
    row + 1, col 20, "UPDT_DT_TM",
    col 40, s.updt_dt_tm, row + 1,
    col 20, "UPDT_ID", col 40,
    s.updt_id, row + 1, col 20,
    "UPDT_TASK", col 40, s.updt_task,
    row + 1, col 20, "UPDT_APPLCTX",
    col 40, s.updt_applctx
   ELSE
    row + 1, col 15, "Item not found"
   ENDIF
  DETAIL
   col 0
  WITH nocounter, maxcol = 500, outerjoin = d
 ;end select
 IF (curqual=0)
  CALL video(b)
  CALL text(7,3,"Loading {specimen \ slide} ... FAILURE")
  CALL video(n)
  CALL pause(5)
 ENDIF
 SET answer = "/"
 GO TO helpmenu
#cartmansays
 CALL refreshscreen(" ")
 CALL text(8,3,"                                  _,          Cerner's Anatomic Pathology  ")
 CALL text(9,3,"                              _.-{__}-._    /                              ")
 CALL video(b)
 CALL text(9,57," Kicks ass ! ")
 CALL video(n)
 CALL text(10,3,"                            .:-'`____`'-:.                                ")
 CALL text(11,3,"                           /_.-'`_  _`'-._\                               ")
 CALL text(12,3,"                          /`   / .\/. \   `\                              ")
 CALL text(13,3,"                          |    \__/\__/    |                              ")
 CALL text(14,3,"                        .-\                /-.                            ")
 CALL text(15,3,"                       /   '._-.__--__.-_.'   \                           ")
 CALL text(16,3,"                       \'.    `''''''''`   .'`\                           ")
 CALL text(17,3,"                       |_)|        '       |  |                           ")
 CALL text(18,3,"                       ; `_________'________`;-'                          ")
 CALL text(19,3,"                       '`--------------------`                            ")
 CALL text(20,3,"                             C A R T M A N                                ")
 SET answer = "/"
 GO TO getanswer
#npat_activity_audit
#npsaa
 CALL refreshscreen("    A c t i v i t y  A u d i t     ")
 CALL video(u)
 CALL video(l)
 CALL text(6,3," UNFORMATTED                           FORMATTED                            ")
 CALL video(n)
 CALL text(8,5,"1   AP_OPS_EXCEPTION        {table    A  Locked reports                   ")
 CALL text(9,5,"2   REPORT_QUEUE_R          {table                                        ")
 CALL text(10,5,"                                                                          ")
 CALL text(11,5,"                                                                          ")
 CALL text(12,5,"                                                                          ")
 CALL text(13,5,"                                                                          ")
 CALL text(14,5,"                                                                          ")
 CALL text(15,5,"                                                                          ")
 CALL text(16,5,"                                                                          ")
 CALL text(17,5,"                                                                          ")
 CALL text(18,5,"                                                                          ")
 CALL video(u)
 CALL video(l)
 CALL text(19,3,"                                                                            ")
 CALL video(n)
 CALL text(20,5,"                                                                          ")
 CALL text(21,5,"                                      X   Exit                            ")
 CALL video(n)
 CALL video(r)
 CALL line(5,40,18,xvert)
 CALL box(5,2,22,79)
 CALL video(n)
 CALL video(l)
 SET npsaa_answer = "/"
 CALL clear(24,1,79)
 CALL text(24,6," ... type your choice and press enter!                   (/ for menu)")
 CALL accept(24,3,"PP;CU","  "
  WHERE curaccept IN ("1", "2", "3", "4", "5",
  "A", "/", "X"))
 SET npsaa_answer = curaccept
 CASE (npsaa_answer)
  OF "/":
   GO TO npsaa
  OF "1":
   GO TO apopsexception
  OF "2":
   GO TO reportquer
  OF "A":
   GO TO lockedreport
  OF "X":
   GO TO start_over
  ELSE
   GO TO npsaa
 ENDCASE
 GO TO npsaa
#apopsexception
 CALL refreshscreen("    A c t i v i t y  A u d i t     ")
 SELECT INTO mine
  x.*
  FROM ap_ops_exception x
  WITH nocounter
 ;end select
 SET npsaa_answer = "/"
 GO TO npsaa
#reportquer
 CALL refreshscreen("    A c t i v i t y  A u d i t     ")
 SELECT INTO mine
  x.*
  FROM report_queue_r x
  ORDER BY x.report_queue_cd, x.sequence
  WITH nocounter
 ;end select
 SET npsaa_answer = "/"
 GO TO npsaa
#lockedreport
 CALL refreshscreen("    A c t i v i t y  A u d i t     ")
 SELECT
  accession_number = decode(pc.seq,pc.accession_nbr,concat("Case_id > ",cnvtstring(cr.case_id,32,2))),
  report_ = decode(cv.seq,cv.display,concat("catalog >",cnvtstring(cr.catalog_cd,32,2)))
  "###################", locking_user = decode(p.seq,p.name_full_formatted,concat("id >",cnvtstring(
     rt.editing_prsnl_id,32,2)))"########################",
  lock_date = rt.editing_dt_tm
  FROM report_task rt,
   dummyt d1,
   case_report cr,
   dummyt d2,
   pathology_case pc,
   dummyt d3,
   prsnl p,
   dummyt d4,
   code_value cv
  PLAN (rt
   WHERE  NOT (rt.editing_prsnl_id IN (null, 0)))
   JOIN (d1)
   JOIN (cr
   WHERE rt.report_id=cr.report_id)
   JOIN (d2)
   JOIN (pc
   WHERE cr.case_id=pc.case_id)
   JOIN (d3)
   JOIN (p
   WHERE rt.editing_prsnl_id=p.person_id)
   JOIN (d4)
   JOIN (cv
   WHERE cr.catalog_cd=cv.code_value)
  WITH outerjoin = d1, outerjoin = d2, outerjoin = d3,
   outerjoin = d4
 ;end select
 SET npsaa_answer = "/"
 GO TO npsaa
 CALL refreshscreen("    A c t i v i t y  A u d i t     ")
 GO TO npsaa
#utilities
#util
 CALL refreshscreen("         U t i l i t i e s         ")
 CALL video(u)
 CALL video(l)
 CALL text(6,3,"                                                                            ")
 CALL video(n)
 CALL text(8,5,"1   output dest label tool                                                ")
 CALL text(9,5,"2   dir cer_print/since = t                                               ")
 CALL text(10,5,"3   directory                                                             ")
 CALL text(11,5,"4   load file to broswer                                                  ")
 CALL text(12,5,"5   Unlock report                                                         ")
 CALL text(13,5,"                                                                          ")
 CALL text(14,5,"                                                                          ")
 CALL text(15,5,"                                                                          ")
 CALL text(16,5,"                                                                          ")
 CALL text(17,5,"                                                                          ")
 CALL text(18,5,"                                                                          ")
 CALL video(u)
 CALL video(l)
 CALL text(19,3,"                                                                            ")
 CALL video(n)
 CALL text(20,5,"C   Issue a COMMIT                                                        ")
 CALL text(21,5,"R   Issue a ROLLBACK                  X   Exit                            ")
 CALL video(n)
 CALL video(r)
 CALL line(5,40,18,xvert)
 CALL box(5,2,22,79)
 CALL video(n)
 CALL video(l)
 SET util_answer = "/"
 CALL clear(24,1,79)
 CALL text(24,6," ... type your choice and press enter!                   (/ for menu)")
 CALL accept(24,3,"PP;CU","  "
  WHERE curaccept IN ("1", "2", "3", "4", "5",
  "C", "R", "/", "X"))
 SET util_answer = curaccept
 CASE (util_answer)
  OF "/":
   GO TO util
  OF "1":
   GO TO chgoutputdest
  OF "2":
   GO TO dircerprint
  OF "3":
   GO TO dir1
  OF "4":
   GO TO viewfile
  OF "5":
   GO TO unlockreport
  OF "C":
   GO TO commit1
  OF "R":
   GO TO rollback1
  OF "X":
   GO TO start_over
  ELSE
   GO TO util
 ENDCASE
 GO TO util
#chgoutputdest
 CALL refreshscreen("         U t i l i t i e s         ")
 EXECUTE aps_chg_output_dest
 SET util_answer = "/"
 GO TO util
#dircerprint
 CALL refreshscreen("         U t i l i t i e s         ")
 SET dcl_cmd = "DIRECTORY/SINCE=TODAY/d/ti/ow CER_PRINT:APS*.DAT/out=cer_print:APSDIR.LIS"
 SET dcl_stat = 0
 CALL dcl(trim(dcl_cmd),textlen(trim(dcl_cmd)),dcl_stat)
 IF (findfile("CER_PRINT:APSDIR.LIS")=1)
  FREE DEFINE rtl
  DEFINE rtl "cer_print:apsdir.lis"
  SELECT
   dir_cer_print = rtlt.line
   FROM rtlt
   WITH nocounter
  ;end select
  SET dcl_cmd = "DELETE CER_PRINT:APSDIR.LIS;*"
  SET dcl_stat = 0
  CALL dcl(trim(dcl_cmd),textlen(trim(dcl_cmd)),dcl_stat)
 ELSE
  CALL text(24,5,"NO FILES WERE LOCATED... ")
  CALL pause(5)
 ENDIF
 SET util_answer = "/"
 GO TO util
#dir1
 CALL refreshscreen("         U t i l i t i e s         ")
 FREE SET file_loc
 CALL text(15,17,"Enter a valid DIRECTORY:FILENAME.EXTENSION.....")
 SET accept = nopatcheck
 CALL accept(17,18,"P(45);C")
 SET logical file_loc value(trim(curaccept))
 CALL text(10,10,file_loc)
 CALL pause(3)
 SET dcl_cmd2 = fillstring(150," ")
 SET dcl_cmd = "DIRECTORY/d/ti/ow/out=cer_print:APSDIR.LIS "
 SET dcl_cmd2 = concat(dcl_cmd,file_loc)
 CALL text(24,5,"Command issued... ")
 CALL text(20,3,tmp_cmd)
 CALL text(21,3,dcl_cmd)
 CALL text(22,3,dcl_cmd2)
 SET accept = patcheck
 SET dcl_stat = 0
 CALL dcl(trim(dcl_cmd2),textlen(trim(dcl_cmd2)),dcl_stat)
 IF (findfile("CER_PRINT:APSDIR.LIS")=1)
  FREE DEFINE rtl
  DEFINE rtl "cer_print:apsdir.lis"
  SELECT
   dir_found = rtlt.line
   FROM rtlt
   WITH nocounter
  ;end select
  SET dcl_cmd_del = "DELETE CER_PRINT:APSDIR.LIS;*"
  SET dcl_stat = 0
  CALL dcl(trim(dcl_cmd_del),textlen(trim(dcl_cmd_del)),dcl_stat)
 ELSE
  CALL text(24,5,"NO FILES WERE LOCATED... ")
  CALL pause(5)
 ENDIF
 SET util_answer = "/"
 GO TO util
#viewfile
 CALL refreshscreen("         U t i l i t i e s         ")
 FREE SET file_loc
 CALL text(15,17,"Enter a valid DIRECTORY:FILENAME.EXTENSION.....")
 CALL accept(17,18,"P(45);UC")
 SET logical file_loc value(trim(curaccept))
 IF (findfile(curaccept)=1)
  FREE DEFINE rtl
  DEFINE rtl "file_loc"
  SELECT
   dir_cer_print = rtlt.line
   FROM rtlt
   WITH nocounter
  ;end select
 ELSE
  CALL text(24,5,"NO FILES WERE LOCATED... ")
  CALL pause(5)
 ENDIF
 SET util_answer = "/"
 GO TO util
#unlockreport
 CALL refreshscreen("         U t i l i t i e s         ")
 SET rcnt = 0
 SET x = 0
 FREE SET temp
 RECORD temp(
   1 report_qual[*]
     2 report_id = f8
     2 report_disp = vc
 )
 SET help =
 SELECT INTO "NL:"
  accession_number = decode(pc.seq,pc.accession_nbr,concat("ERROR Case_id > ",cnvtstring(cr.case_id,
     32,2))), locking_user = rt.editing_prsnl_id, lock_date = rt.editing_dt_tm
  FROM report_task rt,
   case_report cr,
   dummyt d1,
   pathology_case pc
  PLAN (rt
   WHERE  NOT (rt.editing_prsnl_id IN (null, 0)))
   JOIN (cr
   WHERE rt.report_id=cr.report_id)
   JOIN (d1)
   JOIN (pc
   WHERE cr.case_id=pc.case_id)
  WITH nocounter, outterjoin = d1
 ;end select
 SET accept_accession_nbr2 = "00000XX19980000000"
 SET accept = video(iu)
 CALL text(6,20,"Enter a valid accession")
 CALL video(l)
 CALL text(17,45,"Press <HELP> to search.")
 CALL video(n)
 CALL accept(6,45,"PPPPPPPPPPPPPPPPPP;CUP",accept_accession_nbr2)
 SET accept_accession_nbr2 = curaccept
 SET help = off
 IF (accept_accession_nbr2="000000000000000000")
  GO TO unlockreportend
 ENDIF
 IF (textlen(trim(curaccept))=0)
  GO TO unlockreportend
 ENDIF
 SET case_id2 = 0.0
 SELECT INTO "NL:"
  FROM pathology_case pc
  PLAN (pc
   WHERE accept_accession_nbr2=pc.accession_nbr)
  DETAIL
   case_id2 = pc.case_id
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "NL:"
   cr.case_id
   FROM case_report cr,
    report_task rt,
    code_value cv
   PLAN (cr
    WHERE case_id2=cr.case_id)
    JOIN (rt
    WHERE cr.report_id=rt.report_id
     AND  NOT (rt.editing_prsnl_id IN (null, 0)))
    JOIN (cv
    WHERE cr.catalog_cd=cv.code_value)
   HEAD REPORT
    rcnt = 0
   DETAIL
    rcnt += 1, stat = alterlist(temp->report_qual,rcnt), temp->report_qual[rcnt].report_disp = cv
    .display,
    temp->report_qual[rcnt].report_id = cr.report_id
   WITH nocounter
  ;end select
  IF (rcnt > 1)
   CALL text(10,5,"Choose a report number: ")
   FOR (x = 1 TO rcnt)
     CALL text((10+ x),7,cnvtstring(x))
     CALL text((10+ x),8,"->")
     CALL text((10+ x),12,temp->report_qual[x].report_disp)
   ENDFOR
   CALL accept(10,30,"P;CU",accept_rpt_nbr)
   SET accept_rpt_nbr = cnvtint(curaccept)
   IF (accept_rpt_nbr=0)
    GO TO unlockreportend
   ENDIF
   CALL text(24,5,"Loading...                                                   ")
  ELSEIF (rcnt=1)
   SET accept_rpt_nbr = 1
   CALL text(24,5,"Loading...                                                   ")
  ELSE
   CALL text(24,5,"No locked reports found for this accession.                  ")
   CALL pause(5)
   GO TO unlockreport
  ENDIF
 ELSE
  CALL text(24,5,"Accession invalid, try again                                 ")
  CALL pause(5)
  GO TO unlockreport
 ENDIF
 CALL refreshscreen("     R e p o r t   U n l o c k     ")
 CALL text(2,3,"Current Case:")
 CALL video(b)
 CALL text(3,3,accept_accession_nbr2)
 CALL video(n)
 CALL text(6,10,"Unlocking a report that is being edited in an application")
 CALL text(7,10,"can cause text to be lost or overwritten.  Please be sure")
 CALL text(8,10,"that no one is truely editing this case. ")
 CALL text(10,10,"You have been warned. ")
 CALL text(12,10,"To unlock this report,  type YES and press enter.  To exit")
 CALL text(13,10,"not unlock this case press enter. ")
 CALL accept(22,45,"PPP;CU"," NO")
 IF (curaccept != "YES")
  CALL text(24,5,"Report was not unlocked at your request...                   ")
  CALL pause(2)
  GO TO unlockreportend
 ENDIF
 CALL text(24,5,"Unlocking report...                                          ")
 CALL pause(1)
 UPDATE  FROM report_task rt
  SET rt.editing_prsnl_id = 0, rt.updt_dt_tm = cnvtdatetime(curdate,curtime), rt.updt_id = 0,
   rt.updt_task = 989898, rt.updt_applctx = 0, rt.updt_cnt = (rt.updt_cnt+ 1)
  WHERE (temp->report_qual[accept_rpt_nbr].report_id=rt.report_id)
  WITH nocounter
 ;end update
 IF (curqual=0)
  CALL text(24,5,"Error while unlocking ...                                    ")
  CALL pause(5)
  GO TO unlockreport
 ELSE
  CALL text(24,5,"Unlocked...                                                  ")
  CALL pause(1)
 ENDIF
#unlockreportend
 SET util_answer = "/"
 GO TO util
#commit1
 CALL refreshscreen("         U t i l i t i e s         ")
 CALL text(15,5,"Issue a COMMIT to the database... Continue? Y/N")
 CALL accept(15,65,"P;CU"," "
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  CALL displaymessage("COMMIT","Working...")
  COMMIT
 ENDIF
 SET util_answer = "/"
 GO TO util
#rollback1
 CALL refreshscreen("         U t i l i t i e s         ")
 CALL text(15,5,"Issue a ROLLBACK to the database... Continue? Y/N")
 CALL accept(15,65,"P;CU"," "
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  CALL displaymessage("ROLLBACK","Working...")
  ROLLBACK
 ENDIF
 SET util_answer = "/"
 GO TO util
 CALL refreshscreen("         U t i l i t i e s         ")
 GO TO util
 SUBROUTINE refreshscreen(utilname)
   CALL clear(1,1)
   CALL video(r)
   CALL text(2,24,"        Anatomic Pathology         ")
   CALL text(3,24,utilname)
   CALL video(n)
   CALL box(1,1,23,80)
   CALL line(4,1,80,xhor)
   CALL line(1,22,4,xvert)
   CALL line(1,60,4,xvert)
 END ;Subroutine
 SUBROUTINE displaycase(dummy)
   CALL text(2,3,"Current Case:")
   CALL video(l)
   CALL text(3,3,accept_accession_nbr)
   CALL video(n)
 END ;Subroutine
 SUBROUTINE displaymessage(text1,text2)
   CALL text(2,62,trim(text1))
   CALL video(b)
   CALL text(3,62,trim(text2))
   CALL video(n)
 END ;Subroutine
#end_program
 CALL clear(1,1)
 CALL text(24,0,"Exiting Program...                                                      ")
END GO
