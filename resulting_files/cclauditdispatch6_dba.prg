CREATE PROGRAM cclauditdispatch6:dba
 CASE ( $1)
  OF 0600063:
   EXECUTE cclaudit 0, "Query Flowsheet", "Orders",
   "System Object", "List", "Patient",
   "Access / use", request->person_id, " "
  OF 0600064:
   EXECUTE cclaudit 0, "Query Flowsheet", "MAR",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600070:
   EXECUTE cclaudit 0, "Maintain Flowsheet", "Intake and Output",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600114:
   EXECUTE cclaudit 0, "Query Encounter", "Procedure History",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0600116:
   EXECUTE cclaudit 0, "Maintain Encounter", "Procedure History",
   "System Object", " ", "Encounter",
   "Amendment", request->encntr_id, " "
  OF 0600117:
   EXECUTE cclaudit 0, "Maintain Encounter", "Procedure History",
   "System Object", " ", "Encounter",
   "Origination", request->encntr_id, " "
  OF 0600118:
   EXECUTE cclaudit 0, "Output Report", "Incomplete Tasks",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0600119:
   EXECUTE cclaudit 0, "Output Report", "Overdue Tasks",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0600124:
   EXECUTE cclaudit 0, "Query List", "Patient",
   "System Object", "List", " ",
   "Access / use", 0.0, reply->name
  OF 0600301:
   EXECUTE cclaudit 0, "Query Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600310:
   EXECUTE cclaudit 0, "Query Encounter", "List",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600311:
   EXECUTE cclaudit 0, "Access Person", "Patient-Provider Relations",
   "Person", "User", "Provider",
   "Access / use", request->prsnl_person_id, " "
  OF 0600312:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Patient-Provider Relations",
   "System Object", "Security Granularity Definition", "Encntr Reltn",
   "Origination", reply->encntr_prsnl_reltn_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Person", "Patient-Provider Relations",
   "System Object", "Security Granularity Definition", "Person Reltn",
   "Origination", reply->person_prsnl_reltn_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0600313:
   SET cclaud->hipaamode = 0
   FOR (curhipaacnt = 1 TO size(request->encntr_qual,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Patient-Provider Relations",
    "System Object", "Security Granularity Definition", "Encntr Reltn",
    "Amendment", request->encntr_qual[curhipaacnt].encntr_prsnl_reltn_id, " "
   ENDFOR
   FOR (curhipaacnt = 1 TO size(request->person_qual,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Maintain Person", "Patient-Provider Relations",
    "System Object", "Security Granularity Definition", "Person Reltn",
    "Amendment", request->person_qual[curhipaacnt].person_prsnl_reltn_id, " "
   ENDFOR
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0600318:
   EXECUTE cclaudit 0, "Access List", "Provider Group",
   "Organization", "Resource", "Personnel Group",
   "Access / use", request->group_id, " "
  OF 0600319:
   EXECUTE cclaudit 0, "Maintain List", "Patient-Provider Relations",
   "Person", " ", "Patient",
   " ", 0.0, " "
  OF 0600321:
   EXECUTE cclaudit 0, "Access Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600322:
   EXECUTE cclaudit 0, "Access Person", "Demographics",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600324:
   EXECUTE cclaudit 0, "Access Person", "PPR Summary",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600325:
   EXECUTE cclaudit 0, "Access List", "Patient Encounters",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600343:
   EXECUTE cclaudit 0, "Access Encounter", "Visit Summary",
   "System Object", "Report", "Encounter",
   "Report", request->encntr_id, " "
  OF 0600347:
   EXECUTE cclaudit 0, "Run Report", "PowerChart",
   "System Object", "Report", " ",
   "Report", 0.0, request->script_name
  OF 0600349:
   EXECUTE cclaudit 0, "Run Report", "PowerChart",
   "System Object", "Report", " ",
   "Report", 0.0, request->script_name
  OF 0600353:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Structured Clinical Documents",
   "Person", "Patient", "Patient",
   "Access / use", request->encntr_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Forms", "Structured Clinical Documents",
   "System Object", "Report", "DCP FORMS",
   "Amendment", reply->activity_form_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0600354:
   EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
   "Person", "Patient", "DCP FORMS",
   "Access / use", request->form_activity_id, " "
  OF 0600355:
   EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
   "Person", "Patient", "DCP FORMS",
   "Access / use", request->dcp_forms_activity_id, " "
  OF 0600363:
   EXECUTE cclaudit 0, "Access List", "Patient-Provider Relations",
   "Person", "User", "Provider",
   "Access / use", request->prsnl_id, " "
  OF 0600366:
   EXECUTE cclaudit 0, "Access List", "Location",
   "System Object", "Location", "Location Code",
   "Access / use", request->unit_cd, " "
  OF 0600369:
   EXECUTE cclaudit 0, "Access List", "Patient-Provider Relations",
   "Organization", "Resource", "Personnel Group",
   "Access / use", request->group_id, " "
  OF 0600370:
   EXECUTE cclaudit 0, "Access List", "Patient-Provider Relations",
   "Person", "User", "Provider",
   "Access / use", request->prsnl_id, " "
  OF 0600389:
   EXECUTE cclaudit 0, "Maintain Encounter", "Structured Clinical Documents",
   "Person", "Patient", "DCP FORMS",
   "Access / use", request->dcp_forms_activity_id, " "
  OF 0600394:
   EXECUTE cclaudit 0, "View Encounter", "Get Best Encounter",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600409:
   EXECUTE cclaudit 0, "Maintain Encounter", "Temp. Location",
   "Person", "Patient", "Patient",
   "Amendment", request->encntr_id, " "
  OF 0600422:
   EXECUTE cclaudit 0, "Query Orders", "Intake and Output",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0600545:
   FOR (curhipaacnt = 1 TO size(request->persons,5))
     EXECUTE cclaudit evaluate(((size(request->persons,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->persons,5) - 1)+ 1),3,
       2)), "Query Patient Information Panel", "Patient-Provider Relations",
     "System Object", "Patient", "Patient",
     "Access / use", request->persons[curhipaacnt].person_id, " "
   ENDFOR
  OF 0600553:
   EXECUTE cclaudit 0, "Query Patient Information Panel", "Assigned Personnel",
   "Person", "Patient", "Patient",
   "Access / use", request->patient_id, " "
  OF 0600571:
   EXECUTE cclaudit 0, "Query List", "Provider Assignment",
   "Person", "User", "Patient",
   "Access / use", request->prsnl_id, " "
  OF 0600576:
   EXECUTE cclaudit 0, "Query List", "Provider Assignment",
   "Person", "User", "Patient",
   "Access / use", request->prsnl_id, " "
  OF 0600580:
   FOR (curhipaacnt = 1 TO size(request->person_list,5))
     EXECUTE cclaudit evaluate(((size(request->person_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->person_list,5) - 1)+ 1),3,
       2)), "Query List", "Continuous Med. Orders",
     "System Object", "Patient", "Patient",
     "Access / use", request->person_list[curhipaacnt].person_id, " "
   ENDFOR
  OF 0600633:
   FOR (curhipaacnt = 1 TO size(request->persons,5))
     EXECUTE cclaudit evaluate(((size(request->persons,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->persons,5) - 1)+ 1),3,
       2)), "Query Patient Information Panel", "Demographics",
     "System Object", "Patient", "Patient",
     "Access / use", request->persons[curhipaacnt].person_id, " "
   ENDFOR
  OF 0600807:
   EXECUTE cclaudit 0, "Maintain Flowsheet", "Intake and Output",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
  OF 0600851:
   EXECUTE cclaudit 0, "Query List", "Shift Assignments",
   "System Object", "Location", "Location Code",
   "Access / use", 0.0, " "
  OF 0600854:
   EXECUTE cclaudit 0, "Maintain User", "Patient Assignments",
   "Person", "User", "Patient",
   "Amendment", request->prsnl_id, " "
  OF 0600856:
   FOR (curhipaacnt = 1 TO size(request->location_list,5))
     EXECUTE cclaudit evaluate(((size(request->location_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,
       ((size(request->location_list,5) - 1)+ 1),3,
       2)), "Query List", "Shift Assignments",
     "System Object", "Patient", "Patient",
     "Access / use", request->location_list[curhipaacnt].person_id, " "
   ENDFOR
  OF 0600860:
   EXECUTE cclaudit 0, "Query Person", "Provider Assignment",
   "Person", "Patient", "Patient",
   "Access / use", request->patient_id, " "
  OF 0601100:
   EXECUTE cclaudit 0, "Query Person", "Pathways",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
 ENDCASE
END GO
