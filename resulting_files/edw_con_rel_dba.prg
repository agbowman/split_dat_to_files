CREATE PROGRAM edw_con_rel:dba
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SELECT INTO value(con_rel_extractfile)
  n_characteristic_type_flag = nullind(c.characteristic_type_flag), n_refinability_flag = nullind(c
   .refinability_flag)
  FROM cmt_concept_reltn c
  WHERE c.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   reltngroup = validate(c.reltn_group,0), col 0, health_system_source_id,
   v_bar,
   CALL print(trim(replace(build(c.concept_cki1,"~",c.concept_cki2,"~",c.relation_cki,
      "~",validate(c.reltn_identifier,"")),str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(c.concept_cki2,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(c.relation_cki,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(c.concept_cki1,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(validate(c.reltn_identifier,""),str_find,str_replace,3))), v_bar,
   CALL print(trim(evaluate(reltngroup,0,blank_field,build(reltngroup)))),
   v_bar,
   CALL print(trim(evaluate(n_characteristic_type_flag,0,build(c.characteristic_type_flag),
     blank_field))), v_bar,
   CALL print(trim(evaluate(n_refinability_flag,0,build(c.refinability_flag),blank_field))), v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,c.beg_effective_dt_tm,0,cnvtdatetimeutc(c
       .beg_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))),
   v_bar,
   CALL print(trim(datetimezoneformat(evaluate(curutc,1,c.end_effective_dt_tm,0,cnvtdatetimeutc(c
       .end_effective_dt_tm,3)),utc_timezone_index,"MM/DD/YYYY HH:mm"))), v_bar,
   CALL print(build(c.active_ind)), v_bar, extract_dt_tm_fmt,
   v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1
 ;end select
 CALL echo(build("CON_REL Count = ",curqual))
 CALL edwupdatescriptstatus("CON_REL",curqual,"1","1")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "002 05/23/07 JW014069"
END GO
