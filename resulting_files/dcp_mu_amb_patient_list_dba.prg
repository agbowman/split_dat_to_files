CREATE PROGRAM dcp_mu_amb_patient_list:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Begin Date" = "CURDATE",
  "End Date" = "CURDATE",
  "Clinic" = 0,
  "Provider Relation" = "",
  "Provider" = 0,
  "Patient Communication Preference" = 0.000000,
  "Sex" = 0.000000,
  "Age" = 0,
  "Age Unit" = "",
  "Preferred Language" = 0.000000,
  "Race" = 0.000000,
  "Ethnicity" = 0.000000,
  "Preliminary Cause of Death" = 0,
  "Filter by Problem" = 0,
  "Problem 1" = 0,
  "Problem 2" = 0,
  "Problem 3" = 0,
  "Filter by Medication" = 0,
  "Medication 1" = 0,
  "Medication 2" = 0,
  "Medication 3" = 0,
  "Filter by Medication Allergy" = 0,
  "Medication Allergy 1" = 0,
  "Medication Allergy 2" = 0,
  "Medication Allergy 3" = 0,
  "Filter by Lab Test and Result" = 0,
  "Lab Test / Result" = 0,
  "Lab Result Sign" = 0,
  "Lab Result" = 0,
  "Primary Sort" = "",
  "Primary Sort Direction" = "",
  "Secondary Sort" = "",
  "Secondary Sort Direction" = ""
  WITH outdev, beg_date, end_date,
  nu_amb, prov_reltn, prov,
  comm, sex, age,
  age_unit, lang, race,
  ethnic, death, prob_ind,
  problem, problem2, problem3,
  med_ind, med, med2,
  med3, allergy_ind, allergy,
  allergy2, allergy3, lab_ind,
  lab_test, lab_res_sign, lab_result,
  primary_sort, primary_sort_direction, secondary_sort,
  secondary_sort_direction
 RECORD pat_request(
   1 outdev = vc
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 loc_facility_cd = f8
   1 loc_nurse_unit_cd = f8
   1 demographics
     2 sex_cd = f8
     2 age_num = i4
     2 age_unit = vc
     2 language_cd = f8
     2 race_cd = f8
     2 ethnic_grp_cd = f8
     2 contact_method_cd = f8
     2 pcp_prsnl_list = vc
     2 cause_of_death_type = vc
     2 cause_of_death_id = f8
   1 prob_diag_nomen_id = f8
   1 prob_diag_nomen_id2 = f8
   1 prob_diag_nomen_id3 = f8
   1 catalog_cd = f8
   1 catalog_cd2 = f8
   1 catalog_cd3 = f8
   1 allergy_nomen_id = f8
   1 allergy_nomen_id2 = f8
   1 allergy_nomen_id3 = f8
   1 task_assay_cd = f8
   1 result_sign = i2
   1 result_value_numeric = f8
   1 primary_sort = vc
   1 primary_sort_desc = i2
   1 secondary_sort = vc
   1 secondary_sort_desc = i2
   1 reltn_option = i4
 )
 DECLARE code_set = vc WITH protect, constant("CODESET")
 DECLARE event_code = vc WITH protect, constant("EVENTCODE")
 DECLARE getpromptlist(which_prompt=i2) = vc
 DECLARE ispromptany(which_prompt=i2) = i2
 DECLARE ispromptlist(which_prompt=i2) = i2
 DECLARE ispromptsingle(which_prompt=i2) = i2
 DECLARE ispromptempty(which_prompt=i2) = i2
 DECLARE parsedateprompt(date_str=vc,default_date=vc,time=i4) = dq8
 DECLARE _evaluatedatestr(date_str=vc) = i4
 DECLARE _parsedate(date_str=vc) = i4
 SUBROUTINE getpromptlist(which_prompt)
   DECLARE prompt_reflect = vc WITH noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH noconstant(0), private
   DECLARE item_num = i4 WITH noconstant(0), private
   DECLARE return_val = vc WITH noconstant(" "), private
   DECLARE enq = c1 WITH constant(char(5)), private
   IF (ispromptempty(which_prompt))
    SET return_val = " "
   ELSEIF (ispromptlist(which_prompt))
    SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
   ELSEIF (ispromptsingle(which_prompt))
    SET count = 1
   ENDIF
   IF (count > 0)
    FOR (item_num = 1 TO count)
      SET return_val = build(return_val,value(parameter(which_prompt,item_num)),enq)
    ENDFOR
    SET return_val = replace(trim(return_val,3),enq,",")
    IF (count=1)
     SET return_val = build("=",return_val)
    ELSE
     SET return_val = build("in (",return_val,")")
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE ispromptany(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (prompt_reflect="C1")
    IF (ichar(value(parameter(which_prompt,1)))=42)
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE ispromptlist(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (substring(1,1,prompt_reflect)="L")
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE ispromptsingle(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3)) > 0
    AND  NOT (ispromptany(which_prompt))
    AND  NOT (ispromptlist(which_prompt)))
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE ispromptempty(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3))=0)
    SET return_val = 1
   ELSEIF (ispromptsingle(which_prompt))
    IF (substring(1,1,prompt_reflect)="C")
     IF (textlen(trim(value(parameter(which_prompt,0)),3))=0)
      SET return_val = 1
     ENDIF
    ELSE
     IF (cnvtreal(value(parameter(which_prompt,1)))=0)
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE parsedateprompt(date_str,default_date,time)
   DECLARE _return_val = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE _time = i4 WITH constant(cnvtint(time)), private
   DECLARE _date = i4 WITH constant(_parsedate(date_str)), private
   IF (_date=0.0)
    CASE (substring(1,1,reflect(default_date)))
     OF "F":
      SET _return_val = cnvtdatetime(cnvtdate(default_date),_time)
     OF "C":
      SET _return_val = cnvtdatetime(_evaluatedatestr(default_date),_time)
     OF "I":
      SET _return_val = cnvtdatetime(default_date,_time)
     ELSE
      SET _return_val = 0
    ENDCASE
   ELSE
    SET _return_val = cnvtdatetime(_date,_time)
   ENDIF
   RETURN(_return_val)
 END ;Subroutine
 SUBROUTINE _parsedate(date_str)
   DECLARE _return_val = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE _time = i4 WITH constant(0), private
   IF (isnumeric(date_str))
    DECLARE _date = vc WITH constant(trim(cnvtstring(date_str))), private
    SET _return_val = cnvtdatetime(cnvtdate(_date),_time)
    IF (_return_val=0.0)
     SET _return_val = cnvtdatetime(cnvtint(_date),_time)
    ENDIF
   ELSE
    DECLARE _date = vc WITH constant(trim(date_str)), private
    IF (textlen(trim(_date))=0)
     SET _return_val = 0
    ELSE
     IF (_date IN ("*CURDATE*"))
      SET _return_val = cnvtdatetime(_evaluatedatestr(_date),_time)
     ELSE
      SET _return_val = cnvtdatetime(cnvtdate2(_date,"DD-MMM-YYYY"),_time)
     ENDIF
    ENDIF
   ENDIF
   RETURN(cnvtdate(_return_val))
 END ;Subroutine
 SUBROUTINE _evaluatedatestr(date_str)
   DECLARE _dq8 = dq8 WITH noconstant, private
   DECLARE _parse = vc WITH constant(concat("set _dq8 = cnvtdatetime(",date_str,", 0) go")), private
   CALL parser(_parse)
   RETURN(cnvtdate(_dq8))
 END ;Subroutine
 SET pat_request->outdev = trim( $OUTDEV)
 SET pat_request->beg_dt_tm = parsedateprompt( $BEG_DATE,curdate,000000)
 SET pat_request->end_dt_tm = parsedateprompt( $END_DATE,curdate,235959)
 SET pat_request->loc_nurse_unit_cd = cnvtreal( $NU_AMB)
 SET pat_request->demographics.sex_cd = cnvtreal( $SEX)
 SET pat_request->demographics.age_num = cnvtint( $AGE)
 SET pat_request->demographics.age_unit = trim(cnvtupper( $AGE_UNIT),3)
 SET pat_request->demographics.contact_method_cd = cnvtreal( $COMM)
 SET pat_request->demographics.pcp_prsnl_list = getpromptlist(parameter2( $PROV))
 SET pat_request->demographics.language_cd = cnvtreal( $LANG)
 SET pat_request->demographics.race_cd = cnvtreal( $RACE)
 SET pat_request->demographics.ethnic_grp_cd = cnvtreal( $ETHNIC)
 SET pat_request->demographics.cause_of_death_id = cnvtreal( $DEATH)
 SET pat_request->primary_sort = trim(cnvtupper( $PRIMARY_SORT),3)
 SET pat_request->secondary_sort = trim(cnvtupper( $SECONDARY_SORT),3)
 SET pat_request->primary_sort_desc = cnvtint( $PRIMARY_SORT_DIRECTION)
 SET pat_request->secondary_sort_desc = cnvtint( $SECONDARY_SORT_DIRECTION)
 IF (cnvtint( $PROB_IND))
  SET pat_request->prob_diag_nomen_id = cnvtreal( $PROBLEM)
  SET pat_request->prob_diag_nomen_id2 = cnvtreal( $PROBLEM2)
  SET pat_request->prob_diag_nomen_id3 = cnvtreal( $PROBLEM3)
 ENDIF
 IF (cnvtint( $MED_IND))
  SET pat_request->catalog_cd = cnvtreal( $MED)
  SET pat_request->catalog_cd2 = cnvtreal( $MED2)
  SET pat_request->catalog_cd3 = cnvtreal( $MED3)
 ENDIF
 IF (cnvtint( $ALLERGY_IND))
  SET pat_request->allergy_nomen_id = cnvtreal( $ALLERGY)
  SET pat_request->allergy_nomen_id2 = cnvtreal( $ALLERGY2)
  SET pat_request->allergy_nomen_id3 = cnvtreal( $ALLERGY3)
 ENDIF
 IF (cnvtint( $LAB_IND))
  SET pat_request->task_assay_cd = cnvtreal( $LAB_TEST)
  SET pat_request->result_sign = cnvtint( $LAB_RES_SIGN)
  IF (trim( $LAB_RESULT) != "")
   SET pat_request->result_value_numeric = cnvtreal( $LAB_RESULT)
  ELSE
   SET pat_request->result_value_numeric = 1.36e36
  ENDIF
 ELSE
  SET pat_request->task_assay_cd = 0
  SET pat_request->result_sign = 0
  SET pat_request->result_value_numeric = 1.36e36
 ENDIF
 SET pat_request->reltn_option = cnvtint(trim( $PROV_RELTN))
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=27300
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(sysdate)
   AND cv.end_effective_dt_tm > cnvtdatetime(sysdate)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET pat_request->demographics.cause_of_death_type = code_set
 ELSE
  SET pat_request->demographics.cause_of_death_type = event_code
 ENDIF
 EXECUTE dcp_mu_patient_list_driver
 CALL echo("last mod: 10/21/2013  Mark Smith")
END GO
