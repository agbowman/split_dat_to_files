CREATE PROGRAM cps_t_hm_gender_age:dba
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  Start of program CPS_T_HM_GENDER_AGE  *******"),1,0)
 SET cur_series_index = size(reply->expectation_series,5)
 SET start_days_diff = 0.0
 SET qual_msg_started = 0
 SET opt_qual_ind = 0
 SET opt_age1_ind = 0
 SET opt_age2_ind = 0
 SET opt_gender_ind = 0
 SET age1_unit_mult = 0.0
 SET age2_unit_nult = 0.0
 SET unit_str1 = fillstring(6," ")
 SET unit_str2 = fillstring(6," ")
 SET age_match = 0
 SET gender_match = 0
 SET age_qual_two_opt = 0
 SET check_age = 0
 SET check_gender = 0
 SET retval = 0
 DECLARE zerotimebirthdt = dq8 WITH protect, noconstant(0)
 CALL echo("***   Check Age Options")
 IF (validate(opt_qual,"Z") != "Z")
  CALL echo("***   OPT_QUAL was defined")
  IF (trim(opt_qual) != " "
   AND cnvtupper(trim(opt_qual)) IN ("GREATER THAN", "GREATER THAN OR EQUAL TO", "LESS THAN",
  "LESS THAN OR EQUAL TO", "EQUAL TO",
  "BETWEEN", "OUTSIDE"))
   SET opt_qual_ind = 1
   IF (cnvtupper(trim(opt_qual)) IN ("BETWEEN", "OUTSIDE"))
    SET age_qual_two_opt = 1
   ENDIF
   CALL echo(concat("***   OPT_QUAL has a valid value of ",trim(opt_qual)))
   IF (validate(opt_age1,"Z") != "Z")
    CALL echo("***   OPT_AGE1 is defined")
    IF (isnumeric(opt_age1))
     CALL echo(concat("***   OPT_AGE1 has a valid value of ",trim(opt_age1)))
     SET opt_age1_ind = 1
    ELSE
     SET check_age = - (1)
     SET opt_age1_ind = - (1)
     CALL echo(concat("***   OPT_AGE1 has a invalid value of ",trim(opt_age1)))
     GO TO exit_script
    ENDIF
   ENDIF
   IF (age_qual_two_opt=1)
    IF (validate(opt_age2,"Z") != "Z")
     CALL echo("***   OPT_AGE2 is defined")
     IF ( NOT (isnumeric(opt_age2)))
      CALL echo(concat("***   OPT_AGE2 has a invalid value of ",trim(opt_age2)))
      SET check_age = - (1)
      SET opt_age2_ind = - (1)
      GO TO exit_script
     ELSE
      CALL echo(concat("***   OPT_AGE2 has a valid value of ",trim(opt_age2)))
      SET opt_age2_ind = 1
     ENDIF
    ELSE
     CALL echo("***   OPT_AGE2 is not defined")
     SET check_age = - (1)
     SET opt_age2_ind = - (1)
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (((opt_qual_ind=1
  AND opt_age1_ind=1
  AND (opt_age2_ind=- (1))) OR (opt_qual_ind=1
  AND opt_age1_ind != 1)) )
  CALL echo("***   Age options are in error exiting script")
  CALL echo(build("***      opt_qual_ind :",opt_qual_ind))
  CALL echo(build("***      opt_age1_ind :",opt_age1_ind))
  CALL echo(build("***      opt_age2_ind :",opt_age2_ind))
  GO TO exit_script
 ENDIF
 IF (opt_qual_ind=1
  AND opt_age1_ind=1
  AND (opt_age2_ind != - (1)))
  SET check_age = 1
  CALL echo("***   Age options are valid Start age check")
  CALL echo(build("***      opt_qual_ind :",opt_qual_ind))
  CALL echo(build("***      opt_age1_ind :",opt_age1_ind))
  CALL echo(build("***      opt_age2_ind :",opt_age2_ind))
  IF ((request->birth_dt_tm < 1))
   CALL echo("***   Invalid birth date/time in request exiting script")
   CALL echo(build("***      request->birth_dt_tm :",request->birth_dt_tm))
   GO TO exit_script
  ENDIF
  SET zerotimebirthdt = cnvtdatetime(cnvtdate(request->birth_dt_tm),0)
  IF (validate(opt_unit1,"Z") != "Z")
   SET unit_str1 = cnvtupper(trim(opt_unit1))
   IF (unit_str1="HOURS")
    SET unit_str1 = ",H"
   ELSEIF (unit_str1="DAYS")
    SET unit_str1 = ",D"
   ELSEIF (unit_str1="WEEKS")
    SET unit_str1 = ",W"
   ELSEIF (unit_str1="MONTHS")
    SET unit_str1 = ",M"
   ELSE
    SET unit_str1 = ",Y"
   ENDIF
  ELSE
   SET unit_str1 = ",Y"
  ENDIF
  CALL echo(build("***      unit_str1 :",unit_str1))
  IF (opt_age2_ind=1)
   IF (validate(opt_unit2,"Z") != "Z")
    SET unit_str2 = cnvtupper(trim(opt_unit2))
    IF (unit_str2="HOURS")
     SET unit_str2 = ",H"
    ELSEIF (unit_str2="DAYS")
     SET unit_str2 = ",D"
    ELSEIF (unit_str2="WEEKS")
     SET unit_str2 = ",W"
    ELSEIF (unit_str2="MONTHS")
     SET unit_str2 = ",M"
    ELSE
     SET unit_str2 = ",Y"
    ENDIF
   ELSE
    SET unit_str2 = ",Y"
   ENDIF
   CALL echo(build("***      unit_str2 :",unit_str2))
  ENDIF
  CASE (trim(cnvtupper(opt_qual)))
   OF "GREATER THAN":
    SET opt_age1_int = cnvtint(opt_age1)
    SET opt_age1_int = (opt_age1_int+ 1)
    SET opt_age1 = trim(cnvtstring(opt_age1_int))
    SET qualifydate = cnvtlookbehind(build(opt_age1,unit_str1),cnvtdatetime(curdate,0))
    CALL echo(build("qualify date: ",format(qualifydate,";;Q")))
    CALL echo(build("birth date: ",format(zerotimebirthdt,";;Q")))
    IF (qualifydate > zerotimebirthdt)
     SET age_match = 1
    ENDIF
    CALL echo("***   Performing GREATER THAN operation >")
    CALL echo(build("***      age_match       :",age_match))
   OF "GREATER THAN OR EQUAL TO":
    SET qualifydate = cnvtlookbehind(build(opt_age1,unit_str1),cnvtdatetime(curdate,0))
    CALL echo(build("qualify date: ",format(qualifydate,";;Q")))
    CALL echo(build("birth date: ",format(zerotimebirthdt,";;Q")))
    IF (qualifydate >= zerotimebirthdt)
     SET age_match = 1
    ENDIF
    CALL echo("***   Performing GREATER THAN OR EQUAL TO operation >=")
    CALL echo(build("***      age_match       :",age_match))
   OF "LESS THAN":
    SET qualifydate = cnvtlookbehind(build(opt_age1,unit_str1),cnvtdatetime(curdate,0))
    CALL echo(build("qualify date: ",format(qualifydate,";;Q")))
    CALL echo(build("birth date: ",format(zerotimebirthdt,";;Q")))
    IF (qualifydate < zerotimebirthdt)
     SET age_match = 1
    ENDIF
    CALL echo("***   Performing LESS THAN operation <")
    CALL echo(build("***      age_match       :",age_match))
   OF "LESS THAN OR EQUAL TO":
    SET qualifydate = cnvtlookbehind(build(opt_age1,unit_str1),cnvtdatetime(curdate,0))
    CALL echo(build("qualify date: ",format(qualifydate,";;Q")))
    CALL echo(build("birth date: ",format(zerotimebirthdt,";;Q")))
    IF (qualifydate <= zerotimebirthdt)
     SET age_match = 1
    ENDIF
    CALL echo("***   Performing LESS THAN OR EQUAL TO operation <=")
    CALL echo(build("***      age_match       :",age_match))
   OF "EQUAL TO":
    SET qualifydate = cnvtlookbehind(build(opt_age1,unit_str1),cnvtdatetime(curdate,0))
    CALL echo(build("qualify date: ",format(qualifydate,";;Q")))
    CALL echo(build("birth date: ",format(zerotimebirthdt,";;Q")))
    IF (qualifydate=zerotimebirthdt)
     SET age_match = 1
    ENDIF
    CALL echo("***   Performing EQUAL TO operation <")
    CALL echo(build("***      age_match       :",age_match))
   OF "BETWEEN":
    SET qualifydate1 = cnvtlookbehind(build(opt_age1,unit_str1),cnvtdatetime(curdate,0))
    SET qualifydate2 = cnvtlookbehind(build(opt_age2,unit_str2),cnvtdatetime(curdate,0))
    CALL echo(build("qualify date1: ",format(qualifydate1,";;Q")))
    CALL echo(build("qualify date2: ",format(qualifydate2,";;Q")))
    CALL echo(build("birth date: ",format(zerotimebirthdt,";;Q")))
    IF (qualifydate1 >= zerotimebirthdt
     AND qualifydate2 <= zerotimebirthdt)
     SET age_match = 1
    ENDIF
    CALL echo("***   Performing BETWEEN operation >= age1_days and <= age2_days")
    CALL echo(build("***      age_match       :",age_match))
   OF "OUTSIDE":
    SET opt_age1_int = cnvtint(opt_age1)
    SET opt_age1_int = (opt_age1_int+ 1)
    SET opt_age1 = trim(cnvtstring(opt_age1_int))
    SET qualifydate1 = cnvtlookbehind(build(opt_age1,unit_str1),cnvtdatetime(curdate,0))
    SET qualifydate2 = cnvtlookbehind(build(opt_age2,unit_str2),cnvtdatetime(curdate,0))
    CALL echo(build("qualify date: ",format(qualifydate1,";;Q")))
    CALL echo(build("qualify date: ",format(qualifydate2,";;Q")))
    CALL echo(build("birth date: ",format(zerotimebirthdt,";;Q")))
    IF (((qualifydate1 < zerotimebirthdt) OR (qualifydate2 > zerotimebirthdt)) )
     SET age_match = 1
    ENDIF
    CALL echo("***   Performing OUTSIDE operation < age1_days and > age2_days")
    CALL echo(build("***      age_match       :",age_match))
  ENDCASE
 ENDIF
 CALL echo("***   Check Gender")
 IF (validate(opt_gender,"Z") != "Z")
  CALL echo(build("***   OPT_GENDER :",opt_gender))
  RECORD opt_genderlist(
    1 cnt = i4
    1 qual[*]
      2 value = vc
      2 display = vc
  )
  SET orig_param = opt_gender
  EXECUTE eks_t_parse_list  WITH replace(reply,opt_genderlist)
  FREE SET orig_param
  SET check_gender = 1
  CALL echo("***      OPT_GENDER is valid")
  CALL echorecord(opt_genderlist)
 ELSE
  CALL echo("***      OPT_GENDER is not valid")
  GO TO exit_script
 ENDIF
 IF ((opt_genderlist->cnt > 0))
  CALL echo(build("***      Gender list has values cnt :",opt_genderlist->cnt))
  CALL echo("***      Find code_values")
  FOR (i = 1 TO opt_genderlist->cnt)
   CALL echo(build("***      display :",trim(opt_genderlist->qual[i].display)))
   IF (isnumeric(opt_genderlist->qual[i].value))
    SET gender_cd = cnvtreal(opt_genderlist->qual[i].value)
    IF (gender_cd > 0)
     SET opt_genderlist->qual[i].value = build(gender_cd)
    ELSE
     CALL echo(build("***      Code_value is not > 0 :",trim(opt_genderlist->qual[i].value)))
     SET opt_gender_ind = - (1)
     GO TO exit_script
    ENDIF
   ELSE
    CALL echo(build("***      Not a valid code_value number :",trim(opt_genderlist->qual[i].value)))
    SET opt_gender_ind = - (1)
    GO TO exit_script
   ENDIF
  ENDFOR
  SET opt_gender_ind = 1
 ELSE
  SET check_gender = 0
 ENDIF
 SET idx = 1
 CALL echo(build("***   opt_gender_ind      :",opt_gender_ind))
 CALL echo(build("***   OPT_GENDERlist->cnt :",opt_genderlist->cnt))
 CALL echo(build("***   idx                 :",idx))
 WHILE (opt_gender_ind=1
  AND (idx <= opt_genderlist->cnt))
   IF ((request->sex_cd=cnvtreal(opt_genderlist->qual[idx].value)))
    SET gender_match = 1
    SET opt_gender_ind = 0
   ENDIF
   SET idx = (idx+ 1)
   CALL echo(build("***   opt_gender_ind      :",opt_gender_ind))
   CALL echo(build("***   OPT_GENDERlist->cnt :",opt_genderlist->cnt))
   CALL echo(build("***   idx                 :",idx))
 ENDWHILE
