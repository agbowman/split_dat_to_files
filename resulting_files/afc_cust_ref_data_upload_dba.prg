CREATE PROGRAM afc_cust_ref_data_upload:dba
 SET afc_cust_ref_data_upload_vrsn = "000"
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD request_add_bill_item_mod(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 action_type = c3
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 key11_id = f8
     2 key12_id = f8
     2 key13_id = f8
     2 key14_id = f8
     2 key15_id = f8
     2 bim1_int = f8
     2 bim2_int = f8
     2 bim_ind = i2
     2 bim1_ind = i2
     2 bim1_nbr = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
 )
 RECORD request_upt_bill_item_mod(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 action_type = c3
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 key11_id = f8
     2 key12_id = f8
     2 key13_id = f8
     2 key14_id = f8
     2 key15_id = f8
     2 bim1_int = f8
     2 bim2_int = f8
     2 bim_ind = i2
     2 bim1_ind = i2
     2 bim1_nbr = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
 )
 RECORD request_del_bill_item_mod(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[*]
     2 action_type = c3
     2 bill_item_mod_id = f8
     2 bill_item_id = f8
     2 bill_item_type_cd = f8
     2 key1_id = f8
     2 key2_id = f8
     2 key3_id = f8
     2 key4_id = f8
     2 key5_id = f8
     2 key6 = vc
     2 key7 = vc
     2 key8 = vc
     2 key9 = vc
     2 key10 = vc
     2 key11 = vc
     2 key12 = vc
     2 key13 = vc
     2 key14 = vc
     2 key15 = vc
     2 key11_id = f8
     2 key12_id = f8
     2 key13_id = f8
     2 key14_id = f8
     2 key15_id = f8
     2 bim1_int = f8
     2 bim2_int = f8
     2 bim_ind = i2
     2 bim1_ind = i2
     2 bim1_nbr = f8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
 )
 RECORD reply_ens_bill_item_mod(
   1 bill_item_modifier_qual = i2
   1 bill_item_modifier[10]
     2 bill_item_mod_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD request_item_price(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 action_type = c3
     2 price_sched_id = f8
     2 bill_item_id = f8
     2 price_sched_items_id = f8
     2 price_ind = i2
     2 price = f8
     2 allowable = f8
     2 percent_revenue = f8
     2 charge_level_cd = f8
     2 interval_template_cd = f8
     2 detail_charge_ind_ind = i2
     2 detail_charge_ind = i2
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm_ind = i2
     2 end_effective_dt_tm = dq8
     2 updt_cnt = i2
     2 units_ind = i2
     2 units_ind_ind = i2
     2 stats_only_ind_ind = i2
     2 stats_only_ind = i2
     2 capitation_ind = i2
     2 referral_req_ind = i2
 )
 RECORD reply_item_price(
   1 price_sched_items_qual = i2
   1 price_sched_items[*]
     2 price_sched_id = f8
     2 price_sched_items_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE SET rejects
 RECORD rejects(
   1 errors[*]
     2 cdm_number = vc
     2 message = vc
 )
 DECLARE 13019_bill_code = f8
 DECLARE 14002_cdm_sched = f8
 DECLARE 14002_revenue = f8
 DECLARE 14002_cpt4 = f8
 DECLARE 14002_cpt4_mod = f8
 DECLARE bill_item_mod_id = f8
 DECLARE count1 = i4
 DECLARE checkfile = i2
 RECORD billitem(
   1 bill_items[*]
     2 bill_item_id = f8
 )
 SET failed = false
 SET num_rejects = 0
 SET stat = uar_get_meaning_by_codeset(13019,nullterm("BILL CODE"),1,13019_bill_code)
 CALL echo(build("the bill_code_cd is : ",13019_bill_code))
 SET 14002_cdm_sched = request->cdm_sched_cd
 SELECT INTO "nl:"
  FROM bill_item_modifier bim
  WHERE bim.bill_item_type_cd=13019_bill_code
   AND bim.key1_id=14002_cdm_sched
   AND (bim.key6=request->cdm_number)
   AND bim.bim1_int=1
   AND bim.active_ind=1
  DETAIL
   count1 = (count1+ 1), stat = alterlist(billitem->bill_items,count1), billitem->bill_items[count1].
   bill_item_id = bim.bill_item_id
  WITH nocounter
 ;end select
 IF (size(billitem->bill_items,5) <= 0)
  SET failed = true
  CALL echo("Cannot find bill_item")
  CALL echo(build("    The cdm passed in was: ",request->cdm_number))
  CALL echo(build("    The cdm schedule passed in was: ",14002_cdm_sched))
  SET num_rejects = (num_rejects+ 1)
  SET stat = alterlist(rejects->errors,num_rejects)
  SET rejects->errors[num_rejects].cdm_number = request->cdm_number
  SET rejects->errors[num_rejects].message = trim("Cannot find bill_item. Not a valid CDM")
  GO TO end_program
 ELSE
  CALL echo("Found bill item(s): ")
  CALL echorecord(billitem)
 ENDIF
 IF (size(request->rev_codes,5) > 0)
  SET revcount = 0
  CALL echo("Finding rev code scheds")
  SELECT INTO "nl:"
   FROM code_value_alias cva,
    (dummyt d1  WITH seq = value(size(request->rev_codes,5)))
   PLAN (d1)
    JOIN (cva
    WHERE cva.code_set=14002
     AND (cva.alias=request->rev_codes[d1.seq].alias))
   DETAIL
    request->rev_codes[d1.seq].schedule = cva.code_value, revcount = d1.seq
   WITH nocounter
  ;end select
  FOR (revx = 1 TO revcount)
    IF ((((request->rev_codes[revx].schedule=0)) OR ((request->rev_codes[revx].schedule=null))) )
     CALL echo("Cannot find Revenue Code Schedules with the given alias")
     SET num_rejects = (num_rejects+ 1)
     SET stat = alterlist(rejects->errors,num_rejects)
     SET rejects->errors[num_rejects].cdm_number = request->cdm_number
     SET rejects->errors[num_rejects].message = trim(
      "Cannot find Revenue Code Schedules with the given alias")
     GO TO end_program
    ENDIF
    CALL echo(build("the rev_cd is : ",request->rev_codes[revx].schedule))
    SET revx = (revx+ 1)
  ENDFOR
 ELSE
  CALL echo("No rev code scheds to find")
 ENDIF
 IF (size(request->cpt4_codes,5) > 0)
  CALL echo("Finding CPT4 scheds")
  SELECT INTO "nl:"
   FROM code_value_alias cva,
    (dummyt d1  WITH seq = value(size(request->cpt4_codes,5)))
   PLAN (d1)
    JOIN (cva
    WHERE cva.code_set=14002
     AND (cva.alias=request->cpt4_codes[d1.seq].alias))
   DETAIL
    request->cpt4_codes[d1.seq].schedule = cva.code_value
   WITH nocounter
  ;end select
  IF ((((request->cpt4_codes[1].schedule=0)) OR ((request->cpt4_codes[1].schedule=null))) )
   CALL echo("Cannot find CPT4 Code Schedules with the given alias")
   SET num_rejects = (num_rejects+ 1)
   SET stat = alterlist(rejects->errors,num_rejects)
   SET rejects->errors[num_rejects].cdm_number = request->cdm_number
   SET rejects->errors[num_rejects].message = trim(
    "Cannot find CPT4 Code Schedules with the given alias")
   GO TO end_program
  ENDIF
  CALL echo(build("the cpt4_cd is : ",request->cpt4_codes[1].schedule))
 ELSE
  CALL echo("No CPT4 scheds to find")
 ENDIF
 IF (size(request->cpt4_mods,5) > 0)
  CALL echo("Finding CPT4_MODS scheds")
  SELECT INTO "nl:"
   FROM code_value_alias cva,
    (dummyt d1  WITH seq = value(size(request->cpt4_mods,5)))
   PLAN (d1)
    JOIN (cva
    WHERE cva.code_set=14002
     AND (cva.alias=request->cpt4_mods[d1.seq].alias))
   DETAIL
    request->cpt4_mods[d1.seq].schedule = cva.code_value
   WITH nocounter
  ;end select
  IF ((((request->cpt4_mods[1].schedule=0)) OR ((request->cpt4_mods[1].schedule=null))) )
   CALL echo("Cannot find CPT4 Modifier Code Schedules with the given alias")
   SET num_rejects = (num_rejects+ 1)
   SET stat = alterlist(rejects->errors,num_rejects)
   SET rejects->errors[num_rejects].cdm_number = request->cdm_number
   SET rejects->errors[num_rejects].message = trim(
    "Cannot find CPT4 Modifier Code Schedules with the given alias")
   GO TO end_program
  ENDIF
  CALL echo(build("the cpt4_mod_cd is : ",request->cpt4_mods[1].schedule))
 ELSE
  CALL echo("No CPT4 MODS scheds to find")
 ENDIF
 SET total_upts = 0
 SET total_adds = 0
 SET total_dels = 0
 SET skip_flg = 0
 CALL echo("Processing revenue codes")
 IF (size(request->rev_codes,5) > 0)
  FOR (nloopcntr = 1 TO size(request->rev_codes,5))
    SET cur_bill_code = ""
    SET skip_flg = 0
    SET bill_item_mod_id = 0
    SET rev_sched = request->rev_codes[nloopcntr].schedule
    CALL echo("    Select bill_item_modifier")
    CALL echo(build("    rev_sched: ",rev_sched))
    CALL echo(build("    current rev code: ",request->rev_codes[nloopcntr].code))
    FOR (temp_bill = 1 TO size(billitem->bill_items,5))
      CALL echo(build("    current bill code: ",billitem->bill_items[temp_bill].bill_item_id))
      SET cur_bill_code = ""
      SET found_one = 0
      SET skip_flg = 0
      SELECT INTO "nl:"
       FROM bill_item_modifier bim
       WHERE (bim.bill_item_id=billitem->bill_items[temp_bill].bill_item_id)
        AND bim.key1_id=rev_sched
        AND bim.active_ind=1
        AND ((bim.bim1_int+ 0)=1)
       DETAIL
        found_one = 1, cur_bill_code = bim.key6, bill_item_mod_id = bim.bill_item_mod_id
        IF ((request->rev_codes[nloopcntr].code=bim.key6))
         CALL echo("Duplicate Rev code for schedule"), skip_flg = 1
        ENDIF
       WITH nocounter
      ;end select
      CALL echo(build("Skip flg is: ",skip_flg))
      IF (skip_flg=0)
       IF (cur_bill_code != ""
        AND (request->rev_codes[nloopcntr].code != ""))
        CALL echo("here 1")
        SET total_upts = (total_upts+ 1)
        SET stat = alterlist(request_upt_bill_item_mod->bill_item_modifier,total_upts)
        SET request_upt_bill_item_mod->bill_item_modifier_qual = total_upts
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].action_type = "UPT"
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_mod_id =
        bill_item_mod_id
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_id = billitem->
        bill_items[temp_bill].bill_item_id
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_type_cd =
        13019_bill_code
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key1_id = request->rev_codes[
        nloopcntr].schedule
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key6 = request->rev_codes[
        nloopcntr].code
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key7 = request->rev_codes[
        nloopcntr].code
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bim1_int = 1
       ELSEIF ((request->rev_codes[nloopcntr].code != ""))
        CALL echo("here 2")
        SET total_adds = (total_adds+ 1)
        SET stat = alterlist(request_add_bill_item_mod->bill_item_modifier,total_adds)
        SET request_add_bill_item_mod->bill_item_modifier_qual = total_adds
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].action_type = "ADD"
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].bill_item_id = billitem->
        bill_items[temp_bill].bill_item_id
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].bill_item_type_cd =
        13019_bill_code
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].key1_id = request->rev_codes[
        nloopcntr].schedule
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].key6 = request->rev_codes[
        nloopcntr].code
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].key7 = request->rev_codes[
        nloopcntr].code
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].bim1_int = 1
       ELSEIF ((request->rev_codes[nloopcntr].code="")
        AND found_one=1)
        CALL echo("here 3")
        SET total_dels = (total_dels+ 1)
        SET stat = alterlist(request_del_bill_item_mod->bill_item_modifier,total_dels)
        SET request_del_bill_item_mod->bill_item_modifier_qual = total_dels
        SET request_del_bill_item_mod->bill_item_modifier[total_dels].action_type = "DEL"
        SET request_del_bill_item_mod->bill_item_modifier[total_dels].bill_item_mod_id =
        bill_item_mod_id
       ELSEIF ((request->rev_codes[nloopcntr].code="")
        AND found_one=0)
        CALL echo("here 4")
        CALL echo("There is no Revenue Code to delete for the current schedule.")
       ELSE
        CALL echo("There is an error with the Revenue Codes.")
        SET num_rejects = (num_rejects+ 1)
        SET stat = alterlist(rejects->errors,num_rejects)
        SET rejects->errors[num_rejects].cdm_number = request->cdm_number
        SET rejects->errors[num_rejects].message = trim("There is an error with the Revenue Code.")
       ENDIF
       SET failed = false
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SET skip_flg = 0
 CALL echo("Processing CPT-4 codes")
 IF ((request->cpt4_codes != ""))
  FOR (nloopcntr = 1 TO size(request->cpt4_codes,5))
    SET cur_bill_code = ""
    SET bill_item_mod_id = 0
    SET cpt4_sched = request->cpt4_codes[nloopcntr].schedule
    CALL echo("    Select bill_item_modifier")
    CALL echo(build("    cpt4_sched: ",cpt4_sched))
    CALL echo(build("    current cpt4 code: ",request->cpt4_codes[nloopcntr].code))
    FOR (temp_bill = 1 TO size(billitem->bill_items,5))
      SET cur_bill_code = ""
      SET skip_flg = 0
      SET found_one = 0
      SELECT INTO "nl:"
       FROM bill_item_modifier bim
       WHERE (bim.bill_item_id=billitem->bill_items[temp_bill].bill_item_id)
        AND bim.key1_id=cpt4_sched
        AND bim.active_ind=1
        AND ((bim.bim1_int+ 0)=1)
       DETAIL
        found_one = 1, cur_bill_code = bim.key6, bill_item_mod_id = bim.bill_item_mod_id
        IF ((request->cpt4_codes[nloopcntr].code=bim.key6))
         CALL echo("Duplicate CPT4 code for schedule"), skip_flg = 1
        ENDIF
       WITH nocounter
      ;end select
      IF (skip_flg=0)
       IF (cur_bill_code != ""
        AND (request->cpt4_codes[nloopcntr].code != ""))
        SET total_upts = (total_upts+ 1)
        SET stat = alterlist(request_upt_bill_item_mod->bill_item_modifier,total_upts)
        SET request_upt_bill_item_mod->bill_item_modifier_qual = total_upts
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].action_type = "UPT"
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_mod_id =
        bill_item_mod_id
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_id = billitem->
        bill_items[temp_bill].bill_item_id
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_type_cd =
        13019_bill_code
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key1_id = request->cpt4_codes[
        nloopcntr].schedule
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key6 = request->cpt4_codes[
        nloopcntr].code
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key7 = request->cpt4_codes[
        nloopcntr].code
        SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bim1_int = 1
       ELSEIF ((request->cpt4_codes[nloopcntr].code != ""))
        SET total_adds = (total_adds+ 1)
        SET stat = alterlist(request_add_bill_item_mod->bill_item_modifier,total_adds)
        SET request_add_bill_item_mod->bill_item_modifier_qual = total_adds
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].action_type = "ADD"
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].bill_item_id = billitem->
        bill_items[temp_bill].bill_item_id
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].bill_item_type_cd =
        13019_bill_code
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].key1_id = request->cpt4_codes[
        nloopcntr].schedule
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].key6 = request->cpt4_codes[
        nloopcntr].code
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].key7 = request->cpt4_codes[
        nloopcntr].code
        SET request_add_bill_item_mod->bill_item_modifier[total_adds].bim1_int = 1
       ELSEIF ((((request->cpt4_codes[nloopcntr].code="")) OR ((request->rev_codes[nloopcntr].code=
       null)))
        AND found_one=1)
        SET total_dels = (total_dels+ 1)
        SET stat = alterlist(request_del_bill_item_mod->bill_item_modifier,total_dels)
        SET request_del_bill_item_mod->bill_item_modifier_qual = total_dels
        SET request_del_bill_item_mod->bill_item_modifier[total_dels].action_type = "DEL"
        SET request_del_bill_item_mod->bill_item_modifier[total_dels].bill_item_mod_id =
        bill_item_mod_id
       ELSEIF ((request->cpt4_codes[nloopcntr].code="")
        AND found_one=0)
        CALL echo("There is no CPT4 Code to delete for the current schedule.")
       ELSE
        CALL echo("There is an error with the CPT4 Codes.")
        SET num_rejects = (num_rejects+ 1)
        SET stat = alterlist(rejects->errors,num_rejects)
        SET rejects->errors[num_rejects].cdm_number = request->cdm_number
        SET rejects->errors[num_rejects].message = trim("There is an error with the CPT4 Code.")
       ENDIF
       SET failed = false
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
 SET skip_flg = 0
 CALL echo("Processing CPT4 Mods")
 IF ((request->cpt4_mods != ""))
  FOR (nloopcntr = 1 TO size(request->cpt4_mods,5))
    SET cur_bill_code = ""
    SET bill_item_mod_id = 0
    SET cpt4_mods_sched = request->cpt4_mods[nloopcntr].schedule
    CALL echo("    Select bill_item_modifier")
    CALL echo(build("    cpt4_mods_sched: ",cpt4_mods_sched))
    FOR (temp_bill = 1 TO size(billitem->bill_items,5))
      SET cur_bill_code = ""
      SET found_one = 0
      SET codecnt = 0
      SET skipcount = 0
      SELECT INTO "nl:"
       FROM bill_item_modifier bim
       WHERE (bim.bill_item_id=billitem->bill_items[temp_bill].bill_item_id)
        AND bim.key1_id=cpt4_mods_sched
        AND bim.active_ind=1
       ORDER BY bim1_int
       DETAIL
        found_one = 1, codecnt = (codecnt+ 1), cur_bill_code = bim.key6,
        bill_item_mod_id = bim.bill_item_mod_id
       WITH nocounter
      ;end select
      FOR (cpt4modcnt = 1 TO 2)
        IF ((request->cpt4_mods[nloopcntr].codes[cpt4modcnt].skip=0))
         IF (cur_bill_code != ""
          AND (request->cpt4_mods[nloopcntr].codes[cpt4modcnt].code != ""))
          SET total_upts = (total_upts+ 1)
          SET stat = alterlist(request_upt_bill_item_mod->bill_item_modifier,total_upts)
          SET request_upt_bill_item_mod->bill_item_modifier_qual = total_upts
          SET request_upt_bill_item_mod->bill_item_modifier[total_upts].action_type = "UPT"
          SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_mod_id =
          bill_item_mod_id
          SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_id = billitem->
          bill_items[temp_bill].bill_item_id
          SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bill_item_type_cd =
          13019_bill_code
          SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key1_id = request->cpt4_mods[
          nloopcntr].schedule
          SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key6 = request->cpt4_mods[
          nloopcntr].codes[cpt4modcnt].code
          SET request_upt_bill_item_mod->bill_item_modifier[total_upts].key7 = request->cpt4_mods[
          nloopcntr].codes[cpt4modcnt].code
          SET request_upt_bill_item_mod->bill_item_modifier[total_upts].bim1_int = request->
          cpt4_mods[nloopcntr].codes[cpt4modcnt].priority
         ELSEIF ((request->cpt4_mods[nloopcntr].codes[cpt4modcnt].code != ""))
          SET total_adds = (total_adds+ 1)
          SET stat = alterlist(request_add_bill_item_mod->bill_item_modifier,total_adds)
          SET request_add_bill_item_mod->bill_item_modifier_qual = total_adds
          SET request_add_bill_item_mod->bill_item_modifier[total_adds].action_type = "ADD"
          SET request_add_bill_item_mod->bill_item_modifier[total_adds].bill_item_id = billitem->
          bill_items[temp_bill].bill_item_id
          SET request_add_bill_item_mod->bill_item_modifier[total_adds].bill_item_type_cd =
          13019_bill_code
          SET request_add_bill_item_mod->bill_item_modifier[total_adds].key1_id = request->cpt4_mods[
          nloopcntr].schedule
          SET request_add_bill_item_mod->bill_item_modifier[total_adds].key6 = request->cpt4_mods[
          nloopcntr].codes[cpt4modcnt].code
          SET request_add_bill_item_mod->bill_item_modifier[total_adds].key7 = request->cpt4_mods[
          nloopcntr].codes[cpt4modcnt].code
          SET request_add_bill_item_mod->bill_item_modifier[total_adds].bim1_int = request->
          cpt4_mods[nloopcntr].codes[cpt4modcnt].priority
         ELSEIF ((request->cpt4_mods[nloopcntr].codes[cpt4modcnt].code="")
          AND found_one=1)
          SET total_dels = (total_dels+ 1)
          SET stat = alterlist(request_del_bill_item_mod->bill_item_modifier,total_dels)
          SET request_del_bill_item_mod->bill_item_modifier_qual = total_dels
          SET request_del_bill_item_mod->bill_item_modifier[total_dels].action_type = "DEL"
          SET request_del_bill_item_mod->bill_item_modifier[total_dels].bill_item_mod_id =
          bill_item_mod_id
         ELSEIF ((request->cpt4_mods[nloopcntr].codes[cpt4modcnt].code="")
          AND found_one=0)
          CALL echo("There is no CPT4 Mod Code to delete for the current schedule.")
         ELSE
          CALL echo("There is an error with the CPT4 Modifiers Codes.")
          SET num_rejects = (num_rejects+ 1)
          SET stat = alterlist(rejects->errors,num_rejects)
          SET rejects->errors[num_rejects].cdm_number = request->cdm_number
          SET rejects->errors[num_rejects].message = trim(
           "There is an error with the CPT4 Modifier Code.")
         ENDIF
         SET failed = false
        ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
 ENDIF
 CALL echorecord(request)
 CALL echorecord(request_upt_bill_item_mod)
 CALL echo(build("Total_UPTs: ",total_upts))
 IF (total_upts > 0)
  SET action_begin = 1
  SET action_end = total_upts
  EXECUTE afc_upt_bill_item_modifier  WITH replace("REQUEST",request_upt_bill_item_mod), replace(
   "REPLY",reply_ens_bill_item_mod)
  IF ((reply_ens_bill_item_mod->status_data.status != "S"))
   SET failed = true
   CALL echo("Cannot process CDM Updates")
   GO TO end_program
  ELSE
   SET failed = false
  ENDIF
 ENDIF
 CALL echo(build("Total_ADDs: ",total_adds))
 IF (total_adds > 0)
  SET action_begin = 1
  SET action_end = total_adds
  EXECUTE afc_add_bill_item_modifier  WITH replace("REQUEST",request_add_bill_item_mod), replace(
   "REPLY",reply_ens_bill_item_mod)
  IF ((reply_ens_bill_item_mod->status_data.status != "S"))
   SET failed = true
   CALL echo("Cannot process CDM Adds")
   GO TO end_program
  ELSE
   SET failed = false
  ENDIF
 ENDIF
 CALL echo(build("Total_DELs: ",total_dels))
 IF (total_dels > 0)
  SET action_begin = 1
  SET action_end = total_dels
  EXECUTE afc_del_bill_item_modifier  WITH replace("REQUEST",request_del_bill_item_mod), replace(
   "REPLY",reply_ens_bill_item_mod)
  IF ((reply_ens_bill_item_mod->status_data.status != "S"))
   CALL echo("Cannot process CDM Deletes")
  ELSE
   SET failed = false
  ENDIF
 ENDIF
 CALL echo(build("Finding price schedule using id: ",request->price_sched_id))
 FOR (pricecount = 1 TO size(billitem->bill_items,5))
   FREE SET request_item_price
   RECORD request_item_price(
     1 price_sched_items_qual = i2
     1 price_sched_items[*]
       2 action_type = c3
       2 price_sched_id = f8
       2 bill_item_id = f8
       2 price_sched_items_id = f8
       2 price_ind = i2
       2 price = f8
       2 allowable = f8
       2 percent_revenue = f8
       2 charge_level_cd = f8
       2 interval_template_cd = f8
       2 detail_charge_ind_ind = i2
       2 detail_charge_ind = i2
       2 active_ind_ind = i2
       2 active_ind = i2
       2 active_status_cd = f8
       2 active_status_dt_tm = dq8
       2 active_status_prsnl_id = dq8
       2 beg_effective_dt_tm = dq8
       2 end_effective_dt_tm_ind = i2
       2 end_effective_dt_tm = dq8
       2 updt_cnt = i2
       2 units_ind = i2
       2 units_ind_ind = i2
       2 stats_only_ind_ind = i2
       2 stats_only_ind = i2
       2 capitation_ind = i2
       2 referral_req_ind = i2
   )
   IF ((request->price_sched_id > 0))
    SET failed = true
    SET one_sec = (1.0/ 86400.0)
    SET price_sched_items_id = 0
    SET valid_price_sched = 0
    SET found_one = 0
    SELECT INTO "nl:"
     FROM price_sched ps
     WHERE (ps.price_sched_id=request->price_sched_id)
      AND ps.active_ind=1
     DETAIL
      valid_price_sched = 1
     WITH nocounter
    ;end select
    IF (valid_price_sched=0)
     CALL echo("There Price Schedule sent in is not Valid.")
     SET failed = true
     SET num_rejects = (num_rejects+ 1)
     SET stat = alterlist(rejects->errors,num_rejects)
     SET rejects->errors[num_rejects].cdm_number = request->cdm_number
     SET rejects->errors[num_rejects].message = trim("There Price Schedule sent in is not Valid.")
     GO TO end_program
    ENDIF
    SELECT INTO "nl:"
     FROM price_sched_items psi
     WHERE (psi.price_sched_id=request->price_sched_id)
      AND (psi.bill_item_id=billitem->bill_items[pricecount].bill_item_id)
      AND psi.active_ind=1
      AND psi.active_status_cd=188
      AND psi.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND psi.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     DETAIL
      found_one = 1, beg_dt_tm = cnvtdatetime(psi.beg_effective_dt_tm), end_dt_tm = cnvtdatetime(psi
       .end_effective_dt_tm),
      price = psi.price, price_sched_items_id = psi.price_sched_items_id
     WITH nocounter
    ;end select
    IF (found_one=0
     AND (request->price != null))
     SET request_item_price->price_sched_items_qual = 1
     SET stat = alterlist(request_item_price->price_sched_items,1)
     SET request_item_price->price_sched_items[1].action_type = "ADD"
     SET request_item_price->price_sched_items[1].price_sched_id = request->price_sched_id
     SET request_item_price->price_sched_items[1].bill_item_id = billitem->bill_items[pricecount].
     bill_item_id
     SET request_item_price->price_sched_items[1].price_sched_items_id = 0
     SET request_item_price->price_sched_items[1].price_ind = 1
     SET request_item_price->price_sched_items[1].price = request->price
     SET request_item_price->price_sched_items[1].interval_template_cd = 0
     SET request_item_price->price_sched_items[1].detail_charge_ind_ind = 0
     SET request_item_price->price_sched_items[1].detail_charge_ind = 1
     SET request_item_price->price_sched_items[1].units_ind_ind = 0
     SET request_item_price->price_sched_items[1].units_ind = 0
     SET request_item_price->price_sched_items[1].beg_effective_dt_tm = cnvtdatetime(request->
      beg_effective_dt_tm)
     SET request_item_price->price_sched_items[1].end_effective_dt_tm = cnvtdatetime(request->
      end_effective_dt_tm)
     SET action_begin = 1
     SET action_end = 1
     EXECUTE afc_add_price_sched_item  WITH replace("REQUEST",request_item_price), replace("REPLY",
      reply_item_price)
    ELSEIF (found_one=1
     AND (request->price != null))
     SET request_item_price->price_sched_items_qual = 1
     SET stat = alterlist(request_item_price->price_sched_items,1)
     SET request_item_price->price_sched_items[1].action_type = "UPT"
     SET request_item_price->price_sched_items[1].price_sched_id = request->price_sched_id
     SET request_item_price->price_sched_items[1].bill_item_id = billitem->bill_items[pricecount].
     bill_item_id
     SET request_item_price->price_sched_items[1].active_status_cd = 192
     SET request_item_price->price_sched_items[1].price_sched_items_id = price_sched_items_id
     SET request_item_price->price_sched_items[1].end_effective_dt_tm = datetimeadd(request->
      beg_effective_dt_tm,- (one_sec))
     SET action_begin = 1
     SET action_end = 1
     EXECUTE afc_upt_price_sched_item  WITH replace("REQUEST",request_item_price), replace("REPLY",
      reply_item_price)
     IF ((reply_item_price->status_data.status="S"))
      FREE SET request_item_price
      RECORD request_item_price(
        1 price_sched_items_qual = i2
        1 price_sched_items[*]
          2 action_type = c3
          2 price_sched_id = f8
          2 bill_item_id = f8
          2 price_sched_items_id = f8
          2 price_ind = i2
          2 price = f8
          2 allowable = f8
          2 percent_revenue = f8
          2 charge_level_cd = f8
          2 interval_template_cd = f8
          2 detail_charge_ind_ind = i2
          2 detail_charge_ind = i2
          2 active_ind_ind = i2
          2 active_ind = i2
          2 active_status_cd = f8
          2 active_status_dt_tm = dq8
          2 active_status_prsnl_id = dq8
          2 beg_effective_dt_tm = dq8
          2 end_effective_dt_tm_ind = i2
          2 end_effective_dt_tm = dq8
          2 updt_cnt = i2
          2 units_ind = i2
          2 units_ind_ind = i2
          2 stats_only_ind_ind = i2
          2 stats_only_ind = i2
          2 capitation_ind = i2
          2 referral_req_ind = i2
      )
      SET stat = alterlist(request_item_price->price_sched_items,1)
      SET request_item_price->price_sched_items_qual = 1
      SET request_item_price->price_sched_items[1].action_type = "ADD"
      SET request_item_price->price_sched_items[1].price_sched_id = request->price_sched_id
      SET request_item_price->price_sched_items[1].bill_item_id = billitem->bill_items[pricecount].
      bill_item_id
      SET request_item_price->price_sched_items[1].price_sched_items_id = 0
      SET request_item_price->price_sched_items[1].price_ind = 1
      SET request_item_price->price_sched_items[1].price = request->price
      SET request_item_price->price_sched_items[1].interval_template_cd = 0
      SET request_item_price->price_sched_items[1].detail_charge_ind_ind = 0
      SET request_item_price->price_sched_items[1].detail_charge_ind = 1
      SET request_item_price->price_sched_items[1].units_ind_ind = 0
      SET request_item_price->price_sched_items[1].units_ind = 0
      SET request_item_price->price_sched_items[1].beg_effective_dt_tm = cnvtdatetime(request->
       beg_effective_dt_tm)
      SET request_item_price->price_sched_items[1].end_effective_dt_tm = cnvtdatetime(request->
       end_effective_dt_tm)
      SET action_begin = 1
      SET action_end = 1
      EXECUTE afc_add_price_sched_item  WITH replace("REQUEST",request_item_price), replace("REPLY",
       reply_item_price)
      SET failed = false
     ELSE
      SET failed = true
      SET num_rejects = (num_rejects+ 1)
      SET stat = alterlist(rejects->errors,num_rejects)
      SET rejects->errors[num_rejects].cdm_number = request->cdm_number
      SET rejects->errors[num_rejects].message = trim("There is an error with Updating the Price.")
     ENDIF
    ELSE
     CALL echo("There is an error with the price.")
     SET failed = true
     SET num_rejects = (num_rejects+ 1)
     SET stat = alterlist(rejects->errors,num_rejects)
     SET rejects->errors[num_rejects].cdm_number = request->cdm_number
     SET rejects->errors[num_rejects].message = trim("There is an error with the Price.")
     GO TO end_program
    ENDIF
   ENDIF
 ENDFOR
