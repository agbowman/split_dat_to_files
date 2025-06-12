CREATE PROGRAM cclauditdispatch3:dba
 CASE ( $1)
  OF 0340126:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Query Person", "Medication Claims History",
     "Person", "Patient", "Order",
     "Access / use", request->qual[curhipaacnt].order_id, " "
   ENDFOR
  OF 0340225:
   FOR (curhipaacnt = 1 TO size(request->subsec_list,5))
     EXECUTE cclaudit evaluate(((size(request->subsec_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,(
       (size(request->subsec_list,5) - 1)+ 1),3,
       2)), "Query List", "Medication Dispense Monitor",
     "System Object", "List", " ",
     "Access / use", request->subsec_list[curhipaacnt].subsection_cd, " "
   ENDFOR
  OF 0340233:
   EXECUTE cclaudit 0, "Query Person", "Medication Profile",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0340234:
   EXECUTE cclaudit 0, "Query Orders", "Medication",
   "Person", "Patient", "Patient",
   "Access / use", request->orderlist[1].orderid, " "
  OF 0350030:
   EXECUTE cclaudit 0, "View Orders", "Order Item",
   "Person", "Patient", "Order",
   "Access / use", request->orderid, " "
  OF 0380001:
   EXECUTE cclaudit 0, "Query Person", "Medication Profile",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0380030:
   EXECUTE cclaudit 0, "Query Person", "Medication Profile",
   "Person", "Patient", "Patient",
   "Access / use", reply->person_id, " "
  OF 0380032:
   FOR (curhipaacnt = 1 TO size(request->location_list,5))
     EXECUTE cclaudit evaluate(((size(request->location_list,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,
       ((size(request->location_list,5) - 1)+ 1),3,
       2)), "Query List", "Unverified Medication Order Monitor",
     "System Object", "List", " ",
     "Access / use", request->location_list[curhipaacnt].location_cd, " "
   ENDFOR
  OF 0380043:
   EXECUTE cclaudit 0, "Query Orders", "Medication",
   "Person", "Patient", "Patient",
   "Access / use", request->order_id, " "
 ENDCASE
END GO
