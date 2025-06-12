CREATE PROGRAM bhs_sys_rte_process_req
 SET error = exit_on_error
 IF ((validate(rte_req->r_cnt,- (1))=- (1)))
  DECLARE successful_flg = i2 WITH constant(1)
  DECLARE err_encntr_not_found_flg = i2 WITH constant(2)
  DECLARE err_no_results_found_flg = i2 WITH constant(3)
  DECLARE err_no_reltns_found_flg = i2 WITH constant(4)
  DECLARE err_rec_filtered_out_flg = i2 WITH constant(5)
  FREE RECORD rte_req
  RECORD rte_req(
    1 prg_name = vc
    1 r_cnt = i4
    1 records[*]
      2 rec_id = f8
      2 encntr_id = f8
      2 entity_name = vc
      2 entity_id = vc
  ) WITH persist
 ELSE
  GO TO exit_on_error
 ENDIF
 GO TO exit_script
#exit_on_error
 FREE RECORD rte_req
 FREE RECORD rte_reply
 FREE SET successful_flg
 FREE SET err_encntr_not_found_flg
 FREE SET err_no_results_found_flg
 FREE SET err_no_reltns_found_flg
 FREE SET err_rec_filtered_out_flg
#exit_script
 SET error = off
END GO
