CREATE PROGRAM cclauditdispatch:dba
 CASE ( $1)
  OF "CE_AUDIT_QUERY_RESULTS":
   FOR (curhipaacnt = 1 TO size(request->person_id_list,5))
     EXECUTE cclaudit evaluate(((size(request->person_id_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,
       1,((size(request->person_id_list,5) - 1)+ 1),3,
       2)), "Query Clinical Events", "Results",
     "Person", "Patient", "Patient",
     "Access / use", request->person_id_list[curhipaacnt].person_id, " "
   ENDFOR
  OF "CE_AUDIT_QUERY_WORKFLOW":
   FOR (curhipaacnt = 1 TO size(request->person_id_list,5))
     EXECUTE cclaudit evaluate(((size(request->person_id_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,
       1,((size(request->person_id_list,5) - 1)+ 1),3,
       2)), "Query Clinical Events", "Workflow",
     "Person", "Patient", "Patient",
     "Access / use", request->person_id_list[curhipaacnt].person_id, " "
   ENDFOR
  OF "CE_AUDIT_WRITE_RESULTS":
   FOR (curhipaacnt = 1 TO size(request->person_id_list,5))
     EXECUTE cclaudit evaluate(((size(request->person_id_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,
       1,((size(request->person_id_list,5) - 1)+ 1),3,
       2)), "Maintain Clinical Events", "Write/Update Results",
     "Person", "Patient", "Patient",
     "Origination / Amendment", request->person_id_list[curhipaacnt].person_id, " "
   ENDFOR
  OF "CE_AUDIT_WRITE_WORKFLOW":
   FOR (curhipaacnt = 1 TO size(request->person_id_list,5))
     EXECUTE cclaudit evaluate(((size(request->person_id_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,
       1,((size(request->person_id_list,5) - 1)+ 1),3,
       2)), "Maintain Clinical Events", "Write/Update Workflow",
     "Person", "Patient", "Patient",
     "Origination / Amendment", request->person_id_list[curhipaacnt].person_id, " "
   ENDFOR
  OF "DCP_ADD_ASSIGNMENT":
   FOR (curhipaacnt = 1 TO size(request->assign_list,5))
     EXECUTE cclaudit evaluate(((size(request->assign_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->assign_list,5) - 1)+ 1),3,
       2)), "Maintain Tasks", "Assignements",
     "System Object", "Task", "Task",
     "Origination/Amendment", request->assign_list[curhipaacnt].task_id, " "
   ENDFOR
  OF "DCP_CHG_TASK":
   FOR (curhipaacnt = 1 TO size(request->mod_list,5))
     EXECUTE cclaudit evaluate(((size(request->mod_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->mod_list,5) - 1)+ 1),3,
       2)), "Maintain Tasks", "Tasks",
     "System Object", "Task", "Task",
     "Origination/Amendment", request->mod_list[curhipaacnt].task_id, " "
   ENDFOR
  OF "DCP_DEL_ALL_ASSIGNMENTS":
   FOR (curhipaacnt = 1 TO size(request->task_list,5))
     EXECUTE cclaudit evaluate(((size(request->task_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->task_list,5) - 1)+ 1),3,
       2)), "Maintain Tasks", "Assignements",
     "System Object", "Task", "Task",
     "Origination/Amendment", request->task_list[curhipaacnt].task_id, " "
   ENDFOR
  OF "DCP_DEL_ASSIGNMENT":
   FOR (curhipaacnt = 1 TO size(request->assign_list,5))
     EXECUTE cclaudit evaluate(((size(request->assign_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->assign_list,5) - 1)+ 1),3,
       2)), "Maintain Tasks", "Assignements",
     "System Object", "Task", "Task",
     "Origination/Amendment", request->assign_list[curhipaacnt].task_id, " "
   ENDFOR
  OF "DCP_DEL_TASKS":
   FOR (curhipaacnt = 1 TO size(request->assign_list,5))
     EXECUTE cclaudit evaluate(((size(request->assign_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->assign_list,5) - 1)+ 1),3,
       2)), "Maintain Tasks", "Tasks",
     "System Object", "Task", "Task",
     "Origination/Amendment", request->assign_list[curhipaacnt].task_id, " "
   ENDFOR
  OF "DCP_P_ADD_TASK":
   EXECUTE cclaudit 0, "Maintain Tasks", "Tasks",
   "System Object", "Task", "Encounter",
   "Origination/Amendment", request->encntr_id, " "
  OF "ORD_SRV_ADD_ALL":
   EXECUTE cclaudit 0, "Maintain Order", "Add",
   "System Object", "Order", "Order",
   "Origination/Amendment", request->order_id, " "
  OF "ORD_SRV_CHG_REVIEW":
   EXECUTE cclaudit 0, "Maintain Order", "Review",
   "Order", "request->order_id", "Order",
   " ", request->order_id, " "
  OF "ORD_SRV_CHG_RX_REVIEW":
   EXECUTE cclaudit 0, "Maintain Order", "Review",
   "System Object", "Order", "Order",
   "Origination/Amendment", request->order_id, " "
  OF "ORD_SRV_DEMOG_CHG":
   EXECUTE cclaudit 0, "Maintain Order", "Demographics",
   "System Object", "Order", "Order",
   "Origination/Amendment", request->order_id, " "
  OF "ORD_SRV_UPD_ORDER":
   EXECUTE cclaudit 0, "Maintain Order", "Tasks",
   "System Object", "Order", "Order",
   "Origination/Amendment", request->order_id, " "
  OF "PCS_ADD_PROP_ORDERS":
   EXECUTE cclaudit 0, "Maintain Person", "Create Order (PROP)",
   "Person", "Patient", " ",
   "Origination", 0.0, curprog
  OF "PM_ENS_AUTH_INFO":
   SET cclaud->hipaamode = 0
   FOR (curhipaacnt = 1 TO size(request->auth_info,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Auth",
    "Person", "Patient", "ENCOUNTER",
    "Orginiation/Amendment", request->auth_info[curhipaacnt].encntr_id, " "
   ENDFOR
   FOR (curhipaacnt = 1 TO size(request->auth_info,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Maintain Person", "Auth",
    "Person", "Patient", "Patient",
    "Orginiation/Amendment", request->auth_info[curhipaacnt].person_id, " "
   ENDFOR
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF "PM_ENS_DIAGNOSIS":
   SET cclaud->hipaamode = 0
   FOR (curhipaacnt = 1 TO size(request->diagnosis,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Diagnosis",
    "Person", "Patient", "ENCOUNTER",
    "Orginiation/Amendment", request->diagnosis[curhipaacnt].encntr_id, " "
   ENDFOR
   FOR (curhipaacnt = 1 TO size(request->diagnosis,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Maintain Person", "Diagnosis",
    "Person", "Patient", "Patient",
    "Orginiation/Amendment", request->diagnosis[curhipaacnt].person_id, " "
   ENDFOR
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF "PM_ENS_ENCNTR_ACCIDENT":
   FOR (curhipaacnt = 1 TO size(request->encntr_accident,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_accident,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,
       1,((size(request->encntr_accident,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Accident",
     "Person", "Patient", "ENCOUNTER",
     "Orginiation/Amendment", request->encntr_accident[curhipaacnt].encntr_id, " "
   ENDFOR
  OF "PM_ENS_ENCNTR_ALIAS":
   FOR (curhipaacnt = 1 TO size(request->encntr_alias,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_alias,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,
       ((size(request->encntr_alias,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Aliases",
     "Person", "Patient", "ENCOUNTER",
     "Orginiation/Amendment", request->encntr_alias[curhipaacnt].encntr_id, " "
   ENDFOR
  OF "PM_ENS_ENCNTR_INFO":
   FOR (curhipaacnt = 1 TO size(request->encntr_info,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_info,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->encntr_info,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Ensure",
     "Person", "Patient", "ENCOUNTER",
     "Orginiation/Amendment", request->encntr_info[curhipaacnt].encntr_id, " "
   ENDFOR
  OF "PM_ENS_ENCNTR_ORG_RELTN_REG":
   FOR (curhipaacnt = 1 TO size(request->encntr_org_reltn,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_org_reltn,5) - 1)+ 1),1,0,evaluate(curhipaacnt,
       1,1,((size(request->encntr_org_reltn,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Org Relation",
     "Person", "Patient", "ENCOUNTER",
     "Orginiation/Amendment", request->encntr_org_reltn[curhipaacnt].encntr_id, " "
   ENDFOR
  OF "PM_ENS_ENCNTR_PENDING":
   EXECUTE cclaudit 0, "Maintain Encounter", "Ensure",
   "Person", "Patient", "ENCOUNTER",
   "Orginiation/Amendment", request->encntr_id, " "
  OF "PM_ENS_ENCNTR_PLAN_RELTN_REG":
   FOR (curhipaacnt = 1 TO size(request->encntr_plan_reltn,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_plan_reltn,5) - 1)+ 1),1,0,evaluate(curhipaacnt,
       1,1,((size(request->encntr_plan_reltn,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Plan Relationship",
     "Person", "Patient", "ENCOUNTER",
     "Orginiation/Amendment", request->encntr_plan_reltn[curhipaacnt].encntr_id, " "
   ENDFOR
  OF "PM_ENS_ENCNTR_PRSNL_RELTN":
   FOR (curhipaacnt = 1 TO size(request->encntr_prsnl_reltn,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_prsnl_reltn,5) - 1)+ 1),1,0,evaluate(
       curhipaacnt,1,1,((size(request->encntr_prsnl_reltn,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Prsnl Relationship",
     "Person", "Patient", "ENCOUNTER",
     "Orginiation/Amendment", request->encntr_prsnl_reltn[curhipaacnt].encntr_id, " "
   ENDFOR
  OF "PM_ENS_ENCOUNTER":
   FOR (curhipaacnt = 1 TO size(reply->encounter,5))
     EXECUTE cclaudit evaluate(((size(reply->encounter,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(reply->encounter,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Ensure",
     "Person", "Patient", "ENCOUNTER",
     "Orginiation/Amendment", reply->encounter[curhipaacnt].encntr_id, " "
   ENDFOR
  OF "PM_ENS_PERSON.PRG":
   FOR (curhipaacnt = 1 TO size(reply->person,5))
     EXECUTE cclaudit evaluate(((size(reply->person,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->person,5) - 1)+ 1),3,
       2)), "Maintain Person", "Ensure",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", reply->person[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_ENS_PERSON_ALIAS":
   FOR (curhipaacnt = 1 TO size(request->person_alias,5))
     EXECUTE cclaudit evaluate(((size(request->person_alias,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,
       ((size(request->person_alias,5) - 1)+ 1),3,
       2)), "Maintain Person", "Aliases",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_alias[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_ENS_PERSON_INFO":
   FOR (curhipaacnt = 1 TO size(request->person_info,5))
     EXECUTE cclaudit evaluate(((size(request->person_info,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->person_info,5) - 1)+ 1),3,
       2)), "Maintain Person", "Ensure",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_info[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_ENS_PERSON_NAME":
   FOR (curhipaacnt = 1 TO size(request->person_name,5))
     EXECUTE cclaudit evaluate(((size(request->person_name,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->person_name,5) - 1)+ 1),3,
       2)), "Maintain Person", "Name",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_name[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_ENS_PERSON_ORG_RELTN_REG":
   FOR (curhipaacnt = 1 TO size(request->person_org_reltn,5))
     EXECUTE cclaudit evaluate(((size(request->person_org_reltn,5) - 1)+ 1),1,0,evaluate(curhipaacnt,
       1,1,((size(request->person_org_reltn,5) - 1)+ 1),3,
       2)), "Maintain Person", "Org Relation",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_org_reltn[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_ENS_PERSON_PATIENT":
   FOR (curhipaacnt = 1 TO size(request->person_patient,5))
     EXECUTE cclaudit evaluate(((size(request->person_patient,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,
       1,((size(request->person_patient,5) - 1)+ 1),3,
       2)), "Maintain Person", "Patient",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_patient[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_ENS_PERSON_PERSON_RELTN":
   FOR (curhipaacnt = 1 TO size(request->person_person_reltn,5))
     EXECUTE cclaudit evaluate(((size(request->person_person_reltn,5) - 1)+ 1),1,0,evaluate(
       curhipaacnt,1,1,((size(request->person_person_reltn,5) - 1)+ 1),3,
       2)), "Maintain Person", "Person Relationship",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_person_reltn[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_ENS_PERSON_PLAN_RELTN_REG":
   FOR (curhipaacnt = 1 TO size(request->person_plan_reltn,5))
     EXECUTE cclaudit evaluate(((size(request->person_plan_reltn,5) - 1)+ 1),1,0,evaluate(curhipaacnt,
       1,1,((size(request->person_plan_reltn,5) - 1)+ 1),3,
       2)), "Maintain Person", "Plan Relationship",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_plan_reltn[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_ENS_PERSON_PRSNL_RELTN":
   FOR (curhipaacnt = 1 TO size(request->person_prsnl_reltn,5))
     EXECUTE cclaudit evaluate(((size(request->person_prsnl_reltn,5) - 1)+ 1),1,0,evaluate(
       curhipaacnt,1,1,((size(request->person_prsnl_reltn,5) - 1)+ 1),3,
       2)), "Maintain Person", "Prsnl Relationship",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_prsnl_reltn[curhipaacnt].person_id, " "
   ENDFOR
  OF "PM_EPI_UPT_EPISODES":
   EXECUTE cclaudit 0, "Maintain Person", "Episodes",
   "Person", "Patient", "Patient",
   "Orginiation/Amendment", request->person_id, " "
  OF "PM_MHA":
   EXECUTE cclaudit 0, "Maintain Encounter", "MHA",
   "Person", "Patient", "ENCOUNTER",
   "Orginiation/Amendment", request->encntr_id, " "
  OF "RX_DISPENSE":
   FOR (curhipaacnt = 1 TO size(request->order_list,5))
     EXECUTE cclaudit evaluate(((size(request->order_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->order_list,5) - 1)+ 1),3,
       2)), "Maintain Order", "Medication",
     "System Object", "Order", "Order",
     "Origination/Amendment", request->order_list[curhipaacnt].order_id, " "
   ENDFOR
  OF "RX_RETAIL_DISPENSE":
   FOR (curhipaacnt = 1 TO size(request->order_list,5))
     EXECUTE cclaudit evaluate(((size(request->order_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->order_list,5) - 1)+ 1),3,
       2)), "Maintain Order", "Medication",
     "System Object", "Order", "Order",
     "Origination/Amendment", request->order_list[curhipaacnt].order_id, " "
   ENDFOR
 ENDCASE
END GO
