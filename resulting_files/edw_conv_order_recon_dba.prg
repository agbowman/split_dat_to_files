CREATE PROGRAM edw_conv_order_recon:dba
 DECLARE iord_ct = i4 WITH protect, noconstant(0)
 DECLARE time_zone = i4 WITH protect, noconstant(0)
 DECLARE iparent_cnt = i4 WITH protect, noconstant(0)
 DECLARE iparentencntr_cnt = i4 WITH protect, noconstant(0)
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE scripterror_ind = i2 WITH protect, noconstant(0)
 SET parser_line = build("BUILD(",value(encounter_nk),")")
 DECLARE temp_indx = i4 WITH noconstant(0)
 DECLARE keys_start = i4 WITH noconstant(0)
 DECLARE keys_end = i4 WITH noconstant(0)
 DECLARE keys_batch = i4 WITH constant(medium_batch_size)
 DECLARE iexist = i2 WITH protect, constant(checkdic("ORDER_RECON_DETAIL.SIMPLIFIED_DISPLAY_LINE","A",
   0))
 SELECT DISTINCT INTO "nl:"
  ore_detail_id = ord.order_recon_detail_id, ore_id = ord.order_recon_id
  FROM order_recon ore,
   order_recon_detail ord
  PLAN (ore)
   JOIN (ord
   WHERE ord.order_recon_id=outerjoin(ore.order_recon_id)
    AND ((ord.updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)) OR (ore
   .updt_dt_tm BETWEEN cnvtdatetime(act_from_dt_tm) AND cnvtdatetime(act_to_dt_tm)))
    AND ((ore.order_recon_id+ 0) > 0)
    AND nullind(ord.order_recon_detail_id)=1)
  DETAIL
   iord_ct = (iord_ct+ 1)
   IF (mod(iord_ct,100)=1)
    ifieldstat = alterlist(ord_recon_keys->qual,(iord_ct+ 99))
   ENDIF
   ord_recon_keys->qual[iord_ct].order_recon_detail_id = ord.order_recon_detail_id, ord_recon_keys->
   qual[iord_ct].order_recon_id = ore.order_recon_id
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  or_detail_id = ord.order_recon_detail_id, or_id = orn.order_recon_id, loc_facility_cd = encounter
  .loc_facility_cd,
  encntr_id = encounter.encntr_id, enc_nk = parser(parser_line)
  FROM (dummyt d  WITH seq = value(iord_ct)),
   order_recon_detail ord,
   order_recon orn,
   encounter encounter
  PLAN (d
   WHERE iord_ct > 0
    AND (ord_recon_keys->qual[d.seq].order_recon_id > 0))
   JOIN (orn
   WHERE (orn.order_recon_id=ord_recon_keys->qual[d.seq].order_recon_id))
   JOIN (ord
   WHERE outerjoin(orn.order_recon_id)=ord.order_recon_id)
   JOIN (encounter
   WHERE encounter.encntr_id=orn.encntr_id
    AND parser(inst_filter)
    AND parser(org_filter))
  ORDER BY encounter.encntr_id, encounter.loc_facility_cd, ord.order_nbr,
   orn.order_recon_id, ord.order_recon_detail_id
  HEAD REPORT
   cnt = 0
  HEAD orn.encntr_id
   IF (orn.encntr_id > 0)
    iparentencntr_cnt = (iparentencntr_cnt+ 1)
    IF (mod(iparentencntr_cnt,100)=1)
     ifieldstat = alterlist(ord_recon_encntr_parents->qual,(iparentencntr_cnt+ 99))
    ENDIF
    ord_recon_encntr_parents->qual[iparentencntr_cnt].encntr_id = orn.encntr_id
   ENDIF
  HEAD ord.order_nbr
   IF (ord.order_nbr > 0)
    iparent_cnt = (iparent_cnt+ 1)
    IF (mod(iparent_cnt,100)=1)
     ifieldstat = alterlist(ord_recon_order_parents->qual,(iparent_cnt+ 99))
    ENDIF
    ord_recon_order_parents->qual[iparent_cnt].order_id = ord.order_nbr
   ENDIF
  DETAIL
   cnt = (cnt+ 1), ord_recon_keys->qual[cnt].order_recon_detail_id = or_detail_id, ord_recon_keys->
   qual[cnt].order_recon_id = or_id,
   ord_recon_keys->qual[cnt].loc_facility_cd = loc_facility_cd, ord_recon_keys->qual[cnt].encntr_id
    = encntr_id, ord_recon_keys->qual[cnt].encntr_nk = enc_nk
  FOOT REPORT
   iord_ct = cnt, ifieldstat = alterlist(ord_recon_keys->qual,iord_ct)
  WITH nocounter
 ;end select
 IF (iord_ct <= 0)
  SET iord_cnt = 0
  SET ifieldstat = alterlist(ord_recon_keys->qual,iord_ct)
  GO TO exit_script
 ENDIF
 SET keys_start = 1
 SET keys_end = minval(((keys_start+ keys_batch) - 1),iord_ct)
 CALL echo(build("keys_end:",keys_end))
 WHILE (keys_start <= keys_end)
   SET ifieldstat = alterlist(edw_order_recon->qual,keys_batch)
   IF (debug="Y")
    CALL echo(concat("Looping from keys_start = ",build(keys_start)," to keys_end = ",build(keys_end)
      ))
   ENDIF
   SET temp_indx = 0
   FOR (i = keys_start TO keys_end)
     SET temp_indx = (temp_indx+ 1)
     SET edw_order_recon->qual[temp_indx].order_recon_detail_id = ord_recon_keys->qual[i].
     order_recon_detail_id
     SET edw_order_recon->qual[temp_indx].order_recon_id = ord_recon_keys->qual[i].order_recon_id
     SET edw_order_recon->qual[temp_indx].loc_facility_cd = ord_recon_keys->qual[i].loc_facility_cd
     SET edw_order_recon->qual[temp_indx].encntr_id = ord_recon_keys->qual[i].encntr_id
     SET edw_order_recon->qual[temp_indx].encntr_nk = ord_recon_keys->qual[i].encntr_nk
   ENDFOR
   IF (temp_indx < keys_batch)
    SET cur_list_size = temp_indx
   ELSE
    SET cur_list_size = keys_batch
   ENDIF
   SELECT
    IF (iexist=2)
     n_recon_type_flg = nullind(orn.recon_type_flag), n_no_known_meds_ind = nullind(orn
      .no_known_meds_ind), n_continue_order_ind = nullind(ord.continue_order_ind),
     display_line = ord.simplified_display_line
    ELSE
     n_recon_type_flg = nullind(orn.recon_type_flag), n_no_known_meds_ind = nullind(orn
      .no_known_meds_ind), n_continue_order_ind = nullind(ord.continue_order_ind),
     display_line = " "
    ENDIF
    INTO "nl:"
    FROM (dummyt d  WITH seq = value(cur_list_size)),
     order_recon_detail ord,
     order_recon orn
    PLAN (d
     WHERE cur_list_size > 0)
     JOIN (ord
     WHERE ord.order_recon_detail_id=outerjoin(edw_order_recon->qual[d.seq].order_recon_detail_id))
     JOIN (orn
     WHERE (orn.order_recon_id=edw_order_recon->qual[d.seq].order_recon_id))
    DETAIL
     edw_order_recon->qual[d.seq].performed_prsnl_id = orn.performed_prsnl_id, edw_order_recon->qual[
     d.seq].performed_dt_tm = orn.performed_dt_tm, edw_order_recon->qual[d.seq].updt_dt_tm = orn
     .updt_dt_tm,
     edw_order_recon->qual[d.seq].updt_id = orn.updt_id, edw_order_recon->qual[d.seq].recon_type_flg
      = nullcheck(build(orn.recon_type_flag)," ",n_recon_type_flg), edw_order_recon->qual[d.seq].
     no_known_meds_ind = nullcheck(build(orn.no_known_meds_ind)," ",n_no_known_meds_ind)
     IF ((edw_order_recon->qual[d.seq].order_recon_detail_id=0))
      edw_order_recon->qual[d.seq].order_recon_detail_id = - (1)
     ELSE
      edw_order_recon->qual[d.seq].order_nbr = ord.order_nbr, edw_order_recon->qual[d.seq].
      order_mnemonic = ord.order_mnemonic, edw_order_recon->qual[d.seq].clinical_display_line = ord
      .clinical_display_line,
      edw_order_recon->qual[d.seq].simplified_display_line = display_line, edw_order_recon->qual[d
      .seq].continue_order_ind = nullcheck(build(ord.continue_order_ind)," ",n_continue_order_ind),
      edw_order_recon->qual[d.seq].recon_order_action_meaning = ord.recon_order_action_mean
     ENDIF
    FOOT REPORT
     ifieldstat = alterlist(ord_recon_order_parents->qual,iparent_cnt)
    WITH nocounter
   ;end select
   FOR (i = 1 TO cur_list_size)
     SET timezone = gettimezone(edw_order_recon->qual[i].loc_facility_cd,edw_order_recon->qual[i].
      encntr_id)
     SET edw_order_recon->qual[i].performed_tm_zn = evaluate(edw_order_recon->qual[i].performed_tm_zn,
      0,cnvtint(timezone),edw_order_recon->qual[i].performed_tm_zn)
     SET edw_order_recon->qual[i].updt_tm_zn = evaluate(edw_order_recon->qual[i].updt_tm_zn,0,cnvtint
      (timezone),edw_order_recon->qual[i].updt_tm_zn)
   ENDFOR
   IF (error(err_msg,1) != 0)
    SET scripterror_ind = 1
   ENDIF
   EXECUTE edw_create_order_recon
   SET ifieldstat = alterlist(edw_order_recon->qual,0)
   SET keys_start = (keys_end+ 1)
   SET keys_end = minval(((keys_start+ keys_batch) - 1),iord_ct)
 ENDWHILE
#exit_script
 IF (iord_ct <= 0)
  SELECT INTO value(ord_recon_extractfile)
   FROM dummyt d
   WHERE iord_ct > 0
   WITH noheading, nocounter, format = lfstream,
    maxcol = 1999, maxrow = 1
  ;end select
 ENDIF
 FREE RECORD order_recon_keys
 FREE RECORD edw_order_recon
 CALL edwupdatescriptstatus("ORD_RECN",iord_ct,"0","0")
 CALL echo(build("ORD_RECN Count = ",iord_ct))
 IF (error(err_msg,1) != 0)
  SET scripterror_ind = 1
 ENDIF
 SET error_ind = scripterror_ind
 SET script_version = "000 07/22/11 RP019504"
END GO
