-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: cosc4606.ch062i2a4yvv.us-east-2.rds.amazonaws.com    Database: cosc4606
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `CategoryId` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) NOT NULL,
  `Path` varchar(45) NOT NULL,
  PRIMARY KEY (`CategoryId`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Pasta','pasta'),(2,'Pizza','pizza'),(3,'Salad','salad'),(4,'Desserts','desserts'),(5,'Drinks','drinks');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customerpreferences`
--

DROP TABLE IF EXISTS `customerpreferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customerpreferences` (
  `CustomerID` int NOT NULL,
  `IsVegan` tinyint(1) DEFAULT NULL,
  `IsVegetarian` tinyint(1) DEFAULT NULL,
  `Allergies` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`CustomerID`),
  CONSTRAINT `customerpreferences_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customerpreferences`
--

LOCK TABLES `customerpreferences` WRITE;
/*!40000 ALTER TABLE `customerpreferences` DISABLE KEYS */;
INSERT INTO `customerpreferences` VALUES (1,1,0,'Nuts'),(2,0,1,'Dairy,Gluten'),(3,0,0,'Shellfish'),(4,1,1,'Soy'),(5,0,0,'Gluten,Nuts'),(6,0,0,NULL),(7,1,1,'Soy,Dairy'),(8,0,0,'Shellfish,Soy'),(9,0,0,'Shellfish,Nuts'),(10,0,1,'Nuts'),(11,0,0,'Dairy'),(12,0,0,'Shellfish'),(13,0,0,''),(14,1,1,NULL),(15,0,0,'Soy'),(16,1,1,'Dairy'),(17,0,0,'Gluten'),(18,1,0,NULL),(19,0,1,'Nuts,Soy'),(20,1,1,'Shellfish');
/*!40000 ALTER TABLE `customerpreferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `CustomerID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  `Email` varchar(255) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  `Address` varchar(255) DEFAULT NULL,
  `Password` varchar(255) NOT NULL,
  `PermissionLevel` int DEFAULT '1',
  `reset_token` varchar(255) DEFAULT NULL,
  `reset_token_expiration` datetime DEFAULT NULL,
  PRIMARY KEY (`CustomerID`),
  UNIQUE KEY `Email` (`Email`),
  UNIQUE KEY `Phone` (`Phone`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'Alice Smith','alice.smith@example.com','555-123-4567','123 Maple St, Springfield','$2b$10$AaFjOI8wq3AphMNXeXbJ3uPyHt0.5zWjB2BxYmBdp68XBL1PEHJMi',1,NULL,NULL),(2,'Bob Johnson','bob.johnson@example.com','555-234-5678','456 Oak St, Rivertown','$2b$10$Yt3BmULrQd8/68NlFxQgvuFnpld9tX3eBVXzsl9IpVX9bsIsDzxXa',1,NULL,NULL),(3,'Charlie Lee','charlie.lee@example.com','555-342-6789','789 Pine Ave, Hillview','$2b$10$fFYIEpOmMv7RhzRnbK9T2OtwKZ7Z.cCIJe.DqP3qFltIvyr6f2hPO',2,NULL,NULL),(4,'Diana Martinez','diana.martinez@example.com','555-456-7890','101 Birch Blvd, Lakeside','$2b$10$90s.QjsmXowXO5.oCDpETe6PGSVoB72A7r/EyIslxh5yo5wvTzUAG',1,NULL,NULL),(5,'Ethan Brown','ethan.brown@example.com','555-567-8901','202 Cedar St, Woodland','$2b$10$BfIPW6mThDFZ1HwXmt6DXOFhJ2piEg/5kLR0.Ho.bhxRMK/0y4v9i',1,NULL,NULL),(6,'Fiona White','fiona.white@example.com','555-678-9012','303 Willow Rd, Meadowbrook','$2b$10$Ccz2bbFHH8.ehZs/BJpDkeqZTlV1w66vrXBp5oaCZ.UyCFg1oiuQe',2,NULL,NULL),(7,'George Davis','george.davis@example.com','555-789-0123','404 Elm St, Riverbend','$2b$10$FpHfHaXqBQvQjV4AWCHe1O8TZaeOcbFTsSTaP8NJyDSqV99B5BW5a',1,NULL,NULL),(8,'Hannah Clark','hannah.clark@example.com','555-890-1234','505 Aspen Ln, Valleyview','$2b$10$d5bTLZZcPvT8g9HY9zBOheZoQ9Hbt57o7mUvMeFcXxtJUsC0IhnkO',1,NULL,NULL),(9,'Nicholas Bergeron','nbergeron1@laurentian.ca','1112223452','123 Main St','$2b$10$.lC.gw06.1bFec74PsKlXOIIsCaKTG2wt1F6YSv0O0zLaNjt30sZq',2,'178f1a1415d9bb79f6926dba4cf0531511dc221d','2024-11-18 03:08:02'),(10,'Julia Walker','julia.walker@example.com','555-012-3456','707 Chestnut Ct, Greenfield','$2b$10$h7kTlpE/m7RuQXxDjQwQkuGLX.G5ThkWQpXLS9KNdX3V7pH9VwEFq',1,NULL,NULL),(11,'Kyle Harris','kyle.harris@example.com','555-123-7567','808 Redwood St, Mountainview','$2b$10$T9F88O9Cv2JjzXDKphTFOuOucZfIhyCbWv0L3W17pMWCgBVyg8rbS',1,NULL,NULL),(12,'Laura Adams','laura.adams@example.com','555-234-5278','909 Sycamore Ave, Hillside','$2b$10$k7FgCQEIOmpNzgWBY/yOBbIji1eLlF5eTu1ZZKK0TxTcuk8u2rdta',1,NULL,NULL),(13,'Aman Kahlon','akahlon1@laurentian.ca','7056751151','935 Ramsey Lake Road','$2b$10$qSpJz6rH2VDFGHMK9qyVmutzLC3wkY2UiSbY95nZ.XoLCYBHJKnNO',2,NULL,NULL),(14,'Nina Perez','nina.perez@example.com','555-452-7890','1111 Spruce Rd, Clearview','$2b$10$GL8V21ebJp7ly6Ak.t/CRu5IsHGStPC6QVVgy/rOlKX6et8VIoQTa',1,NULL,NULL),(15,'Oscar Ramirez','oscar.ramirez@example.com','555-227-8901','1212 Fir St, Forestwood','$2b$10$gI.1hAKyERJTkDOcYtzZhOpHKfx9rK9TVEb2y1k6fQKc7VpP4HgCG',1,NULL,NULL),(16,'Paula King','paula.king@example.com','555-688-9012','1313 Magnolia Ct, Brookfield','$2b$10$5.KHZQoVzOmP9XSc2chZg.9Ll.zqYltfAdEKg9HDHKpm9o0z9VRy6',2,NULL,NULL),(17,'Quinn Mitchell','quinn.mitchell@example.com','555-789-9123','1414 Poplar Ave, Oakridge','$2b$10$DN3GyckFf8MI59F9lf.K1ehDCnMA2OETuvC5YzRCLziwPmn8jrhVO',1,NULL,NULL),(18,'Rachel Allen','rachel.allen@example.com','555-890-1224','1515 Walnut Blvd, Sunset','$2b$10$fNbTaAvb2vL2hyyh3PsBaeYmRP9lNx3qYdLPjLY0Xh2idLuG2e8Fi',1,NULL,NULL),(19,'Isaac Lewis','isaac.lewis@example.com','555-901-2345','606 Alder Dr, Ridgewood','$2b$10$xOpQOJjoHFmWENcLP7hYEuDdGRmOVBY8UuC.H8TLVGTV9lzq4N3xC',2,NULL,NULL),(20,'Michael Robinson','michael.robinson@example.com','555-345-6789','1010 Hickory Ln, Westwood','$2b$10$OgPzL2BQyHEhnP/rIFHGTe8UpiqzN4JbDVxROt2szMB/aV6OQJfyK',1,NULL,NULL);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deals`
--

DROP TABLE IF EXISTS `deals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deals` (
  `DealID` int NOT NULL AUTO_INCREMENT,
  `Title` varchar(255) NOT NULL,
  `Description` text NOT NULL,
  `MenuID` int DEFAULT NULL,
  `Discount` float NOT NULL,
  `ValidUntil` date NOT NULL,
  PRIMARY KEY (`DealID`),
  UNIQUE KEY `Title_UNIQUE` (`Title`),
  KEY `deals_ibfk_1` (`MenuID`),
  CONSTRAINT `deals_ibfk_1` FOREIGN KEY (`MenuID`) REFERENCES `menu` (`MenuID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deals`
--

LOCK TABLES `deals` WRITE;
/*!40000 ALTER TABLE `deals` DISABLE KEYS */;
INSERT INTO `deals` VALUES (1,'Fettucinni Deal','Get 20% off Fettucinni',1,0.2,'2024-12-31'),(2,'Vegetarian Pizza Deal','Enjoy 15% off on Vegetarian Pizza',2,0.15,'2024-12-25'),(3,'Vegan Salad Deal','Save 10% on Vegan Salad',3,0.1,'2024-11-30'),(4,'Margherita Pizza Deal','Margherita Pizza at a 25% discount',2,0.25,'2024-12-15'),(5,'Pepperoni Pizza Deal','Buy Pepperoni Pizza with a 20% discount',2,0.2,'2024-12-10'),(6,'BBQ Chicken Pizza Deal','BBQ Chicken Pizza at 15% off',2,0.15,'2024-11-20'),(7,'Caesar Salad Deal','Caesar Salad for 10% off',3,0.1,'2024-12-05'),(8,'Greek Salad Deal','Save 12% on Greek Salad',3,0.12,'2024-11-22'),(9,'Caprese Salad Deal','Caprese Salad with a 5% discount',3,0.05,'2024-11-18'),(10,'Tiramisu Deal','Get 20% off Tiramisu dessert',4,0.2,'2024-12-25'),(11,'Chocolate Lava Cake Deal','Chocolate Lava Cake with 15% off',4,0.15,'2024-12-18'),(12,'Cheesecake Deal','Enjoy 10% off Cheesecake',4,0.1,'2024-12-01'),(13,'Lasagna Deal','Get 25% off Lasagna',1,0.25,'2024-11-30'),(14,'Veggie Pizza Deal','Veggie Pizza at a 10% discount',2,0.1,'2024-11-23'),(15,'Spinach Salad Deal','Spinach Salad with 15% off',3,0.15,'2024-12-10'),(16,'Classic Lemonade Deal','Get 10% off Classic Lemonade',5,0.1,'2024-11-27'),(17,'Iced Coffee Deal','Iced Coffee with a 20% discount',5,0.2,'2024-11-30'),(18,'Green Tea Deal','Save 5% on Green Tea',5,0.05,'2024-12-05'),(19,'Berry Smoothie Deal','Berry Smoothie at 15% off',5,0.15,'2024-12-20'),(20,'Sparkling Water Deal','Sparkling Water for 10% off',5,0.1,'2024-12-15');
/*!40000 ALTER TABLE `deals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dishreview`
--

DROP TABLE IF EXISTS `dishreview`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dishreview` (
  `ReviewID` int NOT NULL AUTO_INCREMENT,
  `MenuID` int NOT NULL,
  `CustomerID` int DEFAULT NULL,
  `Rating` int NOT NULL,
  `Comment` text,
  `ReviewDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ReviewID`),
  KEY `dishreview_ibfk_1` (`MenuID`),
  KEY `dishreview_ibfk_2` (`CustomerID`),
  CONSTRAINT `dishreview_ibfk_1` FOREIGN KEY (`MenuID`) REFERENCES `menu` (`MenuID`) ON DELETE CASCADE,
  CONSTRAINT `dishreview_ibfk_2` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dishreview`
--

LOCK TABLES `dishreview` WRITE;
/*!40000 ALTER TABLE `dishreview` DISABLE KEYS */;
INSERT INTO `dishreview` VALUES (1,5,3,4,'Loved the flavors, especially the spice balance.','2024-11-10 08:12:47'),(2,10,7,3,'Good but a bit salty for my taste.','2024-11-12 14:25:05'),(3,15,12,5,'Absolutely delicious! Highly recommend.','2024-11-08 10:37:22'),(4,8,6,2,'Did not enjoy it much; too bland.','2024-11-11 20:43:55'),(5,20,1,5,'Refreshing and perfect for a hot day!','2024-11-09 16:17:32'),(6,2,9,4,'Nice texture and flavor.','2024-11-13 09:05:11'),(7,7,14,3,'Decent, but could use more seasoning.','2024-11-14 11:22:48'),(8,16,20,5,'Amazing drink! Just the right sweetness.','2024-11-10 18:29:07'),(9,12,11,4,'Good portion size and tasty.','2024-11-12 07:18:36'),(10,18,4,5,'Very refreshing and healthy.','2024-11-09 21:40:23'),(11,1,19,3,'Average, not very memorable.','2024-11-08 16:45:51'),(12,3,15,5,'Great dish! I will order again.','2024-11-10 22:15:58'),(13,9,8,2,'Too spicy for me.','2024-11-07 13:04:04'),(14,13,17,4,'Good presentation and flavors.','2024-11-13 19:39:12'),(15,6,5,1,'Terrible, wouldn’t recommend.','2024-11-08 08:53:09'),(16,4,10,4,'Really enjoyed this dish.','2024-11-11 14:38:44'),(17,11,2,3,'Not bad but could be better.','2024-11-14 10:27:16'),(18,14,13,5,'One of the best I’ve had.','2024-11-07 17:50:31'),(19,16,18,4,'Simple and tasty.','2024-11-13 12:11:04'),(20,17,4,5,'Perfectly brewed, loved it.','2024-11-10 23:59:59'),(21,5,7,2,'Too much oil, not great.','2024-11-12 18:23:17'),(22,10,1,3,'Decent but nothing special.','2024-11-09 10:02:03'),(23,15,12,5,'Really enjoyed this. Well done!','2024-11-13 20:04:55'),(24,8,3,4,'Good balance of flavors.','2024-11-07 09:16:43'),(25,20,6,5,'Refreshing and light.','2024-11-11 15:47:29'),(26,2,14,3,'It was okay.','2024-11-08 11:35:14'),(27,7,9,4,'Great portion size and taste.','2024-11-10 17:05:55'),(28,16,11,5,'Loved it! Will try again.','2024-11-09 13:23:28'),(29,12,20,3,'Good but not my favorite.','2024-11-14 08:47:52'),(30,18,4,5,'Healthy and flavorful.','2024-11-10 06:55:41');
/*!40000 ALTER TABLE `dishreview` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `location`
--

DROP TABLE IF EXISTS `location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `location` (
  `LocationID` int NOT NULL AUTO_INCREMENT,
  `Address` varchar(255) NOT NULL,
  `City` varchar(100) NOT NULL,
  `Province` varchar(100) NOT NULL,
  `ZipCode` varchar(10) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  PRIMARY KEY (`LocationID`),
  UNIQUE KEY `Phone_UNIQUE` (`Phone`),
  UNIQUE KEY `Address_UNIQUE` (`Address`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `location`
--

LOCK TABLES `location` WRITE;
/*!40000 ALTER TABLE `location` DISABLE KEYS */;
INSERT INTO `location` VALUES (1,'123 Maple St','Cityville','ON','K9L 3S2','555-322-4567'),(2,'456 Oak Ave','Townville','ON','A2B 8L0','555-112-4567'),(3,'789 Pine Rd','Villagetown','ON','B1C 3D4','555-567-4567'),(4,'123 Birch Rd','Springfield','ON','A1B 2C3','555-123-4567'),(5,'456 Maple St','Rivertown','BC','B2C 3D4','555-234-5678'),(6,'789 Cedar Ave','Hillview','AB','C3D 4E5','555-345-6789'),(7,'101 Oak Ln','Lakeside','QC','D4E 5F6','555-456-7890'),(8,'202 Willow Dr','Woodland','NS','E5F 6G7','555-567-8901'),(9,'303 Elm Ct','Meadowbrook','MB','F6G 7H8','555-678-9012'),(10,'404 Aspen Blvd','Riverbend','SK','G7H 8I9','555-789-0123'),(11,'505 Chestnut Way','Valleyview','NL','H8I 9J0','555-890-1234'),(12,'606 Spruce Rd','Ridgewood','PE','I9J 0K1','555-901-2345'),(13,'707 Fir St','Greenfield','YT','J0K 1L2','555-012-3456'),(14,'808 Redwood Ave','Mountainview','NT','K1L 2M3','555-113-4567'),(15,'909 Hickory Blvd','Hillside','NU','L2M 3N4','555-214-5678'),(16,'1010 Alder Ln','Westwood','NB','M3N 4O5','555-315-6789'),(17,'1111 Magnolia St','Clearview','ON','N4O 5P6','555-416-7890'),(18,'1212 Poplar Dr','Forestwood','BC','O5P 6Q7','555-517-8901'),(19,'1313 Walnut Ct','Brookfield','AB','P6Q 7R8','555-618-9012');
/*!40000 ALTER TABLE `location` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu`
--

DROP TABLE IF EXISTS `menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu` (
  `MenuID` int NOT NULL AUTO_INCREMENT,
  `CategoryID` int NOT NULL,
  `Name` varchar(255) NOT NULL,
  `Description` text NOT NULL,
  `Price` float NOT NULL,
  `Image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`MenuID`),
  UNIQUE KEY `Name_UNIQUE` (`Name`),
  KEY `CategoryID_idx` (`CategoryID`),
  CONSTRAINT `CategoryID` FOREIGN KEY (`CategoryID`) REFERENCES `categories` (`CategoryId`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu`
--

LOCK TABLES `menu` WRITE;
/*!40000 ALTER TABLE `menu` DISABLE KEYS */;
INSERT INTO `menu` VALUES (1,1,'Fettucinni','Classic Italian pasta dish with creamy sauce and bacon.',6.69,'https://img.freepik.com/free-photo/bowl-pasta-with-parmesan-cheese_1340-25573.jpg'),(2,2,'Vegetarian Pizza','Pizza topped with mixed vegetables and cheese.',9.99,'https://img.freepik.com/free-photo/delicious-pizza-served-wooden-table_23-2147926042.jpg'),(3,3,'Vegan Salad','A fresh salad with mixed greens, avocado, and a lemon vinaigrette.',8.99,'https://img.freepik.com/free-photo/buckwheat-salad-with-cherry-tomatoes-red-onion-fresh-herbs-vegan-food-diet-menu_2829-6446.jpg'),(4,2,'Margherita Pizza','Classic pizza topped with fresh mozzarella, tomatoes, and basil.',9.99,'https://img.freepik.com/free-photo/homemade-vegan-margherita-pizza-food-photography_53876-63238.jpg'),(5,2,'Pepperoni Pizza','Pizza topped with spicy pepperoni slices and mozzarella cheese.',10.99,'https://img.freepik.com/free-photo/pepperoni-pizza-with-herbs-top_141793-902.jpg'),(6,2,'BBQ Chicken Pizza','Pizza with BBQ sauce, chicken, red onions, and cilantro.',11.99,'https://img.freepik.com/free-photo/pizza-with-sausages-tomato-cheese-olives-pepper_141793-17551.jpg'),(7,3,'Caesar Salad','Crisp romaine lettuce, croutons, and Caesar dressing.',8.99,'https://img.freepik.com/free-photo/top-view-caesar-salad-oval-plate-green-white-checkered-tablecloth-dark-red-background_140725-124913.jpg'),(8,3,'Greek Salad','Mixed greens with feta cheese, olives, and a tangy vinaigrette.',9.49,'https://img.freepik.com/free-photo/greek-salad-with-cucumber-tomato-sweet-pepper-lettuce-green-onion-feta-cheese-olives-with-olive-oil-healthy-food_2829-19693.jpg'),(9,3,'Caprese Salad','Fresh mozzarella, tomatoes, basil, and balsamic reduction.',10.49,'https://img.freepik.com/free-photo/italian-caprese-salad-with-tomatoes-basil-mozzarella-olives-olive-oil-wooden-board-italian-traditional-caprese-salad-ingredients-mediterranean-organic-natural-food-concept_1150-44847.jpg'),(10,4,'Tiramisu','Classic Italian dessert with layers of coffee-soaked ladyfingers and mascarpone.',6.99,'https://img.freepik.com/free-photo/tiramisu-with-mascarpone-cheese-chocolate-plate_140725-11024.jpg'),(11,4,'Chocolate Lava Cake','Warm chocolate cake with a molten center, served with vanilla ice cream.',7.49,'https://img.freepik.com/free-photo/chocolate-lava-cake-white-plate_1150-6317.jpg'),(12,4,'Cheesecake','Rich and creamy cheesecake with a graham cracker crust.',6.49,'https://img.freepik.com/free-photo/slice-new-york-cheesecake_1232-2131.jpg'),(13,1,'Lasagna','Layered pasta with meat, cheese, and marinara sauce.',14.99,'https://img.freepik.com/free-photo/classic-lasagna-with-bolognese-sauce_2829-14066.jpg'),(14,2,'Veggie Pizza','Pizza topped with bell peppers, mushrooms, and onions.',10.49,'https://img.freepik.com/free-photo/pizza-food-food_144627-38484.jpg'),(15,3,'Spinach Salad','Fresh spinach with cranberries, walnuts, and goat cheese.',9.99,'https://img.freepik.com/free-photo/mushroom-salad-with-green-beans-eggs_2829-3916.jpg'),(16,5,'Classic Lemonade','Refreshing lemonade made with freshly squeezed lemons and a hint of mint.',3.5,'https://img.freepik.com/free-photo/refreshing-drink_144627-25605.jpg'),(17,5,'Iced Coffee','Cold brew coffee served with cream or milk.',4,'https://img.freepik.com/free-photo/cold-coffee_144627-22086.jpg'),(18,5,'Green Tea','Organic green tea brewed to perfection.',2.75,'https://img.freepik.com/free-photo/leaf-plate-wood-object-healthy-eating_1172-451.jpg'),(19,5,'Berry Smoothie','A blend of fresh strawberries, blueberries, and raspberries.',5,'https://img.freepik.com/free-photo/high-angle-glasses-with-smoothie_23-2148751825.jpg'),(20,5,'Sparkling Water','Chilled sparkling water with a choice of lime or lemon twist.',2.5,'https://img.freepik.com/free-photo/glass-table_144627-8856.jpg');
/*!40000 ALTER TABLE `menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menuattributes`
--

DROP TABLE IF EXISTS `menuattributes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menuattributes` (
  `MenuID` int NOT NULL,
  `Ingredients` text NOT NULL,
  `NutritionalInfo` text,
  `IsVegan` tinyint(1) NOT NULL,
  `IsVegetarian` tinyint(1) NOT NULL,
  `AllergyInfo` varchar(255) DEFAULT NULL,
  `SpiceLevel` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`MenuID`),
  CONSTRAINT `menuattributes_ibfk_1` FOREIGN KEY (`MenuID`) REFERENCES `menu` (`MenuID`)
);

INSERT INTO `menuattributes` VALUES (1,'Dough, Tomato Sauce, Cheese, Pepperoni','Calories: 800, Fat: 35g',0,0,'Gluten, Dairy',''),(2,'Dough, Tomato Sauce, Cheese, Vegetables','Calories: 500, Fat: 20g',0,1,'Gluten',''),(3,'Pasta, Cream Sauce, Chicken, Cheese','Calories: 700, Fat: 30g',0,0,'Dairy, Gluten',NULL),(4,'Pizza Dough, Mozzarella, Tomato, Basil','Calories: 400, Fat: 15g',1,1,'Gluten, Dairy',NULL),(5,'Pizza Dough, Pepperoni, Mozzarella','Calories: 450, Fat: 20g',0,0,'Gluten, Dairy',NULL),(6,'Pizza Dough, Chicken, BBQ Sauce, Cheese','Calories: 600, Fat: 25g',0,0,'Gluten, Dairy','Mild'),(7,'Romaine, Croutons, Caesar Dressing','Calories: 300, Fat: 20g',0,1,'Gluten, Dairy',NULL),(8,'Mixed Greens, Feta, Olives, Vinaigrette','Calories: 250, Fat: 10g',1,1,'Dairy',NULL),(9,'Mozzarella, Tomatoes, Basil, Balsamic','Calories: 150, Fat: 10g',1,1,'Dairy',NULL),(10,'Ladyfingers, Coffee, Mascarpone','Calories: 350, Fat: 15g',0,1,'Gluten, Dairy',NULL),(11,'Chocolate, Flour, Eggs, Butter','Calories: 450, Fat: 25g',0,0,'Gluten, Dairy',NULL),(12,'Cream Cheese, Sugar, Crust','Calories: 400, Fat: 20g',0,1,'Gluten, Dairy',NULL),(13,'Lasagna Noodles, Meat, Cheese, Sauce','Calories: 800, Fat: 30g',0,0,'Gluten, Dairy',NULL),(14,'Pizza Dough, Bell Peppers, Mushrooms','Calories: 350, Fat: 10g',1,1,'Gluten, Dairy',NULL),(15,'Spinach, Cranberries, Walnuts, Goat Cheese','Calories: 300, Fat: 20g',1,1,'Nuts',NULL),(16,'Lemon, Sugar, Water, Mint','Calories: 120, Sugar: 25g, Fat: 0g',1,1,'',''),(17,'Coffee, Ice, Milk or Cream','Calories: 80, Sugar: 2g, Fat: 3g',0,1,'Dairy',''),(18,'Green Tea Leaves, Water','Calories: 0, Sugar: 0g, Fat: 0g',1,1,'',''),(19,'Strawberries, Blueberries, Raspberries, Yogurt, Honey','Calories: 150, Sugar: 18g, Fat: 1g',0,1,'Dairy',''),(20,'Carbonated Water, Lime or Lemon','Calories: 0, Sugar: 0g, Fat: 0g',1,1,'','');

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `OrderID` int NOT NULL AUTO_INCREMENT,
  `OrderDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `OrderStatus` varchar(50) NOT NULL,
  `OrderData` varchar(255) DEFAULT NULL,
  `TotalAmount` float NOT NULL,
  `CustomerID` int DEFAULT NULL,
  `LocationID` int NOT NULL,
  `OrderType` varchar(50) NOT NULL DEFAULT 'Dine-In',
  `GuestID` varchar(19) DEFAULT NULL,
  PRIMARY KEY (`OrderID`),
  KEY `orders_ibfk_1` (`CustomerID`),
  KEY `orders_ibfk_2` (`LocationID`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customers` (`CustomerID`) ON DELETE CASCADE,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`LocationID`) REFERENCES `location` (`LocationID`) ON DELETE CASCADE
);

INSERT INTO `orders` VALUES (24,'2024-11-18 15:27:02','Completed','[{\"title\":\"Lasagna\",\"price\":14.99,\"count\":1},{\"title\":\"Lasagna\",\"price\":14.99,\"count\":1},{\"title\":\"Lasagna\",\"price\":14.99,\"count\":1},{\"title\":\"Lasagna\",\"price\":14.99,\"count\":1}]',14.99,9,1,'Dine In',NULL),(25,'2024-11-18 15:27:08','Completed','[{\"title\":\"Chocolate Lava Cake\",\"price\":7.49,\"count\":1}]',7.49,9,1,'Dine In',NULL),(26,'2024-11-18 15:28:02','Completed','[{\"title\":\"Cheesecake\",\"price\":6.49,\"count\":2}]',12.98,9,1,'Dine In',NULL),(28,'2024-11-18 15:59:57','Completed','[{\"title\":\"Lasagna\",\"price\":14.99,\"count\":1}]',14.99,9,3,'Dine In',NULL),(39,'2024-11-18 03:05:55','Completed','[{\"title\":\"Lasagna\",\"price\":14.99,\"count\":1}]',14.99,9,1,'Dine In',NULL),(40,'2024-11-18 03:53:59','Completed','[{\"title\":\"Chocolate Lava Cake\",\"price\":7.49,\"count\":1}]',7.49,9,1,'Dine In',NULL),(41,'2024-11-24 21:21:34','Completed','[{\"title\":\"Fettucinni\",\"price\":6.69,\"count\":1},{\"title\":\"Lasagna\",\"price\":14.99,\"count\":1}]',21.68,13,1,'Dine In',NULL),(42,'2024-11-24 22:01:47','Completed','[{\"title\":\"Fettucinni\",\"price\":6.69,\"count\":1}]',6.69,13,1,'Dine In',NULL),(43,'2024-11-25 00:57:26','Pending','[{\"title\":\"Fettucinni\",\"price\":6.69,\"count\":1}]',6.69,13,2,'Take Out',NULL),(44,'2024-11-25 02:02:39','Pending','[{\"title\":\"Fettucinni\",\"price\":6.69,\"count\":1}]',6.69,NULL,1,'Dine In','b754-ce8f-40ee-77ec'),(45,'2024-11-27 02:07:02','Completed','[{\"title\":\"Vegetarian Pizza\",\"price\":9.99,\"count\":2}]',19.98,9,1,'Dine In',NULL),(46,'2024-11-27 02:07:08','Pending','[{\"title\":\"Lasagna\",\"price\":14.99,\"count\":1}]',14.99,9,1,'Dine In',NULL),(47,'2024-11-27 02:07:18','Completed','[{\"title\":\"Chocolate Lava Cake\",\"price\":7.49,\"count\":1},{\"title\":\"Tiramisu\",\"price\":6.99,\"count\":2}]',21.47,9,1,'Dine In',NULL),(48,'2024-11-25 12:34:00','Completed','[{\"title\":\"Chocolate Lava Cake\",\"price\":7.49,\"count\":1},{\"title\":\"Tiramisu\",\"price\":6.99,\"count\":2}]',21.47,5,1,'Dine-In',NULL),(49,'2024-11-26 14:50:00','Pending','[{\"title\":\"BBQ Chicken Pizza\",\"price\":9.99,\"count\":1},{\"title\":\"Caesar Salad\",\"price\":5.49,\"count\":1}]',15.48,NULL,2,'Takeout','b754-ce8f-40ee-77ec'),(50,'2024-11-24 16:15:00','Completed','[{\"title\":\"Pepperoni Pizza\",\"price\":8.99,\"count\":2}]',17.98,3,3,'Dine-In',NULL),(51,'2024-11-25 13:20:00','Cancelled','[{\"title\":\"Vegan Salad\",\"price\":6.99,\"count\":1},{\"title\":\"Greek Salad\",\"price\":5.99,\"count\":1}]',12.98,NULL,4,'Takeout','b754-ce8f-40ee-77ec'),(52,'2024-11-26 18:00:00','Completed','[{\"title\":\"Lasagna\",\"price\":10.99,\"count\":1}]',10.99,1,5,'Delivery',NULL),(53,'2024-11-24 12:30:00','Pending','[{\"title\":\"Tiramisu\",\"price\":6.99,\"count\":1},{\"title\":\"Caprese Salad\",\"price\":7.49,\"count\":1}]',14.48,NULL,1,'Dine-In','b754-ce8f-40ee-77ec'),(54,'2024-11-25 19:45:00','Completed','[{\"title\":\"BBQ Chicken Pizza\",\"price\":9.99,\"count\":1},{\"title\":\"Spinach Salad\",\"price\":5.99,\"count\":1}]',15.98,7,2,'Takeout',NULL),(55,'2024-11-26 15:30:00','Completed','[{\"title\":\"Vegetarian Pizza\",\"price\":7.99,\"count\":1}]',7.99,NULL,3,'Dine-In','b754-ce8f-40ee-77ec'),(56,'2024-11-25 20:00:00','Cancelled','[{\"title\":\"Margherita Pizza\",\"price\":8.49,\"count\":1},{\"title\":\"Green Tea\",\"price\":3.49,\"count\":2}]',15.47,4,1,'Takeout',NULL),(57,'2024-11-24 11:00:00','Completed','[{\"title\":\"Pepperoni Pizza\",\"price\":8.99,\"count\":1},{\"title\":\"Cheesecake\",\"price\":5.99,\"count\":1}]',14.98,9,4,'Dine-In',NULL),(58,'2024-11-25 16:00:00','Pending','[{\"title\":\"Caesar Salad\",\"price\":5.49,\"count\":1},{\"title\":\"Classic Lemonade\",\"price\":2.49,\"count\":1}]',7.98,NULL,5,'Delivery','b754-ce8f-40ee-77ec'),(59,'2024-11-24 10:45:00','Completed','[{\"title\":\"Greek Salad\",\"price\":7.49,\"count\":1},{\"title\":\"Berry Smoothie\",\"price\":4.99,\"count\":1}]',12.48,2,2,'Takeout',NULL),(60,'2024-11-26 17:10:00','Completed','[{\"title\":\"Lasagna\",\"price\":10.99,\"count\":2}]',21.98,6,3,'Dine-In',NULL),(61,'2024-11-25 13:40:00','Pending','[{\"title\":\"Chocolate Lava Cake\",\"price\":7.49,\"count\":1},{\"title\":\"Caprese Salad\",\"price\":7.49,\"count\":1}]',14.98,NULL,6,'Delivery','b754-ce8f-40ee-77ec'),(62,'2024-11-26 14:10:00','Cancelled','[{\"title\":\"Vegan Salad\",\"price\":6.99,\"count\":1}]',6.99,3,4,'Takeout',NULL);

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `PaymentID` int NOT NULL AUTO_INCREMENT,
  `PaymentDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Amount` float NOT NULL,
  `Tip` float DEFAULT NULL,
  `PaymentMethod` varchar(50) NOT NULL,
  `OrderID` int NOT NULL,
  PRIMARY KEY (`PaymentID`),
  KEY `payment_ibfk_1` (`OrderID`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`OrderID`) REFERENCES `orders` (`OrderID`)
);

INSERT INTO `payment` VALUES (4,'2024-11-15 00:00:00',14.99,2.2485,'cash',24),(5,'2024-11-18 00:00:00',7.49,1.1235,'credit_card',25),(6,'2024-11-25 19:00:00',21.47,2,'credit_card',48),(7,'2024-11-26 14:05:00',15.48,1.5,'cash',49),(8,'2024-11-24 16:25:00',17.98,1.8,'debit',50),(9,'2024-11-25 13:40:00',12.98,2,'credit_card',51),(10,'2024-11-26 18:15:00',10.99,1.5,'cash',52),(11,'2024-11-24 12:40:00',14.48,1,'debit',53),(12,'2024-11-25 19:55:00',15.98,2,'credit_card',54),(13,'2024-11-26 15:30:00',7.99,1,'cash',55),(14,'2024-11-25 20:20:00',15.47,2.5,'credit_card',56),(15,'2024-11-24 11:30:00',14.98,1.5,'debit',57),(16,'2024-11-25 14:00:00',9.99,1.2,'cash',58),(17,'2024-11-26 16:10:00',22.49,2.8,'credit_card',59),(18,'2024-11-24 17:30:00',13.88,1.9,'debit',60),(19,'2024-11-25 12:00:00',18.99,2.1,'cash',61),(20,'2024-11-26 13:45:00',19.49,2.3,'credit_card',62);

--
-- Table structure for table `reservation`
--

CREATE TABLE `reservation` (
  `ReservationID` int NOT NULL AUTO_INCREMENT,
  `Phone` varchar(15) NOT NULL,
  `ReservationDate` date NOT NULL,
  `ReservationTime` time NOT NULL,
  `NumberOfGuests` int NOT NULL,
  `Notes` text,
  `LocationID` int DEFAULT NULL,
  PRIMARY KEY (`ReservationID`),
  KEY `reservation_ibfk_1` (`LocationID`)
);

INSERT INTO `reservation` VALUES (1,'1234567890','2024-12-01','18:30:00',2,'Anniversary celebration',1),(3,'5556667777','2024-12-10','19:00:00',6,'Birthday party',3),(4,'1112223333','2024-12-15','20:30:00',3,'Quiet corner requested',1),(5,'4445556666','2024-12-20','13:00:00',8,'Business lunch',2),(6,'7778889999','2024-12-25','17:00:00',5,'Christmas dinner',3),(7,'9998887777','2024-12-31','22:00:00',10,'New Year’s Eve party',1),(8,'1231231234','2025-01-05','14:00:00',2,'Celebrating engagement',2),(9,'4564564567','2025-01-10','18:00:00',4,'Allergy-friendly seating',3),(10,'7897897890','2025-01-15','19:30:00',3,'Meeting with friends',1),(11,'3213213210','2025-01-20','20:00:00',2,'Romantic dinner',2),(12,'6546546541','2025-01-25','12:30:00',6,'Family gathering',3),(13,'9879879872','2025-02-01','16:00:00',5,'Celebrating promotion',1),(14,'1471471473','2025-02-10','18:30:00',7,'Friends reunion',2),(15,'2582582584','2025-02-15','21:00:00',12,'Valentine’s Day group dinner',3);
