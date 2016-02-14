#
# fabric file for deploying
#   fab -u root -f eau/deploy.py -H dixie backup deploy
#

import fabric.api

def backup():
    fabric.api.run("rm -rf /var/www/eau-prev")
    fabric.api.run("cp -a /var/www/eau /var/www/eau-prev")
    
def deploy():
    fabric.api.local("rsync -a --copy-links --delete eau %s@%s:/var/www/." % (fabric.api.env.user, fabric.api.env.host))
    with fabric.api.cd("/var/www/eau"):
      fabric.api.run("bundle install")
      fabric.api.run("RAILS_ENV=production rake db:migrate")
    fabric.api.run("chown -R www-data.www-data /var/www/eau")
    fabric.api.run("apache2ctl graceful")
    fabric.api.run("wget https://apps.piscinedixiepool.com:8482/ -o /dev/null -O /dev/null")
    pass