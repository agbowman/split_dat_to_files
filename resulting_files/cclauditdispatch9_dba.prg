CREATE PROGRAM cclauditdispatch9:dba
 CASE ( $1)
  OF 0951010:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", " ",
   "Origination/Amendment", 0.0, " "
  OF 0961010:
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0961011:
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0961012:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Query Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->prsnl_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Query Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0961013:
   FOR (curhipaacnt = 1 TO size(request->encntr,5))
     EXECUTE cclaudit evaluate(((size(request->encntr,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size
       (request->encntr,5) - 1)+ 1),3,
       2)), "Query Person", "Demographics",
     "Person", "Patient", "Encounter",
     "Access / use", request->encntr[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 0961015:
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0961017:
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0961021:
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0961023:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Person", "Chart Access Log",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Person", "Chart Access Log",
   "Person", "Patient", "Patient",
   "Access / use", request->prsnl_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0961025:
   FOR (curhipaacnt = 1 TO size(request->encntr,5))
     EXECUTE cclaudit evaluate(((size(request->encntr,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size
       (request->encntr,5) - 1)+ 1),3,
       2)), "Query Person", "Demographics",
     "Person", "Patient", "Encounter",
     "Access / use", request->encntr[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 0961030:
   FOR (curhipaacnt = 1 TO size(reply->qual,5))
     EXECUTE cclaudit evaluate(((size(reply->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->qual,5) - 1)+ 1),3,
       2)), "Query Orders", "PowerChart Office",
     "System Object", "List", "Patient",
     "Access / use", reply->qual[curhipaacnt].person_id, " "
   ENDFOR
  OF 0961040:
   EXECUTE cclaudit 0, "Query Orders", "PowerChart Office",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0961100:
   EXECUTE cclaudit 0, "Query Encounter", "PowerChart Office",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0963003:
   EXECUTE cclaudit 0, "Query Person", "Problem",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0963004:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Query Person", "Problem",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Query Person", "Problem",
   "Person", "Patient", "Patient",
   "Access / use", request->problem_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0963005:
   EXECUTE cclaudit 0, "Maintain Person", "Problem",
   "Person", "Patient", "Patient",
   "Origination/Amendment", request->person_id, " "
  OF 0963006:
   EXECUTE cclaudit 0, "Query Person", "Allergy",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0963015:
   EXECUTE cclaudit 0, "Query Person", "Problem",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0964515:
   EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0964520:
   EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
   "Person", "Patient", "Encounter",
   "Access / use", reply->notes[1].encounter_id, " "
  OF 0964521:
   EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
   "Person", "Patient", "Encounter",
   "Access / use", reply->notes[1].encounter_id, " "
  OF 0964535:
   EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
   "Person", "Patient", "Patient",
   "Access / use", request->notes[1].person_id, " "
  OF 0965215:
   FOR (curhipaacnt = 1 TO size(request->diagnosis,5))
     EXECUTE cclaudit evaluate(((size(request->diagnosis,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->diagnosis,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Diagnosis",
     "Encounter", "Patient", "Patient",
     "Origination", request->diagnosis[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 0965221:
   EXECUTE cclaudit 0, "Query Encounter", "Diagnosis",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0965230:
   EXECUTE cclaudit 0, "Maintain Encounter", "Diagnosis",
   "System Object", "List", "Patient",
   "Amendment", request->diagnosis[1].person_id, " "
  OF 0965235:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Output Encounter", "Superbill Report",
   "Person", "Patient", "Patient",
   "Report", request->person_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Output Encounter", "Superbill Report",
   "Person", "Patient", "Patient",
   "Report", request->encntr_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0965238:
   EXECUTE cclaudit 0, "Query Orders", "PowerChart Office",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0967205:
   FOR (curhipaacnt = 1 TO size(reply->person,5))
     EXECUTE cclaudit evaluate(((size(reply->person,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->person,5) - 1)+ 1),3,
       2)), "Query List", "Patient List",
     "System Object", "List", "Patient",
     "Access / use", reply->person[curhipaacnt].person_id, " "
   ENDFOR
  OF 0968305:
   EXECUTE cclaudit 0, "Output Report", "Summary Sheet",
   "Person", "Patient", "Patient",
   "Report", request->person_id, " "
  OF 0968350:
   EXECUTE cclaudit 0, "Output Report", "Inbox Patient List",
   "System Object", "Report", " ",
   "Report", 0.0, request->report_name
  OF 1030176:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Organization", "Location", "Location Code",
   "Access / use", 0.0, curprog
  OF 1030293:
   EXECUTE cclaudit 0, "Access Person", "Aliases",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 1030320:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1037502:
   EXECUTE cclaudit 0, "Access Encounter", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1037507:
   EXECUTE cclaudit 0, "Output Report", "ABN",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 1037508:
   EXECUTE cclaudit 0, "Access Encounter", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1037526:
   EXECUTE cclaudit 0, "Output Report", "Cancel List",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 1037532:
   EXECUTE cclaudit 0, "Access Person", "Guarantor",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1037536:
   EXECUTE cclaudit 0, "Access Person", "Insurance",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1037537:
   EXECUTE cclaudit 0, "Maintain Person", "Insurance",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1037541:
   EXECUTE cclaudit 0, "Output Report", "Requisition",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 1037548:
   EXECUTE cclaudit 0, "Output Report", "Daily Orders",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 1037550:
   EXECUTE cclaudit 0, "Output Report", "Packing List",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 1037576:
   EXECUTE cclaudit 0, "Olutput Report", "Requisition",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 1037584:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Provider",
   "Access / use", request->physician_id, " "
  OF 1037602:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", reply->personid, " "
  OF 1037608:
   EXECUTE cclaudit 0, "Output Report", "Daily Orders",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 1037620:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "Location Code",
   "Access / use", request->location_cd, " "
  OF 1037626:
   EXECUTE cclaudit 0, "Output Label", "Label",
   "System Object", "Report", " ",
   "Access / use", 0.0, curprog
  OF 1037697:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "Location Code",
   "Access / use", request->location_cd, " "
  OF 1037699:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "Location Code",
   "Access / use", request->location_cd, " "
  OF 1050000:
   EXECUTE cclaudit 0, "Access Order", "by Accession",
   "Person", "Patient", "Accession",
   "Access / use", request->accession, " "
  OF 1050060:
   EXECUTE cclaudit 0, "Access Person", "Addon Info",
   "Person", "Patient", "Accession",
   "Access / use", request->accession, " "
  OF 1052509:
   EXECUTE cclaudit 0, "Access List", "Queued Orders",
   "Person", "Patient", "Patient",
   "Access / use", reply->order_qual.person_id, " "
  OF 1065052:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1065056:
   EXECUTE cclaudit 0, "Access Person", "Patient Provider Relationship",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1065093:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1065099:
   EXECUTE cclaudit 0, "Access Person", "Person ABO/Rh",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1065100:
   EXECUTE cclaudit 0, "Access Person", "HLA Type",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 1065114:
   EXECUTE cclaudit 0, "Maintain Relationship", "Patient Provider Relationship",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 1065116:
   EXECUTE cclaudit 0, "Maintain Person", "Haplotype Chart",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1065119:
   EXECUTE cclaudit 0, "Maintain Person", "Patient Provider Relationship",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1065121:
   EXECUTE cclaudit 0, "Maintain Person", "Delete Person Relationship",
   "Person", "Patient", " ",
   "Destruction", 0.0, curprog
  OF 1065136:
   EXECUTE cclaudit 0, "Access Person", "HLA History",
   "Person", "Patient", "Haplotype Chart",
   "Access / use", request->haplotype_chart_id, " "
  OF 1065161:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 1065203:
   EXECUTE cclaudit 0, "Access Person", "HLA History",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1065222:
   EXECUTE cclaudit 0, "Maintain Result", "Add Result Info",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1065223:
   EXECUTE cclaudit 0, "Maintain Result", "Add Result Info",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1065224:
   EXECUTE cclaudit 0, "Maintain Person", "HLA Specificity",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
  OF 1065234:
   EXECUTE cclaudit 0, "Maintain Person", "Add Transplant Candidate",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1065237:
   EXECUTE cclaudit 0, "Access List", "Organ Donor",
   "Person", "List", "Patient",
   "Access / use", request->person_id, " "
  OF 1065238:
   EXECUTE cclaudit 0, "Maintain Person", "Organ Donor",
   "Person", "Patient", "Patient",
   "Amendment", request->person_id, " "
  OF 1065239:
   EXECUTE cclaudit 0, "Maintain Person", "Add Organ Donor",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1065282:
   EXECUTE cclaudit 0, "Maintain Person", "Add Patient Provider Relationship",
   "Person", "Patient", " ",
   "Origination", 0.0, curprog
  OF 1065283:
   EXECUTE cclaudit 0, "Maintain Person", "Maintain Person Relationship",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 1065284:
   EXECUTE cclaudit 0, "Access Person", "Patient Provider Relationship",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1065316:
   EXECUTE cclaudit 0, "Access Result", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1065320:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Lot Number",
   "Access / use", request->lot_number_id, " "
  OF 1065331:
   EXECUTE cclaudit 0, "Maintain Person", "Add Person HLA Type",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1065336:
   EXECUTE cclaudit 0, "View List", "Serum Matches",
   "Person", "List", "Patient",
   "Access / use", request->person_id, " "
  OF 1065337:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1065371:
   EXECUTE cclaudit 0, "Maintain Result", "Add Result Info",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 1065372:
   EXECUTE cclaudit 0, "Maintain Result", "Pathology",
   "Person", "Patient", " ",
   "Amendment", 0.0, curprog
  OF 1065382:
   EXECUTE cclaudit 0, "Access Person", "Person Haplotype",
   "Person", "Patient", "Haplotype Chart",
   "Access / use", request->haplotype_chart_id, " "
  OF 1065388:
   EXECUTE cclaudit 0, "Access Person", "Person Sera",
   "Person", "Patient", "Sera Query",
   "Access / use", request->sera_query_id, " "
  OF 1065391:
   EXECUTE cclaudit 0, "Maintain Person", "Add Sera Query",
   "Person", "Patient", " ",
   "Amendment", 0.0, "Opened tasks"
  OF 1065406:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", reply->donor_id, " "
  OF 1065410:
   EXECUTE cclaudit 0, "Access Result", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 1120008:
   EXECUTE cclaudit 0, "Query Encounter", "ProFile",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 1120009:
   FOR (curhipaacnt = 1 TO size(request->encntr_qual,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->encntr_qual,5) - 1)+ 1),3,
       2)), "Query Encounter", "ProFile",
     "Encounter", "Patient", "Encounter",
     "Access / use", request->encntr_qual[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 1120070:
   FOR (curhipaacnt = 1 TO size(request->encntr_qual,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->encntr_qual,5) - 1)+ 1),3,
       2)), "Query Encounter", "ProFile",
     "Encounter", "Patient", "Encounter",
     "Access / use", request->encntr_qual[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 1120075:
   FOR (curhipaacnt = 1 TO size(reply->qual,5))
     EXECUTE cclaudit evaluate(((size(reply->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->qual,5) - 1)+ 1),3,
       2)), "Query List", "Media List",
     "System Object", "Location", "Patient",
     "Access / use", reply->qual[curhipaacnt].person_id, " "
   ENDFOR
  OF 1120095:
   EXECUTE cclaudit 0, "Query Encounter", "ProFile",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 1120113:
   FOR (curhipaacnt = 1 TO size(reply->encntr_qual,5))
     EXECUTE cclaudit evaluate(((size(reply->encntr_qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(reply->encntr_qual,5) - 1)+ 1),3,
       2)), "Query Encounter", "Tracking ID",
     "Encounter", "Patient", "Encounter",
     "Access / use", reply->encntr_qual[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 1120114:
   FOR (curhipaacnt = 1 TO size(reply->encntr_qual,5))
     EXECUTE cclaudit evaluate(((size(reply->encntr_qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(reply->encntr_qual,5) - 1)+ 1),3,
       2)), "Query Encounter", "Tracking ID",
     "Encounter", "Patient", "Encounter",
     "Access / use", reply->encntr_qual[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 1120121:
   FOR (curhipaacnt = 1 TO size(reply->encntr_list,5))
     EXECUTE cclaudit evaluate(((size(reply->encntr_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(reply->encntr_list,5) - 1)+ 1),3,
       2)), "Query Encounter", "Person-Provider Relationship",
     "Encounter", "Doctor", "Provider",
     "Access / use", reply->encntr_list[curhipaacnt].physician_id, " "
   ENDFOR
  OF 1120156:
   FOR (curhipaacnt = 1 TO size(reply->encntr_qual,5))
     EXECUTE cclaudit evaluate(((size(reply->encntr_qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(reply->encntr_qual,5) - 1)+ 1),3,
       2)), "Query Encounter", "ProFile",
     "Encounter", "Patient", "Encounter",
     "Access / use", reply->encntr_qual[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 1135004:
   EXECUTE cclaudit 0, "Modify Person", "Person-Provider Relationship",
   " ", " ", "Encounter",
   " ", request->encntr_id, " "
  OF 1180008:
   EXECUTE cclaudit 0, "Run Report", "Backup Physician Deficiency List",
   "System Object", "Report", " ",
   "Report", 0.0, "Deficiency backup list"
  OF 1180009:
   EXECUTE cclaudit 0, "Run Report", "Incomplete Chart Detail",
   "System Object", "Report", " ",
   "Report", 0.0, "Loaned chart report"
  OF 1180012:
   EXECUTE cclaudit 0, "Run Report", "Physician Hold Detail",
   "System Object", "Report", " ",
   "Report", 0.0, "Complete chart audit"
  OF 1180013:
   EXECUTE cclaudit 0, "Run Report", "Chart Hold Detail",
   "System Object", "Report", " ",
   "Report", 0.0, "Charts not coded"
  OF 1180017:
   EXECUTE cclaudit 0, "Run Report", "Physician Letters",
   "System Object", "Report", " ",
   "Report", 0.0, "ROI pull list"
  OF 1180031:
   EXECUTE cclaudit 0, "Run Report", "Chart Location",
   "System Object", "Report", " ",
   "Report", 0.0, "Task Productivity"
  OF 1180035:
   EXECUTE cclaudit 0, "Run Report", "Deliquent Rates",
   "System Object", "Report", " ",
   "Report", 0.0, "Physician letters"
  OF 1180040:
   EXECUTE cclaudit 0, "Run Report", "Loaned Charts",
   "System Object", "Report", " ",
   "Report", 0.0, "Group pull list"
  OF 1180041:
   EXECUTE cclaudit 0, "Run Report", "All Deficiencies for All Physicians",
   "System Object", "Report", " ",
   "Report", 0.0, "Incomplete charts"
  OF 1180042:
   EXECUTE cclaudit 0, "Run Report", "Pull List for Specific Group",
   "System Object", "Report", " ",
   "Report", 0.0, "Charts by location"
  OF 1180043:
   EXECUTE cclaudit 0, "Run Report", "Loaned Charts Summary",
   "System Object", "Report", " ",
   "Report", 0.0, "Loaned chart report (summary)"
  OF 1180044:
   EXECUTE cclaudit 0, "Run Report", "Task Productivity",
   "System Object", "Report", " ",
   "Report", 0.0, "Coding summary"
  OF 1180056:
   EXECUTE cclaudit 0, "Run Report", "ROI Pull List",
   "System Object", "Report", " ",
   "Report", 0.0, "Supplemental documents"
  OF 1180057:
   EXECUTE cclaudit 0, "Run Report", "Patients Created by Transcription Interface",
   "System Object", "Report", " ",
   "Report", 0.0, "Physician document letters"
  OF 1180058:
   EXECUTE cclaudit 0, "Run Report", "Completed Charts",
   "System Object", "Report", " ",
   "Report", 0.0, "Charts not abstracted"
  OF 1180060:
   EXECUTE cclaudit 0, "Run Report", "Supplemental Documents by Department",
   "System Object", "Report", " ",
   "Report", 0.0, "Group pull list for print preview"
  OF 1180062:
   EXECUTE cclaudit 0, "Run Report", "Preview Pull List",
   "System Object", "Report", " ",
   "Report", 0.0, "Delinquency report"
  OF 1180066:
   EXECUTE cclaudit 0, "Output Report", "Coding Summary",
   "System Object", "Report", " ",
   "Report", 0.0, " "
  OF 1180067:
   EXECUTE cclaudit 0, "Run Report", "Physician Doc Letters",
   "System Object", "Report", " ",
   "Report", 0.0, "Patients created via transcription interface"
  OF 1180070:
   EXECUTE cclaudit 0, "Run Report", "Unauthenticated Documents",
   "System Object", "Report", " ",
   "Report", 0.0, "Unauthicated document report"
  OF 1185020:
   EXECUTE cclaudit 0, "Run Report", "Refused to Sign:  Ops",
   "System Object", "Report", " ",
   "Report", 0.0, "Complete dictate report"
  OF 1185023:
   EXECUTE cclaudit 0, "Run Report", "In Error",
   "System Object", "Report", " ",
   "Report", 0.0, "Detailed deficiency backup list"
  OF 1185024:
   EXECUTE cclaudit 0, "Run Report", "Completed Dictations:  Ops",
   "System Object", "Report", " ",
   "Report", 0.0, "Refuse to sign report"
  OF 1185025:
   EXECUTE cclaudit 0, "Run Report", "Opened Tasks:  Ops",
   "System Object", "Report", " ",
   "Report", 0.0, "Inerror report"
  OF 1300000:
   EXECUTE cclaudit 0, "Maintain Distributions", "Maintain Distribution",
   "System Object", "Qualification Criteria", "Distribution",
   "Origination", reply->distribution_id, " "
  OF 1300002:
   EXECUTE cclaudit 0, "Maintain Distributions", "Maintain Distribution",
   "System Object", "Qualification Criteria", "Distribution",
   "Amendment", request->distribution_id, " "
  OF 1300003:
   EXECUTE cclaudit 0, "Maintain Distributions", "Maintain Distribution",
   "System Object", "Qualification Criteria", "Distribution",
   "Amendment", request->chart_distribution[1].distribution_id, " "
  OF 1300070:
   EXECUTE cclaudit 0, "Maintain Distributions", "Maintain Cross-Encounter Law",
   "System Object", "Qualification Criteria", "Chart Law",
   "Origination", reply->law_id, " "
  OF 1300071:
   EXECUTE cclaudit 0, "Maintain Distributions", "Maintain Cross-Encounter Law",
   "System Object", "Qualification Criteria", "Chart Law",
   "Amendment", request->chart_law[1].law_id, " "
  OF 1300072:
   EXECUTE cclaudit 0, "Maintain Distributions", "Maintain Cross-Encounter Law",
   "System Object", "Qualification Criteria", "Chart Law",
   "Amendment", request->law_id, " "
  OF 1300102:
   EXECUTE cclaudit 0, "Maintain Distributions", "Maintain Operation",
   "System Object", "Routing Criteria", "Chart Operations",
   "Amendment", request->charting_operations_id, " "
  OF 1300104:
   FOR (curhipaacnt = 1 TO size(reply->qual,5))
     EXECUTE cclaudit evaluate(((size(reply->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->qual,5) - 1)+ 1),3,
       2)), "Maintain Distributions", "Maintain Operation",
     "System Object", "Routing Criteria", "Chart Operations",
     "Amendment", reply->qual[curhipaacnt].op_number, " "
   ENDFOR
  OF 1320000:
   FOR (curhipaacnt = 1 TO size(reply->qual,5))
     EXECUTE cclaudit evaluate(((size(reply->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->qual,5) - 1)+ 1),3,
       2)), "Submit Chart", "Ad Hoc",
     "System Object", "Report", "Chart Report",
     "Origination", reply->qual[curhipaacnt].chart_request_id, " "
   ENDFOR
  OF 1320100:
   EXECUTE cclaudit 0, "Maintain Chart Formats", "Format",
   "System Object", "Master file", "Chart Format",
   "Amendment", request->chart_format_id, " "
  OF 1330002:
   EXECUTE cclaudit 0, "Complete  Chart", "Spooling Complete",
   "System Object", "Report", " ",
   "Report", 0.0, " "
  OF 1335010:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Submit Chart", "Resubmit",
     "System Object", "Report", "Chart Report",
     "Amendment", request->qual[curhipaacnt].chart_request_id, " "
   ENDFOR
  OF 1349520:
   EXECUTE cclaudit 0, "Maintain Chart Formats", "Format",
   "System Object", "Master file", "Chart Format",
   "Origination", reply->chart_format_id, " "
  OF 1349530:
   EXECUTE cclaudit 0, "Maintain Chart Formats", "Format",
   "System Object", "Master file", "Chart Format",
   "Amendment", request->chart_format_id, " "
  OF 1349540:
   EXECUTE cclaudit 0, "Maintain Chart Formats", "Format",
   "System Object", "Master file", "Chart Format",
   "Amendment", request->chart_format_id, " "
  OF 1349550:
   EXECUTE cclaudit 0, "Complete  Chart", "Processing Complete",
   "System Object", "Report", "Chart Report",
   "Report", request->chart_request_id, " "
  OF 1349701:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain MRP Build", "MRP Build",
   "System Object", "Security Granularity Definition", "Organization",
   "Orgination/Amendment", 0.0, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain MRP Build", "MRP Build",
   "System Object", "Security Granularity Definition", "Chart Format",
   "Orgination/Amendment", 0.0, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 1349702:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain MRP Build", "MRP Build",
   "System Object", "Security Granularity Definition", "Chart Section",
   "Orgination/Amendment", 0.0, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain MRP Build", "MRP Build",
   "System Object", "Security Granularity Definition", "Position Code",
   "Orgination/Amendment", 0.0, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 1349703:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain MRP Build", "MRP Build",
   "System Object", "Security Granularity Definition", "Chart Section",
   "Orgination/Amendment", 0.0, " "
   FOR (curhipaacnt = 1 TO size(request->qual,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Maintain MRP Build", "MRP Build",
    "System Object", "Security Granularity Definition", "Chart Format",
    "Orginiation/Amendment", request->qual[curhipaacnt].chart_format_id, " "
   ENDFOR
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 4250271:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Run Patient List", "Tracking Group",
   "Person List", "Patient", "List",
   "Access / use", request->column_view_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Run Patient List", "Tracking Group",
   "Person List", "Patient", "Tracking Group Code",
   "Access / use", request->tracking_group_cd, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 4250282:
   EXECUTE cclaudit 0, "Maintain Encounter", "Tracking Item",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 4250285:
   EXECUTE cclaudit 0, "Maintain Encounter", "Tracking Item",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->encntr_id, " "
  OF 4250295:
   EXECUTE cclaudit 0, "Run Patient List", "Provider Assignment",
   "Person", "Provider", "Provider",
   "Access / use", request->provider_id, " "
  OF 4250297:
   EXECUTE cclaudit 0, "Maintain Patient Assignments", "Tracking",
   "Tracking Item", "Patient", "Tracking Item",
   "Update", request->tracking_id, " "
  OF 4250298:
   EXECUTE cclaudit 0, "Query Encounter", "Acuity/Reason for Visit",
   "Tracking Item", "Patient", "Tracking Item",
   "Query", request->tracking_id, " "
  OF 4250302:
   EXECUTE cclaudit 0, "Maintain Encounter", "Tracking Item",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->encntr_id, " "
  OF 4250307:
   EXECUTE cclaudit 0, "Maintain Encounter", "Check Patient Out of Tracking",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->encntr_id, " "
  OF 4250312:
   EXECUTE cclaudit 0, "Run Patient List", "Tracking Group",
   "Person List", "List", "Tracking Group Code",
   "Access / use", request->tracking_group_cd, " "
  OF 4250316:
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "Person", "Patient", "Tracking Item",
   "Access / use", request->tracking_id, " "
  OF 4250326:
   EXECUTE cclaudit 0, "Run Patient List", "Tracking List",
   "Person List", "List", "Tracking Group Code",
   "Access / use", request->tracking_group_cd, " "
  OF 4250353:
   EXECUTE cclaudit 0, "Maintain Patient Provider Assignment", "Tracking",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->encntr_id, " "
  OF 4250370:
   EXECUTE cclaudit 0, "Query Encounter Data", "Arrival Information",
   "Encounter", "Patient", "Tracking Item",
   "Access / use", request->tracking_id, " "
  OF 4250373:
   EXECUTE cclaudit 0, "Run Patient List", "Tracking List",
   "Person List", "List", "Tracking Group Code",
   "Access / use", request->tracking_group_cd, " "
  OF 4250381:
   EXECUTE cclaudit 0, "Query Orders", "Emergency",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encounter_id, " "
  OF 4250382:
   EXECUTE cclaudit 0, "Review Results", "Retrieve",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 4250387:
   EXECUTE cclaudit 0, "Query Orders", "Tracking",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->tracking_event_id, " "
  OF 4250388:
   EXECUTE cclaudit 0, "Maintain Tracking Orders", "Tracking",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->tracking_event_id, " "
  OF 4250389:
   EXECUTE cclaudit 0, "Maintain Tracking Orders", "Tracking",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->encntr_id, " "
  OF 4250452:
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->patient[1].encntr_id, " "
  OF 4250601:
   EXECUTE cclaudit 0, "Maintain Encounter", "Depart Patient",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 4250603:
   EXECUTE cclaudit 0, "Maintain Encounter", "Depart Patient",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 4250645:
   EXECUTE cclaudit 0, "Maintain Encounter", "Patient Location",
   "Encounter", "Patient", "Encounter",
   "Access / use", reply->encntr_id, " "
  OF 4250646:
   EXECUTE cclaudit 0, "Maintain Encounter", "Patient Location",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->tracking_id, " "
  OF 4250755:
   EXECUTE cclaudit 0, "Maintain Encounter", "Discharge Instructions",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 4250758:
   EXECUTE cclaudit 0, "Maintain Encounter", "Discharge Instructions",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 4250759:
   EXECUTE cclaudit 0, "Maintain Encounter", "Discharge Instructions",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 4250767:
   EXECUTE cclaudit 0, "Maintain Encounter", "Reactivate Patient Tracking",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->encntr_id, " "
  OF 4250777:
   EXECUTE cclaudit 0, "Maintain Encounter", "Discharge Instructions",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
 ENDCASE
END GO
