CREATE PROGRAM cclauditdispatch0:dba
 CASE ( $1)
  OF 0003000:
   EXECUTE cclaudit 0, "Access User", "Retrieve",
   "Person", "User", "Provider",
   "Access / use", request->person_id, " "
  OF 0003001:
   EXECUTE cclaudit 0, "Maintain User", "Add User",
   "Person", "User", "Provider",
   "Origination", reply->person_id, " "
  OF 0003002:
   EXECUTE cclaudit 0, "Access User", "Retrieve",
   "Person", "User", " ",
   "Access / use", 0.0, concat(request->name_last,",",request->name_first)
  OF 0003007:
   EXECUTE cclaudit 0, "Maintain User", "User Groupings",
   "Person", "User", "Personnel Group",
   "Access / use", 0.0, " "
  OF 0003009:
   EXECUTE cclaudit 0, "Maintain User", "Add User Group",
   "Person", "User", "Personnel Group",
   "Amendment", 0.0, " "
  OF 0003010:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain User", "User Groupings",
   "Person", "User", "Provider",
   "Amendment", request->person_id, " "
   FOR (curhipaacnt = 1 TO size(request->qual,5))
    SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
    EXECUTE cclaudit cclaud->hipaamode, "Maintain User", "User Groupings",
    "Person", "User", "Personnel Group",
    "Amendment", request->qual[curhipaacnt].prsnl_group_id, " "
   ENDFOR
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0003012:
   EXECUTE cclaudit 0, "Maintain User", "User Groupings",
   "Person", "User", "Personnel Group",
   "Amendment", (request->person_id/ request->prsnlgrouplist.prsnl_group_id), " "
  OF 0003013:
   EXECUTE cclaudit 0, "Access User", "Retrieve",
   "Person", "User", " ",
   "Access / use", 0.0, request->username
  OF 0003014:
   EXECUTE cclaudit 0, "Access User", "Retrieve",
   "Person", "User", " ",
   "Access / use", 0.0, request->alias
  OF 0003015:
   EXECUTE cclaudit 0, "Access User", "Retrieve",
   "Person", "User", " ",
   "Access / use", 0.0, concat(request->name_last,",",request->name_first,"Position:",
    uar_get_code_display(request->position_cd))
  OF 0003016:
   EXECUTE cclaudit 0, "Maintain User", "Add Prsnl Alias",
   "Person", "User", "Provider",
   "Amendment", request->person_id, " "
  OF 0003017:
   EXECUTE cclaudit 0, "Maintain User", "Add Person Alias",
   "Person", "User", "Provider",
   "Amendment", request->person_id, " "
  OF 0003018:
   EXECUTE cclaudit 0, "Access User", "Aliases",
   "Person", "User", "Provider",
   "Access / use", request->person_id, " "
  OF 0003019:
   EXECUTE cclaudit 0, "Access User", "Aliases",
   "Person", "User", "Provider",
   "Access / use", request->person_id, " "
  OF 0003022:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Maintain User", "Maintain Person Alias",
     "Person", "User", "Person Alias",
     "Amendment", request->qual[curhipaacnt].person_alias_id, " "
   ENDFOR
  OF 0003023:
   EXECUTE cclaudit 0, "Maintain User", "User Status and Authentication",
   "Person", "User", "Provider",
   "Amendment", request->person_id, " "
  OF 0003024:
   EXECUTE cclaudit 0, "Maintain User", "Change Authorization",
   "Person", "User", "Provider",
   "Access / use", request->person_id, " "
  OF 0003025:
   EXECUTE cclaudit 0, "Access User", "Retrieve",
   "Person", "User", " ",
   "Access / use", 0.0, request->alias
  OF 0003026:
   EXECUTE cclaudit 0, "Maintain User", "Position-Application Group Reltn",
   "Person", "User", "Position Code",
   "Amendment", request->position_cd, " "
  OF 0003027:
   EXECUTE cclaudit 0, "Maintain User", "Position-Application Group Reltn",
   "Person", "User", "Position Code",
   "Amendment", request->position_cd, " "
  OF 0003029:
   EXECUTE cclaudit 0, "Maintain User", "Maintain User Group",
   "Person", "User", "Personnel Group",
   "Amendment", 0.0, " "
  OF 0003043:
   EXECUTE cclaudit 0, "Access User", "Retrieve",
   "Person", "User", "Provider",
   "Access / use", request->person_id, " "
  OF 0003054:
   EXECUTE cclaudit 0, "Access User", "Prsnl-Org Reltn",
   "Person", "User", "Provider",
   "Access / use", request->person_id, " "
  OF 0003055:
   EXECUTE cclaudit 0, "Maintain User", "Prsnl-Org Reltn",
   "Person", "User", "Provider",
   "Access / use", request->person_id, " "
  OF 0003056:
   EXECUTE cclaudit 0, "Maintain User", "Prsnl-Org Reltn",
   "Person", "User", "Provider",
   "Amendment", request->person_id, " "
  OF 0003057:
   EXECUTE cclaudit 0, "Maintain User", "Prsnl-Org Reltn",
   "Person", "User", "Provider",
   "Amendment", request->person_id, " "
  OF 0003060:
   EXECUTE cclaudit 0, "Access User", "Prsnl-Org Reltn",
   "Person", "User", "Organization",
   "Access / use", request->organization_id, " "
  OF 0003061:
   FOR (curhipaacnt = 1 TO size(request->person,5))
     EXECUTE cclaudit evaluate(((size(request->person,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size
       (request->person,5) - 1)+ 1),3,
       2)), "Maintain User", "Prsnl-Org Reltn",
     "Person", "User", "Provider",
     "Amendment", request->person[curhipaacnt].person_id, " "
   ENDFOR
  OF 0003062:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Organization Groups",
   "System Object", "Resource", " ",
   "Origination/Amendment", 0.0, " "
  OF 0013000:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Maintain Reference Data", "Maintain Locations & Service Resources",
     "System Object", "Resource", "Location Code",
     "Origination/Amendment", reply->qual[curhipaacnt].location_cd, " "
   ENDFOR
  OF 0013001:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Maintain Reference Data", "Maintain Locations & Service Resources",
     "System Object", "Resource", "Service Resource Code",
     "Origination/Amendment", reply->qual[curhipaacnt].service_resource_cd, " "
   ENDFOR
  OF 0013007:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", "Service Resource Code",
   "Origination/Amendment", request->qual[curhipaacnt].service_resource_cd, " "
  OF 0013008:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", "Location Code",
   "Origination/Amendment", request->qual[curhipaacnt].location_cd, " "
  OF 0013025:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", "Service Resource Code",
   "Origination/Amendment", request->qual[curhipaacnt].service_resource_cd, " "
  OF 0013026:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", "Location Code",
   "Origination/Amendment", request->qual[curhipaacnt].location_cd, " "
  OF 0013050:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", "Location Code",
   "Origination/Amendment", 0.0, " "
  OF 0013054:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Maintain Reference Data", "Maintain Locations & Service Resources",
     "System Object", "Resource", "Location Code",
     "Origination/Amendment", request->qual[curhipaacnt].code_value, " "
   ENDFOR
  OF 0013065:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", "Location Code",
   "Origination/Amendment", request->location_cd, " "
  OF 0013068:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", "Service Resource Code",
   "Origination/Amendment", request->service_resource_cd, " "
  OF 0013082:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Maintain Reference Data", "Maintain Locations & Service Resources",
     "System Object", "Resource", "Location Code",
     "Origination/Amendment", request->qual[curhipaacnt].location_cd, " "
   ENDFOR
  OF 0013083:
   EXECUTE cclaudit 0, "Maintain Reference Data", "Maintain Locations & Service Resources",
   "System Object", "Resource", "Location Code",
   "Origination/Amendment", request->location_cd, " "
  OF 0013096:
   SET cclaud->hipaamode = 0
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,1,2)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Reference Data",
   "Maintain Locations & Service Resources",
   "System Object", "Resource", "Location Code",
   "Origination/Amendment", request->parent_entity_id, " "
   SET cclaud->hipaamode = evaluate(cclaud->hipaamode,0,0,3)
   EXECUTE cclaudit cclaud->hipaamode, "Maintain Reference Data",
   "Maintain Locations & Service Resources",
   "System Object", "Resource", " ",
   "Origination/Amendment", 0.0, request->parent_entity_name
   IF ((cclaud->hipaamode IN (1, 2)))
    EXECUTE cclaudit 4, " ", " ",
    " ", " ", " ",
    " ", 0.0, " "
   ENDIF
  OF 0030001:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Maintain Expedites", "Maintain Parameter",
     "System Object", "Routing Criteria", "Expediate Param",
     "Origination", 0.0, " "
   ENDFOR
  OF 0030002:
   EXECUTE cclaudit 0, "Maintain Expedites", "Maintain Trigger",
   "System Object", "Qualification Criteria", "Expedite Trigger",
   "Origination", request->name, " "
  OF 0030005:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Maintain Expedites", "Maintain Parameter",
     "System Object", "Routing Criteria", "Expedite Param",
     "Amendment", request->qual[curhipaacnt].expedite_params_id, " "
   ENDFOR
  OF 0030006:
   FOR (curhipaacnt = 1 TO size(request->qual,5))
     EXECUTE cclaudit evaluate(((size(request->qual,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        request->qual,5) - 1)+ 1),3,
       2)), "Maintain Expedites", "Maintain Parameter",
     "System Object", "Routing Criteria", "Expedite Param",
     "Destruction", request->qual[curhipaacnt].expedite_params_id, " "
   ENDFOR
  OF 0030011:
   EXECUTE cclaudit 0, "Maintain Expedites", "Maintain Trigger",
   "System Object", "Qualification Criteria", "Expedite Trigger",
   "Destruction", request->name, " "
  OF 0030018:
   EXECUTE cclaudit 0, "Maintain Expedites", "Maintain Trigger",
   "System Object", "Qualification Criteria", "Expedite Trigger",
   "Amendment", request->name, " "
  OF 0032000:
   EXECUTE cclaudit 0, "Submit Chart", "Manual Expedite",
   "System Object", "Report", "Manual Expedite",
   "Origination", reply->expedite_manual_id, " "
  OF 0070000:
   EXECUTE cclaudit 0, "Query List", "Matching Persons",
   "Person List", "List", " ",
   "Report", 0.0, curprog
  OF 0070001:
   EXECUTE cclaudit 0, "Query Person", "Retrieve",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0070003:
   EXECUTE cclaudit 0, "Maintain Person", "Aliases",
   "Person", "Master file", " ",
   "Amendment", 0.0, curprog
  OF 0070004:
   EXECUTE cclaudit 0, "Maintain Person Match", "Combine",
   "System Object", "Master file", " ",
   "Amendment", 0.0, curprog
  OF 0070005:
   EXECUTE cclaudit 0, "Query Person Match", "Master Person",
   "Person", "Patient", " ",
   "Access / use", 0.0, curprog
  OF 0070006:
   FOR (curhipaacnt = 1 TO size(reply->person,5))
     EXECUTE cclaudit evaluate(((size(reply->person,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((size(
        reply->person,5) - 1)+ 1),3,
       2)), "Query Person Match", "List of Persons",
     "Person List", "List", " ",
     "Report", 0.0, curprog
   ENDFOR
  OF 0070007:
   EXECUTE cclaudit 0, "Query Person Match", "List of Encounters",
   "Encounter List", "List", " ",
   "Report", 0.0, curprog
  OF 0070008:
   FOR (curhipaacnt = 1 TO size(reply->encounter,5))
     EXECUTE cclaudit evaluate(((size(reply->encounter,5) - 1)+ 1),1,0,evaluate(curhipaacnt,1,1,((
       size(reply->encounter,5) - 1)+ 1),3,
       2)), "Query Person Match", "List of Encounters",
     "Encounter List", "List", " ",
     "Report", 0.0, curprog
   ENDFOR
  OF 0070009:
   EXECUTE cclaudit 0, "Query Encounter", "Retrieve",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encounter_id, " "
  OF 0070010:
   EXECUTE cclaudit 0, "Query List", "Encounters",
   "Encounter List", "List", "Encounter",
   "Report", request->combine_id, " "
 ENDCASE
END GO
