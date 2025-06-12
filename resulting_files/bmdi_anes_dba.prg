CREATE PROGRAM bmdi_anes:dba
 DECLARE monid = vc
 DECLARE custom_options = vc
 SET monid = ""
#menu
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,20,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"BMDI TROUBLESHOOTING UTILITY")
 CALL box(5,9,19,72)
 CALL line(7,9,64,xhor)
 CALL text(6,11,"Anesthesia")
 CALL text(8,11," 1. View task assay build")
 CALL text(10,11," 2. View inet anesthesia parameter mapping")
 CALL text(12,11," 3. View results")
 CALL text(14,11," 4. View associations")
 CALL text(16,11," 5. View devices available for association")
 CALL text(18,11," 6. Back to main menu")
 CALL text(21,2,"Select an item number:  ")
 CALL accept(21,25,"9",0
  WHERE curaccept > 0
   AND curaccept <= 6)
 CASE (curaccept)
  OF 1:
   GO TO taskassay_audit
  OF 2:
   GO TO inet_anes_parm
  OF 3:
   GO TO results
  OF 4:
   GO TO anes_assoc
  OF 5:
   GO TO free_devices
  ELSE
   GO TO exit_script
 ENDCASE
#taskassay_audit
 SELECT
  mnemonic = substring(1,40,dta.mnemonic), dta.task_assay_cd, dta.event_cd,
  seq = src.sequence, category = decode(src.sa_ref_cat_parameter_id,srca.category_name,"")
  FROM sa_ref_parameter s,
   sa_ref_cat_parameter src,
   sa_ref_category srca,
   discrete_task_assay dta
  PLAN (s
   WHERE s.active_ind=1)
   JOIN (src
   WHERE src.sa_ref_parameter_id=s.sa_ref_parameter_id
    AND src.active_ind=1)
   JOIN (srca
   WHERE srca.sa_ref_category_id=src.sa_ref_category_id
    AND srca.active_ind=1)
   JOIN (dta
   WHERE s.task_assay_cd=dta.task_assay_cd)
  ORDER BY dta.mnemonic, category
  WITH nocounter
 ;end select
 GO TO menu
#inet_anes_parm
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,16,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"Inet Anesthesia parameter mapping")
 CALL box(6,9,14,72)
 CALL line(8,9,64,xhor)
 CALL text(7,11,"MENU")
 CALL text(9,11," 1. View all")
 CALL text(11,11," 2. View parameters by device")
 CALL text(13,11," 3. Back to anesthesia menu")
 CALL text(18,2,"Select an item number:  ")
 CALL accept(18,25,"9",0
  WHERE curaccept > 0
   AND curaccept <= 3)
 CASE (curaccept)
  OF 1:
   GO TO view_all
  OF 2:
   GO TO view_by_device
  ELSE
   GO TO menu
 ENDCASE
#view_all
 SELECT
  class = substring(1,18,lab.instr_alias), mnemonic = substring(1,40,dta.mnemonic), dta.task_assay_cd,
  dta.event_cd, bdp.parameter_alias, seq = src.sequence,
  category = srca.category_name
  FROM lab_instrument lab,
   sa_ref_parameter s,
   sa_ref_cat_parameter src,
   sa_ref_category srca,
   bmdi_device_parameter bdp,
   discrete_task_assay dta
  PLAN (s
   WHERE s.active_ind=1)
   JOIN (src
   WHERE src.sa_ref_parameter_id=s.sa_ref_parameter_id
    AND src.active_ind=1)
   JOIN (srca
   WHERE srca.sa_ref_category_id=src.sa_ref_category_id
    AND srca.active_ind=1)
   JOIN (dta
   WHERE s.task_assay_cd=dta.task_assay_cd)
   JOIN (bdp
   WHERE s.task_assay_cd=bdp.task_assay_cd)
   JOIN (lab
   WHERE lab.service_resource_cd=bdp.device_cd)
  ORDER BY seq, dta.mnemonic, category
  WITH nocounter
 ;end select
 GO TO inet_anes_parm
