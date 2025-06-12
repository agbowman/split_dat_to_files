CREATE PROGRAM cclauditdispatch4:dba
 CASE ( $1)
  OF 0400100:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400101:
   EXECUTE cclaudit 0, "Maintain Order", "Radiology",
   "Person", "Patient", "Patient",
   "Amendment", request->changes[1].person_id, " "
  OF 0400104:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400127:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0400129:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0400131:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology",
   "Encounter", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0400135:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400166:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400167:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400170:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400174:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Organization", "List", " ",
   "Access / use", 0.0, curprog
  OF 0400176:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Exams",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0400180:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400181:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Exams",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400187:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0400189:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Organization", "List", " ",
   "Access / use", 0.0, curprog
  OF 0400217:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->qual[1].person_id, " "
  OF 0400225:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0400230:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology",
   "Encounter", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0400231:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0400232:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0400233:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Order",
   "Access / use", request->order_id, " "
  OF 0400241:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", " ",
   "Report", 0.0, curprog
  OF 0400243:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", " ",
   "Report", 0.0, curprog
  OF 0400244:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", " ",
   "Report", 0.0, curprog
  OF 0415008:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Organization", "List", "Location Code",
   "Access / use", request->qual[1].location_cd, " "
  OF 0415018:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Organization", "List", "Location Code",
   "Access / use", request->qual[1].location_cd, " "
  OF 0415021:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0415022:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Person", "Patient", "Encounter",
   "Access / use", request->encntr_id, " "
  OF 0415025:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "System Object", "List", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0425017:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0425024:
   EXECUTE cclaudit 0, "Maintain Encounter", "Add Radiology Exam",
   "Person", "Patient", "Patient",
   "Origination", request->qual[1].person_id, " "
  OF 0425034:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0440003:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0440004:
   EXECUTE cclaudit 0, "Maintain Encounter", "Add Radiology Folder",
   "Person", "Patient", "Patient",
   "Origination", request->qual[1].person_id, " "
  OF 0440007:
   EXECUTE cclaudit 0, "Maintain Encounter", "Folder",
   "Person", "Patient", "Patient",
   "Amendment", request->changes[1].person_id, " "
  OF 0440009:
   EXECUTE cclaudit 0, "Maintain Encounter", "Add Radiology Folder",
   "Person", "Patient", "Patient",
   "Origination", request->qual[1].person_id, " "
  OF 0440010:
   EXECUTE cclaudit 0, "Maintain Encounter", "Folder",
   "Person", "Patient", "Patient",
   "Amendment", request->changes[1].person_id, " "
  OF 0440011:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0440013:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Exams",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440017:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Exams",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440018:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0440030:
   EXECUTE cclaudit 0, "Maintain Encounter", "Add Radiology Exam",
   "Person", "Patient", "Patient",
   "Origination", request->qual[1].person_id, " "
  OF 0440032:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0440047:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440049:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Organization", "List", "Tracking Point Code",
   "Access / use", request->tracking_point_cd, " "
  OF 0440050:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440053:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->id_group[1].person_id, " "
  OF 0440058:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0440064:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Organization", "List", "Tracking Point Code",
   "Access / use", request->tracking_point_cd, " "
  OF 0440065:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440073:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440074:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->qual[1].person_id, " "
  OF 0440108:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0440109:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Exams",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440115:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440116:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0440127:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Folders",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0455075:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0455123:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", " ",
   "Report", 0.0, curprog
  OF 0455135:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0455147:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465007:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465008:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465009:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0465011:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465012:
   EXECUTE cclaudit 0, "Maintain Encounter", "Add Radiology Mammo Study",
   "Person", "Patient", "Patient",
   "Origination", request->qual[1].person_id, " "
  OF 0465013:
   EXECUTE cclaudit 0, "Maintain Encounter", "Radiology Mammo Study",
   "Person", "Patient", "Patient",
   "Amendment", request->changes[1].person_id, " "
  OF 0465022:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465023:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0465025:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465060:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0465065:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465066:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465073:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", reply->qual[1].person_id, " "
  OF 0465099:
   EXECUTE cclaudit 0, "Access Encounter", "Radiology Mammo Study",
   "Person", "Patient", " ",
   "Report", 0.0, curprog
  OF 0480022:
   EXECUTE cclaudit 0, "Access Patient", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0480026:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
  OF 0480033:
   EXECUTE cclaudit 0, "Access Orders", "Radiology",
   "Person", "Patient", "Patient",
   "Access / use", request->person_id, " "
 ENDCASE
END GO
