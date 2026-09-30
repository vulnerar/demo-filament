#!/usr/bin/bash

php artisan schedule:clear-cache -n

php artisan optimize -n

php artisan migrate:fresh --seed --force -n

php artisan storage:link --force -n

