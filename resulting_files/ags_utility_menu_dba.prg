CREATE PROGRAM ags_utility_menu:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE s_log_name = vc WITH public, noconstant("")
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD msg_rec
 RECORD msg_rec(
   1 qual_knt = i4
   1 qual[*]
     2 line = vc
 )
 DECLARE working_job_id = f8 WITH public, noconstant(0.0)
 DECLARE working_file_type = vc WITH public, noconstant("")
 DECLARE working_file_name = vc WITH public, noconstant("")
 DECLARE msg_line_nbr = i2 WITH public, noconstant(0)
 DECLARE msg_wknt = i2 WITH public, noconstant(0)
 DECLARE accept_value = vc WITH public, noconstant("")
 DECLARE data_type = vc WITH public, noconstant("")
 DECLARE backout_driver = vc WITH public, constant("")
 DECLARE s_process_type = vc WITH public, noconstant("")
 DECLARE s_file_type = vc WITH public, noconstant("")
 DECLARE msg_line_1 = vc WITH public, noconstant("")
 DECLARE msg_line_2 = vc WITH public, noconstant("")
 DECLARE msg_line_3 = vc WITH public, noconstant("")
 DECLARE msg_line_4 = vc WITH public, noconstant("")
 DECLARE msg_line_5 = vc WITH public, noconstant("")
 DECLARE header_line = vc WITH public, noconstant("")
 DECLARE true_header_line = vc WITH public, noconstant("")
 DECLARE line_len = i4 WITH public, noconstant(0)
 DECLARE working_str = vc WITH public, noconstant("")
 DECLARE delim = c1 WITH public, noconstant(",")
 DECLARE wknt = i4 WITH public, noconstant(0)
 DECLARE continue = i2 WITH public, noconstant(false)
 DECLARE the_col_name = vc WITH public, noconstant(" ")
 DECLARE dpos = i4 WITH public, noconstant(0)
 DECLARE file_row_knt = i4 WITH public, noconstant(0)
 DECLARE ridx = i4 WITH public, noconstant(0)
 DECLARE found_person_id = i2 WITH public, noconstant(false)
 DECLARE found_ssn_alias = i2 WITH public, noconstant(false)
 DECLARE found_name_last = i2 WITH public, noconstant(false)
 DECLARE found_name_first = i2 WITH public, noconstant(false)
 DECLARE found_sex_code = i2 WITH public, noconstant(false)
 DECLARE found_birth_date = i2 WITH public, noconstant(false)
 DECLARE found_sending_facility = i2 WITH public, noconstant(false)
 DECLARE w_line = vc WITH public, noconstant(" ")
 DECLARE field_knt = i4 WITH public, noconstant(0)
 DECLARE dknt = i4 WITH public, noconstant(0)
 DECLARE min_line_knt = i4 WITH public, noconstant(0)
 DECLARE max_line_knt = i4 WITH public, noconstant(0)
 DECLARE d_element = vc WITH public, noconstant("")
 DECLARE zidx = i4 WITH public, noconstant(1)
 DECLARE rpt_knt = i4 WITH public, noconstant(1)
 DECLARE suser = vc WITH protect, constant(curuser)
 DECLARE iengineerrun = i2 WITH protect, noconstant(false)
 IF (suser IN ("SF3151", "WA4101", "SB2348", "BR014532"))
  SET iengineerrun = true
 ENDIF
 FREE RECORD col_rec
 RECORD col_rec(
   1 qual_knt = i4
   1 qual[*]
     2 col_name = vc
 )
 FREE RECORD rec_info
 RECORD rec_info(
   1 qual_knt = i4
   1 qual[*]
     2 rec_line = vc
     2 assignment_line = vc
 )
 FREE RECORD data
 RECORD data(
   1 qual_knt = i4
   1 qual[*]
     2 element = vc
 )
 FREE RECORD person_rec
 RECORD person_rec(
   1 qual_knt = i4
   1 qual[*]
     2 person_id = f8
     2 validated_ind = i2
     2 name_last_key = vc
     2 name_first_key = vc
     2 sex_cd = f8
     2 birth_dt_tm = dq8
     2 ssn_alias = vc
 )
 DECLARE male_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",57,"MALE"))
 DECLARE female_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",57,"FEMALE"))
 DECLARE ssn_alias_type_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE testing_domain = i2 WITH public, noconstant(false)
 DECLARE purge_extended_data = c1 WITH public, noconstant("N")
 SELECT INTO "nl:"
  FROM dm_info d
  PLAN (d
   WHERE d.info_domain="AGS"
    AND d.info_name="TEST_DOMAIN")
  DETAIL
   testing_domain = true
  WITH nocounter
 ;end select
 DECLARE valid_job(d_job_id=f8,s_file_type=vc) = i2
 IF (male_cd < 1)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line =
  "FAILED :: INVALID CODE_VALUE MALE_CD :: CDF_MEANING MALE :: CODE_SET 57"
  GO TO msg_menu
 ENDIF
 IF (female_cd < 1)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line =
  "FAILED :: INVALID CODE_VALUE FEMALE_CD :: CDF_MEANING FEMALE :: CODE_SET 57"
  GO TO msg_menu
 ENDIF
 IF (ssn_alias_type_cd < 1)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line =
  "FAILED :: INVALID CODE_VALUE SSN_ALIAS_TYPE_CD :: CDF_MEANING SSN :: CODE_SET 4"
  GO TO msg_menu
 ENDIF
#main_menu
 SET failed = false
 CALL video(n)
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Utility Menu")
 CALL text(8,7," 1. Clean")
 CALL text(10,7," 2. Backout")
 CALL text(12,7," 3. Purge")
 CALL text(14,7," 4. EXIT")
 CALL text(23,2,"Select an item number:  ")
 CALL accept(23,25,"9;H",4
  WHERE curaccept >= 0
   AND curaccept <= 4)
 CASE (curaccept)
  OF 1:
   GO TO clean_menu
  OF 2:
   GO TO backout_menu
  OF 3:
   GO TO purge_menu
  OF 4:
   GO TO exit_script
  ELSE
   GO TO main_menu
 ENDCASE
#clean_menu
 SET working_file_type = ""
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Clean Type")
 CALL text(8,7," 1. Person")
 CALL text(10,7," 2. Organization")
 CALL text(12,7," 3. Personnel")
 CALL text(14,7," 4. Plan")
 CALL text(20,7," 0 - Return to Main Menu")
 CALL text(23,2,"Select an item number:  ")
 CALL accept(23,25,"9;H",0
  WHERE curaccept >= 0
   AND curaccept <= 4)
 CASE (curaccept)
  OF 1:
   GO TO person_clean_menu
  OF 2:
   GO TO org_clean_menu
  OF 3:
   GO TO prsnl_clean_menu
  OF 4:
   GO TO plan_clean_menu
  OF 0:
   GO TO main_menu
  ELSE
   GO TO clean_menu
 ENDCASE
 GO TO main_menu
