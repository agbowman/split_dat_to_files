CREATE PROGRAM cclauditdispatch5:dba
 CASE ( $1)
  OF 0500017:
   EXECUTE cclaudit 0, "View Orders", "Retrieve",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0500076:
   EXECUTE cclaudit 0, "View Orders", "Order Comment",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500077:
   EXECUTE cclaudit 0, "View Orders", "Modify Details",
   "Person", "Patient", "Order",
   "Access / use", request->order_qual[1].order_id, " "
  OF 0500173:
   EXECUTE cclaudit 0, "View Orders", "Duplicate Check Indicator",
   "Person", "Patient", "Order",
   "Access / use", request->person_id, " "
  OF 0500184:
   EXECUTE cclaudit 0, "Maintain Person", "Add Sticky Note",
   "Person", "Patient", "Patient",
   "Origination", request->parent_entity_id, " "
  OF 0500235:
   EXECUTE cclaudit 0, "View Orders", "Order Details",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500236:
   EXECUTE cclaudit 0, "View Orders", "Order Info",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500237:
   EXECUTE cclaudit 0, "View Orders", "Order Info Comment",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500238:
   EXECUTE cclaudit 0, "View Orders", "Order Info Validation",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500244:
   EXECUTE cclaudit 0, "View Orders", "Order Info History",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500257:
   EXECUTE cclaudit 0, "View Orders", "Info",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500261:
   EXECUTE cclaudit 0, "View Orders", "Ingredient",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500265:
   EXECUTE cclaudit 0, "View Orders", "Lab Status",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500266:
   EXECUTE cclaudit 0, "Query List", "Patient Location",
   "System Object", "Location", "Location Code",
   "Access / use", request->loc_nurse_unit_cd, " "
  OF 0500267:
   EXECUTE cclaudit 0, "View Encounter", "Patient-Provider Reltn",
   "Person", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0500269:
   EXECUTE cclaudit 0, "Query List", "Patient-Provider Relations",
   "Person", "Patient", "Patient",
   "Access / use", request->prsnl_person_id, " "
  OF 0500280:
   EXECUTE cclaudit 0, "View Patient", "Retrieve",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0500320:
   EXECUTE cclaudit 0, "View Orders", "Retrieve",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0500325:
   EXECUTE cclaudit 0, "Query List", "Medical Service",
   "Organization", "Resource", "Organization",
   "Access / use", request->med_service_cd, " "
  OF 0500331:
   FOR (curhipaacnt = 1 TO size(reply->qual,5))
     EXECUTE cclaudit evaluate(((size(reply->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->qual,5) - 1)+ 1),3,
       2)), "View List", "Orders to Sign",
     "System Object", "List", "Patient",
     "Access / use", reply->qual[curhipaacnt].person_id, " "
   ENDFOR
  OF 0500332:
   EXECUTE cclaudit 0, "View Orders", "Order Flow Info",
   "Person", "Patient", "Order",
   "Access / use", request->qual[1].order_id, " "
  OF 0500415:
   EXECUTE cclaudit 0, "View Orders", "Retrieve",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0500430:
   EXECUTE cclaudit 0, "View Orders", "Order Profile",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0500521:
   EXECUTE cclaudit 0, "View Orders", "Ingredient",
   "Person", "Patient", "Order",
   "Access / use", request->order_list[1].order_id, " "
  OF 0560601:
   EXECUTE cclaudit 0, "Output Orders", "Reprint Requisitions",
   "Person", "Patient", "Patient",
   "Origination", request->person_id, " "
 ENDCASE
END GO
