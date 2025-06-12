CREATE PROGRAM bhs_st_rsn_inpat_svcs_tst:dba
 FREE SET request
 RECORD request(
   1 output_device = vc
   1 script_name = vc
   1 person_cnt = i4
   1 person[1]
     2 person_id = f8
   1 visit_cnt = i4
   1 visit[1]
     2 encntr_id = f8
   1 prsnl_cnt = i4
   1 prsnl[*]
     2 prsnl_id = f8
   1 nv_cnt = i4
   1 nv[*]
     2 pvc_name = vc
     2 pvc_value = vc
   1 batch_selection = vc
 )
 SET request->visit[1].encntr_id = 183345457.00
 SET trace = recpersist
 EXECUTE bhs_st_rsn_inpat_svcs
 CALL echorecord(reply)
 SET trace = norecpersist
END GO
