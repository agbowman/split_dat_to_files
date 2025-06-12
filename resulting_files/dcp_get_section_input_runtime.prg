CREATE PROGRAM dcp_get_section_input_runtime
 IF (validate(reply,"Y")="Y")
  RECORD reply(
    1 dcp_section_instance_id = f8
    1 dcp_section_ref_id = f8
    1 description = vc
    1 definition = vc
    1 task_assay_cd = f8
    1 task_assay_disp = vc
    1 event_cd = f8
    1 event_disp = vc
    1 active_ind = i2
    1 beg_effective_dt_tm = dq8
    1 end_effective_dt_tm = dq8
    1 updt_cnt = i4
    1 input_cnt = i2
    1 input_list[*]
      2 dcp_input_ref_id = f8
      2 input_ref_seq = i4
      2 description = vc
      2 module = vc
      2 input_type = i4
      2 updt_cnt = i4
      2 nv_cnt = i2
      2 nv[*]
        3 pvc_name = vc
        3 pvc_value = vc
        3 merge_id = f8
        3 sequence = i4
    1 cki = vc
    1 width = i4
    1 height = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 EXECUTE dcp_get_section_input
END GO
