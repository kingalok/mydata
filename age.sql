--- Enable and Load Apache AGE in Your Database Session

-- 1. Create the AGE extension in your current database.
--    'IF NOT EXISTS' prevents errors if you run it multiple times.
--    'CASCADE' ensures any dependencies are also installed.
CREATE EXTENSION IF NOT EXISTS AGE CASCADE;

-- Expected Output:
-- NOTICE:  extension "age" already exists, skipping
-- OR
-- CREATE EXTENSION

-- 2. Load the AGE library for the current session.
--    This makes AGE functions and data types available.
LOAD 'age';

-- Expected Output:
-- LOAD

-- 3. Set the search path to include ag_catalog schema.
--    This allows you to call AGE functions like 'create_graph' and 'cypher' directly
--    without prefixing them with 'ag_catalog.'.
SET search_path = ag_catalog, "$user", public;

-- Expected Output:
-- SET


--- Verify AGE Installation and Version

-- Check if the 'age' extension is installed in the current database
SELECT extname, extversion
FROM pg_extension
WHERE extname = 'age';

-- Expected Output (extversion may vary depending on AGE updates):
-- extname | extversion
-----------+------------
-- age     | 1.1.0      (or similar, e.g., 1.2.0, 1.3.0)
--(1 row)

-- Check the PostgreSQL version (for context)
SELECT version();

-- Expected Output (example for PG15 on Azure):
--                                                    version
----------------------------------------------------------------------------------------------------------------
-- PostgreSQL 15.6 on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 10.3.0-1ubuntu1~20.04) 10.3.0, 64-bit
--(1 row)


-- Create your First Graph

-- Create a new graph named 'social_network'
SELECT create_graph('social_network');

-- Expected Output:
--                      create_graph
----------------------------------------------------------
-- {"graph_name": "social_network", "message": "graph \"social_network\" has been created"}
--(1 row)

-- Insert Nodes (Vertices) into the Graph

-- Insert three 'Person' nodes with properties into 'social_network'
SELECT * FROM cypher('social_network', $$
    CREATE (p1:Person {name: 'Alice', age: 30, city: 'New York'}),
           (p2:Person {name: 'Bob', age: 25, city: 'London'}),
           (p3:Person {name: 'Charlie', age: 35, city: 'New York'}),
           (p4:Person {name: 'Diana', age: 28, city: 'Paris'})
$$) AS (result agtype);

-- Expected Output (result will be an agtype NULL as CREATE does not return by default):
-- result
----------
-- (null)
--(1 row)


--- Insert Edges (Relationships) into the Graph

-- Create relationships between the 'Person' nodes
SELECT * FROM cypher('social_network', $$
    MATCH (a:Person {name: 'Alice'}), (b:Person {name: 'Bob'})
    CREATE (a)-[:FRIENDS_WITH {since: '2020-01-15'}]->(b)
$$) AS (result agtype);

SELECT * FROM cypher('social_network', $$
    MATCH (b:Person {name: 'Bob'}), (c:Person {name: 'Charlie'})
    CREATE (b)-[:WORKS_WITH {project: 'Alpha'}]->(c)
$$) AS (result agtype);

SELECT * FROM cypher('social_network', $$
    MATCH (a:Person {name: 'Alice'}), (d:Person {name: 'Diana'})
    CREATE (a)-[:FRIENDS_WITH {since: '2021-03-22'}]->(d)
$$) AS (result agtype);

SELECT * FROM cypher('social_network', $$
    MATCH (c:Person {name: 'Charlie'}), (d:Person {name: 'Diana'})
    CREATE (c)-[:FRIENDS_WITH {since: '2019-11-01'}]->(d)
$$) AS (result agtype);

-- Expected Output for each CREATE query:
-- result
----------
-- (null)
--(1 row)


--- Query the Graph Data

-- Query 1: Get all Persons and their names/ages

SELECT * FROM cypher('social_network', $$
    MATCH (p:Person)
    RETURN p.name, p.age, p.city
$$) AS (name agtype, age agtype, city agtype);

-- Expected Output:
--    name   | age |    city
-----------+-----+------------
-- "Alice"   | 30  | "New York"
-- "Bob"     | 25  | "London"
-- "Charlie" | 35  | "New York"
-- "Diana"   | 28  | "Paris"
--(4 rows)

-- Query 2: Find all friends of Alice

SELECT * FROM cypher('social_network', $$
    MATCH (alice:Person {name: 'Alice'})-[:FRIENDS_WITH]->(friend)
    RETURN friend.name AS FriendName, friend.city AS FriendCity
$$) AS (FriendName agtype, FriendCity agtype);

-- Expected Output:
-- FriendName | FriendCity
--------------+------------
-- "Bob"        | "London"
-- "Diana"      | "Paris"
--(2 rows)

-- Query 3: Find people who work with Bob, and what project they worked on

SELECT * FROM cypher('social_network', $$
    MATCH (worker)-[r:WORKS_WITH]->(bob:Person {name: 'Bob'})
    RETURN worker.name AS WorkerName, r.project AS Project
$$) AS (WorkerName agtype, Project agtype);

-- Expected Output (Note: No one works *with* Bob, rather Bob works *with* Charlie as per our initial data):
-- WorkerName | Project
--------------+---------
-- (No results if 'Charlie' is the one connected to Bob with 'WORKS_WITH' from Bob)
-- Let's correct the query if Bob worked WITH Charlie:
-- SELECT * FROM cypher('social_network', $$
--     MATCH (b:Person {name: 'Bob'})-[:WORKS_WITH]->(c:Person)
--     RETURN b.name AS BobName, c.name AS WorksWith, r.project AS Project
-- $$) AS (BobName agtype, WorksWith agtype, Project agtype);

-- Let's find who *works with* Charlie (meaning Charlie is the target)
SELECT * FROM cypher('social_network', $$
    MATCH (p)-[r:WORKS_WITH]->(c:Person {name: 'Charlie'})
    RETURN p.name AS WorkerName, r.project AS Project
$$) AS (WorkerName agtype, Project agtype);

-- Corrected Expected Output (from our data where Bob WORKS_WITH Charlie):
-- WorkerName | Project
--------------+---------
-- "Bob"      | "Alpha"
--(1 row)

-- Query 4: Find people who are friends with someone in 'New York'


SELECT * FROM cypher('social_network', $$
    MATCH (p1:Person)-[:FRIENDS_WITH]-(p2:Person {city: 'New York'})
    RETURN DISTINCT p1.name AS FriendOutsideNY
$$) AS (FriendOutsideNY agtype);

-- Expected Output:
-- FriendOutsideNY
-------------------
-- "Bob"
-- "Diana"
--(2 rows)


-- Clean Up (Optional)

-- Drop the graph 'social_network'
SELECT drop_graph('social_network', true); -- 'true' attempts to drop even if it contains data

-- Expected Output:
--                      drop_graph
------------------------------------------------------
-- {"graph_name": "social_network", "message": "graph \"social_network\" has been dropped"}
--(1 row)

