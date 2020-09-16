CREATE DATABASE IF NOT EXISTS workflowdb  DEFAULT CHARSET utf8;
CREATE USER 'everybim'@'%' IDENTIFIED BY 'YiZhu2018everybim!';
GRANT ALL PRIVILEGES ON workflowdb.* TO 'everybim'@'%';