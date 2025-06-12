CREATE PROGRAM bed_ens_oc_work_tables:dba
 FREE SET reply
 RECORD reply(
   1 oc_list[*]
     2 oc_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET reply_count = 0
 SET list_count = 0
 SET prev_catalog_type = fillstring(40," ")
 SET prev_activity_type = fillstring(40," ")
 SET prev_activity_subtype = fillstring(40," ")
 SET prev_clinical_category = fillstring(40," ")
 SET prev_exact_hit_action = fillstring(12," ")
 SET prev_min_ahead_action = fillstring(12," ")
 SET prev_min_behind_action = fillstring(12," ")
 SET prev_op_exact_hit_action = fillstring(12," ")
 SET prev_op_min_ahead_action = fillstring(12," ")
 SET prev_op_min_behind_action = fillstring(12," ")
 SET prev_contributor_source = fillstring(40," ")
 SET prev_oe_format = fillstring(200," ")
 SET prev_mnemonic_type = fillstring(40," ")
 SET prev_price_sched = fillstring(200," ")
 SET prev_billcode = fillstring(40," ")
 SET billcode = fillstring(25," ")
 SET catalog_code_value = 0.0
 SET activity_code_value = 0.0
 SET subactivity_code_value = 0.0
 SET clinical_category_code_value = 0.0
 SET exact_hit_action_code_value = 0.0
 SET min_ahead_action_code_value = 0.0
 SET min_behind_action_code_value = 0.0
 SET op_exact_hit_action_code_value = 0.0
 SET op_min_ahead_action_code_value = 0.0
 SET op_min_behind_action_code_value = 0.0
 SET contributor_source_code_value = 0.0
 SET oe_format_id = 0.0
 SET mnemonic_type_code_value = 0.0
 SET price_sched_id = 0.0
 SET billcode_code_value = 0.0
 SET price_id = 0.0
 SET price = 0.00
 RECORD dup_check_type(
   1 qual[*]
     2 dup_check_cd = f8
     2 meaning = vc
 )
 RECORD contributor(
   1 qual[*]
     2 contributor_cd = f8
     2 display = vc
 )
 RECORD oe_format(
   1 qual[*]
     2 format_id = f8
     2 display = vc
 )
 RECORD billcodes(
   1 qual[*]
     2 billcode_cd = f8
     2 display = vc
 )
 RECORD price_sched(
   1 qual[*]
     2 price_sched_id = f8
     2 display = vc
 )
 RECORD mnemonic_type(
   1 qual[*]
     2 mnemonic_cd = f8
     2 display = vc
 )
 SET tot_dup_check_type = 0
 SELECT INTO "nl:"
  cv.code_value, cv.cdf_meaning
  FROM code_value cv
  WHERE cv.code_set=6001
   AND cv.active_ind=1
  DETAIL
   tot_dup_check_type = (tot_dup_check_type+ 1)
   IF (tot_dup_check_type > size(dup_check_type->qual,5))
    stat = alterlist(dup_check_type->qual,(tot_dup_check_type+ 5))
   ENDIF
   dup_check_type->qual[tot_dup_check_type].dup_check_cd = cv.code_value, dup_check_type->qual[
   tot_dup_check_type].meaning = trim(cv.cdf_meaning)
  WITH nocounter
 ;end select
 SET stat = alterlist(dup_check_type->qual,tot_dup_check_type)
 SET tot_contributor = 0
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM code_value cv
  WHERE cv.code_set=73
   AND cv.active_ind=1
  DETAIL
   tot_contributor = (tot_contributor+ 1)
   IF (tot_contributor > size(contributor->qual,5))
    stat = alterlist(contributor->qual,(tot_contributor+ 5))
   ENDIF
   contributor->qual[tot_contributor].contributor_cd = cv.code_value, contributor->qual[
   tot_contributor].display = trim(cv.display)
  WITH nocounter
 ;end select
 SET stat = alterlist(contributor->qual,tot_contributor)
 SET tot_billcode = 0
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM code_value cv
  WHERE cv.code_set=14002
   AND cv.active_ind=1
  DETAIL
   tot_billcode = (tot_billcode+ 1)
   IF (tot_billcode > size(billcodes->qual,5))
    stat = alterlist(billcodes->qual,(tot_billcode+ 5))
   ENDIF
   billcodes->qual[tot_billcode].billcode_cd = cv.code_value, billcodes->qual[tot_billcode].display
    = trim(cv.display)
  WITH nocounter
 ;end select
 SET stat = alterlist(billcodes->qual,tot_billcode)
 SET tot_oe_format = 0
 SELECT INTO "nl:"
  oef.oe_format_id, oef.oe_format_name
  FROM order_entry_format oef
  DETAIL
   tot_oe_format = (tot_oe_format+ 1)
   IF (tot_oe_format > size(oe_format->qual,5))
    stat = alterlist(oe_format->qual,(tot_oe_format+ 5))
   ENDIF
   oe_format->qual[tot_oe_format].format_id = oef.oe_format_id, oe_format->qual[tot_oe_format].
   display = trim(oef.oe_format_name)
  WITH nocounter
 ;end select
 SET stat = alterlist(oe_format->qual,tot_oe_format)
 SET tot_price_sched = 0
 SELECT INTO "nl:"
  ps.price_sched_id, ps.price_sched_desc
  FROM price_sched ps
  WHERE ps.active_ind=1
  DETAIL
   tot_price_sched = (tot_price_sched+ 1)
   IF (tot_price_sched > size(price_sched->qual,5))
    stat = alterlist(price_sched->qual,(tot_price_sched+ 5))
   ENDIF
   price_sched->qual[tot_price_sched].price_sched_id = ps.price_sched_id, price_sched->qual[
   tot_price_sched].display = trim(ps.price_sched_desc)
  WITH nocounter
 ;end select
 SET stat = alterlist(price_sched->qual,tot_price_sched)
 SET tot_mnemonic_type = 0
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.active_ind=1
  DETAIL
   tot_mnemonic_type = (tot_mnemonic_type+ 1)
   IF (tot_mnemonic_type > size(mnemonic_type->qual,5))
    stat = alterlist(mnemonic_type->qual,(tot_mnemonic_type+ 5))
   ENDIF
   mnemonic_type->qual[tot_mnemonic_type].mnemonic_cd = cv.code_value, mnemonic_type->qual[
   tot_mnemonic_type].display = trim(cv.display)
  WITH nocounter
 ;end select
 SET stat = alterlist(mnemonic_type->qual,tot_mnemonic_type)
 SET oc_cnt = size(request->oc_list,5)
 SET stat = alterlist(reply->oc_list,oc_cnt)
 SET stat = alterlist(reply->status_data.subeventstatus,oc_cnt)
 FOR (x = 1 TO oc_cnt)
   SET error_flag = "N"
   SET new_id = 0.0
   CALL get_codes(x)
   IF ((request->oc_list[x].action_flag=1))
    SELECT INTO "NL:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    SET reply->oc_list[x].oc_id = new_id
    INSERT  FROM br_oc_work b
     SET b.seq = 1, b.oc_id = new_id, b.short_desc = trim(request->oc_list[x].short_desc),
      b.long_desc = trim(request->oc_list[x].long_desc), b.dept_name = trim(request->oc_list[x].
       dept_name), b.status_ind = 0,
      b.match_ind = 0, b.match_orderable_cd = 0, b.match_value = " ",
      b.commit_ind = 0, b.catalog_type = trim(request->oc_list[x].catalog_type), b.activity_type =
      trim(request->oc_list[x].activity_type),
      b.activity_subtype = trim(request->oc_list[x].activity_subtype), b.dcp_clin_cat = trim(request
       ->oc_list[x].dcp_clin_cat), b.rx_mask = request->oc_list[x].rx_mask,
      b.oe_format_id = oe_format_id, b.dup_check_seq = request->oc_list[x].dup_check_seq, b
      .exact_hit_action = exact_hit_action_code_value,
      b.min_ahead_action_cd = min_ahead_action_code_value, b.min_ahead = request->oc_list[x].
      min_ahead, b.min_behind_action_cd = min_behind_action_code_value,
      b.min_behind = request->oc_list[x].min_behind, b.op_exact_hit_action =
      op_exact_hit_action_code_value, b.op_min_ahead_action_cd = op_min_ahead_action_code_value,
      b.op_min_ahead = request->oc_list[x].op_min_ahead, b.op_min_behind_action_cd =
      op_min_behind_action_code_value, b.op_min_behind = request->oc_list[x].op_min_behind,
      b.contributor_source_cd = contributor_source_code_value, b.alias = request->oc_list[x].alias, b
      .alias_type_meaning = request->oc_list[x].alias_type_meaning,
      b.mapping_mne = request->oc_list[x].mapping_mne, b.bill_only_ind = request->oc_list[x].
      bill_only_ind, b.loinc_code = request->oc_list[x].loinc_code,
      b.careset_ind = request->oc_list[x].careset_ind, b.alias1 = request->oc_list[x].alias1, b
      .alias2 = request->oc_list[x].alias2,
      b.alias3 = request->oc_list[x].alias3, b.alias4 = request->oc_list[x].alias4, b.alias5 =
      request->oc_list[x].alias5,
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].short_desc),
      " into the br_oc_work table.")
     GO TO exit_script
    ENDIF
    SET syn_cnt = size(request->oc_list[x].synonym_list,5)
    SET syn_seq = 0
    FOR (y = 1 TO syn_cnt)
      CALL get_mnemonic_type(x,y)
      SET syn_seq = (syn_seq+ 1)
      INSERT  FROM br_oc_synonym b
       SET b.seq = syn_seq, b.synonym_id = cnvtreal(seq(reference_seq,nextval)), b.oc_id = new_id,
        b.mnemonic_type_cd = mnemonic_type_code_value, b.mnemonic = trim(request->oc_list[x].
         synonym_list[y].mnemonic), b.hide_flag = request->oc_list[x].synonym_list[y].hide_flag,
        b.virtual_views = request->oc_list[x].synonym_list[y].virtual_views, b.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
        b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET error_flag = "Y"
       SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].short_desc),
        " into the br_oc_synonym table.")
       GO TO exit_script
      ENDIF
    ENDFOR
    SET price_cnt = size(request->oc_list[x].pricing_list,5)
    SET price_seq = 0
    FOR (y = 1 TO price_cnt)
      SET price = 0
      SET billcode = fillstring(25," ")
      CALL get_billcode(x,y)
      CALL get_price_sched(x,y)
      SET price_seq = (price_seq+ 1)
      IF (((billcode != "    "
       AND billcode_code_value > 0) OR (price > 0
       AND price_sched_id > 0)) )
       INSERT  FROM br_oc_pricing b
        SET b.seq = price_seq, b.pricing_id = cnvtreal(seq(reference_seq,nextval)), b.oc_id = new_id,
         b.price_sched_id = price_sched_id, b.price = price, b.billcode_sched_cd =
         billcode_code_value,
         b.billcode = billcode, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->
         updt_id,
         b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
        WITH nocounter
       ;end insert
       IF (curqual=0)
        SET error_flag = "Y"
        SET error_msg = concat("Unable to insert ",trim(request->oc_list[x].short_desc),
         " into the br_oc_synonym table.")
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE get_codes(x)
   IF (trim(request->oc_list[x].exact_hit_action) != trim(prev_exact_hit_action))
    SET exact_hit_action_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].exact_hit_action > "    "))
     WHILE (i <= tot_dup_check_type)
      IF ((trim(request->oc_list[x].exact_hit_action)=dup_check_type->qual[i].meaning))
       SET exact_hit_action_code_value = dup_check_type->qual[i].dup_check_cd
       SET prev_exact_hit_action = trim(request->oc_list[x].exact_hit_action)
       SET i = tot_dup_check_type
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
    ENDIF
   ENDIF
   IF (trim(request->oc_list[x].min_ahead_action) != trim(prev_min_ahead_action))
    SET min_ahead_action_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].min_ahead_action > "    "))
     WHILE (i <= tot_dup_check_type)
      IF ((trim(request->oc_list[x].min_ahead_action)=dup_check_type->qual[i].meaning))
       SET min_ahead_action_code_value = dup_check_type->qual[i].dup_check_cd
       SET prev_min_ahead_action = trim(request->oc_list[x].min_ahead_action)
       SET i = tot_dup_check_type
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
    ENDIF
   ENDIF
   IF (trim(request->oc_list[x].min_behind_action) != trim(prev_min_behind_action))
    SET min_behind_action_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].min_behind_action > "    "))
     WHILE (i <= tot_dup_check_type)
      IF ((trim(request->oc_list[x].min_behind_action)=dup_check_type->qual[i].meaning))
       SET min_behind_action_code_value = dup_check_type->qual[i].dup_check_cd
       SET prev_min_behind_action = trim(request->oc_list[x].min_behind_action)
       SET i = tot_dup_check_type
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
    ENDIF
   ENDIF
   IF (trim(request->oc_list[x].op_exact_hit_action) != trim(prev_op_exact_hit_action))
    SET op_exact_hit_action_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].op_exact_hit_action > "    "))
     WHILE (i <= tot_dup_check_type)
      IF ((trim(request->oc_list[x].op_exact_hit_action)=dup_check_type->qual[i].meaning))
       SET op_exact_hit_action_code_value = dup_check_type->qual[i].dup_check_cd
       SET prev_op_exact_hit_action = trim(request->oc_list[x].op_exact_hit_action)
       SET i = tot_dup_check_type
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
    ENDIF
   ENDIF
   IF (trim(request->oc_list[x].op_min_ahead_action) != trim(prev_op_min_ahead_action))
    SET op_min_ahead_action_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].op_min_ahead_action > "    "))
     WHILE (i <= tot_dup_check_type)
      IF ((trim(request->oc_list[x].op_min_ahead_action)=dup_check_type->qual[i].meaning))
       SET op_min_ahead_action_code_value = dup_check_type->qual[i].dup_check_cd
       SET prev_op_min_ahead_action = trim(request->oc_list[x].op_min_ahead_action)
       SET i = tot_dup_check_type
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
    ENDIF
   ENDIF
   IF (trim(request->oc_list[x].op_min_behind_action) != trim(prev_op_min_behind_action))
    SET op_min_behind_action_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].op_min_behind_action > "    "))
     WHILE (i <= tot_dup_check_type)
      IF ((trim(request->oc_list[x].op_min_behind_action)=dup_check_type->qual[i].meaning))
       SET op_min_behind_action_code_value = dup_check_type->qual[i].dup_check_cd
       SET prev_op_min_behind_action = trim(request->oc_list[x].op_min_behind_action)
       SET i = tot_dup_check_type
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
    ENDIF
   ENDIF
   IF (trim(request->oc_list[x].contributor_source) != trim(prev_contributor_source))
    SET contributor_source_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].contributor_source > "    "))
     WHILE (i <= tot_contributor)
      IF ((trim(request->oc_list[x].contributor_source)=contributor->qual[i].display))
       SET contributor_source_code_value = contributor->qual[i].contributor_cd
       SET prev_contributor_source = trim(request->oc_list[x].contributor_source)
       SET i = tot_contributor
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
     IF (contributor_source_code_value=0)
      SET error_flag = "Y"
      SET error_msg = concat(trim(request->oc_list[x].short_desc),
       " has an invalid contributor source .  Define ",trim(request->oc_list[x].contributor_source),
       " in Millennium.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
   IF (trim(request->oc_list[x].oe_format) != trim(prev_oe_format))
    SET oe_format_id = 0.0
    SET i = 1
    IF ((request->oc_list[x].oe_format > "    "))
     WHILE (i <= tot_oe_format)
      IF ((trim(request->oc_list[x].oe_format)=oe_format->qual[i].display))
       SET oe_format_id = oe_format->qual[i].format_id
       SET prev_oe_format = trim(request->oc_list[x].oe_format)
       SET i = tot_oe_format
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
     IF (oe_format_id=0)
      SET error_flag = "Y"
      SET error_msg = concat(trim(request->oc_list[x].short_desc),
       " has an invalid order entry format .  Define ",trim(request->oc_list[x].oe_format),
       " in Millennium.")
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_mnemonic_type(x,y)
   IF (trim(request->oc_list[x].synonym_list[y].synonym_type) != trim(prev_mnemonic_type))
    SET mnemonic_type_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].synonym_list[y].synonym_type > "    "))
     WHILE (i <= tot_mnemonic_type)
      IF ((trim(request->oc_list[x].synonym_list[y].synonym_type)=mnemonic_type->qual[i].display))
       SET mnemonic_type_code_value = mnemonic_type->qual[i].mnemonic_cd
       SET i = tot_mnemonic_type
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_price_sched(x,y)
   IF (trim(request->oc_list[x].pricing_list[y].price_sched) != trim(prev_price_sched))
    SET price_sched_id = 0.0
    SET i = 1
    IF ((request->oc_list[x].pricing_list[y].price_sched > "    ")
     AND (request->oc_list[x].pricing_list[y].price > 0))
     WHILE (i <= tot_price_sched)
      IF ((trim(request->oc_list[x].pricing_list[y].price_sched)=price_sched->qual[i].display))
       SET price_sched_id = price_sched->qual[i].price_sched_id
       SET prev_price_sched = trim(request->oc_list[x].pricing_list[y].price_sched)
       SET price = request->oc_list[x].pricing_list[y].price
       SET i = tot_price_sched
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
     IF (price_sched_id=0)
      SET error_flag = "Y"
      SET error_msg = concat(trim(request->oc_list[x].short_desc),
       " has an invalid price schedule .  Define ",trim(request->oc_list[x].pricing_list[y].
        price_sched)," in Millennium.")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    SET price = request->oc_list[x].pricing_list[y].price
   ENDIF
 END ;Subroutine
 SUBROUTINE get_billcode(x,y)
   IF (trim(request->oc_list[x].pricing_list[y].billcode_sched) != trim(prev_billcode))
    SET billcode_code_value = 0.0
    SET i = 1
    IF ((request->oc_list[x].pricing_list[y].billcode_sched != "    ")
     AND (request->oc_list[x].pricing_list[y].billcode != "    "))
     WHILE (i <= tot_billcode)
      IF ((trim(request->oc_list[x].pricing_list[y].billcode_sched)=billcodes->qual[i].display))
       SET billcode_code_value = billcodes->qual[i].billcode_cd
       SET prev_billcode = trim(request->oc_list[x].pricing_list[y].billcode_sched)
       SET billcode = request->oc_list[x].pricing_list[y].billcode
       SET i = tot_billcode
      ENDIF
      SET i = (i+ 1)
     ENDWHILE
     IF (billcode_code_value=0)
      SET error_flag = "Y"
      SET error_msg = concat(trim(request->oc_list[x].short_desc),
       " has an invalid billcode.  Define ",trim(request->oc_list[x].pricing_list[y].billcode_sched),
       " in Millennium.")
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    SET billcode = request->oc_list[x].pricing_list[y].billcode
   ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_OC_WORK_TABLES","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 FREE RECORD dup_check_type
 FREE RECORD contributor
 FREE RECORD oe_format
 FREE RECORD price_sched
 FREE RECORD billcodes
END GO
