CREATE PROGRAM bbt_add_mod_split_prod:dba
 RECORD reply(
   1 qual[*]
     2 orig_product_id = f8
     2 assign_events[*]
       3 product_event_id = f8
     2 newproducts[*]
       3 product_cd = f8
       3 product_nbr = c20
       3 product_sub_nbr = c5
       3 new_product_id = f8
       3 assign_events[*]
         4 product_event_id = f8
       3 xm_events[*]
         4 product_event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_to_updt = size(request->origproducts,5)
 SET nbr_of_devices = 0
 SET gsub_code_value = 0.0
 SET gsub_product_event_status = "  "
 SET product_event_id = 0
 SET cur_updt_cnt = 0.0
 SET cur_supplier_id = 0.0
 SET failed = "F"
 SET subroutine_status = "  "
 SET y = 0
 SET dispose_code = 0.0
 SET disposed_product_event_id = 0.0
 SET modify_dispose_code = 0.0
 SET destroy_code = 0.0
 SET xmatch_code = 0.0
 SET orig_product_id = 0.0
 SET xm_event_id = 0
 SET xm_bb_result_id = 0
 SET xm_person_id = 0
 SET xm_encntr_id = 0
 SET xm_order_id = 0
 SET xm_event_dt_tm = cnvtdatetime(curdate,curtime3)
 SET xm_event_prsnl_id = 0
 SET xm_event_status_flag = 0
 SET xm_override_ind = 0
 SET xm_override_reason_cd = 0
 SET xm_reinstate_reason_cd = 0
 SET xm_exp_dt_tm = cnvtdatetime(curdate,curtime3)
 SET xm_bb_id_nbr = fillstring(20," ")
 SET xm_reason_cd = 0
 SET carry_forward_xm = " "
 SET nbr_to_add = 0
 SET new_seqnbr = 0
 SET seqnbr = 0
 SET seqnbr2 = 0
 SET gsub_bp_status = "  "
 SET unconfirmed_code = 0.0
 SET auto_code = 0.0
 SET quar_code = 0.0
 SET available_code = 0.0
 SET tested_code = 0.0
 SET drawn_code = 0.0
 SET nbr_of_ags = 0
 SET count1 = 0
 SET nbr_of_quars = 0
 SET quar_idx = 0
 SET stat = alterlist(reply->qual,nbr_to_updt)
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 CALL get_code_value(1610,"2")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname =
  "get quarantine code value from code_set 1610"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "2"
  GO TO exit_program
 ELSE
  SET quar_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"3")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get modified code value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "3"
  GO TO exit_program
 ELSE
  SET xmatch_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"5")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get dispose code value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "5"
  SET failed = "T"
  GO TO exit_program
 ELSE
  SET dispose_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"8")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get modified code value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "8"
  GO TO exit_program
 ELSE
  SET modified_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"9")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname =
  "get unconfirmed code value from codeset 1610"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "9"
  GO TO exit_program
 ELSE
  SET unconfirmed_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"10")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname =
  "get autologous code value from codeset 1610"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "10"
  GO TO exit_program
 ELSE
  SET auto_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"12")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname =
  "get available code value from codeset 1610"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "12"
  GO TO exit_program
 ELSE
  SET available_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"14")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname =
  "get destroyed code value from codeset 1610"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "12"
  GO TO exit_program
 ELSE
  SET destroy_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"20")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname =
  "get drawn code value from code_set 1610"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "20"
  GO TO exit_program
 ELSE
  SET drawn_code = gsub_code_value
 ENDIF
 CALL get_code_value(1610,"21")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname =
  "get tested code value from code_set 1610"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "21"
  GO TO exit_program
 ELSE
  SET tested_code = gsub_code_value
 ENDIF
 CALL get_code_value(1608,"MODIFIED")
 IF (stat=1)
  SET reply->status_data.status = "Z"
  SET count1 = (count1+ 1)
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get dispose reason from 1608"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "MODIFIED"
  GO TO exit_program
 ELSE
  SET modify_dispose_code = gsub_code_value
 ENDIF
 SET cur_own_area = 0.0
 SET cur_inv_area = 0.0
 FOR (a = 1 TO nbr_to_updt)
   SET orig_product_id = request->origproducts[a].product_id
   SET reply->qual[a].orig_product_id = orig_product_id
   SELECT INTO "nl:"
    p.product_id
    FROM product p
    WHERE p.product_id=orig_product_id
    DETAIL
     cur_updt_cnt = p.updt_cnt, cur_supplier_id = p.cur_supplier_id, cur_own_area = p
     .cur_owner_area_cd,
     cur_inv_area = p.cur_inv_area_cd
    WITH nocounter, forupdate(p)
   ;end select
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Product select"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (((curqual=0) OR ((cur_updt_cnt != request->origproducts[a].updt_cnt))) )
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "select for update"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product table"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = " "
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SET product_event_id = 0
   CALL add_product_event(orig_product_id,0.0,0.0,0.0,0.0,
    modified_code,cnvtdatetime(request->modified_dt_tm),reqinfo->updt_id,0,0,
    0.0,0.0,0,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
    reqinfo->updt_id)
   IF (gsub_product_event_status != "OK")
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "add modification event"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product_event"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = gsub_product_event_status
    SET failed = "T"
    GO TO exit_program
   ENDIF
   CALL add_modification(a,product_event_id)
   IF (subroutine_status != "OK")
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "add modification row"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "modification"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = " "
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SET method_cd = 0.0
   CALL get_code_value(1609,"MODIFIED")
   IF (stat=1)
    SET reply->status_data.status = "Z"
    SET count1 = (count1+ 1)
    IF (count1 > 1)
     SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[count1].operationname = "get destruction method"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "bbt_add_destroyed_event.inc failed"
    GO TO exit_program
   ELSE
    SET method_cd = gsub_code_value
   ENDIF
   IF (method_cd=0.0)
    SET failed = "T"
    GO TO exit_program
   ENDIF
   IF ((request->division_type_flag != 4))
    SET carry_forward_xm = "N"
    SELECT INTO "nl:"
     FROM product_event pv
     WHERE (request->origproducts[a].product_id=pv.product_id)
      AND pv.active_ind=1
      AND pv.event_type_cd=xmatch_code
     DETAIL
      xm_event_id = pv.product_event_id, xm_bb_result_id = pv.bb_result_id, xm_person_id = pv
      .person_id,
      xm_encntr_id = pv.encntr_id, xm_order_id = pv.order_id, xm_event_dt_tm = pv.event_dt_tm,
      xm_event_prsnl_id = pv.event_prsnl_id, xm_event_status_flag = pv.event_status_flag,
      xm_override_ind = pv.override_ind,
      xm_override_reason_cd = pv.override_reason_cd
     WITH nocounter
    ;end select
    SET serror_check = error(serrormsg,0)
    IF (serror_check != 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "Error!"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Product_event select"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
     GO TO exit_program
    ENDIF
    IF (curqual != 0)
     SET carry_forward_xm = "Y"
     SELECT INTO "nl:"
      FROM crossmatch xm
      WHERE xm_event_id=xm.product_event_id
      DETAIL
       xm_exp_dt_tm = cnvtdatetime(xm.crossmatch_exp_dt_tm), xm_bb_id_nbr = xm.bb_id_nbr,
       xm_reason_cd = xm.xm_reason_cd,
       xm_reinstate_reason_cd = xm.reinstate_reason_cd
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "select xmatch row"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "crossmatch"
      SET reply->status_data.subeventstatus[y].targetobjectvalue =
      "unable to select for carrying forward"
      SET failed = "T"
      GO TO exit_program
     ENDIF
    ENDIF
   ENDIF
   SET event_states_added = " "
   IF ((request->dispose_orig_ind=1))
    CALL bbt_add_destroyed_event(orig_product_id,cnvtdatetime(request->modified_dt_tm),
     modify_dispose_code,request->origproducts[a].disposed_qty,0,
     method_cd,0," "," ",0)
   ENDIF
   IF (event_states_added="F")
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "destroyed event failed"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "bbt_add_destroyed_event.inc failed"
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SET nbr_of_devices = size(request->origproducts[a].modify_device,5)
   IF (nbr_of_devices > 0)
    FOR (nidx = 1 TO nbr_of_devices)
     SELECT INTO "nl:"
      snbr = seq(pathnet_seq,nextval)"#####################;rp0"
      FROM dual
      DETAIL
       seqnbr2 = cnvtint(snbr)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "nextval"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "SEQUENCE"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = "pathnet_seq"
     ELSE
      INSERT  FROM modify_device md
       SET md.modify_device_id = seqnbr2, md.product_id = request->origproducts[a].product_id, md
        .device_id = request->origproducts[a].modify_device[nidx].device_id,
        md.active_ind = 1, md.active_status_cd = reqdata->active_status_cd, md.active_status_dt_tm =
        cnvtdatetime(curdate,curtime3),
        md.active_status_prsnl_id = reqinfo->updt_id, md.updt_cnt = 0, md.updt_dt_tm = cnvtdatetime(
         curdate,curtime3),
        md.updt_id = reqinfo->updt_id, md.updt_task = reqinfo->updt_task, md.updt_applctx = reqinfo->
        updt_applctx
       WITH counter
      ;end insert
      SET serror_check = error(serrormsg,0)
      IF (serror_check != 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "Error!"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "Modify_device insert"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
       GO TO exit_program
      ENDIF
      IF (curqual=0)
       SET failed = "T"
       SET y = (y+ 1)
       IF (y > 0)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[y].operation_name = "insert"
       SET reply->status_data.subeventstatus[y].operation_status = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "modify device"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "modify_device"
       GO TO exit_program
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   SET nbr_of_ags = size(request->origproducts[a].antigens,5)
   IF ((request->division_type_flag=3)
    AND (request->dispose_orig_ind=0))
    IF (nbr_of_ags > 0)
     FOR (nidx = 1 TO nbr_of_ags)
      SELECT INTO "nl:"
       snbr = seq(pathnet_seq,nextval)"#####################;rp0"
       FROM dual
       DETAIL
        seqnbr2 = cnvtint(snbr)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "nextval"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "SEQUENCE"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "pathnet_seq"
      ELSE
       INSERT  FROM special_testing s
        SET s.special_testing_id = seqnbr2, s.product_id = request->origproducts[a].product_id, s
         .special_testing_cd = request->origproducts[a].antigens[nidx].antigen_cd,
         s.active_ind = 1, s.active_status_cd = reqdata->active_status_cd, s.active_status_dt_tm =
         cnvtdatetime(curdate,curtime3),
         s.active_status_prsnl_id = reqinfo->updt_id, s.updt_cnt = 0, s.updt_dt_tm = cnvtdatetime(
          curdate,curtime3),
         s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
         updt_applctx
        WITH counter
       ;end insert
       SET serror_check = error(serrormsg,0)
       IF (serror_check != 0)
        SET reply->status_data.status = "F"
        SET reply->status_data.subeventstatus[1].operationname = "Error!"
        SET reply->status_data.subeventstatus[1].operationstatus = "F"
        SET reply->status_data.subeventstatus[1].targetobjectname = "Special_testing insert"
        SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
        GO TO exit_program
       ENDIF
       IF (curqual=0)
        SET y = (y+ 1)
        IF (y > 1)
         SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[y].operationname = "insert"
        SET reply->status_data.subeventstatus[y].operationstatus = "F"
        SET reply->status_data.subeventstatus[y].targetobjectname = "orig_product attribute"
        SET reply->status_data.subeventstatus[y].targetobjectvalue = "special_testing"
       ENDIF
      ENDIF
     ENDFOR
    ENDIF
   ENDIF
   CALL updt_orig_product(a)
   IF (subroutine_status != "OK")
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "update original product row"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = " "
    SET failed = "T"
    GO TO exit_program
   ENDIF
   CALL updt_blood_product(a)
   IF (subroutine_status != "OK")
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "update original blood_product row"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "blood_product"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = " "
    SET failed = "T"
    GO TO exit_program
   ENDIF
   SET nbr_to_add = size(request->origproducts[a].newproducts,5)
   SET stat = alterlist(reply->qual[a].newproducts,nbr_to_add)
   FOR (nidx = 1 TO nbr_to_add)
     SELECT INTO "nl:"
      snbr = seq(blood_bank_seq,nextval)"#####################;rp0"
      FROM dual
      DETAIL
       new_seqnbr = cnvtint(snbr)
      WITH format, counter
     ;end select
     IF (curqual=0)
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "nextval"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "SEQUENCE"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = "blood_bank_seq"
      SET failed = "T"
      GO TO exit_program
     ENDIF
     CALL add_new_product(a,nidx,new_seqnbr,request->origproducts[a].pooled_product_ind,request->
      origproducts[a].barcode_nbr)
     IF (subroutine_status != "OK")
      SET y = (y+ 1)
      IF (y > 1)
       SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
      ENDIF
      SET reply->status_data.subeventstatus[y].operationname = "add_new_product"
      SET reply->status_data.subeventstatus[y].operationstatus = "F"
      SET reply->status_data.subeventstatus[y].targetobjectname = "product"
      SET reply->status_data.subeventstatus[y].targetobjectvalue = " "
      SET failed = "T"
      GO TO exit_program
     ENDIF
     IF ((request->origproducts[a].product_type="B"))
      CALL add_new_blood_product_tbls(a,nidx,new_seqnbr)
      IF (gsub_bp_status != "OK")
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "insert into blood_product table"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "blood_product"
       SET failed = "T"
       GO TO exit_program
      ENDIF
     ELSE
      CALL add_new_derivative(x,nidx,new_seqnbr)
      IF (subroutine_status != "OK")
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "add_new_derivative"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = " "
       SET reply->status_data.subeventstatus[y].targetobjectvalue = " "
       SET failed = "T"
       GO TO exit_program
      ENDIF
     ENDIF
     IF ((request->origproducts[a].newproducts[nidx].available_ind=1))
      IF (available_code=0.0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "add available event"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "code_set 1610"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "key 12 nonexistent"
       SET failed = "T"
       GO TO exit_program
      ELSE
       SET product_event_id = 0
       CALL add_product_event(new_seqnbr,0.0,0.0,0.0,0.0,
        available_code,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
        0.0,0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id)
       IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
        SET y = (y+ 1)
        IF (y > 1)
         SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[y].operationname = "add product event"
        SET reply->status_data.subeventstatus[y].operationstatus = "F"
        SET reply->status_data.subeventstatus[y].targetobjectname = "available event"
        SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
        SET failed = "T"
        GO TO exit_program
       ENDIF
      ENDIF
     ENDIF
     IF ((request->origproducts[a].newproducts[nidx].assign_ind=1))
      SET assign_status = " "
      CALL add_assign(new_seqnbr,request->origproducts[a].newproducts[nidx].person_id,request->
       origproducts[a].newproducts[nidx].encntr_id,request->origproducts[a].newproducts[nidx].
       reason_cd,0,
       request->origproducts[a].newproducts[nidx].qty_assigned,0,reqinfo->updt_id,reqinfo->updt_task,
       reqinfo->updt_applctx,
       reqdata->active_status_cd,reqinfo->updt_id,cnvtdatetime(curdate,curtime3))
      IF (assign_status != "S")
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "add assignment"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "assign event"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "assign event id"
       SET failed = "T"
       GO TO exit_program
      ENDIF
      SET stat = alterlist(reply->qual[a].newproducts[nidx].assign_events,1)
      SET reply->qual[a].newproducts[nidx].assign_events[1].product_event_id = product_event_id
     ENDIF
     IF ((request->origproducts[a].newproducts[nidx].quarantine_ind=1))
      SET nbr_of_quars = size(request->origproducts[a].quar_reasons,5)
      FOR (quar_idx = 1 TO nbr_of_quars)
        SET product_event_id = 0
        CALL add_product_event(new_seqnbr,0.0,0.0,0.0,0.0,
         quar_code,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
         0.0,0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
         reqinfo->updt_id)
        IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
         SET y = (y+ 1)
         IF (y > 1)
          SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[y].operationname = "add product event"
         SET reply->status_data.subeventstatus[y].operationstatus = "F"
         SET reply->status_data.subeventstatus[y].targetobjectname = "quarantine event"
         SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
         SET failed = "T"
         GO TO exit_program
        ENDIF
        CALL add_quarantine(product_event_id,request->origproducts[a].quar_reasons[quar_idx].
         quar_reason_cd)
        IF (subroutine_status != "OK")
         SET y = (y+ 1)
         IF (y > 1)
          SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[y].operationname = "add_quarantine"
         SET reply->status_data.subeventstatus[y].operationstatus = "F"
         SET reply->status_data.subeventstatus[y].targetobjectname = "quarantine"
         SET reply->status_data.subeventstatus[y].targetobjectvalue = " "
         SET failed = "T"
         GO TO exit_program
        ENDIF
      ENDFOR
     ENDIF
     IF ((request->origproducts[a].newproducts[nidx].drawn_ind=1))
      IF (drawn_code=0.0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "add drawn event"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "code_set 1610"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "key 20 nonexistent"
       SET failed = "T"
       GO TO exit_program
      ELSE
       SET product_event_id = 0
       CALL add_product_event(new_seqnbr,0.0,0.0,0.0,0.0,
        drawn_code,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
        0.0,0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id)
       IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
        SET y = (y+ 1)
        IF (y > 1)
         SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[y].operationname = "add product event"
        SET reply->status_data.subeventstatus[y].operationstatus = "F"
        SET reply->status_data.subeventstatus[y].targetobjectname = "drawn event"
        SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
        SET failed = "T"
        GO TO exit_program
       ENDIF
      ENDIF
     ENDIF
     IF ((request->origproducts[a].newproducts[nidx].tested_ind=1))
      IF (tested_code=0.0)
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "add tested event"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "code_set 1610"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "key 21 nonexistent"
       SET failed = "T"
       GO TO exit_program
      ELSE
       SET product_event_id = 0
       CALL add_product_event(new_seqnbr,0.0,0.0,0.0,0.0,
        tested_code,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
        0.0,0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
        reqinfo->updt_id)
       IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
        SET y = (y+ 1)
        IF (y > 1)
         SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
        ENDIF
        SET reply->status_data.subeventstatus[y].operationname = "add product event"
        SET reply->status_data.subeventstatus[y].operationstatus = "F"
        SET reply->status_data.subeventstatus[y].targetobjectname = "tested event"
        SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
        SET failed = "T"
        GO TO exit_program
       ENDIF
      ENDIF
     ENDIF
     IF (carry_forward_xm="Y")
      SET product_event_id = 0
      CALL add_product_event(new_seqnbr,xm_person_id,xm_encntr_id,xm_order_id,xm_bb_result_id,
       xmatch_code,cnvtdatetime(xm_event_dt_tm),reqinfo->updt_id,xm_event_status_flag,xm_override_ind,
       xm_override_reason_cd,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id)
      IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "add product event"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "crossmatch event"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
       SET failed = "T"
       GO TO exit_program
      ENDIF
      SET stat = alterlist(reply->qual[a].newproducts[nidx].xm_events,1)
      SET reply->qual[a].newproducts[nidx].xm_events[1].product_event_id = product_event_id
      INSERT  FROM crossmatch c
       SET c.product_event_id = product_event_id, c.product_id = new_seqnbr, c.person_id =
        xm_person_id,
        c.crossmatch_qty = 0, c.crossmatch_exp_dt_tm = cnvtdatetime(xm_exp_dt_tm), c
        .reinstate_reason_cd = xm_reinstate_reason_cd,
        c.bb_id_nbr = xm_bb_id_nbr, c.xm_reason_cd = xm_reason_cd, c.release_prsnl_id = 0,
        c.release_reason_cd = 0, c.release_qty = 0, c.active_ind = 1,
        c.active_status_cd = reqdata->active_status_cd, c.active_status_dt_tm = cnvtdatetime(curdate,
         curtime3), c.active_status_prsnl_id = reqinfo->updt_id,
        c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->updt_id,
        c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
      ;end insert
      SET serror_check = error(serrormsg,0)
      IF (serror_check != 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = "Error!"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "Crossmatch insert"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
       GO TO exit_program
      ENDIF
      IF (curqual=0)
       SET failed = "T"
       GO TO exit_program
      ENDIF
     ENDIF
     SET nbr_of_ags = size(request->origproducts[a].antigens,5)
     IF (nbr_of_ags > 0)
      FOR (idx2 = 1 TO nbr_of_ags)
        SELECT INTO "nl:"
         snbr = seq(pathnet_seq,nextval)"#####################;rp0"
         FROM dual
         DETAIL
          seqnbr2 = cnvtint(snbr)
         WITH format, counter
        ;end select
        SET serror_check = error(serrormsg,0)
        IF (serror_check != 0)
         SET reply->status_data.status = "F"
         SET reply->status_data.subeventstatus[1].operationname = "Error!"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "Pathnet_seq select"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
         GO TO exit_program
        ENDIF
        IF (curqual=0)
         SET y = (y+ 1)
         IF (y > 1)
          SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
         ENDIF
         SET reply->status_data.subeventstatus[y].operationname = "nextval"
         SET reply->status_data.subeventstatus[y].operationstatus = "F"
         SET reply->status_data.subeventstatus[y].targetobjectname = "SEQUENCE"
         SET reply->status_data.subeventstatus[y].targetobjectvalue = "pathnet_seq"
        ELSE
         INSERT  FROM special_testing s
          SET s.special_testing_id = seqnbr2, s.product_id = new_seqnbr, s.special_testing_cd =
           request->origproducts[a].antigens[idx2].antigen_cd,
           s.active_ind = 1, s.active_status_cd = reqdata->active_status_cd, s.active_status_dt_tm =
           cnvtdatetime(curdate,curtime3),
           s.active_status_prsnl_id = reqinfo->updt_id, s.updt_cnt = 0, s.updt_dt_tm = cnvtdatetime(
            curdate,curtime3),
           s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
           updt_applctx
          WITH counter
         ;end insert
         SET serror_check = error(serrormsg,0)
         IF (serror_check != 0)
          SET reply->status_data.status = "F"
          SET reply->status_data.subeventstatus[1].operationname = "Error!"
          SET reply->status_data.subeventstatus[1].operationstatus = "F"
          SET reply->status_data.subeventstatus[1].targetobjectname = "Special_testing insert"
          SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
          GO TO exit_program
         ENDIF
         IF (curqual=0)
          SET y = (y+ 1)
          IF (y > 1)
           SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
          ENDIF
          SET reply->status_data.subeventstatus[y].operationname = "insert"
          SET reply->status_data.subeventstatus[y].operationstatus = "F"
          SET reply->status_data.subeventstatus[y].targetobjectname = "TABLE"
          SET reply->status_data.subeventstatus[y].targetobjectvalue = "special_testing"
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 ENDFOR
 SUBROUTINE add_product_event(sub_product_id,sub_person_id,sub_encntr_id,sub_order_id,
  sub_bb_result_id,sub_event_type_cd,sub_event_dt_tm,sub_event_prsnl_id,sub_event_status_flag,
  sub_override_ind,sub_override_reason_cd,sub_related_product_event_id,sub_active_ind,
  sub_active_status_cd,sub_active_status_dt_tm,sub_active_status_prsnl_id)
   SET gsub_product_event_status = "  "
   SET product_event_id = 0.0
   SET sub_product_event_id = 0.0
   DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
   SET new_pathnet_seq = 0
   SELECT INTO "nl:"
    seqn = seq(pathnet_seq,nextval)
    FROM dual
    DETAIL
     new_pathnet_seq = seqn
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    SET gsub_product_event_status = "FS"
   ELSE
    SET sub_product_event_id = new_pathnet_seq
    INSERT  FROM product_event pe
     SET pe.product_event_id = sub_product_event_id, pe.product_id = sub_product_id, pe.person_id =
      IF (sub_person_id=null) 0
      ELSE sub_person_id
      ENDIF
      ,
      pe.encntr_id =
      IF (sub_encntr_id=null) 0
      ELSE sub_encntr_id
      ENDIF
      , pe.order_id =
      IF (sub_order_id=null) 0
      ELSE sub_order_id
      ENDIF
      , pe.bb_result_id = sub_bb_result_id,
      pe.event_type_cd = sub_event_type_cd, pe.event_dt_tm = cnvtdatetime(sub_event_dt_tm), pe
      .event_prsnl_id = sub_event_prsnl_id,
      pe.event_status_flag = sub_event_status_flag, pe.override_ind = sub_override_ind, pe
      .override_reason_cd = sub_override_reason_cd,
      pe.related_product_event_id = sub_related_product_event_id, pe.active_ind = sub_active_ind, pe
      .active_status_cd = sub_active_status_cd,
      pe.active_status_dt_tm = cnvtdatetime(sub_active_status_dt_tm), pe.active_status_prsnl_id =
      sub_active_status_prsnl_id, pe.updt_cnt = 0,
      pe.updt_dt_tm = cnvtdatetime(curdate,curtime3), pe.updt_id = reqinfo->updt_id, pe.updt_task =
      reqinfo->updt_task,
      pe.updt_applctx = reqinfo->updt_applctx, pe.event_tz =
      IF (curutc=1) curtimezoneapp
      ELSE 0
      ENDIF
     WITH nocounter
    ;end insert
    SET product_event_id = sub_product_event_id
    SET new_product_event_id = sub_product_event_id
    IF (curqual=0)
     SET gsub_product_event_status = "FA"
    ELSE
     SET gsub_product_event_status = "OK"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   CALL echo(gsub_code_value)
 END ;Subroutine
 SUBROUTINE add_modification(midx,prod_event_id)
   SET subroutine_status = "OK"
   INSERT  FROM modification m
    SET m.product_id = request->origproducts[midx].product_id, m.product_event_id = prod_event_id, m
     .orig_expire_dt_tm = cnvtdatetime(request->origproducts[midx].orig_expire_dt_tm),
     m.cur_expire_dt_tm = cnvtdatetime(request->origproducts[midx].cur_expire_dt_tm), m.orig_volume
      = request->origproducts[midx].orig_volume, m.orig_unit_meas_cd = request->origproducts[midx].
     orig_unit_meas_cd,
     m.cur_volume = request->origproducts[midx].cur_volume, m.cur_unit_meas_cd = request->
     origproducts[midx].cur_unit_meas_cd, m.modified_qty = request->origproducts[midx].modified_qty,
     m.crossover_reason_cd = request->crossover_reason_cd, m.option_id = request->option_id, m
     .active_ind = 1,
     m.active_status_cd = reqdata->active_status_cd, m.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), m.active_status_prsnl_id = reqinfo->updt_id,
     m.updt_cnt = 0, m.updt_dt_tm = cnvtdatetime(curdate,curtime3), m.updt_id = reqinfo->updt_id,
     m.updt_applctx = reqinfo->updt_applctx, m.updt_task = reqinfo->updt_task
    WITH counter
   ;end insert
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Modification insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET subroutine_status = "F"
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "modification"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE add_disposition(prod_event_id,didx)
   SET subroutine_status = "OK"
   INSERT  FROM disposition d
    SET d.product_id = request->origproducts[didx].product_id, d.product_event_id = prod_event_id, d
     .reason_cd = modify_dispose_code,
     d.disposed_qty = request->origproducts[didx].disposed_qty, d.active_ind = 0, d.active_status_cd
      = reqdata->active_status_cd,
     d.active_status_dt_tm = cnvtdatetime(curdate,curtime3), d.active_status_prsnl_id = reqinfo->
     updt_id, d.updt_cnt = 0,
     d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id, d.updt_applctx =
     reqinfo->updt_applctx,
     d.updt_task = reqinfo->updt_task
    WITH counter
   ;end insert
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Disposition insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "disposition"
    SET failed = "T"
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE add_destruction(prod_event_id,didx)
   SET subroutine_status = "OK"
   INSERT  FROM destruction d
    SET d.product_id = request->origproducts[didx].product_id, d.product_event_id = prod_event_id, d
     .active_ind = 1,
     d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm = cnvtdatetime(curdate,
      curtime3), d.active_status_prsnl_id = reqinfo->updt_id,
     d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
     d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task
    WITH counter
   ;end insert
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Destruction insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product_event"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "unable to insert"
    SET failed = "T"
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE updt_orig_product(pidx)
   SET subroutine_status = "OK"
   UPDATE  FROM product p
    SET p.locked_ind = 0, p.modified_product_ind = 1, p.cur_expire_dt_tm = cnvtdatetime(request->
      origproducts[pidx].cur_expire_dt_tm),
     p.cur_unit_meas_cd = request->origproducts[pidx].cur_unit_meas_cd, p.orig_unit_meas_cd = request
     ->origproducts[pidx].orig_unit_meas_cd, p.updt_cnt = (p.updt_cnt+ 1),
     p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = reqinfo->updt_id, p.updt_task =
     reqinfo->updt_task
    WHERE (p.product_id=request->origproducts[pidx].product_id)
    WITH counter
   ;end update
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Product update"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET subroutine_status = "F"
   ENDIF
 END ;Subroutine
 SUBROUTINE updt_blood_product(bidx)
   SET subroutine_status = "OK"
   SELECT INTO "nl:"
    b.*
    FROM blood_product b
    WHERE orig_product_id=b.product_id
    DETAIL
     cur_updt_cnt = b.updt_cnt
    WITH nocounter, forupdate(p)
   ;end select
   IF (((curqual=0) OR ((cur_updt_cnt != request->origproducts[bidx].blood_product_updt_cnt))) )
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "select for blood_product"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "blood_product"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = "blood product table"
    SET subroutine_status = "FS"
   ELSE
    UPDATE  FROM blood_product b
     SET b.cur_volume = request->origproducts[bidx].cur_volume, b.supplier_prefix = request->
      origproducts[bidx].supplier_prefix, b.updt_cnt = (cur_updt_cnt+ 1),
      b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task
     WHERE (b.product_id=request->origproducts[bidx].product_id)
     WITH counter
    ;end update
    SET serror_check = error(serrormsg,0)
    IF (serror_check != 0)
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = "Error!"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "Blood_product update"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
     GO TO exit_program
    ENDIF
    IF (curqual=0)
     SET subroutine_status = "FU"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_new_product(xx,pidx,pseqnbr,pp_ind,barcode_nbr)
   SET subroutine_status = "OK"
   SET product_sub_nbr = request->origproducts[xx].newproducts[pidx].product_sub_nbr
   SET product_nbr = cnvtupper(request->origproducts[xx].product_nbr)
   INSERT  FROM product p1
    SET p1.product_id = pseqnbr, p1.cur_owner_area_cd = cur_own_area, p1.cur_inv_area_cd =
     cur_inv_area,
     p1.modified_product_id = request->origproducts[xx].product_id, p1.pooled_product_id = 0, p1
     .pooled_product_ind = pp_ind,
     p1.barcode_nbr = barcode_nbr, p1.product_nbr = trim(product_nbr), p1.product_sub_nbr = trim(
      product_sub_nbr),
     p1.flag_chars = request->origproducts[xx].flag_chars, p1.product_cd = request->origproducts[xx].
     newproducts[pidx].product_cd, p1.product_cat_cd = request->origproducts[xx].newproducts[pidx].
     product_cat_cd,
     p1.product_class_cd = request->origproducts[xx].newproducts[pidx].product_class_cd, p1
     .cur_unit_meas_cd = request->origproducts[xx].newproducts[pidx].cur_unit_meas_cd, p1
     .orig_unit_meas_cd = request->origproducts[xx].newproducts[pidx].cur_unit_meas_cd,
     p1.storage_temp_cd = request->origproducts[xx].newproducts[pidx].storage_temp_cd, p1
     .cur_supplier_id = cur_supplier_id, p1.cur_expire_dt_tm = cnvtdatetime(request->origproducts[xx]
      .newproducts[pidx].cur_expire_dt_tm),
     p1.active_ind = 1, p1.active_status_cd = reqdata->active_status_cd, p1.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     p1.active_status_prsnl_id = reqinfo->updt_id, p1.updt_cnt = 0, p1.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     p1.updt_id = reqinfo->updt_id, p1.updt_applctx = reqinfo->updt_applctx, p1.updt_task = reqinfo->
     updt_task
    WITH counter
   ;end insert
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Product insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET subroutine_status = "F"
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET reply->status_data.subeventstatus[y].operationname = "insert"
    SET reply->status_data.subeventstatus[y].operationstatus = "F"
    SET reply->status_data.subeventstatus[y].targetobjectname = "product"
    SET reply->status_data.subeventstatus[y].targetobjectvalue = pseqnbr
   ELSE
    SET reply->qual[xx].newproducts[pidx].new_product_id = pseqnbr
    SET reply->qual[xx].newproducts[pidx].product_cd = request->origproducts[xx].newproducts[pidx].
    product_cd
    SET reply->qual[xx].newproducts[pidx].product_nbr = request->origproducts[xx].product_nbr
    SET reply->qual[xx].newproducts[pidx].product_sub_nbr = request->origproducts[xx].newproducts[
    pidx].product_sub_nbr
   ENDIF
 END ;Subroutine
 SUBROUTINE add_new_blood_product_tbls(idx,pidx,pseqnbr)
   SET gsub_bp_status = "OK"
   INSERT  FROM blood_product p2
    SET p2.product_id = pseqnbr, p2.product_cd = request->origproducts[idx].newproducts[pidx].
     product_cd, p2.supplier_prefix = request->origproducts[idx].supplier_prefix,
     p2.orig_expire_dt_tm = cnvtdatetime(request->origproducts[idx].cur_expire_dt_tm), p2.cur_volume
      = request->origproducts[idx].newproducts[pidx].cur_volume, p2.orig_volume = request->
     origproducts[idx].newproducts[pidx].cur_volume,
     p2.orig_label_abo_cd = request->origproducts[idx].abo_cd, p2.orig_label_rh_cd = request->
     origproducts[idx].rh_cd, p2.cur_abo_cd = request->origproducts[idx].abo_cd,
     p2.cur_rh_cd = request->origproducts[idx].rh_cd, p2.segment_nbr = " ", p2.donor_person_id =
     request->origproducts[idx].donor_person_id,
     p2.drawn_dt_tm = cnvtdatetime(request->origproducts[idx].drawn_dt_tm), p2.active_ind = 1, p2
     .active_status_cd = reqdata->active_status_cd,
     p2.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p2.active_status_prsnl_id = reqinfo->
     updt_id, p2.updt_cnt = 0,
     p2.updt_dt_tm = cnvtdatetime(curdate,curtime3), p2.updt_id = reqinfo->updt_id, p2.updt_task =
     reqinfo->updt_task,
     p2.updt_applctx = reqinfo->updt_applctx
    WITH counter
   ;end insert
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Blood_product insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET gsub_bp_status = "FI"
   ELSE
    IF ((request->origproducts[idx].newproducts[pidx].unconfirmed_ind=1))
     IF (unconfirmed_code=0.0)
      SET gsub_bp_status = "F"
     ELSE
      SET product_event_id = 0
      CALL add_product_event(new_seqnbr,0.0,0.0,0.0,0.0,
       unconfirmed_code,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
       0.0,0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id)
      IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
       SET gsub_bp_status = "FI"
      ENDIF
     ENDIF
    ENDIF
    IF ((request->origproducts[idx].newproducts[pidx].autologous_ind=1))
     IF (auto_code=0.0)
      SET gsub_bp_status = "F"
     ELSE
      SET product_event_id = 0
      CALL add_product_event(new_seqnbr,request->origproducts[idx].newproducts[pidx].person_id,
       request->origproducts[idx].newproducts[pidx].encntr_id,0.0,0.0,
       auto_code,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
       0.0,0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id)
      IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "add product event"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "autologous event"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
       SET failed = "T"
      ELSE
       CALL add_auto_directed(new_seqnbr,product_event_id,request->origproducts[idx].newproducts[pidx
        ].person_id,request->origproducts[idx].newproducts[pidx].encntr_id,request->origproducts[idx]
        .newproducts[pidx].expected_usage_dt_tm,
        request->origproducts[idx].newproducts[pidx].associated_dt_tm)
       IF (gsub_ad_status != "OK")
        SET gsub_bp_status = "F"
       ENDIF
      ENDIF
     ENDIF
    ELSE
     IF ((request->origproducts[idx].newproducts[pidx].directed_ind=1))
      SET product_event_id = 0
      CALL add_product_event(new_seqnbr,request->origproducts[idx].newproducts[pidx].person_id,
       request->origproducts[idx].newproducts[pidx].encntr_id,0.0,0.0,
       directed_code,cnvtdatetime(curdate,curtime3),reqinfo->updt_id,0,0,
       0.0,0.0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
       reqinfo->updt_id)
      IF (((gsub_product_event_status="FS") OR (gsub_product_event_status="FA")) )
       SET y = (y+ 1)
       IF (y > 1)
        SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
       ENDIF
       SET reply->status_data.subeventstatus[y].operationname = "add product event"
       SET reply->status_data.subeventstatus[y].operationstatus = "F"
       SET reply->status_data.subeventstatus[y].targetobjectname = "directed event"
       SET reply->status_data.subeventstatus[y].targetobjectvalue = "add product event"
       SET gsub_bp_status = "F"
      ELSE
       CALL add_auto_directed(new_seqnbr,product_event_id,request->origproducts[idx].newproducts[pidx
        ].person_id,request->origproducts[idx].newproducts[pidx].encntr_id,request->origproducts[idx]
        .newproducts[pidx].expected_usage_dt_tm,
        request->origproducts[idx].newproducts[pidx].associated_dt_tm)
       IF (gsub_ad_status != "OK")
        SET gsub_bp_status = "F"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_assign(sub_product_id,sub_person_id,encntr_id,sub_assign_reason_cd,sub_prov_id,
  qty_assigned,assign_intl_units,sub_updt_id,sub_updt_task,sub_updt_applctx,sub_active_status_cd,
  sub_active_status_prsnl_id,assign_dt_tm)
   SET assign_event_id = 0.0
   SET event_type_cd = 0.0
   CALL get_event_type("1")
   IF (event_type_cd=0)
    SET assign_status = "F"
   ELSE
    DECLARE new_pathnet_seq = f8 WITH protect, noconstant(0.0)
    SET new_pathnet_seq = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      new_pathnet_seq = seqn
     WITH format, nocounter
    ;end select
    SET product_event_id = 0.0
    SET sub_product_event_id = 0.0
    CALL add_product_event(sub_product_id,sub_person_id,encntr_id,0,0,
     event_type_cd,cnvtdatetime(assign_dt_tm),reqinfo->updt_id,0,0,
     0,0,1,reqdata->active_status_cd,cnvtdatetime(curdate,curtime3),
     reqinfo->updt_id)
    SET sub_product_event_id = product_event_id
    IF (curqual=0)
     SET assign_status = "F"
    ELSE
     INSERT  FROM assign a
      SET a.product_event_id = sub_product_event_id, a.product_id = sub_product_id, a.person_id =
       sub_person_id,
       a.assign_reason_cd = sub_assign_reason_cd, a.prov_id = sub_prov_id, a.orig_assign_qty =
       qty_assigned,
       a.cur_assign_qty = qty_assigned, a.cur_assign_intl_units = assign_intl_units, a
       .orig_assign_intl_units = assign_intl_units,
       a.updt_cnt = 0, a.updt_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_id = sub_updt_id,
       a.updt_task = sub_updt_task, a.updt_applctx = sub_updt_applctx, a.active_ind = 1,
       a.active_status_cd = sub_active_status_cd, a.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), a.active_status_prsnl_id = sub_active_status_prsnl_id
      WITH counter
     ;end insert
     IF (curqual=0)
      SET assign_status = "F"
     ELSE
      SET assign_event_id = sub_product_event_id
      SET assign_status = "S"
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_event_type(meaning)
   SELECT INTO "nl:"
    cv.code_value
    FROM code_value cv
    WHERE cv.code_set=1610
     AND cv.cdf_meaning=meaning
    DETAIL
     event_type_cd = cv.code_value
    WITH counter
   ;end select
 END ;Subroutine
 SUBROUTINE add_auto_directed(a_pseqnbr,autodir_event_id,autodir_person_id,autodir_encntr_id,
  autodir_expected_usage_dt_tm,autodir_associated_dt_tm)
   SET gsub_ad_status = "OK"
   INSERT  FROM auto_directed ad
    SET ad.product_event_id = autodir_event_id, ad.product_id = a_pseqnbr, ad.person_id =
     autodir_person_id,
     ad.encntr_id = autodir_encntr_id, ad.expected_usage_dt_tm = cnvtdatetime(
      autodir_expected_usage_dt_tm), ad.associated_dt_tm = cnvtdatetime(autodir_associated_dt_tm),
     ad.active_ind = 1, ad.active_status_cd = reqdata->active_status_cd, ad.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     ad.active_status_prsnl_id = reqinfo->updt_id, ad.updt_cnt = 0, ad.updt_dt_tm = cnvtdatetime(
      curdate,curtime3),
     ad.updt_id = reqinfo->updt_id, ad.updt_task = reqinfo->updt_task, ad.updt_applctx = reqinfo->
     updt_applctx
    WITH counter
   ;end insert
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Select"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET y = (y+ 1)
    IF (y > 1)
     SET stat = alter(reply->status_data.subeventstatus,(y+ 1))
    ENDIF
    SET gsub_ad_status = "F"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_quarantine(quar_event_id,reason_cd)
   SET gsub_quar_status = "OK"
   INSERT  FROM quarantine q
    SET q.product_event_id = quar_event_id, q.product_id = new_seqnbr, q.quar_reason_cd = reason_cd,
     q.active_ind = 1, q.active_status_cd = reqdata->active_status_cd, q.active_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     q.active_status_prsnl_id = reqinfo->updt_id, q.updt_cnt = 0, q.updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     q.updt_id = reqinfo->updt_id, q.updt_task = reqinfo->updt_task, q.updt_applctx = reqinfo->
     updt_applctx
    WITH counter
   ;end insert
   SET serror_check = error(serrormsg,0)
   IF (serror_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "Error!"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Quarantine insert"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = serror
    GO TO exit_program
   ENDIF
   IF (curqual=0)
    SET gsub_quar_status = "FI"
   ENDIF
 END ;Subroutine
 SUBROUTINE bbt_add_destroyed_event(sub_product_id,sub_event_dt_tm,sub_dispose_reason_code,
  sub_disposed_qty,sub_disposed_intl_units,sub_method_cd,sub_autoclave_ind,sub_box_nbr,
  sub_manifest_nbr,sub_destruction_org_id)
   SET event_states_added = "I"
   SET disposed_event_cd = 0.0
   SET destroyed_event_cd = 0.0
   SET auto_event_cd = 0.0
   SET dir_event_cd = 0.0
   SET unconfirmed_event_cd = 0.0
   SET nidx = 0
   SET struct_count = 0
   RECORD event_list(
     1 qual[*]
       2 product_event_id = f8
   )
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"14",cv_cnt,destroyed_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"10",cv_cnt,auto_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"11",cv_cnt,dir_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"9",cv_cnt,unconfirmed_event_cd)
   SET cv_cnt = 1
   SET stat = uar_get_meaning_by_codeset(1610,"5",cv_cnt,disposed_event_cd)
   IF (((destroyed_event_cd=0) OR (((auto_event_cd=0) OR (((dir_event_cd=0) OR (((
   unconfirmed_event_cd=0) OR (disposed_event_cd=0)) )) )) )) )
    SET event_states_added = "F"
   ENDIF
   IF (event_states_added="I")
    SET disposed_event_id = 0.0
    SET new_pathnet_seq = 0.0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)"#####################;rp0"
     FROM dual
     DETAIL
      new_pathnet_seq = cnvtint(seqn)
     WITH format, nocounter
    ;end select
    INSERT  FROM product_event p
     SET p.product_event_id = new_pathnet_seq, p.product_id = sub_product_id, p.event_type_cd =
      disposed_event_cd,
      p.event_dt_tm = cnvtdatetime(sub_event_dt_tm), p.event_prsnl_id = reqinfo->updt_id, p
      .event_status_flag = 0,
      p.order_id = 0, p.event_prsnl_id = reqinfo->updt_id, p.active_ind = 0,
      p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_cd = reqdata->
      inactive_status_cd, p.active_status_prsnl_id = reqinfo->updt_id,
      p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_task = reqinfo->updt_task,
      p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET event_states_added = "F"
    ENDIF
    IF (event_states_added != "F")
     INSERT  FROM disposition d
      SET d.product_event_id = new_pathnet_seq, d.product_id = sub_product_id, d.reason_cd =
       sub_dispose_reason_code,
       d.disposed_qty = sub_disposed_qty, d.disposed_intl_units = 0, d.active_ind = 0,
       d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm = cnvtdatetime(curdate,
        curtime3), d.active_status_prsnl_id = reqinfo->updt_id,
       d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
       d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task
      WITH counter
     ;end insert
     IF (curqual=0)
      SET event_states_added = "F"
     ELSE
      SET disposed_event_id = new_pathnet_seq
     ENDIF
     IF (event_states_added != "F")
      SELECT INTO "nl:"
       p.product_event_id, p.event_type_cd
       FROM product_event p
       WHERE p.product_id=sub_product_id
        AND p.active_ind=1
       DETAIL
        IF (p.event_type_cd != auto_event_cd
         AND p.event_type_cd != dir_event_cd
         AND p.event_type_cd != unconfirmed_event_cd)
         struct_count = (struct_count+ 1), stat = alterlist(event_list->qual,struct_count),
         event_list->qual[struct_count].product_event_id = p.product_event_id
        ENDIF
       WITH counter
      ;end select
      FOR (nidx = 1 TO struct_count)
        SELECT INTO "nl:"
         p.*
         FROM product_event p
         WHERE (p.product_event_id=event_list->qual[nidx].product_event_id)
         WITH counter, forupdate(p)
        ;end select
        IF (curqual=0)
         SET event_states_added = "F"
        ENDIF
        IF (event_states_added != "F")
         UPDATE  FROM product_event p
          SET p.active_ind = 0, p.active_status_cd = reqdata->inactive_status_cd, p
           .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
           p.active_status_prsnl_id = reqinfo->updt_id, p.updt_id = reqinfo->updt_id, p.updt_cnt = (p
           .updt_cnt+ 1),
           p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm =
           cnvtdatetime(curdate,curtime3)
          WHERE (p.product_event_id=event_list->qual[nidx].product_event_id)
          WITH nocounter
         ;end update
         IF (curqual=0)
          SET event_states_added = "F"
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF (event_states_added != "F")
      SET new_pathnet_seq = 0.0
      SELECT INTO "nl:"
       seqn = seq(pathnet_seq,nextval)"#####################;rp0"
       FROM dual
       DETAIL
        new_pathnet_seq = cnvtint(seqn)
       WITH format, nocounter
      ;end select
      INSERT  FROM product_event p
       SET p.product_event_id = new_pathnet_seq, p.product_id = sub_product_id, p.event_type_cd =
        destroyed_event_cd,
        p.event_dt_tm = cnvtdatetime(sub_event_dt_tm), p.related_product_event_id = disposed_event_id,
        p.event_prsnl_id = reqinfo->updt_id,
        p.event_status_flag = 0, p.order_id = 0, p.active_ind = 1,
        p.active_status_dt_tm = cnvtdatetime(curdate,curtime3), p.active_status_cd = reqdata->
        active_status_cd, p.active_status_prsnl_id = reqinfo->updt_id,
        p.updt_id = reqinfo->updt_id, p.updt_cnt = 0, p.updt_task = reqinfo->updt_task,
        p.updt_applctx = reqinfo->updt_applctx, p.updt_dt_tm = cnvtdatetime(curdate,curtime3)
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET event_states_added = "F"
      ENDIF
      IF (event_states_added != "F")
       INSERT  FROM destruction d
        SET d.product_id = sub_product_id, d.product_event_id = new_pathnet_seq, d.autoclave_ind =
         sub_autoclave_ind,
         d.method_cd = sub_method_cd, d.box_nbr = sub_box_nbr, d.manifest_nbr = sub_manifest_nbr,
         d.destroyed_qty = sub_disposed_qty, d.destruction_org_id = sub_destruction_org_id, d
         .active_ind = 1,
         d.active_status_cd = reqdata->active_status_cd, d.active_status_dt_tm = cnvtdatetime(curdate,
          curtime3), d.active_status_prsnl_id = reqinfo->updt_id,
         d.updt_cnt = 0, d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_id = reqinfo->updt_id,
         d.updt_applctx = reqinfo->updt_applctx, d.updt_task = reqinfo->updt_task
        WITH counter
       ;end insert
       IF (curqual=0)
        SET event_states_added = "F"
       ENDIF
      ENDIF
     ENDIF
    ENDIF
    IF (event_states_added="I")
     SET event_states_added = "S"
    ENDIF
   ENDIF
 END ;Subroutine
#exit_program
 IF (failed="F")
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
  COMMIT
 ELSE
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ENDIF
END GO
