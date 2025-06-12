CREATE PROGRAM edw_con_expl:dba
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SELECT INTO value(con_expl_extractfile)
  FROM cmt_concept_explode c
  WHERE c.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(trim(replace(build(c.parent_concept_cki,"~",c.child_concept_cki),str_find,str_replace,3
     ))), v_bar,
   CALL print(trim(replace(c.parent_concept_cki,str_find,str_replace,3))),
   v_bar,
   CALL print(trim(replace(c.child_concept_cki,str_find,str_replace,3))), v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1
 ;end select
 CALL echo(build("CON_EXPL Count = ",curqual))
 CALL edwupdatescriptstatus("CON_EXPL",curqual,"2","2")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "002 05/23/07 JW014069"
END GO
