CREATE PROGRAM dm_run_cmb_in_proc:dba
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 encntr_id = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 person_id = f8
   1 encntr_id = f8
   1 new_person_id = f8
   1 new_encntr_id = f8
   1 valid_person_ind = i2
   1 valid_encntr_ind = i2
   1 person_encntr_match_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->person_id =  $1
 SET request->encntr_id =  $2
 EXECUTE dm_combine_in_process
 CALL echorecord(reply)
#exit_script
END GO
