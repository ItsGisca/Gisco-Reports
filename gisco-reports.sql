
CREATE TABLE IF NOT EXISTS `gisco_reports` (
  `reportnumber` int(11) DEFAULT NULL,
  `identifier` varchar(50) DEFAULT NULL,
  `state` varchar(10) DEFAULT NULL,
  `category` text DEFAULT NULL,
  `reason` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;