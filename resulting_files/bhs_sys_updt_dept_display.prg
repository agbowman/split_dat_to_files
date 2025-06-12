CREATE PROGRAM bhs_sys_updt_dept_display
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter catalog code to view/update" = "0.00",
  "Sychronize Department Displays with Primary Mnemonics" = "0"
  WITH outdev, updt_cat_cd, run_update
 DECLARE run_update_ind = i2
 DECLARE user_updt_id = f8
 DECLARE cs6011_primary_cd = f8 WITH constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 IF (cnvtreal( $RUN_UPDATE)=1)
  SET run_update_ind = 1
 ELSE
  SET run_update_ind = 0
 ENDIF
 CALL echo(build2("run_update_ind = ",trim(build(run_update_ind),3)))
 IF (run_update_ind=1
  AND cnvtreal( $UPDT_CAT_CD) <= 0.00)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   PLAN (d)
   HEAD REPORT
    col 1, "Cannot update all departmental display names.", row + 1,
    col 1, "Please enter catalog_cd to update or uncheck 'sychronize...'"
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (validate(reqinfo->updt_id,0.00) <= 0.00)
  SELECT INTO "nl:"
   FROM prsnl pr
   WHERE pr.username=curuser
   DETAIL
    user_updt_id = pr.person_id
   WITH nocounter
  ;end select
 ELSE
  SET user_updt_id = reqinfo->updt_id
 ENDIF
 CALL echo(build2("user_updt_id = ",trim(build2(user_updt_id),3)))
 IF (user_updt_id <= 0.00)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   PLAN (d)
   HEAD REPORT
    col 1, "No user id found. Exitting Script", row + 1,
    col 1,
    CALL print(build2("isodbc = ",isodbc)), row + 1,
    col 1,
    CALL print(build2("curuser = ",validate(curuser," "))), row + 1,
    col 1,
    CALL print(build2("reqinfo->updt_id = ",validate(reqinfo->updt_id,0.00)))
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 FREE RECORD temp
 RECORD temp(
   1 cnt = i4
   1 rows[*]
     2 catalog_cd = f8
     2 mnemonic = vc
     2 update_ind = i2
     2 error = i4
     2 err_msg = vc
 )
 SELECT INTO "nl:"
  oc.dept_display_name, ocs.mnemonic
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.active_ind=1
    AND ((cnvtreal( $UPDT_CAT_CD) <= 0.00) OR (cnvtreal( $UPDT_CAT_CD)=oc.catalog_cd)) )
   JOIN (ocs
   WHERE oc.catalog_cd=ocs.catalog_cd
    AND ocs.mnemonic_type_cd=cs6011_primary_cd
    AND ((cnvtreal( $UPDT_CAT_CD) <= 0.00
    AND oc.dept_display_name != ocs.mnemonic) OR (cnvtreal( $UPDT_CAT_CD) > 0.00)) )
  ORDER BY ocs.mnemonic_key_cap
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (oc.catalog_cd > 0.00)
    cnt = (temp->cnt+ 1), temp->cnt = cnt, stat = alterlist(temp->rows,temp->cnt),
    temp->rows[cnt].catalog_cd = oc.catalog_cd, temp->rows[cnt].mnemonic = ocs.mnemonic
   ENDIF
  WITH nocounter
 ;end select
 IF (run_update_ind=1)
  FOR (r = 1 TO temp->cnt)
    UPDATE  FROM order_catalog oc
     SET oc.dept_display_name = temp->rows[r].mnemonic, oc.updt_task = 999, oc.updt_dt_tm =
      cnvtdatetime(curdate,curtime3),
      oc.updt_cnt = (oc.updt_cnt+ 1), oc.updt_id = user_updt_id
     PLAN (oc
      WHERE (oc.catalog_cd=temp->rows[r].catalog_cd))
     WITH nocounter
    ;end update
    SET temp->rows[r].error = error(temp->rows[r].err_msg,0)
    IF ((temp->rows[r].error != 0))
     SET temp->rows[r].update_ind = - (1)
     ROLLBACK
    ELSE
     SET temp->rows[r].update_ind = 1
     COMMIT
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = value(temp->cnt)),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (temp->rows[d.seq].catalog_cd=oc.catalog_cd))
  HEAD REPORT
   col 0, "CATALOG_CD", col 15,
   "PRIMARY_MNEMONIC", col 116, "DEPT_DISPLAY_NAME",
   col 217, "UPDT_TASK", col 229,
   "UPDT_DT_TM", col 250, "UPDT_CNT",
   col 262, "UPDT_ID", col 277,
   "ERROR"
  DETAIL
   IF (oc.catalog_cd > 0.00)
    row + 1, col 0, temp->rows[d.seq].catalog_cd,
    col 15, temp->rows[d.seq].mnemonic, col 116,
    oc.dept_display_name, col 217, oc.updt_task,
    col 229,
    CALL print(format(oc.updt_dt_tm,"mm/dd/yyyy hh:mm:ss;;d")), col 250,
    oc.updt_cnt, col 262, oc.updt_id
    IF (run_update_ind=1)
     IF ((temp->rows[d.seq].update_ind=- (1)))
      col 277,
      CALL print(build2(trim(build(temp->rows[d.seq].error),3),": ",trim(temp->rows[d.seq].err_msg,3)
       ))
     ELSEIF ((temp->rows[d.seq].update_ind=0))
      col 277, "0: Unknown error. Entry not updated"
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, maxcol = 500, maxrow = 1,
   formfeed = none, format = variable
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  WITH skipreport = 1
 ;end select
#exit_script
END GO
