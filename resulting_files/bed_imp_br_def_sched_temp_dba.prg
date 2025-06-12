CREATE PROGRAM bed_imp_br_def_sched_temp:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 DECLARE br_sch_template_id = f8
 DECLARE br_sch_temp_slot_r_id = f8
 DECLARE skip_template = i2
 DECLARE t = i2
 DECLARE numeric_check = i4
 DECLARE time_size = i4
 DECLARE numeric_logical_domain_id = f8
 SET numeric_logical_domain_id = 0
 DECLARE week_ind = i2
 DECLARE month1_ind = i2
 DECLARE month2_ind = i2
 DECLARE year1_ind = i2
 DECLARE year2_ind = i2
 SET data_partition_ind = 0
 RANGE OF s IS sch_resource
 SET data_partition_ind = validate(s.logical_domain_id)
 FREE RANGE s
 SET lstat = 0.0
 DECLARE log_msg = vc
 DECLARE logfilename = vc
 SET logfilename = build2("defsched_imp_",format(curdate,"MMDDYYYY;;D"),format(curtime,"HHMM;;M"))
 SELECT INTO value(logfilename)
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Bedrock Default Schedule Templates Import Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SET log_msg =
 "Templates that were successfully imported but contain errors can be reviewed and corrected"
 SET lstat = log_message(t)
 SET log_msg =
 "in the Default Schedule Templates wizard. Templates that were not imported must be corrected"
 SET lstat = log_message(t)
 SET log_msg = "on the spreadsheet and then imported again."
 SET lstat = log_message(t)
 SET log_msg = " "
 SET lstat = log_message(t)
 SET nbr_rows = size(requestin->list_0,5)
 FOR (x = 1 TO nbr_rows)
  IF ((requestin->list_0[x].template_name IN (" ", null))
   AND (((requestin->list_0[x].day_begin > " ")) OR ((requestin->list_0[x].day_end > " "))) )
   SET skip_template = 0
   IF (x=1)
    SET log_msg = "Error: First Template Name missing."
    SET lstat = log_message(t)
    GO TO exit_script
   ELSE
    SET log_msg = "Template:    was not imported."
    SET lstat = log_message(t)
    SET log_msg = "Error: Missing Template Name."
    SET lstat = log_message(t)
    SET skip_template = 1
   ENDIF
  ELSEIF ((requestin->list_0[x].template_name > " "))
   SET skip_template = 0
   SET name_size_error = 0
   SET logical_domain_error = 0
   SET slot_type_error = 0
   SET app_pattern_error = 0
   SET name_size = 0
   SET name_size = size(requestin->list_0[x].template_name,1)
   IF (name_size > 100)
    SET name_size_error = 1
    SET skip_template = 1
   ENDIF
   IF (data_partition_ind=1)
    IF ((requestin->list_0[x].logical_domain_id > " "))
     SET numeric_check = isnumeric(requestin->list_0[x].logical_domain_id)
     IF (numeric_check=0)
      SET logical_domain_error = 1
      SET skip_template = 1
     ENDIF
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].slot_type IN (" ", null)))
    SET slot_type_error = 1
    SET skip_template = 1
   ENDIF
   SET week_ind = 0
   SET month1_ind = 0
   SET month2_ind = 0
   SET year1_ind = 0
   SET year2_ind = 0
   IF ((((requestin->list_0[x].week_option_nbr_of_weeks > " ")) OR ((requestin->list_0[x].
   week_option_days_of_week > " "))) )
    SET week_ind = 1
   ENDIF
   IF ((((requestin->list_0[x].month_option1_dates_of_month > " ")) OR ((requestin->list_0[x].
   month_option1_nbr_of_months > " "))) )
    SET month1_ind = 1
   ENDIF
   IF ((((requestin->list_0[x].month_option2_weeks_of_month > " ")) OR ((((requestin->list_0[x].
   month_option2_days_of_week > " ")) OR ((requestin->list_0[x].month_option2_nbr_of_months > " ")))
   )) )
    SET month2_ind = 1
   ENDIF
   IF ((((requestin->list_0[x].year_option1_months_of_year > " ")) OR ((requestin->list_0[x].
   year_option1_dates_of_month > " "))) )
    SET year1_ind = 1
   ENDIF
   IF ((((requestin->list_0[x].year_option2_weeks_of_month > " ")) OR ((((requestin->list_0[x].
   year_option2_days_of_week > " ")) OR ((requestin->list_0[x].year_option2_months_of_year > " ")))
   )) )
    SET year2_ind = 1
   ENDIF
   IF (((week_ind=1
    AND ((month1_ind=1) OR (((month2_ind=1) OR (((year1_ind=1) OR (year2_ind=1)) )) )) ) OR (((
   month1_ind=1
    AND ((week_ind=1) OR (((month2_ind=1) OR (((year1_ind=1) OR (year2_ind=1)) )) )) ) OR (((
   month2_ind=1
    AND ((week_ind=1) OR (((month1_ind=1) OR (((year1_ind=1) OR (year2_ind=1)) )) )) ) OR (((
   year1_ind=1
    AND ((week_ind=1) OR (((month1_ind=1) OR (((month2_ind=1) OR (year2_ind=1)) )) )) ) OR (year2_ind
   =1
    AND ((week_ind=1) OR (((month1_ind=1) OR (((month2_ind=1) OR (year1_ind=1)) )) )) )) )) )) )) )
    SET app_pattern_error = 1
    SET skip_template = 1
   ENDIF
   IF (skip_template=0)
    SET log_msg = concat("Template: ",trim(requestin->list_0[x].template_name),
     " was successfully imported.")
    SET lstat = log_message(t)
    SET stat = new_template(x)
   ELSE
    IF (name_size_error=1)
     SET log_msg = concat("Template: ",substring(1,50,requestin->list_0[x].template_name),
      " was not imported.")
    ELSE
     SET log_msg = concat("Template: ",trim(requestin->list_0[x].template_name)," was not imported.")
    ENDIF
    SET lstat = log_message(t)
    IF (name_size_error=1)
     SET log_msg = "Error: Template Name exceeds 100 characters."
     SET lstat = log_message(t)
    ENDIF
    IF (logical_domain_error=1)
     SET log_msg = "Error: Logical Domain ID is not numeric."
     SET lstat = log_message(t)
    ENDIF
    IF (slot_type_error=1)
     SET log_msg = "Error: Missing Slot Type."
     SET lstat = log_message(t)
    ENDIF
    IF (app_pattern_error=1)
     SET log_msg = "Error: Multiple Application Patterns defined."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
  ENDIF
  IF (skip_template=0)
   IF ((requestin->list_0[x].default_resource > " "))
    SET stat = new_resource(x)
   ENDIF
   IF ((requestin->list_0[x].slot_type > " "))
    SET stat = new_slot(x)
   ELSE
    IF ((requestin->list_0[x].slot_release_to > " "))
     SET stat = new_release(x)
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE new_template(t)
   SET numeric_logical_domain_id = 0.0
   IF (data_partition_ind=1)
    IF ((requestin->list_0[x].logical_domain_id > " "))
     SET numeric_logical_domain_id = cnvtreal(requestin->list_0[x].logical_domain_id)
    ENDIF
   ENDIF
   SET save_uk_format = " "
   IF ((requestin->list_0[x].uk_format > " "))
    IF ((requestin->list_0[x].uk_format IN ("YES", "Yes", "yes")))
     SET save_uk_format = "Y"
    ELSEIF ((requestin->list_0[x].uk_format IN ("NO", "No", "no")))
     SET save_uk_format = "N"
    ELSE
     SET log_msg = "Error: Invalid UK Date Format."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].day_begin > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].day_begin)
    IF (numeric_check=0)
     SET log_msg = "Error: Invalid Day Begin Time."
     SET lstat = log_message(t)
    ELSE
     SET time_size = 0
     SET time_size = size(requestin->list_0[x].day_begin,1)
     IF (time_size != 4)
      SET log_msg = "Error: Invalid Day Begin Time."
      SET lstat = log_message(t)
     ENDIF
    ENDIF
   ELSE
    SET log_msg = "Error: Missing Day Begin Time."
    SET lstat = log_message(t)
   ENDIF
   IF ((requestin->list_0[x].day_end > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].day_end)
    IF (numeric_check=0)
     SET log_msg = "Error: Invalid Day End Time."
     SET lstat = log_message(t)
    ELSE
     SET time_size = 0
     SET time_size = size(requestin->list_0[x].day_end,1)
     IF (time_size != 4)
      SET log_msg = "Error: Invalid Day End Time."
      SET lstat = log_message(t)
     ENDIF
    ENDIF
   ELSE
    SET log_msg = "Error: Missing Day End Time."
    SET lstat = log_message(t)
   ENDIF
   IF ((requestin->list_0[x].apply_end_date > " ")
    AND (requestin->list_0[x].apply_occurrences > " "))
    SET log_msg = "Error: Both Application End Date and Application Occurrences are completed."
    SET lstat = log_message(t)
   ENDIF
   IF ((requestin->list_0[x].apply_begin_date IN (" ", null))
    AND (((requestin->list_0[x].apply_end_date > " ")) OR ((requestin->list_0[x].apply_occurrences >
   " "))) )
    SET log_msg = "Error: Missing Application Begin Date."
    SET lstat = log_message(t)
   ENDIF
   IF (((week_ind=1) OR (((month1_ind=1) OR (((month2_ind=1) OR (((year1_ind=1) OR (year2_ind=1)) ))
   )) ))
    AND (requestin->list_0[x].apply_begin_date IN (" ", null))
    AND (requestin->list_0[x].apply_end_date IN (" ", null))
    AND (requestin->list_0[x].apply_occurrences IN (" ", null)))
    SET log_msg = "Error: Missing Application Range."
    SET lstat = log_message(t)
   ENDIF
   IF (week_ind=0
    AND month1_ind=0
    AND month2_ind=0
    AND year1_ind=0
    AND year2_ind=0
    AND (((requestin->list_0[x].apply_begin_date > " ")) OR ((((requestin->list_0[x].apply_end_date
    > " ")) OR ((requestin->list_0[x].apply_occurrences > " "))) )) )
    SET log_msg = "Error: Missing Application Pattern."
    SET lstat = log_message(t)
   ENDIF
   SET apply_beg_date_numeric = 0
   IF ((requestin->list_0[x].apply_begin_date > " "))
    SET date_format_bad = 0
    SET date_size = 0
    SET date_size = size(requestin->list_0[x].apply_begin_date,1)
    IF (date_size != 10)
     SET date_format_bad = 1
    ELSE
     IF (((substring(3,1,requestin->list_0[x].apply_begin_date) != "/") OR (substring(6,1,requestin->
      list_0[x].apply_begin_date) != "/")) )
      SET date_format_bad = 1
     ELSE
      SET numeric_check = 0
      IF (save_uk_format="N")
       SET numeric_check = isnumeric(substring(1,2,requestin->list_0[x].apply_begin_date))
      ELSEIF (save_uk_format="Y")
       SET numeric_check = isnumeric(substring(4,2,requestin->list_0[x].apply_begin_date))
      ENDIF
      IF (numeric_check > 0)
       IF (((save_uk_format="N"
        AND cnvtint(substring(1,2,requestin->list_0[x].apply_begin_date)) > 12) OR (save_uk_format=
       "Y"
        AND cnvtint(substring(4,2,requestin->list_0[x].apply_begin_date)) > 12)) )
        SET date_format_bad = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (date_format_bad=1)
     SET log_msg = "Error: Invalid Application Begin Date."
     SET lstat = log_message(t)
    ELSE
     IF (save_uk_format="N")
      SET apply_beg_date_numeric = cnvtdate2(trim(requestin->list_0[x].apply_begin_date),"MM/DD/YYYY"
       )
     ELSEIF (save_uk_format="Y")
      SET apply_beg_date_numeric = cnvtdate2(trim(requestin->list_0[x].apply_begin_date),"DD/MM/YYYY"
       )
     ENDIF
    ENDIF
   ENDIF
   SET apply_end_date_numeric = 0
   IF ((requestin->list_0[x].apply_end_date > " "))
    SET date_format_bad = 0
    SET date_size = 0
    SET date_size = size(requestin->list_0[x].apply_end_date,1)
    IF (date_size != 10)
     SET date_format_bad = 1
    ELSE
     IF (((substring(3,1,requestin->list_0[x].apply_end_date) != "/") OR (substring(6,1,requestin->
      list_0[x].apply_end_date) != "/")) )
      SET date_format_bad = 1
     ELSE
      SET numeric_check = 0
      IF (save_uk_format="N")
       SET numeric_check = isnumeric(substring(1,2,requestin->list_0[x].apply_end_date))
      ELSEIF (save_uk_format="Y")
       SET numeric_check = isnumeric(substring(4,2,requestin->list_0[x].apply_end_date))
      ENDIF
      IF (numeric_check > 0)
       IF (((save_uk_format="N"
        AND cnvtint(substring(1,2,requestin->list_0[x].apply_end_date)) > 12) OR (save_uk_format="Y"
        AND cnvtint(substring(4,2,requestin->list_0[x].apply_end_date)) > 12)) )
        SET date_format_bad = 1
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (date_format_bad=1)
     SET log_msg = "Error: Invalid Application End Date."
     SET lstat = log_message(t)
    ELSE
     IF (save_uk_format="N")
      SET apply_end_date_numeric = cnvtdate2(trim(requestin->list_0[x].apply_end_date),"MM/DD/YYYY")
     ELSEIF (save_uk_format="Y")
      SET apply_end_date_numeric = cnvtdate2(trim(requestin->list_0[x].apply_end_date),"DD/MM/YYYY")
     ENDIF
    ENDIF
   ENDIF
   IF (apply_beg_date_numeric > apply_end_date_numeric)
    SET log_msg = "Error: Application Begin Date is greater than Application End Date."
    SET lstat = log_message(t)
   ENDIF
   IF ((requestin->list_0[x].apply_occurrences > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].apply_occurrences)
    IF (numeric_check=0)
     SET log_msg = "Error: Invalid Application Occurrences."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].apply_range > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].apply_range)
    IF (numeric_check=0)
     SET log_msg = "Error: Invalid Application Range."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].week_option_nbr_of_weeks > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].week_option_nbr_of_weeks)
    IF (numeric_check=0)
     SET log_msg = "Error: Invalid Weekly Option Number of Weeks."
     SET lstat = log_message(t)
    ELSE
     SET numeric_check = cnvtint(requestin->list_0[x].week_option_nbr_of_weeks)
     IF (((numeric_check < 1) OR (numeric_check > 99)) )
      SET log_msg = "Error: Invalid Weekly Option Number of Weeks."
      SET lstat = log_message(t)
     ENDIF
    ENDIF
   ELSE
    IF ((requestin->list_0[x].week_option_days_of_week > " "))
     SET log_msg = "Error: Missing Weekly Option Number of Weeks."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].week_option_days_of_week > " "))
    SET scnt = size(requestin->list_0[x].week_option_days_of_week,1)
    SET error_found = 0
    SET m_found = 0
    SET t_found = 0
    SET w_found = 0
    SET h_found = 0
    SET f_found = 0
    SET s_found = 0
    SET u_found = 0
    FOR (s = 1 TO scnt)
      IF (substring(s,1,cnvtupper(requestin->list_0[x].week_option_days_of_week)) IN ("M", "T", "W",
      "H", "F",
      "S", "U"))
       IF (substring(s,1,cnvtupper(requestin->list_0[x].week_option_days_of_week))="M")
        IF (m_found=0)
         SET m_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].week_option_days_of_week))="T")
        IF (t_found=0)
         SET t_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].week_option_days_of_week))="W")
        IF (w_found=0)
         SET w_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].week_option_days_of_week))="H")
        IF (h_found=0)
         SET h_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].week_option_days_of_week))="F")
        IF (f_found=0)
         SET f_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].week_option_days_of_week))="S")
        IF (s_found=0)
         SET s_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].week_option_days_of_week))="U")
        IF (u_found=0)
         SET u_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ENDIF
      ELSE
       SET error_found = 1
      ENDIF
    ENDFOR
    IF (error_found=1)
     SET log_msg = "Error: Invalid Weekly Option Days of Week."
     SET lstat = log_message(t)
    ENDIF
   ELSE
    IF ((requestin->list_0[x].week_option_nbr_of_weeks > " "))
     SET log_msg = "Error: Missing Weekly Option Days of Week."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].month_option1_dates_of_month > " "))
    SET scnt = size(requestin->list_0[x].month_option1_dates_of_month,1)
    SET error_found = 0
    SET 1_found = 0
    SET 2_found = 0
    SET 3_found = 0
    SET 4_found = 0
    SET 5_found = 0
    SET 6_found = 0
    SET 7_found = 0
    SET 8_found = 0
    SET 9_found = 0
    SET 10_found = 0
    SET 11_found = 0
    SET 12_found = 0
    SET 13_found = 0
    SET 14_found = 0
    SET 15_found = 0
    SET 16_found = 0
    SET 17_found = 0
    SET 18_found = 0
    SET 19_found = 0
    SET 20_found = 0
    SET 21_found = 0
    SET 22_found = 0
    SET 23_found = 0
    SET 24_found = 0
    SET 25_found = 0
    SET 26_found = 0
    SET 27_found = 0
    SET 28_found = 0
    SET 29_found = 0
    SET 30_found = 0
    SET 31_found = 0
    SET end_loop = 0
    FOR (s = 1 TO scnt)
      SET comma_psn = 0
      SET comma_psn = findstring(",",requestin->list_0[x].month_option1_dates_of_month,s)
      IF (comma_psn=0)
       SET comma_psn = (scnt+ 1)
       SET end_loop = 1
      ENDIF
      IF (comma_psn > 0)
       SET string_len = (comma_psn - s)
       SET date_string = substring(s,string_len,requestin->list_0[x].month_option1_dates_of_month)
       SET numeric_check = 0
       SET numeric_check = isnumeric(date_string)
       IF (numeric_check=0)
        SET log_msg = "Error: Invalid Monthly Option 1 Dates of Month."
        SET lstat = log_message(t)
        SET s = (scnt+ 1)
       ELSE
        SET numeric_check = cnvtint(date_string)
        IF (((numeric_check < 1) OR (numeric_check > 31)) )
         SET log_msg = "Error: Invalid Monthly Option 1 Dates of Month."
         SET lstat = log_message(t)
         SET s = (scnt+ 1)
        ELSE
         IF (numeric_check=1)
          IF (1_found=0)
           SET 1_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=2)
          IF (2_found=0)
           SET 2_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=3)
          IF (3_found=0)
           SET 3_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=4)
          IF (4_found=0)
           SET 4_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=5)
          IF (5_found=0)
           SET 5_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=6)
          IF (6_found=0)
           SET 6_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=7)
          IF (7_found=0)
           SET 7_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=8)
          IF (8_found=0)
           SET 8_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=9)
          IF (9_found=0)
           SET 9_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=10)
          IF (10_found=0)
           SET 10_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=11)
          IF (11_found=0)
           SET 11_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=12)
          IF (12_found=0)
           SET 12_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=13)
          IF (13_found=0)
           SET 13_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=14)
          IF (14_found=0)
           SET 14_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=15)
          IF (15_found=0)
           SET 15_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=16)
          IF (16_found=0)
           SET 16_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=17)
          IF (17_found=0)
           SET 17_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=18)
          IF (18_found=0)
           SET 18_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=19)
          IF (19_found=0)
           SET 19_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=20)
          IF (20_found=0)
           SET 20_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=21)
          IF (21_found=0)
           SET 21_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=22)
          IF (22_found=0)
           SET 22_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=23)
          IF (23_found=0)
           SET 23_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=24)
          IF (24_found=0)
           SET 24_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=25)
          IF (25_found=0)
           SET 25_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=26)
          IF (26_found=0)
           SET 26_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=27)
          IF (27_found=0)
           SET 27_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=28)
          IF (28_found=0)
           SET 28_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=29)
          IF (29_found=0)
           SET 29_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=30)
          IF (30_found=0)
           SET 30_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=31)
          IF (31_found=0)
           SET 31_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ENDIF
         IF (error_found=1)
          SET log_msg = "Error: Invalid Monthly Option 1 Dates of Month."
          SET lstat = log_message(t)
          SET s = (scnt+ 1)
         ELSE
          IF (end_loop=1)
           SET s = (scnt+ 1)
          ELSE
           SET s = comma_psn
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    IF ((requestin->list_0[x].month_option1_nbr_of_months > " "))
     SET log_msg = "Error: Missing Monthly Option 1 Dates of Month."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].month_option1_nbr_of_months > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].month_option1_nbr_of_months)
    IF (numeric_check=0)
     SET log_msg = "Error: Invalid Monthly Option 1 Number of Months."
     SET lstat = log_message(t)
    ELSE
     SET numeric_check = cnvtint(requestin->list_0[x].month_option1_nbr_of_months)
     IF (((numeric_check < 1) OR (numeric_check > 99)) )
      SET log_msg = "Error: Invalid Monthly Option 1 Number of Months."
      SET lstat = log_message(t)
     ENDIF
    ENDIF
   ELSE
    IF ((requestin->list_0[x].month_option1_dates_of_month > " "))
     SET log_msg = "Error: Missing Monthly Option 1 Number of Months."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].month_option2_weeks_of_month > " "))
    SET scnt = size(requestin->list_0[x].month_option2_weeks_of_month,1)
    SET error_found = 0
    SET 1_found = 0
    SET 2_found = 0
    SET 3_found = 0
    SET 4_found = 0
    SET 5_found = 0
    SET l_found = 0
    FOR (s = 1 TO scnt)
      IF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_weeks_of_month)) IN ("1", "2",
      "3", "4", "5",
      "L"))
       IF (substring(s,1,requestin->list_0[x].month_option2_weeks_of_month)="1")
        IF (1_found=0)
         SET 1_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,requestin->list_0[x].month_option2_weeks_of_month)="2")
        IF (2_found=0)
         SET 2_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,requestin->list_0[x].month_option2_weeks_of_month)="3")
        IF (3_found=0)
         SET 3_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,requestin->list_0[x].month_option2_weeks_of_month)="4")
        IF (4_found=0)
         SET 4_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,requestin->list_0[x].month_option2_weeks_of_month)="5")
        IF (5_found=0)
         SET 5_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_weeks_of_month))="L")
        IF (l_found=0)
         SET l_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ENDIF
      ELSE
       SET error_found = 1
      ENDIF
    ENDFOR
    IF (error_found=1)
     SET log_msg = "Error: Invalid Monthly Option 2 Weeks of Month."
     SET lstat = log_message(t)
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].month_option2_days_of_week > " ")) OR ((requestin->list_0[x].
    month_option2_nbr_of_months > " "))) )
     SET log_msg = "Error: Missing Monthly Option 2 Weeks of Month."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].month_option2_days_of_week > " "))
    SET scnt = size(requestin->list_0[x].month_option2_days_of_week,1)
    SET error_found = 0
    SET m_found = 0
    SET t_found = 0
    SET w_found = 0
    SET h_found = 0
    SET f_found = 0
    SET s_found = 0
    SET u_found = 0
    FOR (s = 1 TO scnt)
      IF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_days_of_week)) IN ("M", "T", "W",
      "H", "F",
      "S", "U"))
       IF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_days_of_week))="M")
        IF (m_found=0)
         SET m_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_days_of_week))="T")
        IF (t_found=0)
         SET t_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_days_of_week))="W")
        IF (w_found=0)
         SET w_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_days_of_week))="H")
        IF (h_found=0)
         SET h_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_days_of_week))="F")
        IF (f_found=0)
         SET f_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_days_of_week))="S")
        IF (s_found=0)
         SET s_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].month_option2_days_of_week))="U")
        IF (u_found=0)
         SET u_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ENDIF
      ELSE
       SET error_found = 1
      ENDIF
    ENDFOR
    IF (error_found=1)
     SET log_msg = "Error: Invalid Monthly Option 2 Days of Week."
     SET lstat = log_message(t)
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].month_option2_weeks_of_month > " ")) OR ((requestin->list_0[x].
    month_option2_nbr_of_months > " "))) )
     SET log_msg = "Error: Missing Monthly Option 2 Days of Week."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].month_option2_nbr_of_months > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].month_option2_nbr_of_months)
    IF (numeric_check=0)
     SET log_msg = "Error: Invalid Monthly Option 2 Number of Months."
     SET lstat = log_message(t)
    ELSE
     SET numeric_check = cnvtint(requestin->list_0[x].month_option2_nbr_of_months)
     IF (((numeric_check < 1) OR (numeric_check > 99)) )
      SET log_msg = "Error: Invalid Monthly Option 2 Number of Months."
      SET lstat = log_message(t)
     ENDIF
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].month_option2_weeks_of_month > " ")) OR ((requestin->list_0[x].
    month_option2_days_of_week > " "))) )
     SET log_msg = "Error: Missing Monthly Option 2 Number of Months."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].year_option1_months_of_year > " "))
    SET scnt = size(requestin->list_0[x].year_option1_months_of_year,1)
    SET error_found = 0
    SET 1_found = 0
    SET 2_found = 0
    SET 3_found = 0
    SET 4_found = 0
    SET 5_found = 0
    SET 6_found = 0
    SET 7_found = 0
    SET 8_found = 0
    SET 9_found = 0
    SET 10_found = 0
    SET 11_found = 0
    SET 12_found = 0
    SET end_loop = 0
    FOR (s = 1 TO scnt)
      SET comma_psn = 0
      SET comma_psn = findstring(",",requestin->list_0[x].year_option1_months_of_year,s)
      IF (comma_psn=0)
       SET comma_psn = (scnt+ 1)
       SET end_loop = 1
      ENDIF
      IF (comma_psn > 0)
       SET string_len = (comma_psn - s)
       SET date_string = substring(s,string_len,requestin->list_0[x].year_option1_months_of_year)
       SET numeric_check = 0
       SET numeric_check = isnumeric(date_string)
       IF (numeric_check=0)
        SET log_msg = "Error: Invalid Yearly Option 1 Months of Year."
        SET lstat = log_message(t)
        SET s = (scnt+ 1)
       ELSE
        SET numeric_check = cnvtint(date_string)
        IF (((numeric_check < 1) OR (numeric_check > 12)) )
         SET log_msg = "Error: Invalid Yearly Option 1 Months of Year."
         SET lstat = log_message(t)
         SET s = (scnt+ 1)
        ELSE
         IF (numeric_check=1)
          IF (1_found=0)
           SET 1_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=2)
          IF (2_found=0)
           SET 2_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=3)
          IF (3_found=0)
           SET 3_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=4)
          IF (4_found=0)
           SET 4_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=5)
          IF (5_found=0)
           SET 5_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=6)
          IF (6_found=0)
           SET 6_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=7)
          IF (7_found=0)
           SET 7_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=8)
          IF (8_found=0)
           SET 8_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=9)
          IF (9_found=0)
           SET 9_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=10)
          IF (10_found=0)
           SET 10_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=11)
          IF (11_found=0)
           SET 11_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=12)
          IF (12_found=0)
           SET 12_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ENDIF
         IF (error_found=1)
          SET log_msg = "Error: Invalid Yearly Option 2 Months of Year."
          SET lstat = log_message(t)
          SET s = (scnt+ 1)
         ELSE
          IF (end_loop=1)
           SET s = (scnt+ 1)
          ELSE
           SET s = comma_psn
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    IF ((requestin->list_0[x].year_option1_dates_of_month > " "))
     SET log_msg = "Error: Missing Yearly Option 1 Months of Year."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].year_option1_dates_of_month > " "))
    SET scnt = size(requestin->list_0[x].year_option1_dates_of_month,1)
    SET error_found = 0
    SET 1_found = 0
    SET 2_found = 0
    SET 3_found = 0
    SET 4_found = 0
    SET 5_found = 0
    SET 6_found = 0
    SET 7_found = 0
    SET 8_found = 0
    SET 9_found = 0
    SET 10_found = 0
    SET 11_found = 0
    SET 12_found = 0
    SET 13_found = 0
    SET 14_found = 0
    SET 15_found = 0
    SET 16_found = 0
    SET 17_found = 0
    SET 18_found = 0
    SET 19_found = 0
    SET 20_found = 0
    SET 21_found = 0
    SET 22_found = 0
    SET 23_found = 0
    SET 24_found = 0
    SET 25_found = 0
    SET 26_found = 0
    SET 27_found = 0
    SET 28_found = 0
    SET 29_found = 0
    SET 30_found = 0
    SET 31_found = 0
    SET end_loop = 0
    FOR (s = 1 TO scnt)
      SET comma_psn = 0
      SET comma_psn = findstring(",",requestin->list_0[x].year_option1_dates_of_month,s)
      IF (comma_psn=0)
       SET comma_psn = (scnt+ 1)
       SET end_loop = 1
      ENDIF
      IF (comma_psn > 0)
       SET string_len = (comma_psn - s)
       SET date_string = substring(s,string_len,requestin->list_0[x].year_option1_dates_of_month)
       SET numeric_check = 0
       SET numeric_check = isnumeric(date_string)
       IF (numeric_check=0)
        SET log_msg = "Error: Invalid Yearly Option 1 Dates of Month."
        SET lstat = log_message(t)
        SET s = (scnt+ 1)
       ELSE
        SET numeric_check = cnvtint(date_string)
        IF (((numeric_check < 1) OR (numeric_check > 31)) )
         SET log_msg = "Error: Invalid Yearly Option 1 Dates of Month."
         SET lstat = log_message(t)
         SET s = (scnt+ 1)
        ELSE
         IF (numeric_check=1)
          IF (1_found=0)
           SET 1_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=2)
          IF (2_found=0)
           SET 2_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=3)
          IF (3_found=0)
           SET 3_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=4)
          IF (4_found=0)
           SET 4_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=5)
          IF (5_found=0)
           SET 5_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=6)
          IF (6_found=0)
           SET 6_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=7)
          IF (7_found=0)
           SET 7_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=8)
          IF (8_found=0)
           SET 8_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=9)
          IF (9_found=0)
           SET 9_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=10)
          IF (10_found=0)
           SET 10_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=11)
          IF (11_found=0)
           SET 11_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=12)
          IF (12_found=0)
           SET 12_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=13)
          IF (13_found=0)
           SET 13_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=14)
          IF (14_found=0)
           SET 14_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=15)
          IF (15_found=0)
           SET 15_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=16)
          IF (16_found=0)
           SET 16_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=17)
          IF (17_found=0)
           SET 17_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=18)
          IF (18_found=0)
           SET 18_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=19)
          IF (19_found=0)
           SET 19_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=20)
          IF (20_found=0)
           SET 20_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=21)
          IF (21_found=0)
           SET 21_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=22)
          IF (22_found=0)
           SET 22_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=23)
          IF (23_found=0)
           SET 23_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=24)
          IF (24_found=0)
           SET 24_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=25)
          IF (25_found=0)
           SET 25_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=26)
          IF (26_found=0)
           SET 26_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=27)
          IF (27_found=0)
           SET 27_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=28)
          IF (28_found=0)
           SET 28_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=29)
          IF (29_found=0)
           SET 29_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=30)
          IF (30_found=0)
           SET 30_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=31)
          IF (31_found=0)
           SET 31_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ENDIF
         IF (error_found=1)
          SET log_msg = "Error: Invalid Yearly Option 1 Dates of Month."
          SET lstat = log_message(t)
          SET s = (scnt+ 1)
         ELSE
          IF (end_loop=1)
           SET s = (scnt+ 1)
          ELSE
           SET s = comma_psn
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    IF ((requestin->list_0[x].year_option1_months_of_year > " "))
     SET log_msg = "Error: Missing Yearly Option 1 Dates of Month."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].year_option2_weeks_of_month > " "))
    SET scnt = size(requestin->list_0[x].year_option2_weeks_of_month,1)
    SET error_found = 0
    SET 1_found = 0
    SET 2_found = 0
    SET 3_found = 0
    SET 4_found = 0
    SET 5_found = 0
    SET l_found = 0
    FOR (s = 1 TO scnt)
      IF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_weeks_of_month)) IN ("1", "2",
      "3", "4", "5",
      "L"))
       IF (substring(s,1,requestin->list_0[x].year_option2_weeks_of_month)="1")
        IF (1_found=0)
         SET 1_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,requestin->list_0[x].year_option2_weeks_of_month)="2")
        IF (2_found=0)
         SET 2_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,requestin->list_0[x].year_option2_weeks_of_month)="3")
        IF (3_found=0)
         SET 3_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,requestin->list_0[x].year_option2_weeks_of_month)="4")
        IF (4_found=0)
         SET 4_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,requestin->list_0[x].year_option2_weeks_of_month)="5")
        IF (5_found=0)
         SET 5_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_weeks_of_month))="L")
        IF (l_found=0)
         SET l_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ENDIF
      ELSE
       SET error_found = 1
      ENDIF
    ENDFOR
    IF (error_found=1)
     SET log_msg = "Error: Invalid Yearly Option 2 Weeks of Month."
     SET lstat = log_message(t)
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].year_option2_days_of_week > " ")) OR ((requestin->list_0[x].
    year_option2_months_of_year > " "))) )
     SET log_msg = "Error: Missing Yearly Option 2 Weeks of Month."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].year_option2_days_of_week > " "))
    SET scnt = size(requestin->list_0[x].year_option2_days_of_week,1)
    SET error_found = 0
    SET m_found = 0
    SET t_found = 0
    SET w_found = 0
    SET h_found = 0
    SET f_found = 0
    SET s_found = 0
    SET u_found = 0
    FOR (s = 1 TO scnt)
      IF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_days_of_week)) IN ("M", "T", "W",
      "H", "F",
      "S", "U"))
       IF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_days_of_week))="M")
        IF (m_found=0)
         SET m_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_days_of_week))="T")
        IF (t_found=0)
         SET t_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_days_of_week))="W")
        IF (w_found=0)
         SET w_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_days_of_week))="H")
        IF (h_found=0)
         SET h_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_days_of_week))="F")
        IF (f_found=0)
         SET f_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_days_of_week))="S")
        IF (s_found=0)
         SET s_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ELSEIF (substring(s,1,cnvtupper(requestin->list_0[x].year_option2_days_of_week))="U")
        IF (u_found=0)
         SET u_found = 1
        ELSE
         SET error_found = 1
        ENDIF
       ENDIF
      ELSE
       SET error_found = 1
      ENDIF
    ENDFOR
    IF (error_found=1)
     SET log_msg = "Error: Invalid Yearly Option 2 Days of Week."
     SET lstat = log_message(t)
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].year_option2_weeks_of_month > " ")) OR ((requestin->list_0[x].
    year_option2_months_of_year > " "))) )
     SET log_msg = "Error: Missing Yearly Option 2 Days of Week."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].year_option2_months_of_year > " "))
    SET scnt = size(requestin->list_0[x].year_option2_months_of_year,1)
    SET error_found = 0
    SET 1_found = 0
    SET 2_found = 0
    SET 3_found = 0
    SET 4_found = 0
    SET 5_found = 0
    SET 6_found = 0
    SET 7_found = 0
    SET 8_found = 0
    SET 9_found = 0
    SET 10_found = 0
    SET 11_found = 0
    SET 12_found = 0
    SET end_loop = 0
    FOR (s = 1 TO scnt)
      SET comma_psn = 0
      SET comma_psn = findstring(",",requestin->list_0[x].year_option2_months_of_year,s)
      IF (comma_psn=0)
       SET comma_psn = (scnt+ 1)
       SET end_loop = 1
      ENDIF
      IF (comma_psn > 0)
       SET string_len = (comma_psn - s)
       SET date_string = substring(s,string_len,requestin->list_0[x].year_option2_months_of_year)
       SET numeric_check = 0
       SET numeric_check = isnumeric(date_string)
       IF (numeric_check=0)
        SET log_msg = "Error: Invalid Yearly Option 2 Months of Year."
        SET lstat = log_message(t)
        SET s = (scnt+ 1)
       ELSE
        SET numeric_check = cnvtint(date_string)
        IF (((numeric_check < 1) OR (numeric_check > 12)) )
         SET log_msg = "Error: Invalid Yearly Option 2 Months of Year."
         SET lstat = log_message(t)
         SET s = (scnt+ 1)
        ELSE
         IF (numeric_check=1)
          IF (1_found=0)
           SET 1_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=2)
          IF (2_found=0)
           SET 2_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=3)
          IF (3_found=0)
           SET 3_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=4)
          IF (4_found=0)
           SET 4_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=5)
          IF (5_found=0)
           SET 5_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=6)
          IF (6_found=0)
           SET 6_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=7)
          IF (7_found=0)
           SET 7_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=8)
          IF (8_found=0)
           SET 8_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=9)
          IF (9_found=0)
           SET 9_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=10)
          IF (10_found=0)
           SET 10_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=11)
          IF (11_found=0)
           SET 11_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ELSEIF (numeric_check=12)
          IF (12_found=0)
           SET 12_found = 1
          ELSE
           SET error_found = 1
          ENDIF
         ENDIF
         IF (error_found=1)
          SET log_msg = "Error: Invalid Yearly Option 2 Months of Year."
          SET lstat = log_message(t)
          SET s = (scnt+ 1)
         ELSE
          IF (end_loop=1)
           SET s = (scnt+ 1)
          ELSE
           SET s = comma_psn
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   ELSE
    IF ((((requestin->list_0[x].year_option2_weeks_of_month > " ")) OR ((requestin->list_0[x].
    year_option2_days_of_week > " "))) )
     SET log_msg = "Error: Missing Yearly Option 2 Months of Year."
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   SET br_sch_template_id = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     br_sch_template_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   INSERT  FROM br_sch_template b
    SET b.br_sch_template_id = br_sch_template_id, b.template_name = requestin->list_0[x].
     template_name, b.daybegin_str = requestin->list_0[x].day_begin,
     b.dayend_str = requestin->list_0[x].day_end, b.template_status_flag = 0, b.def_sched_id = 0,
     b.apply_beg_dt_tm_string = requestin->list_0[x].apply_begin_date, b.apply_end_dt_tm_string =
     requestin->list_0[x].apply_end_date, b.apply_range_str = requestin->list_0[x].apply_range,
     b.apply_occurrences_str = requestin->list_0[x].apply_occurrences, b.new_format_ind = 1, b
     .logical_domain_id = numeric_logical_domain_id,
     b.uk_date_format_str = requestin->list_0[x].uk_format, b.week_opt_nbrofweeks = requestin->
     list_0[x].week_option_nbr_of_weeks, b.week_opt_daysofweek = requestin->list_0[x].
     week_option_days_of_week,
     b.month_opt1_datesofmonth = requestin->list_0[x].month_option1_dates_of_month, b
     .month_opt1_nbrofmonths = requestin->list_0[x].month_option1_nbr_of_months, b
     .month_opt2_weeksofmonth = requestin->list_0[x].month_option2_weeks_of_month,
     b.month_opt2_daysofweek = requestin->list_0[x].month_option2_days_of_week, b
     .month_opt2_nbrofmonths = requestin->list_0[x].month_option2_nbr_of_months, b
     .year_opt1_monthsofyear = requestin->list_0[x].year_option1_months_of_year,
     b.year_opt1_datesofmonth = requestin->list_0[x].year_option1_dates_of_month, b
     .year_opt2_weeksofmonth = requestin->list_0[x].year_option2_weeks_of_month, b
     .year_opt2_daysofweek = requestin->list_0[x].year_option2_days_of_week,
     b.year_opt2_monthsofyear = requestin->list_0[x].year_option2_months_of_year, b.updt_dt_tm =
     cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
     b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
    WITH nocounter
   ;end insert
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE new_resource(t)
   SET resource_cd = 0.0
   SET quota = 0
   IF (data_partition_ind=1)
    SELECT INTO "nl:"
     FROM sch_resource sr
     WHERE sr.mnemonic_key=cnvtupper(requestin->list_0[x].default_resource)
      AND sr.logical_domain_id=numeric_logical_domain_id
     DETAIL
      resource_cd = sr.resource_cd, quota = sr.quota
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM sch_resource sr
     WHERE sr.mnemonic_key=cnvtupper(requestin->list_0[x].default_resource)
     DETAIL
      resource_cd = sr.resource_cd, quota = sr.quota
     WITH nocounter
    ;end select
   ENDIF
   IF (resource_cd=0)
    SET log_msg = concat("Error: Default Resource ",trim(requestin->list_0[x].default_resource),
     " does not exist.")
    SET lstat = log_message(t)
   ELSE
    IF (quota > 0)
     SET log_msg = concat("Error: Default Resource ",trim(requestin->list_0[x].default_resource),
      " has a booking limit.")
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   INSERT  FROM br_sch_temp_res_r b
    SET b.br_sch_temp_res_r_id = seq(bedrock_seq,nextval), b.br_sch_template_id = br_sch_template_id,
     b.resource_cd = resource_cd,
     b.resource_name = requestin->list_0[x].default_resource, b.resource_status_flag =
     IF (resource_cd > 0) 1
     ELSE 0
     ENDIF
     , b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
     updt_applctx,
     b.updt_cnt = 0
    WITH nocounter
   ;end insert
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE new_slot(t)
   SET slot_type_id = 0.0
   SET contiguous_ind = 0
   IF (data_partition_ind=1)
    SELECT INTO "nl:"
     FROM sch_slot_type sst
     WHERE sst.mnemonic_key=cnvtupper(requestin->list_0[x].slot_type)
      AND sst.logical_domain_id=numeric_logical_domain_id
     DETAIL
      slot_type_id = sst.slot_type_id, contiguous_ind = sst.contiguous_ind
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM sch_slot_type sst
     WHERE sst.mnemonic_key=cnvtupper(requestin->list_0[x].slot_type)
     DETAIL
      slot_type_id = sst.slot_type_id, contiguous_ind = sst.contiguous_ind
     WITH nocounter
    ;end select
   ENDIF
   IF (slot_type_id=0)
    SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type)," does not exist.")
    SET lstat = log_message(t)
   ENDIF
   IF ((requestin->list_0[x].slot_start_time > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].slot_start_time)
    IF (numeric_check=0)
     SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
      " start time is not valid.")
     SET lstat = log_message(t)
    ELSE
     SET time_size = 0
     SET time_size = size(requestin->list_0[x].slot_start_time,1)
     IF (time_size != 4)
      SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
       " start time is not valid.")
      SET lstat = log_message(t)
     ELSE
      IF (substring(4,1,requestin->list_0[x].slot_start_time) != "0"
       AND substring(4,1,requestin->list_0[x].slot_start_time) != "5")
       SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
        " start time is not valid.")
       SET lstat = log_message(t)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
     " start time is missing.")
    SET lstat = log_message(t)
   ENDIF
   IF ((requestin->list_0[x].slot_end_time > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].slot_end_time)
    IF (numeric_check=0)
     SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
      " end time is not valid.")
     SET lstat = log_message(t)
    ELSE
     SET time_size = 0
     SET time_size = size(requestin->list_0[x].slot_end_time,1)
     IF (time_size != 4)
      SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
       " end time is not valid.")
      SET lstat = log_message(t)
     ELSE
      IF (substring(4,1,requestin->list_0[x].slot_end_time) != "0"
       AND substring(4,1,requestin->list_0[x].slot_end_time) != "5")
       SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
        " end time is not valid.")
       SET lstat = log_message(t)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
     " end time is missing.")
    SET lstat = log_message(t)
   ENDIF
   IF ((requestin->list_0[x].start_interval > " "))
    IF (slot_type_id > 0
     AND contiguous_ind=0)
     SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
      " appointment start time interval is defined for a discrete slot.")
     SET lstat = log_message(t)
    ENDIF
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].start_interval)
    IF (numeric_check=0)
     SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
      " appointment start interval is not valid.")
     SET lstat = log_message(t)
    ELSE
     SET numeric_check = cnvtint(requestin->list_0[x].start_interval)
     IF (mod(numeric_check,5) > 0)
      SET log_msg = concat("Error: Slot Type ",trim(requestin->list_0[x].slot_type),
       " appointment start interval is not valid.")
      SET lstat = log_message(t)
     ENDIF
    ENDIF
   ENDIF
   SET br_sch_temp_slot_r_id = 0.0
   SELECT INTO "nl:"
    j = seq(bedrock_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     br_sch_temp_slot_r_id = cnvtreal(j)
    WITH format, nocounter
   ;end select
   INSERT  FROM br_sch_temp_slot_r b
    SET b.br_sch_temp_slot_r_id = br_sch_temp_slot_r_id, b.br_sch_template_id = br_sch_template_id, b
     .slot_name = requestin->list_0[x].slot_type,
     b.slot_start_str = requestin->list_0[x].slot_start_time, b.slot_end_str = requestin->list_0[x].
     slot_end_time, b.interval_str = requestin->list_0[x].start_interval,
     b.slot_type_id = slot_type_id, b.slot_status_flag =
     IF (slot_type_id > 0) 1
     ELSE 0
     ENDIF
     , b.time_block_str = requestin->list_0[x].time_block,
     b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
     reqinfo->updt_task,
     b.updt_applctx = reqinfo->updt_applctx, b.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF ((((requestin->list_0[x].slot_release_to > " ")) OR ((((requestin->list_0[x].
   slot_release_start_time > " ")) OR ((((requestin->list_0[x].slot_release_end_time > " ")) OR ((((
   requestin->list_0[x].slot_release_unit > " ")) OR ((requestin->list_0[x].slot_release_unit_value
    > " "))) )) )) )) )
    SET stat = new_release(x)
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE new_release(t)
   SET release_type_id = 0.0
   IF ((requestin->list_0[x].slot_release_to > " "))
    IF (data_partition_ind=1)
     SELECT INTO "nl:"
      FROM sch_slot_type sst
      WHERE sst.mnemonic_key=cnvtupper(requestin->list_0[x].slot_release_to)
       AND sst.logical_domain_id=numeric_logical_domain_id
      DETAIL
       release_type_id = sst.slot_type_id
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM sch_slot_type sst
      WHERE sst.mnemonic_key=cnvtupper(requestin->list_0[x].slot_release_to)
      DETAIL
       release_type_id = sst.slot_type_id
      WITH nocounter
     ;end select
    ENDIF
    IF (release_type_id=0)
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
      " does not exist.")
     SET lstat = log_message(t)
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].slot_release_start_time > " ")) OR ((((requestin->list_0[x].
    slot_release_end_time > " ")) OR ((((requestin->list_0[x].slot_release_unit > " ")) OR ((
    requestin->list_0[x].slot_release_unit_value > " "))) )) )) )
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
      " is missing.")
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].slot_release_start_time > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].slot_release_start_time)
    IF (numeric_check=0)
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
      " start time is not valid.")
     SET lstat = log_message(t)
    ELSE
     SET time_size = 0
     SET time_size = size(requestin->list_0[x].slot_release_start_time,1)
     IF (time_size != 4)
      SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
       " start time is not valid.")
      SET lstat = log_message(t)
     ELSE
      IF (substring(4,1,requestin->list_0[x].slot_release_start_time) != "0"
       AND substring(4,1,requestin->list_0[x].slot_release_start_time) != "5")
       SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
        " start time is not valid.")
       SET lstat = log_message(t)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].slot_release_to > " ")) OR ((((requestin->list_0[x].
    slot_release_end_time > " ")) OR ((((requestin->list_0[x].slot_release_unit > " ")) OR ((
    requestin->list_0[x].slot_release_unit_value > " "))) )) )) )
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
      " start time is missing.")
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].slot_release_end_time > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].slot_release_end_time)
    IF (numeric_check=0)
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
      " end time is not valid.")
     SET lstat = log_message(t)
    ELSE
     SET time_size = 0
     SET time_size = size(requestin->list_0[x].slot_release_end_time,1)
     IF (time_size != 4)
      SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
       " end time is not valid.")
      SET lstat = log_message(t)
     ELSE
      IF (substring(4,1,requestin->list_0[x].slot_release_end_time) != "0"
       AND substring(4,1,requestin->list_0[x].slot_release_end_time) != "5")
       SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
        " end time is not valid.")
       SET lstat = log_message(t)
      ENDIF
     ENDIF
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].slot_release_to > " ")) OR ((((requestin->list_0[x].
    slot_release_start_time > " ")) OR ((((requestin->list_0[x].slot_release_unit > " ")) OR ((
    requestin->list_0[x].slot_release_unit_value > " "))) )) )) )
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
      " end time is missing.")
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].slot_release_unit_value > " "))
    SET numeric_check = 0
    SET numeric_check = isnumeric(requestin->list_0[x].slot_release_unit_value)
    IF (numeric_check=0)
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].
       slot_release_unit_value)," unit value is not valid.")
     SET lstat = log_message(t)
    ELSE
     SET numeric_check = cnvtint(requestin->list_0[x].slot_release_unit_value)
     IF (((numeric_check < 1) OR (numeric_check > 1440)) )
      SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].
        slot_release_unit_value)," unit value is not valid.")
      SET lstat = log_message(t)
     ENDIF
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].slot_release_to > " ")) OR ((((requestin->list_0[x].
    slot_release_start_time > " ")) OR ((((requestin->list_0[x].slot_release_end_time > " ")) OR ((
    requestin->list_0[x].slot_release_unit > " "))) )) )) )
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
      " unit value is missing.")
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((requestin->list_0[x].slot_release_unit > " "))
    IF (cnvtupper(requestin->list_0[x].slot_release_unit) IN ("MINUTES", "HOURS", "DAYS", "WEEKS"))
     SET log_msg = log_msg
    ELSE
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_unit),
      " unit is not valid.")
     SET lstat = log_message(t)
    ENDIF
   ELSE
    IF ((((requestin->list_0[x].slot_release_to > " ")) OR ((((requestin->list_0[x].
    slot_release_start_time > " ")) OR ((((requestin->list_0[x].slot_release_end_time > " ")) OR ((
    requestin->list_0[x].slot_release_unit_value > " "))) )) )) )
     SET log_msg = concat("Error: Release Slot Type ",trim(requestin->list_0[x].slot_release_to),
      " unit is missing.")
     SET lstat = log_message(t)
    ENDIF
   ENDIF
   IF ((((requestin->list_0[x].slot_release_to > " ")) OR ((((requestin->list_0[x].
   slot_release_start_time > " ")) OR ((((requestin->list_0[x].slot_release_end_time > " ")) OR ((((
   requestin->list_0[x].slot_release_unit > " ")) OR ((requestin->list_0[x].slot_release_unit_value
    > " "))) )) )) )) )
    INSERT  FROM br_sch_temp_slot_release_r b
     SET b.br_sch_temp_slot_release_r_id = seq(bedrock_seq,nextval), b.br_sch_temp_slot_r_id =
      br_sch_temp_slot_r_id, b.release_name = requestin->list_0[x].slot_release_to,
      b.release_start_time_str = requestin->list_0[x].slot_release_start_time, b.release_end_time_str
       = requestin->list_0[x].slot_release_end_time, b.release_type_id = release_type_id,
      b.release_unit = requestin->list_0[x].slot_release_unit, b.release_unit_value_str = requestin->
      list_0[x].slot_release_unit_value, b.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
      updt_applctx,
      b.updt_cnt = 0
     WITH nocounter
    ;end insert
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE log_message(t)
  SELECT INTO value(logfilename)
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    log_msg, row + 1
   WITH nocounter, append
  ;end select
  RETURN(1.0)
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_BR_DEF_SCHED_TEMP","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
