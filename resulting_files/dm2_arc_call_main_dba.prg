CREATE PROGRAM dm2_arc_call_main:dba
 FREE RECORD dcm_request
 RECORD dcm_request(
   1 batch_selection = vc
 )
 SET dcm_request->batch_selection = "PERSON"
 EXECUTE dm2_arc_main  WITH replace("REQUEST","DCM_REQUEST")
 FREE RECORD dcm_request
END GO
