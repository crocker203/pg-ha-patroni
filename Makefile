SHELL := /bin/bash

.PHONY: up destroy ssh consul db1 db2 inventory ping

up:
	vagrant up
	./generate_inventory.sh

destroy:
	vagrant destroy -f

ssh:
	vagrant ssh

consul:
	vagrant ssh consul

db1:
	vagrant ssh db1

db2:
	vagrant ssh db2

inventory:
	./generate_inventory.sh

ping:
	ansible all -m ping
