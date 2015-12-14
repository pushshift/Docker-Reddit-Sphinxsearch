SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `reddit`
--
CREATE DATABASE IF NOT EXISTS `reddit` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `reddit`;

-- --------------------------------------------------------

--
-- Table structure for table `author`
--

CREATE TABLE IF NOT EXISTS `author` (
`author_id` int(10) unsigned NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `com_index`
--

CREATE TABLE IF NOT EXISTS `com_index` (
  `comment_id` bigint(20) unsigned NOT NULL,
  `created_utc` int(10) unsigned NOT NULL,
  `subreddit_id` int(10) unsigned NOT NULL,
  `link_id` int(10) unsigned NOT NULL,
  `author_id` int(10) unsigned NOT NULL,
  `score` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Reddit comment index table';

-- --------------------------------------------------------

--
-- Table structure for table `com_json`
--

CREATE TABLE IF NOT EXISTS `com_json` (
  `comment_id` bigint(20) unsigned NOT NULL COMMENT 'Comment id',
  `json` mediumtext CHARACTER SET utf8mb4 NOT NULL COMMENT 'Comment json'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Reddit comment bodies ';

-- --------------------------------------------------------

--
-- Table structure for table `link_count`
--

CREATE TABLE IF NOT EXISTS `link_count` (
  `link_id` bigint(20) unsigned NOT NULL,
  `count` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `link_index`
--

CREATE TABLE IF NOT EXISTS `link_index` (
  `link_id` int(10) unsigned NOT NULL,
  `created_utc` int(10) unsigned NOT NULL,
  `subreddit_id` int(10) unsigned NOT NULL,
  `author_id` int(10) unsigned NOT NULL,
  `score` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Reddit comment index table';

-- --------------------------------------------------------

--
-- Table structure for table `link_json`
--

CREATE TABLE IF NOT EXISTS `link_json` (
  `link_id` bigint(20) unsigned NOT NULL COMMENT 'Comment id',
  `json` mediumtext CHARACTER SET utf8mb4 NOT NULL COMMENT 'Comment json'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Reddit comment bodies ';

-- --------------------------------------------------------

--
-- Table structure for table `log`
--

CREATE TABLE IF NOT EXISTS `log` (
`log_id` int(10) unsigned NOT NULL,
  `created_utc` int(10) unsigned NOT NULL,
  `source` varchar(32) NOT NULL,
  `severity` enum('debug','info','notice','warning','error','critical','alert','emergency') NOT NULL DEFAULT 'info',
  `message` mediumtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `subreddit`
--

CREATE TABLE IF NOT EXISTS `subreddit` (
  `subreddit_id` int(10) unsigned NOT NULL COMMENT 'Subreddit id',
  `name` varchar(32) NOT NULL COMMENT 'Subreddit name'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Reddit subreddits';

-- --------------------------------------------------------

--
-- Table structure for table `time_day`
--

CREATE TABLE IF NOT EXISTS `time_day` (
  `created_utc` int(10) unsigned NOT NULL,
  `comment_count` int(10) unsigned DEFAULT NULL,
  `link_count` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_hour`
--

CREATE TABLE IF NOT EXISTS `time_hour` (
  `created_utc` int(10) unsigned NOT NULL,
  `comment_count` mediumint(5) unsigned DEFAULT NULL,
  `link_count` mediumint(5) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_link_hour`
--

CREATE TABLE IF NOT EXISTS `time_link_hour` (
  `created_utc` int(10) unsigned NOT NULL,
  `link_id` int(10) unsigned NOT NULL,
  `count` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_link_minute`
--

CREATE TABLE IF NOT EXISTS `time_link_minute` (
  `created_utc` int(10) unsigned NOT NULL,
  `link_id` int(10) unsigned NOT NULL,
  `count` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_link_second`
--

CREATE TABLE IF NOT EXISTS `time_link_second` (
  `created_utc` int(10) unsigned NOT NULL,
  `link_id` int(10) unsigned NOT NULL,
  `count` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_minute`
--

CREATE TABLE IF NOT EXISTS `time_minute` (
  `created_utc` int(10) unsigned NOT NULL,
  `comment_count` smallint(5) unsigned DEFAULT NULL,
  `link_count` smallint(5) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_second`
--

CREATE TABLE IF NOT EXISTS `time_second` (
  `created_utc` int(10) unsigned NOT NULL,
  `comment_count` smallint(5) unsigned DEFAULT NULL,
  `link_count` smallint(5) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_subreddit_day`
--

CREATE TABLE IF NOT EXISTS `time_subreddit_day` (
  `created_utc` int(10) unsigned NOT NULL,
  `subreddit_id` int(10) unsigned NOT NULL,
  `count` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_subreddit_hour`
--

CREATE TABLE IF NOT EXISTS `time_subreddit_hour` (
  `created_utc` int(10) unsigned NOT NULL,
  `subreddit_id` int(10) unsigned NOT NULL,
  `count` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_subreddit_minute`
--

CREATE TABLE IF NOT EXISTS `time_subreddit_minute` (
  `created_utc` int(10) unsigned NOT NULL,
  `subreddit_id` int(10) unsigned NOT NULL,
  `count` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `time_subreddit_second`
--

CREATE TABLE IF NOT EXISTS `time_subreddit_second` (
  `created_utc` int(10) unsigned NOT NULL,
  `subreddit_id` int(10) unsigned NOT NULL,
  `count` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `author`
--
ALTER TABLE `author`
 ADD PRIMARY KEY (`author_id`), ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `com_index`
--
ALTER TABLE `com_index`
 ADD PRIMARY KEY (`comment_id`), ADD KEY `score` (`score`), ADD KEY `link_id` (`link_id`), ADD KEY `subreddit_id` (`subreddit_id`), ADD KEY `created_utc` (`created_utc`), ADD KEY `author_id` (`author_id`);

--
-- Indexes for table `com_json`
--
ALTER TABLE `com_json`
 ADD PRIMARY KEY (`comment_id`);

--
-- Indexes for table `link_count`
--
ALTER TABLE `link_count`
 ADD PRIMARY KEY (`link_id`);

--
-- Indexes for table `link_index`
--
ALTER TABLE `link_index`
 ADD PRIMARY KEY (`link_id`), ADD KEY `score` (`score`), ADD KEY `subreddit_id` (`subreddit_id`), ADD KEY `created_utc` (`created_utc`), ADD KEY `author_id` (`author_id`);

--
-- Indexes for table `link_json`
--
ALTER TABLE `link_json`
 ADD PRIMARY KEY (`link_id`);

--
-- Indexes for table `log`
--
ALTER TABLE `log`
 ADD PRIMARY KEY (`log_id`), ADD KEY `created_utc` (`created_utc`), ADD KEY `severity` (`severity`), ADD KEY `source` (`source`);

--
-- Indexes for table `subreddit`
--
ALTER TABLE `subreddit`
 ADD PRIMARY KEY (`subreddit_id`), ADD KEY `subreddit-name` (`name`);

--
-- Indexes for table `time_day`
--
ALTER TABLE `time_day`
 ADD PRIMARY KEY (`created_utc`);

--
-- Indexes for table `time_hour`
--
ALTER TABLE `time_hour`
 ADD PRIMARY KEY (`created_utc`);

--
-- Indexes for table `time_link_hour`
--
ALTER TABLE `time_link_hour`
 ADD PRIMARY KEY (`created_utc`,`link_id`), ADD KEY `link_id` (`link_id`);

--
-- Indexes for table `time_link_minute`
--
ALTER TABLE `time_link_minute`
 ADD PRIMARY KEY (`created_utc`,`link_id`), ADD KEY `link_id` (`link_id`);

--
-- Indexes for table `time_link_second`
--
ALTER TABLE `time_link_second`
 ADD PRIMARY KEY (`created_utc`,`link_id`), ADD KEY `link_id` (`link_id`);

--
-- Indexes for table `time_minute`
--
ALTER TABLE `time_minute`
 ADD PRIMARY KEY (`created_utc`);

--
-- Indexes for table `time_second`
--
ALTER TABLE `time_second`
 ADD PRIMARY KEY (`created_utc`);

--
-- Indexes for table `time_subreddit_day`
--
ALTER TABLE `time_subreddit_day`
 ADD PRIMARY KEY (`created_utc`,`subreddit_id`), ADD KEY `subreddit_created_utc` (`subreddit_id`,`created_utc`);

--
-- Indexes for table `time_subreddit_hour`
--
ALTER TABLE `time_subreddit_hour`
 ADD PRIMARY KEY (`created_utc`,`subreddit_id`), ADD KEY `subreddit_created_utc` (`subreddit_id`,`created_utc`);

--
-- Indexes for table `time_subreddit_minute`
--
ALTER TABLE `time_subreddit_minute`
 ADD PRIMARY KEY (`created_utc`,`subreddit_id`), ADD KEY `subreddit_created_utc` (`subreddit_id`,`created_utc`);

--
-- Indexes for table `time_subreddit_second`
--
ALTER TABLE `time_subreddit_second`
 ADD PRIMARY KEY (`created_utc`,`subreddit_id`), ADD KEY `subreddit_created_utc` (`subreddit_id`,`created_utc`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `author`
--
ALTER TABLE `author`
MODIFY `author_id` int(10) unsigned NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `log`
--
ALTER TABLE `log`
MODIFY `log_id` int(10) unsigned NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