#view_by_device
 CALL clear(1,1)
 CALL video(n)
 CALL box(2,1,8,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"Inet Anesthesia Parameter Mapping")
 CALL text(6,11," Enter a monitor ID: ")
 CALL accept(6,35,"P(15);C","")
 SET monid = curaccept
 IF (monid="")
  CALL text(9,2," Invalid monitor entered. Press any key to continue")
  CALL accept(9,56,"P(1)")
  GO TO view_by_device
 ENDIF
 SELECT
  class = substring(1,18,lab.instr_alias), mnemonic = substring(1,40,dta.mnemonic), dta.task_assay_cd,
  dta.event_cd, bdp.parameter_alias, seq = src.sequence,
  category = decode(src.sa_ref_cat_parameter_id,srca.category_name,"")
  FROM lab_instrument lab,
   sa_ref_parameter s,
   sa_ref_cat_parameter src,
   sa_ref_category srca,
   bmdi_device_parameter bdp,
   discrete_task_assay dta
  PLAN (s
   WHERE s.active_ind=1)
   JOIN (src
   WHERE src.sa_ref_parameter_id=s.sa_ref_parameter_id
    AND src.active_ind=1)
   JOIN (srca
   WHERE srca.sa_ref_category_id=src.sa_ref_category_id
    AND srca.active_ind=1)
   JOIN (dta
   WHERE s.task_assay_cd=dta.task_assay_cd)
   JOIN (bdp
   WHERE s.task_assay_cd=bdp.task_assay_cd)
   JOIN (lab
   WHERE lab.service_resource_cd=bdp.device_cd
    AND lab.instr_alias=patstring(monid))
  ORDER BY seq, dta.mnemonic, category
 ;end select
 GO TO inet_anes_parm
#results
 CALL clear(1,1)
 CALL video(nw)
 CALL box(2,1,14,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"Results")
 CALL box(5,9,13,72)
 CALL line(7,9,64,xhor)
 CALL text(6,11,"MENU")
 CALL text(8,11," 1. View all")
 CALL text(10,11," 2. View results by monitor")
 CALL text(12,11," 3. Back to anesthesia menu")
 CALL text(15,2,"Select an item number:  ")
 CALL accept(15,25,"9",0
  WHERE curaccept > 0
   AND curaccept <= 3)
 CASE (curaccept)
  OF 1:
   GO TO view_all_res
  OF 2:
   GO TO view_res_device
  ELSE
   GO TO menu
 ENDCASE
#view_all_res
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT
  b.clinical_dt_tm"@SHORTDATETIME", bd_task_assay_disp = substring(1,30,uar_get_code_display(bd
    .task_assay_cd)), result_val = substring(1,5,b.result_val),
  monitor_id = substring(1,16,bm.device_alias), b.acquired_dt_tm"@SHORTDATETIME", b.updt_dt_tm
  "@SHORTDATETIME",
  bm_resource_loc_disp = uar_get_code_display(bm.resource_loc_cd)
  FROM bmdi_acquired_results b,
   bmdi_device_parameter bd,
   bmdi_monitored_device bm
  PLAN (b
   WHERE b.parent_entity_id > 0)
   JOIN (bd
   WHERE bd.device_parameter_id=b.device_parameter_id
    AND bd.active_ind=1)
   JOIN (bm
   WHERE bm.monitored_device_id=b.monitored_device_id)
  ORDER BY b.updt_dt_tm DESC, bm.device_alias
  WITH nocounter
 ;end select
 GO TO results
#view_res_device
 CALL clear(1,1)
 CALL video(n)
 CALL box(2,1,8,80)
 CALL line(4,1,80,xhor)
 CALL text(3,3,"Results")
 CALL text(6,11," Enter a monitor ID: ")
 CALL accept(6,35,"P(15);C","")
 SET monid = curaccept
 IF (monid="")
  CALL text(9,2," Invalid monitor entered. Press any key to continue")
  CALL accept(9,56,"P(1)")
  GO TO view_res_device
 ENDIF
 CALL video(rbw)
 CALL text(14,2,"Please wait...")
 SELECT
  b.clinical_dt_tm"@SHORTDATETIME", bd_task_assay_disp = substring(1,30,uar_get_code_display(bd
    .task_assay_cd)), result_val = substring(1,5,b.result_val),
  monitor_id = substring(1,16,bm.device_alias), b.acquired_dt_tm"@SHORTDATETIME", b.updt_dt_tm
  "@SHORTDATETIME",
  bm_resource_loc_disp = uar_get_code_display(bm.resource_loc_cd)
  FROM bmdi_acquired_results b,
   bmdi_device_parameter bd,
   bmdi_monitored_device bm
  PLAN (b
   WHERE b.parent_entity_id > 0)
   JOIN (bd
   WHERE bd.device_parameter_id=b.device_parameter_id
    AND bd.active_ind=1)
   JOIN (bm
   WHERE bm.monitored_device_id=b.monitored_device_id
    AND bm.device_alias=patstring(monid))
  ORDER BY b.clinical_dt_tm DESC, bm.device_alias
  WITH nocounter
 ;end select
 GO TO results
