CREATE PROGRAM bhs_syn_med_rec_query4_ev:dba
 FREE RECORD t_record
 RECORD t_record(
   1 encntr_id = f8
   1 elh_id1 = f8
   1 nu_id1 = f8
   1 beg_dt_tm = dq8
   1 elh_id2 = f8
   1 nu_id2 = f8
   1 end_dt_tm = dq8
 )
 SET retval = 0
 SET t_record->encntr_id = trigger_encntrid
 DECLARE icua_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUA"))
 DECLARE icub_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUB"))
 DECLARE icuc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICUC"))
 DECLARE cicu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"CICU"))
 DECLARE iccu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICCU"))
 DECLARE icu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"ICU"))
 DECLARE pcu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"PCU"))
 DECLARE nccn_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"NCCN"))
 DECLARE nicu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"NICU"))
 DECLARE picu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"PICU"))
 DECLARE nnura_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"NNURA"))
 DECLARE nnurb_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"NNURB"))
 DECLARE nnurc_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"NNURC"))
 DECLARE nnurd_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"NNURD"))
 DECLARE pahld_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"PAHLD"))
 DECLARE cvcu_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"CVCU"))
 DECLARE cvic_cd = f8 WITH public, constant(uar_get_code_by("DISPLAY_KEY",220,"CVIC"))
 SET fmced = uar_get_code_by("displaykey",220,"FMCEMERGENCY")
 SET bmcedgen = uar_get_code_by("displaykey",220,"EMERGENCYGENER")
 SET bmctrauma = uar_get_code_by("displaykey",220,"EMERGENCYTRAUM")
 SET bmcpedi = uar_get_code_by("displaykey",220,"EMERGENCYPEDI")
 SET bmced = uar_get_code_by("displaykey",220,"BMCEMERGENCY")
 SET eshld = uar_get_code_by("displaykey",220,"ESHLD")
 SET edau = uar_get_code_by("displaykey",220,"EDAU")
 SET ambsg = uar_get_code_by("displaykey",220,"AMBSG")
 SET edhld = uar_get_code_by("displaykey",220,"EDHLD")
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh
  PLAN (elh
   WHERE (elh.encntr_id=t_record->encntr_id)
    AND  NOT ( EXISTS (
   (SELECT
    elh1.encntr_id
    FROM encntr_loc_hist elh1
    WHERE elh1.encntr_id=elh.encntr_id
     AND elh1.beg_effective_dt_tm > elh.beg_effective_dt_tm))))
  DETAIL
   t_record->elh_id1 = elh.encntr_loc_hist_id, t_record->nu_id1 = elh.loc_nurse_unit_cd
  WITH nocounter
 ;end select
 CALL echo(build("nu_id1:",t_record->nu_id1))
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh
  PLAN (elh
   WHERE (elh.encntr_id=t_record->encntr_id)
    AND (elh.loc_nurse_unit_cd != t_record->nu_id1))
  ORDER BY elh.beg_effective_dt_tm
  FOOT  elh.beg_effective_dt_tm
   t_record->elh_id2 = elh.encntr_loc_hist_id, t_record->nu_id2 = elh.loc_nurse_unit_cd, t_record->
   end_dt_tm = cnvtdatetime(elh.end_effective_dt_tm)
  WITH nocounter
 ;end select
 CALL echo(build("nu_id2: ",t_record->nu_id2))
 SET nu1 = 0
 SET nu2 = 0
 IF ((t_record->nu_id1 IN (icua_cd, icub_cd, icuc_cd, iccu_cd, cicu_cd,
 icu_cd, pcu_cd, cvcu_cd, cvic_cd)))
  SET nu1 = 1
 ENDIF
 CALL echo(build("NU1:",nu1))
 IF ((t_record->nu_id2 IN (icua_cd, icub_cd, icuc_cd, iccu_cd, cicu_cd,
 icu_cd, pcu_cd, cvcu_cd, cvic_cd)))
  SET nu2 = 1
 ENDIF
 CALL echo(build("NU2:",nu2))
 IF (((nu1=1
  AND nu2=0) OR (nu1=0
  AND nu2=1)) )
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
 CALL echo(build("retval:",retval))
END GO
