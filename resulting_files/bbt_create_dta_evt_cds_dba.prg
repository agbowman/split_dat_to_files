CREATE PROGRAM bbt_create_dta_evt_cds:dba
 RECORD internal(
   1 int_rec[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
 )
 FREE SET dm_post_event_code
 RECORD dm_post_event_code(
   1 event_set_name = c40
   1 event_cd_disp = c40
   1 event_cd_descr = c60
   1 event_cd_definition = c100
   1 status = c12
   1 format = c12
   1 storage = c12
   1 event_class = c12
   1 event_confid_level = c12
   1 event_subclass = c12
   1 event_code_status = c12
   1 event_cd = f8
   1 parent_cd = f8
   1 flex1_cd = f8
   1 flex2_cd = f8
   1 flex3_cd = f8
   1 flex4_cd = f8
   1 flex5_cd = f8
 )
 SET cnt = 0
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 106
 SET cdf_meaning = "BB"
 EXECUTE cpm_get_cd_for_cdf
 SET bb_act_cd = code_value
 SET code_value = 0.0
 SET glab_result_type_bill_cd = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 289
 SET cdf_meaning = "17"
 EXECUTE cpm_get_cd_for_cdf
 SET bb_result_type_bill_cd = code_value
 SET cnt = 0
 SET x = 0
 SELECT INTO "nl:"
  dta.mnemonic, dta.task_assay_cd
  FROM discrete_task_assay dta
  WHERE dta.activity_type_cd=bb_act_cd
   AND dta.default_result_type_cd != bb_result_type_bill_cd
   AND dta.active_ind=1
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(internal->int_rec,cnt), internal->int_rec[cnt].task_assay_cd =
   dta.task_assay_cd,
   internal->int_rec[cnt].mnemonic = dta.mnemonic
  WITH nocounter
 ;end select
 CALL echo(build("COUNT :",cnt))
 FOR (x = 1 TO cnt)
   SET dm_post_event_code->event_set_name = substring(1,40,internal->int_rec[x].mnemonic)
   SET dm_post_event_code->event_cd_disp = substring(1,40,internal->int_rec[x].mnemonic)
   SET dm_post_event_code->event_cd_descr = substring(1,60,internal->int_rec[x].mnemonic)
   SET dm_post_event_code->event_cd_definition = internal->int_rec[x].mnemonic
   SET dm_post_event_code->status = "ACTIVE"
   SET dm_post_event_code->format = "UNKNOWN"
   SET dm_post_event_code->storage = "UNKNOWN"
   SET dm_post_event_code->event_class = "UNKNOWN"
   SET dm_post_event_code->event_confid_level = "ROUTCLINICAL"
   SET dm_post_event_code->event_subclass = "UNKNOWN"
   SET dm_post_event_code->event_code_status = "AUTH"
   SET dm_post_event_code->event_cd = 0.0
   SET dm_post_event_code->parent_cd = internal->int_rec[x].task_assay_cd
   SET dm_post_event_code->flex1_cd = 0.0
   SET dm_post_event_code->flex2_cd = 0.0
   SET dm_post_event_code->flex3_cd = 0.0
   SET dm_post_event_code->flex4_cd = 0.0
   SET dm_post_event_code->flex5_cd = 0.0
   EXECUTE dm_post_event_code
   CALL echo(build("added :",dm_post_event_code->event_cd_disp,"->",dm_post_event_code->parent_cd,
     "->",
     dm_post_event_code->event_cd))
 ENDFOR
END GO
