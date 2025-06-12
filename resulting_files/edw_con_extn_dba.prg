CREATE PROGRAM edw_con_extn:dba
 DECLARE cmt_con_extn_exist = i2 WITH noconstant(0)
 DECLARE whereclause = vc WITH protect, noconstant
 DECLARE record_cnt = i4 WITH noconstant(0), protect
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dtableattr d,
   dtableattrl dl
  WHERE d.table_name="CMT_CONCEPT_EXTENSION"
  DETAIL
   cmt_con_extn_exist = 1
  WITH nocounter
 ;end select
 IF (cmt_con_extn_exist=1)
  SELECT INTO value(con_extn_extractfile)
   n_age1_operator = nullind(c.age1_operator), n_age1_unit_flag = nullind(c.age1_unit_flag),
   n_age1_value = nullind(c.age1_value),
   n_age2_operator = nullind(c.age2_operator), n_age2_unit_flag = nullind(c.age2_unit_flag),
   n_age2_value = nullind(c.age2_value),
   n_gender_flag = nullind(c.gender_flag)
   FROM cmt_concept_extension c
   WHERE c.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
   DETAIL
    record_cnt = (record_cnt+ 1), col 0, health_system_source_id,
    v_bar,
    CALL print(trim(cnvtstring(c.concept_extension_id,16))), v_bar,
    CALL print(trim(replace(c.concept_cki,str_find,str_replace,3))), v_bar,
    CALL print(trim(replace(c.extension_type_mean,str_find,str_replace,3))),
    v_bar,
    CALL print(trim(replace(c.extension_value,str_find,str_replace,3))), v_bar,
    CALL print(build(c.extension_data_type_flag)), v_bar,
    CALL print(trim(replace(evaluate(n_age1_operator,0,c.age1_operator,blank_field),str_find,
      str_replace,3))),
    v_bar,
    CALL print(trim(evaluate(n_age1_unit_flag,0,build(c.age1_unit_flag),blank_field))), v_bar,
    CALL print(trim(evaluate(n_age1_value,0,cnvtstring(c.age1_value,16),blank_field))), v_bar,
    CALL print(trim(replace(evaluate(n_age2_operator,0,c.age2_operator,blank_field),str_find,
      str_replace,3))),
    v_bar,
    CALL print(trim(evaluate(n_age2_unit_flag,0,build(c.age2_unit_flag),blank_field))), v_bar,
    CALL print(trim(evaluate(n_age2_value,0,cnvtstring(c.age2_value,16),blank_field))), v_bar,
    CALL print(trim(evaluate(n_gender_flag,0,build(c.gender_flag),blank_field))),
    v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,c.beg_effective_dt_tm,0,cnvtdatetimeutc(c
        .beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
    CALL print(trim(datetimezoneformat(evaluate(curutc,1,c.end_effective_dt_tm,0,cnvtdatetimeutc(c
        .end_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
    CALL print(build(c.active_ind)),
    v_bar, extract_dt_tm_fmt, v_bar,
    row + 1
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ELSE
  CALL echo("CMT_CONCEPT_EXTENSION table is not found! No flat file created")
 ENDIF
 CALL edwupdatescriptstatus("CON_EXTN",record_cnt,"2","2")
 CALL echo(build("CON_EXTN Count = ",record_cnt))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "002 05/23/07 JW104069"
END GO
