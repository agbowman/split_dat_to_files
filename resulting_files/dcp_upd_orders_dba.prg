CREATE PROGRAM dcp_upd_orders:dba
 RECORD ord(
   1 ordcnt = i4
   1 ord_list[*]
     2 order_id = f8
     2 freq_id = f8
     2 freq_type = i2
 )
 SET cnt = 0
 SET code_value = 0.0
 SET code_set = 6004
 SET cdf_meaning = fillstring(12," ")
 SET passthru = 0
 SET updtcnt = 0
 SET cdf_meaning = "ORDERED"
 EXECUTE cpm_get_cd_for_cdf
 SET ordered_cd = code_value
 CALL echo(build("ordered code:",ordered_cd))
 SET cdf_meaning = "SUSPENDED"
 EXECUTE cpm_get_cd_for_cdf
 SET suspended_cd = code_value
 CALL echo(build("suspended code:",suspended_cd))
 SET cdf_meaning = "INPROCESS"
 EXECUTE cpm_get_cd_for_cdf
 SET inprocess_cd = code_value
 CALL echo(build("in process code:",inprocess_cd))
 SET cdf_meaning = "FUTURE"
 EXECUTE cpm_get_cd_for_cdf
 SET future_cd = code_value
 CALL echo(build("future code:",future_cd))
 SET cdf_meaning = "INCOMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET incomplete_cd = code_value
 CALL echo(build("incomplete code:",incomplete_cd))
 SET cdf_meaning = "MEDSTUDENT"
 EXECUTE cpm_get_cd_for_cdf
 SET medstudent_cd = code_value
 CALL echo(build("medstudent code:",medstudent_cd))
 CALL echo("**********************************************")
 CALL echo("*  Retrieving information.                   *")
 CALL echo("*  Please wait...                            *")
 CALL echo("**********************************************")
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_domain="OM READ ME"
   AND di.info_name="DCP_UPD_ORDERS"
   AND di.info_number=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo("already done update, exit now")
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  o.order_id
  FROM orders o
  WHERE o.order_status_cd IN (ordered_cd, incomplete_cd, suspended_cd, inprocess_cd, medstudent_cd,
  future_cd)
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (o.constant_ind=1)) ))
    AND ((o.freq_type_flag=0
    AND o.frequency_id > 0) OR (((o.freq_type_flag=0
    AND o.frequency_id=0) OR (o.freq_type_flag=6)) )) )
    cnt = (cnt+ 1)
    IF (cnt > size(ord->ord_list,5))
     stat = alterlist(ord->ord_list,(cnt+ 100))
    ENDIF
    ord->ord_list[cnt].order_id = o.order_id
    IF (o.frequency_id=0)
     ord->ord_list[cnt].freq_id = - (1)
    ELSE
     ord->ord_list[cnt].freq_id = o.frequency_id
    ENDIF
    IF (o.freq_type_flag=0)
     ord->ord_list[cnt].freq_type = - (1)
    ELSE
     ord->ord_list[cnt].freq_type = o.freq_type_flag
    ENDIF
   ENDIF
  FOOT REPORT
   ord->ordcnt = cnt, stat = alterlist(ord->ord_list,ord->ordcnt)
  WITH nocounter
 ;end select
 CALL echo("**************************************************")
 CALL echo("*  Updating freq_type_flags and freq_ids         *")
 CALL echo("*  on ORDERS table.                              *")
 CALL echo("*  Please wait...                                *")
 CALL echo("**************************************************")
 FOR (x = 1 TO cnt)
   IF ((ord->ord_list[x].freq_id=0))
    SELECT INTO "nl:"
     od.frequency_id
     FROM order_detail od
     WHERE (od.order_id=ord->ord_list[x].order_id)
      AND od.oe_field_meaning_id=2094
     ORDER BY od.action_sequence DESC
     HEAD od.order_id
      CALL echo(build("freq id: ",od.oe_field_value))
      IF (od.oe_field_value > 0)
       ord->ord_list[x].freq_id = od.oe_field_value
      ELSE
       ord->ord_list[x].freq_id = - (1)
      ENDIF
     WITH counter
    ;end select
    IF ((ord->ord_list[x].freq_id > 0))
     SELECT INTO "nl:"
      fs.frequency_cd
      FROM frequency_schedule fs
      WHERE (fs.frequency_id=ord->ord_list[x].freq_id)
      DETAIL
       CALL echo(build("freq type: ",fs.frequency_cd))
       IF (fs.frequency_cd > 0)
        ord->ord_list[x].freq_type = fs.frequency_cd
       ELSE
        ord->ord_list[x].freq_type = - (1)
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((ord->ord_list[x].freq_type=0))
    SELECT INTO "nl:"
     fs.frequency_cd
     FROM order_detail od,
      frequency_schedule fs
     PLAN (od
      WHERE (od.order_id=ord->ord_list[x].order_id)
       AND od.oe_field_meaning_id=2011)
      JOIN (fs
      WHERE fs.frequency_cd=od.oe_field_value)
     ORDER BY od.action_sequence DESC
     HEAD fs.frequency_cd
      CALL echo(build("freq type: ",fs.frequency_cd))
      IF (fs.frequency_cd > 0)
       ord->ord_list[x].freq_type = fs.frequency_cd
      ELSE
       ord->ord_list[x].freq_type = - (1)
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF ((ord->ord_list[x].freq_id >= 0))
    CALL echo(build("order id: ",ord->ord_list[x].order_id))
    CALL echo(build("new freq id: ",ord->ord_list[x].freq_id))
    UPDATE  FROM orders o
     SET o.frequency_id = ord->ord_list[x].freq_id, o.updt_id = 99999
     WHERE (o.order_id=ord->ord_list[x].order_id)
     WITH nocounter
    ;end update
    SET updtcnt = (updtcnt+ 1)
   ENDIF
   IF ((ord->ord_list[x].freq_type >= 0))
    CALL echo(build("new freq_type: ",ord->ord_list[x].freq_type))
    CALL echo(build("order id: ",ord->ord_list[x].order_id))
    IF ((ord->ord_list[x].freq_type=6))
     UPDATE  FROM orders o
      SET o.freq_type_flag = 5, o.updt_id = 99999
      WHERE (o.order_id=ord->ord_list[x].order_id)
      WITH nocounter
     ;end update
    ELSE
     UPDATE  FROM orders o
      SET o.freq_type_flag = ord->ord_list[x].freq_type, o.updt_id = 99999
      WHERE (o.order_id=ord->ord_list[x].order_id)
      WITH nocounter
     ;end update
    ENDIF
    SET updtcnt = (updtcnt+ 1)
   ENDIF
   IF (passthru > 10)
    COMMIT
    SET passthru = 0
   ELSE
    SET passthru = (passthru+ 1)
   ENDIF
 ENDFOR
 COMMIT
 CALL echo("***************************************************")
 CALL echo("*  Successfully updated all freq_type_flags       *")
 CALL echo("*  and freq_ids on ORDERS table.                  *")
 CALL echo("*                                                 *")
 CALL echo("***************************************************")
#exit_program
END GO
