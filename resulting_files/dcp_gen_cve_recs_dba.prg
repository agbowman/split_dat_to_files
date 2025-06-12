CREATE PROGRAM dcp_gen_cve_recs:dba
 FREE RECORD cve_request
 RECORD cve_request(
   1 security_flag = i4
   1 encntr_info_flag = i2
   1 encntrs[*]
     2 person_id = f8
     2 encntr_id = f8
     2 org_id = f8
     2 confid_cd = f8
     2 confid_level = i4
   1 concept_string = vc
 ) WITH persistscript
 FREE RECORD cve_reply
 RECORD cve_reply(
   1 security_flag = i4
   1 encntrs[*]
     2 person_id = f8
     2 encntr_id = f8
     2 org_id = f8
     2 confid_cd = f8
     2 confid_level = i4
     2 secure_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
#exit_script
 SET script_version = "000 04/25/03 SF3151"
END GO
