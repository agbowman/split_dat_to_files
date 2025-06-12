CREATE PROGRAM edw_concept:dba
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SELECT INTO value(concept_extractfile)
  n_concept_name = nullind(c.concept_name)
  FROM cmt_concept c
  WHERE c.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(trim(replace(c.concept_cki,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(c.concept_source_mean,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(c.concept_identifier,str_find,str_replace,3))), v_bar,
   CALL print(trim(replace(evaluate(n_concept_name,0,c.concept_name,blank_field),str_find,str_replace,
     3))), v_bar,
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
 CALL echo(build("CONCEPT Count = ",curqual))
 CALL edwupdatescriptstatus("CONCEPT",curqual,"1","1")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "002 05/23/07 JW014069"
END GO
