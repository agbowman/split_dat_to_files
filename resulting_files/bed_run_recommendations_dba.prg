CREATE PROGRAM bed_run_recommendations:dba
 RECORD drequest(
   1 source_flag = i2
   1 programs[*]
     2 program_name = vc
     2 meaning = vc
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM br_rec b
  PLAN (b
   WHERE b.active_ind=1)
  HEAD REPORT
   tot_cnt = 0, cnt = 0, stat = alterlist(drequest->programs,100)
  DETAIL
   tot_cnt = (tot_cnt+ 1), cnt = (cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(drequest->programs,(tot_cnt+ 100)), cnt = 1
   ENDIF
   drequest->programs[tot_cnt].program_name = b.program_name, drequest->programs[tot_cnt].meaning = b
   .rec_mean
  FOOT REPORT
   stat = alterlist(drequest->programs,tot_cnt)
  WITH nocounter
 ;end select
 SET trace = recpersist
 EXECUTE bed_rec_driver  WITH replace("REQUEST",drequest)
 COMMIT
#exit_script
 SET reply->status_data.status = "S"
END GO