#person_clean_menu
 SET accept_value = ""
 SET working_job_id = 0.0
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Person Clean Option")
 CALL text(8,7," Enter the AGS_JOB_ID value you wish to clean")
 CALL text(10,7," The AGS_JOB_ID can be found on the AGS_JOB")
 CALL text(11,7," table with a FILE_TYPE value of PERSON")
 CALL text(23,2,"Enter <0> for Clean Menu:  ")
 CALL accept(23,28,"P(20);C")
 SET accept_value = curaccept
 IF (isnumeric(accept_value) < 1)
  GO TO clean_menu
 ENDIF
 SET working_job_id = cnvtreal(accept_value)
 SET working_file_type = "PERSON"
 IF (working_job_id < 1)
  GO TO clean_menu
 ENDIF
 SET stat = initrec(msg_rec)
 IF (valid_job(working_job_id,working_file_type))
  EXECUTE ags_person_clean value(working_job_id)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("EXECUTE :: AGS_PERSON_CLEAN :: AGS_JOB_ID :: ",
   trim(cnvtstring(working_job_id)))
  IF (failed != false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_PERSON_CLEAN :: AGS_JOB_ID :: ",
    trim(cnvtstring(working_job_id)))
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS :: AGS_PERSON_CLEAN :: AGS_JOB_ID :: ",
    trim(cnvtstring(working_job_id)))
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
   " in the cer_log")
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "   directory for details"
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID AGS_JOB_ID (",trim(cnvtstring(
     working_job_id)),") for FILE_TYPE (",trim(working_file_type),")")
 ENDIF
 GO TO msg_menu
#org_clean_menu
 SET accept_value = ""
 SET working_job_id = 0.0
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Organization Clean Option")
 CALL text(8,7," Enter the AGS_JOB_ID value you wish to clean")
 CALL text(10,7," The AGS_JOB_ID can be found on the AGS_JOB")
 CALL text(11,7," table with a FILE_TYPE value of PRSNL_ORG")
 CALL text(23,2,"Enter <0> for Clean Menu:  ")
 CALL accept(23,28,"P(20);C")
 SET accept_value = curaccept
 IF (isnumeric(accept_value) < 1)
  GO TO clean_menu
 ENDIF
 SET working_job_id = cnvtreal(accept_value)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="AGS"
    AND di.info_name="ORG_MIGRATION")
  DETAIL
   IF (cnvtint(di.info_number) < 1)
    working_file_type = "PRSNL_ORG"
   ELSE
    working_file_type = "ORG"
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line =
  "ERROR >> VALIDATING PROVIDER DIRECTORY :: Select Error"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(serrmsg)
  GO TO msg_menu
 ENDIF
 IF (working_job_id < 1)
  GO TO clean_menu
 ENDIF
 SET stat = initrec(msg_rec)
 IF (valid_job(working_job_id,working_file_type))
  EXECUTE ags_org_clean value(working_job_id)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("EXECUTE :: AGS_ORG_CLEAN :: AGS_JOB_ID :: ",
   trim(cnvtstring(working_job_id)))
  IF (failed != false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_ORG_CLEAN :: AGS_JOB_ID :: ",
    trim(cnvtstring(working_job_id)))
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS :: AGS_ORG_CLEAN :: AGS_JOB_ID :: ",
    trim(cnvtstring(working_job_id)))
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
   " in the cer_log")
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "   directory for details"
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID AGS_JOB_ID (",trim(cnvtstring(
     working_job_id)),") for FILE_TYPE (",trim(working_file_type),")")
 ENDIF
 GO TO msg_menu
#prsnl_clean_menu
 SET accept_value = ""
 SET working_job_id = 0.0
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Personnel Clean Option")
 CALL text(8,7," Enter the AGS_JOB_ID value you wish to clean")
 CALL text(10,7," The AGS_JOB_ID can be found on the AGS_JOB")
 CALL text(11,7," table with a FILE_TYPE value of PRSNL_ORG")
 CALL text(23,2,"Enter <0> for Clean Menu:  ")
 CALL accept(23,28,"P(20);C")
 SET accept_value = curaccept
 IF (isnumeric(accept_value) < 1)
  GO TO clean_menu
 ENDIF
 SET working_job_id = cnvtreal(accept_value)
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="AGS"
    AND di.info_name="PRSNL_MIGRATION")
  DETAIL
   IF (cnvtint(di.info_number) < 1)
    working_file_type = "PRSNL_ORG"
   ELSE
    working_file_type = "PRSNL"
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line =
  "ERROR >> VALIDATING PROVIDER DIRECTORY :: Select Error"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(serrmsg)
  GO TO msg_menu
 ENDIF
 IF (working_job_id < 1)
  GO TO clean_menu
 ENDIF
 SET stat = initrec(msg_rec)
 IF (valid_job(working_job_id,working_file_type))
  EXECUTE ags_prsnl_clean value(working_job_id)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("EXECUTE :: AGS_PRSNL_CLEAN :: AGS_JOB_ID :: ",
   trim(cnvtstring(working_job_id)))
  IF (failed != false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_PRSNL_CLEAN :: AGS_JOB_ID :: ",
    trim(cnvtstring(working_job_id)))
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS :: AGS_PRSNL_CLEAN :: AGS_JOB_ID :: ",
    trim(cnvtstring(working_job_id)))
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
   " in the cer_log")
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "   directory for details"
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID AGS_JOB_ID (",trim(cnvtstring(
     working_job_id)),") for FILE_TYPE (",trim(working_file_type),")")
 ENDIF
 GO TO msg_menu
#plan_clean_menu
 SET accept_value = ""
 SET working_job_id = 0.0
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Plan Clean Option")
 CALL text(8,7," Enter the AGS_JOB_ID value you wish to clean")
 CALL text(10,7," The AGS_JOB_ID can be found on the AGS_JOB")
 CALL text(11,7," table with a FILE_TYPE value of PLAN")
 CALL text(23,2,"Enter <0> for Clean Menu:  ")
 CALL accept(23,28,"P(20);C")
 SET accept_value = curaccept
 IF (isnumeric(accept_value) < 1)
  GO TO clean_menu
 ENDIF
 SET working_job_id = cnvtreal(accept_value)
 SET working_file_type = "PLAN"
 IF (working_job_id < 1)
  GO TO clean_menu
 ENDIF
 SET stat = initrec(msg_rec)
 IF (valid_job(working_job_id,working_file_type))
  EXECUTE ags_plan_clean value(working_job_id)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("EXECUTE :: AGS_PLAN_CLEAN :: AGS_JOB_ID :: ",
   trim(cnvtstring(working_job_id)))
  IF (failed != false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_PLAN_CLEAN :: AGS_JOB_ID :: ",
    trim(cnvtstring(working_job_id)))
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS :: AGS_PLAN_CLEAN :: AGS_JOB_ID :: ",
    trim(cnvtstring(working_job_id)))
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
   " in the cer_log")
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "   directory for details"
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID AGS_JOB_ID (",trim(cnvtstring(
     working_job_id)),") for FILE_TYPE (",trim(working_file_type),")")
 ENDIF
 GO TO msg_menu
