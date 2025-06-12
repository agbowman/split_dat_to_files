CREATE PROGRAM bhs_fix_muse_format:dba
 DECLARE mf_url_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23,"URL"))
 DECLARE mf_surl_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",25,"URL"))
 DECLARE ml_for_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_updt_cnt = i4 WITH protect, noconstant(0)
 CALL echo(mf_url_cd)
 CALL echo(mf_surl_cd)
 FOR (ml_for_cnt = 1 TO 200)
   CALL echo(build("Loop: ",ml_for_cnt))
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="BHS_MUSE_FIX"
     AND di.info_name="STOP"
    WITH nocounter
   ;end select
   IF (curqual != 0)
    CALL echo("User Stopped process")
    GO TO exit_program
   ENDIF
   UPDATE  FROM ce_blob_result cbr
    SET cbr.format_cd = mf_url_cd, cbr.updt_dt_tm = sysdate
    WHERE cbr.blob_handle="http://*musescripts*"
     AND cbr.storage_cd=mf_surl_cd
     AND cbr.format_cd != mf_url_cd
    WITH maxqual(cbr,5000)
   ;end update
   SET ml_updt_cnt = (ml_updt_cnt+ curqual)
   CALL echo(build("Total updated: ",ml_updt_cnt))
   CALL echo(curqual)
   COMMIT
   IF (curqual < 5000)
    CALL echo("Count is less than qual, stopping")
    GO TO exit_program
   ENDIF
 ENDFOR
#exit_program
END GO
