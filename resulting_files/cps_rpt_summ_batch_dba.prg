CREATE PROGRAM cps_rpt_summ_batch:dba
 RECORD requestin(
   1 output_file = vc
   1 person_qual = i4
   1 person[*]
     2 person_id = f8
   1 nbr_sections = i4
   1 allergy = i2
   1 problem = i2
   1 orders = i2
   1 med_profile = i2
   1 encounter = i2
 )
 SET stat = alterlist(requestin->person,request->person_qual)
 SET requestin->output_file = request->output_file
 SET requestin->person_qual = request->person_qual
 SET requestin->nbr_sections = request->nbr_sections
 SET requestin->allergy = request->allergy
 SET requestin->problem = request->problem
 SET requestin->orders = request->orders
 SET requestin->med_profile = request->med_profile
 SET requestin->encounter = request->encounter
 FOR (index = 1 TO request->person_qual)
   SET requestin->person[index].person_id = request->person[index].person_id
 ENDFOR
 FOR (person_index = 1 TO requestin->person_qual)
   FREE SET request
   RECORD request(
     1 output_file = vc
     1 person_id = f8
     1 nbr_sections = i4
     1 allergy = i2
     1 problem = i2
     1 orders = i2
     1 med_profile = i2
     1 encounter = i2
   )
   SET request->nbr_sections = requestin->nbr_sections
   SET request->allergy = requestin->allergy
   SET request->problem = requestin->problem
   SET request->orders = requestin->orders
   SET request->med_profile = requestin->med_profile
   SET request->encounter = requestin->encounter
   IF ((requestin->output_file=" "))
    SET requestin->output_file = "CPS_SUMMARY_SHEET"
   ENDIF
   SET request->output_file = requestin->output_file
   SET request->person_id = requestin->person[person_index].person_id
   EXECUTE cps_rpt_summ
 ENDFOR
 RECORD reply(
   1 output_qual = i4
   1 output[*]
     2 output_file = vc
     2 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->output_qual = requestin->person_qual
 SET stat = alterlist(reply->output,requestin->person_qual)
 FOR (person_index = 1 TO requestin->person_qual)
  SET reply->output[person_index].output_file = concat("ccluserdir:",trim(requestin->output_file),
   trim(cnvtstring(person_index)),".dat")
  SET reply->output[person_index].person_id = requestin->person[person_index].person_id
 ENDFOR
 SET reply->status_data.status = "S"
END GO
