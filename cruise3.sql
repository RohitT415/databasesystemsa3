-- Part 1

-- 1: List the ship and the company it belongs to where the stock symbol has a letter ‘R’ in
-- it, and the total capacity of people on the ship is over 3500. Display the ship name, company
-- name, and a header of TotalPeople for the total ship capacity. Use theta joins.
SELECT S.shipName, S.companyName, (S.crew + S.passengers) AS TotalPeople
FROM Ship S
JOIN Company CO ON S.companyName = CO.companyName
WHERE CO.stockSymbol LIKE '%R%'
AND (S.crew + S.passengers) > 3500;

-- 2: List the first name and last name of travel agents and their totals sales but only if the
-- total sales are above $1000. Sort the results in order of greatest total sales to smallest total
-- sales. If travel agents have the same total sales, sort by last name in regular alphabet order and
-- then first name in regular alphabetic order.
SELECT T.firstName, T.lastName, SUM(CR.price) AS TotalSales
FROM Reservation R
JOIN Cruise CR ON R.cruiseID = CR.cruiseID
JOIN TravelAgent T ON R.travelAgentID = T.travelAgentID
GROUP BY T.firstName, T.lastName
HAVING SUM(CR.price) > 1000
ORDER BY TotalSales DESC, T.lastName ASC, T.firstName ASC;


-- 3: Determine the customer who will make greatest number of visits to Miami. List the
-- firstName, lastName, and the number of visits (use the heading Visits). If you really struggle with
-- this, write the code for Question 7 below and see if you can determine the relational algebra
-- from the SQL code.
SELECT C.firstName, C.lastName, COUNT(*) AS Visits
FROM Reservation R
JOIN Cruise CR ON R.cruiseID = CR.cruiseID
JOIN Customer C ON R.customerID = C.customerID
WHERE CR.departurePort = 'Miami'
GROUP BY C.customerID, C.firstName, C.lastName
ORDER BY Visits DESC
FETCH FIRST 1 ROWS ONLY;


-- 4. Given the schema below:
-- NS <- NewShip (newShipName PK, companyName PK FK, yearBuilt, crew, passengers, tonnage, dailyTips)
-- List customers who are going on cruises less than 7 days on the old ships and who are also going
-- on cruises more than 7 days on new ships. List the customer first name, customer last name,
-- and total number of cruises that meet the restrictions above.
DROP TABLE NewShip;

CREATE TABLE NewShip (
    newShipName varchar2(20),
    companyName varchar2(15),
    yearBuilt number(4),
    crew number(4),
    passengers number(4),
    tonnage number(6),
    dailyTips number(5,2),
    CONSTRAINT NewShip_PK PRIMARY KEY (newShipName, companyName),
    CONSTRAINT NewShip_FK FOREIGN KEY (companyName)
        REFERENCES Company (companyName)
);

SELECT C.firstName, C.lastName, COUNT(*) AS TotalCruises
FROM Customer C
JOIN Reservation R ON C.customerID = R.customerID
JOIN Cruise CR ON R.cruiseID = CR.cruiseID
LEFT JOIN Ship S ON CR.shipName = S.shipName
LEFT JOIN NewShip NS ON CR.shipName = NS.newShipName
WHERE 
  (CR.days < 7 AND S.shipName IS NOT NULL)
  AND 
  (CR.days > 7 AND NS.newShipName IS NOT NULL)
GROUP BY C.firstName, C.lastName;

-- 5.b. (5 points) Convert the algebraic expression into SQL code. Do not use subqueries
SELECT (M.A + M.B) AS E, M.C, N.X AS G
FROM M
JOIN N ON M.B = N.B
WHERE N.X > M.B;


-- Part 2

-- 6. Instead of joins, use subqueries to write efficient SQL code: List the ship and the
-- company it belongs to where the stock symbol has a letter ‘R’ in it, and the total capacity of
-- people on the ship is over 3500. Display the ship name, company name, and a header of
-- TotalPeople for the total ship capacity.
SELECT shipName, companyName, (crew + passengers) AS TotalPeople
FROM Ship
WHERE companyName IN (
    SELECT companyName 
    FROM Company 
    WHERE stockSymbol LIKE '%R%'
)
AND (crew + passengers) > 3500;


-- 7.
-- Write the SQL query for Question 3. It may help to refer to your relational algebra
-- answers in Question 3. You may also want to look at the PowerPoint slides at the end of SQL 5
-- and follow the code posted on Canvas for the SQL 5 demo. 
SELECT firstName, lastName, Visits
FROM (
    SELECT C.firstName, C.lastName, COUNT(*) AS Visits
    FROM Reservation R
    JOIN Cruise CR ON R.cruiseID = CR.cruiseID
    JOIN Customer C ON R.customerID = C.customerID
    WHERE CR.departurePort = 'Miami'
    GROUP BY C.customerID, C.firstName, C.lastName
    ORDER BY Visits DESC
)
WHERE ROWNUM = 1;

-- 8.
-- Write the SQL query for Question 4. It may help to refer to your relational algebra
--answers in Question 4.
SELECT firstName, lastName, TotalCruises
FROM (
    SELECT C.firstName, C.lastName, COUNT(*) AS TotalCruises
    FROM Reservation R
    JOIN Cruise CR ON R.cruiseID = CR.cruiseID
    JOIN Customer C ON R.customerID = C.customerID
    WHERE R.customerID IN (
        SELECT R.customerID 
        FROM Reservation R
        JOIN Cruise CR ON R.cruiseID = CR.cruiseID
        JOIN Ship S ON CR.shipName = S.shipName
        WHERE CR.days < 7
    )
    AND R.customerID IN (
        SELECT R.customerID 
        FROM Reservation R
        JOIN Cruise CR ON R.cruiseID = CR.cruiseID
        JOIN NewShip NS ON CR.shipName = NS.newShipName
        WHERE CR.days > 7
    )
    GROUP BY C.firstName, C.lastName
);