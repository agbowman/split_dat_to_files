CREATE PROGRAM bhs_admit_diagnosis_mutiorder:dba
 SET retval = 0
 IF (size(request->orderlist,5) > 1)
  SET stat = alterlist(request->orderlist,1)
  SET log_message = "More then one order found, reducing recStruct. "
 ELSE
  SET log_message = "Only one order found. "
 ENDIF
 IF (size(request->orderlist[1].ingredientlist,5) > 1)
  SET stat = alterlist(request->orderlist[1].ingredientlist,1)
  SET log_message = concat(log_message," More then one ingredient found, reducing recStruct")
 ELSE
  SET log_message = concat(log_message," Only one ingredient found")
 ENDIF
 CALL echo(log_message)
 SET retval = 100
END GO