#exit_script
 CALL echo(build("***   check_age      :",check_age))
 CALL echo(build("***   check_gender   :",check_gender))
 CALL echo(build("***   opt_gender_ind :",opt_gender_ind))
 CALL echo(build("***   gender_match :",gender_match))
 CALL echo(build("***   age_match    :",age_match))
 IF (check_age=1
  AND check_gender=1
  AND (opt_gender_ind != - (1)))
  IF (gender_match=true
   AND age_match=true)
   SET retval = 100
  ENDIF
 ELSEIF (check_age=1
  AND (opt_gender_ind != - (1)))
  IF (age_match=true)
   SET retval = 100
  ENDIF
 ELSEIF (check_gender=1
  AND (opt_gender_ind != - (1)))
  IF (gender_match=true)
   SET retval = 100
  ENDIF
 ELSEIF (check_age=0
  AND check_gender=0
  AND (opt_gender_ind != - (1)))
  SET retval = 100
 ENDIF
 CALL echo(build("***   retval :",retval))
 IF (retval=0)
  SET reply->expectation_series[cur_series_index].qualify_explanation = concat(reply->
   expectation_series[cur_series_index].qualify_explanation," ",trim(false_text))
 ELSE
  SET reply->expectation_series[cur_series_index].qualify_explanation = concat(reply->
   expectation_series[cur_series_index].qualify_explanation," ",trim(true_text))
 ENDIF
 CALL echo(concat(format(curdate,"dd-mmm-yyyy;;d")," ",format(curtime3,"hh:mm:ss.cc;3;m"),
   "  *******  End of program cps_t_hm_gender_age  *******"),1,0)
END GO
