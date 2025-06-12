CREATE PROGRAM afc_srv_interface_charge
 CALL echo("Begin afc_srv_interface_charge")
 CALL echo(build("size(request->interface_charge): ",size(request->interface_charge,5)))
 EXECUTE afc_post_interface_charge
 CALL echo("End afc_srv_interface_charge")
END GO
