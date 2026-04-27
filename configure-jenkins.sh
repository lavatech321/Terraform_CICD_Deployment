#!/bin/bash
set -e

echo "===== STOP JENKINS ====="
sudo systemctl stop jenkins || true

echo "===== DISABLE SETUP WIZARD ====="
sudo sed -i '/JENKINS_JAVA_OPTIONS/d' /etc/default/jenkins 2>/dev/null || true
echo 'JENKINS_JAVA_OPTIONS="-Djenkins.install.runSetupWizard=false"' | \
sudo tee -a /etc/default/jenkins >/dev/null

echo "===== CLEAN OLD SETUP ====="
sudo rm -f /var/lib/jenkins/secrets/initialAdminPassword
sudo rm -rf /var/lib/jenkins/users/*

echo "===== CLEAN OLD/BROKEN PLUGINS ====="
sudo rm -rf /var/lib/jenkins/plugins/*

echo "===== CREATE GROOVY INIT USER ====="
sudo mkdir -p /var/lib/jenkins/init.groovy.d

cat <<'EOF' | sudo tee /var/lib/jenkins/init.groovy.d/create-user.groovy >/dev/null
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.instanceOrNull

if (instance != null) {

  def realm = new HudsonPrivateSecurityRealm(false)
  realm.createAccount("admin","admin123")
  instance.setSecurityRealm(realm)

  def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
  strategy.setAllowAnonymousRead(false)
  instance.setAuthorizationStrategy(strategy)

  instance.save()
}
EOF

echo "===== MARK SETUP COMPLETE ====="
echo "2.0" | sudo tee /var/lib/jenkins/jenkins.install.UpgradeWizard.state >/dev/null
echo "2.0" | sudo tee /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion >/dev/null

echo "===== DOWNLOAD PLUGIN MANAGER ====="
sudo wget -q \
https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.0/jenkins-plugin-manager-2.13.0.jar \
-O /tmp/plugin-manager.jar

echo "===== RELOAD SYSTEMD ====="
sudo systemctl daemon-reload

echo "===== START JENKINS ====="
sudo systemctl start jenkins

echo "Waiting for Jenkins to initialize..."
sleep 30

echo "===== INSTALL PLUGINS ====="
sudo java -jar /tmp/plugin-manager.jar \
  --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins \
  --plugins \
    workflow-aggregator \
    git \
    credentials-binding \
  --latest false

echo "===== FIX PERMISSIONS ====="
sudo chown -R jenkins:jenkins /var/lib/jenkins

echo "===== RESTART JENKINS ====="
sudo systemctl restart jenkins

sleep 20

echo "===== VERIFY ====="
if sudo journalctl -u jenkins -n 50 | grep -Ei "failed|error"; then
  echo "❌ Plugin errors detected"
  exit 1
else
  echo "✅ Jenkins setup successful"
  echo "Login: http://<server>:8080"
  echo "Username: admin"
  echo "Password: admin123"
fi


