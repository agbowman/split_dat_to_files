CREATE PROGRAM bhs_upd_prob_med_to_ft:dba
 DECLARE mf_medical_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12033,"MEDICAL"))
 DECLARE mf_freetext_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12033,"FREETEXT"))
 CALL echo(build2("mf_MEDICAL_CD: ",mf_medical_cd))
 CALL echo(build2("mf_FREETEXT_CD: ",mf_freetext_cd))
 DECLARE mn_stop = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 IF (((mf_medical_cd <= 0.0) OR (mf_freetext_cd < 0.0)) )
  IF (mf_medical_cd <= 0.0)
   CALL echo("MEDICAL code value not found on 12033")
  ENDIF
  IF (mf_freetext_cd <= 0.0)
   CALL echo("FREETEXT code value not found on 12033")
  ENDIF
  GO TO exit_script
 ENDIF
 WHILE (mn_stop=0)
   SET ml_cnt = (ml_cnt+ 1)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="BHS_UPD_PROB_MED_TO_FT"
     AND di.info_name="STOP"
    WITH nocounter
   ;end select
   IF (curqual != 0)
    CALL echo("User Stopped process")
    GO TO exit_script
   ENDIF
   UPDATE  FROM problem p
    SET p.classification_cd = mf_freetext_cd, p.updt_dt_tm = sysdate, p.updt_cnt = (p.updt_cnt+ 1),
     p.updt_id = 22226380.00
    WHERE p.nomenclature_id=0.0
     AND p.originating_nomenclature_id=0.0
     AND p.classification_cd=mf_medical_cd
     AND  NOT (trim(p.problem_ftdesc) IN ("", " ", null))
    WITH maxqual(p,5000), maxcommit = 1000
   ;end update
   IF (((curqual < 5000) OR (ml_cnt=200)) )
    SET mn_stop = 1
   ENDIF
 ENDWHILE
 COMMIT
#exit_script
END GO