#anes_assoc
 SELECT INTO "nl:"
  FROM strt_model_custom s
  WHERE s.strt_config_id=1282105
  DETAIL
   custom_options = s.custom_option
  WITH nocounter
 ;end select
 IF (substring(1,1,custom_options) != "1")
  SELECT
   record_description = substring(1,16,s.record_description), device_alias = substring(1,20,bm
    .device_alias), room = substring(1,10,uar_get_code_display(b.resource_loc_cd)),
   b.active_ind, assoc_time = b.association_dt_tm"@SHORTDATETIME", b.dis_association_dt_tm
   "@SHORTDATETIME",
   anes_rec_create_tm = s.create_dt_tm"@SHORTDATETIME"
   FROM sa_anesthesia_record s,
    bmdi_acquired_data_track b,
    bmdi_monitored_device bm
   PLAN (s
    WHERE s.active_ind=1)
    JOIN (b
    WHERE s.sa_anesthesia_record_id=b.parent_entity_id
     AND ((b.active_ind=1) OR (b.active_ind=0)) )
    JOIN (bm
    WHERE bm.device_cd=b.device_cd
     AND bm.resource_loc_cd=b.resource_loc_cd)
   ORDER BY assoc_time DESC, b.active_ind, room,
    device_alias
   WITH nocounter
  ;end select
 ELSE
  SELECT
   record_description = substring(1,16,s.record_description), device_alias = substring(1,20,bm
    .device_alias), room = substring(1,10,uar_get_code_display(b.resource_loc_cd)),
   b.active_ind, assoc_time = b.association_dt_tm"@SHORTDATETIME", b.dis_association_dt_tm
   "@SHORTDATETIME",
   anes_rec_create_tm = s.create_dt_tm"@SHORTDATETIME"
   FROM sa_anesthesia_record s,
    bmdi_acquired_data_track b,
    bmdi_monitored_device bm
   PLAN (s
    WHERE s.active_ind=1)
    JOIN (b
    WHERE s.sa_anesthesia_record_id=b.parent_entity_id
     AND ((b.active_ind=1) OR (b.active_ind=0)) )
    JOIN (bm
    WHERE bm.monitored_device_id=b.monitored_device_id
     AND bm.resource_loc_cd=b.resource_loc_cd)
   ORDER BY assoc_time DESC, b.active_ind, room,
    device_alias
   WITH nocounter
  ;end select
 ENDIF
 GO TO menu
#free_devices
 SELECT
  device_alias = substring(1,20,bm.device_alias), room = substring(1,10,uar_get_code_display(b
    .resource_loc_cd)), b.active_ind,
  b.parent_entity_name, b.parent_entity_id, b.updt_dt_tm"@SHORTDATETIME",
  assoc_time = b.association_dt_tm"@SHORTDATETIME", b.dis_association_dt_tm"@SHORTDATETIME", b
  .resource_loc_cd
  FROM bmdi_acquired_data_track b,
   bmdi_monitored_device bm
  PLAN (b
   WHERE b.resource_loc_cd > 0
    AND b.active_ind=0
    AND b.parent_entity_id=0)
   JOIN (bm
   WHERE b.resource_loc_cd=bm.resource_loc_cd
    AND b.monitored_device_id=bm.monitored_device_id)
  ORDER BY b.resource_loc_cd, device_alias
 ;end select
 GO TO menu
END GO
