CREATE PROGRAM edw_code_value_grp:dba
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SELECT INTO value(cd_grp_extractfile)
  n_collation_seq = nullind(cd.collation_seq), n_code_set = nullind(cd.code_set)
  FROM code_value_group cd
  WHERE cd.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)
  DETAIL
   col 0, health_system_source_id, v_bar,
   CALL print(build(cnvtstring(cd.parent_code_value,16),"~",cnvtstring(cd.child_code_value,16))),
   v_bar,
   CALL print(trim(evaluate(n_code_set,0,build(cd.code_set)," "))),
   v_bar,
   CALL print(trim(cnvtstring(cd.child_code_value,16))), v_bar,
   CALL print(trim(cnvtstring(cd.parent_code_value,16))), v_bar,
   CALL print(trim(evaluate(n_collation_seq,0,build(cd.collation_seq)," "))),
   v_bar, "3", v_bar,
   extract_dt_tm_fmt, v_bar, row + 1
  WITH noheading, nocounter, format = lfstream,
   maxcol = 1999, maxrow = 1, append
 ;end select
 CALL echo(build("CD_GRP Count = ",curqual))
 CALL edwupdatescriptstatus("CD_GRP",curqual,"0","0")
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 07/10/07 AO9323"
END GO
