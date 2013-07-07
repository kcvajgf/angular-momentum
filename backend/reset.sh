#/bin/bash
sudo initctl stop flask
psql angular_momentum_db momentum < drop.sql
sudo initctl start flask
psql angular_momentum_db momentum < seed.sql
