CREATE PROGRAM cclauditdispatch8:dba
 CASE ( $1)
  OF 0800071:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Surgical Case",
   "Person", "Patient", "Surg Case",
   "Origination", request->surg_case_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Surgical Case",
   "Person", "Patient", "Encounter",
   "Origination", request->enctr_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0800201:
   EXECUTE cclaudit 0, "Query List", "Surgical Case Charge",
   "System Object", "List", "Surg Case",
   "Access / use", reply->cases.surg_case_id, " "
  OF 0800202:
   EXECUTE cclaudit 0, "Query Person", "Surgical Case Charge",
   "Person", "Patient", "Surg Case",
   "Access / use", request->transactions.surg_case_id, " "
  OF 0800203:
   EXECUTE cclaudit 0, "Query List", "Surgical Case Charge",
   "Person", "Patient", "Surg Case",
   "Access / use", request->surg_case_id, " "
  OF 0800370:
   EXECUTE cclaudit 0, "Query Person", "Procedures",
   "Person", "Patient", "Surg Case",
   "Access / use", request->surg_case_id, " "
  OF 0800371:
   EXECUTE cclaudit 0, "Maintain Person", "Surgical Case",
   "Person", "Patient", "Surg Case",
   "Amendment", request->surg_case_id, " "
  OF 0800400:
   EXECUTE cclaudit 0, "Maintain Person", "Surgical Case",
   "Person", "Patient", "Patient",
   "Origination/Amendment", req_c_case->person_id, " "
  OF 0800401:
   EXECUTE cclaudit 0, "Maintain Person", "Surgical Case",
   "Person", "Patient", "Surg Case",
   "Amendment", request->surg_case_id, " "
  OF 0805010:
   EXECUTE cclaudit 0, "Query Document", "Surgical Document",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0840030:
   EXECUTE cclaudit 0, "Maintain Person", "Checkout surgical case patient",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
 ENDCASE
END GO
