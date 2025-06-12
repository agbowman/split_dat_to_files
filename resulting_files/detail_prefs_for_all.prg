CREATE PROGRAM detail_prefs_for_all
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 IF (validate(isodbc,0)=0)
  EXECUTE cclseclogin
 ENDIF
 SET _separator = ""
 IF (validate(isodbc,0)=0)
  SET _separator = " "
 ENDIF
 SET maxsecs = 0
 IF (validate(isodbc,0)=1)
  SET maxsecs = 15
 ENDIF
 SELECT DISTINCT INTO  $OUTDEV
  d_position_disp = uar_get_code_display(d.position_cd), d.position_cd, d.view_name,
  d.comp_name, d.detail_prefs_id, d.view_seq,
  d.active_ind, d.application_number, d.comp_seq,
  d.person_id, d.prsnl_id, d.updt_applctx,
  d.updt_cnt, d.updt_dt_tm, d.updt_id,
  d.updt_task
  FROM detail_prefs d
  WHERE d.active_ind=1
   AND ((d.position_cd=880830) OR (((d.position_cd=880882) OR (((d.position_cd=880883) OR (((d
  .position_cd=925824) OR (((d.position_cd=2063395) OR (((d.position_cd=922120) OR (((d.position_cd=
  966300) OR (((d.position_cd=2399306) OR (((d.position_cd=2063396) OR (((d.position_cd=884325) OR (
  ((d.position_cd=925841) OR (((d.position_cd=884839) OR (((d.position_cd=962754) OR (((d.position_cd
  =2063397) OR (((d.position_cd=925830) OR (((d.position_cd=104370545) OR (((d.position_cd=634812)
   OR (((d.position_cd=950103) OR (((d.position_cd=2399307) OR (((d.position_cd=925831) OR (((d
  .position_cd=686743) OR (((d.position_cd=2063398) OR (((d.position_cd=1447374) OR (((d.position_cd=
  719677) OR (((d.position_cd=2063399) OR (((d.position_cd=885562) OR (((d.position_cd=1465245) OR (
  ((d.position_cd=925825) OR (((d.position_cd=1465246) OR (((d.position_cd=36409588) OR (((d
  .position_cd=36572393) OR (((d.position_cd=119781217) OR (((d.position_cd=925843) OR (((d
  .position_cd=925832) OR (((d.position_cd=925833) OR (((d.position_cd=1447375) OR (((d.position_cd=
  905956) OR (((d.position_cd=908707) OR (((d.position_cd=925834) OR (((d.position_cd=120709982) OR (
  ((d.position_cd=637897) OR (((d.position_cd=6651142) OR (((d.position_cd=2387193) OR (((d
  .position_cd=637899) OR (((d.position_cd=637900) OR (((d.position_cd=2634874) OR (((d.position_cd=
  637042) OR (((d.position_cd=637041) OR (((d.position_cd=777650) OR (((d.position_cd=966301) OR (((d
  .position_cd=925835) OR (((d.position_cd=907028) OR (((d.position_cd=907029) OR (((d.position_cd=
  925844) OR (((d.position_cd=1646210) OR (((d.position_cd=907609) OR (((d.position_cd=2063400) OR (
  ((d.position_cd=1713124) OR (((d.position_cd=457) OR (((d.position_cd=908706) OR (((d.position_cd=
  984626) OR (((d.position_cd=925826) OR (((d.position_cd=37333948) OR (((d.position_cd=722943) OR (
  ((d.position_cd=925836) OR (((d.position_cd=925845) OR (((d.position_cd=65699687) OR (((d
  .position_cd=35742713) OR (((d.position_cd=35742679) OR (((d.position_cd=35742669) OR (((d
  .position_cd=69178498) OR (((d.position_cd=69178474) OR (((d.position_cd=922119) OR (((d
  .position_cd=909831) OR (((d.position_cd=637054) OR (((d.position_cd=1571561) OR (((d.position_cd=
  746080) OR (((d.position_cd=2063401) OR (((d.position_cd=925846) OR (((d.position_cd=2399308) OR (
  ((d.position_cd=719476) OR (((d.position_cd=925827) OR (((d.position_cd=908013) OR (((d.position_cd
  =54010344) OR (((d.position_cd=884326) OR (((d.position_cd=925847) OR (((d.position_cd=2063402) OR
  (((d.position_cd=2063403) OR (((d.position_cd=884324) OR (((d.position_cd=719555) OR (((d
  .position_cd=2063502) OR (((d.position_cd=966302) OR (((d.position_cd=879383) OR (((d.position_cd=
  637058) OR (((d.position_cd=879382) OR (((d.position_cd=925828) OR (((d.position_cd=909833) OR (((d
  .position_cd=2063404) OR (((d.position_cd=925837) OR (((d.position_cd=925850) OR (((d.position_cd=
  719554) OR (((d.position_cd=2063405) OR (((d.position_cd=909836) OR (((d.position_cd=2399309) OR (
  ((d.position_cd=719678) OR (((d.position_cd=451) OR (((d.position_cd=2399310) OR (((d.position_cd=
  909837) OR (((d.position_cd=925851) OR (((d.position_cd=719556) OR (((d.position_cd=925848) OR (((d
  .position_cd=441) OR (((d.position_cd=786870) OR (d.position_cd=64193183)) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  )) )) )) )) ))
  ORDER BY d_position_disp, d.view_seq, d.view_name,
   d.comp_name
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
