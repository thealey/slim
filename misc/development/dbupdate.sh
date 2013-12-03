mysql -uroot -pbondaxe -e 'drop database slim_development;'
mysql -uroot -pbondaxe -e 'create database slim_development;'
mysql -uroot -pbondaxe slim_development < slim.sql