#end_program
 IF (failed=true)
  SET reply->status_data.status = "F"
  ROLLBACK
  EXECUTE pft_log "afc_cust_ref_data_upload", build("THE FOLLOWING CDM WAS NOT UPDATED: ",request->
   cdm_number), 0
  CALL echo("Commit is false")
 ELSE
  SET reply->status_data.status = "S"
  CALL echo("Commit is true")
  COMMIT
 ENDIF
 IF (num_rejects > 0)
  SET checkfile = findfile("ccluserdir:afc_cdm_upload.err")
  IF (checkfile=0)
   SET equal_line = fillstring(130,"=")
   SET file_name = "ccluserdir:afc_cdm_upload.err"
   SELECT INTO value(file_name)
    cdm_number = trim(rejects->errors[d1.seq].cdm_number), message = rejects->errors[d1.seq].message,
    run_date = format(curdate,"mm/dd/yy;;d"),
    run_time = format(curtime,"hh:mm;;m")
    FROM (dummyt d1  WITH seq = value(size(rejects->errors,5)))
    ORDER BY cdm_number, message
    HEAD REPORT
     col 47, "** AFC Cust Ref Data Upload Error Log **", row + 2
    HEAD PAGE
     row + 1, col 00, "CDM Number",
     col 35, "Error Message", col 90,
     "Date", row + 1, col 00,
     equal_line, row + 1
    DETAIL
     col 00, cdm_number, col 35,
     message, col 90, run_date,
     " ", run_time, row + 1
    WITH nocounter
   ;end select
  ELSE
   SET file_name = "ccluserdir:afc_cdm_upload.err"
   SELECT INTO value(file_name)
    cdm_number = trim(rejects->errors[d1.seq].cdm_number), message = rejects->errors[d1.seq].message,
    run_date = format(curdate,"mm/dd/yy;;d"),
    run_time = format(curtime,"hh:mm;;m")
    FROM (dummyt d1  WITH seq = value(size(rejects->errors,5)))
    ORDER BY cdm_number, message
    DETAIL
     col 00, cdm_number, col 35,
     message, col 90, run_date,
     " ", run_time, row + 1
    WITH nocounter, append
   ;end select
  ENDIF
 ENDIF
END GO
