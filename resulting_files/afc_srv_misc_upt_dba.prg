CREATE PROGRAM afc_srv_misc_upt:dba
 CALL echo(
  "##############################################################################################")
 SUBROUTINE updatediagnostics(dummy)
   CALL echo("UpdateDiagnostics")
   CALL echo("   charge_event_act_id = ",0)
   CALL echo( $7)
   CALL echo("   srv_diag_cd         = ",0)
   CALL echo( $2)
   CALL echo("   srv_diag1_id        = ",0)
   CALL echo( $3)
   CALL echo("   srv_diag2_id        = ",0)
   CALL echo( $4)
   CALL echo("   srv_diag3_id        = ",0)
   CALL echo( $5)
   CALL echo("   srv_diag4_id        = ",0)
   CALL echo( $6)
   UPDATE  FROM charge_event_act
    SET srv_diag_cd =  $2, srv_diag1_id =  $3, srv_diag2_id =  $4,
     srv_diag3_id =  $5, srv_diag4_id =  $6
    WHERE (charge_event_act_id= $7)
   ;end update
   COMMIT
 END ;Subroutine
 SUBROUTINE updatechargeeventdb_lock(dummy)
   CALL echo("UpdateChargeEventDB_Lock")
   CALL echo("   charge_event_id = ",0)
   CALL echo( $2)
   CALL echo("   updt_cnt        = updt_cnt + 1")
   UPDATE  FROM charge_event
    SET updt_cnt = (updt_cnt+ 1)
    WHERE (charge_event_id= $2)
   ;end update
 END ;Subroutine
 SUBROUTINE updatechargeevent_createcharge(dummy)
   CALL echo("UpdateChargeEvent_CreateCharge")
   CALL echo("   bill_item_id    = ",0)
   CALL echo( $2)
   CALL echo("   charge_event_id = ",0)
   CALL echo( $3)
   UPDATE  FROM charge_event
    SET bill_item_id =  $2
    WHERE (charge_event_id= $3)
   ;end update
   COMMIT
 END ;Subroutine
 SUBROUTINE updatechargeprocessflg(dummy)
   CALL echo("UpdateChargeProcessFlg")
   CALL echo("   charge_item_id = ",0)
   CALL echo( $2)
   CALL echo("   set process_flg = 10, updt_task = 951020")
   UPDATE  FROM charge
    SET process_flg = 10, updt_task = 951020
    WHERE (charge_item_id= $2)
   ;end update
   COMMIT
 END ;Subroutine
 SUBROUTINE updatechargeevent_cancell(dummy)
   CALL echo("UpdateChargeEvent_Cancell")
   CALL echo("   charge_event_id = ",0)
   CALL echo( $2)
   CALL echo("   cancelled_ind = 1, cancelled_dt_tm = cnvtdatetime(curdate,curtime)")
   UPDATE  FROM charge_event
    SET cancelled_ind = 1, cancelled_dt_tm = cnvtdatetime(curdate,curtime)
    WHERE (charge_event_id= $2)
   ;end update
   COMMIT
 END ;Subroutine
 SUBROUTINE updatechargemod(dummy)
   CALL echo("UpdateChargeMod")
   CALL echo("   charge_item_id = ",0)
   CALL echo( $2)
   CALL echo("   active_ind = 0, updt_id = 951020, updt_dt_tm = cnvtdatetime(curdate,curtime)")
   UPDATE  FROM charge_mod
    SET active_ind = 0, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 951020
    WHERE (charge_item_id= $2)
   ;end update
   COMMIT
 END ;Subroutine
 SUBROUTINE updatecharge(dummy)
   CALL echo("UpdateCharge")
   CALL echo("   charge_item_id = ",0)
   CALL echo( $2)
   CALL echo("   active_ind = 0, updt_id = 951020, updt_dt_tm = cnvtdatetime(curdate,curtime)")
   UPDATE  FROM charge
    SET active_ind = 0, updt_dt_tm = cnvtdatetime(curdate,curtime), updt_id = 951020
    WHERE (charge_item_id= $2)
   ;end update
   COMMIT
 END ;Subroutine
 CASE ( $1)
  OF 1:
   CALL updatediagnostics("dummy")
  OF 2:
   CALL updatechargeeventdb_lock("dummy")
  OF 3:
   CALL updatechargeevent_createcharge("dummy")
  OF 4:
   CALL updatechargeprocessflg("dummy")
  OF 5:
   CALL updatechargeevent_cancell("dummy")
  OF 6:
   CALL updatechargemod("dummy")
  OF 7:
   CALL updatecharge("dummy")
  ELSE
   CALL echo("unknown")
 ENDCASE
 CALL echo(
  "##############################################################################################")
END GO
