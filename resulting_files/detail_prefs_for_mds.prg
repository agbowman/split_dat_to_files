CREATE PROGRAM detail_prefs_for_mds
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
 SELECT INTO  $OUTDEV
  d.active_ind, d.application_number, d.comp_name,
  d.comp_seq, d.detail_prefs_id, d.person_id,
  d.position_cd, d_position_disp = uar_get_code_display(d.position_cd), d.prsnl_id,
  d.updt_applctx, d.updt_cnt, d.updt_dt_tm,
  d.updt_id, d.updt_task, d.view_name,
  d.view_seq
  FROM detail_prefs d
  WHERE ((d.position_cd=925824) OR (((d.position_cd=925841) OR (((d.position_cd=925830) OR (((d
  .position_cd=925831) OR (((d.position_cd=925842) OR (((d.position_cd=925825) OR (((d.position_cd=
  925832) OR (((d.position_cd=925833) OR (((d.position_cd=925843) OR (((d.position_cd=925834) OR (((d
  .position_cd=925835) OR (((d.position_cd=925844) OR (((d.position_cd=1646210) OR (((d.position_cd=
  925826) OR (((d.position_cd=925836) OR (((d.position_cd=925845) OR (((d.position_cd=925846) OR (((d
  .position_cd=719476) OR (((d.position_cd=925827) OR (((d.position_cd=925847) OR (((d.position_cd=
  925828) OR (((d.position_cd=925837) OR (((d.position_cd=925851) OR (((d.position_cd=925852) OR (d
  .position_cd=925848)) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
  ORDER BY d_position_disp, d.view_seq
  WITH time = value(maxsecs), format, separator = value(_separator),
   skipreport = 1
 ;end select
END GO
