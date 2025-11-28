# ror_ready2deploy
### Ruby On Rails Application Ready To Deploy

> Ruby Version : 3.2.2

> Rails Version : 7.2.1.1

> Database : PostGreSQL

> OS : Debian 11 (15.8)

> Git : GitHub 

> Deploy with Capistrano

> Dev made on macOS

>[!NOTE]
>In this guide we consider you are using a brand new VPS install with no other project (especialy Ruby/RoR project). Following this guide could (*will*) break your other apps.


## Init
### Clone the repo

```
git clone git@github.com:vgauther/ror_ready2deploy.git
```

### Create your repo
Create a repo on GitHub (or GitLab). 
```
git clone {your_repo}
```

use this to transfer the data from ror_ready2deploy
```
rsync -av --exclude='.git' ~/path/to/this/repo/ror_ready2deploy/ ~/path/to/your/empty/git/your_repo
```

Than you must rename the project. We'll use a `gem` called `rename`
```
rails g rename:into rr2d-{your_repo} 
```

>[!NOTE]
> You can't rename the project by the name of your repo. That's why I add the prefix rr2d. Also, you'll rememeber where the project comes from.

It will rename the project in a lot of files/folder. You'll have to quit the repo `cd ..` than re-enter it `cd your_repo`

## Server Side

### Connect with SSH
```
ssh <user>@<vps_ip> 
```

### Create a 'Deploy User'
We need to create a user used to deploy the RoR App. Here, we'll call it `deploy` but, for security reason, you should change the name of the user.
```
sudo adduser deploy
usermod -aG sudo deploy
```
Connect to `deploy`
```
sudo -i -u deploy
```
Launch the script
```
bash <(wget -qO- https://cdn-nivo.com/wp-content/uploads/server_config.sh)
```

### Install and configure PostgreSQL
Access PostGres shell.
```
sudo -i -u postgres
```
Create a user with the interactive mode.
```
createuser --interactive
```

You can put any name you want you will need it once after this. I'll choose `p_sql_user`. 
Connect to the psql console.
```
psql
```
Set the database user password.
```
ALTER USER p_sql_user WITH PASSWORD 'new_password';
```
Quit the psql console.
```
exit
```
Create the database `ror_db`
```
createdb ror_db -O p_sql_user
```
Return to the `deploy` user.
```
exit
```
You can replace `ror_db` by anything you want. (You should change the name for security reasons) 


Open the file with your favorite editor. 
```
sudo vim /etc/postgresql/13/main/pg_hba.conf
```
Then change :
```
local   all             all                                     peer
```
by 

```
local   all             all                                     md5
```
Finaly, restart the PostGreSQL service.
```
sudo systemctl restart postgresql
```

## Setup NGINX

Do this to generate SSL Certificate for you domain name.
```
sudo certbot --nginx -d example.com
```

Then replace the `/etc/nginx/sites-available/default` with 
```
sudo vi /etc/nginx/sites-available/default
```
by this 
```nginx
# Configuration pour Puma
# Replace deploy by your user name
# Replace app_name by your app_name in the path and the socket name
upstream puma {
    server unix:///home/deploy/apps/app_name/shared/tmp/sockets/app_name-puma.sock;
}

# Bloc de redirection HTTP vers HTTPS
# Replace example.com www.example.com by your domain name
server {
    listen 80;
    server_name example.com www.example.com;

    # Redirige tout le trafic HTTP vers HTTPS
    # Redirige tout le trafic HTTP vers HTTPS
    return 301 https://$host$request_uri;
}

# Bloc HTTPS avec configuration SSL
# Replace example.com www.example.com by your domain name
# Replace app_name by your app name in ssl_certificate path
server {
    listen 443 ssl;
    server_name example.com www.example.com;

    # Configuration SSL Certbot
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    # Configuration de l'application
    location / {
        proxy_pass http://puma;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

Finaly, restart the PostGreSQL service.
```
sudo systemctl restart nginx
```

## Project Side

>[!NOTE]
>This project has been developped and tested on a VPS with Debian 11. The host provider was IONOS


### Setup
Now, you should be good to go.
Clone the repo on your computer.
```
cd {your_repo}
```
and 
```
bundle install
```

### Master.key
On your computer, generate a master.key
```
EDITOR="vim" bin/rails credentials:edit
```
Copy your file to server.
```
ssh deploy@87.106.105.31 "mkdir -p ~/apps/second_try_rr2d/shared/config/" && scp config/master.key deploy@87.106.105.31:~/apps/second_try_rr2d/shared/config/master.key
```
## Config database.yml
```
EDITOR="vim" bin/rails credentials:edit
```

```ruby
production:
  database_password: "your_password"
```


### Setup Capistrano
In `congif/deploy/production.rb`
1. Change `ip` by your IP bewteen coma ex : '192.168.0.1'
```ruby
server ip, port: 22, roles: [:web, :app, :db], primary: true
```
2. Change `git@github.com:user/your_git.git` by your repo git URL (SSH)
```ruby
set :repo_url,        'git@github.com:user/your_git.git'
```
3. Change `app_name` by the name of your app
```ruby
set :application,     'app_name'
```
4. (Maybe you don't need to change it) Change `deploy` the name of your user
```ruby
set :user,            'deploy'
```
>[!NOTE]
> You don't need to edit `Capifile` or 'config\deploy.rb'

### Put everything on your Git
```
git add * && git commit -m "First Push - Setup Done" && git push
```

## Deploy (with Capistrano)

You can now deploy. (The first deploy take some time)
```
cap production deploy
```

