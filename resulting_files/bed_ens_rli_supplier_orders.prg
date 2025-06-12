CREATE PROGRAM bed_ens_rli_supplier_orders
 FREE SET reply
 RECORD reply(
   1 order_list[*]
     2 catalog_cd = f8
     2 mnemonic = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE numorders = i4
 DECLARE sendout_suffix = vc
 DECLARE action_flag = i2
 DECLARE error_flag = vc WITH protect
 DECLARE error_msg = vc WITH protect
 DECLARE error_count = i2
 DECLARE fatal_error = vc
 DECLARE dup_order = vc
 DECLARE dup_dta = vc
 DECLARE dup_mnemonic = vc
 DECLARE msg = vc
 DECLARE dtacnt = i4
 DECLARE first_container = vc
 DECLARE new_order_id = f8
 DECLARE new_dta_id = f8
 DECLARE dept_name = vc
 DECLARE spectype_found = i2
 DECLARE container_found = i2
 DECLARE spec_handle_found = i2
 DECLARE coll_method_found = i2
 DECLARE accn_class_found = i2
 DECLARE coll_class_found = i2
 DECLARE supplier_meaning = vc
 DECLARE supplier_flag = i4
 DECLARE container_id = f8
 DECLARE add_error = vc
 DECLARE chg_error = vc
 SET syncnt = 0
 SET childcnt = 0
 DECLARE ch_cdesc = vc
 DECLARE ch_container_id = f8
 DECLARE child_order_id = f8
 FREE SET clist
 RECORD clist(
   1 cntr[*]
     2 desc = vc
     2 op = vc
     2 cntr_cd = f8
 )
 DECLARE c_string = vc
 DECLARE start_pos = i2
 DECLARE end_pos = i2
 DECLARE op = vc
 DECLARE top = vc
 DECLARE opflag = i2
 DECLARE sze = i2
 DECLARE length = i2
 DECLARE tdesc = vc
 DECLARE csze = i4
 SET rvar = 0
 SELECT INTO "ccluserdir:bed_rli_supplier_orders.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Bedrock RLI Supplier Orders Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SELECT INTO "ccluserdir:bed_rli_supplier_orders_error.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "Bedrock RLI Supplier Orders Error Log"
  DETAIL
   row + 2, col 2, " "
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SET error_flag = "F"
 SET fatal_error = "N"
 SET error_count = 0
 SET supplier_meaning = " "
 SET supplier_flag = 0
 SET new_order_id = 0.0
 SET msg = fillstring(300," ")
 SELECT INTO "nl:"
  FROM br_rli_supplier brs
  PLAN (brs
   WHERE (brs.supplier_flag=request->rli_supplier_flag))
  DETAIL
   supplier_meaning = brs.supplier_meaning, sendout_suffix = brs.supplier_prefix, supplier_flag = brs
   .supplier_flag
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET error_flag = "T"
  SET error_msg = concat("No supplier data found for ",cnvtstring(request->rli_supplier_flag))
  SET msg = error_msg
  CALL logerrormessage(msg)
  GO TO exit_script
 ENDIF
 SET numorders = size(request->orders,5)
 FOR (ii = 1 TO numorders)
  CASE (trim(request->orders[ii].action_flag))
   OF "ADD":
    SET action_flag = 1
   OF "UPD":
    SET action_flag = 2
   OF "CHG":
    SET action_flag = 2
   OF "DEL":
    SET action_flag = 3
  ENDCASE
  IF (action_flag=1)
   SET stat = add_rli_order(ii)
  ELSEIF (action_flag=2)
   SET stat = chg_rli_order(ii)
  ELSEIF (action_flag=3)
   SET stat = del_rli_order(ii)
  ELSE
   SET msg = concat("Invalid action flag for order: ",request->orders[ii].order_desc)
   CALL logerrormessage(msg)
  ENDIF
 ENDFOR
 SUBROUTINE add_rli_order(ii)
   SET add_error = "N"
   SET dup_order = "N"
   CALL check_dup_order(ii)
   IF (dup_order="Y")
    SET msg = concat(" ADD transaction sent for existing order alias: ",trim(request->orders[ii].
      alias),".  Mnemonic:",trim(request->orders[ii].order_mnemonic))
    CALL logerrormessage(msg)
    SET add_error = "Y"
   ENDIF
   IF (add_error="N")
    CALL check_dup_mnemonic(ii)
    IF (dup_mnemonic="Y")
     SET msg = concat(" Duplicate primary mnemonic: ",trim(request->orders[ii].order_mnemonic))
     CALL logerrormessage(msg)
     SET add_error = "Y"
    ENDIF
   ENDIF
   IF (add_error="N")
    SET spectype_found = 0
    SELECT INTO "nl:"
     FROM br_auto_rli_alias bara
     PLAN (bara
      WHERE (bara.alias_name=request->orders[ii].specimen_type)
       AND bara.code_set=2052
       AND bara.supplier_flag=supplier_flag)
     DETAIL
      spectype_found = 1
     WITH nocounter
    ;end select
    IF (spectype_found=0)
     SET msg = concat(" No specimen type alias value found for: ",trim(request->orders[ii].
       specimen_type)," Mnemonic: ",trim(request->orders[ii].order_mnemonic))
     CALL logerrormessage(msg)
     SET add_error = "Y"
    ENDIF
   ENDIF
   IF (add_error="N")
    SET container_found = 0
    SET container_id = 0.0
    IF (((supplier_flag=2) OR (supplier_flag=1)) )
     SET c_string = request->orders[ii].container
     IF (supplier_flag=2)
      CALL parse_mayo_container(c_string)
     ELSE
      CALL parse_arup_container(c_string)
     ENDIF
     SET container_found = clist->cntr[1].cntr_cd
     IF (container_found=0)
      SET msg = concat(" No container alias found for :",trim(request->orders[ii].container),
       " Mnemonic: ",trim(request->orders[ii].order_mnemonic))
      CALL logerrormessage(msg)
      SET add_error = "Y"
     ENDIF
    ELSE
     SET csze = 1
     SELECT INTO "nl:"
      FROM br_auto_rli_alias bara
      PLAN (bara
       WHERE (bara.alias_name=request->orders[ii].container)
        AND bara.code_set=2051
        AND bara.supplier_flag=supplier_flag)
      DETAIL
       container_found = 1, container_id = bara.alias_id
      WITH nocounter
     ;end select
     IF (container_found=0)
      SET msg = concat(" No container alias found for :",trim(request->orders[ii].container),
       " Mnemonic: ",trim(request->orders[ii].order_mnemonic))
      CALL logerrormessage(msg)
      SET add_error = "Y"
     ELSE
      SET stat = alterlist(clist->cntr,1)
      SET clist->cntr[1].cntr_cd = container_id
      SET clist->cntr[1].desc = request->orders[ii].container
     ENDIF
    ENDIF
   ENDIF
   IF (add_error="N")
    SET spec_handle_found = 0
    SELECT INTO "nl:"
     FROM br_auto_rli_alias bara
     PLAN (bara
      WHERE (bara.alias_name=request->orders[ii].spec_handling)
       AND bara.code_set=230
       AND bara.supplier_flag=supplier_flag)
     DETAIL
      spec_handle_found = 1
     WITH nocounter
    ;end select
    IF (spec_handle_found=0)
     SET msg = concat(" No special handling alias value found for: ",trim(request->orders[ii].
       spec_handling)," Mnemonic: ",trim(request->orders[ii].order_mnemonic))
     CALL logerrormessage(msg)
     SET add_error = "Y"
    ENDIF
   ENDIF
   IF (add_error="N")
    SET coll_class_found = 0
    SELECT INTO "nl:"
     FROM br_auto_rli_alias bara
     PLAN (bara
      WHERE cnvtupper(bara.alias_name)=cnvtupper(request->orders[ii].coll_class)
       AND bara.code_set=231
       AND bara.supplier_flag=supplier_flag)
     DETAIL
      coll_class_found = 1
     WITH nocounter
    ;end select
    IF (coll_class_found=0)
     SET msg = concat(" No collection class alias value found for: ",trim(request->orders[ii].
       coll_class),"Mnemonic: ",trim(request->orders[ii].order_mnemonic))
     CALL logerrormessage(msg)
     SET add_error = "Y"
    ENDIF
   ENDIF
   IF (add_error="N")
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_order_id = cnvtreal(j)
     WITH format, counter
    ;end select
    IF ((request->orders[ii].dept_name > " "))
     SET dept_name = concat(trim(request->orders[ii].dept_name),"-",sendout_suffix)
    ELSE
     SET dept_name = concat(trim(request->orders[ii].order_mnemonic),"-",sendout_suffix)
    ENDIF
    INSERT  FROM br_auto_rli_order b
     SET b.rli_order_id = new_order_id, b.supplier_flag = supplier_flag, b.order_desc = concat(trim(
        request->orders[ii].order_desc),"-",sendout_suffix),
      b.performing_loc = request->orders[ii].performing_loc, b.order_mnemonic = concat(trim(request->
        orders[ii].order_mnemonic),"-",sendout_suffix), b.supplier_mnemonic = concat(sendout_suffix,
       "-",trim(request->orders[ii].supplier_mnemonic)),
      b.dept_name = dept_name, b.alias_name = request->orders[ii].alias, b.specimen_type = request->
      orders[ii].specimen_type,
      b.special_handling = request->orders[ii].spec_handling, b.container = request->orders[ii].
      container, b.min_vol_value = cnvtreal(request->orders[ii].min_vol),
      b.min_vol_units = request->orders[ii].min_vol_units, b.transfer_temp = request->orders[ii].
      transfer_temp, b.collection_method = request->orders[ii].coll_method,
      b.accession_class = request->orders[ii].accn_class, b.collection_class = request->orders[ii].
      coll_class, b.concept_cki = request->orders[ii].concept_cki,
      b.parent_order_id = 0, b.active_ind = 1, b.updt_dt_tm = cnvtdatetime(curdate,curtime),
      b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_task = reqinfo->updt_task,
      b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     INSERT  FROM br_auto_rli_container barc
      SET barc.rli_order_id = new_order_id, barc.supplier_flag = supplier_flag, barc.container =
       clist->cntr[1].desc,
       barc.container_alias_id = clist->cntr[1].cntr_cd, barc.updt_dt_tm = cnvtdatetime(curdate,
        curtime), barc.updt_id = reqinfo->updt_id,
       barc.updt_cnt = 0, barc.updt_task = reqinfo->updt_task, barc.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
     IF (csze > 1)
      INSERT  FROM br_rli_container_reltn brcr
       SET brcr.rli_order_id = new_order_id, brcr.supplier_flag = supplier_flag, brcr.operand = clist
        ->cntr[1].op,
        brcr.active_ind = 1
       WITH nocounter
      ;end insert
      FOR (cc = 2 TO csze)
        INSERT  FROM br_auto_rli_container barc
         SET barc.rli_order_id = new_order_id, barc.supplier_flag = supplier_flag, barc.container =
          clist->cntr[cc].desc,
          barc.container_alias_id = clist->cntr[cc].cntr_cd, barc.updt_dt_tm = cnvtdatetime(curdate,
           curtime), barc.updt_id = reqinfo->updt_id,
          barc.updt_cnt = 0, barc.updt_task = reqinfo->updt_task, barc.updt_applctx = reqinfo->
          updt_applctx
         WITH nocounter
        ;end insert
      ENDFOR
     ENDIF
    ENDIF
    SET dtacnt = size(request->orders[ii].assay_list,5)
    FOR (jj = 1 TO dtacnt)
      CALL check_dup_dta(ii,jj)
      IF (dup_dta="N")
       CALL add_dta(ii,jj)
      ENDIF
      CALL echo(build("add_error = ",add_error))
      IF (add_error="N")
       CALL add_oc_dta_reltn(ii)
      ENDIF
    ENDFOR
    IF (add_error="N")
     CALL add_orc_summary(ii)
    ENDIF
    IF (add_error="N")
     SET msg = concat("Successfully added RLI order: ",request->orders[ii].order_mnemonic)
     CALL logmessage(msg)
    ENDIF
   ELSE
    SET msg = concat("Error creating order catalog row for :",request->orders[ii].order_mnemonic,
     " Alias: ",request->orders[ii].alias)
    CALL logerrormessage(msg)
    SET add_error = "Y"
   ENDIF
   SET syncnt = size(request->orders[ii].synonym_list,5)
   IF (syncnt > 0)
    FOR (ss = 1 TO syncnt)
      IF ((request->orders[ii].synonym_list[ss].synonym > " "))
       INSERT  FROM br_auto_rli_synonym bars
        SET bars.rli_order_id = new_order_id, bars.synonym_type_flag = cnvtint(request->orders[ii].
          synonym_list[ss].synonym_type), bars.synonym_name = concat(request->orders[ii].
          synonym_list[ss].synonym,"-",sendout_suffix),
         bars.supplier_flag = supplier_flag, bars.synonym_seq = ss, bars.updt_cnt = 0,
         bars.updt_dt_tm = cnvtdatetime(curdate,curtime3), bars.updt_id = reqinfo->updt_id, bars
         .updt_task = reqinfo->updt_task,
         bars.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
      ENDIF
    ENDFOR
   ENDIF
   SET childcnt = size(request->orders[ii].child_list,5)
   IF (childcnt > 0)
    FOR (cc = 1 TO childcnt)
      SELECT INTO "NL:"
       j = seq(bedrock_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        child_order_id = cnvtreal(j)
       WITH format, counter
      ;end select
      INSERT  FROM br_auto_rli_order b
       SET b.rli_order_id = child_order_id, b.parent_order_id = new_order_id, b.supplier_flag =
        supplier_flag,
        b.order_desc = concat(trim(request->orders[ii].order_desc),"-",sendout_suffix), b
        .performing_loc = request->orders[ii].performing_loc, b.order_mnemonic = concat(trim(request
          ->orders[ii].order_mnemonic),"-",sendout_suffix),
        b.supplier_mnemonic = concat(sendout_suffix,"-",trim(request->orders[ii].supplier_mnemonic)),
        b.dept_name = dept_name, b.alias_name = request->orders[ii].alias,
        b.specimen_type = request->orders[ii].child_list[cc].specimen_type, b.special_handling =
        request->orders[ii].child_list[cc].spec_handling, b.container = request->orders[ii].
        child_list[cc].container,
        b.min_vol_value = cnvtreal(request->orders[ii].child_list[cc].min_vol), b.min_vol_units =
        request->orders[ii].child_list[cc].min_vol_units, b.transfer_temp = request->orders[ii].
        child_list[cc].transfer_temp,
        b.collection_method = request->orders[ii].child_list[cc].coll_method, b.accession_class =
        request->orders[ii].child_list[cc].accn_class, b.collection_class = request->orders[ii].
        child_list[cc].coll_class,
        b.concept_cki = request->orders[ii].concept_cki, b.active_ind = 1, b.updt_dt_tm =
        cnvtdatetime(curdate,curtime),
        b.updt_id = reqinfo->updt_id, b.updt_cnt = 0, b.updt_task = reqinfo->updt_task,
        b.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      SET ch_container_id = 0.0
      SET ch_cdesc = " "
      SELECT INTO "nl:"
       FROM br_auto_rli_alias bara
       PLAN (bara
        WHERE (bara.alias_name=request->orders[ii].child_list[cc].container)
         AND bara.code_set=2051
         AND bara.supplier_flag=supplier_flag)
       DETAIL
        container_found = 1, ch_container_id = bara.alias_id, ch_cdesc = bara.alias_name
       WITH nocounter
      ;end select
      INSERT  FROM br_auto_rli_container barc
       SET barc.rli_order_id = child_order_id, barc.supplier_flag = supplier_flag, barc.container =
        ch_cdesc,
        barc.container_alias_id = ch_container_id, barc.updt_dt_tm = cnvtdatetime(curdate,curtime),
        barc.updt_id = reqinfo->updt_id,
        barc.updt_cnt = 0, barc.updt_task = reqinfo->updt_task, barc.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE chg_rli_order(ii)
   DECLARE rli_order_id = f8
   SET rli_order_id = 0.0
   SET chg_error = "N"
   SELECT INTO "nl:"
    FROM br_auto_rli_order b
    WHERE (b.alias_name=request->orders[ii].alias)
     AND b.supplier_flag=supplier_flag
     AND b.active_ind=1
    DETAIL
     rli_order_id = b.rli_order_id
    WITH nocounter
   ;end select
   IF (rli_order_id=0.0)
    SET msg = concat(error_msg,"Unable to retrieve rli_order_id for: ",request->orders[ii].alias,
     " to update order.")
    CALL logerrormessage(msg)
    SET chg_error = "Y"
   ENDIF
   IF (chg_error="N")
    SET spectype_found = 0
    SELECT INTO "nl:"
     FROM br_auto_rli_alias ba
     PLAN (ba
      WHERE (ba.alias_name=request->orders[ii].specimen_type)
       AND ba.code_set=2052
       AND ba.supplier_flag=supplier_flag)
     DETAIL
      spectype_found = 1
     WITH nocounter
    ;end select
    IF (spectype_found=0)
     SET msg = concat(" No specimen type alias value found for: ",trim(request->orders[ii].
       specimen_type)," Mnemonic: ",trim(request->orders[ii].order_mnemonic))
     CALL logerrormessage(msg)
     SET chg_error = "Y"
    ENDIF
   ENDIF
   IF (chg_error="N")
    SET container_found = 0
    SET container_id = 0.0
    IF (((supplier_flag=2) OR (supplier_flag=1)) )
     SET c_string = request->orders[ii].container
     IF (supplier_flag=2)
      CALL parse_mayo_container(c_string)
     ELSE
      CALL parse_arup_container(c_string)
     ENDIF
     SET container_found = clist->cntr[1].cntr_cd
     IF (container_found=0)
      SET msg = concat(" No container alias found for :",trim(request->orders[ii].container),
       " Mnemonic: ",trim(request->orders[ii].order_mnemonic))
      CALL logerrormessage(msg)
      SET add_error = "Y"
     ENDIF
    ELSE
     SET csze = 1
     SELECT INTO "nl:"
      FROM br_auto_rli_alias bara
      PLAN (bara
       WHERE (bara.alias_name=request->orders[ii].container)
        AND bara.code_set=2051
        AND bara.supplier_flag=supplier_flag)
      DETAIL
       container_id = bara.alias_id, container_found = 1
      WITH nocounter
     ;end select
     IF (container_found=0)
      SET msg = concat(" No container alias found for :",trim(request->orders[ii].container),
       " Mnemonic: ",trim(request->orders[ii].order_mnemonic))
      CALL logerrormessage(msg)
      SET chg_error = "Y"
     ENDIF
    ENDIF
   ENDIF
   IF (chg_error="N")
    SET spec_handle_found = 0
    SELECT INTO "nl:"
     FROM br_auto_rli_alias ba
     PLAN (ba
      WHERE (ba.alias_name=request->orders[ii].spec_handling)
       AND ba.code_set=230
       AND ba.supplier_flag=supplier_flag)
     DETAIL
      spec_handle_found = 1
     WITH nocounter
    ;end select
    IF (spec_handle_found=0)
     SET msg = concat(" No special handling alias value found for: ",trim(request->orders[ii].
       spec_handling)," Mnemonic: ",trim(request->orders[ii].order_mnemonic))
     CALL logerrormessage(msg)
     SET chg_error = "Y"
    ENDIF
   ENDIF
   IF (chg_error="N")
    SET coll_class_found = 0
    SELECT INTO "nl:"
     FROM br_auto_rli_alias ba
     PLAN (ba
      WHERE (ba.alias_name=request->orders[ii].coll_class)
       AND ba.code_set=231
       AND ba.supplier_flag=supplier_flag)
     DETAIL
      coll_class_found = 1
     WITH nocounter
    ;end select
    IF (coll_class_found=0)
     SET msg = concat(" No collection class alias value found for: ",trim(request->orders[ii].
       coll_class),"Mnemonic: ",trim(request->orders[ii].order_mnemonic))
     CALL logerrormessage(msg)
     SET chg_error = "Y"
    ENDIF
   ENDIF
   IF (chg_error="N")
    IF ((request->orders[ii].dept_name > " "))
     SET dept_name = concat(trim(request->orders[ii].dept_name),"-",sendout_suffix)
    ELSE
     SET dept_name = concat(trim(request->orders[ii].order_mnemonic),"-",sendout_suffix)
    ENDIF
    UPDATE  FROM br_auto_rli_order b
     SET b.order_desc = request->orders[ii].order_desc, b.performing_loc = request->orders[ii].
      performing_loc, b.order_mnemonic = concat(trim(request->orders[ii].order_mnemonic),"-",
       sendout_suffix),
      b.supplier_mnemonic = concat(sendout_suffix,"-",trim(request->orders[ii].supplier_mnemonic)), b
      .dept_name = dept_name, b.specimen_type = request->orders[ii].specimen_type,
      b.special_handling = request->orders[ii].spec_handling, b.min_vol_value = cnvtreal(request->
       orders[ii].min_vol), b.min_vol_units = request->orders[ii].min_vol_units,
      b.transfer_temp = request->orders[ii].transfer_temp, b.collection_method = request->orders[ii].
      coll_method, b.accession_class = request->orders[ii].accn_class,
      b.collection_class = request->orders[ii].coll_class, b.updt_dt_tm = cnvtdatetime(curdate,
       curtime), b.updt_cnt = (b.updt_cnt+ 1),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
      updt_applctx
     WHERE b.rli_order_id=rli_order_id
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET msg = concat(" Unable to update br_auto_rli_orders for: ",trim(request->orders[ii].
       coll_class),"Mnemonic: ",trim(request->orders[ii].order_mnemonic))
     CALL logerrormessage(msg)
     SET chg_error = "Y"
    ENDIF
   ENDIF
   IF (chg_error="N")
    DELETE  FROM br_rli_container_reltn brcr
     WHERE (brcr.rli_order_id=(rli_order - id))
      AND brcr.supplier_flag=supplier_flag
     WITH nocounter
    ;end delete
    IF (curqual > 0)
     INSERT  FROM br_auto_rli_container barc
      SET barc.rli_order_id = rli_order_id, barc.supplier_flag = supplier_flag, barc.container =
       clist->cntr[1].desc,
       barc.container_alias_id = clist->cntr[1].cntr_cd, barc.updt_dt_tm = cnvtdatetime(curdate,
        curtime), barc.updt_id = reqinfo->updt_id,
       barc.updt_cnt = 0, barc.updt_task = reqinfo->updt_task, barc.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
     IF (csze > 1)
      INSERT  FROM br_rli_container_reltn brcr
       SET brcr.rli_order_id = rli_order_id, brcr.supplier_flag = supplier_flag, brcr.operand = clist
        ->cntr[1].op,
        brcr.active_ind = 1
       WITH nocounter
      ;end insert
      FOR (cc = 2 TO csze)
        INSERT  FROM br_auto_rli_container barc
         SET barc.rli_order_id = rli_order_id, barc.supplier_flag = supplier_flag, barc.container =
          clist->cntr[cc].desc,
          barc.container_alias_id = clist->cntr[cc].cntr_cd, barc.updt_dt_tm = cnvtdatetime(curdate,
           curtime), barc.updt_id = reqinfo->updt_id,
          barc.updt_cnt = 0, barc.updt_task = reqinfo->updt_task, barc.updt_applctx = reqinfo->
          updt_applctx
         WITH nocounter
        ;end insert
      ENDFOR
     ENDIF
    ENDIF
    DELETE  FROM br_auto_rli_order_dta_r bz
     WHERE bz.rli_order_id=rli_order_id
      AND bz.supplier_flag=supplier_flag
     WITH nocounter
    ;end delete
    SET new_order_id = rli_order_id
    SET dtacnt = size(request->orders[ii].assay_list,5)
    FOR (jj = 1 TO dtacnt)
      CALL check_dup_dta(ii,jj)
      IF (dup_dta="N")
       CALL add_dta(ii,jj)
      ENDIF
      IF (chg_error="N")
       CALL add_oc_dta_reltn(ii)
      ENDIF
    ENDFOR
    IF (chg_error="N")
     CALL add_orc_summary(ii)
    ENDIF
    SET msg = concat("Successfully updated RLI order: ",request->orders[ii].order_mnemonic)
    CALL logmessage(msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE del_rli_order(ii)
   DECLARE orderid = f8
   SET orderid = 0.0
   DECLARE del_error = vc
   SET del_error = "N"
   SELECT INTO "nl:"
    FROM br_auto_rli_order baro
    PLAN (baro
     WHERE (baro.alias_name=request->orders[ii].alias)
      AND baro.supplier_flag=supplier_flag
      AND baro.active_ind=1)
    DETAIL
     orderid = baro.rli_order_id
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET del_error = "Y"
    SET msg = concat(error_msg,"Unable to inactivate order for: ",request->orders[ii].alias,".")
    CALL logerrormessage(msg)
   ENDIF
   IF (del_error="N")
    UPDATE  FROM br_auto_rli_order baro
     SET baro.active_ind = 0, baro.updt_applctx = reqinfo->updt_applctx, baro.updt_cnt = (oc.updt_cnt
      + 1),
      baro.updt_dt_tm = cnvtdatetime(curdate,curtime), baro.updt_id = reqinfo->updt_id, baro
      .updt_task = reqinfo->updt_task
     WHERE baro.rli_order_id=orderid
      AND baro.supplier_flag=supplier_flag
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET msg = concat(error_msg,"Unable to inactivate order for: ",request->orders[ii].alias,".")
     CALL logerrormessage(msg)
     SET del_error = "Y"
    ENDIF
   ENDIF
   IF (del_error="N")
    UPDATE  FROM br_auto_rli_order_dta_r bz
     SET bz.active_ind = 0, bz.updt_applctx = reqinfo->updt_applctx, bz.updt_cnt = (ocs.updt_cnt+ 1),
      bz.updt_dt_tm = cnvtdatetime(curdate,curtime), bz.updt_id = reqinfo->updt_id, bz.updt_task =
      reqinfo->updt_task
     WHERE bz.rli_order_id=orderid
      AND bz.supplier_flag=supplier_flag
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET msg = concat(error_msg,"Unable to inactivate catalog synonyms for: ",request->orders[ii].
      alias," to inactivate order.")
     CALL logerrormessage(msg)
     SET del_error = "Y"
    ENDIF
   ENDIF
   IF (del_error="N")
    SET msg = concat("Successfully inactivated RLI order: ",request->orders[ii].order_mnemonic)
    CALL logmessage(msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE check_dup_order(ii)
  SELECT INTO "nl:"
   FROM br_auto_rli_order baro
   PLAN (baro
    WHERE (baro.alias_name=request->orders[ii].alias)
     AND baro.supplier_flag=supplier_flag)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET dup_order = "N"
  ELSE
   SET dup_order = "Y"
  ENDIF
 END ;Subroutine
 SUBROUTINE check_dup_mnemonic(ii)
   DECLARE temp_mnemonic = vc
   DECLARE temp_performing_loc = vc
   SET temp_performing_loc = trim(request->orders[ii].performing_loc)
   SET temp_mnemonic = concat(trim(request->orders[ii].order_mnemonic),"-",sendout_suffix)
   SELECT INTO "nl:"
    FROM br_auto_rli_order baro
    WHERE baro.order_mnemonic=temp_mnemonic
     AND baro.performing_loc=temp_performing_loc
     AND baro.supplier_flag=supplier_flag
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dup_mnemonic = "N"
   ELSE
    SET dup_mnemonic = "Y"
   ENDIF
 END ;Subroutine
 SUBROUTINE check_dup_dta(ii,jj)
   SET new_dta_id = 0.0
   SELECT INTO "nl:"
    FROM br_auto_rli_dta bard
    PLAN (bard
     WHERE bard.supplier_flag=supplier_flag
      AND bard.alias_name=trim(request->orders[ii].assay_list[jj].assay_alias))
    DETAIL
     new_dta_id = bard.rli_dta_id, dup_dta = "Y"
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET dup_dta = "N"
   ELSE
    SET dup_dta = "Y"
   ENDIF
 END ;Subroutine
 SUBROUTINE add_dta(ii,jj)
   DECLARE temp_dta_mnem = vc
   DECLARE temp_performing_loc = vc
   DECLARE dup_alias = vc
   SET temp_dta_mnem = concat(trim(request->orders[ii].assay_list[jj].assay_mnemonic),"-",
    sendout_suffix)
   SET temp_performing_loc = trim(request->orders[ii].performing_loc)
   CALL echo(build("Adding: ",temp_dta_mnem,",",request->orders[ii].assay_list[jj].assay_desc))
   SET new_dta_id = 0.0
   SET dup_dta = "N"
   SELECT INTO "nl:"
    FROM br_auto_rli_dta bard
    PLAN (bard
     WHERE bard.supplier_flag=supplier_flag
      AND bard.mnemonic=temp_dta_mnem)
    DETAIL
     dup_alias = bard.alias_name, dup_dta = "Y"
    WITH nocounter
   ;end select
   IF (dup_dta="Y")
    SELECT INTO "nl:"
     FROM br_auto_rli_dta bard
     PLAN (bard
      WHERE bard.mnemonic=temp_dta_mnem
       AND bard.performing_loc=temp_performing_loc)
     DETAIL
      dup_dta = "Y"
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET dup_dta = "N"
    ENDIF
    IF (dup_dta="Y")
     SET msg = concat("DTA: ",temp_dta_mnem," for mnemonic: ",request->orders[ii].assay_list[jj].
      assay_mnemonic," already exists under another alias.  The other alias is: ",
      dup_alias,".  Cannot add this DTA.")
     CALL logerrormessage(msg)
     SET add_error = "Y"
     CALL echo(build("Skipped: ",temp_dta_mnem,",",request->orders[ii].assay_list[jj].assay_desc))
    ENDIF
   ENDIF
   IF (dup_dta="N")
    SELECT INTO "NL:"
     j = seq(bedrock_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_dta_id = cnvtreal(j)
     WITH format, counter
    ;end select
    CALL echo(build("New dta id = ",new_dta_id))
    INSERT  FROM br_auto_rli_dta bard
     SET bard.rli_dta_id = new_dta_id, bard.description = concat(trim(request->orders[ii].assay_list[
        jj].assay_desc),"-",sendout_suffix), bard.mnemonic = concat(trim(request->orders[ii].
        assay_list[jj].assay_mnemonic),"-",sendout_suffix),
      bard.alias_name = request->orders[ii].assay_list[jj].assay_alias, bard.performing_loc = trim(
       request->orders[ii].performing_loc), bard.supplier_flag = supplier_flag,
      bard.updt_dt_tm = cnvtdatetime(curdate,curtime), bard.updt_id = reqinfo->updt_id, bard.updt_cnt
       = 0,
      bard.updt_task = reqinfo->updt_task, bard.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     CALL echo(build("Added: ",temp_dta_mnem,",",request->orders[ii].assay_list[jj].assay_desc))
     SET msg = concat("Successfully added RLI DTA: ",request->orders[ii].assay_list[jj].
      assay_mnemonic)
     CALL logmessage(msg)
    ELSE
     SET msg = concat("Unable to add DTA: ","Alias: ",request->orders[ii].assay_list[jj].assay_alias,
      "Mnemonic: ",request->orders[ii].assay_list[jj].assay_mnemonic,
      "Desc: ",request->orders[ii].assay_list[jj].assay_desc)
     CALL logerrormessage(msg)
     SET add_error = "Y"
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE add_oc_dta_reltn(ii)
   DECLARE drf = i2
   SET drf = 0
   SELECT INTO "nl:"
    FROM br_auto_rli_order_dta_r ba
    PLAN (ba
     WHERE ba.rli_order_id=new_order_id
      AND ba.rli_dta_id=new_dta_id
      AND ba.supplier_flag=supplier_flag)
    DETAIL
     drf = 1
    WITH nocounter
   ;end select
   IF (drf=0)
    INSERT  FROM br_auto_rli_order_dta_r ba
     SET ba.rli_order_id = new_order_id, ba.rli_dta_id = new_dta_id, ba.supplier_flag = supplier_flag,
      ba.updt_dt_tm = cnvtdatetime(curdate,curtime), ba.updt_id = reqinfo->updt_id, ba.updt_task =
      reqinfo->updt_task,
      ba.updt_cnt = 0, ba.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET msg = concat("Error adding dta relationship: ",request->orders[ii].order_desc,":",request->
      orders[ii].assay_list[jj].assay_desc)
     CALL logerrormessage(msg)
     SET msg = concat("New_dta_id =  ",cnvtstring(new_dta_id))
     CALL logerrormessage(msg)
    ENDIF
   ELSE
    SET msg = concat("DTA relationship already exists for : ",request->orders[ii].order_desc,":",
     request->orders[ii].assay_list[jj].assay_desc)
    CALL logerrormessage(msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE add_orc_summary(ii)
   DECLARE oseq = i4
   DECLARE csz = i2
   DECLARE ctr1 = vc
   DECLARE ctr2 = vc
   DECLARE ctr3 = vc
   DECLARE ctr4 = vc
   DECLARE ctr5 = vc
   SET oseq = 0
   IF (supplier_flag=2)
    SET csz = size(clist->cntr,5)
    SET ctr1 = clist->cntr[1].desc
    IF (csz > 1)
     SET ctr2 = clist->cntr[2].desc
     IF (csz > 2)
      SET ctr3 = clist->cntr[3].desc
      IF (csz > 3)
       SET ctr4 = clist->cntr[4].desc
       IF (csz > 4)
        SET ctr5 = clist->cntr[5].desc
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET ctr1 = clist->cntr[1].desc
   ENDIF
   SELECT INTO "nl:"
    FROM br_rli_orc_summary bros
    PLAN (bros
     WHERE bros.rli_order_id=new_order_id
      AND bros.supplier_flag=supplier_flag)
    DETAIL
     IF (oseq < bros.sequence)
      oseq = bros.sequence
     ENDIF
    WITH nocounter
   ;end select
   SET oseq = (oseq+ 1)
   INSERT  FROM br_rli_orc_summary bros
    SET bros.rli_order_id = new_order_id, bros.supplier_flag = supplier_flag, bros.sequence = oseq,
     bros.spec_type = request->orders[ii].specimen_type, bros.special_handling = request->orders[ii].
     spec_handling, bros.accn_class = request->orders[ii].accn_class,
     bros.coll_class = request->orders[ii].coll_class, bros.coll_method = request->orders[ii].
     coll_method, bros.container1 = ctr1,
     bros.container2 = ctr2, bros.container3 = ctr3, bros.container4 = ctr4,
     bros.container5 = ctr5, bros.min_vol = request->orders[ii].min_vol, bros.updt_dt_tm =
     cnvtdatetime(curdate,curtime),
     bros.updt_id = reqinfo->updt_id, bros.updt_cnt = 0, bros.updt_task = reqinfo->updt_task,
     bros.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET msg = concat("Error adding br_rli_orc_summary row: ",request->orders[ii].order_desc)
    CALL logerrormessage(msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE parse_mayo_container(c_string)
   SET sze = size(c_string,1)
   SET end_pos = 0
   SET start_pos = 0
   SET csze = 1
   WHILE (end_pos < sze)
     SET start_pos = findstring(":",c_string,(start_pos+ 1),0)
     IF (start_pos=0)
      SET stat = alterlist(clist->cntr,csze)
      SET clist->cntr[csze].desc = trim(c_string,3)
      SET clist->cntr[csze].op = " "
      SET end_pos = sze
     ELSE
      SET end_pos = findstring(" OR ",c_string,start_pos,0)
      IF (end_pos=0)
       SET end_pos = findstring(" AND ",c_string,start_pos,0)
       IF (end_pos=0)
        SET end_pos = sze
       ELSE
        SET opflag = 2
       ENDIF
      ELSE
       SET opflag = 1
      ENDIF
      IF (end_pos=sze)
       SET length = (end_pos - start_pos)
      ELSE
       SET length = ((end_pos - start_pos) - 1)
      ENDIF
      SET stat = alterlist(clist->cntr,csze)
      SET clist->cntr[csze].desc = trim(substring((start_pos+ 1),length,c_string),3)
      IF (end_pos=sze)
       SET clist->cntr[csze].op = " "
      ELSE
       IF (opflag=1)
        SET clist->cntr[csze].op = "OR"
       ELSE
        SET clist->cntr[csze].op = "AND"
       ENDIF
      ENDIF
     ENDIF
     SET csze = (csze+ 1)
   ENDWHILE
   SET csze = (csze - 1)
   FOR (zz = 1 TO csze)
    SELECT INTO "nl:"
     FROM br_auto_rli_alias bara
     PLAN (bara
      WHERE (bara.alias_name=clist->cntr[zz].desc)
       AND bara.code_set=2051
       AND bara.supplier_flag=supplier_flag)
     DETAIL
      clist->cntr[zz].cntr_cd = bara.alias_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET clist->cntr[zz].cntr_cd = 0
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE parse_arup_container(c_string)
   SET sze = size(c_string,1)
   SET end_pos = 0
   SET start_pos = 0
   SET csze = 1
   SET found_or = 0
   SET found_and = 0
   SET found_or = findstring(" OR ",c_string,start_pos,0)
   SET found_and = findstring(" AND ",c_string,start_pos,0)
   IF (found_or=0
    AND found_and=0)
    SET stat = alterlist(clist->cntr,1)
    SET clist->cntr[csze].desc = trim(c_string,3)
    SET clist->cntr[csze].op = " "
    SET end_pos = sze
    SET csze = (csze+ 1)
   ENDIF
   SET start_pos = 0
   WHILE (end_pos < sze)
     SET end_pos = findstring(" OR ",c_string,start_pos,0)
     IF (end_pos=0)
      SET end_pos = findstring(" AND ",c_string,start_pos,0)
      IF (end_pos=0)
       SET end_pos = sze
      ELSE
       SET opflag = 2
      ENDIF
     ELSE
      SET opflag = 1
     ENDIF
     IF (end_pos=sze)
      SET length = (end_pos - start_pos)
     ELSE
      SET length = ((end_pos - start_pos) - 1)
     ENDIF
     SET stat = alterlist(clist->cntr,csze)
     SET clist->cntr[csze].desc = trim(substring((start_pos+ 1),length,c_string),3)
     IF (end_pos=sze)
      SET clist->cntr[csze].op = " "
     ELSE
      IF (opflag=1)
       SET clist->cntr[csze].op = "OR"
      ELSE
       SET clist->cntr[csze].op = "AND"
      ENDIF
     ENDIF
     SET csze = (csze+ 1)
     IF (opflag=1)
      SET start_pos = (end_pos+ 3)
     ELSE
      SET start_pos = (end_pos+ 4)
     ENDIF
   ENDWHILE
   SET csze = (csze - 1)
   FOR (zz = 1 TO csze)
    SELECT INTO "nl:"
     FROM br_auto_rli_alias bara
     PLAN (bara
      WHERE (bara.alias_name=clist->cntr[zz].desc)
       AND bara.code_set=2051
       AND bara.supplier_flag=supplier_flag)
     DETAIL
      clist->cntr[zz].cntr_cd = bara.alias_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET clist->cntr[zz].cntr_cd = 0
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE logmessage(msg)
   SELECT INTO "ccluserdir:bed_rli_supplier_orders.log"
    rvar
    DETAIL
     row + 1, col 0, msg
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
 END ;Subroutine
 SUBROUTINE logerrormessage(msg)
   SELECT INTO "ccluserdir:bed_rli_supplier_orders_error.log"
    rvar
    DETAIL
     row + 1, col 0, msg
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 300, maxrow = 1
   ;end select
   SET error_count = (error_count+ 1)
   IF (error_count > 200)
    SET error_msg = "Program terminating:  Error threshold (20) reached.  Check error log."
    SET error_flag = "T"
    SELECT INTO "ccluserdir:bed_rli_supplier_orders_error.log"
     rvar
     DETAIL
      row + 1, col 0, error_msg
     WITH nocounter, append, format = variable,
      noformfeed, maxcol = 300, maxrow = 1
    ;end select
    GO TO exit_script
   ENDIF
   IF (fatal_error="Y")
    SET error_msg = "Program terminating:  Fatal error encountered."
    SET error_flag = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat(error_msg,
   " >> PROGRAM_NAME:  BED_ENS_RLI_SUPPLIER_ORDERS   >> ERROR MESSAGE: ",error_msg)
  SET reqinfo->commit_ind = 0
 ELSE
  IF (error_count > 0
   AND error_count < 20)
   SET reply->error_msg = "Errors encountered, but error threshold not reached.  Check error log"
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationname = "ENS"
  SET reply->status_data.subeventstatus[1].targetobjectname = "BED_ENS_RLI_SUPPLIER_ORDERS"
  SET reqinfo->commit_ind = 1
 ENDIF
 CALL echorecord(reply)
END GO
