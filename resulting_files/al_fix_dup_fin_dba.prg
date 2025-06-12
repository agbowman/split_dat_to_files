CREATE PROGRAM al_fix_dup_fin:dba
 DECLARE ml_rs_cnt = i4
 FREE RECORD bad_enc
 RECORD bad_enc(
   1 cnt = i4
   1 list[*]
     2 encntr_id = f8
     2 end_date = dq8
     2 ea_act_ind = i2
     2 ea_end_eff_dt = dq8
     2 e_act_ind = i2
     2 e_dis_dt = dq8
     2 e_data_st_cd = f8
     2 e_end_eff_dt = dq8
     2 e_beg_eff_dt = dq8
     2 ed_end_eff_dt = dq8
 ) WITH protect
 FOR (ml_rs_cnt = 1 TO size(requestin->list_0,5))
   SET bad_enc->cnt = (bad_enc->cnt+ 1)
   SET stat = alterlist(bad_enc->list,ml_rs_cnt)
   SET bad_enc->list[ml_rs_cnt].encntr_id = cnvtreal(requestin->list_0[ml_rs_cnt].encounter)
 ENDFOR
 FOR (ml_rs_cnt = 1 TO bad_enc->cnt)
   CALL echo(ml_rs_cnt)
   SELECT INTO "nl:"
    FROM encounter e
    WHERE (e.encntr_id=bad_enc->list[ml_rs_cnt].encntr_id)
    DETAIL
     bad_enc->list[ml_rs_cnt].end_date = e.reg_dt_tm, bad_enc->list[ml_rs_cnt].e_act_ind = e
     .active_ind, bad_enc->list[ml_rs_cnt].e_dis_dt = e.disch_dt_tm,
     bad_enc->list[ml_rs_cnt].e_data_st_cd = e.data_status_cd, bad_enc->list[ml_rs_cnt].e_end_eff_dt
      = e.end_effective_dt_tm, bad_enc->list[ml_rs_cnt].e_beg_eff_dt = e.beg_effective_dt_tm
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encntr_alias ea
    WHERE (ea.encntr_id=bad_enc->list[ml_rs_cnt].encntr_id)
    DETAIL
     bad_enc->list[ml_rs_cnt].ea_act_ind = ea.active_ind, bad_enc->list[ml_rs_cnt].ea_end_eff_dt = ea
     .end_effective_dt_tm
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encntr_domain ed
    WHERE (ed.encntr_id=bad_enc->list[ml_rs_cnt].encntr_id)
    DETAIL
     bad_enc->list[ml_rs_cnt].ed_end_eff_dt = ed.end_effective_dt_tm
    WITH nocounter
   ;end select
   UPDATE  FROM encntr_alias ea
    SET ea.active_ind = 0, ea.end_effective_dt_tm = (sysdate - 1), ea.updt_dt_tm = sysdate,
     ea.updt_cnt = (ea.updt_cnt+ 1)
    WHERE (ea.encntr_id=bad_enc->list[ml_rs_cnt].encntr_id)
    WITH nocounter
   ;end update
   UPDATE  FROM encounter e
    SET e.disch_dt_tm = sysdate, e.active_ind = 0, e.data_status_cd = 28,
     e.updt_dt_tm = sysdate, e.end_effective_dt_tm = sysdate, e.updt_cnt = (e.updt_cnt+ 1)
    WHERE (e.encntr_id=bad_enc->list[ml_rs_cnt].encntr_id)
   ;end update
   UPDATE  FROM encntr_domain ed
    SET ed.end_effective_dt_tm = sysdate, ed.updt_dt_tm = sysdate, ed.beg_effective_dt_tm = sysdate
    WHERE (encntr_id=bad_enc->list[ml_rs_cnt].encntr_id)
   ;end update
 ENDFOR
 CALL echorecord(bad_enc)
END GO
