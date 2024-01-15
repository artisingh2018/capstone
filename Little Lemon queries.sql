CREATE VIEW Ordersview as SELECT OrderID, Quantity, TotalCost FROM Orders WHERE Quantity > 2;
SELECT * from OrdersView;

SELECT Customers.CustomerID, Customers.CustomerName, Orders.OrderID, Orders.Totalcost, Menu.MenuItemName, Menu.Type FROM (((Customers INNER JOIN Bookings ON Customers.CustomerID=Bookings.CustomerID) INNER JOIN Orders ON Bookings.BookingID=Orders.BookingID) INNER JOIN Menu ON Orders.MenuID=Menu.MenuID);

SELECT MenuItemName From Menu WHERE MenuID = ANY (SELECT MenuID FROM Orders WHERE Quantity > 2);

DELIMITER //
CREATE PROCEDURE GetMaxQuantity()
BEGIN
SELECT MAX(Quantity) AS Max_Quantity_in_Order FROM Orders;
END //
DELIMITER ;

CALL GetMaxQuantity();

PREPARE GetOrderDetail FROM 'SELECT Orders.OrderID, Orders.Quantity, Orders.TotalCost FROM Orders INNER JOIN Bookings ON Orders.BookingID=Bookings.BookingID WHERE Bookings.CustomerID=?';
SET @id = 1;
EXECUTE GetOrderDetail USING @id;

DELIMITER //
CREATE PROCEDURE CancelOrder(order_id INT)
BEGIN
DECLARE Confirmation VARCHAR(255);
DELETE FROM Orders WHERE OrderID= order_id;
SET Confirmation = "Order" + order_id + "is cancelled";
SELECT Confirmation;
END //
DELIMITER ;

CALL CancelOrder(5);

INSERT INTO Bookings (BookingID, TableNo, CustomerID, BookingDate, EmployeeID) VALUES (1, 5, 1, "2022-10-10", 1), (2, 3, 3, "2022-11-12", 1), (3, 2, 2, "2022-10-11", 1), (4, 2, 1, "2022-10-13", 1);

DELIMITER //
CREATE PROCEDURE CheckBooking(booking_date DATE, table_no INT)
BEGIN
DECLARE BookingStatus VARCHAR(255);
DECLARE settableno INT DEFAULT NULL;
SELECT TableNo INTO settableno FROM Bookings WHERE TableNo=table_no;
IF settableno=table_no AND BookingDate=booking_date THEN SET BookingStatus="Table" + table_no + "is already booked";
ELSE SET BookingStatus = "Table" + table_no + " is available for booking ";
END IF;
SELECT BookingStatus;
END //
DELIMITER ;

CALL CheckBooking("2022-11-12", 3);

DELIMITER //
CREATE PROCEDURE AddValidBooking(booking_date DATE, table_no INT)
BEGIN
DECLARE BookingStatus VARCHAR(255);
DECLARE settableno INT DEFAULT NULL;
START TRANSACTION;
SELECT TableNo INTO settableno FROM Bookings WHERE TableNo=table_no;
INSERT INTO Bookings (BookingDate, TableNo) VALUES (booking_date, table_no);
IF settableno=table_no AND BookingDate=booking_date THEN ROLLBACK;
SET BookingStatus = "Table " + table_no + "is already booked - Booking Cancelled";
SELECT BookingStatus;
ELSE COMMIT;
END IF;
END //
DELIMITER ;

CALL AddValidBooking("2022-12-17", 6);

DELIMITER //
CREATE PROCEDURE AddBooking(booking_id INT, customer_id INT, booking_date DATE, table_no INT)
BEGIN
DECLARE Confirmation VARCHAR(255);
INSERT INTO Bookings (BookingID, CustomerID, BookingDate, TableNo) VALUES (booking_id, customer_id, booking_date, table_no);
SET Confirmation = "New booking added";
SELECT Confirmation;
END //
DELIMITER ;

CALL AddBooking(9, 3, "2022-12-30", 4);

DELIMITER //
CREATE PROCEDURE UpdateBooking(booking_id INT, booking_date DATE)
BEGIN
DECLARE Confirmation VARCHAR(255);
UPDATE Bookings SET BookingDate=booking_date WHERE BookingID=booking_id;
SET Confirmation = "Booking" + booking_id + "updated";
SELECT Confirmation;
END //
DELIMITER ;

CALL UpdateBooking(9, "2022-12-27");

DELIMITER //
CREATE PROCEDURE CancelBooking(booking_id INT)
BEGIN
DECLARE Confirmation VARCHAR(255);
DELETE FROM Bookings WHERE BookingID=booking_id;
SET Confirmation = "Booking" + booking_id + "cancelled";
SELECT Confirmation;
END //
DELIMITER ;

CALL CancelBooking(9);