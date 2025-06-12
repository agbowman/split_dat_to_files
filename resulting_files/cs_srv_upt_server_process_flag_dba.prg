CREATE PROGRAM cs_srv_upt_server_process_flag:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 RECORD non_server_susp(
   1 list[*]
     2 code_value = f8
 )
 DECLARE suspcnt = i2
 SET suspcnt = 0
 CALL echo("Read suspense reason codes . . .")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13030
   AND cv.active_ind=1
   AND  NOT (cv.cdf_meaning IN ("NOBILLITEM", "NOICD9", "NORENDPHYS", "NOPAYORSCHED", "NOPARENTBI",
  "NOPPAYORSCHE", "NOPARENTCE", "NOINTERFACE", "ADDONBILL", "ADDONPRICE",
  "NOTIER", "PAYORIDZERO", "NOENCNTRID", "NOPERSONID", "CEBIIDSZERO",
  "CEPBIIDSZERO", "ADDONPAYOR", "NOORDER", "NOPARENTORDR"))
  DETAIL
   suspcnt += 1, stat = alterlist(non_server_susp->list,suspcnt), non_server_susp->list[suspcnt].
   code_value = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(build("Number of non server suspense reasons . . .",suspcnt))
 DECLARE suspensecd = f8
 SET suspensecd = 0
 CALL echo("Read 13019:SUSPENSE code value . . .")
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=13019
   AND cv.cdf_meaning="SUSPENSE"
   AND cv.active_ind=1
  DETAIL
   suspensecd = cv.code_value
  WITH nocounter
 ;end select
 CALL echo(build("13019:SUSPENSE . . .",suspensecd))
 RECORD charges(
   1 list[*]
     2 charge_item_id = f8
     2 process_flg = i2
     2 server_process_flag = i2
 )
 DECLARE done = i2
 SET done = 0
 DECLARE chargecnt = i4
 DECLARE totalcnt = f8
 SET totalcnt = 0
 WHILE (done=0)
   SET done = 1
   SET chargecnt = 0
   CALL echo("Read list of qualifying charges . . .")
   SELECT INTO "nl:"
    c.charge_item_id, c.process_flg
    FROM charge c
    WHERE c.process_flg IN (0, 1, 2, 3, 4,
    8)
     AND c.active_ind=1
     AND ((c.server_process_flag=null) OR (c.server_process_flag=0))
    DETAIL
     chargecnt += 1, stat = alterlist(charges->list,chargecnt), charges->list[chargecnt].
     charge_item_id = c.charge_item_id,
     charges->list[chargecnt].process_flg = c.process_flg
     IF (((c.process_flg=1) OR (c.process_flg=2)) )
      charges->list[chargecnt].server_process_flag = 1
     ELSE
      charges->list[chargecnt].server_process_flag = 2
     ENDIF
    WITH nocounter, maxqual(c,10000)
   ;end select
   CALL echo(build("Number of qualifying charges this pass . . .",chargecnt))
   SET totalcnt += chargecnt
   CALL echo(build("Total number of charges so far . . .",totalcnt))
   IF (chargecnt > 0)
    IF (chargecnt=10000)
     SET done = 0
    ENDIF
    CALL echo("Check for suspended charges with non server suspense codes . . .")
    DECLARE cnt = i2
    SELECT INTO "nl:"
     cm.field1_id
     FROM (dummyt d  WITH seq = value(chargecnt)),
      charge_mod cm
     PLAN (d
      WHERE (charges->list[d.seq].process_flg=1))
      JOIN (cm
      WHERE (cm.charge_item_id=charges->list[d.seq].charge_item_id)
       AND cm.charge_mod_type_cd=suspensecd
       AND expand(cnt,1,suspcnt,cm.field1_id,non_server_susp->list[cnt].code_value))
     DETAIL
      charges->list[d.seq].server_process_flag = 2
     WITH nocounter
    ;end select
    CALL echo("Update server_process_flag on charge table . . .")
    DECLARE intervalsize = i4
    SET intervalsize = 1000
    DECLARE loopcnt = i4
    SET loopcnt = (chargecnt/ intervalsize)
    IF (mod(chargecnt,intervalsize) > 0)
     SET loopcnt += 1
    ENDIF
    DECLARE looppos = i4
    DECLARE lowerlimit = i4
    DECLARE upperlimit = i4
    FOR (looppos = 1 TO loopcnt)
      SET upperlimit = (looppos * intervalsize)
      SET lowerlimit = (upperlimit - intervalsize)
      IF (upperlimit > chargecnt)
       SET upperlimit = chargecnt
      ENDIF
      CALL echo(build("Updating items=>",(lowerlimit+ 1),"...",upperlimit))
      UPDATE  FROM charge c,
        (dummyt d  WITH seq = value(chargecnt))
       SET c.server_process_flag = charges->list[d.seq].server_process_flag
       PLAN (d
        WHERE d.seq > lowerlimit
         AND d.seq <= upperlimit)
        JOIN (c
        WHERE (c.charge_item_id=charges->list[d.seq].charge_item_id))
       WITH nocounter
      ;end update
      COMMIT
    ENDFOR
   ENDIF
   CALL echo("Checking for errors and updating readme status . . .")
   SET error_code = 0
   SET error_msg = fillstring(132," ")
   SET error_code = error(error_msg,0)
   IF (error_code > 0)
    SET done = 1
    SET readme_data->status = "F"
    SET readme_data->message = error_msg
   ELSE
    SET readme_data->status = "S"
    SET readme_data->message = "Upt Server Process Flag completed successfully"
   ENDIF
 ENDWHILE
 EXECUTE dm_readme_status
 CALL echo("Finished")
END GO