#backout_menu
 SET data_type = ""
 SET working_file_type = ""
 SET s_process_type = "BACKOUT"
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Backout Data Type")
 CALL text(8,7," 1. Benefit Level")
 CALL text(9,7," 2. Claim Detail")
 CALL text(10,7," 3. Immun")
 CALL text(11,7," 4. Meds")
 CALL text(12,7," 5. Result")
 CALL text(13,7," 6. Claim")
 CALL text(14,7," 7. Org")
 CALL text(15,7," 8. Prsnl")
 CALL text(16,7," 9. Person")
 CALL text(8,40," 10. Plan")
 CALL text(20,7," 0 - Return to Main Menu")
 CALL text(23,2,"Select an item number:  ")
 CALL accept(23,25,"9(2);H",0
  WHERE curaccept >= 0
   AND curaccept <= 10)
 CASE (curaccept)
  OF 1:
   SET working_file_type = "BENEFIT_LEVEL"
  OF 2:
   SET working_file_type = "CLAIMDETAIL"
  OF 3:
   SET working_file_type = "IMMUN"
  OF 4:
   SET working_file_type = "MEDS"
  OF 5:
   SET working_file_type = "RESULT"
  OF 6:
   SET working_file_type = "CLAIM"
  OF 7:
   SET working_file_type = "PRSNL_ORG"
   SET data_type = "ORG"
   GO TO disclaimer_menu
  OF 8:
   SET working_file_type = "PRSNL_ORG"
   SET data_type = "PRSNL"
   GO TO disclaimer_menu
  OF 9:
   SET working_file_type = "PERSON"
   GO TO disclaimer_menu
  OF 10:
   SET working_file_type = "PLAN"
  ELSE
   GO TO main_menu
 ENDCASE
 GO TO driver_type_menu
#disclaimer_menu
 IF (iengineerrun=true)
  GO TO driver_type_menu
 ENDIF
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7,"WARNING!!!!!  WARNING!!!!  WARNING!!!!  WARNING!!!!  WARNING!!!!!")
 CALL text(8,7,"   The back-out and/or purging of Person, Personnel, or")
 CALL text(9,7,"   Organization data is not recommended.  The back-out")
 CALL text(10,7,"   and/or purging of this information can result in the")
 CALL text(11,7,"   orphaning of activity data associated to the Person,")
 CALL text(12,7,"   Personnel or Organization data being backed-out or purged")
 CALL text(14,7,"Only Proceed if you fully understand the ramifications of the action")
 CALL text(16,7,"WARNING!!!!!  WARNING!!!!  WARNING!!!!  WARNING!!!!  WARNING!!!!!")
 CALL text(18,7,"Entering (N) will return you to the Main Menu")
 CALL text(20,7,"Entering (Y) will continue the Back-out or Purge")
 CALL text(23,2,"Enter (Y or N):  ")
 CALL accept(23,18,"P;CU","N"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="Y")
  GO TO driver_type_menu
 ELSE
  GO TO main_menu
 ENDIF
#purge_menu
 SET data_type = ""
 SET working_file_type = ""
 SET s_process_type = "PURGE"
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Purge Data Type")
 CALL text(8,7," 1. Benefit Level")
 CALL text(9,7," 2. Claim Detail")
 CALL text(10,7," 3. Immun")
 CALL text(11,7," 4. Meds")
 CALL text(12,7," 5. Result")
 CALL text(13,7," 6. Claim")
 CALL text(14,7," 7. Org")
 CALL text(15,7," 8. Prsnl")
 CALL text(16,7," 9. Person")
 CALL text(8,40," 10. Plan")
 CALL text(20,7," 0 - Return to Main Menu")
 CALL text(23,2,"Select an item number:  ")
 CALL accept(23,25,"9(2);H",0
  WHERE curaccept >= 0
   AND curaccept <= 10)
 CASE (curaccept)
  OF 1:
   SET working_file_type = "BENEFIT_LEVEL"
  OF 2:
   SET working_file_type = "CLAIMDETAIL"
  OF 3:
   SET working_file_type = "IMMUN"
  OF 4:
   SET working_file_type = "MEDS"
  OF 5:
   SET working_file_type = "RESULT"
  OF 6:
   SET working_file_type = "CLAIM"
  OF 7:
   SET working_file_type = "PRSNL_ORG"
   SET data_type = "ORG"
   GO TO disclaimer_menu
  OF 8:
   SET working_file_type = "PRSNL_ORG"
   SET data_type = "PRSNL"
   GO TO disclaimer_menu
  OF 9:
   SET working_file_type = "PERSON"
   GO TO disclaimer_menu
  OF 10:
   SET working_file_type = "PLAN"
  ELSE
   GO TO main_menu
 ENDCASE
 GO TO driver_type_menu
#driver_type_menu
 IF (working_file_type IN ("PRSNL_ORG", "PERSON"))
  GO TO get_job_id_menu
 ENDIF
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Driver Type")
 CALL text(10,7," 1. Job")
 CALL text(14,7," 2. Person")
 CALL text(20,7," 0 - Return to Main Menu")
 CALL text(23,2,"Select an item number:  ")
 CALL accept(23,25,"9;H",0
  WHERE curaccept >= 0
   AND curaccept <= 2)
 CASE (curaccept)
  OF 1:
   GO TO get_job_id_menu
  OF 2:
   GO TO get_person_file_menu
  ELSE
   GO TO main_menu
 ENDCASE
