CREATE PROGRAM cclauditdispatch1:dba
 CASE ( $1)
  OF 0100040:
   EXECUTE cclaudit 0, "Person Search", "Search",
   "Person List", "List", " ",
   "Report", 0.0, reply->filter_str
  OF 0100041:
   EXECUTE cclaudit 0, "Encounter Search", "Search",
   "Encounter List", "List", " ",
   "Report", 0.0, reply->filter_str
  OF 0100042:
   EXECUTE cclaudit 0, "Person Search", "Query Details",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0100043:
   EXECUTE cclaudit 0, "Encounter Search", "Query Details",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0100052:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", " ",
   "Origination/Amendment", 0.0, curprog
  OF 0100080:
   EXECUTE cclaudit 0, "Query Person Lock", "Retrieve",
   "System Object", "List", "Patient",
   "Report", request->person_id, " "
  OF 0100082:
   FOR (curhipaacnt = 1 TO size(request->person,5))
     EXECUTE cclaudit evaluate(((size(request->person,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size
       (request->person,5) - 1)+ 1),3,
       2)), "Maintain Person Lock", "Lock",
     "System Object", "Master file", "Patient",
     "Amendment", request->person[curhipaacnt].person_id, " "
   ENDFOR
  OF 0100102:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Run Combine", "Combine",
   "Person", "Patient", "Patient",
   "Aggregation, summarization, derivation", request->xxx_combine[1].from_xxx_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Run Combine", "Combine",
   "Person", "Patient", "Patient",
   "Aggregation, summarization, derivation", request->xxx_combine[1].to_xxx_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Run Combine", "Combine",
   "System Object", "Resource", " ",
   "Origination/Amendment", 0.0, request->parent_table
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0100103:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Reference Data", "Maintain Organizations",
   "System Object", "Resource", " ",
   "Origination/Amendment", 0.0, " "
   FOR (curhipaacnt = 1 TO size(request->xxx_uncombine,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Run Uncombine", "Uncombine",
    "Person", "Patient", "Patient",
    "Amendment", request->xxx_uncombine[curhipaacnt].xxx_combine_id, " "
   ENDFOR
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0100107:
   EXECUTE cclaudit 0, "View Encounter", "Open Chart",
   "Person", "Patient", "Patient",
   "Verification", request->person_id, " "
  OF 0100122:
   EXECUTE cclaudit 0, "Maintain System Resource", "Alias Pool",
   "System Object", "Master file", "Alias Pool Code",
   "Amendment", reply->alias_pool_cd, " "
  OF 0100123:
   EXECUTE cclaudit 0, "Maintain System Resource", "Alias Pool",
   "System Object", "Master file", "Alias Pool Code",
   "Amendment", reply->alias_pool_cd, " "
  OF 0100130:
   EXECUTE cclaudit 0, "Query Patient List", "Encounters",
   "Encounter List", "List", "Encounter",
   "Report", 0.0, request->name
  OF 0100150:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Episode", "Update",
   "Encounter", "Patient", "Encounter",
   "Origination", request->person_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Person", "Episodes",
   "Person", "Patient", "Patient",
   "Orginiation/Amendment", request->person_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0100151:
   EXECUTE cclaudit 0, "Query Episode", "Retrieve",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->person_id, " "
  OF 0100161:
   EXECUTE cclaudit 0, "Query Patient List", "Location Census",
   "Location Query", "Location", "Location Code",
   "Report", request->nurse_unit_cd, " "
  OF 0100162:
   SET cclaud->hipaamode = 0
   FOR (curhipaacnt = 1 TO size(request->ids,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Query Encounter", "Information",
    "Encounter", "Patient", "Encounter",
    "Access / use", request->ids[curhipaacnt].encntr_id, " "
   ENDFOR
   FOR (curhipaacnt = 1 TO size(request->ids,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Query Person", "Information",
    "Person", "Patient", "Patient",
    "Access / use", request->ids[curhipaacnt].person_id, " "
   ENDFOR
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0100176:
   EXECUTE cclaudit 0, "Query Encounter", "Location History",
   "Location Query", "Location", " ",
   "Report", 0.0, curprog
  OF 0100177:
   EXECUTE cclaudit 0, "Query Encounter", "Pending History",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0100300:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Encntr Prsnl Reltn", "Transfer",
   "Encounter", "Doctor", "Provider",
   "Amendment", request->pm_transfer_encntr_reltn[1].prsnl_person_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Encntr Prsnl Reltn", "Transfer",
   "Encounter", "Doctor", "Provider",
   "Amendment", request->pm_transfer_encntr_reltn[1].transfer_prsnl_person_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0101101:
   FOR (curhipaacnt = 1 TO size(reply->person,5))
     EXECUTE cclaudit evaluate(((size(reply->person,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->person,5) - 1)+ 1),3,
       2)), "Maintain Person", "Ensure",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", reply->person[curhipaacnt].person_id, " "
   ENDFOR
  OF 0101102:
   FOR (curhipaacnt = 1 TO size(request->person_alias,5))
     EXECUTE cclaudit evaluate(((size(request->person_alias,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,
       ((size(request->person_alias,5) - 1)+ 1),3,
       2)), "Maintain Person", "Aliases",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_alias[curhipaacnt].person_id, " "
   ENDFOR
  OF 0101103:
   FOR (curhipaacnt = 1 TO size(request->person_name,5))
     EXECUTE cclaudit evaluate(((size(request->person_name,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->person_name,5) - 1)+ 1),3,
       2)), "Maintain Person", "Name",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_name[curhipaacnt].person_id, " "
   ENDFOR
  OF 0101130:
   EXECUTE cclaudit 0, "Output Report", "Preview",
   "System Object", "Report", " ",
   "Report", 0.0, curprog
  OF 0101133:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Output Report", "Batch",
   "System Object", "Report", "Report Number",
   "Report", request->batch_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Output Report", "Batch",
   "System Object", "Report", "Report Number",
   "Report", request->report_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0101140:
   FOR (curhipaacnt = 1 TO size(request->person_patient,5))
     EXECUTE cclaudit evaluate(((size(request->person_patient,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,
       1,((size(request->person_patient,5) - 1)+ 1),3,
       2)), "Maintain Person", "Patient",
     "Person", "Patient", "Patient",
     "Orginiation/Amendment", request->person_patient[curhipaacnt].person_id, " "
   ENDFOR
  OF 0101143:
   EXECUTE cclaudit 0, "Run Report", "Patient",
   "System Object", "Report", "Report Number",
   "Report", request->report_id, " "
  OF 0101300:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Location History",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->encntr_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Query Encounter", "Location History",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0101311:
   EXECUTE cclaudit 0, "Maintain Encounter", "Ensure",
   "Person", "Patient", "ENCOUNTER",
   "Orginiation/Amendment", request->encntr_id, " "
  OF 0101312:
   EXECUTE cclaudit 0, "Query Person", "Retrieve",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0101411:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Organization Maintenance",
   "System Object", "Resource", "Organization",
   "Origination/Amendment", reply->organizations[1].organization_id, " "
  OF 0101706:
   EXECUTE cclaudit 0, "Maintain Person", "Allergy",
   "Person", "Patient", "Patient",
   "Origination/Amendment", request->allergy[1].person_id, " "
  OF 0102000:
   FOR (curhipaacnt = 1 TO size(request->doc_list,5))
     EXECUTE cclaudit evaluate(((size(request->doc_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->doc_list,5) - 1)+ 1),3,
       2)), "Maintain Provider", "Physician History",
     "Person", "Doctor", "Provider",
     "Amendment", request->doc_list[curhipaacnt].person_id, " "
   ENDFOR
  OF 0102011:
   FOR (curhipaacnt = 1 TO size(request->doc_list,5))
     EXECUTE cclaudit evaluate(((size(request->doc_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(request->doc_list,5) - 1)+ 1),3,
       2)), "Maintain Provider", "Physician Information",
     "Person", "Doctor", "Provider",
     "Amendment", request->doc_list[curhipaacnt].person_id, " "
   ENDFOR
  OF 0102012:
   EXECUTE cclaudit 0, "Query List", "Document",
   "Person List", "List", "Patient",
   "Report", request->username, " "
  OF 0104402:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Organization Maintenance",
   "System Object", "Resource", "Organization",
   "Origination/Amendment", request->organization_id, " "
  OF 0110001:
   EXECUTE cclaudit 0, "Run Custom Query", "Run",
   "System Object", "List", "Report Number",
   "Report", 0.0, request->select_string
  OF 0110005:
   EXECUTE cclaudit 0, "Run Work List", "Run",
   "System Object", "List", "Report Number",
   "Report", 0.0, request->select_string
  OF 0112510:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Reference Data", "Organization Maintenance",
   "System Object", "Resource", " ",
   "Origination/Amendment", 0.0, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Reference Data", "Organization Groups",
   "System Object", "Resource", " ",
   "Origination/Amendment", 0.0, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0113003:
   EXECUTE cclaudit 0, "Run Work List", "Run",
   "System Object", "Master file", "PM Worklist",
   "Access / use", request->work_list_id, " "
  OF 0113006:
   EXECUTE cclaudit 0, "Maintain List", "Delete",
   "System Object", "Master file", "PM Worklist",
   "Amendment", request->work_queue_id, " "
  OF 0113019:
   EXECUTE cclaudit 0, "Run Work List", "Run",
   "System Object", "Master file", "PM Worklist",
   "Access / use", request->method_id, " "
  OF 0113021:
   EXECUTE cclaudit 0, "Run Work List", "Run",
   "System Object", "Job", "PM Worklist",
   "Origination", request->script, " "
  OF 0114304:
   EXECUTE cclaudit 0, "Query Person", "Person Name",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0114317:
   EXECUTE cclaudit 0, "Query Encounter", "Retrieve",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0114346:
   FOR (curhipaacnt = 1 TO size(reply->organization,5))
     EXECUTE cclaudit evaluate(((size(reply->organization,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(reply->organization,5) - 1)+ 1),3,
       2)), "Maintain System Resource", "Organization",
     "Organization", "Master file", "Organization",
     "Amendment", reply->organization[curhipaacnt].organization_id, " "
   ENDFOR
  OF 0114350:
   FOR (curhipaacnt = 1 TO size(reply->health_plan,5))
     EXECUTE cclaudit evaluate(((size(reply->health_plan,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(reply->health_plan,5) - 1)+ 1),3,
       2)), "Maintain System Resource", "Health Plan",
     "Health Plan", "Master file", "Health Plan",
     "Amendment", reply->health_plan[curhipaacnt].health_plan_id, " "
   ENDFOR
  OF 0114356:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Query Patient List", "Location Census",
   "Location Query", "Location", "Location Code",
   "Report", request->facility_cd, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Query Patient List", "Location Census",
   "Location Query", "Location", "Location Code",
   "Report", request->building_cd, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Query Patient List", "Location Census",
   "Location Query", "Location", "Location Code",
   "Report", request->nurse_unit_or_amb_cd, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0114394:
   EXECUTE cclaudit 0, "Query Encounter", "Financial History",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0114395:
   EXECUTE cclaudit 0, "Query Encounter", "Service Category History",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0114396:
   FOR (curhipaacnt = 1 TO size(request->encntr_financial_hist,5))
     EXECUTE cclaudit evaluate(((size(request->encntr_financial_hist,5) - 1)+ 1),1,0,evaluate(
       curhipaacnt,1,1,((size(request->encntr_financial_hist,5) - 1)+ 1),3,
       2)), "Maintain Encounter", "Financial History",
     "Encounter", "Patient", "Encounter",
     "Amendment", request->encntr_financial_hist[curhipaacnt].encntr_id, " "
   ENDFOR
  OF 0114397:
   EXECUTE cclaudit 0, "Maintain Encounter", "Service Category History",
   "Encounter", "Patient", "Encounter",
   "Amendment", request->service_category_hist[1].encntr_id, " "
  OF 0114471:
   EXECUTE cclaudit 0, "Query Encounter", "Pending Information",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0114557:
   IF (validate(reply->print_status_data[1].pm_doc_print_hist_id)=0)
    EXECUTE cclaudit 0, "Output Report", "Patient Documents",
    "System Object", "Report", "Report Number",
    "Report", 0.0, request->file_name
   ENDIF
  OF 0114609:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Encounter", "Ensure",
   "Encounter", "Patient", "Encounter",
   "Amendment", reply->encntr_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Person", "Ensure",
   "Person", "Patient", "Patient",
   "Amendment", reply->person_id, " "
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0115050:
   EXECUTE cclaudit 0, "Query Encounter", "Encounter Leave History",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0115052:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Query Transaction", "Audit",
   "Transaction", "List", " ",
   "Report", 0.0, value(cnvtdatetime(request->begin_dt_tm))
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Query Transaction", "Audit",
   "Transaction", "List", " ",
   "Report", 0.0, value(cnvtdatetime(request->end_dt_tm))
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0120006:
   EXECUTE cclaudit 0, "Access Person", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0120013:
   EXECUTE cclaudit 0, "Access Order", "Pathology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0140007:
   FOR (curhipaacnt = 1 TO size(reply->prsnl,5))
     EXECUTE cclaudit evaluate(((size(reply->prsnl,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->prsnl,5) - 1)+ 1),3,
       2)), "Maintain Provider", "Provider Select",
     "Person", "Provider", "Provider",
     "Amendment", reply->prsnl[curhipaacnt].person_id, " "
   ENDFOR
 ENDCASE
END GO
