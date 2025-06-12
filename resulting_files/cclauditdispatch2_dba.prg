CREATE PROGRAM cclauditdispatch2:dba
 CASE ( $1)
  OF 0200002:
   EXECUTE cclaudit 0, "Output Label", "Speciman",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0200005:
   EXECUTE cclaudit 0, "Maintain Person", "Add Pathology Case",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0200007:
   EXECUTE cclaudit 0, "Access Person", "Pathology Case",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200009:
   FOR (curhipaacnt = 1 TO size(reply->qual,5))
     EXECUTE cclaudit evaluate(((size(reply->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->qual,5) - 1)+ 1),3,
       2)), "Access Person", "Pathology Case",
     "Person", "List", "Patient",
     "Access / use", reply->qual[curhipaacnt].person_id, " "
   ENDFOR
  OF 0200014:
   EXECUTE cclaudit 0, "Maintain Person", "Report",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
  OF 0200018:
   EXECUTE cclaudit 0, "Access Person", "Pathology Case",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0200043:
   EXECUTE cclaudit 0, "Query Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0200048:
   EXECUTE cclaudit 0, "Maintain Person", "Reserve Pathology Case",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0200050:
   EXECUTE cclaudit 0, "Access List", "Reserved Pathology Cases",
   "System Object", "List", "Patient",
   "Access / use", request->person_id, " "
  OF 0200051:
   EXECUTE cclaudit 0, "Output Report", "Reserved Cases",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200066:
   EXECUTE cclaudit 0, "Access Person", "Pathology Case",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200067:
   EXECUTE cclaudit 0, "Run Report", "By Responsibility - Pathology",
   "Person", "User", "Provider",
   "Access / use", request->responsible_pathologist_id, " "
  OF 0200071:
   EXECUTE cclaudit 0, "Access Person", "Open Pathology Cases",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0200075:
   EXECUTE cclaudit 0, "Access List", "Report Queue Info",
   "System Object", "List", "Report Queue Code",
   "Access / use", request->report_queue_cd, " "
  OF 0200077:
   EXECUTE cclaudit 0, "Access Person", "Reports By Accession",
   "System Object", "List", " ",
   "Access / use", 0.0, curprog
  OF 0200079:
   EXECUTE cclaudit 0, "Access Person", "Pathology Case",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200083:
   EXECUTE cclaudit 0, "Output Label", "Reserved Case Labels",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200089:
   EXECUTE cclaudit 0, "Access Person", "Pathology History",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0200091:
   EXECUTE cclaudit 0, "Access Person", "Case Alerts",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0200098:
   EXECUTE cclaudit 0, "Access Person", "Cytology Case Info",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200118:
   EXECUTE cclaudit 0, "Maintain Person", "Cytology Report Info",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
  OF 0200125:
   EXECUTE cclaudit 0, "Access List", "Cytology Reports by Queue",
   "System Object", "List", "Report Queue Code",
   "Access / use", request->report_queue_cd, " "
  OF 0200127:
   EXECUTE cclaudit 0, "Output Report", "Outstanding Reports",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200137:
   EXECUTE cclaudit 0, "Access Person", "Pathology Case",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200141:
   EXECUTE cclaudit 0, "Maintain Person", "Historical Case",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0200143:
   EXECUTE cclaudit 0, "Access Person", "Pathology Case",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200146:
   EXECUTE cclaudit 0, "Access List", "Outstanding Tasks",
   "System Object", "List", " ",
   "Access / use", 0.0, curprog
  OF 0200149:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0200152:
   EXECUTE cclaudit 0, "Access Person", "Follow Up Tracking Info",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0200156:
   EXECUTE cclaudit 0, "Access Person", "Pathology Case Info",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200157:
   EXECUTE cclaudit 0, "Maintain Person", "Add Followup Tracking Event",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0200159:
   EXECUTE cclaudit 0, "Maintain Person", "Maintain Followup Tracking Event",
   "Person", "Patient", "Patient",
   "Amendment", reply->person_id, " "
  OF 0200168:
   EXECUTE cclaudit 0, "Output Report", "Detailed Worklist",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200169:
   EXECUTE cclaudit 0, "Access List", "Open Pathology Cases",
   "System Object", "List", "Patient",
   "Access / use", request->person_id, " "
  OF 0200172:
   EXECUTE cclaudit 0, "Output Report", "Follow Up Tracking Report",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200173:
   EXECUTE cclaudit 0, "Output Report", "Sample Quality by Physician Report",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200174:
   EXECUTE cclaudit 0, "Output Report", "Report Verification Summary",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200177:
   EXECUTE cclaudit 0, "Output Report", "Followup Tracking Review Report",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200187:
   EXECUTE cclaudit 0, "Output Report", "Statistics by Physician Report",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200189:
   EXECUTE cclaudit 0, "Output Report", "Cytology Screening Worklist",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200191:
   EXECUTE cclaudit 0, "Output Report", "Cytology Screening Worklist",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200195:
   EXECUTE cclaudit 0, "Output Label", "Speciman and Slide Labels",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200200:
   EXECUTE cclaudit 0, "Output Report", "Summary Worklist",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200208:
   EXECUTE cclaudit 0, "Query Person", "Speciman Login Info",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200209:
   EXECUTE cclaudit 0, "Output Report", "Case Log",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200211:
   EXECUTE cclaudit 0, "Output Report", "Speciman Adequacy Report",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0200216:
   EXECUTE cclaudit 0, "Access List", "Report by Queue",
   "System Object", "List", "Report Queue Code",
   "Access / use", request->report_queue_cd, " "
  OF 0200217:
   EXECUTE cclaudit 0, "Access Person", "Cases by Accession",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0200308:
   EXECUTE cclaudit 0, "Access Person", "Corrected Reports by Case",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200315:
   EXECUTE cclaudit 0, "Access Person", "Query Pathology Case",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0200321:
   EXECUTE cclaudit 0, "Access Person", "Aliases",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0200329:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0200334:
   EXECUTE cclaudit 0, "Access Person", "Case Alerts",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0200335:
   EXECUTE cclaudit 0, "Access Person", "Cases by Query Result",
   "Person", "Patient", "Case Query",
   "Access / use", request->case_query_id, " "
  OF 0200338:
   EXECUTE cclaudit 0, "Access Person", "Cases by Query Result",
   "Person", "Patient", "Case Query",
   "Access / use", request->qual[1].case_query_id, " "
  OF 0200389:
   EXECUTE cclaudit 0, "Maintain Person", "Case ICD-9 Codes",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
  OF 0200404:
   EXECUTE cclaudit 0, "Access List", "Cytology Reports by Responsibility",
   "Person", "List", "Provider",
   "Access / use", request->responsible_pathologist_id, " "
  OF 0200405:
   EXECUTE cclaudit 0, "Maintain Person", "Diagnostic Correlation Events",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
  OF 0225002:
   EXECUTE cclaudit 0, "Access Person", "Access Blood Product",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0225032:
   EXECUTE cclaudit 0, "Maintain Person", "Dispense BB Product",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0225048:
   EXECUTE cclaudit 0, "Maintain Person", "Transfuse Product(s) to Person(s)",
   "Person", "Patient", " ",
   "Origination", 0.0, curprog
  OF 0225051:
   EXECUTE cclaudit 0, "Access Person", "Dispense Information",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0225064:
   EXECUTE cclaudit 0, "Maintain Person", "Return BB Products",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 0225068:
   EXECUTE cclaudit 0, "Query Person", "BB Orders and Results",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0225069:
   FOR (curhipaacnt = 1 TO size(reply->qual,5))
     EXECUTE cclaudit evaluate(((size(reply->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->qual,5) - 1)+ 1),3,
       2)), "Maintain Person", "Add BB Product Event",
     "Person", "Patient", "Patient",
     "Origination", request->qual[curhipaacnt].person_id, " "
   ENDFOR
  OF 0225070:
   EXECUTE cclaudit 0, "Maintain Person", "BB Transfusion Results",
   "Person", "Patient", " ",
   "Origination", 0.0, curprog
  OF 0225077:
   EXECUTE cclaudit 0, "Access Person", "Get Crossmatch Validation Information",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0225079:
   EXECUTE cclaudit 0, "Maintain Person", "Add Modified Products",
   "Person", "Patient", " ",
   "Origination", 0.0, curprog
  OF 0225087:
   EXECUTE cclaudit 0, "Output Report", "Patient Result Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225089:
   EXECUTE cclaudit 0, "Output Report", "Dispense Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225091:
   EXECUTE cclaudit 0, "Query Person", "BB Patient Data",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225107:
   EXECUTE cclaudit 0, "Query Person", "Transfusion History",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225110:
   EXECUTE cclaudit 0, "Query Person", "Get Patient / Product Information",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225111:
   EXECUTE cclaudit 0, "Query Person", "Get Person ABORH",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225125:
   EXECUTE cclaudit 0, "Query Person", "Get Blood Product",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225152:
   EXECUTE cclaudit 0, "Output Label", "BB Tags/Labels",
   "Person", "Patient", " ",
   "Report", 0.0, curprog
  OF 0225173:
   EXECUTE cclaudit 0, "Maintain Person", "BB Person Comment",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0225174:
   EXECUTE cclaudit 0, "Query Person", "Get BB Person Comment",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225175:
   EXECUTE cclaudit 0, "Maintain Person", "Update BB Person Comment",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225180:
   EXECUTE cclaudit 0, "Maintain Person", "Add Pooled Product",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0225181:
   EXECUTE cclaudit 0, "Query Person", "Get Crossmatch",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0225182:
   EXECUTE cclaudit 0, "Output Report", "Autologous/Directed Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225183:
   EXECUTE cclaudit 0, "Output Report", "Exception Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225186:
   EXECUTE cclaudit 0, "Output Report", "Final Disposition Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225187:
   EXECUTE cclaudit 0, "Output Report", "Patient and Typings Comment Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225190:
   EXECUTE cclaudit 0, "Output Report", "Transfusion Log Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225193:
   EXECUTE cclaudit 0, "Maintain Person", "Update BB Transfusion Results",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 0225196:
   EXECUTE cclaudit 0, "Maintain Person", "Correct Product",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 0225197:
   EXECUTE cclaudit 0, "Maintain Person", "Add BB Assignment",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0225214:
   EXECUTE cclaudit 0, "Access List", "Get Crossmatch Release Products",
   "System Object", "List", " ",
   "Access / use", 0.0, build(request->look_ahead_hrs)
  OF 0225218:
   EXECUTE cclaudit 0, "Access List", "Batch Transfusion",
   "Person", "List", " ",
   "Access / use", 0.0, build(request->look_ahead_hrs)
  OF 0225219:
   EXECUTE cclaudit 0, "Access Person", "Get BB Transfusion Requirements",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225220:
   EXECUTE cclaudit 0, "Maintain Person", "Add/Update BB Transfusion Requirements",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0225223:
   EXECUTE cclaudit 0, "Access Person", "Crossmatch Reinstatement Information by product",
   "Person", "Patient", " ",
   "Access / use", 0.0, reply->patient_name
  OF 0225227:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225229:
   EXECUTE cclaudit 0, "Access Person", "Person Transfusion Requirements",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225230:
   EXECUTE cclaudit 0, "Access Person", "Crossmatch Reinstatement Information by patient",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225232:
   EXECUTE cclaudit 0, "Maintain Person", "Correct Emergency Dispensed Product",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
  OF 0225233:
   EXECUTE cclaudit 0, "Access Person", "Emergency Dispensed Data",
   "Person", "Patient", " ",
   "Access / use", 0.0, reply->unknown_patient_text
  OF 0225234:
   EXECUTE cclaudit 0, "Output Report", "Result Corrections",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225235:
   EXECUTE cclaudit 0, "Output Report", "Pooled Products",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225236:
   EXECUTE cclaudit 0, "Output Report", "Product Corrections",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225243:
   EXECUTE cclaudit 0, "Output Report", "Review Queue",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225248:
   EXECUTE cclaudit 0, "Output Report", "Product Status Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225251:
   EXECUTE cclaudit 0, "Access Person", "Patient Dispense Information",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0225270:
   EXECUTE cclaudit 0, "Access Person", "Product Hisotry",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0225282:
   EXECUTE cclaudit 0, "Output Report", "Transfusion Committee",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225290:
   EXECUTE cclaudit 0, "Output Report", "Component Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225300:
   EXECUTE cclaudit 0, "Output Report", "Autologous/Directed Persons not Combined Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225301:
   EXECUTE cclaudit 0, "Output Report", "Products Dispensed to Unknown Patients Report",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0225386:
   EXECUTE cclaudit 0, "Access Person", "Get Anutologous/Directed Information",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0225396:
   EXECUTE cclaudit 0, "Maintain Person", "Correct Pooled Product",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 0225411:
   EXECUTE cclaudit 0, "Access Person", "Person Antigens",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225472:
   EXECUTE cclaudit 0, "Access Person", "Person Phenotype",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225489:
   EXECUTE cclaudit 0, "Access Person", "Products for Person",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225500:
   EXECUTE cclaudit 0, "Access Person", "Aliases",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225566:
   EXECUTE cclaudit 0, "Access Person", "ABORH Results",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225568:
   EXECUTE cclaudit 0, "Access Person", "Product Events",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225570:
   EXECUTE cclaudit 0, "Access Person", "Current BB Orders and Results",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225571:
   EXECUTE cclaudit 0, "Access Person", "Get Autologous/Directed Products",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225597:
   EXECUTE cclaudit 0, "Access Person", "Available Speciments",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0225907:
   EXECUTE cclaudit 0, "Access List", "BB Review Information",
   "System Object", "List", "Patient",
   "Access / use", request->person_id, " "
  OF 0225911:
   EXECUTE cclaudit 0, "Run Report", "Data for Historical Upload",
   "Organization", "Location", " ",
   "Access / use", 0.0, curprog
  OF 0225912:
   EXECUTE cclaudit 0, "Maintain Person", "Inactivate Multiple Active Person ABORH's",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
  OF 0250003:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->qual[1].order_id, " "
  OF 0250051:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0250052:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0250060:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Organization", "Location", "Service Resource Code",
   "Access / use", request->service_resource_cd, " "
  OF 0250067:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0250070:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0250071:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0250074:
   EXECUTE cclaudit 0, "Maintain Person", "Discrete Results",
   "Person", "Patient", " ",
   "Origination", 0.0, curprog
  OF 0250077:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Worklist",
   "Access / use", request->worklist_id, " "
  OF 0250083:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Organization", "Location", "Service Resource Code",
   "Access / use", request->service_resource_cd, " "
  OF 0250095:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0250109:
   EXECUTE cclaudit 0, "Output Report", "Results",
   "Organization", "Location", " ",
   "Report", 0.0, curprog
  OF 0250110:
   EXECUTE cclaudit 0, "Output Report", "Exception Report",
   "Organization", "Location", " ",
   "Report", 0.0, curprog
  OF 0250116:
   EXECUTE cclaudit 0, "Output Report", "Correction Report",
   "Organization", "Location", " ",
   "Report", 0.0, curprog
  OF 0250143:
   FOR (curhipaacnt = 1 TO size(request->accns,5))
     EXECUTE cclaudit evaluate(((size(request->accns,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->accns,5) - 1)+ 1),3,
       2)), "Access Person", "Pathology",
     "Person", "Patient", "Accession",
     "Access / use", request->accns[curhipaacnt].accession, " "
   ENDFOR
  OF 0250148:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0250149:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0250150:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0250197:
   EXECUTE cclaudit 0, "Output Report", "Worklist",
   "Organization", "Location", " ",
   "Report", 0.0, curprog
  OF 0250212:
   EXECUTE cclaudit 0, "Access Encounter", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0250216:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0265003:
   EXECUTE cclaudit 0, "Maintain Person", "Update Collection Information",
   "Person", "Patient", "Patient",
   "Access / use", request->encntr_id, " "
  OF 0265007:
   EXECUTE cclaudit 0, "Access List", "Get Login Information By Transfer List",
   "System Object", "Report", "Collection List",
   "Access / use", request->list_id, " "
  OF 0265014:
   EXECUTE cclaudit 0, "Access List", "Get Login Information By Location",
   "System Object", "Report", "Location Code",
   "Access / use", request->location_cd, " "
  OF 0265015:
   EXECUTE cclaudit 0, "Access List", "Get Login Information By List",
   "System Object", "Report", "Collection List",
   "Access / use", request->list_id, " "
  OF 0265016:
   EXECUTE cclaudit 0, "Access List", "Get Login Information By Person",
   "System Object", "Report", "Patient",
   "Access / use", request->person_id, " "
  OF 0265017:
   EXECUTE cclaudit 0, "Access List", "Get Login Information By Accession",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0265018:
   EXECUTE cclaudit 0, "Maintain Person", "Schedule Collection",
   "Person", "Patient", "Patient",
   "Access / use", request->encntr_id, " "
  OF 0265060:
   EXECUTE cclaudit 0, "Update Login Information", "Pathology",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 0265066:
   EXECUTE cclaudit 0, "Access Person", "Patient Information by Accession",
   "Person", "Patient", "Accession",
   "Access / use", request->accession_nbr, " "
  OF 0265084:
   EXECUTE cclaudit 0, "Output Label", "Specimen Label",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0265088:
   EXECUTE cclaudit 0, "Access List", "Pending Collections by Location",
   "Organization", "List", " ",
   "Access / use", 0.0, curprog
  OF 0265092:
   EXECUTE cclaudit 0, "Access List", "Transfer List",
   "Person", "List", " ",
   "Access / use", 0.0, curprog
  OF 0265104:
   EXECUTE cclaudit 0, "Access List", "Pending Collections by List",
   "Person", "List", " ",
   "Access / use", 0.0, curprog
  OF 0265120:
   EXECUTE cclaudit 0, "Access List", "Containers by Accession",
   "Person", "List", " ",
   "Access / use", 0.0, curprog
  OF 0265121:
   EXECUTE cclaudit 0, "Access List", "Pending Collections",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0265137:
   EXECUTE cclaudit 0, "Access List", "Missed Collections",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0265152:
   EXECUTE cclaudit 0, "Maintain Person", "Modify Container Information",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 0265179:
   EXECUTE cclaudit 0, "Maintain Person", "Update Collection Information",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 0265197:
   EXECUTE cclaudit 0, "Output Report", "Transfer List",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0265210:
   EXECUTE cclaudit 0, "Access List", "Manual Transfer",
   "Person", "List", " ",
   "Access / use", 0.0, curprog
  OF 0265225:
   EXECUTE cclaudit 0, "Access Person", "Containers by Person",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0265228:
   EXECUTE cclaudit 0, "Output Report", "Packing List",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0265245:
   EXECUTE cclaudit 0, "Access List", "Containers by Accession",
   "Person", "List", " ",
   "Access / use", 0.0, curprog
  OF 0275004:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0275062:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Order",
   "Access / use", request->dorder_id, " "
  OF 0275080:
   EXECUTE cclaudit 0, "Output Label", "Pathology",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0295407:
   EXECUTE cclaudit 0, "Output Report", "Pathology",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0295546:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "WorkList",
   "Access / use", request->worklist_id, " "
  OF 0295552:
   EXECUTE cclaudit 0, "Output Report", "Breakpoint Worklist",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0295554:
   EXECUTE cclaudit 0, "Output Report", "Breakpoint Susceptability Report",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 0295555:
   EXECUTE cclaudit 0, "Output Report", "Breakpoint Bio Report",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
 ENDCASE
END GO
