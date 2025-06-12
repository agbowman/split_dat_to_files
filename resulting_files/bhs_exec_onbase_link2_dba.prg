CREATE PROGRAM bhs_exec_onbase_link2:dba
 DECLARE ml_loop_parent = i4
 DECLARE ml_row_cnt = i4
 DECLARE errmsg2 = vc
 DECLARE errcode2 = i4
 DECLARE mf_total_rows = f8 WITH protect, noconstant(0.0)
 SET ml_loop_parent = 1
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 WHILE (ml_loop_parent=1)
   SELECT INTO "nl:"
    FROM dm_info di
    WHERE di.info_domain="BHS_ONBASE_CONVERSION"
     AND di.info_name="STOP"
    WITH nocounter
   ;end select
   IF (curqual != 0)
    CALL echo("User Stopped process")
    GO TO exit_program
   ENDIF
   SET ml_row_cnt = 0
   SELECT INTO "nl:"
    FROM bhs_onbase_stage@jtest bos
    WHERE bos.onbase_stage_id >= 8261343.0
     AND bos.onbase_stage_id < 8380287.0
     AND bos.update_ind=0
    DETAIL
     ml_row_cnt = (ml_row_cnt+ 1)
    WITH nocounter, maxqual(bos,1000)
   ;end select
   IF (ml_row_cnt != 0)
    EXECUTE bhs_cnvt_onbase_link 8261343.0, 8380287.0
    SET errcode2 = error(errmsg2,0)
    IF (errcode2 != 0)
     CALL echo("ERROR")
     CALL echo(errmsg2)
     GO TO exit_program
    ENDIF
    IF (ml_row_cnt < 1000)
     SET ml_loop_parent = 0
    ENDIF
   ELSE
    SET ml_loop_parent = 0
   ENDIF
 ENDWHILE
#exit_program
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
END GO
