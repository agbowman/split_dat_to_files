CREATE PROGRAM dm2_eod_si_history_load:dba
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
 SET readme_data->status = "F"
 SET readme_data->message = "Failed: Starting script dm2_eod_si_history_load.prg..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE prev_key_version = vc WITH protect, noconstant(" ")
 DECLARE cur_key_version = vc WITH protect, noconstant(" ")
 DECLARE cnt = i4 WITH protect, noconstant(size(eod_dm_info->list,5))
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE this_batch_cnt = i4 WITH protect, noconstant(0)
 FREE RECORD eod_si
 RECORD eod_si(
   1 list[*]
     2 os_version = vc
     2 si_release_ident = f8
     2 version_number = i4
     2 line_number = i4
     2 instruction_txt = vc
     2 key_version = vc
     2 exists_ind = i4
 )
 SET stat = alterlist(eod_si->list,size(requestin->list_0,5))
 FOR (i = 1 TO size(requestin->list_0,5))
   SET eod_si->list[i].os_version = trim(requestin->list_0[i].os_version)
   SET eod_si->list[i].si_release_ident = cnvtreal(requestin->list_0[i].si_release_ident)
   SET eod_si->list[i].version_number = cnvtint(requestin->list_0[i].version_number)
   SET eod_si->list[i].line_number = cnvtint(requestin->list_0[i].line_number)
   SET eod_si->list[i].instruction_txt = trim(requestin->list_0[i].instruction_txt)
   SET eod_si->list[i].key_version = concat("KEY:",trim(requestin->list_0[i].si_release_ident),
    " VERSION:",trim(requestin->list_0[i].version_number))
   SET eod_si->list[i].exists_ind = 0
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Failed loading eod_si record structure:",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di,
   (dummyt d  WITH seq = value(size(eod_si->list,5)))
  PLAN (d)
   JOIN (di
   WHERE di.info_domain="CORE_EOD_SI"
    AND (di.info_name=eod_si->list[d.seq].key_version))
  DETAIL
   eod_si->list[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Failed to find EOD SI info on DM_INFO:",errmsg)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO size(eod_si->list,5))
   SET prev_key_version = cur_key_version
   SET cur_key_version = eod_si->list[i].key_version
   IF ((eod_si->list[i].exists_ind=0)
    AND cur_key_version != prev_key_version)
    IF (locateval(num,1,size(eod_dm_info->list,5),cur_key_version,eod_dm_info->list[num].key_version)
    =0)
     SET cnt = (cnt+ 1)
     SET this_batch_cnt = (this_batch_cnt+ 1)
     IF (mod(this_batch_cnt,10)=1)
      SET stat = alterlist(eod_dm_info->list,((cnt+ this_batch_cnt)+ 9))
     ENDIF
     SET eod_dm_info->list[cnt].os_version = eod_si->list[i].os_version
     SET eod_dm_info->list[cnt].version_number = eod_si->list[i].version_number
     SET eod_dm_info->list[cnt].key_version = eod_si->list[i].key_version
    ENDIF
   ENDIF
 ENDFOR
 SET stat = alterlist(eod_dm_info->list,cnt)
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Failed loading eod_dm_info record structure:",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_core_eod_si dces,
   (dummyt d  WITH seq = value(size(eod_si->list,5)))
  SET dces.core_eod_si_id = seq(dm_ref_seq,nextval), dces.os_version_name = eod_si->list[d.seq].
   os_version, dces.si_release_ident = eod_si->list[d.seq].si_release_ident,
   dces.version_number = eod_si->list[d.seq].version_number, dces.line_number = eod_si->list[d.seq].
   line_number, dces.instruction_txt = eod_si->list[d.seq].instruction_txt,
   dces.updt_applctx = reqinfo->updt_applctx, dces.updt_cnt = 0, dces.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   dces.updt_id = reqinfo->updt_id, dces.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (eod_si->list[d.seq].exists_ind=0))
   JOIN (dces)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to load EOD SI on DM_CORE_EOD_SI:",errmsg)
 ELSE
  SET readme_data->message = "Dm2_eod_si_history_load successful"
  SET readme_data->status = "S"
 ENDIF
#exit_script
END GO