#get_job_id_menu
 SET accept_value = ""
 SET working_job_id = 0.0
 SET msg_line_1 = ""
 SET msg_line_2 = ""
 SET msg_line_3 = ""
 SET msg_line_4 = ""
 SET msg_line_5 = ""
 SET msg_line_1 = "Enter the AGS_JOB_ID value you wish to"
 IF (s_process_type="BACKOUT")
  SET msg_line_1 = concat(trim(msg_line_1)," backout.")
 ELSEIF (s_process_type="PURGE")
  SET msg_line_1 = concat(trim(msg_line_1)," purge.")
 ELSE
  GO TO main_menu
 ENDIF
 SET msg_line_2 = "The AGS_JOB_ID can be found on the AGS_JOB"
 SET msg_line_3 = "table with a FILE_TYPE value of"
 IF (working_file_type="BENEFIT_LEVEL")
  SET msg_line_3 = concat(trim(msg_line_3)," BENEFIT_LEVEL")
 ELSEIF (working_file_type="CLAIMDETAIL")
  SET msg_line_3 = concat(trim(msg_line_3)," CLAIMDETAIL")
 ELSEIF (working_file_type="IMMUN")
  SET msg_line_3 = concat(trim(msg_line_3)," IMMUN")
 ELSEIF (working_file_type="MEDS")
  SET msg_line_3 = concat(trim(msg_line_3)," MEDS")
 ELSEIF (working_file_type="RESULT")
  SET msg_line_3 = concat(trim(msg_line_3)," RESULT")
 ELSEIF (working_file_type="CLAIM")
  SET msg_line_3 = concat(trim(msg_line_3)," CLAIM")
 ELSEIF (working_file_type="PERSON")
  SET msg_line_3 = concat(trim(msg_line_3)," PERSON")
 ELSEIF (working_file_type="PLAN")
  SET msg_line_3 = concat(trim(msg_line_3)," PLAN")
 ELSEIF (working_file_type="PRSNL_ORG")
  IF (data_type="PRSNL")
   SET msg_line_3 = concat(trim(msg_line_3)," PRSNL_ORG")
  ELSEIF (data_type="ORG")
   SET msg_line_3 = concat(trim(msg_line_3)," PRSNL_ORG")
  ELSE
   GO TO main_menu
  ENDIF
 ELSE
  GO TO main_menu
 ENDIF
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," AGS_JOB_ID MENU")
 CALL text(8,7,trim(msg_line_1))
 CALL text(10,7,trim(msg_line_2))
 CALL text(11,7,trim(msg_line_3))
 CALL text(23,2,"Enter <0> for Main Menu:  ")
 CALL accept(23,28,"P(20);C")
 SET accept_value = curaccept
 IF (isnumeric(accept_value) < 1)
  GO TO main_menu
 ENDIF
 SET working_job_id = cnvtreal(accept_value)
 IF (working_job_id < 1)
  GO TO main_menu
 ENDIF
 SET stat = initrec(msg_rec)
 IF (valid_job(working_job_id,working_file_type))
  IF (working_file_type="BENEFIT_LEVEL")
   IF (s_process_type="BACKOUT")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_BENEFIT_LEVEL_BACKOUT for AGS_JOB_ID"
    EXECUTE ags_benefit_level_backout value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_BENEFIT_LEVEL_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_BENEFIT_LEVEL_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSEIF (s_process_type="PURGE")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_BENEFIT_LEVEL_PURGE for AGS_JOB_ID"
    EXECUTE ags_benefit_level_purge value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_BENEFIT_LEVEL_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_BENEFIT_LEVEL_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
      working_job_id)))
   GO TO msg_menu
  ELSEIF (working_file_type="CLAIMDETAIL")
   IF (s_process_type="BACKOUT")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_CLAIM_DETAIL_BACKOUT for AGS_JOB_ID"
    EXECUTE ags_claim_detail_backout value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_CLAIM_DETAIL_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_CLAIM_DETAIL_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSEIF (s_process_type="PURGE")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_CLAIM_DETAIL_PURGE for AGS_JOB_ID"
    EXECUTE ags_claim_detail_purge value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_CLAIM_DETAIL_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_CLAIM_DETAIL_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
      working_job_id)))
   GO TO msg_menu
  ELSEIF (working_file_type="IMMUN")
   IF (s_process_type="BACKOUT")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_IMMUN_BACKOUT for AGS_JOB_ID"
    EXECUTE ags_immun_backout value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_IMMUN_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_IMMUN_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSEIF (s_process_type="PURGE")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_IMMUN_PURGE for AGS_JOB_ID"
    EXECUTE ags_immun_purge value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_IMMUN_PURGE :: AGS_JOB_ID :: ",
      trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_IMMUN_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
      working_job_id)))
   GO TO msg_menu
  ELSEIF (working_file_type="MEDS")
   IF (s_process_type="BACKOUT")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_MEDS_BACKOUT for AGS_JOB_ID"
    EXECUTE ags_meds_backout value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_MEDS_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_MEDS_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSEIF (s_process_type="PURGE")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_MEDS_PURGE for AGS_JOB_ID"
    EXECUTE ags_meds_purge value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_MEDS_PURGE :: AGS_JOB_ID :: ",
      trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS :: AGS_MEDS_PURGE :: AGS_JOB_ID :: ",
      trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
      working_job_id)))
   GO TO msg_menu
  ELSEIF (working_file_type="RESULT")
   IF (s_process_type="BACKOUT")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_RESULT_BACKOUT for AGS_JOB_ID"
    EXECUTE ags_result_backout value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_RESULT_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_RESULT_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSEIF (s_process_type="PURGE")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_RESULT_PURGE for AGS_JOB_ID"
    EXECUTE ags_result_purge value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_RESULT_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_RESULT_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
      working_job_id)))
   GO TO msg_menu
  ELSEIF (working_file_type="CLAIM")
   IF (s_process_type="BACKOUT")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_CLAIM_BACKOUT for AGS_JOB_ID"
    EXECUTE ags_claim_backout value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_CLAIM_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_CLAIM_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSEIF (s_process_type="PURGE")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_CLAIM_PURGE for AGS_JOB_ID"
    EXECUTE ags_claim_purge value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_CLAIM_PURGE :: AGS_JOB_ID :: ",
      trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_CLAIM_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
      working_job_id)))
   GO TO msg_menu
  ELSEIF (working_file_type="PERSON")
   IF (s_process_type="BACKOUT")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_PERSON_BACKOUT for AGS_JOB_ID"
    EXECUTE ags_person_backout value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_PERSON_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_PERSON_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSEIF (s_process_type="PURGE")
    IF (testing_domain=true)
     CALL clear(1,1)
     CALL box(2,1,22,80)
     CALL line(4,1,80,xhor)
     CALL text(3,3,"AGS UTILITY PROGRAM")
     CALL box(5,5,21,76)
     CALL line(7,5,72,xhor)
     CALL text(6,7," EXTENDED PERSON DATA")
     CALL text(8,7," Purge extended person data? (Y/N) ")
     CALL accept(23,25,"A;CU","N"
      WHERE curaccept IN ("N", "Y"))
     CASE (curaccept)
      OF "N":
       SET purge_extended_data = curaccept
      OF "Y":
       SET purge_extended_data = curaccept
      ELSE
       SET purge_extended_data = "N"
     ENDCASE
    ELSE
     SET purge_extended_data = "N"
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_PERSON_PURGE for AGS_JOB_ID"
    EXECUTE ags_person_purge value("J"), value(working_job_id), value(purge_extended_data)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_PERSON_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_PERSON_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
      working_job_id)))
   GO TO msg_menu
  ELSEIF (working_file_type="PLAN")
   IF (s_process_type="BACKOUT")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_PLAN_BACKOUT for AGS_JOB_ID"
    EXECUTE ags_plan_backout value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "FAILED :: AGS_PLAN_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SUCCESS :: AGS_PLAN_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSEIF (s_process_type="PURGE")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_PLAN_PURGE for AGS_JOB_ID"
    EXECUTE ags_plan_purge value("J"), value(working_job_id)
    IF (failed != false)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_PLAN_PURGE :: AGS_JOB_ID :: ",
      trim(cnvtstring(working_job_id)))
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS :: AGS_PLAN_PURGE :: AGS_JOB_ID :: ",
      trim(cnvtstring(working_job_id)))
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
     " in the")
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
      working_job_id)))
   GO TO msg_menu
  ELSEIF (working_file_type="PRSNL_ORG")
   IF (data_type="PRSNL")
    IF (s_process_type="BACKOUT")
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_PRSNL_BACKOUT for AGS_JOB_ID"
     EXECUTE ags_prsnl_backout value("J"), value(working_job_id)
     IF (failed != false)
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat(
       "FAILED :: AGS_PRSNL_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
     ELSE
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat(
       "SUCCESS :: AGS_PRSNL_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
     ENDIF
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
      " in the")
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
    ELSEIF (s_process_type="PURGE")
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_PRSNL_PURGE for AGS_JOB_ID"
     EXECUTE ags_prsnl_purge value("J"), value(working_job_id)
     IF (failed != false)
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat(
       "FAILED :: AGS_PRSNL_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
     ELSE
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat(
       "SUCCESS :: AGS_PRSNL_PURGE :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
     ENDIF
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
      " in the")
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
       working_job_id)))
    GO TO msg_menu
   ELSEIF (data_type="ORG")
    IF (s_process_type="BACKOUT")
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_ORG_BACKOUT for AGS_JOB_ID"
     EXECUTE ags_org_backout value("J"), value(working_job_id)
     IF (failed != false)
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat(
       "FAILED :: AGS_ORG_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
     ELSE
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat(
       "SUCCESS :: AGS_ORG_BACKOUT :: AGS_JOB_ID :: ",trim(cnvtstring(working_job_id)))
     ENDIF
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
      " in the")
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
    ELSEIF (s_process_type="PURGE")
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_ORG_PURGE for AGS_JOB_ID"
     EXECUTE ags_org_purge value("J"), value(working_job_id)
     IF (failed != false)
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: AGS_ORG_PURGE :: AGS_JOB_ID :: ",
       trim(cnvtstring(working_job_id)))
     ELSE
      SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
      SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
      SET msg_rec->qual[msg_rec->qual_knt].line = concat("SUCCESS :: AGS_ORG_PURGE :: AGS_JOB_ID :: ",
       trim(cnvtstring(working_job_id)))
     ENDIF
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
      " in the")
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
    ELSE
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
    ENDIF
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("   AGS_JOB_ID = ",trim(cnvtstring(
       working_job_id)))
    GO TO msg_menu
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID DATA_TYPE : ",trim(data_type))
    GO TO msg_menu
   ENDIF
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID WORKING_FILE_TYPE : ",trim(
     working_file_type))
   GO TO msg_menu
  ENDIF
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID AGS_JOB_ID (",trim(cnvtstring(
     working_job_id)),") for FILE_TYPE (",trim(working_file_type),")")
 ENDIF
 GO TO msg_menu
