#
# fabric file for deploying
#   fab -H ec2-user@apps.piscinedixiepool.com backup deploy
#
# Relies on the ssh key of runner to be in ec2-user/.ssh/authorized_keys

from invoke import task

@task
def backup(c):
    c.run("rm -rf eau-prev")
    c.run("cp -r /var/www/eau ./eau-prev")
    
@task
def deploy(c):
    c.sudo("rm -rf eau")
    c.local("rsync -vv -a --delete --exclude='vendor/*' --exclude='.git/*' --exclude=log/development.log  --exclude='tmp/*' . %s@%s:eau" % (c.user, c.host))
    c.run("cd eau && bundle install --deployment --path vendor/bundle")
    c.run("cd eau && RAILS_ENV=production bin/rails assets:precompile")
    c.run("cd eau && RAILS_ENV=production bundle exec rake db:migrate")
    c.sudo("chown -R apache:apache eau")
    c.sudo("rm -rf /var/www/eau")
    c.sudo("mv eau /var/www/.")
    c.sudo("systemctl reload httpd")
    c.run("wget http://localhost:8082/ -o /dev/null -O /dev/null")
    pass

@task
def deploy(c):
    c.run("rm -rf eau")
    c.run("git clone https://github.com/PiscineDixie/eau.git")
    c.local("rsync ./config/secrets.yml %s@%s:eau/config/." % (c.user, c.host))
    c.run("cd eau && env BUNDLE_DEPLOYMENT=1 BUNDLE_WITHOUT=development bundle install")
    c.run("cd eau && env RAILS_ENV=production bin/rails assets:precompile")
    c.run("cd eau && env RAILS_ENV=production bundle exec rake db:migrate")
    c.run("rm -rf eau/.git")
    c.sudo("chown -R apache:apache eau")
    c.sudo("rm -rf /var/www/eau")
    c.sudo("mv eau /var/www/.")
    c.sudo("systemctl reload httpd")
    c.run("wget https://apps.piscinedixiepool:8482/ -o /dev/null -O /dev/null")
    pass