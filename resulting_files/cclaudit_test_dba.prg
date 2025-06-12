CREATE PROGRAM cclaudit_test:dba
 RECORD request(
   1 qual[3]
     2 person_id = f8
   1 person_id = f8
   1 person_id1 = f8
   1 person_id2 = f8
   1 person_id3 = f8
   1 person_id4 = f8
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET request->person_id1 = 100
 SET request->person_id2 = 200
 SET request->person_id3 = 300
 SET request->person_id4 = 400
 SET reply->status_data.status = "S"
 EXECUTE cclaudit 0, "Query Pat", "Demographics",
 "1", "1", "2",
 "5", request->person_id, " "
 FOR (curhipaacnt = 1 TO size(request->qual,5))
   EXECUTE cclaudit 0, "Query Pat", "Demographics",
   "1", "1", "2",
   "5", request->qual[curhipaacnt].person_id, " "
 ENDFOR
END GO
