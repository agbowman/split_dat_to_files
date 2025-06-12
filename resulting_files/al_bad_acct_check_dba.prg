CREATE PROGRAM al_bad_acct_check:dba
 DECLARE ml_rs_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_e_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_e_cmrn = i4 WITH protect, noconstant(0)
 FREE RECORD acc_rs
 RECORD acc_rs(
   1 list[*]
     2 s_cmrn = vc
     2 s_acct = vc
     2 qual[*]
       3 f_encntr_id = f8
       3 elst[*]
         4 e_cmrn = vc
 ) WITH protect
 DECLARE ml_loc_idx = i4
 DECLARE ml_loc_idx2 = i4
 FREE RECORD an_sing_rs
 RECORD an_sing_rs(
   1 cnt = i4
   1 list[*]
     2 account = vc
     2 cmrn = vc
 ) WITH protect
 FOR (ml_rs_cnt = 1 TO size(requestin->list_0,5))
   IF (ml_rs_cnt=1)
    SET an_sing_rs->cnt = (an_sing_rs->cnt+ 1)
    SET stat = alterlist(an_sing_rs->list,an_sing_rs->cnt)
    SET an_sing_rs->list[an_sing_rs->cnt].account = requestin->list_0[ml_rs_cnt].account
    SET an_sing_rs->list[an_sing_rs->cnt].cmrn = requestin->list_0[ml_rs_cnt].cmrn
   ELSE
    SET ml_loc_idx = locateval(ml_loc_idx2,1,an_sing_rs->cnt,requestin->list_0[ml_rs_cnt].account,
     an_sing_rs->list[ml_loc_idx2].account)
    IF (ml_loc_idx=0)
     SET an_sing_rs->cnt = (an_sing_rs->cnt+ 1)
     SET stat = alterlist(an_sing_rs->list,an_sing_rs->cnt)
     SET an_sing_rs->list[an_sing_rs->cnt].account = requestin->list_0[ml_rs_cnt].account
     SET an_sing_rs->list[an_sing_rs->cnt].cmrn = requestin->list_0[ml_rs_cnt].cmrn
    ELSE
     IF ((an_sing_rs->list[ml_loc_idx].cmrn != requestin->list_0[ml_rs_cnt].cmrn))
      SET an_sing_rs->cnt = (an_sing_rs->cnt+ 1)
      SET stat = alterlist(an_sing_rs->list,an_sing_rs->cnt)
      SET an_sing_rs->list[an_sing_rs->cnt].account = requestin->list_0[ml_rs_cnt].account
      SET an_sing_rs->list[an_sing_rs->cnt].cmrn = requestin->list_0[ml_rs_cnt].cmrn
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 FOR (ml_rs_cnt = 1 TO an_sing_rs->cnt)
   SET stat = alterlist(acc_rs->list,ml_rs_cnt)
   SET acc_rs->list[ml_rs_cnt].s_acct = trim(an_sing_rs->list[ml_rs_cnt].account,3)
   SET acc_rs->list[ml_rs_cnt].s_cmrn = trim(an_sing_rs->list[ml_rs_cnt].cmrn,3)
 ENDFOR
 CALL echorecord(acc_rs)
 FOR (ml_rs_cnt = 1 TO size(acc_rs->list,5))
   SET ml_e_cnt = 0
   SELECT INTO "nl:"
    FROM encntr_alias ea
    WHERE (ea.alias=acc_rs->list[ml_rs_cnt].s_acct)
     AND ea.encntr_alias_type_cd=1077.0
     AND ea.active_ind=1
    DETAIL
     ml_e_cnt = (ml_e_cnt+ 1), stat = alterlist(acc_rs->list[ml_rs_cnt].qual,ml_e_cnt), acc_rs->list[
     ml_rs_cnt].qual[ml_e_cnt].f_encntr_id = ea.encntr_id
    WITH nocounter
   ;end select
   IF (ml_e_cnt != 1)
    CALL echo("ANGELCE")
    CALL echo(ml_e_cnt)
    CALL echo(acc_rs->list[ml_rs_cnt].s_acct)
   ENDIF
 ENDFOR
 FOR (ml_rs_cnt = 1 TO size(acc_rs->list,5))
   IF (size(acc_rs->list[ml_rs_cnt].qual,5) > 0)
    FOR (ml_e_cnt = 1 TO size(acc_rs->list[ml_rs_cnt].qual,5))
     SET ml_e_cmrn = 0
     SELECT INTO "nl:"
      FROM encounter e,
       person_alias pa
      WHERE (e.encntr_id=acc_rs->list[ml_rs_cnt].qual[ml_e_cnt].f_encntr_id)
       AND pa.person_id=e.person_id
       AND pa.person_alias_type_cd=2.0
       AND pa.active_ind=1
       AND pa.end_effective_dt_tm > sysdate
      DETAIL
       ml_e_cmrn = (ml_e_cmrn+ 1), stat = alterlist(acc_rs->list[ml_rs_cnt].qual[ml_e_cnt].elst,
        ml_e_cmrn), acc_rs->list[ml_rs_cnt].qual[ml_e_cnt].elst[ml_e_cmrn].e_cmrn = trim(pa.alias)
       IF ((acc_rs->list[ml_rs_cnt].qual[ml_e_cnt].elst[ml_e_cmrn].e_cmrn=trim(acc_rs->list[ml_rs_cnt
        ].s_cmrn)))
        IF (size(acc_rs->list[ml_rs_cnt].qual,5) > 1)
         CALL echo("ANGMIS FOUND"),
         CALL echo(acc_rs->list[ml_rs_cnt].s_acct),
         CALL echo(acc_rs->list[ml_rs_cnt].s_cmrn),
         CALL echo(acc_rs->list[ml_rs_cnt].qual[ml_e_cnt].elst[ml_e_cmrn].e_cmrn)
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
    ENDFOR
   ENDIF
 ENDFOR
 FREE RECORD al_out
 RECORD al_out(
   1 cnt = i4
   1 list[*]
     2 s_cmrn = vc
     2 s_acct = vc
     2 s_enc = f8
     2 e_cmrn = vc
 )
 DECLARE al_siz = i4
 DECLARE al_siz2 = i4
 FOR (ml_rs_cnt = 1 TO size(acc_rs->list,5))
  SET al_siz = size(acc_rs->list[ml_rs_cnt].qual,5)
  IF (al_siz > 1)
   FOR (ml_e_cnt = 1 TO al_siz)
    SET al_siz2 = size(acc_rs->list[ml_rs_cnt].qual[ml_e_cnt].elst,5)
    IF (al_siz2 > 0)
     FOR (ml_e_cmrn = 1 TO al_siz2)
       SET al_out->cnt = (al_out->cnt+ 1)
       SET stat = alterlist(al_out->list,al_out->cnt)
       SET al_out->list[al_out->cnt].s_cmrn = acc_rs->list[ml_rs_cnt].s_cmrn
       SET al_out->list[al_out->cnt].s_acct = acc_rs->list[ml_rs_cnt].s_acct
       SET al_out->list[al_out->cnt].s_enc = acc_rs->list[ml_rs_cnt].qual[ml_e_cnt].f_encntr_id
       SET al_out->list[al_out->cnt].e_cmrn = acc_rs->list[ml_rs_cnt].qual[ml_e_cnt].elst[ml_e_cmrn].
       e_cmrn
     ENDFOR
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
 DECLARE al_out2 = vc
 SET al_out2 = "al_out_test2.txt"
 DECLARE output_string = vc
 CALL echorecord(al_out)
 SELECT INTO value(al_out2)
  FROM (dummyt d  WITH seq = al_out->cnt)
  PLAN (d
   WHERE d.seq > 0)
  HEAD REPORT
   col 1, "ACCOUNT,", "S_CMRN,",
   "ENCOUNTER,", "E_CMRN,"
  DETAIL
   row + 1, output_string = build('"',al_out->list[d.seq].s_acct,'"',',"',al_out->list[d.seq].s_cmrn,
    '"',',"',al_out->list[d.seq].s_enc,'"',',"',
    al_out->list[d.seq].e_cmrn,'"'), col 1,
   output_string
  WITH format = variable, formfeed = none, maxcol = 2000
 ;end select
#exit_script
END GO
