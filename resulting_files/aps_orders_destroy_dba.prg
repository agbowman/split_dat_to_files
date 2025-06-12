CREATE PROGRAM aps_orders_destroy:dba
 CALL echo("Destroying persistent record structure of order information.")
 FREE SET orders
 FREE SET cd
END GO