#get_person_file_menu
 SET stat = initrec(col_rec)
 SET stat = initrec(rec_info)
 SET stat = initrec(data)
 SET accept_value = ""
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," PERSON FILE MENU")
 CALL text(8,7," Enter the full/path file name of the person file")
 CALL text(23,2,"Enter <0> for Main Menu:  ")
 CALL accept(23,28,"P(70);C")
 SET accept_value = curaccept
 IF (isnumeric(accept_value) > 0)
  GO TO main_menu
 ENDIF
 SET stat = initrec(msg_rec)
 SET working_file_name = trim(accept_value,3)
 IF (findfile(value(working_file_name))=0)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED to find person file"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(working_file_name)
  GO TO msg_menu
 ENDIF
 FREE DEFINE rtl2
 FREE SET file_loc
 SET logical file_loc value(nullterm(working_file_name))
 DEFINE rtl2 "file_loc"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM rtl2t t
  HEAD REPORT
   header_line = t.line, true_header_line = header_line, line_len = textlen(header_line),
   stat = alterlist(col_rec->qual,10), working_str = substring(1,1,header_line)
   IF (working_str != '"')
    IF (findstring(",",header_line,1,0) > 0)
     delim = ","
    ELSEIF (findstring("|",header_line,1,0) > 0)
     delim = "|"
    ELSEIF (findstring("@",header_line,1,0) > 0)
     delim = "@"
    ELSEIF (findstring("~",header_line,1,0) > 0)
     delim = "~"
    ELSEIF (findstring("$",header_line,1,0) > 0)
     delim = "$"
    ELSEIF (findstring("^",header_line,1,0) > 0)
     delim = "^"
    ELSEIF (findstring("*",header_line,1,0) > 0)
     delim = "*"
    ELSEIF (findstring("#",header_line,1,0) > 0)
     delim = "#"
    ELSE
     delim = ","
    ENDIF
   ELSE
    delim = substring((findstring('"',header_line,2,0)+ 1),1,header_line)
   ENDIF
   continue = true, wknt = 0
   WHILE (continue=true)
     the_col_name = " ", wknt = (wknt+ 1)
     IF (mod(wknt,10)=1
      AND wknt != 1)
      stat = alterlist(col_rec->qual,(wknt+ 9))
     ENDIF
     IF (substring(1,1,header_line)='"')
      IF (substring(2,2,header_line)='""')
       dpos = findstring('""",',header_line)
       IF (dpos=0)
        continue = false, dpos = findstring('"""',substring(4,line_len,header_line)), the_col_name =
        substring(4,(dpos - 1),header_line)
       ELSE
        the_col_name = substring(4,(dpos - 4),header_line), header_line = substring((dpos+ 4),
         line_len,header_line)
        IF (header_line=" ")
         continue = false
        ENDIF
       ENDIF
      ELSE
       dpos = findstring('",',header_line)
       IF (dpos=0)
        continue = false, dpos = findstring('"',substring(2,line_len,header_line)), the_col_name =
        substring(2,(dpos - 1),header_line)
       ELSE
        the_col_name = substring(2,(dpos - 2),header_line), header_line = substring((dpos+ 2),
         line_len,header_line)
        IF (header_line=" ")
         continue = false
        ENDIF
       ENDIF
      ENDIF
     ELSE
      dpos = findstring(delim,header_line)
      IF (dpos=0)
       continue = false, the_col_name = substring(1,line_len,header_line)
      ELSE
       the_col_name = substring(1,(dpos - 1),header_line), header_line = substring((dpos+ 1),line_len,
        header_line)
       IF (header_line=" ")
        continue = false
       ENDIF
      ENDIF
     ENDIF
     col_rec->qual[wknt].col_name = the_col_name
     IF (the_col_name="PERSON_ID")
      found_person_id = true
     ELSEIF (the_col_name="SSN_ALIAS")
      found_ssn_alias = true
     ELSEIF (the_col_name="NAME_LAST")
      found_name_last = true
     ELSEIF (the_col_name="NAME_FIRST")
      found_name_first = true
     ELSEIF (the_col_name="SEX_CODE")
      found_sex_code = true
     ELSEIF (the_col_name="BIRTH_DATE")
      found_birth_date = true
     ENDIF
   ENDWHILE
   stat = alterlist(col_rec->qual,wknt), col_rec->qual_knt = wknt
  DETAIL
   file_row_knt = (file_row_knt+ 1)
  WITH nocounter
 ;end select
 FREE DEFINE rtl2
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR >> READ PARAMETER FILE :: Select Error"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(serrmsg)
  GO TO msg_menu
 ENDIF
 IF (((found_person_id=false) OR (((found_ssn_alias=false) OR (((found_name_last=false) OR (((
 found_name_first=false) OR (((found_sex_code=false) OR (found_birth_date=false)) )) )) )) )) )
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR >> INVALID COL FORMAT :: Input Error"
  IF (found_person_id=false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   FAILED to find PERSON_ID column"
  ENDIF
  IF (found_ssn_alias=false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   FAILED to find SSN_ALIAS column"
  ENDIF
  IF (found_name_last=false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   FAILED to find NAME_LAST column"
  ENDIF
  IF (found_name_first=false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   FAILED to find NAME_FIRST column"
  ENDIF
  IF (found_sex_code=false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   FAILED to find SEX_CODE column"
  ENDIF
  IF (found_birth_date=false)
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   FAILED to find BIRTH_DATE column"
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(true_header_line)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("delim = ",trim(delim))
  GO TO msg_menu
 ENDIF
 IF (file_row_knt <= 1)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR >> INVALID ROW COUNT :: Input Error"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("ERROR >> Person File Row Count : ",trim(
    cnvtstring(file_row_knt)))
  GO TO msg_menu
 ENDIF
 SET stat = alterlist(rec_info->qual,10)
 SET ridx = 0
 FOR (ridx = 1 TO col_rec->qual_knt)
  IF (mod(ridx,10)=1
   AND ridx != 1)
   SET stat = alterlist(rec_info->qual,(ridx+ 9))
  ENDIF
  SET rec_info->qual[ridx].rec_line = concat("2 ",col_rec->qual[ridx].col_name," = vc")
 ENDFOR
 SET rec_info->qual_knt = ridx
 SET stat = alterlist(rec_info->qual,ridx)
 FREE RECORD requestin
 CALL parser("record requestin")
 CALL parser("(1 list_0[*]")
 SET ridx = 0
 FOR (ridx = 1 TO rec_info->qual_knt)
   CALL parser(rec_info->qual[ridx].rec_line)
 ENDFOR
 CALL parser(")")
 CALL parser("go")
 FREE DEFINE rtl2
 FREE SET file_loc
 SET logical file_loc value(nullterm(working_file_name))
 DEFINE rtl2 "file_loc"
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM rtl2t t
  PLAN (t
   WHERE t.line > " ")
  HEAD REPORT
   min_line_knt = 2, max_line_knt = (file_row_knt+ 1), w_line = " ",
   knt = 0, dknt = 0, stat = alterlist(data->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (knt >= min_line_knt
    AND knt <= max_line_knt)
    w_line = "", w_line = t.line, line_len = textlen(w_line),
    field_knt = 1, dpos = 0
    WHILE ((field_knt <= col_rec->qual_knt))
      d_element = " ", dknt = (dknt+ 1)
      IF (mod(dknt,10)=1
       AND dknt != 1)
       stat = alterlist(data->qual,(dknt+ 9))
      ENDIF
      IF (substring(1,1,w_line)='"')
       IF (substring(2,2,w_line)='""')
        dpos = findstring('""",',substring(2,line_len,w_line))
        IF (dpos=0)
         dpos = findstring('"""',substring(4,line_len,w_line)), d_element = substring(4,(dpos - 1),
          w_line), w_line = " "
        ELSE
         d_element = substring(4,(dpos - 3),w_line), w_line = substring((dpos+ 5),line_len,w_line)
        ENDIF
       ELSE
        dpos = findstring('",',substring(2,line_len,w_line))
        IF (dpos=0)
         dpos = findstring('"',substring(2,line_len,w_line)), d_element = substring(2,(dpos - 1),
          w_line), w_line = " "
        ELSE
         d_element = substring(2,(dpos - 1),w_line), w_line = substring((dpos+ 3),line_len,w_line)
        ENDIF
       ENDIF
      ELSE
       dpos = findstring(delim,w_line)
       IF (dpos=0)
        d_element = substring(1,line_len,w_line), w_line = " "
       ELSE
        d_element = substring(1,(dpos - 1),w_line), w_line = substring((dpos+ 1),line_len,w_line)
       ENDIF
      ENDIF
      data->qual[dknt].element = d_element, rec_info->qual[field_knt].assignment_line = concat(
       "set requestin->list_0[zidx].",trim(col_rec->qual[field_knt].col_name,3)," = d_element "),
      field_knt = (field_knt+ 1)
    ENDWHILE
   ENDIF
  FOOT REPORT
   data->qual_knt = dknt, stat = alterlist(data->qual,dknt)
  WITH nocounter
 ;end select
 FREE DEFINE rtl3
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR >> LOAD DATA ELEMENTS :: Select Error"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(serrmsg)
  GO TO msg_menu
 ENDIF
 SET stat = alterlist(requestin->list_0,10)
 SET rpt_knt = 1
 SET wknt = 1
 SET zidx = 1
 WHILE ((wknt <= data->qual_knt))
   IF ((rpt_knt > col_rec->qual_knt))
    SET rpt_knt = 1
    SET zidx = (zidx+ 1)
   ENDIF
   IF (mod(zidx,10)=1
    AND zidx != 1)
    SET stat = alterlist(requestin->list_0,(zidx+ 9))
   ENDIF
   SET d_element = " "
   SET d_element = data->qual[wknt].element
   IF (((d_element=" ") OR (d_element=null)) )
    SET d_element = ""
   ENDIF
   CALL parser(rec_info->qual[rpt_knt].assignment_line)
   CALL parser(" go")
   SET rpt_knt = (rpt_knt+ 1)
   SET wknt = (wknt+ 1)
 ENDWHILE
 SET stat = alterlist(requestin->list_0,zidx)
 SET stat = initrec(col_rec)
 SET stat = initrec(rec_info)
 SET stat = initrec(data)
 IF (size(requestin->list_0,5) < 1)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("FAILED :: No items found in file ",trim(
    working_file_name))
  GO TO msg_menu
 ENDIF
 SET stat = initrec(person_rec)
 SET person_rec->qual_knt = size(requestin->list_0,5)
 SET stat = alterlist(person_rec->qual,person_rec->qual_knt)
 FOR (fidx = 1 TO person_rec->qual_knt)
   IF (isnumeric(trim(requestin->list_0[fidx].person_id,3)) > 0)
    SET person_rec->qual[fidx].person_id = cnvtreal(trim(requestin->list_0[fidx].person_id,3))
   ELSE
    SET person_rec->qual[fidx].validated_ind = - (1)
   ENDIF
   IF (trim(requestin->list_0[fidx].name_last,3) > " ")
    SET person_rec->qual[fidx].name_last_key = cnvtupper(cnvtalphanum(trim(requestin->list_0[fidx].
       name_last,3)))
   ELSE
    SET person_rec->qual[fidx].validated_ind = - (1)
   ENDIF
   IF (trim(requestin->list_0[fidx].name_first,3) > " ")
    SET person_rec->qual[fidx].name_first_key = cnvtupper(cnvtalphanum(trim(requestin->list_0[fidx].
       name_first,3)))
   ELSE
    SET person_rec->qual[fidx].validated_ind = - (1)
   ENDIF
   IF (isnumeric(trim(requestin->list_0[fidx].birth_date,3))=1)
    SET person_rec->qual[fidx].birth_dt_tm = cnvtdate2(trim(requestin->list_0[fidx].birth_date,3),
     "YYYYMMDD")
   ELSE
    SET person_rec->qual[fidx].validated_ind = - (1)
   ENDIF
   IF (trim(requestin->list_0[fidx].ssn_alias,3) > " ")
    SET person_rec->qual[fidx].ssn_alias = trim(cnvtstring(cnvtint(trim(requestin->list_0[fidx].
        ssn_alias,3))))
   ELSE
    SET person_rec->qual[fidx].validated_ind = - (1)
   ENDIF
   IF (trim(requestin->list_0[fidx].sex_code,3)="M")
    SET person_rec->qual[fidx].sex_cd = male_cd
   ELSEIF (trim(requestin->list_0[fidx].sex_code,3)="F")
    SET person_rec->qual[fidx].sex_cd = female_cd
   ELSE
    SET person_rec->qual[fidx].validated_ind = - (1)
   ENDIF
 ENDFOR
 FREE RECORD requestin
 CALL echo("***")
 CALL echo("***   Check PERSON_ID > 0")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(person_rec->qual_knt)),
   person p,
   person_alias pa
  PLAN (d
   WHERE d.seq > 0
    AND (person_rec->qual[d.seq].person_id > 0)
    AND (person_rec->qual[d.seq].validated_ind >= 0))
   JOIN (p
   WHERE (p.person_id=person_rec->qual[d.seq].person_id)
    AND (p.name_last_key=person_rec->qual[d.seq].name_last_key)
    AND (p.name_first_key=person_rec->qual[d.seq].name_first_key)
    AND p.birth_dt_tm=cnvtdatetime(person_rec->qual[d.seq].birth_dt_tm)
    AND (p.sex_cd=person_rec->qual[d.seq].sex_cd))
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=ssn_alias_type_cd
    AND (pa.alias=person_rec->qual[d.seq].ssn_alias)
    AND pa.active_ind=1)
  HEAD d.seq
   person_rec->qual[d.seq].validated_ind = 1
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR >> VALIDATING PERSON_ID > 0 :: Select Error"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(serrmsg)
  GO TO msg_menu
 ENDIF
 CALL echo("***")
 CALL echo("***   Check PERSON_ID < 0")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(person_rec->qual_knt)),
   person p,
   person_alias pa
  PLAN (d
   WHERE d.seq > 0
    AND (person_rec->qual[d.seq].person_id < 1)
    AND (person_rec->qual[d.seq].validated_ind >= 0))
   JOIN (p
   WHERE (p.name_last_key=person_rec->qual[d.seq].name_last_key)
    AND (p.name_first_key=person_rec->qual[d.seq].name_first_key)
    AND p.birth_dt_tm=cnvtdatetime(person_rec->qual[d.seq].birth_dt_tm)
    AND (p.sex_cd=person_rec->qual[d.seq].sex_cd))
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=ssn_alias_type_cd
    AND (pa.alias=person_rec->qual[d.seq].ssn_alias)
    AND pa.active_ind=1)
  HEAD d.seq
   person_rec->qual[d.seq].validated_ind = 1, person_rec->qual[d.seq].person_id = p.person_id
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = "ERROR >> VALIDATING PERSON_ID < 0 :: Select Error"
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(serrmsg)
  GO TO msg_menu
 ENDIF
 IF (working_file_type="BENEFIT_LEVEL")
  IF (s_process_type="BACKOUT")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_BENEFIT_LEVEL_BACKOUT for person file"
   EXECUTE ags_benefit_level_backout value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_BENEFIT_LEVEL_BACKOUT :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_BENEFIT_LEVEL_BACKOUT :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSEIF (s_process_type="PURGE")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_BENEFIT_LEVEL_PURGE for person file"
   EXECUTE ags_benefit_level_purge value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_BENEFIT_LEVEL_PURGE :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_BENEFIT_LEVEL_PURGE :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(working_file_name)
  GO TO msg_menu
 ELSEIF (working_file_type="CLAIMDETAIL")
  IF (s_process_type="BACKOUT")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_CLAIM_DETAIL_BACKOUT for person file"
   EXECUTE ags_claim_detail_backout value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_CLAIM_DETAIL_BACKOUT :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_CLAIM_DETAIL_BACKOUT :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSEIF (s_process_type="PURGE")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_CLAIM_DETAIL_PURGE for person file"
   EXECUTE ags_claim_detail_purge value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_CLAIM_DETAIL_PURGE :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_CLAIM_DETAIL_PURGE :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(working_file_name)
  GO TO msg_menu
 ELSEIF (working_file_type="IMMUN")
  IF (s_process_type="BACKOUT")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_IMMUN_BACKOUT for person file"
   EXECUTE ags_immun_backout value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_IMMUN_BACKOUT :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_IMMUN_BACKOUT :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSEIF (s_process_type="PURGE")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_IMMUN_PURGE for person file"
   EXECUTE ags_immun_purge value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_IMMUN_PURGE :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_IMMUN_PURGE :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(working_file_name)
  GO TO msg_menu
 ELSEIF (working_file_type="MEDS")
  IF (s_process_type="BACKOUT")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_MEDS_BACKOUT for person file"
   EXECUTE ags_meds_backout value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_MEDS_BACKOUT :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_MEDS_BACKOUT :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSEIF (s_process_type="PURGE")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_MEDS_PURGE for person file"
   EXECUTE ags_meds_purge value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_MEDS_PURGE :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_MEDS_PURGE :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(working_file_name)
  GO TO msg_menu
 ELSEIF (working_file_type="RESULT")
  IF (s_process_type="BACKOUT")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_RESULT_BACKOUT for person file"
   EXECUTE ags_result_backout value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_RESULT_BACKOUT :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_RESULT_BACKOUT :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSEIF (s_process_type="PURGE")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_RESULT_PURGE for person file"
   EXECUTE ags_result_purge value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_RESULT_PURGE :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_RESULT_PURGE :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(working_file_name)
  GO TO msg_menu
 ELSEIF (working_file_type="CLAIM")
  IF (s_process_type="BACKOUT")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_CLAIM_BACKOUT for person file"
   EXECUTE ags_claim_backout value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_CLAIM_BACKOUT :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_CLAIM_BACKOUT :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSEIF (s_process_type="PURGE")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_CLAIM_PURGE for person file"
   EXECUTE ags_claim_purge value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_CLAIM_PURGE :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_CLAIM_PURGE :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(working_file_name)
  GO TO msg_menu
 ELSEIF (working_file_type="PLAN")
  IF (s_process_type="BACKOUT")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_PLAN_BACKOUT for person file"
   EXECUTE ags_plan_backout value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_PLAN_BACKOUT :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_PLAN_BACKOUT :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSEIF (s_process_type="PURGE")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Executed AGS_PLAN_PURGE for person file"
   EXECUTE ags_plan_purge value("P"), value(0.0)
   IF (failed != false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "FAILED :: AGS_PLAN_PURGE :: Person File"
   ELSE
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = "SUCCESS :: AGS_PLAN_PURGE :: Person File"
   ENDIF
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = concat("   Examine log file ",trim(s_log_name),
    " in the")
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "   cer_log directory for details"
  ELSE
   SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
   SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
   SET msg_rec->qual[msg_rec->qual_knt].line = "Unknown Process Type"
  ENDIF
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = trim(working_file_name)
  GO TO msg_menu
 ELSE
  SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
  SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
  SET msg_rec->qual[msg_rec->qual_knt].line = concat("INVALID WORKING_FILE_TYPE : ",trim(
    working_file_type))
  GO TO msg_menu
 ENDIF
 GO TO msg_menu
#msg_menu
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"AGS UTILITY PROGRAM")
 CALL box(5,5,21,76)
 CALL line(7,5,72,xhor)
 CALL text(6,7," Message Screen")
 IF ((msg_rec->qual_knt < 1))
  CALL text(8,6," Unknown Message")
 ELSE
  SET msg_line_nbr = 8
  SET msg_wknt = 1
  WHILE (msg_line_nbr <= 21
   AND (msg_wknt <= msg_rec->qual_knt))
    CALL text(msg_line_nbr,6,msg_rec->qual[msg_wknt].line)
    SET msg_line_nbr = (msg_line_nbr+ 1)
    SET msg_wknt = (msg_wknt+ 1)
  ENDWHILE
 ENDIF
 CALL text(23,2,"Enter <0> for Main Menu:  ")
 CALL accept(23,27,"9;H",0
  WHERE curaccept >= 0)
 SET stat = initrec(col_rec)
 SET stat = initrec(rec_info)
 SET stat = initrec(data)
 SET stat = initrec(person_rec)
 GO TO main_menu
 SUBROUTINE valid_job(temp_job_id,temp_file_type)
   DECLARE found_job = i2 WITH protect, noconstant(false)
   DECLARE job_run_nbr = i4 WITH protect, noconstant(0)
   DECLARE found_higher_job = i2 WITH protect, noconstant(false)
   SET found_job = false
   SET job_run_nbr = 0
   SET found_higher_job = false
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM ags_job j
    PLAN (j
     WHERE j.ags_job_id=temp_job_id
      AND j.file_type=temp_file_type)
    DETAIL
     found_job = true, job_run_nbr = j.run_nbr
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("SCRIPT ERROR :: Validating AGS_JOB_ID (",trim
     (cnvtstring(working_job_id)),") for FILE_TYPE (",trim(working_file_type),")")
    RETURN(false)
   ENDIF
   IF (found_job=false)
    SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
    SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
    SET msg_rec->qual[msg_rec->qual_knt].line = concat("SEARCH ERROR :: Validating AGS_JOB_ID (",trim
     (cnvtstring(working_job_id)),") for FILE_TYPE (",trim(working_file_type),")")
    RETURN(false)
   ELSE
    SET ierrcode = error(serrmsg,1)
    SET ierrcode = 0
    SELECT INTO "nl:"
     FROM ags_job j
     PLAN (j
      WHERE j.file_type=temp_file_type
       AND j.run_nbr > job_run_nbr
       AND j.status != "PURGED")
     DETAIL
      found_higher_job = true,
      CALL echo("***"),
      CALL echo(build("***   ags_job_id :",j.ags_job_id)),
      CALL echo("***")
     WITH nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat(
      "SCRIPT ERROR :: Validating Most Current AGS_JOB_ID (",trim(cnvtstring(working_job_id)),
      ") for FILE_TYPE (",trim(working_file_type),")")
     RETURN(false)
    ENDIF
    IF (found_higher_job=true)
     SET msg_rec->qual_knt = (msg_rec->qual_knt+ 1)
     SET stat = alterlist(msg_rec->qual,msg_rec->qual_knt)
     SET msg_rec->qual[msg_rec->qual_knt].line = concat("NOT MOST CURRENT :: Validating AGS_JOB_ID (",
      trim(cnvtstring(working_job_id)),") for FILE_TYPE (",trim(working_file_type),")")
     RETURN(false)
    ELSE
     RETURN(true)
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 CALL clear(1,1)
 SET script_ver = "005 12/06/06"
END GO
