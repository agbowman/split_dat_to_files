CREATE PROGRAM bhs_eks_upd_person_id:dba
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_cmrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"CMRN"))
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(trigger_encntrid)
 DECLARE mf_person_id = f8 WITH protect, noconstant(trigger_personid)
 DECLARE log_message = vc WITH public, noconstant(" ")
 DECLARE ms_fin = vc WITH protect, noconstant(" ")
 DECLARE ms_cmrn = vc WITH protect, noconstant(" ")
 SELECT
  *
  FROM code_value cv
  WHERE cv.code_value=2
 ;end select
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE ea.encntr_id=mf_encntr_id
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  HEAD ea.encntr_id
   ms_fin = trim(ea.alias)
  WITH nocounter
 ;end select
 IF (((curqual < 1) OR (trim(ms_fin) <= " ")) )
  SET log_message = "FIN not found; "
 ENDIF
 SELECT INTO "nl:"
  FROM person_alias pa
  PLAN (pa
   WHERE pa.person_id=mf_person_id
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > sysdate
    AND pa.person_alias_type_cd=mf_cmrn_cd)
  HEAD pa.person_id
   ms_cmrn = trim(pa.alias)
  WITH nocounter
 ;end select
 IF (((curqual < 1) OR (trim(ms_cmrn) <= " ")) )
  SET log_message = concat(log_message,"CMRN not found;")
  IF (trim(ms_fin) <= " ")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (trim(ms_fin) > " ")
  CALL echo("select1")
  SELECT INTO "nl:"
   FROM bhs_demographics b
   PLAN (b
    WHERE b.acct_nbr=ms_fin
     AND b.corp_nbr=ms_cmrn
     AND b.person_id=0.0)
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1
   FOOT REPORT
    CALL echo(build2("found ",trim(cnvtstring(pl_cnt))," rows to update"))
   WITH nocounter
  ;end select
 ELSE
  CALL echo(build2("select2 cmrn: ",ms_cmrn))
  SELECT INTO "nl:"
   FROM bhs_demographics b
   PLAN (b
    WHERE b.corp_nbr=ms_cmrn
     AND b.person_id=0.0)
   HEAD REPORT
    pl_cnt = 0
   DETAIL
    pl_cnt += 1
   FOOT REPORT
    CALL echo(build2("found ",trim(cnvtstring(pl_cnt))," rows to update"))
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual < 1)
  SET log_message = "No rows found to update;"
  GO TO exit_script
 ENDIF
 IF (trim(ms_fin) > " ")
  CALL echo("updt1")
  UPDATE  FROM bhs_demographics b
   SET b.person_id = mf_person_id, b.updt_dt_tm = sysdate, b.updt_cnt = (b.updt_cnt+ 1),
    b.updt_id = reqinfo->updt_id
   PLAN (b
    WHERE b.acct_nbr=ms_fin
     AND b.corp_nbr=ms_cmrn
     AND b.person_id=0.0)
   WITH nocounter
  ;end update
 ELSE
  CALL echo("updt2")
  UPDATE  FROM bhs_demographics b
   SET b.person_id = mf_person_id, b.updt_dt_tm = sysdate, b.updt_cnt = (b.updt_cnt+ 1),
    b.updt_id = reqinfo->updt_id
   PLAN (b
    WHERE b.corp_nbr=ms_cmrn
     AND b.person_id=0.0)
   WITH nocounter
  ;end update
 ENDIF
 COMMIT
 SET log_message = "Rows updated;"
 SET retval = 100
#exit_script
 SET log_message = concat(log_message," EncntrID:",trim(cnvtstring(mf_encntr_id)),"; PersonID:",trim(
   cnvtstring(mf_person_id)),
  "; FIN:",ms_fin,"; CMRN:",ms_cmrn)
 CALL echo(log_message)
END GO
